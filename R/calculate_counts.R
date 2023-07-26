# Copyright © 2022 University of Kansas. All rights reserved.
#
# Creative Commons Attribution NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

#' @title calculate_counts
#' @description Calculate ActiGraph activity counts from raw acceleration data
#'     by passing in a data frame with a time stamp, X, Y, and Z axis. This function
#'     allows the ability to work with the raw data from other files, but the data
#'     frame needs to have "start_time" and "stop_time" attributes. This is different
#'     from the \code{\link{get_counts}} function because it reads a raw
#'     data frame rather than a path name to a GT3X file.
#' @param raw data frame of raw acceleration data obtained from
#'   \code{\link[read.gt3x]{read.gt3x}}
#' @inheritParams get_counts
#' @export
#' @examples
#' f <- system.file("extdata/example.gt3x", package = "agcounts")
#' d <- read.gt3x::read.gt3x(f, asDataFrame = TRUE, imputeZeroes = TRUE)
#' calculate_counts(d, 60)
calculate_counts <- function(
  raw, epoch, lfe_select = FALSE,
  tz = "UTC", verbose = FALSE
) {

  #* Determine the complete time range that should be represented in the file

    frequency <- .get_frequency(raw)
    timestamps <- .get_timestamps(raw, epoch, frequency, tz)


  #* Now calculate counts

    raw <- .check_idle_sleep(raw, frequency, epoch, verbose, tz)

    data_start <-
      raw[["time"]][1] %>%
      format("%Y-%m-%d %H:%M:%S") %>%
      as.POSIXct(tz) %>%
      lubridate::floor_date(paste(epoch, "secs"))

    if(data_start != raw[1, "time"]){
      raw <-
        seq(data_start, (raw[1, "time"]-1), 1/frequency) %>%
        {data.frame(
          time = as.POSIXct(., tz), X = rep(raw[1, "X"], length(.)),
          Y = rep(raw[1, "Y"], length(.)), Z = rep(raw[1, "Z"], length(.))
        )} %>%
        rbind(raw)
    }

    epoch_counts <-
      .resample(raw, frequency, verbose) %!>%
      .bpf_filter(verbose) %!>%
      .trim_data(lfe_select, verbose) %!>%
      .resample_10hz(verbose) %!>%
      .sum_counts(epoch, verbose) %!>%
      t(.) %>%
      data.frame(stringsAsFactors = FALSE) %>%
      .[c("Y", "X", "Z")] %>%
      stats::setNames(c("Axis1", "Axis2", "Axis3")) %>%
      within({Vector.Magnitude = round(sqrt(
        Axis1^2 + Axis2^2 + Axis3^2
      ))}) %>%
      data.frame(
        time = seq(data_start, by = epoch, length.out = nrow(.)),
        .
      )

  #* Add 0-count rows for any missing times, then return

    as.character(timestamps$timestamps) %>%
    setdiff(as.character(epoch_counts$time)) %>%
    {data.frame(
      time = as.POSIXct(., tz), Axis1 = rep(0, length(.)),
      Axis2 = rep(0, length(.)), Axis3 = rep(0, length(.)),
      Vector.Magnitude = rep(0, length(.)), stringsAsFactors = FALSE
    )} %>%
    rbind(epoch_counts) %>%
    .[order(.$time), ] %>%
    structure(., row.names = seq(nrow(.)))

}
