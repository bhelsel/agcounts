# Copyright © 2022 University of Kansas. All rights reserved.

testthat::test_that("Test raw module reactable table output", {
  #skip_if(!py_module_available("pygt3x"))
  app <- shinytest2::AppDriver$new(agShinyDeployApp())
  app$upload_file(`rawDataModule-gt3xFile` = system.file("extdata/example.gt3x", package = "agcounts"))
  app$set_inputs(`rawDataModule-parser` = "read.gt3x")
  app$set_inputs(rawTabset = "Data")
  app$expect_values(output = "rawDataModule-rawReactableTable", screenshot_args = FALSE)
  app$set_inputs(countsTabset = "Data")
  app$expect_values(output = "countsModule-countsReactableTable", screenshot_args = FALSE)
  app$upload_file(`compareCountsModule-agdFile` = system.file("extdata/example5sec.agd", package = "agcounts"))
  app$set_inputs(comparisonTabset = "Data")
  app$expect_values(output = "compareCountsModule-comparisonReactableTable", screenshot_args = FALSE)
  app$stop()
})
