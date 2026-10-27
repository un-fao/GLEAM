#' Validate inputs for run_nondemographic_herd_module
#'
#' Validates that cohort_level_data and herd_level_data have the correct structure,
#' required columns, and proper relationships between them. Checks effective
#' phase 1 durations against their configured range before simulation starts.
#'
#' @param cohort_level_data data.table. Non-demographic cohort-level data.
#' @param herd_level_data data.table. Herd-level data with one row per herd.
#'
#' @noRd
validate_run_nondemographic_herd_module_inputs <- function(
    cohort_level_data,
    herd_level_data
) {
  phase_duration_cols <- c(
    "phase1_nondemo_fem_duration_days",
    "phase2_nondemo_fem_duration_days",
    "phase1_nondemo_mal_duration_days",
    "phase2_nondemo_mal_duration_days"
  )
  has_any_herd_phase_durations <- any(phase_duration_cols %in% names(herd_level_data))
  has_all_herd_phase_durations <- all(phase_duration_cols %in% names(herd_level_data))

  check_data_table(cohort_level_data, "cohort_level_data")
  check_data_table(herd_level_data, "herd_level_data")

  required_cohort_cols <- c(
    "herd_id", "cohort_short", "nondemo_productive_phase_id", "death_rate"
  )
  required_herd_cols <- c(
    "herd_id",
    "cohort_stock_fem_annual_nondemo",
    "cohort_stock_mal_annual_nondemo",
    "rest_between_nondemo_cycles_duration"
  )

  check_required_columns(cohort_level_data, required_cohort_cols, "cohort_level_data")
  check_required_columns(herd_level_data, required_herd_cols, "herd_level_data")

  if (has_any_herd_phase_durations && !has_all_herd_phase_durations) {
    cli::cli_abort(
      "If herd-level non-demographic phase durations are provided in {.arg herd_level_data},
      all of the following columns must be present: {.val {phase_duration_cols}}."
    )
  }

  if (!has_all_herd_phase_durations) {
    check_required_columns(
      cohort_level_data,
      "cohort_duration_days",
      "cohort_level_data"
    )
  }

  numeric_cohort_cols <- c("nondemo_productive_phase_id", "death_rate")
  if ("cohort_duration_days" %in% names(cohort_level_data) && !has_all_herd_phase_durations) {
    numeric_cohort_cols <- c(numeric_cohort_cols, "cohort_duration_days")
  }
  numeric_herd_cols <- c(
    "cohort_stock_fem_annual_nondemo",
    "cohort_stock_mal_annual_nondemo",
    "rest_between_nondemo_cycles_duration"
  )
  if (has_all_herd_phase_durations) {
    numeric_herd_cols <- c(numeric_herd_cols, phase_duration_cols)
  }

  for (col_name in numeric_cohort_cols) {
    if (!is.numeric(cohort_level_data[[col_name]])) {
      cli::cli_abort("{.arg cohort_level_data${col_name}} must be numeric.")
    }
  }

  for (col_name in numeric_herd_cols) {
    if (!is.numeric(herd_level_data[[col_name]])) {
      cli::cli_abort("{.arg herd_level_data${col_name}} must be numeric.")
    }
  }

  validate_cohort_short_values(
    cohort_level_data$cohort_short,
    data_arg = "cohort_level_data"
  )
  invalid_nondemographic_cohorts <- setdiff(
    unique(cohort_level_data$cohort_short),
    c("FN", "MN")
  )
  if (length(invalid_nondemographic_cohorts) > 0) {
    cli::cli_abort(
      "Invalid {.var cohort_short} values in {.arg cohort_level_data}: {.val {invalid_nondemographic_cohorts}}.
      Non-demographic inputs must use only {.val {c('FN', 'MN')}}."
    )
  }
  check_nondemographic_phase_completeness(
    cohort_level_data,
    data_arg = "cohort_level_data"
  )

  check_herd_id_unique(herd_level_data, "herd_level_data")
  check_herd_id_consistency(
    cohort_level_data,
    herd_level_data,
    "cohort_level_data",
    "herd_level_data"
  )

  # Resolve phase 1 durations with the same overrides used by the module.
  phase1_rows <- cohort_level_data[nondemo_productive_phase_id == 1]
  phase1_herd_rows <- herd_level_data[phase1_rows, on = "herd_id"]
  phase1_nondemo_duration <- assign_nondemographic_phase_durations(
    cohort_short = phase1_rows$cohort_short,
    nondemo_productive_phase_id = phase1_rows$nondemo_productive_phase_id,
    cohort_duration_days = if ("cohort_duration_days" %in% names(phase1_rows)) {
      phase1_rows$cohort_duration_days
    } else {
      NA_real_
    },
    phase1_nondemo_fem_duration_days = if (has_all_herd_phase_durations) {
      as.numeric(phase1_herd_rows$phase1_nondemo_fem_duration_days)
    } else {
      NA_real_
    },
    phase1_nondemo_mal_duration_days = if (has_all_herd_phase_durations) {
      as.numeric(phase1_herd_rows$phase1_nondemo_mal_duration_days)
    } else {
      NA_real_
    }
  )
  names(phase1_nondemo_duration) <- paste(
    phase1_rows$herd_id, phase1_rows$cohort_short, sep = "/"
  )
  validate_param_range(phase1_nondemo_duration)
}
