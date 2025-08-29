#===== FIRST PART======

# Energy to produce milk----
# Energy to produce total milk, MJ
calculate_milk_production <- function(output_milk_fpcm_production, 
                                      standard_protein,
                                      standard_fat,
                                      standard_lactose) {
  
  # Calculate energy content of standard milk ----
  energy_standard <- (0.0929 * standard_fat + 0.0547 * standard_protein + 0.0395 * standard_lactose) * 4.184 * 100 # MJ/kg milk (IDF 2022 / Bulletin of the IDF N°520/2022: The IDF global Carbon Footprint standard for the dairy sector / pag 82) || 
  # The coefficients (0.0929, 0.0547, 0.0395) used to estimate energy standards are from IDF (2022) and represent
  # kcal per 100 g milk for each 1% unit of fat, protein, or lactose.
  # -> Multiply by % composition (g/100 g) to get kcal per 100 g milk.
  # -> Multiply by 100 to scale to kcal per kg milk.
  # -> Multiply by 4.184 to convert kcal → kJ, then ÷1000 → MJ.
  # Final result: MJ/kg milk (energy density of standard milk).
  
  energy_allocation_milk <- energy_standard * output_milk_fpcm_production # Energy to produce total milk, MJ
  
  # Return both as a data.frame or list
  return(energy_allocation_milk)
}





# Energy to produce meat-----
# energy requirement for meat production by Animal_short 
# Energy to produce total meat, MJ
calculate_energy_allocation_meat <- function(Animal_short, 
                                             cohort, 
                                             afc,
                                             slaughterLW,
                                             initialLW,
                                             ckg,
                                             output_meat_production_liveweight) {
  ret <- NA_real_  # default fallback
  
  if (Animal_short %in% c("CTL", "BFL")) {
    if (cohort %in% c("FA", "FS", "FJ")) { 
      cgro <- 0.8
    } else if (cohort %in% c("MA", "MS", "MJ")) { 
      cgro <- 1
    }
    ret <- ( ( 22.02*( ( (slaughterLW - ckg)/2) / (cgro*slaughterLW) )^0.75 * (slaughterLW-ckg)^1.097) ) / slaughterLW 
    
  } else if (Animal_short %in% c("CML")) {
    ret  <- ( 41.8 * (slaughterLW - ckg) )/slaughterLW
    
    
  } else if (Animal_short %in% c("SHP", "GTS")) {
    if (Animal_short == "SHP") {
      if (cohort %in% c("FA", "FS", "FJ")) { 
        a <- 2.1
        b <- 0.45 
      } else if (cohort %in% c("MA", "MS", "MJ")) { 
        a <- 4.4
        b <- 0.32
      }
    } else if (Animal_short == "GTS") {
      a <- 5
      b <- 0.33 
    }
    ret <- ( ( slaughterLW - ckg) *( a + 0.5 * b * (ckg + slaughterLW))) / slaughterLW
    
    # } else if (Animal_short %in% c("CHK")) {
    #   if (LPS %in% c("LYR", "BCK")) {
    #     a <- 0.0279
    #     b <- 0.02117
    #   } else if (LPS == "BRL") {
    #     a <- 0.03185
    #     b <- 0.01045 }
    #   if (cohort %in% c("AF", "AM", "MF2", "MF3", "MF4")) {  
    #     ret <- ( ( (slaughterLW - initialLW) * 1000 * a ) + (initialLW - ckg) * 1000 * b ) / slaughterLW 
    #   } else if (cohort %in% c("RF", "RM", "MF1", "MM")) {
    #     ret <- ( (slaughterLW - ckg) * 1000 * b ) / slaughterLW
    #   } 
    
  } else if (Animal_short %in% c("PGS")) { 
    ret <- NA 
  }
  
  energy_allocation_meat <- ret * output_meat_production_liveweight
  
  return(energy_allocation_meat)
}

# Energy to produce fiber------
# Energy to produce total fiber, MJ
calculate_energy_allocation_fibre <- function(Animal_short,
                                              nefibre,  
                                              ratio_ne_me,
                                              assessment_duration = 365) {
  
  if (Animal_short %in% c("GTS", "SHP")) {
    energy_allocation_fibre <- nefibre * assessment_duration
    
    } else if (Animal_short %in% c("CML")) {
    energy_allocation_fibre <- nefibre * ratio_ne_me * assessment_duration 
   
    } else {
    energy_allocation_fibre <- 0
  }
  
  # Return both as a data.frame or list
  return(energy_allocation_fibre)
}



