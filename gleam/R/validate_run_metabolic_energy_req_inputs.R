#' Validate inputs for run_metabolic_energy_req_module
#'
#' Validates that cohort_level_data and herd_level_data have the correct structure,
#' required columns, valid cohort and species_short values, and consistent herd_id linkage.
#'
#' @param cohort_level_data data.table. Cohort-level inputs (one row per herd-cohort).
#' @param herd_level_data data.table. Herd-level inputs (one row per herd).
#'
#' @noRd
validate_run_metabolic_energy_req_module_inputs <- function(
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
    "herd_id", "cohort_short",
    "live_weight_cohort_average", "offtake_rate",
    "low_activity_fraction", "high_activity_fraction",
    "live_weight_cohort_initial", "live_weight_cohort_final", "live_weight_mature_stage",
    "daily_weight_gain", "cohort_duration_days",
    "ration_digestibility_fraction", "ration_gross_energy", "ration_metabolizable_energy"
  )
  required_herd_cols <- c(
    "herd_id", "species_short",
    "age_first_parturition", "lactating_females_fraction", "milk_yield_day", "milk_fat_fraction",
    "non_productive_duration", "pregnancy_duration", "litter_size", "death_rate_juvenile",
    "live_weight_at_birth", "live_weight_at_weaning",
    "lactation_duration", "parturition_rate",
    "draught_work_hours_female", "draught_work_hours_male",
    "draught_fraction_female", "draught_fraction_male",
    "fibre_yield_year"
  )

  check_required_columns(cohort_level_data, required_cohort_cols, "cohort_level_data")
  check_required_columns(herd_level_data, required_herd_cols, "herd_level_data")

  # --- Cohort: valid cohort_short, exactly 6 rows per herd_id -----------------
  # Must use valid GLEAM cohort codes; each herd must have all 6 cohorts
  validate_cohort_short_values(cohort_level_data$cohort_short, data_arg = "cohort_level_data")
  check_cohort_completeness(cohort_level_data, "cohort_level_data")

  # --- Herd: one row per herd_id, valid species_short -------------------------
  check_herd_id_unique(herd_level_data, "herd_level_data")
  validate_species_short_values(herd_level_data$species_short, data_arg = "herd_level_data")

  # --- Cross-table: same herd_id set ------------------------------------------
  check_herd_id_consistency(
    cohort_level_data, herd_level_data,
    "cohort_level_data", "herd_level_data"
  )

  # --- Module-specific: numeric consistency (cohort-level) --------------------
  # low_activity_fraction + high_activity_fraction >= 0 and <= 1 per row
  cohort_level_data[
    , activity_sum := low_activity_fraction + high_activity_fraction
  ]
  bad_activity_high <- cohort_level_data[activity_sum > 1, .(herd_id, cohort_short)]
  bad_activity_low <- cohort_level_data[activity_sum < 0, .(herd_id, cohort_short)]
  cohort_level_data[, activity_sum := NULL]
  if (nrow(bad_activity_high) > 0) {
    bad_info <- bad_activity_high[, paste0(herd_id, " / ", cohort_short)]
    cli::cli_abort(
      "For each row, {.field low_activity_fraction} + {.field high_activity_fraction} must be <= 1.
      Violation(s): {.val {bad_info}}"
    )
  }
  if (nrow(bad_activity_low) > 0) {
    bad_info <- bad_activity_low[, paste0(herd_id, " / ", cohort_short)]
    cli::cli_abort(
      "For each row, {.field low_activity_fraction} + {.field high_activity_fraction} must be >= 0.
      Violation(s): {.val {bad_info}}"
    )
  }

  # live_weight_cohort_initial <= live_weight_cohort_average <= live_weight_cohort_final (skip if any NA)
  inconsistent_weights <- cohort_level_data[
    !is.na(live_weight_cohort_initial) & !is.na(live_weight_cohort_average) & !is.na(live_weight_cohort_final) &
      (live_weight_cohort_initial > live_weight_cohort_average | live_weight_cohort_average > live_weight_cohort_final),
    .(herd_id, cohort_short)
  ]
  if (nrow(inconsistent_weights) > 0) {
    bad_info <- inconsistent_weights[, paste0(herd_id, " / ", cohort_short)]
    cli::cli_abort(
      "For each row, {.field live_weight_cohort_initial} <= {.field live_weight_cohort_average} <= {.field live_weight_cohort_final} must hold.
      Violation(s): {.val {bad_info}}"
    )
  }

  # --- Numeric consistency (herd-level) ----------------------------------------
  # live_weight_at_birth < live_weight_at_weaning where both present (strict)
  bad_birth_weaning <- herd_level_data[
    !is.na(live_weight_at_birth) & !is.na(live_weight_at_weaning) & live_weight_at_birth >= live_weight_at_weaning,
    herd_id
  ]
  if (length(bad_birth_weaning) > 0) {
    cli::cli_abort(
      "For each herd, {.field live_weight_at_birth} must be strictly less than {.field live_weight_at_weaning}.
      Violation(s) for herd_id: {.val {bad_birth_weaning}}"
    )
  }
}
