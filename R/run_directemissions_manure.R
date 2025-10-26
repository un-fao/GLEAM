#' Run Direct Emissions Manure Module (Internal)
#'
#' Computes direct and indirect emissions from manure management systems following
#' IPCC methodology. This function handles parameter loading, data merging, and calls
#' the core calculation functions to produce emission estimates.
#'
#' This function is intended for internal use and performs no validation of inputs.
#' Input data must be preloaded and properly formatted.
#'
#' @param gleam_data A data.table containing cohort-level data with required columns:
#'   Animal_short, LPS_short, ADM0_CODE, HerdType_short, dmi, diet_dig, diet_me,
#'   diet_ge, mms_pasture, mms_burned, mms_other, n_excretion
#' @param ipcc_method Character. IPCC method to use: "2006" or "2019". Defaults to "2019".
#'
#' @return A data.table with added emission columns following the exact legacy order
#'
#' @examples
#' \dontrun{
#' # Load example data and compute manure emissions
#' input_path <- system.file("extdata/GLEAM_input_directemissions_manure2.csv", package = "gleam")
#' gleam_data <- data.table::fread(input_path)
#' result <- run_directemissions_manure(gleam_data, ipcc_method = "2019")
#' }
#' @keywords internal
#'
#' @importFrom data.table := .SD .I merge rbindlist setcolorder
run_directemissions_manure <- function(gleam_data, ipcc_method = "2019") {

  # Convert ADM0_CODE to character to avoid merge issues
  gleam_data[, ADM0_CODE := as.character(ADM0_CODE)]

  # Load parameter tables
  read_param <- function(param_name) {
    file_path <- paste0("inst/extdata/Manure_parameters/", param_name, "_", ipcc_method, ".csv")
    if (!file.exists(file_path)) {
      stop("Parameter file not found: ", file_path)
    }
    param_table <- data.table::fread(file_path)
    param_table[, ADM0_CODE := as.character(ADM0_CODE)]
    # Remove ipcc_method column to avoid merge conflicts
    if ("ipcc_method" %in% names(param_table)) {
      param_table[, ipcc_method := NULL]
    }
    return(param_table)
  }

  b0_table <- read_param("b0")
  mcf_table <- read_param("mcf")
  ef3_table <- read_param("ef3")
  ef4_table <- read_param("ef4")
  ef5_table <- read_param("ef5")
  fracgas_table <- read_param("fracgas")
  fracleach_table <- read_param("fracleach")

  # CH4-----

  ## CH4 from manure-----

  ### Volatile Solids (VS)------

  #### VS - IPCC method------
  gleam_data[, c(
    paste0("vs", ipcc_method)
  ) :=
    calc_volatile_solids(
      animal_short = Animal_short,
      lps_short = LPS_short,
      dmi = dmi,
      diet_dig = diet_dig,
      diet_me = diet_me,
      diet_ge = diet_ge,
      ipcc_method = ipcc_method
    )]

  #### MCF - IPCC method -----
  # Merge MCF data into temporary variable (like legacy)
  mms_cols <- setdiff(intersect(names(gleam_data), names(mcf_table)), "ADM0_CODE")
  mcf_subset <- mcf_table[, c("ADM0_CODE", mms_cols), with = FALSE]
  mcf_merged <- merge(gleam_data, mcf_subset, by = "ADM0_CODE", suffixes = c("", "_mcf"), allow.cartesian = TRUE)

  # Calculate MCF values
  mcf_result <- mcf_merged[, {
    available_mms_cols <- intersect(mms_cols, names(.SD))
    available_mcf_cols <- intersect(paste0(mms_cols, "_mcf"), names(.SD))

    mms_vals <- unlist(.SD[, available_mms_cols, with = FALSE])
    mcf_vals <- unlist(.SD[, available_mcf_cols, with = FALSE])

    names(mms_vals) <- sub("^mms", "", available_mms_cols)
    names(mcf_vals) <- sub("^mms", "", sub("_mcf$", "", available_mcf_cols))

    pasture <- if (!is.na(mms_vals["pasture"]) && !is.na(mcf_vals["pasture"])) {
      mms_vals["pasture"] * mcf_vals["pasture"] / 100
    } else 0

    burned <- if (!is.na(mms_vals["burned"]) && !is.na(mcf_vals["burned"])) {
      mms_vals["burned"] * mcf_vals["burned"] / 100
    } else 0

    other_names <- setdiff(intersect(names(mms_vals), names(mcf_vals)), c("pasture", "burned"))
    other <- sum(mms_vals[other_names] * mcf_vals[other_names] / 100, na.rm = TRUE)

    list(mcf_pasture = pasture, mcf_burned = burned, mcf_other = other)
  }, by = seq_len(nrow(mcf_merged))]

  gleam_data[, c(paste0("mcf_pasture", ipcc_method), paste0("mcf_burned", ipcc_method), paste0("mcf_other", ipcc_method)) := list(
    mcf_result$mcf_pasture, mcf_result$mcf_burned, mcf_result$mcf_other
  )]

  #### CH4 manure - IPCC method -----
  # Merge B0 data into temporary variable (handle HerdType_short for CTL/CHK) - rename columns like legacy
  b0_table[, mms_all_b0 := mms_all]
  b0_table[, mmspasture_b0 := mmspasture]

  b0_with_herd <- b0_table[
    HerdType_short %in% c("DRY", "LAY", "BRL") & Animal_short %in% c("CTL", "CHK")
  ]
  b0_without_herd <- b0_table[
    !(Animal_short %in% c("CTL", "CHK") & HerdType_short %in% c("DRY", "LAY", "BRL"))
  ]

  gleam_with_herd <- gleam_data[
    HerdType_short %in% c("DRY", "LAY", "BRL") & Animal_short %in% c("CTL", "CHK")
  ]
  gleam_without_herd <- gleam_data[
    !(Animal_short %in% c("CTL", "CHK") & HerdType_short %in% c("DRY", "LAY", "BRL"))
  ]

  gleam_with_herd <- merge(gleam_with_herd, b0_with_herd, by = c("ADM0_CODE", "Animal_short", "HerdType_short"), all.x = TRUE)
  gleam_without_herd <- merge(gleam_without_herd, b0_without_herd[, .(ADM0_CODE, Animal_short, mms_all_b0, mmspasture_b0)], by = c("ADM0_CODE", "Animal_short"), all.x = TRUE)

  ch4_merged <- rbindlist(list(gleam_with_herd, gleam_without_herd), fill = TRUE)

  # Calculate CH4 emissions
  vs_col <- paste0("vs", ipcc_method)
  mcf_pasture_col <- paste0("mcf_pasture", ipcc_method)
  mcf_burned_col <- paste0("mcf_burned", ipcc_method)
  mcf_other_col <- paste0("mcf_other", ipcc_method)

  ch4_result <- ch4_merged[, calc_ch4_emissions(
    vs = get(vs_col),
    mcf_pasture = get(mcf_pasture_col),
    mcf_burned = get(mcf_burned_col),
    mcf_other = get(mcf_other_col),
    b0_mms_all = mms_all_b0,
    b0_mms_pasture = mmspasture_b0
  ), by = seq_len(nrow(ch4_merged))]

  gleam_data[, c(
    paste0("ch4_manure_pasture", ipcc_method),
    paste0("ch4_manure_burned", ipcc_method),
    paste0("ch4_manure_other", ipcc_method),
    paste0("ch4_manure_all_noburn", ipcc_method)
  ) := list(
    ch4_result$ch4_manure_pasture, ch4_result$ch4_manure_burned,
    ch4_result$ch4_manure_other, ch4_result$ch4_manure_all_noburn
  )]

  # N2O------
  ## N2O from manure - direct ------
  ### EF3 - IPCC method------
  # Merge EF3 data into temporary variable
  ef3_subset <- ef3_table[, c("ADM0_CODE", "Animal_short", mms_cols), with = FALSE]
  ef3_merged <- merge(gleam_data, ef3_subset, by = c("ADM0_CODE", "Animal_short"), suffixes = c("", "_ef3"), allow.cartesian = TRUE)

  # Calculate EF3 values
  ef3_result <- ef3_merged[, {
    available_mms_cols <- intersect(mms_cols, names(.SD))
    available_ef3_cols <- intersect(paste0(mms_cols, "_ef3"), names(.SD))

    mms_vals <- unlist(.SD[, available_mms_cols, with = FALSE])
    ef3_vals <- unlist(.SD[, available_ef3_cols, with = FALSE])

    names(mms_vals) <- sub("^mms", "", available_mms_cols)
    names(ef3_vals) <- sub("^mms", "", sub("_ef3$", "", available_ef3_cols))

    pasture_term <- if (!is.na(mms_vals["pasture"]) && !is.na(ef3_vals["pasture"])) {
      mms_vals["pasture"] * ef3_vals["pasture"]
    } else 0

    burned_term <- if (!is.na(mms_vals["burned"]) && !is.na(ef3_vals["burned"])) {
      mms_vals["burned"] * ef3_vals["burned"]
    } else 0

    other_names <- setdiff(intersect(names(mms_vals), names(ef3_vals)), c("pasture", "burned"))
    other_terms <- sum(mms_vals[other_names] * ef3_vals[other_names], na.rm = TRUE)

    list(ef3_pasture = pasture_term, ef3_burned = burned_term, ef3_other = other_terms)
  }, by = seq_len(nrow(ef3_merged))]

  gleam_data[, c(paste0("ef3_pasture", ipcc_method), paste0("ef3_burned", ipcc_method), paste0("ef3_other", ipcc_method)) := list(
    ef3_result$ef3_pasture, ef3_result$ef3_burned, ef3_result$ef3_other
  )]

  ### N2O manure direct - IPCC method------
  ef3_pasture_col <- paste0("ef3_pasture", ipcc_method)
  ef3_burned_col <- paste0("ef3_burned", ipcc_method)
  ef3_other_col <- paste0("ef3_other", ipcc_method)

  direct_n2o_result <- gleam_data[, calc_direct_n2o_emissions(
    n_excretion = n_excretion,
    ef3_pasture = get(ef3_pasture_col),
    ef3_burned = get(ef3_burned_col),
    ef3_other = get(ef3_other_col)
  ), by = seq_len(nrow(gleam_data))]

  gleam_data[, c(
    paste0("direct_n2o_manure_pasture", ipcc_method),
    paste0("direct_n2o_manure_burned", ipcc_method),
    paste0("direct_n2o_manure_other", ipcc_method),
    paste0("direct_n2o_manure_all_noburn", ipcc_method)
  ) := list(
    direct_n2o_result$direct_n2o_manure_pasture, direct_n2o_result$direct_n2o_manure_burned,
    direct_n2o_result$direct_n2o_manure_other, direct_n2o_result$direct_n2o_manure_all_noburn
  )]

  ## N2O from manure - indirect ------

  ### Fracgas - IPCC method------
  # Merge FracGAS data into temporary variable (handle HerdType_short for CTL/CHK)
  fracgas_with_herd <- fracgas_table[
    HerdType_short %in% c("DRY", "LAY", "BRL") & Animal_short %in% c("CTL", "CHK")
  ]
  fracgas_without_herd <- fracgas_table[
    !(Animal_short %in% c("CTL", "CHK") & HerdType_short %in% c("DRY", "LAY", "BRL"))
  ]

  gleam_fracgas_with_herd <- gleam_data[
    HerdType_short %in% c("DRY", "LAY", "BRL") & Animal_short %in% c("CTL", "CHK")
  ]
  gleam_fracgas_without_herd <- gleam_data[
    !(Animal_short %in% c("CTL", "CHK") & HerdType_short %in% c("DRY", "LAY", "BRL"))
  ]

  gleam_fracgas_with_herd <- merge(gleam_fracgas_with_herd, fracgas_with_herd, by = c("ADM0_CODE", "Animal_short", "HerdType_short"), suffixes = c("", "_fracgas"), all.x = TRUE)
  gleam_fracgas_without_herd <- merge(gleam_fracgas_without_herd, fracgas_without_herd[, .(ADM0_CODE, Animal_short, mmspasture, mmsdaily, mmssolid, mmssolidcov, mmssolidbulk, mmssolidadd, mmsdrylot, mmspit1, mmspit3, mmspit4, mmspit6, mmspit12, mmsliquid1, mmsliquid3, mmsliquid4, mmsliquid6, mmsliquid12, mmsliquidnatcov1, mmsliquidnatcov3, mmsliquidnatcov4, mmsliquidnatcov6, mmsliquidnatcov12, mmsliquidsolcov1, mmsliquidsolcov3, mmsliquidsolcov4, mmsliquidsolcov6, mmsliquidsolcov12, mmslagoon, mmsbiogaslowleak1, mmsbiogaslowleak2, mmsbiogaslowleak3, mmsbiogashighleak1, mmsbiogashighleak2, mmsbiogashighleak3, mmsburned, mmsdeepnomix2, mmsdeepnomix1, mmsdeepmix2, mmsdeepmix1, mmscompostves, mmscompoststat, mmscompostint, mmscompostpass, mmslitter, mmsnolitter, mmsareobic, mmsaerproc)], by = c("ADM0_CODE", "Animal_short"), suffixes = c("", "_fracgas"), all.x = TRUE)

  fracgas_merged <- rbindlist(list(gleam_fracgas_with_herd, gleam_fracgas_without_herd), use.names = TRUE, fill = TRUE)

  # Calculate FracGAS values
  fracgas_result <- fracgas_merged[, {
    available_mms_cols <- intersect(mms_cols, names(.SD))
    available_fracgas_cols <- intersect(paste0(mms_cols, "_fracgas"), names(.SD))

    mms_vals <- unlist(.SD[, available_mms_cols, with = FALSE])
    fracgas_vals <- unlist(.SD[, available_fracgas_cols, with = FALSE])

    names(mms_vals) <- sub("^mms", "", available_mms_cols)
    names(fracgas_vals) <- sub("^mms", "", sub("_fracgas$", "", available_fracgas_cols))

    pasture_term <- if (!is.na(mms_vals["pasture"]) && !is.na(fracgas_vals["pasture"])) {
      mms_vals["pasture"] * fracgas_vals["pasture"]
    } else 0

    burned_term <- if (!is.na(mms_vals["burned"]) && !is.na(fracgas_vals["burned"])) {
      mms_vals["burned"] * fracgas_vals["burned"]
    } else 0

    other_names <- setdiff(intersect(names(mms_vals), names(fracgas_vals)), c("pasture", "burned"))
    other_terms <- sum(mms_vals[other_names] * fracgas_vals[other_names], na.rm = TRUE)

    list(fracgas_pasture = pasture_term, fracgas_burned = burned_term, fracgas_other = other_terms)
  }, by = seq_len(nrow(fracgas_merged))]

  gleam_data[, c(paste0("fracgas_pasture", ipcc_method), paste0("fracgas_burned", ipcc_method), paste0("fracgas_other", ipcc_method)) := list(
    fracgas_result$fracgas_pasture, fracgas_result$fracgas_burned, fracgas_result$fracgas_other
  )]

  ### Nvol - IPCC method------
  fracgas_pasture_col <- paste0("fracgas_pasture", ipcc_method)
  fracgas_burned_col <- paste0("fracgas_burned", ipcc_method)
  fracgas_other_col <- paste0("fracgas_other", ipcc_method)

  n_vol_result <- gleam_data[, calc_nitrogen_volatilization(
    n_excretion = n_excretion,
    fracgas_pasture = get(fracgas_pasture_col),
    fracgas_burned = get(fracgas_burned_col),
    fracgas_other = get(fracgas_other_col)
  ), by = seq_len(nrow(gleam_data))]

  gleam_data[, c(
    paste0("n_vol_manure_pasture", ipcc_method),
    paste0("n_vol_manure_burned", ipcc_method),
    paste0("n_vol_manure_other", ipcc_method),
    paste0("n_vol_manure_all_noburn", ipcc_method)
  ) := list(
    n_vol_result$n_vol_manure_pasture, n_vol_result$n_vol_manure_burned,
    n_vol_result$n_vol_manure_other, n_vol_result$n_vol_manure_all_noburn
  )]

  ### N2O manure indirect volatilization - IPCC method------
  # Merge EF4 data into temporary variable
  ef4_merged <- merge(gleam_data, ef4_table, by = "ADM0_CODE", allow.cartesian = TRUE)

  n_vol_pasture_col <- paste0("n_vol_manure_pasture", ipcc_method)
  n_vol_burned_col <- paste0("n_vol_manure_burned", ipcc_method)
  n_vol_other_col <- paste0("n_vol_manure_other", ipcc_method)

  n2o_vol_result <- ef4_merged[, calc_n2o_from_volatilization(
    n_vol_pasture = get(n_vol_pasture_col),
    n_vol_burned = get(n_vol_burned_col),
    n_vol_other = get(n_vol_other_col),
    ef4 = ef4
  ), by = seq_len(nrow(ef4_merged))]

  gleam_data[, c(
    paste0("n2o_vol_manure_pasture", ipcc_method),
    paste0("n2o_vol_manure_burned", ipcc_method),
    paste0("n2o_vol_manure_other", ipcc_method),
    paste0("n2o_vol_manure_all_noburn", ipcc_method)
  ) := list(
    n2o_vol_result$n2o_vol_manure_pasture, n2o_vol_result$n2o_vol_manure_burned,
    n2o_vol_result$n2o_vol_manure_other, n2o_vol_result$n2o_vol_manure_all_noburn
  )]

  ### Fracleach - IPCC method------
  # Merge FracLEACH data into temporary variable (handle HerdType_short for CTL/CHK)
  fracleach_with_herd <- fracleach_table[
    HerdType_short %in% c("DRY", "LAY", "BRL") & Animal_short %in% c("CTL", "CHK")
  ]
  fracleach_without_herd <- fracleach_table[
    !(Animal_short %in% c("CTL", "CHK") & HerdType_short %in% c("DRY", "LAY", "BRL"))
  ]

  gleam_fracleach_with_herd <- gleam_data[
    HerdType_short %in% c("DRY", "LAY", "BRL") & Animal_short %in% c("CTL", "CHK")
  ]
  gleam_fracleach_without_herd <- gleam_data[
    !(Animal_short %in% c("CTL", "CHK") & HerdType_short %in% c("DRY", "LAY", "BRL"))
  ]

  gleam_fracleach_with_herd <- merge(gleam_fracleach_with_herd, fracleach_with_herd, by = c("ADM0_CODE", "Animal_short", "HerdType_short"), suffixes = c("", "_fracleach"), all.x = TRUE)
  gleam_fracleach_without_herd <- merge(gleam_fracleach_without_herd, fracleach_without_herd[, .(ADM0_CODE, Animal_short, mmspasture, mmsdaily, mmssolid, mmssolidcov, mmssolidbulk, mmssolidadd, mmsdrylot, mmspit1, mmspit3, mmspit4, mmspit6, mmspit12, mmsliquid1, mmsliquid3, mmsliquid4, mmsliquid6, mmsliquid12, mmsliquidnatcov1, mmsliquidnatcov3, mmsliquidnatcov4, mmsliquidnatcov6, mmsliquidnatcov12, mmsliquidsolcov1, mmsliquidsolcov3, mmsliquidsolcov4, mmsliquidsolcov6, mmsliquidsolcov12, mmslagoon, mmsbiogaslowleak1, mmsbiogaslowleak2, mmsbiogaslowleak3, mmsbiogashighleak1, mmsbiogashighleak2, mmsbiogashighleak3, mmsburned, mmsdeepnomix2, mmsdeepnomix1, mmsdeepmix2, mmsdeepmix1, mmscompostves, mmscompoststat, mmscompostint, mmscompostpass, mmslitter, mmsnolitter, mmsareobic, mmsaerproc)], by = c("ADM0_CODE", "Animal_short"), suffixes = c("", "_fracleach"), all.x = TRUE)

  fracleach_merged <- rbindlist(list(gleam_fracleach_with_herd, gleam_fracleach_without_herd), use.names = TRUE, fill = TRUE)

  # Calculate FracLEACH values
  fracleach_result <- fracleach_merged[, {
    available_mms_cols <- intersect(mms_cols, names(.SD))
    available_fracleach_cols <- intersect(paste0(mms_cols, "_fracleach"), names(.SD))

    mms_vals <- unlist(.SD[, available_mms_cols, with = FALSE])
    fracleach_vals <- unlist(.SD[, available_fracleach_cols, with = FALSE])

    names(mms_vals) <- sub("^mms", "", available_mms_cols)
    names(fracleach_vals) <- sub("^mms", "", sub("_fracleach$", "", available_fracleach_cols))

    pasture_term <- if (!is.na(mms_vals["pasture"]) && !is.na(fracleach_vals["pasture"])) {
      mms_vals["pasture"] * fracleach_vals["pasture"]
    } else 0

    burned_term <- if (!is.na(mms_vals["burned"]) && !is.na(fracleach_vals["burned"])) {
      mms_vals["burned"] * fracleach_vals["burned"]
    } else 0

    other_names <- setdiff(intersect(names(mms_vals), names(fracleach_vals)), c("pasture", "burned"))
    other_terms <- sum(mms_vals[other_names] * fracleach_vals[other_names], na.rm = TRUE)

    list(fracleach_pasture = pasture_term, fracleach_burned = burned_term, fracleach_other = other_terms)
  }, by = seq_len(nrow(fracleach_merged))]

  gleam_data[, c(paste0("fracleach_pasture", ipcc_method), paste0("fracleach_burned", ipcc_method), paste0("fracleach_other", ipcc_method)) := list(
    fracleach_result$fracleach_pasture, fracleach_result$fracleach_burned, fracleach_result$fracleach_other
  )]

  ### Nleach - IPCC method------
  fracleach_pasture_col <- paste0("fracleach_pasture", ipcc_method)
  fracleach_burned_col <- paste0("fracleach_burned", ipcc_method)
  fracleach_other_col <- paste0("fracleach_other", ipcc_method)

  n_leach_result <- gleam_data[, calc_nitrogen_leaching(
    n_excretion = n_excretion,
    fracleach_pasture = get(fracleach_pasture_col),
    fracleach_burned = get(fracleach_burned_col),
    fracleach_other = get(fracleach_other_col)
  ), by = seq_len(nrow(gleam_data))]

  gleam_data[, c(
    paste0("n_leach_manure_pasture", ipcc_method),
    paste0("n_leach_manure_burned", ipcc_method),
    paste0("n_leach_manure_other", ipcc_method),
    paste0("n_leach_manure_all_noburn", ipcc_method)
  ) := list(
    n_leach_result$n_leach_manure_pasture, n_leach_result$n_leach_manure_burned,
    n_leach_result$n_leach_manure_other, n_leach_result$n_leach_manure_all_noburn
  )]

  ### N2O manure indirect leaching - IPCC method------
  # Merge EF5 data into temporary variable
  ef5_merged <- merge(gleam_data, ef5_table, by = "ADM0_CODE", allow.cartesian = TRUE)

  n_leach_pasture_col <- paste0("n_leach_manure_pasture", ipcc_method)
  n_leach_burned_col <- paste0("n_leach_manure_burned", ipcc_method)
  n_leach_other_col <- paste0("n_leach_manure_other", ipcc_method)

  n2o_leach_result <- ef5_merged[, calc_n2o_from_leaching(
    n_leach_pasture = get(n_leach_pasture_col),
    n_leach_burned = get(n_leach_burned_col),
    n_leach_other = get(n_leach_other_col),
    ef5 = ef5
  ), by = seq_len(nrow(ef5_merged))]

  gleam_data[, c(
    paste0("n2o_leach_manure_pasture", ipcc_method),
    paste0("n2o_leach_manure_burned", ipcc_method),
    paste0("n2o_leach_manure_other", ipcc_method),
    paste0("n2o_leach_manure_all_noburn", ipcc_method)
  ) := list(
    n2o_leach_result$n2o_leach_manure_pasture, n2o_leach_result$n2o_leach_manure_burned,
    n2o_leach_result$n2o_leach_manure_other, n2o_leach_result$n2o_leach_manure_all_noburn
  )]

  ## TOTAL N2O -----
  direct_pasture_col <- paste0("direct_n2o_manure_pasture", ipcc_method)
  direct_burned_col <- paste0("direct_n2o_manure_burned", ipcc_method)
  direct_other_col <- paste0("direct_n2o_manure_other", ipcc_method)
  vol_pasture_col <- paste0("n2o_vol_manure_pasture", ipcc_method)
  vol_burned_col <- paste0("n2o_vol_manure_burned", ipcc_method)
  vol_other_col <- paste0("n2o_vol_manure_other", ipcc_method)
  leach_pasture_col <- paste0("n2o_leach_manure_pasture", ipcc_method)
  leach_burned_col <- paste0("n2o_leach_manure_burned", ipcc_method)
  leach_other_col <- paste0("n2o_leach_manure_other", ipcc_method)

  total_n2o_result <- gleam_data[, calc_total_n2o_emissions(
    direct = list(
      direct_n2o_manure_pasture = get(direct_pasture_col),
      direct_n2o_manure_burned = get(direct_burned_col),
      direct_n2o_manure_other = get(direct_other_col)
    ),
    vol = list(
      n2o_vol_manure_pasture = get(vol_pasture_col),
      n2o_vol_manure_burned = get(vol_burned_col),
      n2o_vol_manure_other = get(vol_other_col)
    ),
    leach = list(
      n2o_leach_manure_pasture = get(leach_pasture_col),
      n2o_leach_manure_burned = get(leach_burned_col),
      n2o_leach_manure_other = get(leach_other_col)
    )
  ), by = seq_len(nrow(gleam_data))]

  gleam_data[, c(
    paste0("indirect_n2o_manure_burned", ipcc_method),
    paste0("indirect_n2o_manure_pasture", ipcc_method),
    paste0("indirect_n2o_manure_other", ipcc_method),
    paste0("total_n2o_manure_burned", ipcc_method),
    paste0("total_n2o_manure_pasture", ipcc_method),
    paste0("total_n2o_manure_other", ipcc_method)
  ) := list(
    total_n2o_result$indirect_n2o_manure_burned, total_n2o_result$indirect_n2o_manure_pasture,
    total_n2o_result$indirect_n2o_manure_other, total_n2o_result$total_n2o_manure_burned,
    total_n2o_result$total_n2o_manure_pasture, total_n2o_result$total_n2o_manure_other
  )]

  return(gleam_data)
}
