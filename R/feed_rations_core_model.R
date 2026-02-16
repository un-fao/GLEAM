#' Calculate feed digestibility fraction
#'
#' Computes digestibility as the ratio of digestible or metabolizable energy
#' to gross energy.
#'
#' @param feed_digestible_energy_ruminant Numeric. Digestible energy for ruminants
#'   (same units as `feed_gross_energy`).
#' @param feed_digestible_energy_pigs Numeric. Digestible energy for pigs
#'   (same units as `feed_gross_energy`).
#' @param feed_metabolizable_energy_chicken Numeric. Metabolizable energy for chickens
#'   (same units as `feed_gross_energy`).
#' @param feed_gross_energy Numeric. Gross energy (same units as
#'   `feed_digestible_energy_ruminant`, `feed_digestible_energy_pigs`,
#'   and `feed_metabolizable_energy_chicken`).
#'
#' @return List. Digestibility fractions (unitless) with elements:
#'   `feed_digestibility_fraction_ruminant`, `feed_digestibility_fraction_pigs`,
#'   `feed_digestibility_fraction_chicken`.
#'
#' @details
#' The digestibility ratio is defined as:
#' \deqn{feed\_digestibility\_fraction = feed\_digestible\_energy / feed\_gross\_energy}
#'
#' This helper is vectorized over its inputs.
#'
#' @export
calc_feed_digestibility_fraction <- function(
    feed_digestible_energy_ruminant,
    feed_digestible_energy_pigs,
    feed_metabolizable_energy_chicken,
    feed_gross_energy
) {
  validate_feed_digestibility_inputs(
    feed_digestible_energy_ruminant,
    feed_digestible_energy_pigs,
    feed_metabolizable_energy_chicken,
    feed_gross_energy
  )

  # Ratios are unitless and vectorized by default
  # Treat missing numerator inputs as zero before division.
  feed_digestibility_fraction_ruminant <- ifelse(
    is.na(feed_digestible_energy_ruminant),
    0,
    feed_digestible_energy_ruminant / feed_gross_energy
  )
  feed_digestibility_fraction_pigs <- ifelse(
    is.na(feed_digestible_energy_pigs),
    0,
    feed_digestible_energy_pigs / feed_gross_energy
  )
  feed_digestibility_fraction_chicken <- ifelse(
    is.na(feed_metabolizable_energy_chicken),
    0,
    feed_metabolizable_energy_chicken / feed_gross_energy
  )

  return(
    list(
      feed_digestibility_fraction_ruminant = feed_digestibility_fraction_ruminant,
      feed_digestibility_fraction_pigs = feed_digestibility_fraction_pigs,
      feed_digestibility_fraction_chicken = feed_digestibility_fraction_chicken
    )
  )
}

#' Calculate diet digestibility contribution for a ration component
#'
#' Applies species-specific digestibility parameters to a ration share.
#'
#' @param species_short Character. Species short code. Supported values include
#'   ruminants (\code{CTL}, \code{BFL}, \code{CML}, \code{SHP}, \code{GTS}),
#'   chickens (\code{CHK}), and pigs (\code{PGS}).
#' @param feed_ration_fraction Numeric. Ration share for the feed component (fraction).
#' @param feed_digestibility_fraction_ruminant Numeric. Digestibility ratio for ruminants.
#' @param feed_digestibility_fraction_pigs Numeric. Digestibility ratio for pigs.
#' @param feed_digestibility_fraction_chicken Numeric. Digestibility ratio for chickens.
#'
#' @return Numeric. Digestibility contribution for the ration component.
#'
#' @details
#' The digestibility contribution uses the animal-specific digestibility ratio:
#' \itemize{
#'   \item Ruminants: \code{feed_ration_fraction * feed_digestibility_fraction_ruminant}
#'   \item Chickens: \code{feed_ration_fraction * feed_digestibility_fraction_chicken}
#'   \item Pigs: \code{feed_ration_fraction * feed_digestibility_fraction_pigs}
#' }
#'
#' This helper is vectorized over its inputs.
#'
#' @export
calc_diet_digestibility <- function(
    species_short,
    feed_ration_fraction,
    feed_digestibility_fraction_ruminant = NA_real_,
    feed_digestibility_fraction_pigs = NA_real_,
    feed_digestibility_fraction_chicken = NA_real_
) {
  validate_diet_digestibility_inputs(
    species_short,
    feed_ration_fraction,
    feed_digestibility_fraction_ruminant,
    feed_digestibility_fraction_pigs,
    feed_digestibility_fraction_chicken
  )

  # Apply the species-specific digestibility coefficient
  if (species_short %in% c("CTL", "BFL", "CML", "SHP", "GTS")) {
    diet_digestibility_fraction <- feed_ration_fraction * feed_digestibility_fraction_ruminant
  } else if (species_short == "CHK") {
    diet_digestibility_fraction <- feed_ration_fraction * feed_digestibility_fraction_chicken
  } else {
    diet_digestibility_fraction <- feed_ration_fraction * feed_digestibility_fraction_pigs
  }
  return(diet_digestibility_fraction)
}

