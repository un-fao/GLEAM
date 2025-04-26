# Function direct_nemain - 3.6.1.1
# *computes Net energy for maintenance
# output: MJ/head/day
Dfunction_nemain = function(Animal_short, # CTL, BFL, SHP, GTS, PGS, CHK, CML
                            cohort, # CTL, BFL, SHP, PGS, CHK
                            afc,
                            averageLW, # CTL, BFL, SHP, GTS, PGS, CHK
                            milking_fraction, # CTL / proportion of lactating adult females
                            offtake_rate, # CTL, BFL, SHP, GTS, PGS, CHK, CML / offtake rate by cohort
                            idle, # PGS
                            gest, # PGS
                            lact, # PGS
                            litsize, # PGS
                            ckg ){
  
  cmain <- NA  # Ensure `cmain` always exists
  
  if (Animal_short %in% c("CTL", "BFL")){
    
    if (cohort %in% c("FA")){
      cmain = 0.386 * milking_fraction + 0.322 * (1 - milking_fraction)
      
    } else if (cohort %in% c("FS", "FJ", "MJ")){
      cmain = 0.322
      
    } else if (cohort %in% c("MA", "MS")){
      cmain = 0.37 * offtake_rate + (0.322) * (1 - offtake_rate)
    }
    
  } else if (Animal_short == "CML"){
    cmain = 0.435
    
  } else if (Animal_short == "GTS"){
    cmain = 0.315
    
  } else if (Animal_short == "SHP") {
    if (cohort == "FA") {
      cmain <- 0.217
    } else if (cohort == "FS") {
      cmain <- (0.236 * (1 / afc)) + (0.217 * ((afc - 1) / afc))
    } else if (cohort == "FJ") {
      cmain <- 0.236
    } else if (cohort == "MA") {
      cmain <- 0.217 * offtake_rate + 0.217 * 1.15 * (1 - offtake_rate)
    } else if (cohort == "MS") {
      cmain <- ((0.271 * offtake_rate + 0.217 * 1.15 * (1 - offtake_rate)) * ((afc - 1) / afc) +
                  (0.236 * offtake_rate + 0.236 * 1.15 * (1 - offtake_rate)) * (1 / afc))
    } else if (cohort == "MJ") {
      cmain <- 0.236 * offtake_rate + 0.236 * 1.15 * (1 - offtake_rate)
    }
  } else if (Animal_short == "PGS") {
    cmain <- 0.4435
    
    if (cohort == "FA") {
      
      lw_AF <- ((averageLW^0.75 * idle) +
                  ((averageLW + (litsize * ckg + 0.15 * averageLW) / 2)^0.75 * gest) +
                  ((averageLW + (0.15 * averageLW) / 2)^0.75 * lact)) /
        (idle + gest + lact)
      
      return(lw_AF * cmain) 
    }
  # } else if (Animal_short == "CHK"){
  #   if (lps == "BCK") {
  #     lct = 24.54 - 5.65
  #     if (cohort  %in% c("AF", "AM", "MF2", "MF3", "MF4")){
  #       cmain = 0.6928 - 9.9*10^-3 * temp
  #     } else if (cohort  %in% c("RF", "RM", "MF1", "MM")){
  #       cmain = (92.4 + 0.88 * (temp - lct)) * 4.186 * 10^-3
  #       if (temp < lct) {
  #         cmain = (92.4 + 6.73 * (lct - temp)) * 4.186 * 10^-3
  #       }
  #     }
  #   } else if (lps == "LYR"){
  #     temp = 20
  #     if (cohort  %in% c("AF", "AM", "MF2", "MF3", "MF4")){
  #       cmain = 0.6928 - 9.9*10^-3 * temp
  #     } else if (cohort  %in% c("RF", "RM", "MF1", "MM")){
  #       cmain = 0.39031
  #     }
  #   } else if (lps == "BRL") {
  #     temp = 20
  #     if (cohort  %in% c("AF", "AM", "MF2", "MF3", "MF4")){
  #       cmain = (192.76 - 6.32 * temp + 0.12 * temp^2) * 4.18 * 10^-3
  #     } else if (cohort  %in% c("RF", "RM")){
  #       cmain = 0.727 - 7.86 * 10^-3 * temp
  #     } else if (cohort  %in% c("MF1", "MM")){
  #       cmain = (307.87 - 15.63 * temp + 0.31 * temp^2) * 4.18 * 10^-3
  #     }
  #   }
  }
  
  # Default return value
  return((averageLW ^ 0.75) * cmain)
}






