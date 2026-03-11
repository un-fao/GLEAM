#' Validate inputs for calc_co2_ration_fertilizer
#'
#' @noRd
validate_co2_ration_fertilizer_inputs <- function(
    feed_ration_fraction,
    co2_feed_fertilizer
) {
  validate_param_range(feed_ration_fraction)
  validate_scalar_numeric_or_na(co2_feed_fertilizer, min_val = 0)
}

#' Validate inputs for calc_co2_ration_pesticides
#'
#' @noRd
validate_co2_ration_pesticides_inputs <- function(
    feed_ration_fraction,
    co2_feed_pesticides
) {
  validate_param_range(feed_ration_fraction)
  validate_scalar_numeric_or_na(co2_feed_pesticides, min_val = 0)
}

#' Validate inputs for calc_co2_ration_crop_activities
#'
#' @noRd
validate_co2_ration_crop_activities_inputs <- function(
    feed_ration_fraction,
    co2_feed_crop_operations
) {
  validate_param_range(feed_ration_fraction)
  validate_scalar_numeric_or_na(co2_feed_crop_operations, min_val = 0)
}

#' Validate inputs for calc_co2_ration_luc_nopeat
#'
#' @noRd
validate_co2_ration_luc_nopeat_inputs <- function(
    feed_ration_fraction,
    co2_feed_luc_nopeat
) {
  validate_param_range(feed_ration_fraction)
  validate_scalar_numeric_or_na(co2_feed_luc_nopeat, min_val = -Inf)
}

#' Validate inputs for calc_co2_ration_luc_peat
#'
#' @noRd
validate_co2_ration_luc_peat_inputs <- function(
    feed_ration_fraction,
    co2_feed_luc_peat
) {
  validate_param_range(feed_ration_fraction)
  validate_scalar_numeric_or_na(co2_feed_luc_peat, min_val = -Inf)
}

#' Validate inputs for calc_n2o_ration_fertilizer
#'
#' @noRd
validate_n2o_ration_fertilizer_inputs <- function(
    feed_ration_fraction,
    n2o_feed_fertilizer
) {
  validate_param_range(feed_ration_fraction)
  validate_scalar_numeric_or_na(n2o_feed_fertilizer, min_val = 0)
}

#' Validate inputs for calc_n2o_ration_manure
#'
#' @noRd
validate_n2o_ration_manure_applied_inputs <- function(
    feed_ration_fraction,
    n2o_feed_manure_applied
) {
  validate_param_range(feed_ration_fraction)
  validate_scalar_numeric_or_na(n2o_feed_manure_applied, min_val = 0)
}

#' Validate inputs for calc_n2o_ration_crop_residues
#'
#' @noRd
validate_n2o_ration_crop_residues_inputs <- function(
    feed_ration_fraction,
    n2o_feed_crop_residues
) {
  validate_param_range(feed_ration_fraction)
  validate_scalar_numeric_or_na(n2o_feed_crop_residues, min_val = 0)
}

#' Validate inputs for calc_ch4_ration_rice
#'
#' @noRd
validate_ch4_ration_rice_inputs <- function(
    feed_ration_fraction,
    ch4_feed_rice
) {
  validate_param_range(feed_ration_fraction)
  validate_scalar_numeric_or_na(ch4_feed_rice, min_val = 0)
}
