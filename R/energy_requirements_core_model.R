#' Calculate Energy for Maintenance
#'
#' Computes the **energy requirement for maintenance** (MJ/head/day).
#' This approach follows the IPCC Tier 2 partitioning method, and applies this general equation:
#' energy_maintenance = cmain * average_weight^0.75
#' where cmain is a category-specific coefficient (MJ d^-1 kg^-1).
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
#' @param average_weight Numeric. Average live weight over the cohort stage. Computed by accounting for the share of offtaken animals within the cohort, using their slaughter weight, and the potential final weight of animals that remain in the cohort (kg).
#' @param milking_fraction Numeric. Share of adult females lactating within the assessment duration. Applies to species = CML, CTL, BFL, SHP, GTS. (fraction).
#' @param offtake_rate Numeric. Annual proportion of animals removed from the herd for each sex-age cohort (fraction).
#' @param afc Numeric. Age at first parturition for female breeding animals (days)
#'
#' @return Numeric. Energy required for maintenance, defined as the amount of energy needed to keep the animal
#' in equilibrium such that body energy is neither gained nor lost.
#' Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS (MJ/head/day).
#'
#' @details
#' The maintenance coefficient \eqn{cmain} reflects basal metabolic requirements and differs
#' by species, physiological status, and sex. For selected cohorts it is computed as a
#' weighted average to account for:
#'
#' \itemize{
#'   \item lactating vs. non-lactating females (CTL, BFL),
#'   \item intact vs. castrated males (CTL, BFL, SHP). Offtaken animals are assumed castrated,
#'   \item animals below vs. above one year of age (SHP).
#' }
#'
#'**Specific cofficients by species and cohort:**
#'
#' \strong{CTL and BFL} (NRC, 1996; AFRC, 1993, 1995):
#' \itemize{
#'   \item \code{FA}:
#'     \eqn{cmain = 0.386 \times milking\_fraction + 0.322 \times (1 - milking\_fraction)}
#'   \item \code{FS}, \code{FJ}, \code{MJ}:
#'     \eqn{cmain = 0.322}
#'   \item \code{MA}, \code{MS}:
#'     \eqn{cmain = 0.322 \times offtake\_rate + 0.370 \times (1 - offtake\_rate)}
#' }
#'
#' \strong{CML} (Wardeh, 2004):
#' \itemize{
#'   \item All cohorts:
#'     \eqn{cmain = 0.435}
#' }
#'
#' \strong{GTS} (AFRC, 1993, 1995):
#' \itemize{
#'   \item All cohorts:
#'     \eqn{cmain = 0.315}
#' }
#'
#' \strong{SHP} (AFRC, 1993, 1995):
#' \itemize{
#'   \item \code{FA}:
#'     \eqn{cmain = 0.217}
#'   \item \code{FJ}:
#'     \eqn{cmain = 0.236}
#'   \item \code{FS}:
#'     \eqn{cmain = 0.236 \times (365/afc) + 0.217 \times ((afc - 365)/afc)}
#'   \item \code{MA}:
#'     \eqn{cmain = 0.217 \times offtake\_rate + (0.217 \times 1.15) \times (1 - offtake\_rate)}
#'   \item \code{MJ}:
#'     \eqn{cmain = 0.236 \times offtake\_rate + (0.236 \times 1.15) \times (1 - offtake\_rate)}
#'   \item \code{MS}:
#'     A weighted average of juvenile and adult male coefficients using \code{afc},
#'     with an additional intact-male adjustment (multiplied by 1.15) weighted by \code{offtake\_rate}.
#' }
#'
#' \strong{PGS} (NRC, 1998):
#' \itemize{
#'   \item All cohorts:
#'     \deqn{cmain = 0.4435}
#' }
#'
#' @references
#' NRC (1998). \emph{Nutrient Requirements of Swine},
#' 10th Revised Edition. National Academies Press, Washington, DC.
#'
#' NRC (1996). \emph{Nutrient Requirements of Beef Cattle},
#' 7th Revised Edition. National Academies Press, Washington, DC.
#'
#' AFRC (1995). \emph{Energy and Protein Requirements of Ruminants}.
#' CAB International, Wallingford, UK.
#'
#' AFRC (1993). \emph{Energy and Protein Requirements of Ruminants}.
#' CAB International, Wallingford, UK.
#'
#' IPCC. (2019). \emph{2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories}. Chapter 10: Emissions from
#' Livestock and Manure Management, Equation 10.3; Table 10.4.
#'
#' IPCC. (2006). \emph{2006 IPCC Guidelines for National Greenhouse Gas Inventories}. Chapter 10: Emissions from
#' Livestock and Manure Management, Equation 10.3; Table 10.4.
#'
#' Wardeh, M. F. (2004). \emph{The nutrient requirements of the dromedary camel}.
#' Journal of Camel Science. 2004;1:37–45. The Camel Applied Research and Development Network (CARDN),
#' Arab Center for the Studies of Arid Zones and Dry Lands (ACSAD).
#'
#' @export
#'
calc_net_energy_maintenance <- function(
    animal,
    cohort,
    average_weight,
    milking_fraction = NA_real_,
    offtake_rate = NA_real_,
    afc = NA_real_
) {

  # Normalize offtake_rate
  offtake_rate <- normalize_rate(offtake_rate)

  # Validate inputs
  validate_maintenance_inputs(
    animal, cohort, average_weight,
    milking_fraction, offtake_rate, afc
  )
  cmain <- NA

  if (animal %in% c("CTL", "BFL")) {
    if (cohort == "FA") {
      # Weighted by milking_fraction
      cmain <- 0.386 * milking_fraction + 0.322 * (1 - milking_fraction)
    } else if (cohort %in% c("FS", "FJ", "MJ")) {
      cmain <- 0.322
    } else if (cohort %in% c("MA", "MS")) {
      # Weighted by offtake rate
      cmain <- 0.322 * offtake_rate + 0.37 * (1 - offtake_rate)
    }
  } else if (animal == "CML") {
    cmain <- 0.435 # Camelids fixed coefficient
  } else if (animal == "GTS") {
    cmain <- 0.315 # Goats fixed coefficient
  } else if (animal == "SHP") {
    # Sheep: different coefficients for cohorts
    if (cohort == "FA") {
      cmain <- 0.217
    } else if (cohort == "FS") {
      # Weighted by age at first calving (afc)
      cmain <- (0.236 * (365 / afc)) + (0.217 * ((afc - 365) / afc))
    } else if (cohort == "FJ") {
      cmain <- 0.236
    } else if (cohort == "MA") {
      # Weighted by offtake rate
      cmain <- 0.217 * offtake_rate + 0.217 * 1.15 * (1 - offtake_rate)
    } else if (cohort == "MS") {
      # Complex weighted average for subadult males
      cmain <- ((0.217 * offtake_rate + 0.217 * 1.15 * (1 - offtake_rate)) * ((afc - 365) / afc) +
                  (0.236 * offtake_rate + 0.236 * 1.15 * (1 - offtake_rate)) * (365 / afc))
    } else if (cohort == "MJ") {
      cmain <- 0.236 * offtake_rate + 0.236 * 1.15 * (1 - offtake_rate)
    }
  } else if (animal == "PGS") {
    cmain <- 0.4435 # Pigs fixed coefficient
  }
  # Default: metabolic body weight scaling
  return((average_weight^0.75) * cmain)
}

