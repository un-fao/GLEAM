#' Run Direct Emissions From Manure
#'
#' Orchestrates the manure emissions core model at the cohort level by:
#' - estimating volatile solids from diet inputs,
#' - applying manure management system (MMS) fractions and factors, and
#' - aggregating CH4 and N2O direct + indirect emissions.
#'
#' This wrapper assumes pre-cleaned inputs and performs run-level validation
#' of table structure and key consistency.
#'
#' Key requirements enforced at run time include:
#' - For each herd_id, the MMS list must match between
#'   `manure_management_system_fraction` and `manure_management_system_factors`.
#'
#' @param directemissions_manure_input_cohort_level_data Cohort-level data with at least:
#'   `herd_id`, `cohort`, `dry_matter_intake`, `diet_digestibility_fraction`,
#'   `nitrogen_excretion`.
#' @param manure_management_system_fraction Cohort-level MMS fractions with at least:
#'   `herd_id`, `cohort`, `manure_management_system`, `manure_management_system_fraction`.
#' @param manure_management_system_factors Herd-level MMS factors with at least:
#'   `herd_id`, `manure_management_system`,
#'   `methane_conversion_factor_mcf`, `ch4_max_producing_capacity_bo`,
#'   `n2o_ef3`, `n2o_ef4`, `n2o_ef5`, `nitrogen_fracgas`, `nitrogen_fracleach`.
#' @param diet_ash Numeric. Fraction of feed as ash in dry matter.
#' @param urinary_energy_fraction Numeric. Fraction of gross energy excreted in urine.
#'
#' @return The input `data.table` with added manure emissions columns
#'   (volatile solids, CH4 components, N2O direct/indirect and totals).
#'
#' @examples
#' \dontrun{
#' manure_management_system_factors <- data.table::fread(
#'   system.file(
#'     "extdata/examples/manure_management_system_factors.csv",
#'     package = "gleam"
#'   )
#' )
#' manure_management_system_fraction <- data.table::fread(
#'   system.file(
#'     "extdata/examples/manure_management_system_fraction.csv",
#'     package = "gleam"
#'   )
#' )
#' directemissions_manure_input_cohort_level_data <- data.table::fread(
#'   system.file(
#'     "extdata/examples/directemissions_manure_input_cohort_level_data.csv",
#'     package = "gleam"
#'   )
#' )
#'
#' result <- run_directemissions_manure(
#'   directemissions_manure_input_cohort_level_data = directemissions_manure_input_cohort_level_data,
#'   manure_management_system_fraction = manure_management_system_fraction,
#'   manure_management_system_factors = manure_management_system_factors
#' )
#' }
#'
#' @export
#'
#' @importFrom data.table := .I
run_directemissions_manure <- function(
    directemissions_manure_input_cohort_level_data,
    manure_management_system_fraction,
    manure_management_system_factors,
    diet_ash = 0.08,
    urinary_energy_fraction = 0.04
) {
  # --- Step 1: Validate inputs ------------------------------------------------
  validate_directemissions_manure_inputs(
    directemissions_manure_input_cohort_level_data = directemissions_manure_input_cohort_level_data,
    manure_management_system_fraction = manure_management_system_fraction,
    manure_management_system_factors = manure_management_system_factors
  )

  # --- Step 2: Prepare inputs -------------------------------------------------
  cohort_level_data <- data.table::copy(directemissions_manure_input_cohort_level_data)
  mms_fraction <- data.table::copy(manure_management_system_fraction)
  mms_factors <- data.table::copy(manure_management_system_factors)

  # Join cohort fractions with herd-level MMS factors
  mms_data <- merge(
    mms_fraction,
    mms_factors,
    by = c("herd_id", "manure_management_system")
  )

  # Build the MMS list expected by scientific core functions.
  # Each MMS becomes a named numeric vector with specific fields.
  build_mms_list <- function(mms_rows, fields) {
    if (nrow(mms_rows) == 0) {
      return(list())
    }

    # Keep only MMS id plus required fields, then split by MMS name.
    mms_subset <- mms_rows[, c("manure_management_system", fields), with = FALSE]
    mms_split <- split(mms_subset, mms_subset$manure_management_system)

    # Convert each MMS to a named numeric vector of required fields.
    mms_list <- lapply(mms_split, function(mms_df) {
      unlist(mms_df[1, fields, with = FALSE], use.names = TRUE)
    })

    return(mms_list)
  }

  # --- Step 3: Volatile solids (VS) -------------------------------------------
  cohort_level_data[
    ,
    volatile_solids := calc_volatile_solids(
      dry_matter_intake = dry_matter_intake,
      diet_digestibility_fraction = diet_digestibility_fraction,
      urinary_energy_fraction = urinary_energy_fraction,
      diet_ash = diet_ash
    ),
    by = .I
  ]

  # --- Step 4: CH4 from manure (pasture, burned, other, total non-burned) -----
  cohort_level_data[
    ,
    c(
      "ch4_manure_pasture",
      "ch4_manure_burned",
      "ch4_manure_other",
      "ch4_manure_all_noburn"
    ) := {
      # Select MMS records for this herd/cohort (fractions + factors).
      current_herd_id <- herd_id
      current_cohort <- cohort
      mms_rows <- mms_data[herd_id == current_herd_id & cohort == current_cohort]

      # Build the list expected by calc_ch4_emissions(...)
      mms_list <- build_mms_list(
        mms_rows,
        c("manure_management_system_fraction",
          "methane_conversion_factor_mcf",
          "ch4_max_producing_capacity_bo")
      )

      # calc_ch4_emissions() accepts variable MMS inputs via `...`.
      ch4 <- do.call(
        calc_ch4_emissions, c(list(volatile_solids = volatile_solids), mms_list)
      )
      list(
        ch4$ch4_manure_pasture,
        ch4$ch4_manure_burned,
        ch4$ch4_manure_other,
        ch4$ch4_manure_all_noburn
      )
    },
    by = .I
  ]

  # --- Step 5: Direct N2O from manure (pasture, burned, other, total non-burned)
  cohort_level_data[
    ,
    c(
      "n2o_manure_pasture_direct",
      "n2o_manure_burned_direct",
      "n2o_manure_other_direct",
      "n2o_manure_all_noburn_direct"
    ) := {
      # Select MMS records for this herd/cohort (fractions + factors).
      current_herd_id <- herd_id
      current_cohort <- cohort
      mms_rows <- mms_data[herd_id == current_herd_id & cohort == current_cohort]

      # Build the list expected by calc_direct_n2o_emissions(...)
      mms_list <- build_mms_list(mms_rows, c("manure_management_system_fraction", "n2o_ef3"))

      # calc_direct_n2o_emissions() accepts variable MMS inputs via `...`.
      n2o_direct <- do.call(
        calc_direct_n2o_emissions,
        c(list(nitrogen_excretion = nitrogen_excretion), mms_list)
      )
      list(
        n2o_direct$n2o_manure_pasture_direct,
        n2o_direct$n2o_manure_burned_direct,
        n2o_direct$n2o_manure_other_direct,
        n2o_direct$n2o_manure_all_noburn_direct
      )
    },
    by = .I
  ]

  # --- Step 6: Indirect N2O from volatilization -------------------------------
  cohort_level_data[
    ,
    c(
      "n2o_vol_manure_pasture",
      "n2o_vol_manure_burned",
      "n2o_vol_manure_other",
      "n2o_vol_manure_all_noburn"
    ) := {
      # Select MMS records for this herd/cohort (fractions + factors).
      current_herd_id <- herd_id
      current_cohort <- cohort
      mms_rows <- mms_data[herd_id == current_herd_id & cohort == current_cohort]

      # Build the list expected by calc_n2o_from_volatilization(...)
      mms_list <- build_mms_list(
        mms_rows, c("manure_management_system_fraction", "n2o_ef4", "nitrogen_fracgas")
      )

      # calc_n2o_from_volatilization() accepts variable MMS inputs via `...`.
      n2o_vol <- do.call(
        calc_n2o_from_volatilization,
        c(list(nitrogen_excretion = nitrogen_excretion), mms_list)
      )
      list(
        n2o_vol$n2o_vol_manure_pasture,
        n2o_vol$n2o_vol_manure_burned,
        n2o_vol$n2o_vol_manure_other,
        n2o_vol$n2o_vol_manure_all_noburn
      )
    },
    by = .I
  ]

  # --- Step 7: Indirect N2O from leaching/runoff ------------------------------
  cohort_level_data[
    ,
    c(
      "n2o_leach_manure_pasture",
      "n2o_leach_manure_burned",
      "n2o_leach_manure_other",
      "n2o_leach_manure_all_noburn"
    ) := {
      # Select MMS records for this herd/cohort (fractions + factors).
      current_herd_id <- herd_id
      current_cohort <- cohort
      mms_rows <- mms_data[herd_id == current_herd_id & cohort == current_cohort]

      # Build the list expected by calc_n2o_from_leaching(...)
      mms_list <- build_mms_list(
        mms_rows, c("manure_management_system_fraction", "n2o_ef5", "nitrogen_fracleach")
      )

      # calc_n2o_from_leaching() accepts variable MMS inputs via `...`.
      n2o_leach <- do.call(
        calc_n2o_from_leaching,
        c(list(nitrogen_excretion = nitrogen_excretion), mms_list)
      )
      list(
        n2o_leach$n2o_leach_manure_pasture,
        n2o_leach$n2o_leach_manure_burned,
        n2o_leach$n2o_leach_manure_other,
        n2o_leach$n2o_leach_manure_all_noburn
      )
    },
    by = .I
  ]

  # --- Step 8: Total N2O (direct + indirect) ---------------------------------
  cohort_level_data[
    ,
    c(
      "n2o_manure_pasture_indirect",
      "n2o_manure_burned_indirect",
      "n2o_manure_other_indirect",
      "n2o_manure_pasture_total",
      "n2o_manure_burned_total",
      "n2o_manure_other_total"
    ) := {
      totals <- calc_total_n2o_emissions(
        n2o_vol_manure_pasture = n2o_vol_manure_pasture,
        n2o_leach_manure_pasture = n2o_leach_manure_pasture,
        n2o_vol_manure_burned = n2o_vol_manure_burned,
        n2o_leach_manure_burned = n2o_leach_manure_burned,
        n2o_vol_manure_other = n2o_vol_manure_other,
        n2o_leach_manure_other = n2o_leach_manure_other,
        n2o_manure_pasture_direct = n2o_manure_pasture_direct,
        n2o_manure_burned_direct = n2o_manure_burned_direct,
        n2o_manure_other_direct = n2o_manure_other_direct
      )
      list(
        totals$n2o_manure_pasture_indirect,
        totals$n2o_manure_burned_indirect,
        totals$n2o_manure_other_indirect,
        totals$n2o_manure_pasture_total,
        totals$n2o_manure_burned_total,
        totals$n2o_manure_other_total
      )
    },
    by = .I
  ]

  return(cohort_level_data)
}
