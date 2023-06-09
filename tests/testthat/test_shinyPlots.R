testthat::test_that("Test the comparison plot", {
  app <- shinytest2::AppDriver$new(agShinyDeployApp())
  app$upload_file(`rawDataModule-gt3xFile` = system.file("extdata/example.gt3x", package = "agcounts"))
  app$set_inputs(`rawDataModule-parser` = "uncalibrated")
  app$set_inputs(`rawDataModule-timeSlot` = "All Day", allow_no_input_binding_ = TRUE)
  app$upload_file(`compareCountsModule-agdFile` = system.file("extdata/example5sec.agd", package = "agcounts"))
  app$expect_values(output = "compareCountsModule-comparisonPlot", screenshot_args = FALSE)
  app$set_inputs(`compareCountsModule-agdBlandAltmanPlot` = TRUE)
  app$expect_values(output = "compareCountsModule-comparisonPlot", screenshot_args = FALSE)
})

