# Energy to produce meat
# energy requirement for meat production by Animal_short 
# MJ/kg Slaughter weight
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




# Energy to produce milk
# MJ/kg FPCM
calculate_milk_production <- function(milk_output_fpcm, 
                                      standard_protein,
                                      standard_fat,
                                      standard_lactose) {
  
  # Calculate energy content of standard milk ----
  energy_standard <- (0.0929 * standard_fat + 0.0547 * standard_protein + 0.0395 * standard_lactose) * 4.184 * 100 # MJ/kg (IDF 2022 / Bulletin of the IDF N°520/2022: The IDF global Carbon Footprint standard for the dairy sector / pag 82)
  
  energy_allocation_milk <- energy_standard * milk_output_fpcm
  
  # Return both as a data.frame or list
  return(energy_allocation_milk)
}



calculate_energy_allocation_fibre <- function(nefibre,  assessment_duration = 365) {
  
  energy_allocation_fibre<-nefibre * assessment_duration
  
  
  # Return both as a data.frame or list
  return(energy_allocation_fibre)
}



calculate_energy_allocation_work <- function(nework,  assessment_duration = 365) {
  
  energy_allocation_work<-nework * assessment_duration
  
  
  # Return both as a data.frame or list
  return(energy_allocation_work)
}





# calculate_energy_allocation_eggs <- function(**,  assessment_duration = 365) {
#   
#   energy_allocation_eggs<-** * assessment_duration
#   
#   
#   # Return both as a data.frame or list
#   return(energy_allocation_eggs)
# }


calculate_allocation_shares <- function(
    energy_meat, energy_milk, energy_fibre, energy_work, energy_eggs,
    Animal_short
) {
  # Use provided energy values (not undefined variables)
  total_energy <- energy_meat + energy_milk + energy_fibre + energy_work + energy_eggs
  
  # If Animal_short is "PGS", assign 100% allocation to meat
  if (!is.null(Animal_short) && Animal_short == "PGS") {
    return(list(
      allocation_share_meat = 1,
      allocation_share_milk = 0,
      allocation_share_work = 0,
      allocation_share_wool = 0,
      allocation_share_eggs = 0
    ))
  }
  
  # Check for NA or zero total
  if (is.na(total_energy) || total_energy == 0) {
    share_meat <- NA_real_
    share_milk <- NA_real_
    share_work <- NA_real_
    share_wool <- NA_real_
    share_eggs <- NA_real_
  } else {
    share_meat <- energy_meat / total_energy
    share_milk <- energy_milk / total_energy
    share_work <- energy_work / total_energy
    share_wool <- energy_fibre / total_energy  
    share_eggs <- energy_eggs / total_energy
  }
  
  return(list(
    allocation_share_meat = share_meat,
    allocation_share_milk = share_milk,
    allocation_share_work = share_work,
    allocation_share_wool = share_wool,
    allocation_share_eggs = share_eggs
  ))
}
