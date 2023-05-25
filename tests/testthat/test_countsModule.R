.testHTML_countsModuleUI <- function(...) {
  shiny:::withPrivateSeed(set.seed(100))
  countsModuleUI(...)
}

testthat::test_that("shiny countsModuleUI creates expected HTML", {

  expect_snapshot(.testHTML_countsModuleUI("countsModule"))

})


testthat::test_that("Test counts module reactable table output", {
  app <- shinytest2::AppDriver$new(agShinyDeployApp())
  app$upload_file(`rawDataModule-gt3xFile` = system.file("extdata/example.gt3x", package = "agcounts"))
  app$set_inputs(`rawDataModule-parser` = "uncalibrated")

  # names(app$get_values()$input)
  # names(app$get_values()$output)
  app$set_inputs(countsTabset = "Data")
  app$expect_values(output = "countsModule-countsReactableTable", screenshot_args = FALSE)
  app$stop()

})
