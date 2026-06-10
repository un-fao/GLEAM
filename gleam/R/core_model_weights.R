#' Calculate live weights by cohort and life stage
#'
#' Determines the initial, potential final, and slaughter live weights for a
#' given cohort based on species-specific biological parameters. The function
#' handles demographic cohorts (\code{FJ}, \code{FS}, \code{FA}, \code{MJ},
#' \code{MS}, \code{MA}) and nondemographic cohorts (\code{FN}, \code{MN}).
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
#'     \item \code{FN}: non-demographic females
#'     \item \code{MN}: non-demographic males
#'   }
#' @param live_weight_female_adult Numeric. Live weight of adult females (kg)
#' @param live_weight_male_adult Numeric. Live weight of adult males (kg)
#' @param live_weight_at_birth Numeric. Live weight of the animal at birth (kg).
#' @param live_weight_female_at_slaughter Numeric. Slaughter weight of female sub-adult animals (kg).
#' @param live_weight_male_at_slaughter Numeric. Slaughter weight of male sub-adult animals (kg).
#' @param live_weight_at_weaning Numeric. Live weight of the animal at weaning (kg)
#' @param live_weight_female_nondemographic_start Numeric. Live weight of
#'   female animals at the beginning of the nondemographic cycle (kg).
#' @param live_weight_female_nondemographic_end Numeric. Live weight of female
#'   animals at the end of the nondemographic cycle (kg).
#' @param live_weight_male_nondemographic_start Numeric. Live weight of male
#'   animals at the beginning of the nondemographic cycle (kg).
#' @param live_weight_male_nondemographic_end Numeric. Live weight of male
#'   animals at the end of the nondemographic cycle (kg).
#' @param nondemo_productive_phase_id Numeric. Productive phase identifier for
#'   nondemographic cohorts. Takes value \code{1} for phase 1 and optionally
#'   \code{2} for phase 2. Demographic cohorts use \code{NA}.
#' @param phase1_nondemo_fem_duration_days Numeric. Duration of productive phase
#'   1 for the female nondemographic cohort (\code{FN}) (days).
#' @param phase2_nondemo_fem_duration_days Numeric. Duration of productive phase
#'   2 for the female nondemographic cohort (\code{FN}) (days).
#' @param phase1_nondemo_mal_duration_days Numeric. Duration of productive phase
#'   1 for the male nondemographic cohort (\code{MN}) (days).
#' @param phase2_nondemo_mal_duration_days Numeric. Duration of productive phase
#'   2 for the male nondemographic cohort (\code{MN}) (days).
#'
#' @return A named list with:
#' \describe{
#'   \item{live_weight_cohort_initial}{Numeric. Live weight at the beginning of the cohort stage (kg).}
#'   \item{live_weight_cohort_potential_final}{Numeric. Potential final live weight attainable at the end of the cohort stage in the absence of offtake (kg). (For juveniles: equals weaning weight; For subadults: equals adult live weight; For adults: equals adult live weight)}
#'   \item{live_weight_cohort_at_slaughter}{Numeric. Live weight at slaughter for animals removed from the cohort (kg).}
#'   \item{live_weight_mature_stage}{Numeric. Mature (adult) live weight that the animal can attain under given biological and management conditions (kg).}
#' }
#'
#' @details
#' The function attributes weights according to cohort and animal type:
#'
#' \itemize{
#'   \item \strong{Juveniles} (\code{"FJ"}, \code{"MJ"}):
#'   \itemize{
#'     \item \code{live_weight_cohort_initial = live_weight_at_birth}
#'     \item \code{live_weight_cohort_potential_final = live_weight_at_weaning}
#'     \item \code{live_weight_cohort_at_slaughter = live_weight_at_weaning}
#'   }
#'
#'   \item \strong{Subadults} (\code{"FS"}, \code{"MS"}):
#'   \itemize{
#'     \item \code{live_weight_cohort_initial = live_weight_at_weaning}
#'     \item \code{live_weight_cohort_potential_final} = adult weight for the cohort sex
#'       (\code{live_weight_female_adult} for \code{"FS"}, \code{live_weight_male_adult} for \code{"MS"})
#'     \item \code{live_weight_cohort_at_slaughter} = subadult slaughter weight for the cohort sex
#'       (\code{live_weight_female_at_slaughter} for \code{"FS"}, \code{live_weight_male_at_slaughter} for \code{"MS"})
#'   }
#'
#'   \item \strong{Adults} (\code{"FA"}, \code{"MA"}):
#'   \itemize{
#'     \item \code{live_weight_cohort_initial = live_weight_female_adult} for \code{"FA"},
#'       and \code{live_weight_cohort_initial = live_weight_male_adult} for \code{"MA"}
#'     \item \code{live_weight_cohort_potential_final} = adult weight for the cohort sex
#'     \item \code{live_weight_cohort_at_slaughter} = adult weight for the cohort sex
#'   }
#'
#'   \item \strong{Nondemographic cohorts} (\code{"FN"}, \code{"MN"}):
#'   \itemize{
#'     \item a linear live-weight gain is computed from the nondemographic start
#'       and end weights over the total nondemographic duration
#'     \item for \code{nondemo_productive_phase_id = 1}, the initial weight is the
#'       nondemographic start weight and the potential final weight is the end
#'       of phase 1
#'     \item for \code{nondemo_productive_phase_id = 2}, the initial weight is the
#'       end of phase 1 and the potential final weight is the end of phase 2
#'     \item \code{live_weight_cohort_at_slaughter} is set equal to the
#'       phase-specific potential final weight
#'   }
#' }
#'
#' This function is part of the [run_weights_module()].
#' 
#' @seealso
#' \code{\link{run_weights_module}}
#'
#' @export
calc_cohort_weights <- function(
    cohort_short,
    live_weight_female_adult = NA_real_, live_weight_male_adult = NA_real_,
    live_weight_at_birth = NA_real_, live_weight_female_at_slaughter = NA_real_,
    live_weight_male_at_slaughter = NA_real_, live_weight_at_weaning = NA_real_,
    nondemo_productive_phase_id = NA_real_,
    live_weight_female_nondemographic_start = NA_real_, live_weight_female_nondemographic_end = NA_real_,
    live_weight_male_nondemographic_start = NA_real_, live_weight_male_nondemographic_end = NA_real_,
    phase1_nondemo_fem_duration_days = NA_real_,
    phase2_nondemo_fem_duration_days = NA_real_,
    phase1_nondemo_mal_duration_days = NA_real_,
    phase2_nondemo_mal_duration_days = NA_real_
) {
  validate_cohort_weight_inputs(
    cohort_short,
    live_weight_female_adult, live_weight_male_adult,
    live_weight_at_birth,
    live_weight_female_at_slaughter, live_weight_male_at_slaughter,
    live_weight_at_weaning,
    nondemo_productive_phase_id,
    live_weight_female_nondemographic_start, live_weight_female_nondemographic_end,
    live_weight_male_nondemographic_start, live_weight_male_nondemographic_end,
    phase1_nondemo_fem_duration_days,
    phase2_nondemo_fem_duration_days,
    phase1_nondemo_mal_duration_days,
    phase2_nondemo_mal_duration_days
  )

  # Juvenile cohorts
  if (cohort_short %in% c("FJ", "MJ")) {
    live_weight_cohort_initial <- live_weight_at_birth
    live_weight_cohort_potential_final <- live_weight_cohort_at_slaughter <- live_weight_at_weaning
    live_weight_mature_stage <- if (cohort_short == "FJ") {
      live_weight_female_adult
    } else {
      live_weight_male_adult
    }

    # Subadult cohorts
  } else if (cohort_short %in% c("FS", "MS")) {
    live_weight_cohort_initial <- live_weight_at_weaning
    live_weight_mature_stage <- if (cohort_short == "FS") {
      live_weight_female_adult
    } else {
      live_weight_male_adult
    }
    live_weight_cohort_potential_final <- live_weight_mature_stage
    live_weight_cohort_at_slaughter <- if (cohort_short == "FS") {
      live_weight_female_at_slaughter
    } else {
      live_weight_male_at_slaughter
    }

    # Adult cohorts
  } else if (cohort_short == "FA") {
    live_weight_cohort_initial <- live_weight_female_adult
    live_weight_mature_stage <- live_weight_female_adult
    live_weight_cohort_potential_final <- live_weight_mature_stage
    live_weight_cohort_at_slaughter <- live_weight_mature_stage
  } else if (cohort_short == "MA") {
    live_weight_cohort_initial <- live_weight_male_adult
    live_weight_mature_stage <- live_weight_male_adult
    live_weight_cohort_potential_final <- live_weight_mature_stage
    live_weight_cohort_at_slaughter <- live_weight_mature_stage
  
    # Non demographic cohorts
  } else if (cohort_short == "FN") {
    total_nondemographic_duration_days <- phase1_nondemo_fem_duration_days +
      phase2_nondemo_fem_duration_days
    live_weight_gain_nondemo_fem <- (
      live_weight_female_nondemographic_end -
        live_weight_female_nondemographic_start
    ) / total_nondemographic_duration_days

    if (nondemo_productive_phase_id == 1) {
      live_weight_cohort_initial <- live_weight_female_nondemographic_start
      live_weight_mature_stage <- live_weight_female_nondemographic_end
      live_weight_cohort_potential_final <- live_weight_female_nondemographic_start +
        (live_weight_gain_nondemo_fem * phase1_nondemo_fem_duration_days)
      live_weight_cohort_at_slaughter <- live_weight_cohort_potential_final
    } else if (nondemo_productive_phase_id == 2) {
      live_weight_cohort_initial <- live_weight_female_nondemographic_start +
        (live_weight_gain_nondemo_fem * phase1_nondemo_fem_duration_days)
      live_weight_mature_stage <- live_weight_female_nondemographic_end
      live_weight_cohort_potential_final <- live_weight_cohort_initial +
        (live_weight_gain_nondemo_fem * phase2_nondemo_fem_duration_days)
      live_weight_cohort_at_slaughter <- live_weight_cohort_potential_final
    }
  } else if (cohort_short == "MN") {
    total_nondemographic_duration_days <- phase1_nondemo_mal_duration_days +
      phase2_nondemo_mal_duration_days
    live_weight_gain_nondemo_mal <- (
      live_weight_male_nondemographic_end -
        live_weight_male_nondemographic_start
    ) / total_nondemographic_duration_days

    if (nondemo_productive_phase_id == 1) {
      live_weight_cohort_initial <- live_weight_male_nondemographic_start
      live_weight_mature_stage <- live_weight_male_nondemographic_end
      live_weight_cohort_potential_final <- live_weight_male_nondemographic_start +
        (live_weight_gain_nondemo_mal * phase1_nondemo_mal_duration_days)
      live_weight_cohort_at_slaughter <- live_weight_cohort_potential_final
    } else if (nondemo_productive_phase_id == 2) {
      live_weight_cohort_initial <- live_weight_male_nondemographic_start +
        (live_weight_gain_nondemo_mal * phase1_nondemo_mal_duration_days)
      live_weight_mature_stage <- live_weight_male_nondemographic_end
      live_weight_cohort_potential_final <- live_weight_cohort_initial +
        (live_weight_gain_nondemo_mal * phase2_nondemo_mal_duration_days)
      live_weight_cohort_at_slaughter <- live_weight_cohort_potential_final
    }
  }

  return(
    list(
      live_weight_mature_stage = live_weight_mature_stage,
      live_weight_cohort_initial = live_weight_cohort_initial,
      live_weight_cohort_potential_final = live_weight_cohort_potential_final,
      live_weight_cohort_at_slaughter = live_weight_cohort_at_slaughter
    )
  )
}

