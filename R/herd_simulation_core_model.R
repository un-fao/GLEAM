#' Compute Daily Fecundity Rates
#'
#' Calculates the daily number of male and female offspring produced per adult female.
#'
#' @param parturition_rate Numeric. Parturition rate (probability of an adult female to give birth).
#' @param litsize Numeric. Prolificacy rate (mean number of offspring per parturition).
#' @param fem_birth_fraction Numeric. Female birth ratio (probability that an offspring is female).
#'
#' @return A named list with two elements:
#' \describe{
#'   \item{fem_fec}{Daily number of female offspring per adult female.}
#'   \item{mal_fec}{Daily number of male offspring per adult female.}
#' }
#' @examples
#' compute_fecundity_rates(parturition_rate = 0.8, litsize = 2, fem_birth_fraction = 0.5)
#'
#' @export
compute_fecundity_rates <- function(parturition_rate, litsize, fem_birth_fraction) {
  validate_fecundity_inputs(parturition_rate, litsize, fem_birth_fraction)

  # Calculate fecundity rates
  return(
    list(
      fem_fec = litsize * fem_birth_fraction * (parturition_rate / 365),
      mal_fec = litsize * (1 - fem_birth_fraction) * (parturition_rate / 365)
    )
  )
}

#' Compute Transition Probabilities for Sex-Age Classes
#'
#' Calculates hazard rates and daily transition probabilities (death, offtake, survival, and growth)
#' across 10 cohorts derived from 6 sex-age classes.
#'
#' @param duration Numeric vector of length 6. Duration (in days) of each sex-age class.
#' @param offtake_rate Numeric vector of length 6. Annual offtake rate for each sex-age class.
#' @param mort_rate Numeric vector of length 6. Annual death rate for each sex-age class.
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
compute_transition_probabilities <- function(duration, offtake_rate, mort_rate) {
  validate_transition_inputs(duration, offtake_rate, mort_rate)

  # Define cohort names for clarity
  six_cohort_names <- c("FJ", "FS", "FA", "MJ", "MS", "MA")
  ten_cohort_names <- c("FB", "FJ", "FS", "FA", "FC", "MB", "MJ", "MS", "MA", "MC")

  # Prevent 0/0 in downstream hazard math by ensuring each cohort has at least
  # one non-zero rate. We choose to bump mort_rate, leaving offtake_rate at 0.
  EPSILON <- 1e-12
  zero_hazard <- offtake_rate == 0 & mort_rate == 0
  if (any(zero_hazard)) {
    # bump mort_rate for those cohorts
    mort_rate[zero_hazard] <- EPSILON
  }

  # --- Part 1: Compute values for 6 core sex-age classes ---

  # Instantaneous mortality hazard rate (hazard_death), adjusted by duration
  hazard_death <- ifelse(
    duration < 365, -log(1 - mort_rate) / duration, -log(1 - mort_rate) / 365
  )
  names(hazard_death) <- names(duration)

  # Adjusted duration: keep original if <365, otherwise cap at 365
  duration_max365 <- ifelse(duration < 365, duration, 365)
  names(duration_max365) <- names(duration)

  # Initialize offtake hazard rate (hazard_offtake) with names
  hazard_offtake <- numeric(6)
  names(hazard_offtake) <- names(duration)

  # Estimate hazard_offtake using Newton-Raphson method for each class
  for (cohort_name in six_cohort_names) {
    hazard_death_adj <- hazard_death[[cohort_name]] * duration_max365[[cohort_name]]

    for (t in 1:15) {
      class_hazard_offtake <- ifelse(
        t == 1, offtake_rate[[cohort_name]], class_hazard_offtake - (class_f / class_deriv)
      )

      class_f <- (class_hazard_offtake / (hazard_death_adj + class_hazard_offtake)) *
        (1 - exp(-hazard_death_adj - class_hazard_offtake)) - offtake_rate[[cohort_name]]

      class_deriv <- (
        hazard_death_adj * (1 - exp(-hazard_death_adj - class_hazard_offtake)) +
          class_hazard_offtake * (hazard_death_adj + class_hazard_offtake) *
          exp(-hazard_death_adj - class_hazard_offtake)
      ) / (hazard_death_adj + class_hazard_offtake)^2
    }

    hazard_offtake[[cohort_name]] <- class_hazard_offtake / duration_max365[[cohort_name]]
  }

  # --- Part 2: Extend to 10 cohorts (6 sex-age classes + 2 birth + 2 culling) ---

  # Extend hazard_death and hazard_offtake for 10 cohorts using named access
  # Mapping: FB/MB use juvenile rates (FJ/MJ), FC/MC use adult rates (FA/MA)
  hazard_death_all <- c(
    FB = hazard_death[["FJ"]],
    FJ = hazard_death[["FJ"]],
    FS = hazard_death[["FS"]],
    FA = hazard_death[["FA"]],
    FC = hazard_death[["FA"]],
    MB = hazard_death[["MJ"]],
    MJ = hazard_death[["MJ"]],
    MS = hazard_death[["MS"]],
    MA = hazard_death[["MA"]],
    MC = hazard_death[["MA"]]
  )

  hazard_offtake_all <- c(
    FB = hazard_offtake[["FJ"]],
    FJ = hazard_offtake[["FJ"]],
    FS = hazard_offtake[["FS"]],
    FA = hazard_offtake[["FA"]],
    FC = hazard_offtake[["FA"]],
    MB = hazard_offtake[["MJ"]],
    MJ = hazard_offtake[["MJ"]],
    MS = hazard_offtake[["MS"]],
    MA = hazard_offtake[["MA"]],
    MC = hazard_offtake[["MA"]]
  )

  # Extend duration: assign 1 day to birth/culling cohorts; subtract 1 day where split
  duration_all <- c(
    FB = 1,
    FJ = duration[["FJ"]] - 1,
    FS = duration[["FS"]],
    FA = duration[["FA"]],
    FC = 1,
    MB = 1,
    MJ = duration[["MJ"]] - 1,
    MS = duration[["MS"]],
    MA = duration[["MA"]],
    MC = 1
  )

  # Daily probability of death (prob_death)
  prob_death <- (hazard_death_all / (hazard_death_all + hazard_offtake_all)) *
    (1 - exp(-(hazard_death_all + hazard_offtake_all)))
  prob_death[["FC"]] <- 0  # Culling cohorts cannot die again
  prob_death[["MC"]] <- 0

  # Daily probability of offtake (prob_offtake)
  prob_offtake <- (hazard_offtake_all / (hazard_death_all + hazard_offtake_all)) *
    (1 - exp(-(hazard_death_all + hazard_offtake_all)))
  prob_offtake[["FC"]] <- 1  # Culling cohorts are entirely offtaken
  prob_offtake[["MC"]] <- 1

  # Daily survival probability (prob_survival)
  prob_survival <- 1 - prob_death - prob_offtake

  # Probability of growing into the next class (prob_growth)
  prob_growth <- (prob_survival^(duration_all - 1) - prob_survival^duration_all) / (1 - prob_survival^duration_all)

  # --- Prepare and return results ---

  return(
    list(
      hazard_death = hazard_death,
      hazard_offtake = hazard_offtake,
      prob_death = prob_death,
      prob_offtake = prob_offtake,
      prob_survival = prob_survival,
      prob_growth = prob_growth
    )
  )
}

