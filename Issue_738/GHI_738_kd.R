# Code related to github issue 738
#
# https://github.com/JGCRI/hector/issues/738#issuecomment-2043524579


# remotes::install_github("JGCRI/hector") # only need to install once
library(hector)
# because of the hector version we will be running the ssps instead of the RCPS
ini_file <- system.file("input/hector_ssp245.ini", package = "hector")
core <- newcore(ini_file)
core

ecs <- fetchvars(core, NA, ECS())
OceanDiffusivity <- fetchvars(core, NA, DIFFUSIVITY())
AerosolForcing <- fetchvars(core, NA, AERO_SCALE())
VolcanicForcing <- fetchvars(core, NA, VOLCANIC_SCALE())
beta <- fetchvars(core, NA, BETA())
PreindustrialC02 <- fetchvars(core, NA, PREINDUSTRIAL_CO2())
Hetero_respiration_tempSensi <- fetchvars(core, NA, Q10_RH())



#################################
#calibrated Values from doreheim et al
#showing difference from hector default to calibrated values
#trying to troubleshoot as of 07.04.24- why this only returning one line on graph
setvar(core, NA, DIFFUSIVITY(), 1.16, "cm2/s")
fetchvars(core, NA, DIFFUSIVITY())
core
reset(core)
core
run(core)
results_OD_1.16 <- fetchvars(core, 1850:2024)
results[["DIFFUSIVITY"]] <- 2.38
results_OD_1.16[["DIFFUSIVITY"]] <- 1.16
compare_results <- rbind(results, results_OD_1.16)

ggplot(compare_results) +
    aes(x = year, y = value, color = factor((DIFFUSIVITY()))) +
    geom_line() +
    facet_wrap(~variable, scales = "free_y") +
    guides(color = guide_legend(title = expression(DIFFUSIVITY())))

###########################################
#lhs set up


install.packages("lhs")
library(lhs)
set.seed(2455)
#35 ensembles and 4 parameters as trial
lhs_design = maximinLHS(35, 4)

colnames(lhs_design) <- c("ECS", "OceanDiff","AerosolF","VolcanicF")
ranges <-
    list(lower = c(1, 1, 0, 0),
         upper = c(4.5, 5, 2.44, 3.66))

cube2box <- function(X, lower, upper, check = TRUE, eps = 1e-6) {
    is.axial <- inherits(X, "axial")
    stopifnot(is.matrix(X))
    p <- ncol(X)
    stopifnot(length(lower) == p, length(upper) == p)
    X <- t(X)
    if (check) stopifnot(0 - eps < X, X < 1 + eps)
    # This bit:
    robj <- t(X * (upper - lower) + lower)
    if (is.axial)
        class(robj) <- c("matrix", "axial")
    robj
}

lhs_des <- maximinLHS(35, 4)
ens_params <- cube2box(lhs_des, ranges$lower, ranges$upper)
ens_params
write.csv(ens_params, "ens_params.csv")





##############################################
#trial attempt to change Ocean diffusivity and run.
#Keep in mind calibrated parameters from Dorheim et al., 2023 to match observation data.


parameter_values <- read.csv("ens_params.csv")

# Adding the parameter names names to the data frame so the subsetting in the for
# loop works.
names(parameter_values) <- c("Climate.Sensitivity", "Ocean.Heat.diffusivity",
                             "Aerosol.forcing", "Volcanic.forcing")

# Make an empty data frame to store the results in!
output <- data.frame()

# This for loop is running over each of the rows in the parameter_values data frame
for (i in 1:nrow(parameter_values)) {
    # Adding some print statements can be really helpful when debugging a for loop!
    print(i)

    # Extract parameter values for the current ensemble run
    Climate.Sensitivity <- parameter_values[i, "Climate.Sensitivity"]
    Ocean.Heat.diffusivity <- parameter_values[i, "Ocean.Heat.diffusivity"]
    Aerosol.forcing <- parameter_values[i, "Aerosol.forcing"]
    Volcanic.forcing <- parameter_values[i, "Volcanic.forcing"]

    # Setting the new diffusivity parameter value, running the model, and
    # fetching the results is going to need to happen in the for loop.
    print(cat("Ocean.Heat.diffusivity ", Ocean.Heat.diffusivity))
    setvar(core = core, dates = NA, var = DIFFUSIVITY(), values = Ocean.Heat.diffusivity, unit = "cm2/s")
    # TODO when you are ready add more setvar calls for the other parameters you'd like to vary.

    # reset the core to make sure the core is ready to run and uses
    # the new parameter value, this is an important step when using a for loop
    # to rerun the same hector core over and over again.
    reset(core)

    run(core)

    # Get the variables!
    OD_attempt <- fetchvars(core, 1850:2024)

    # Add information about which parameters were used to for the Hector run
    OD_attempt[, "scenario"] <- i

    # Since every time the for loop is running the OD_attempt data frame
    # is going to be overwritten so we will want to concatenate the new
    # results to previous run results.
    output <- rbind(output, OD_attempt)


}

library(ggplot2)

ggplot(output) +
    aes(x = year, y = value, color = factor(scenario)) +
    geom_line() +
    facet_wrap(~variable, scales = "free_y")


# Save a copy of the session info!
sink("./Issue_738/GHI_7238-session_info.txt")
sessionInfo()
sink()
