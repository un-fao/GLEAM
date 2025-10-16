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
  validate_scalar_character(animal, "animal")
  validate_scalar_character(cohort, "cohort")
  validate_scalar_numeric(diet_dig, "diet_dig")

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
#'   - `afc` must be a non-negative numeric scalar (days).
#'
#' This validator is designed for internal use in
#' [compute_daily_enteric_emissions()].
#'
#' @noRd
validate_enteric_emission_inputs <- function(
    animal,
    cohort,
    ym,
    diet_ge,
    dmi,
    afc
) {
  validate_scalar_character(animal, "animal")
  validate_scalar_character(cohort, "cohort")

  # Special case: chickens always return NA for now
  if (animal == "CHK") {
    return(invisible(TRUE))
  }

  validate_scalar_numeric(ym, "ym")
  validate_scalar_numeric(diet_ge, "diet_ge")
  validate_scalar_numeric(dmi, "dmi")
  validate_scalar_numeric(afc, "afc")

  # Minimal, generic bounds
  if (ym < 0) {
    cli::cli_abort("{.arg ym} must be a non-negative percentage.")
  }
  if (diet_ge <= 0) {
    cli::cli_abort("{.arg diet_ge} must be strictly positive (MJ/kg DM).")
  }
  if (dmi < 0) {
    cli::cli_abort("{.arg dmi} must be non-negative (kg DM/head/day).")
  }
  if (afc < 0) {
    cli::cli_abort("{.arg afc} must be non-negative (days).")
  }
}
