.testHTML_rawDataModuleUI <- function(...) {
  shiny:::withPrivateSeed(set.seed(100))
  rawDataModuleUI(...)
}

testthat::test_that("shiny rawDataModuleUI creates expected HTML", {
  
  expect_snapshot(.testHTML_rawDataModuleUI("rawDataModule"))
  
})

.testHTML_countsModuleUI <- function(...) {
  shiny:::withPrivateSeed(set.seed(100))
  countsModuleUI(...)
}

testthat::test_that("shiny countsModuleUI creates expected HTML", {
  
  expect_snapshot(.testHTML_countsModuleUI("countsModule"))
  
})


.testHTML_compareCountsModuleUI <- function(...) {
  shiny:::withPrivateSeed(set.seed(100))
  compareCountsModuleUI(...)
}

testthat::test_that("shiny compareCountsModuleUI creates expected HTML", {
  
  expect_snapshot(.testHTML_compareCountsModuleUI("compareCountsModule"))
  
})