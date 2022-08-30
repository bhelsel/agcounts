.get_timestamps <- function(raw, tz, epoch, frequency) {

  start <-
    attr(raw, "start_time") %>%
    lubridate::force_tz(tz)

  end <-
    attr(raw, "last_sample_time") %>%
    {if (is.null(.)) attr(raw, "stop_time") else .} %>%
    {if (
      strftime(., "%Y-%m-%d %H:%M:%S", tz) == "0001-01-01 00:00:00" |
      is.null(.)
    )
      raw$time[nrow(raw)]
      else .
    } %>%
    .adjust_missingness(raw) %>%
    # .adjust_incomplete(raw, epoch, frequency) %>%
    ##^Tests if the final epoch is complete or not,
    ## but ActiLife doesn't seem to worry about this
    {. - 0.001} %>%
    lubridate::force_tz(tz)

  list(
    start = start,
    end = end,
    timestamps = seq(start, end, epoch)
  )

}


.adjust_missingness <- function(end, raw) {

  if (!exists("missingness", attributes(raw))) return(end)

  last_missing_event <-
    attr(raw, "missingness") %>%
    utils::tail(1)

  last_missing_time <-
    last_missing_event$time +
    last_missing_event$n_missing /
    attr(raw, "sample_rate")

  if (last_missing_time >= end) {
    last_missing_event$time
  } else {
    end
  }

}


.adjust_incomplete <- function(end, raw, epoch, frequency) {

  samples_per_epoch <- epoch * frequency

  utils::tail(raw$time, samples_per_epoch*2) %>%
  lubridate::floor_date(paste0(epoch, "sec")) %>%
  as.character(.) %>%
  {rle(.)$lengths} %>%
  .[length(.)] %>%
  {. != samples_per_epoch} %>%
  {. * 0.001} %>%
  {lubridate::floor_date(end, paste(epoch, "sec")) - .} %>%
  lubridate::floor_date(paste(epoch, "sec"))

}
