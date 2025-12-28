# Output: kg gas CO2, N2O and CH4 from energy consumption on farm
calculate_energy_onfarm <- function(GLEAM_input, EnergyEF_df, reference_year, 
                                    source = c("Electricity only", "Electricity and heat")) {
  
  GLEAM_input<-copy(as.data.table(GLEAM_input))
  EnergyEF_df<-copy(as.data.table(EnergyEF_df))
  
  # Define varname
  varname <- switch(source,
                    "Electricity only"      = "Electricity",
                    "Electricity and heat"  = "ElectricityHeat",
                    stop("Unknown 'source': ", source,
                         ". Use 'Electricity only' or 'Electricity and heat'.")
  )
  
  # ensure RefYear is integer for comparisons
  EnergyEF_df[, RefYear := as.integer(as.character(RefYear))]
  ref <- as.integer(reference_year)
  
  # candidate years available for this VarName
  cand <- sort(unique(EnergyEF_df[VarName == varname & !is.na(RefYear), RefYear]))
  if (length(cand) == 0L) stop("No years available for VarName = '", varname, "'.")
  
  # pick most recent ≤ reference_year; otherwise earliest > reference_year
  year_use <- cand[which.min(abs(cand - ref))]
  
  # warn if not an exact match
  if (year_use != ref) {
    warning(sprintf("\nNo emissions factor is available for %s reference year.
                   \nThe closest available year was used for the calculation (reference year used:%s).",
                    reference_year, year_use))
  }
  
  gleam_selected <- c("ADM0_CODE", "Animal", "Animal_short", "LPS", "LPS_short", "HerdType", "HerdType_short", "energy_onfarm")
  
  # perform the merge
  rhs <- EnergyEF_df[RefYear == year_use & VarName == varname]
  merged <- merge(
    GLEAM_input[,..gleam_selected],
    rhs[,.(ADM0_CODE, VarName, GWP, Item, V1)],
    by = "ADM0_CODE",
    allow.cartesian = TRUE
  )
  
  
  #Calculate emission from on-farm energy
  merged[, "onfarm_emissions" := energy_onfarm * V1/1000 ]
  merged[, "Unit" := paste0("kg", Item)]
  
  
  # return the merged table (with an attribute indicating which year was used)
  setattr(merged, "RefYearUsed", year_use)
  merged[,.(ADM0_CODE, Animal, Animal_short, LPS, LPS_short, HerdType, HerdType_short, VarName, GWP, Item, onfarm_emissions, Unit, V1)]
}

