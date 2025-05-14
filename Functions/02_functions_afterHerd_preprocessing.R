#' Calculate Live Weights by Cohort and at different lifestage
#'
#' Computes initial, potential final, and slaughter live weight (LW) for
#'  a given cohort and animal type.
#'
#' @param Animal_short Character. Species code (e.g., "PGS", "CML", "CTL", "BFL", "SHP", "GTS").
#' @param cohort Character. Cohort code (e.g., "FJ", "MJ", "FS", "MS", "FA", "MA").
#' @param AFKG Numeric. Adult female weight in kg.
#' @param AMKG Numeric. Adult male weight in kg.
#' @param CKG Numeric. Birth weight in kg.
#' @param MFSKG Numeric. Slaughter weight of adult female in kg.
#' @param MMSKG Numeric. Slaughter weight of adult male in kg.
#' @param WKG Numeric. Weaning weight in kg.
#' @param AFC Numeric. Age at first calving (in days).
#' @param WA Numeric. Age of the animal at the current stage (in days).
#'
#' @return A named list with:
#' \describe{
#'   \item{initialLW}{Initial live weight.}
#'   \item{potfinalLW}{Potential final live weight.}
#'   \item{slaughterLW}{Slaughter live weight.}
#' }
#'
#' @export
calc_cohort_weights <- function(
    Animal_short, cohort,
    AFKG = NA_real_, AMKG = NA_real_, CKG = NA_real_, MFSKG = NA_real_,
    MMSKG = NA_real_, WKG = NA_real_, AFC = NA_real_, WA = NA_real_) {
  
  # Helper function for growing weight
  grow_weight <- function(adult_weight) {
    ((adult_weight - CKG) / AFC) * WA + CKG
  }
  
  # Defaults
  initialLW <- potfinalLW <- slaughterLW <- NA_real_
  
  # Juvenile cohorts
  if (cohort %in% c("FJ", "MJ")) {
    initialLW <- CKG
    if (Animal_short %in% c("PGS", "CML")) {
      potfinalLW <- slaughterLW <- WKG
    } else {
      adult_weight <- if (cohort == "FJ") AFKG else AMKG
      potfinalLW <- slaughterLW <- grow_weight(adult_weight)
    }
    
    # Subadult cohorts
  } else if (cohort %in% c("FS", "MS")) {
    if (Animal_short %in% c("PGS", "CML")) {
      initialLW <- WKG
    } else {
      adult_weight <- if (cohort == "FS") AFKG else AMKG
      initialLW <- grow_weight(adult_weight)
    }
    potfinalLW <- if (cohort == "FS") AFKG else AMKG
    slaughterLW <- if (cohort == "FS") MFSKG else MMSKG
    
    # Adult cohorts
  } else if (cohort == "FA") {
    initialLW <- potfinalLW <- slaughterLW <- AFKG
  } else if (cohort == "MA") {
    initialLW <- potfinalLW <- slaughterLW <- AMKG
  }
  
  output <- list(
    initialLW = initialLW, potfinalLW = potfinalLW, slaughterLW = slaughterLW
  )
  return(output)
}

#' Calculate Average and Final Live Weights by Cohort
#'
#' Computes the average and final live weight (LW) of a cohort based on initial weight,
#' potential final weight, slaughter weight, and the offtake rate.
#'
#' @param initialLW Numeric. Initial live weight at the start of the cohort stage.
#' @param potfinalLW Numeric. Potential final live weight if no offtake occurs.
#' @param slaughterLW Numeric. Live weight at slaughter.
#' @param offtake_rate Numeric. Proportion of individuals removed via offtake during the stage.
#'
#' @return A named list with:
#' \describe{
#'   \item{averageLW}{Average live weight over the stage (accounts for offtake and survivors).}
#'   \item{finalLW}{Final live weight after accounting for both survivors and offtaken animals.}
#' }
#'
#' @export
calc_avg_weights <- function(initialLW, potfinalLW, slaughterLW, offtake_rate) {
  # Weighted final weight: survivors reach potfinalLW, offtaken animals go to slaughter
  finalLW <- potfinalLW * (1 - offtake_rate) + slaughterLW * offtake_rate
  
  # Average weight across the stage
  averageLW <- (initialLW + finalLW) / 2
  
  output <- list(
    averageLW = averageLW, finalLW = finalLW
  )
  return(output)
}

# Function to calculate daily weight gain
calc_daily_gain <- function(potfinalLW, initialLW, duration) {
  dwg <- (potfinalLW - initialLW) / duration
  return(dwg)
}
