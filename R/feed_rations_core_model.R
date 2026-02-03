#' Calculate energy digestibility ratio
#'
#' Computes digestibility as the ratio of digestible or metabolizable energy
#' to gross energy.
#'
#' @param energy_digestible Numeric. Digestible or metabolizable energy (same
#'   units as `energy_gross`).
#' @param energy_gross Numeric. Gross energy (same units as `energy_digestible`).
#'
#' @return Numeric. Digestibility ratio (unitless).
#'
#' @details
#' The digestibility ratio is defined as:
#' \deqn{digestibility = energy_digestible / energy_gross}
#'
#' This helper is vectorized over its inputs.
#'
#' @export
calc_energy_digestibility_ratio <- function(
    energy_digestible,
    energy_gross
) {
  validate_energy_digestibility_inputs(
    energy_digestible, energy_gross
  )
  # Ratio is unitless and vectorized by default
  digestibility <- energy_digestible / energy_gross
  return(digestibility)
}

#' Calculate diet digestibility contribution for a ration component
#'
#' Applies species-specific digestibility parameters to a ration share.
#'
#' @param animal Character. Species short code. Supported values include
#'   ruminants (\code{CTL}, \code{BFL}, \code{CML}, \code{SHP}, \code{GTS}),
#'   chickens (\code{CHK}), and pigs (\code{PGS}).
#' @param ration Numeric. Ration share for the feed component (fraction).
#' @param dig_ruminants Numeric. Digestibility ratio for ruminants.
#' @param dig_pigs Numeric. Digestibility ratio for pigs.
#' @param dig_chickens Numeric. Digestibility ratio for chickens.
#'
#' @return Numeric. Digestibility contribution for the ration component.
#'
#' @details
#' The digestibility contribution uses the animal-specific digestibility ratio:
#' \itemize{
#'   \item Ruminants: \code{ration * dig_ruminants}
#'   \item Chickens: \code{ration * dig_chickens}
#'   \item Pigs: \code{ration * dig_pigs}
#' }
#'
#' This helper is vectorized over its inputs.
#'
#' @export
calc_diet_digestibility <- function(
    animal,
    ration,
    dig_ruminants = NA_real_,
    dig_pigs = NA_real_,
    dig_chickens = NA_real_
) {
  validate_diet_digestibility_inputs(
    animal, ration, dig_ruminants, dig_pigs, dig_chickens
  )

  # Apply the species-specific digestibility coefficient
  if (animal %in% c("CTL", "BFL", "CML", "SHP", "GTS")) {
    diet_dig <- ration * dig_ruminants
  } else if (animal == "CHK") {
    diet_dig <- ration * dig_chickens
  } else {
    diet_dig <- ration * dig_pigs
  }
  return(diet_dig)
}

#' Calculate diet metabolizable energy contribution for a ration component
#'
#' Applies species-specific metabolizable energy parameters to a ration share.
#'
#' @param animal Character. Species short code. Supported values include
#'   ruminants (\code{CTL}, \code{BFL}, \code{CML}, \code{SHP}, \code{GTS}),
#'   chickens (\code{CHK}), and pigs (\code{PGS}).
#' @param ration Numeric. Ration share for the feed component (fraction).
#' @param me_ruminants Numeric. Metabolizable energy for ruminants.
#' @param me_pigs Numeric. Metabolizable energy for pigs.
#' @param me_chickens Numeric. Metabolizable energy for chickens.
#'
#' @return Numeric. Metabolizable energy contribution for the ration component.
#'
#' @details
#' The metabolizable energy contribution uses the animal-specific parameter:
#' \itemize{
#'   \item Ruminants: \code{ration * me_ruminants}
#'   \item Chickens: \code{ration * me_chickens}
#'   \item Pigs: \code{ration * me_pigs}
#' }
#'
#' This helper is vectorized over its inputs.
#'
#' @export
calc_diet_metabolizable_energy <- function(
    animal,
    ration,
    me_ruminants = NA_real_,
    me_pigs = NA_real_,
    me_chickens = NA_real_
) {
  validate_diet_metabolizable_energy_inputs(
    animal, ration, me_ruminants, me_pigs, me_chickens
  )

  # Apply the species-specific metabolizable energy parameter
  if (animal %in% c("CTL", "BFL", "CML", "SHP", "GTS")) {
    diet_me <- ration * me_ruminants
  } else if (animal == "CHK") {
    diet_me <- ration * me_chickens
  } else {
    diet_me <- ration * me_pigs
  }
  return(diet_me)
}

#' Calculate diet gross energy contribution for a ration component
#'
#' Computes gross energy contribution from a ration share and gross energy input.
#'
#' @param ration Numeric. Ration share for the feed component (fraction).
#' @param ge Numeric. Gross energy content (MJ/kg DM).
#'
#' @return Numeric. Gross energy contribution for the ration component.
#'
#' @details
#' The gross energy contribution is defined as:
#' \deqn{diet\_ge = ration \times ge}
#'
#' This helper is vectorized over its inputs.
#'
#' @export
calc_diet_gross_energy <- function(ration, ge) {
  validate_diet_gross_energy_inputs(ration, ge)
  # Contribution is ration share multiplied by gross energy content
  diet_ge <- ration * ge
  return(diet_ge)
}

#' Calculate diet nitrogen contribution for a ration component
#'
#' Computes nitrogen contribution from a ration share and nitrogen content.
#'
#' @param ration Numeric. Ration share for the feed component (fraction).
#' @param n_content Numeric. Nitrogen content (kg N/kg DM).
#'
#' @return Numeric. Nitrogen contribution for the ration component.
#'
#' @details
#' The nitrogen contribution is defined as:
#' \deqn{diet\_nitrogen = ration \times n\_content}
#'
#' This helper is vectorized over its inputs.
#'
#' @export
calc_diet_nitrogen_content <- function(ration, n_content) {
  validate_diet_nitrogen_inputs(ration, n_content)
  # Contribution is ration share multiplied by nitrogen content
  diet_nitrogen <- ration * n_content
  return(diet_nitrogen)
}
