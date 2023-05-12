

testthat::test_that("Check that data can be read into agcounts using each agread method", {
  
  file <- system.file("extdata/example.gt3x", package = "agcounts")
  
  pygt3x <- agread(path = file, parser = "pygt3x")
  expect_equal(nrow(pygt3x), 16200)
  expect_equal(ncol(pygt3x), 4)
  
  ggir <- agread(path = file, parser = "ggir")
  expect_equal(nrow(ggir), 16200)
  expect_equal(ncol(ggir), 4)
  
  uncalibrated <- agread(path = file, parser = "uncalibrated")
  expect_equal(nrow(uncalibrated), 16200)
  expect_equal(ncol(uncalibrated), 4)
  
  raw <- read.gt3x(path = file, asDataFrame = TRUE)
  sf <- .get_frequency(raw)
  agcalibrated <- agcalibrate(raw)
  expect_equal(nrow(agcalibrated), 16201) # Looks like agcalibrate produces 1 additional row of data
  expect_equal(ncol(agcalibrated), 4)
  
})