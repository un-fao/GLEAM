# UPLOADING EMISSION FACTORS
load_manure_parameters <- function(input_path,
                                   ipcc_methods) {
  
  # Validate input
  ipcc_methods <- intersect(ipcc_methods, c("2006", "2019"))
  if (length(ipcc_methods) == 0) {
    stop("No valid IPCC method provided. Choose from '2006' or '2019'.")
  }
  
  # File and name mappings
  file_names <- c(
    "manure_ch4_b0",
    "manure_ch4_mcf",
    "manure_n2o_ef3",
    "manure_n2o_ef4",
    "manure_n2o_ef5",
    "manure_n2o_fracgas",
    "manure_n2o_fracleach"
  )
  table_names <- c("b0", "mcf", "ef3", "ef4", "ef5", "fracgas", "fracleach")
  
  split_tables <- list()
  
  for (i in seq_along(file_names)) {
    file_path <- file.path(input_path, paste0(file_names[i], ".csv"))
    dt <- fread(file_path)
    
    # Factor conversion
    if ("ADM0_CODE" %in% names(dt)) {
      dt[, ADM0_CODE := as.factor(ADM0_CODE)]
    }
    
    if ("HerdType_short" %in% names(dt)) {
      dt[, HerdType_short := fifelse(HerdType_short == "", NA_character_, HerdType_short)]
      dt[, HerdType_short := as.factor(HerdType_short)]
    }
    
    # Split and store only selected methods
    for (method in ipcc_methods) {
      dt_sub <- dt[ipcc_method == method]
      object_name <- paste0(table_names[i], "_", method)
      split_tables[[object_name]] <- dt_sub
    }
  }
  
  # Export to global environment
  list2env(split_tables, envir = .GlobalEnv)
}


## ----- function - direct emissions - methane manure----

# Function VS
# *compute vs value for the function module4_ch4_manure
# output: kg VS/head/day
Dfunction_vs = function (gleam_data, ipcc_method
){
  ipcc_method="2019"
  gleam_data <- copy(GLEAM_input_directemissions)

  # Case 1: CTL, BFL, CML, SHP, GTS
  gleam_data[Animal_short %in% c("CTL", "BFL", "CML", "SHP", "GTS"),
             vs := dmi * (1.04 - diet_dig) * 0.92]
  
  # Case 2: PGS
  gleam_data[Animal_short == "PGS" & ipcc_method == "2019",
             vs := dmi * (1.02 - diet_dig) * 0.94]
  
  gleam_data[Animal_short == "PGS" & ipcc_method == "2006",
             vs := dmi * (1.02 - diet_dig) * 0.8]
  
  # Case 3: CHK (to be revised)
  gleam_data[Animal_short == "CHK" & ipcc_method == "2006" & LPS_short == "BRL",
             vs := dmi * (1 - diet_me / diet_ge) * 0.95]
  
  gleam_data[Animal_short == "CHK" & ipcc_method == "2006" & LPS_short != "BRL",
             vs := dmi * (1 - diet_me / diet_ge) * 0.89]
  
  gleam_data[Animal_short == "CHK" & ipcc_method == "2019",
             vs := dmi * (1 - diet_me / diet_ge) * 0.70]
  
  return(gleam_data[, .(
    vs)])
}

# Manure MCF
# Compute weighed mcf by mms.
# output: MCF %

Dfunction_mcf_emissions <- function(gleam_data, mcf_dataset, ipcc_method) {
  gleam_data <- as.data.table(gleam_data)
  mcf_dataset <- as.data.table(mcf_dataset)
  
  mms_cols <- setdiff(intersect(names(gleam_data), names(mcf_dataset)), "ADM0_CODE")
  mcf_dataset_subset <- mcf_dataset[, c("ADM0_CODE", mms_cols), with = FALSE]

  # Join data by ADM0_CODE
  merged <- merge(
    gleam_data,
    mcf_dataset_subset,
    by = "ADM0_CODE",
    suffixes = c("_mms", "_mcf"),
    allow.cartesian = TRUE
  )
  
  results <- merged[, {
    mms_vals <- unlist(.SD[, paste0(mms_cols, "_mms"), with = FALSE])
    mcf_vals <- unlist(.SD[, paste0(mms_cols, "_mcf"), with = FALSE])
    
    # Align names
    names(mms_vals) <- sub("^mms", "", mms_cols)
    names(mcf_vals) <- sub("^mms", "", mms_cols)
    
    # Calculate terms
    pasture <- if (!is.na(mms_vals["pasture"]) && !is.na(mcf_vals["pasture"])) {
      mms_vals["pasture"] * mcf_vals["pasture"] / 100
    } else 0
    
    burned <- if (!is.na(mms_vals["burned"]) && !is.na(mcf_vals["burned"])) {
      mms_vals["burned"] * mcf_vals["burned"] / 100
    } else 0
    
    other_names <- setdiff(intersect(names(mms_vals), names(mcf_vals)), c("pasture", "burned"))
    other <- sum(mms_vals[other_names] * mcf_vals[other_names] / 100, na.rm = TRUE)
    
    list(
      mcf_pasture = pasture,
      mcf_burned = burned,
      mcf_other = other
    )
  }, by = seq_len(nrow(merged))] 
  
}



