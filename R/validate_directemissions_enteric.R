#' Validate inputs for compute_methane_conversion_factor
#'
#' Ensures that inputs for the methane conversion factor (YM) calculation
#' are correctly typed and within valid ranges. Specifically:
#' * `species_short` and `cohort_short` must be scalar characters.
#' * `diet_digestibility_fraction` must be a scalar numeric between 0 and 1 (fraction of GE).
#'
#' This validator is designed for internal use in
#' [compute_methane_conversion_factor()].
#'
#' @noRd
validate_ym_inputs <- function(
    species_short,
    cohort_short,
    diet_digestibility_fraction
) {
  validate_scalar_character(species_short, "species_short")
  validate_scalar_character(cohort_short, "cohort_short")
  validate_scalar_numeric(diet_digestibility_fraction, "diet_digestibility_fraction")

  # Basic bounds consistent with a digestibility fraction (0–1)
  if (diet_digestibility_fraction < 0 || diet_digestibility_fraction > 1) {
    cli::cli_abort(
      "{.arg diet_digestibility_fraction} must be between 0 and 1 (fraction of GE)."
    )
  }
}

#' Validate inputs for compute_daily_enteric_emissions
#'
#' Ensures that inputs for the daily enteric methane emissions calculation
#' are valid. Specifically:
#' * `species_short` must be a scalar character.
#' * For chickens (`CHK`), YM is always `NA` and validation is skipped.
#' * For other species:
#'   - `ch4_conversion_factor_ym` must be a non-negative numeric scalar (percentage).
#'   - `diet_gross_energy` must be a strictly positive numeric scalar (MJ/kg DM).
#'   - `dry_matter_intake` must be a non-negative numeric scalar (kg DM/head/day).
#'
#' This validator is designed for internal use in
#' [compute_daily_enteric_emissions()].
#'
#' @noRd
validate_enteric_emission_inputs <- function(
    species_short,
    ch4_conversion_factor_ym,
    ch4_mitigation_factor,
    diet_gross_energy,
    dry_matter_intake
) {
  validate_scalar_character(species_short, "species_short")

  # Special case: chickens always return NA for now
  if (species_short == "CHK") {
    return(invisible(TRUE))
  }

  validate_scalar_numeric(ch4_conversion_factor_ym, "ch4_conversion_factor_ym")
  validate_scalar_numeric(diet_gross_energy, "diet_gross_energy")
  validate_scalar_numeric(dry_matter_intake, "dry_matter_intake")
  validate_scalar_numeric(ch4_mitigation_factor, "ch4_mitigation_factor")

  # Minimal, generic bounds
  if (ch4_conversion_factor_ym < 0) {
    cli::cli_abort(
      "{.arg ch4_conversion_factor_ym} must be a non-negative percentage."
    )
  }
  if (ch4_mitigation_factor < 0 || ch4_mitigation_factor > 1) {
    cli::cli_abort("{.arg ch4_mitigation_factor} must be between 0 and 1.")
  }
  if (diet_gross_energy <= 0) {
    cli::cli_abort(
      "{.arg diet_gross_energy} must be strictly positive (MJ/kg DM)."
    )
  }
  if (dry_matter_intake < 0) {
    cli::cli_abort(
      "{.arg dry_matter_intake} must be non-negative (kg DM/head/day)."
    )
  }
}
