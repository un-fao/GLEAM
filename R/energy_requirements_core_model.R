#' Calculate Energy for Maintenance
#'
#' Computes the energy requirement for maintenance by cohort (MJ/head/day), 
#' defined as the energy required to maintain basal physiological functions at equilibrium,
#' with no net gain or loss of body energy.
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
#' @param live_weight_cohort_average Numeric. Average live weight over the cohort stage. Computed by accounting 
#' for the share of offtaken animals within the cohort, using their slaughter weight, and the potential 
#' final weight of animals that remain in the cohort (kg).
#' @param lactating_females_fraction Numeric. Proportion of adult females that are lactating during the assessment period (fraction). 
#' Required only for species = CML, CTL, BFL, SHP, and GTS.
#' @param offtake_rate Numeric. Annual proportion of animals removed from the herd for
#'  each sex-age cohort (fraction).
#' @param age_first_parturition Numeric. Age at first parturition for female breeding animals (days)
#'
#' @return Numeric. Energy required for maintenance, defined as the amount of energy needed to 
#' keep the animal at equilibrium such that body energy is neither gained nor lost. 
#' Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for 
#' CML and PGS (MJ/head/day).
#'
#' @details
#' This approach follows the IPCC Tier 2 partitioning method and applies:
#'
#' \eqn{energy\_requirement\_maintenance = cmain \times average\_weight^{0.75}}
#'
#' where \eqn{cmain} is a category-specific coefficient (MJ/day/kg\eqn{^{0.75}}) that reflects
#' basal metabolic requirements and varies by species, physiological status, and sex.
#'
#' For selected cohorts, \eqn{cmain} is computed as a weighted average to account for:
#' \itemize{
#'   \item \code{CTL, BFL}: lactating vs. non-lactating females
#'   \item \code{CTL, BFL, SHP}: intact vs. castrated males - Offtaken animals assumed castrated
#'   \item \code{SHP}: animals below vs. above one year of age
#' }
#'
#' \strong{Specific coefficients by species and cohort:}
#'
#' \strong{CTL and BFL} (NRC, 1996; AFRC, 1993):
#' \itemize{
#'   \item \code{FA}:
#'     \eqn{cmain = 0.386 \times lactating\_females\_fraction + 0.322 \times (1 - lactating\_females\_fraction)}
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
#' \strong{GTS} (AFRC, 1993):
#' \itemize{
#'   \item All cohorts:
#'     \eqn{cmain = 0.315}
#' }
#'
#' \strong{SHP} (AFRC, 1993):
#' \itemize{
#'   \item \code{FA}:
#'     \eqn{cmain = 0.217}
#'   \item \code{FJ}:
#'     \eqn{cmain = 0.236}
#'   \item \code{FS}:
#'     \eqn{cmain = 0.236 \times (365/age\_first\_parturition) +
#'          0.217 \times ((age\_first\_parturition - 365)/age\_first\_parturition)}
#'   \item \code{MA}:
#'     \eqn{cmain = 0.217 \times offtake\_rate + (0.217 \times 1.15) \times (1 - offtake\_rate)}
#'   \item \code{MJ}:
#'     \eqn{cmain = 0.236 \times offtake\_rate + (0.236 \times 1.15) \times (1 - offtake\_rate)}
#'   \item \code{MS}:
#'     \eqn{cmain =
#'       (0.217 \times offtake\_rate + (0.217 \times 1.15) \times (1 - offtake\_rate)) \times ((age\_first\_parturition - 365)/age\_first\_parturition) +
#'       (0.236 \times offtake\_rate + (0.236 \times 1.15) \times (1 - offtake\_rate)) \times (365/age\_first\_parturition)}
#' }
#' \strong{PGS} (NRC, 1998):
#' \itemize{
#'   \item All cohorts: \eqn{cmain = 0.4435}
#' }
#'
#' @seealso
#' \code{\link{calc_avg_weights}} 
#'
#' @references
#' NRC (1998). \emph{Nutrient Requirements of Swine},
#' 10th Revised Edition. National Academies Press, Washington, DC.
#'
#' NRC (1996). \emph{Nutrient Requirements of Beef Cattle},
#' 7th Revised Edition. National Academies Press, Washington, DC.
#'
#' AFRC (1993). \emph{Energy and Protein Requirements of Ruminants. An Advisory Manual Prepared by the AFRC Technical Committee on Responses to Nutrients.} 
#' CAB International, Wallingford, UK.
#'
#' IPCC. (2019). \emph{2019 Refinement to the 2006 IPCC Guidelines for National
#'  Greenhouse Gas Inventories}. Chapter 10: Emissions from
#' Livestock and Manure Management, Equation 10.3; Table 10.4.
#'
#' IPCC. (2006). \emph{2006 IPCC Guidelines for National Greenhouse Gas Inventories}.
#' Chapter 10: Emissions from Livestock and Manure Management, Equation 10.3; Table 10.4.
#'
#' Wardeh, M. F. (2004). \emph{The nutrient requirements of the dromedary camel}.
#' Journal of Camel Science, 1(1):37-45. The Camel Applied Research and Development Network (CARDN),
#' Arab Center for the Studies of Arid Zones and Dry Lands (ACSAD).
#'
#' @export
calc_metabolic_energy_req_maintenance <- function(
    species_short,
    cohort_short,
    live_weight_cohort_average,
    lactating_females_fraction = NA_real_,
    offtake_rate = NA_real_,
    age_first_parturition = NA_real_
) {

  # Validate inputs
  validate_maintenance_inputs(
    species_short, cohort_short, live_weight_cohort_average,
    lactating_females_fraction, offtake_rate, age_first_parturition
  )

  # Normalize offtake_rate if it's available (not NA_real_)
  if (!is.na(offtake_rate)) {
    offtake_rate <- normalize_rate(offtake_rate)
  }

  if (species_short %in% c("CTL", "BFL")) {
    if (cohort_short == "FA") {
      # Weighted by lactating_females_fraction
      cmain <- 0.386 * lactating_females_fraction + 0.322 * (1 - lactating_females_fraction)
    } else if (cohort_short %in% c("FS", "FJ", "MJ")) {
      cmain <- 0.322
    } else if (cohort_short %in% c("MA", "MS")) {
      # Weighted by offtake rate
      cmain <- 0.322 * offtake_rate + 0.37 * (1 - offtake_rate)
    }
  } else if (species_short == "CML") {
    cmain <- 0.435 # Camelids fixed coefficient
  } else if (species_short == "GTS") {
    cmain <- 0.315 # Goats fixed coefficient
  } else if (species_short == "SHP") {
    # Sheep: different coefficients for cohorts
    if (cohort_short == "FA") {
      cmain <- 0.217
    } else if (cohort_short == "FS") {
      # Weighted by age at first calving (age_first_parturition)
      cmain <- (0.236 * (365 / age_first_parturition)) +
        (0.217 * ((age_first_parturition - 365) / age_first_parturition))
    } else if (cohort_short == "FJ") {
      cmain <- 0.236
    } else if (cohort_short == "MA") {
      # Weighted by offtake rate
      cmain <- 0.217 * offtake_rate + 0.217 * 1.15 * (1 - offtake_rate)
    } else if (cohort_short == "MS") {
      # Complex weighted average for subadult males
      cmain <- (0.217 * offtake_rate + 0.217 * 1.15 * (1 - offtake_rate)) *
        ((age_first_parturition - 365) / age_first_parturition) +
        (0.236 * offtake_rate + 0.236 * 1.15 * (1 - offtake_rate)) *
        (365 / age_first_parturition)
    } else if (cohort_short == "MJ") {
      cmain <- 0.236 * offtake_rate + 0.236 * 1.15 * (1 - offtake_rate)
    }
  } else if (species_short == "PGS") {
    cmain <- 0.4435 # Pigs fixed coefficient
  }
  # Default: metabolic body weight scaling
  energy_requirement_maintenance <- (live_weight_cohort_average^0.75) * cmain
  return(energy_requirement_maintenance)
}

