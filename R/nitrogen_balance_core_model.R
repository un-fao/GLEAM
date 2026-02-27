#' Compute Daily Nitrogen Intake
#'
#' Calculates the daily nitrogen intake per head (kg N/head/day) as the product of dry matter
#' intake (DMI) and diet nitrogen content. 
#'
#' @param dry_matter_intake Numeric. Average daily dry matter intake of feed (kg DM/head/day).
#' @param diet_nitrogen Numeric. Average nitrogen content of diet (kg N/kg DM).
#'
#' @return Numeric. Daily nitrogen intake (kg N/head/day).
#' 
#' @details
#' This approach follows the IPCC Tier 2 approach and estimates \code{dry_matter_intake}  as follows:
#'
#' \eqn{nitrogen\_intake = dry\_matter\_intake \times diet\_nitrogen}
#' 
#' @seealso
#' \code{\link{calc_dry_matter_intake}}, 
#' \code{\link{run_energy_requirements}},
#' \code{\link{calc_diet_nitrogen_content}}, 
#' \code{\link{run_feed_rations}}
#'
#' @references
#' IPCC. (2019). \emph{2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories}, 
#' Chapter 10: Emissions from
#' Livestock and Manure Management. Equation 10.32.
#'
#' IPCC. (2006). \emph{2006 IPCC Guidelines for National Greenhouse Gas Inventories}, 
#' Chapter 10: Emissions from
#' Livestock and Manure Management. Equation 10.32.
#'
#' @export
compute_nitrogen_intake <- function(dry_matter_intake, diet_nitrogen) {
  # Validate inputs
  validate_nitrogen_intake_inputs(dry_matter_intake, diet_nitrogen)

  nitrogen_intake <- dry_matter_intake * diet_nitrogen

  return(nitrogen_intake)
}

