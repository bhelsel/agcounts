# Copyright © 2022 University of Kansas. All rights reserved.
#
# Creative Commons Attribution NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

testthat::test_that("Expected results from each stage of the algorithm", {

  file <- system.file("extdata/example.gt3x", package = "agcounts")

  raw <- read.gt3x::read.gt3x(file, asDataFrame = TRUE, imputeZeroes = TRUE)

  frequency <- .get_frequency(raw)
  expect_equal(frequency, 100)

  raw %<>% .resample(frequency, verbose = TRUE)

  expect_equal(nrow(raw), 3)
  expect_equal(ncol(raw) %% 30 == 0, TRUE)
  expect_equal(round(sum(raw["X", ])), 5153)
  expect_equal(round(sum(raw["Y", ])), 1374)
  expect_equal(round(sum(raw["Z", ])), 84)

  raw %<>% .bpf_filter(verbose = TRUE)
  expect_equal(round(sum(raw["X", ])), -72)
  expect_equal(round(sum(raw["Y", ])), 100)
  expect_equal(round(sum(raw["Z", ])), 65)

  raw %<>% .trim_data(lfe_select = FALSE, verbose = TRUE)
  expect_equal(round(sum(raw["X", ])), 32767)
  expect_equal(round(sum(raw["Y", ])), 20561)
  expect_equal(round(sum(raw["Z", ])), 28279)

  raw %<>% .resample_10hz(verbose = TRUE)
  expect_equal(ncol(raw) %% 10 == 0, TRUE)
  expect_equal(round(sum(raw["X", ])), 10422)
  expect_equal(round(sum(raw["Y", ])), 6516)
  expect_equal(round(sum(raw["Z", ])), 9028)

  epoch_counts <- raw %>% .sum_counts(epoch = 5, verbose = TRUE)
  expect_equal(ncol(epoch_counts), ncol(raw)/(10*5))
  expect_equal(round(sum(epoch_counts["X", ])), 10422)
  expect_equal(round(sum(epoch_counts["Y", ])), 6516)
  expect_equal(round(sum(epoch_counts["Z", ])), 9028)

})
