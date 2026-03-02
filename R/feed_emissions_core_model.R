#' Calculate diet Carbon dioxide (CO₂) from fertilizer used for feed production
#'
#' Computes the weighted contribution of Carbon dioxide (CO₂) emissions from fertilizer use
#' associated with feed production for a feed ration component.
#'
#' @param feed_ration_fraction Numeric. Proportion of a specific feed item in the total ration, expressed as its fraction of diet dry matter (fraction). Within each herd_id and cohort, proportions should sum to 1.
#' @param co2_feed_fertilizer Numeric. Carbon dioxide (CO₂) emission factor from fertilizer use in feed production, calculated per kg of dry matter intake (g CO₂/kg DM).
#'
#' @return Numeric. Average carbon dioxide (CO₂) emission factor from fertilizer use in feed production of the diet (g CO₂/kg DM).
#'
#' @details
#' The contribution is computed as:
#' 
#' \deqn{diet\_co2\_feed\_fertilizer = feed\_ration\_fraction \times co2\_feed\_fertilizer}
#' @export
#'
calc_diet_co2_feed_fertilizer <- function(feed_ration_fraction, co2_feed_fertilizer) {
  validate_diet_co2_feed_fertilizer_inputs(feed_ration_fraction, co2_feed_fertilizer)
  feed_ration_fraction * co2_feed_fertilizer
}

#' Calculate diet Carbon dioxide (CO₂) from pesticide used for feed production
#'
#' Computes the weighted contribution of Carbon dioxide (CO₂) emissions from pesticide use
#' associated with feed production for a feed ration component.
#'
#' @param feed_ration_fraction Numeric. Proportion of a specific feed item in the total ration, expressed as its fraction of diet dry matter (fraction). Within each herd_id and cohort, proportions should sum to 1.
#' @param co2_feed_pesticides Numeric. Carbon dioxide (CO₂) emission factor from pesticide use in feed production, calculated per kg of dry matter intake (g CO₂/kg DM).
#'
#' @return Numeric. Average carbon dioxide (CO₂) emission factor from pesticide use in feed production of the diet (g CO₂/kg DM).
#'
#' @details
#' The contribution is computed as:
#' 
#' \deqn{diet\_co2\_feed\_pesticides = feed\_ration\_fraction \times co2\_feed\_pesticides}
#'
#' @export
calc_diet_co2_feed_pesticides <- function(feed_ration_fraction, co2_feed_pesticides) {
  validate_diet_co2_feed_pesticides_inputs(feed_ration_fraction, co2_feed_pesticides)
  feed_ration_fraction * co2_feed_pesticides
}


#' Calculate diet Carbon dioxide (CO₂) from crop operations for feed production
#'
#' Computes the weighted contribution of Carbon dioxide (CO₂) emissions from crop operations
#' (e.g., machinery use, on-field energy use) associated with feed production for a feed ration component.
#'
#' @param feed_ration_fraction Numeric. Proportion of a specific feed item in the total ration, expressed as its fraction of diet dry matter (fraction). Within each herd_id and cohort, proportions should sum to 1.
#' @param co2_feed_crop_operations Numeric. Carbon dioxide (CO₂) emission factor from crop operations in feed production, calculated per kg of dry matter intake (g CO₂/kg DM).
#'
#' @return Numeric. Average carbon dioxide (CO₂) emission factor from crop operations in feed production of the diet (g CO₂/kg DM).
#'
#' @details
#' The contribution is computed as:
#' 
#' \deqn{diet\_co2\_feed\_crop\_operations =
#'   feed\_ration\_fraction \times co2\_feed\_crop\_operations}
#'
#' @export
calc_diet_co2_feed_crop_operations <- function(feed_ration_fraction, co2_feed_crop_operations) {
  validate_diet_co2_feed_crop_operations_inputs(feed_ration_fraction, co2_feed_crop_operations)
  feed_ration_fraction * co2_feed_crop_operations
}