# Manure CH4 2019
# output: kg CH4/head/day

Dfunction_ch4_manure <- function(gleam_data, b0_dataset, ipcc_method) {
  
  gleam_data <- as.data.table(gleam_data)
  b0_dt    <- as.data.table(b0_dataset)
  
  
  setnames(b0_dt, "mms_all", "mms_all_b0")
  setnames(b0_dt, "mmspasture", "mmspasture_b0")
  
  # Merge b0 values (wide format: one column per MMS)
  b0_with_herd <- b0_dt[
    HerdType_short %in% c("DRY", "LAY", "BRL") &
      Animal_short %in% c("CTL", "CHK")
  ]
  
  gleam_data_with_herd<- gleam_data[
    HerdType_short %in% c("DRY", "LAY", "BRL") &
      Animal_short %in% c("CTL", "CHK")
  ]
  
  
  b0_without_herd <- b0_dt[
    !(Animal_short %in% c("CTL", "CHK") & HerdType_short %in% c("DRY", "LAY", "BRL"))
  ]
  
  gleam_data_without_herd <- gleam_data[
    !(Animal_short %in% c("CTL", "CHK") & HerdType_short %in% c("DRY", "LAY", "BRL"))
  ]
  
  gleam_data_with_herd <- merge(
    gleam_data_with_herd,
    b0_with_herd,
    by = c("ADM0_CODE", "Animal_short", "HerdType_short"),
    all.x = T
  )
  
  gleam_data_without_herd <- merge(
    gleam_data_without_herd[
      !(Animal_short %in% c("CTL", "CHK") & HerdType_short %in% c("DRY", "LAY", "BRL"))
    ],
    b0_without_herd[,.(ADM0_CODE, Animal_short, mmspasture_b0, mms_all_b0)],
    by = c("ADM0_CODE", "Animal_short"),
    all.x = T
  )
  
  gleam_merged <- rbindlist(list(gleam_data_with_herd, gleam_data_without_herd), fill = TRUE)
  
  # Dynamic column suffix
  suffix <- if (ipcc_method == "2019") "2019" else "2006"
  
  mcf_burned_col   <- paste0("mcf_burned", suffix)
  mcf_pasture_col  <- paste0("mcf_pasture", suffix)
  mcf_other_col    <- paste0("mcf_other", suffix)
  vs_col           <- paste0("vs", suffix)
  
  # Calculate CH4 emissions using ..get_col for safe dynamic referencing
  gleam_merged[, ch4_manure_burned := 
                 get(vs_col) * 0.67 * get(mcf_burned_col) * mms_all_b0]
  
  gleam_merged[, ch4_manure_pasture := 
                 get(vs_col) * 0.67 * get(mcf_pasture_col) * mmspasture_b0]
  
  gleam_merged[, ch4_manure_other := 
                 get(vs_col) * 0.67 * get(mcf_other_col) * mms_all_b0]
  
  gleam_merged[, ch4_manure_all_noburn := ch4_manure_pasture + ch4_manure_other]
  
  # Return only the calculated results
  return(gleam_merged[, .(
    ch4_manure_pasture,
    ch4_manure_burned,
    ch4_manure_other,
    ch4_manure_all_noburn
  )])
}
  


## ----- function - emissions - N2O manure----

### direct N2O manure -----

# EF3 
# Computes emission factors weighted by MMS
# Output: EF3 in kg N2O-N/kg N excreted

