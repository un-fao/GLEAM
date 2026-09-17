#' Validate inputs for run_nitrogen_balance_module
#'
#' Validates that cohort_level_data and herd_level_data have the correct structure,
#' required columns, valid species and cohort codes, and consistent herd_id linkage.
#' Detailed scalar-level checks (ranges, required parameters by species) are handled
#' by the nitrogen balance core model validators.
#'
#' @param cohort_level_data data.table. Cohort-level inputs (one row per herd-cohort).
#' @param herd_level_data data.table. Herd-level inputs (one row per herd).
#'
#' @noRd
validate_run_nitrogen_balance_module_inputs <- function(cohort_level_data, herd_level_data) {
  if (!validation_enabled()) return(invisible(NULL))
  # --- Basic type and structure checks ----------------------------------------
  # Ensure inputs are data.tables with at least one row
  check_data_table(cohort_level_data, "cohort_level_data")
  check_data_table(herd_level_data, "herd_level_data")

  # --- Required columns -------------------------------------------------------
  # Verify all module-specific columns are present
  required_cohort_cols <- c(
    "herd_id", "cohort_short",
    "ration_intake", "ration_nitrogen", "daily_weight_gain", "cohort_duration_days"
  )
  required_herd_cols <- c(
    "herd_id", "species_short",
    "milk_protein_fraction", "milk_yield_day", "fibre_yield_year",
    "litter_size", "parturition_rate",
    "live_weight_at_weaning", "live_weight_at_birth", "pregnancy_duration"
  )
  check_module_input_columns(
    cohort_level_data, required_cohort_cols, "cohort_level_data",
    "nitrogen", cohort_level_data, herd_level_data
  )
  check_module_input_columns(
    herd_level_data, required_herd_cols, "herd_level_data",
    "nitrogen", cohort_level_data, herd_level_data,
    function_filter = "run_nitrogen_balance_module"
  )

  # --- Cohort: valid, unique requested cohorts -----------------
  # Must use valid GLEAM cohort codes; each requested herd/cohort must be unique
  validate_cohort_short_values(cohort_level_data$cohort_short, data_arg = "cohort_level_data")
  check_cohort_uniqueness(cohort_level_data, "cohort_level_data")

  # --- Herd: unique herd_id, valid species_short ------------------------------
  # One row per herd; species codes must be valid GLEAM codes
  check_herd_id_unique(herd_level_data, "herd_level_data")
  validate_species_short_values(herd_level_data$species_short, data_arg = "herd_level_data")

  # --- Cross-table: same herd_id set ------------------------------------------
  # Cohort and herd tables must cover identical herd_id sets
  check_herd_id_consistency(
    cohort_level_data, herd_level_data,
    "cohort_level_data", "herd_level_data"
  )
}