#' Calculate Energy for Activity
#'
#' Computes the energy requirement for activity by cohort (MJ/head/day), 
#' defined as the amount of energy needed to support animal movement and physical activity.
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
#' @param energy_requirement_maintenance Numeric. Energy required for maintenance, defined as the amount of energy needed to 
#' keep the animal at equilibrium such that body energy is neither gained nor lost. 
#' Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for 
#' CML and PGS (MJ/head/day).
#' @param live_weight_cohort_average Numeric. Average live weight over the cohort stage. Computed by accounting 
#' for the share of offtaken animals within the cohort, using their slaughter weight, and the potential 
#' final weight of animals that remain in the cohort (kg).
#' @param low_activity_fraction Numeric. Proportion of the assessment period during which the animal performs 
#' low-intensity movement typical of stall-feeding or near-field grazing, characterized by minimal walking distances and flat terrain  (fraction).
#' @param high_activity_fraction Numeric. Proportion of the assessment period during which the animal engages in sustained locomotion associated 
#' with herding or long-distance grazing, typically involving extended walking distances and/or uneven or hilly terrain (fraction).
#'
#' @return Numeric. Energy required for activity, defined as the amount of energy needed to support animal movement and physical activity (MJ/head/day). 
#' Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS.
#'
#' @details
#' This approach follows the IPCC Tier 2 energy partitioning method and applies:
#'
#' \eqn{energy\_requirement\_activity = cact \times energy\_requirement\_maintenance}
#' 
#' For \code{SHP} and \code{GTS}, activity energy is calculated as:
#'
#' \eqn{energy\_requirement\_activity = cact \times live\_weight\_cohort\_average}
#' 
#' where 
#' 
#' \eqn{cact} is an activity coefficient (dimensionless for \code{CTL}, \code{BFL}, \code{PGS};
#' MJ/day/kg for \code{SHP},  \code{GTS}) that reflects the animal’s feeding and management conditions.
#' \code{energy_requirement_maintenance} can be calculated using
#' \code{\link{calc_metabolic_energy_req_maintenance}()}.
#' 
#' For \code{CTL, BFL, SHP} and \code{GTS}, \eqn{cact} is computed as a *weighted average* of activity levels
#' over the assessment period to account for variation in management and grazing intensity.
#' 
#' \strong{Specific coefficients by species and cohort:}
#'
#' \strong{CTL, BFL} (NRC, 1996; AFRC, 1993):
#' \itemize{
#'   \item \code{low_activity_fraction}: \eqn{cact = 0.17}
#'   \item \code{high_activity_fraction}: \eqn{cact = 0.36}
#'   }
#' \strong{CML} (Wardeh, 2004):
#' \itemize{
#'   \item \code{all activity levels}: \eqn{cact = 0.1}
#'   }
#'\strong{GTS} (AFRC, 1993):
#' \itemize{
#'   \item \code{low_activity_fraction}: \eqn{cact = 0.019}
#'   \item \code{high_activity_fraction}: \eqn{cact = 0.024}
#'   }
#' \strong{SHP} (AFRC, 1993):
#' \itemize{
#'   \item \code{low_activity_fraction}: \eqn{cact = 0.0107}
#'   \item \code{high_activity_fraction}: \eqn{cact = 0.024}
#'      }
#' \strong{PGS} (NRC, 1998):
#' \itemize{
#'   \item \code{all activity levels}: \eqn{cact = 0.125}
#'   }
#'   
#' @seealso
#' \code{\link{calc_metabolic_energy_req_maintenance}} 
#' \code{\link{calc_avg_weights}} 
#' 
#' @references
#' NRC (1998). \emph{Nutrient Requirements of Swine},
#' 10th Revised Edition. National Academies Press, Washington, DC.
#'
#' NRC (1996). \emph{Nutrient Requirements of Beef Cattle},
#' 7th Revised Edition. National Academies Press, Washington, DC.
#'
#' AFRC (1993). \emph{Energy and Protein Requirements of Ruminants. An Advisory Manual Prepared by the AFRC Technical Committee on Responses to Nutrients.} 
#' CAB International, Wallingford, UK.
#'
#' IPCC. (2019). \emph{2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories},
#'   Chapter 10: Emissions from Livestock and Manure Management, Equation 10.4; Table 10.5.
#'
#' IPCC. (2006). \emph{2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions
#'   from Livestock and Manure Management, Equation 10.4; Table 10.5.
#'
#' Wardeh, M. F. (2004). \emph{The nutrient requirements of the dromedary camel}.
#' Journal of Camel Science, 1(1):37-45. The Camel Applied Research and Development Network (CARDN),
#' Arab Center for the Studies of Arid Zones and Dry Lands (ACSAD).
#'
#' @export
calc_metabolic_energy_req_activity <- function(
    species_short,
    cohort_short,
    energy_requirement_maintenance,
    live_weight_cohort_average,
    low_activity_fraction,
    high_activity_fraction
) {
  # Validate inputs
  validate_activity_inputs(
    species_short, cohort_short,
    energy_requirement_maintenance, live_weight_cohort_average,
    low_activity_fraction,
    high_activity_fraction
  )

  if (species_short %in% c("CTL", "BFL")) {
    # Weighted by pasture management
    cact <- (0.17 * low_activity_fraction) + (0.36 * high_activity_fraction)
    energy_requirement_activity <- cact * energy_requirement_maintenance
  } else if (species_short %in% c("CML")) {
    cact <- (0.1 * (low_activity_fraction + high_activity_fraction))
    energy_requirement_activity <- cact * energy_requirement_maintenance
  } else if (species_short == "SHP") {
    cact <- (0.0107 * low_activity_fraction) + (0.024 * high_activity_fraction)
    energy_requirement_activity <- cact * live_weight_cohort_average
  } else if (species_short %in% c("GTS")) {
    cact <- (0.019 * low_activity_fraction) + (0.024 * high_activity_fraction)
    energy_requirement_activity <- cact * live_weight_cohort_average
  } else if (species_short == "PGS") {
    cact <- 0.125 * (low_activity_fraction + high_activity_fraction)
    energy_requirement_activity <- cact * energy_requirement_maintenance
  }
  return(energy_requirement_activity)
}