#' Calculate diet metabolizable energy contribution for a ration component
#'
#' Applies species-specific metabolizable energy parameters to a ration share.
#'
#' @param species_short Character. Species short code. Supported values include
#'   ruminants (\code{CTL}, \code{BFL}, \code{CML}, \code{SHP}, \code{GTS}),
#'   chickens (\code{CHK}), and pigs (\code{PGS}).
#' @param feed_ration_fraction Numeric. Ration share for the feed component (fraction).
#' @param feed_metabolizable_energy_ruminant Numeric. Metabolizable energy for ruminants.
#' @param feed_metabolizable_energy_pigs Numeric. Metabolizable energy for pigs.
#' @param feed_metabolizable_energy_chicken Numeric. Metabolizable energy for chickens.
#'
#' @return Numeric. Metabolizable energy contribution for the ration component.
#'
#' @details
#' The metabolizable energy contribution uses the animal-specific parameter:
#' \itemize{
#'   \item Ruminants: \code{feed_ration_fraction * feed_metabolizable_energy_ruminant}
#'   \item Chickens: \code{feed_ration_fraction * feed_metabolizable_energy_chicken}
#'   \item Pigs: \code{feed_ration_fraction * feed_metabolizable_energy_pigs}
#' }
#'
#' This helper is vectorized over its inputs.
#'
#' @export
calc_diet_metabolizable_energy <- function(
    species_short,
    feed_ration_fraction,
    feed_metabolizable_energy_ruminant = NA_real_,
    feed_metabolizable_energy_pigs = NA_real_,
    feed_metabolizable_energy_chicken = NA_real_
) {
  validate_diet_metabolizable_energy_inputs(
    species_short,
    feed_ration_fraction,
    feed_metabolizable_energy_ruminant,
    feed_metabolizable_energy_pigs,
    feed_metabolizable_energy_chicken
  )

  # Apply the species-specific metabolizable energy parameter
  if (species_short %in% c("CTL", "BFL", "CML", "SHP", "GTS")) {
    diet_metabolizable_energy <- feed_ration_fraction * feed_metabolizable_energy_ruminant
  } else if (species_short == "CHK") {
    diet_metabolizable_energy <- feed_ration_fraction * feed_metabolizable_energy_chicken
  } else {
    diet_metabolizable_energy <- feed_ration_fraction * feed_metabolizable_energy_pigs
  }
  return(diet_metabolizable_energy)
}

#' Calculate diet gross energy contribution for a ration component
#'
#' Computes gross energy contribution from a ration share and gross energy input.
#'
#' @param feed_ration_fraction Numeric. Ration share for the feed component (fraction).
#' @param feed_gross_energy Numeric. Gross energy content (MJ/kg DM).
#'
#' @return Numeric. Gross energy contribution for the ration component.
#'
#' @details
#' The gross energy contribution is defined as:
#' \deqn{diet\_gross\_energy = feed\_ration\_fraction \times feed\_gross\_energy}
#'
#' This helper is vectorized over its inputs.
#'
#' @export
calc_diet_gross_energy <- function(feed_ration_fraction, feed_gross_energy) {
  validate_diet_gross_energy_inputs(feed_ration_fraction, feed_gross_energy)
  # Contribution is ration share multiplied by gross energy content
  diet_gross_energy <- feed_ration_fraction * feed_gross_energy
  return(diet_gross_energy)
}

