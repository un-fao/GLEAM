#' Validate inputs for run_all_herd_module
#'
#' @param cohort_level_data Optional cohort-level data.
#' @param herd_level_data Herd-level data.
#' @param run_demographic Logical switch for the demographic module.
#' @param run_nondemographic Logical switch for the non-demographic module.
#'
#' @noRd
validate_run_all_herd_module_inputs <- function(
    cohort_level_data,
    herd_level_data,
    run_demographic,
    run_nondemographic
) {
  if (!is.logical(run_demographic) || length(run_demographic) != 1L || is.na(run_demographic)) {
    cli::cli_abort("{.arg run_demographic} must be a single logical value (TRUE or FALSE).")
  }
  if (!is.logical(run_nondemographic) || length(run_nondemographic) != 1L || is.na(run_nondemographic)) {
    cli::cli_abort("{.arg run_nondemographic} must be a single logical value (TRUE or FALSE).")
  }

  if (!isTRUE(run_demographic) && !isTRUE(run_nondemographic)) {
    cli::cli_abort(
      "At least one of {.arg run_demographic} or {.arg run_nondemographic} must be {.val TRUE}."
    )
  }

  check_data_table(herd_level_data, "herd_level_data")

  if (is.null(cohort_level_data)) {
    cli::cli_abort("{.arg cohort_level_data} must be provided.")
  }
  check_data_table(cohort_level_data, "cohort_level_data")

  if (!"cohort_short" %in% names(cohort_level_data)) {
    cli::cli_abort("{.arg cohort_level_data} must contain {.var cohort_short}.")
  }

  cohort_level_data_demographic <- cohort_level_data[
    !is.na(cohort_short) & cohort_short %in% gleam_cohorts_demographic
  ]
  cohort_level_data_nondemographic <- cohort_level_data[
    !is.na(cohort_short) & cohort_short %in% c("FN", "MN")
  ]

  if (isTRUE(run_demographic) && nrow(cohort_level_data_demographic) == 0L) {
    cli::cli_abort(
      "{.arg run_demographic = TRUE} requires demographic rows in {.arg cohort_level_data}."
    )
  }

  if (isTRUE(run_nondemographic) && nrow(cohort_level_data_nondemographic) == 0L) {
    cli::cli_warn(
      "run_nondemographic=TRUE but no non-demographic rows were found in cohort_level_data."
    )
  }
}
