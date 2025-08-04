GLEAM_input_production <- fread("inst/extdata/GLEAM_input_production.csv")
lactose_lookup <- fread("inst/extdata/GLEAM_MilkDefault_LactoseContent.csv")

source("legacy/Functions/02.1_functions_production.R")



# Milk production
# Output: kg milk/head/year
GLEAM_input_production[, c("output_milk_mass_production", 
                           "output_milk_protein_production", 
                           "output_milk_fpcm_production") :=
                         calculate_milk_production(
                           milk_yield = milk_yield,
                           assessment_duration = 365,
                           size = size,
                           milking_fraction = milking_fraction,
                           milk_protein = milk_protein,
                           milk_fat = milk_fat,
                           Animal_short = Animal_short,
                           lactose_lookup = lactose_lookup,
                           standard_protein = 0.033,
                           standard_fat = 0.04,
                           standard_lactose = 0.048
                         ), 
                       by = .I  # apply per row
]



# Fibre yield (this is needed also to use the data for energy requirements calculations)
# Output: kg fibre/head/day
GLEAM_input_production <- calculate_fibre_yield_per_head(GLEAM_input_production, 
                                                         assessment_duration=365,
                                                         fibre_cohorts = c("FA", "MA", "SA", "SM"), 
                                                         non_fibre_cohorts = c("FJ", "MJ"),
                                                         merge_by = c("ADM0_CODE", "Animal_short", "LPS_short", "HerdType_short"))


# Fibre production 
# Output: kg fibre/head/year
GLEAM_input_production[, output_fibre_production := 
                         calculate_fibre_production(fibre_yield, assessment_duration=365, size)]



# Meat production
# Output: kg meat/head/year (as live weight, carcass weight, bone-free-meat, meat protein)
GLEAM_input_production[, c("output_meat_production_liveweight", "output_meat_production_carcassweight", "output_meat_production_meat", "output_meat_production_protein") := 
                         calculate_meat_production(offtake_number, 
                                                   slaughter_weight, 
                                                   carcass_dressing_percentage, 
                                                   bone_free_meat_fraction, 
                                                   meat_protein)]



# Eggs production
# kg eggs/head/year

# PLACEHOLDER

# OUTPUT TABLE -----
fwrite(GLEAM_input_production, "inst/extdata/GLEAM_input_feed.csv")
