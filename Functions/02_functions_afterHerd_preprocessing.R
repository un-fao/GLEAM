#' Calculate Live Weights by Cohort and at different lifestage
#'
#' Computes initial, potential final, and slaughter live weight (LW) for
#'  a given cohort and animal type.
#'
#' @param animal Character. Species code (e.g., "PGS", "CML", "CTL", "BFL", "SHP", "GTS").
#' @param cohort Character. Cohort code (e.g., "FJ", "MJ", "FS", "MS", "FA", "MA").
#' @param adult_female_weight Numeric. Adult female weight in kg.
#' @param adult_male_weight Numeric. Adult male weight in kg.
#' @param birth_weight Numeric. Birth weight in kg.
#' @param slaughter_weight_female Numeric. Slaughter weight of adult female in kg.
#' @param slaughter_weight_male Numeric. Slaughter weight of adult male in kg.
#' @param weaning_weight Numeric. Weaning weight in kg.
#' @param age_first_calving Numeric. Age at first calving (in days).
#' @param animal_age Numeric. Age of the animal at the current stage (in days).
#'
#' @return A named list with:
#' \describe{
#'   \item{initial_weight}{Initial live weight.}
#'   \item{potential_final_weight}{Potential final live weight.}
#'   \item{slaughter_weight}{Slaughter live weight.}
#' }
#'
#' @export
calc_cohort_weights <- function(
    animal, cohort,
    adult_female_weight = NA_real_, adult_male_weight = NA_real_, birth_weight = NA_real_, slaughter_weight_female = NA_real_,
    slaughter_weight_male = NA_real_, weaning_weight = NA_real_, age_first_calving = NA_real_, animal_age = NA_real_) {

  # Helper function for growing weight
  grow_weight <- function(adult_weight) {
    ((adult_weight - birth_weight) / age_first_calving) * animal_age + birth_weight
  }

  # Defaults
  initial_weight <- potential_final_weight <- slaughter_weight <- NA_real_

  # Juvenile cohorts
  if (cohort %in% c("FJ", "MJ")) {
    initial_weight <- birth_weight
    if (animal %in% c("PGS", "CML")) {
      potential_final_weight <- slaughter_weight <- weaning_weight
    } else {
      adult_weight <- if (cohort == "FJ") adult_female_weight else adult_male_weight
      potential_final_weight <- slaughter_weight <- grow_weight(adult_weight)
    }

    # Subadult cohorts
  } else if (cohort %in% c("FS", "MS")) {
    if (animal %in% c("PGS", "CML")) {
      initial_weight <- weaning_weight
    } else {
      adult_weight <- if (cohort == "FS") adult_female_weight else adult_male_weight
      initial_weight <- grow_weight(adult_weight)
    }
    potential_final_weight <- if (cohort == "FS") adult_female_weight else adult_male_weight
    slaughter_weight <- if (cohort == "FS") slaughter_weight_female else slaughter_weight_male

    # Adult cohorts
  } else if (cohort == "FA") {
    initial_weight <- potential_final_weight <- slaughter_weight <- adult_female_weight
  } else if (cohort == "MA") {
    initial_weight <- potential_final_weight <- slaughter_weight <- adult_male_weight
  }

  output <- list(
    initial_weight = initial_weight, potential_final_weight = potential_final_weight, slaughter_weight = slaughter_weight
  )
  return(output)
}

#' Calculate Average and Final Live Weights by Cohort
#'
#' Computes the average and final live weight (LW) of a cohort based on initial weight,
#' potential final weight, slaughter weight, and the offtake rate.
#'
#' @param initial_weight Numeric. Initial live weight at the start of the cohort stage.
#' @param potential_final_weight Numeric. Potential final live weight if no offtake occurs.
#' @param slaughter_weight Numeric. Live weight at slaughter.
#' @param offtake_rate Numeric. Proportion of individuals removed via offtake during the stage.
#'
#' @return A named list with:
#' \describe{
#'   \item{average_weight}{Average live weight over the stage (accounts for offtake and survivors).}
#'   \item{final_weight}{Final live weight after accounting for both survivors and offtaken animals.}
#' }
#'
#' @export
calc_avg_weights <- function(initial_weight, potential_final_weight, slaughter_weight, offtake_rate) {
  # Weighted final weight: survivors reach potential_final_weight, offtaken animals go to slaughter
  final_weight <- potential_final_weight * (1 - offtake_rate) + slaughter_weight * offtake_rate

  # Average weight across the stage
  average_weight <- (initial_weight + final_weight) / 2

  output <- list(
    average_weight = average_weight, final_weight = final_weight
  )
  return(output)
}

#' Calculate Daily Weight Gain
#'
#' Computes average daily weight gain over a given duration based on the difference
#' between potential final and initial live weights.
#'
#' @param potential_final_weight Numeric. Potential final live weight.
#' @param initial_weight Numeric. Initial live weight.
#' @param duration Numeric. Duration of the stage (in days).
#'
#' @return Numeric. Daily weight gain (kg/day).
#'
#' @export
calc_daily_weight_gain <- function(potential_final_weight, initial_weight, duration) {
  # Average daily gain over the period
  output <- (potential_final_weight - initial_weight) / duration
  return(output)
}
