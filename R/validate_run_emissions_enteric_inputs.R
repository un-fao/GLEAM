#' Validate inputs for run_emissions_enteric_module
#'
#' Validates that cohort-level data has the correct structure, required columns,
#' valid cohort and species codes, and unique requested cohorts per herd_id.
#'
#' @param data data.table. Cohort-level data with one row per herd x cohort.
#'
#' @noRd
validate_run_emissions_enteric_module_inputs <- function(data) {
  if (!validation_enabled()) return(invisible(NULL))

  # --- Basic type and structure checks ----------------------------------------
  # Ensure input is a data.table with at least one row
  check_data_table(data, "data")

  # --- Required columns -------------------------------------------------------
  # Verify all module-specific columns are present
  required_cols <- c(
    "herd_id", "species_short", "cohort_short", "ration_digestibility_fraction",
    "ration_gross_energy", "ration_intake"
  )
  check_module_input_columns(data, required_cols, "data", "enteric", data, input_table_filter = "cohort_level_data")

  # --- Valid cohort and species_short codes -----------------------------------
  # Must use valid GLEAM codes; each requested herd/cohort must be unique
  validate_cohort_short_values(data$cohort_short, data_arg = "data")
  validate_species_short_values(data$species_short, data_arg = "data")

  # --- Unique requested cohorts per herd_id ----------------------------------------
  # Each requested herd/cohort pair must have exactly one row
  check_cohort_uniqueness(data, "data")
}
