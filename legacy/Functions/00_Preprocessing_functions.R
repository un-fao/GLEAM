## function to calculate AFC for pigs from previous GLEAM parameters
get.afc_pigs <- function (AFKG,AMKG,DWG2,WKG,WA) {
  DWGF = AFKG / ((AFKG + AMKG) / 2) * DWG2
  AFC = (AFKG - WKG) / (365 * DWGF) + WA
  DWGM = AMKG / ((AFKG + AMKG) / 2) * DWG2
  AFCM = (AMKG - WKG) / (365 * DWGM) + WA
  ret <- list(AFC, AFCM)
  names(ret) <- c("AFC", "AFCM")
  return(ret)
}

## function to calculate litsize (prolificacy) for chickens from previous GLEAM parameters
get.litsize_chk <- function (
    LPS_short,
    AF_FRAC,		  ##fraction		fraction of reproductive famales
    CKG,		      ##kg	        	  Liveweight of chicks at birth
    M2SKG,		    ##kg	        	Liveweight of fattening animals at slaughter
    DR1,		      ##fraction		Death rate of chicks during the first 16-17 weeks
    DRL2,		      ##fraction		Death rate for the laying period
    DR2,		      ##fraction		Death rate of adult animals
    DRF,		      ##fraction		Death rate of fattening animals
    DRM,		      ##fraction		Death rate of M molting animals. Note: default value 0.15
    FRRF,		      ##fraction		Rate of fertile replacement females. Note: default value 0.95
    FRMF,		      ##fraction		Rate of fertile surplus females. Note: default values = 0.95 for BCK; 1 for LYR
    BCR,		      ##fraction		Adult male to female ratio
    LAYTIME1,	    ##year	        	length of the first laying period
    MOLTTIME,	    ##year	        	length of the molting period. Note: default value of 6 weeks
    LAYTIME2,	    ##year	        	length of the second laying period. Note: default value of 30 weeks
    BIDLE,		    ##year			length of idle period between two production cycles in Broilers facilities. Note: default value 14 days
    AFC,		      ##year	        	Age at first reproduction
    AFS,		      ##year	        	Age at which adult surplus females are slaughtered (only for BCK)
    A2S,		      ##year	        	Age at slaughter of meat animals (only for BRL)
    CYCLE,		    ##cycles/hen/year	number of laying cycles per hen per year (only for BCK)
    CLTSIZE,		  ##eggs/cycle		number of eggs per laying cycle (only for BCK)
    HATCH,		    ##fraction		Hatchability, fraction of laid eggs that actually give a chick
    EGGSYEAR,	    ##eggs/hen/year		number of eggs per hen per year
    MALE,		      ##binary condition	Conition indicating if surplus male chicks are kept (1) or killed (0)
    MOLT		      ##binary condition	Conition indicating if laying hens are allowed to molt and kept for a second laying period (1) or not (0) 
)
{
  ## SETTING OF COMMON PARAMETERS
  ###########################################
  # LAYING TIME
  if  (LPS_short %in% c("BCK")) {
    LAYTIME1 = AFS - AFC
  } else {
    LAYTIME1 = LAYTIME1
  }
  LAYtime = LAYTIME1 + MOLTTIME + LAYTIME2
  # DEATH RATES
  if  (LPS_short %in% c("BCK")) {
    DR2 = DR2
    DRL2 = DR2
  } else {
    DR2 = DRL2 / LAYTIME1
  }
  if  (LPS_short %in% c("BCK", "LYR")) {
    DRF = DR1
  }
  # EGGS FOR REPRODUCTION
  if  (LPS_short %in% c("BCK")) {
    EGGSrepro = CYCLE * CLTSIZE
    if (EGGSrepro > EGGSYEAR) {
      EGGSrepro = EGGSYEAR
    }
  } else {
    EGGSrepro = EGGSYEAR
  }
  ## FEMALE SECTION
  ###########################################
  STOCK = 1000 # the actual size is not important
  AF = STOCK * AF_FRAC	
  RRF = 1/LAYtime
  AFin = AF * RRF
  AFx = AF * DR2	
  AFexit = AFin - AFx
  CFin = AF * (1 - DR2) * EGGSrepro * HATCH / 2
  RFin = (AFin / FRRF) / (1 - DR1)
  RFexit = (AFin / FRRF) - AFin
  RFx = RFin - (AFin + RFexit)
  RF = (RFin + AFin) / 2 * AFC
  MFin = CFin - RFin
  if  (LPS_short %in% c("BRL")) {
    MFexit = MFin * (1 - DRF)
    MFx = MFin - MFexit
    MF = (MFin + MFexit) / 2 * (A2S + BIDLE)
    MF1 = MF
    MF2 = 0
    MF3 = 0
    MF4 = 0
    MF4exit = MFexit
  } else {
    if (LPS_short %in% c("BCK")) {
      FRMF = FRRF
      MF2period = (AFS - AFC)
    } else {
      FRMF = 1
      MF2period = 1
    }
    ## producing hens - growing period
    MF1x = MFin * DR1
    MF1exit = (MFin - MF1x) * (1 - FRMF)
    MF2in =  (MFin - MF1x) * FRMF
    MF1 = ((MFin + MF2in) / 2) * AFC
    ## producing hens - Laying period 1
    MF2exit = MF2in * (1 - DRL2) ^ MF2period
    MF2x = MF2in - MF2exit
    MF2 = ((MF2in + MF2exit) / 2) * LAYTIME1
    ## producing hens - Molting period
    MF3exit = MF2exit * (1 - DRM) * MOLT
    MF3x = MF2exit - MF3exit * MOLT
    MF3 = ((MF2exit + MF3exit) / 2) * MOLTTIME * MOLT
    ## producing hens - Laying period 2
    if (MOLT == 0) {
      MF4exit = MF2exit
    } else {
      MF4exit = MF3exit * (1 - DRL2)
    }
    MF4x = MF3exit - MF4exit * MOLT
    MF4 = ((MF3exit + MF4exit) / 2) * LAYTIME2 * MOLT
  }
  ## MALE SECTION
  ###########################################
  AM = AF * BCR
  AMx = AM * DR2
  RRM = RRF
  AMin = AM * RRM
  AMexit = AMin - AMx
  CMin = CFin
  RMin = AMin / (1 - DR1)
  RMx = RMin - AMin
  RM = (RMin + AMin) / 2 * AFC
  if (LPS_short %in% c("BCK", "LYR")) {
    ASM = AFC
  } else {
    ASM = A2S
  }
  MMin = CMin - RMin
  MMexit = MMin * (1 - DRF) * MALE
  MMx = MMin - MMexit * MALE
  MM = (MMin + MMexit) / 2 * (ASM + BIDLE) * MALE
  ##ADJUSTMENT
  ###########################################
  TOT = AF + RF + AM + RM + MF1 + MF2 + MF3 + MF4 + MM
  RATIO = STOCK / TOT
  if (RATIO < 0.99 | RATIO > 1.01) {
    AF = AF * RATIO	
    if (LPS_short %in% c("BRL")) {
    } else {
      MF2 = MF2 * RATIO
      MF3 = MF3 * RATIO
      MF4 = MF4 * RATIO
    }
  }
  LITSIZE = (EGGSrepro*AF)/(AF+MF2+MF3+MF4)
  ret <- list(LITSIZE)
  names(ret) <- c("LITSIZE")
  return(ret)
}

