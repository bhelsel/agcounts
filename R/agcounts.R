get_counts <- function(path, frequency, epoch, lfe_select = FALSE, write.file = TRUE, return.data = FALSE){
  if(!frequency %in% seq(30, 100, 10)){
    stop(paste0("Frequency has to be 30, 40, 50, 60, 70, 80, 90 or 100 Hz"))
  }
  print("Reading ActiGraph GT3X File")
  raw <- read.gt3x::read.gt3x(path = path, asDataFrame = TRUE, imputeZeroes = TRUE)
  start <- as.POSIXct(format(attr(raw, "start_time"), "%Y-%m-%d %H:%M:%S"), "%Y-%m-%d %H:%M:%S", tz = "America/Chicago")
  end <- as.POSIXct(format(attr(raw, "stop_time"), "%Y-%m-%d %H:%M:%S"), "%Y-%m-%d %H:%M:%S", tz = "America/Chicago")
  raw <- .check_idle_sleep(raw = raw, frequency = frequency, epoch = epoch)
  downsample_data <- .resample(raw = raw, frequency = frequency)
  bpf_data <- .bpf_filter(downsample_data = downsample_data)
  trim_data <- .trim_data(bpf_data = bpf_data, lfe_select=lfe_select)
  downsample_10hz <- .resample_10hz(trim_data = trim_data)
  epoch_counts <- data.frame(t(.sum_counts(downsample_10hz = downsample_10hz, epoch_seconds = epoch)))
  epoch_counts <- epoch_counts[c("Y", "X", "Z")]
  colnames(epoch_counts) <- c("Axis1", "Axis2", "Axis3")
  epoch_counts$`Vector Magnitude` <- round((sqrt(epoch_counts$Axis1^2 + epoch_counts$Axis2^2 + epoch_counts$Axis3^2)))

  first.time.obs <- as.POSIXct(format(raw[1, "time"], "%Y-%m-%d %H:%M:%S"), "%Y-%m-%d %H:%M:%S", tz = "America/Chicago")
  if(start == first.time.obs){
    epoch_counts <- cbind(time = seq(from = start, by = epoch, length.out = nrow(epoch_counts)), epoch_counts)
  }

  if(start != first.time.obs){
    last.missing.time <- as.POSIXct(format(raw[1, "time"], "%Y-%m-%d %H:%M:%S"), "%Y-%m-%d %H:%M:%S", tz = "America/Chicago") - epoch
    missing.timestamps <- cbind(time = rev(seq(to = start, from = last.missing.time, by = -epoch)), matrix(0, ncol = 4, nrow = length(rev(seq(to = start, from = last.missing.time, by = -epoch)))))
    colnames(missing.timestamps) <- c("time", "Axis1", "Axis2", "Axis3", "Vector Magnitude")
    epoch_counts <- cbind(time = seq(from = first.time.obs, by = epoch, length.out = nrow(epoch_counts)), epoch_counts)
    epoch_counts <- rbind(missing.timestamps, epoch_counts)
    epoch_counts$time <- as.POSIXct(epoch_counts$time, origin = "1970-01-01")
  }

  if(write.file){
    if(lfe_select){name <- paste0("AG ", epoch, "s", " LFE ", "Epoch Counts")}
    if(!lfe_select){name <- paste0("AG ", epoch, "s", " Epoch Counts")}
    if(!dir.exists(paste0(dirname(path), "/", name))){dir.create(paste0(dirname(path), "/", name))}
    write.csv(epoch_counts, file = paste0(dirname(path), "/", name, "/", strsplit(basename(path), "[.]")[[1]][1], ".csv"), row.names = FALSE)
  }

  if(return.data){
    return(epoch_counts)
  }

}

