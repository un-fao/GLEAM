## ----- function - direct emissions - nitrogen retention & excretion -----
#Functions to compute nitrogen retention & excretion requirements


# Nitrogen intake
# output = kg N/head/day
Dfunction_n_intake <- function(gleam_data, ipcc_method) {
  gleam_data <- as.data.table(gleam_data)
  
  # Calculate nitrogen intake in g/day
  gleam_data[, n_intake := dmi * diet_nitrogen]
  
  # Return only the result column
  return(gleam_data[, .(n_intake)])
}


# Nitrogen retention
# output = kg N/head/day
Dfunction_n_retention <- function(gleam_data, ipcc_method) {
  
  gleam_data <- copy(gleam_data)
  gleam_data[, n_ret := NA_real_]
  
  # Case 1: CTL, BFL, SHP, GTS, CML
  gleam_data[Animal_short %in% c("CTL", "BFL", "SHP", "GTS", "CML"), 
             n_retention := {
               tissue_n <- ifelse(Animal_short %in% c("CTL", "BFL"), 0.0326, 0.026)
               milk_n <- milk_protein / 6.38
               fibre_n <- 0.0134
               
               milk_comp <- fifelse(cohort == "AF" & !is.na(milk_yield) & milk_yield > 0, 
                                    milk_yield * milk_n, 0)
               growth_comp <- fifelse(!is.na(dwg) & dwg > 0, dwg * tissue_n, 0)
               fibre_comp <- fifelse(!is.na(fibre_prod) & fibre_prod > 0, 
                                     fibre_prod / 365 * fibre_n, 0)
               
               milk_comp + growth_comp + fibre_comp
             }]
  
  # Case 2: PGS
  gleam_data[Animal_short == "PGS", 
             n_retention := fifelse(
               cohort == "AF",
               ((0.025 * litsize * parturition_rate * (wkg - ckg) / 0.98) +
                  (0.025 * litsize * parturition_rate * ckg)) / 365,
               fifelse(
                 cohort == "RF",
                 0.025 * dwg +
                   (1 / afc) * (((0.025 * litsize * parturition_rate * (wkg - ckg) / 0.98) +
                                   (0.025 * litsize * parturition_rate * ckg)) / 365),
                 fifelse(!is.na(dwg), 0.025 * dwg, NA_real_)
               )
             )]
  
  
  
  

  # ==== Case 3: CHK / TO BE ADDED 

    
    # } else if (Animal_short == "CHK") {
    #   if (cohort %in% c("AF", "MF2", "MF4")) {
    #     eggs <- (eggs_year / 365) * egg_weight
    #     ret <- 0.028 * dwg + 0.0185 * 1e-3 * eggs
    #   } else if (cohort == "MF3") {
    #     ret <- 0
    #   } else {
    #     ret <- 0.028 * dwg
    #   }
  
  # Return only the result column
  return(gleam_data[, .(n_retention)])
}


# Nitrogen excretion
# output = kg N/head/day
Dfunction_n_excretion	=	function(gleam_data, ipcc_method
){
  
  gleam_data <- copy(GLEAM_input_directemissions)
  
  
  # CASE 1 / "CTL", "BFL", "CML", "GTS", "SHP", "PGS"
  gleam_data[Animal_short %in% c("CTL", "BFL", "CML", "GTS", "SHP", "PGS"), 
             n_excretion := n_intake - n_retention]
  
  # CASE 2 / CHICKEN - TO BE ADDED
  # } else if  (animal %in% c("CHK")){
  #   if(lps=="BRL" & cohort %in% c("MF1", "MM", "MF2", "MF3", "MF4")){ #note: fraction of time in the housing system -	 age slaughter/period empty(15 DAYS) house MF1 MM MF2 MF3 MF4
  #     m2house = a2s/(a2s+bidle) 
  #     ret = ((dmi * diet_n_cont)/1000 - n_retention) * m2house
  #   } else {
  #     ret = (dmi * diet_n_cont)/1000 - n_retention
  #   }
return(gleam_data[, .(n_excretion)])
}