#' Calculate Energy for Activity
#'
#' Computes the **energy requirement for activity** (MJ/head/day).
#' This approach follows the IPCC Tier 2 energy partitioning method and applies
#' the following general equation:
#' energy_activity = cact * energy_maintenance
#' (except for sheep: cact * average_weight)
#' where cact is an activity coefficient reflecting the animal’s feeding
#' and management situation. (MJ d^-1 kg^-1).
#'
#'@param animal Character. Code identifying the livestock species.
#'   Supported values include:
#'   \itemize{
#'     \item \code{PGS}: pigs
#'     \item \code{CML}: camels
#'     \item \code{CHK}: chickens
#'     \item \code{CTL}: cattle
#'     \item \code{BFL}: buffalo
#'     \item \code{SHP}: sheep
#'     \item \code{GTS}: goats
#'   }
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
#' @param nemain Numeric. Energy required for maintenance, defined as the amount of energy needed to keep the animal in equilibrium such that body energy is neither gained nor lost. Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS (MJ/head/day).
#' @param average_weight Numeric. Average live weight over the cohort stage. Computed by accounting for the share of offtaken animals within the cohort, using their slaughter weight, and the potential final weight of animals that remain in the cohort (kg).
#' @param activity_fraction Numeric. Proportion of the assessment period during which the animal performs low-intensity movement typical of stall-feeding or near-field grazing, characterized by minimal walking distances and flat terrain  (fraction).
#' @param high_activity_fraction Numeric. Proportion of the assessment period during which the animal engages in sustained locomotion associated with herding or long-distance grazing, typically involving extended walking distances and/or uneven or hilly terrain (fraction).
#'
#' @return Numeric. Energy required for activity, defined as the amount of energy needed to obtain food, water and
#' shelter (example stall, grazing large areas). Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable
#' energy for CML and PGS (MJ/head/day).
#'
#' @details
#' The activity coefficient \code{cact} reflects the animal’s feeding and management conditions.
#' For CTL, BFL, SHP, and GTS, \code{cact} is calculated as a **weighted average** of the different activity levels over the assessment period.
#' Reference coefficients are derived from NRC (1996) and AFRC (1993) for CTL, BFL, SHP, and GTS; NRC (1998) for PGS; and Wardeh (2004) for CML.
#'
#' @references
#' NRC (1998). \emph{Nutrient Requirements of Swine},
#' 10th Revised Edition. National Academies Press, Washington, DC.
#'
#' NRC (1996). \emph{Nutrient Requirements of Beef Cattle},
#' 7th Revised Edition. National Academies Press, Washington, DC.
#'
#' AFRC (1993). \emph{Energy and Protein Requirements of Ruminants}.
#' CAB International, Wallingford, UK.
#'
#' IPCC. (2019). \emph{2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions from
#' Livestock and Manure Management, Equation 10.4; Table 10.5.
#'
#' IPCC. (2006). \emph{2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions from
#' Livestock and Manure Management, Equation 10.4; Table 10.5.
#'
#' Wardeh, M. F. (2004). \emph{The nutrient requirements of the dromedary camel}.
#' Journal of Camel Science. 2004;1:37–45. The Camel Applied Research and Development Network (CARDN),
#' Arab Center for the Studies of Arid Zones and Dry Lands (ACSAD).
#'
#' @export

calc_net_energy_activity <- function(
    animal,
    cohort,
    nemain,
    average_weight,
    activity_fraction,
    high_activity_fraction
) {
  # Validate inputs
  validate_activity_inputs(
    animal, cohort,
    nemain, average_weight,
    activity_fraction,
    high_activity_fraction
  )
  if (animal %in% c("CTL", "BFL")) {
    # Weighted by pasture management
    cact <- (0.17 * activity_fraction) + (0.36 * high_activity_fraction)
    ret <- cact * nemain
  } else if (animal %in% c("CML")) {
    cact <- (0.1 * (activity_fraction + high_activity_fraction))
    ret <- cact * nemain
  } else if (animal == "SHP") {
    cact <- (0.0107 * activity_fraction) + (0.024 * high_activity_fraction)
    ret <- cact * average_weight
  } else if (animal %in% c("GTS")) {
    cact <- (0.019 * activity_fraction) + (0.024 * high_activity_fraction)
    ret <- cact * average_weight
  } else if (animal == "PGS") {
    cact <- 0.125 * (activity_fraction + high_activity_fraction)
    ret <- cact * nemain
  }
  return(ret)
}

#' Calculate Energy for Growth
#'
#' Computes the **energy requirement for growth** (MJ/head/day), defined as the energy needed for body weight gain.
#' This approach follows the IPCC Tier 2 partitioning method and applies species-specific equations for growth energy requirements.
#'
#'@param animal Character. Code identifying the livestock species.
#'   Supported values include:
#'   \itemize{
#'     \item \code{PGS}: pigs
#'     \item \code{CML}: camels
#'     \item \code{CHK}: chickens
#'     \item \code{CTL}: cattle
#'     \item \code{BFL}: buffalo
#'     \item \code{SHP}: sheep
#'     \item \code{GTS}: goats
#'   }
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
#' @param average_weight Numeric. Average live weight over the cohort stage. Computed by accounting for the share of offtaken animals within the cohort, using their slaughter weight, and the potential final weight of animals that remain in the cohort (kg).
#' @param final_weight Numeric. Live weight at the end of the cohort stage, accounting for both surviving and offtaken animals. Computed in the GLEAM pipeline as a weighted average of the potential final weight of surviving animals and the slaughter weight of offtaken animals, based on the offtake rate (kg).
#' @param initial_weight Numeric. Live weight at the beginning of the cohort stage (kg).
#' @param adult_weight Numeric. Mature (adult) live weight that the animal can attain under given biological and management conditions (kg).
#' @param dwg Numeric. Average live weight of the cohort over the cohort stage (kg/head/day).
#' @param offtake_rate Numeric. Annual proportion of animals removed from the herd for each sex-age cohort (fraction).
#' @param duration Numeric. Amount of time that each animal spends in a specific cohort (days).
#'
#' @return Numeric. Energy required for growth (i.e., weight gain). Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS (MJ/head/day).
#'
#' @details
#' Energy for growth represents the energy required for tissue accretion associated with live weight gain.
#' Species-specific formulations follow IPCC Tier 2 guidelines.
#'
#' \itemize{
#'
#'   \item\strong{CTL and BFL} — NRC (1996); IPCC (2006, 2019).
#'
#' The equation uses a growth coefficient (\eqn{cgro}) that differs between
#' castrated and intact males. For male cohorts, the code calculates
#' \eqn{cgro} as a **weighted average** using `offtake_rate`, assuming that
#' animals removed from the herd are castrated and animals remaining in the
#' cohort are intact.
#'
#
#'   \item\strong{SHP and GTS} — Gibbs et al. (2002); AFRC (1993, 1995); IPCC (2006, 2019).
#'
#' For sheep, the coefficients \eqn{a} and \eqn{b} (MJ kg\eqn{^{-1}}) differ
#' between castrated and intact males. The code calculates a **weighted average**
#' using `offtake_rate`, assuming that offtaken animals are castrated.
#'

