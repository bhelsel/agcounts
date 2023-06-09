

testthat::test_that("Check that data can be read into agcounts using each agread method", {

  file <- system.file("extdata/example.gt3x", package = "agcounts")

  expect_error(agread(path = file, parser = "no parser"))

  pygt3x <- agread(path = file, parser = "pygt3x", verbose = TRUE)
  expect_equal(nrow(pygt3x), 27000)
  expect_equal(ncol(pygt3x), 4)

  ggir <- agread(path = file, parser = "ggir", verbose = TRUE)
  expect_equal(nrow(ggir), 27000)
  expect_equal(ncol(ggir), 4)

  uncalibrated <- agread(path = file, parser = "uncalibrated", verbose = TRUE)
  expect_equal(nrow(uncalibrated), 27000)
  expect_equal(ncol(uncalibrated), 4)

  raw <- read.gt3x(path = file, asDataFrame = TRUE)
  sf <- .get_frequency(raw)
  agcalibrated <- agcalibrate(raw)
  expect_equal(nrow(agcalibrated), 27001) # Looks like agcalibrate produces 1 additional row of data
  expect_equal(ncol(agcalibrated), 4)

  class(raw) <- "data.frame"
  raw[91:180, c("X", "Y", "Z")] <- 0
  expect_error(agcalibrate(raw))

})
