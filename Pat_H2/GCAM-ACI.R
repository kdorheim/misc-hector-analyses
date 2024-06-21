# Objective: Look into Pat's GCAM-ACI forcing calculation, so it does look like
# the ACI RF needs to be normalized by the value from 1750, which is not equal to
# 0 initially. Although I am not sure why after normalizing we are getting a different
# value... I do think that the conversion value is correct

# Load the required libs
library(dplyr)
library(tidyr)

# Define the conversion units
RHO_ACI <- 2.279759
S_SO2 <- 130303.3
S_BCOC <- 111.05064063
CONVERSION_UNIT <- (1000) * (32.065 / 64.066)

# 1750 Hector Emission Values
E_BC <- 2.097770755
E_OC <- 15.44766815
E_SO2 <- 1221.927531

RF_ACI_1750 <- -1 * RHO_ACI * log(1 + E_SO2/S_SO2 + (E_BC + E_OC)/S_BCOC )

# 2050 Hector Emission Values using values from the climate-log.txt file
E_BC <- 5.69342
E_OC <- 22.1296
E_SO2 <- 31511.3

RF_ACI_2050 <- -1 * RHO_ACI * log(1 + E_SO2/S_SO2 + (E_BC + E_OC)/S_BCOC )

# Comparison of values back calculated vs value reported in the output stream
my_value <- RF_ACI_2050 - RF_ACI_1750
outputstream_value <- -0.5599

my_value - outputstream_value