#'   \item\strong{CML} — Al-Jassim (2019).
#'
#' Growth energy is represented using a simplified linear relationship with
#' daily weight gain.
#'
#'   \item\strong{PGS} — NRC (1998)
#'
#' For pigs, growth is assumed to consist exclusively of **protein tissue**
#' and **fat tissue**, and growth energy requirements are expressed as
#' **metabolizable energy (ME)**.
#'
#' A growth energy coefficient (\eqn{cgro}, MJ kg\eqn{^{-1}} LW) is calculated as:
#'
#' \eqn{
#' cgro =
#' \mathrm{prot\_tissue\_frac} \times \mathrm{meat\_protein} \times \mathrm{meat\_protein\_energy}
#' + (1 - \mathrm{prot\_tissue\_frac}) \times \mathrm{fat\_adipose\_tissue\_frac} \times \mathrm{meat\_fat\_energy}
#' }
#'
#' Total metabolizable energy required for growth is then:
#'
#' \eqn{ME_{growth} = DWG \times cgro}
#'
#' where:
#' \itemize{
#'   \item \eqn{cgro} is the growth energy coefficient
#'     (MJ kg\eqn{^{-1}} live weight),
#'     \item \code{prot_tissue_frac = 0.65} is the fraction of protein tissue in daily weight gain,
#'   \item \code{meat_protein = 0.23} is the fraction of protein in protein tissue,
#'   \item \code{meat_protein_energy = 54.0} is the metabolizable energy cost of protein deposition
#'     (MJ kg protein\eqn{^{-1}}),
#'   \item \code{fat_adipose_tissue_frac = 0.90} is the fraction of fat in adipose tissue,
#'   \item \code{meat_fat_energy = 52.3} is the metabolizable energy cost of fat deposition
#'     (MJ kg fat\eqn{^{-1}}).
#' }
#' }
#'
#' @references
#' Al-Jassim, R. (2019). \emph{Metabolisable energy and protein requirements of the Arabian camel (Camelus dromedarius)}.
#' Journal of Camelid Science (12) 33-45
#'
#' NRC (1998). \emph{Nutrient Requirements of Swine},
#' 10th Revised Edition. National Academies Press, Washington, DC.
#'
#' NRC (1996). \emph{Nutrient Requirements of Beef Cattle},
#' 7th Revised Edition. National Academies Press, Washington, DC.
#'
#' AFRC (1995). \emph{Energy and Protein Requirements of Ruminants}.
#' CAB International, Wallingford, UK.
#'
#' AFRC (1993). \emph{Energy and Protein Requirements of Ruminants}.
#' CAB International, Wallingford, UK.
#'
#' Gibbs, M.J., Conneely, D., Johnson, D., Lassey, K.R. and Ulyatt, M.J. (2002).
#' \emph{CH4 emissions from enteric fermentation}. In: Background Papers: IPCC Expert Meetings on Good Practice Guidance and Uncertainty Management in National Greenhouse Gas Inventories, p 297–320. IPCC-NGGIP, Institute for Global Environmental Strategies (IGES), Hayama, Kanagawa, Japan.
#'
#' IPCC. (2019). \emph{2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions from
#' Livestock and Manure Management, Equation 10.6 and 10.7; Table 10.6.
#'
#' IPCC. (2006). \emph{2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions from
#' Livestock and Manure Management, Equation 10.6 and 10.7; Table 10.6.
#'
#' @export

calc_net_energy_growth <- function(
    animal,
    cohort,
    average_weight,
    final_weight,
    initial_weight,
    adult_weight,
    dwg,
    offtake_rate,
    duration
) {

  # Normalize offtake_rate
  offtake_rate <- normalize_rate(offtake_rate)

  # Validate inputs
  validate_growth_inputs(
    animal, cohort, average_weight, final_weight,
    initial_weight, adult_weight, dwg, offtake_rate, duration
  )
  if (animal %in% c("CTL", "BFL")) {
    if (cohort %in% c("FS", "FJ")) {
      cgro <- 0.8
    } else if (cohort %in% c("MS", "MJ")) {
      cgro <- 1.2 * (1 - offtake_rate) + 1 * offtake_rate
    }
    if (cohort %in% c("FS", "FJ", "MS", "MJ")) {
      ret <- 22.02 * ((average_weight / (cgro * adult_weight))^0.75) * (dwg^1.097)
    } else {
      return(0) # No growth for other cohorts
    }
  } else if (animal %in% c("CML")) {
    if (cohort %in% c("FS", "FJ", "MS", "MJ")) {
      ret <- 41.2 * dwg
    } else {
      ret <- 0
    }
  } else if (animal %in% c("SHP")) {
    # Sheep: a, b coefficients depend on cohort and offtake
    if (cohort %in% c("FS", "FJ")) {
      a <- 2.1
      b <- 0.45
    } else if (cohort %in% c("MS", "MJ")) {
      a <- 4.4 * offtake_rate + 2.5 * (1 - offtake_rate)
      b <- 0.32 * offtake_rate + 0.35 * (1 - offtake_rate)
    } else if (cohort %in% c("FA", "MA")) {
      a <- 0
      b <- 0
    }
    # Linear growth formula
    ret <- ((final_weight - initial_weight) * (a + 0.5 * b * (initial_weight + final_weight))) / duration
  } else if (animal %in% c("GTS")) {
    if (cohort %in% c("FS", "FJ", "MS", "MJ")) {
      a <- 5
      b <- 0.33
    } else if (cohort %in% c("FA", "MA")) {
      a <- 0
      b <- 0
    }
    ret <- ((final_weight - initial_weight) * (a + 0.5 * b * (initial_weight + final_weight))) / duration
  } else if (animal == "PGS") {
    prot_tissue_frac <- 0.65
    if (cohort %in% c("FS", "FJ", "MS", "MJ")) {
      cgro <- (prot_tissue_frac * 0.23 * 54) + ((1 - prot_tissue_frac) * 0.9 * 52.3)
      ret <- dwg * cgro
    } else {
      ret <- 0
    }
  } else {
    ret <- 0 # Default: no growth
  }
  return(ret)
}

#' Calculate Energy for Lactation
#'
#' Computes the **energy requirement for lactation** (MJ/head/day), defined as the
#' energy needed to support milk production by lactating females.
#' This approach follows the IPCC Tier 2 partitioning method and applies
#' species-specific equations for lactation energy requirements.
#'
#'@param animal Character. Code identifying the livestock species.
#'   Supported values include:
#'   \itemize{
#'     \item \code{PGS}: pigs
#'     \item \code{CML}: camels
#'     \item \code{CHK}: chickens
#'     \item \code{CTL}: cattle
#'     \item \code{BFL}: buffalo
#'     \item \code{SHP}: sheep
#'     \item \code{GTS}: goats
#'   }
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
#' @param milking_fraction Numeric. Share of adult females lactating within the assessment duration. Applies to species = CML, CTL, BFL, SHP, GTS. (fraction).
#' @param milk_yield Numeric. Average milk yield per milk-producing animal during the assessment duration (kg/head/day). This value can be calculated by dividing the total milk destinated to human consumption produced per milk-producing animal over the assessment duration by the length of the assessment period.
#' @param milk_fat Numeric. Milk fat fraction (kg fat / kg milk).
#' @param idle Numeric. Period during which the animal is not performing any productive physiological function such as pregnancy or lactation (days).
#' @param gest Numeric. Duration of pregnancy period (days).
#' @param litsize Numeric. Average number of offspring born per parturition (#).
#' This value can be calculated as the total number of offspring born divided by the total number of parturitions during the year.
#'
#' @param dr1 Numeric. Percentage of deaths in a herd over a year for juvenile cohorts (i.e. FJ and MJ) (fraction).
#' @param ckg Numeric. Live body weight of the animal at birth (kg).
#' @param wkg Numeric. Live body weight of the animal at weaning (kg).
#' @param lact Numeric. Duration of the lactation period, defined as the number of days during which the animal is lactating (days).
#' @param parturition_rate Numeric. Average annual number of parturition per female animal (#). A herd-level reproductive performance indicator calculated as the total number of parturitions (born) occurring during a year divided by the number of adult females potentially able to give birth during that year.
#'
#' @return Numeric. Energy required for lactation. Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS (MJ/head/day).
#'
#'
#' @details
#'
#' Energy for lactation (\code{energy_lactation}) represents the additional
#' energy required to support **milk synthesis** during lactation. Following
#' IPCC Tier 2 guidelines, lactation energy is calculated as a function of the
#' **quantity of milk produced** and a **species-specific energy cost per unit
#' of milk**.
#'
#'\strong{For CTL, BFL, CML, SHP and GTS}:
#'
#' Total milk production includes:
#' \itemize{
#'   \item milk extracted for human consumption (\code{milk_yield})
#'   \item milk consumed directly by offspring (\code{milk_for_offspring})
#' }
#'
#' Lactation energy requirements are applied **only to adult females** and are
#' scaled by the proportion of milked (\code{milking_fraction}) or lactating
#' (\code{parturition_rate}) animals within the cohort.
#'
#'
#' In general form, lactation energy is computed as:
#'
#' \deqn{
#' energy\_lactation =
#' (milk\_yield \times milking\_fraction + milk\_for\_offspring)
#' \times energy\_milk
#'
#' }
#'
#' where:
#'
#' \code{energy_milk} is a species-specific coefficient representing the
#' net energy cost of producing one kilogram of milk (MJ kg\eqn{^{-1}})
#'
#' Species-specific values of \code{energy_milk} are:
#' \itemize{
#'   \item \code{CTL}, \code{BFL}: estimated as a function of milk fat content,
#'     \eqn{1.47 + 0.40 \times (milk\_fat \times 100)} (NRC 1989),
#'   \item \code{CML}: 4.063 (Wardeh, 2004),
#'   \item \code{SHP}: 4.6 (AFRC, 1993; AFRC, 1995),
#'   \item \code{GTS}: 3.0 (AFRC, 1998).
#'   }
#'
#' \code{milk_for_offspring} is the daily amount of milk required to rear offspring across the year (kg day\eqn{^{-1}}).
#' It is calculated assuming that **5 kg of milk are required for each kilogram of live-weight gain up to weaning**, using the equation below.
#'
#' \deqn{
#' milk\_for\_offspring =
#' \frac{parturition\_rate \times 5 \times (wkg - ckg)}
#' {365} \code(AFRC, 1990)
#' }

