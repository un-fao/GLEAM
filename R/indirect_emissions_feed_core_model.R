#' Calculate diet CO2 from fertilizer use (feed production)
#'
#' Computes the weighted contribution of CO2 emissions from fertilizer use
#' associated with feed production for a ration component.
#'
#' @param feed_ration_fraction Numeric. Fraction of the total ration represented
#'   by this feed component (unitless, typically sums to 1 across feeds).
#' @param co2_feed_fertilizer Numeric. Emission factor for CO2 from fertilizer
#'   use in feed production (e.g., kg CO2 per kg DM of feed).
#'
#' @return Numeric. CO2 contribution from fertilizer by feed item
#'   (same units as `co2_feed_fertilizer`).
#'
#' @details
#' The contribution is computed as:
#' \deqn{diet\_co2\_feed\_fertilizer = feed\_ration\_fraction \times co2\_feed\_fertilizer}
#'#' @export
#'
calc_diet_co2_feed_fertilizer <- function(feed_ration_fraction, co2_feed_fertilizer) {
  validate_diet_co2_feed_fertilizer_inputs(feed_ration_fraction, co2_feed_fertilizer)
  feed_ration_fraction * co2_feed_fertilizer
}

#' Calculate diet CO2 from pesticide use (feed production)
#'
#' Computes the weighted contribution of CO2 emissions from pesticide use
#' associated with feed production for a ration component.
#'
#' @param feed_ration_fraction Numeric. Fraction of the total ration represented
#'   by this feed component (unitless).
#' @param co2_feed_pesticides Numeric. Emission factor for CO2 from pesticide use
#'   in feed production (e.g., kg CO2 per kg DM of feed).
#'
#' @return Numeric. CO2 contribution from pesticides for this feed item.
#'
#' @details
#' \deqn{diet\_co2\_feed\_pesticides = feed\_ration\_fraction \times co2\_feed\_pesticides}
#'
#' This helper is vectorized over its inputs.
#'
#' @export
calc_diet_co2_feed_pesticides <- function(feed_ration_fraction, co2_feed_pesticides) {
  validate_diet_co2_feed_pesticides_inputs(feed_ration_fraction, co2_feed_pesticides)
  feed_ration_fraction * co2_feed_pesticides
}


#' Calculate diet CO2 from crop operations (feed production)
#'
#' Computes the weighted contribution of CO2 emissions from crop operations
#' (e.g., machinery use, on-field energy use) for feed production.
#'
#' @param feed_ration_fraction Numeric. Fraction of the total ration represented
#'   by this feed component (unitless).
#' @param co2_feed_crop_operations Numeric. Emission factor for CO2 from crop
#'   operations (e.g., kg CO2 per kg DM of feed).
#'
#' @return Numeric. CO2 contribution from crop operations for this feed item.
#'
#' @details
#' \deqn{diet\_co2\_feed\_crop\_operations =
#'   feed\_ration\_fraction \times co2\_feed\_crop\_operations}
#'
#' This helper is vectorized over its inputs.
#'
#' @export
calc_diet_co2_feed_crop_operations <- function(feed_ration_fraction, co2_feed_crop_operations) {
  validate_diet_co2_feed_crop_operations_inputs(feed_ration_fraction, co2_feed_crop_operations)
  feed_ration_fraction * co2_feed_crop_operations
}


#' Calculate diet CO2 from land-use change (no peat) for feed production
#'
#' Computes the weighted contribution of CO2 emissions from land-use change
#' excluding peatland conversion associated with feed production.
#'
#' @param feed_ration_fraction Numeric. Fraction of the total ration represented
#'   by this feed component (unitless).
#' @param co2_feed_luc_nopeat Numeric. Emission factor for CO2 from land-use change
#'   excluding peat (e.g., kg CO2 per kg DM of feed).
#'
#' @return Numeric. CO2 contribution from LUC (no peat) for this feed item.
#'
#' @details
#' \deqn{diet\_co2\_feed\_luc\_nopeat = feed\_ration\_fraction \times co2\_feed\_luc\_nopeat}
#'
#' This helper is vectorized over its inputs.
#'
#' @export
calc_diet_co2_feed_luc_nopeat <- function(feed_ration_fraction, co2_feed_luc_nopeat) {
  validate_diet_co2_feed_luc_nopeat_inputs(feed_ration_fraction, co2_feed_luc_nopeat)
  feed_ration_fraction * co2_feed_luc_nopeat
}


