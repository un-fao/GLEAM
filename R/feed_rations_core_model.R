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
#' @param feed_metabolizable_energy_chicken Numeric. Metabolizable energy content
#'   of a feed component for chickens, representing digestible energy minus energy
#'   losses in uric acid and gaseous products of digestion (MJ/kg DM).
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
#'     \item{feed_digestibility_fraction_chicken}{
#'       Numeric. Digestibility of a feed component for chickens, expressed as the ratio
#'       of metabolizable energy to gross energy content (fraction).
#'     }
#'   }
#'   
#' @details
#' Digestibility is computed as the ratio of usable energy to gross energy:
#' \deqn{feed\_digestibility\_fraction = usable\_energy / feed\_gross\_energy}
#'
#' For ruminants and pigs, usable energy is represented by \code{digestible_energy} (DE),
#' which accounts for fecal energy losses. For chickens, \code{metabolizable_energy}
#' (ME) is used instead of \code{digestible_energy} because urinary losses (excreted as uric acid) and fecal
#' excretions are voided together, making fecal energy losses difficult to measure
#' separately. \code{metabolizable_energy} therefore provides a more appropriate and
#' standard measure of usable dietary energy in poultry nutrition.
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
#'     \item \code{CHK}: chickens
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
#' @param feed_digestibility_fraction_chicken Numeric. Digestibility of a feed
#'   component for chickens, expressed as the ratio of metabolizable energy to gross
#'   energy content (fraction).
#'
#' @return Numeric. Contribution of the feed component to total diet digestibility (fraction).
#'
#' @details
#' The digestibility contribution uses the animal-specific digestibility ratio:
#' \itemize{
#'   \item Ruminants (\code{CTL}, \code{BFL}, \code{CML}, \code{SHP}, \code{GTS}):
#'     \code{feed_ration_fraction * feed_digestibility_fraction_ruminant}
#'   \item Chickens (\code{CHK}):
#'     \code{feed_ration_fraction * feed_digestibility_fraction_chicken}
#'   \item Pigs (\code{PGS}):
#'     \code{feed_ration_fraction * feed_digestibility_fraction_pigs}
#' }
#' @export
calc_ration_digestibility <- function(
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
#'     \item \code{CHK}: chickens
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
#' @param feed_metabolizable_energy_chicken Numeric. Metabolizable energy content
#'   of a feed component for chickens, representing digestible energy minus energy
#'   losses in uric acid and gaseous products of digestion (MJ/kg DM).
#'
#' @return Numeric. Contribution of the feed component to total diet metabolizable energy content (MJ/kg DM).
#'
#' @details
#' The metabolizable energy contribution uses the animal-specific parameter:
#' \itemize{
#'   \item Ruminants (\code{CTL}, \code{BFL}, \code{CML}, \code{SHP}, \code{GTS}):
#'     \code{feed_ration_fraction * feed_metabolizable_energy_ruminant}
#'   \item Chickens (\code{CHK}):
#'     \code{feed_ration_fraction * feed_metabolizable_energy_chicken}
#'   \item Pigs (\code{PGS}):
#'     \code{feed_ration_fraction * feed_metabolizable_energy_pigs}
#' }
#'
#' @export
calc_ration_metabolizable_energy <- function(
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
  validate_diet_gross_energy_inputs(feed_ration_fraction, feed_gross_energy)
  # Contribution is ration composition share multiplied by gross energy content
  diet_gross_energy <- feed_ration_fraction * feed_gross_energy
  return(diet_gross_energy)
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
  validate_diet_nitrogen_inputs(feed_ration_fraction, feed_nitrogen_content)
  # Contribution is ration composition share multiplied by nitrogen content
  diet_nitrogen <- feed_ration_fraction * feed_nitrogen_content
  return(diet_nitrogen)
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
#'     \item \code{CHK}: chickens
#'   }
#' @param feed_ration_fraction Numeric. Proportion of a specific feed component in the
#'   total ration, expressed as its fraction of diet dry matter intake (fraction). Within
#'   each herd_id and cohort, proportions should sum to 1.
#' @param feed_urinary_energy_ruminant Numeric. Fraction of feed's gross energy that
#'   is excreted in urine for ruminants (fraction).
#' @param feed_urinary_energy_pigs Numeric. Fraction of feed's gross energy that
#'   is excreted in urine for pigs (fraction).
#' @param feed_urinary_energy_chicken Numeric. Fraction of feed's gross energy that
#'   is excreted in uric acid for chickens (fraction). Default = 0.
#'
#' @return Numeric. Contribution of the feed component to the fraction of total diet
#'  gross energy that is excreted in urine (fraction).
#'
#' @details
#' The urinary energy fraction contribution uses the animal-specific parameter:
#' \itemize{
#'   \item Ruminants (\code{CTL}, \code{BFL}, \code{CML}, \code{SHP}, \code{GTS}):
#'     \code{feed_ration_fraction * feed_urinary_energy_ruminant}
#'   \item Chickens (\code{CHK}):
#'     \code{feed_ration_fraction * feed_urinary_energy_chicken}
#'   \item Pigs (\code{PGS}):
#'     \code{feed_ration_fraction * feed_urinary_energy_pigs}
#' }
#' 
#' For chickens, \code{feed_urinary_energy_chicken} defaults to 0 because urinary
#' energy losses are accounted for within \code{metabolizable_energy} in poultry
#' nutrition (urine and feces are excreted together), and are therefore not modeled
#' as a separate fraction of gross energy.
#'
#' @export
calc_ration_urinary_energy_fraction <- function(
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
#' Computes the contribution of a single feed component to diet ash content by
#' weighting feed ash content by its ration composition share.
#'
#' @param feed_ration_fraction Numeric. Proportion of a specific feed component in the
#'   total ration, expressed as its fraction of diet dry matter intake (fraction). Within
#'   each herd_id and cohort, proportions should sum to 1.
#' @param feed_ash_content Numeric. Average ash content by feed component, expressed as
#'   a fraction of the dry matter intake (g ash/100g DM).
#'
#' @return Numeric. Contribution of the feed component to total diet ash content (kg ash/kg DM).
#'
#' @details
#' The ash contribution is defined as:
#' \deqn{diet\_ash = feed\_ration\_fraction \times feed\_ash\_content / 100}
#'
#' Ash content is expressed as a percentage (g/100g DM); the result is a fraction.
#'
#' @export
calc_ration_ash <- function(feed_ration_fraction, feed_ash_content) {
  validate_diet_ash_inputs(feed_ration_fraction, feed_ash_content)

  # Contribution is ration composition share multiplied by feed_ash_content
  diet_ash <- feed_ration_fraction * feed_ash_content / 100

  return(diet_ash)
}
