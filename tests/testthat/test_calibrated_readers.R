testthat::test_that("python and ggir calibrated readers get similar results",{
  
  # Read in example data 
  file <- system.file("extdata/example.gt3x", package = "agcounts")
  ggir <- agread.ggir(file)
  pygt3x <- agread.pygt3x(file)
  
  # Compare raw acceleration
  expect_equal(nrow(ggir), nrow(pygt3x))
  compare(ggir$X, pygt3x$X, tolerance = 0.05)
  compare(ggir$Y, pygt3x$Y, tolerance = 0.05)
  compare(ggir$Z, pygt3x$Z, tolerance = 0.05)
  
  # Calculate counts
  ggir %<>% calculate_counts(raw = .,  epoch = 60)
  pygt3x %<>% calculate_counts(raw = .,  epoch = 60)
  
  # Compare counts from all 3 axes and vector magnitude
  compare(ggir$Axis1, pygt3x$Axis1, tolerance = 0.05)
  compare(ggir$Axis2, pygt3x$Axis2, tolerance = 0.05)
  compare(ggir$Axis3, pygt3x$Axis3, tolerance = 0.05)
  compare(ggir$Vector.Magnitude, pygt3x$Vector.Magnitude, tolerance = 0.05)
  
})