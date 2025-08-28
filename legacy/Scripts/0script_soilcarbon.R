library(data.table)

# define base path
my_path <- "~/Library/CloudStorage/OneDrive-FoodandAgricultureOrganization/GLEAM scripts and codes/gleam/"

# read parameters
soil_type_params <- fread(file.path(my_path, "inst/extdata/SoilCarbon_parameters/soc_socref_soiltype.csv"))
management_params <- fread(file.path(my_path, "inst/extdata/SoilCarbon_parameters/soc_factor_management.csv"))
luc_factors <- fread(file.path(my_path, "inst/extdata/SoilCarbon_parameters/soc_luc_factor.csv"))

# Functions
source(file.path(my_path, "legacy/Functions/0_functions_soilcarbon.R"))

# Read input files (Example)
# data<-fread(file.path(my_path, "inst/extdata/soc_input_data.csv"))

# Calling the function
# outputs: 
# SOC1, #soil organic carbon stock at the beginning of the inventory time period, tonnes C
# SOC2, #soil organic carbon stock in the last year of an inventory time period, tonnes C
# dSOC # = annual change in carbon stocks in mineral soils, tonnes C yr-1
# Land USE CHANGE not considered

data[, c("SOC1","SOC2","dSOC") := 
       calculate_soil_organic_carbon(
         area = area,                          # Area in ha (provided by the user )
         climate_zone = climate_zone,          # IPCC climate zone | levels = c("TropicalMontane", "TropicalWet", "TropicalMoist", "TropicalDry", "WarmTemperateMoist", "WarmTemperateDry","CoolTemperateMoist", "CoolTemperateDry", "BorealMoist","BorealDry","PolarMoist","PolarDry")
         socRef = socRef,                      # tonnes of carbon per ha, tC/ha) | Prompt: leave NA to use soil_type_params lookup (if not, use specific input)
         soil_type = soil_type,                # IPCC soil types | levels = c("HighActivityClay", "LowActivityClay", "Sandy", "Spodic", "Volcanic", "Wetland") 
         management_start = management_start,  # IPCC management types | levels = c("ImprovedMediumInput","ImprovedHighInput", "SeverelyDegraded", "HighIntensityGrazing", "NonDegraded")
         management_end   = management_end,    # IPCC management types | levels = c("ImprovedMediumInput","ImprovedHighInput", "SeverelyDegraded", "HighIntensityGrazing", "NonDegraded")
         management_params = management_params, # stock change factor for management regime, dimensionless. dataset with IPCC factors from SOC default values are sourced from the IPCC Guidelines (2019 refinement). Chapter 2 / TABLE 3.3.4 
         soil_type_params = soil_type_params,   # stock change factor for management regime, dimensionless. dataset with IPCC factors from SOC default values (tC/ha) are sourced from the IPCC Guidelines (2019 refinement). Chapter 2 - TABLE 3.3.3
         luc_factors = luc_factors             # stock change factor for land use or land-use change type, dimensionless (IPCC Guidelines (2019 refinement). Chapter 2; set to 1 for now)
       ),
     by = 1:nrow(data)]
