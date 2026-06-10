#' Calculate a ration component's contribution to carbon dioxide (CO2) emissions from fertilizer manufacture
#'
#' Calculates the contribution of an individual feed component to carbon dioxide (CO2)
#' emissions from fertilizer manufacture in feed production,
#' using feed-specific emission factors weighted by the component's share in the ration.
#'
#' @param feed_ration_fraction Numeric. Proportion of a specific feed component in
#' the total ration,as its fraction of diet dry matter intake (fraction). Within
#' each herd_id and cohort, proportions should sum to 1.
#' @param co2_feed_fertilizer Numeric. Carbon dioxide (CO2) emission factor of a
#' feed component, representing CO2 emissions from fertilizer manufacture in feed
#' production, expressed per kilogram of dry matter intake (g CO2/kg DM).
#'
#' @return Numeric. Contribution of an individual feed component to the diet-level average
#' carbon dioxide (CO2) emission factor from fertilizer manufacture in feed production
#' (g CO2/kg DM).
#'
#' @details
#' The contribution is computed as:
#'
#' \deqn{diet\_co2\_feed\_fertilizer = feed\_ration\_fraction \times co2\_feed\_fertilizer}
#' 
#' This function is part of the [run_emissions_ration_module()].
#' 
#' @seealso
#'   \code{\link{run_emissions_ration_module}}
#'   
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

#' Calculate a ration component's contribution to carbon dioxide (CO2) emissions from pesticide manufacture
#'
#' Calculates the contribution of an individual feed component to carbon dioxide (CO2)
#' emissions from pesticide manufacture in feed production,
#' using feed-specific emission factors weighted by the component's share in the ration.
#'
#' @param feed_ration_fraction Numeric. Proportion of a specific feed component in the total
#' ration, expressed as its fraction of diet dry matter intake (fraction). Within
#' each herd_id and cohort, proportions should sum to 1.
#' @param co2_feed_pesticides Numeric. Carbon dioxide (CO2) emission factor of a
#' feed component, representing CO2 emissions from pesticide manufacture in feed
#' production, expressed per kilogram of dry matter intake (g CO2/kg DM).
#'
#' @return Numeric. Contribution of an individual feed component to the diet-level average
#' carbon dioxide (CO2) emission factor from pesticide manufacture in feed production
#' (g CO2/kg DM).
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


#' Calculate a ration component's contribution to carbon dioxide (CO2) emissions from on-field agricultural activities
#'
#' Calculates the contribution of an individual feed component to carbon dioxide (CO2)
#' emissions from on-field agricultural activities in feed production (e.g., energy use for tillage and
#' machinery operations), using feed-specific emission factors weighted by
#' the component's share in the ration.
#'
#' @param feed_ration_fraction Numeric. Proportion of a specific feed component in the total
#' ration, expressed as its fraction of diet dry matter intake (fraction). Within
#' each herd_id and cohort, proportions should sum to 1.
#' @param co2_feed_crop_activities Numeric. Carbon dioxide (CO2) emission factor of a
#' feed component, representing CO2 emissions from on-field agricultural activities
#' in feed production, expressed per kilogram of dry matter intake (kg CO2/kg DM).
#'
#' @return Numeric. Contribution of an individual feed component to the diet-level
#' average carbon dioxide (CO2) emission factor from on-field agricultural activities
#' in feed production (g CO2/kg DM).
#'
#' @details
#' The contribution is computed as:
#'
#' \deqn{diet\_co2\_feed\_crop\_operations =
#'   feed\_ration\_fraction \times co2\_feed\_crop\_operations}
#'   
#' This function is part of the [run_emissions_ration_module()].
#' 
#' @seealso
#'   \code{\link{run_emissions_ration_module}}
#'
#' @export
calc_co2_ration_crop_activities <- function(
    feed_ration_fraction,
    co2_feed_crop_activities
) {
  validate_co2_ration_crop_activities_inputs(feed_ration_fraction, co2_feed_crop_activities)

  co2_ration_crop_activities <- feed_ration_fraction * co2_feed_crop_activities

  return(co2_ration_crop_activities)
}


