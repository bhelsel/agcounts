#' @title get_counts
#' @description Main function to extract counts from the Actigraph GT3X Files.
#' @param path Full path name to the GT3X File
#' @param frequency Sampling frequency in hertz. Sampling frequency must be a multiple of 10 between 30 and 100 hertz.
#' @param epoch The epoch length for which the counts should be summed.
#' @param lfe_select Apply the Actigraph Low Frequency Extension filter, Default: FALSE
#' @param write.file Export a CSV file of the counts, Default: TRUE
#' @param return.data Return the data frame to the R Global Environment, Default: FALSE
#' @param verbose Print the progress of the Actigraph raw data conversion to counts, Default: FALSE.
#' @return Returns a CSV file if write.file is TRUE or a data frame if return.data is TRUE
#' @details Main function to extract counts from the Actigraph GT3X Files.
#' @examples agcounts::get_counts(path = "filename.gt3x", frequency = 60, epoch = 60, lfe_select = FALSE, write.file = FALSE, return.data = TRUE)
#' @seealso
#'  \code{\link[read.gt3x]{read.gt3x}},\code{\link[read.gt3x]{read_gt3x}}
#' @rdname get_counts
#' @export
#' @importFrom read.gt3x read.gt3x

get_counts <- function(path, frequency, epoch, lfe_select = FALSE, write.file = TRUE, return.data = FALSE, verbose = FALSE){
  if(!frequency %in% seq(30, 100, 10)){
    stop(paste0("Frequency has to be 30, 40, 50, 60, 70, 80, 90 or 100 Hz"))
  }
  if(verbose){
    print(paste0("------------------------- ", "Reading ActiGraph GT3X File for ", basename(path), " -------------------------"))
  }

  raw <- read.gt3x::read.gt3x(path = path, asDataFrame = TRUE, imputeZeroes = TRUE)
  start <- as.POSIXct(format(attr(raw, "start_time"), "%Y-%m-%d %H:%M:%S"), "%Y-%m-%d %H:%M:%S", tz = "America/Chicago")
  end <- as.POSIXct(format(attr(raw, "stop_time"), "%Y-%m-%d %H:%M:%S"), "%Y-%m-%d %H:%M:%S", tz = "America/Chicago")
  raw <- .check_idle_sleep(raw = raw, frequency = frequency, epoch = epoch, verbose = verbose)
  downsample_data <- .resample(raw = raw, frequency = frequency, verbose = verbose)
  bpf_data <- .bpf_filter(downsample_data = downsample_data, verbose = verbose)
  trim_data <- .trim_data(bpf_data = bpf_data, lfe_select=lfe_select, verbose = verbose)
  downsample_10hz <- .resample_10hz(trim_data = trim_data, verbose = verbose)
  epoch_counts <- data.frame(t(.sum_counts(downsample_10hz = downsample_10hz, epoch_seconds = epoch, verbose = verbose)))
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

#' @title .check_idle_sleep
#' @description Check for missing raw data in the Actigraph file
#' @param raw A data frame of the raw Actigraph data that will be checked for missing data.
#' @param frequency Sampling frequency in hertz. Sampling frequency must be a multiple of 10 between 30 and 100 hertz.
#' @param epoch The epoch length for which the counts should be summed.
#' @param verbose Print the progress of the Actigraph raw data conversion to counts, Default: FALSE.
#' @return Data set with the raw missing values filled in with the last observed observation.
#' @details This function checks for missing raw data within the continuous time stamp and replaces it with the last observed observation. Missing data may occur due to an accelerometer malfunction or if the user enabled the idle sleep mode.
#' @seealso
#'  \code{\link[lubridate]{round_date}}
#'  \code{\link[zoo]{na.locf}}
#' @rdname .check_idle_sleep
#' @export
#' @importFrom lubridate ceiling_date
#' @importFrom zoo na.locf
#' @noRd

.check_idle_sleep <- function(raw, frequency, epoch, verbose = FALSE){
  # Missing data that may be due to enabling idle sleep mode.
  # https://actigraphcorp.my.site.com/support/s/article/Idle-Sleep-Mode-Explained
  if(nrow(raw[raw$X==0 & raw$Y==0 & raw$Z==0, ]) != 0){
    if(verbose){
      print("Missing data found. Carrying the last observation forward to fill in missing values in the raw data.")
    }
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

#' @title .resample
#' @description Down sample data to a sampling frequency of 30 hertz
#' @param raw A data frame of the raw Actigraph data that will be down sampled.
#' @param frequency Sampling frequency in hertz. Sampling frequency must be a multiple of 10 between 30 and 100 hertz.
#' @param verbose Print the progress of the Actigraph raw data conversion to counts, Default: FALSE.
#' @return Down sampled data
#' @details Down sample data to a sampling frequency of 30 hertz
#' @rdname .resample
#' @export
#' @noRd

.resample <- function(raw, frequency, verbose = FALSE){
  if(verbose){
    print("Creating Downsampled Data")
  }
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

#' @title .bpf_filter
#' @description Band pass filter for down sampled Actigraph data
#' @param downsample_data Down sampled Actigraph data from the GT3X file
#' @param verbose Print the progress of the Actigraph raw data conversion to counts, Default: FALSE.
#' @return Band pass filtered data
#' @details Band pass filter for down sampled Actigraph data
#' @seealso
#'  \code{\link[gsignal]{filter_zi}},\code{\link[gsignal]{filter}}
#' @rdname .bpf_filter
#' @export
#' @importFrom gsignal filter_zi filter
#' @noRd

.bpf_filter <- function(downsample_data, verbose = FALSE){
  if(verbose){
    print("Filtering Data")
  }
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

#' @title .trim_data
#' @description Adds the Actigraph normal or low frequency extension filters to the band pass filtered data.
#' @param bpf_data The raw Actigraph data after it has passed through the band pass filter.
#' @param lfe_select An option to add the low frequency extension filter instead of the normal filter, Default: FALSE
#' @param verbose Print the progress of the Actigraph raw data conversion to counts, Default: FALSE.
#' @return Data that have been filtered by Actigraph's normal or low frequency extension filter.
#' @details Adds the Actigraph normal or low frequency extension filters to the band pass filtered data.
#' @rdname .trim_data
#' @export
#' @noRd

.trim_data <- function(bpf_data, lfe_select=FALSE, verbose = FALSE){
  if(verbose){
    print("Trimming Data")
  }
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

#' @title .resample_10hz
#' @description Resample the filtered data from 30 hertz to 10 hertz.
#' @param trim_data Data that have been filtered by a band pass filter and Actigraph's normal or low frequency extension filter.
#' @param verbose Print the progress of the Actigraph raw data conversion to counts, Default: FALSE.
#' @return Resampled data that was converted to 10 hertz
#' @details Resample the filtered data from 30 hertz to 10 hertz.
#' @rdname .resample_10hz
#' @export
#' @noRd

.resample_10hz <- function(trim_data, verbose = FALSE){
  if(verbose){
    print("Getting data back to 10Hz for accumulation")
  }
  downsample_10hz = t(apply(trim_data, 1, cumsum))
  downsample_10hz[, 4:ncol(downsample_10hz)] <- downsample_10hz[, 4:ncol(downsample_10hz)] - downsample_10hz[, 1:(ncol(downsample_10hz)-3)]
  downsample_10hz = floor((downsample_10hz[, seq((4-1), ncol(downsample_10hz), 3)] / 3))
  return (downsample_10hz)
}

#' @title .sum_counts
#' @description Add the counts over the specified epoch.
#' @param downsample_10hz Resampled data that was converted to 10 hertz
#' @param epoch_seconds The epoch length to sum the counts.
#' @param verbose Print the progress of the Actigraph raw data conversion to counts, Default: FALSE.
#' @return Actigraph counts for the X, Y, and Z axes.
#' @details Add the counts over the specified epoch.
#' @rdname .sum_counts
#' @export
#' @noRd

.sum_counts <- function(downsample_10hz, epoch_seconds, verbose = FALSE){
  if(verbose){
    print("Summing epochs")
  }
  # Accumulator for epoch
  block_size = epoch_seconds * 10
  epoch_counts = t(apply(downsample_10hz, 1, cumsum))
  epoch_counts[, (block_size+1):ncol(epoch_counts)] <- (epoch_counts[, (block_size+1):ncol(epoch_counts)] - epoch_counts[, 1:(ncol(epoch_counts)-block_size)])
  epoch_counts <- floor(epoch_counts[, seq(block_size, ncol(epoch_counts), block_size)])
  return (epoch_counts)
}
