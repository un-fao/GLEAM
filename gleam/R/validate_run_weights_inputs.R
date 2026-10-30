#' Validate inputs for run_weights_module
#'
#' Validates that cohort_level_data and herd_level_data have the correct structure,
#' required columns, and proper relationships between them.
#'
#' @param cohort_level_data data.table. Cohort-level data with one row per cohort.
#' @param herd_level_data data.table. Herd-level data with one row per herd.
#'
#' @noRd
validate_run_weights_module_inputs <- function(
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
    "herd_id", "cohort_short", "cohort_duration_days", "offtake_rate"
  )
  required_herd_cols <- c(
    "herd_id",
    "live_weight_female_adult",
    "live_weight_male_adult",
    "live_weight_at_birth",
    "live_weight_female_at_slaughter",
    "live_weight_male_at_slaughter",
    "live_weight_at_weaning"
  )

  check_required_columns(cohort_level_data, required_cohort_cols, "cohort_level_data")
  check_required_columns(herd_level_data, required_herd_cols, "herd_level_data")

  if (any(cohort_level_data$cohort_short %in% c("FN", "MN"))) {
    required_nondemo_herd_cols <- c(
      "live_weight_female_nondemographic_start",
      "live_weight_male_nondemographic_start",
      "live_weight_female_nondemographic_end",
      "live_weight_male_nondemographic_end",
      "phase1_nondemo_fem_duration_days",
      "phase2_nondemo_fem_duration_days",
      "phase1_nondemo_mal_duration_days",
      "phase2_nondemo_mal_duration_days"
    )
    check_required_columns(
      herd_level_data,
      required_nondemo_herd_cols,
      "herd_level_data"
    )
  }

  # --- Cohort: valid cohort_short, exactly 6 rows per herd_id ------------------
  validate_cohort_short_values(cohort_level_data$cohort_short, data_arg = "cohort_level_data")

  # --- Herd: one row per herd_id -----------------------------------------------
  check_herd_id_unique(herd_level_data, "herd_level_data")

  # --- Cross-table: same herd_id set -------------------------------------------
  check_herd_id_consistency(
    cohort_level_data, herd_level_data,
    "cohort_level_data", "herd_level_data"
  )

  # --- Module-specific: weight ordering (per herd_id) -------------------------
  # For each herd: live_weight_at_birth must be less than live_weight_female_at_slaughter,
  # live_weight_male_at_slaughter, and live_weight_at_weaning (cohort slaughter weights are
  # derived from these, so this ensures live_weight_at_birth < live_weight_cohort_at_slaughter).
  violations_female <- herd_level_data[
    !is.na(live_weight_at_birth) & !is.na(live_weight_female_at_slaughter) & live_weight_at_birth >= live_weight_female_at_slaughter,
    herd_id
  ]
  if (length(violations_female) > 0) {
    cli::cli_abort(
      "For each herd_id, {.var live_weight_at_birth} must be less than {.var live_weight_female_at_slaughter}.
      Violation(s) for herd_id: {.val {violations_female}}"
    )
  }

  violations_male <- herd_level_data[
    !is.na(live_weight_at_birth) & !is.na(live_weight_male_at_slaughter) & live_weight_at_birth >= live_weight_male_at_slaughter,
    herd_id
  ]
  if (length(violations_male) > 0) {
    cli::cli_abort(
      "For each herd_id, {.var live_weight_at_birth} must be less than {.var live_weight_male_at_slaughter}.
      Violation(s) for herd_id: {.val {violations_male}}"
    )
  }

  violations_weaning <- herd_level_data[
    !is.na(live_weight_at_birth) & !is.na(live_weight_at_weaning) & live_weight_at_birth >= live_weight_at_weaning,
    herd_id
  ]
  if (length(violations_weaning) > 0) {
    cli::cli_abort(
      "For each herd_id, {.var live_weight_at_birth} must be less than {.var live_weight_at_weaning}.
      Violation(s) for herd_id: {.val {violations_weaning}}"
    )
  }
}
