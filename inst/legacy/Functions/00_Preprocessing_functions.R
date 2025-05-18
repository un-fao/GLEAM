## function to calculate offtake rate from previous GLEAM parameters
get.afc_pigs <- function (AFKG,AMKG,DWG2,WKG,WA) {
  DWGF = AFKG / ((AFKG + AMKG) / 2) * DWG2
  AFC = (AFKG - WKG) / (365 * DWGF) + WA
  DWGM = AMKG / ((AFKG + AMKG) / 2) * DWG2
  AFCM = (AMKG - WKG) / (365 * DWGM) + WA
  ret <- list(AFC, AFCM)
  names(ret) <- c("AFC", "AFCM")
  return(ret)
}
    
## function to calculate offtake rate from previous GLEAM parameters
get.offtake_rate <- function (
    #Stock,
    Animal_short,
    #AF_FRAC,	##fraction	  fraction of reproductive famales
    AFC,	  ##kg	        age at firs reproduction
    AFCM,	  ##kg	        age at firs reproduction
    CKG,	  ##kg	        Liveweight of piglets at weaning age
    WKG,	  ##kg	        Liveweight of piglets at weaning age
    AFKG,	  ##kg	        Liveweight of adult female
    AMKG,	  ##kg	        Liveweight of adult male
    M2SKG,	##kg	        Liveweight of fattening animals at slaughter
    MFSKG,	##kg	        Liveweight of fattening animals at slaughter
    MMSKG,	##kg	        Liveweight of fattening animals at slaughter
    DR1,	  ##fraction	  Death rate from birth to weaning age
    DR1M,	  ##fraction	  Death rate from birth to weaning age males
    DR2,	  ##fraction	  Death rate of adult ruminants
    DRR2A,	##fraction	  Death rate of replacement animals, from weaning age to first reproduction
    DRR2B,	##fraction	  Death rate of adult animals
    DRF,	  ##fraction	  Death rate of fattening animals, from weaning age to slaughter
    FR,	    ##part/year	  Number of parturitions per sow per year
    FRRF,	  ##fraction	  Rate of fertile replacement females. Note: default value 0.95
    RRF,	  ##fraction	  Replacement of adult females
    RRM,	  ##fraction	  Replacement of adult females
    WA,	    ##year	      Age at weaning
    BCR,	  ##fraction	  Adult male to female ratio
    DWG2,	  ##kg/day	    Daily weight gain of fattening animals
    LITSIZE	##heads	      Litter size, number of piglets per parturition
){
  if (Animal_short %in% c("PGS")) {
    # FEMALES
    AF = 100 # the actual size is not important	
    AFin = AF * RRF
    AFx = AF * DRR2B	
    AFexit = AF * RRF - AFx
    CFin = AF * ((1 - DRR2B) * FR * LITSIZE + RRF * LITSIZE) * (1 - DR1) / 2
    DWGF = AFKG / ((AFKG + AMKG) / 2) * DWG2
    #AFC = (AFKG - WKG) / (365 * DWGF) + WA
    RFin = ((AF * RRF) / FRRF) / (1 - DRR2A)^AFC
    RFexit = ((AF * RRF) / FRRF) - AFin
    MFin = CFin- RFin
    ASF = (M2SKG - WKG) / (365 * DWG2)
    MFexit = MFin * (1 - DRF)^ASF
    # MALES
    AM = AF * BCR
    AMx = AM * DRR2B
    AMin = AM * RRM
    AMexit = AMin - AMx
    CMin = CFin
    DWGM = AMKG / ((AFKG + AMKG) / 2) * DWG2
    #AFCM = (AMKG - WKG) / (365 * DWGM) + WA
    RMin = AMin / (1 - DRR2A)^AFCM
    MMin = CMin - RMin
    ASM = (M2SKG - WKG) / (365 * DWG2)
    MMexit = MMin * (1 - DRF)^ASM
  } 
  else if (Animal_short %in% c("CTL", "BFL", "CML", "SHP", "GTS")) {
    # FEMALES
    AF = 100 # the actual size is not important	
    AFin = AF * RRF
    AFx = AF * DR2
    AFexit = AF * RRF - AFx
    if ( Animal_short %in% c("CTL", "BFL", "CML")) {
      CFin = AF * ((1 - DR2) * FR + RRF) * (1 - DR1) / 2
      CMin = AF * ((1 - DR2) * FR + RRF) * (1 - DR1M) / 2
      RFin = ((AF * RRF) / FRRF) / (1 - DR2)^AFC
    }else{
      CFin = AF * ((1 - DR2) * FR * LITSIZE + RRF) / 2
      CMin = AF * ((1 - DR2) * FR * LITSIZE + RRF) / 2
      RFin = ((AF * RRF) / FRRF) / ((1 - DR1) * (1 - DR2)^(AFC - 1))
    }
    RFexit = ((AF * RRF) / FRRF) - AFin
    MFin = ifelse(CFin < RFin, 0, CFin - RFin) #<- CORRECTED TO HANDLE VECTORS
    ASF = AFC * (MFSKG - CKG) / (AFKG - CKG)
    if (Animal_short %in% c("CTL", "BFL", "CML")) {
      MFexit = MFin * (1 - DR2)^ASF
      
    } else{
      MFexit = MFin * (1 - DR1)^ASF
    }
    # MALES
    AM = AF * BCR
    AMx = AM * DR2
    if ( Animal_short %in% c("CTL", "BFL", "CML")) {
      AMexit = AM / AFC - AMx
      AMin = AM / AFC
      RMin = AMin / (1 - DR2)^AFC
    } else{
      AMexit = AM / (3 * AFC) - AMx
      AMin = AM / (3 * AFC)
      RMin = AMin / ((1 - DR1) * (1- DR2)^(AFC - 1))
    }
    MMin = ifelse(CMin < RMin, 0, CMin - RMin) #<- CORRECTED TO HANDLE VECTORS
    ASM = AFC * (MMSKG - CKG) / (AMKG - CKG)
    if (Animal_short %in% c("CTL", "BFL", "CML")) {
      MMexit = MMin * (1 - DR2)^ASM
    }else{
      MMexit = MMin * (1 - DR1)^ASM
    }
  }
  # outputs
  offtake_rate.FJ = offtake_rate.FS = (RFexit+MFexit)/(RFin+MFin)
  offtake_rate.FA = AFexit/AFin
  offtake_rate.MJ = offtake_rate.MS = (MMexit)/(RMin+MMin)
  offtake_rate.MA = AMexit/AMin
  ret <- list(offtake_rate.FJ, offtake_rate.FS, offtake_rate.FA, offtake_rate.MJ, offtake_rate.MS, offtake_rate.MA)
  names(ret) <- c("offtake_rate.FJ", "offtake_rate.FS", "offtake_rate.FA", "offtake_rate.MJ", "offtake_rate.MS", "offtake_rate.MA")
  return(ret)
}

