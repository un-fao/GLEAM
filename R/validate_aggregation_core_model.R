#' Validate inputs for calc_totals_by_cohort
#'
#' Ensures that inputs for the cohort totals calculation are correctly typed
#' and within valid ranges. Specifically:
#' * All numeric inputs must be numeric vectors of the same length.
#' * `value` must be non-negative.
#' * `cohort_stock_size` must be positive (number of heads).
#' * `simulation_duration` must be positive (days).
#' * `variable_type` must be a character vector with valid values.
#'
#' Valid variable types: `"Production"`, `"Emissions"`, `"Feed"`, `"NitrogenBalance"`.
#'
#' This validator is designed for internal use in [calc_totals_by_cohort()].
#'
#' @param value Numeric vector. Variable value (kg/head/day or kg/cohort/assessment duration).
#' @param cohort_stock_size Numeric vector. Number of heads in the cohort.
#' @param simulation_duration Numeric vector. Duration of the assessment (days).
#' @param variable_type Character vector. Variable group classification.
#'
#' @noRd
validate_totals_by_cohort_inputs <- function(
    value,
    cohort_stock_size,
    simulation_duration,
    variable_type
) {
  # Check that all inputs are vectors of the same length
  lengths <- c(
    length(value),
    length(cohort_stock_size),
    length(simulation_duration),
    length(variable_type)
  )

  if (length(unique(lengths)) > 1) {
    cli::cli_abort(
      "All inputs to {.fun calc_totals_by_cohort} must have the same length."
    )
  }

  # Validate numeric inputs
  if (!is.numeric(value)) {
    cli::cli_abort("{.arg value} must be numeric.")
  }
  if (!is.numeric(cohort_stock_size)) {
    cli::cli_abort("{.arg cohort_stock_size} must be numeric.")
  }
  if (!is.numeric(simulation_duration)) {
    cli::cli_abort("{.arg simulation_duration} must be numeric.")
  }

  # Validate variable_type
  if (!is.character(variable_type)) {
    cli::cli_abort("{.arg variable_type} must be character.")
  }

  # Validate bounds
  if (any(value < 0)) {
    cli::cli_abort("{.arg value} must be non-negative.")
  }
  if (any(cohort_stock_size <= 0)) {
    cli::cli_abort("{.arg cohort_stock_size} must be positive.")
  }
  if (any(simulation_duration <= 0)) {
    cli::cli_abort("{.arg simulation_duration} must be positive.")
  }

  # Validate variable_type values
  valid_types <- c("Production", "Emissions", "Feed", "NitrogenBalance")
  invalid_types <- setdiff(unique(variable_type), valid_types)
  if (length(invalid_types) > 0) {
    cli::cli_abort(
      "{.arg variable_type} must be one of: {cli::format_inline('{valid_types}')}. Found invalid values: {cli::format_inline('{invalid_types}')}"
    )
  }
}


#' Validate inputs for calc_allocated_emissions
#'
#' Ensures that inputs for the allocated emissions calculation are correctly
#' typed and within valid ranges. Specifically:
#' * Both inputs must be numeric vectors of the same length.
#' * `value` must be non-negative (emissions in kg gas).
#' * `allocation_share` must be between 0 and 1.
#'
#' This validator is designed for internal use in [calc_allocated_emissions()].
#'
#' @param value Numeric vector. Total emissions at herd-level by source (kg gas).
#' @param allocation_share Numeric vector. Fraction of emissions to allocate
#'   to different commodities (between 0 and 1).
#'
#' @noRd
validate_allocated_emissions_inputs <- function(
    value,
    allocation_share
) {
  # Check that inputs have the same length
  if (length(value) != length(allocation_share)) {
    cli::cli_abort(
      "{.arg value} and {.arg allocation_share} must have the same length."
    )
  }

  # Validate numeric inputs
  if (!is.numeric(value)) {
    cli::cli_abort("{.arg value} must be numeric.")
  }
  if (!is.numeric(allocation_share)) {
    cli::cli_abort("{.arg allocation_share} must be numeric.")
  }

  # Validate bounds
  if (any(value < 0)) {
    cli::cli_abort("{.arg value} must be non-negative.")
  }
  if (any(allocation_share < 0 | allocation_share > 1)) {
    cli::cli_abort("{.arg allocation_share} must be between 0 and 1.")
  }
}


#' Validate inputs for calc_co2eq
#'
#' Ensures that inputs for the CO2-equivalent conversion are correctly typed
#' and within valid ranges. Specifically:
#' * `gas` must be a character vector with valid gas types.
#' * `value_allocated` must be a numeric vector of the same length as `gas`.
#' * `gwp` must be a scalar character with a valid GWP version.
#' * `value_allocated` must be non-negative.
#'
#' Valid gas types: `"CH4"`, `"N2O"`, `"CO2"`.
#' Valid GWP versions: `"AR6"`, `"AR5_excluding_carbon_feedback"`,
#' `"AR5_including_carbon_feedback"`, `"AR4"`.
#'
#' This validator is designed for internal use in [calc_co2eq()].
#'
#' @param gas Character vector. Gas type for each observation.
#' @param value_allocated Numeric vector. Emission values (kg gas).
#' @param gwp Character scalar. IPCC assessment report version.
#'
#' @noRd
validate_co2eq_inputs <- function(
    gas,
    value_allocated,
    global_warming_potential_set
) {
  # Validate gwp is scalar character
  validate_scalar_character(global_warming_potential_set, "global_warming_potential_set")

  # Validate GWP version
  valid_gwp <- c(
    "AR6",
    "AR5_excluding_carbon_feedback",
    "AR5_including_carbon_feedback",
    "AR4"
  )
  if (!global_warming_potential_set %in% valid_gwp) {
    cli::cli_abort(
      "{.arg global_warming_potential_set} must be one of: {cli::format_inline('{valid_gwp}')}"
    )
  }

  # Check that gas and value_allocated have the same length
  if (length(gas) != length(value_allocated)) {
    cli::cli_abort(
      "{.arg gas} and {.arg value_allocated} must have the same length."
    )
  }

  # Validate gas types
  if (!is.character(gas)) {
    cli::cli_abort("{.arg gas} must be character.")
  }

  valid_gases <- c("CH4", "N2O", "CO2")
  invalid_gases <- setdiff(unique(gas), valid_gases)
  if (length(invalid_gases) > 0) {
    cli::cli_abort(
      "{.arg gas} must be one of: {cli::format_inline('{valid_gases}')}. Found invalid values: {cli::format_inline('{invalid_gases}')}"
    )
  }

  # Validate value_allocated
  if (!is.numeric(value_allocated)) {
    cli::cli_abort("{.arg value_allocated} must be numeric.")
  }
  if (any(value_allocated < 0)) {
    cli::cli_abort("{.arg value_allocated} must be non-negative.")
  }
}
