#' Validate inputs for calc_conversion_factor_ym
#'
#' Ensures that inputs for the methane conversion factor (YM) calculation
#' are correctly typed and within valid ranges. Specifically:
#' * `species_short` and `cohort_short` must be scalar characters.
#' * `diet_digestibility_fraction` must be a scalar numeric between 0 and 1 (fraction of GE).
#'
#' This validator is designed for internal use in
#' [calc_conversion_factor_ym()].
#'
#' @noRd
validate_ym_inputs <- function(
    species_short,
    cohort_short,
    diet_digestibility_fraction
) {
  validate_scalar_character(species_short, "species_short")
  validate_scalar_character(cohort_short, "cohort_short")
  validate_param_range(diet_digestibility_fraction, "diet_digestibility_fraction")
}

#' Validate inputs for calc_ch4_enteric
#'
#' Ensures that inputs for the daily enteric methane emissions calculation
#' are valid. Specifically:
#' * `species_short` must be a scalar character.
#' * For chickens (`CHK`), YM is always `NA` and validation is skipped.
#' * For other species, numeric parameters are validated against
#'   \code{parameter_ranges} (ch4_conversion_factor_ym, ch4_mitigation_factor,
#'   diet_gross_energy, dry_matter_intake).
#'
#' This validator is designed for internal use in
#' [calc_ch4_enteric()].
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
    return()
  }

  validate_param_range(ch4_conversion_factor_ym, "ch4_conversion_factor_ym")
  validate_param_range(ch4_mitigation_factor, "ch4_mitigation_factor")
  validate_param_range(diet_gross_energy, "diet_gross_energy")
  validate_param_range(dry_matter_intake, "dry_matter_intake")
}
