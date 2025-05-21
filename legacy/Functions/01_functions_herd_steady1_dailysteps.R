#' Compute Daily Fecundity Rates
#'
#' Calculates the daily number of male and female offspring produced per adult female.
#'
#' @param part_rate Numeric. Parturition rate (probability of an adult female to give birth).
#' @param prolif_rate Numeric. Prolificacy rate (mean number of offspring per parturition).
#' @param fem_birth_ratio Numeric. Female birth ratio (probability that an offspring is female).
#'
#' @return A named list with two elements:
#' \describe{
#'   \item{female_fecundity}{Daily number of female offspring per adult female.}
#'   \item{male_fecundity}{Daily number of male offspring per adult female.}
#' }
#' @examples
#' compute_fecundity_rates(part_rate = 0.8, prolif_rate = 2, fem_birth_ratio = 0.5)
#'
#' @export
compute_fecundity_rates <- function(part_rate, prolif_rate, fem_birth_ratio) {
  # Calculate fecundity rates
  female_fecundity <- prolif_rate * fem_birth_ratio * (part_rate / 365)
  male_fecundity <- prolif_rate * (1 - fem_birth_ratio) * (part_rate / 365)

  # Prepare output
  output <- list(female_fecundity, male_fecundity)
  names(output) <- c("female_fecundity", "male_fecundity")

  return(output)
}

#' Compute Transition Probabilities for Sex-Age Classes
#'
#' Calculates hazard rates and daily transition probabilities (death, offtake, survival, and growth)
#' across 10 cohorts derived from 6 sex-age classes.
#'
#' @param duration Numeric vector of length 6. Duration (in days) of each sex-age class.
#' @param offtake_rate Numeric vector of length 6. Annual offtake rate for each sex-age class.
#' @param death_rate Numeric vector of length 6. Annual death rate for each sex-age class.
#'
#' @return A named list with:
#' \describe{
#'   \item{hazard_death}{Instantaneous mortality hazard rate for 6 sex-age classes.}
#'   \item{hazard_offtake}{Instantaneous offtake hazard rate for 6 sex-age classes.}
#'   \item{prob_death}{Daily death probability for 10 cohorts.}
#'   \item{prob_offtake}{Daily offtake probability for 10 cohorts.}
#'   \item{prob_survival}{Daily survival probability for 10 cohorts.}
#'   \item{prob_growth}{Probability of growing into the next age class for 10 cohorts.}
#' }
#'
#' @export
compute_transition_probabilities <- function(duration, offtake_rate, death_rate) {
  # --- Part 1: Compute values for 6 core sex-age classes ---

  # Instantaneous mortality hazard rate (hazard_death), adjusted by duration
  hazard_death <- ifelse(
    duration < 365, -log(1 - death_rate) / duration, -log(1 - death_rate) / 365
  )

  # Adjusted duration: keep original if <365, otherwise cap at 365
  duration_max365 <- ifelse(duration < 365, duration, 365)

  # Initialize offtake hazard rate (hazard_offtake)
  hazard_offtake <- NA

  # Estimate hazard_offtake using Newton-Raphson method for each class
  for (class in 1:6) {
    hazard_death_adj <- hazard_death[class] * duration_max365[class]

    for (t in 1:15) {
      class_hazard_offtake <- ifelse(
        t == 1, offtake_rate[class], class_hazard_offtake - (class_f / class_deriv)
      )

      class_f <- (class_hazard_offtake / (hazard_death_adj + class_hazard_offtake)) *
        (1 - exp(-hazard_death_adj - class_hazard_offtake)) - offtake_rate[class]

      class_deriv <- (
        hazard_death_adj * (1 - exp(-hazard_death_adj - class_hazard_offtake)) +
          class_hazard_offtake * (hazard_death_adj + class_hazard_offtake) * exp(-hazard_death_adj - class_hazard_offtake)
      ) / (hazard_death_adj + class_hazard_offtake)^2
    }

    hazard_offtake[class] <- class_hazard_offtake / duration_max365[class]
  }

  # --- Part 2: Extend to 10 cohorts (6 sex-age classes + 2 birth + 2 culling) ---

  # Extend hazard_death and hazard_offtake for 10 cohorts: copy juvenile/adult rates to birth/culling cohorts
  hazard_death_all <- hazard_death[c(1, 1:3, 3, 4, 4:6, 6)]
  hazard_offtake_all <- hazard_offtake[c(1, 1:3, 3, 4, 4:6, 6)]

  # Extend duration: assign 1 day to birth/culling cohorts; subtract 1 day where split
  duration_all <- c(1, duration[1] - 1, duration[c(2:3)], 1, 1,
                    duration[4] - 1, duration[c(5:6)], 1)

  # Daily probability of death (prob_death)
  prob_death <- (hazard_death_all / (hazard_death_all + hazard_offtake_all)) * (1 - exp(-(hazard_death_all + hazard_offtake_all)))
  prob_death[c(5, 10)] <- 0  # Culling cohorts cannot die again

  # Daily probability of offtake (prob_offtake)
  prob_offtake <- (hazard_offtake_all / (hazard_death_all + hazard_offtake_all)) * (1 - exp(-(hazard_death_all + hazard_offtake_all)))
  prob_offtake[c(5, 10)] <- 1  # Culling cohorts are entirely offtaken

  # Daily survival probability (prob_survival)
  prob_survival <- 1 - prob_death - prob_offtake

  # Probability of growing into the next class (prob_growth)
  prob_growth <- (prob_survival^(duration_all - 1) - prob_survival^duration_all) / (1 - prob_survival^duration_all)

  # --- Prepare and return results ---

  names(prob_death) <- names(prob_offtake) <- names(prob_survival) <- names(prob_growth) <-
    c("FB", "FJ", "FS", "FA", "FC", "MB", "MJ", "MS", "MA", "MC")
  names(hazard_death) <- names(hazard_offtake) <- c("FJ", "FS", "FA", "MJ", "MS", "MA")

  output <- list(hazard_death, hazard_offtake, prob_death, prob_offtake, prob_survival, prob_growth)
  names(output) <- c("hazard_death", "hazard_offtake", "prob_death", "prob_offtake", "prob_survival", "prob_growth")

  return(output)
}

