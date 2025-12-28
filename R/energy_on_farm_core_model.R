#' On-Farm Energy Emissions Calculation
#'
#' Converts energy consumption values into emissions by applying country-specific factors and unit conversion.
#' The formula used is:
#'
#' \deqn{emissions = energy\_onfarm \times emission\_factor / 1000}
#'
#' where the division by 1000 converts from grams to kilograms CO2-equivalent.
#'
#' @param energy_onfarm Numeric scalar. Energy consumption value (MJ or equivalent).
#' @param emission_factor Numeric scalar. Emission factor per unit energy (g CO2-eq per unit energy).
#'
#' @return Numeric scalar. Emissions in kilograms CO2-equivalent.
#' @export
calc_on_farm_emissions <- function(
    energy_onfarm,
    emission_factor
) {
  validate_onfarm_emission_inputs(energy_onfarm, emission_factor)

  emissions <- energy_onfarm * emission_factor / 1000

  return(emissions)
}
