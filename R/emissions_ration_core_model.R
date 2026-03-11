#' Calculate a ration component's contribution to carbon dioxide (CO₂) emissions from fertilizer manufacture
#'
#' Computes the contribution of an individual feed component to carbon dioxide (CO₂)
#' emissions from fertilizer manufacture in feed production,
#' using feed-specific emission factors weighted by the component's share in the ration.
#'
#' @param feed_ration_fraction Numeric. Proportion of a specific feed component in
#' the total ration, expressed as its fraction of diet dry matter (fraction). Within
#' each herd_id and cohort, proportions should sum to 1.
#' @param co2_feed_fertilizer Numeric. Carbon dioxide (CO₂) emission factor of a
#' feed component, representing CO₂ emissions from fertilizer manufacture in feed
#' production, expressed per kilogram of dry matter intake (g CO₂/kg DM).
#'
#' @return Numeric. Contribution of an individual feed component to the diet-level average
#' carbon dioxide (CO₂) emission factor from fertilizer manufacture in feed production
#' (g CO₂/kg DM).
#'
#' @details
#' The contribution is computed as:
#'
#' \deqn{diet\_co2\_feed\_fertilizer = feed\_ration\_fraction \times co2\_feed\_fertilizer}
#' @export
#'
calc_co2_ration_fertilizer <- function(
    feed_ration_fraction,
    co2_feed_fertilizer
) {
  validate_co2_ration_fertilizer_inputs(feed_ration_fraction, co2_feed_fertilizer)

  co2_ration_fertilizer <- feed_ration_fraction * co2_feed_fertilizer

  return(co2_ration_fertilizer)
}

#' Calculate a ration component's contribution to carbon dioxide (CO₂) emissions from pesticide manufacture
#'
#' Computes the contribution of an individual feed component to carbon dioxide (CO₂)
#' emissions from pesticide manufacture in feed production,
#' using feed-specific emission factors weighted by the component's share in the ration.
#'
#' @param feed_ration_fraction Numeric. Proportion of a specific feed component in the total
#' ration, expressed as its fraction of diet dry matter intake (fraction). Within
#' each herd_id and cohort, proportions should sum to 1.
#' @param co2_feed_pesticides Numeric. Carbon dioxide (CO₂) emission factor of a
#' feed component, representing CO₂ emissions from pesticide manufacture in feed
#' production, expressed per kilogram of dry matter intake (g CO₂/kg DM).
#'
#' @return Numeric. Contribution of an individual feed component to the diet-level average
#' carbon dioxide (CO₂) emission factor from pesticide manufacture in feed production
#' (g CO₂/kg DM).
#'
#' @details
#' The contribution is computed as:
#'
#' \deqn{diet\_co2\_feed\_pesticides = feed\_ration\_fraction \times co2\_feed\_pesticides}
#'
#' @export
calc_co2_ration_pesticides <- function(
    feed_ration_fraction,
    co2_feed_pesticides
) {
  validate_co2_ration_pesticides_inputs(feed_ration_fraction, co2_feed_pesticides)

  co2_ration_pesticides <- feed_ration_fraction * co2_feed_pesticides

  return(co2_ration_pesticides)
}


#' Calculate a ration component's contribution to carbon dioxide (CO₂) emissions from on-field agricultural activities
#'
#' Computes the contribution of an individual feed component to carbon dioxide (CO₂)
#' emissions from on-field agricultural activities in feed production (e.g energy use for tillage and
#' machinery operations), using feed-specific emission factors weighted by
#' the component's share in the ration.
#'
#' @param feed_ration_fraction Numeric. Proportion of a specific feed component in the total
#' ration, expressed as its fraction of diet dry matter intake (fraction). Within
#' each herd_id and cohort, proportions should sum to 1.
#' @param co2_feed_crop_operations Numeric. Carbon dioxide (CO₂) emission factor of a
#' feed component, representing CO₂ emissions from on-field agricultural activities
#' in feed production, expressed per kilogram of dry matter intake (kg CO₂/kg DM).
#'
#' @return Numeric. Contribution of an individual feed component to the diet-level
#' average carbon dioxide (CO₂) emission factor from on-field agricultural activities
#' in feed production (g CO₂/kg DM).
#'
#' @details
#' The contribution is computed as:
#'
#' \deqn{diet\_co2\_feed\_crop\_operations =
#'   feed\_ration\_fraction \times co2\_feed\_crop\_operations}
#'
#' @export
calc_co2_ration_crop_activities <- function(
    feed_ration_fraction,
    co2_feed_crop_operations
) {
  validate_co2_ration_crop_activities_inputs(feed_ration_fraction, co2_feed_crop_operations)

  co2_ration_crop_activities <- feed_ration_fraction * co2_feed_crop_operations

  return(co2_ration_crop_activities)
}


