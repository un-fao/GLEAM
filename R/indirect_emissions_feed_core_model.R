#' Compute Dry Matter Intake by Feed Item
#'
#' Calculates the dry matter intake (DMI) allocated to each feed item based on the total
#' DMI and the feed's share in the ration. This function handles missing values by
#' returning zero when either input is NA.
#'
#' @param dmi_total Numeric. Total dry matter intake per animal per day (kg DM/head/day).
#' @param feed_share Numeric. Fraction of total diet represented by this feed item (0-1).
#'
#' @return Numeric. Feed-specific dry matter intake (kg DM/head/day).
#'
#' @details
#' The calculation is: \code{dmi_byfeed = dmi_total * feed_share}
#'
#' If either \code{dmi_total} or \code{feed_share} is NA, the result is 0.
#'
#' @export
compute_dmi_by_feed <- function(dmi_total, feed_share) {
  # Validate inputs
  validate_dmi_by_feed_inputs(dmi_total, feed_share)
  
  # Handle missing values: return 0 if either input is NA
  if (is.na(dmi_total) || is.na(feed_share)) {
    return(0)
  }
  
  # Calculate feed-specific DMI
  dmi_byfeed <- dmi_total * feed_share
  
  return(dmi_byfeed)
}

#' Compute Feed-Specific Emissions
#'
#' Calculates the emissions generated from a specific feed item based on its dry matter
#' intake and emission factor. This function handles missing values by returning zero
#' when either input is NA.
#'
#' @param dmi_byfeed Numeric. Dry matter intake for this feed item (kg DM/head/day).
#' @param emission_factor Numeric. Emission factor for this feed item (kg gas/kg DM).
#'
#' @return Numeric. Feed-specific emissions (kg gas/head/day).
#'
#' @details
#' The calculation is: \code{feed_emissions = dmi_byfeed * emission_factor}
#'
#' If either \code{dmi_byfeed} or \code{emission_factor} is NA, the result is 0.
#'
#' @export
compute_feed_emissions <- function(dmi_byfeed, emission_factor) {
  # Validate inputs
  validate_feed_emissions_inputs(dmi_byfeed, emission_factor)
  
  # Handle missing values: return 0 if either input is NA
  if (is.na(dmi_byfeed) || is.na(emission_factor)) {
    return(0)
  }
  
  # Calculate feed-specific emissions
  feed_emissions <- dmi_byfeed * emission_factor
  
  return(feed_emissions)
}