#' Calculate Energy for Growth
#'
#' Computes the energy requirement for growth by cohort (MJ/head/day), defined 
#' as the energy required for body tissue accretion, corresponding to the retained energy 
#' component of live weight gain. 
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
#' @param live_weight_cohort_average Numeric. Average live weight over the cohort stage. Computed by accounting 
#' for the share of offtaken animals within the cohort, using their slaughter weight, and the potential 
#' final weight of animals that remain in the cohort (kg).
#' @param live_weight_cohort_final Numeric. Live weight at the end of the cohort stage, accounting for 
#' both surviving and offtaken animals. Computed as a weighted average of the potential final weight of surviving animals 
#' and the slaughter weight of offtaken animals, based on the offtake rate (kg).
#' @param live_weight_cohort_initial Numeric. Live weight at the beginning of the cohort stage (kg).
#' @param mature_weight Numeric. Mature (adult) live weight that the animal can attain under given 
#' biological and management conditions (kg).
#' @param daily_weight_gain Numeric. Average live weight gain of the cohort over the cohort stage (kg/head/day).
#' @param offtake_rate Numeric. Annual proportion of animals removed from the herd for each sex-age cohort (fraction).
#' @param cohort_duration_days Numeric. Amount of time that each animal spends in a specific cohort (days).
#'
#' @return Numeric. Energy required for growth (i.e., weight gain) (MJ/head/day). Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS.
#'
#' @details
#' This function follows the IPCC Tier 2 energy partitioning
#' approach and applies species-specific equations for growth energy requirements.
#' 
#' In general, growth energy is computed only for growing cohorts (\code{FJ}, \code{FS}, \code{MJ}, \code{MS});
#'   in this implementation, growth is set to 0 for adult cohorts (\code{FA}, \code{MA}).
#'
#' \strong{Species-specific approach:}
#' \itemize{
#'   \item \strong{CTL and BFL} (NRC, 1996; IPCC, 2006; IPCC, 2019)
#'
#'   Growth energy is computed using a growth coefficient \eqn{cgro} that differs between
#'   castrated and intact males. For male cohorts, \eqn{cgro} is calculated as a weighted average
#'   using \code{offtake_rate}, assuming that animals removed from the herd are castrated and
#'   animals remaining in the cohort are intact.
#'   
#'   \item \strong{SHP and GTS} (Gibbs et al., 2002; AFRC, 1993; IPCC, 2006; IPCC, 2019)
#'
#'   For sheep and goats, growth energy is calculated using a linear formulation with coefficients
#'   \eqn{a} and \eqn{b} (MJ/kg live weight). For male cohorts, the coefficients differ between
#'   castrated and intact males; the model computes a weighted average using \code{offtake_rate},
#'   assuming that offtaken animals are castrated.
#'
#'   \item \strong{CML} (Al-Jassim, 2019)
#'
#'   Growth energy is represented using a simplified linear relationship with daily weight gain.
#'
#'   \item \strong{PGS} (NRC, 1998)
#'
#'   For pigs, growth is assumed to consist exclusively of protein tissue and fat tissue, and
#'   growth energy requirements are expressed as metabolizable energy (ME).
#'
#'   The growth energy coefficient \eqn{cgro} (MJ/kg live weight) is calculated as:
#'
#'   \eqn{
#'     cgro =
#'     prot\_tissue\_frac \times meat\_protein \times meat\_protein\_energy
#'     + (1 - prot\_tissue\_frac) \times fat\_adipose\_tissue_frac \times meat\_fat\_energy
#'   }
#'
#'   Total metabolizable energy required for growth is then:
#'
#'   \eqn{energy\_requirement\_growth = daily\_weight\_gain \times cgro}
#'
#'   where:
#'   \itemize{
#'     \item \eqn{cgro} is the growth energy coefficient (MJ/kg live weight),
#'     \item \code{prot_tissue_frac = 0.65} is the fraction of protein tissue in daily weight gain,
#'     \item \code{meat_protein = 0.23} is the fraction of protein in protein tissue,
#'     \item \code{meat_protein_energy = 54.0} is the ME cost of protein deposition (MJ/kg protein),
#'     \item \code{fat_adipose_tissue_frac = 0.90} is the fraction of fat in adipose tissue,
#'     \item \code{meat_fat_energy = 52.3} is the ME cost of fat deposition (MJ/kg fat).
#'   }
#'   
#'   }
#' 
#' @seealso
#' \code{\link{calc_cohort_weights}} 
#' \code{\link{calc_avg_weights}} 
#' \code{\link{calc_daily_weight_gain}} 
#'
#' @references
#' Al-Jassim, R. (2019). \emph{Metabolisable energy and protein requirements of the Arabian camel
#'   (Camelus dromedarius)}. Journal of Camelid Science (12) 33-45
#'
#' NRC (1998). \emph{Nutrient Requirements of Swine},
#' 10th Revised Edition. National Academies Press, Washington, DC.
#'
#' NRC (1996). \emph{Nutrient Requirements of Beef Cattle},
#' 7th Revised Edition. National Academies Press, Washington, DC.
#'
#' AFRC (1993). \emph{Energy and Protein Requirements of Ruminants. An Advisory Manual Prepared by the AFRC Technical Committee on Responses to Nutrients.} 
#' CAB International, Wallingford, UK.
#'
#' Gibbs, M.J., Conneely, D., Johnson, D., Lassey, K.R. and Ulyatt, M.J. (2002).
#' \emph{CH4 emissions from enteric fermentation}. In: Background Papers: IPCC Expert Meetings on Good
#' Practice Guidance and Uncertainty Management in National Greenhouse Gas Inventories, p 297–320.
#' IPCC-NGGIP, Institute for Global Environmental Strategies (IGES), Hayama, Kanagawa, Japan.
#'
#' IPCC. (2019). \emph{2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories},
#'   Chapter 10: Emissions from Livestock and Manure Management, Equation 10.6 and 10.7; Table 10.6.
#'
#' IPCC. (2006). \emph{2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions
#'   from Livestock and Manure Management, Equation 10.6 and 10.7; Table 10.6.
#'
#' @export
calc_metabolic_energy_req_growth <- function(
    species_short,
    cohort_short,
    live_weight_cohort_average = NA_real_,
    live_weight_cohort_final = NA_real_,
    live_weight_cohort_initial = NA_real_,
    mature_weight = NA_real_,
    daily_weight_gain = NA_real_,
    offtake_rate = NA_real_,
    cohort_duration_days = NA_real_
) {

  # Validate inputs
  validate_growth_inputs(
    species_short, cohort_short, live_weight_cohort_average, live_weight_cohort_final,
    live_weight_cohort_initial, mature_weight, daily_weight_gain, offtake_rate, cohort_duration_days
  )

  # Normalize offtake_rate if it's available (not NA_real_)
  if (!is.na(offtake_rate)) {
    offtake_rate <- normalize_rate(offtake_rate)
  }

  if (species_short %in% c("CTL", "BFL")) {
    if (cohort_short %in% c("FS", "FJ")) {
      cgro <- 0.8
    } else if (cohort_short %in% c("MS", "MJ")) {
      cgro <- 1.2 * (1 - offtake_rate) + 1 * offtake_rate
    }
    if (cohort_short %in% c("FS", "FJ", "MS", "MJ")) {
      energy_requirement_growth <- 22.02 *
        ((live_weight_cohort_average / (cgro * mature_weight))^0.75) * (daily_weight_gain^1.097)
    } else {
      energy_requirement_growth <- 0 # No growth for other cohorts
    }
  } else if (species_short %in% c("CML")) {
    if (cohort_short %in% c("FS", "FJ", "MS", "MJ")) {
      energy_requirement_growth <- 41.2 * daily_weight_gain
    } else {
      energy_requirement_growth <- 0
    }
  } else if (species_short %in% c("SHP")) {
    # Sheep: a, b coefficients depend on cohort and offtake
    if (cohort_short %in% c("FS", "FJ")) {
      a <- 2.1
      b <- 0.45
    } else if (cohort_short %in% c("MS", "MJ")) {
      a <- 4.4 * offtake_rate + 2.5 * (1 - offtake_rate)
      b <- 0.32 * offtake_rate + 0.35 * (1 - offtake_rate)
    } else if (cohort_short %in% c("FA", "MA")) {
      a <- 0
      b <- 0
    }
    # Linear growth formula
    energy_requirement_growth <- (
      (live_weight_cohort_final - live_weight_cohort_initial) *
        (a + 0.5 * b * (live_weight_cohort_initial + live_weight_cohort_final))
    ) / cohort_duration_days
  } else if (species_short %in% c("GTS")) {
    if (cohort_short %in% c("FS", "FJ", "MS", "MJ")) {
      a <- 5
      b <- 0.33
    } else if (cohort_short %in% c("FA", "MA")) {
      a <- 0
      b <- 0
    }
    energy_requirement_growth <- (
      (live_weight_cohort_final - live_weight_cohort_initial) *
        (a + 0.5 * b * (live_weight_cohort_initial + live_weight_cohort_final))
    ) / cohort_duration_days
  } else if (species_short == "PGS") {
    prot_tissue_frac <- 0.65
    if (cohort_short %in% c("FS", "FJ", "MS", "MJ")) {
      cgro <- (prot_tissue_frac * 0.23 * 54) + ((1 - prot_tissue_frac) * 0.9 * 52.3)
      energy_requirement_growth <- daily_weight_gain * cgro
    } else {
      energy_requirement_growth <- 0
    }
  } else {
    energy_requirement_growth <- 0 # Default: no growth
  }
  return(energy_requirement_growth)
}

