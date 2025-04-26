function_milking_fraction <- function(GLEAM_input_feed_preproc, afmilk_raw) {
  
  # Step 1: Clean and prep afmilk data
  afmilk[, Animal_short := fifelse(grepl("camel", Item, ignore.case = TRUE), "CML",
                                   fifelse(grepl("cattle", Item, ignore.case = TRUE), "CTL",
                                           fifelse(grepl("buffalo", Item, ignore.case = TRUE), "BFL",
                                                   fifelse(grepl("goats", Item, ignore.case = TRUE), "GTS",
                                                           fifelse(grepl("sheep", Item, ignore.case = TRUE), "SHP", NA_character_)))))]
  
  afmilk[, HerdType_short := "DRY"]  # default
  afmilk[Animal_short == "CML", HerdType_short := "ALL"]  # special case for camels  
  setnames(afmilk, old = "Area Code (M49)", new = "M49_code")
  setnames(afmilk, old = "Value", new = "milking_females_faostat_size")
  afmilk_short <- afmilk[, .(Animal_short, HerdType_short, M49_code, milking_females_faostat_size)]
  afmilk_short[, M49_code := as.factor(M49_code)]
  
 
  
  # Step 2: Prepare GLEAM input
  GLEAM_input_feed_preproc[, M49_code := as.factor(M49_code)]
  
  input_dairy <- GLEAM_input_feed_preproc[
    HerdType_short %in% c("DRY", "ALL") & 
      Animal_short %in% c("CTL", "BFL", "CML", "GTS", "SHP") & 
      cohort == "FA", 
    .(ADM0_CODE, M49_code, COUNTRY, Animal_short, LPS_short, HerdType_short, size_total, FA_size = size)
  ]

  
  # Step 3: Calculate proportion of each LPS
  group_total <- input_dairy[, .(total_population = sum(size_total)),
                           by = .(ADM0_CODE, M49_code, COUNTRY, Animal_short, HerdType_short)]
  
  proportion_bylps <- merge(input_dairy, group_total,
                  by = c("ADM0_CODE", "M49_code", "COUNTRY", "Animal_short", "HerdType_short"))
  
  proportion_bylps[, proportion_byLPS_size := fifelse(size_total == 0, 0, size_total / total_population)]
  
  # Step 4: Merge milk stock and calculate fraction
  af_bylps <- merge(
    proportion_bylps, 
    afmilk_short, 
    by = c("M49_code", "Animal_short", "HerdType_short"), 
    all.x = TRUE
  )
  
  af_bylps[, milking_females_faostat_size := fifelse(is.na(milking_females_faostat_size), 0, milking_females_faostat_size)]
  af_bylps[, milking_females_size := fifelse(
    milking_females_faostat_size == 0,
    0,
    milking_females_faostat_size * proportion_byLPS_size
  )]
  
  # Step 5: Merge result into original dairy input to calculate milking_fraction
  milking_fraction.dt <- merge(
    input_dairy,
    af_bylps[, .(ADM0_CODE, M49_code, COUNTRY, Animal_short, LPS_short, HerdType_short, milking_females_size)],
    by = c("ADM0_CODE", "M49_code", "COUNTRY", "Animal_short", "LPS_short", "HerdType_short"),
    all.x = TRUE
  )
  
  milking_fraction.dt[, milking_fraction := fifelse(milking_females_size == 0, 0, milking_females_size / FA_size)]
  
  output <- merge(
    GLEAM_input_feed_preproc,
    milking_fraction.dt[, .(ADM0_CODE, M49_code, COUNTRY, Animal_short, LPS_short, HerdType_short, milking_females_size, FA_size, milking_fraction)],
    by = c("ADM0_CODE", "M49_code", "COUNTRY", "Animal_short", "LPS_short", "HerdType_short"),
    all.x = TRUE
  )
  
  # Step 6: Replace NA with 0
  output[is.na(milking_fraction), milking_fraction := 0]
  output[is.na(milking_females_size), milking_females_size := 0]
  output[is.na(FA_size), FA_size := 0]
  return(output)
}





# Function to calculate cohort-specific weights at different lifestage
get.stepLW <- function (Animal_short, cohort, AFKG, AMKG, CKG, MFSKG, MMSKG, WKG, AFC, WA) {
  if (cohort %in% c("FJ")) {
    initialLW= CKG
    if (Animal_short %in% c("PGS", "CML")) {
      potfinalLW = slaughterLW = WKG
    }
    else if (Animal_short %in% c("CTL", "BFL", "SHP", "GTS" )) {
      potfinalLW = slaughterLW = ((AFKG-CKG)/AFC)*WA+CKG
    }
  }
  else if (cohort %in% c("MJ")) {
    initialLW= CKG
    if (Animal_short %in% c("PGS","CML")) {
      potfinalLW = slaughterLW = WKG
    }
    else if (Animal_short %in% c("CTL", "BFL", "SHP", "GTS")) {
      potfinalLW = slaughterLW = ((AMKG-CKG)/AFC)*WA+CKG
    }
  }
  else if (cohort == "FS") {
    if (Animal_short %in% c("PGS", "CML")) {
      initialLW = WKG
    }
    else if (Animal_short %in% c("CTL", "BFL", "SHP", "GTS")) {
      initialLW = ((AFKG-CKG)/AFC)*WA+CKG
    }
    potfinalLW = AFKG
    slaughterLW = MFSKG
  }
  else if (cohort == "MS") {
    if (Animal_short %in% c("PGS", "CML")) {
      initialLW = WKG
    }
    else if (Animal_short %in% c("CTL", "BFL", "SHP", "GTS")) {
      initialLW = ((AMKG-CKG)/AFC)*WA+CKG
    }
    potfinalLW = AMKG
    slaughterLW = MMSKG
  }
  else if (cohort == "FA") {
    initialLW = potfinalLW = slaughterLW = AFKG
  } 
  else if (cohort == "MA") {
    initialLW = potfinalLW = slaughterLW = AMKG
  }
  
  ret <- list(initialLW, potfinalLW, slaughterLW)
  names(ret) <- c("initialLW", "potfinalLW", "slaughterLW")
  return(ret)
}

# Function to calculate cohort-specific average and final weights
get.otherLW <- function(initialLW, potfinalLW, slaughterLW, offtake_rate) {
  averageLW = (initialLW+(potfinalLW*(1-offtake_rate)+slaughterLW*(offtake_rate)))/2
  finalLW = potfinalLW*(1-offtake_rate)+slaughterLW*(offtake_rate)
  ret = list(averageLW, finalLW)
  names(ret) <- c("averageLW", "finalLW")
  return(ret)
}

get.dwg <- function(potfinalLW, initialLW, duration) {
  dwg = (potfinalLW-initialLW)/duration
  return(dwg)
}



