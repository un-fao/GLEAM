#' Validate a scalar numeric input
#'
#' Ensures that the given argument is a single numeric value (length 1, not NA).
#' This function is used throughout the package to enforce minimal type safety
#' for numeric parameters like rates, durations, weights, etc.
#'
#' @param x The object to validate.
#' @param arg_name String. The name of the argument to use in the error message.
#'
#' @noRd
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
#' @noRd
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
#' @noRd
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
#' @noRd
validate_fecundity_inputs <- function(
    parturition_rate,
    litter_size,
    birth_fraction_female
) {
  validate_scalar_numeric(parturition_rate, "parturition_rate")
  validate_scalar_numeric(litter_size, "litter_size")
  validate_scalar_numeric(birth_fraction_female, "birth_fraction_female")

  # Enforce configured bounds
  validate_param_range(parturition_rate)
  validate_param_range(litter_size)
  validate_param_range(birth_fraction_female)
}

#' Validate inputs for compute_transition_probabilities
#'
#' @noRd
validate_transition_inputs <- function(
    cohort_duration_days,
    offtake_rate,
    death_rate
) {
  validate_named_numeric_vector(cohort_duration_days, "cohort_duration_days", 6)
  validate_named_numeric_vector(offtake_rate, "offtake_rate", 6)
  validate_named_numeric_vector(death_rate, "death_rate", 6)

  # Enforce configured bounds
  validate_param_range(cohort_duration_days)
  validate_param_range(death_rate)
  validate_param_range(offtake_rate)
}

#' Validate inputs for simulate_steady_state_structure
#'
#' @noRd
validate_steady_state_inputs <- function(
    initial_herd_structure,
    max_simulation_years,
    min_lambda_change,
    fecundity_female,
    fecundity_male,
    probability_death,
    probability_offtake,
    probability_growth
) {
  # Define expected names
  six_cohort_names <- c("FJ", "FS", "FA", "MJ", "MS", "MA")
  ten_cohort_names <- c("FB", "FJ", "FS", "FA", "FC", "MB", "MJ", "MS", "MA", "MC")

  # Vector inputs with required names
  validate_named_numeric_vector(
    initial_herd_structure, "initial_herd_structure", 6, expected_names = six_cohort_names
  )
  validate_named_numeric_vector(
    probability_death, "probability_death", 10, expected_names = ten_cohort_names
  )
  validate_named_numeric_vector(
    probability_offtake, "probability_offtake", 10, expected_names = ten_cohort_names
  )
  validate_named_numeric_vector(
    probability_growth, "probability_growth", 10, expected_names = ten_cohort_names
  )

  # Scalar numeric inputs
  validate_scalar_numeric(max_simulation_years, "max_simulation_years")
  validate_scalar_numeric(min_lambda_change, "min_lambda_change")
  validate_scalar_numeric(fecundity_female, "fecundity_female")
  validate_scalar_numeric(fecundity_male, "fecundity_male")
}

#' Validate inputs for project_population_size
#'
#' @noRd
validate_population_size_inputs <- function(
    herd_size_total,
    fecundity_female,
    fecundity_male,
    probability_death,
    probability_offtake,
    probability_growth,
    growth_rate_herd,
    herd_structure,
    cohort_share
) {
  # Expected cohort names
  six_cohort_names <- c("FJ", "FS", "FA", "MJ", "MS", "MA")
  eight_cohort_names <- c("FB", "FJ", "FS", "FA", "MB", "MJ", "MS", "MA")
  ten_cohort_names <- c("FB", "FJ", "FS", "FA", "FC", "MB", "MJ", "MS", "MA", "MC")

  # Named vector inputs with required names
  validate_named_numeric_vector(
    probability_death, "probability_death", 10, expected_names = ten_cohort_names
  )
  validate_named_numeric_vector(
    probability_offtake, "probability_offtake", 10, expected_names = ten_cohort_names
  )
  validate_named_numeric_vector(
    probability_growth, "probability_growth", 10, expected_names = ten_cohort_names
  )
  validate_named_numeric_vector(
    herd_structure, "herd_structure", 8, expected_names = eight_cohort_names
  )
  validate_named_numeric_vector(
    cohort_share, "cohort_share", 6, expected_names = six_cohort_names
  )

  # Scalar numeric inputs
  validate_scalar_numeric(herd_size_total, "herd_size_total")
  validate_scalar_numeric(fecundity_female, "fecundity_female")
  validate_scalar_numeric(fecundity_male, "fecundity_male")
  validate_scalar_numeric(growth_rate_herd, "growth_rate_herd")

  # Enforce configured bounds
  validate_param_range(herd_size_total)
}

#' Validate inputs for summarise_offtake
#'
#' @noRd
validate_offtake_summary_inputs <- function(
    cohort_stock_start,
    cohort_stock_end_projected,
    cohort_stock_average,
    cohort_offtake_heads,
    simulation_duration
) {
  validate_named_numeric_vector(cohort_stock_start, "cohort_stock_start", 6)
  validate_named_numeric_vector(cohort_stock_end_projected, "cohort_stock_end_projected", 6)
  validate_named_numeric_vector(cohort_stock_average, "cohort_stock_average", 6)
  validate_named_numeric_vector(cohort_offtake_heads, "cohort_offtake_heads", 10)
  validate_scalar_numeric(simulation_duration, "simulation_duration")
}
