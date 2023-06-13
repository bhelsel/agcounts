

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
  expect_equal(sum(data$Axis1), 6516)
  expect_equal(sum(data$Axis2), 10422)
  expect_equal(sum(data$Axis3), 9028)
  expect_equal(sum(data$Vector.Magnitude), 15790)

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

  expect_equal(data$Axis1, c(2606, 1738, 2172))
  expect_equal(data$Axis2, c(3116, 3943, 3363))
  expect_equal(data$Axis3, c(3542, 2840, 2646))
  expect_equal(data$Vector.Magnitude, c(5389, 5161, 4799))

})