#' Compute Daily Nitrogen Retention
#'
#' Calculates daily nitrogen retention per animal by species and cohort (kg N/head/day).
#' Nitrogen retention represents the portion of consumed nitrogen that is
#' incorporated into animal products or body tissues.
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
#' @param milk_protein_fraction Numeric. Milk protein fraction (kg protein / kg milk). 
#' Required only for species = CML, CTL, BFL, SHP, and GTS.
#' @param milk_yield_day Numeric. Average milk yield per milk-producing animal during 
#' the assessment duration (kg/head/day). This value is calculated as the total quantity 
#' of milk produced for human consumption by milk-producing animals during the assessment period, 
#' divided by the number of milk-producing animals, and the length of the assessment period (days). 
#' Required only for species = CML, CTL, BFL, SHP, and GTS.
#' @param daily_weight_gain Numeric. Average live weight gain of the cohort over the cohort stage (kg/head/day).
#' @param fibre_yield_year Numeric. Annual production yield of fibre, such as wool, cashmere, mohair (kg/head/year). 
#' Required only for species = CML, SHP, and GTS.
#' @param litter_size Numeric. Average number of offspring born per parturition (# offsprings/parturition). 
#' This value can be calculated as the total number of offspring born divided
#' by the total number of parturitions during the year.
#' @param parturition_rate Numeric. Average annual number of parturitions per
#' female animal (# parturitions/adult female/year).
#' A herd-level reproductive performance indicator calculated as the total
#' number of parturitions (deliveries) occurring during
#' a year divided by the number of adult females potentially able to give birth during that year.
#' @param weaning_weight Numeric. Live weight of the animal at weaning (kg).
#' @param birth_weight Numeric. Live weight of the animal at birth (kg).
#' @param age_first_parturition Numeric. Age at first parturition for female breeding animals (days).
#'
#' @return Numeric. Daily nitrogen retention in animal body tissues and products
#' (e.g., growth, pregnancy, milk...) (kg N/head/day)
#'
#' @details
#' Species-specific nitrogen retention calculations are applied.
#'
#' \strong{For CTL, BFL, SHP, GTS, and CML}:
#'
#' Nitrogen retained in products and tissues is
#' computed consistent with the process described in the Technical paper
#' from MPI (Ministry for Primary Industries (MPI), 2025), where nitrogen retention is calculated as the sum of:
#' \itemize{
#'   \item nitrogen secreted in milk,
#'   \item nitrogen retained in liveweight gain (tissue),
#'   \item nitrogen retained in fibre (for fibre-producing species).
#' }
#'
#' Coefficients for nitrogen content of deposited tissue, fibre, and milk
#' are derived from Chapter 5 (Nitrogen Excretion) of the MPI Technical paper.
#'
#' The following constants are used:
#' \itemize{
#'   \item \strong{Tissue nitrogen content (\code{tissue_n})}
#'     \itemize{
#'       \item \code{CTL} and \code{BFL}: \strong{0.0326 kg N/kg live weight}
#'       \item \code{SHP}, \code{GTS} and \code{CML}:
#'         \strong{0.026 kg N/kg live weight}
#'     }
#'   \item \strong{Fibre nitrogen content (\code{fibre_n})}
#'     \itemize{
#'       \item \code{SHP}, \code{GTS} and \code{CML}:
#'       \strong{0.134 kg N/kg fibre}
#'      } 
#'   \item \strong{Milk nitrogen content (\code{milk_n})}:
#'     \itemize{
#'       \item \code{CTL}, \code{BFL}, \code{SHP}, \code{GTS} and \code{CML}:
#'     derived from \code{milk_protein_fraction} using a protein-to-nitrogen conversion factor
#'     of \strong{6.25 kg milk protein/kg nitrogen}
#'     }
#'     }
#' 
#' \strong{For PGS}
#'
#' Nitrogen retention is calculated following the IPCC 2019 equations
#' for swine (Equations 10.33A and 10.33B).
#'
#' Nitrogen retention includes nitrogen retained in:
#' \itemize{
#'   \item body growth,
#'   \item reproductive outputs (conceptus and weaned offspring).
#' }
#'
#' In this implementation:
#' \itemize{
#'   \item Nitrogen content of live weight gain:
#'     \strong{\code{0.025} kg N/kg live weight}
#'   \item Protein digestibility fraction:
#'    \strong{ \code{0.98} (dimensionless)}
#'   \item Reproductive component for breeding cohorts:
#'     annual nitrogen retention in conceptus and weaned offspring
#'     converted to a daily equivalent.
#' }
#'
#'@references
#' Ministry for Primary Industries (MPI). (2025).
#' \emph{Detailed methodologies for agricultural greenhouse gas emission calculation:
#' Methodology for calculation of New Zealand’s agricultural greenhouse gas emissions}
#' (Version 11). MPI Technical Paper, Wellington, New Zealand. Chapter 5.
#'
#' IPCC. (2019). \emph{2019 Refinement to the 2006 IPCC Guidelines for National
#' Greenhouse Gas Inventories}, Chapter 10: Emissions from
#' Livestock and Manure Management. Equation 10.33A, 10.33B.
#'
#' IPCC. (2006). \emph{2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions from
#' Livestock and Manure Management. Equation 10.33.
#'
#' @export
compute_nitrogen_retention <- function(
    species_short,
    cohort_short,
    milk_protein_fraction = NA_real_,
    milk_yield_day = NA_real_,
    daily_weight_gain = NA_real_,
    fibre_yield_year = NA_real_,
    litter_size = NA_real_,
    parturition_rate = NA_real_,
    weaning_weight = NA_real_,
    birth_weight = NA_real_,
    age_first_parturition = NA_real_
) {
  # Validate inputs
  validate_nitrogen_retention_inputs(
    species_short, cohort_short, milk_protein_fraction, milk_yield_day,
    daily_weight_gain, fibre_yield_year, litter_size, parturition_rate,
    weaning_weight, birth_weight, age_first_parturition
  )

  if (species_short %in% c("CTL", "BFL", "SHP", "GTS", "CML")) {
    tissue_n <- ifelse(species_short %in% c("CTL", "BFL"), 0.0326, 0.026)
    milk_n <- milk_protein_fraction / 6.25
    fibre_n <- 0.134

    milk_comp <- if (!is.na(milk_yield_day) &&
      cohort_short == "FA" && milk_yield_day > 0) {
      milk_yield_day * milk_n
    } else {
      0
    }
    growth_comp <- if (!is.na(daily_weight_gain) && daily_weight_gain > 0) daily_weight_gain * tissue_n else 0
    fibre_comp <- if (!is.na(fibre_yield_year) &&
      cohort_short %in% c("FA", "FS", "MA", "MS") &&
      species_short %in% c("SHP", "GTS", "CML") &&
      fibre_yield_year > 0) {
      fibre_yield_year / 365 * fibre_n
    } else {
      0
    }

    nitrogen_retention <- milk_comp + growth_comp + fibre_comp

  } else if (species_short == "PGS") {
    if (cohort_short == "FA") {
      nitrogen_retention <- (
        (0.025 * litter_size * parturition_rate * (weaning_weight - birth_weight) / 0.98 +
           0.025 * litter_size * parturition_rate * birth_weight) / 365
      )
    } else if (cohort_short == "FS") {
      nitrogen_retention <- 0.025 * daily_weight_gain +
        (365 / age_first_parturition) * (
          (0.025 * litter_size * parturition_rate * (weaning_weight - birth_weight) / 0.98 +
             0.025 * litter_size * parturition_rate * birth_weight) / 365
        )
    } else {
      nitrogen_retention <- 0.025 * daily_weight_gain
    }

  } else if (species_short == "CHK") {
    nitrogen_retention <- 0  # not implemented yet
  }

  return(nitrogen_retention)
}

