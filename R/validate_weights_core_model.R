#' Validate inputs for calc_cohort_weights
#'
#' @noRd
validate_cohort_weight_inputs <- function(
    cohort_short,
    live_weight_female_adult, live_weight_male_adult,
    live_weight_at_birth,
    live_weight_female_at_slaughter, live_weight_male_at_slaughter,
    live_weight_at_weaning,
    species_short = NULL
) {
  if (!validation_enabled()) return(invisible(NULL))
  # Character inputs
  validate_cohort_code(cohort_short)


  # Numeric inputs (allow NA by default; cohort-specific checks below)
  args <- list(
    live_weight_female_adult = live_weight_female_adult,
    live_weight_male_adult = live_weight_male_adult,
    live_weight_at_birth = live_weight_at_birth,
    live_weight_female_at_slaughter = live_weight_female_at_slaughter,
    live_weight_male_at_slaughter = live_weight_male_at_slaughter,
    live_weight_at_weaning = live_weight_at_weaning
  )

  for (arg_name in names(args)) {
    val <- args[[arg_name]]
    if (length(val) != 1L || (!is.na(val) && !is.numeric(val))) {
      cli::cli_abort("{.arg {arg_name}} must be a single numeric (scalar). NA is allowed.")
    }
  }

  required_params <- get_required_function_parameters(
    cohort_filter = cohort_short,
    function_filter = "calc_cohort_weights",
    species_filter = species_short,
    input_table_filter = "herd_level_data"
  )

  # A misspelled or missing dependency must not silently skip validation.
  unknown_params <- setdiff(required_params, names(args))
  if (length(unknown_params) > 0L || length(required_params) == 0L) {
    cli::cli_abort(
      "Invalid weight parameter dependency rules for cohort {.val {cohort_short}}: expected required weight arguments, found {.val {required_params}}."
    )
  }

  # Check required values
  missing_required <- required_params[
    vapply(
      required_params,
      function(arg_name) {
        is.na(args[[arg_name]])
      },
      logical(1)
    )
  ]

  if (length(missing_required) > 0) {
    cli::cli_abort(
      "Missing required weight inputs for cohort {.val {cohort_short}}:
       {.val {missing_required}}"
    )
  }

  # Validate ranges only for applicable parameters
  for (arg_name in required_params) {
    validate_param_range(
      args[[arg_name]],
      arg_name,
      species_filter = species_short,
      cohort_filter = cohort_short
    )
  }

  validate_parameter_relations(args, "calc_cohort_weights", species_short, cohort_short)

}

#' Validate inputs for calc_avg_weights
#'
#' Ensures all arguments are numeric scalars (length 1), allows NA.
#'
#' @noRd
validate_avg_weight_inputs <- function(
    live_weight_cohort_initial,
    live_weight_cohort_potential_final,
    live_weight_cohort_at_slaughter,
    offtake_rate
) {
  if (!validation_enabled()) return(invisible(NULL))
  validate_scalar_numeric(live_weight_cohort_initial)
  validate_scalar_numeric(live_weight_cohort_potential_final)
  validate_scalar_numeric(live_weight_cohort_at_slaughter)
  validate_scalar_numeric(offtake_rate)

  # Enforce configured bounds
  validate_param_range(live_weight_cohort_at_slaughter)
  validate_param_range(offtake_rate)
}

#' Validate inputs for calc_daily_weight_gain
#'
#' Ensures arguments are numeric scalars (length 1), allows NA values.
#'
#' @noRd
validate_daily_gain_inputs <- function(
    live_weight_cohort_potential_final,
    live_weight_cohort_initial,
    cohort_duration_days
) {
  if (!validation_enabled()) return(invisible(NULL))
  validate_scalar_numeric(live_weight_cohort_potential_final)
  validate_scalar_numeric(live_weight_cohort_initial)
  validate_scalar_numeric(cohort_duration_days)

  # Enforce configured bounds
  validate_param_range(cohort_duration_days)
}
