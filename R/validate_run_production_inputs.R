#' Validate inputs for run_production_module
#'
#' Validates that cohort_level_data and herd_level_data have the correct structure,
#' required columns, valid cohort values, and consistent herd_id linkage.
#'
#' @param cohort_level_data data.table. Cohort-level inputs (one row per herd-cohort).
#' @param herd_level_data data.table. Herd-level inputs (one row per herd).
#'
#' @noRd
validate_run_production_module_inputs <- function(
    cohort_level_data,
    herd_level_data
) {
  if (!validation_enabled()) return(invisible(NULL))
  # --- Basic type and structure checks ----------------------------------------
  # Ensure inputs are data.tables with at least one row
  check_data_table(cohort_level_data, "cohort_level_data")
  check_data_table(herd_level_data, "herd_level_data")

  # --- Required columns -------------------------------------------------------
  # Verify all module-specific columns are present
  required_cohort_cols <- c(
    "herd_id", "cohort_short", "cohort_stock_size",
    "offtake_heads_assessment", "live_weight_cohort_at_slaughter"
  )
  required_herd_cols <- c(
    "herd_id", "species_short",
    "milk_yield_day", "lactating_females_fraction",
    "milk_protein_fraction", "milk_fat_fraction", "milk_lactose_fraction",
    "milk_protein_fraction_standard", "milk_fat_fraction_standard", "milk_lactose_fraction_standard",
    "fibre_yield_year",
    "carcass_dressing_fraction", "bone_free_meat_fraction", "meat_protein_fraction"
  )
  check_module_input_columns(
    cohort_level_data, required_cohort_cols, "cohort_level_data",
    "production", cohort_level_data, herd_level_data
  )
  check_module_input_columns(
    herd_level_data, required_herd_cols, "herd_level_data",
    "production", cohort_level_data, herd_level_data,
    function_filter = "run_production_module"
  )

  # --- Cohort: valid, unique requested cohorts -----------------
  # Must use valid GLEAM cohort codes; each requested herd/cohort must be unique
  validate_cohort_short_values(cohort_level_data$cohort_short, data_arg = "cohort_level_data")
  check_cohort_uniqueness(cohort_level_data, "cohort_level_data")

  # --- Herd: one row per herd_id -----------------------------------------------
  check_herd_id_unique(herd_level_data, "herd_level_data")

  # --- Cross-table: same herd_id set ------------------------------------------
  # Cohort and herd tables must cover identical herd_id sets
  check_herd_id_consistency(
    cohort_level_data, herd_level_data,
    "cohort_level_data", "herd_level_data"
  )
}