#' Calculate diet Carbon dioxide (CO₂) from land-use change (no peat) for feed production
#'
#' Computes the weighted contribution of Carbon dioxide (CO₂) emissions from land-use change
#' excluding peatland conversion associated with feed production for a feed ration component.
#'
#' @param feed_ration_fraction Numeric. Proportion of a specific feed item in the total ration, expressed as its fraction of diet dry matter (fraction). Within each herd_id and cohort, proportions should sum to 1.
#' @param co2_feed_luc_nopeat Numeric. Carbon dioxide (CO₂) emission factor from land-use change excluding peat in feed production, calculated per kg of dry matter intake (g CO₂/kg DM).
#'
#' @return Numeric. Average carbon dioxide (CO₂) emission factor from land-use change excluding peat in feed production of the diet (g CO₂/kg DM).
#'
#' @details
#' The contribution is computed as:
#' 
#' \deqn{diet\_co2\_feed\_luc\_nopeat = feed\_ration\_fraction \times co2\_feed\_luc\_nopeat}
#'
#' @export
calc_diet_co2_feed_luc_nopeat <- function(feed_ration_fraction, co2_feed_luc_nopeat) {
  validate_diet_co2_feed_luc_nopeat_inputs(feed_ration_fraction, co2_feed_luc_nopeat)
  feed_ration_fraction * co2_feed_luc_nopeat
}


#' Calculate diet Carbon dioxide (CO₂) from land-use change (peat) for feed production
#'
#' Computes the weighted contribution of Carbon dioxide (CO₂) emissions from peatland conversion
#' associated with feed production for a feed ration component.
#'
#' @param feed_ration_fraction Numeric. Proportion of a specific feed item in the total ration, expressed as its fraction of diet dry matter (fraction). Within each herd_id and cohort, proportions should sum to 1.
#' @param co2_feed_luc_peat Numeric. Carbon dioxide (CO₂) emission factor from peatland land-use change in feed production, calculated per kg of dry matter intake (g CO₂/kg DM).
#'
#' @return Numeric. Average carbon dioxide (CO₂) emission factor from peatland land-use change in feed production of the diet (g CO₂/kg DM).
#'
#' @details
#' The contribution is computed as:
#' 
#' \deqn{diet\_co2\_feed\_luc\_peat = feed\_ration\_fraction \times co2\_feed\_luc\_peat}
#'
#' @export
calc_diet_co2_feed_luc_peat <- function(feed_ration_fraction, co2_feed_luc_peat) {
  validate_diet_co2_feed_luc_peat_inputs(feed_ration_fraction, co2_feed_luc_peat)
  feed_ration_fraction * co2_feed_luc_peat
}


#' Calculate diet nitrous oxide (N₂O) from fertilizer use for feed production
#'
#' Computes the weighted contribution of nitrous oxide (N₂O) emissions from fertilizer application
#' associated with feed production for a feed ration component.
#'
#' @param feed_ration_fraction Numeric. Proportion of a specific feed item in the total ration, expressed as its fraction of diet dry matter (fraction). Within each herd_id and cohort, proportions should sum to 1.
#' @param n2o_feed_fertilizer Numeric. Nitrous oxide (N₂O) emission factor from fertilizer use in feed production, calculated per kg of dry matter intake (g N₂O/kg DM).
#'
#' @return Numeric. Average nitrous oxide (N₂O) emission factor from fertilizer use in feed production of the diet (g N₂O/kg DM).
#'
#' @details
#' The contribution is computed as:
#' 
#' \deqn{diet\_n2o\_feed\_fertilizer = feed\_ration\_fraction \times n2o\_feed\_fertilizer}
#'
#' @export
calc_diet_n2o_feed_fertilizer <- function(feed_ration_fraction, n2o_feed_fertilizer) {
  validate_diet_n2o_feed_fertilizer_inputs(feed_ration_fraction, n2o_feed_fertilizer)
  feed_ration_fraction * n2o_feed_fertilizer
}