#'
#' For \code{SHP} and \code{GTS}, \code{milk_for_offspring} also accounts for
#' the average number of offspring per birth by multiplying by \code{litsize}.
#'
#'
#' \strong{For PGS} — NRC (1998):
#'
#' For pigs, lactation energy accounts only for the milk consumed directly by offspring (\code{milk_for_offspring})
#' adjusted by the fraction of the reproductive cycle spent in lactation (\code{cadj}),
#' and is calculated as follows:
#'
#' \deqn{
#' energy\_lactation =
#' litsize \times (1 - 0.5 \times dr1)
#' \times \left(
#' \frac{0.02059 \times (wkg - ckg) \times 1000}{lact}
#' - \frac{0.3766}{0.67}
#' \right)
#' \times cadj
#' }
#'
#' where:
#' \itemize{
#'   \item \eqn{0.02059} is the coefficient for lactation energy requirement
#'     (MJ g live-weight\eqn{^{-1}}),
#'   \item \eqn{0.3766} is the coefficient for sow weight loss during lactation
#'     (\eqn{C_{wloss}}, MJ head\eqn{^{-1}} day\eqn{^{-1}}),
#'   \item \eqn{0.67} is the efficiency of conversion of dietary intake to milk
#'     energy (\eqn{C_{conv}}, fraction),
#'   \item \code{litsize} is litter size,
#'   \item \code{dr1} is the proportion of stillborn piglets,
#'   \item \eqn{wkg} and \eqn{ckg} are live weights at weaning and at birth,
#'     respectively (kg),
#'    \item \eqn{cadj} is the fraction of the reproductive cycle spent in lactation calculated as
#'
#'    \deqn{
#'    cadj = \frac{lact}{idle + gest + lact}
#'    }
#' }
#'
#' @references
#' AFRC (1998) \emph{The Nutrition of Goats. Wallingford: CAB International}.
#' Animut G., Puchala R., Goetsch A.L., Patra A.K., Sahlu T., Varel V.H., Wells J.
#'
#' AFRC (1995). \emph{Energy and Protein Requirements of Ruminants}.
#' CAB International, Wallingford, UK.
#'
#' AFRC (1993). \emph{Energy and Protein Requirements of Ruminants}.
#' CAB International, Wallingford, UK.
#'
#' AFRC (1990). \emph{Nutritive Requirements of Ruminant Animals: Energy.}
#' Rep. 5. Wallingford, UK: CAB International.
#'
#' IPCC. (2019). \emph{2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions from
#' Livestock and Manure Management, Equation 10.8-10.10.
#'
#' IPCC. (2006). \emph{2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions from
#' Livestock and Manure Management, Equation 10.8-10.10.
#'
#' NRC (1998). \emph{Nutrient Requirements of Swine},
#' 10th Revised Edition. National Academies Press, Washington, DC.
#'
#' NRC (1989) \emph{Nutrient Requirements of Dairy Cattle},
#' 6th Ed. . Washington, D.C. U.S.A: National Academy Press.
#'
#' Wardeh, M. F. (2004). \emph{The nutrient requirements of the dromedary camel}.
#' Journal of Camel Science. 2004;1:37–45. The Camel Applied Research and Development Network (CARDN),
#' Arab Center for the Studies of Arid Zones and Dry Lands (ACSAD).
#'
#' @export
#'
#'
#'
calc_net_energy_lactation <- function(
    animal,
    cohort,
    milking_fraction,
    milk_yield,
    milk_fat,
    idle,
    gest,
    litsize,
    dr1,
    ckg,
    wkg,
    lact,
    parturition_rate
) {
  # Validate inputs
  validate_lactation_inputs(
    animal, cohort, milking_fraction, milk_yield, milk_fat,
    idle, gest, litsize, dr1, ckg, wkg, lact,
    parturition_rate
  )
  if (animal %in% c("CTL", "BFL")) {
    if (cohort == "FA") {
      ret <- ((milk_yield * milking_fraction) + (parturition_rate * 5 * (wkg - ckg) / 365)) *
        (milk_fat * 100 * 0.40 + 1.47)
    } else {
      ret <- 0
    }
  } else if (animal %in% c("CML")) {
    if (cohort == "FA") {
      ret <- ((milk_yield * milking_fraction) + (parturition_rate * 5 * (wkg - ckg) / 365)) * 4.063
    } else {
      ret <- 0
    }
  } else if (animal %in% c("SHP")) {
    if (cohort == "FA") {
      # Includes effect of litter size and lambing interval
      ret <- ((milk_yield * milking_fraction)  + (litsize * parturition_rate * 5 *
                                                    (wkg - ckg) / 365)) * 4.6
    } else {
      ret <- 0
    }
  } else if (animal %in% c("GTS")) {
    if (cohort == "FA") {
      ret <- ((milk_yield * milking_fraction)  + (litsize * parturition_rate * 5 *
                                                    (wkg - ckg) / 365)) * 3
    } else {
      ret <- 0
    }
  } else if (animal == "PGS") {
    if (cohort != "FA") {
      ret <- 0
    } else {
      # Pigs: adjustment for lactation period
      cadj <- lact / (idle + gest + lact)
      ret <- litsize * (1 - 0.5 * dr1) * ((0.02059 * (wkg - ckg) * 1000 / lact) - (0.3766 / 0.67)) * cadj
    }
    return(ret)
  }
}

