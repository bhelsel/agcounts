# Copyright © 2022 University of Kansas. All rights reserved.

#' @title Read in raw acceleration data
#' @description This function reads in raw acceleration data
#'     with the pygt3x Python package, the read.gt3x R package with GGIR autocalibration, or the read.gt3x R package.
#' @param path Path name to the GT3X file or the dataset with columns time, X, Y, and Z axis
#' @param verbose Print the read method, Default: FALSE.
#' @param parser The parser to use when reading in the data. Parser values include pygt3x, GGIR, and read.gt3x options.
#' @param tz the desired timezone, Default: \code{UTC}
#' @param ... Additional arguments to pass into the agread function
#' @return Returns the raw acceleration data
#' @details This function reads in raw acceleration data
#'     with the pygt3x Python package, the read.gt3x R package with GGIR autocalibration, or the read.gt3x R package.
#' @examples
#'     agread(system.file("extdata/example.gt3x", package = "agcounts"), parser = "pygt3x")
#' @seealso
#'  \code{\link[GGIR]{g.calibrate}}
#'  \code{\link[read.gt3x]{read.gt3x}}
#' @rdname agread
#' @export
#' @importFrom reticulate import py_module_available `%as%`
#' @importFrom GGIR g.calibrate g.inspectfile
#' @importFrom read.gt3x read.gt3x

agread <- function(path, parser = c("pygt3x", "GGIR", "read.gt3x"), tz = "UTC", verbose = FALSE, ...){
  parser = match.arg(parser)

  if(parser == "pygt3x" & !reticulate::py_module_available("pygt3x")) {
    message('Python module "pygt3x" is not found. Switching parser to GGIR.')
    parser <- "GGIR"
  }
  switch(parser,
         "pygt3x" = .pygt3xReader(path = path, verbose = verbose, ...),
         "GGIR" = .ggirReader(path = path, verbose = verbose, ...),
         "read.gt3x" = .gt3xReader(path = path, verbose = verbose, ...),
         stop("No method exists yet for ", sQuote(parser), call. = FALSE)
  )
}

.pygt3xReader <- function(path, tz = "UTC", verbose = FALSE, ...){
  reader <- NULL
  if(!reticulate::py_module_available("pygt3x")) stop('Python module "pygt3x" not found.')
  if(verbose) print("Reading and calibrating data with pygt3x.")
  `%as%` <- reticulate::`%as%`
  # Import Modules
  Reader <- reticulate::import("pygt3x.reader", convert = FALSE)
  pd <- reticulate::import("pandas")
  reset_index <- pd$core$frame$DataFrame$reset_index
  # Import Classes
  FileReader <- Reader$FileReader
  to_pandas <- FileReader$to_pandas
  # Read and calibrate data
  with(FileReader(path) %as% reader, {
    raw = to_pandas(reader)
    raw = reset_index(raw)})
  # Return Data
  colnames(raw) <- c("time", "X", "Y", "Z")
  raw$time <- as.POSIXct(raw$time, origin = "1970-01-01 00:00:00", tz=tz)
  meta <- read.gt3x::parse_gt3x_info(path)
  attr(raw, "start_time") <- meta$`Start Date` %>% lubridate::force_tz(tz)
  attr(raw, "stop_time") <- meta$`Stop Date` %>% lubridate::force_tz(tz)
  raw
}

.ggirReader <- function(path, tz = "UTC", verbose = FALSE, ...){
  if(verbose) print("Reading data with read.gt3x and calibrating with GGIR.")
  I <- GGIR::g.inspectfile(datafile = path)
  C <- GGIR::g.calibrate(datafile = path, use.temp = FALSE, printsummary = FALSE, inspectfileobject = I)
  raw <- read.gt3x::read.gt3x(path, asDataFrame = TRUE, imputeZeroes = TRUE)
  raw[, 2:4] <- scale(raw[, 2:4], center = -C$offset, scale = 1/C$scale)
  if(C$nhoursused==0) message("\n There is not enough data to perform the GGIR autocalibration method. Returning data as read by read.gt3x.")
  raw
}

.gt3xReader <- function(path, tz = "UTC", verbose = FALSE, ...){
  if(verbose) print("Reading data with read.gt3x.")
  raw <- read.gt3x::read.gt3x(path, asDataFrame = TRUE, imputeZeroes = TRUE)
  raw$time <- lubridate::force_tz(raw$time, tzone = tz)
  raw
}

