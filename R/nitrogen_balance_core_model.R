#' Compute Daily Nitrogen Intake
#'
#' Calculates the daily nitrogen intake per head as the product of dry matter intake (DMI) and diet nitrogen content.
#' The approach follows the Tier 2 IPCC guidelines (IPCC 2006, 2019). 
#'
#' @param dmi Numeric. Daily dry matter intake of feed (kg DM/head/day).
#' @param diet_nitrogen Numeric. Average nitrogen content of diet (kg N/kg DM).
#'
#' @return Numeric. Daily nitrogen intake (kg N/head/day)
#'
#'@references
#' IPCC. (2019). \emph{2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions from
#' Livestock and Manure Management. Equation 10.32.
#'
#' IPCC. (2006). \emph{2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions from
#' Livestock and Manure Management. Equation 10.32.
#'
#' @export
compute_nitrogen_intake <- function(dmi, diet_nitrogen) {
  # Validate inputs
  validate_nitrogen_intake_inputs(dmi, diet_nitrogen)
  return(dmi * diet_nitrogen)
}

#' Compute Daily Nitrogen Retention
#'
#' Calculates daily nitrogen retention per animal by species and cohort.
#' Nitrogen retention represents the portion of consumed nitrogen that is
#' incorporated into animal products or body tissues.
#' The approach follows the Tier 2 IPCC guidelines (IPCC 2006, 2019).
#'
#' @param animal Character. Code identifying the livestock species.
#'   Supported values include:
#'   \itemize{
#'     \item \code{PGS}: pigs
#'     \item \code{CML}: camels
#'     \item \code{CTL}: cattle
#'     \item \code{BFL}: buffalo
#'     \item \code{SHP}: sheep
#'     \item \code{GTS}: goats
#'   }
#' @param cohort "Character. Sex- and age-specific cohort code describing the
#'   production stage of the animals. Supported values include:
#'   \itemize{
#'     \item \code{FA}: adult females (from age at first parturition)
#'     \item \code{FS}: sub-adult females (from weaning to age at first parturition)
#'     \item \code{FJ}: juvenile females (from birth to weaning)
#'     \item \code{MA}: adult males (from age at first breeding)
#'     \item \code{MS}: sub-adult males (from weaning to age at first breeding)
#'     \item \code{MJ}: juvenile males (from birth to weaning)
#'   }
#' @param milk_protein Numeric. Milk protein fraction (kg protein / kg milk).
#' @param milk_yield Numeric. Average milk yield per milk-producing animal during the assessment duration (kg/head/day). This value can be calculated by dividing the total milk destinated to human consumption produced per milk-producing animal over the assessment duration by the length of the assessment period.
#' @param dwg Numeric. Average live weight of the cohort over the cohort stage (kg/head/day).
#' @param fibre_prod Numeric. Annual production yield of fibre, such as wool, cashmere, mohair (kg/head/year).
#' @param litsize Numeric. Average number of offspring born per parturition (#). This value can be calculated as the total number of offspring born divided by the total number of parturitions during the year.
#' @param parturition_rate Numeric. Numeric. Average annual number of parturitions per female animal (fraction). At herd level, calculated as offspring delivered divided by the number of adult females.
#' @param wkg Numeric. Live weight of the animal at weaning (kg)
#' @param ckg Numeric. Live weight of the animal at birth (kg).
#' @param afc Numeric. Age at first parturition for female breeding animals (days)
#'
#' @return Numeric.  Daily nitrogen retention in animal body tissues and products (e.g., growth, pregnancy, milk...) (kg N/head/day)
#' 
#' @details
#' Species-specific calculations are performed.
#'
#' ## Ruminants and camelids (CTL, BFL, SHP, GTS, CML)
#' For ruminants and camelids, nitrogen retained in products and tissues is
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
#'   \item \strong{Milk nitrogen content}:
#'   Milk nitrogen is derived from milk protein using a protein-to-nitrogen
#'   conversion factor of \strong{6.25}
#' }
#'
#' ## Pigs (PGS)
#' For pigs, nitrogen retention is calculated following the IPCC 2019 equations
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
    animal,
    cohort,
    milk_protein = NA_real_,
    milk_yield = NA_real_,
    dwg = NA_real_,
    fibre_prod = NA_real_,
    litsize = NA_real_,
    parturition_rate = NA_real_,
    wkg = NA_real_,
    ckg = NA_real_,
    afc = NA_real_
) {
  # Validate inputs
  validate_nitrogen_retention_inputs(
    animal, cohort, milk_protein, milk_yield,
    dwg, fibre_prod, litsize, parturition_rate,
    wkg, ckg, afc
  )

  if (animal %in% c("CTL", "BFL", "SHP", "GTS", "CML")) {
    tissue_n <- ifelse(animal %in% c("CTL", "BFL"), 0.0326, 0.026)
    milk_n <- milk_protein / 6.25
    fibre_n <- 0.134

    milk_comp <- if (!is.na(milk_yield) && cohort == "FA" && milk_yield > 0) milk_yield * milk_n else 0
    growth_comp <- if (!is.na(dwg) && dwg > 0) dwg * tissue_n else 0
    fibre_comp <- if (!is.na(fibre_prod) && fibre_prod > 0) fibre_prod / 365 * fibre_n else 0

    return(milk_comp + growth_comp + fibre_comp)

  } else if (animal == "PGS") {
    if (cohort == "FA") {
      return(
        (0.025 * litsize * parturition_rate * (wkg - ckg) / 0.98 +
           0.025 * litsize * parturition_rate * ckg) / 365
      )
    } else if (cohort == "FS") {
      return(
        0.025 * dwg +
          (365 / afc) * (
            (0.025 * litsize * parturition_rate * (wkg - ckg) / 0.98 +
               0.025 * litsize * parturition_rate * ckg) / 365
          )
      )
    } else {
      return(0.025 * dwg)
    }

  } else if (animal == "CHK") {
    return(NA_real_)  # not implemented yet
  }
}

