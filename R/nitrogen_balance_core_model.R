#' Compute Daily Nitrogen Intake
#'
#' Calculates the daily nitrogen intake per head as the product of dry matter
#' intake (DMI) and diet nitrogen content. The approach follows the Tier 2 IPCC
#' guidelines (IPCC 2006, 2019).
#'
#' @param dry_matter_intake Numeric. Daily dry matter intake of feed (kg DM/head/day).
#' @param diet_nitrogen Numeric. Average nitrogen content of diet (kg N/kg DM).
#'
#' @return Numeric. Daily nitrogen intake (kg N/head/day).
#'
#' @references
#' IPCC. (2019). \emph{2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions from
#' Livestock and Manure Management. Equation 10.32.
#'
#' IPCC. (2006). \emph{2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions from
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
#' Calculates daily nitrogen retention per animal by species and cohort.
#' Nitrogen retention represents the portion of consumed nitrogen that is
#' incorporated into animal products or body tissues.
#' The approach follows the Tier 2 IPCC guidelines (IPCC 2006, 2019).
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
#' @param milk_yield_day Numeric. Average milk yield per milk-producing animal during the assessment duration (kg/head/day). This value can be calculated by dividing the total milk destined to human consumption produced per milk-producing animal over the assessment duration by the length of the assessment period.
#' @param daily_weight_gain Numeric. Average daily live weight gain of the cohort over the cohort stage (kg/head/day).
#' @param fibre_yield_year Numeric. Annual production yield of fibre, such as wool, cashmere, mohair (kg/head/year).
#' @param litter_size Numeric. Average number of offspring born per parturition. This value can be calculated as the total number of offspring born divided by the total number of parturitions during the year.
#' @param parturition_rate Numeric. Average annual number of parturitions per female animal (fraction). At herd level, calculated as offspring delivered divided by the number of adult females.
#' @param weaning_weight Numeric. Live weight of the animal at weaning (kg).
#' @param birth_weight Numeric. Live weight of the animal at birth (kg).
#' @param age_first_parturition Numeric. Age at first parturition for female breeding animals (days).
#'
#' @return Numeric.  Daily nitrogen retention in animal body tissues and products (e.g., growth, pregnancy, milk...) (kg N/head/day)
#'
#' @details
#' Species-specific calculations are performed.
#'
#' \strong{For CTL, BFL, SHP, GTS and CML}
#'
#' Nitrogen retained in products and tissues is
#' computed consistent with the process described in the Technical paper
#' from MPI (Ministry for Primary Industries (MPI), 2025).
#'
#' Nitrogen retention is calculated as the sum of:
#' \itemize{
#'   \item nitrogen secreted in milk,
#'   \item nitrogen retained in liveweight gain (tissue),
#'   \item nitrogen retained in fibre (for fibre-producing species).
#' }
#'
#' Coefficients for nitrogen content of deposited tissue, fibre, and milk are
#' derived from Chapter 5 (Nitrogen excretion) of the MPI inventory methodology.
#'
#' The following constants are used:
#' \itemize{
#'   \item \strong{Tissue nitrogen content (\code{tissue_n})}:
#'     \itemize{
#'       \item Cattle (\code{CTL}, \code{BFL}): \strong{0.0326 kg N per kg live weight}
#'       \item Sheep (\code{SHP}), goats (\code{GTS}) and camelids (\code{CML}):
#'       \strong{0.026 kg N per kg live weight}
#'     }
#'   \item \strong{Fibre nitrogen content (\code{fibre_n})}:
#'   \strong{0.134 kg N per kg fibre}
#'   \item \strong{Milk nitrogen content (\code{milk_n})}:
#'   Milk nitrogen is derived from milk protein using a protein-to-nitrogen
#'   conversion factor of \strong{6.25}
#' }
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
#' Calculations are expressed on a daily basis. In this implementation:
#' \itemize{
#'   \item \code{0.025} represents the nitrogen content of liveweight gain
#'   (kg N per kg gain),
#'   \item \code{0.98} is the protein digestibility fraction,
#'   \item breeding cohorts include an annual reproductive component that is
#'   converted to a daily rate.
#' }
#'
#'@references
#' Ministry for Primary Industries (MPI). (2025).
#' \emph{Detailed methodologies for agricultural greenhouse gas emission calculation:
#' Methodology for calculation of New Zealand’s agricultural greenhouse gas emissions}
#' (Version 11). MPI Technical Paper, Wellington, New Zealand. Chapter 5.
#'
#' IPCC. (2019). \emph{2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions from
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

    milk_comp <- if (!is.na(milk_yield_day) && cohort_short == "FA" && milk_yield_day > 0) milk_yield_day * milk_n else 0
    growth_comp <- if (!is.na(daily_weight_gain) && daily_weight_gain > 0) daily_weight_gain * tissue_n else 0
    fibre_comp <- if (!is.na(fibre_yield_year) && cohort_short %in% c("FA", "FS", "MA", "MS") && species_short %in% c("SHP", "GTS", "CML") && fibre_yield_year > 0) fibre_yield_year / 365 * fibre_n else 0

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
#' Nitrogen excretion represents the fraction of consumed nitrogen that is not
#' retained in animal products or body tissues and is therefore excreted in urine
#' and dung. This quantity forms the basis for subsequent calculations of
#' nitrous oxide \code{N₂O} emissions from manure management and agricultural soils.
#' The approach follows the IPCC 2019 guidelines.
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
#' @param nitrogen_retention Numeric. Daily nitrogen retention in animal body tissues and products (e.g., growth, pregnancy, milk...) (kg N/head/day).
#'
#' @return Numeric. Daily nitrogen excretion (kg N/head/day).
#'
#' @references
#' IPCC. (2019). \emph{2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions from
#' Livestock and Manure Management. Equation 10.31A.
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