#' Calculate Energy for Lactation
#'
#' Computes the energy requirement for lactation by cohort (MJ/head/day), defined as the
#' energy needed to support milk production by lactating females. 
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
#' @param lactating_females_fraction Numeric. Proportion of adult females that are lactating during the assessment period (fraction). 
#' Required only for species = CML, CTL, BFL, SHP, and GTS.
#' @param milk_yield_day Numeric.  Average milk yield per milk-producing animal during the assessment duration (kg/head/day). 
#' This value is calculated as the total quantity of milk produced for human consumption by milk-producing animals during the assessment period, 
#' divided by the number of milk-producing animals, and the length of the assessment period (days).
#' Required only for species = CML, CTL, BFL, SHP, and GTS.
#' @param milk_fat_fraction Numeric. Milk fat fraction (kg fat/kg milk). Required only for species = CML, CTL, BFL, SHP, and GTS.
#' @param non_productive_duration Numeric. Period during which the animal is not performing 
#' any productive physiological function such as pregnancy or lactation (days). Required only for PGS.
#' @param pregnancy_duration Numeric. Duration of pregnancy period (days).
#' @param litter_size Numeric. Average number of offspring born per parturition (# offsprings/parturition). 
#' This value can be calculated as the total number of offspring born divided by the total number of parturitions during the year.
#' @param death_rate_juvenile Numeric. Fraction of deaths in a herd over a year for juvenile cohorts (i.e. FJ and MJ), (fraction).
#' @param birth_weight Numeric. Live weight of the animal at birth (kg).
#' @param weaning_weight Numeric. Live weight of the animal at weaning (kg).
#' @param lactation_duration Numeric. Duration of the lactation period, defined as the number of days during which the animal is lactating (days). 
#' Required only for PGS.
#' @param parturition_rate Numeric. Average annual number of parturitions per female animal (# parturitions/adult female/year). 
#' A herd-level reproductive performance indicator calculated as the total number of parturitions (deliveries) occurring during a year divided by the number of adult females potentially able to give birth during that year.
#'
#' @return Numeric. Energy required for lactation (MJ/head/day). Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS.
#'
#' @details
#' This approach follows the IPCC Tier 2 partitioning method and applies
#' species-specific equations for lactation energy requirements as a function of the
#' quantity of milk produced and a species-specific energy cost per unit of milk.
#' 
#' Requirements are calculated only for cohort = \code{FA} (adult females) and are scaled
#' by the proportion of lactating animals (\code{lactating_females_fraction}) or reproducing
#' females (\code{parturition_rate}) within the cohort.
#'
#' \strong{Species-specific approach:}
#'
#' \strong{CTL, BFL, CML, SHP and GTS}:
#'
#' Total milk production includes:
#' \itemize{
#'   \item milk extracted for human consumption (\code{milk_yield})
#'   \item milk consumed directly by offspring (\code{milk_for_offspring})
#' }
#'
#' In general form, lactation energy is computed as:
#'
#' \deqn{
#' energy\_requirement\_lactation =
#' (milk\_yield \times lactating\_females\_fraction + milk\_for\_offspring)
#' \times energy\_milk
#' }
#'
#' where:
#'
#' \code{energy_milk} is a species-specific coefficient representing the
#' net energy cost of producing one kilogram of milk (MJ/kg milk).
#'
#' Species-specific values of \code{energy_milk} are:
#' \itemize{
#'   \item \code{CTL}, \code{BFL}: estimated as a function of milk fat content,
#'     \eqn{1.47 + 0.40 \times (milk\_fat\_fraction \times 100)} (NRC, 1989),
#'   \item \code{CML}: \eqn{4.063} (Wardeh, 2004),
#'   \item \code{SHP}: \eqn{4.6} (AFRC, 1993),
#'   \item \code{GTS}: \eqn{3.0} (AFRC, 1998).
#' }
#'
#' \code{milk_for_offspring} is the daily amount of milk required to rear offspring
#' across the year (kg/day). It is calculated assuming that **5 kg of milk are
#' required for each kilogram of live-weight gain up to weaning**:
#'
#' \deqn{
#' milk\_for\_offspring =
#' \frac{parturition\_rate \times 5 \times (weaning\_weight - birth\_weight)}{365}
#' }
#'
#' For \code{SHP} and \code{GTS}, \code{milk_for_offspring} is multiplied by
#' \code{litter_size} to account for multiple offspring per birth.
#'
#' \strong{PGS} (NRC, 1998):
#'
#' Lactation energy accounts only for the milk consumed directly by offspring
#' (\code{milk_for_offspring}), adjusted by the fraction of the reproductive cycle spent
#' in lactation (\code{cadj}):
#'
#' \deqn{
#' energy\_requirement\_lactation =
#' litter\_size \times (1 - 0.5 \times death\_rate\_juvenile)
#' \times \left(
#' \frac{0.02059 \times (weaning\_weight - birth\_weight) \times 1000}{lactation\_duration}
#' - \frac{0.3766}{0.67}
#' \right)
#' \times cadj
#' }
#'
#' where:
#' \itemize{
#'   \item \eqn{0.02059} is the coefficient for lactation energy requirement
#'     (MJ/g live weight),
#'   \item \eqn{0.3766} is the coefficient for sow weight loss during lactation
#'     (MJ/head/day),
#'   \item \eqn{0.67} is the efficiency of conversion of dietary intake to milk energy (fraction),
#'   \item \eqn{cadj} is the fraction of the reproductive cycle spent in lactation:
#'
#'   \deqn{
#'   cadj = \frac{lactation\_duration}{non\_productive\_duration + pregnancy\_duration + lactation\_duration}
#'   }
#' }
#'
#' @references
#' AFRC (1998) \emph{The Nutrition of Goats.}
#' CAB International, Wallingford, UK.
#'
#' AFRC (1993). \emph{Energy and Protein Requirements of Ruminants. An Advisory Manual Prepared by the AFRC Technical Committee on Responses to Nutrients.} 
#' CAB International, Wallingford, UK.
#'
#' IPCC. (2019). \emph{2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories},
#'   Chapter 10: Emissions from Livestock and Manure Management, Equation 10.8-10.10.
#'
#' IPCC. (2006). \emph{2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions
#'   from Livestock and Manure Management, Equation 10.8-10.10.
#'
#' NRC (1998). \emph{Nutrient Requirements of Swine},
#' 10th Revised Edition. National Academies Press, Washington, DC.
#'
#' NRC (1989) \emph{Nutrient Requirements of Dairy Cattle},
#' 6th Ed. . Washington, D.C. U.S.A: National Academy Press.
#'
#' Wardeh, M. F. (2004). \emph{The nutrient requirements of the dromedary camel}.
#' Journal of Camel Science, 1(1):37-45. The Camel Applied Research and Development Network (CARDN),
#' Arab Center for the Studies of Arid Zones and Dry Lands (ACSAD).
#'
#' @export
calc_metabolic_energy_req_lactation <- function(
    species_short,
    cohort_short,
    lactating_females_fraction = NA_real_,
    milk_yield_day = NA_real_,
    milk_fat_fraction = NA_real_,
    non_productive_duration = NA_real_,
    pregnancy_duration = NA_real_,
    litter_size = NA_real_,
    death_rate_juvenile = NA_real_,
    birth_weight = NA_real_,
    weaning_weight = NA_real_,
    lactation_duration = NA_real_,
    parturition_rate = NA_real_
) {
  # Validate inputs
  validate_lactation_inputs(
    species_short, cohort_short, lactating_females_fraction, milk_yield_day, milk_fat_fraction,
    non_productive_duration, pregnancy_duration, litter_size, death_rate_juvenile, birth_weight,
    weaning_weight, lactation_duration, parturition_rate
  )

  if (species_short %in% c("CTL", "BFL")) {
    if (cohort_short == "FA") {
      energy_requirement_lactation <- ((milk_yield_day * lactating_females_fraction) +
                                         (parturition_rate * 5 * (weaning_weight - birth_weight) / 365)) *
        (milk_fat_fraction * 100 * 0.40 + 1.47)
    } else {
      energy_requirement_lactation <- 0
    }
  } else if (species_short %in% c("CML")) {
    if (cohort_short == "FA") {
      energy_requirement_lactation <- ((milk_yield_day * lactating_females_fraction) +
                                         (parturition_rate * 5 * (weaning_weight - birth_weight) / 365)) * 4.063
    } else {
      energy_requirement_lactation <- 0
    }
  } else if (species_short %in% c("SHP")) {
    if (cohort_short == "FA") {
      # Includes effect of litter size and lambing interval
      energy_requirement_lactation <- (
        (milk_yield_day * lactating_females_fraction) +
          (litter_size * parturition_rate * 5 * (weaning_weight - birth_weight) / 365)
      ) * 4.6
    } else {
      energy_requirement_lactation <- 0
    }
  } else if (species_short %in% c("GTS")) {
    if (cohort_short == "FA") {
      energy_requirement_lactation <- (
        (milk_yield_day * lactating_females_fraction) +
          (litter_size * parturition_rate * 5 * (weaning_weight - birth_weight) / 365)
      ) * 3
    } else {
      energy_requirement_lactation <- 0
    }
  } else if (species_short == "PGS") {
    if (cohort_short != "FA") {
      energy_requirement_lactation <- 0
    } else {
      # Pigs: adjustment for lactation period
      cadj <- lactation_duration / (non_productive_duration + pregnancy_duration + lactation_duration)
      energy_requirement_lactation <- litter_size * (1 - 0.5 * death_rate_juvenile) *
        ((0.02059 * (weaning_weight - birth_weight) * 1000 / lactation_duration) - (0.3766 / 0.67)) *
        cadj
    }
  }
  return(energy_requirement_lactation)
}

#' Calculate Energy for Egg Production (placeholder)
#'
#' Placeholder for metabolizable energy required for egg production (MJ/head/day).
#' Not implemented yet.
#'
#' @param species_short Character. Code identifying the livestock species.
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
#' @param egg_yield_year Numeric. Eggs produced per hen per year.
#' @param egg_average_weight Numeric. Average egg weight (kg/egg).
#'
#' @return No return value; this function always errors to indicate it's a stub.
#' @noRd
calc_metabolic_energy_req_eggs <- function(
    species_short,
    cohort_short,
    egg_yield_year = NA_real_,
    egg_average_weight = NA_real_
) {
  return(NA_real_)
}