#' Calculate diet CO2 from land-use change (peat) for feed production
#'
#' Computes the weighted contribution of CO2 emissions from peatland conversion
#' associated with feed production.
#'
#' @param feed_ration_fraction Numeric. Fraction of the total ration represented
#'   by this feed component (unitless).
#' @param co2_feed_luc_peat Numeric. Emission factor for CO2 from peatland-related
#'   land-use change (e.g., kg CO2 per kg DM of feed).
#'
#' @return Numeric. CO2 contribution from LUC (peat) for this feed item.
#'
#' @details
#' \deqn{diet\_co2\_feed\_luc\_peat = feed\_ration\_fraction \times co2\_feed\_luc\_peat}
#'
#' This helper is vectorized over its inputs.
#'
#' @export
calc_diet_co2_feed_luc_peat <- function(feed_ration_fraction, co2_feed_luc_peat) {
  validate_diet_co2_feed_luc_peat_inputs(feed_ration_fraction, co2_feed_luc_peat)
  feed_ration_fraction * co2_feed_luc_peat
}


#' Calculate diet N2O from fertilizer use (feed production)
#'
#' Computes the weighted contribution of N2O emissions from fertilizer application
#' associated with feed production.
#'
#' @param feed_ration_fraction Numeric. Fraction of the total ration represented
#'   by this feed component (unitless).
#' @param n2o_feed_fertilizer Numeric. Emission factor for N2O from fertilizer use
#'   in feed production (e.g., kg N2O per kg DM of feed).
#'
#' @return Numeric. N2O contribution from fertilizer for this feed item.
#'
#' @details
#' \deqn{diet\_n2o\_feed\_fertilizer = feed\_ration\_fraction \times n2o\_feed\_fertilizer}
#'
#' This helper is vectorized over its inputs.
#'
#' @export
calc_diet_n2o_feed_fertilizer <- function(feed_ration_fraction, n2o_feed_fertilizer) {
  validate_diet_n2o_feed_fertilizer_inputs(feed_ration_fraction, n2o_feed_fertilizer)
  feed_ration_fraction * n2o_feed_fertilizer
}


#' Calculate diet N2O from manure application (feed production)
#'
#' Computes the weighted contribution of N2O emissions from manure applied to cropland
#' associated with feed production.
#'
#' @param feed_ration_fraction Numeric. Fraction of the total ration represented
#'   by this feed component (unitless).
#' @param n2o_feed_manure_applied Numeric. Emission factor for N2O from manure
#'   application in feed production (e.g., kg N2O per kg DM of feed).
#'
#' @return Numeric. N2O contribution from manure application for this feed item.
#'
#' @details
#' \deqn{diet\_n2o\_feed\_manure\_applied =
#'   feed\_ration\_fraction \times n2o\_feed\_manure\_applied}
#'
#' This helper is vectorized over its inputs.
#'
#' @export
calc_diet_n2o_feed_manure_applied <- function(feed_ration_fraction, n2o_feed_manure_applied) {
  validate_diet_n2o_feed_manure_applied_inputs(feed_ration_fraction, n2o_feed_manure_applied)
  feed_ration_fraction * n2o_feed_manure_applied
}


#' Calculate diet N2O from crop residues (feed production)
#'
#' Computes the weighted contribution of N2O emissions from crop residues returned
#' to fields associated with feed production.
#'
#' @param feed_ration_fraction Numeric. Fraction of the total ration represented
#'   by this feed component (unitless).
#' @param n2o_feed_crop_residues Numeric. Emission factor for N2O from crop residues
#'   in feed production (e.g., kg N2O per kg DM of feed).
#'
#' @return Numeric. N2O contribution from crop residues for this feed item.
#'
#' @details
#' \deqn{diet\_n2o\_feed\_crop\_residues =
#'   feed\_ration\_fraction \times n2o\_feed\_crop\_residues}
#'
#' This helper is vectorized over its inputs.
#'
#' @export
calc_diet_n2o_feed_crop_residues <- function(feed_ration_fraction, n2o_feed_crop_residues) {
  validate_diet_n2o_feed_crop_residues_inputs(feed_ration_fraction, n2o_feed_crop_residues)
  feed_ration_fraction * n2o_feed_crop_residues
}


#' Calculate diet CH4 from rice cultivation (feed production)
#'
#' Computes the weighted contribution of CH4 emissions from flooded rice cultivation
#' associated with feed production.
#'
#' @param feed_ration_fraction Numeric. Fraction of the total ration represented
#'   by this feed component (unitless).
#' @param ch4_feed_rice Numeric. Emission factor for CH4 from rice cultivation
#'   in feed production (e.g., kg CH4 per kg DM of feed).
#'
#' @return Numeric. CH4 contribution from rice cultivation for this feed item.
#'
#' @details
#' \deqn{diet\_ch4\_feed\_rice = feed\_ration\_fraction \times ch4\_feed\_rice}
#'
#' This helper is vectorized over its inputs.
#'
#' @export
calc_diet_ch4_feed_rice <- function(feed_ration_fraction, ch4_feed_rice) {
  validate_diet_ch4_feed_rice_inputs(feed_ration_fraction, ch4_feed_rice)
  feed_ration_fraction * ch4_feed_rice
}