#' Validate inputs for run_emissions_enteric_module
#'
#' Validates that cohort-level data has the correct structure, required columns,
#' valid cohort and species codes, and exactly 6 cohorts per herd_id.
#'
#' @param data data.table. Cohort-level data with one row per herd x cohort.
#'
#' @noRd
validate_run_emissions_enteric_module_inputs <- function(data) {

  # --- Basic type and structure checks ----------------------------------------
  # Ensure input is a data.table with at least one row
  check_data_table(data, "data")

  # --- Required columns -------------------------------------------------------
  # Verify all module-specific columns are present
  required_cols <- c(
    "herd_id", "species_short", "cohort_short", "ration_digestibility_fraction",
    "ration_gross_energy", "ration_intake"
  )
  check_required_columns(data, required_cols, "data")

  # --- Valid cohort and species_short codes -----------------------------------
  # Must use valid GLEAM codes; each herd must have all 6 cohorts
  validate_cohort_short_values(data$cohort_short, data_arg = "data")
  validate_species_short_values(data$species_short, data_arg = "data")

  # --- Cohort completeness per herd_id ----------------------------------------
  # Each herd_id must have exactly 6 rows (one per cohort)
  check_cohort_completeness(data, "data")
}
