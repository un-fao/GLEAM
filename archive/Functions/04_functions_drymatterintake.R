
# Function direct_dmi - 3.7
# *daily feed intake per animal
# output: kg DM/head/day
Dfunction_dmi = function(Animal_short, # CTL, BFL, CML, SHP, GTS, PGS, CHK
                         getot, # CTL, BFL, CML, SHP, GTS, PGS, CHK
                         diet_ge, # CTL, BFL, CML, SHP, GTS
                         diet_me # PGS, CHK
                        ){
  
  if(Animal_short  %in% c("CTL", "BFL", "SHP", "GTS")){
    ret = getot/diet_ge
    
  } else if(Animal_short  %in% c("PGS", "CHK", "CML")){
    ret = getot/diet_me
  }  
  
  return(ret)
}
