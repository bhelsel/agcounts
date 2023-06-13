
testthat::test_that("Check that the upsampleC works correctly", {

  file <- system.file("extdata/example.gt3x", package = "agcounts")
  raw <- read.gt3x(file, asDataFrame = TRUE)
  frequency <- .get_frequency(raw)
  f <- .factors(frequency)
  raw = t(as.matrix(raw[c("X", "Y", "Z")]))
  upsample_data = matrix(data = 0, nrow = nrow(raw), ncol = ncol(raw) * f$upsample_factor)
  upsample_data[1:3, seq(1, ncol(upsample_data), f$upsample_factor)] <- raw[1:3, ]
  a_fp = pi / (pi + 2 * f$upsample_factor)
  b_fp = (pi - 2 * f$upsample_factor) / (pi + 2 * f$upsample_factor)
  up_factor_fp = f$upsample_factor

  .np.roll <- function(X){
    X <- as.vector(c(X[1, ], X[2, ], X[3, ]))
    X <- c(utils::tail(X, 1) , utils::head(X, -1))
    X <- matrix(X, nrow = 3, byrow = TRUE)
    return(X)
  }

  if(frequency!=30){rm(raw)}

  if(!frequency %in% c(30, 60, 90)){
    upsample_data <- (a_fp * up_factor_fp) * (upsample_data + .np.roll(upsample_data))
    upsample_data <- cbind(rep(0,3), upsample_data)
  }

  upsample_data[1:3, 1:10]

  # Method 1: C++
  upsample_data_cpp <- upsampleC(upsample_data, b_fp)
  upsample_data_cpp <- upsample_data_cpp[, -1]

  # Method 2: R
  for (i in 2:ncol(upsample_data)){
    upsample_data[, i] <- upsample_data[, i] + -b_fp * upsample_data[, i-1]
    }
  upsample_data <- upsample_data[, -1]

  expect_equal(upsample_data_cpp, upsample_data)

})
