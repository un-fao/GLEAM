#' Compute Methane Conversion Factor (YM)
#'
#' Calculates the methane conversion factor (YM, % of dietary gross energy in feed converted to methane)
#' for a given species and cohort based on diet digestibility. Implements species- and cohort-specific
#' rules consistent with the GLEAM methodology and with IPCC Tier 2 approach.
#' 
#'
#' @param animal Character. Species code  (e.g., `PGS`, `CML`, `CTL`, `BFL`, `SHP`, `GTS`). 
#' @param cohort Character. Cohort code (e.g., `FA`, `FS`, `FJ`, `MA`, `MS`,`MJ`).
#' @param diet_dig Numeric. Average digestibility of the the feed ration, expressed as ratio of digestible to gross energy content (fraction)
#'
#' @return Numeric scalar. Methane conversion factor (YM), representing the share of  gross energy of the feed ration that is converted to CH₄.
#'
#' @references
#' Opio, C., Gerber, P., Mottet, A., Falcucci, A., Tempio, G.,
#' MacLeod, M., Vellinga, T., Henderson, B. & Steinfeld, H. (2013).
#' *Greenhouse gas emissions from ruminant supply chains – A global life cycle assessment*. Food and Agriculture Organization of the United Nations (FAO), Rome.
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
    ret = 9.75 - 0.05 * diet_dig * 100
  } else if (animal %in% c("SHP", "GTS", "CML")) {
    if (cohort %in% c("SF", "SM", "JF", "JM")) {
      ret = 7.75 - 0.05 * diet_dig * 100
    } else {
      ret = 9.75 - 0.05 * diet_dig * 100
    }
  } else if (animal %in% c("PGS")) {
    ret <- if (cohort %in% c("AF", "AM")) 1.01 else 0.39
  } else if (animal == "CHK") {
    ret <- NA_real_
  }
  return(ret)
}


#' Compute Daily Enteric Methane Emissions
#'
#' Calculates daily enteric methane emissions (kg CH₄/head/day) based on gross energy intake,
#' methane conversion factor (YM), and dry matter intake (DMI). The formula assumes:
#'
#' \deqn{CH₄ = diet\_ge × dmi × (ym / 100) / 55.65}
#'
#' where 55.65 MJ/kg is the energy content of methane. Returns `NA` for chickens.
#'
#' @param animal Character. Species code  (e.g., `PGS`, `CML`, `CTL`, `BFL`, `SHP`, `GTS`). 
#' @param cohort Character. Cohort code (e.g., `FA`, `FS`, `FJ`, `MA`, `MS`,`MJ`).
#' @param ym Numeric. Methane conversion factor (YM), representing the share of  gross energy of the feed ration that is converted to CH₄.
#' @param diet_ge Numeric. Average gross energy content of the diet (MJ/kg DM).
#' @param dmi Numeric. Daily dry matter intake of feed (kg DM/head/day).
#'
#' @return Numeric scalar. Daily enteric methane emissions (kg CH₄/head/day).
#'
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
    cohort,
    ym,
    diet_ge,
    dmi
) {
  validate_enteric_emission_inputs(animal, cohort, ym, diet_ge, dmi)
  if (animal %in% c("CTL", "BFL", "CML", "PGS", "SHP", "GTS")) {
    ret <- diet_ge * dmi * (ym / 100) / 55.65
  } else if (animal == "CHK") {
    ret <- NA_real_
  }
  return(ret)
}