#' Calculate Energy for Egg Production (placeholder)
#'
#' Placeholder for metabolizable energy required for egg production (MJ/head/day).
#' Not implemented yet.
#'
#' @param animal Character. Code identifying the livestock species.
#'   Supported values include:
#'   \itemize{
#'     \item \code{PGS}: pigs
#'     \item \code{CML}: camels
#'     \item \code{CHK}: chickens
#'     \item \code{CTL}: cattle
#'     \item \code{BFL}: buffalo
#'     \item \code{SHP}: sheep
#'     \item \code{GTS}: goats
#'   }
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
#' @param eggs_year Numeric. Eggs produced per hen per year.
#' @param egg_weight Numeric. Average egg weight (kg/egg).
#'
#' @return No return value; this function always errors to indicate it's a stub.
#' @noRd
calc_net_energy_eggs <- function(
    animal,
    cohort,
    eggs_year,
    egg_weight
) {
  return(NA_real_)
}

#' Calculate Energy for Work
#'
#' Computes the **energy requirement for work** (MJ/head/day), defined as the
#' energy required for draft power. This approach follows the IPCC Tier 2 partitioning method and applies
#' species-specific coefficients.
#'
#'
#' @param animal Character. Code identifying the livestock species.
#'   Supported values include:
#'   \itemize{
#'     \item \code{PGS}: pigs
#'     \item \code{CML}: camels
#'     \item \code{CHK}: chickens
#'     \item \code{CTL}: cattle
#'     \item \code{BFL}: buffalo
#'     \item \code{SHP}: sheep
#'     \item \code{GTS}: goats
#'   }
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
#' @param nemain Numeric. Energy required for maintenance, defined as the amount of energy needed to keep the animal in equilibrium such that body energy is neither gained nor lost. Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS (MJ/head/day).
#' @param work_hours_female Numeric. Average daily working time per adult females for CTL, BFL and CML, expressed as hours worked per head per day  (hours/head/day). 
#' @param work_hours_male Numeric. Average daily working time per adult males for CTL, BFL and CML, expressed as hours worked per head per day  (hours/head/day). 
#' @param draught_fraction_female Numeric. Fraction of adult females involved in draught work (fraction).
#' @param draught_fraction_male Numeric. Fraction of adult males involved in draught work (fraction).
#'
#' @return Numeric. Energy required for work, used to estimate the energy required for draught power for CTL, BFL and CML. Assumed to be 0 for other species. (MJ/head/day). Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS (MJ/head/day).
#'
#'@details
#' Energy for work (\code{energy_work}) represents the additional energy required
#' to support \strong{draught power generation} by working animals.
#'
#' This component is applied only to draught-capable species and is scaled by
#' the fraction of adult animals involved in draught work (\code{draught_fraction})
#' and their average daily working time (\code{work_hours}).
#'
#' \strong{CTL and BFL} - Bamualim & Kartiarso (1985); IPCC (2006, 2019).
#' For cattle and buffalo, draught work energy is expressed as a proportion of
#' net energy for maintenance:
#'
#' \eqn{
#' energy\_work = 0.1 \times NEm \times work\_hours \times draught\_fraction
#' }
#'
#' where:
#' \itemize{
#'   \item \eqn{energy\_work} is net energy required for maintenance (MJ head\eqn{^{-1}} day\eqn{^{-1}}),
#'   \item \eqn{0.1} represents a 10% increase in maintenance energy per hour of work,
#'   \item \eqn{work\_hours} is the mean number of hours worked per animal per day,
#'   \item \eqn{draught\_fraction} is the fraction of adult males performing draught work.
#' }
#'
#' \strong{CML} -  Wilson (1989)
#' For camels, draught work energy is calculated using a fixed metabolizable
#' energy cost per hour of work:
#'
#' \deqn{
#' energy\_work = 4 \times work\_hours \times draught\_fraction
#' }
#'
#' where:
#' \itemize{
#'   \item \eqn{4} is the metabolizable energy requirement for draught work
#'     (MJ head\eqn{^{-1}} hour\eqn{^{-1}}),
#'   \item \eqn{work\_hours} is the mean daily working time per animal,
#'   \item \eqn{draught\_fraction} is the fraction of adult males involved in draught work.
#' }
#'
#'@references
#' Bamualim A., Kartiarso (1985). \emph{Nutrition of draught animals with special reference to Indonesia}.
#' In:Draught Animal Power for Production. Australian Centre for International agricultural Research (ACIAR),
#' Proceedings Series No. 10, ed. JW Copland. Canberra, A.C.T., Australia: ACIAR.
#'
#' IPCC. (2019). \emph{2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions from
#' Livestock and Manure Management, Equation 10.11.
#'
#' IPCC. (2006). \emph{2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions from
#' Livestock and Manure Management, Equation 10.11.
#'
#' Wilson (1989). \emph{The nutritional requirements of camel}.
#' In: Tisserand J.-L. (ed.). Séminaire sur la digestion, la nutrition et l'alimentation du dromadaire.
#' Zaragoza : CIHEAM. (1989). p. 171-179 (Options Méditerranéennes : Série A. Séminaires Méditerranéens; n. 2)
#'
#' @export
calc_net_energy_work <- function(
    animal,
    cohort,
    nemain,
    work_hours_female,
    work_hours_male,
    draught_fraction_female,
    draught_fraction_male
) {
  # Validate inputs
  validate_work_inputs(animal, cohort, nemain,  
                       work_hours_female,
                       work_hours_male,
                       draught_fraction_female,
                       draught_fraction_male)
  
  # Only adult males (MA) work
  if (animal %in% c("CTL", "BFL")) {
    if (cohort == "MA") {
      ret <- 0.1 * nemain * work_hours_male * draught_fraction_male
    } else if (cohort == "FA") {  
      ret <- 0.1 * nemain * work_hours_female * draught_fraction_female
    } else {
      ret <- 0
    }
  } else if (animal %in% c("CML")) {
    if (cohort == "MA") {
      ret <- 4 * work_hours_male * draught_fraction_male
    } else if (cohort == "FA") {  
      ret <- 4 * work_hours_female * draught_fraction_female
    } else {
      ret <- 0
    }
  } else if (animal %in% c("SHP", "GTS", "PGS", "CHK")) {
    ret <- 0 # No work for these species
  }
  return(ret)
}

