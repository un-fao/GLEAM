#' Compute Milk Production Outputs
#'
#' Returns milk mass, protein, and FPCM using the IDF energy formulation while preserving
#' the legacy treatment of standard lactose.
#'
#' @param milk_yield Numeric. Milk yield per head per day (kg/day).
#' @param assessment_duration Numeric. Number of assessment days in the year used to annualise outputs.
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
#'   \item{output_milk_mass_production}{Numeric. Milk production (kg/year).}
#'   \item{output_milk_protein_production}{Numeric. Milk protein production (kg protein/year).}
#'   \item{output_milk_fpcm_production}{Numeric. Fat-protein-corrected milk production (kg FPCM/year).}
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

#' Compute Fibre Yield Per Head
#'
#' Calculates fibre yield per head per day (kg/head/day) for a single cohort row.
#'
#' @param fibre_prod Numeric. Total fibre production for the cohort group (kg/year).
#' @param fibre_cohorts_size Numeric. Total size of all fibre-producing cohorts in the group (heads).
#' @param assessment_duration Numeric. Number of assessment days used when annualising fibre output.
#' @param cohort Character. Cohort code for the current row.
#' @param non_fibre_cohorts Character vector. Cohort codes forced to zero fibre production.
#'
#' @return Numeric. Fibre yield per head per day (kg/head/day).
#' @export
compute_fibre_yield_per_head <- function(
  fibre_prod,
  fibre_cohorts_size,
  assessment_duration,
  cohort,
  non_fibre_cohorts
) {
  validate_fibre_yield_inputs(
    fibre_prod = fibre_prod,
    fibre_cohorts_size = fibre_cohorts_size,
    assessment_duration = assessment_duration,
    cohort = cohort,
    non_fibre_cohorts = non_fibre_cohorts
  )

  # Force zero for non-fibre cohorts
  if (cohort %in% non_fibre_cohorts) {
    return(0)
  }

  # Calculate fibre yield if there are fibre cohorts in the group
  if (fibre_cohorts_size > 0) {
    return((fibre_prod / fibre_cohorts_size) / assessment_duration)
  }

  return(0)
}

#' Compute Fibre Production
#'
#' @param fibre_yield Numeric. Fibre yield per head per day (kg/head/day).
#' @param assessment_duration Numeric. Number of assessment days used to annualise fibre output.
#' @param size Numeric. Herd size (heads) for the cohort.
#'
#' @return Numeric. Fibre production per cohort (kg/year).
#' @export
compute_fibre_output <- function(fibre_yield, assessment_duration, size) {
  validate_fibre_output_inputs(
    fibre_yield = fibre_yield,
    assessment_duration = assessment_duration,
    size = size
  )

  fibre_production <- fibre_yield * assessment_duration * size
  return(fibre_production)
}

#' Compute Meat Production Outputs
#'
#' Produces liveweight, carcass weight, boneless meat, and meat protein using the
#' sequential multipliers from the legacy implementation.
#'
#' @param offtake_number Numeric. Number of animals removed via offtake (head/year).
#' @param slaughter_weight Numeric. Live weight at slaughter (kg).
#' @param carcass_dressing_percentage Numeric. Dressing percentage applied to live weight (fraction).
#' @param bone_free_meat_fraction Numeric. Share of carcass that becomes boneless meat (fraction).
#' @param meat_protein Numeric. Protein fraction of boneless meat (kg protein per kg meat).
#'
#' @return Named list containing:
#'   \item{output_meat_production_liveweight}{Numeric. Meat production as live weight (kg/year).}
#'   \item{output_meat_production_carcassweight}{Numeric. Meat production as carcass weight (kg/year).}
#'   \item{output_meat_production_meat}{Numeric. Boneless meat production (kg/year).}
#'   \item{output_meat_production_protein}{Numeric. Meat protein production (kg protein/year).}
#' @export
compute_meat_outputs <- function(
  offtake_number,
  slaughter_weight,
  carcass_dressing_percentage,
  bone_free_meat_fraction,
  meat_protein
) {
  validate_meat_outputs_inputs(
    offtake_number = offtake_number,
    slaughter_weight = slaughter_weight,
    carcass_dressing_percentage = carcass_dressing_percentage,
    bone_free_meat_fraction = bone_free_meat_fraction,
    meat_protein = meat_protein
  )

  meat_production_liveweight <- offtake_number * slaughter_weight
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