#' Compute Daily Nitrogen Excretion
#'
#' Calculates daily nitrogen excretion per animal (kg N/head/day) as the difference between
#' nitrogen intake and nitrogen retention.
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
#' @param nitrogen_intake Numeric. Daily nitrogen intake (kg N/head/day).
#' @param nitrogen_retention Numeric. Daily nitrogen retention in animal body
#' tissues and products (e.g., growth, pregnancy, milk...) (kg N/head/day).
#'
#' @return Numeric. Daily nitrogen excretion (kg N/head/day).
#' 
#' @details
#' Nitrogen excretion represents the fraction of consumed nitrogen that is not
#' retained in animal tissues or products and is therefore excreted in urine
#' and dung.
#'
#' Nitrogen excretion is calculated as:
#'
#' \eqn{nitrogen\_excretion = nitrogen\_intake - nitrogen\_retention}
#'
#' where all quantities are expressed in kg N/head/day.
#'
#' This quantity forms the basis for subsequent calculations of nitrous oxide
#' (N₂O) emissions from manure management under
#' the IPCC Tier 2 methodology.
#' 
#'
#' @references
#' IPCC. (2019). \emph{2019 Refinement to the 2006 IPCC Guidelines for National
#' Greenhouse Gas Inventories}, Chapter 10: Emissions from
#' Livestock and Manure Management. Equation 10.31A.
#'
#' @seealso
#' \code{\link{compute_nitrogen_intake}}, 
#' \code{\link{compute_nitrogen_retention}}
#'
#' @export
compute_nitrogen_excretion <- function(
    species_short,
    nitrogen_intake,
    nitrogen_retention
) {
  # Validate inputs
  validate_nitrogen_excretion_inputs(species_short, nitrogen_intake, nitrogen_retention)

  if (species_short %in% c("CTL", "BFL", "CML", "GTS", "SHP", "PGS")) {
    nitrogen_excretion <- nitrogen_intake - nitrogen_retention
  } else {
    nitrogen_excretion <- 0  # not implemented yet
  }
  return(nitrogen_excretion)
}
