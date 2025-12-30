#' Compute Daily Nitrogen Intake
#'
#' Calculates nitrogen intake as the product of dry matter intake (DMI) and diet nitrogen content.
#' This represents the gross nitrogen consumed per head per day.
#'
#' @param dmi Numeric. Dry matter intake of feed (kg DM/head/day).
#' @param diet_nitrogen Numeric. Nitrogen content per kg of feed dry matter intake (kg N/kg DM).
#'
#' @return Numeric. Daily nitrogen intake (kg N/head/day).
#'
#' @export
compute_nitrogen_intake <- function(dmi, diet_nitrogen) {
  # Validate inputs
  validate_nitrogen_intake_inputs(dmi, diet_nitrogen)
  return(dmi * diet_nitrogen)
}

#' Compute Daily Nitrogen Retention
#'
#' Calculates nitrogen retention by species and cohort. Retention includes nitrogen
#' retained in milk, growth, and fibre (for ruminants only), and in growth and reproductive processes (for pigs only).
#' Chickens are not implemented yet and return `NA`.
#'
#' @param animal Character. Species code (e.g., "PGS", "CML", "CTL", "BFL", "SHP", "GTS").
#' @param cohort Character. Cohort code (e.g., "FJ", "MJ", "FS", "MS", "FA", "MA").
#' @param milk_protein Numeric. Milk protein content (fraction), used to derive milk nitrogen.
#' @param milk_yield Numeric. Milk yield (kg/head/day).
#' @param dwg Numeric. Daily weight gain (kg/head/day).
#' @param fibre_prod Numeric. Production yield of fibre, such as wool, cashmere, mohair (kg/head/year).
#' @param litsize Numeric. Litter size (mean number of offspring per parturition).
#' @param parturition_rate Numeric. Annual parturition rate of adult females (parturitions/head/year).
#' @param wkg Numeric. Weaning weight (kg).
#' @param ckg Numeric. Birth weight (kg).
#' @param afc Numeric. Age at first parturition (years).
#'
#' @return Numeric. Daily nitrogen retention (kg N/head/day).
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
          (1 / afc) * (
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
#' Calculates nitrogen excretion (kg N/head/day) as the difference between
#' nitrogen intake and retention for applicable species.
#'
#' @param animal Character. Species code (e.g., "PGS", "CML", "CTL", "BFL", "SHP", "GTS").
#' @param n_intake Numeric. Nitrogen intake (kg N/head/day).
#' @param n_retention Numeric. Nitrogen retention (kg N/head/day).
#'
#' @return Numeric. Daily nitrogen excretion (kg N/head/day).
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