Dfunction_ef3_manure <- function(gleam_data, ef3_dataset, ipcc_method) {
  
  # Use the provided arguments
  emissions_copy <- copy(gleam_data)
  ef3_copy <- copy(ef3_dataset)
  
  # Get common MMS columns (excluding ADM0_CODE and Animal_short)
  mms_cols <- setdiff(intersect(names(emissions_copy), names(ef3_copy)), c("ADM0_CODE", "Animal_short"))
  
  # Merge the two datasets
  merged_dt <- merge(
    emissions_copy,
    ef3_copy,
    by = c("ADM0_CODE", "Animal_short"),
    all.x = TRUE,
    suffixes = c("_mms", "_ef3"),
    allow.cartesian = TRUE
  )
  
  # Compute emissions row-by-row
  results <- merged_dt[, {
    mms_vals <- unlist(.SD[, paste0(mms_cols, "_mms"), with = FALSE])
    ef3_vals <- unlist(.SD[, paste0(mms_cols, "_ef3"), with = FALSE])
    
    # Strip "mms" prefix from names
    names(mms_vals) <- sub("^mms", "", mms_cols)
    names(ef3_vals) <- sub("^mms", "", mms_cols)
    
    # Compute pasture, burned, and other terms
    pasture_term <- if (!is.na(mms_vals["pasture"]) && !is.na(ef3_vals["pasture"])) {
      mms_vals["pasture"] * ef3_vals["pasture"]
    } else 0
    
    burned_term <- if (!is.na(mms_vals["burned"]) && !is.na(ef3_vals["burned"])) {
      mms_vals["burned"] * ef3_vals["burned"]
    } else 0
    
    other_names <- setdiff(intersect(names(mms_vals), names(ef3_vals)), c("pasture", "burned"))
    other_terms <- sum(mms_vals[other_names] * ef3_vals[other_names], na.rm = TRUE)
    
    list(
      ef3_pasture = pasture_term,
      ef3_burned  = burned_term,
      ef3_other   = other_terms
    )
  }, by = seq_len(nrow(merged_dt))]
}





# Direct N2O from manure 
# Computes direct N2O from manure
# Output: N2O/head/day

Dfunction_direct_n2o_manure <- function(
    gleam_data, ipcc_method
) {
  
  gleam_data <- copy(gleam_data)
  
  # Dynamic column suffix
  suffix <- if (ipcc_method == "2019") "2019" else "2006"
  
  ef3_pasture_col  <- paste0("ef3_pasture", suffix)
  ef3_burned_col   <- paste0("ef3_burned", suffix)
  ef3_other_col    <- paste0("ef3_other", suffix)

  # Calculate CH4 emissions using ..get_col for safe dynamic referencing
    gleam_data[, direct_n2o_manure_pasture := 
               n_excretion * get(ef3_pasture_col) * 44/28]
  
  gleam_data[, direct_n2o_manure_burned := 
                 n_excretion * get(ef3_burned_col) * 44/28]
  
  gleam_data[, direct_n2o_manure_other := 
                 n_excretion * get(ef3_other_col) * 44/28]
  
  gleam_data[, direct_n2o_manure_all_noburn := direct_n2o_manure_pasture + direct_n2o_manure_other]
  
  
  # Return all components
  return(gleam_data[, .(
    direct_n2o_manure_pasture,
    direct_n2o_manure_burned,
    direct_n2o_manure_other,
    direct_n2o_manure_all_noburn
  )])
}



### indirect N2O manure -----

# Fracgas 
# Computes emission factors weighted by MMS, and species
# Output: Fracgas, in fraction


