#' Calculate Live Weights by Cohort and at different lifestage
#'
#' Attributes and/or compute initial, potential final, and slaughter live weight for
#' a given cohort and animal species
#'
#' @param cohort Character scalar. Sex- and age-specific cohort code describing the
#'   production stage of the animals. Supported values include:
#'   \describe{
#'     \item{\code{FA}}{Adult females (from age at first parturition).}
#'     \item{\code{FS}}{Subadult females (from weaning to age at first parturition).}
#'     \item{\code{FJ}}{Juvenile females (from birth to weaning).}
#'     \item{\code{MA}}{Adult males (from age at first breeding).}
#'     \item{\code{MS}}{Subadult males (from weaning to age at first breeding).}
#'     \item{\code{MJ}}{Juvenile males (from birth to weaning).}
#'   }
#' @param adult_fem_weight Numeric. Live weight of adult females (kg)
#' @param adult_mal_weight Numeric. Live weight of adult males (kg)
#' @param birth_weight Numeric. Live weight of the animal at birth (kg).
#' @param slaughter_weight_fem Numeric. Slaughter weight of female sub-adult animals (kg).
#' @param slaughter_weight_mal Numeric. Slaughter weight of male sub-adult animals (kg).
#' @param weaning_weight Numeric. Live weight of the animal at weaning (kg)
#'
#' @return A named list with:
#' \describe{
#'   \item{initial_weight}{Numeric. Live weight at the beginning of the cohort stage (kg).}
#'   \item{potential_final_weight}{Numeric. Potential final live weight attainable at the end of the cohort stage in the absence of offtake (kg). (For juveniles: equals weaning weight; For subadults: equals adult live weight; For adults: equals adult live weight)}
#'   \item{slaughter_weight}{Numeric. Live weight at slaughter for animals removed from the cohort (kg).}
#' }
#'
#' @details
#' The function attributes weights according to cohort and animal type:
#'
#' \itemize{
#'   \item \strong{Juveniles} (\code{"FJ"}, \code{"MJ"}):
#'   \itemize{
#'     \item \code{initial_weight = birth_weight}
#'     \item \code{potential_final_weight = weaning_weight}
#'     \item \code{slaughter_weight = weaning_weight}
#'   }
#'
#'   \item \strong{Subadults} (\code{"FS"}, \code{"MS"}):
#'   \itemize{
#'     \item \code{initial_weight = weaning_weight}
#'     \item \code{potential_final_weight} equals the adult weight for the cohort sex
#'       (\code{adult_fem_weight} for \code{"FS"}, \code{adult_mal_weight} for \code{"MS"})
#'     \item \code{slaughter_weight} equals the subadult slaughter weight for the cohort sex
#'       (\code{slaughter_weight_fem} for \code{"FS"}, \code{slaughter_weight_mal} for \code{"MS"})
#'   }
#'
#'   \item \strong{Adults} (\code{"FA"}, \code{"MA"}):
#'   \itemize{
#'     \item \code{initial_weight = adult_fem_weight} for \code{"FA"} and
#'       \code{initial_weight = adult_mal_weight} for \code{"MA"}
#'     \item \code{potential_final_weight} equals the adult weight for the cohort sex
#'     \item \code{slaughter_weight} equals the adult weight for the cohort sex
#'   }
#' }
#'
#' @export
calc_cohort_weights <- function(
    cohort,
    adult_fem_weight = NA_real_, adult_mal_weight = NA_real_,
    birth_weight = NA_real_, slaughter_weight_fem = NA_real_,
    slaughter_weight_mal = NA_real_, weaning_weight = NA_real_
) {
  validate_cohort_weight_inputs(
    cohort,
    adult_fem_weight, adult_mal_weight,
    birth_weight,
    slaughter_weight_fem, slaughter_weight_mal,
    weaning_weight
  )

  # Juvenile cohorts
  if (cohort %in% c("FJ", "MJ")) {
    initial_weight <- birth_weight
    potential_final_weight <- slaughter_weight <- weaning_weight
    adult_weight <- if (cohort == "FJ") adult_fem_weight else adult_mal_weight

    # Subadult cohorts
  } else if (cohort %in% c("FS", "MS")) {

    initial_weight <- weaning_weight
    adult_weight <- if (cohort == "FS") adult_fem_weight else adult_mal_weight
    potential_final_weight <- if (cohort == "FS") adult_fem_weight else adult_mal_weight
    slaughter_weight <- if (cohort == "FS") slaughter_weight_fem else slaughter_weight_mal

    # Adult cohorts
  } else if (cohort == "FA") {
    initial_weight <- adult_weight <- potential_final_weight <- slaughter_weight <- adult_fem_weight
  } else if (cohort == "MA") {
    initial_weight <- adult_weight <- potential_final_weight <- slaughter_weight <- adult_mal_weight
  }

  return(
    list(
      adult_weight = adult_weight,
      initial_weight = initial_weight,
      potential_final_weight = potential_final_weight,
      slaughter_weight = slaughter_weight
    )
  )
}

