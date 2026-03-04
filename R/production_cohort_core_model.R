#' Compute Milk Production Outputs
#'
#' Computes total milk production for the producing cohort (\code{FA}) of milk-producing species
#' (\code{CML}, \code{CTL}, \code{BFL}, \code{SHP}, \code{GTS}) over the assessment period and returns
#' multiple production metrics: total milk mass, milk protein, and fat-protein-corrected milk (FPCM)
#' (kg/cohort/assessment period).
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
#' @param cohort_short Character. Sex- and age-specific cohort code describing the production stage of the animals.
#' Supported values include:
#'       \itemize{
#'         \item \code{FA}: adult females (from age at first parturition)
#'         \item \code{FS}: sub-adult females (from weaning to age at first parturition)
#'         \item \code{FJ}: juvenile females (from birth to weaning)
#'         \item \code{MA}: adult males (from age at first breeding)
#'         \item \code{MS}: sub-adult males (from weaning to age at first breeding)
#'         \item \code{MJ}: juvenile males (from birth to weaning)
#'       }
#' @param milk_yield_day {Numeric. Average milk yield per milk-producing animal during the assessment duration
#' (kg/head/day).
#' This value is calculated as the total quantity of milk produced for human consumption by milk-producing animals
#' during the assessment period,
#' divided by the number of milk-producing animals, and the length of the assessment period (days). Required only for
#' species = CML, CTL, BFL, SHP, and GTS.}
#' @param simulation_duration Numeric. Length of the assessment period (days).
#' @param cohort_stock_size Numeric. Average population size in each of the 6 sex–age cohorts (# heads). (cohorts=FJ,
#' FS, FA, MJ, MS, MA).
#' @param lactating_females_fraction Numeric. Proportion of adult females that are lactating during the assessment
#' period (fraction). Required only for species: CML, CTL, BFL, SHP, and GTS.
#' @param milk_protein_fraction Numeric. Milk protein fraction (kg protein/kg milk). Required only for species = CML,
#' CTL, BFL, SHP, and GTS.
#' @param milk_fat_fraction Numeric. Milk fat fraction (kg fat/kg milk). Required only for species = CML, CTL, BFL, SHP,
#' and GTS.
#' @param milk_lactose_fraction Numeric. Milk lactose fraction (kg lactose/kg milk). Required only for species = CML,
#' CTL, BFL, SHP, and GTS.
#' @param milk_protein_fraction_standard Numeric. Standard protein content of milk, used to calculate
#' Fat-protein-corrected milk (FPCM), (kg protein/kg milk). Suggested value = 0.033.
#' @param milk_fat_fraction_standard Numeric. Standard fat content of milk, used to calculate Fat-protein-corrected milk
#' (FPCM), (kg fat/kg milk). Suggested value = 0.04.
#' @param milk_lactose_fraction_standard Numeric. Standard lactose content of milk, used to calculate
#' Fat-protein-corrected milk (FPCM) , (kg lactose/kg milk). Suggested value = 0.048.
#'
#' @return A named list with:
#' \describe{
#' \item{milk_production_mass_cohort}{Numeric. Total milk production produced over the assessment period
#' (kg/cohort/assessment period).}
#' \item{milk_production_protein_cohort}{Numeric. Total milk protein production produced over the assessment period (kg
#' protein/cohort/assessment period).}
#' \item{milk_production_fpcm_cohort}{Numeric. Total fat-protein-corrected milk (FPCM) produced over the assessment
#' period (kg/cohort/assessment period).}
#' }
#' 
#' @details
#' Milk production outputs are computed as follows:
#' \itemize{
#'   \item \strong{\code{milk_production_mass_cohort}} is computed as:
#'
#'   \eqn{milk\_production =
#'   milk\_yield\_day \times simulation\_duration \times cohort\_stock\_size \times lactating\_females\_fraction}
#'
#'   \item \strong{\code{milk_production_protein_cohort}} is computed as:
#'
#'   \eqn{milk\_protein\_production =
#'   milk\_production \times milk\_protein\_fraction}
#'
#'   \item \strong{\code{milk_production_fpcm_cohort}} is computed using the ratio of
#'   energy content of actual versus standard milk:
#'
#'   \eqn{FPCM = milk\_production \times \frac{E_{milk}}{E_{standard}}}
#'
#'   where milk energy content (Mcal/kg) is computed as (IDF, 2022):
#'
#'   \eqn{E_{milk} =
#'   0.0929 \times milk\_fat\_fraction +
#'   0.0547 \times milk\_protein\_fraction +
#'   0.0395 \times milk\_lactose\_fraction}
#'
#'   \eqn{E_{standard} =
#'   0.0929 \times milk\_fat\_fraction\_standard +
#'   0.0547 \times milk\_protein\_fraction\_standard +
#'   0.0395 \times milk\_lactose\_fraction\_standard}
#' }
#'
#' Non-zero milk outputs are only expected for adult female cohorts of
#' milk-producing species.
#'
#' @references
#' International Dairy Federation (IDF). 2022.
#' \emph{The IDF Global Carbon Footprint Standard for the Dairy Sector}.
#' Bulletin of the IDF No. 520/2022. International Dairy Federation (ed.), Brussels, Belgium.
#' Equation 10.
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
#' Computes fibre production for producing cohorts (\code{FA}, \code{FS}, \code{MA}, \code{MS})
#' of fibre-producing species (\code{CML}, \code{SHP}, \code{GTS}) over the assessment period
#' (kg/cohort/assessment period).
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
#' @param fibre_yield_year Numeric. Annual production yield of fibre, such as wool, cashmere, mohair (kg/head/year).
#' Required only for species = CML, SHP, and GTS.
#' @param simulation_duration Numeric. Length of the assessment period (days).
#' @param cohort_stock_size Numeric. Average population size in each of the 6 sex–age cohorts (# heads). (cohorts=FJ,
#' FS, FA, MJ, MS, MA).
#'
#' @return Numeric. Total fibre produced over the assessment period by cohort (kg /cohort/assessment period).
#'   
#' @details
#' Fibre production outputs are computed as follows:
#'
#'   \eqn{fibre\_production =
#'   \frac{fibre\_yield\_year}{365} \times simulation\_duration \times cohort\_stock\_size}
#'
#' Non-zero fibre outputs are only expected for producing cohorts (\code{FA}, \code{FS}, \code{MA}, \code{MS})
#' of fibre-producing species (\code{CML}, \code{SHP}, \code{GTS}).
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
#' Computes cohort-level meat production outputs over the assessment period based on
#' the number of animals removed from the herd (offtake). The function returns
#' multiple production metrics expressed in live weight, carcass weight,
#' bone-free meat, and meat protein (kg/cohort/assessment period).
#'
#' @param offtake_heads_assessment Numeric. Total number of animals removed via offtake over the assessment period,
#' aggregated to 6 sex–age cohorts (heads/assessment period) (cohorts = FJ, FS, FA, MJ, MS, MA).
#' @param slaughter_weight_cohort Numeric. Live weight at slaughter for animals removed from the cohort (kg).
#' @param carcass_dressing_fraction Numeric. Ratio of a slaughtered animal's carcass weight to its live weight
#' (fraction).
#' @param bone_free_meat_fraction Numeric. Ratio of bone-free-meat to carcass weight (fraction).
#' @param meat_protein_fraction Numeric. Protein content of bone-free-meat (kg protein/kg bone-free-meat).
#'
#' @return A named list with:
#' \describe{
#' \item{meat_production_live_weight_cohort}{Numeric . Total meat produced as live weight over the assessment period by
#' cohort (kg/cohort/assessment period).}
#' \item{meat_production_carcass_weight_cohort}{Numeric. Total meat as carcass weight (excluding organs, and other
#' by-products after dressing) produced over the assessment period by cohort (kg/cohort/assessment period).}
#' \item{meat_production_bone_free_meat_cohort}{Numeric. Total bone-free-meat (excluding bones, organs, and other
#' by-products after dressing and bone removal)
#'   produced over the assessment period by cohort (kg/cohort/assessment period).}
#' \item{meat_production_protein_cohort}{Numeric. Total meat protein (excluding bones, organs, and other by-products
#' after dressing and bone removal) produced
#'   over the assessment period by cohort (kg protein/cohort/assessment period).}
#' }
#' 
#' @details
#' Meat production outputs are computed as follows:
#' \itemize{
#'   \item \strong{\code{meat_production_live_weight_cohort}} is computed as:
#'
#'   \eqn{meat\_production\_live\_weight\_cohort =
#'   offtake\_heads\_assessment \times slaughter\_weight\_cohort}
#'
#'   \item \strong{\code{meat_production_carcass_weight_cohort}} is computed as:
#'
#'   \eqn{meat\_production\_carcass\_weight\_cohort =
#'   meat\_production\_live\_weight\_cohort \times carcass\_dressing\_fraction}
#'
#'   \item \strong{\code{meat_production_bone_free_meat_cohort}} is computed as:
#'
#'   \eqn{meat\_production\_bone\_free\_meat\_cohort =
#'   meat\_production\_carcass\_weight\_cohort \times bone\_free\_meat\_fraction}
#'
#'   \item \strong{\code{meat_production_protein_cohort}} is computed as:
#'
#'   \eqn{meat\_production\_protein\_cohort =
#'   meat\_production\_bone\_free\_meat\_cohort \times meat\_protein\_fraction}
#' }
#' 
#' @seealso
#' \code{\link{run_herd_simulation}}
#' \code{\link{run_weights_calculations}}
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
