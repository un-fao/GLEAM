#' Compute Milk Production Outputs
#'
#' Computes total milk production for a producing cohort (\code{FA}) over the assessment
#' period and returns multiple production metrics: total milk mass,
#' milk protein, and fat-protein-corrected milk (FPCM).
#' All outputs are expressed in kg per cohort per assessment period.
#'
#' FPCM is calculated using Equation 10 of the International Dairy Federation
#' (IDF) Global Carbon Footprint Standard for the Dairy Sector (IDF, 2022).
#'
#' @param cohort Character. Sex- and age-specific cohort code describing the
#'   production stage of the animals. Supported values include:
#'   \itemize{
#'     \item \code{FA}: adult females (from age at first parturition)
#'     \item \code{FS}: sub-adult females (from weaning to age at first parturition)
#'     \item \code{FJ}: juvenile females (from birth to weaning)
#'     \item \code{MA}: adult males (from age at first breeding)
#'     \item \code{MS}: sub-adult males (from weaning to age at first breeding)
#'     \item \code{MJ}: juvenile males (from birth to weaning)
#'   }
#' @param milk_yield Numeric.  Average milk yield per milk-producing animal during the assessment duration (kg/head/day).
#' This value can be calculated by dividing the total milk destined to human consumption produced per milk-producing animal over the assessment duration by the length of the assessment period.
#' @param assessment_duration Numeric. Length of the assessment period (days).
#' @param size Numeric. Population size in each of the 6 sex–age cohorts: adult females (FA), sub-adult females (FS), juvenile females (FJ), adult males (MA), sub-adult males (MS), and juvenile males (MJ) at the start of the year (heads).
#' @param milking_fraction Numeric. Share of adult females lactating within the assessment duration (fraction). Applies to species: camels (CML), cattle (CTL), buffalo (BFL), sheep (SHP) and goats (GTS).
#' @param milk_protein Numeric. Milk protein fraction (kg protein/kg milk).
#' @param milk_fat Numeric. Milk fat fraction (kg fat/kg milk).
#' @param lactose Numeric. Milk lactose fraction (kg lactose/kg milk).
#' @param standard_protein Numeric. Standard protein content of milk, used to calculate Fat-protein-corrected milk (FPCM), (kg protein/kg milk). Default used=0.033.
#' @param standard_fat Numeric. Standard fat content of milk, used to calculate Fat-protein-corrected milk (FPCM), (kg fat/kg milk). Default used=0.04.
#' @param standard_lactose Numeric. Standard lactose content of milk, used to calculate Fat-protein-corrected milk (FPCM) , (kg lactose/kg milk). Default used=0.048.
#'
#' @return Named list containing:
#'   \item{output_milk_mass_production}{Numeric. Total milk production produced over the assessment period (kg/herd/assessment period).}
#'   \item{output_milk_protein_production}{Numeric. Total milk protein production produced over the assessment period (kg protein/herd/assessment period).}
#'   \item{output_milk_fpcm_production}{Numeric. Total Fat-protein-corrected milk (FPCM) produced over the assessment period (kg/herd/assessment period). Default fat and protein content=0.04 and 0.033.}
#'
#' Non-zero milk outputs are only expected for adult female cohorts. All other
#' cohorts should return zero milk production through upstream parameterisation.
#'
#' @references
#' International Dairy Federation (IDF). 2022.
#' *The IDF Global Carbon Footprint Standard for the Dairy Sector*.
#' Bulletin of the IDF No. 520/2022.
#' International Dairy Federation (ed.), Brussels, Belgium.
#' @export

compute_milk_outputs <- function(
    cohort,
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
    cohort = cohort,
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
  
  if (cohort == "FA"){

  # Energy content of standard milk (Mcal/kg) - IDF 2022 formula
  energy_standard <- (0.0929 * standard_fat + 0.0547 * standard_protein + 0.0395 * standard_lactose)

  # Energy content of actual milk
  energy_milk <- (0.0929 * milk_fat + 0.0547 * milk_protein + 0.0395 * lactose)

  # Milk production (kg/head/year)
  milk_production <- milk_yield * assessment_duration * size * milking_fraction

  # Milk protein production (kg protein/year)
  milk_protein_production <- milk_production * milk_protein

  # FPCM production using energy ratio
  energy_ratio <- energy_milk / energy_standard
  fpcm_production <- energy_ratio * milk_production
  
  } else {
  milk_production <- 0
  milk_protein_production <- 0
  fpcm_production <- 0
  }
    
  return(list(
    output_milk_mass_production = milk_production,
    output_milk_protein_production = milk_protein_production,
    output_milk_fpcm_production = fpcm_production
  ))
}