#' Calculate Average and Final Live Weights by Cohort
#'
#' Computes the average and final live weight of a cohort based on initial weight,
#' potential final weight, slaughter weight, and the offtake rate.
#'
#' @param initial_weight Numeric. Live weight at the beginning of the cohort stage (kg).
#' @param potential_final_weight Numeric. Potential final live weight attainable at the end of the cohort stage in the absence of offtake (kg). (For juveniles: equals weaning weight; For subadults: equals adult live weight; For adults: equals adult live weight)
#' @param slaughter_weight Numeric. Live weight at slaughter for animals removed from the cohort (kg).
#' @param offtake_rate Numeric. Annual proportion of animals removed from the herd for each sex-age cohort (fraction).
#'
#' @return A named list with:
#' \describe{
#'   \item{average_weight}{Numeric. Average live weight over the cohort stage. Computed by accounting for the share of offtaken animals within the cohort, using their slaughter weight, and the potential final weight of animals that remain in the cohort (kg).}
#'   \item{final_weight}{Numeric. Live weight at the end of the cohort stage, accounting for both surviving and offtaken animals. Computed in the GLEAM pipeline as a weighted average of the potential final weight of surviving animals and the slaughter weight of offtaken animals, based on the offtake rate (kg).}
#' }
#'
#' @details
#' The calculation of \code{average_weight} and \code{final_weight} is performed considering that
#' a fraction of animals is removed (offtake) during the cohort stage, while the
#' remaining animals reach the potential final live weight.
#'
#' The final live weight is computed as:
#' \deqn{final\_weight = (1 - offtake\_rate) \times potential\_final\_weight +
#'       offtake\_rate \times slaughter\_weight}
#'
#' The average live weight over the stage is approximated as:
#' \deqn{average\_weight = (initial\_weight + final\_weight)/2}
#'
#' @export
calc_avg_weights <- function(
    initial_weight,
    potential_final_weight,
    slaughter_weight,
    offtake_rate
) {
  validate_avg_weight_inputs(
    initial_weight,
    potential_final_weight,
    slaughter_weight,
    offtake_rate
  )

  # Normalize offtake_rate
  offtake_rate <- normalize_rate(offtake_rate)

  # Weighted final weight: survivors reach potential_final_weight, offtaken animals go to slaughter
  final_weight <- potential_final_weight * (1 - offtake_rate) + slaughter_weight * offtake_rate

  # Average weight across the stage
  average_weight <- (initial_weight + final_weight) / 2

  return(
    list(
      average_weight = average_weight,
      final_weight = final_weight
    )
  )
}

#' Calculate Daily Weight Gain
#'
#' Computes average daily weight gain over a given duration based on the difference
#' between potential final and initial live weights.
#'
#' @param potential_final_weight Numeric. Potential final live weight attainable at the end of the cohort stage in the absence of offtake (kg). (For juveniles: equals weaning weight; For subadults: equals adult live weight; For adults: equals adult live weight)
#' @param initial_weight Numeric. Live weight at the beginning of the cohort stage (kg).
#' @param duration Numeric. Amount of time that each animal spends in a specific cohort (days).
#'
#' @return Numeric. Average live weight gain of the cohort over the cohort stage (kg/head/day).
#'
#'@details
#' Daily live weight gain is calculated as the difference between the
#' potential final live weight and the initial live weight, divided by the
#' duration of the cohort stage:
#'
#' \deqn{daily\_weight\_gain = (potential\_final\_weight - initial\_weight) / duration}
#'
#' This represents an average (per-head) daily gain.
#'
#' @export
calc_daily_weight_gain <- function(
    potential_final_weight,
    initial_weight,
    duration
) {
  validate_daily_gain_inputs(potential_final_weight, initial_weight, duration)

  # Average daily gain over the period
  return(
    (potential_final_weight - initial_weight) / duration
  )
}
