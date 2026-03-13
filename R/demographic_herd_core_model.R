#' Compute Daily Fecundity Rates
#'
#' Calculates the daily number of male and female offspring produced per adult female.
#'
#' @param parturition_rate Numeric. Average annual number of parturitions per female animal (# parturitions/adult female/year). A herd-level reproductive performance indicator calculated as the total number of parturitions (deliveries) occurring during a year divided by the number of adult females potentially able to give birth during that year.
#' @param litter_size Numeric. Average number of offspring born per parturition (# offsprings/parturition). This value can be calculated as the total number of offspring born divided by the total number of parturitions during the year.
#' @param birth_fraction_female Numeric. Female birth fraction, defined as the probability that a newborn offspring is female (fraction). Can be calculated  as the number of female offspring born divided by the total number of offspring born.
#'
#' @return A named list with two elements:
#' \describe{
#'   \item{fecundity_female}{Numeric. Daily number of female offspring per adult female (# offspring/day)}
#'   \item{fecundity_male}{Numeric. Daily number of male offspring per adult female (# offspring/day)}
#' }
#' @examples
#' calc_fecundity_rates(parturition_rate = 0.8, litter_size = 2, birth_fraction_female = 0.5)
#'
#' @export
calc_fecundity_rates <- function(
    parturition_rate,
    litter_size,
    birth_fraction_female
) {
  validate_fecundity_inputs(parturition_rate, litter_size, birth_fraction_female)

  # Calculate fecundity rates
  fecundity_female <-  litter_size * birth_fraction_female * (parturition_rate / 365)
  fecundity_male <- litter_size * (1 - birth_fraction_female) * (parturition_rate / 365)

  return(
    list(
      fecundity_female = fecundity_female,
      fecundity_male = fecundity_male
    )
  )
}