#' Calculate Energy for Fibre Production
#'
#' Computes the **energy requirement for fibre production** (MJ/head/day),
#' defined as the energy needed to produce animal fibres such as wool or hair.
#' This component follows the IPCC Tier 2 partitioning approach and is applied
#' only to fibre-producing species and relevant cohorts, which are assumed by the model to be = ("FA", "FS", "MA", "MS").
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
#' @param fibre_prod Numeric. Annual fibre production yield (kg/head/year).
#'
#' @return Numeric. Energy required for the synthesis of fibre for SHP, GTS and CML. Assumed to be 0 for other species. (MJ/head/day).  Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS (MJ/head/day).
#' @details
#'
#' \itemize{
#'
#' \item\strong{SHP and GTS} - (AFRC 1995); IPCC (2006, 2019):
#'
#' For sheep and goats, fibre production energy is calculated assuming a fixed
#' net energy cost of \eqn{24} MJ per kilogram of fibre produced. Annual fibre
#' production is converted to a daily requirement as:
#'
#' \deqn{
#' energy\_fibre =
#' \frac{24 \times fibre\_prod}{365}
#' }
#'
#' where:
#' \itemize{
#'   \item \eqn{fibre\_prod} is annual fibre production
#'     (kg head\eqn{^{-1}} year\eqn{^{-1}}),
#'   \item \eqn{24} is the net energy requirement per kilogram of fibre
#'     (MJ kg fibre\eqn{^{-1}}).
#' }
#'
#' \item\strong{CML} - (AFRC, 1998; Cannas et al, 2007):
#'
#' For camels, energy requirements for fibre production are first calculated on
#' a **net energy (NE)** basis and then converted to **metabolizable energy (ME)**
#' using a net-to-metabolizable energy efficiency coefficient.
#'
#' Fibre energy requirements are calculated as:
#'
#' \deqn{
#' energy\_fibre =
#' \frac{24}{0.43}
#' \times
#' \frac{fibre\_prod}{365}
#' }
#'
#' where:
#' \itemize{
#'   \item \eqn{24} is the net energy requirement per kilogram of fibre
#'     (MJ kg fibre\eqn{^{-1}}),
#'   \item \eqn{0.43} is the efficiency of conversion from metabolizable energy
#'     to net energy for fibre production (dimensionless fraction),
#'   \item \code{fibre_prod} is the annual fibre production per animal
#'     (kg head\eqn{^{-1}} year\eqn{^{-1}}),
#'   \item division by \eqn{365} converts annual fibre production to a
#'     daily basis.
#' }
#'
#' The efficiency coefficient of 0.43 is adopted by analogy with goats, assuming
#' a dietary metabolizability of approximately 0.55, following AFRC guidance and
#' subsequent synthesis by Cannas et al. (2007).
#'
#'
#' \item\strong{Other species}
#' Fibre production energy is assumed to be zero for cattle, buffalo, pigs, and
#' poultry.
#' }
#'
#' @references
#'
#' AFRC (1998) \emph{The Nutrition of Goats. Wallingford: CAB International}.
#' Animut G., Puchala R., Goetsch A.L., Patra A.K., Sahlu T., Varel V.H., Wells J.
#'
#' AFRC (1995). \emph{Energy and Protein Requirements of Ruminants}.
#' CAB International, Wallingford, UK.
#'
#' Cannas, A., Atzori, A. S., Boe, F., & Teixeira, I. (2007).
#' \emph{Energy and protein requirements of goats}.
#' In: Dairy sheep nutrition (pp. 31-49). CAB International, Wallingford, UK.
#'
#' IPCC. (2019). \emph{2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories}. Chapter 10: Emissions from
#' Livestock and Manure Management, Equation 10.12.
#'
#' IPCC. (2006). \emph{2006 IPCC Guidelines for National Greenhouse Gas Inventories}. Chapter 10: Emissions from
#' Livestock and Manure Management, Equation 10.12.
#'
#' @export
#'
calc_net_energy_fibre <- function(
    animal,
    cohort,
    fibre_prod
) {
  # Validate inputs
  validate_fibre_inputs(animal, cohort, fibre_prod)
  # Only sheep, goats, camelids produce fibre
  if (animal %in% c("GTS", "SHP")) {
    if (cohort %in% c("FA", "FS", "MA", "MS")) {
      ret <- 24 * fibre_prod / 365 # 24 MJ/kg fibre, annualized
    } else {
      ret <- 0
    }
  } else if (animal %in% c("CML")) {
    if (cohort %in% c("FA", "FS", "MA", "MS")) {
      ret <- (24 / 0.43) * (fibre_prod / 365) # 0.43: efficiency factor for camels
    } else {
      ret <- 0
    }
  } else if (animal %in% c("CTL", "BFL", "PGS", "CHK")) {
    ret <- 0 # Not applicable
  }
  return(ret)
}

#' Calculate Energy for Pregnancy
#'
#' Computes the **energy requirement for pregnancy** (MJ/head/day) for pregnant
#' females. This approach follows the IPCC Tier 2 partitioning framework and is applied
#' only to **female cohorts**.
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
#' @param nemain Numeric. Energy required for maintenance, defined as the amount of energy needed to keep the animal in equilibrium such that body energy is neither gained nor lost. Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS (MJ/head/day).
#' @param parturition_rate Numeric. Average annual number of parturitions per female animal (#). A herd-level reproductive performance indicator calculated as the total number of parturitions (deliveries) occurring during a year divided by the number of adult females potentially able to give birth during that year.
#' @param litsize Numeric. Average number of offspring born per parturition (#). This value can be calculated as the total number of offspring born divided by the total number of parturitions during the year.
#' @param gest Numeric. Duration of pregnancy period (days).
#' @param idle Numeric. Period during which the animal is not performing any productive physiological function such as pregnancy or lactation (days).
#' @param lact Numeric. Duration of the lactation period, defined as the number of days during which the animal is lactating (days).
#' @param duration Numeric. Amount of time that each animal spends in a specific cohort (days).
#' @param offtake_rate Numeric. Annual proportion of animals removed from the herd for each sex-age cohort (fraction).
#'
#' @return Numeric. Energy required for pregnancy for pregnant adult females (MJ/head/day). Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS (MJ/head/day).
#'
#' @details
#' Pregnancy energy is calculated **only for female cohorts**
#' (i.e., \code{FA} and \code{FS}) and represents the additional
#' energy required to support gestation.
#'
#' For \code{FA}, pregnancy energy requirements are adjusted to account
#' for the proportion of time animals spend in gestation.
#'
#' For \code{FS}, only a fraction of animals is assumed to be of reproductive age;
#' pregnancy energy requirements are therefore scaled accordingly.
#'
#'
#' \itemize{
#'   \item For \strong{CTL and BFL} — IPCC (2006, 2019):
#'
#'   Pregnancy energy is approximated as 10% of maintenance energy.
#'   \itemize{
#'     \item \code{FA}:
#'       \deqn{
#'       energy\_pregnancy =
#'       0.10 \times nemain \times parturition\_rate \times \frac{gest}{365}
#'       }
#'     \item \code{FS}:
#'       \deqn{
#'       energy\_pregnancy =
#'       0.10 \times nemain \times \frac{gest}{duration}
#'       \times (1 - offtake\_rate)
#'       }
#'   }
#'
#'   \item For \strong{CML} — Wardeh (2004):
#'
#'   Pregnancy energy is estimated as 12% of maintenance energy.
#'   \itemize{
#'     \item \code{FA}:
#'       \deqn{
#'       energy\_pregnancy =
#'       0.12 \times nemain \times parturition\_rate
#'       }
#'     \item \code{FS}:
#'       \deqn{
#'       energy\_pregnancy =
#'       0.12 \times nemain \times \frac{gest}{duration}
#'       \times (1 - offtake\_rate)
#'       }
#'   }
#'
#'   \item For \strong{SHP and GTS} — IPCC (2006, 2019):
#'
#'   Pregnancy energy is calculated as a litter-size–dependent fraction
#'   of maintenance energy.
#'   \itemize{
#'     \item \code{FA}:
#'       \deqn{
#'       energy\_pregnancy =
#'       nemain \times cpreg \times parturition\_rate \times \frac{gest}{365}
#'       }
#'       where \eqn{cpreg} is defined as:
#'       \itemize{
#'         \item If \eqn{1 \le litsize \le 2}:
#'           \deqn{
#'           cpreg = 0.077 \times (2 - litsize) + 0.126 \times (litsize - 1)
#'           }
#'         \item If \eqn{litsize > 2}:
#'           \deqn{cpreg = 0.150}
#'       }
#'     \item \code{FS} -
#'       Pregnancy energy is calculated using the single-birth coefficient
#'       and scaled to the proportion of reproductive individuals in the cohort.
#'       \deqn{
#'       energy\_pregnancy =
#'       0.077 \times nemain \times \frac{gest}{duration}
#'       \times (1 - offtake\_rate)
#'       }
#'   }
#'
#'   \item For \strong{PGS} — NRC (1998):
#'
#'   \itemize{
#'     \item \code{FA}:
#'       \deqn{
#'       energy\_pregnancy = cgest \times litsize \times \frac{gest}{lact + gest + idle}
#'       }
#'     \item \code{FS}:
#'       \deqn{
#'       energy\_pregnancy =
#'       cgest \times litsize \times \frac{gest}{duration}
#'       \times (1 - offtake\_rate)
#'       }
#'   The default value for the gestation coefficient is
#'   \eqn{cgest = 0.14985} MJ piglet\eqn{^{-1}}.
#'   }
#' }
#'
#' @references
#' NRC (1998). \emph{Nutrient Requirements of Swine},
#' 10th Revised Edition. National Academies Press, Washington, DC.
#'
#' IPCC. (2019). \emph{2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories}. Chapter 10: Emissions from
#' Livestock and Manure Management, Equation 10.13; Table 10.7.
#'
#' IPCC. (2006). \emph{2006 IPCC Guidelines for National Greenhouse Gas Inventories}. Chapter 10: Emissions from
#' Livestock and Manure Management, Equation 10.13; Table 10.7.
#'
#' Wardeh, M. F. (2004). \emph{The nutrient requirements of the dromedary camel}.
#' Journal of Camel Science. 2004;1:37–45. The Camel Applied Research and Development Network (CARDN),
#' Arab Center for the Studies of Arid Zones and Dry Lands (ACSAD).
#'
#' @export
#'
calc_net_energy_pregnancy <- function(
    animal,
    cohort,
    nemain,
    parturition_rate,
    litsize,
    gest,
    idle,
    lact,
    duration,
    offtake_rate
) {

  # Normalize offtake_rate
  offtake_rate <- normalize_rate(offtake_rate)

  # Validate inputs
  validate_pregnancy_inputs(
    animal, cohort, nemain, parturition_rate,
    litsize, gest, idle, lact, duration, offtake_rate
  )
  if (animal %in% c("CTL", "BFL")) {
    if (cohort == "FA") {
      ret <- (nemain * 0.1 * parturition_rate * gest / 365)
    } else if (cohort == "FS") {
      ret <- (nemain * 0.1) * (gest/duration) * (1 - offtake_rate)
    } else {
      ret <- 0
    }
  } else if (animal %in% c("CML")) {
    if (cohort == "FA") {
      ret <- nemain * 0.12 * parturition_rate
    } else if (cohort == "FS") {
      ret <- nemain * 0.12 * (gest/duration) * (1 - offtake_rate)
    } else {
      ret <- 0
    }
  } else if (animal %in% c("SHP", "GTS")) {
    if (cohort == "FA") {
      cpreg <- 0
      # Litter size effect
      if (litsize >= 1 && litsize <= 2) {
        cpreg <- (0.077 * (2 - litsize) + 0.126 * (litsize - 1))
      } else if (litsize > 2) {
        cpreg <- 0.150
      }
      ret <- nemain * cpreg * parturition_rate * gest / 365
    } else if (cohort == "FS") {
      ret <- nemain * 0.077 * (gest/duration) * (1 - offtake_rate)
    } else {
      ret <- 0
    }
  } else if (animal == "PGS") {
    cgest <- 0.14985

    if (cohort == "FA") {
      ret <- cgest * litsize * gest / (idle + gest + lact)

    } else if (cohort == "FS") {

      ret <- cgest * litsize * (gest / duration) * (1 - offtake_rate)

    } else {
      ret <- 0
    }
  } else if (animal == "CHK") {
    ret <- 0 # Not applicable
  }
  return(ret)
}

