GLEAM_input_allocation<-fread("inst/extdata/GLEAM_input_allocation.csv")
source("legacy/Functions/0_functions_Allocation.R")


# Energy to produce meat
# energy requirement for meat production by Animal_short 
# MJ/kg Slaughter weight
GLEAM_input_allocation[, energy_allocation_meat := calculate_energy_allocation_meat(Animal_short, 
                                                                                    cohort, 
                                                                                    afc,
                                                                                    slaughterLW,
                                                                                    initialLW,
                                                                                    ckg,
                                                                                    output_meat_production_liveweight), by = seq_len(nrow(GLEAM_input_allocation))]




# Energy to produce milk
# MJ/kg FPCM
GLEAM_input_allocation[, energy_allocation_milk := calculate_milk_production(milk_output_fpcm = output_milk_fpcm_production, 
                                                                             standard_protein = 0.033,
                                                                             standard_fat = 0.04,
                                                                             standard_lactose = 0.048), by = seq_len(nrow(GLEAM_input_allocation))]




GLEAM_input_allocation[, energy_allocation_fibre := calculate_energy_allocation_fibre(nefibre,  
                                                                                      assessment_duration = 365), by = seq_len(nrow(GLEAM_input_allocation))]




GLEAM_input_allocation[, energy_allocation_work := calculate_energy_allocation_work(nework,  
                                                                                    assessment_duration = 365), by = seq_len(nrow(GLEAM_input_allocation))]



# GLEAM_input_allocation[, energy_allocation_eggs := calculate_energy_allocation_eggs(PLACEHOLDER), by = seq_len(nrow(GLEAM_input_allocation))]
# 


summarize_by = c("ADM0_CODE", "HerdType_short", "Animal_short", "LPS_short")

#from cohort to herd
GLEAM_summary_allocation <- GLEAM_input_allocation[
  ,
  .(
    energy_allocation_meat   = sum(energy_allocation_meat, na.rm = TRUE),
    energy_allocation_milk   = sum(energy_allocation_milk, na.rm = TRUE),
    energy_allocation_fibre  = sum(energy_allocation_fibre, na.rm = TRUE),
    energy_allocation_work   = sum(energy_allocation_work, na.rm = TRUE)
    # ,
    # energy_allocation_eggs = sum(energy_allocation_eggs, na.rm = TRUE)
  ),
  by = c(summarize_by) # or by = ..summarize_by if NOT inside a function
]

GLEAM_summary_allocation[, c("allocation_share_meat", "allocation_share_milk", "allocation_share_work",
                             "allocation_share_wool", "allocation_share_eggs") := 
                           calculate_allocation_shares(
                             energy_meat=energy_allocation_meat, 
                             energy_milk=energy_allocation_milk, 
                             energy_fibre=energy_allocation_fibre, 
                             energy_work=energy_allocation_work, 
                             energy_eggs=0,
                             Animal_short
                           ),
                         by = 1:nrow(GLEAM_summary_allocation)]
                         