#' Calculate average and final live weights by cohort
#'
#' Calculates the average and final live weight for a given
#' sex–age cohort based on initial weight, 
#' potential final weight, slaughter weight, and the offtake rate.
#'
#' @param cohort_short Character. Sex- and age-specific cohort code. Supported
#'   values include \code{FA}, \code{FS}, \code{FJ}, \code{MA}, \code{MS},
#'   \code{MJ}, \code{FN}, and \code{MN}.
#' @param live_weight_cohort_initial Numeric. Live weight at the beginning of the cohort stage (kg).
#' @param live_weight_cohort_potential_final Numeric. Potential final live weight attainable at the end of the cohort stage in the absence of offtake (kg). (For juveniles: equals weaning weight; For subadults: equals adult live weight; For adults: equals adult live weight)
#' @param live_weight_cohort_at_slaughter Numeric. Live weight at slaughter for animals removed from the cohort (kg).
#' @param offtake_rate Numeric. Annual proportion of animals removed from the herd for each sex-age cohort (fraction).
#'
#' @return A named list with:
#' \describe{
#'   \item{live_weight_cohort_average}{Numeric. Average live weight over the cohort stage. Computed by accounting for the share of offtaken animals within the cohort, using their slaughter weight, and the potential final weight of animals that remain in the cohort (kg).}
#'   \item{live_weight_cohort_final}{Numeric. Live weight at the end of the cohort stage, accounting for both surviving and offtaken animals. Computed as a weighted average of the potential final weight of surviving animals and the slaughter weight of offtaken animals, based on the offtake rate (kg).}
#' }
#'
#' @details
#' The calculation of \code{live_weight_cohort_average} and \code{live_weight_cohort_final} is performed considering that
#' a fraction of animals is removed (offtake) during the cohort stage, while the
#' remaining animals reach the potential final live weight.
#' For nondemographic cohorts (\code{FN}, \code{MN}), \code{offtake_rate} is
#' not used; \code{live_weight_cohort_final} is set equal to
#' \code{live_weight_cohort_potential_final}.
#'
#' The final live weight is computed as:
#' \deqn{
#' live\_weight\_cohort_final =
#' (1 - offtake\_rate) \times live\_weight\_cohort\_potential\_final +
#' offtake\_rate \times live\_weight\_cohort\_at\_slaughter
#' }
#'
#' The average live weight over the stage is approximated as:
#' \deqn{live\_weight\_cohort\_average = 
#' (live\_weight\_cohort\_initial + live\_weight\_cohort\_final)/2}
#'
#' This function is part of the [run_weights_module()].
#' 
#' @seealso
#' \code{\link{run_weights_module}}
#'
#' @export
calc_avg_weights <- function(
    cohort_short,
    live_weight_cohort_initial,
    live_weight_cohort_potential_final,
    live_weight_cohort_at_slaughter,
    offtake_rate
) {
  validate_avg_weight_inputs(
    cohort_short,
    live_weight_cohort_initial,
    live_weight_cohort_potential_final,
    live_weight_cohort_at_slaughter,
    offtake_rate
  )

  if (cohort_short %in% c("FN", "MN")) {
    live_weight_cohort_final <- live_weight_cohort_potential_final
  } else {
    # Normalize offtake_rate
    offtake_rate <- normalize_rate(offtake_rate)

    # Weighted final weight: survivors reach potential_final_weight, offtaken animals go to slaughter
    live_weight_cohort_final <- live_weight_cohort_potential_final * (1 - offtake_rate) +
      live_weight_cohort_at_slaughter * offtake_rate
  }

  # Average weight across the stage
  live_weight_cohort_average <- (live_weight_cohort_initial + live_weight_cohort_final) / 2

  return(
    list(
      live_weight_cohort_average = live_weight_cohort_average,
      live_weight_cohort_final = live_weight_cohort_final
    )
  )
}

