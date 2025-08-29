GLEAM_input_allocation<-fread("inst/extdata/GLEAM_input_allocation.csv")
source("legacy/Functions/0_functions_Allocation.R")

# Description
# Purpose: Calculate allocation 
# The final output of this block is to obtain the fraction of allocation for each edible commodity (at herd level)
# Allocation fractions are later used to associate total emissions with the related edible commodities

# The FIRST PART of the code performs the calculations at cohort level of energy required to produce each of the edible/non edible commodity (meat, milk, eggs, fibre, work)
# The SECOND PART of the code moves from cohort level to herd level, summing up the energy_allocation for each product

# Methodological reference: 
# The allocation methodology currently included is the biophysical allocation based on the energy requirements to produce the different products.
# This aligns with:
# International Dairy Federation. (2022). The IDF global carbon footprint standard for the dairy sector. Bulletin of the IDF n 520/2022.
# LEAP guidelines


## INTERNAL NOTE ##: 
# only 1 allocation approach is currently proposed / in the future different types of methodology for allocation could be implemented to provide the user of the package/app with different options


#==== FIRST PART (cohort level)=====
# Energy to produce milk----
# Energy to produce total milk, MJ (by cohort)
# This should be 0 for all cohorts, except for adult females (FA)
#' @param milk_output_fpcm kg of fat and protein corrected milk (standard correction is (in g/L): 0.033 standard protein; 0.04 standard fat; and 0.048 standard lactose). Should be 0 for all cohorts except FA. / CALCULATED IN PRODUCTION 0_scriptProduction
#' @param standard_protein Standard milk protein content, g protein/100 g milk. Default set to 0.033 
#' @param standard_fat Standard milk fat content, g fat/100 g milk. Default set to 0.04
#' @param standard_lactose Standard milk lactose content, g fat/100 g milk. Default set to 0.048

GLEAM_input_allocation[, energy_allocation_milk := calculate_milk_production(output_milk_fpcm_production = output_milk_fpcm_production,
                                                                             standard_protein = 0.033, 
                                                                             standard_fat = 0.04,
                                                                             standard_lactose = 0.048 
                                                                             ), by = seq_len(nrow(GLEAM_input_allocation))]




# Energy to produce meat----
# energy requirement for meat production by Animal_short 
# Energy to produce total meat, MJ  (by cohort)

#' @param Animal_short Categorical variable. Animal species. Levels=c("CTL", "SHP", "GTS", "CML", "BFL", "PGS", "CHK")
#' @param cohort Categorical variable. Cohort =c("FA", "MA", "FS", "MS", "FJ", "MJ" ).
#' @param afc Age at first parturition, years
#' @param slaughterLW Weight at slaughter (by cohort), kg
#' @param initialLW Weight at the beginning of the cohort (by cohort), kg
#' @param ckg Weight at at birth, kg
#' @param output_meat_production_liveweight Total meat production (by cohort), kg LW = kg live weight

GLEAM_input_allocation[, energy_allocation_meat := calculate_energy_allocation_meat(Animal_short, 
                                                                                    cohort, 
                                                                                    afc, #age at first parturition, 
                                                                                    slaughterLW, # Weight at slaughter (by cohort), kg
                                                                                    initialLW, # Weight at the beginning of the cohort (by cohort), kg
                                                                                    ckg, # Weight at at birth, kg
                                                                                    output_meat_production_liveweight # Total meat production (by cohort), kg LW = kg live weight
                                                                                    ), by = seq_len(nrow(GLEAM_input_allocation))]