## function to calculate offtake rate from previous GLEAM parameters
get.offtake_rate <- function (
    Animal_short,
    LPS_short,
    AFC,	  ##kg	        age at firs reproduction
    AFCM,	  ##kg	        age at firs reproduction
    AFS,		##year	        	Age at which adult surplus females are slaughtered (only for BCK)
    A2S,		##year	        	Age at slaughter of meat animals (only for BRL)
    CKG,	  ##kg	        Liveweight of newborn
    WKG,	  ##kg	        Liveweight of piglets at weaning age
    AFKG,	  ##kg	        Liveweight of adult female
    AMKG,	  ##kg	        Liveweight of adult male
    M2SKG,	##kg	        Liveweight of fattening animals at slaughter
    MFSKG,	##kg	        Liveweight of fattening animals at slaughter
    MMSKG,	##kg	        Liveweight of fattening animals at slaughter
    AF1KG,	##kg	        Liveweight of adult hens at the beginning of the laying period
    AF2KG,	##kg	        Liveweight of adult hens at the end of the laying period
    AM2KG,	##kg	        Liveweight of adult roosters a the end of the laying period
    DR1,	  ##fraction	  Death rate from birth to weaning age
    DR1M,	  ##fraction	  Death rate from birth to weaning age males
    DR2,	  ##fraction	  Death rate of adult ruminants
    DRL2,		##fraction		Death rate for the laying period
    DRR2A,	##fraction	  Death rate of replacement animals, from weaning age to first reproduction
    DRR2B,	##fraction	  Death rate of adult animals
    DRF,	  ##fraction	  Death rate of fattening animals, from weaning age to slaughter
    DRM,		##fraction		Death rate of M molting animals. Note: default value 0.15
    FR,	    ##part/year	  Number of parturitions per sow per year
    FRRF,	  ##fraction	  Rate of fertile replacement females. Note: default value 0.95
    FRMF,		##fraction		Rate of fertile surplus females. Note: default values = 0.95 for BCK; 1 for LYR
    RRF,	  ##fraction	  Replacement of adult females
    RRM,	  ##fraction	  Replacement of adult females
    WA,	    ##year	      Age at weaning
    BCR,	  ##fraction	  Adult male to female ratio
    DWG2,	  ##kg/day	    Daily weight gain of fattening animals
    LAYTIME1,	##year	    length of the first laying period
    MOLTTIME,	##year	    length of the molting period. Note: default value of 6 weeks
    LAYTIME2,	##year	    length of the second laying period. Note: default value of 30 weeks
    CYCLE,		##cycles/hen/year	number of laying cycles per hen per year (only for BCK)
    CLTSIZE,		##eggs/cycle		number of eggs per laying cycle (only for BCK)
    HATCH,		##fraction		Hatchability, fraction of laid eggs that actually give a chick
    EGGSYEAR,	##eggs/hen/year		number of eggs per hen per year
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
  else if (Animal_short %in% c("CHK")) {
    # LAYING TIME
    if  (LPS_short %in% c("BCK")) {
      LAYTIME1 = AFS - AFC
    } else {
      LAYTIME1 = LAYTIME1
    }
    LAYtime = LAYTIME1 + MOLTTIME + LAYTIME2
    # DEATH RATES
    if  (LPS_short %in% c("BCK")) {
      DR2 = DR2
      DRL2 = DR2
    } else {
      DR2 = DRL2 / LAYTIME1
    }
    if  (LPS_short %in% c("BCK", "LYR")) {
      DRF = DR1
    }
    # EGGS FOR REPRODUCTION
    if  (LPS_short %in% c("BCK")) {
      EGGSrepro = CYCLE * CLTSIZE
      if (EGGSrepro > EGGSYEAR) {
        EGGSrepro = EGGSYEAR
      }
    } else {
      EGGSrepro = EGGSYEAR
    }
    ## FEMALE SECTION
    ###########################################
    AF = 100 # the actual size is not important	
    RRF = 1/LAYtime
    AFin = AF * RRF
    AFx = AF * DR2	
    AFexit = AFin - AFx
    CFin = AF * (1 - DR2) * EGGSrepro * HATCH / 2
    RFin = (AFin / FRRF) / (1 - DR1)
    RFexit = (AFin / FRRF) - AFin
    MFin = CFin - RFin
    if  (LPS_short %in% c("BRL")) {
      MFexit = MFin * (1 - DRF)
    } else {
      MF1x = MFin * DR1
      MFexit = (MFin - MF1x) * (1 - FRMF)
    }
    ## MALE SECTION
    ###########################################
    AM = AF * BCR
    AMx = AM * DR2
    RRM = RRF
    AMin = AM * RRM
    AMexit = AMin - AMx
    CMin = CFin
    RMin = AMin / (1 - DR1)
    if (LPS_short %in% c("BCK", "LYR")) {
      ASM = AFC
    } else {
      ASM = A2S
    }
    MMin = CMin - RMin
    MMexit = MMin * (1 - DRF) # the offtake rate depends also from killed chicks in countries where they are not consumed
  }
    
  # outputs
  offtake_rate.FS = (RFexit+MFexit)/(RFin+MFin)
  offtake_rate.MS = (MMexit)/(RMin+MMin)
  if (Animal_short %in% c("CHK")) {
    offtake_rate.FJ = offtake_rate.MJ <- 0
  } else {
    offtake_rate.FJ = offtake_rate.FS
    offtake_rate.MJ = offtake_rate.MS
  }
  offtake_rate.FA = AFexit/AFin # to be replaced with line 348 in a separate debugging
  offtake_rate.MA = AMexit/AMin # to be replaced with line 348 in a separate debugging
  #offtake_rate.FA = offtake_rate.MA <- 0
  ret <- list(offtake_rate.FJ, offtake_rate.FS, offtake_rate.FA, offtake_rate.MJ, offtake_rate.MS, offtake_rate.MA)
  names(ret) <- c("offtake_rate.FJ", "offtake_rate.FS", "offtake_rate.FA", "offtake_rate.MJ", "offtake_rate.MS", "offtake_rate.MA")
  return(ret)
}

