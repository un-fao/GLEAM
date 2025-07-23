library(data.table)
GLEAM_input_production <- fread("inst/extdata/GLEAM_input_production.csv")

source("legacy/Functions/02.1_functions_production.R")

# Milk production
# Output: kg milk/head/year
GLEAM_input_production[, c("output_milk_mass_production", "output_milk_protein_production") := 
                         calculate_milk_production(milk_yield, assessment_duration = 365, size, milking_fraction, milk_protein)]



# Fibre yield (this is needed also to use the data for energy requirements calculations)
# Output: kg fibre/head/day
GLEAM_input_production <- calculate_fibre_yield_per_head(GLEAM_input_production, assessment_duration=365)


# Fibre production 
# Output: kg fibre/head/year
GLEAM_input_production[, output_fibre_production := 
                         calculate_fibre_production(fibre_yield, assessment_duration=365, size)]



# Meat production
# Output: kg meat/head/year (as live weight, carcass weight, bone-free-meat, meat protein)
GLEAM_input_production[, c("output_meat_production_liveweight", "output_meat_production_carcassweight", "output_meat_production_meat", "output_meat_production_protein") := 
                         calculate_meat_production(offtake_number, slaughter_weight, carcass_dressing_percentage, bone_free_meat_fraction, meat_protein)]



# Eggs production
# kg eggs/head/year

# PLACEHOLDER

# OUTPUT TABLE -----
fwrite(GLEAM_input_production, "inst/extdata/GLEAM_input_feed.csv")