#' Calculate a ration component's contribution to carbon dioxide (CO2) emissions from land-use change (excluding peatland drainage)
#'
#' Calculates the contribution of an individual feed component to carbon dioxide (CO2)
#' emissions from land-use change in feed production (excluding peatland drainage),
#' using feed-specific emission factors weighted by the component's share in the ration.
#'
#' @param feed_ration_fraction Numeric. Proportion of a specific feed component in the total
#' ration, expressed as its fraction of diet dry matter intake (fraction). Within
#' each herd_id and cohort, proportions should sum to 1.
#' @param co2_feed_luc_nopeat Numeric. Carbon dioxide (CO2) emission factor of a feed component,
#' representing CO2 emissions from land-use change in feed production (excluding peatland drainage),
#' expressed per kilogram of dry matter intake (g CO2/kg DM).
#'
#' @return Numeric. Contribution of an individual feed component to the diet-level
#' average carbon dioxide (CO2) emission factor from land-use change (excluding peatland drainage)
#' in feed production (g CO2/kg DM).
#'
#' @details
#' The contribution is computed as:
#'
#' \deqn{diet\_co2\_feed\_luc\_nopeat = feed\_ration\_fraction \times co2\_feed\_luc\_nopeat}
#'
#' This function is part of the [run_emissions_ration_module()].
#' 
#' @seealso
#'   \code{\link{run_emissions_ration_module}}
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


#' Calculate a ration component's contribution to carbon dioxide (CO2) emissions from peatland drainage
#'
#' Calculates the contribution of an individual feed component to carbon dioxide (CO2)
#' emissions from peatland drainage in feed production,
#' using feed-specific emission factors weighted by the component's share in the ration.
#'
#' @param feed_ration_fraction Numeric. Proportion of a specific feed component in the total
#' ration, expressed as its fraction of diet dry matter intake (fraction). Within
#' each herd_id and cohort, proportions should sum to 1.
#' @param co2_feed_luc_peat Numeric. Carbon dioxide (CO2) emission factor of a feed component,
#' representing CO2 emissions from peatland drainage in feed production,
#' expressed per kilogram of dry matter intake (g CO2/kg DM).
#'
#' @return Numeric. Contribution of an individual feed component to the diet-level
#' average carbon dioxide (CO2) emission factor from  peatland drainage in feed
#' production (g CO2/kg DM).
#'
#' @details
#' The contribution is computed as:
#'
#' \deqn{diet\_co2\_feed\_luc\_peat = feed\_ration\_fraction \times co2\_feed\_luc\_peat}
#'
#' This function is part of the [run_emissions_ration_module()].
#' 
#' @seealso
#'   \code{\link{run_emissions_ration_module}}
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


#' Calculate a ration component's contribution to nitrous oxide (N2O) emissions from fertilizer use
#'
#' Calculates the contribution of an individual feed component to nitrous oxide (N2O)
#' emissions from synthetic fertilizer in feed production,
#' using feed-specific emission factors weighted by the component's share in the ration.
#'
#' @param feed_ration_fraction Numeric. Proportion of a specific feed component in the total
#' ration, expressed as its fraction of diet dry matter intake (fraction). Within
#' each herd_id and cohort, proportions should sum to 1.
#' @param n2o_feed_fertilizer Numeric. Nitrous oxide (N2O) emission factor of a feed component,
#' representing N2O emissions from fertilizer use in feed production,
#' expressed per kg of dry matter intake (g N2O/kg DM).
#'
#' @return Numeric. Contribution of an individual feed component to the diet-level
#' average nitrous oxide (N2O) emission factor from fertilizer use in feed
#' production (g N2O/kg DM).
#'
#' @details
#' The contribution is computed as:
#'
#' \deqn{diet\_n2o\_feed\_fertilizer = feed\_ration\_fraction \times n2o\_feed\_fertilizer}
#'
#' This function is part of the [run_emissions_ration_module()].
#' 
#' @seealso
#'   \code{\link{run_emissions_ration_module}}
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


