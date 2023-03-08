#' @title Read in raw acceleration data
#' @description This generic function reads in calibrated raw acceleration data
#'     from the python module pygt3x or the R GGIR package or uncalibrated data
#'     from the read.gt3x package.
#' @param raw Path name to the GT3X file or the dataset with columns time, X, Y, and Z axis
#' @param verbose Print the read method, Default: FALSE.
#' @param parser The parser to use when reading in the data. Parser values include pygt3x, ggir, and gt3x (uncalibrated reader)
#' @param tz the desired timezone, Default: \code{UTC}
#' @param ... Additional arguments to pass into the agread S3 generic function
#' @return Returns the raw acceleration signal
#' @details This generic function reads in calibrated raw acceleration data
#'     from the python module pygt3x or the R read.gt3x and GGIR packages.
#' @examples
#' \dontrun{
#'    agread(system.file("extdata/example.gt3x", package = agcounts))
#' }
#' @rdname agread
#' @importFrom utils installed.packages
#' @importFrom reticulate import py_module_available `%as%` py_to_r
#' @export

agread <- function(raw, verbose = FALSE, parser = c("pygt3x", "ggir", "gt3x"), tz = "UTC", ...){
  parser = match.arg(parser)
  UseMethod("agread")

}

#' @inheritParams agread
#' @export
agread.character <- function(raw, verbose = FALSE, parser = c("pygt3x", "ggir", "gt3x"), tz = "UTC", ...){
  if(parser == "pygt3x" & !reticulate::py_module_available("pygt3x")) {
    message('Python module "pygt3x" is not found. Switching parser to GGIR.')
    parser <- "GGIR"
  }
  switch(parser,
         "pygt3x" = .pygt3xReader(raw = raw, verbose = verbose, ...),
         "ggir" = .ggirReader(raw = raw, verbose = verbose, ...),
         "gt3x" = .gt3xReader(raw = raw, verbose = verbose, ...),
         stop("No method exists yet for ", sQuote(parser), call. = FALSE)
         )
}


#' @inheritParams agread
#' @export
agread.activity_df <- function(raw, verbose = FALSE, parser = c("pygt3x", "ggir", "gt3x"), tz = "UTC", ...){
  .ggirReader(raw = raw, verbose = verbose)
}


.pygt3xReader <- function(raw, verbose = FALSE, parser = c("pygt3x", "ggir", "gt3x"), tz = "UTC", ...){
  if(!reticulate::py_module_available("pygt3x")) {
    stop('Python module "pygt3x" not found. Install it or use a different method.')
  }
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
  with(FileReader(raw) %as% reader, {
    raw_data = to_pandas(reader)
    raw_data = reset_index(raw_data)
    colnames(raw_data) <- c("time", "X", "Y", "Z")
    raw_data$time <- as.POSIXct(raw_data$time, origin = "1970-01-01 00:00:00", tz=tz)})
  # Return Data
  raw_data
}

.ggirReader <- function(raw, verbose = FALSE, parser = c("pygt3x", "ggir", "gt3x"), tz = "UTC", ...){
  if(verbose) print("Reading data with read.gt3x and calibrating with GGIR.")
  if(any(c("activity_df", "data.frame") %in% class(raw))){
    if(any(.get_sleep(raw))) stop("Calibration with GGIR requires the data to be imported without imputed zeros.")
    sf = .get_frequency(raw)
    C <- gcalibrateC(dataset = as.matrix(raw[, 2:4]), sf = sf)
    timestamps = seq(raw[1, 1], raw[nrow(raw), 1], 1/sf) %>% lubridate::force_tz(tz) %>% data.frame(time = .)
    raw_data = merge(timestamps, raw, by = "time", all = TRUE)
    raw_data[which(is.na(raw_data[, 2])), 2] <- 0
    raw_data[which(is.na(raw_data[, 3])), 3] <- 0
    raw_data[which(is.na(raw_data[, 4])), 4] <- 0
  } else if(inherits(raw, "character")){
    C <- read.gt3x::read.gt3x(raw, asDataFrame = TRUE, imputeZeroes = FALSE) %>%
      .get_frequency(.) %>%
      gcalibrateC(pathname = raw, sf = .)
    raw_data <- read.gt3x::read.gt3x(raw, asDataFrame = TRUE, imputeZeroes = TRUE)
  } else {
    stop("Path and data arguments are both set to NULL.")
  }
  raw_data[, 2:4] <- scale(raw_data[, 2:4], center = -C$offset, scale = 1/C$scale)
  if(C$nhoursused==0) message("\n There is not enough data to perform the GGIR calibration method. Returning uncalibrated data.")
  # Return Data
  raw_data
}


.gt3xReader <- function(raw, verbose = FALSE, parser = c("pygt3x", "ggir", "gt3x"), tz = "UTC", ...){
  if(verbose) print("Reading uncalibrated with read.gt3x.")
  raw_data <- read.gt3x::read.gt3x(raw, asDataFrame = TRUE, imputeZeroes = TRUE)
  # Return Data
  raw_data
}