# Energy for working-----
# Energy associated with total working time in the assessment timespan, MJ
calculate_energy_allocation_work <- function(Animal_short, nework, ratio_ne_me, assessment_duration = 365) {
  
  if (Animal_short %in% c("CML")) {
    energy_allocation_work <- nework * ratio_ne_me * assessment_duration 
  } else {
    energy_allocation_work <- nework * assessment_duration 
  }
  
  # Return as a numeric value 
  return(energy_allocation_work)
}



# Energy for egg production-----
# Energy associated with total egg production, MJ
# calculate_energy_allocation_eggs <- function(**,  assessment_duration = 365) {
#   
#   energy_allocation_eggs<-** * assessment_duration
#   
#   
#   # Return both as a data.frame or list
#   return(energy_allocation_eggs)
# }

#===== SECOND PART======

# From cohort to hed----
calculate_from_cohort_to_herd_energy_allocation <- function(gleam_data,
                                        summarize_by) {
  
  # ensure data.table behavior
  summary_dt <- gleam_data[
    ,
    .(
      energy_allocation_meat   = sum(energy_allocation_meat, na.rm = TRUE),
      energy_allocation_milk   = sum(energy_allocation_milk, na.rm = TRUE),
      energy_allocation_fibre  = sum(energy_allocation_fibre, na.rm = TRUE),
      energy_allocation_work   = sum(energy_allocation_work, na.rm = TRUE)
      # energy_allocation_eggs = sum(energy_allocation_eggs, na.rm = TRUE) # optional
    ),
    by = summarize_by
  ]
  
  return(summary_dt)
}


# Allocation fractions-----
calculate_allocation_fractions <- function(
    energy_allocation_meat, energy_allocation_milk, energy_allocation_fibre, energy_allocation_work, energy_allocation_eggs,
    Animal_short
) {
  # Use provided energy values (not undefined variables)
  total_allocation_energy <- energy_allocation_meat + energy_allocation_milk + energy_allocation_fibre + energy_allocation_work + energy_allocation_eggs
  
  # If Animal_short is "PGS", assign 100% allocation to meat
  if (!is.null(Animal_short) && Animal_short == "PGS") {
    return(list(
      allocation_share_meat = 1,
      allocation_share_milk = 0,
      allocation_share_work = 0,
      allocation_share_fibre = 0,
      allocation_share_eggs = 0
    ))
  }
  
  # Check for NA or zero total
  if (is.na(total_allocation_energy) || total_allocation_energy == 0) {
    allocation_share_meat <- NA_real_
    allocation_share_milk <- NA_real_
    allocation_share_work <- NA_real_
    allocation_share_fibre <- NA_real_
    allocation_share_eggs <- NA_real_
  } else {
    allocation_share_meat <- energy_allocation_meat / total_allocation_energy
    allocation_share_milk <- energy_allocation_milk / total_allocation_energy
    allocation_share_work <- energy_allocation_work / total_allocation_energy
    allocation_share_fibre <- energy_allocation_fibre / total_allocation_energy  
    allocation_share_eggs <- energy_allocation_eggs / total_allocation_energy
  }
  
  return(list(
    allocation_share_meat, 
    allocation_share_milk,
    allocation_share_work,
    allocation_share_fibre,
    allocation_share_eggs
  ))
}



# From width to long----
melt_energy_allocation <- function(gleam_data,
                                   id_vars) {
  
  # melt allocation share columns into long format
  long_dt <- melt(
    gleam_data,
    id.vars = id_vars,
    measure.vars = patterns("^allocation_share_"),
    variable.name = "commodity_name",
    value.name   = "V1"
  )
  
  # clean up commodity_name (remove prefix)
  long_dt[, commodity_name := gsub("^allocation_share_", "", commodity_name)]
  long_dt[, commodity_name := paste0(toupper(substr(commodity_name, 1, 1)),
                                     substr(commodity_name, 2, nchar(commodity_name)))] 
  # map commodity_type
  edible     <- c("Meat", "Milk", "Eggs")
  non_edible <- c("Fibre", "Work")
  
  long_dt[, commodity_type := fifelse(commodity_name %in% edible, "Edible",
                                      fifelse(commodity_name %in% non_edible, "NonEdible", NA_character_))]
  
  setcolorder(long_dt, c(setdiff(names(long_dt), "V1"), "V1"))
  
  return(long_dt[])
}
