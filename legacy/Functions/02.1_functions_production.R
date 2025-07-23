# Milk production
# kg milk/head/year
calculate_milk_production <- function(milk_yield, assessment_duration, size, milking_fraction, milk_protein) {
  
  # Annual milk production 
  milk_production <- milk_yield * assessment_duration * size * milking_fraction
  
  # Annual milk protein production
  milk_protein_production <- milk_production * milk_protein
  
  # Return both as a data.frame or list
  return(data.frame(
    milk_production = milk_production,
    milk_protein_production = milk_protein_production
  ))
}


# Fibre yield (this is needed also to use the data for energy requirements calculations)
# Output: kg fibre/head/day
calculate_fibre_yield_per_head <- function(dt, assessment_duration, fibre_cohorts = c("FA", "MA", "SA", "SM"), non_fibre_cohorts = c("FJ", "MJ")) {
  
  # Step 1: Calculate total fibre-producing size per group
  fibre_cohort_size_per_group <- dt[cohort %in% fibre_cohorts,
                                    .(fibre_cohorts_size = sum(size, na.rm = TRUE)),
                                    by = .(ADM0_CODE, Animal_short, LPS_short, HerdType_short)]
  
  # Step 2: Merge with original table
  dt <- merge(dt,
              fibre_cohort_size_per_group,
              by = c("ADM0_CODE", "Animal_short", "LPS_short", "HerdType_short"),
              all.x = TRUE)
  
  # Step 3: Replace fibre_prod with per-head values
  dt[, fibre_yield := fifelse(fibre_cohorts_size > 0, (fibre_prod / fibre_cohorts_size)/assessment_duration, 0)]
  
  # Step 4: Set fibre_prod to 0 for non-fibre cohorts like FJ, MJ
  dt[cohort %in% non_fibre_cohorts, fibre_yield := 0]
  
  # Step 5: Clean up temporary column
  dt[, fibre_cohorts_size := NULL]
  
  return(dt)
}

# Fibre production 
# Output: kg fibre/head/year
calculate_fibre_production <- function(fibre_yield, assessment_duration, size) {
  
  fibre_production<-fibre_yield * assessment_duration * size
  return(fibre_production)
}


# Meat production
# Output: kg meat/head/year (as live weight, carcass weight, bone-free-meat, meat protein)
calculate_meat_production <- function(offtake_number, slaughterLW, carcass_dressing_percentage, bone_free_meat_fraction, meat_protein) {
  
  # Step-by-step calculations
  meat_production_liveweight <- offtake_number * slaughterLW
  meat_production_carcassweight <- meat_production_liveweight * carcass_dressing_percentage
  meat_production_meat <- meat_production_carcassweight * bone_free_meat_fraction
  meat_production_protein <- meat_production_meat * meat_protein
  
  # Return all as a data.frame
  return(data.frame(
    meat_production_liveweight = meat_production_liveweight,
    meat_production_carcassweight = meat_production_carcassweight,
    meat_production_meat = meat_production_meat,
    meat_production_protein = meat_production_protein
  ))
}

# Eggs production
# kg eggs/head/year

# calculate_eggs_production <- function(animal, LPS, cohort, CYCLE, CLTSIZE, EGGSYEAR, EGGWGHT) {
#   
#   if (animal == "CHK") {
#     # EGGS FOR REPRODUCTION
#     if  (LPS %in% c("BCK")) {
#       EGGSrepro = CYCLE * CLTSIZE
#       if (EGGSrepro > EGGSYEAR) {
#         EGGSrepro = EGGSYEAR
#       }
#     } else {
#       EGGSrepro = EGGSYEAR
#     }
#     # TOTAL EGG PRODUCTION
#     if ((LPS %in% c("BRL")) | (cohort %in% c("AM", "RF", "RM", "MF1", "MF3", "MM"))) {
#       EGGS_N_consume = 0
#       EGGS_KG = 0
#     }
#     else {
#       if (cohort %in% c("AF")) {
#         EGGS_N_consume = EGGSYEAR - EGGSrepro
#       }
#       else if (cohort %in% c("MF2", "MF4")) {
#         EGGS_N_consume = EGGSYEAR
#       }
#       
#       EGGS_KG = EGGS_N_consume * EGGWGHT / 1000
#     }
#     return(EGGS_KG)
#     
#   } else { return(NA) }
# }

