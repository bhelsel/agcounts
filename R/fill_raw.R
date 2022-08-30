.fill_raw <- function(raw, timestamps, frequency, epoch) {


  ## Initial calculation and check

    target_n_rows <-
      timestamps$end %>%
      lubridate::ceiling_date(paste(epoch, "sec")) %>%
      difftime(timestamps$start) %>%
      as.numeric("secs") %>%
      {. / epoch * frequency * epoch}

    if (nrow(raw) == target_n_rows) return(raw)


  ## Trim file down to only usable data, then look at what's missing

    raw %<>% .[.$time < timestamps$end + 1, ]

    n_missing_rows <- target_n_rows - nrow(raw)


  ## Set up for the latching

    last_time <-
      raw$time %>%
      .[length(.)] %>%
      lubridate::ceiling_date("1 sec")

    epoch_increments <- seq(0, 1, by = 1/frequency)[1:frequency]

    trail_times <-
      {seq(n_missing_rows / frequency) - 1} %>%
      lapply(
        function(x, inc) x + inc,
        inc = epoch_increments
      ) %>%
      do.call(c, .) %>%
      {last_time + .}


  ## Do the latching

    indices <- nrow(raw) + 1:n_missing_rows

    raw[indices, ] <- NA

    raw$time[indices] <- trail_times
    raw$X <- zoo::na.locf0(raw$X)
    raw$Y <- zoo::na.locf0(raw$Y)
    raw$Z <- zoo::na.locf0(raw$Z)


  ## Done

    raw


}
