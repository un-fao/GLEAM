## ----- function - direct emissions - methane manure----

# Function VS
# *compute vs value for the function module4_ch4_manure
# output: kg VS/head/day
Dfunction_vs2019 = function (Animal_short, # CTL, BFL, CML, SHP, GTS, PGS, CHK
                             cohort, # SHP, GTS 
                             dmi, # CTL, BFL, CML, SHP, GTS, PGS, CHK
                             diet_dig, # CTL, BFL, CML, SHP, GTS, PGS
                             diet_me, # CHK
                             diet_ge, # CHK
                             afc # SHP, GTS 
){
  

  if (Animal_short %in% c("CTL", "BFL", "CML", "SHP", "GTS")){
    ret = dmi*(1.04-diet_dig)*0.92

  } else if (Animal_short == "PGS"){
    ret = dmi*(1.02-diet_dig)*0.94
  # } else if (Animal_short == "CHK"){
  #   if (lps == "BRL"){
  #     ret = dmi*(1-diet_me/diet_ge)*0.95 
  #   } else {
  #     ret = dmi*(1-diet_me/diet_ge)*0.89
  #   }
  } 
  return (ret)
}

# Function VS
# *compute vs value for the function module4_ch4_manure
# output: kg VS/head/day
Dfunction_vs2006 = function (Animal_short, # CTL, BFL, SHP, GTS, PGS, CHK
                             dmi, # CTL, BFL, SHP, GTS, PGS, CHK
                             diet_dig, # CTL, BFL, SHP, GTS, PGS
                             diet_me, # CHK
                             diet_ge # CHK
){
  
  if (Animal_short %in% c("CTL", "BFL", "SHP", "GTS", "CML")){
    ret = dmi*(1.04-diet_dig)*0.92
  } else if (Animal_short == "PGS"){
    ret = dmi*(1.02-diet_dig)*0.8
  } else if (Animal_short == "CHK"){ #Change 2019
    ret = dmi*(1-diet_me/diet_ge)*0.70
  } 
  return (ret)
}

# Manure MCF
# Compute weighed mcf by mms.
# output: MCF %

Dfunction_mcf_emissions <- function(
    ADM0_CODE_input,
    mms_values,
    mcf_dataset
) {
  # Dynamically detect all MCF and corresponding MMS columns
  mcf_cols <- grep("^mcf", names(mcf_dataset), value = TRUE)
  mms_cols <- gsub("^mcf", "mms", mcf_cols)
  
  # Filter the MCF data for the given country
  mcf_row <- mcf_dataset[ADM0_CODE == ADM0_CODE_input]
  
  if (nrow(mcf_row) == 0) {
    warning(paste("No MCF values found for country:", ADM0_CODE_input))
    return(list(
      mcf_pasture2019 = NA_real_,
      mcf_burned2019 = NA_real_,
      mcf_other2019 = NA_real_
    ))
  }
  
  # Extract relevant MCF and MMS values
  mcf_vals <- unlist(mcf_row[, ..mcf_cols])
  mms_vals <- unlist(mms_values[, ..mms_cols])
  
  names(mcf_vals) <- mcf_cols
  names(mms_vals) <- mcf_cols  # align names for safe indexing
  
  # Calculate each component
  pasture <- mms_vals["mcfpasture"] * mcf_vals["mcfpasture"] / 100
  burned  <- mms_vals["mcfburned"]  * mcf_vals["mcfburned"]  / 100
  
  # Remove these from other calculations
  mcf_vals <- mcf_vals[!names(mcf_vals) %in% c("mcfpasture", "mcfburned")]
  mms_vals <- mms_vals[!names(mms_vals) %in% c("mcfpasture", "mcfburned")]
  
  other <- sum(mms_vals * mcf_vals / 100, na.rm = TRUE)
  
  return(list(
    mcf_pasture2019 = pasture,
    mcf_burned2019 = burned,
    mcf_other2019 = other
  ))
}



# Manure CH4 2019
# output: kg CH4/head/day

