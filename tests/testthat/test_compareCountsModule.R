.testHTML_compareCountsModuleUI <- function(...) {
  shiny:::withPrivateSeed(set.seed(100))
  compareCountsModuleUI(...)
}

testthat::test_that("shiny compareCountsModuleUI creates expected HTML", {
  
  expect_snapshot(.testHTML_compareCountsModuleUI("compareCountsModule"))

})
  