#' Calculate daily weight gain by cohort
#' 
#' Calculates average daily weight gain for a given
#' sex–age cohort based on the difference between potential final and initial live weights.
#'
#' @param live_weight_cohort_potential_final Numeric. Potential final live weight attainable at the end of the cohort stage in the absence of offtake (kg). (For juveniles: equals weaning weight; For subadults: equals adult live weight; For adults: equals adult live weight)
#' @param live_weight_cohort_initial Numeric. Live weight at the beginning of the cohort stage (kg).
#' @param cohort_duration_days Numeric. Amount of time that each animal spends in a specific cohort (days).
#'
#' @return Numeric. Average live weight gain of the cohort over the cohort stage (kg/head/day).
#'
#'@details
#' Daily live weight gain is calculated as the difference between the
#' potential final live weight and the initial live weight, divided by the
#' duration of the cohort stage:
#'
#' \deqn{daily\_weight\_gain = 
#' (live\_weight\_cohort\_potential\_final - live\_weight\_cohort\_initial) / cohort\_duration\_days}
#'
#' This function is part of the [run_weights_module()].
#' 
#' @seealso
#' \code{\link{run_weights_module}}
#'
#' @export
calc_daily_weight_gain <- function(
    live_weight_cohort_potential_final,
    live_weight_cohort_initial,
    cohort_duration_days
) {
  validate_daily_gain_inputs(
    live_weight_cohort_potential_final,
    live_weight_cohort_initial,
    cohort_duration_days
  )

  # Average daily gain over the period
  return(
    (live_weight_cohort_potential_final - live_weight_cohort_initial) / cohort_duration_days
  )
}