# Function direct_neact - 3.6.1.2
# *computes Net energy for activity 
# output: MJ/head/day
Dfunction_neact = function(Animal_short, # CTL, BFL, SHP, GTS, PGS, CHK, CML
                           cohort, # SHP
                           past_man_frac, # CTL, BFL, SHP, GTS, CML
                           mmspasture, # CTL, BFL, SHP, GTS, CML
                           nemain, # CTL, BFL, PGS, CHK
                           averageLW, # SHP, GTS, CML
                           offtake_rate # CTL, BFL, SHP, GTS, PGS, CHK, CML / offtake rate by cohort
                           # activity_fraction,
                           # high_activity_fraction
                           
){
  
  if (Animal_short  %in% c("CTL", "BFL")){
    # cact = (0.17 * activity_fraction) + (0.36 * high_activity_fraction)
    cact = (0.17 * mmspasture * past_man_frac) + (0.36 * mmspasture * (1 - past_man_frac))
    ret = cact * nemain
    
  } else if (Animal_short %in% c("CML")){ 
    # cact = (0.1 * activity_fraction) 
    cact = (0.1 * mmspasture) 
    ret = cact * nemain 
    
  } else if (Animal_short  == "SHP"){
    # cact = (0.0107 * activity_fraction) + (0.024 * high_activity_fraction)*(1-offtake_rate) + (0.0067 * offtake_rate)
    cact = (0.0107 * mmspasture * past_man_frac) + (0.024 * mmspasture * (1 - past_man_frac))*(1-offtake_rate) + (0.0067 * offtake_rate)
    if (cohort == "FA"){
      cact = 0.0096
    }
    ret = cact * averageLW
    
  } else if (Animal_short %in% c("GTS")){
    # cact = (0.019 * activity_fraction) + (0.024 * high_activity_fraction)
    cact = (0.019 * mmspasture * past_man_frac) + (0.024 * mmspasture * (1 - past_man_frac))
    ret = cact * averageLW
    
  } else if (Animal_short == "PGS"){ #ASSUMING MMSPASTURE AS A PROXY ALSO FOR PIGS. NEED TO BE REVISED!
    # cact = 0.125 * activity_fraction
    cact = 0.125 * mmspasture
      ret = cact * nemain
  } 
  
  return(ret)
}






# Function direct_negrow - 3.6.1.3
# *net energy required by Animal_short for growth
# output: MJ/head/day
Dfunction_negrow = function(Animal_short, # CTL, BFL, SHP, GTS, PGS, CHK, CML
                            cohort, # CTL, BFL, SHP, GTS, PGS, CHK, CML
                            averageLW, # CTL, BFL, CML
                            finalLW,
                            initialLW, # SHP, GTS
                            dwg, # CTL, BFL, SHP, GTS, PGS, CHK, CML
                            offtake_rate, # Added missing parameter
                            duration #time spent in the cohort
){

  if (Animal_short %in% c("CTL", "BFL")){

    if (cohort %in% c("FS", "FJ")){
      cgro = 0.8
    } else if (cohort %in% c("MS", "MJ")){
      cgro = 1.2 * (1-offtake_rate) + 1 * offtake_rate
    }
    if (cohort %in% c("FS", "FJ", "MS", "MJ")){
      ret = 22.02 * ((averageLW / (cgro * finalLW)) ^ 0.75) * (dwg ^ 1.097)
    } else {
      return(0)  # Explicitly return 0 if cohort does not match
    }

  } else if (Animal_short %in% c("CML")) {

    if (cohort %in% c("FS", "FJ", "MS", "MJ")){
      ret = 41.8 * dwg
    } else {
      ret = 0
    }

  } else if (Animal_short %in% c("SHP")) {

    if (cohort %in% c("FS", "FJ")){
      a <- 2.1
      b <- 0.45

    } else if (cohort %in% c("MS", "MJ")){
      a <- 4.4 * offtake_rate + 2.5 * (1 - offtake_rate)
      b <- 0.32 * offtake_rate + 0.35 * (1 - offtake_rate)

    } else if (cohort %in% c("FA", "MA")){
      a <- 0
      b <- 0
    }

    ret = ((finalLW - initialLW) * (a + 0.5 * b * (initialLW + finalLW))) / duration

  } else if (Animal_short %in% c("GTS")) {

    if (cohort %in% c("FS", "FJ", "MS", "MJ")) {
      a <- 5
      b <- 0.33

    } else if (cohort %in% c("FA", "MA")){
      a <- 0
      b <- 0
    }

    ret = ((finalLW - initialLW) * (a + 0.5 * b * (initialLW + finalLW))) / duration

  } else if (Animal_short == "PGS") {
    prot_tissue_frac = 0.65 #Change from GLEAM3: using the average value for all Animal_shorts (in GLEAM3: used for MED LPS)

    if (cohort %in% c("FS", "FJ", "MS", "MJ")) {
      cgro = (prot_tissue_frac * 0.23 * 54) + ((1 - prot_tissue_frac) * 0.9 * 52.3)
      ret = dwg * cgro
    } else {
      ret = 0
    }
  } else {
    ret = 0  # Default return 0 if `Animal_short` doesn't match any case
  }

  return(ret)
}




