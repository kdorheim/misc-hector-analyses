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
    group_by(scenario) %>%
    summarise(value = mean(dif))
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



# Parse out all of the RF variables from the function table so make it easy to
# get all the RF values with a fetchvars call.
hector::fxntable %>%
    filter(grepl(x = fxn, pattern = "RF_")) %>%
    pull(string) ->
    rf_vars

# By forcing component
rslts %>%
  #  filter(scenario == "ssp245") %>%
    spread(version, value) %>%
    mutate(dif = `3.2.0` - `3.1.1`) %>%
    filter(grepl(x = variable, pattern = "RF_|F")) ->
    diff_in_rf


diff_in_rf %>%
    group_by(variable) %>%
    summarise(value = sum(dif)) %>%
    filter(value == 0) %>%
    pull(variable) ->
    no_rf_change


diff_in_rf %>%
    filter(!variable %in% no_rf_change) %>%
    group_by(variable) %>%
    summarise(value = sum(abs(dif)))



diff_in_rf %>%
    filter(!variable %in% no_rf_change) %>%
    ggplot(aes(year, dif, color = variable)) +
    geom_line()



diff_in_rf %>%
    filter(variable == RF_TOTAL()) %>%
    filter(year >= 1990) %>%
    ggplot(aes(year, 100 * dif/`3.1.1`, color = scenario)) +
    geom_line() +
    labs(title = "Percent Change in RF",
         y = "% change aka (new - old) / old")




diff_in_rf %>%
    filter(scenario == "ssp245") %>%
    filter(!variable %in% no_rf_change) %>%
    filter(variable != RF_TOTAL()) %>%
    filter(year >= 1990) %>%
    ggplot(aes(year, dif, color = variable)) +
    geom_line() +
    labs(title = "Change in RF by type for SSP245",
         y = "v3.2.0 - v3.1.1")