#' Compute Daily Nitrogen Excretion
#' 
#' Calculates daily nitrogen excretion per animal (kg N/head/day) as the difference between
#' nitrogen intake and nitrogen retention.
#'
#' Nitrogen excretion represents the fraction of consumed nitrogen that is not
#' retained in animal products or body tissues and is therefore excreted in urine
#' and dung. This quantity forms the basis for subsequent calculations of
#' nitrous oxide (N2O) emissions from manure management and agricultural soils.
#' The approach follows the Tier 2 IPCC guidelines.
#'
#' @param animal Character. Code identifying the livestock species.
#'   Supported values include:
#'   \itemize{
#'     \item \code{PGS}: pigs
#'     \item \code{CML}: camels
#'     \item \code{CTL}: cattle
#'     \item \code{BFL}: buffalo
#'     \item \code{SHP}: sheep
#'     \item \code{GTS}: goats
#'   }
#' @param n_intake Numeric. Daily nitrogen intake (kg N/head/day)
#' @param n_retention Numeric.  Daily nitrogen retention in animal body tissues and products (e.g., growth, pregnancy, milk...) (kg N/head/day)
#'
#' @return Numeric. Daily nitrogen excretion (kg N/head/day).
#' 
#' @references
#' IPCC. (2019). \emph{2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions from
#' Livestock and Manure Management. Equation 10.31A.
#' 
#' @export
compute_nitrogen_excretion <- function(
    animal,
    n_intake,
    n_retention
) {
  # Validate inputs
  validate_nitrogen_excretion_inputs(animal, n_intake, n_retention)

  if (animal %in% c("CTL", "BFL", "CML", "GTS", "SHP", "PGS")) {
    return(n_intake - n_retention)
  } else {
    return(NA_real_)
  }
}
