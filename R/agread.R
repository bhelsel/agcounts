#' @title Read in raw acceleration data
#' @description This generic function reads in calibrated raw acceleration data
#'     from the python module pygt3x or the R GGIR package or uncalibrated data
#'     from the read.gt3x package.
#' @param path Path name to the GT3X file
#' @param verbose Print the read method, Default: FALSE.
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

agread <- function(path, verbose = FALSE, ...){

  if("reticulate" %in% installed.packages()){

    if(reticulate::py_module_available("pygt3x")){

      class(path) <- "pygt3x"

    }

  } else if("GGIR" %in% utils::installed.packages()){

    class(path) <- "ggir"

  } else {

    class(path) <- "gt3x"

  }

  UseMethod("agread", path)

}

#' @inheritParams agread
#' @export
agread.pygt3x <- function(path, verbose = FALSE, ...){

  if(!reticulate::py_module_available("pygt3x")){

    message('Python module "pygt3x" is not found. Try installing it or use a different method.')

  } else {

    if(verbose) print("Reading and calibrating data with pygt3x.")

    `%as%` <- reticulate::`%as%`

    # Import Modules
    Reader <- reticulate::import("pygt3x.reader", convert = FALSE)
    Calibration <- reticulate::import("pygt3x.calibration", convert = FALSE)

    # Import Classes
    FileReader <- Reader$FileReader
    CalibratedReader <- Calibration$CalibratedReader
    CalibrateAcceleration <- CalibratedReader$calibrate_acceleration

    with(FileReader(path) %as% reader, {
      calibrated_reader = CalibratedReader(reader)
      data = CalibrateAcceleration(calibrated_reader)
      data = reticulate::py_to_r(data$T)
    })

    data %<>% t() %>% data.frame()

    colnames(data) <- c("time", "X", "Y", "Z")

    data$time <- as.POSIXct(data$time, origin = "1970-01-01 00:00:00", tz="UTC")

    data
  }
}


#' @inheritParams agread
#' @export
agread.ggir <- function(path, verbose = FALSE, ...){

  if(verbose) print("Reading data with read.gt3x and calibrating with GGIR.")

  data <- read.gt3x::read.gt3x(path, asDataFrame = TRUE, imputeZeroes = TRUE)

  C <- GGIR::g.calibrate(datafile = path, use.temp = FALSE, printsummary = FALSE)

  data[, 2:4] <- scale(data[, 2:4], center = -C$offset, scale = 1/C$scale)

  data

}



#' @inheritParams agread
#' @export
agread.gt3x <- function(path, verbose = FALSE, ...){

  if(verbose) print("Reading uncalibrated with read.gt3x.")

  data <- read.gt3x::read.gt3x(path, asDataFrame = TRUE, imputeZeroes = TRUE)

  data

}
