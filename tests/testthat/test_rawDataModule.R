.testHTML_rawDataModuleUI <- function(...) {
  shiny:::withPrivateSeed(set.seed(100))
  rawDataModuleUI(...)
}

testthat::test_that("shiny rawDataModuleUI creates expected HTML", {
  
  expect_snapshot(.testHTML_rawDataModuleUI("rawDataModule"))

})
  
