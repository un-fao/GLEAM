#' Validate inputs for calc_cohort_weights
#'
#' @noRd
validate_cohort_weight_inputs <- function(
    cohort_short,
    live_weight_female_adult, live_weight_male_adult,
    live_weight_at_birth,
    live_weight_female_at_slaughter, live_weight_male_at_slaughter,
    live_weight_at_weaning
) {
  # Character inputs
  validate_scalar_character(cohort_short, "cohort_short")

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
    if (!is.na(val) && (!is.numeric(val) || length(val) != 1)) {
      cli::cli_abort("{.arg {arg_name}} must be a single numeric (scalar). NA is allowed.")
    }
  }

  # Cohort-specific required inputs (non-NA)
  validate_cohort_code(cohort_short)

  required_by_cohort <- switch(
    cohort_short,
    "FJ" = c("live_weight_at_birth", "live_weight_at_weaning", "live_weight_female_adult"),
    "MJ" = c("live_weight_at_birth", "live_weight_at_weaning", "live_weight_male_adult"),
    "FS" = c("live_weight_at_weaning", "live_weight_female_adult", "live_weight_female_at_slaughter"),
    "MS" = c("live_weight_at_weaning", "live_weight_male_adult", "live_weight_male_at_slaughter"),
    "FA" = c("live_weight_female_adult"),
    "MA" = c("live_weight_male_adult")
  )

  missing_required <- required_by_cohort[vapply(
    required_by_cohort,
    function(arg_name) is.na(args[[arg_name]]),
    logical(1)
  )]

  if (length(missing_required) > 0) {
    cli::cli_abort(
      "Missing required weight inputs for cohort {.val {cohort_short}}: {.val {missing_required}}"
    )
  }

  # Enforce configured bounds for cohort-specific required params only
  for (arg_name in required_by_cohort) {
    validate_param_range(args[[arg_name]], arg_name)
  }

  # Birth weight must be strictly below weaning weight when both are provided
  if (!is.na(live_weight_at_birth) && !is.na(live_weight_at_weaning) && live_weight_at_birth >= live_weight_at_weaning) {
    cli::cli_abort(
      "{.arg live_weight_at_birth} must be strictly less than {.arg live_weight_at_weaning}."
    )
  }
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
  validate_scalar_numeric(live_weight_cohort_initial, "live_weight_cohort_initial")
  validate_scalar_numeric(live_weight_cohort_potential_final, "live_weight_cohort_potential_final")
  validate_scalar_numeric(live_weight_cohort_at_slaughter, "live_weight_cohort_at_slaughter")
  validate_scalar_numeric(offtake_rate, "offtake_rate")

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
  validate_scalar_numeric(live_weight_cohort_potential_final, "live_weight_cohort_potential_final")
  validate_scalar_numeric(live_weight_cohort_initial, "live_weight_cohort_initial")
  validate_scalar_numeric(cohort_duration_days, "cohort_duration_days")

  # Enforce configured bounds
  validate_param_range(cohort_duration_days)
}
