#' Calculate methane conversion factor (ym)
#'
#' Calculates the methane conversion factor (ym, % of dietary gross energy in feed converted to methane)
#' for a given species and cohort based on diet digestibility. Implements species- and cohort-specific
#' rules consistent with IPCC Tier 2 approach.
#'
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
#'
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
#' @param ration_digestibility_fraction Numeric. Average digestibility of the feed ration, expressed as ratio of 
#' digestible (or metabolizable, for poultry) to gross energy content (fraction).
#'
#' @return Numeric. Methane (CH4) conversion factor (ym), representing the percentage of  gross energy 
#' of the feed ration that is converted to CH4 (percentage).
#'
#'@details
#' ym is computed using species- and cohort-specific default relationships with diet digestibility (Opio et al., 2013). 
#' 
#' \code{ration_digestibility_fraction} can be calculated with
#' \code{\link{calc_ration_digestibility}} - see also \code{\link{run_ration_quality_module}}.
#'
#' \itemize{
#'   \item \strong{For \code{CTL} and \code{BFL}:}
#'     \deqn{ym = 9.75 - 0.05 \times (ration\_digestibility\_fraction \times 100)}
#'
#'   \item \strong{For \code{SHP}, \code{GTS} and \code{CML}:}
#'     \itemize{
#'       \item \code{FA} and \code{MA} cohorts: 
#'       \deqn{ym = 9.75 - 0.05 \times (ration\_digestibility\_fraction \times 100)}
#'       \item \code{FS} and \code{MS} cohorts: 
#'       \deqn{ym = 7.75 - 0.05 \times (ration\_digestibility\_fraction \times 100)}
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
#' ym is returned as 0 for juvenile cohorts (\code{FJ}, \code{MJ}), assuming 
#' negligible enteric methane production before weaning/rumen development.
#' 
#' This function is part of the [run_emissions_enteric_module()].
#' 
#' @seealso
#'   \code{\link{run_emissions_enteric_module}},
#'   \code{\link{calc_ration_digestibility}},
#'   \code{\link{run_ration_quality_module}}
#'
#' @references
#' Opio, C., Gerber, P., Mottet, A., Falcucci, A., Tempio, G.,
#' MacLeod, M., Vellinga, T., Henderson, B. & Steinfeld, H. (2013).
#' \emph{Greenhouse gas emissions from ruminant supply chains – A global life cycle assessment}.
#' Food and Agriculture Organization of the United Nations (FAO), Rome.
#'
#' Jørgensen, H., Theil, P. K. & Knudsen, K. E. B. (2011).
#' \emph{Enteric methane emission from pigs}.
#' In: Planet Earth 2011 – Global Warming Challenges and Opportunities for Policy and Practice
#' (p. 610; Table 2). InTech.
#'
#' IPCC. (2019).
#' \emph{2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories}.
#' Chapter 10: Emissions from Livestock and Manure Management, Equation 10.21.
#'
#' IPCC. (2006).
#' \emph{2006 IPCC Guidelines for National Greenhouse Gas Inventories}.
#' Chapter 10: Emissions from Livestock and Manure Management, Equation 10.21.
#'
#' @export
calc_conversion_factor_ym <- function(
    species_short,
    cohort_short,
    ration_digestibility_fraction
) {
  validate_ym_inputs(species_short, cohort_short, ration_digestibility_fraction)

  if (species_short %in% c("CTL", "BFL")) {
    if (cohort_short %in% c("FJ", "MJ")) {
      ch4_conversion_factor_ym <- 0
    } else {
      ch4_conversion_factor_ym <- 9.75 - 0.05 * ration_digestibility_fraction * 100
    }
  } else if (species_short %in% c("SHP", "GTS", "CML")) {
    if (cohort_short %in% c("FJ", "MJ")) {
      ch4_conversion_factor_ym <- 0
    } else if (cohort_short %in% c("FS", "MS")) {
      ch4_conversion_factor_ym <- 7.75 - 0.05 * ration_digestibility_fraction * 100
    } else {
      ch4_conversion_factor_ym <- 9.75 - 0.05 * ration_digestibility_fraction * 100
    }
  } else if (species_short %in% c("PGS")) {
    if (cohort_short %in% c("FJ", "MJ")) {
      ch4_conversion_factor_ym <- 0
    } else if (cohort_short %in% c("FS", "MS")) {
      ch4_conversion_factor_ym <- 0.39
    } else {
      ch4_conversion_factor_ym <- 1.01
    }
  }

  return(ch4_conversion_factor_ym)
}


#' Calculate daily enteric methane emissions
#'
#' Calculates daily enteric methane emissions (kg CH4/head/day) based on gross
#' energy intake, methane conversion factor (ym), and dry matter intake.
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
#' @param ch4_conversion_factor_ym Numeric. Methane (CH4) conversion factor (ym), 
#' representing the percentage of  gross energy of the feed ration that is converted to CH4 (percentage).
#' @param ch4_mitigation_factor Numeric. Optional. Multiplicative mitigation factor applied to
#'     baseline enteric methane (CH4) emissions (dimensionless). If not provided, a default
#'     value of \code{1} (no mitigation) is used. Values lower than 1 represent proportional
#'     reductions (e.g., \code{0.90} = 10% reduction). This factor can represent mitigation
#'     measures with a direct effect on enteric methane emissions, such as the use of feed
#'     additives or methane inhibitors.
#' @param ration_gross_energy Numeric. Average gross energy content of the diet (MJ/kg DM).
#' @param ration_intake Numeric. Average daily dry matter intake of feed (kg DM/head/day).
#'
#' @return Numeric. Average daily enteric methane (CH4) emissions (kg CH4/head/day).
#'
#'@details
#' The formula used to estimate daily enteric methane emissions is:
#'
#' \deqn{CH_4 = \frac{ration\_gross\_energy \times ration\_intake 
#' \times ch4\_conversion\_factor\_ym}{55.65 \times 100}}
#' 
#' where 55.65 MJ/kg is the energy content of methane.
#' 
#' \code{ration_gross_energy} and \code{ration_intake} can be calculated with
#' \code{\link{calc_ration_gross_energy}} and \code{\link{calc_ration_intake}} (
#' see also \code{\link{run_ration_quality_module}} and \code{\link{run_metabolic_energy_req_module}}).
#'
#' This function is part of the [run_emissions_enteric_module()].
#' 
#' @seealso
#'   \code{\link{run_emissions_enteric_module}},
#'   \code{\link{calc_ration_gross_energy}},
#'   \code{\link{calc_ration_intake}},
#'   \code{\link{run_ration_quality_module}}
#'   \code{\link{run_metabolic_energy_req_module}}
#'
#' @references
#' IPCC. (2019).
#' \emph{2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories}.
#' Chapter 10: Emissions from Livestock and Manure Management, Equation 10.21.
#'
#' IPCC. (2006).
#' \emph{2006 IPCC Guidelines for National Greenhouse Gas Inventories}.
#' Chapter 10: Emissions from Livestock and Manure Management, Equation 10.21.
#'
#' @export
calc_ch4_enteric <- function(
    species_short,
    ch4_conversion_factor_ym,
    ch4_mitigation_factor,
    ration_gross_energy,
    ration_intake
) {
  validate_enteric_emission_inputs(
    species_short, ch4_conversion_factor_ym, ch4_mitigation_factor,
    ration_gross_energy, ration_intake
  )

  ch4_enteric <- ration_gross_energy * ration_intake *
    (ch4_conversion_factor_ym / 100) * ch4_mitigation_factor / 55.65

  return(ch4_enteric)
}
