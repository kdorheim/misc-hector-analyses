# Objective: Run the "old version" of Hector coupled with GCAM.
# These will be used in the comparison included in the CMP documentation.
# Based on the changes between Hector V 3.1.1 & V 3.2.0 out comparison is going
# to need to focus on [CO2], [CH4], global temps, & aerosol RF.

# 0. Set Up --------------------------------------------------------------------
# need to install the specific version of hector being used....
# after updates might need to change from @gcam-integrationv3 to the
# ‘3.1.1’ release
remotes::install_github("jgcri/hector@gcam-integrationv3")
library(hector)
version <- packageVersion("hector")

# load other packages
library(dplyr)
library(tidyr)


# 1. Run Hector ----------------------------------------------------------------

# Run Hector & fetch results of interest
# Args
#       ini: str path to the ini file
# Return: data frame of our variables of interest.
my_run_hector <- function(ini){
    scn_name <- gsub(pattern = "hector_|.ini", x = basename(ini), replacement = "")
    hc <- newcore(inifile = ini, name = scn_name)
    run(hc)
    vars <- c(GLOBAL_TAS(), GMST(), RF_BC(), RF_NH3(), RF_ACI(), RF_OC(), RF_SO2(),
              CONCENTRATIONS_CH4(), CONCENTRATIONS_CO2())
    out <- fetchvars(hc, dates = 1950:2300, vars = vars)
    return(out)
}


system.file("input", package = "hector") %>%
    list.files(pattern = "ini", full.names = TRUE) %>%
    lapply(FUN=my_run_hector) %>%
    do.call(what = "rbind") ->
    rslts

# 2. Save Results  -------------------------------------------------------------
ofile <- file.path("CMP_397", paste0(version, "_rslts.csv"))
write.csv(x = rslts, file = ofile, row.names = FALSE)