# Energy to produce fiber----
# Energy requirement for fiber production 
# Energy to produce total fiber, MJ (by cohort)
# This is only relevant for Animal_short = c("GTS", "SHP", "CML") and cohort = c("FA", "MA", "FS", "MS")
#' @param Animal_short Categorical variable. Animal species. Levels=c("CTL", "SHP", "GTS", "CML", "BFL", "PGS", "CHK")
#' @param ne_fibre Net energy (for SHP and GTS) or Metabolizable energy (for CML) required by animal for fibre production, MJ/head/day. (Note: NE=ME*0.43)  / Calculated by the energy requirements functions
#' @param ratio_ne_me Efficiency factor (dimensionless): the proportion of net energy (NE) that can be converted into metabolizable energy (ME). Efficiency factor used for camelids because nefibre is in MJ/head/day of ME, while net energy for the other species. By default is set to 0.43. If someone is using the function alone and has calculate energy requirements for camelids differently (in NE), this should be changed to 0.
#' @param assessment_duration Duration of the assessment, days

GLEAM_input_allocation[, energy_allocation_fibre := calculate_energy_allocation_fibre(Animal_short,
                                                                                      nefibre,  
                                                                                      ratio_ne_me = 0.43, 
                                                                                      assessment_duration = 365 
                                                                                      ), by = seq_len(nrow(GLEAM_input_allocation))]


# Energy for work----
# Energy associated with total working time in the assessment timespan, MJ
#' @param Animal_short Categorical variable. Animal species. Levels=c("CTL", "SHP", "GTS", "CML", "BFL", "PGS", "CHK")
#' @param nework Net energy (for SHP and GTS) or Metabolizable energy (for CML) required by animal for working, MJ/head/day. (Note: NE=ME*0.43) / Calculated by the energy requirements functions
#' @param ratio_ne_me Efficiency factor (dimensionless): the proportion of net energy (NE) that can be converted into metabolizable energy (ME). Efficiency factor used for camelids because nefibre is in MJ/head/day of ME, while net energy for the other species. By default is set to 0.43. If someone is using the function alone and has calculate energy requirements for camelids differently (in NE), this should be changed to 0.
#' @param assessment_duration Duration of the assessment, days

GLEAM_input_allocation[, energy_allocation_work := calculate_energy_allocation_work(Animal_short,
                                                                                    nework,  # Net energy required by Animal_short for working, MJ/head/day
                                                                                    ratio_ne_me = 0.43, 
                                                                                    assessment_duration = 365 # Duration of the assessment
                                                                                    ), by = seq_len(nrow(GLEAM_input_allocation))]

# Energy for egg production-----
# Energy associated with total egg production, MJ
# GLEAM_input_allocation[, energy_allocation_eggs := calculate_energy_allocation_eggs(PLACEHOLDER), by = seq_len(nrow(GLEAM_input_allocation))]


#==== SECOND PART (herd level)=====

# From cohort to herd----
# This function sums up the energy requirements by "summarize_by" key. 
# Therefore, it turns it from cohort level - to herd level
# /!\ INTERNAL NOTE: see the comment for "summarize_by"

GLEAM_summary_allocation <- calculate_from_cohort_to_herd_energy_allocation(
  gleam_data=GLEAM_input_allocation,
  summarize_by = c("ADM0_CODE", "HerdType_short", "Animal_short", "LPS_short") # summarize_by is set here as it should be adapted to the pipeline, and include the record numbers instead/a different final ID
)


# Calculate allocation shares----
# Returns the fractions for each commodity
GLEAM_summary_allocation[, c("allocation_share_meat", "allocation_share_milk", "allocation_share_work",
                             "allocation_share_wool", "allocation_share_eggs") := 
                           calculate_allocation_fractions(
                             energy_allocation_meat, 
                             energy_allocation_milk, 
                             energy_allocation_fibre, 
                             energy_allocation_work, 
                             energy_allocation_eggs=0,
                             Animal_short
                           ),
                         by = 1:nrow(GLEAM_summary_allocation)]



# Width --> Long-----
# Table manipulation from width to long for next steps (combine with emissions + final calculations)
# /!\ INTERNAL NOTE: id_vars has the same issues as "summarize_by" described above
GLEAM_long <- melt_energy_allocation(
  GLEAM_summary_allocation,
  id_vars = c("ADM0_CODE", "Animal_short", "LPS_short", "HerdType_short" )
)