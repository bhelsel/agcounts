.get_frequency <- function(raw, timevar = "time") {
  timevar %T>%
  {stopifnot(exists(., raw))} %>%
  raw[1:pmin(nrow(raw), 1000), .] %>%
  lubridate::floor_date("1 sec") %>%
  table(.) %>%
  table(.) %>%
  {names(.)[which.max(.)]} %>%
  as.numeric(.) %T>%
  {if(!. %in% seq(30, 100, 10)) stop(
    "Frequency has to be 30, 40, 50, 60, 70, 80, 90 or 100 Hz"
  )}
}

.factors <- function(frequency){

  data.frame(
    upsample_factors = c(1, 3, 3, 1, 3, 3, 1, 3),
    downsample_factors = c(1, 4, 5, 2, 7, 8, 3, 10)
  ) %>%
  {.[match(frequency, c(30, 40, 50, 60, 70, 80, 90, 100)), ]} %>%
  as.list(.)

}
