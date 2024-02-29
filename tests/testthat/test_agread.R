# Copyright © 2022 University of Kansas. All rights reserved.

testthat::test_that("Check that data can be read into agcounts using pygt3x", {
  skip_if(!py_module_available("pygt3x"))
  file <- system.file("extdata/example.gt3x", package = "agcounts")
  pygt3x <- agread(path = file, parser = "pygt3x", verbose = FALSE)
  expect_equal(nrow(pygt3x), 18000)
  expect_equal(ncol(pygt3x), 4)
})


testthat::test_that("Check that data can be read into agcounts using each agread method", {
  file <- system.file("extdata/example.gt3x", package = "agcounts")
  expect_error(agread(path = file, parser = "no parser"))

  invisible(capture.output(ggir <- agread(path = file, parser = "GGIR", verbose = FALSE)))
  expect_equal(nrow(ggir), 18000)
  expect_equal(ncol(ggir), 4)

  invisible(capture.output(rawData <- agread(path = file, parser = "read.gt3x", verbose = FALSE)))
  expect_equal(nrow(rawData), 18000)
  expect_equal(ncol(rawData), 4)

  raw <- read.gt3x(path = file, asDataFrame = TRUE)
  sf <- agcounts:::.get_frequency(raw)
  invisible(capture.output(agcalibrated <- agcalibrate(raw)))
  expect_equal(nrow(agcalibrated), 18001) # Looks like agcalibrate produces 1 additional row of data
  expect_equal(ncol(agcalibrated), 4)

  class(raw) <- "data.frame"
  raw[91:180, c("X", "Y", "Z")] <- 0
  expect_error(agcalibrate(raw))

})

