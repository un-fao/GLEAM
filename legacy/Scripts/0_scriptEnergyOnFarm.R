GLEAM_input <- fread("inst/extdata/GLEAM_input_herd.csv")
EnergyEF_df<-fread("inst/extdata/Electricity_parameters/IEA_ElectricityGrid.csv")

source("legacy/Functions/0_functions_Energyonfarm.R")

output_energy<-calculate_energy_onfarm(GLEAM_input, EnergyEF_df, reference_year="2019", source="Electricity only") #other option: Electricity and heat