#' Compute Fibre Production
#'
#' Computes fibre production for producing cohorts (\code{FA}, \code{MA}, \code{FS}, \code{MS})  by scaling per-animal
#' fibre yield to the assessment period and cohort size.
#' The output is expressed in kg per cohort per assessment period.
#' 
#' @param cohort Character. Sex- and age-specific cohort code describing the
#'   production stage of the animals. Supported values include:
#'   \itemize{
#'     \item \code{FA}: adult females (from age at first parturition)
#'     \item \code{FS}: sub-adult females (from weaning to age at first parturition)
#'     \item \code{FJ}: juvenile females (from birth to weaning)
#'     \item \code{MA}: adult males (from age at first breeding)
#'     \item \code{MS}: sub-adult males (from weaning to age at first breeding)
#'     \item \code{MJ}: juvenile males (from birth to weaning)
#'   }
#' @param fibre_prod Numeric. Annual production yield of fibre, such as wool, cashmere, mohair (kg/head/year).
#' @param assessment_duration Numeric. Length of the assessment period (days).
#' @param size Numeric. Population size in each of the 6 sex–age cohorts: adult females (FA), sub-adult females (FS), juvenile females (FJ), adult males (MA), sub-adult males (MS), and juvenile males (MJ) at the start of the year (heads).
#'
#' @return Numeric. Total fibre produced over the assessment period by cohort (kg /cohort/assessment period).
#'
#' Cohorts that do not produce fibre should return zero output through
#' upstream parameterisation.
#'
#' @export
compute_fibre_output <- function(
    cohort = cohort,
    fibre_prod,
    assessment_duration,
    size
) {
  validate_fibre_output_inputs(
    cohort = cohort,
    fibre_prod = fibre_prod,
    assessment_duration = assessment_duration,
    size = size
  )
  
  if (cohort %in% c("FA", "FS", "MA", "MS")) {
    
  fibre_production <- fibre_prod / 365 * assessment_duration * size
  
    } else {
    fibre_production <- 0
  }
    
  
  return(fibre_production)
}

#' Compute Meat Production Outputs
#'
#' Computes meat production outputs at the animal cohort level based on
#' the number of animals removed from the herd during the assessment
#' period.
#' The function returns multiple meat production metrics, including total meat production
#' expressed in live weight, carcass weight, boneless meat, and meat protein.
#' All outputs are expressed in kg per cohort per assessment period.
#'
#' @param offtake_number_assessment Numeric. Total number of animals removed via offtake over the assessment period, aggregated to 6 sex–age cohorts: adult females (FA), sub-adult females (FS), juvenile females (FJ), adult males (MA), sub-adult males (MS), and juvenile males (MJ) (heads/year).
#' @param slaughter_weight Numeric. Live weight at slaughter for animals removed from the cohort (kg).
#' @param carcass_dressing_percentage Numeric. Ratio of a slaughtered animal's carcass weight to its live weight (fraction).
#' @param bone_free_meat_fraction Numeric. Ratio of bone-free-meat to carcass weight (fraction).
#' @param meat_protein Numeric. Protein content of bone-free-meat (kg protein/kg bone-free-meat).
#'
#' @return Named list containing:
#'   \item{output_meat_production_liveweight}{Numeric. Total meat produced as live weight over the assessment period by cohort (kg/cohort/assessment period).}
#'   \item{output_meat_production_carcassweight}{Numeric. Total meat as carcass weight (excluding organs, and other by-products after dressing) produced over the assessment period by cohort (kg/cohort/assessment period).}
#'   \item{output_meat_production_meat}{Numeric. Total bone-free-meat (excluding bones, organs, and other by-products after dressing and bone removal) produced over the assessment period by cohort (kg/cohort/assessment period)}
#'   \item{output_meat_production_protein}{Numeric. Total meat protein (excluding bones, organs, and other by-products after dressing and bone removal) produced over the assessment period by cohort (kg protein/cohort/assessment period).}
#'
#' Cohorts with no offtake during the assessment period should return
#' zero outputs through upstream parameterisation (e.g. `offtake_number = 0`).
#'
#' @export
compute_meat_outputs <- function(
    offtake_number_assessment,
    slaughter_weight,
    carcass_dressing_percentage,
    bone_free_meat_fraction,
    meat_protein
) {
  validate_meat_outputs_inputs(
    offtake_number_assessment = offtake_number_assessment,
    slaughter_weight = slaughter_weight,
    carcass_dressing_percentage = carcass_dressing_percentage,
    bone_free_meat_fraction = bone_free_meat_fraction,
    meat_protein = meat_protein
  )

  meat_production_liveweight <- offtake_number_assessment * slaughter_weight
  meat_production_carcassweight <- meat_production_liveweight * carcass_dressing_percentage
  meat_production_meat <- meat_production_carcassweight * bone_free_meat_fraction
  meat_production_protein <- meat_production_meat * meat_protein

  return(
    list(
      output_meat_production_liveweight = meat_production_liveweight,
      output_meat_production_carcassweight = meat_production_carcassweight,
      output_meat_production_meat = meat_production_meat,
      output_meat_production_protein = meat_production_protein
    )
  )
}
