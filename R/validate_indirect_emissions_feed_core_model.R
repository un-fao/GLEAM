#' Validate inputs for compute_dmi_by_feed function
#'
#' Ensures that the inputs to compute_dmi_by_feed are valid numeric values.
#' Both parameters must be single numeric values (can be NA, which is handled by the function).
#'
#' @param dmi_total The total dry matter intake to validate.
#' @param feed_share The feed share to validate.
#'
#' @noRd
validate_dmi_by_feed_inputs <- function(dmi_total, feed_share) {
  # Check dmi_total (allow NA)
  if (length(dmi_total) != 1 || (!is.na(dmi_total) && !is.numeric(dmi_total))) {
    cli::cli_abort("{.arg dmi_total} must be a single numeric value.")
  }

  # Check feed_share (allow NA)
  if (length(feed_share) != 1 || (!is.na(feed_share) && !is.numeric(feed_share))) {
    cli::cli_abort("{.arg feed_share} must be a single numeric value.")
  }

  # Check that feed_share is between 0 and 1 (if not NA)
  if (!is.na(feed_share) && (feed_share < 0 || feed_share > 1)) {
    cli::cli_abort("{.arg feed_share} must be between 0 and 1.")
  }

  # Check that dmi_total is non-negative (if not NA)
  if (!is.na(dmi_total) && dmi_total < 0) {
    cli::cli_abort("{.arg dmi_total} must be non-negative.")
  }
}

#' Validate inputs for compute_feed_emissions function
#'
#' Ensures that the inputs to compute_feed_emissions are valid numeric values.
#' Both parameters must be single numeric values (can be NA, which is handled by the function).
#'
#' @param dmi_byfeed The dry matter intake by feed to validate.
#' @param emission_factor The emission factor to validate.
#'
#' @noRd
validate_feed_emissions_inputs <- function(dmi_byfeed, emission_factor) {
  # Check dmi_byfeed (allow NA)
  if (length(dmi_byfeed) != 1 || (!is.na(dmi_byfeed) && !is.numeric(dmi_byfeed))) {
    cli::cli_abort("{.arg dmi_byfeed} must be a single numeric value.")
  }

  # Check emission_factor (allow NA)
  if (length(emission_factor) != 1 || (!is.na(emission_factor) && !is.numeric(emission_factor))) {
    cli::cli_abort("{.arg emission_factor} must be a single numeric value.")
  }

  # Check that dmi_byfeed is non-negative (if not NA)
  if (!is.na(dmi_byfeed) && dmi_byfeed < 0) {
    cli::cli_abort("{.arg dmi_byfeed} must be non-negative.")
  }

  # Check that emission_factor is non-negative (if not NA)
  if (!is.na(emission_factor) && emission_factor < 0) {
    cli::cli_abort("{.arg emission_factor} must be non-negative.")
  }
}
