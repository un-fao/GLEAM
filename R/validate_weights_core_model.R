#' Validate inputs for calc_cohort_weights
#'
#' @noRd
validate_cohort_weight_inputs <- function(
    cohort,
    adult_fem_weight, adult_mal_weight,
    birth_weight,
    slaughter_weight_fem, slaughter_weight_mal,
    weaning_weight
) {
  # Character inputs
  validate_scalar_character(cohort, "cohort")

  # Numeric inputs (allow NA by default; cohort-specific checks below)
  args <- list(
    adult_fem_weight = adult_fem_weight,
    adult_mal_weight = adult_mal_weight,
    birth_weight = birth_weight,
    slaughter_weight_fem = slaughter_weight_fem,
    slaughter_weight_mal = slaughter_weight_mal,
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
  if (!cohort %in% valid_cohorts) {
    cli::cli_abort(
      "Invalid cohort value: {.val {cohort}}. Must be one of: {.val {valid_cohorts}}"
    )
  }

  required_by_cohort <- switch(
    cohort,
    "FJ" = c("birth_weight", "weaning_weight", "adult_fem_weight"),
    "MJ" = c("birth_weight", "weaning_weight", "adult_mal_weight"),
    "FS" = c("weaning_weight", "adult_fem_weight", "slaughter_weight_fem"),
    "MS" = c("weaning_weight", "adult_mal_weight", "slaughter_weight_mal"),
    "FA" = c("adult_fem_weight"),
    "MA" = c("adult_mal_weight")
  )

  missing_required <- required_by_cohort[vapply(
    required_by_cohort,
    function(arg_name) isTRUE(is.na(args[[arg_name]])),
    logical(1)
  )]

  if (length(missing_required) > 0) {
    cli::cli_abort(
      "Missing required weight inputs for cohort {.val {cohort}}: {.val {missing_required}}"
    )
  }
}

#' Validate inputs for calc_avg_weights
#'
#' Ensures all arguments are numeric scalars (length 1), allows NA.
#'
#' @noRd
validate_avg_weight_inputs <- function(
    initial_weight,
    potential_final_weight,
    slaughter_weight,
    offtake_rate
) {
  validate_scalar_numeric(initial_weight, "initial_weight")
  validate_scalar_numeric(potential_final_weight, "potential_final_weight")
  validate_scalar_numeric(slaughter_weight, "slaughter_weight")
  validate_scalar_numeric(offtake_rate, "offtake_rate")

  # Enforce configured bounds
  validate_param_range(offtake_rate)
}

#' Validate inputs for calc_daily_weight_gain
#'
#' Ensures arguments are numeric scalars (length 1), allows NA values.
#'
#' @noRd
validate_daily_gain_inputs <- function(
    potential_final_weight,
    initial_weight,
    duration
) {
  validate_scalar_numeric(potential_final_weight, "potential_final_weight")
  validate_scalar_numeric(initial_weight, "initial_weight")
  validate_scalar_numeric(duration, "duration")

  # Enforce configured bounds
  validate_param_range(duration)
}
