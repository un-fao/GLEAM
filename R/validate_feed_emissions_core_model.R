#' Validate inputs for calc_diet_co2_feed_fertilizer
#'
#' @noRd
validate_diet_co2_feed_fertilizer_inputs <- function(
    feed_ration_fraction,
    co2_feed_fertilizer
) {
  validate_param_range(feed_ration_fraction)
  validate_scalar_numeric_or_na(co2_feed_fertilizer, min_val = 0)
}

#' Validate inputs for calc_diet_co2_feed_pesticides
#'
#' @noRd
validate_diet_co2_feed_pesticides_inputs <- function(
    feed_ration_fraction,
    co2_feed_pesticides
) {
  validate_param_range(feed_ration_fraction)
  validate_scalar_numeric_or_na(co2_feed_pesticides, min_val = 0)
}

#' Validate inputs for calc_diet_co2_feed_crop_operations
#'
#' @noRd
validate_diet_co2_feed_crop_operations_inputs <- function(
    feed_ration_fraction,
    co2_feed_crop_operations
) {
  validate_param_range(feed_ration_fraction)
  validate_scalar_numeric_or_na(co2_feed_crop_operations, min_val = 0)
}

#' Validate inputs for calc_diet_co2_feed_luc_nopeat
#'
#' @noRd
validate_diet_co2_feed_luc_nopeat_inputs <- function(
    feed_ration_fraction,
    co2_feed_luc_nopeat
) {
  validate_param_range(feed_ration_fraction)
  validate_scalar_numeric_or_na(co2_feed_luc_nopeat, min_val = -Inf)
}

#' Validate inputs for calc_diet_co2_feed_luc_peat
#'
#' @noRd
validate_diet_co2_feed_luc_peat_inputs <- function(
    feed_ration_fraction,
    co2_feed_luc_peat
) {
  validate_param_range(feed_ration_fraction)
  validate_scalar_numeric_or_na(co2_feed_luc_peat, min_val = -Inf)
}

#' Validate inputs for calc_diet_n2o_feed_fertilizer
#'
#' @noRd
validate_diet_n2o_feed_fertilizer_inputs <- function(
    feed_ration_fraction,
    n2o_feed_fertilizer
) {
  validate_param_range(feed_ration_fraction)
  validate_scalar_numeric_or_na(n2o_feed_fertilizer, min_val = 0)
}

#' Validate inputs for calc_diet_n2o_feed_manure_applied
#'
#' @noRd
validate_diet_n2o_feed_manure_applied_inputs <- function(
    feed_ration_fraction,
    n2o_feed_manure_applied
) {
  validate_param_range(feed_ration_fraction)
  validate_scalar_numeric_or_na(n2o_feed_manure_applied, min_val = 0)
}

#' Validate inputs for calc_diet_n2o_feed_crop_residues
#'
#' @noRd
validate_diet_n2o_feed_crop_residues_inputs <- function(
    feed_ration_fraction,
    n2o_feed_crop_residues
) {
  validate_param_range(feed_ration_fraction)
  validate_scalar_numeric_or_na(n2o_feed_crop_residues, min_val = 0)
}

#' Validate inputs for calc_diet_ch4_feed_rice
#'
#' @noRd
validate_diet_ch4_feed_rice_inputs <- function(
    feed_ration_fraction,
    ch4_feed_rice
) {
  validate_param_range(feed_ration_fraction)
  validate_scalar_numeric_or_na(ch4_feed_rice, min_val = 0)
}
