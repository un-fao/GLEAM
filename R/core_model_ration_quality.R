#' Calculate feed digestibility fraction
#'
#' Computes species-specific feed digestibility fractions by feed component.
#'
#' @param feed_digestible_energy_ruminant Numeric. Digestible energy content of a
#'   feed component for ruminants, representing the energy absorbed by the animal after
#'   fecal losses (MJ/kg DM).
#' @param feed_digestible_energy_pigs Numeric. Digestible energy content of a feed
#'   component for pigs, representing the energy absorbed by the animal after fecal
#'   losses (MJ/kg DM).
#' @param feed_gross_energy Numeric. Gross energy content of a feed component,
#'   representing the total chemical energy released upon complete combustion of
#'   the feed (MJ/kg DM).
#'
#' @return List with elements:
#'   \describe{
#'     \item{feed_digestibility_fraction_ruminant}{
#'       Numeric. Digestibility of a feed component for ruminants, expressed as the ratio
#'       of digestible energy to gross energy content (fraction).
#'     }
#'     \item{feed_digestibility_fraction_pigs}{
#'       Numeric. Digestibility of a feed component for pigs, expressed as the ratio of
#'       digestible energy to gross energy content (fraction).
#'     }
#'   }
#'   
#' @details
#' Digestibility is computed as the ratio of usable energy to gross energy:
#' \deqn{feed\_digestibility\_fraction = usable\_energy / feed\_gross\_energy}
#'
#' For ruminants and pigs, usable energy is represented by \code{digestible_energy} (DE),
#' which accounts for fecal energy losses.
#'
#' @export
calc_feed_digestibility_fraction <- function(
    feed_digestible_energy_ruminant,
    feed_digestible_energy_pigs,
    feed_gross_energy
) {
  validate_feed_digestibility_inputs(
    feed_digestible_energy_ruminant,
    feed_digestible_energy_pigs,
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

  return(
    list(
      feed_digestibility_fraction_ruminant = feed_digestibility_fraction_ruminant,
      feed_digestibility_fraction_pigs = feed_digestibility_fraction_pigs
    )
  )
}

#' Calculate diet digestibility contribution for a ration component
#'
#' Applies species-specific digestibility parameters to a ration composition share to compute
#' the contribution of a single feed component to total diet digestibility.
#'
#' @param species_short Character. Code identifying the livestock species.
#'   Supported values include:
#'   \itemize{
#'     \item \code{PGS}: pigs
#'     \item \code{CML}: camels
#'     \item \code{CTL}: cattle
#'     \item \code{BFL}: buffalo
#'     \item \code{SHP}: sheep
#'     \item \code{GTS}: goats
#'   }
#' @param feed_ration_fraction Numeric. Proportion of a specific feed component in the
#'   total ration, expressed as its fraction of diet dry matter intake (fraction). Within
#'   each herd_id and cohort, proportions should sum to 1.
#' @param feed_digestibility_fraction_ruminant Numeric. Digestibility of a feed
#'   component for ruminants, expressed as the ratio of digestible energy to gross energy
#'   content (fraction).
#' @param feed_digestibility_fraction_pigs Numeric. Digestibility of a feed component
#'   for pigs, expressed as the ratio of digestible energy to gross energy content
#'   (fraction).
#'
#' @return Numeric. Contribution of the feed component to total diet digestibility (fraction).
#'
#' @details
#' The digestibility contribution uses the animal-specific digestibility ratio:
#' \itemize{
#'   \item Ruminants (\code{CTL}, \code{BFL}, \code{CML}, \code{SHP}, \code{GTS}):
#'     \code{feed_ration_fraction * feed_digestibility_fraction_ruminant}
#'   \item Pigs (\code{PGS}):
#'     \code{feed_ration_fraction * feed_digestibility_fraction_pigs}
#' }
#' @export
calc_ration_digestibility <- function(
    species_short,
    feed_ration_fraction,
    feed_digestibility_fraction_ruminant = NA_real_,
    feed_digestibility_fraction_pigs = NA_real_
) {
  validate_diet_digestibility_inputs(
    species_short,
    feed_ration_fraction,
    feed_digestibility_fraction_ruminant,
    feed_digestibility_fraction_pigs
  )

  # Apply the species-specific digestibility coefficient
  if (species_short %in% gleam_species_milk_producers) {
    ration_digestibility_fraction <- feed_ration_fraction * feed_digestibility_fraction_ruminant
  } else {
    ration_digestibility_fraction <- feed_ration_fraction * feed_digestibility_fraction_pigs
  }
  return(ration_digestibility_fraction)
}

#' Calculate diet metabolizable energy contribution for a ration component
#'
#' Applies species-specific metabolizable energy parameters to a ration composition share to
#' compute the contribution of a single feed component to total diet metabolizable
#' energy content.
#' 
#' @param species_short Character. Code identifying the livestock species.
#'   Supported values include:
#'   \itemize{
#'     \item \code{PGS}: pigs
#'     \item \code{CML}: camels
#'     \item \code{CTL}: cattle
#'     \item \code{BFL}: buffalo
#'     \item \code{SHP}: sheep
#'     \item \code{GTS}: goats
#'   }
#' @param feed_ration_fraction Numeric. Proportion of a specific feed component in the
#'   total ration, expressed as its fraction of diet dry matter intake (fraction). Within
#'   each herd_id and cohort, proportions should sum to 1.
#' @param feed_metabolizable_energy_ruminant Numeric. Metabolizable energy content
#'   of a feed component for ruminants, representing digestible energy minus energy
#'   losses in urine and gaseous products of digestion (MJ/kg DM).
#' @param feed_metabolizable_energy_pigs Numeric. Metabolizable energy content of a
#'   feed component for pigs, representing digestible energy minus energy losses in
#'   urine and gaseous products of digestion (MJ/kg DM).
#'
#' @return Numeric. Contribution of the feed component to total diet metabolizable energy content (MJ/kg DM).
#'
#' @details
#' The metabolizable energy contribution uses the animal-specific parameter:
#' \itemize{
#'   \item Ruminants (\code{CTL}, \code{BFL}, \code{CML}, \code{SHP}, \code{GTS}):
#'     \code{feed_ration_fraction * feed_metabolizable_energy_ruminant}
#'   \item Pigs (\code{PGS}):
#'     \code{feed_ration_fraction * feed_metabolizable_energy_pigs}
#' }
#'
#' @export
calc_ration_metabolizable_energy <- function(
    species_short,
    feed_ration_fraction,
    feed_metabolizable_energy_ruminant = NA_real_,
    feed_metabolizable_energy_pigs = NA_real_
) {
  validate_ration_metabolizable_energy_inputs(
    species_short,
    feed_ration_fraction,
    feed_metabolizable_energy_ruminant,
    feed_metabolizable_energy_pigs
  )

  # Apply the species-specific metabolizable energy parameter
  if (species_short %in% gleam_species_milk_producers) {
    ration_metabolizable_energy <- feed_ration_fraction * feed_metabolizable_energy_ruminant
  } else {
    ration_metabolizable_energy <- feed_ration_fraction * feed_metabolizable_energy_pigs
  }
  return(ration_metabolizable_energy)
}

#' Calculate diet gross energy contribution for a ration component
#'
#' Computes the contribution of a single feed component to diet gross energy content by
#' weighting feed gross energy by its ration composition share.
#'
#' @param feed_ration_fraction Numeric. Proportion of a specific feed component in the
#'   total ration, expressed as its fraction of diet dry matter intake (fraction). Within
#'   each herd_id and cohort, proportions should sum to 1.
#' @param feed_gross_energy Numeric. Gross energy content of a feed component,
#'   representing the total chemical energy released upon complete combustion of
#'   the feed (MJ/kg DM).
#'
#' @return Numeric. Contribution of the feed component to total diet gross energy content (MJ/kg DM).
#'
#' @details
#' The gross energy contribution is defined as:
#' \deqn{diet\_gross\_energy = feed\_ration\_fraction \times feed\_gross\_energy}
#'
#' @export
calc_ration_gross_energy <- function(feed_ration_fraction, feed_gross_energy) {
  validate_ration_gross_energy_inputs(feed_ration_fraction, feed_gross_energy)
  # Contribution is ration composition share multiplied by gross energy content
  ration_gross_energy <- feed_ration_fraction * feed_gross_energy
  return(ration_gross_energy)
}

#' Calculate diet nitrogen contribution for a ration component
#'
#' Computes the contribution of a single feed component to diet nitrogen content by
#' weighting feed nitrogen content by its ration composition share.
#'
#' @param feed_ration_fraction Numeric. Proportion of a specific feed component in the
#'   total ration, expressed as its fraction of diet dry matter intake (fraction). Within
#'   each herd_id and cohort, proportions should sum to 1.
#' @param feed_nitrogen_content Numeric. Nitrogen content of a feed component (kg N/kg DM).
#'
#' @return Numeric. Contribution of the feed component to total diet nitrogen content (kg N/kg DM).
#'
#' @details
#' The nitrogen contribution is defined as:
#' \deqn{diet\_nitrogen = feed\_ration\_fraction \times feed\_nitrogen\_content}
#'
#' @export
calc_ration_nitrogen_content <- function(feed_ration_fraction, feed_nitrogen_content) {
  validate_ration_nitrogen_inputs(feed_ration_fraction, feed_nitrogen_content)
  # Contribution is ration composition share multiplied by nitrogen content
  ration_nitrogen <- feed_ration_fraction * feed_nitrogen_content
  return(ration_nitrogen)
}

#' Calculate urinary energy fraction contribution for a ration component
#' 
#' Applies species-specific urinary energy fractions to a ration composition share to compute
#' the contribution of a feed component to urinary energy losses.
#'
#' @param species_short Character. Code identifying the livestock species.
#'   Supported values include:
#'   \itemize{
#'     \item \code{PGS}: pigs
#'     \item \code{CML}: camels
#'     \item \code{CTL}: cattle
#'     \item \code{BFL}: buffalo
#'     \item \code{SHP}: sheep
#'     \item \code{GTS}: goats
#'   }
#' @param feed_ration_fraction Numeric. Proportion of a specific feed component in the
#'   total ration, expressed as its fraction of diet dry matter intake (fraction). Within
#'   each herd_id and cohort, proportions should sum to 1.
#' @param feed_urinary_energy_ruminant Numeric. Fraction of feed's gross energy that
#'   is excreted in urine for ruminants (fraction).
#' @param feed_urinary_energy_pigs Numeric. Fraction of feed's gross energy that
#'   is excreted in urine for pigs (fraction).
#'
#' @return Numeric. Contribution of the feed component to the fraction of total diet
#'  gross energy that is excreted in urine (fraction).
#'
#' @details
#' The urinary energy fraction contribution uses the animal-specific parameter:
#' \itemize{
#'   \item Ruminants (\code{CTL}, \code{BFL}, \code{CML}, \code{SHP}, \code{GTS}):
#'     \code{feed_ration_fraction * feed_urinary_energy_ruminant}
#'   \item Pigs (\code{PGS}):
#'     \code{feed_ration_fraction * feed_urinary_energy_pigs}
#' }
#'
#' @export
calc_ration_urinary_energy_fraction <- function(
    species_short,
    feed_ration_fraction,
    feed_urinary_energy_ruminant = NA_real_,
    feed_urinary_energy_pigs = NA_real_
) {
  validate_urinary_energy_inputs(
    species_short,
    feed_ration_fraction,
    feed_urinary_energy_ruminant,
    feed_urinary_energy_pigs
  )

  # Apply the species-specific diet_urinary_energy
  if (species_short %in% gleam_species_milk_producers) {
    ration_urinary_energy_fraction <- feed_ration_fraction * feed_urinary_energy_ruminant
  } else {
    ration_urinary_energy_fraction <- feed_ration_fraction * feed_urinary_energy_pigs
  }
  return(ration_urinary_energy_fraction)
}

#' Calculate diet ash contribution for a ration component
#'
#' Computes the contribution of a single feed component to diet ash content by
#' weighting feed ash content by its ration composition share.
#'
#' @param feed_ration_fraction Numeric. Proportion of a specific feed component in the
#'   total ration, expressed as its fraction of diet dry matter intake (fraction). Within
#'   each herd_id and cohort, proportions should sum to 1.
#' @param feed_ash Numeric. Average ash content by feed component, expressed as
#'   a fraction of the dry matter intake (g ash/100g DM).
#'
#' @return Numeric. Contribution of the feed component to total diet ash content (kg ash/kg DM).
#'
#' @details
#' The ash contribution is defined as:
#' \deqn{ration\_ash = feed\_ration\_fraction \times feed\_ash / 100}
#'
#' Ash content is expressed as a percentage (g/100g DM); the result is a fraction.
#'
#' @export
calc_ration_ash <- function(feed_ration_fraction, feed_ash) {
  validate_ration_ash_inputs(feed_ration_fraction, feed_ash)

  # Contribution is ration composition share multiplied by feed_ash
  ration_ash <- feed_ration_fraction * feed_ash / 100

  return(ration_ash)
}