#' Calculate Energy for Work
#'
#' Computes the energy requirement for work (MJ/head/day),  defined as the
#' additional energy required to support draught power and work-related physical activity.
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
#' @param energy_requirement_maintenance Numeric. Energy required for maintenance, defined as the amount of energy needed 
#' to keep the animal at equilibrium such that body energy is neither gained nor lost. 
#' Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS (MJ/head/day).
#' @param draught_work_hours_female Numeric. Average daily working time per adult female (hours/head/day). Required only for species = CML, CTL and BFL.
#' @param draught_work_hours_male Numeric. Average daily working time per adult male (hours/head/day). Required only for species = CML, CTL and BFL.
#' @param draught_fraction_female Numeric. Fraction of adult females involved in draught work (fraction). Required only for species = CML, CTL and BFL.
#' @param draught_fraction_male Numeric. Fraction of adult males involved in draught work (fraction). Required only for species = CML, CTL and BFL.
#'
#' @return Numeric. Energy required for work, used to estimate the energy required for draught power for CTL, BFL and CML (MJ/head/day).
#' Assumed to be 0 for other species. Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS.
#'
#' @details
#' This approach follows the IPCC Tier 2 partitioning method and applies
#' species-specific coefficients for draught work.
#'
#' This energy component is calculated only for adult cohorts ( \code{FA} and \code{MA}) of draught-capable species
#' (\code{CTL}, \code{BFL}, and \code{CML}). It is scaled by
#' the fraction of adult animals involved in draught work
#' (\code{draught_fraction_female}, \code{draught_fraction_male}) and their average
#' daily working time (\code{draught_work_hours_female}, \code{draught_work_hours_male}).
#'
#' \strong{Species-specific approach:}
#'
#' \strong{CTL and BFL} - (Bamualim & Kartiarso, 1985; IPCC, 2006; IPCC 2019).
#' Draught work energy is expressed as a proportion of
#' net energy for maintenance:
#'
#' \eqn{
#' energy\_requirement\_work = 0.1 \times energy\_requirement\_maintenance \times work\_hours \times draught\_fraction
#' }
#'
#' where:
#' \itemize{
#'   \item \eqn{energy\_requirement\_maintenance} is net energy required for maintenance (MJ/head/day) and can be calculated using 
#'   \code{\link{calc_metabolic_energy_req_maintenance}()},
#'   \item \eqn{0.1} represents a 10% increase in maintenance energy per hour of work,
#'   \item \eqn{work\_hours} is the mean number of hours worked per animal per day - 
#'   \code{draught_work_hours_female} (for \code{FA}) and \code{draught_work_hours_male} (for \code{MA}) and,
#'   \item \eqn{draught\_fraction} is the fraction of adult animals performing draught work -
#'   \code{draught_fraction_female} (for \code{FA}) and \code{draught_fraction_male} (for \code{MA})
#' }
#'
#' \strong{CML} -  (Wilson, 1989)
#' Draught work energy is calculated using a fixed metabolizable
#' energy cost per hour of work:
#'
#' \deqn{
#' energy\_requirement\_work = 4 \times work\_hours \times draught\_fraction
#' }
#'
#' where:
#' \itemize{
#'   \item \eqn{4} is the metabolizable energy requirement for draught work
#'     (MJ/hour),
#'   \item \eqn{work\_hours} is the mean number of hours worked per animal per day - 
#'   \code{draught_work_hours_female} (for \code{FA}) and \code{draught_work_hours_male} (for \code{MA}) and,
#'   \item \eqn{draught\_fraction} is the fraction of adult animals performing draught work -
#'   \code{draught_fraction_female} (for \code{FA}) and \code{draught_fraction_male} (for \code{MA})
#'   }
#'
#'@seealso
#' \code{\link{calc_metabolic_energy_req_maintenance}} 
#'
#'@references
#' Bamualim A., Kartiarso (1985). \emph{Nutrition of draught animals with special reference to Indonesia}.
#' In: Draught Animal Power for Production. Australian Centre for International agricultural Research (ACIAR),
#' Proceedings Series No. 10, ed. JW Copland. Canberra, A.C.T., Australia: ACIAR.
#'
#' IPCC. (2019). \emph{2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories},
#'   Chapter 10: Emissions from Livestock and Manure Management, Equation 10.11.
#'
#' IPCC. (2006). \emph{2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions
#'   from Livestock and Manure Management, Equation 10.11.
#'
#' Wilson (1989). \emph{The nutritional requirements of camel}.
#' In: Tisserand J.-L. (ed.). Séminaire sur la digestion, la nutrition et l'alimentation du dromadaire.
#' Zaragoza : CIHEAM. (1989). p. 171-179 (Options Méditerranéennes : Série A. Séminaires Méditerranéens; n. 2)
#'
#' @export
calc_metabolic_energy_req_work <- function(
    species_short,
    cohort_short,
    energy_requirement_maintenance = NA_real_,
    draught_work_hours_female = NA_real_,
    draught_work_hours_male = NA_real_,
    draught_fraction_female = NA_real_,
    draught_fraction_male = NA_real_
) {
  # Validate inputs
  validate_work_inputs(
    species_short, cohort_short, energy_requirement_maintenance,
    draught_work_hours_female,
    draught_work_hours_male,
    draught_fraction_female,
    draught_fraction_male
  )

  if (species_short %in% c("CTL", "BFL")) {
    if (cohort_short == "MA") {
      energy_requirement_work <- 0.1 * energy_requirement_maintenance * draught_work_hours_male * draught_fraction_male
    } else if (cohort_short == "FA") {
      energy_requirement_work <- 0.1 * energy_requirement_maintenance * draught_work_hours_female *
        draught_fraction_female
    } else {
      energy_requirement_work <- 0
    }
  } else if (species_short %in% c("CML")) {
    if (cohort_short == "MA") {
      energy_requirement_work <- 4 * draught_work_hours_male * draught_fraction_male
    } else if (cohort_short == "FA") {
      energy_requirement_work <- 4 * draught_work_hours_female * draught_fraction_female
    } else {
      energy_requirement_work <- 0
    }
  } else if (species_short %in% c("SHP", "GTS", "PGS", "CHK")) {
    energy_requirement_work <- 0 # No work for these species
  }
  return(energy_requirement_work)
}

#' Calculate Energy for Fibre Production
#'
#' Computes the energy requirement for fibre production (MJ/head/day),
#' defined as the additional energy required for the synthesis of animal fibre
#' (e.g. wool or hair).
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
#'
#' @return Numeric. Energy required for the synthesis of fibre for SHP, GTS and CML. 
#' Assumed to be 0 for other species. (MJ/head/day).  Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS (MJ/head/day).
#' 
#' @details
#' This component follows the IPCC Tier 2 partitioning approach and is applied
#' only to fibre-producing species and relevant cohorts, which are assumed to be \code{FA}, \code{FS}, \code{MA}, and \code{MS}.
#'
#' \strong{Species-specific approach:}
#'
#' \itemize{
#'
#' \item \strong{SHP and GTS} (IPCC, 2006; IPCC, 2019):
#'
#' For sheep and goats, fibre production energy is calculated assuming a fixed
#' net energy cost of \eqn{24} MJ per kilogram of fibre produced. Annual fibre
#' production is converted to a daily requirement as:
#'
#' \deqn{
#' energy\_requirement\_fibre =
#' \frac{24 \times fibre\_yield\_year}{365}
#' }
#'
#' where:
#' \itemize{
#'   \item \eqn{fibre\_yield\_year} is annual fibre production
#'     (kg/head/year),
#'   \item \eqn{24} is the net energy requirement per kilogram of fibre
#'     (MJ/kg fibre),
#'   \item division by \eqn{365} converts annual production to a daily basis.
#' }
#'
#' \item \strong{CML} (AFRC, 1998; Cannas et al., 2007):
#'
#' For camels, fibre energy requirements are first calculated on a
#' \strong{net energy} basis and then converted to
#' \strong{metabolizable energy} using a net-to-metabolizable energy
#' efficiency coefficient:
#'
#' \deqn{
#' energy\_requirement\_fibre =
#' \frac{24}{0.43}
#' \times
#' \frac{fibre\_yield\_year}{365}
#' }
#'
#' where:
#' \itemize{
#'   \item \eqn{24} is the net energy requirement per kilogram of fibre
#'     (MJ/kg fibre),
#'   \item \eqn{0.43} is the efficiency of conversion from metabolizable energy
#'     to net energy for fibre production (fraction),
#'   \item \eqn{fibre\_prod} is annual fibre production per animal
#'     (kg/head/year),
#'   \item \eqn{365} to convert annual production to a daily basis.
#' }
#'
#' The efficiency coefficient of \eqn{0.43} is adopted by analogy with goats,
#' assuming a dietary metabolizability of approximately 0.55, following AFRC
#' guidance and the synthesis by Cannas et al. (2007).
#'
#' \item\strong{Other species}: Fibre production energy is assumed to be zero.
#' }
#'
#' @references
#'
#' AFRC (1998) \emph{The Nutrition of Goats.}
#' CAB International, Wallingford, UK.
#'
#' AFRC (1993). \emph{Energy and Protein Requirements of Ruminants. An Advisory Manual Prepared by the AFRC Technical Committee on Responses to Nutrients.} 
#' CAB International, Wallingford, UK.
#'
#' Cannas, A., Atzori, A. S., Boe, F., & Teixeira, I. (2007).
#' \emph{Energy and protein requirements of goats}.
#' In: Dairy sheep nutrition (pp. 31-49). CAB International, Wallingford, UK.
#'
#' IPCC. (2019). \emph{2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories}.
#'   Chapter 10: Emissions from Livestock and Manure Management, Equation 10.12.
#'
#' IPCC. (2006). \emph{2006 IPCC Guidelines for National Greenhouse Gas Inventories}. Chapter 10: Emissions from
#' Livestock and Manure Management, Equation 10.12.
#'
#' @export
#'
calc_metabolic_energy_req_fibre <- function(
    species_short,
    cohort_short,
    fibre_yield_year = NA_real_
) {
  # Validate inputs
  validate_fibre_inputs(species_short, cohort_short, fibre_yield_year)
  # Only sheep, goats, camelids produce fibre

  if (species_short %in% c("GTS", "SHP")) {
    if (cohort_short %in% c("FA", "FS", "MA", "MS")) {
      energy_requirement_fibre_production <- 24 * fibre_yield_year / 365 # 24 MJ/kg fibre, annualized
    } else {
      energy_requirement_fibre_production <- 0
    }
  } else if (species_short %in% c("CML")) {
    if (cohort_short %in% c("FA", "FS", "MA", "MS")) {
      energy_requirement_fibre_production <- (24 / 0.43) * (fibre_yield_year / 365) # 0.43: efficiency factor for camels
    } else {
      energy_requirement_fibre_production <- 0
    }
  } else if (species_short %in% c("CTL", "BFL", "PGS", "CHK")) {
    energy_requirement_fibre_production <- 0 # Not applicable
  }
  return(energy_requirement_fibre_production)
}