Dfunction_ch4_manure <- function(
    ADM0_CODE_input,
    Animal_short_input,
    HerdType_short_input,
    vs,
    mcf_pasture,
    mcf_burned,
    mcf_other,
    b0_dataset,
    ipcc_method
) {
  # Should we match on herd type?
  use_herdtype <- HerdType_short_input %in% c("DRY", "LAY", "BRL") &&
    Animal_short_input %in% c("CTL", "CHK")
  
  # --- General b0 lookup (optionally use herd type) ---
  if (use_herdtype) {
    b0_rows_main <- b0_dataset[
      ADM0_CODE == ADM0_CODE_input &
        Animal_short == Animal_short_input &
        HerdType_short == HerdType_short_input
    ]
  } else {
    b0_rows_main <- b0_dataset[
      ADM0_CODE == ADM0_CODE_input &
        Animal_short == Animal_short_input
    ]
  }
  
  b0_main <- b0_rows_main[is.na(mms) | mms == "", b0]
  b0 <- if (length(b0_main) >= 1) b0_main[1] else {
    warning(paste("Missing general b0 for:", ADM0_CODE_input, Animal_short_input, HerdType_short_input))
    NA_real_
  }
  
  # --- b0_pasture lookup (do NOT use herd type) ---
  b0_rows_pasture <- b0_dataset[
    ADM0_CODE == ADM0_CODE_input &
      Animal_short == Animal_short_input &
      mms == "mmspasture"
  ]
  
  b0_pasture <- if (ipcc_method == "2019") {
    if (nrow(b0_rows_pasture) >= 1) b0_rows_pasture$b0[1] else {
      warning(paste("Missing b0_pasture for:", ADM0_CODE_input, Animal_short_input))
      0
    }
  } else {
    b0  # fallback for 2006
  }
  
  # Emission calculations
  ch4_burned  <- vs * 0.67 * mcf_burned  * b0
  ch4_pasture <- vs * 0.67 * mcf_pasture * b0_pasture
  ch4_other   <- vs * 0.67 * mcf_other   * b0
  
  return(list(
    b0 = b0,
    b0_pasture = b0_pasture,
    ch4_manure_burned     = ch4_burned,
    ch4_manure_pasture    = ch4_pasture,
    ch4_manure_other      = ch4_other,
    ch4_manure_all_noburn = ch4_pasture + ch4_other
  ))
}


## ----- function - direct emissions - nitrogen retention & excretion -----
#Functions to compute nitrogen retention & excretion requirements


# Nitrogen intake
# output = kg N/head/day


Dfunction_n_intake	=	function(dmi, # CTL, BFL, CML, SHP, GTS, PGS, CHK
                              diet_nitrogen, # CTL, BFL, CML, SHP, GTS, PGS, CHK
                              n_retention # CTL, BFL, CML, SHP, GTS, PGS, CHK
                              
) {
  # N intake in g/day
  ret <- dmi * diet_nitrogen
  return(ret)
}


# Nitrogen retention
# output = kg N/head/day


Dfunction_n_retention <- function(Animal_short,
                                  cohort,
                                  duration,
                                  n_intake,
                                  dwg,
                                  negrow,
                                  milk_yield,
                                  milk_protein,
                                  ckg,
                                  litsize,
                                  fr,
                                  wkg,
                                  afc,
                                  fibre_prod
) {
  ret <- NA
  
  if (Animal_short %in% c("CTL", "BFL", "SHP", "GTS", "CML")) {
    
    # Fixed coefficients
    nitrogen_retention_milk <- milk_protein / 6.38
    nitrogen_retention_fiber <- 0.0134
    
    # Tissue N retention coefficient by species
    nitrogen_retention_tissue <- switch(Animal_short,
                                        "CTL" = 0.0326,
                                        "BFL" = 0.0326,
                                        "SHP" = 0.026,
                                        "GTS" = 0.026,
                                        "CML" = 0.026,
                                        NA)
    
    # Components
    milk_component <- if (cohort == "AF" && !is.na(milk_yield) && milk_yield > 0) {
      milk_yield * nitrogen_retention_milk
    } else {
      0
    }
    growth_component <- if (dwg == 0 || is.na(dwg)) 0 else (dwg * nitrogen_retention_tissue)
    fibre_component <- if (fibre_prod == 0 || is.na(fibre_prod)) 0 else (fibre_prod/365 * nitrogen_retention_fiber)
    
    # Total N retention
    ret <- milk_component + growth_component + fibre_component
  }
  
  
  
  else if (Animal_short == "PGS") {
    if (cohort == "AF") {
      ret <- ((0.025 * litsize * fr * (wkg - ckg)/0.98) + (0.025 * litsize * fr * ckg)) / 365
    } else if (cohort == "RF") {
      ret <- 0.025 * dwg + 
        (1 / afc) * (((0.025 * litsize * fr * (wkg - ckg)/0.98) + 
                        (0.025 * litsize * fr * ckg)) / 365)
    } else if (!is.na(dwg)) {
      ret <- 0.025 * dwg
    }
    
    # } else if (Animal_short == "CHK") {
    #   if (cohort %in% c("AF", "MF2", "MF4")) {
    #     eggs <- (eggs_year / 365) * egg_weight
    #     ret <- 0.028 * dwg + 0.0185 * 1e-3 * eggs
    #   } else if (cohort == "MF3") {
    #     ret <- 0
    #   } else {
    #     ret <- 0.028 * dwg
    #   }
  }
  
  return(ret)
}