# Function to calculate mortality rates from previous GLEAM parameters [calculate offtake_rates first]
get.mort_rate <- function(Animal_short, DR1, DR1M, DR2, DRR2A, DRR2B, DRF, offtake_rate.FS, offtake_rate.MS) {
  mort_rate.FJ = DR1
  if (Animal_short %in% c("CTL", "BFL", "SHP", "GTS")) {
    mort_rate.FS = mort_rate.MS = mort_rate.FA = mort_rate.MA = DR2
  }
  else if (Animal_short %in% c("PGS")) {
    mort_rate.FS = DRR2A * (1-offtake_rate.FS) + DRF * (offtake_rate.FS)
    mort_rate.MS = DRR2A * (1-offtake_rate.MS) + DRF * (offtake_rate.MS)
    mort_rate.FA = mort_rate.MA = DRR2B
  }
  if (Animal_short %in% c("CTL", "BFL")) {
    mort_rate.MJ = DR1M
  } 
  else if (Animal_short %in% c("SHP", "GTS", "PGS")) {
    mort_rate.MJ = DR1
  }
  ret <- list(mort_rate.FJ, mort_rate.FS, mort_rate.FA, mort_rate.MJ, mort_rate.MS, mort_rate.MA)
  names(ret) <- c("mort_rate.FJ", "mort_rate.FS", "mort_rate.FA", "mort_rate.MJ", "mort_rate.MS", "mort_rate.MA")
  return(ret)
}

# Function to calculate cohorts duration from previous GLEAM parameters [calculate offtake_rates first]
get.duration <- function(Animal_short, WA, AFC, AFCM, RRF, mort_rate.FA, mort_rate.MA) {
  duration.FJ = duration.MJ = WA*365
  if (Animal_short %in% c("PIGS")) {
    duration.FS = (AFC-WA)*365
    duration.MS = (AFCM-WA)*365
  } else {
    duration.FS = duration.MS = (AFC-WA)*365
  }
  duration.FA = 1 / (RRF - mort_rate.FA) * 365
  if (Animal_short %in% c("CTL", "BFL")) {
    duration.MA = 1/(1/AFC-mort_rate.MA)*365
  }
  else if (Animal_short %in% c("SHP", "GTS")) {
    duration.MA = 1/(1/(3*AFC)-mort_rate.MA)*365
  }
  else if (Animal_short %in% c("PGS")) {
    duration.MA = 1 / (RRF - mort_rate.MA) * 365
  }
  ret <- list(duration.FJ, duration.FS, duration.FA, duration.MJ, duration.MS, duration.MA)
  names(ret) <- c("duration.FJ", "duration.FS", "duration.FA", "duration.MJ", "duration.MS", "duration.MA")
  return(ret)
}



function_draught_proportion <- function(BCR) {
  ifelse(BCR > 0.10, (BCR - 0.10) / BCR, 0)
}