Dfunction_fracgas_manure <- function(gleam_data, fracgas_dt, ipcc_method) {
  
  emissions_copy <- copy(GLEAM_input_directemissions)
  fracgas_copy <- copy(fracgas_2006)
  
  mms_cols <- setdiff(intersect(names(emissions_copy), names(fracgas_copy)), 
                      c("ADM0_CODE", "Animal_short", "HerdType_short"))
  
  # Split emissions by presence of HerdType_short
  fracgas_copy_with_herdtype <- fracgas_copy[!is.na(HerdType_short)]
  emissions_copy_with_herdtype <- emissions_copy[Animal_short == "CTL" & HerdType_short == "DRY"]
  
  fracgas_copy_without_herdtype <- fracgas_copy[is.na(HerdType_short)]
  emissions_copy_without_herdtype <- emissions_copy[!(Animal_short == "CTL" & HerdType_short == "DRY")]
  
  
  # Merge when HerdType_short is relevant
  merged_with_herdtype <- merge(
    emissions_copy_with_herdtype,
    fracgas_copy_with_herdtype,
    by = c("ADM0_CODE", "Animal_short", "HerdType_short"),
    suffixes = c("_mms", "_fracgas"),
    all.x = TRUE
  )
  
  # Merge when HerdType_short is irrelevant
  merged_without_herdtype <- merge(
    emissions_copy_without_herdtype,
    fracgas_copy_without_herdtype[, !"HerdType_short", with = FALSE],  # drop this column from fracgas_copy
    by = c("ADM0_CODE", "Animal_short"),
    suffixes = c("_mms", "_fracgas"),
    all.x = TRUE
  )
  
  # Combine the two datasets again
  merged_dt <- rbindlist(list(merged_with_herdtype, merged_without_herdtype), use.names = TRUE, fill = TRUE)
  
  
  # Identify valid mms/fracgas column pairs
  # Compute emissions row-by-row
  results <- merged_dt[, {
    mms_vals <- unlist(.SD[, paste0(mms_cols, "_mms"), with = FALSE])
    fracgas_vals <- unlist(.SD[, paste0(mms_cols, "_fracgas"), with = FALSE])
    
    # Strip "mms" prefix from names
    names(mms_vals) <- sub("^mms", "", mms_cols)
    names(fracgas_vals) <- sub("^mms", "", mms_cols)
  
    
    # Compute pasture, burned, and other terms
    pasture_term <- if (!is.na(mms_vals["pasture"]) && !is.na(fracgas_vals["pasture"])) {
      mms_vals["pasture"] * fracgas_vals["pasture"]
    } else 0
    
    burned_term <- if (!is.na(mms_vals["burned"]) && !is.na(fracgas_vals["burned"])) {
      mms_vals["burned"] * fracgas_vals["burned"]
    } else 0
    
    other_names <- setdiff(intersect(names(mms_vals), names(fracgas_vals)), c("pasture", "burned"))
    other_terms <- sum(mms_vals[other_names] * fracgas_vals[other_names], na.rm = TRUE)
    
    list(
      fracgas_pasture = pasture_term, 
      fracgas_burned = burned_term, 
      fracgas_other = other_terms)
  }, by = seq_len(nrow(merged_dt))]
}

  
 
  

# N lost due to volatilization 
# Computes amount of manure nitrogen lost due to volatilization
# Output: kg N/head/day

Dfunction_n_volatilization_manure <- function(gleam_data, ipcc_method) {
  
  gleam_data <- as.data.table(gleam_data)
  
  # Dynamic column suffix
  suffix <- if (ipcc_method == "2019") "2019" else "2006"
  
  fracgas_pasture_col   <- paste0("fracgas_pasture", suffix)
  fracgas_burned_col  <- paste0("fracgas_burned", suffix)
  fracgas_other_col    <- paste0("fracgas_other", suffix)

  
  # Dfunction N2O emissions for each pathway
  gleam_data[, n_vol_manure_pasture := 
               n_excretion * get(fracgas_pasture_col)]
  
  gleam_data[, n_vol_manure_burned := 
               n_excretion * get(fracgas_burned_col)]
  
  gleam_data[, n_vol_manure_other := 
               n_excretion * get(fracgas_other_col)]
  
  
  gleam_data[, n_vol_manure_all_noburn := n_vol_manure_pasture + n_vol_manure_other]
  
  
  # Return all components
  return(gleam_data[, .(
    n_vol_manure_pasture,
    n_vol_manure_burned,
    n_vol_manure_other,
    n_vol_manure_all_noburn
  )])
}


# Indirect N2O emissions due to volatilization 
# Computes amount of N2O emitted due to volatilization
# Output: kg N2O/head/day