#' Calculate a ration component's contribution to carbon dioxide (CO₂) emissions from land-use change (excluding peatland drainage)
#'
#' Computes the contribution of an individual feed component to carbon dioxide (CO₂)
#' emissions from land-use change in feed production (excluding peatland drainage),
#' using feed-specific emission factors weighted by the component's share in the ration.
#'
#' @param feed_ration_fraction Numeric. Proportion of a specific feed component in the total
#' ration, expressed as its fraction of diet dry matter intake (fraction). Within
#' each herd_id and cohort, proportions should sum to 1.
#' @param co2_feed_luc_nopeat Numeric. Carbon dioxide (CO₂) emission factor of a feed component,
#' representing CO₂ emissions from land-use change in feed production (excluding peatland drainage),
#' expressed per kilogram of dry matter intake (g CO₂/kg DM).
#'
#' @return Numeric. Contribution of an individual feed component to the diet-level
#' average carbon dioxide (CO₂) emission factor from land-use change (excluding peatland drainage)
#' in feed production (g CO₂/kg DM).
#'
#' @details
#' The contribution is computed as:
#'
#' \deqn{diet\_co2\_feed\_luc\_nopeat = feed\_ration\_fraction \times co2\_feed\_luc\_nopeat}
#'
#' @export
calc_co2_ration_luc_nopeat <- function(
    feed_ration_fraction,
    co2_feed_luc_nopeat
) {
  validate_co2_ration_luc_nopeat_inputs(feed_ration_fraction, co2_feed_luc_nopeat)

  co2_ration_luc_nopeat <- feed_ration_fraction * co2_feed_luc_nopeat

  return(co2_ration_luc_nopeat)
}


#' Calculate a ration component's contribution to carbon dioxide (CO₂) emissions from peatland drainage
#'
#' Computes the contribution of an individual feed component to carbon dioxide (CO₂)
#' emissions from peatland drainage in feed production,
#' using feed-specific emission factors weighted by the component's share in the ration.
#'
#' @param feed_ration_fraction Numeric. Proportion of a specific feed component in the total
#' ration, expressed as its fraction of diet dry matter intake (fraction). Within
#' each herd_id and cohort, proportions should sum to 1.
#' @param co2_feed_luc_peat Numeric. Carbon dioxide (CO₂) emission factor of a feed component,
#' representing CO₂ emissions from peatland drainage in feed production,
#' expressed per kilogram of dry matter intake (g CO₂/kg DM).
#'
#' @return Numeric. Contribution of an individual feed component to the diet-level
#' average carbon dioxide (CO₂) emission factor from  peatland drainage in feed
#' production (g CO₂/kg DM).
#'
#' @details
#' The contribution is computed as:
#'
#' \deqn{diet\_co2\_feed\_luc\_peat = feed\_ration\_fraction \times co2\_feed\_luc\_peat}
#'
#' @export
calc_co2_ration_luc_peat <- function(
    feed_ration_fraction,
    co2_feed_luc_peat
) {
  validate_co2_ration_luc_peat_inputs(feed_ration_fraction, co2_feed_luc_peat)

  co2_ration_luc_peat <- feed_ration_fraction * co2_feed_luc_peat

  return(co2_ration_luc_peat)
}


#' Calculate a ration component's contribution to nitrous oxide (N₂O) emissions from fertilizer use
#'
#' Computes the contribution of an individual feed component to nitrous oxide (N₂O)
#' emissions from synthetic fertilizer in feed production,
#' using feed-specific emission factors weighted by the component's share in the ration.
#'
#' @param feed_ration_fraction Numeric. Proportion of a specific feed component in the total
#' ration, expressed as its fraction of diet dry matter intake (fraction). Within
#' each herd_id and cohort, proportions should sum to 1.
#' @param n2o_feed_fertilizer Numeric. Nitrous oxide (N₂O) emission factor of a feed component,
#' representing N₂O emissions from fertilizer use in feed production,
#' expressed per kg of dry matter intake (g N₂O/kg DM).
#'
#' @return Numeric. Contribution of an individual feed component to the diet-level
#' average nitrous oxide (N₂O) emission factor from fertilizer use in feed
#' production (g N₂O/kg DM).
#'
#' @details
#' The contribution is computed as:
#'
#' \deqn{diet\_n2o\_feed\_fertilizer = feed\_ration\_fraction \times n2o\_feed\_fertilizer}
#'
#' @export
calc_n2o_ration_fertilizer <- function(
    feed_ration_fraction,
    n2o_feed_fertilizer
) {
  validate_n2o_ration_fertilizer_inputs(feed_ration_fraction, n2o_feed_fertilizer)

  n2o_ration_fertilizer <- feed_ration_fraction * n2o_feed_fertilizer

  return(n2o_ration_fertilizer)
}


