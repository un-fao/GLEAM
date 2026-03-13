#' Validate inputs for compute_methane_conversion_factor
#'
#' Ensures that inputs for the methane conversion factor (YM) calculation
#' are correctly typed and within valid ranges. Specifically:
#' * `animal` and `cohort` must be scalar characters.
#' * `diet_dig` must be a scalar numeric between 0 and 1 (fraction of GE).
#'
#' This validator is designed for internal use in
#' [compute_methane_conversion_factor()].
#'
#' @noRd
validate_ym_inputs <- function(
    animal,
    cohort,
    diet_dig
) {
  validate_scalar_character(animal)
  validate_scalar_character(cohort)
  validate_scalar_numeric(diet_dig)

  # Basic bounds consistent with a digestibility fraction (0–1)
  if (diet_dig < 0 || diet_dig > 1) {
    cli::cli_abort("{.arg diet_dig} must be between 0 and 1 (fraction of GE).")
  }
}

#' Validate inputs for compute_daily_enteric_emissions
#'
#' Ensures that inputs for the daily enteric methane emissions calculation
#' are valid. Specifically:
#' * `animal` and `cohort` must be scalar characters.
#' * For chickens (`CHK`), YM is always `NA` and validation is skipped.
#' * For other species:
#'   - `ym` must be a non-negative numeric scalar (percentage).
#'   - `diet_ge` must be a strictly positive numeric scalar (MJ/kg DM).
#'   - `dmi` must be a non-negative numeric scalar (kg DM/head/day).
#'
#' This validator is designed for internal use in
#' [compute_daily_enteric_emissions()].
#'
#' @noRd
validate_enteric_emission_inputs <- function(
    animal,
    ym,
    ch4_mitigation_factor,
    diet_ge,
    dmi
) {
  validate_scalar_character(animal)

  # Special case: chickens always return NA for now
  if (animal == "CHK") {
    return(invisible(TRUE))
  }

  validate_scalar_numeric(ym)
  validate_scalar_numeric(diet_ge)
  validate_scalar_numeric(dmi)
  validate_scalar_numeric(ch4_mitigation_factor)


  # Minimal, generic bounds
  if (ym < 0) {
    cli::cli_abort("{.arg ym} must be a non-negative percentage.")
  }
  if (ch4_mitigation_factor < 0 || ch4_mitigation_factor > 1) {
    cli::cli_abort("{.arg ch4_mitigation_factor} must be between 0 and 1.")
  }
  if (diet_ge <= 0) {
    cli::cli_abort("{.arg diet_ge} must be strictly positive (MJ/kg DM).")
  }
  if (dmi < 0) {
    cli::cli_abort("{.arg dmi} must be non-negative (kg DM/head/day).")
  }
}
