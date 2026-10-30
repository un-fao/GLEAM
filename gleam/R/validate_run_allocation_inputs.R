#' Validate inputs for run_allocation_module
#'
#' Validates that cohort_level_data and herd_level_data have the expected structure,
#' required columns, and consistent herd_id linkage (like run_metabolic_energy_req_module).
#'
#' @param cohort_level_data data.table. Cohort-level allocation inputs (one row per herd-cohort).
#' @param herd_level_data data.table. Herd-level allocation inputs (one row per herd).
#'
#' @noRd
validate_run_allocation_module_inputs <- function(
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
    "herd_id",
    "cohort_short",
    "milk_production_fpcm_cohort",
    "live_weight_cohort_at_slaughter",
    "meat_production_live_weight_cohort",
    "metabolic_energy_req_fibre_production",
    "cohort_stock_size",
    "metabolic_energy_req_work"
  )
  required_herd_cols <- c(
    "herd_id",
    "species_short",
    "live_weight_at_birth",
    "milk_protein_fraction_standard",
    "milk_fat_fraction_standard",
    "milk_lactose_fraction_standard",
    "ratio_me_to_ne"
  )

  check_required_columns(cohort_level_data, required_cohort_cols, "cohort_level_data")
  check_required_columns(herd_level_data, required_herd_cols, "herd_level_data")

  # --- Cross-table: same herd_id set -----------------------------------------
  # Cohort and herd tables must cover identical herd_id sets
  check_herd_id_consistency(
    cohort_level_data, herd_level_data,
    "cohort_level_data", "herd_level_data"
  )

  # --- Herd: one row per herd_id ----------------------------------------------
  check_herd_id_unique(herd_level_data, "herd_level_data")
}
