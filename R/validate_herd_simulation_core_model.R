#' Validate a scalar numeric input
#'
#' Ensures that the given argument is a single numeric value (length 1, not NA).
#' This function is used throughout the package to enforce minimal type safety
#' for numeric parameters like rates, durations, weights, etc.
#'
#' @param x The object to validate.
#' @param arg_name String. The name of the argument to use in the error message.
#'
#' @keywords internal
validate_scalar_numeric <- function(x, arg_name) {
  # Check if the input is numeric, scalar, and not missing
  if (!is.numeric(x) || length(x) != 1 || is.na(x)) {
    cli::cli_abort("{.arg {arg_name}} must be a single numeric value.")
  }
}

#' Validate a scalar character input
#'
#' Ensures that the input is a single, non-missing character value.
#' This function is typically used to validate identifiers or categorical inputs
#' such as `animal` or `cohort` within model functions.
#'
#' @param x The object to validate.
#' @param arg_name A string. The name of the argument (used in the error message).
#'
#' @keywords internal
validate_scalar_character <- function(x, arg_name) {
  if (!is.character(x) || length(x) != 1 || is.na(x)) {
    cli::cli_abort("{.arg {arg_name}} must be a single character value.")
  }
}

#' Validate that input is a named numeric vector of a given length
#'
#' Used to validate cohort-based vectors like durations, offtake rates, death rates, etc.
#' Validate that input is a named numeric vector of a given length and optional names
#'
#' Used to validate cohort-based vectors like durations, offtake rates, death rates, etc.
#' This version checks type, length, presence of names, and (optionally) required names.
#'
#' @param x The object to validate.
#' @param arg_name String. The argument name for error reporting (not evaluated).
#' @param expected_length Integer. Required length of the vector.
#' @param expected_names Character vector. Optional. Set of required names.
#'
#' @keywords internal
validate_named_numeric_vector <- function(
    x, arg_name, expected_length, expected_names = NULL
) {
  if (!is.numeric(x) || length(x) != expected_length || is.null(names(x))) {
    cli::cli_abort("{.arg {arg_name}} must be a numeric vector of length {expected_length} with names.")
  }

  if (!is.null(expected_names)) {
    if (!setequal(sort(names(x)), sort(expected_names))) {
      cli::cli_abort(
        "{.arg {arg_name}} must have names: {cli::format_inline('{expected_names}')}"
      )
    }
  }
}

#' Validate inputs for compute_fecundity_rates
#'
#' @keywords internal
validate_fecundity_inputs <- function(part_rate, prolif_rate, fem_birth_ratio) {
  validate_scalar_numeric(part_rate, "part_rate")
  validate_scalar_numeric(prolif_rate, "prolif_rate")
  validate_scalar_numeric(fem_birth_ratio, "fem_birth_ratio")
}

#' Validate inputs for compute_transition_probabilities
#'
#' @keywords internal
validate_transition_inputs <- function(duration, offtake_rate, death_rate) {
  validate_named_numeric_vector(duration, "duration", 6)
  validate_named_numeric_vector(offtake_rate, "offtake_rate", 6)
  validate_named_numeric_vector(death_rate, "death_rate", 6)
}

#' Validate inputs for simulate_steady_state_structure
#'
#' @keywords internal
validate_steady_state_inputs <- function(
    initial_structure,
    max_years,
    min_lambda_change,
    fem_fec,
    mal_fec,
    prob_death,
    prob_offtake,
    prob_growth
) {
  # Define expected names
  six_cohort_names <- c("FJ", "FS", "FA", "MJ", "MS", "MA")
  ten_cohort_names <- c("FB", "FJ", "FS", "FA", "FC", "MB", "MJ", "MS", "MA", "MC")

  # Vector inputs with required names
  validate_named_numeric_vector(
    initial_structure, "initial_structure", 6, expected_names = six_cohort_names
  )
  validate_named_numeric_vector(
    prob_death, "prob_death", 10, expected_names = ten_cohort_names
  )
  validate_named_numeric_vector(
    prob_offtake, "prob_offtake", 10, expected_names = ten_cohort_names
  )
  validate_named_numeric_vector(
    prob_growth, "prob_growth", 10, expected_names = ten_cohort_names
  )

  # Scalar numeric inputs
  validate_scalar_numeric(max_years, "max_years")
  validate_scalar_numeric(min_lambda_change, "min_lambda_change")
  validate_scalar_numeric(fem_fec, "fem_fec")
  validate_scalar_numeric(mal_fec, "mal_fec")
}