#' Calculate Energy for Pregnancy
#'
#' Computes the energy requirement for pregnancy by cohort (MJ/head/day) for pregnant
#' females, defined as the additional energy needed to support gestation.
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
#' @param energy_requirement_maintenance Numeric. Energy required for maintenance, defined as the amount of energy needed 
#' to keep the animal at equilibrium such that body energy is neither gained nor lost. 
#' Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS (MJ/head/day).
#' @param parturition_rate Numeric. Average annual number of parturitions per female animal (# parturitions/adult female/year). 
#' A herd-level reproductive performance indicator calculated as the total number of parturitions (deliveries) occurring during 
#' a year divided by the number of adult females potentially able to give birth during that year.
#' @param litter_size Numeric. Average number of offspring born per parturition (# offsprings/parturition). This value can be 
#' calculated as the total number of offspring born divided by the total number of parturitions during the year.
#' @param pregnancy_duration Numeric. Duration of pregnancy period (days).
#' @param non_productive_duration Numeric. Period during which the animal is not performing any productive physiological 
#' function such as pregnancy or lactation (days). Required only for PGS.
#' @param lactation_duration Numeric. Duration of the lactation period, defined as the number of days during which the animal 
#' is lactating (days). Required only for PGS.
#' @param cohort_duration_days Numeric. Amount of time that each animal spends in a specific cohort (days).
#' @param offtake_rate Numeric. Annual proportion of animals removed from the herd for each sex-age cohort (fraction).
#'
#' @return Numeric. Energy required for pregnancy for pregnant females (MJ/head/day). 
#' Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS.
#'
#' @details
#' This component follows the IPCC Tier 2 partitioning framework and is applied
#' only to \strong{female cohorts} (\code{FA} and \code{FS}).
#'
#' Pregnancy energy (\code{energy_requirement_pregnancy}) represents the additional
#' energy required to support gestation. Requirements are computed as a fraction
#' of maintenance energy and are adjusted to reflect reproductive activity within
#' the cohort:
#' \itemize{
#'   \item For \code{FA}, requirements are scaled by the annual parturition rate
#'     (\code{parturition_rate}) and (when applicable) by the fraction of the reproductive cycle
#'     spent in gestation (\code{pregnancy_duration/(pregnancy_duration+lactation_duration+non_productive_duration)}).
#'   \item For \code{FS}, only a fraction of animals is assumed to reach reproductive
#'     age within the cohort; requirements are therefore scaled by the proportion
#'     remaining in the cohort (\eqn{1 - offtake\_rate}) and by the share of the
#'     cohort duration spent pregnant (\code{pregnancy_duration/cohort_duration_days}).
#' }
#'
#' \strong{General form}
#' \deqn{
#' energy\_requirement\_pregnancy =
#' energy\_requirement\_maintenance \times c_{preg} \times S
#' }
#' 
#' where 
#' \itemize{
#' \item \eqn{c_{preg}} is a species-specific pregnancy coefficient, 
#' \item \eqn{S} is a scaling term that depends on cohort (\code{FA} vs \code{FS}).
#' \item \eqn{energy\_requirement\_maintenance} can be calculated using \code{\link{calc_metabolic_energy_req_maintenance}()}
#'}
#'
#' \strong{Specific coefficients by species and cohort:}
#' 
#' \itemize{
#' \item \strong{CTL and BFL} (IPCC, 2006, 2019):
#' Pregnancy energy is approximated as \eqn{10\%} of maintenance energy.
#' \itemize{
#'   \item \code{FA}:
#'   \deqn{
#'   energy\_requirement\_pregnancy =
#'   0.10 \times energy\_requirement\_maintenance \times parturition\_rate \times
#'   \frac{pregnancy\_duration}{365}
#'   }
#'   \item \code{FS}:
#'   \deqn{
#'   energy\_requirement\_pregnancy =
#'   0.10 \times energy\_requirement\_maintenance \times
#'   \frac{pregnancy\_duration}{cohort\_duration\_days} \times (1 - offtake\_rate)
#'   }
#' }
#'
#' \item \strong{CML} (Wardeh, 2004):
#' Pregnancy energy is estimated as \eqn{12\%} of maintenance energy.
#' \itemize{
#'   \item \code{FA}:
#'   \deqn{
#'   energy\_requirement\_pregnancy =
#'   0.12 \times energy\_requirement\_maintenance \times parturition\_rate
#'   }
#'   \item \code{FS}:
#'   \deqn{
#'   energy\_requirement\_pregnancy =
#'   0.12 \times energy\_requirement\_maintenance \times
#'   \frac{pregnancy\_duration}{cohort\_duration\_days} \times (1 - offtake\_rate)
#'   }
#' }
#'
#' \item \strong{SHP and GTS} (IPCC 2006; 2019):
#' Pregnancy energy is calculated as a litter-size-dependent fraction of
#' maintenance energy (\eqn{c_{preg}}).
#' \itemize{
#'   \item \code{FA}:
#'   \deqn{
#'   energy\_requirement\_pregnancy =
#'   energy\_requirement\_maintenance \times c_{preg} \times parturition\_rate \times
#'   \frac{pregnancy\_duration}{365}
#'   }
#'   where \eqn{c_{preg}} is:
#'   \deqn{
#'   c_{preg} =
#'   \left\{
#'   \begin{array}{ll}
#'   0.077 \times (2 - litter\_size) + 0.126 \times (litter\_size - 1), & 1 \le litter\_size \le 2 \\
#'   0.150, & litter\_size > 2
#'   \end{array}
#'   \right.
#'   }
#'   \item \code{FS}:
#'   A single-birth coefficient is used (\eqn{c_{preg}=0.077}) and scaled by the
#'   proportion of reproductive individuals in the cohort:
#'   \deqn{
#'   energy\_requirement\_pregnancy =
#'   0.077 \times energy\_requirement\_maintenance \times
#'   \frac{pregnancy\_duration}{cohort\_duration\_days} \times (1 - offtake\_rate)
#'   }
#' }
#'
#' \item \strong{PGS} (NRC, 1998):
#' Pregnancy energy is expressed using a gestation coefficient \eqn{c_{gest}}
#' (MJ/piglet), with default \eqn{c_{gest}=0.14985}.
#' \itemize{
#'   \item \code{FA}:
#'   \deqn{
#'   energy\_requirement\_pregnancy =
#'   c_{gest} \times litter\_size \times
#'   \frac{pregnancy\_duration}{non\_productive\_duration + pregnancy\_duration + lactation\_duration}
#'   }
#'   \item \code{FS}:
#'   \deqn{
#'   energy\_requirement\_pregnancy =
#'   c_{gest} \times litter\_size \times
#'   \frac{pregnancy\_duration}{cohort\_duration\_days} \times (1 - offtake\_rate)
#'   }
#' }
#' }
#' 
#' @seealso
#' \code{\link{calc_metabolic_energy_req_maintenance}} 
#'
#' @references
#' NRC (1998). \emph{Nutrient Requirements of Swine},
#' 10th Revised Edition. National Academies Press, Washington, DC.
#'
#' IPCC. (2019). \emph{2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories}.
#'   Chapter 10: Emissions from Livestock and Manure Management, Equation 10.13; Table 10.7.
#'
#' IPCC. (2006). \emph{2006 IPCC Guidelines for National Greenhouse Gas Inventories}. Chapter 10: Emissions
#'   from Livestock and Manure Management, Equation 10.13; Table 10.7.
#'
#' Wardeh, M. F. (2004). \emph{The nutrient requirements of the dromedary camel}.
#' Journal of Camel Science, 1(1):37-45. The Camel Applied Research and Development Network (CARDN),
#' Arab Center for the Studies of Arid Zones and Dry Lands (ACSAD).
#'
#' @export
#'
calc_metabolic_energy_req_pregnancy <- function(
    species_short,
    cohort_short,
    energy_requirement_maintenance = NA_real_,
    parturition_rate = NA_real_,
    litter_size = NA_real_,
    pregnancy_duration = NA_real_,
    non_productive_duration = NA_real_,
    lactation_duration = NA_real_,
    cohort_duration_days = NA_real_,
    offtake_rate = NA_real_
) {

  # Normalize offtake_rate if it's available (not NA_real_)
  if (!is.na(offtake_rate)) {
    offtake_rate <- normalize_rate(offtake_rate)
  }

  # Validate inputs
  validate_pregnancy_inputs(
    species_short, cohort_short, energy_requirement_maintenance, parturition_rate,
    litter_size, pregnancy_duration, non_productive_duration, lactation_duration,
    cohort_duration_days, offtake_rate
  )

  if (species_short %in% c("CTL", "BFL")) {
    if (cohort_short == "FA") {
      energy_requirement_pregnancy <- (energy_requirement_maintenance * 0.1 * parturition_rate *
                                         pregnancy_duration / 365)
    } else if (cohort_short == "FS") {
      energy_requirement_pregnancy <- (energy_requirement_maintenance * 0.1) *
        (pregnancy_duration / cohort_duration_days) * (1 - offtake_rate)
    } else {
      energy_requirement_pregnancy <- 0
    }
  } else if (species_short %in% c("CML")) {
    if (cohort_short == "FA") {
      energy_requirement_pregnancy <- energy_requirement_maintenance * 0.12 * parturition_rate
    } else if (cohort_short == "FS") {
      energy_requirement_pregnancy <- energy_requirement_maintenance * 0.12 *
        (pregnancy_duration / cohort_duration_days) * (1 - offtake_rate)
    } else {
      energy_requirement_pregnancy <- 0
    }
  } else if (species_short %in% c("SHP", "GTS")) {
    if (cohort_short == "FA") {
      cpreg <- 0
      # Litter size effect
      if (litter_size >= 1 && litter_size <= 2) {
        cpreg <- (0.077 * (2 - litter_size) + 0.126 * (litter_size - 1))
      } else if (litter_size > 2) {
        cpreg <- 0.150
      }
      energy_requirement_pregnancy <- energy_requirement_maintenance * cpreg * parturition_rate *
        pregnancy_duration / 365
    } else if (cohort_short == "FS") {
      energy_requirement_pregnancy <- energy_requirement_maintenance * 0.077 *
        (pregnancy_duration / cohort_duration_days) * (1 - offtake_rate)
    } else {
      energy_requirement_pregnancy <- 0
    }
  } else if (species_short == "PGS") {
    cgest <- 0.14985

    if (cohort_short == "FA") {
      energy_requirement_pregnancy <- cgest * litter_size * pregnancy_duration /
        (non_productive_duration + pregnancy_duration + lactation_duration)

    } else if (cohort_short == "FS") {

      energy_requirement_pregnancy <- cgest * litter_size * (pregnancy_duration / cohort_duration_days) *
        (1 - offtake_rate)

    } else {
      energy_requirement_pregnancy <- 0
    }
  } else if (species_short == "CHK") {
    energy_requirement_pregnancy <- 0 # Not applicable
  }
  return(energy_requirement_pregnancy)
}