#' Calculate a ration component's contribution to nitrous oxide (N₂O) emissions from manure application and deposition
#'
#' Computes the contribution of an individual feed component to nitrous oxide (N₂O)
#' emissions from manure application to or deposition on soil in feed production,
#' using feed-specific emission factors weighted by the component's share in the ration.
#'
#' @param feed_ration_fraction Numeric. Proportion of a specific feed component in the total
#' ration, expressed as its fraction of diet dry matter intake (fraction). Within
#' each herd_id and cohort, proportions should sum to 1.
#' @param n2o_feed_manure_applied Numeric. Nitrous oxide (N₂O) emission factor of a feed component,
#' representing N₂O emissions from manure applied to or deposited on soil in feed production,
#' expressed per kg of dry matter intake (g N₂O/kg DM).
#'
#' @return Numeric. Contribution of an individual feed component to the diet-level
#' average nitrous oxide (N₂O) emission factor from manure applied to or deposited on
#' soil in feed production (g N₂O/kg DM).
#'
#' @details
#' The contribution is computed as:
#'
#' \deqn{diet\_n2o\_feed\_manure\_applied =
#'   feed\_ration\_fraction \times n2o\_feed\_manure\_applied}
#'
#' @export
calc_n2o_ration_manure <- function(
    feed_ration_fraction,
    n2o_feed_manure_applied
) {
  validate_n2o_ration_manure_applied_inputs(feed_ration_fraction, n2o_feed_manure_applied)

  n2o_ration_manure_applied <- feed_ration_fraction * n2o_feed_manure_applied

  return(n2o_ration_manure_applied)
}


#' Calculate a ration component's contribution to nitrous oxide (N₂O) emissions from crop residues decomposition
#'
#' Computes the contribution of an individual feed component to nitrous oxide (N₂O)
#' emissions from crop residues decomposition in feed production,
#' using feed-specific emission factors weighted by the component's share in the ration.
#'
#' @param feed_ration_fraction Numeric. Proportion of a specific feed component in the total
#' ration, expressed as its fraction of diet dry matter intake (fraction). Within
#' each herd_id and cohort, proportions should sum to 1.
#' @param n2o_feed_crop_residues Numeric. Nitrous oxide (N₂O) emission factor of a feed component,
#' representing N₂O emissions from crop residues decomposition in feed production,
#' expressed per kg of dry matter intake (g N₂O/kg DM).
#'
#' @return Numeric. Contribution of an individual feed component to the diet-level
#' average nitrous oxide (N₂O) emission factor from crop residues decomposition
#' in feed production (g N₂O/kg DM).
#'
#' @details
#' The contribution is computed as:
#'
#' \deqn{diet\_n2o\_feed\_crop\_residues =
#'   feed\_ration\_fraction \times n2o\_feed\_crop\_residues}
#'
#' @export
calc_n2o_ration_crop_residues <- function(
    feed_ration_fraction,
    n2o_feed_crop_residues
) {
  validate_n2o_ration_crop_residues_inputs(feed_ration_fraction, n2o_feed_crop_residues)

  n2o_ration_crop_residues <- feed_ration_fraction * n2o_feed_crop_residues

  return(n2o_ration_crop_residues)
}


#' Calculate a ration component's contribution to methane (CH₄) emissions from rice cultivation
#'
#' Computes the contribution of an individual feed component to methane (CH₄)
#' emissions from rice cultivation in feed production,
#' using feed-specific emission factors weighted by the component's share in the ration.
#'
#' @param feed_ration_fraction Numeric. Proportion of a specific feed component in the total
#' ration, expressed as its fraction of diet dry matter intake (fraction). Within
#' each herd_id and cohort, proportions should sum to 1.
#' @param ch4_feed_rice Numeric. Methane (CH₄) emission factor of a feed component,
#' representing CH₄ emissions from rice cultivation in feed production,
#' expressed per kg of dry matter intake (g CH₄/kg DM).
#'
#' @return Numeric. Contribution of an individual feed component to the diet-level
#' average methane (CH₄) emission factor from rice cultivation in feed production (g CH₄/kg DM).
#'
#' @details
#' The contribution is computed as:
#'
#' \deqn{diet\_ch4\_feed\_rice = feed\_ration\_fraction \times ch4\_feed\_rice}
#'
#' @export
calc_ch4_ration_rice <- function(
    feed_ration_fraction,
    ch4_feed_rice
) {
  validate_ch4_ration_rice_inputs(feed_ration_fraction, ch4_feed_rice)

  ch4_ration_rice <- feed_ration_fraction * ch4_feed_rice

  return(ch4_ration_rice)
}
