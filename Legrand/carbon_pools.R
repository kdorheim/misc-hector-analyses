# Example of looking at Hector's carbon pools for G. Legrand


# 0. Set Up --------------------------------------------------------------------
# Making sure the correct version of Hector is being installed here and that
# I am not accidentally using my local development version of hector.
remotes::install_github("jgcri/hector@v3.2.0")
library(hector)

# Additional R packages used to process & plot data.
library(dplyr)
library(ggplot2)

# 1. Default Run ---------------------------------------------------------------
# The path to the ini file included in the Hector release
ini <- system.file(package = "hector", "input/hector_ssp585.ini")

# Create a new core & complete a run!
core <- newcore(inifile = ini, name = "default ssp585")
run(core)


# Should generate some documentation about all of Hector's carbon cycle variables.
# help("carboncycle")

# Make a list of the variables to save from the run
vars <- c(CONCENTRATIONS_CO2(), GLOBAL_TAS(),  RF_CO2(), RF_TOTAL(), # these are the variables you have already plotted
          VEG_C(), SOIL_C(), DETRITUS_C(), NPP(), OCEAN_C()) # some of the carbon pool names
dates <- 1850:2300
out1 <- fetchvars(core, dates = dates, vars = vars)


to_plot <- c(RF_CO2(), GLOBAL_TAS(), VEG_C(), SOIL_C(),
             DETRITUS_C(), NPP(), OCEAN_C(), CONCENTRATIONS_CO2())
out1 %>%
    filter(variable %in% to_plot) %>%
    ggplot(aes(year, value)) +
    geom_line() +
    facet_wrap("variable", scales = "free")



# 2. G. Legrand's Run ----------------------------------------------------------
# Load the path to the input table from G. Legrand
ini <- "Legrand/input/hector_ssp585-test.ini"

# Create a new core & complete a run!
core2 <- newcore(inifile = ini, name = "Legrand run")
run(core2)

# Make a list of the variables to save from the run
out2 <- fetchvars(core2, dates = dates, vars = vars)

out2 %>%
    filter(variable %in% to_plot) %>%
    ggplot(aes(year, value)) +
    geom_line() +
    facet_wrap("variable", scales = "free")



# 3. Compare Results -----------------------------------------------------------

rbind(out1, out2) %>%
    filter(variable %in% to_plot) %>%
    ggplot(aes(year, value, color = scenario)) +
    geom_line() +
    facet_wrap("variable", scales = "free")