# Nitrogen excretion
# output = kg N/head/day
Dfunction_n_excretion	=	function(Animal_short, # CTL, BFL, CML, SHP, GTS, PGS, CHK
                                 # lps, # CHK
                                 n_intake, # CTL, BFL, CML, SHP, GTS, PGS, CHK
                                 n_retention # CTL, BFL, CML, SHP, GTS, PGS, CHK
                                 # a2s, # CHK
                                 # bidle # CHK
){
  
  # equation 4.6
  if (Animal_short  %in% c("CTL", "BFL", "CML", "GTS", "SHP", "PGS")){
    ret = n_intake - n_retention
  } 
  # } else if  (animal %in% c("CHK")){
  #   if(lps=="BRL" & cohort %in% c("MF1", "MM", "MF2", "MF3", "MF4")){ #note: fraction of time in the housing system -	 age slaughter/period empty(15 DAYS) house MF1 MM MF2 MF3 MF4
  #     m2house = a2s/(a2s+bidle) 
  #     ret = ((dmi * diet_n_cont)/1000 - n_retention) * m2house
  #   } else {
  #     ret = (dmi * diet_n_cont)/1000 - n_retention
  #   }
  return(ret)
}



## ----- function - emissions - N2O manure----

### direct N2O manure -----

# EF3 
# Computes emission factors weighted by MMS
# Output: EF3 in kg N2O-N/kg N excreted

Dfunction_ef3_manure <- function(emissions_dt, ef3_dt) {
  
  emissions_copy <- copy(emissions_dt)
  ef3_copy <- copy(ef3_dt)
  
  merged_dt <- merge(emissions_copy, ef3_copy, by = c("ADM0_CODE", "Animal_short"), all.x = TRUE)
  
  # Dynamically identify column names
  ef3_colnames <- grep("^ef3", names(ef3_copy), value = TRUE)
  mms_colnames <- sub("^ef3", "mms", ef3_colnames)
  
  results <- merged_dt[, {
    mms_vals <- unlist(.SD[, mms_colnames, with = FALSE])
    ef3_vals <- unlist(.SD[, ef3_colnames, with = FALSE])
    
    names(mms_vals) <- sub("^mms", "", names(mms_vals))
    names(ef3_vals) <- sub("^ef3", "", names(ef3_vals))
    
    pasture_term <- if (!is.na(mms_vals["pasture"]) && !is.na(ef3_vals["pasture"])) mms_vals["pasture"] * ef3_vals["pasture"] else 0
    burned_term  <- if (!is.na(mms_vals["burned"])  && !is.na(ef3_vals["burned"]))  mms_vals["burned"]  * ef3_vals["burned"]  else 0
    
    other_names <- setdiff(intersect(names(mms_vals), names(ef3_vals)), c("pasture", "burned"))
    other_terms <- sum(mms_vals[other_names] * ef3_vals[other_names], na.rm = TRUE)
    
    list(
      ef3_pasture = pasture_term,
      ef3_burned  = burned_term,
      ef3_other   = other_terms
    )
  }, by = seq_len(nrow(merged_dt))][, -"seq_len"]
  
  return(results)
}


# Direct N2O from manure 
# Computes direct N2O from manure
# Output: N2O/head/day

