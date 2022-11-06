#' @title .check_idle_sleep
#' @description Check for missing raw data in the Actigraph file
#' @param raw A data frame of the raw Actigraph data that will be checked for missing data.
#' @param epoch The epoch length for which the counts should be summed.
#' @param verbose Print the progress of the Actigraph raw data conversion to counts, Default: FALSE.
#' @return Data set with the raw missing values filled in with the last observed observation.
#' @details This function checks for missing raw data within the continuous time stamp and replaces it with the last observed observation. Missing data may occur due to an accelerometer malfunction or if the user enabled the idle sleep mode.
#' @seealso
#'  \code{\link[lubridate]{round_date}}
#'  \code{\link[zoo]{na.locf}}
#' @importFrom zoo na.locf
#' @noRd
#' @keywords internal

.check_idle_sleep <- function(raw, frequency, epoch, verbose = FALSE, tz){

  # Missing data that may be due to enabling idle sleep mode.
  # https://actigraphcorp.my.site.com/support/s/article/Idle-Sleep-Mode-Explained

  is_sleep <- .get_sleep(raw)

  if (!any(is_sleep)) return(raw)

  if (verbose) print(paste(
    "Missing data found. Carrying the last observation",
    "forward to fill in missing values in the raw data."
  ))

  raw[is_sleep, c("X", "Y", "Z")] <- NA

  if(is_sleep[1]){

    first.obs <- which(!is_sleep)[1]

    first.time.obs <-
      raw[first.obs, "time"] %>%
      lubridate::ceiling_date(paste0(epoch, "sec"))

    raw <- raw[raw$time >= first.time.obs,  ]

    full_second <-
      raw$time[1:(frequency * 2)] %>%
      lubridate::floor_date("1 sec") %>%
      as.character(.) %>%
      {rle(.)$lengths} %>%
      .[1] %>%
      {. == frequency}

    if(!full_second){
      raw <- raw[raw$time >= first.time.obs + 1,  ]
    }

  }

  raw$X <- zoo::na.locf0(raw$X)
  raw$Y <- zoo::na.locf0(raw$Y)
  raw$Z <- zoo::na.locf0(raw$Z)

  raw

}

#' @title .resample
#' @description Down sample data to a sampling frequency of 30 hertz
#' @param raw A data frame of the raw Actigraph data that will be down sampled.
#' @param verbose Print the progress of the Actigraph raw data conversion to counts, Default: FALSE.
#' @return Down sampled data
#' @details Down sample data to a sampling frequency of 30 hertz
#' @noRd
#' @keywords internal

.resample <- function(raw, frequency, verbose = FALSE){
  if(verbose){
    print("Creating Downsampled Data")
  }
  f <- .factors(frequency)
  upsample_factor = f$upsample_factor # For frequencies not divisible by 3
  downsample_factor = f$downsample_factor
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
    X <- c(utils::tail(X, 1) , utils::head(X, -1))
    X <- matrix(X, nrow = 3, byrow = TRUE)
    return(X)
  }

  if(frequency!=30){rm(raw)}

  if(!frequency %in% c(30, 60, 90)){
    upsample_data <- (a_fp * up_factor_fp) * (upsample_data + .np.roll(upsample_data))
    upsample_data <- cbind(rep(0,3), upsample_data)
    upsample_data <- upsampleC(upsample_data, b_fp)
    # for (i in 2:ncol(upsample_data)){
    #   upsample_data[, i] <- upsample_data[, i] + -b_fp * upsample_data[, i-1]
    # }
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
#' @importFrom gsignal filter_zi filter
#' @noRd
#' @keywords internal

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
#' @noRd
#' @keywords internal

.trim_data <- function(bpf_data, lfe_select=FALSE, verbose = FALSE){

  if(verbose) print("Trimming Data")

  min_count <- ifelse(lfe_select, 1, 4)
  max_count <- 128

  trim_data <-
    abs(bpf_data) %>%
    {ifelse(. < min_count, 0, .)} %>%
    pmin(max_count)

  if(lfe_select){

    mask <- (trim_data < 4) & (trim_data >= min_count)
    trim_data[mask] <- trim_data[mask] - 1

  }

  floor(trim_data)

}

#' @title .resample_10hz
#' @description Resample the filtered data from 30 hertz to 10 hertz.
#' @param trim_data Data that have been filtered by a band pass filter and Actigraph's normal or low frequency extension filter.
#' @param verbose Print the progress of the Actigraph raw data conversion to counts, Default: FALSE.
#' @return Resampled data that was converted to 10 hertz
#' @details Resample the filtered data from 30 hertz to 10 hertz.
#' @noRd
#' @keywords internal

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
#'
#' @inheritParams get_counts
#' @inheritParams calculate_counts
#'
#' @return Actigraph counts for the X, Y, and Z axes.
#'
#' @noRd
#' @keywords internal

.sum_counts <- function(raw, epoch, verbose = FALSE){
  if(verbose){
    print("Summing epochs")
  }
  # Accumulator for epoch
  block_size = epoch * 10
  epoch_counts = t(apply(raw, 1, cumsum))
  epoch_counts[, (block_size+1):ncol(epoch_counts)] <- (epoch_counts[, (block_size+1):ncol(epoch_counts)] - epoch_counts[, 1:(ncol(epoch_counts)-block_size)])
  epoch_counts <- floor(epoch_counts[, seq(block_size, ncol(epoch_counts), block_size)])
  return (epoch_counts)
}

.get_frequency <- function(raw, timevar = "time") {

  if (exists("sample_rate", attributes(raw))) return(attr(raw, "sample_rate"))

  timevar %T>%
  {stopifnot(exists(., raw))} %>%
  raw[1:min(nrow(raw), 1000), .] %>%
  lubridate::floor_date("1 sec") %>%
  table(.) %>%
  table(.) %>%
  {names(.)[which.max(.)]} %>%
  as.numeric(.) %T>%
  {if(!. %in% seq(30, 100, 10)) stop(
    "Frequency has to be 30, 40, 50, 60, 70, 80, 90 or 100 Hz"
  )}

}

.factors <- function(frequency){

  data.frame(
    upsample_factors = c(1, 3, 3, 1, 3, 3, 1, 3),
    downsample_factors = c(1, 4, 5, 2, 7, 8, 3, 10)
  ) %>%
  {.[match(frequency, c(30, 40, 50, 60, 70, 80, 90, 100)), ]} %>%
  as.list(.)

}
