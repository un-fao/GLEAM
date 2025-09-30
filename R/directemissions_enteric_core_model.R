#' Compute Methane Conversion Factor (YM)
#'
#' Calculates the methane conversion factor (YM, % of dietary gross energy converted to methane)
#' for a given species and cohort based on diet digestibility. Implements species- and cohort-specific
#' rules consistent with the GLEAM methodology.
#'
#' @param Animal_short Character. Species code: one of `CTL`, `BFL`, `CML`, `SHP`, `GTS`, `PGS`, `CHK`.
#' @param cohort Character. Cohort code (e.g., `FA`, `FS`, `MJ`).
#' @param diet_dig Numeric. Diet digestibility (DE/GE ratio, unitless fraction).
#'
#' @return Numeric scalar. Methane conversion factor (YM) as percentage of GE converted to CH₄.
#'
#' @export
compute_methane_conversion_factor <- function(
    Animal_short,
    cohort,
    diet_dig
) {
  validate_ym_inputs(Animal_short, cohort, diet_dig)
  if (Animal_short %in% c("CTL", "BFL")) {
    ret = 9.75 - 0.05 * diet_dig * 100
  } else if (Animal_short %in% c("SHP", "GTS", "CML")) {
    if (cohort %in% c("SF", "SM", "JF", "JM")) {
      ret = 7.75 - 0.05 * diet_dig * 100
    } else {
      ret = 9.75 - 0.05 * diet_dig * 100
    }
  } else if (Animal_short %in% c("PGS")) {
    ret <- if (cohort %in% c("AF", "AM")) 1.01 else 0.39
  } else if (Animal_short == "CHK") {
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
#' @param Animal_short Character. Species code: `CTL`, `BFL`, `CML`, `SHP`, `GTS`, `PGS`, `CHK`.
#' @param cohort Character. Cohort code (e.g., `FA`, `MJ`); retained for compatibility.
#' @param ym Numeric. Methane conversion factor (percentage of GE converted to CH₄).
#' @param diet_ge Numeric. Gross energy content of the diet (MJ/kg DM).
#' @param dmi Numeric. Dry matter intake (kg DM/head/day).
#' @param afc Numeric. Age at first calving (days); not used but included for signature consistency.
#'
#' @return Numeric scalar. Daily enteric methane emissions (kg CH₄ per animal).
#'
#' @export
compute_daily_enteric_emissions <- function(
    Animal_short,
    cohort,
    ym,
    diet_ge,
    dmi,
    afc
) {
  validate_enteric_emission_inputs(Animal_short, cohort, ym, diet_ge, dmi, afc)
  if (Animal_short %in% c("CTL", "BFL", "CML", "PGS", "SHP", "GTS")) {
    ret <- diet_ge * dmi * (ym / 100) / 55.65
  } else if (Animal_short == "CHK") {
    ret <- NA_real_
  }
  return(ret)
}