# Function direct_nelact - 3.6.1.4
# *metabolizable energy required by Animal_short for lactation  
# output: MJ/head/day
Dfunction_nelact = function(Animal_short, # CTL, BFL, SHP, GTS, PGS, CHK, CML
                            cohort, # CTL, BFL, SHP, GTS, PGS, CML
                            milking_fraction, # CTL, BFL, SHP, GTS, CML / proportion of lactating adult females
                            milk_yield, # CTL, BFL, SHP, GTS, CML
                            milk_fat, # CTL, BFL
                            idle, # PGS
                            gest, # PGS
                            litsize, # PGS
                            dr1, # PGS
                            ckg, # PGS
                            wkg, # PGS
                            lact,
                            parturition_rate,
                            lambing_interval
){
  
  if (Animal_short %in% c("CTL", "BFL")){
    if (cohort == "FA"){
      # ret = milk_yield * (milk_fat * 100 * 0.40 + 1.47) * milking_fraction
      ret = (milk_yield + (parturition_rate*5*(wkg-ckg))/365) * (milk_fat * 100 * 0.40 + 1.47) * milking_fraction
    } else {
      ret = 0
    }
    
  } else if (Animal_short %in% c("CML")){
    if (cohort == "FA"){
      # ret = milk_yield * 4.063 * milking_fraction
      ret = (milk_yield +  (parturition_rate*5*(wkg-ckg))/365) * 4.063 * milking_fraction
    } else {
      ret = 0
    }
    
  } else if (Animal_short %in% c("SHP")){
    if (cohort == "FA"){
      # ret = milk_yield * 4.6 * milking_fraction
      ret = (milk_yield + (litsize*(365*parturition_rate/lambing_interval)*5*(wkg-ckg))/365)* 4.6 * milking_fraction
    } else {
      ret = 0
    }
    
  } else if (Animal_short %in% c("GTS")){ #separating GTS to ensure the correct EV milk
    if (cohort == "FA"){
      # ret = milk_yield * 3 * milking_fraction
      ret = (milk_yield + (litsize*(365*parturition_rate/lambing_interval)*5*(wkg-ckg))/365)* 3 * milking_fraction
    } else {
      ret = 0
    }
    
  } else if (Animal_short == "PGS"){
    if (cohort !="FA") {
    ret = 0 
    } else {
    cadj = lact/ (idle + gest + lact)
    # } else if (cohort == "RF"){
    #   cadj  = (lact / (afc * 365)) * 1/afc
    # }
    # if (cohort %in% c("FA","RF")){
      ret = litsize *(1 - 0.5 * dr1) * ((0.02059 * (wkg - ckg) * 1000 / lact) - (0.3766 / 0.67)) * cadj 
    }
    
    
  return(ret)
  }
}
  


