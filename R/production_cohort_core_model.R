#' Compute Milk Production Outputs
#'
#' Returns milk mass, protein, and FPCM using the IDF energy formulation while preserving
#' the legacy treatment of standard lactose.
#'
#' @param milk_yield Numeric. Milk yield per head per day (kg/day).
#' @param assessment_duration Numeric. Length of the assessment period (days)
#' @param size Numeric. Herd cohort size (heads).
#' @param milking_fraction Numeric. Share of the cohort that is milking during the assessment window.
#' @param milk_protein Numeric. Milk protein fraction (kg protein per kg milk).
#' @param milk_fat Numeric. Milk fat fraction (kg fat per kg milk).
#' @param lactose Numeric. Lactose fraction (kg lactose per kg milk). Note: Legacy implementation
#'   computed animal-specific lactose but used standard_lactose in the energy calculation.
#' @param standard_protein Numeric. Reference protein fraction used for FPCM energy.
#' @param standard_fat Numeric. Reference fat fraction used for FPCM energy.
#' @param standard_lactose Numeric. Reference lactose fraction used for FPCM energy.
#'
#' @return Named list containing:
#'   \item{output_milk_mass_production}{Numeric. Total milk production produced over the assessment period (kg/herd/assessment period).}
#'   \item{output_milk_protein_production}{Numeric. Total milk protein production produced over the assessment period (kg protein/herd/assessment period).}
#'   \item{output_milk_fpcm_production}{Numeric. Total Fat-protein-corrected milk (FPCM) produced over the assessment period  (kg/herd/assessment period). Default fat and protein content=0.04 and 0.033.}
#' @export
compute_milk_outputs <- function(
    milk_yield,
    assessment_duration,
    size,
    milking_fraction,
    milk_protein,
    milk_fat,
    lactose,
    standard_protein,
    standard_fat,
    standard_lactose
) {
  validate_milk_outputs_inputs(
    milk_yield = milk_yield,
    assessment_duration = assessment_duration,
    size = size,
    milking_fraction = milking_fraction,
    milk_protein = milk_protein,
    milk_fat = milk_fat,
    lactose = lactose,
    standard_protein = standard_protein,
    standard_fat = standard_fat,
    standard_lactose = standard_lactose
  )

  # Energy content of standard milk (Mcal/kg) - IDF 2022 formula
  energy_standard <- (0.0929 * standard_fat + 0.0547 * standard_protein + 0.0395 * standard_lactose)

  # Legacy spreadsheets computed the animal-specific lactose but retained the standard
  # lactose value in the subsequent energy calculation to remain consistent with IDF guidance.

  # Energy content of actual milk (legacy used standard_lactose here)
  energy_milk <- (0.0929 * milk_fat + 0.0547 * milk_protein + 0.0395 * standard_lactose)

  # Milk production (kg/head/year)
  milk_production <- milk_yield * assessment_duration * size * milking_fraction

  # Milk protein production (kg protein/year)
  milk_protein_production <- milk_production * milk_protein

  # FPCM production using energy ratio
  energy_ratio <- energy_milk / energy_standard
  fpcm_production <- energy_ratio * milk_production

  return(list(
    output_milk_mass_production = milk_production,
    output_milk_protein_production = milk_protein_production,
    output_milk_fpcm_production = fpcm_production
  ))
}

#' Compute Fibre Production
#'
#' @param fibre_prod Numeric. Fibre yield per head per year (kg/head/year).
#' @param assessment_duration Numeric. Length of the assessment period (days)
#' @param size Numeric. Herd size (heads) for the cohort.
#'
#' @return Numeric. Total fibre produced over the assessment period  by cohort (kg /cohort/assessment period).
#' @export
compute_fibre_output <- function(
    fibre_prod,
    assessment_duration,
    size
) {
  validate_fibre_output_inputs(
    fibre_prod = fibre_prod,
    assessment_duration = assessment_duration,
    size = size
  )

  fibre_production <- fibre_prod / 365 * assessment_duration * size
  return(fibre_production)
}

#' Compute Meat Production Outputs
#'
#' Produces liveweight, carcass weight, boneless meat, and meat protein using the
#' sequential multipliers from the legacy implementation.
#'
#' @param offtake_number_assessment Numeric. Number of animals removed via offtake (head/year).
#' @param slaughter_weight Numeric. Live weight at slaughter (kg).
#' @param carcass_dressing_percentage Numeric. Dressing percentage applied to live weight (fraction).
#' @param bone_free_meat_fraction Numeric. Share of carcass that becomes boneless meat (fraction).
#' @param meat_protein Numeric. Protein fraction of boneless meat (kg protein per kg meat).
#'
#' @return Named list containing:
#'   \item{output_meat_production_liveweight}{Numeric. Total meat produced as live weight over the assessment period by cohort (kg/cohort/year).}
#'   \item{output_meat_production_carcassweight}{Numeric. Total meat as carcass weight (excluding organs, and other by-products after dressing) produced over the assessment period by cohort, (kg/cohort/year).}
#'   \item{output_meat_production_meat}{Numeric. Total bone-free-meat (excluding bones, organs, and other by-products after dressing and bone removal) produced over the assessment period by cohort, (kg/cohort/year)}
#'   \item{output_meat_production_protein}{Numeric. Total meat protein (excluding bones, organs, and other by-products after dressing and bone removal) produced over the assessment period by cohort (kg protein/cohort/year).}
#' @export
compute_meat_outputs <- function(
    offtake_number_assessment,
    slaughter_weight,
    carcass_dressing_percentage,
    bone_free_meat_fraction,
    meat_protein,
    assessment_duration
) {
  validate_meat_outputs_inputs(
    offtake_number_assessment = offtake_number_assessment,
    slaughter_weight = slaughter_weight,
    carcass_dressing_percentage = carcass_dressing_percentage,
    bone_free_meat_fraction = bone_free_meat_fraction,
    meat_protein = meat_protein,
    assessment_duration = assessment_duration
  )

  meat_production_liveweight <- offtake_number_assessment * slaughter_weight
  meat_production_carcassweight <- meat_production_liveweight * carcass_dressing_percentage
  meat_production_meat <- meat_production_carcassweight * bone_free_meat_fraction
  meat_production_protein <- meat_production_meat * meat_protein

  return(list(
    output_meat_production_liveweight = meat_production_liveweight,
    output_meat_production_carcassweight = meat_production_carcassweight,
    output_meat_production_meat = meat_production_meat,
    output_meat_production_protein = meat_production_protein
  ))
}
