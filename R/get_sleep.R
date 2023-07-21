# Copyright © 2022 University of Kansas. All rights reserved.
#
# Creative Commons Attribution NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

#' @export
#' @keywords internal
.get_sleep <- function(raw, ...) {
  UseMethod(".get_sleep", raw)
}

#' @export
.get_sleep.default <- function(raw, ...) {
  raw$X==0 & raw$Y==0 & raw$Z==0
}

#' @export
.get_sleep.activity_df <- function(raw, ...) {


  is_sleep <-
    nrow(raw) %>%
    logical()


  if (!exists("missingness", attributes(raw))) {

    NextMethod()

  } else {

    sleep_i <-
      attr(raw, "missingness") %>%
      {mapply(
        function(index, n_missing) index + 1:n_missing - 1,
        index = match(.$time, raw$time),
        n_missing = .$n_missing,
        SIMPLIFY = FALSE
      )} %>%
      do.call(c, .) %>%
      {.[. <= nrow(raw)]}

    is_sleep[sleep_i] <- TRUE

    is_sleep

  }


}
