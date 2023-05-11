
testthat::test_that("Check to see if gcalibrateC is getting the same result as GGIR g.calibrate", {

  # Load Data
  load(system.file("extdata/calibrationXaxis.RData", package = "agcounts"))
  load(system.file("extdata/calibrationYaxis.RData", package = "agcounts"))
  load(system.file("extdata/calibrationZaxis.RData", package = "agcounts"))
  load(system.file("extdata/ggirCalibrate.RData", package = "agcounts"))

  # Merge X, Y, and Z data together in a matrix
  data <- as.matrix(cbind(X, Y, Z))

  # Run the gcalibrateC C++ function to get calibration data
  agC <- gcalibrateC(dataset = as.matrix(cbind(X, Y, Z)), sf = 30)

  # Convert GGIR spheredata to a matrix to make it comparable to spheredata from gCalibrate
  rownames(C$spheredata) <- NULL
  C$spheredata <- as.matrix(C$spheredata)

  # Tests
  expect_equal(agC$scale, C$scale, tolerance = 0.001)
  expect_equal(agC$offset, C$offset, tolerance = 0.001)
  expect_equal(agC$calErrorStart, C$cal.error.start, tolerance = 0.001)
  expect_equal(agC$calErrorEnd, C$cal.error.end, tolerance = 0.001)
  expect_equal(agC$spheredata, C$spheredata)
  expect_equal(agC$npoints, C$npoints)
  expect_equal(agC$nhoursused, C$nhoursused)

})








