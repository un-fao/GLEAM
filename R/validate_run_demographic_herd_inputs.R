#' Validate inputs for run_demographic_herd_module
#'
#' Validates that cohort_level_data and herd_level_data have the correct structure,
#' required columns, and proper relationships between them.
#'
#' @param cohort_level_data data.table. Cohort-level data with one row per cohort.
#' @param herd_level_data data.table. Herd-level data with one row per herd.
#'
#' @noRd
validate_run_demographic_herd_module_inputs <- function(
    cohort_level_data,
    herd_level_data
) {

  # --- Basic type and structure checks ----------------------------------------
  # Ensure inputs are data.tables with at least one row
  check_data_table(cohort_level_data, "cohort_level_data")
  check_data_table(herd_level_data, "herd_level_data")

  # --- Required columns -------------------------------------------------------
  # Verify all module-specific columns are present
  required_cohort_cols <- c(
    "herd_id", "cohort_short", "cohort_duration_days", "offtake_rate", "death_rate"
  )
  required_herd_cols <- c(
    "herd_id", "parturition_rate", "litter_size", "birth_fraction_female", "herd_size_total",
    "prop_nondemo_fem_juv", "prop_nondemo_mal_juv"
  )
  check_required_columns(cohort_level_data, required_cohort_cols, "cohort_level_data")
  check_required_columns(herd_level_data, required_herd_cols, "herd_level_data")

  # --- Cohort: valid cohort_short, exactly 6 rows per herd_id -----------------
  # Must use valid GLEAM cohort codes; each herd must have all 6 cohorts
  validate_cohort_short_values(cohort_level_data$cohort_short, data_arg = "cohort_level_data")
  check_cohort_completeness(cohort_level_data, "cohort_level_data")

  # --- Herd: one row per herd_id -----------------------------------------------
  check_herd_id_unique(herd_level_data, "herd_level_data")

  # --- Cross-table: same herd_id set ------------------------------------------
  check_herd_id_consistency(
    cohort_level_data, herd_level_data,
    "cohort_level_data", "herd_level_data"
  )
}
