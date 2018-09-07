library(charlatan)
library(stringr)
library(purrr)

n <- 30

starter_data <- data_frame(
  name = ch_name(n),
  date = map_chr(ch_date_time(n), function(x) str_sub(as.character(x), 1, 10)),
  phonenubmers = ch_phone_number(n),
  job = ch_job(n)
)