Dfunction_n2o_volatilization_manure <- function(gleam_data, ef4_dt, ipcc_method) {
  
  gleam_data <- as.data.table(gleam_data)
  ef4_dt <- as.data.table(ef4_dt)
  
  
  # Join data by ADM0_CODE
  merged <- merge(
    gleam_data,
    ef4_dt,
    by = "ADM0_CODE",
    allow.cartesian = TRUE
  )
  
  
  # Ensure valid suffix
  suffix <- match.arg(ipcc_method, choices = c("2006", "2019"))
  suffix_str <- paste0("_", suffix)
  
  
  # Input column names
  n_vol_burned   <- paste0("n_vol_manure_burned", suffix)
  n_vol_pasture  <- paste0("n_vol_manure_pasture", suffix)
  n_vol_other    <- paste0("n_vol_manure_other", suffix)
  

  
  # Dfunction N2O emissions
  merged[, n2o_pasture := get(n_vol_pasture) * ef4 * 44 / 28]
  merged[, n2o_burned  := get(n_vol_burned)  * ef4 * 44 / 28]
  merged[, n2o_other   := get(n_vol_other)   * ef4 * 44 / 28]
  merged[, n2o_noburn  := n2o_pasture   + n2o_other]
  
  
  # Return Dfunctiond columns only
  return(merged[, .(
    n2o_pasture,
    n2o_burned,
    n2o_other,
    n2o_noburn
  )])
}



# Fracleach
# Computes emission factors weighted by MMS
# Output: Fracleach, in fraction

Dfunction_fracleach_manure <- function(gleam_data, fracleach_dt, ipcc_method) {
  
  emissions_copy <- copy(gleam_data)
  fracleach_copy <- copy(fracleach_dt)
  
  mms_cols <- setdiff(intersect(names(emissions_copy), names(fracleach_copy)), 
                      c("ADM0_CODE", "Animal_short", "HerdType_short"))
  
  # Split emissions by presence of HerdType_short
  fracgas_copy_with_herdtype <- fracleach_copy[!is.na(HerdType_short)]
  emissions_copy_with_herdtype <- emissions_copy[Animal_short == "CTL" & HerdType_short == "DRY"]
  
  fracgas_copy_without_herdtype <- fracleach_copy[is.na(HerdType_short)]
  emissions_copy_without_herdtype <- emissions_copy[!(Animal_short == "CTL" & HerdType_short == "DRY")]
  
  
  # Merge when HerdType_short is relevant
  merged_with_herdtype <- merge(
    emissions_copy_with_herdtype,
    fracgas_copy_with_herdtype,
    by = c("ADM0_CODE", "Animal_short", "HerdType_short"),
    suffixes = c("_mms", "_fracleach"),
    all.x = TRUE
  )
  
  # Merge when HerdType_short is irrelevant
  merged_without_herdtype <- merge(
    emissions_copy_without_herdtype,
    fracgas_copy_without_herdtype[, !"HerdType_short", with = FALSE],  # drop this column from fracgas_copy
    by = c("ADM0_CODE", "Animal_short"),
    suffixes = c("_mms", "_fracleach"),
    all.x = TRUE
  )
  
  # Combine the two datasets again
  merged_dt <- rbindlist(list(merged_with_herdtype, merged_without_herdtype), use.names = TRUE, fill = TRUE)
  
  
  # Identify valid mms/fracgas column pairs
  # Compute emissions row-by-row
  results <- merged_dt[, {
    mms_vals <- unlist(.SD[, paste0(mms_cols, "_mms"), with = FALSE])
    fracgas_vals <- unlist(.SD[, paste0(mms_cols, "_fracleach"), with = FALSE])
    
    # Strip "mms" prefix from names
    names(mms_vals) <- sub("^mms", "", mms_cols)
    names(fracgas_vals) <- sub("^mms", "", mms_cols)
    
    
    # Compute pasture, burned, and other terms
    pasture_term <- if (!is.na(mms_vals["pasture"]) && !is.na(fracgas_vals["pasture"])) {
      mms_vals["pasture"] * fracgas_vals["pasture"]
    } else 0
    
    burned_term <- if (!is.na(mms_vals["burned"]) && !is.na(fracgas_vals["burned"])) {
      mms_vals["burned"] * fracgas_vals["burned"]
    } else 0
    
    other_names <- setdiff(intersect(names(mms_vals), names(fracgas_vals)), c("pasture", "burned"))
    other_terms <- sum(mms_vals[other_names] * fracgas_vals[other_names], na.rm = TRUE)
    
    list(
      fracleach_pasture = pasture_term, 
      fracleach_burned = burned_term, 
      fracleach_other = other_terms)
  }, by = seq_len(nrow(merged_dt))]
}



# N lost due to leaching 
# Computes amount of manure nitrogen lost due to leaching
# Output: kg N/head/day