Dfunction_direct_n2o_manure <- function(
    ef3_pasture, ef3_burned, ef3_other, n_excretion
) {
  # Dfunction N2O emissions for each pathway
  direct_n2o_manure_burned <- n_excretion * ef3_burned * 44/28
  direct_n2o_manure_pasture <- n_excretion * ef3_pasture * 44/28
  direct_n2o_manure_other <- n_excretion * ef3_other * 44/28
  
  # Return all components
  return(list(
    direct_n2o_manure_burned = direct_n2o_manure_burned,
    direct_n2o_manure_pasture = direct_n2o_manure_pasture,
    direct_n2o_manure_other = direct_n2o_manure_other,
    direct_n2o_manure_all_noburn = direct_n2o_manure_pasture + direct_n2o_manure_other
  ))
}



### indirect N2O manure -----

# Fracgas 
# Computes emission factors weighted by MMS, and species
# Output: Fracgas, in fraction


Dfunction_fracgas_manure <- function(emissions_dt, fracgas_dt) {
  
  emissions_copy <- copy(emissions_dt)
  fracgas_copy <- copy(fracgas_dt)
  
  # Split emissions by presence of HerdType_short
  fracgas_copy_with_herd <- fracgas_copy[!is.na(HerdType_short)]
  emissions_copy_with_herd <- emissions_copy[Animal_short == "CTL" & HerdType_short == "DRY"]
  
  fracgas_copy_without_herd <- fracgas_copy[is.na(HerdType_short)]
  emissions_copy_without_herd <- emissions_copy[!(Animal_short == "CTL" & HerdType_short == "DRY")]
  
  
  # Merge when HerdType_short is relevant
  merged_with_herd <- merge(
    emissions_copy_with_herd,
    fracgas_copy_with_herd,
    by = c("ADM0_CODE", "Animal_short", "HerdType_short"),
    all.x = TRUE
  )
  
  # Merge when HerdType_short is irrelevant
  merged_without_herd <- merge(
    emissions_copy_without_herd,
    fracgas_copy_without_herd[, !"HerdType_short", with = FALSE],  # drop this column from fracgas_copy
    by = c("ADM0_CODE", "Animal_short"),
    all.x = TRUE
  )
  
  # Combine the two datasets again
  merged_dt <- rbindlist(list(merged_with_herd, merged_without_herd), use.names = TRUE, fill = TRUE)
  
  
  # Identify valid mms/fracgas column pairs
  fracgas_cols <- grep("^fracgas", names(fracgas_copy), value = TRUE)
  mms_cols <- sub("^fracgas", "mms", fracgas_cols)
  
  valid <- fracgas_cols %in% names(merged_dt) & mms_cols %in% names(merged_dt)
  fracgas_cols <- fracgas_cols[valid]
  mms_cols <- mms_cols[valid]
  
  # Main computation
  results <- merged_dt[, {
    mms <- unlist(.SD[, mms_cols, with = FALSE])
    fg  <- unlist(.SD[, fracgas_cols, with = FALSE])
    
    names(mms) <- sub("^mms", "", names(mms))
    names(fg)  <- sub("^fracgas", "", names(fg))
    
    common <- intersect(names(mms), names(fg))
    contribs <- mms[common] * fg[common]
    
    pasture <- if (!is.na(contribs["pasture"])) contribs["pasture"] else 0
    burned  <- if (!is.na(contribs["burned"]))  contribs["burned"]  else 0
    other   <- sum(contribs[!names(contribs) %in% c("pasture", "burned")], na.rm = TRUE)
    
    list(fracgas_pasture = pasture, fracgas_burned = burned, fracgas_other = other)
  }, by = seq_len(nrow(merged_dt))][, -"seq_len"]
  
  
  
  return(results)
}


# N lost due to volatilization 
# Computes amount of manure nitrogen lost due to volatilization
# Output: kg N/head/day

