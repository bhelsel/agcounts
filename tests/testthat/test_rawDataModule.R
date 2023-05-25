.testHTML_rawDataModuleUI <- function(...) {
  shiny:::withPrivateSeed(set.seed(100))
  rawDataModuleUI(...)
}

testthat::test_that("shiny rawDataModuleUI creates expected HTML", {

  expect_snapshot(.testHTML_rawDataModuleUI("rawDataModule"))

})



testthat::test_that("Shiny app rawDataModuleServer loads data", {
  shiny::testServer(rawDataModuleServer, {
    path = system.file("extdata/example.gt3x", package = "agcounts")
    session$setInputs(gt3xFile = list(datapath = path), parser = "pygt3x",
                      applyRaw = "ENMO", timeSlot = "AM")

    # Test Uncalibrated Data
    testthat::expect_equal(ncol(uncalibratedData()), 4)
    testthat::expect_equal(nrow(uncalibratedData()), 16200)
    testthat::expect_equal(mean(uncalibratedData()$X), 0.1438262, tolerance = 7)
    testthat::expect_equal(mean(uncalibratedData()$Y), -0.293216, tolerance = 7)
    testthat::expect_equal(mean(uncalibratedData()$Z), 0.4663786, tolerance = 7)

    # Test the Parser
    testthat::compare(input$parser, "pygt3x")

    # Test the Calibrated Data
    testthat::expect_equal(ncol(calibratedData()), 5)
    testthat::expect_equal(nrow(calibratedData()), 16200)
    testthat::expect_equal(mean(calibratedData()$X), 0.1439079, tolerance = 7)
    testthat::expect_equal(mean(calibratedData()$Y), -0.2931047, tolerance = 7)
    testthat::expect_equal(mean(calibratedData()$Z), 0.4662727, tolerance = 7)
    testthat::expect_equal(mean(calibratedData()$Vector.Magnitude), 1.003602, tolerance = 7)

    # Test that first available date is selected
    testthat::expect_equal(dates()[1], "February 14, 2019")
  })
})


testthat::test_that("Shiny app rawDataModuleServer loads data", {
  app <- shinytest2::AppDriver$new(agShinyDeployApp())
  app$upload_file(`rawDataModule-gt3xFile` = system.file("extdata/example.gt3x", package = "agcounts"))
  app$set_inputs(`rawDataModule-parser` = "uncalibrated")
  testthat::expect_equal(app$get_value(input = "rawDataModule-parser"), "uncalibrated")

  # Test that Raw is set when Vector.Magnitude is selected
  app$set_inputs(`rawDataModule-axisRaw` = "Vector.Magnitude")
  app$wait_for_value(input = "rawDataModule-applyRaw")
  testthat::expect_equal(app$get_value(input = "rawDataModule-applyRaw"), "Raw")

  # Test that apply Epoch is Added when ENMO is selected
  app$set_inputs(`rawDataModule-applyRaw` = "ENMO", allow_no_input_binding_ = TRUE)
  app$wait_for_value(input = "rawDataModule-applyEpoch")
  testthat::expect_equal(app$get_value(input = "rawDataModule-applyEpoch"), 5)
  app$stop()
})