# Function to calculate mortality rates from previous GLEAM parameters [calculate offtake_rates first]
get.mort_rate <- function(Animal_short, LPS_short, DR1, DR1M, DR2, DRL2, DRM, DRR2A, DRR2B, DRF, LAYTIME1, LAYTIME2, MOLTTIME, AFS, AFC, offtake_rate.FS, offtake_rate.MS) {
  mort_rate.FJ = DR1
  if (Animal_short %in% c("CTL", "BFL", "SHP", "GTS")) {
    mort_rate.FS = mort_rate.MS = mort_rate.FA = mort_rate.MA = DR2
  }
  else if (Animal_short %in% c("PGS")) {
    mort_rate.FS = DRR2A * (1-offtake_rate.FS) + DRF * (offtake_rate.FS)
    mort_rate.MS = DRR2A * (1-offtake_rate.MS) + DRF * (offtake_rate.MS)
    mort_rate.FA = mort_rate.MA = DRR2B
  }
  else if (Animal_short %in% c("CHK")) {
    # LAYING TIME
    if  (LPS_short %in% c("BCK")) {
      LAYTIME1 = AFS - AFC
    } else {
      LAYTIME1 = LAYTIME1
    }
    LAYtime = LAYTIME1 + MOLTTIME + LAYTIME2
    #
    if (LPS_short %in% c("BRL")){
      mort_rate.FS = mort_rate.MS = DR1 * (1-offtake_rate.FS) + DRF * (offtake_rate.FS)
      mort_rate.FA = mort_rate.MA = DRL2
    }
    if (LPS_short %in% c("LYR")){
      mort_rate.FS = mort_rate.MS = DR1
      mort_rate.FA = mort_rate.MA = (DRL2*(LAYTIME1+LAYTIME2) + DRM * (MOLTTIME))/LAYtime
    }
    if (LPS_short %in% c("BCK")){
      mort_rate.FS = mort_rate.MS = DR1
      mort_rate.FA = mort_rate.MA = (DR2*(LAYTIME1+LAYTIME2) + DRM * (MOLTTIME))/LAYtime
    }
  }
  if (Animal_short %in% c("CTL", "BFL")) {
    mort_rate.MJ = DR1M
  } 
  else if (Animal_short %in% c("SHP", "GTS", "PGS", "CHK")) {
    mort_rate.MJ = DR1
  }
  ret <- list(mort_rate.FJ, mort_rate.FS, mort_rate.FA, mort_rate.MJ, mort_rate.MS, mort_rate.MA)
  names(ret) <- c("mort_rate.FJ", "mort_rate.FS", "mort_rate.FA", "mort_rate.MJ", "mort_rate.MS", "mort_rate.MA")
  return(ret)
}