#' Simulate Steady-State Population Structure
#'
#' Simulates population dynamics over time until a steady-state is reached. Tracks age-class structure and
#' population growth based on survival, offtake, and fecundity parameters.
#'
#' @param x_start Numeric vector of length 6. Initial number of individuals in each of the 6 sex-age classes.
#' @param max_years Integer. Maximum number of years to simulate.
#' @param min_lambda_change Numeric. Threshold for minimal change in class-specific growth rates (lambda) to reach steady state.
#' @param female_fecundity Numeric. Daily number of female births per adult female.
#' @param male_fecundity Numeric. Daily number of male births per adult female.
#' @param prob_death Numeric vector of length 10. Daily death probabilities for 10 cohorts.
#' @param prob_offtake Numeric vector of length 10. Daily offtake probabilities for 10 cohorts.
#' @param prob_growth Numeric vector of length 10. Daily probability of transition to the next class for 10 cohorts.
#'
#' @return A named list with:
#' \describe{
#'   \item{days_steady}{Number of days until steady state is reached.}
#'   \item{structure}{Final share of each of the 8 sex-age cohorts.}
#'   \item{share}{Final share of 6 grouped sex-age classes.}
#'   \item{growth_rate_pop}{Annualized growth rate at steady state.}
#' }
#'
#' @export
simulate_steady_state_structure <- function(
    x_start, max_years, min_lambda_change,
    female_fecundity, male_fecundity, prob_death, prob_offtake, prob_growth) {

  # Initialize output vectors
  fem_birth <- fem_juv <- fem_sub <- fem_adult <- fem_cull <- NULL
  mal_birth <- mal_juv <- mal_sub <- mal_adult <- mal_cull <- NULL

  fem_juv_grow <- fem_sub_grow <- fem_adult_grow <- fem_cull_grow <- NULL
  mal_juv_grow <- mal_sub_grow <- mal_adult_grow <- mal_cull_grow <- NULL

  lambda_change <- rep(1, 6)

  # Run simulation for up to max_years
  for (t in 1:(max_years * 365 + 1)) {
    if (t == 1) {
      # Time step 1: initialize from starting vector
      ## calculate initial number of individuals taking into account
      ## the daily number of born females and males (female_fecundity/male_fecundity)
      fem_birth_fec <- x_start[3] * female_fecundity
      fem_juv_fec <- x_start[1]
      fem_sub_fec <- x_start[2]
      fem_adult_fec <- x_start[3]
      fem_cull_fec <- 0
      mal_birth_fec <- x_start[3] * male_fecundity
      mal_juv_fec <- x_start[4]
      mal_sub_fec <- x_start[5]
      Mal_A__x_fec <- x_start[6]
      Mal_C__x_fec <- 0
    } else {
      # Time step >1: propagate individuals from previous day
      ## calculate number of individuals taking into account both female_fecundity/male_fecundity and
      ## the number of individuals that survived the previous month and how they moved in the age classes
      fem_juv_fec[t] <- fem_juv_grow[t - 1]
      fem_sub_fec[t] <- fem_sub_grow[t - 1]
      fem_adult_fec[t] <- fem_adult_grow[t - 1]
      fem_cull_fec[t] <- 0
      fem_birth_fec[t] <- fem_adult_fec[t] * female_fecundity
      mal_juv_fec[t] <- mal_juv_grow[t - 1]
      mal_sub_fec[t] <- mal_sub_grow[t - 1]
      Mal_A__x_fec[t] <- mal_adult_grow[t - 1]
      Mal_C__x_fec[t] <- 0
      mal_birth_fec[t] <- fem_adult_fec[t] * male_fecundity
    }

    # Compute class-specific growth rate change (lambda)
    if (t > 2) {
      lambda_change <- c(
        fem_juv_fec[t] / fem_juv_fec[t - 1] - fem_juv_fec[t - 1] / fem_juv_fec[t - 2],
        fem_sub_fec[t] / fem_sub_fec[t - 1] - fem_sub_fec[t - 1] / fem_sub_fec[t - 2],
        fem_adult_fec[t] / fem_adult_fec[t - 1] - fem_adult_fec[t - 1] / fem_adult_fec[t - 2],
        mal_juv_fec[t] / mal_juv_fec[t - 1] - mal_juv_fec[t - 1] / mal_juv_fec[t - 2],
        mal_sub_fec[t] / mal_sub_fec[t - 1] - mal_sub_fec[t - 1] / mal_sub_fec[t - 2],
        Mal_A__x_fec[t] / Mal_A__x_fec[t - 1] - Mal_A__x_fec[t - 1] / Mal_A__x_fec[t - 2]
      )
    }

    # Exit early if all 6 lambda changes are below threshold
    if (all(lambda_change < min_lambda_change)) break

    # Apply death and offtake rates to each class
    fem_birth[t] <- fem_birth_fec[t] - prob_death[1] * fem_birth_fec[t] - prob_offtake[1] * fem_birth_fec[t]
    fem_juv[t] <- fem_juv_fec[t] - prob_death[2] * fem_juv_fec[t] - prob_offtake[2] * fem_juv_fec[t]
    fem_sub[t] <- fem_sub_fec[t] - prob_death[3] * fem_sub_fec[t] - prob_offtake[3] * fem_sub_fec[t]
    fem_adult[t] <- fem_adult_fec[t] - prob_death[4] * fem_adult_fec[t] - prob_offtake[4] * fem_adult_fec[t]
    fem_cull[t] <- fem_cull_fec[t] - prob_death[5] * fem_cull_fec[t] - prob_offtake[5] * fem_cull_fec[t]
    mal_birth[t] <- mal_birth_fec[t] - prob_death[6] * mal_birth_fec[t] - prob_offtake[6] * mal_birth_fec[t]
    mal_juv[t] <- mal_juv_fec[t] - prob_death[7] * mal_juv_fec[t] - prob_offtake[7] * mal_juv_fec[t]
    mal_sub[t] <- mal_sub_fec[t] - prob_death[8] * mal_sub_fec[t] - prob_offtake[8] * mal_sub_fec[t]
    mal_adult[t] <- Mal_A__x_fec[t] - prob_death[9] * Mal_A__x_fec[t] - prob_offtake[9] * Mal_A__x_fec[t]
    mal_cull[t] <- Mal_C__x_fec[t] - prob_death[10] * Mal_C__x_fec[t] - prob_offtake[10] * Mal_C__x_fec[t]

    # Apply transition probabilities (growth to next class)
    fem_juv_grow[t] <- fem_birth[t] + (1 - prob_growth[2]) * fem_juv[t]
    fem_sub_grow[t] <- prob_growth[2] * fem_juv[t] + (1 - prob_growth[3]) * fem_sub[t]
    fem_adult_grow[t] <- prob_growth[3] * fem_sub[t] + (1 - prob_growth[4]) * fem_adult[t]
    fem_cull_grow[t] <- prob_growth[4] * fem_adult[t]

    mal_juv_grow[t] <- mal_birth[t] + (1 - prob_growth[7]) * mal_juv[t]
    mal_sub_grow[t] <- prob_growth[7] * mal_juv[t] + (1 - prob_growth[8]) * mal_sub[t]
    mal_adult_grow[t] <- prob_growth[8] * mal_sub[t] + (1 - prob_growth[9]) * mal_adult[t]
    mal_cull_grow[t] <- prob_growth[9] * mal_adult[t]
  }

  # Final iteration count
  days_steady <- t

  # Extract population state at steady-state
  xend <- c(
    fem_birth_fec[days_steady], fem_juv_fec[days_steady],
    fem_sub_fec[days_steady], fem_adult_fec[days_steady],
    mal_birth_fec[days_steady], mal_juv_fec[days_steady],
    mal_sub_fec[days_steady], Mal_A__x_fec[days_steady]
  )

  # Compute final structure (8 classes)
  structure <- xend / sum(xend)
  names(structure) <- c("FB", "FJ", "FS", "FA", "MB", "MJ", "MS", "MA")

  # Compute condensed share (6 classes: juveniles = birth + juvenile)
  share <- c(
    structure["FB"] + structure["FJ"],
    structure[c("FS", "FA")],
    structure["MB"] + structure["MJ"],
    structure[c("MS", "MA")]
  )
  names(share) <- c("FJ", "FS", "FA", "MJ", "MS", "MA")

  # Compute steady-state annual growth rate
  growth_rate_pop <- (fem_juv_fec[days_steady] / fem_juv_fec[days_steady - 1])^365 - 1

  # Return output
  output <- list(days_steady, structure, share, growth_rate_pop)
  names(output) <- c("days_steady", "structure", "share", "growth_rate_pop")

  return(output)
}



