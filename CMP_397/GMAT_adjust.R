# Get the new reference temperature values that will be used in the
# GCAM-hector coupling. These values normalize Hector temperature
# results to the same reference period as the IPCC Assessment Reports.

# 0. Set Up --------------------------------------------------------------------
library(dplyr)
library(tidyr)
library(hector)

# Define reference period
ref_period <- 1850:1900

# 1. Get GMAT reference --------------------------------------------------------
# Path to the hector-output stream, note that this might change.
read.csv("~/Documents/GCAM-WD/gcam-core/exe/logs/gcam-hector-outputstream.csv",
         skip = 1) %>%
    filter(variable == GLOBAL_TAS()) %>%
    filter(year %in% ref_period) %>%
    pull(value) %>%
    mean() ->
    ref_val

ref_val <- round(ref_val, digits = 4)


# 1. Get GMSAT reference --------------------------------------------------------
# Path to the hector-output stream, note that this might change.
read.csv("~/Documents/GCAM-WD/gcam-core/exe/logs/gcam-hector-outputstream.csv",
         skip = 1) %>%
    filter(variable == GMST()) %>%
    filter(year %in% ref_period) %>%
    pull(value) %>%
    mean() ->
    ref_val

ref_val <- round(ref_val, digits = 4)