Dfunction_n_volatilization_manure <- function(
    fracgas_pasture, fracgas_burned, fracgas_other, n_excretion
) {
  # Dfunction N2O emissions for each pathway
  n_vol_manure_burned <- n_excretion * fracgas_burned 
  n_vol_manure_pasture <- n_excretion * fracgas_pasture
  n_vol_manure_other <- n_excretion * fracgas_other
  
  # Return all components
  return(list(
    n_vol_manure_burned = n_vol_manure_burned,
    n_vol_manure_pasture = n_vol_manure_pasture,
    n_vol_manure_other = n_vol_manure_other,
    n_vol_manure_all_noburn = n_vol_manure_pasture + n_vol_manure_other
  ))
}

# Indirect N2O emissions due to volatilization 
# Computes amount of N2O emitted due to volatilization
# Output: kg N2O/head/day


Dfunction_n2o_volatilization_manure <- function(emissions_dt, ef4_dt, ipcc_method) {
  
  # Ensure valid suffix
  suffix <- match.arg(ipcc_method, choices = c("2006", "2019"))
  suffix_str <- paste0("_", suffix)
  
  
  # Create copies to avoid modifying original data
  emissions_copy <- copy(emissions_dt)
  emissions_copy[, .id := .I]
  ef4_copy <- copy(ef4_dt)
  emissions_copy[, ADM0_CODE := as.character(ADM0_CODE)]
  ef4_copy[, ADM0_CODE := as.character(ADM0_CODE)]
  ef4_copy[, ef4 := as.numeric(ef4)]
  
  # Temporarily merge to access ef4
  temp_merged <- merge(emissions_copy, ef4_copy, by = "ADM0_CODE", all.x = TRUE)
  
  
  setorder(temp_merged, .id)
  
  # Input column names
  n_vol_burned   <- paste0("n_vol_manure_burned", suffix)
  n_vol_pasture  <- paste0("n_vol_manure_pasture", suffix)
  n_vol_other    <- paste0("n_vol_manure_other", suffix)
  
  # Output column names
  n2o_burned   <- paste0("n2o_vol_manure_burned", suffix)
  n2o_pasture  <- paste0("n2o_vol_manure_pasture", suffix)
  n2o_other    <- paste0("n2o_vol_manure_other", suffix)
  n2o_noburn   <- paste0("n2o_vol_manure_all_noburn", suffix)
  
  # Dfunction N2O emissions
  temp_merged[, (n2o_burned)   := get(n_vol_burned)   * ef4 * 44 / 28]
  temp_merged[, (n2o_pasture)  := get(n_vol_pasture)  * ef4 * 44 / 28]
  temp_merged[, (n2o_other)    := get(n_vol_other)    * ef4 * 44 / 28]
  temp_merged[, (n2o_noburn)   := get(n2o_pasture)    + get(n2o_other)]
  
  # Return Dfunctiond columns only
  return(temp_merged[, .SD, .SDcols = c(n2o_burned, n2o_pasture, n2o_other, n2o_noburn)])
}








# Fracleach
# Computes emission factors weighted by MMS
# Output: Fracleach, in fraction

Dfunction_fracleach_manure <- function(emissions_dt, fracleach_dt) {
  
  emissions_copy <- copy(emissions_dt)
  fracleach_copy <- copy(fracleach_dt)
  
  # Split emissions by presence of HerdType_short
  fracleach_copy_with_herd <- fracleach_copy[!is.na(HerdType_short)]
  emissions_copy_with_herd <- emissions_copy[Animal_short == "CTL" & HerdType_short == "DRY"]
  
  fracleach_copy_without_herd <- fracleach_copy[is.na(HerdType_short)]
  emissions_copy_without_herd <- emissions_copy[!(Animal_short == "CTL" & HerdType_short == "DRY")]
  
  
  # Merge when HerdType_short is relevant
  merged_with_herd <- merge(
    emissions_copy_with_herd,
    fracleach_copy_with_herd,
    by = c("ADM0_CODE", "Animal_short", "HerdType_short"),
    all.x = TRUE
  )
  
  # Merge when HerdType_short is irrelevant
  merged_without_herd <- merge(
    emissions_copy_without_herd,
    fracleach_copy_without_herd[, !"HerdType_short", with = FALSE],  # drop this column from fracleach_copy
    by = c("ADM0_CODE", "Animal_short"),
    all.x = TRUE
  )
  
  # Combine the two datasets again
  merged_dt <- rbindlist(list(merged_with_herd, merged_without_herd), use.names = TRUE, fill = TRUE)
  
  fracleach_cols <- grep("^fracleach", names(fracleach_copy), value = TRUE)
  mms_cols <- sub("^fracleach", "mms", fracleach_cols)
  
  
  # Main computation
  results <- merged_dt[, {
    mms <- unlist(.SD[, mms_cols, with = FALSE])
    fg  <- unlist(.SD[, fracleach_cols, with = FALSE])
    
    names(mms) <- sub("^mms", "", names(mms))
    names(fg)  <- sub("^fracleach", "", names(fg))
    
    common <- intersect(names(mms), names(fg))
    contribs <- mms[common] * fg[common]
    
    pasture <- if (!is.na(contribs["pasture"])) contribs["pasture"] else 0
    burned  <- if (!is.na(contribs["burned"]))  contribs["burned"]  else 0
    other   <- sum(contribs[!names(contribs) %in% c("pasture", "burned")], na.rm = TRUE)
    
    list(fracleach_pasture = pasture, fracleach_burned = burned, fracleach_other = other)
  }, by = seq_len(nrow(merged_dt))][, -"seq_len"]
  
  
  
  return(results)
}