#' Project One Year of Steady-State Population Dynamics
#'
#' Simulates one year of population dynamics under steady-state assumptions using demographic parameters
#' and returns population size statistics and offtake results.
#'
#' @param size_total Numeric. Total population size at the start of the year.
#' @param female_fecundity Numeric. Daily female births per adult female (from `compute_fecundity_rates()`).
#' @param male_fecundity Numeric. Daily male births per adult female (from `compute_fecundity_rates()`).
#' @param prob_death Numeric vector of length 10. Daily death probabilities (from `compute_transition_probabilities()`).
#' @param prob_offtake Numeric vector of length 10. Daily offtake probabilities (from `compute_transition_probabilities()`).
#' @param prob_growth Numeric vector of length 10. Transition probabilities to next age class (from `compute_transition_probabilities()`).
#' @param growth_rate_pop Numeric. Annual population growth rate (from `simulate_steady_state_structure()`).
#' @param structure Numeric vector of length 8. Final population share in 8 classes (from `simulate_steady_state_structure()`).
#' @param share Numeric vector of length 6. Final population share in 6 grouped classes (from `simulate_steady_state_structure()`).
#'
#' @return A named list with:
#' \describe{
#'   \item{size}{Size in 6 sex-age classes at the start of the year.}
#'   \item{size_end}{Size at year end (projected using growth rate).}
#'   \item{size_end_exact}{Size at year end (based on full simulation over 366 days).}
#'   \item{size_avg}{Average population size over the year.}
#'   \item{offtake}{Total offtake over the year per sex-age class.}
#' }
#'
#' @export
project_population_size <- function(
    size_total, female_fecundity, male_fecundity, prob_death, prob_offtake, prob_growth,
    growth_rate_pop, structure, share) {

  # Calculate initial number of individuals in each of the 8 sex-age classes
  xini <- size_total * structure

  # Compute beginning, end (via growth rate), and average size for 6 sex-age classes
  size <- size_total * share
  size_end <- (1 + growth_rate_pop) * size
  size_avg <- (size + size_end) / 2

  # Compute relative structure within sex for later simulation
  structure_intrasex <- c(size[1:3] / sum(size[1:3]), size[4:6] / sum(size[4:6]))

  # Initialize all tracking vectors
  fem_birth <- fem_juv <- fem_sub <- fem_adult <- fem_cull <- NULL
  mal_birth <- mal_juv <- mal_sub <- mal_adult <- mal_cull <- NULL

  fem_birth_death <- fem_juv_death <- fem_sub_death <- fem_adult_death <- fem_cull_death <- NULL
  mal_birth_death <- mal_juv_death <- mal_sub_death <- mal_adult_death <- mal_cull_death <- NULL

  fem_birth <- fem_juv <- fem_sub <- fem_adult <- fem_cull <- NULL
  mal_birth <- mal_juv <- mal_sub <- mal_adult <- mal_cull <- NULL

  fem_juv_grow <- fem_sub_grow <- fem_adult_grow <- fem_cull_grow <- NULL
  mal_juv_grow <- mal_sub_grow <- mal_adult_grow <- mal_cull_grow <- NULL

  # Simulate daily dynamics over 366 days (leap year assumption)
  for (t in 1:366) {
    if (t == 1) {
      # Initialize class sizes using xini and fecundity
      fem_juv_fec <- xini[2]
      fem_sub_fec <- xini[3]
      fem_adult_fec <- xini[4]
      fem_cull_fec <- 0
      fem_birth_fec <- fem_adult_fec * female_fecundity

      mal_juv_fec <- xini[6]
      mal_sub_fec <- xini[7]
      Mal_A__x_fec <- xini[8]
      Mal_C__x_fec <- 0
      mal_birth_fec <- fem_adult_fec * male_fecundity
    } else {
      # Update fecundity stage from previous day's transitions
      fem_juv_fec[t] <- fem_juv_grow[t - 1]
      fem_sub_fec[t] <- fem_sub_grow[t - 1]
      fem_adult_fec[t] <- fem_adult_grow[t - 1]
      fem_cull_fec[t] <- 0
      fem_birth_fec[t] <- fem_adult_fec[t] * female_fecundity

      mal_juv_fec[t] <- mal_juv_grow[t - 1]
      mal_sub_fec[t] <- mal_sub_grow[t - 1]
      Mal_A__x_fec[t] <- mal_adult_grow[t - 1]
      Mal_C__x_fec[t] <- 0
      mal_birth_fec[t] <- fem_adult_fec[t] * male_fecundity
    }

    if (t <= 365) {
      # Apply death rates
      fem_birth[t] <- prob_death[1] * fem_birth_fec[t]
      fem_juv[t] <- prob_death[2] * fem_juv_fec[t]
      fem_sub[t] <- prob_death[3] * fem_sub_fec[t]
      fem_adult[t] <- prob_death[4] * fem_adult_fec[t]
      fem_cull[t] <- prob_death[5] * fem_cull_fec[t]
      mal_birth[t] <- prob_death[6] * mal_birth_fec[t]
      mal_juv[t] <- prob_death[7] * mal_juv_fec[t]
      mal_sub[t] <- prob_death[8] * mal_sub_fec[t]
      mal_adult[t] <- prob_death[9] * Mal_A__x_fec[t]
      mal_cull[t] <- prob_death[10] * Mal_C__x_fec[t]

      # Apply offtake rates
      fem_birth_death[t] <- prob_offtake[1] * fem_birth_fec[t]
      fem_juv_death[t] <- prob_offtake[2] * fem_juv_fec[t]
      fem_sub_death[t] <- prob_offtake[3] * fem_sub_fec[t]
      fem_adult_death[t] <- prob_offtake[4] * fem_adult_fec[t]
      fem_cull_death[t] <- prob_offtake[5] * fem_cull_fec[t]
      mal_birth_death[t] <- prob_offtake[6] * mal_birth_fec[t]
      mal_juv_death[t] <- prob_offtake[7] * mal_juv_fec[t]
      mal_sub_death[t] <- prob_offtake[8] * mal_sub_fec[t]
      mal_adult_death[t] <- prob_offtake[9] * Mal_A__x_fec[t]
      mal_cull_death[t] <- prob_offtake[10] * Mal_C__x_fec[t]

      # Compute survivors after deaths and offtakes
      fem_birth[t] <- fem_birth_fec[t] - fem_birth[t] - fem_birth_death[t]
      fem_juv[t] <- fem_juv_fec[t] - fem_juv[t] - fem_juv_death[t]
      fem_sub[t] <- fem_sub_fec[t] - fem_sub[t] - fem_sub_death[t]
      fem_adult[t] <- fem_adult_fec[t] - fem_adult[t] - fem_adult_death[t]
      fem_cull[t] <- fem_cull_fec[t] - fem_cull[t] - fem_cull_death[t]
      mal_birth[t] <- mal_birth_fec[t] - mal_birth[t] - mal_birth_death[t]
      mal_juv[t] <- mal_juv_fec[t] - mal_juv[t] - mal_juv_death[t]
      mal_sub[t] <- mal_sub_fec[t] - mal_sub[t] - mal_sub_death[t]
      mal_adult[t] <- Mal_A__x_fec[t] - mal_adult[t] - mal_adult_death[t]
      mal_cull[t] <- Mal_C__x_fec[t] - mal_cull[t] - mal_cull_death[t]

      # Transition to next age classes
      fem_juv_grow[t] <- fem_birth[t] + (1 - prob_growth[2]) * fem_juv[t]
      fem_sub_grow[t] <- prob_growth[2] * fem_juv[t] + (1 - prob_growth[3]) * fem_sub[t]
      fem_adult_grow[t] <- prob_growth[3] * fem_sub[t] + (1 - prob_growth[4]) * fem_adult[t]
      fem_cull_grow[t] <- prob_growth[4] * fem_adult[t]

      mal_juv_grow[t] <- mal_birth[t] + (1 - prob_growth[7]) * mal_juv[t]
      mal_sub_grow[t] <- prob_growth[7] * mal_juv[t] + (1 - prob_growth[8]) * mal_sub[t]
      mal_adult_grow[t] <- prob_growth[8] * mal_sub[t] + (1 - prob_growth[9]) * mal_adult[t]
      mal_cull_grow[t] <- prob_growth[9] * mal_adult[t]
    }
  }

  # Compute offtake and final sizes
  offtake <- c(
    sum(fem_birth_death), sum(fem_juv_death), sum(fem_sub_death), sum(fem_adult_death), sum(fem_cull_grow),
    sum(mal_birth_death), sum(mal_juv_death), sum(mal_sub_death), sum(mal_adult_death), sum(mal_cull_grow)
  )

  size_end_exact <- c(
    fem_birth_fec[366], fem_juv_fec[366], fem_sub_fec[366], fem_adult_fec[366],
    fem_cull_fec[366],
    mal_birth_fec[366], mal_juv_fec[366], mal_sub_fec[366], Mal_A__x_fec[366],
    Mal_C__x_fec[366]
  )

  names(size_end_exact) <- names(offtake) <- c(
    "FB", "FJ", "FS", "FA", "FC", "MB", "MJ", "MS", "MA", "MC"
  )
  names(size) <- names(size_end) <- names(size_avg) <- c(
    "FJ", "FS", "FA", "MJ", "MS", "MA"
  )

  # Prepare output
  output <- list(size, size_end, size_end_exact, size_avg, offtake)
  names(output) <- c("size", "size_end", "size_end_exact", "size_avg", "offtake")

  return(output)
}