#' Validate inputs for project_population_size
#'
#' @keywords internal
validate_population_size_inputs <- function(
    size_total,
    fem_fec,
    mal_fec,
    prob_death,
    prob_offtake,
    prob_growth,
    growth_rate_pop,
    structure,
    share
) {
  # Expected cohort names
  six_cohort_names <- c("FJ", "FS", "FA", "MJ", "MS", "MA")
  eight_cohort_names <- c("FB", "FJ", "FS", "FA", "MB", "MJ", "MS", "MA")
  ten_cohort_names <- c("FB", "FJ", "FS", "FA", "FC", "MB", "MJ", "MS", "MA", "MC")

  # Named vector inputs with required names
  validate_named_numeric_vector(
    prob_death, "prob_death", 10, expected_names = ten_cohort_names
  )
  validate_named_numeric_vector(
    prob_offtake, "prob_offtake", 10, expected_names = ten_cohort_names
  )
  validate_named_numeric_vector(
    prob_growth, "prob_growth", 10, expected_names = ten_cohort_names
  )
  validate_named_numeric_vector(
    structure, "structure", 8, expected_names = eight_cohort_names
  )
  validate_named_numeric_vector(
    share, "share", 6, expected_names = six_cohort_names
  )

  # Scalar numeric inputs
  validate_scalar_numeric(size_total, "size_total")
  validate_scalar_numeric(fem_fec, "fem_fec")
  validate_scalar_numeric(mal_fec, "mal_fec")
  validate_scalar_numeric(growth_rate_pop, "growth_rate_pop")
}

#' Validate inputs for summarise_offtake
#'
#' @keywords internal
validate_offtake_summary_inputs <- function(
    size,
    size_end,
    size_avg,
    offtake
) {
  validate_named_numeric_vector(size, "size", 6)
  validate_named_numeric_vector(size_end, "size_end", 6)
  validate_named_numeric_vector(size_avg, "size_avg", 6)
  validate_named_numeric_vector(offtake, "offtake", 10)
}

#' Validate inputs for calc_cohort_weights
#'
#' @keywords internal
validate_cohort_weight_inputs <- function(
    animal, cohort,
    adult_fem_weight, adult_mal_weight,
    birth_weight,
    slaughter_weight_fem, slaughter_weight_mal,
    weaning_weight,
    age_first_calving,
    animal_age
) {
  # Character inputs
  validate_scalar_character(animal, "animal")
  validate_scalar_character(cohort, "cohort")

  # Numeric inputs (allow NA)
  args <- list(
    adult_fem_weight = adult_fem_weight,
    adult_mal_weight = adult_mal_weight,
    birth_weight = birth_weight,
    slaughter_weight_fem = slaughter_weight_fem,
    slaughter_weight_mal = slaughter_weight_mal,
    weaning_weight = weaning_weight,
    age_first_calving = age_first_calving,
    animal_age = animal_age
  )

  for (arg_name in names(args)) {
    val <- args[[arg_name]]
    if (!is.numeric(val) || length(val) != 1) {
      cli::cli_abort("{.arg {arg_name}} must be a single numeric (scalar). NA is allowed.")
    }
  }
}

#' Validate inputs for calc_avg_weights
#'
#' Ensures all arguments are numeric scalars (length 1), allows NA.
#'
#' @keywords internal
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
}

#' Validate inputs for calc_daily_weight_gain
#'
#' Ensures arguments are numeric scalars (length 1), allows NA values.
#'
#' @keywords internal
validate_daily_gain_inputs <- function(
    potential_final_weight,
    initial_weight,
    duration
) {
  validate_scalar_numeric(potential_final_weight, "potential_final_weight")
  validate_scalar_numeric(initial_weight, "initial_weight")
  validate_scalar_numeric(duration, "duration")
}