#' Simulate Steady-State Population Structure
#'
#' Simulates population dynamics over time until a steady-state is reached. Tracks age-class structure and
#' population growth based on survival, offtake, and fecundity parameters.
#'
#' @param initial_structure Named numeric vector of length 6. Initial number of individuals in each of the 6
#'   sex-age classes. Must be named with: \code{FJ}, \code{FS}, \code{FA}, \code{MJ}, \code{MS}, \code{MA}.
#' @param max_years Integer. Maximum number of years to simulate.
#' @param min_lambda_change Numeric. Threshold for minimal change in class-specific growth rates to reach
#'   steady state.
#' @param fem_fec Numeric. Daily number of female births per adult female.
#' @param mal_fec Numeric. Daily number of male births per adult female.
#' @param prob_death Named numeric vector of length 10. Daily death probabilities for 10 cohorts. Must be named
#'   using: \code{FB}, \code{FJ}, \code{FS}, \code{FA}, \code{FC}, \code{MB}, \code{MJ}, \code{MS},
#'   \code{MA}, \code{MC}.
#' @param prob_offtake Named numeric vector of length 10. Daily offtake probabilities for 10 cohorts.
#' Names must match those in \code{prob_death}.
#' @param prob_growth Named numeric vector of length 10. Daily probability of transition
#' to the next class for 10 cohorts. Names must match those in \code{prob_death}.
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
    initial_structure, max_years, min_lambda_change,
    fem_fec, mal_fec, prob_death, prob_offtake, prob_growth
) {
  validate_steady_state_inputs(
    initial_structure, max_years, min_lambda_change,
    fem_fec, mal_fec,
    prob_death, prob_offtake, prob_growth
  )

  # Initialize population vectors
  fem_birth <- fem_juv <- fem_sub <- fem_adult <- fem_cull <- numeric()
  mal_birth <- mal_juv <- mal_sub <- mal_adult <- mal_cull <- numeric()

  fem_juv_grow <- fem_sub_grow <- fem_adult_grow <- fem_cull_grow <- numeric()
  mal_juv_grow <- mal_sub_grow <- mal_adult_grow <- mal_cull_grow <- numeric()

  lambda_change <- rep(1, 6)

  # Run simulation for up to max_years
  for (t in 1:(max_years * 365 + 1)) {
    if (t == 1) {
      # Time step 1: initialize from starting vector
      ## calculate initial number of individuals taking into account
      ## the daily number of born females and males (fem_fec/mal_fec)
      fem_birth_fec <- initial_structure[["FA"]] * fem_fec
      fem_juv_fec <- initial_structure[["FJ"]]
      fem_sub_fec <- initial_structure[["FS"]]
      fem_adult_fec <- initial_structure[["FA"]]
      fem_cull_fec <- 0

      mal_birth_fec <- initial_structure[["FA"]] * mal_fec
      mal_juv_fec <- initial_structure[["MJ"]]
      mal_sub_fec <- initial_structure[["MS"]]
      mal_adult_fec <- initial_structure[["MA"]]
      mal_cull_fec <- 0
    } else {
      # Time step >1: propagate individuals from previous day
      ## calculate number of individuals taking into account both fem_fec/mal_fec and
      ## the number of individuals that survived the previous month and how they moved in the age classes
      fem_juv_fec[t] <- fem_juv_grow[t - 1]
      fem_sub_fec[t] <- fem_sub_grow[t - 1]
      fem_adult_fec[t] <- fem_adult_grow[t - 1]
      fem_cull_fec[t] <- 0
      fem_birth_fec[t] <- fem_adult_fec[t] * fem_fec

      mal_juv_fec[t] <- mal_juv_grow[t - 1]
      mal_sub_fec[t] <- mal_sub_grow[t - 1]
      mal_adult_fec[t] <- mal_adult_grow[t - 1]
      mal_cull_fec[t] <- 0
      mal_birth_fec[t] <- fem_adult_fec[t] * mal_fec
    }

    # Compute class-specific growth rate change (lambda)
    if (t > 2) {
      lambda_change <- c(
        fem_juv_fec[t] / fem_juv_fec[t - 1] - fem_juv_fec[t - 1] / fem_juv_fec[t - 2],
        fem_sub_fec[t] / fem_sub_fec[t - 1] - fem_sub_fec[t - 1] / fem_sub_fec[t - 2],
        fem_adult_fec[t] / fem_adult_fec[t - 1] - fem_adult_fec[t - 1] / fem_adult_fec[t - 2],
        mal_juv_fec[t] / mal_juv_fec[t - 1] - mal_juv_fec[t - 1] / mal_juv_fec[t - 2],
        mal_sub_fec[t] / mal_sub_fec[t - 1] - mal_sub_fec[t - 1] / mal_sub_fec[t - 2],
        mal_adult_fec[t] / mal_adult_fec[t - 1] - mal_adult_fec[t - 1] / mal_adult_fec[t - 2]
      )
    }

    # Exit early if all 6 lambda changes are below threshold
    if (all(lambda_change < min_lambda_change)) break

    # Apply death and offtake rates to each class
    fem_birth[t] <- fem_birth_fec[t] * (1 - prob_death[["FB"]] - prob_offtake[["FB"]])
    fem_juv[t] <- fem_juv_fec[t] * (1 - prob_death[["FJ"]] - prob_offtake[["FJ"]])
    fem_sub[t] <- fem_sub_fec[t] * (1 - prob_death[["FS"]] - prob_offtake[["FS"]])
    fem_adult[t] <- fem_adult_fec[t] * (1 - prob_death[["FA"]] - prob_offtake[["FA"]])
    fem_cull[t] <- fem_cull_fec[t] * (1 - prob_death[["FC"]] - prob_offtake[["FC"]])

    mal_birth[t] <- mal_birth_fec[t] * (1 - prob_death[["MB"]] - prob_offtake[["MB"]])
    mal_juv[t] <- mal_juv_fec[t] * (1 - prob_death[["MJ"]] - prob_offtake[["MJ"]])
    mal_sub[t] <- mal_sub_fec[t] * (1 - prob_death[["MS"]] - prob_offtake[["MS"]])
    mal_adult[t] <- mal_adult_fec[t] * (1 - prob_death[["MA"]] - prob_offtake[["MA"]])
    mal_cull[t] <- mal_cull_fec[t] * (1 - prob_death[["MC"]] - prob_offtake[["MC"]])

    # Apply transition probabilities (growth to next class)
    fem_juv_grow[t] <- fem_birth[t] + (1 - prob_growth[["FJ"]]) * fem_juv[t]
    fem_sub_grow[t] <- prob_growth[["FJ"]] * fem_juv[t] + (1 - prob_growth[["FS"]]) * fem_sub[t]
    fem_adult_grow[t] <- prob_growth[["FS"]] * fem_sub[t] + (1 - prob_growth[["FA"]]) * fem_adult[t]
    fem_cull_grow[t] <- prob_growth[["FA"]] * fem_adult[t]

    mal_juv_grow[t] <- mal_birth[t] + (1 - prob_growth[["MJ"]]) * mal_juv[t]
    mal_sub_grow[t] <- prob_growth[["MJ"]] * mal_juv[t] + (1 - prob_growth[["MS"]]) * mal_sub[t]
    mal_adult_grow[t] <- prob_growth[["MS"]] * mal_sub[t] + (1 - prob_growth[["MA"]]) * mal_adult[t]
    mal_cull_grow[t] <- prob_growth[["MA"]] * mal_adult[t]
  }

  # Final iteration count
  days_steady <- t

  # Extract population state at steady-state
  xend <- c(
    fem_birth_fec[days_steady], fem_juv_fec[days_steady],
    fem_sub_fec[days_steady], fem_adult_fec[days_steady],
    mal_birth_fec[days_steady], mal_juv_fec[days_steady],
    mal_sub_fec[days_steady], mal_adult_fec[days_steady]
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
  return(
    list(
      days_steady = days_steady,
      structure = structure,
      share = share,
      growth_rate_pop = growth_rate_pop
    )
  )
}

#' Project One Year of Steady-State Population Dynamics
#'
#' Simulates one year of population dynamics under steady-state assumptions using demographic parameters
#' and returns population size statistics and offtake results.
#'
#' @param size_total Numeric. Total population size at the start of the year.
#' @param fem_fec Numeric. Daily female births per adult female.
#' @param mal_fec Numeric. Daily male births per adult female.
#' @param prob_death Named numeric vector of length 10. Daily death probabilities. Must be named using:
#'   \code{FB}, \code{FJ}, \code{FS}, \code{FA}, \code{FC}, \code{MB}, \code{MJ}, \code{MS}, \code{MA}, \code{MC}.
#' @param prob_offtake Named numeric vector of length 10. Daily offtake probabilities.
#' Names must match those in \code{prob_death}.
#' @param prob_growth Named numeric vector of length 10. Transition probabilities to next age class.
#' Names must match those in \code{prob_death}.
#' @param growth_rate_pop Numeric. Annual population growth rate.
#' @param structure Named numeric vector of length 8. Final population share in 8 classes. Must be named:
#'   \code{FB}, \code{FJ}, \code{FS}, \code{FA}, \code{MB}, \code{MJ}, \code{MS}, \code{MA}.
#' @param share Named numeric vector of length 6. Final population share in 6 grouped classes. Must be named:
#'   \code{FJ}, \code{FS}, \code{FA}, \code{MJ}, \code{MS}, \code{MA}.
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
    size_total, fem_fec, mal_fec, prob_death, prob_offtake, prob_growth,
    growth_rate_pop, structure, share
) {
  validate_population_size_inputs(
    size_total, fem_fec, mal_fec,
    prob_death, prob_offtake, prob_growth,
    growth_rate_pop,
    structure, share
  )

  # Calculate initial number of individuals in each of the 8 sex-age classes
  xini <- size_total * structure

  # Compute beginning, end (via growth rate), and average size for 6 sex-age classes
  size <- size_total * share
  size_end <- (1 + growth_rate_pop) * size
  size_avg <- (size + size_end) / 2

  # Initialize all tracking vectors
  fem_birth <- fem_juv <- fem_sub <- fem_adult <- fem_cull <- numeric()
  mal_birth <- mal_juv <- mal_sub <- mal_adult <- mal_cull <- numeric()

  fem_birth_death <- fem_juv_death <- fem_sub_death <- fem_adult_death <- fem_cull_death <- numeric()
  mal_birth_death <- mal_juv_death <- mal_sub_death <- mal_adult_death <- mal_cull_death <- numeric()

  fem_juv_grow <- fem_sub_grow <- fem_adult_grow <- fem_cull_grow <- numeric()
  mal_juv_grow <- mal_sub_grow <- mal_adult_grow <- mal_cull_grow <- numeric()

  # Simulate daily dynamics over 366 days (leap year assumption)
  for (t in seq_len(366)) {
    if (t == 1) {
      # Initialize class sizes using xini and fecundity
      fem_juv_fec <- xini[["FJ"]]
      fem_sub_fec <- xini[["FS"]]
      fem_adult_fec <- xini[["FA"]]
      fem_cull_fec <- 0
      fem_birth_fec <- fem_adult_fec * fem_fec

      mal_juv_fec <- xini[["MJ"]]
      mal_sub_fec <- xini[["MS"]]
      mal_adult_fec <- xini[["MA"]]
      mal_cull_fec <- 0
      mal_birth_fec <- fem_adult_fec * mal_fec
    } else {
      # Update fecundity stage from previous day's transitions
      fem_juv_fec[t] <- fem_juv_grow[t - 1]
      fem_sub_fec[t] <- fem_sub_grow[t - 1]
      fem_adult_fec[t] <- fem_adult_grow[t - 1]
      fem_cull_fec[t] <- 0
      fem_birth_fec[t] <- fem_adult_fec[t] * fem_fec

      mal_juv_fec[t] <- mal_juv_grow[t - 1]
      mal_sub_fec[t] <- mal_sub_grow[t - 1]
      mal_adult_fec[t] <- mal_adult_grow[t - 1]
      mal_cull_fec[t] <- 0
      mal_birth_fec[t] <- fem_adult_fec[t] * mal_fec
    }

    if (t <= 365) {
      # Apply death rates
      fem_birth[t] <- fem_birth_fec[t] * (1 - prob_death[["FB"]] - prob_offtake[["FB"]])
      fem_juv[t] <- fem_juv_fec[t]   * (1 - prob_death[["FJ"]] - prob_offtake[["FJ"]])
      fem_sub[t] <- fem_sub_fec[t]   * (1 - prob_death[["FS"]] - prob_offtake[["FS"]])
      fem_adult[t] <- fem_adult_fec[t] * (1 - prob_death[["FA"]] - prob_offtake[["FA"]])
      fem_cull[t] <- fem_cull_fec[t]  * (1 - prob_death[["FC"]] - prob_offtake[["FC"]])

      mal_birth[t] <- mal_birth_fec[t] * (1 - prob_death[["MB"]] - prob_offtake[["MB"]])
      mal_juv[t] <- mal_juv_fec[t]   * (1 - prob_death[["MJ"]] - prob_offtake[["MJ"]])
      mal_sub[t] <- mal_sub_fec[t]   * (1 - prob_death[["MS"]] - prob_offtake[["MS"]])
      mal_adult[t] <- mal_adult_fec[t] * (1 - prob_death[["MA"]] - prob_offtake[["MA"]])
      mal_cull[t] <- mal_cull_fec[t]  * (1 - prob_death[["MC"]] - prob_offtake[["MC"]])

      # Apply offtake rates
      fem_birth_death[t] <- prob_offtake[["FB"]] * fem_birth_fec[t]
      fem_juv_death[t] <- prob_offtake[["FJ"]] * fem_juv_fec[t]
      fem_sub_death[t] <- prob_offtake[["FS"]] * fem_sub_fec[t]
      fem_adult_death[t] <- prob_offtake[["FA"]] * fem_adult_fec[t]
      fem_cull_death[t] <- prob_offtake[["FC"]] * fem_cull_fec[t]

      mal_birth_death[t] <- prob_offtake[["MB"]] * mal_birth_fec[t]
      mal_juv_death[t] <- prob_offtake[["MJ"]] * mal_juv_fec[t]
      mal_sub_death[t] <- prob_offtake[["MS"]] * mal_sub_fec[t]
      mal_adult_death[t] <- prob_offtake[["MA"]] * mal_adult_fec[t]
      mal_cull_death[t] <- prob_offtake[["MC"]] * mal_cull_fec[t]

      # Transition
      fem_juv_grow[t] <- fem_birth[t] + (1 - prob_growth[["FJ"]]) * fem_juv[t]
      fem_sub_grow[t] <- prob_growth[["FJ"]] * fem_juv[t] + (1 - prob_growth[["FS"]]) * fem_sub[t]
      fem_adult_grow[t] <- prob_growth[["FS"]] * fem_sub[t] + (1 - prob_growth[["FA"]]) * fem_adult[t]
      fem_cull_grow[t] <- prob_growth[["FA"]] * fem_adult[t]

      mal_juv_grow[t] <- mal_birth[t] + (1 - prob_growth[["MJ"]]) * mal_juv[t]
      mal_sub_grow[t] <- prob_growth[["MJ"]] * mal_juv[t] + (1 - prob_growth[["MS"]]) * mal_sub[t]
      mal_adult_grow[t] <- prob_growth[["MS"]] * mal_sub[t] + (1 - prob_growth[["MA"]]) * mal_adult[t]
      mal_cull_grow[t] <- prob_growth[["MA"]] * mal_adult[t]
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
    mal_birth_fec[366], mal_juv_fec[366], mal_sub_fec[366], mal_adult_fec[366],
    mal_cull_fec[366]
  )

  names(size_end_exact) <- names(offtake) <- c(
    "FB", "FJ", "FS", "FA", "FC", "MB", "MJ", "MS", "MA", "MC"
  )
  names(size) <- names(size_end) <- names(size_avg) <- c(
    "FJ", "FS", "FA", "MJ", "MS", "MA"
  )

  # Prepare output
  return(
    list(
      size = size,
      size_end = size_end,
      size_end_exact = size_end_exact,
      size_avg = size_avg,
      offtake = offtake
    )
  )
}

#' Summarise Offtake and Stock Variation for a Steady-State Year
#'
#' Computes annual offtake quantities and rates, as well as stock variation and their combined values
#' across 6 sex-age classes based on steady-state population projections.
#'
#' @param size Numeric vector of length 6. Population at start of year.
#' @param size_end Numeric vector of length 6. Population at end of year.
#' @param size_avg Numeric vector of length 6. Average population over the year.
#' @param offtake Numeric vector of length 10. Offtake counts from 10 sex-age classes.
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
  validate_offtake_summary_inputs(size, size_end, size_avg, offtake)

  # Aggregate offtake: collapse 10 sex-age classes into 6
  offtake_number <- c(
    FJ = sum(offtake[c("FB", "FJ")]),
    FS = offtake["FS"],
    FA = sum(offtake[c("FA", "FC")]),
    MJ = sum(offtake[c("MB", "MJ")]),
    MS = offtake["MS"],
    MA = sum(offtake[c("MA", "MC")])
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
  return(
    list(
      stock_variation = stock_variation,
      offtake_number = offtake_number,
      offtake_share = offtake_share,
      offtake_share_avg = offtake_share_avg,
      offtake_sv_number = offtake_sv_number,
      offtake_sv_share = offtake_sv_share,
      offtake_sv_share_avg = offtake_sv_share_avg
    )
  )
}
