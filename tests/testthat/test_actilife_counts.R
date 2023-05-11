
testthat::test_that("agcounts and Actilife counts are the same",{

  # Load Data
  load(system.file("extdata/calibrationXaxis.RData", package = "agcounts"))
  load(system.file("extdata/calibrationYaxis.RData", package = "agcounts"))
  load(system.file("extdata/calibrationZaxis.RData", package = "agcounts"))
  agdPath <- system.file("extdata/calibration1sec.agd", package = "agcounts")

  # Recreate time stamps
  sf = 30
  start <- as.POSIXct("2023-04-24 15:02:00", tz = "UTC")
  end <- as.POSIXct("2023-04-25 11:46:13", tz = "UTC") + 1
  time <- seq(from = start, to = end - 0.001, by = 1/sf)

  # Merge X, Y, and Z data together in a matrix
  rawData <- data.frame(time, X, Y, Z)

  # Calculate Counts
  gt3xData <- calculate_counts(raw = rawData, epoch = 1)

  # Read in agd data
  agdData <- .read_agd(agdPath)$data

  # Remove rows that are not in the gt3xData file
  agdData <- agdData[-which(!agdData$time %in% gt3xData$time), ]

  # Tests
  expect_equal(nrow(agdData), nrow(gt3xData))
  expect_equal(agdData$Axis1, gt3xData$Axis1)
  expect_equal(agdData$Axis2, gt3xData$Axis2)
  expect_equal(agdData$Axis3, gt3xData$Axis3)
  expect_equal(agdData$Vector.Magnitude, gt3xData$Vector.Magnitude)
})