# N lost due to leaching 
# Computes amount of manure nitrogen lost due to leaching
# Output: kg N/head/day

Dfunction_n_leaching_manure <- function(
    fracleach_pasture, fracleach_burned, fracleach_other, n_excretion
) {
  # Dfunction N2O emissions for each pathway
  n_leach_manure_burned <- n_excretion * fracleach_burned 
  n_leach_manure_pasture <- n_excretion * fracleach_pasture
  n_leach_manure_other <- n_excretion * fracleach_other
  
  # Return all components
  return(list(
    n_leach_manure_burned = n_leach_manure_burned,
    n_leach_manure_pasture = n_leach_manure_pasture,
    n_leach_manure_other = n_leach_manure_other,
    n_leach_manure_all_noburn = n_leach_manure_pasture + n_leach_manure_other
  ))
}

# Indirect N2O emissions due to leaching 
# Computes amount of N2O emitted due to leaching
# Output: kg N2O/head/day

Dfunction_n2o_leaching_manure <- function(emissions_dt, ef5_dt, ipcc_method) {
  
  # Validate and create suffix
  suffix <- match.arg(ipcc_method, choices = c("2006", "2019"))
  suffix_str <- paste0(suffix)  # no underscore since you include it in names below
  
  # Create copies to avoid modifying original data
  emissions_copy <- copy(emissions_dt)
  emissions_copy[, .id := .I]
  ef5_copy <- copy(ef5_dt)
  
  emissions_copy[, ADM0_CODE := as.character(ADM0_CODE)]
  ef5_copy[, ADM0_CODE := as.character(ADM0_CODE)]
  ef5_copy[, ef5 := as.numeric(ef5)]
  
  
  # Temporarily merge to access ef5
  temp_merged <- merge(emissions_copy, ef5_copy, by = "ADM0_CODE", all.x = TRUE)
  setorder(temp_merged, .id)
  
  # Dynamic input column names
  n_leach_burned   <- paste0("n_leach_manure_burned", suffix)
  n_leach_pasture  <- paste0("n_leach_manure_pasture", suffix)
  n_leach_other    <- paste0("n_leach_manure_other", suffix)
  
  # Dynamic output column names
  n2o_burned   <- paste0("n2o_leach_manure_burned", suffix)
  n2o_pasture  <- paste0("n2o_leach_manure_pasture", suffix)
  n2o_other    <- paste0("n2o_leach_manure_other", suffix)
  n2o_noburn   <- paste0("n2o_leach_manure_all_noburn", suffix)
  
  # Dfunction N2O emissions
  temp_merged[, (n2o_burned)   := get(n_leach_burned)   * ef5 * 44 / 28]
  temp_merged[, (n2o_pasture)  := get(n_leach_pasture)  * ef5 * 44 / 28]
  temp_merged[, (n2o_other)    := get(n_leach_other)    * ef5 * 44 / 28]
  temp_merged[, (n2o_noburn)   := get(n2o_pasture)      + get(n2o_other)]
  
  # Return relevant results
  return(temp_merged[, .SD, .SDcols = c(n2o_burned, n2o_pasture, n2o_other, n2o_noburn)])
}






