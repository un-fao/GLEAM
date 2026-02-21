#' Compute Methane Conversion Factor (ym)
#'
#' Calculates the methane conversion factor (ym, % of dietary gross energy in feed converted to methane)
#' for a given species and cohort based on diet digestibility. Implements species- and cohort-specific
#' rules consistent with IPCC Tier 2 approach.
#' 
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
#' @param diet_dig Numeric. Average digestibility of the the feed ration, expressed as ratio of digestible to gross energy content (fraction)
#'
#' @return Numeric. Methane conversion factor (ym), representing the share of gross energy of the feed ration that is converted to CH₄ (percentage)
#'
#'@details
#' ym is computed using species- and cohort-specific default relationships with diet digestibility (Opio et al., 2013).
#'
#' \itemize{
#'   \item \strong{For \code{CTL} and \code{BFL}:}
#'     \deqn{ym = 9.75 - 0.05 \times (diet\_dig \times 100)}
#'
#'   \item \strong{For \code{SHP}, \code{GTS} and \code{CML}:}
#'     \itemize{
#'       \item \code{FA} and \code{MA} cohorts: \deqn{ym = 9.75 - 0.05 \times (diet\_dig \times 100)}
#'       \item \code{FS} and \code{MS} cohorts: \deqn{ym = 7.75 - 0.05 \times (diet\_dig \times 100)}
#'     }
#'
#'   \item \strong{For \code{PGS}:}
#'     ym is assigned fixed values by cohort:
#'     \itemize{
#'       \item \code{FA} and \code{MA} cohorts: \deqn{ym = 1.01}
#'        \item \code{FS} and \code{MS} cohorts: \deqn{ym = 0.39}
#'     }
#' }
#' 
#' ym is returned as 0 for juvenile cohorts (\code{JF}, \code{JM}), assuming negligible enteric methane production before weaning/rumen development.
#'
#'
#' @references
#' Opio, C., Gerber, P., Mottet, A., Falcucci, A., Tempio, G.,
#' MacLeod, M., Vellinga, T., Henderson, B. & Steinfeld, H. (2013).
#' *Greenhouse gas emissions from ruminant supply chains – A global life cycle assessment*. Food and Agriculture Organization of the United Nations (FAO), Rome.
#' 
#' Jørgensen, H., Theil, P.K. and Knudsen, K.E.B., (2011). 
#' *Enteric methane emission from pigs*. In Planet Earth 2011-Global Warming Challenges and Opportunities for Policy and Practice (p. 610 - Table 2). InTech.
#'
#' IPCC. (2019). *2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories*, Chapter 10: Emissions from
#' Livestock and Manure Management, Equation 10.21.
#' 
#' IPCC. (2006). *2006 IPCC Guidelines for National Greenhouse Gas Inventories*, Chapter 10: Emissions from
#' Livestock and Manure Management, Equation 10.21.
#'
#' @export
compute_methane_conversion_factor <- function(
    animal,
    cohort,
    diet_dig
) {
  validate_ym_inputs(animal, cohort, diet_dig)
  
  if (animal %in% c("CTL", "BFL")) {
    if (cohort %in% c("FJ", "MJ")) {
      ym_value <- 0
    } else {
      ym_value <- 9.75 - 0.05 * diet_dig * 100
    }
  } else if (animal %in% c("SHP", "GTS", "CML")) {
    if (cohort %in% c("FJ", "MJ")) {
      ym_value <- 0
    } else if (cohort %in% c("FS", "MS")) {
      ym_value <- 7.75 - 0.05 * diet_dig * 100
    } else {
      ym_value <- 9.75 - 0.05 * diet_dig * 100
    }
  } else if (animal %in% c("PGS")) {
    if (cohort %in% c("FJ", "MJ")) {
      ym_value <- 0
    } else if (cohort %in% c("FS", "MS")) {
      ym_value <- 0.39
    } else {
      ym_value <- 1.01
    }
  } else if (animal == "CHK") {
    ym_value <- NA_real_
  }

  return(ym_value)
}


#' Compute Daily Enteric Methane Emissions
#'
#' Calculates daily enteric methane emissions (kg CH₄/head/day) based on gross energy intake,
#' methane conversion factor (ym), and dry matter intake (dmi). 
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
#'   
#' @param ym Numeric. Methane conversion factor (ym), representing the percentage of gross energy of the feed ration that is converted to CH₄ (percentage).
#' @param ch4_mitigation_factor Numeric. Dimensionless fraction of baseline enteric methane emissions remaining after mitigation. Applied as a
#' multiplicative factor to calculated emissions (1 = no mitigation, 0.9 = 10% reduction). Default = 1.
#' @param diet_ge Numeric. Average gross energy content of the diet (MJ/kg DM).
#' @param dmi Numeric. Average daily dry matter intake of feed (kg dry matter/head/day).
#'
#' @return Numeric. Average daily enteric methane emissions (kg CH₄/head/day).
#'
#'@details
#' The formula used to estimate daily enteric methane emissions is:
#'
#' \deqn{CH_4 = \frac{diet\_ge \times dmi \times \frac{ym}{100}}{55.65}}
#'
#' where 55.65 MJ/kg is the energy content of methane.
#'
#' The function returns `NA` for chickens.
#'
#' @references
#' IPCC. (2019). *2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories*, Chapter 10: Emissions from
#' Livestock and Manure Management, Equation 10.21.
#' 
#' IPCC. (2006). *2006 IPCC Guidelines for National Greenhouse Gas Inventories*, Chapter 10: Emissions from
#' Livestock and Manure Management, Equation 10.21.
#' 
#'
#' @export
compute_daily_enteric_emissions <- function(
    animal,
    ym,
    ch4_mitigation_factor,
    diet_ge,
    dmi
) {
  validate_enteric_emission_inputs(animal, ym, ch4_mitigation_factor, diet_ge, dmi)

  if (animal %in% c("CTL", "BFL", "CML", "PGS", "SHP", "GTS")) {
    ch4_enteric_value <- diet_ge * dmi * (ym / 100) * ch4_mitigation_factor / 55.65
  } else if (animal == "CHK") {
    ch4_enteric_value <- NA_real_
  }

  return(ch4_enteric_value)
}
