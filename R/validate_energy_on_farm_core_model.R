#' Validate inputs for calc_onfarm_emissions
#'
#' Ensures that inputs for the on-farm energy emissions calculation
#' are correctly typed and within valid ranges. Specifically:
#' * `energy_onfarm` must be a non-negative numeric scalar.
#' * `emission_factor` must be a non-negative numeric scalar.
#'
#' This validator is designed for internal use in
#' [calc_onfarm_emissions()].
#'
#' @noRd
validate_onfarm_emission_inputs <- function(energy_onfarm, emission_factor) {
  validate_scalar_numeric(energy_onfarm, "energy_onfarm")
  validate_scalar_numeric(emission_factor, "emission_factor")

  # Basic bounds: both values must be non-negative
  if (energy_onfarm < 0) {
    cli::cli_abort("{.arg energy_onfarm} must be non-negative.")
  }
  if (emission_factor < 0) {
    cli::cli_abort("{.arg emission_factor} must be non-negative.")
  }
}

