
testthat::test_that("Expected results from each stage of the algorithm", {

  file <- system.file("extdata/example.gt3x", package = "agcounts")

  raw <- read.gt3x::read.gt3x(file, asDataFrame = TRUE, imputeZeroes = TRUE)

  frequency <- .get_frequency(raw)
  expect_equal(frequency, 90)

  raw %<>% .resample(frequency, verbose = TRUE)

  expect_equal(nrow(raw), 3)
  expect_equal(ncol(raw) %% 30 == 0, TRUE)
  expect_equal(round(sum(raw["X", ])), 8749)
  expect_equal(round(sum(raw["Y", ])), 5443)
  expect_equal(round(sum(raw["Z", ])), 1329)

  raw %<>% .bpf_filter(verbose = TRUE)
  expect_equal(round(sum(raw["X", ])), 8)
  expect_equal(round(sum(raw["Y", ])), -51)
  expect_equal(round(sum(raw["Z", ])), -44)

  raw %<>% .trim_data(lfe_select = FALSE, verbose = TRUE)
  expect_equal(round(sum(raw["X", ])), 145591)
  expect_equal(round(sum(raw["Y", ])), 141425)
  expect_equal(round(sum(raw["Z", ])), 67958)

  raw %<>% .resample_10hz(verbose = TRUE)
  expect_equal(ncol(raw) %% 10 == 0, TRUE)
  expect_equal(round(sum(raw["X", ])), 47643)
  expect_equal(round(sum(raw["Y", ])), 46258)
  expect_equal(round(sum(raw["Z", ])), 21966)

  epoch_counts <- raw %>% .sum_counts(epoch = 5, verbose = TRUE)
  expect_equal(ncol(epoch_counts), ncol(raw)/(10*5))
  expect_equal(round(sum(epoch_counts["X", ])), 47643)
  expect_equal(round(sum(epoch_counts["Y", ])), 46258)
  expect_equal(round(sum(epoch_counts["Z", ])), 21966)

})
