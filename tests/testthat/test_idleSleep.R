# Copyright © 2022 University of Kansas. All rights reserved.

testthat::test_that("Check that idle sleep carries last observation forward", {
  file <- system.file("extdata/example.gt3x", package = "agcounts")
  raw <- data.frame(read.gt3x(file))
  expect_false(any(.get_sleep(raw)))
  raw[100:250, c("X", "Y", "Z")] <- 0 # Create idle sleep mode behavior
  expect_true(any(.get_sleep(raw)))
  sf <- .get_frequency(raw)
  raw_with_first_obs <- .check_idle_sleep(raw, frequency = sf, epoch = 5, tz = "UTC", verbose = TRUE)
  expect_true(raw_with_first_obs$X[99] == mean(raw_with_first_obs$X[100:250]))
  expect_true(raw_with_first_obs$Y[99] == mean(raw_with_first_obs$Y[100:250]))
  expect_true(raw_with_first_obs$Z[99] == mean(raw_with_first_obs$Z[100:250]))
  raw[1:99, c("X", "Y", "Z")] <- 0 # Create idle sleep mode behavior
  raw_missing_first_obs <- .check_idle_sleep(raw, frequency = sf, epoch = 5, tz = "UTC", verbose = FALSE)
  # Divisible by epoch length
  expect_equal(as.numeric(format(raw_missing_first_obs[1, "time"], "%S")) %% 5, 0)
  last_missing_obs <- which(!.get_sleep(raw))[1] - 1
  obs_per_epoch <- sf * 5
  obs_removed <- (last_missing_obs %/% obs_per_epoch) * obs_per_epoch + obs_per_epoch
  expect_equal(nrow(raw_missing_first_obs), nrow(raw) - obs_removed)
})