#' Calculate diet nitrous oxide (N₂O) from manure application for feed production
#'
#' Computes the weighted contribution of N2O emissions from manure applied to cropland
#' associated with feed production for a feed ration component.
#'
#' @param feed_ration_fraction Numeric. Proportion of a specific feed item in the total ration, expressed as its fraction of diet dry matter (fraction). Within each herd_id and cohort, proportions should sum to 1.
#' @param n2o_feed_manure_applied Numeric. Nitrous oxide (N₂O) emission factor from manure applied to cropland in feed production, calculated per kg of dry matter intake (g N₂O/kg DM).
#'
#' @return Numeric. Average nitrous oxide (N₂O) emission factor from manure applied to cropland in feed production of the diet (g N₂O/kg DM).
#'
#' @details
#' The contribution is computed as:
#' 
#' \deqn{diet\_n2o\_feed\_manure\_applied =
#'   feed\_ration\_fraction \times n2o\_feed\_manure\_applied}
#'
#' @export
calc_diet_n2o_feed_manure_applied <- function(feed_ration_fraction, n2o_feed_manure_applied) {
  validate_diet_n2o_feed_manure_applied_inputs(feed_ration_fraction, n2o_feed_manure_applied)
  feed_ration_fraction * n2o_feed_manure_applied
}


#' Calculate diet Nitrous oxide (N₂O) from crop residues for feed production
#'
#' Computes the weighted contribution of Nitrous oxide (N₂O) emissions from crop residues returned
#' to fields associated with feed production for a feed ration component.
#'
#' @param feed_ration_fraction Numeric. Proportion of a specific feed item in the total ration, expressed as its fraction of diet dry matter (fraction). Within each herd_id and cohort, proportions should sum to 1.
#' @param n2o_feed_crop_residues Numeric. Nitrous oxide (N₂O) emission factor from crop residues in feed production, calculated per kg of dry matter intake (g N₂O/kg DM).
#'
#' @return Numeric. Average nitrous oxide (N₂O) emission factor from crop residues in feed production of the diet (g N₂O/kg DM).
#'
#' @details
#' The contribution is computed as:
#' 
#' \deqn{diet\_n2o\_feed\_crop\_residues =
#'   feed\_ration\_fraction \times n2o\_feed\_crop\_residues}
#'
#' @export
calc_diet_n2o_feed_crop_residues <- function(feed_ration_fraction, n2o_feed_crop_residues) {
  validate_diet_n2o_feed_crop_residues_inputs(feed_ration_fraction, n2o_feed_crop_residues)
  feed_ration_fraction * n2o_feed_crop_residues
}


#' Calculate diet Methane (CH₄) from rice cultivation for feed production
#'
#' Computes the weighted contribution of Methane (CH₄) emissions from flooded rice cultivation
#' associated with feed production for a feed ration component.
#'
#' @param feed_ration_fraction Numeric. Proportion of a specific feed item in the total ration, expressed as its fraction of diet dry matter (fraction). Within each herd_id and cohort, proportions should sum to 1.
#' @param ch4_feed_rice Numeric. Methane (CH₄) emission factor from rice cultivation in feed production, calculated per kg of dry matter intake (g CH₄/kg DM).
#'
#' @return Numeric. Average methane (CH₄) emission factor from rice cultivation in feed production of the diet (g CH₄/kg DM).
#'
#' @details
#' The contribution is computed as:
#' 
#' \deqn{diet\_ch4\_feed\_rice = feed\_ration\_fraction \times ch4\_feed\_rice}
#'
#' @export
calc_diet_ch4_feed_rice <- function(feed_ration_fraction, ch4_feed_rice) {
  validate_diet_ch4_feed_rice_inputs(feed_ration_fraction, ch4_feed_rice)
  feed_ration_fraction * ch4_feed_rice
}