# Objective: Compare the Hector V 3.1.0 and V 3.2.0 results with one another.

# 0. Set Up --------------------------------------------------------------------
BASE_DIR <- here::here("CMP_397")

library(dplyr)
library(ggplot2)
library(tidyr)

# FYI the version of hector does not matter here since we will only be using
# the helper functions.
library(hector)

theme_set(theme_bw())

# 1. Load Data -----------------------------------------------------------------

file.path(BASE_DIR, "3.1.1_rslts.csv") %>%
    read.csv() %>%
    mutate(version = "3.1.1") ->
    old_rslts

file.path(BASE_DIR, "3.2.0_rslts.csv") %>%
    read.csv() %>%
    mutate(version = "3.2.0") ->
    new_rslts

rslts <- rbind(old_rslts, new_rslts)

# 2. Comparisons  --------------------------------------------------------------

rslts %>%
    filter(variable == GMST()) %>%
    ggplot(aes(year, value, linetype = version, color = scenario)) +
    geom_line() +
    labs(title = "Global Mean Surface Temperature",
         y = "deg C (relative to 1745)",
         x = "Year")

rslts %>%
    filter(variable == GMST()) %>%
    select(year, version, value, scenario) %>%
    spread(version, value) %>%
    mutate(dif = `3.2.0` - `3.1.1` ) %>%
    pull(dif) %>% mean()


# The aerosol RF
rslts %>%
    filter(variable %in% c(RF_BC(), RF_OC(), RF_NH3(), RF_ACI(), RF_SO2())) %>%
    ggplot(aes(year, value, linetype = version, color = scenario)) +
    geom_line() +
    facet_wrap("variable", scales = "free") +
    labs(title = "Aerosol RF",
         y = "W m-2")


# Carbon cycle concentration changes cause by the permafrost feedback &
# hector characterization
rslts %>%
    filter(variable %in% c(CONCENTRATIONS_CH4(), CONCENTRATIONS_CO2())) %>%
    ggplot(aes(year, value, linetype = version, color = scenario)) +
    geom_line() +
    facet_wrap("variable", scales = "free") +
    labs(title = "Atmos. Concentrations",
         y = "ppbv CH4, ppmv CO2")






