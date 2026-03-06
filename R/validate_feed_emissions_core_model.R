#' Validate inputs for calc_diet_co2_feed_fertilizer
#'
#' @noRd
validate_diet_co2_feed_fertilizer_inputs <- function(
    feed_ration_fraction,
    co2_feed_fertilizer
) {
  validate_scalar_numeric(feed_ration_fraction, "feed_ration_fraction")
  validate_param_range(feed_ration_fraction)

  if (!is.numeric(co2_feed_fertilizer) || length(co2_feed_fertilizer) != 1) {
    cli::cli_abort("{.arg co2_feed_fertilizer} must be a single numeric (scalar). NA is allowed.")
  }
  if (!is.na(co2_feed_fertilizer) && co2_feed_fertilizer < 0) {
    cli::cli_abort("{.arg co2_feed_fertilizer} must be >= 0.")
  }
}

#' Validate inputs for calc_diet_co2_feed_pesticides
#'
#' @noRd
validate_diet_co2_feed_pesticides_inputs <- function(
    feed_ration_fraction,
    co2_feed_pesticides
) {
  validate_scalar_numeric(feed_ration_fraction, "feed_ration_fraction")
  validate_param_range(feed_ration_fraction)

  if (!is.numeric(co2_feed_pesticides) || length(co2_feed_pesticides) != 1) {
    cli::cli_abort("{.arg co2_feed_pesticides} must be a single numeric (scalar). NA is allowed.")
  }
  if (!is.na(co2_feed_pesticides) && co2_feed_pesticides < 0) {
    cli::cli_abort("{.arg co2_feed_pesticides} must be >= 0.")
  }
}

#' Validate inputs for calc_diet_co2_feed_crop_operations
#'
#' @noRd
validate_diet_co2_feed_crop_operations_inputs <- function(
    feed_ration_fraction,
    co2_feed_crop_operations
) {
  validate_scalar_numeric(feed_ration_fraction, "feed_ration_fraction")
  validate_param_range(feed_ration_fraction)

  if (!is.numeric(co2_feed_crop_operations) || length(co2_feed_crop_operations) != 1) {
    cli::cli_abort("{.arg co2_feed_crop_operations} must be a single numeric (scalar). NA is allowed.")
  }
  if (!is.na(co2_feed_crop_operations) && co2_feed_crop_operations < 0) {
    cli::cli_abort("{.arg co2_feed_crop_operations} must be >= 0.")
  }
}

#' Validate inputs for calc_diet_co2_feed_luc_nopeat
#'
#' @noRd
validate_diet_co2_feed_luc_nopeat_inputs <- function(
    feed_ration_fraction,
    co2_feed_luc_nopeat
) {
  validate_scalar_numeric(feed_ration_fraction, "feed_ration_fraction")
  validate_param_range(feed_ration_fraction)

  if (!is.numeric(co2_feed_luc_nopeat) || length(co2_feed_luc_nopeat) != 1) {
    cli::cli_abort("{.arg co2_feed_luc_nopeat} must be a single numeric (scalar). NA is allowed.")
  }
}

#' Validate inputs for calc_diet_co2_feed_luc_peat
#'
#' @noRd
validate_diet_co2_feed_luc_peat_inputs <- function(
    feed_ration_fraction,
    co2_feed_luc_peat
) {
  validate_scalar_numeric(feed_ration_fraction, "feed_ration_fraction")
  validate_param_range(feed_ration_fraction)

  if (!is.numeric(co2_feed_luc_peat) || length(co2_feed_luc_peat) != 1) {
    cli::cli_abort("{.arg co2_feed_luc_peat} must be a single numeric (scalar). NA is allowed.")
  }
}

#' Validate inputs for calc_diet_n2o_feed_fertilizer
#'
#' @noRd
validate_diet_n2o_feed_fertilizer_inputs <- function(
    feed_ration_fraction,
    n2o_feed_fertilizer
) {
  validate_scalar_numeric(feed_ration_fraction, "feed_ration_fraction")
  validate_param_range(feed_ration_fraction)

  if (!is.numeric(n2o_feed_fertilizer) || length(n2o_feed_fertilizer) != 1) {
    cli::cli_abort("{.arg n2o_feed_fertilizer} must be a single numeric (scalar). NA is allowed.")
  }
  if (!is.na(n2o_feed_fertilizer) && n2o_feed_fertilizer < 0) {
    cli::cli_abort("{.arg n2o_feed_fertilizer} must be >= 0.")
  }
}

#' Validate inputs for calc_diet_n2o_feed_manure_applied
#'
#' @noRd
validate_diet_n2o_feed_manure_applied_inputs <- function(
    feed_ration_fraction,
    n2o_feed_manure_applied
) {
  validate_scalar_numeric(feed_ration_fraction, "feed_ration_fraction")
  validate_param_range(feed_ration_fraction)

  if (!is.numeric(n2o_feed_manure_applied) || length(n2o_feed_manure_applied) != 1) {
    cli::cli_abort("{.arg n2o_feed_manure_applied} must be a single numeric (scalar). NA is allowed.")
  }
  if (!is.na(n2o_feed_manure_applied) && n2o_feed_manure_applied < 0) {
    cli::cli_abort("{.arg n2o_feed_manure_applied} must be >= 0.")
  }
}

#' Validate inputs for calc_diet_n2o_feed_crop_residues
#'
#' @noRd
validate_diet_n2o_feed_crop_residues_inputs <- function(
    feed_ration_fraction,
    n2o_feed_crop_residues
) {
  validate_scalar_numeric(feed_ration_fraction, "feed_ration_fraction")
  validate_param_range(feed_ration_fraction)

  if (!is.numeric(n2o_feed_crop_residues) || length(n2o_feed_crop_residues) != 1) {
    cli::cli_abort("{.arg n2o_feed_crop_residues} must be a single numeric (scalar). NA is allowed.")
  }
  if (!is.na(n2o_feed_crop_residues) && n2o_feed_crop_residues < 0) {
    cli::cli_abort("{.arg n2o_feed_crop_residues} must be >= 0.")
  }
}

#' Validate inputs for calc_diet_ch4_feed_rice
#'
#' @noRd
validate_diet_ch4_feed_rice_inputs <- function(
    feed_ration_fraction,
    ch4_feed_rice
) {
  validate_scalar_numeric(feed_ration_fraction, "feed_ration_fraction")
  validate_param_range(feed_ration_fraction)

  if (!is.numeric(ch4_feed_rice) || length(ch4_feed_rice) != 1) {
    cli::cli_abort("{.arg ch4_feed_rice} must be a single numeric (scalar). NA is allowed.")
  }
  if (!is.na(ch4_feed_rice) && ch4_feed_rice < 0) {
    cli::cli_abort("{.arg ch4_feed_rice} must be >= 0.")
  }
}