Dfunction_n_leaching_manure <- function(gleam_data, ipcc_method) {
    
    gleam_data <- as.data.table(gleam_data)
    
    # Dynamic column suffix
    suffix <- if (ipcc_method == "2019") "2019" else "2006"
    
    fracleach_pasture_col   <- paste0("fracleach_pasture", suffix)
    fracleach_burned_col  <- paste0("fracleach_burned", suffix)
    fracleach_other_col    <- paste0("fracleach_other", suffix)
    
    
    # Dfunction N2O emissions for each pathway
    gleam_data[, n_leach_manure_pasture := 
                 n_excretion * get(fracleach_pasture_col)]
    
    gleam_data[, n_leach_manure_burned := 
                 n_excretion * get(fracleach_burned_col)]
    
    gleam_data[, n_leach_manure_other := 
                 n_excretion * get(fracleach_other_col)]
    
    
    gleam_data[, n_leach_manure_all_noburn := n_leach_manure_pasture + n_leach_manure_other]
    
    
    # Return all components
    return(gleam_data[, .(
      n_leach_manure_pasture,
      n_leach_manure_burned,
      n_leach_manure_other,
      n_leach_manure_all_noburn
    )])
  }
  
  
  
 
# Indirect N2O emissions due to leaching 
# Computes amount of N2O emitted due to leaching
# Output: kg N2O/head/day

Dfunction_n2o_leaching_manure <- function(gleam_data, ef5_dt, ipcc_method) {

  gleam_data <- as.data.table(GLEAM_input_directemissions)
  ef5_dt <- as.data.table(ef5_2006)
  
  # Join data by ADM0_CODE
  merged <- merge(
    gleam_data,
    ef5_dt,
    by = "ADM0_CODE",
    allow.cartesian = TRUE
  )
  # Ensure valid suffix
  suffix <- match.arg(ipcc_method, choices = c("2006", "2019"))
  suffix_str <- paste0("_", suffix)
  
  
  # Input column names
  n_leach_pasture  <- paste0("n_leach_manure_pasture", suffix)
  n_leach_burned   <- paste0("n_leach_manure_burned", suffix)
  n_leach_other    <- paste0("n_leach_manure_other", suffix)
  
  
  # Dfunction N2O emissions
  merged[, n2o_pasture  := get(n_leach_pasture)  * ef5 * 44 / 28]
  merged[, n2o_burned   := get(n_leach_burned)   * ef5 * 44 / 28]
  merged[, n2o_other    := get(n_leach_other)    * ef5 * 44 / 28]
  merged[, n2o_noburn   := n2o_pasture      +  n2o_other]
  
  # Return relevant results
  return(merged[, .(
    n2o_pasture,
    n2o_burned,
    n2o_other,
    n2o_noburn
  )])
}


#TOTALS-----
Dfunction_n2o_manure_total <- function(gleam_data, ipcc_method) {
  gleam_data <- as.data.table(gleam_data)
  ipcc_method <- match.arg(ipcc_method, choices = c("2006", "2019"))
  
  # Helper to construct names dynamically
  colname <- function(base) paste0(base, ipcc_method)
  
  # Input column names (with suffix)
  direct_cols <- c("direct_n2o_manure_burned", "direct_n2o_manure_pasture", "direct_n2o_manure_other")
  vol_cols    <- c("n2o_vol_manure_burned",    "n2o_vol_manure_pasture",    "n2o_vol_manure_other")
  leach_cols  <- c("n2o_leach_manure_burned",  "n2o_leach_manure_pasture",  "n2o_leach_manure_other")
  
  # Output column names (generic, no year)
  indirect_cols <- c("indirect_n2o_manure_burned", "indirect_n2o_manure_pasture", "indirect_n2o_manure_other")
  total_cols    <- c("total_n2o_manure_burned",    "total_n2o_manure_pasture",    "total_n2o_manure_other")
  
  # Compute values into temporary variables
  results <- gleam_data[, {
    indirect <- mapply(function(vol, leach) get(colname(vol)) + get(colname(leach)), vol_cols, leach_cols)
    total <- mapply(function(dir, ind) get(colname(dir)) + ind, direct_cols, indirect)
    
    out <- as.list(c(indirect, total))
    names(out) <- c(indirect_cols, total_cols)
    out
  }, by = seq_len(nrow(gleam_data))][, seq_len := NULL]  # remove temp index column
  
  return(results)
}

