# Copyright © 2022 University of Kansas. All rights reserved.

testthat::test_that("agcounts and Actilife counts are the same",{

  #skip_if(!py_module_available("pygt3x"))
  gt3xPath <- system.file("extdata/example.gt3x", package = "agcounts")
  agdPath <- system.file("extdata/example5sec.agd", package = "agcounts")

  # Merge X, Y, and Z data together in a matrix
  rawData <- agread(gt3xPath, parser = "pygt3x")

  # Calculate Counts
  gt3xData <- calculate_counts(raw = rawData, epoch = 5)

  # Read in agd data
  agdData <- .read_agd(agdPath)$data

  # Tests
  expect_equal(nrow(agdData), nrow(gt3xData))
  expect_equal(agdData$Axis1, gt3xData$Axis1)
  expect_equal(agdData$Axis2, gt3xData$Axis2)
  expect_equal(agdData$Axis3, gt3xData$Axis3)
  expect_equal(agdData$Vector.Magnitude, gt3xData$Vector.Magnitude)

})
