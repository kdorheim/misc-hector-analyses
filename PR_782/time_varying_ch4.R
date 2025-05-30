# Related to PR 782
# The dev branch with the time varying natural CH4 emissions.
HECTOR_DIR <- "~/Documents/Hector-WD/hector"
devtools::load_all(HECTOR_DIR)

# 0. Set Up --------------------------------------------------------------------
#library(hector)
library(dplyr)
library(tidyr)

library(ggplot2)
theme_set(theme_bw())
library(ggpmisc)

BASE_DIR <- here::here("PR_782")

YRS  <- 1746:2100
VARS <- c(EMISSIONS_CH4(), NATURAL_CH4(), GLOBAL_TAS(), CONCENTRATIONS_CH4())

HEIGHT <- 2
WIDTH <- 2 * HEIGHT


# 1. Run Hector ----------------------------------------------------------------

# Constant natural CH4 emissions
ini <- file.path(HECTOR_DIR, "inst", "input", "hector_ssp245.ini")
hc  <- newcore(ini)
run(hc, runtodate = max(YRS))
out1 <- fetchvars(hc, YRS, VARS)
out1$scenario <- "constant"

# 2. Time Varying CH4 Emissions ----------------------------------------------------------------

# Extract the natural CH4 emissions and use it to generate a random time series
default_nat_ch4 <- fetchvars(hc, 1750, NATURAL_CH4())[["value"]]
diff_by <- 150
min <- default_nat_ch4 - diff_by
max <- default_nat_ch4 + diff_by
nat_ch4_emiss <- sample(min:max, size = length(YRS), replace = TRUE)

# Time varing natural ch4 emissions
ini <- file.path(HECTOR_DIR, "inst", "input", "hector_ssp245.ini")
hc  <- newcore(ini)
setvar(hc,
       dates = YRS,
       var = NATURAL_CH4(),
       values = nat_ch4_emiss,
       unit = getunits(EMISSIONS_CH4()))
run(hc, runtodate = max(YRS))
out2 <- fetchvars(hc, YRS, VARS)
out2$scenario <- "varying"

# 3. Comparison Plots ----------------------------------------------------------
# Combine results for plotting.
out <- rbind(out1, out2)

# CH4 Emissions!
out %>%
    filter(variable %in% c(NATURAL_CH4(), EMISSIONS_CH4())) %>%
    ggplot(aes(year, value, color = scenario)) +
    geom_line(alpha = 0.5) +
    theme(legend.title = element_blank()) +
    facet_wrap("variable", scales = "free") +
    labs(y = NULL, x = NULL) +
    scale_color_manual(values = c("constant" = "black", "varying" = "red")) +
    labs(title = "CH4 Emissions") ->
    plot1; plot1
fname <- file.path(BASE_DIR, paste0("ch4_emissions.png"))
ggsave(filename = fname, plot1, width = 8, height = 4)



# CH4 Concentrations!
out %>%
    filter(variable == CONCENTRATIONS_CH4()) %>%
    ggplot(aes(year, value, color = scenario)) +
    geom_line() +
    theme(legend.title = element_blank()) +
    labs(y = NULL, x = NULL) +
    scale_color_manual(values = c("constant" = "black", "varying" = "red")) +
    labs(title = NATURAL_CH4()) ->
    plot2; plot2
fname <- file.path(BASE_DIR, paste0(CONCENTRATIONS_CH4(), ".png"))
ggsave(filename = fname, plot2, width = 8, height = 4)



# Global Temp!
out %>%
    filter(variable == GLOBAL_TAS()) %>%
    ggplot(aes(year, value, color = scenario)) +
    geom_line() +
    theme(legend.title = element_blank()) +
    labs(y = NULL, x = NULL) +
    scale_color_manual(values = c("constant" = "black", "varying" = "red")) +
    labs(title = NATURAL_CH4()) ->
    plot3; plot3
fname <- file.path(BASE_DIR, paste0(GLOBAL_TAS(), ".png"))
ggsave(filename = fname, plot3, width = 8, height = 4)



