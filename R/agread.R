#' @title Read in raw acceleration data
#' @description This generic function reads in calibrated raw acceleration data
#'     from the python module pygt3x or the R GGIR package or uncalibrated data
#'     from the read.gt3x package.
#' @param path Path name to the GT3X file or the dataset with columns time, X, Y, and Z axis
#' @param verbose Print the read method, Default: FALSE.
#' @param parser The parser to use when reading in the data. Parser values include pygt3x, ggir, and uncalibrated readers
#' @param tz the desired timezone, Default: \code{UTC}
#' @param ... Additional arguments to pass into the agread function
#' @return Returns the calibrated or uncalibrated raw acceleration data
#' @details This function reads in calibrated raw acceleration data from GGIR or pygt3x.
#' @examples
#' \dontrun{
#'    agread(system.file("extdata/example.gt3x", package = "agcounts"), parser = "pygt3x")
#' }
#' @rdname agread
#' @importFrom utils installed.packages
#' @importFrom reticulate import py_module_available `%as%` py_to_r
#' @export

agread <- function(path, parser = c("pygt3x", "ggir", "uncalibrated"), tz = "UTC", verbose = FALSE, ...){
  parser = match.arg(parser)

  if(parser == "pygt3x" & !reticulate::py_module_available("pygt3x")) {
    message('Python module "pygt3x" is not found. Switching parser to GGIR.')
    parser <- "ggir"
  }
  switch(parser,
         "pygt3x" = .pygt3xReader(path = path, verbose = verbose, ...),
         "ggir" = .ggirReader(path = path, verbose = verbose, ...),
         "uncalibrated" = .uncalibratedReader(path = path, verbose = verbose, ...),
         stop("No method exists yet for ", sQuote(parser), call. = FALSE)
         )
}

.pygt3xReader <- function(path, parser = c("pygt3x", "ggir", "gt3x"), tz = "UTC", verbose = FALSE, ...){
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
  raw
}

.ggirReader <- function(path, parser = c("pygt3x", "ggir", "gt3x"), tz = "UTC", verbose = FALSE, ...){
  if(verbose) print("Reading data with read.gt3x and calibrating with GGIR.")
  C <- GGIR::g.calibrate(datafile = path, use.temp = FALSE, printsummary = FALSE)
  raw <- read.gt3x::read.gt3x(path, asDataFrame = TRUE, imputeZeroes = TRUE)
  raw[, 2:4] <- scale(raw[, 2:4], center = -C$offset, scale = 1/C$scale)
  if(C$nhoursused==0) message("\n There is not enough data to perform the GGIR calibration method. Returning uncalibrated data.")
  raw
}

.uncalibratedReader <- function(path, parser = c("pygt3x", "ggir", "gt3x"), tz = "UTC", verbose = FALSE, ...){
  if(verbose) print("Reading uncalibrated with read.gt3x.")
  raw <- read.gt3x::read.gt3x(path, asDataFrame = TRUE, imputeZeroes = TRUE)
  raw
}

#' @title Calibrate acceleration data
#' @description This function uses a C++ implementation of the GGIR `g.calibrate` function.
#' @param raw data frame of raw acceleration data obtained from
#' @param verbose Print the progress of the calibration for the raw data, Default: FALSE
#' @param tz the desired timezone, Default: \code{UTC}
#' @param ... Additional arguments to pass into the agread function
#' @return Returns the calibrated raw acceleration data
#' @details This function uses a C++ implementation of the GGIR `g.calibrate` function to
#' return calibrated raw acceleration data.
#' @examples
#' \dontrun{
#'    path <- system.file("extdata/example.gt3x", package = "agcounts")
#'    data <- read.gt3x::read.gt3x(path, asDataFrame = TRUE)
#'    data <- agcalibrate(raw = data)
#' }
#' @seealso
#'  \code{\link[lubridate]{force_tz}}
#' @rdname agcalibrate
#' @export
#' @importFrom lubridate force_tz


agcalibrate <- function(raw, verbose = FALSE, tz = "UTC", ...){
  if(any(.get_sleep(raw))) stop("Calibration requires the data to be imported without imputed zeros.")
  sf = .get_frequency(raw)
  C <- gcalibrateC(dataset = as.matrix(raw[, c("X", "Y", "Z")]), sf = sf)
  timestamps = seq(raw[1, 1], raw[nrow(raw), 1], 1/sf) %>% lubridate::force_tz(tz) %>% data.frame(time = .)
  raw = merge(timestamps, raw, by = "time", all = TRUE)
  raw[which(is.na(raw[, 2])), 2] <- 0
  raw[which(is.na(raw[, 3])), 3] <- 0
  raw[which(is.na(raw[, 4])), 4] <- 0
  raw[, c("X", "Y", "Z")] <- scale(raw[, c("X", "Y", "Z")], center = -C$offset, scale = 1/C$scale)
  if(C$nhoursused==0) message("\n There is not enough data to perform the GGIR calibration method. Returning uncalibrated data.")
  raw
}
