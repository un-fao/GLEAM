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
#' @param cohort_short Character. Sex- and age-specific cohort code describing the
#'   production stage of the animals. Supported values include:
#'   \itemize{
#'     \item \code{FA}: adult females (from age at first parturition)
#'     \item \code{FS}: sub-adult females (from weaning to age at first parturition)
#'     \item \code{FJ}: juvenile females (from birth to weaning)
#'     \item \code{MA}: adult males (from age at first breeding)
#'     \item \code{MS}: sub-adult males (from weaning to age at first breeding)
#'     \item \code{MJ}: juvenile males (from birth to weaning)
#'   }
#' @param milk_yield_day Numeric. Average milk yield per milk-producing animal during the assessment
#'   duration (kg/head/day).
#' @param simulation_duration Numeric. Length of the assessment period (days).
#' @param cohort_stock_size Numeric. Population size in each of the 6 sex–age cohorts: adult females (FA),
#'   sub-adult females (FS), juvenile females (FJ), adult males (MA), sub-adult males (MS), and juvenile
#'   males (MJ) at the start of the year (heads).
#' @param lactating_females_fraction Numeric. Share of adult females lactating within the assessment
#'   duration. Applies to species = CML, CTL, BFL, SHP, GTS. (fraction).
#' @param milk_protein_fraction Numeric. Milk protein fraction (kg protein/kg milk).
#' @param milk_fat_fraction Numeric. Milk fat fraction (kg fat/kg milk).
#' @param milk_lactose_fraction Numeric. Milk lactose fraction (kg lactose/kg milk).
#' @param milk_protein_fraction_standard Numeric. Standard protein content of milk, used to calculate
#'   Fat-protein-corrected milk (FPCM), (kg protein/kg milk). Default used=0.033.
#' @param milk_fat_fraction_standard Numeric. Standard fat content of milk, used to calculate
#'   Fat-protein-corrected milk (FPCM), (kg fat/kg milk). Default used=0.04.
#' @param milk_lactose_fraction_standard Numeric. Standard lactose content of milk, used to calculate
#'   Fat-protein-corrected milk (FPCM), (kg lactose/kg milk). Default used=0.048.
#'
#' @return Named list containing:
#'   \item{milk_production_mass_cohort}{Numeric. Total milk produced over the assessment period
#'     (kg milk / cohort / assessment period).}
#'   \item{milk_production_protein_cohort}{Numeric. Total milk protein produced over the assessment
#'     period (kg protein / cohort / assessment period).}
#'   \item{milk_production_fpcm_cohort}{Numeric. Total fat-protein-corrected milk (FPCM) produced over
#'     the assessment period, calculated using IDF (2022) energy-based correction with standard
#'     composition (kg FPCM / cohort / assessment period).}
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
    species_short,  
    cohort_short,
    milk_yield_day,
    simulation_duration,
    cohort_stock_size,
    lactating_females_fraction,
    milk_protein_fraction,
    milk_fat_fraction,
    milk_lactose_fraction,
    milk_protein_fraction_standard,
    milk_fat_fraction_standard,
    milk_lactose_fraction_standard
) {
  validate_milk_outputs_inputs(
    species_short = species_short,
    cohort_short = cohort_short,
    milk_yield_day = milk_yield_day,
    simulation_duration = simulation_duration,
    cohort_stock_size = cohort_stock_size,
    lactating_females_fraction = lactating_females_fraction,
    milk_protein_fraction = milk_protein_fraction,
    milk_fat_fraction = milk_fat_fraction,
    milk_lactose_fraction = milk_lactose_fraction,
    milk_protein_fraction_standard = milk_protein_fraction_standard,
    milk_fat_fraction_standard = milk_fat_fraction_standard,
    milk_lactose_fraction_standard = milk_lactose_fraction_standard
  )
  
  milk_production <- 0
  milk_protein_production <- 0
  fpcm_production <- 0
  
  if (species_short %in% c("CTL", "BFL", "SHP", "GTS", "CML")) {
    if (cohort_short == "FA") {

    # Energy content of standard milk (Mcal/kg) - IDF 2022 formula
    energy_standard <- (
      0.0929 * milk_fat_fraction_standard +
      0.0547 * milk_protein_fraction_standard +
      0.0395 * milk_lactose_fraction_standard
    )

    # Energy content of actual milk
    energy_milk <- (
      0.0929 * milk_fat_fraction +
      0.0547 * milk_protein_fraction +
      0.0395 * milk_lactose_fraction
    )

    # Milk production (kg/head/year)
    milk_production <- (
      milk_yield_day * simulation_duration * cohort_stock_size * lactating_females_fraction
    )

    # Milk protein production (kg protein/year)
    milk_protein_production <- milk_production * milk_protein_fraction

    # FPCM production using energy ratio
    energy_ratio <- energy_milk / energy_standard
    fpcm_production <- energy_ratio * milk_production
    } 
  }
  return(list(
    milk_production_mass_cohort = milk_production,
    milk_production_protein_cohort = milk_protein_production,
    milk_production_fpcm_cohort = fpcm_production
  ))
}

