
testthat::test_that("Shiny app rawDataModuleServer loads raw acceleration data", {
  shiny::testServer(rawDataModuleServer, {
    path = system.file("extdata/example.gt3x", package = "agcounts")
    session$setInputs(gt3xFile = list(datapath = path), parser = "pygt3x",
                      applyRaw = "ENMO", timeSlot = "AM")
    
    # Test Uncalibrated Data
    testthat::expect_equal(ncol(uncalibratedData()), 4)
    testthat::expect_equal(nrow(uncalibratedData()), 27000)
    testthat::compare(mean(uncalibratedData()$X), 0.9727254, tolerance = 1e-7)
    testthat::compare(mean(uncalibratedData()$Y), 0.6042353, tolerance = 1e-7)
    testthat::compare(mean(uncalibratedData()$Z), 0.1478806, tolerance = 1e-7)
    
    # Test the Parser
    testthat::compare(input$parser, "pygt3x")
    
    # Test the Calibrated Data
    testthat::expect_equal(ncol(calibratedData()), 5)
    testthat::expect_equal(nrow(calibratedData()), 27000)
    testthat::compare(mean(calibratedData()$X), 0.9727254, tolerance = 1e-7)
    testthat::compare(mean(calibratedData()$Y), 0.6042353, tolerance = 1e-7)
    testthat::compare(mean(calibratedData()$Z), 0.1478806, tolerance = 1e-7)
    testthat::compare(mean(calibratedData()$Vector.Magnitude), 1.352164, tolerance = 1e-7)
    
    # Test that first available date is selected
    testthat::expect_equal(dates()[1], "June 08, 2023")
  })
})

testthat::test_that("Shiny app rawDataModuleServer loads dynamic UI", {
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


testthat::test_that("Shiny app compareCountsModule loads agd data", {
  
  shiny::testServer(compareCountsModuleServer, {
    path = system.file("extdata/calibration1sec.agd", package = "agcounts")
    data <- .read_agd(path)
    expect_equal(data[[1]], "Normal")
    expect_equal(data[[2]], 1)
    expect_equal(sum(data[[3]]$Axis1), 623130)
    expect_equal(sum(data[[3]]$Axis2), 758279)
    expect_equal(sum(data[[3]]$Axis3), 902153)
    expect_equal(sum(data[[3]]$Vector.Magnitude), 1548384)
  })
  
})
