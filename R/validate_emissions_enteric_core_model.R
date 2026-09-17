#' Validate inputs for calc_conversion_factor_ym
#'
#' Ensures that inputs for the methane conversion factor (YM) calculation
#' are correctly typed and within valid ranges. Specifically:
#' * `species_short` and `cohort_short` must be scalar characters.
#' * `ration_digestibility_fraction` must be a scalar numeric between 0 and 1 (fraction of GE).
#'
#' This validator is designed for internal use in
#' [calc_conversion_factor_ym()].
#'
#' @noRd
validate_ym_inputs <- function(
    species_short,
    cohort_short,
    ration_digestibility_fraction
) {
  if (!validation_enabled()) return(invisible(NULL))
  validate_scalar_character(species_short)
  validate_scalar_character(cohort_short)
  validate_param_range(ration_digestibility_fraction, species_filter = species_short, cohort_filter = cohort_short)
}

#' Validate inputs for calc_ch4_enteric
#'
#' Ensures that inputs for the daily enteric methane emissions calculation
#' are valid. Specifically:
#' * `species_short` must be a scalar character.
#' * Numeric parameters are validated against
#'   \code{parameter_rules} (ch4_conversion_factor_ym, ch4_mitigation_factor,
#'   ration_gross_energy, ration_intake).
#'
#' This validator is designed for internal use in
#' [calc_ch4_enteric()].
#'
#' @noRd
validate_enteric_emission_inputs <- function(
    species_short,
    ch4_conversion_factor_ym,
    ch4_mitigation_factor,
    ration_gross_energy,
    ration_intake
) {
  if (!validation_enabled()) return(invisible(NULL))
  validate_scalar_character(species_short)
  validate_param_range(ch4_conversion_factor_ym, species_filter = species_short)
  validate_param_range(ch4_mitigation_factor, species_filter = species_short)
  validate_param_range(ration_gross_energy, species_filter = species_short)
  validate_param_range(ration_intake, species_filter = species_short)
}