# Function to calculate cohorts duration from previous GLEAM parameters [calculate offtake_rates first]
get.duration <- function(Animal_short, LPS_short, WA, AFC, AFCM, AFS, RRF, LAYTIME1, LAYTIME2, MOLTTIME, mort_rate.FA, mort_rate.MA) {
  if (Animal_short != "CHK") {
    duration.FJ = duration.MJ = WA*365
    duration.FA = 1 / (RRF - mort_rate.FA) * 365
  } else {
    # LAYING TIME
    if  (LPS_short %in% c("BCK")) {
      LAYTIME1 = AFS - AFC
    } else {
      LAYTIME1 = LAYTIME1
    }
    LAYtime = LAYTIME1 + MOLTTIME + LAYTIME2
    #
    duration.FJ = duration.MJ = 2
    duration.FA = duration.MA = LAYtime*365
  }
  if (Animal_short %in% c("PGS")) {
    duration.FS = (AFC-WA)*365
    duration.MS = (AFCM-WA)*365
  } else if (Animal_short %in% c("CTL", "BFL", "SHP", "GTS")) {
    duration.FS = duration.MS = (AFC-WA)*365
  } else {
    duration.FS = AFC*365 - duration.FJ
    duration.MS = AFC*365 - duration.MJ
  }
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

