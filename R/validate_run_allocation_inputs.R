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
  if (!data.table::is.data.table(cohort_level_data)) {
    cli::cli_abort("{.arg cohort_level_data} must be a data.table.")
  }
  if (!data.table::is.data.table(herd_level_data)) {
    cli::cli_abort("{.arg herd_level_data} must be a data.table.")
  }

  if (nrow(cohort_level_data) == 0) {
    cli::cli_abort("{.arg cohort_level_data} must contain at least one row.")
  }
  if (nrow(herd_level_data) == 0) {
    cli::cli_abort("{.arg herd_level_data} must contain at least one row.")
  }

  # --- Required columns validation --------------------------------------------
  required_cohort_cols <- c(
    "herd_id",
    "cohort_short",
    "milk_production_fpcm_cohort",
    "live_weight_cohort_at_slaughter",
    "meat_production_live_weight_cohort",
    "energy_requirement_fibre_production",
    "cohort_stock_size",
    "energy_requirement_work"
  )
  required_herd_cols <- c(
    "herd_id",
    "animal",
    "live_weight_at_birth",
    "milk_protein_fraction_standard",
    "milk_fat_fraction_standard",
    "milk_lactose_fraction_standard",
    "ratio_me_to_ne"
  )

  missing_cohort_cols <- setdiff(required_cohort_cols, names(cohort_level_data))
  if (length(missing_cohort_cols) > 0) {
    cli::cli_abort(
      "Missing required columns in {.arg cohort_level_data}: {.val {missing_cohort_cols}}"
    )
  }

  missing_herd_cols <- setdiff(required_herd_cols, names(herd_level_data))
  if (length(missing_herd_cols) > 0) {
    cli::cli_abort(
      "Missing required columns in {.arg herd_level_data}: {.val {missing_herd_cols}}"
    )
  }

  # --- Cross-table validation -------------------------------------------------
  cohort_herd_ids <- unique(cohort_level_data$herd_id)
  herd_level_herd_ids <- unique(herd_level_data$herd_id)

  missing_in_herd_level <- setdiff(cohort_herd_ids, herd_level_herd_ids)
  if (length(missing_in_herd_level) > 0) {
    cli::cli_abort(
      "Herd IDs in {.arg cohort_level_data} not found in {.arg herd_level_data}: {.val {missing_in_herd_level}}"
    )
  }

  missing_in_cohort <- setdiff(herd_level_herd_ids, cohort_herd_ids)
  if (length(missing_in_cohort) > 0) {
    cli::cli_abort(
      "Herd IDs in {.arg herd_level_data} not found in {.arg cohort_level_data}: {.val {missing_in_cohort}}"
    )
  }

  # --- Herd-level: one row per herd_id ----------------------------------------
  herd_id_counts <- herd_level_data[, .N, by = herd_id]
  duplicate_herds <- herd_id_counts[N > 1]
  if (nrow(duplicate_herds) > 0) {
    cli::cli_abort(
      "Each herd_id must appear exactly once in {.arg herd_level_data}. Found duplicates: {.val {duplicate_herds$herd_id}}"
    )
  }
}