#' Compute Fibre Production
#'
#' Computes fibre production for producing cohorts (\code{FA}, \code{MA}, \code{FS}, \code{MS}) by scaling
#' per-animal fibre yield to the assessment period and cohort size.
#' The output is expressed in kg per cohort per assessment period.
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
#' @param cohort_short Character. Sex- and age-specific cohort code describing the
#'   production stage of the animals. Supported values include:
#'   \itemize{
#'     \item \code{FA}: adult females (from age at first parturition)
#'     \item \code{FS}: sub-adult females (from weaning to age at first parturition)
#'     \item \code{FJ}: juvenile females (from birth to weaning)
#'     \item \code{MA}: adult males (from age at first breeding)
#'     \item \code{MS}: sub-adult males (from weaning to age at first breeding)
#'     \item \code{MJ}: juvenile males (from birth to weaning)
#'   }
#' @param fibre_yield_year Numeric. Annual production yield of fibre, such as wool, cashmere, mohair
#'   (kg/head/year).
#' @param simulation_duration Numeric. Length of the assessment period (days).
#' @param cohort_stock_size Numeric. Population size in each of the 6 sex–age cohorts: adult females (FA),
#'   sub-adult females (FS), juvenile females (FJ), adult males (MA), sub-adult males (MS), and juvenile
#'   males (MJ) at the start of the year (heads).
#'
#' @return Numeric. Total fibre produced over the assessment period (kg fibre / cohort / assessment
#'   period).
#'
#' Cohorts that do not produce fibre should return zero output through
#' upstream parameterisation.
#'
#' @export
compute_fibre_output <- function(
    species_short,
    cohort_short,
    fibre_yield_year,
    simulation_duration,
    cohort_stock_size
) {
  validate_fibre_output_inputs(
    species_short = species_short,
    cohort_short = cohort_short,
    fibre_yield_year = fibre_yield_year,
    simulation_duration = simulation_duration,
    cohort_stock_size = cohort_stock_size
  )
  
  fibre_production_cohort <- 0
  
  if (species_short %in% c("GTS", "SHP", "CML")) {
    if (cohort_short %in% c("FA", "FS", "MA", "MS")) {

    fibre_production_cohort <- (
      fibre_yield_year / 365 * simulation_duration * cohort_stock_size
    )
    }
  }
  
  return(fibre_production_cohort)
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
#' @param offtake_heads_assessment Numeric. Total number of animals removed via offtake over the
#'   assessment period, aggregated to 6 sex–age cohorts (cohorts = FJ, FS, FA, MJ, MS, MA)
#'   (heads/year).
#' @param slaughter_weight_cohort Numeric. Live weight at slaughter for animals removed from the
#'   cohort (kg).
#' @param carcass_dressing_fraction Numeric. Ratio of a slaughtered animal's carcass weight to its
#'   live weight (fraction).
#' @param bone_free_meat_fraction Numeric. Ratio of bone-free-meat to carcass weight (fraction).
#' @param meat_protein_fraction Numeric. Protein content of bone-free-meat (fraction).
#'
#' @return Named list containing:
#'   \item{meat_production_live_weight_cohort}{Numeric. Total meat produced expressed as live weight
#'     removed via offtake (kg live weight / cohort / assessment period).}
#'   \item{meat_production_carcass_weight_cohort}{Numeric. Total carcass weight produced after
#'     dressing (kg carcass weight / cohort / assessment period).}
#'   \item{meat_production_bone_free_meat_cohort}{Numeric. Total bone-free meat produced (kg meat /
#'     cohort / assessment period).}
#'   \item{meat_production_protein_cohort}{Numeric. Total meat protein produced (kg protein / cohort
#'     / assessment period).}
#'
#' Cohorts with no offtake during the assessment period should return
#' zero outputs through upstream parameterisation (e.g. `offtake_number = 0`).
#'
#' @export
compute_meat_outputs <- function(
    offtake_heads_assessment,
    slaughter_weight_cohort,
    carcass_dressing_fraction,
    bone_free_meat_fraction,
    meat_protein_fraction
) {
  validate_meat_outputs_inputs(
    offtake_heads_assessment = offtake_heads_assessment,
    slaughter_weight_cohort = slaughter_weight_cohort,
    carcass_dressing_fraction = carcass_dressing_fraction,
    bone_free_meat_fraction = bone_free_meat_fraction,
    meat_protein_fraction = meat_protein_fraction
  )

  meat_production_live_weight_cohort <- offtake_heads_assessment * slaughter_weight_cohort
  meat_production_carcass_weight_cohort <- (
    meat_production_live_weight_cohort * carcass_dressing_fraction
  )
  meat_production_bone_free_meat_cohort <- (
    meat_production_carcass_weight_cohort * bone_free_meat_fraction
  )
  meat_production_protein_cohort <- (
    meat_production_bone_free_meat_cohort * meat_protein_fraction
  )

  return(
    list(
      meat_production_live_weight_cohort = meat_production_live_weight_cohort,
      meat_production_carcass_weight_cohort = meat_production_carcass_weight_cohort,
      meat_production_bone_free_meat_cohort = meat_production_bone_free_meat_cohort,
      meat_production_protein_cohort = meat_production_protein_cohort
    )
  )
}