# Input data coefficients.
.coefficients = list(
  input_coefficients = c("-0.009341062898525", "-0.025470289659360", "-0.004235264826105", "0.044152415456420", "0.036493718347760", "-0.011893961934740", "-0.022917390623150", "-0.006788163862310", "0.000000000000000"),
  output_coefficients = c("1.00000000000000000000", "-3.63367395910957000000", "5.03689812757486000000", "-3.09612247819666000000", "0.50620507633883000000", "0.32421701566682000000", "-0.15685485875559000000", "0.01949130205890000000", "0.00000000000000000000")
  )

.factors <- function(frequency){
  factors <- list(hertz = c(30, 40, 50, 60, 70, 80, 90, 100),
                  upsample_factors = c(1, 3, 3, 1, 3, 3, 1, 3),
                  downsample_factors = c(1, 4, 5, 2, 7, 8, 3, 10))
  position <- which(factors$hertz==frequency)
  upsample_factor <- factors[["upsample_factors"]][position]
  downsample_factor <- factors[["downsample_factors"]][position]
  return(list(upsample_factor = upsample_factor, downsample_factor = downsample_factor))
}

.check_idle_sleep <- function(raw, frequency, epoch){
  # Missing data that may be due to enabling idle sleep mode.
  # https://actigraphcorp.my.site.com/support/s/article/Idle-Sleep-Mode-Explained
  if(nrow(raw[raw$X==0 & raw$Y==0 & raw$Z==0, ]) != 0){
    print("Missing data found. Carrying the last observation forward to fill in missing values in the raw data.")
    raw[raw$X==0 & raw$Y==0 & raw$Z==0, c("X", "Y", "Z")] <- NA
    if(is.na(raw[1, "X"]) & is.na(raw[1, "Y"]) & is.na(raw[1, "Z"])){
      first.obs <- min(which(!is.na(raw[, "X"]) & !is.na(raw[, "Y"]) & !is.na(raw[, "Z"])))
      first.time.obs <- format(lubridate::ceiling_date(raw[first.obs, "time"], unit = paste0(epoch, "sec")), "%Y-%m-%d %H:%M:%S")
      count <- length(raw[format(raw$time, "%Y-%m-%d %H:%M:%S") == first.time.obs, "time"])
      if(count == frequency){
        raw <- raw[min(which(format(raw$time, "%Y-%m-%d %H:%M:%S") == first.time.obs)):nrow(raw), ]
      }
      if(count != frequency){
        first.time.obs <- format(as.POSIXct(first.time.obs, "%Y-%m-%d %H:%M:%S", tz = "America/Chicago") + 1, "%Y-%m-%d %H:%M:%S")
        raw <- raw[format(raw$time, "%Y-%m-%d %H:%M:%S") >= first.time.obs,  ]
      }
    }
    raw$X <- zoo::na.locf(raw$X)
    raw$Y <- zoo::na.locf(raw$Y)
    raw$Z <- zoo::na.locf(raw$Z)
  }
  return(raw)
}

.resample <- function(raw, frequency){
  print("Creating Downsampled Data")
  upsample_factor = .factors(frequency)$upsample_factor # For frequencies not divisible by 3
  downsample_factor = .factors(frequency)$downsample_factor
  raw = t(as.matrix(raw[c("X", "Y", "Z")]))
  m = nrow(raw)
  n = ncol(raw)
  upsample_data = matrix(data = 0, nrow = m, ncol = n * upsample_factor)
  upsample_data[1:3, seq(1, ncol(upsample_data), upsample_factor)] <- raw[1:3, ]
  a_fp = pi / (pi + 2 * upsample_factor)
  b_fp = (pi - 2 * upsample_factor) / (pi + 2 * upsample_factor)
  up_factor_fp = upsample_factor

  .np.roll <- function(X){
    X <- as.vector(c(X[1, ], X[2, ], X[3, ]))
    X <- c(tail(X, 1) , head(X, -1))
    X <- matrix(X, nrow = 3, byrow = TRUE)
    return(X)
  }

  if(frequency!=30){rm(raw)}

  if(!frequency %in% c(30, 60, 90)){
    upsample_data <- (a_fp * up_factor_fp) * (upsample_data + .np.roll(upsample_data))
    upsample_data <- cbind(rep(0,3), upsample_data)
    for (i in 2:ncol(upsample_data)){
      upsample_data[, i] <- upsample_data[, i] + -b_fp * upsample_data[, i-1]
    }
    upsample_data <- upsample_data[, -1]
  }

  if(frequency == 30){
    downsample_data = raw
    rm(raw)
  } else{
    downsample_data = upsample_data[, seq(1, ncol(upsample_data), downsample_factor)]
  }

  downsample_data = round(downsample_data, 3)
  if(is.null(rownames(downsample_data))){
    rownames(downsample_data) <- c("X", "Y", "Z")
  }
  return(downsample_data)
}