#' Calculate REM (Net Energy for Maintenance / Digestible Energy)
#'
#' Computes the ratio of net energy available in the diet for maintenance to digestible energy.
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
#' @param diet_dig Numeric. Average digestibility of the the feed ration, expressed as ratio of digestible to gross energy content (fraction).
#'
#' @return Ratio of net energy available in diet for maintenance to digestible energy consumed, REM (fraction)
#'
#' @references
#' Gibbs M.J., Johnson D.E. (1993) \emph{Livestock Emissions}.
#' In: International Methane Emissions. Washington, D.C., U.S.A: US Environmental Protection Agency, Climate Change Division.
#'
#' IPCC. (2019). \emph{2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions from
#' Livestock and Manure Management, Equation 10.14.
#'
#' IPCC. (2006). \emph{2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions from
#' Livestock and Manure Management, Equation 10.14.
#'
#'
#' @export
calc_rem_maintenance <- function(
    animal,
    diet_dig
) {
  # Validate inputs
  validate_rem_inputs(animal, diet_dig)
  # Only ruminants: cattle, buffalo, sheep, goats
  if (animal %in% c("CTL", "BFL", "SHP", "GTS")) {
    # Polynomial fit from GLEAM
    ret <- 1.123 - (0.004092 * (diet_dig * 100)) + (0.00001126 * (diet_dig * 100)^2) - (25.4 / (diet_dig * 100))
  } else if (animal %in% c("PGS", "CHK", "CML")) {
    ret <- NA_real_ # Not applicable
  }
  return(ret)
}

#' Calculate REG (Net Energy for Growth / Digestible Energy)
#'
#' Computes the ratio of **net energy available for growth** to **digestible
#' energy consumed** (REG). REG represents the efficiency with which digestible
#' energy in the diet is converted into net energy retained as body tissue
#' (and wool growth where applicable).
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
#' @param diet_dig Numeric. Average digestibility of the the feed ration, expressed as ratio of digestible to gross energy content (fraction).
#'
#' @return Ratio of net energy available for growth in a diet to digestible energy consumed, REG (fraction)
#'
#' @references
#' Gibbs M.J., Johnson D.E. (1993) \emph{Livestock Emissions}.
#' In: International Methane Emissions. Washington, D.C., U.S.A: US Environmental Protection Agency, Climate Change Division.
#'
#' IPCC. (2019). \emph{2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions from
#' Livestock and Manure Management, Equation 10.15.
#'
#' IPCC. (2006). \emph{2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions from
#' Livestock and Manure Management, Equation 10.15.
#'
#' @export

calc_reg_growth <- function(
    animal,
    diet_dig
) {
  # Validate inputs
  validate_reg_inputs(animal, diet_dig)
  # Only ruminants: cattle, buffalo, sheep, goats
  if (animal %in% c("CTL", "BFL", "SHP", "GTS")) {
    # Polynomial fit
    ret <- 1.164 - (0.005160 * (diet_dig * 100)) + (0.00001308 * (diet_dig * 100)^2) - (37.4 / (diet_dig * 100))
  } else if (animal %in% c("PGS", "CHK", "CML")) {
    ret <- NA_real_ # Not applicable
  }
  return(ret)
}