#' Calculate Ratio of Net Energy available for Maintenance in the diet (REM - Net Energy for Maintenance / Digestible Energy)
#'
#' Computes the ratio of net energy available in the diet for maintenance to digestible energy.
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
#' @param diet_digestibility_fraction Numeric. Average digestibility of 
#' the feed ration, expressed as ratio of digestible to gross energy content (fraction).
#'
#' @return Numeric. Ratio of net energy available for maintenance in the diet to digestible energy consumed (fraction). 
#'
#' @details
#' This component follows the IPCC Tier 2 partitioning approach and it returns the value for
#'  ruminants (\code{CTL}, \code{BFL}, \code{SHP}, \code{GTS}) calculated as follows:
#'  
#' \deqn{
#' net\_energy\_maintenance\_digestible\_energy\_ratio =
#' 1.123 - 0.004092 \times (diet\_digestibility\_fraction \times 100) +
#' 0.00001126 \times (diet\_digestibility\_fraction \times 100)^2 -
#' \frac{25.4}{diet\_digestibility\_fraction \times 100}
#' }
#'
#' For the Other species REM is not applicable and the function
#' returns \code{NA_real_}.
#'
#' @seealso
#' \code{\link{calc_ration_digestibility}}
#' \code{\link{calc_total_metabolic_energy_req}}
#' \code{\link{calc_ration_intake}}
#'
#'
#' @references
#' Gibbs M.J., Johnson D.E. (1993) \emph{Livestock Emissions}.
#' In: International Methane Emissions. Washington, D.C., U.S.A: US Environmental Protection Agency,
#' Climate Change Division.
#'
#' IPCC. (2019). \emph{2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories},
#'   Chapter 10: Emissions from Livestock and Manure Management, Equation 10.14.
#'
#' IPCC. (2006). \emph{2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions
#'   from Livestock and Manure Management, Equation 10.14.
#'
#'
#' @export
calc_rem_maintenance <- function(
    species_short,
    diet_digestibility_fraction = NA_real_
) {
  # Validate inputs
  validate_rem_inputs(species_short, diet_digestibility_fraction)
  # Only ruminants: cattle, buffalo, sheep, goats

  if (species_short %in% c("CTL", "BFL", "SHP", "GTS")) {
    # Polynomial fit from GLEAM
    net_energy_maintenance_digestible_energy_ratio <- 1.123 - (0.004092 * (diet_digestibility_fraction * 100)) +
      (0.00001126 * (diet_digestibility_fraction * 100)^2) - (25.4 / (diet_digestibility_fraction * 100))
  } else if (species_short %in% c("PGS", "CHK", "CML")) {
    net_energy_maintenance_digestible_energy_ratio <- NA_real_ # Not applicable
  }
  return(net_energy_maintenance_digestible_energy_ratio)
}


#' Calculate the Ratio of Net Energy Available for Growth in the Diet (REG – Net Energy for Growth / Digestible Energy)
#' 
#' Computes the ratio of net energy available for growth to digestible
#' energy consumed (fraction), which represents the efficiency with which digestible
#' energy in the diet is converted into net energy retained as body tissue.
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
#' @param diet_digestibility_fraction Numeric. Average digestibility of the the feed ration, 
#' expressed as ratio of digestible to gross energy content (fraction).
#'
#' @return Numeric. Ratio of net energy available for growth in the diet to digestible energy consumed (fraction).
#'   
#' @details
#' This component follows the IPCC Tier 2 partitioning approach and returns REG for
#' ruminants (\code{CTL}, \code{BFL}, \code{SHP}, \code{GTS}) as:

#' \deqn{
#' net\_energy\_growth\_digestible\_energy\_ratio = 1.164 - 0.005160 \times diet\_digestibility\_fraction \times 100 + 0.00001308 \times (diet\_digestibility\_fraction \times 100)^2 - \frac{37.4}{diet\_digestibility\_fraction \times 100}
#' }
#'
#' For Other species REG is not applicable and the function
#' returns \code{NA_real_}.
#' 
#'
#' @seealso
#' \code{\link{calc_ration_digestibility}}
#' \code{\link{calc_total_metabolic_energy_req}}
#' \code{\link{calc_ration_intake}}
#'
#'
#' @references
#' Gibbs M.J., Johnson D.E. (1993) \emph{Livestock Emissions}.
#' In: International Methane Emissions. Washington, D.C., U.S.A: US Environmental Protection Agency,
#' Climate Change Division.
#'
#' IPCC. (2019). \emph{2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories},
#'   Chapter 10: Emissions from Livestock and Manure Management, Equation 10.15.
#'
#' IPCC. (2006). \emph{2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions
#'   from Livestock and Manure Management, Equation 10.15.
#'
#' @export
calc_reg_growth <- function(
    species_short,
    diet_digestibility_fraction = NA_real_
) {
  # Validate inputs
  validate_reg_inputs(species_short, diet_digestibility_fraction)
  # Only ruminants: cattle, buffalo, sheep, goats

  if (species_short %in% c("CTL", "BFL", "SHP", "GTS")) {
    # Polynomial fit
    net_energy_growth_digestible_energy_ratio <- 1.164 - (0.005160 * (diet_digestibility_fraction * 100)) +
      (0.00001308 * (diet_digestibility_fraction * 100)^2) - (37.4 / (diet_digestibility_fraction * 100))
  } else if (species_short %in% c("PGS", "CHK", "CML")) {
    net_energy_growth_digestible_energy_ratio <- NA_real_ # Not applicable
  }
  return(net_energy_growth_digestible_energy_ratio)
}

