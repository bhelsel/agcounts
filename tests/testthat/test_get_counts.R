

testthat::test_that("Check that get_counts is working as expected", {
  
  file <- system.file("extdata/example.gt3x", package = "agcounts")
  raw <- read.gt3x::read.gt3x(path = file, asDataFrame = TRUE)
  sf <- .get_frequency(raw)
  
  data <- get_counts(
    path = file, 
    epoch = 5, 
    lfe_select = FALSE,
    write.file = FALSE,
    verbose = TRUE, 
    tz = "UTC",
    parser = "uncalibrated",
    return.data = TRUE
    )

  # Tests
  expect_equal(nrow(data), nrow(raw) / (sf * 5))
  expect_equal(ncol(data), 5)
  expect_equal(sum(data$Axis1), 10821)
  expect_equal(sum(data$Axis2), 8139)
  expect_equal(sum(data$Axis3), 12179)
  expect_equal(sum(data$Vector.Magnitude), 19667)
  
})