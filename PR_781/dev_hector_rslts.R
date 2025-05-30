# Related to PR 781
# The dev branch with the new volcanic RF.
#remotes::install_github("jgcri/hector@b40f0b0")
devtools::load_all("~/Documents/Hector-WD/hector")

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

file.path("~/Documents/Hector-WD/hector/inst/input/") %>%
    list.files(pattern = "ssp", full.names = TRUE) %>%
    lapply(function(ini){
        name <- gsub(x = basename(ini), pattern = "hector_|.ini", replacement = "")
        hc <- newcore(ini, name = name)
        run(hc)
        fetchvars(hc, YRS, VARS)
    }) %>%
    do.call(what = "rbind") %>%
    mutate(source = "new") ->
    new_rslts

write.csv(new_rslts,
          file = file.path(BASE_DIR, "new_hector_rslts.csv"),
          row.names = FALSE)

