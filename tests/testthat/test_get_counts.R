

testthat::test_that("Check that get_counts is working as expected", {

  file <- system.file("extdata/example.gt3x", package = "agcounts")
  raw <- read.gt3x::read.gt3x(path = file, asDataFrame = TRUE)
  sf <- .get_frequency(raw)

  data <- get_counts(
    path = file,
    epoch = 5,
    lfe_select = FALSE,
    write.file = FALSE,
    verbose = TRUE,
    tz = "UTC",
    parser = "uncalibrated",
    return.data = TRUE
    )

  # Tests
  expect_equal(nrow(data), nrow(raw) / (sf * 5))
  expect_equal(ncol(data), 5)
  expect_equal(sum(data$Axis1), 46258)
  expect_equal(sum(data$Axis2), 47643)
  expect_equal(sum(data$Axis3), 21966)
  expect_equal(sum(data$Vector.Magnitude), 72981)

  file.copy(from = file, to = tempdir())

  new_file <- list.files(path = tempdir(), pattern = "example.gt3x", full.names = TRUE)

  expect_true(file.exists(file.path(tempdir(), "example.gt3x")))

  get_counts(
    path = new_file,
    epoch = 60,
    lfe_select = FALSE,
    write.file = TRUE,
    verbose = FALSE,
    tz = "UTC",
    parser = "uncalibrated",
    return.data = FALSE
  )

  get_counts(
    path = new_file,
    epoch = 60,
    lfe_select = TRUE,
    write.file = TRUE,
    verbose = FALSE,
    tz = "UTC",
    parser = "uncalibrated",
    return.data = FALSE
  )

  expect_true(file.exists(file.path(tempdir(), "AG 60s Epoch Counts", "example.csv")))
  expect_true(file.exists(file.path(tempdir(), "AG 60s LFE Epoch Counts", "example.csv")))

  data <- read.csv(file.path(tempdir(), "AG 60s Epoch Counts", "example.csv"))

  unlink(file.path(tempdir(), "AG 60s Epoch Counts"), recursive = TRUE)
  unlink(file.path(tempdir(), "AG 60s LFE Epoch Counts"), recursive = TRUE)

  file.remove(file.path(tempdir(), "example.gt3x"))

  expect_equal(data$Axis1, c(4647, 8435, 13062, 13621, 6493))
  expect_equal(data$Axis2, c(4970, 9394, 12511, 10425, 10343))
  expect_equal(data$Axis3, c(4322, 6597, 4072, 5656, 1319))
  expect_equal(data$Vector.Magnitude, c(8061, 14245, 18540, 18061, 12283))

})
