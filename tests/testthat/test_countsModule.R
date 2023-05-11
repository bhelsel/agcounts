.testHTML_countsModuleUI <- function(...) {
  shiny:::withPrivateSeed(set.seed(100))
  countsModuleUI(...)
}

testthat::test_that("shiny countsModuleUI creates expected HTML", {
  
  expect_snapshot(.testHTML_countsModuleUI("countsModule"))

})
  