# Function direct_neegg - 3.6.3.3
  # *metabolizable energy required by Animal_short for egg production 
  # output: MJ/head/day
  # Dfunction_neegg = function(Animal_short, # CHK
  #                            cohort, # CHK
  #                            eggs_year, # CHK
  #                            egg_weight # CHK
  # ){
  #   
  #   if (Animal_short == "CHK"){
  #     if (cohort %in% c("FA", "MF2", "MF4")){
  #       eggs = eggs_year/365 * egg_weight
  #       ret = eggs * 0.01003 
  #     } else {
  #       ret = 0
  #     }
  #     
  #   } else if (Animal_short %in% c("CTL", "BFL", "CML", "GTS", "SHP", "PGS")){ 
  #     ret = NA 
  #   }
  #   
  #   return(ret)
  # }
  
  
  
  # Function direct_nework - 3.6.1.5
  # *net energy required by Animal_short for work in the adult males cohort AM 
  # output: MJ/head/day

  Dfunction_nework = function(Animal_short, # CTL, BFL, CML
                              cohort, # CTL, BFL
                              nemain, # CTL, BFL
                              hours, # CTL, BFL, CML
                              draught_fraction
  ){
    
    if (Animal_short %in% c("CTL", "BFL")){
      if (cohort  != "MA"){
        ret = 0
      } else {
        ret <- 0.1 * nemain * hours * draught_fraction
      } 
      
    } else if (Animal_short %in% c("CML")){
      if (cohort  != "MA"){
        ret = 0
      } else {
        ret = 4 * hours * draught_fraction
      }
      
    } else if (Animal_short %in% c("SHP", "GTS", "PGS", "CHK")){
      ret = 0
    }
    
    return(ret)
  }

  
  
  
  
  # Function direct_nefibre - 3.6.1.6
  # *net energy required by Animal_short for fibre production 
  # output: MJ/head/day
  Dfunction_nefibre = function(Animal_short, # SHP, GTS
                               cohort, # SHP, GTS
                               fibre_prod # SHP, GTS
  ){
    
    if (Animal_short %in% c("GTS", "SHP")) {
      if (cohort %in% c("FA", "FS", "MA", "MS")) {
        ret = 24 * fibre_prod/365 #production needs to be at year scale
      } else {
        ret = 0
      }
    } else if (Animal_short %in% c("CML")) {
      if (cohort %in% c("FA", "FS", "MA", "MS")) {
        ret = (24/0.43) * (fibre_prod/365)  # 0.4 efficiency factor for camels to convert from NE to ME
      } else {
        ret = 0
      }
    } else if (Animal_short %in% c("CTL", "BFL", "PGS", "CHK")) {
      ret <- 0  # Not applicable for these Animal_shorts
    }
    
    return(ret)
  }
  
  
  
  # Function direct_nepreg - 3.6.1.7
  # *net energy required by adult females for pregnancy
  # output: MJ/head/day
  Dfunction_nepreg = function(Animal_short, # CTL, BFL, CML, SHP, GTS, PGS, CHK
                              cohort, # CTL, BFL, CML, SHP, GTS, PGS
                              nemain, # CTL, BFL, CML, SHP, GTS
                              parturition_rate, # CTL, BFL, CML, SHP, GTS
                              idle, # PGS
                              lact, # CTL, BFL, PGS
                              litsize, # SHP, GTS, PGS
                              gest, # CTL, BFL, CML, SHP, GTS, PGS, CHK - THIS NEEDS TO BE ADDED!
                              duration,
                              offtake_rate
){

    if (Animal_short %in% c("CTL", "BFL")){
      if (cohort == "FA"){
        ret = (nemain * 0.1 * parturition_rate) 
      } else if (cohort == "FS"){
        ret = (nemain * 0.1) * (1 / (duration/365)) * (1 - offtake_rate)
      } else {
        ret = 0
      }
      
    } else if (Animal_short %in% c("CML")){
      if (cohort == "FA"){
        ret = nemain * 0.12 * parturition_rate
      } else if (cohort == "FS"){
        ret = nemain * 0.12 * (1 / (duration/365)) * (1 - offtake_rate)
      } else {
        ret = 0
      }
      
    } else if (Animal_short %in% c("SHP", "GTS")){
      
      if (cohort == "FA") {
        cpreg <- 0
        if (litsize >= 1 & litsize <= 2) {
          cpreg = (0.077 * (2 - litsize) + 0.126 * (litsize - 1))
        } else if (litsize > 2) {
          cpreg = 0.150
        }
        
        ret = nemain * cpreg * parturition_rate 
        
      } else if (cohort == "FS") {
        ### Assumption: pregnancy duration is 5 months
        ret = nemain * 0.077 * (1 / (duration/365)) * (1 - offtake_rate)
      } else {
        ret = 0
      }
      
    } else if (Animal_short == "PGS"){
      cgest = 0.14985
      if (cohort == "FA"){
        cadj = gest/ (idle + gest + lact)
      } else if (cohort == "FS"){
        cadj  = (gest / (duration)) * (1 / (duration/365)) * (1 - offtake_rate)
      }
      if (cohort %in% c("FA","FS")){
        ret = cgest * litsize * cadj
      } else {
        ret = 0
      }
      
    } else if (Animal_short == "CHK") {
      ret = 0
    } 
    
    return(ret)  # Always return a defined value
  }
  
  
  
  # Function direct_rem - 3.6.1.8
  # *ratio of net energy available in the diet for maintenance to digestible energy for the feeding group 
  # output: fraction
  Dfunction_rem = function(Animal_short, # CTL, BFL, SHP, GTS
                           diet_dig # CTL, BFL, SHP, GTS
  ){
    
    if(Animal_short %in% c("CTL", "BFL", "SHP", "GTS")){
      ret = 1.123 - (0.004092 * (diet_dig*100)) + (0.00001126 * (diet_dig*100)^2) - (25.4/(diet_dig*100))
      
    } else if (Animal_short %in% c("PGS", "CHK", "CML")) {
      ret = NA
    }  
    
    return(ret)
  }
  
  
  
  # Function direct_reg - 3.6.1.9
  # *ratio of net energy available in the diet for growth to digestible energy consumed for the feeding group  
  # output: fraction
  Dfunction_reg = function(Animal_short, # CTL, BFL, SHP, GTS
                           diet_dig # CTL, BFL, SHP, GTS
  ){
    
    if(Animal_short %in% c("CTL", "BFL", "SHP", "GTS")){
      ret = 1.164 - (0.005160 * (diet_dig*100)) + (0.00001308 * (diet_dig*100)^2) - (37.4/(diet_dig*100))
      
    } else if (Animal_short %in% c("PGS", "CHK", "CML")) {
      ret = NA
    }
    
    return(ret)
  }
  
  
  
  # Function direct_getot - 3.6.1.10
  # *total energy requirement by Animal_short 
  # output: MJ/head/day
  Dfunction_getot = function(Animal_short, # CTL, BFL, CML, SHP, GTS, PGS, CHK
                             cohort, # SHP, GTS 
                             nemain, # CTL, BFL, CML, SHP, GTS, PGS, CHK
                             neact, # CTL, BFL, CML, SHP, GTS, PGS, CHK
                             nelact, # CTL, BFL, CML, SHP, GTS, PGS
                             nework, # CTL, BFL
                             nepreg, # CTL, BFL, CML, SHP, GTS, PGS
                             rem, # CTL, BFL, CML, SHP, GTS
                             negrow, # CTL, BFL, CML, SHP, GTS, PGS, CHK
                             nefibre, # SHP, GTS
                             neegg, # CHK
                             reg, # CTL, BFL, CML, SHP, GTS
                             diet_dig, # CTL, BFL, CML, SHP, GTS
                             afc # SHP, GTS
  ){
    
    if(Animal_short  %in% c("CTL", "BFL")){
      ret = (((nemain + neact + nelact + nework + nepreg)/ rem) + ((negrow)/reg))/diet_dig
      
    } else if (Animal_short  %in% c("SHP", "GTS")){
      if(cohort %in% c("RF", "RM")){
        ret = (((nemain + neact + nelact + nepreg)/ rem) + ((negrow + nefibre)/reg))/diet_dig
      } else {
        ret = (((nemain + neact + nelact + nepreg)/ rem) + ((negrow + nefibre)/reg))/diet_dig
      }
      
    } else if(Animal_short  == "CML"){ 
      ret = nemain + neact + nelact + nework + nefibre + nepreg 
      
    } else if(Animal_short  == "PGS"){
      ret = nemain + neact + nelact + nepreg + negrow
      
    } else if(Animal_short  == "CHK"){
      ret = nemain + neact + negrow + neegg
    }  
    
    return(ret)
  }
  
  
  
  # Function nemeat - 3.6.1.10
  # energy requirement for meat production by Animal_short 
  # output: MJ/head
  Dfunction_nemeat <- function(Animal_short, 
                               # LPS_short, 
                               cohort, 
                               afc,
                               slaughterLW,
                               initialLW,
                               ckg) {
    ret <- NA_real_  # default fallback
    
    if (Animal_short %in% c("CTL", "BFL")) {
      if (cohort %in% c("FA", "FS", "FJ")) { 
        cgro <- 0.8
      } else if (cohort %in% c("MA", "MS", "MJ")) { 
        cgro <- 1
      }
      ret <- ( ( 22.02*( ( (slaughterLW - ckg)/2) / (cgro*slaughterLW) )^0.75 * (slaughterLW-ckg)^1.097) ) / slaughterLW 
      
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
    
    return(ret)
  }

  