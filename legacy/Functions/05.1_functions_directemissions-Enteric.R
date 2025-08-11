## ----- function - direct emissions - methane enteric----

# Function YM - 4.2
# *compute ym value for the ch4_enteric
# output: percentage of energy in feed converted into methane.
Dfunction_ym = function (Animal_short, # CTL, BFL, CML, SHP, GTS, PGS
                         cohort, # SHP, GTS, PGS
                         diet_dig # CTL, BFL, SHP, GTS
){
  
  if (Animal_short %in% c("CTL", "BFL")){
    ret = 9.75 - 0.05 * diet_dig * 100
  } else if (Animal_short %in% c("SHP", "GTS", "CML")){
    
    if (cohort %in% c("SF", "SM", "JF", "JM")){
      
      ret = 7.75 - 0.05 * diet_dig * 100
    } else {
      ret = 9.75 - 0.05 * diet_dig * 100
    }
    # } else if (Animal_short %in% c("CML")){
    #   ret = 6.5
  }
  else if (Animal_short %in% c("PGS")){
    if (cohort %in% c("AM", "AF")){
      ret = 1.01
    } else {
      ret = 0.39
    }
  } else if (Animal_short %in% c("CHK")){
    ret = NA
  }
  return(ret)
}

# Function CH4 ENTERIC FERMENTATION - 4.2
# *computes methane from enteric fermentation
# output = kg CH4 per day per animal
Dfunction_ch4_enteric	=	function(Animal_short, # CTL, BFL, CML, SHP, GTS, PGS
                                 cohort, # SHP, GTS 
                                 ym, # CTL, BFL, CML, SHP, GTS, PGS
                                 diet_ge, # CTL, BFL, CML, SHP, GTS, PGS
                                 dmi, # CTL, BFL, CML, SHP, GTS, PGS
                                 afc #SHP, GTS 
){
  
  
  if (Animal_short %in% c("CTL", "BFL", "CML", "PGS", "SHP", "GTS")){
    ret = diet_ge*dmi*(ym/100)/55.65
  } else if (Animal_short %in% c("CHK")){
    ret = NA
  }
  return(ret)
}