.bpf_filter <- function(downsample_data){
  print("Filtering Data")
  a = as.numeric(.coefficients$output_coefficients)
  b = as.numeric(.coefficients$input_coefficients)
  zi <- gsignal::filter_zi(filt = b, a = a)
  zi <- matrix(rep(zi, 3), nrow = 3, byrow = 3) * downsample_data[, 1]
  rownames(zi) <- c("X", "Y", "Z")
  bpf_data_x <- gsignal::filter(filt = b, a = a, x = downsample_data["X", ], zi = zi["X", ])
  bpf_data_y <- gsignal::filter(filt = b, a = a, x = downsample_data["Y", ], zi = zi["Y", ])
  bpf_data_z <- gsignal::filter(filt = b, a = a, x = downsample_data["Z", ], zi = zi["Z", ])
  bpf_data <- matrix(rbind(bpf_data_x$y, bpf_data_y$y, bpf_data_z$y), nrow = 3)
  bpf_data = ((3.0 / 4096.0) / (2.6 / 256.0) * 237.5) * bpf_data # 17.127404 is used in ActiLife and 17.128125 is used in firmware.
  rownames(bpf_data) <- c("X", "Y", "Z")
  return(bpf_data)
}

.trim_data <- function(bpf_data=bpf_data, lfe_select=lfe_select){
  print("Trimming Data")
  if(lfe_select){
    min_count <- 1
    max_count <- 128 * 1
    trim_data <- abs(bpf_data)
    trim_data[(trim_data < min_count) & (trim_data >= 4)] <- 0
    trim_data[trim_data > max_count] <- max_count
    mask <- (trim_data < 4) & (trim_data >= min_count)
    trim_data[mask] <- abs(trim_data[mask]) - 1
    trim_data <- floor(trim_data)
  }
  if(!lfe_select){
    min_count <- 4
    max_count <- 128
    trim_data <- abs(bpf_data)
    trim_data[trim_data < min_count] <- 0
    trim_data[trim_data > max_count] <- max_count
    trim_data <- floor(trim_data)
  }
  return(trim_data)
}

.resample_10hz <- function(trim_data){
  print("Getting data back to 10Hz for accumulation")
  # hackish downsample to 10 Hz
  downsample_10hz = t(apply(trim_data, 1, cumsum))
  downsample_10hz[, 4:ncol(downsample_10hz)] <- downsample_10hz[, 4:ncol(downsample_10hz)] - downsample_10hz[, 1:(ncol(downsample_10hz)-3)]
  downsample_10hz = floor((downsample_10hz[, seq((4-1), ncol(downsample_10hz), 3)] / 3))
  return (downsample_10hz)
}

.sum_counts <- function(downsample_10hz, epoch_seconds){
  print("Summing epochs")
  # Accumulator for epoch
  block_size = epoch_seconds * 10
  epoch_counts = t(apply(downsample_10hz, 1, cumsum))
  epoch_counts[, (block_size+1):ncol(epoch_counts)] <- (epoch_counts[, (block_size+1):ncol(epoch_counts)] - epoch_counts[, 1:(ncol(epoch_counts)-block_size)])
  epoch_counts <- floor(epoch_counts[, seq(block_size, ncol(epoch_counts), block_size)])
  return (epoch_counts)
}