#' Calculate a ration component's contribution to nitrous oxide (N2O) emissions from manure application and deposition
#'
#' Calculates the contribution of an individual feed component to nitrous oxide (N2O)
#' emissions from manure application to or deposition on soil in feed production,
#' using feed-specific emission factors weighted by the component's share in the ration.
#'
#' @param feed_ration_fraction Numeric. Proportion of a specific feed component in the total
#' ration, expressed as its fraction of diet dry matter intake (fraction). Within
#' each herd_id and cohort, proportions should sum to 1.
#' @param n2o_feed_manure_applied Numeric. Nitrous oxide (N2O) emission factor of a feed component,
#' representing N2O emissions from manure applied to or deposited on soil in feed production,
#' expressed per kg of dry matter intake (g N2O/kg DM).
#'
#' @return Numeric. Contribution of an individual feed component to the diet-level
#' average nitrous oxide (N2O) emission factor from manure applied to or deposited on
#' soil in feed production (g N2O/kg DM).
#'
#' @details
#' The contribution is computed as:
#'
#' \deqn{diet\_n2o\_feed\_manure\_applied =
#'   feed\_ration\_fraction \times n2o\_feed\_manure\_applied}
#'
#' This function is part of the [run_emissions_ration_module()].
#' 
#' @seealso
#'   \code{\link{run_emissions_ration_module}}
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


#' Calculate a ration component's contribution to nitrous oxide (N2O) emissions from crop residues decomposition
#'
#' Calculates the contribution of an individual feed component to nitrous oxide (N2O)
#' emissions from crop residues decomposition in feed production,
#' using feed-specific emission factors weighted by the component's share in the ration.
#'
#' @param feed_ration_fraction Numeric. Proportion of a specific feed component in the total
#' ration, expressed as its fraction of diet dry matter intake (fraction). Within
#' each herd_id and cohort, proportions should sum to 1.
#' @param n2o_feed_crop_residues Numeric. Nitrous oxide (N2O) emission factor of a feed component,
#' representing N2O emissions from crop residues decomposition in feed production,
#' expressed per kg of dry matter intake (g N2O/kg DM).
#'
#' @return Numeric. Contribution of an individual feed component to the diet-level
#' average nitrous oxide (N2O) emission factor from crop residues decomposition
#' in feed production (g N2O/kg DM).
#'
#' @details
#' The contribution is computed as:
#'
#' \deqn{diet\_n2o\_feed\_crop\_residues =
#'   feed\_ration\_fraction \times n2o\_feed\_crop\_residues}
#'
#' This function is part of the [run_emissions_ration_module()].
#' 
#' @seealso
#'   \code{\link{run_emissions_ration_module}}
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


#' Calculate a ration component's contribution to methane (CH4) emissions from rice cultivation
#'
#' Calculates the contribution of an individual feed component to methane (CH4)
#' emissions from rice cultivation in feed production,
#' using feed-specific emission factors weighted by the component's share in the ration.
#'
#' @param feed_ration_fraction Numeric. Proportion of a specific feed component in the total
#' ration, expressed as its fraction of diet dry matter intake (fraction). Within
#' each herd_id and cohort, proportions should sum to 1.
#' @param ch4_feed_rice Numeric. Methane (CH4) emission factor of a feed component,
#' representing CH4 emissions from rice cultivation in feed production,
#' expressed per kg of dry matter intake (g CH4/kg DM).
#'
#' @return Numeric. Contribution of an individual feed component to the diet-level
#' average methane (CH4) emission factor from rice cultivation in feed production (g CH4/kg DM).
#'
#' @details
#' The contribution is computed as:
#'
#' \deqn{diet\_ch4\_feed\_rice = feed\_ration\_fraction \times ch4\_feed\_rice}
#'
#' This function is part of the [run_emissions_ration_module()].
#' 
#' @seealso
#'   \code{\link{run_emissions_ration_module}}
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