#' Summarise Offtake and Stock Variation for a Steady-State Year
#'
#' Computes annual offtake quantities and rates, as well as stock variation and their combined values
#' across 6 sex-age classes based on steady-state population projections.
#'
#' @param size Numeric vector of length 6. Population at start of year (from `project_population_size()`).
#' @param size_end Numeric vector of length 6. Population at end of year (from `project_population_size()`).
#' @param size_avg Numeric vector of length 6. Average population over the year (from `project_population_size()`).
#' @param offtake Numeric vector of length 10. Offtake counts from 10 sex-age classes (from `project_population_size()`).
#'
#' @return A named list with:
#' \describe{
#'   \item{stock_variation}{Difference between end and start population sizes.}
#'   \item{offtake_number}{Total number of individuals removed via offtake across 6 sex-age classes.}
#'   \item{offtake_share}{Offtake rate relative to starting population size.}
#'   \item{offtake_share_avg}{Offtake rate relative to average population size.}
#'   \item{offtake_sv_number}{Sum of offtake and stock variation (SV).}
#'   \item{offtake_sv_share}{SV rate relative to starting population size.}
#'   \item{offtake_sv_share_avg}{SV rate relative to average population size.}
#' }
#'
#' @export
summarise_offtake <- function(size, size_end, size_avg, offtake) {
  # Aggregate offtake: collapse 10 sex-age classes to 6 by grouping
  offtake_number <- c(
    sum(offtake[1:2]),   # FJ = FB + FJ
    offtake[3],          # FS
    sum(offtake[4:5]),   # FA = FA + FC
    sum(offtake[6:7]),   # MJ = MB + MJ
    offtake[8],          # MS
    sum(offtake[9:10])   # MA = MA + MC
  )

  # Offtake rates
  offtake_share <- offtake_number / size
  offtake_share_avg <- offtake_number / size_avg

  # Calculate stock variation for each sex-age class from numbers at
  # beginning and end of a steady-state year
  stock_variation <- size_end - size

  # Calculate sum of offtake and stock variation (sv),
  # then calculate the rate for start and average cohort sizes:
  # Offtake + stock variation (SV), and corresponding rates
  offtake_sv_number <- stock_variation + offtake_number
  offtake_sv_share <- offtake_sv_number / size
  offtake_sv_share_avg <- offtake_sv_number / size_avg

  # Assign names
  names(stock_variation) <- names(offtake_number) <-
    names(offtake_share) <- names(offtake_share_avg) <-
    names(offtake_sv_number) <- names(offtake_sv_share) <-
    names(offtake_sv_share_avg) <- c("FJ", "FS", "FA", "MJ", "MS", "MA")

  # Prepare output
  output <- list(
    stock_variation, offtake_number, offtake_share, offtake_share_avg,
    offtake_sv_number, offtake_sv_share, offtake_sv_share_avg
  )
  names(output) <- c(
    "stock_variation", "offtake_number", "offtake_share", "offtake_share_avg",
    "offtake_sv_number", "offtake_sv_share", "offtake_sv_share_avg"
  )

  return(output)
}