#' Calculate Total Energy Requirement
#'
#' Computes the total daily energy requirement (MJ/head/day) by summing
#' relevant energy partitions (maintenance, activity, lactation, work, pregnancy,
#' growth, fibre, egg deposition).
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
#' @param energy_requirement_maintenance Numeric. Energy required for maintenance, defined as the amount of 
#' energy needed to keep the animal at equilibrium such that body energy is neither gained nor lost (MJ/head/day). 
#' Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS.
#' @param energy_requirement_activity Numeric. Energy required for activity, defined as the amount of energy 
#' needed to support animal movement and physical activity (MJ/head/day). Expressed as net energy for 
#' CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS.
#' @param energy_requirement_lactation Numeric. Energy required for lactation (MJ/head/day). 
#' Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS.
#' @param energy_requirement_work Numeric. Energy required for work, used to estimate the energy required for draught power for CTL, BFL and CML (MJ/head/day).
#'  Assumed to be 0 for other species. Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS.
#' @param energy_requirement_pregnancy Numeric. Energy required for pregnancy for pregnant females (MJ/head/day). 
#' Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS.
#' @param net_energy_maintenance_digestible_energy_ratio Ratio of net energy available for maintenance in
#'   the diet to digestible energy consumed (fraction).
#' @param energy_requirement_growth Numeric. Energy required for growth (i.e., weight gain) (MJ/head/day). 
#' Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS.
#' @param energy_requirement_fibre_production Numeric. Energy required for the synthesis of fibre for SHP, GTS and CML. Assumed to be 0 for other species (MJ/head/day).
#' Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS (MJ/head/day).
#' @param energy_requirement_egg_deposition Numeric. Net energy for egg production (MJ/head/day).
#' @param net_energy_growth_digestible_energy_ratio Numeric. Ratio of net energy available for growth in the diet to digestible energy consumed (fraction)
#' @param diet_digestibility_fraction Numeric. Average digestibility of the the feed ration, expressed as ratio of digestible to gross energy content (fraction).
#' 
#' @return Numeric. Total daily energy requirement (MJ/head/day). For CTL, BFL, SHP and GTS this is expressed as gross energy intake requirement (GE). 
#' For CML and PGS the function returns the summed daily metabolizable energy requirement.
#'
#' @details
#' This component follows the IPCC Tier 2 partitioning approach and the calculation
#' is computed differently depending on whether
#' species energy requirements are expressed as net or metabolizable energy.
#'
#' \strong{Species-specific approach:}
#' 
#' \itemize{
#'   \item \strong{Energy requirements expressed as net energy (\code{CTL}, \code{BFL}, \code{SHP}, \code{GTS})}
#'
#'   \itemize{
#'     \item \strong{\code{CTL} and \code{BFL}}:
#'     \deqn{
#'       energy\_requirement\_total =
#'       \frac{
#'         \left(
#'           \frac{
#'             energy\_requirement\_maintenance +
#'             energy\_requirement\_activity +
#'             energy\_requirement\_lactation +
#'             energy\_requirement\_work +
#'             energy\_requirement\_pregnancy
#'           }{REM}
#'         \right)
#'         +
#'         \left(
#'           \frac{energy\_requirement\_growth}{REG}
#'         \right)
#'       }{diet\_digestibility\_fraction}
#'     }
#'     \item \strong{\code{SHP} and \code{GTS}}:
#'     \deqn{
#'       energy\_requirement\_total =
#'       \frac{
#'         \left(
#'           \frac{
#'             energy\_requirement\_maintenance +
#'             energy\_requirement\_activity +
#'             energy\_requirement\_lactation +
#'             energy\_requirement\_pregnancy
#'           }{REM}
#'         \right)
#'         +
#'         \left(
#'           \frac{energy\_requirement\_growth + 
#'           energy\_requirement\_fibre
#'           }{REG}
#'         \right)
#'       }{diet\_digestibility\_fraction}
#'     }
#' }
#'   \item \strong{Energy requirements expressed as metabolizable energy (\code{CML}, \code{PGS})}
#'
#'   For these species, the total daily requirement is computed as the \strong{direct sum}
#'   of relevant energy components (MJ/head/day).
#'
#'   \itemize{
#'     \item \strong{\code{CML}}:
#'     \deqn{
#'       energy\_requirement\_total =
#'       energy\_requirement\_maintenance +
#'       energy\_requirement\_activity +
#'       energy\_requirement\_lactation +
#'       energy\_requirement\_work +
#'       energy\_requirement\_fibre\_production +
#'       energy\_requirement\_pregnancy +
#'       energy\_requirement\_growth
#'     }
#'     \item \strong{\code{PGS}}:
#'     \deqn{
#'       energy\_requirement\_total =
#'       energy\_requirement\_maintenance +
#'       energy\_requirement\_activity +
#'       energy\_requirement\_lactation +
#'       energy\_requirement\_pregnancy +
#'       energy\_requirement\_growth
#'     }
#'   }
#'   }
#' 
#' @seealso
#' \code{\link{calc_metabolic_energy_req_maintenance}}
#' \code{\link{calc_metabolic_energy_req_activity}}
#' \code{\link{calc_metabolic_energy_req_growth}}
#' \code{\link{calc_metabolic_energy_req_lactation}}
#' \code{\link{calc_metabolic_energy_req_work}}
#' \code{\link{calc_metabolic_energy_req_fibre}}
#' \code{\link{calc_metabolic_energy_req_pregnancy}}
#' \code{\link{calc_rem_maintenance}}
#' \code{\link{calc_reg_growth}}
#' \code{\link{calc_ration_intake}}
#' 
#' @references
#' IPCC. (2019). \emph{2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories},
#'   Chapter 10: Emissions from Livestock and Manure Management, Equation 10.16.
#'
#' IPCC. (2006). \emph{2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions
#'   from Livestock and Manure Management, Equation 10.16.
#'
#' @export
calc_total_metabolic_energy_req <- function(
    species_short,
    energy_requirement_maintenance,
    energy_requirement_activity,
    energy_requirement_lactation,
    energy_requirement_work,
    energy_requirement_pregnancy,
    net_energy_maintenance_digestible_energy_ratio,
    energy_requirement_growth,
    energy_requirement_fibre_production,
    energy_requirement_egg_deposition,
    net_energy_growth_digestible_energy_ratio,
    diet_digestibility_fraction
) {
  # Validate inputs
  validate_total_energy_inputs(
    species_short,
    energy_requirement_maintenance,
    energy_requirement_activity,
    energy_requirement_lactation,
    energy_requirement_work,
    energy_requirement_pregnancy,
    net_energy_maintenance_digestible_energy_ratio,
    energy_requirement_growth,
    energy_requirement_fibre_production,
    energy_requirement_egg_deposition,
    net_energy_growth_digestible_energy_ratio,
    diet_digestibility_fraction
  )
  # Cattle, buffalo: sum maintenance, activity, lactation, work, pregnancy, growth
  if (species_short %in% c("CTL", "BFL")) {
    energy_requirement_total <- (
      (
        (energy_requirement_maintenance + energy_requirement_activity +
           energy_requirement_lactation + energy_requirement_work + energy_requirement_pregnancy) /
          net_energy_maintenance_digestible_energy_ratio
      ) + ((energy_requirement_growth) /  net_energy_growth_digestible_energy_ratio)
    ) / diet_digestibility_fraction
  } else if (species_short %in% c("SHP", "GTS")) {
    # Sheep, goats: add fibre
    energy_requirement_total <- (
      ((energy_requirement_maintenance + energy_requirement_activity +
          energy_requirement_lactation + energy_requirement_pregnancy) /
         net_energy_maintenance_digestible_energy_ratio) + (
           (energy_requirement_growth +
              energy_requirement_fibre_production) / net_energy_growth_digestible_energy_ratio
         )
    ) / diet_digestibility_fraction
  } else if (species_short == "CML") {
    energy_requirement_total <- energy_requirement_maintenance + energy_requirement_activity +
      energy_requirement_lactation + energy_requirement_work + energy_requirement_fibre_production +
      energy_requirement_pregnancy + energy_requirement_growth
  } else if (species_short == "PGS") {
    energy_requirement_total <- energy_requirement_maintenance + energy_requirement_activity +
      energy_requirement_lactation + energy_requirement_pregnancy + energy_requirement_growth
  } else if (species_short == "CHK") {
    energy_requirement_total <- energy_requirement_maintenance + energy_requirement_activity +
      energy_requirement_growth + energy_requirement_egg_deposition
  }
  return(energy_requirement_total)
}

#' Calculate Daily Dry Matter Intake
#'
#' Computes daily feed intake as dry matter intake (DMI) per animal (kg DM/head/day) from the
#' animal's daily energy requirement and the diet energy density.
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
#' @param energy_requirement_total Numeric. Total daily energy requirement (MJ/head/day). 
#' For CTL, BFL, SHP and GTS this is expressed as gross energy intake requirement (GE). 
#' For CML and PGS the function returns the summed daily metabolizable energy requirement.
#' @param diet_gross_energy Numeric. Average gross energy content of the diet (MJ/kg DM).
#' @param diet_metabolizable_energy Numeric. Average metabolizable energy content of the diet (MJ/kg DM).
#'
#' @return Numeric. Average daily dry matter intake of feed (kg DM/head/day).
#'
#' @details
#' This function follows the IPCC Tier 2 framework. 
#' DMI is computed
#' by dividing the appropriate daily energy requirement by the corresponding
#' diet energy content (MJ/kg DM).
#'
#' \itemize{
#'   \item \strong{Energy expressed as gross energy intake requirement - 
#'   \code{CTL}, \code{BFL}, \code{SHP}, \code{GTS}}:
#'
#'   \deqn{
#'     dry\_matter\_intake = \frac{energy\_requirement\_total}{diet\_gross\_energy}
#'   }
#'
#'   \item \strong{Energy expressed as metabolizable energy requirement - 
#'   \code{CML}, \code{PGS}, \code{CHK}}:
#'
#'   \deqn{
#'     dry\_matter\_intake = \frac{energy\_requirement\_total}{diet\_metabolizable\_energy}
#'   }
#' }
#'
#' @seealso
#' \code{\link{calc_total_metabolic_energy_req}}
#' \code{\link{calc_ration_gross_energy}}
#' \code{\link{calc_ration_metabolizable_energy}}
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
calc_ration_intake <- function(
    species_short,
    energy_requirement_total,
    diet_gross_energy,
    diet_metabolizable_energy
) {
  # Validate inputs
  validate_dmi_inputs(species_short, energy_requirement_total, diet_gross_energy, diet_metabolizable_energy)
  # Ruminants: use gross energy
  if (species_short %in% c("CTL", "BFL", "SHP", "GTS")) {
    dry_matter_intake <- energy_requirement_total / diet_gross_energy
  } else if (species_short %in% c("PGS", "CHK", "CML")) {
    # Monogastrics/camelids: use metabolizable energy
    dry_matter_intake <- energy_requirement_total / diet_metabolizable_energy
  }
  return(dry_matter_intake)
}