#' Calculate Total Energy Requirement
#'
#' Computes the **total daily energy requirement** (MJ/head/day) by summing
#' relevant energy partitions (maintenance, activity, lactation, work, pregnancy,
#' growth, fibre, egg deposition).
#'
#' @param animal Character. Code identifying the livestock species.
#'   Supported values include:
#'   \itemize{
#'     \item \code{PGS}: pigs
#'     \item \code{CML}: camels
#'     \item \code{CHK}: chickens
#'     \item \code{CTL}: cattle
#'     \item \code{BFL}: buffalo
#'     \item \code{SHP}: sheep
#'     \item \code{GTS}: goats
#'   }
#' @param nemain Numeric. Energy required for maintenance, defined as the amount of energy needed to keep the animal in equilibrium such that body energy is neither gained nor lost. Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS (MJ/head/day).
#' @param neact Numeric. Energy required for activity, defined as the amount of energy needed to obtain feed, water and shelter (example stall feeding, grazing large areas). Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS (MJ/head/day).
#' @param nelact Numeric. Energy required for lactation. Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS (MJ/head/day).
#' @param nework Numeric. Energy required for work, used to estimate the energy required for draft power for CTL, BFL and CML. Assumed to be 0 for other species. (MJ/head/day). Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS (MJ/head/day).
#' @param nepreg Numeric. Energy required for pregnancy for pregnant adult females (MJ/head/day). Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS (MJ/head/day).
#' @param rem Numeric. Ratio of net energy available for growth in a diet to digestible energy consumed (fraction).
#' @param negrow Numeric. Energy required for growth (i.e., weight gain). Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS (MJ/head/day).
#' @param nefibre Numeric. Energy required for the synthesis of fibre for SHP, GTS and CML. Assumed to be 0 for other species. (MJ/head/day).  Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS (MJ/head/day).
#' @param neegg Numeric. Energy required for egg deposition for CHK (MJ/head/day).
#' @param reg Numeric. Ratio of net energy available for growth in a diet to digestible energy consumed (fraction).
#' @param diet_dig Numeric. Average digestibility of the the feed ration, expressed as ratio of digestible to gross energy content (fraction)
#'
#' @return Numeric. Total daily energy requirement (MJ/head/day). For CTL, BFL, SHP and GTS
#'   this is expressed as **gross energy intake requirement (GE)**. For CML and PGS
#'   the function returns the summed daily metabolizable energy requirement.
#'
#' @details
#' The total energy requirement is computed differently depending on whether
#' species energy requirements are expressed as **net energy (NE)** or
#' **metabolizable energy (ME)**.
#'
#' \itemize{
#'
#' \item \strong{Energy requirements expressed as net energy
#' (CTL, BFL, SHP, GTS)}:
#'
#' For these species, the calculation follows the IPCC Tier 2 structure
#' (Equation 10.16). Net energy requirements are converted to gross energy (GE)
#' intake using efficiency ratios for maintenance-type (\eqn{REM}) and
#' growth-type (\eqn{REG}) functions, and diet digestibility
#' (\eqn{diet\_dig = DE/GE}).
#'
#' \itemize{
#'   \item \strong{Cattle and buffalo (CTL, BFL)}:
#'     \deqn{
#'       energy\_total =
#'       \frac{\left(\frac{nemain + neact + nelact + nework + nepreg}{rem}\right)
#'       + \left(\frac{negrow}{reg}\right)}{diet\_dig}
#'     }
#'
#'   \item \strong{Sheep and goats (SHP, GTS)}:
#'     Fibre production is treated as a growth-type requirement:
#'     \deqn{
#'       energy\_total =
#'       \frac{\left(\frac{nemain + neact + nelact + nepreg}{rem}\right)
#'       + \left(\frac{negrow + nefibre}{reg}\right)}{diet\_dig}
#'     }
#' }
#'
#' \item \strong{Energy requirements expressed as metabolizable energy
#' (CML, PGS)}:
#'
#' For these species, total energy requirement is calculated as the
#' **direct sum** of the relevant daily energy components.
#'
#' \itemize{
#'   \item \strong{Camels (CML)}:
#'     \deqn{
#'       energy\_total =
#'       nemain + neact + nelact + nework + nefibre + nepreg + negrow
#'     }
#'
#'   \item \strong{Pigs (PGS)}:
#'     \deqn{
#'       energy\_total =
#'       nemain + neact + nelact + nepreg + negrow
#'     }
#' }
#' }
#' @references
#' IPCC. (2019). \emph{2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions from
#' Livestock and Manure Management, Equation 10.16.
#'
#' IPCC. (2006). \emph{2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions from
#' Livestock and Manure Management, Equation 10.16.
#'
#' @export
calc_total_energy_requirement <- function(
    animal,
    nemain,
    neact,
    nelact,
    nework,
    nepreg,
    rem,
    negrow,
    nefibre,
    neegg,
    reg,
    diet_dig
) {
  # Validate inputs
  validate_total_energy_inputs(
    animal, nemain, neact, nelact, nework, nepreg,
    rem, negrow, nefibre, neegg, reg, diet_dig
  )
  # Cattle, buffalo: sum maintenance, activity, lactation, work, pregnancy, growth
  if (animal %in% c("CTL", "BFL")) {
    ret <- (((nemain + neact + nelact + nework + nepreg) / rem) + ((negrow) / reg)) / diet_dig
  } else if (animal %in% c("SHP", "GTS")) {
    # Sheep, goats: add fibre
    ret <- (((nemain + neact + nelact + nepreg) / rem) + ((negrow + nefibre) / reg)) / diet_dig
  } else if (animal == "CML") {
    ret <- nemain + neact + nelact + nework + nefibre + nepreg + negrow
  } else if (animal == "PGS") {
    ret <- nemain + neact + nelact + nepreg + negrow
  } else if (animal == "CHK") {
    ret <- nemain + neact + negrow + neegg
  }
  return(ret)
}

#' Calculate Daily Dry Matter Intake
#'
#' Computes feed intake, expressed as **daily dry matter intake (DMI)** per animal (kg DM/head/day) from the
#' animal's daily energy requirement and the diet energy density.
#'
#' This function follows the IPCC Tier 2, logic.
#' Dry matter intake is calculated by dividing the appropriate daily energy requirement by the
#' corresponding diet energy density (MJ per kg DM).
#'
#' @param animal Character. Code identifying the livestock species.
#'   Supported values include:
#'   \itemize{
#'     \item \code{PGS}: pigs
#'     \item \code{CML}: camels
#'     \item \code{CHK}: chickens
#'     \item \code{CTL}: cattle
#'     \item \code{BFL}: buffalo
#'     \item \code{SHP}: sheep
#'     \item \code{GTS}: goats
#'   }
#' @param total_energy Numeric. Total daily energy requirement (MJ/head/day). For CTL, BFL, SHP and GTS this is expressed as **gross energy intake requirement (GE)**. For CML and PGS the function returns the summed daily metabolizable energy requirement.
#' @param diet_ge Numeric. Average gross energy content of the diet (MJ/kg DM).
#' @param diet_me Numeric. Average metabolizable energy content of the diet (MJ/kg DM).
#'
#' @return Numeric. Daily dry matter intake of feed (kg DM/head/day).
#'
#' @details
#' The function applies one of two analogous intake calculations, depending on how the
#' upstream energy requirement is expressed:
#'
#' \itemize{
#'   \item \strong{total_energy expressed as total gross energy - (CTL, BFL, SHP, GTS):}
#'
#'   Upstream calculations provide total energy as **gross energy intake requirement**
#'   (\eqn{GE}, MJ/head/day). Dry matter intake is:
#'   \deqn{DMI = \frac{GE}{diet\_ge}}
#'
#'   \item \strong{total_energy expressed as total metabolizable energy and camelids - (PGS, CML):}
#'
#'   Upstream calculations provide total energy as **metabolizable energy requirement**
#'   (\eqn{ME}, MJ/head/day). Dry matter intake is:
#'   \deqn{DMI = \frac{ME}{diet\_me}}
#' }
#'
#' @references
#' IPCC. (2006). \emph{2006 IPCC Guidelines for National Greenhouse Gas Inventories},
#' Volume 4 (AFOLU), Chapter 10: \emph{Emissions from Livestock and Manure Management}.
#'
#' IPCC. (2019). \emph{2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories},
#' Volume 4 (AFOLU), Chapter 10: \emph{Emissions from Livestock and Manure Management}.
#'
#'
#' @export
calc_dry_matter_intake <- function(
    animal,
    total_energy,
    diet_ge,
    diet_me
) {
  # Validate inputs
  validate_dmi_inputs(animal, total_energy, diet_ge, diet_me)
  # Ruminants: use gross energy
  if (animal %in% c("CTL", "BFL", "SHP", "GTS")) {
    ret <- total_energy / diet_ge
  } else if (animal %in% c("PGS", "CHK", "CML")) {
    # Monogastrics/camelids: use metabolizable energy
    ret <- total_energy / diet_me
  }
  return(ret)
}
