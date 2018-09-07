library(charlatan)
library(stringr)
library(purrr)

set.seed(100)

n <- 30

starter_data <- data_frame(
  rowid = seq_len(n),
  name = ch_name(n),
  date = map_chr(ch_date_time(n), function(x) str_sub(as.character(x), 1, 10)),
  phonenubmers = ch_phone_number(n)
)