#' Calculate diet nitrogen contribution for a ration component
#'
#' Computes nitrogen contribution from a ration share and nitrogen content.
#'
#' @param feed_ration_fraction Numeric. Ration share for the feed component (fraction).
#' @param feed_nitrogen_content Numeric. Nitrogen content (kg N/kg DM).
#'
#' @return Numeric. Nitrogen contribution for the ration component.
#'
#' @details
#' The nitrogen contribution is defined as:
#' \deqn{diet\_nitrogen = feed\_ration\_fraction \times feed\_nitrogen\_content}
#'
#' This helper is vectorized over its inputs.
#'
#' @export
calc_diet_nitrogen_content <- function(feed_ration_fraction, feed_nitrogen_content) {
  validate_diet_nitrogen_inputs(feed_ration_fraction, feed_nitrogen_content)
  # Contribution is ration share multiplied by nitrogen content
  diet_nitrogen <- feed_ration_fraction * feed_nitrogen_content
  return(diet_nitrogen)
}

#' Calculate urinary energy fraction contribution for a ration component
#'
#' Applies species-specific urinary energy parameters to a ration share.
#'
#' @param species_short Character. Species short code. Supported values include
#'   ruminants (\code{CTL}, \code{BFL}, \code{CML}, \code{SHP}, \code{GTS}),
#'   chickens (\code{CHK}), and pigs (\code{PGS}).
#' @param feed_ration_fraction Numeric proportion of a specific feed item in the total ration,
#'  expressed as its fraction of diet dry matter (fraction)
#' @param feed_urinary_energy_ruminant Numeric. Fraction of feed's gross energy that
#'  is excreted in urine for ruminants (fraction).
#' @param feed_urinary_energy_pigs Numeric. Fraction of feed's gross energy that
#'  is excreted in urine for pigs (fraction).
#' @param feed_urinary_energy_chicken Numeric. Fraction of feed's gross energy that
#'  is excreted in urine for chickens (fraction). Default to 0.
#'
#' @return Numeric. Fraction of feed's gross energy that is excreted in urine (fraction).
#'
#' @details
#' The urinary energy fraction contribution uses the animal-specific parameter:
#' \itemize{
#'   \item Ruminants: \code{feed_ration_fraction * feed_urinary_energy_ruminant}
#'   \item Chickens: \code{feed_ration_fraction * feed_urinary_energy_chicken}
#'   \item Pigs: \code{feed_ration_fraction * feed_urinary_energy_pigs}
#' }
#'
#' @export
calc_urinary_energy_fraction <- function(
    species_short,
    feed_ration_fraction,
    feed_urinary_energy_ruminant = NA_real_,
    feed_urinary_energy_pigs = NA_real_,
    feed_urinary_energy_chicken = 0
) {
  validate_urinary_energy_inputs(
    species_short,
    feed_ration_fraction,
    feed_urinary_energy_ruminant,
    feed_urinary_energy_pigs,
    feed_urinary_energy_chicken
  )

  # Apply the species-specific diet_urinary_energy
  if (species_short %in% c("CTL", "BFL", "CML", "SHP", "GTS")) {
    urinary_energy_fraction <- feed_ration_fraction * feed_urinary_energy_ruminant
  } else if (species_short == "CHK") {
    urinary_energy_fraction <- feed_ration_fraction * feed_urinary_energy_chicken
  } else {
    urinary_energy_fraction <- feed_ration_fraction * feed_urinary_energy_pigs
  }
  return(urinary_energy_fraction)
}

#' Calculate diet ash contribution for a ration component
#'
#' Computes ash contribution from a ration share and ash content.
#'
#' @param feed_ration_fraction Numeric proportion of a specific feed item in the total ration,
#'  expressed as its fraction of diet dry matter (fraction).
#' @param feed_ash_content Numeric. Average ash content by feed item,
#' calculated as a fraction of the dry matter intake (g ash/100g DM).
#'
#' @return Numeric. Average ash content of feed, calculated as a fraction of
#'  the dry matter intake (kg ash/kg DM).
#'
#' @details
#' The ash contribution is defined as:
#' \deqn{diet\_ash = feed\_ration\_fraction \times feed\_ash\_content / 100}
#'
#' Ash content is expressed as a percentage; the result is a fraction.
#'
#' @export
calc_diet_ash <- function(feed_ration_fraction, feed_ash_content) {
  validate_diet_ash_inputs(feed_ration_fraction, feed_ash_content)

  # Contribution is ration share multiplied by feed_ash_content
  diet_ash <- feed_ration_fraction * feed_ash_content / 100

  return(diet_ash)
}
