# Description: code related to preparing the materials for
# https://github.com/JGCRI/hector/issues/743, it seems that when
# adjust alpha and volscl there is no change in the RF_VOL output but
# does have the intended effect on global temperature.

# 0. Set Up -------------------------------------------------------------------
remotes::install_github("jgcri/hector@v3.2.0")
library(hector)

library(dplyr)
library(ggplot2)
theme_set(theme_bw())

# 1. VOLSCL -------------------------------------------------------------------
dates <- 1800:2025
vars <-  c(GLOBAL_TAS(), RF_VOL(), RF_TOTAL())

ini <- system.file(package = "hector", "input/hector_ssp245.ini")
core <- newcore(ini)
run(core)
out1 <- fetchvars(core, dates, vars)

setvar(core, dates = NA, var = VOLCANIC_SCALE(), values = 0.5, unit = getunits(VOLCANIC_SCALE()))
reset(core)
run(core)
out2 <- fetchvars(core, dates, vars)

setvar(core, dates = NA, var = VOLCANIC_SCALE(), values = 0.1, unit = getunits(VOLCANIC_SCALE()))
reset(core)
run(core)
out3 <- fetchvars(core, dates, vars)

out1$scenario <- "volscl = 1"
out2$scenario <- "volscl = 0.5"
out3$scenario <- "volscl = 0.1"


rslst <- rbind(out1, out2, out3)

ggplot(data = rslst) +
    geom_line(aes(year, value, color = scenario, linetype = scenario), size = 0.75) +
    facet_wrap("variable", scales = "free") +
    labs(y = NULL, x = NULL)




# 2. ALPHA -------------------------------------------------------------------
dates <- 1800:2025
vars <-  c(RF_BC(), RF_TOTAL(), GLOBAL_TAS())

ini <- system.file(package = "hector", "input/hector_ssp245.ini")
core <- newcore(ini)
run(core)
out1 <- fetchvars(core, dates, vars)

setvar(core, dates = NA, var = AERO_SCALE(), values = 0.5, unit = getunits(VOLCANIC_SCALE()))
reset(core)
run(core)
out2 <- fetchvars(core, dates, vars)

setvar(core, dates = NA, var = AERO_SCALE(), values = 0.1, unit = getunits(VOLCANIC_SCALE()))
reset(core)
run(core)
out3 <- fetchvars(core, dates, vars)

out1$scenario <- "alpha = 1"
out2$scenario <- "alpha = 0.5"
out3$scenario <- "alpha = 0.1"


rslst <- rbind(out1, out2, out3)

ggplot(data = rslst) +
    geom_line(aes(year, value, color = scenario, linetype = scenario),
              size = 0.75) +
    facet_wrap("variable", scales = "free") +
    labs(y = NULL, x = NULL)