#' @title Calibrate acceleration data
#' @description This function uses a C++ implementation of the GGIR `g.calibrate` function.
#' @param raw data frame of raw acceleration data obtained from
#' @param verbose Print the progress of the calibration for the raw data, Default: FALSE
#' @param tz the desired timezone, Default: \code{UTC}
#' @param imputeTimeGaps Imputes gaps in the raw acceleration data, Default: FALSE
#' @param spherecrit The minimum required acceleration value (in g) on both sides of 0 g
#' for each axis. Used to judge whether the sphere is sufficiently populated
#' @param sdcriter Criteria to define non-wear time, defined as the estimated noise
#' measured in the raw accelerometer data.
#' @param minloadcrit The minimum number of hours the code needs to read for the
#' autocalibration procedure to be effective (only sensitive to multitudes
#' of 12 hrs, other values will be ceiled)
#' @param debug print out diagnostic information for C++ code
#' @param ... Additional arguments to pass into the agread function
#' @return Returns the calibrated raw acceleration data
#' @details This function uses a C++ implementation of the GGIR `g.calibrate` function to
#' return calibrated raw acceleration data.
#' @examples
#'    path <- system.file("extdata/example.gt3x", package = "agcounts")
#'    data <- read.gt3x::read.gt3x(path, asDataFrame = TRUE)
#'    data <- agcalibrate(raw = data)
#' @seealso
#'  \code{\link[lubridate]{force_tz}}
#' @rdname agcalibrate
#' @export
#' @importFrom lubridate force_tz
#' @importFrom data.table setDT setDF


agcalibrate <- function(raw, verbose = FALSE, tz = "UTC", imputeTimeGaps = FALSE,
                        spherecrit = 0.3, sdcriter = 0.013, minloadcrit = 168L, debug = FALSE, ...){

  if(any(.get_sleep(raw))) stop("Calibration requires the data to be imported without imputed zeros.")
  sf = .get_frequency(raw)
  is.wholenumber <- function(x, tol = .Machine$double.eps^0.5) {
    abs(x - round(x)) < tol
  }
  stopifnot(
    is.numeric(spherecrit) && length(spherecrit) == 1,
    is.numeric(sdcriter) && length(sdcriter) == 1,
    is.wholenumber(minloadcrit) && length(minloadcrit) == 1
  )
  spherecrit = as.double(spherecrit)
  sdcriter = as.double(sdcriter)
  minloadcrit = as.integer(minloadcrit)
  C <- gcalibrateC(dataset = as.matrix(raw[, c("X", "Y", "Z")]),
                   sf = sf, spherecrit = spherecrit,
                   sdcriter = sdcriter, minloadcrit = minloadcrit,
                   debug = as.logical(debug))

  if(imputeTimeGaps){
    if("last_sample_time" %in% names(attributes(raw))){
      last_sample_time <- attr(raw, "last_sample_time") - 1
    } else{
      last_sample_time <- raw[nrow(raw), 1, drop = TRUE]
    }
    timestamps <- last_sample_time %>%
      seq(raw[1, 1, drop = TRUE], ., 1/sf) %>%
      lubridate::force_tz(tz) %>%
      data.frame(time = .)
    raw = data.table::setDF(merge(data.table::setDT(timestamps), data.table::setDT(raw), by = "time", all = TRUE))
    raw[is.na(raw)] <- 0
  }

  raw[, c("X", "Y", "Z")] <- scale(raw[, c("X", "Y", "Z")], center = -C$offset, scale = 1/C$scale)
  if(C$nhoursused==0) message("\n There is not enough data to perform the GGIR calibration method. Returning data as read by read.gt3x.")
  attr(raw, "offset") = C$offset
  attr(raw, "scale") = C$scale
  raw
}

#' @title Read ActiGraph AGD Files
#' @description Read the settings or data from the ActiGraph AGD Files
#' @param path The path to the AGD file or the filename if the AGD file is in the current working directory
#' @return Returns a list containing the filter type, epoch length, and the data.
#' @details Read the filter type, epoch length, and data from the ActiGraph AGD Files
#' @rdname .read_agd
#' @noRd
#' @keywords internal
#' @importFrom DBI dbConnect dbReadTable dbDisconnect
#' @importFrom RSQLite SQLite

.read_agd <- function(path) {
  con <- DBI::dbConnect(RSQLite::SQLite(), path)
  settings <- DBI::dbReadTable(con, "settings")
  filter <- settings[settings["settingName"]=="filter", "settingValue"]
  epoch_length <- as.numeric(settings[settings["settingName"]=="epochlength", "settingValue"])
  data <- DBI::dbReadTable(con, "data")
  data$dataTimestamp <- as.POSIXct((data$dataTimestamp / 1e7), origin = "0001-01-01 00:00:00", tz = "UTC")
  if("axis3" %in% colnames(data)){
    data <- data[, 1:4] %>% `colnames<-`(c("time", "Axis1", "Axis2", "Axis3"))
    data$Vector.Magnitude <- round((sqrt(data$Axis1^2 + data$Axis2^2 + data$Axis3^2)))
  }
  DBI::dbDisconnect(con)
  return(list(filter = filter, epoch_length = epoch_length, data = data))
}







