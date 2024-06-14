remotes::install_github("jgcri/hector@v3.2.0")
library(hector)

library(dplyr)
library(ggplot2)
library(tidyr)
theme_set(theme_bw())

# Notes to future self, okay i am confused... and not quite sure where I stand on things....
# I guess am confused as to what is goign on with the RF being negative in the future,
# i thought our assumption was that there were no volcanoes in the future... why is the
# SV baseline for the historical period not centered around 0 then? why is there
# somewaht of a warming effect I did slack steve about it, i think that is all
# that I can do for it right now.

dates <- 1740:2100
vars <- c(RF_VOL(), VOLCANIC_SO2(), RF_TOTAL(), GLOBAL_TAS())

# 1. Pi Control Runs -----------------------------------------------------------
ini <- here::here("Issue_742/input/hector_picontrol.ini")
pi_core <- newcore(ini, name = "pi control")
run(pi_core)
pi_out <- fetchvars(pi_core, dates, vars)

ggplot(data = pi_out) +
    geom_line(aes(year, value)) +
    facet_wrap("variable", scales = "free")

# Now read in SV inputs from package data
table_path <- system.file(package = "hector", "input/tables/ssp245_emiss-constraints_rf.csv")
read.csv(table_path, comment.char = ";") %>%
    select(Date, SV) ->
    SV_inputs

# Read in the typical SV inputs
setvar(pi_core, dates = SV_inputs$Date, values = SV_inputs$SV,
       var = VOLCANIC_SO2(), unit = getunits(VOLCANIC_SO2()))
reset(pi_core)
run(pi_core)

fetchvars(pi_core, dates, c(GLOBAL_TAS(), RF_VOL(), VOLCANIC_SO2())) %>%
    mutate(scenario = "w/ vol rf") ->
    out1


out1 %>%
    filter(variable %in% c(GLOBAL_TAS(), RF_VOL())) %>%
    ggplot(aes(year, value)) +
    geom_line() +
    facet_wrap("variable", scales = "free") +
    labs(x = NULL, y = NULL)

out1 %>%
    filter(variable == GLOBAL_TAS()) %>%
    pull(value) %>% summary()




SV_inputs %>%
    mutate(value = if_else(Date == 1765, 0, value)) ->
    new_SV_inputs


# Read in the typical SV inputs
setvar(pi_core, dates = SV_inputs$Date, values = new_SV_inputs$SV,
       var = VOLCANIC_SO2(), unit = getunits(VOLCANIC_SO2()))
reset(pi_core)
run(pi_core)

fetchvars(pi_core, dates, vars) %>%
    mutate(scenario = "1765 = 0") ->
    out15





# Okay now to the run with the vol rf inputs change volscl and see what happens
setvar(pi_core,
       dates = NA,
       values = 0.5,
       var = VOLCANIC_SCALE(),
       unit = getunits(VOLCANIC_SCALE()))

reset(pi_core)
run(pi_core)

fetchvars(pi_core, dates, vars) %>%
    mutate(scenario = "volscl = 0.5") ->
    out2


rslts <- rbind(pi_out, out1, out2, out15)

ggplot(data = rslts) +
    geom_line(aes(year, value, color = scenario, linetype = scenario)) +
    facet_wrap("variable")


rslts %>%
    filter(scenario ==  "w/ vol rf" ) %>%
    filter(variable == VOLCANIC_SO2()) %>%
    ggplot(aes(year, value)) +
    geom_line(aes(year, value)) +
    labs(title = VOLCANIC_SO2(), y = getunits(VOLCANIC_SO2()))
