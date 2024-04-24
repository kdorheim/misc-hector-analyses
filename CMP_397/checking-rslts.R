# Checking to see if the results reflected in by the GCAM queries match the
# hector output.

# 0. Set Up --------------------------------------------------------------------
library(dplyr)
library(tidyr)
library(hector)


# 1. Pull results form output stream -------------------------------------------
# Path to the hector-output stream, note that this might change.
hector_data_raw <- read.csv("~/Documents/GCAM-WD/gcam-core/exe/logs/gcam-hector-outputstream.csv",
         skip = 1)

hector_data_raw %>%
    filter(year == 2000) %>% filter(variable == RF_ACI())
