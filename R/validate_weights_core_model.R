#' Validate inputs for calc_cohort_weights
#'
#' @noRd
validate_cohort_weight_inputs <- function(
    cohort_short,
    live_weight_female_adult, live_weight_male_adult,
    birth_weight,
    slaughter_weight_female, slaughter_weight_male,
    weaning_weight
) {
  # Character inputs
  validate_scalar_character(cohort_short, "cohort_short")

  # Numeric inputs (allow NA by default; cohort-specific checks below)
  args <- list(
    live_weight_female_adult = live_weight_female_adult,
    live_weight_male_adult = live_weight_male_adult,
    birth_weight = birth_weight,
    slaughter_weight_female = slaughter_weight_female,
    slaughter_weight_male = slaughter_weight_male,
    weaning_weight = weaning_weight
  )

  for (arg_name in names(args)) {
    val <- args[[arg_name]]
    if (!is.numeric(val) || length(val) != 1) {
      cli::cli_abort("{.arg {arg_name}} must be a single numeric (scalar). NA is allowed.")
    }
  }

  # Cohort-specific required inputs (non-NA)
  valid_cohorts <- c("FJ", "FS", "FA", "MJ", "MS", "MA")
  if (!cohort_short %in% valid_cohorts) {
    cli::cli_abort(
      "Invalid cohort value: {.val {cohort_short}}. Must be one of: {.val {valid_cohorts}}"
    )
  }

  required_by_cohort <- switch(
    cohort_short,
    "FJ" = c("birth_weight", "weaning_weight", "live_weight_female_adult"),
    "MJ" = c("birth_weight", "weaning_weight", "live_weight_male_adult"),
    "FS" = c("weaning_weight", "live_weight_female_adult", "slaughter_weight_female"),
    "MS" = c("weaning_weight", "live_weight_male_adult", "slaughter_weight_male"),
    "FA" = c("live_weight_female_adult"),
    "MA" = c("live_weight_male_adult")
  )

  missing_required <- required_by_cohort[vapply(
    required_by_cohort,
    function(arg_name) isTRUE(is.na(args[[arg_name]])),
    logical(1)
  )]

  if (length(missing_required) > 0) {
    cli::cli_abort(
      "Missing required weight inputs for cohort {.val {cohort_short}}: {.val {missing_required}}"
    )
  }

  # Enforce configured bounds
  validate_param_range(live_weight_female_adult)
  validate_param_range(live_weight_male_adult)
  validate_param_range(birth_weight)
  validate_param_range(slaughter_weight_female)
  validate_param_range(slaughter_weight_male)
  validate_param_range(weaning_weight)

  # Birth weight must be strictly below weaning weight when both are provided
  if (!is.na(birth_weight) && !is.na(weaning_weight) && birth_weight >= weaning_weight) {
    cli::cli_abort(
      "{.arg birth_weight} must be strictly less than {.arg weaning_weight}."
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
    slaughter_weight_cohort,
    offtake_rate
) {
  validate_scalar_numeric(live_weight_cohort_initial, "live_weight_cohort_initial")
  validate_scalar_numeric(live_weight_cohort_potential_final, "live_weight_cohort_potential_final")
  validate_scalar_numeric(slaughter_weight_cohort, "slaughter_weight_cohort")
  validate_scalar_numeric(offtake_rate, "offtake_rate")

  # Enforce configured bounds
  validate_param_range(slaughter_weight_cohort)
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