#' Compute Transition Probabilities for Sex-Age Classes
#'
#' Calculates hazard rates and daily transition probabilities (death, offtake, survival, and growth)
#' across different sex-age cohorts. Converts annual inputs to daily hazards, then derives daily probabilities
#' from those hazards.
#'
#' @param cohort_duration_days Numeric vector of length 6. Amount of time that each animal spends in a specific cohort (days).
#' @param offtake_rate Numeric vector of length 6. Annual proportion of animals removed from the herd for each sex-age cohort (fraction).
#' @param death_rate Numeric vector of length 6. Fraction of deaths in a herd over a year for each sex-age cohort (fraction)
#'
#' @return A named list with:
#' \describe{
#'   \item{hazard_death}{Numeric vector of length 6. Instantaneous mortality hazard rate for the 6 sex–age cohorts. Represents the  risk of death per unit time (day) (cohorts= \code{FJ}, \code{FS}, \code{FA}, \code{MJ}, \code{MS}, \code{MA})}
#'   \item{hazard_offtake}{Numeric vector of length 6. Instantaneous offtake hazard rate for the 6 sex-age cohorts. Represents the risk to leave the herd through planned removals per unit of time (day-1) (cohorts= \code{FJ}, \code{FS}, \code{FA}, \code{MJ}, \code{MS}, \code{MA})}
#'   \item{probability_death}{Named numeric vector of length 10. Probability of animal dying within the model time interval for 10 cohorts (fraction).
#'   (cohorts= \code{FB}: Female Birth, \code{FJ}: Female Juvenile, \code{FS}: Female Sub-adult, \code{FA}: Female Adult, \code{FC}: Female Culling, \code{MB}: Male Birth, \code{MJ}: Male Juvenile, \code{MS}: Male Sub-adult, \code{MA}: Male Adult, \code{MC}: Male Culling)}
#'   \item{probability_offtake}{Named numeric vector of length 10. Probability that an animal will be removed from the herd within the model time interval for 10 cohorts (fraction).
#'   (cohorts= \code{FB}: Female Birth, \code{FJ}: Female Juvenile, \code{FS}: Female Sub-adult, \code{FA}: Female Adult, \code{FC}: Female Culling, \code{MB}: Male Birth, \code{MJ}: Male Juvenile, \code{MS}: Male Sub-adult, \code{MA}: Male Adult, \code{MC}: Male Culling)}
#'   \item{probability_survival}{Named numeric vector of length 10. Probability that an animal remains alive in the herd within the model time interval for 10 cohorts (fraction).
#'   (cohorts= \code{FB}: Female Birth, \code{FJ}: Female Juvenile, \code{FS}: Female Sub-adult, \code{FA}: Female Adult, \code{FC}: Female Culling, \code{MB}: Male Birth, \code{MJ}: Male Juvenile, \code{MS}: Male Sub-adult, \code{MA}: Male Adult, \code{MC}: Male Culling)}
#'   \item{probability_growth}{Named numeric vector of length 10. Probability of growing into the next age class for 10 cohorts (fraction)
#'   (cohorts= \code{FB}: Female Birth, \code{FJ}: Female Juvenile, \code{FS}: Female Sub-adult, \code{FA}: Female Adult, \code{FC}: Female Culling, \code{MB}: Male Birth, \code{MJ}: Male Juvenile, \code{MS}: Male Sub-adult, \code{MA}: Male Adult, \code{MC}: Male Culling)}
#' }
#'
#' @export
calc_transition_probabilities <- function(
    cohort_duration_days,
    offtake_rate,
    death_rate
) {
  validate_transition_inputs(cohort_duration_days, offtake_rate, death_rate)

  # Define cohort names for clarity
  six_cohort_names <- c("FJ", "FS", "FA", "MJ", "MS", "MA")
  ten_cohort_names <- c("FB", "FJ", "FS", "FA", "FC", "MB", "MJ", "MS", "MA", "MC")

  # Prevent 0/0 in downstream hazard math by ensuring each cohort has at least
  # one non-zero rate. We choose to bump mort_rate, leaving offtake_rate at 0.
  EPSILON <- 1e-12
  zero_hazard <- offtake_rate == 0 & death_rate == 0
  if (any(zero_hazard)) {
    # bump death_rate for those cohorts
    death_rate[zero_hazard] <- EPSILON
  }

  # --- Part 1: Compute values for 6 core sex-age classes ---

  # Instantaneous mortality hazard rate (hazard_death), adjusted by duration
  hazard_death <- ifelse(
    cohort_duration_days < 365,
    -log(1 - death_rate) / cohort_duration_days,
    -log(1 - death_rate) / 365
  )
  names(hazard_death) <- names(cohort_duration_days)

  # Adjusted duration: keep original if <365, otherwise cap at 365
  duration_max365 <- ifelse(cohort_duration_days < 365, cohort_duration_days, 365)
  names(duration_max365) <- names(cohort_duration_days)

  # Initialize offtake hazard rate (hazard_offtake) with names
  hazard_offtake <- numeric(6)
  names(hazard_offtake) <- names(cohort_duration_days)

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
    FJ = cohort_duration_days[["FJ"]] - 1,
    FS = cohort_duration_days[["FS"]],
    FA = cohort_duration_days[["FA"]],
    FC = 1,
    MB = 1,
    MJ = cohort_duration_days[["MJ"]] - 1,
    MS = cohort_duration_days[["MS"]],
    MA = cohort_duration_days[["MA"]],
    MC = 1
  )

  # Daily probability of death (prob_death)
  probability_death <- (hazard_death_all / (hazard_death_all + hazard_offtake_all)) *
    (1 - exp(-(hazard_death_all + hazard_offtake_all)))
  probability_death[["FC"]] <- 0  # Culling cohorts cannot die again
  probability_death[["MC"]] <- 0

  # Daily probability of offtake (prob_offtake)
  probability_offtake <- (hazard_offtake_all / (hazard_death_all + hazard_offtake_all)) *
    (1 - exp(-(hazard_death_all + hazard_offtake_all)))
  probability_offtake[["FC"]] <- 1  # Culling cohorts are entirely offtaken
  probability_offtake[["MC"]] <- 1

  # Daily survival probability (prob_survival)
  probability_survival <- 1 - probability_death - probability_offtake

  # Probability of growing into the next class (prob_growth)
  probability_growth <- (probability_survival^(duration_all - 1) - probability_survival^duration_all) /
    (1 - probability_survival^duration_all)

  return(
    list(
      hazard_death = hazard_death,
      hazard_offtake = hazard_offtake,
      probability_death = probability_death,
      probability_offtake = probability_offtake,
      probability_survival = probability_survival,
      probability_growth = probability_growth
    )
  )
}

