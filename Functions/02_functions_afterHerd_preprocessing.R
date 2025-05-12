# Function to calculate cohort-specific weights at different lifestage
get_stepLW <- function(
    Animal_short, cohort, AFKG, AMKG, CKG, MFSKG, MMSKG, WKG, AFC, WA) {
  if (cohort %in% c("FJ")) {
    initialLW <- CKG
    if (Animal_short %in% c("PGS", "CML")) {
      potfinalLW <- slaughterLW <- WKG
    } else if (Animal_short %in% c("CTL", "BFL", "SHP", "GTS")) {
      potfinalLW <- slaughterLW <- ((AFKG - CKG) / AFC) * WA + CKG
    }
  } else if (cohort %in% c("MJ")) {
    initialLW <- CKG
    if (Animal_short %in% c("PGS", "CML")) {
      potfinalLW <- slaughterLW <- WKG
    } else if (Animal_short %in% c("CTL", "BFL", "SHP", "GTS")) {
      potfinalLW <- slaughterLW <- ((AMKG - CKG) / AFC) * WA + CKG
    }
  } else if (cohort == "FS") {
    if (Animal_short %in% c("PGS", "CML")) {
      initialLW <- WKG
    } else if (Animal_short %in% c("CTL", "BFL", "SHP", "GTS")) {
      initialLW <- ((AFKG - CKG) / AFC) * WA + CKG
    }
    potfinalLW <- AFKG
    slaughterLW <- MFSKG
  } else if (cohort == "MS") {
    if (Animal_short %in% c("PGS", "CML")) {
      initialLW <- WKG
    } else if (Animal_short %in% c("CTL", "BFL", "SHP", "GTS")) {
      initialLW <- ((AMKG - CKG) / AFC) * WA + CKG
    }
    potfinalLW <- AMKG
    slaughterLW <- MMSKG
  } else if (cohort == "FA") {
    initialLW <- potfinalLW <- slaughterLW <- AFKG
  } else if (cohort == "MA") {
    initialLW <- potfinalLW <- slaughterLW <- AMKG
  }
  
  ret <- list(initialLW, potfinalLW, slaughterLW)
  names(ret) <- c("initialLW", "potfinalLW", "slaughterLW")
  return(ret)
}

# Function to calculate cohort-specific average and final weights
get_otherLW <- function(initialLW, potfinalLW, slaughterLW, offtake_rate) {
  averageLW <- (initialLW + (potfinalLW * (1 - offtake_rate) + slaughterLW * (offtake_rate))) / 2
  finalLW <- potfinalLW * (1 - offtake_rate) + slaughterLW * (offtake_rate)
  ret <- list(averageLW, finalLW)
  names(ret) <- c("averageLW", "finalLW")
  return(ret)
}

get_dwg <- function(potfinalLW, initialLW, duration) {
  dwg <- (potfinalLW - initialLW) / duration
  return(dwg)
}
