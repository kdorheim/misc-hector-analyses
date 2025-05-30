# Related to PR 781
# The dev branch that the PR will be merging into
remotes::install_github("jgcri/hector@fa2be85")

# 0. Set Up --------------------------------------------------------------------
library(hector)
library(dplyr)
library(tidyr)

library(ggplot2)
theme_set(theme_bw())
library(ggpmisc)

BASE_DIR <- here::here("PR_781")

YRS  <- 1750:2100
VARS <- c("SV", RF_VOL(), RF_TOTAL(), GLOBAL_TAS())

# 1. Run Hector ----------------------------------------------------------------

system.file(package = "hector", "input") %>%
    list.files(pattern = "ssp", full.names = TRUE) %>%
    lapply(function(ini){
        name <- gsub(x = basename(ini), pattern = "hector_|.ini", replacement = "")
        hc <- newcore(ini, name = name)
        run(hc)
        fetchvars(hc, YRS, VARS)
    }) %>%
    do.call(what = "rbind") %>%
    mutate(source = "old") ->
    old_rslts


old_rslts %>%
    filter(variable == RF_VOL()) %>%
    ggplot(aes(year, value, color = scenario)) +
    geom_line()



write.csv(old_rslts,
          file = file.path(BASE_DIR, "old_hector_rslts.csv"),
          row.names = FALSE)