#' Simulate Steady-State Population Structure
#'
#'
#'Simulates population dynamics over time until a steady state is reached.
#'The steady state is defined as a constant sex–age cohort structure over time,
#'with population size potentially growing or declining at a constant rate.
#'Tracks sex–age cohort structure and population growth based on survival,
#'offtake, and fecundity parameters.
#'
#'
#' @param initial_herd_structure Named numeric vector of length 6. Initial number of individuals in each of the 6 sex-age classes used
#' to bootstrap the steady-state simulation (# heads).
#' These values are used as starting points for the iterative simulation and do not affect the final steady-state results (only convergence speed).
#' Must be named with: \code{FJ}, \code{FS}, \code{FA}, \code{MJ}, \code{MS}, \code{MA}.
#' @param max_simulation_years Numeric. Maximum number of years to simulate (years).
#' @param min_lambda_change Numeric. Convergence threshold for changes in cohort-specific growth rates of sex–age cohort proportions (lambda). Iterations of the herd simulation stop when the absolute change in lambda between successive iterations falls below this threshold.
#' @param fecundity_female Numeric. Daily number of female offspring per adult female (# offspring/day)
#' @param fecundity_male Numeric. Daily number of male offspring per adult female (# offspring/day)
#' @param probability_death Named numeric vector of length 10. Probability of animal dying within the model time interval for 10 cohorts (fraction)
#' (cohorts= \code{FB}: Female Birth, \code{FJ}: Female Juvenile, \code{FS}: Female Sub-adult, \code{FA}: Female Adult, \code{FC}: Female Culling, \code{MB}: Male Birth, \code{MJ}: Male Juvenile, \code{MS}: Male Sub-adult, \code{MA}: Male Adult, \code{MC}: Male Culling).
#' @param probability_offtake Named numeric vector of length 10. Probability that an animal will be removed from the herd within the model time interval for 10 cohorts (fraction).
#' (cohorts= \code{FB}: Female Birth, \code{FJ}: Female Juvenile, \code{FS}: Female Sub-adult, \code{FA}: Female Adult, \code{FC}: Female Culling, \code{MB}: Male Birth, \code{MJ}: Male Juvenile, \code{MS}: Male Sub-adult, \code{MA}: Male Adult, \code{MC}: Male Culling).
#' @param probability_growth Named numeric vector of length 10. Probability of growing into the next age class for 10 cohorts (fraction)
#' (cohorts= \code{FB}: Female Birth, \code{FJ}: Female Juvenile, \code{FS}: Female Sub-adult, \code{FA}: Female Adult, \code{FC}: Female Culling, \code{MB}: Male Birth, \code{MJ}: Male Juvenile, \code{MS}: Male Sub-adult, \code{MA}: Male Adult, \code{MC}: Male Culling).
#'
#' @return A named list with:
#' \describe{
#'   \item{days_to_steady_state}{Numeric. Number of days required for the herd population structure to converge to a steady state, defined as the point at which successive iterations produce negligible changes in cohort proportions (days)}
#'   \item{herd_structure}{Named numeric vector of length 8. Final steady-state share of each of 8 sex-age cohorts (\code{FB}, \code{FJ}, \code{FS}, \code{FA}, \code{MB}, \code{MJ}, \code{MS}, \code{MA}) (fraction). Shares should sum to 1.}
#'   \item{cohort_share}{Named numeric vector of length 6. Final steady-state share of 6 grouped sex-age cohorts  (\code{FJ}, \code{FS}, \code{FA}, \code{MJ}, \code{MS}, \code{MA}, where `FJ = FB + FJ` and `MJ = MB + MJ`) (fraction). Shares should sum to 1.}
#'   \item{growth_rate_herd}{Numeric. Annualized growth rate at which the herd reaches steady state (fraction)}
#' }
#'
#' @export
calc_steady_state_structure <- function(
    initial_herd_structure,
    max_simulation_years,
    min_lambda_change,
    fecundity_female,
    fecundity_male,
    probability_death,
    probability_offtake,
    probability_growth
) {
  validate_steady_state_inputs(
    initial_herd_structure,
    max_simulation_years,
    min_lambda_change,
    fecundity_female,
    fecundity_male,
    probability_death,
    probability_offtake,
    probability_growth
  )

  # Initialize population vectors
  fem_birth <- fem_juv <- fem_sub <- fem_adult <- fem_cull <- numeric()
  mal_birth <- mal_juv <- mal_sub <- mal_adult <- mal_cull <- numeric()

  fem_juv_grow <- fem_sub_grow <- fem_adult_grow <- fem_cull_grow <- numeric()
  mal_juv_grow <- mal_sub_grow <- mal_adult_grow <- mal_cull_grow <- numeric()

  lambda_change <- rep(1, 6)

  # Run simulation for up to max_years
  for (t in 1:(max_simulation_years * 365 + 1)) {
    if (t == 1) {
      # Time step 1: initialize from starting vector
      ## calculate initial number of individuals taking into account
      ## the daily number of born females and males (fem_fec/mal_fec)
      fem_birth_fec <- initial_herd_structure[["FA"]] * fecundity_female
      fem_juv_fec <- initial_herd_structure[["FJ"]]
      fem_sub_fec <- initial_herd_structure[["FS"]]
      fem_adult_fec <- initial_herd_structure[["FA"]]
      fem_cull_fec <- 0

      mal_birth_fec <- initial_herd_structure[["FA"]] * fecundity_male
      mal_juv_fec <- initial_herd_structure[["MJ"]]
      mal_sub_fec <- initial_herd_structure[["MS"]]
      mal_adult_fec <- initial_herd_structure[["MA"]]
      mal_cull_fec <- 0
    } else {
      # Time step >1: propagate individuals from previous day
      ## calculate number of individuals taking into account both fem_fec/mal_fec and
      ## the number of individuals that survived the previous month and how they moved in the age classes
      fem_juv_fec[t] <- fem_juv_grow[t - 1]
      fem_sub_fec[t] <- fem_sub_grow[t - 1]
      fem_adult_fec[t] <- fem_adult_grow[t - 1]
      fem_cull_fec[t] <- 0
      fem_birth_fec[t] <- fem_adult_fec[t] * fecundity_female

      mal_juv_fec[t] <- mal_juv_grow[t - 1]
      mal_sub_fec[t] <- mal_sub_grow[t - 1]
      mal_adult_fec[t] <- mal_adult_grow[t - 1]
      mal_cull_fec[t] <- 0
      mal_birth_fec[t] <- fem_adult_fec[t] * fecundity_male
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
    fem_birth[t] <- fem_birth_fec[t] * (1 - probability_death[["FB"]] - probability_offtake[["FB"]])
    fem_juv[t] <- fem_juv_fec[t] * (1 - probability_death[["FJ"]] - probability_offtake[["FJ"]])
    fem_sub[t] <- fem_sub_fec[t] * (1 - probability_death[["FS"]] - probability_offtake[["FS"]])
    fem_adult[t] <- fem_adult_fec[t] * (1 - probability_death[["FA"]] - probability_offtake[["FA"]])
    fem_cull[t] <- fem_cull_fec[t] * (1 - probability_death[["FC"]] - probability_offtake[["FC"]])

    mal_birth[t] <- mal_birth_fec[t] * (1 - probability_death[["MB"]] - probability_offtake[["MB"]])
    mal_juv[t] <- mal_juv_fec[t] * (1 - probability_death[["MJ"]] - probability_offtake[["MJ"]])
    mal_sub[t] <- mal_sub_fec[t] * (1 - probability_death[["MS"]] - probability_offtake[["MS"]])
    mal_adult[t] <- mal_adult_fec[t] * (1 - probability_death[["MA"]] - probability_offtake[["MA"]])
    mal_cull[t] <- mal_cull_fec[t] * (1 - probability_death[["MC"]] - probability_offtake[["MC"]])

    # Apply transition probabilities (growth to next class)
    fem_juv_grow[t] <- fem_birth[t] + (1 - probability_growth[["FJ"]]) * fem_juv[t]
    fem_sub_grow[t] <- probability_growth[["FJ"]] * fem_juv[t] + (1 - probability_growth[["FS"]]) * fem_sub[t]
    fem_adult_grow[t] <- probability_growth[["FS"]] * fem_sub[t] + (1 - probability_growth[["FA"]]) * fem_adult[t]
    fem_cull_grow[t] <- probability_growth[["FA"]] * fem_adult[t]

    mal_juv_grow[t] <- mal_birth[t] + (1 - probability_growth[["MJ"]]) * mal_juv[t]
    mal_sub_grow[t] <- probability_growth[["MJ"]] * mal_juv[t] + (1 - probability_growth[["MS"]]) * mal_sub[t]
    mal_adult_grow[t] <- probability_growth[["MS"]] * mal_sub[t] + (1 - probability_growth[["MA"]]) * mal_adult[t]
    mal_cull_grow[t] <- probability_growth[["MA"]] * mal_adult[t]
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
  growth_rate_herd <- (fem_juv_fec[days_steady] / fem_juv_fec[days_steady - 1])^365 - 1

  return(
    list(
      days_to_steady_state = days_steady,
      herd_structure = structure,
      cohort_share = share,
      growth_rate_herd = growth_rate_herd
    )
  )
}

#' Project One Year of Steady-State Population Dynamics
#'
#' Simulates one year of population dynamics under steady-state assumptions using demographic parameters
#' and returns population size statistics and offtake results. The steady state is defined as a constant
#' sex–age cohort structure over time, with population size potentially growing or declining at a constant rate.
#'
#' @param herd_size_total Numeric. Total population size at the start of the year, including all cohorts (# heads)
#' @param fecundity_female Numeric. Daily number of female offspring per adult female (# offspring/day)
#' @param fecundity_male Numeric. Daily number of male offspring per adult female (# offspring/day)
#' @param probability_death Named numeric vector of length 10. Probability of animal dying within the model time interval for 10 cohorts (fraction)
#' (cohorts= \code{FB}: Female Birth, \code{FJ}: Female Juvenile, \code{FS}: Female Sub-adult, \code{FA}: Female Adult, \code{FC}: Female Culling, \code{MB}: Male Birth, \code{MJ}: Male Juvenile, \code{MS}: Male Sub-adult, \code{MA}: Male Adult, \code{MC}: Male Culling).
#' @param probability_offtake Named numeric vector of length 10. Probability that an animal will be removed from the herd within the model time interval for 10 cohorts (fraction).
#' (cohorts= \code{FB}: Female Birth, \code{FJ}: Female Juvenile, \code{FS}: Female Sub-adult, \code{FA}: Female Adult, \code{FC}: Female Culling, \code{MB}: Male Birth, \code{MJ}: Male Juvenile, \code{MS}: Male Sub-adult, \code{MA}: Male Adult, \code{MC}: Male Culling).
#' @param probability_growth Named numeric vector of length 10. Probability of growing into the next age class for 10 cohorts (fraction)
#' (cohorts= \code{FB}: Female Birth, \code{FJ}: Female Juvenile, \code{FS}: Female Sub-adult, \code{FA}: Female Adult, \code{FC}: Female Culling, \code{MB}: Male Birth, \code{MJ}: Male Juvenile, \code{MS}: Male Sub-adult, \code{MA}: Male Adult, \code{MC}: Male Culling).
#' @param growth_rate_herd Numeric. Annualized growth rate at which the herd reaches steady state (fraction)
#' @param herd_structure Named numeric vector of length 8. Final steady-state share of each of 8 sex-age cohorts (\code{FB}, \code{FJ}, \code{FS}, \code{FA}, \code{MB}, \code{MJ}, \code{MS}, \code{MA}) (fraction). Shares should sum to 1.
#' @param cohort_share Named numeric vector of length 6. Final steady-state share of 6 grouped sex-age cohorts  (\code{FJ}, \code{FS}, \code{FA}, \code{MJ}, \code{MS}, \code{MA}, where `FJ = FB + FJ` and `MJ = MB + MJ`) (fraction). Shares should sum to 1.
#'
#' @return A named list with:
#' \describe{
#'   \item{cohort_stock_start}{Numeric vector of length 6. Population size in each of the 6 sex–age cohorts at the start of the year (# heads). (cohorts= \code{FJ}, \code{FS}, \code{FA}, \code{MJ}, \code{MS}, \code{MA})}
#'   \item{cohort_stock_end_projected}{Numeric vector of length 6. Population size in each of the 6 sex–age cohorts at the end of the year, projected using the steady-state growth rate (# heads). (cohorts= \code{FJ}, \code{FS}, \code{FA}, \code{MJ}, \code{MS}, \code{MA})}
#'   \item{cohort_stock_end_exact_simulated}{Numeric vector of length 10. Population size in each of 10 sex–age cohort at the end of the year, based on a demographic daily simulation over 365 days (# heads)
#'   (cohorts= \code{FB}: Female Birth, \code{FJ}: Female Juvenile, \code{FS}: Female Sub-adult, \code{FA}: Female Adult, \code{FC}: Female Culling, \code{MB}: Male Birth, \code{MJ}: Male Juvenile, \code{MS}: Male Sub-adult, \code{MA}: Male Adult, \code{MC}: Male Culling)}
#'   \item{cohort_stock_average}{Numeric vector of length 6. Average population size in each of the 6 sex–age cohorts over the year (# heads). Estimated from cohort_stock_start and cohort_stock_end_projected  (cohorts= \code{FJ}, \code{FS}, \code{FA}, \code{MJ}, \code{MS}, \code{MA})}
#'   \item{cohort_offtake_heads}{Numeric vector of length 10. Total number of animals removed from the herd over the year, by 10 sex–age cohorts (heads/year)
#'   (cohorts= \code{FB}: Female Birth, \code{FJ}: Female Juvenile, \code{FS}: Female Sub-adult, \code{FA}: Female Adult, \code{FC}: Female Culling, \code{MB}: Male Birth, \code{MJ}: Male Juvenile, \code{MS}: Male Sub-adult, \code{MA}: Male Adult, \code{MC}: Male Culling)}
#' }
#'
#' @export
calc_projected_population_size <- function(
    herd_size_total,
    fecundity_female,
    fecundity_male,
    probability_death,
    probability_offtake,
    probability_growth,
    growth_rate_herd,
    herd_structure,
    cohort_share
) {
  validate_population_size_inputs(
    herd_size_total,
    fecundity_female,
    fecundity_male,
    probability_death,
    probability_offtake,
    probability_growth,
    growth_rate_herd,
    herd_structure,
    cohort_share
  )

  # Calculate initial number of individuals in each of the 8 sex-age classes
  xini <- herd_size_total * herd_structure

  # Compute beginning, end (via growth rate), and average size for 6 sex-age classes
  size <- herd_size_total * cohort_share
  size_end <- (1 + growth_rate_herd) * size
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
      fem_birth_fec <- fem_adult_fec * fecundity_female

      mal_juv_fec <- xini[["MJ"]]
      mal_sub_fec <- xini[["MS"]]
      mal_adult_fec <- xini[["MA"]]
      mal_cull_fec <- 0
      mal_birth_fec <- fem_adult_fec * fecundity_male
    } else {
      # Update fecundity stage from previous day's transitions
      fem_juv_fec[t] <- fem_juv_grow[t - 1]
      fem_sub_fec[t] <- fem_sub_grow[t - 1]
      fem_adult_fec[t] <- fem_adult_grow[t - 1]
      fem_cull_fec[t] <- 0
      fem_birth_fec[t] <- fem_adult_fec[t] * fecundity_female

      mal_juv_fec[t] <- mal_juv_grow[t - 1]
      mal_sub_fec[t] <- mal_sub_grow[t - 1]
      mal_adult_fec[t] <- mal_adult_grow[t - 1]
      mal_cull_fec[t] <- 0
      mal_birth_fec[t] <- fem_adult_fec[t] * fecundity_male
    }

    if (t <= 365) {
      # Apply death rates
      fem_birth[t] <- fem_birth_fec[t] * (1 - probability_death[["FB"]] - probability_offtake[["FB"]])
      fem_juv[t] <- fem_juv_fec[t]   * (1 - probability_death[["FJ"]] - probability_offtake[["FJ"]])
      fem_sub[t] <- fem_sub_fec[t]   * (1 - probability_death[["FS"]] - probability_offtake[["FS"]])
      fem_adult[t] <- fem_adult_fec[t] * (1 - probability_death[["FA"]] - probability_offtake[["FA"]])
      fem_cull[t] <- fem_cull_fec[t]  * (1 - probability_death[["FC"]] - probability_offtake[["FC"]])

      mal_birth[t] <- mal_birth_fec[t] * (1 - probability_death[["MB"]] - probability_offtake[["MB"]])
      mal_juv[t] <- mal_juv_fec[t]   * (1 - probability_death[["MJ"]] - probability_offtake[["MJ"]])
      mal_sub[t] <- mal_sub_fec[t]   * (1 - probability_death[["MS"]] - probability_offtake[["MS"]])
      mal_adult[t] <- mal_adult_fec[t] * (1 - probability_death[["MA"]] - probability_offtake[["MA"]])
      mal_cull[t] <- mal_cull_fec[t]  * (1 - probability_death[["MC"]] - probability_offtake[["MC"]])

      # Apply offtake rates
      fem_birth_death[t] <- probability_offtake[["FB"]] * fem_birth_fec[t]
      fem_juv_death[t] <- probability_offtake[["FJ"]] * fem_juv_fec[t]
      fem_sub_death[t] <- probability_offtake[["FS"]] * fem_sub_fec[t]
      fem_adult_death[t] <- probability_offtake[["FA"]] * fem_adult_fec[t]
      fem_cull_death[t] <- probability_offtake[["FC"]] * fem_cull_fec[t]

      mal_birth_death[t] <- probability_offtake[["MB"]] * mal_birth_fec[t]
      mal_juv_death[t] <- probability_offtake[["MJ"]] * mal_juv_fec[t]
      mal_sub_death[t] <- probability_offtake[["MS"]] * mal_sub_fec[t]
      mal_adult_death[t] <- probability_offtake[["MA"]] * mal_adult_fec[t]
      mal_cull_death[t] <- probability_offtake[["MC"]] * mal_cull_fec[t]

      # Transition
      fem_juv_grow[t] <- fem_birth[t] + (1 - probability_growth[["FJ"]]) * fem_juv[t]
      fem_sub_grow[t] <- probability_growth[["FJ"]] * fem_juv[t] + (1 - probability_growth[["FS"]]) * fem_sub[t]
      fem_adult_grow[t] <- probability_growth[["FS"]] * fem_sub[t] + (1 - probability_growth[["FA"]]) * fem_adult[t]
      fem_cull_grow[t] <- probability_growth[["FA"]] * fem_adult[t]

      mal_juv_grow[t] <- mal_birth[t] + (1 - probability_growth[["MJ"]]) * mal_juv[t]
      mal_sub_grow[t] <- probability_growth[["MJ"]] * mal_juv[t] + (1 - probability_growth[["MS"]]) * mal_sub[t]
      mal_adult_grow[t] <- probability_growth[["MS"]] * mal_sub[t] + (1 - probability_growth[["MA"]]) * mal_adult[t]
      mal_cull_grow[t] <- probability_growth[["MA"]] * mal_adult[t]
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

  return(
    list(
      cohort_stock_start = size,
      cohort_stock_end_projected = size_end,
      cohort_stock_end_exact_simulated = size_end_exact,
      cohort_stock_average = size_avg,
      cohort_offtake_heads = offtake
    )
  )
}

#' Summarise Offtake and Stock Variation for a Steady-State Year
#'
#' Computes annual offtake quantities and rates, as well as stock variation and their combined values
#' across 6 sex-age classes based on steady-state population projections. The steady state is defined as a constant
#' sex–age cohort structure over time, with population size potentially growing or declining at a constant rate.
#'
#' @param cohort_stock_start Numeric vector of length 6. Population size in each of the 6 sex–age cohorts at the start of the year (# heads). (cohorts= \code{FJ}, \code{FS}, \code{FA}, \code{MJ}, \code{MS}, \code{MA})
#' @param cohort_stock_end_projected Numeric vector of length 6. Population size in each of the 6 sex–age cohorts at the end of the year, projected using the steady-state growth rate (# heads). (cohorts= \code{FJ}, \code{FS}, \code{FA}, \code{MJ}, \code{MS}, \code{MA})
#' @param cohort_stock_average Numeric vector of length 6. Average population size in each of the 6 sex–age cohorts over the year (# heads). Estimated from cohort_stock_start and cohort_stock_end_projected  (cohorts= \code{FJ}, \code{FS}, \code{FA}, \code{MJ}, \code{MS}, \code{MA})
#' @param cohort_offtake_heads Numeric vector of length 10. Total number of animals removed from the herd over the year, by 10 sex–age cohorts (heads/year)
#' (cohorts= \code{FB}: Female Birth, \code{FJ}: Female Juvenile, \code{FS}: Female Sub-adult, \code{FA}: Female Adult, \code{FC}: Female Culling, \code{MB}: Male Birth, \code{MJ}: Male Juvenile, \code{MS}: Male Sub-adult, \code{MA}: Male Adult, \code{MC}: Male Culling)
#' @param simulation_duration Numeric. Length of the assessment period (days)
#'
#' @return A named list with:
#' \describe{
#'   \item{stock_variation_heads}{Numeric vector of length 6. Change in population size between the start and end of the year for each sex–age cohort (# heads) (cohorts= \code{FJ}, \code{FS}, \code{FA}, \code{MJ}, \code{MS}, \code{MA}).}
#'   \item{offtake_heads}{Numeric vector of length 6. Total number of animals removed via offtake over the year, aggregated to 6 sex–age cohorts (heads/year) (cohorts= \code{FJ}, \code{FS}, \code{FA}, \code{MJ}, \code{MS}, \code{MA})}
#'   \item{offtake_heads_assessment}{Numeric vector of length 6. Total number of animals removed via offtake over the assessment period, aggregated to 6 sex–age cohorts (heads/assessment period) (cohorts= \code{FJ}, \code{FS}, \code{FA}, \code{MJ}, \code{MS}, \code{MA})}
#'   \item{offtake_rate_to_stock_start}{Numeric vector of length 6. Offtake rate relative to the starting population size in each sex–age cohort (fraction) (cohorts= \code{FJ}, \code{FS}, \code{FA}, \code{MJ}, \code{MS}, \code{MA}) }
#'   \item{offtake_rate_to_stock_average}{Numeric vector of length 6. Offtake rate relative to the average population size in each sex–age cohort (fraction) (cohorts= \code{FJ}, \code{FS}, \code{FA}, \code{MJ}, \code{MS}, \code{MA})}
#'   \item{offtake_stock_variation_heads}{Numeric vector of length 6. Sum of offtake and stock variation for each sex–age cohort over the year (# heads) (cohorts= \code{FJ}, \code{FS}, \code{FA}, \code{MJ}, \code{MS}, \code{MA})}
#'   \item{offtake_stock_plus_variation_rate_to_stock_start}{Numeric vector of length 6. Offtake plus stock-variation rate relative to starting population size (fraction) (cohorts= \code{FJ}, \code{FS}, \code{FA}, \code{MJ}, \code{MS}, \code{MA})}
#'   \item{offtake_stock_plus_variation_rate_to_stock_average}{Numeric vector of length 6.  Offtake plus stock-variation rate relative to average population size (fraction) (cohorts= \code{FJ}, \code{FS}, \code{FA}, \code{MJ}, \code{MS}, \code{MA})}
#' }
#'
#' @export
calc_summary_offtake <- function(
    cohort_stock_start,
    cohort_stock_end_projected,
    cohort_stock_average,
    cohort_offtake_heads,
    simulation_duration
) {
  validate_offtake_summary_inputs(
    cohort_stock_start,
    cohort_stock_end_projected,
    cohort_stock_average,
    cohort_offtake_heads,
    simulation_duration
  )

  # Aggregate offtake: collapse 10 sex-age classes into 6
  offtake_heads <- c(
    FJ = sum(cohort_offtake_heads[c("FB", "FJ")]),
    FS = cohort_offtake_heads["FS"],
    FA = sum(cohort_offtake_heads[c("FA", "FC")]),
    MJ = sum(cohort_offtake_heads[c("MB", "MJ")]),
    MS = cohort_offtake_heads["MS"],
    MA = sum(cohort_offtake_heads[c("MA", "MC")])
  )

  # Offtake rates
  offtake_rate_to_stock_start <- offtake_heads / cohort_stock_start
  offtake_rate_to_stock_average <- offtake_heads / cohort_stock_average

  # Calculate stock variation for each sex-age class from numbers at
  # beginning and end of a steady-state year
  stock_variation_heads <- cohort_stock_end_projected - cohort_stock_start

  # Calculate sum of offtake and stock variation (sv),
  # then calculate the rate for start and average cohort sizes:
  # Offtake + stock variation (SV), and corresponding rates
  offtake_stock_variation_heads <- stock_variation_heads + offtake_heads
  offtake_stock_plus_variation_rate_to_stock_start <- offtake_stock_variation_heads / cohort_stock_start
  offtake_stock_plus_variation_rate_to_stock_average <- offtake_stock_variation_heads / cohort_stock_average

  # Calculate the scaled offtake number by simulation_duration
  # If simulation_duration = 365 this variable will be equal to offtake_number

  offtake_heads_assessment <- offtake_heads / 365 * simulation_duration

  # Assign names
  names(stock_variation_heads) <- names(offtake_heads) <- names(offtake_heads_assessment) <-
    names(offtake_rate_to_stock_start) <- names(offtake_rate_to_stock_average) <-
    names(offtake_stock_variation_heads) <- names(offtake_stock_plus_variation_rate_to_stock_start) <-
    names(offtake_stock_plus_variation_rate_to_stock_average) <- c("FJ", "FS", "FA", "MJ", "MS", "MA")

  return(
    list(
      stock_variation_heads = stock_variation_heads,
      offtake_heads = offtake_heads,
      offtake_heads_assessment = offtake_heads_assessment,
      offtake_rate_to_stock_start = offtake_rate_to_stock_start,
      offtake_rate_to_stock_average = offtake_rate_to_stock_average,
      offtake_stock_variation_heads = offtake_stock_variation_heads,
      offtake_stock_plus_variation_rate_to_stock_start = offtake_stock_plus_variation_rate_to_stock_start,
      offtake_stock_plus_variation_rate_to_stock_average = offtake_stock_plus_variation_rate_to_stock_average
    )
  )
}
