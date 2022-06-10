
testthat::test_that("Expected results from each stage of the algorithm", {

  file <- system.file("extdata/example.gt3x", package = "agcounts")

  raw <- read.gt3x::read.gt3x(file, asDataFrame = TRUE, imputeZeroes = TRUE)

  frequency <- .get_frequency(raw)
  expect_equal(frequency, 90)

  raw %<>%
    .check_idle_sleep(frequency, epoch = 5, verbose = FALSE, tz = "UTC") %>%
    .resample(frequency, verbose = FALSE)

  expect_equal(nrow(raw), 3)
  expect_equal(ncol(raw) %% 30 == 0, TRUE)
  expect_equal(round(sum(raw["X", ])), 774)
  expect_equal(round(sum(raw["Y", ])), -1584)
  expect_equal(round(sum(raw["Z", ])), 2518)

  raw %<>% .bpf_filter()
  expect_equal(round(sum(raw["X", ])), -131)
  expect_equal(round(sum(raw["Y", ])), 205)
  expect_equal(round(sum(raw["Z", ])), -142)

  raw %<>% .trim_data(lfe_select = FALSE)
  expect_equal(round(sum(raw["X", ])), 24941)
  expect_equal(round(sum(raw["Y", ])), 32941)
  expect_equal(round(sum(raw["Z", ])), 37117)

  raw %<>% .resample_10hz()
  expect_equal(ncol(raw) %% 10 == 0, TRUE)
  expect_equal(round(sum(raw["X", ])), 8139)
  expect_equal(round(sum(raw["Y", ])), 10821)
  expect_equal(round(sum(raw["Z", ])), 12179)

  epoch_counts <- raw %>% .sum_counts(epoch = 5)
  expect_equal(ncol(epoch_counts), ncol(raw)/(10*5))
  expect_equal(round(sum(epoch_counts["X", ])), 8139)
  expect_equal(round(sum(epoch_counts["Y", ])), 10821)
  expect_equal(round(sum(epoch_counts["Z", ])), 12179)

})
