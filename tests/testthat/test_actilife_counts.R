
testthat::test_that("agcounts and Actilife counts are the same",{
  
  gt3x.file <- system.file("extdata/testGT3X.RData", package = "agcounts")
  load(gt3x.file)
  testGT3X %<>% calculate_counts(raw = ., epoch = 1)
  
  agd.file <- system.file("extdata/testAGD.RData", package = "agcounts")
  load(agd.file)
  
  expect_equal(nrow(testAGD), nrow(testGT3X))
  compare(testAGD$` Axis1`, testGT3X$Axis1, tolerance = 0.05)
  compare(testAGD$Axis2, testGT3X$Axis2, tolerance = 0.05)
  compare(testAGD$Axis3, testGT3X$Axis3, tolerance = 0.05)
  compare(round(testAGD$`Vector Magnitude`), testGT3X$Vector.Magnitude, tolerance = 0.05)
  
})
