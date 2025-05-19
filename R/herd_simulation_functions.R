
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
  list(
    female_fecundity = prolif_rate * fem_birth_ratio * (part_rate / 365),
    male_fecundity = prolif_rate * (1 - fem_birth_ratio) * (part_rate / 365)
  )
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
#'   \item{hdea}{Instantaneous mortality hazard rate for 6 sex-age classes.}
#'   \item{hoff}{Instantaneous offtake hazard rate for 6 sex-age classes.}
#'   \item{pdea}{Daily death probability for 10 cohorts.}
#'   \item{poff}{Daily offtake probability for 10 cohorts.}
#'   \item{psur}{Daily survival probability for 10 cohorts.}
#'   \item{g}{Probability of growing into the next age class for 10 cohorts.}
#' }
#'
#' @export
compute_transition_probabilities <- function(duration, offtake_rate, death_rate) {
  # --- Part 1: Compute values for 6 core sex-age classes ---

  # Instantaneous mortality hazard rate (hdea), adjusted by duration
  hdea <- ifelse(
    duration < 365, -log(1 - death_rate) / duration, -log(1 - death_rate) / 365
  )

  # Adjusted duration: keep original if <365, otherwise cap at 365
  duration_max365 <- ifelse(duration < 365, duration, 365)

  # Initialize offtake hazard rate (hoff)
  hoff <- NA

  # Estimate hoff using Newton-Raphson method for each class
  for (class in 1:6) {
    hdea_adj <- hdea[class] * duration_max365[class]

    for (t in 1:15) {
      class_hoff <- ifelse(
        t == 1, offtake_rate[class], class_hoff - (class_f / class_deriv)
      )

      class_f <- (class_hoff / (hdea_adj + class_hoff)) *
        (1 - exp(-hdea_adj - class_hoff)) - offtake_rate[class]

      class_deriv <- (
        hdea_adj * (1 - exp(-hdea_adj - class_hoff)) +
          class_hoff * (hdea_adj + class_hoff) * exp(-hdea_adj - class_hoff)
      ) / (hdea_adj + class_hoff)^2
    }

    hoff[class] <- class_hoff / duration_max365[class]
  }

  # --- Part 2: Extend to 10 cohorts (6 sex-age classes + 2 birth + 2 culling) ---

  # Extend hdea and hoff for 10 cohorts: copy juvenile/adult rates to birth/culling cohorts
  hdea_all <- hdea[c(1, 1:3, 3, 4, 4:6, 6)]
  hoff_all <- hoff[c(1, 1:3, 3, 4, 4:6, 6)]

  # Extend duration: assign 1 day to birth/culling cohorts; subtract 1 day where split
  duration_all <- c(1, duration[1] - 1, duration[c(2:3)], 1, 1,
                    duration[4] - 1, duration[c(5:6)], 1)

  # Daily probability of death (pdea)
  pdea <- (hdea_all / (hdea_all + hoff_all)) * (1 - exp(-(hdea_all + hoff_all)))
  pdea[c(5, 10)] <- 0  # Culling cohorts cannot die again

  # Daily probability of offtake (poff)
  poff <- (hoff_all / (hdea_all + hoff_all)) * (1 - exp(-(hdea_all + hoff_all)))
  poff[c(5, 10)] <- 1  # Culling cohorts are entirely offtaken

  # Daily survival probability (psur)
  psur <- 1 - pdea - poff

  # Probability of growing into the next class (g)
  g <- (psur^(duration_all - 1) - psur^duration_all) / (1 - psur^duration_all)

  # --- Prepare and return results ---

  names(pdea) <- names(poff) <- names(psur) <- names(g) <-
    c("FB", "FJ", "FS", "FA", "FC", "MB", "MJ", "MS", "MA", "MC")
  names(hdea) <- names(hoff) <- c("FJ", "FS", "FA", "MJ", "MS", "MA")

  list(
    hdea = hdea,
    hoff = hoff,
    pdea = pdea,
    poff = poff,
    psur = psur,
    g = g
  )
}

#' Simulate Steady-State Population Structure
#'
#' Simulates population dynamics over time until a steady-state is reached. Tracks age-class structure and
#' population growth based on survival, offtake, and fecundity parameters.
#'
#' @param initial_structure Numeric vector of length 6. Initial number of individuals in each of the 6 sex-age classes.
#' @param max_years Integer. Maximum number of years to simulate.
#' @param min_lambda_change Numeric. Threshold for minimal change in class-specific growth rates to reach steady state.
#' @param female_fecundity Numeric. Daily number of female births per adult female.
#' @param male_fecundity Numeric. Daily number of male births per adult female.
#' @param pdea Numeric vector of length 10. Daily death probabilities for 10 cohorts.
#' @param poff Numeric vector of length 10. Daily offtake probabilities for 10 cohorts.
#' @param g Numeric vector of length 10. Daily probability of transition to the next class for 10 cohorts.
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
    female_fecundity, male_fecundity, pdea, poff, g
    ) {

  # Initialize population vectors
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
      fem_birth_fec <- initial_structure["FA"] * female_fecundity
      fem_juv_fec <- initial_structure["FJ"]
      fem_sub_fec <- initial_structure["FS"]
      fem_adult_fec <- initial_structure["FA"]
      fem_cull_fec <- 0

      mal_birth_fec <- initial_structure["FA"] * male_fecundity
      mal_juv_fec <- initial_structure["MJ"]
      mal_sub_fec <- initial_structure["MS"]
      mal_adult_fec <- initial_structure["MA"]
      mal_cull_fec <- 0
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
      mal_adult_fec[t] <- mal_adult_grow[t - 1]
      mal_cull_fec[t] <- 0
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
        mal_adult_fec[t] / mal_adult_fec[t - 1] - mal_adult_fec[t - 1] / mal_adult_fec[t - 2]
      )
    }

    # Exit early if all 6 lambda changes are below threshold
    if (all(lambda_change < min_lambda_change)) break

    # Apply death and offtake rates to each class
    fem_birth[t] <- fem_birth_fec[t] - pdea[1] * fem_birth_fec[t] - poff[1] * fem_birth_fec[t]
    fem_juv[t] <- fem_juv_fec[t] - pdea[2] * fem_juv_fec[t] - poff[2] * fem_juv_fec[t]
    fem_sub[t] <- fem_sub_fec[t] - pdea[3] * fem_sub_fec[t] - poff[3] * fem_sub_fec[t]
    fem_adult[t] <- fem_adult_fec[t] - pdea[4] * fem_adult_fec[t] - poff[4] * fem_adult_fec[t]
    fem_cull[t] <- fem_cull_fec[t] - pdea[5] * fem_cull_fec[t] - poff[5] * fem_cull_fec[t]
    mal_birth[t] <- mal_birth_fec[t] - pdea[6] * mal_birth_fec[t] - poff[6] * mal_birth_fec[t]
    mal_juv[t] <- mal_juv_fec[t] - pdea[7] * mal_juv_fec[t] - poff[7] * mal_juv_fec[t]
    mal_sub[t] <- mal_sub_fec[t] - pdea[8] * mal_sub_fec[t] - poff[8] * mal_sub_fec[t]
    mal_adult[t] <- mal_adult_fec[t] - pdea[9] * mal_adult_fec[t] - poff[9] * mal_adult_fec[t]
    mal_cull[t] <- mal_cull_fec[t] - pdea[10] * mal_cull_fec[t] - poff[10] * mal_cull_fec[t]

    # Apply transition probabilities (growth to next class)
    fem_juv_grow[t] <- fem_birth[t] + (1 - g[2]) * fem_juv[t]
    fem_sub_grow[t] <- g[2] * fem_juv[t] + (1 - g[3]) * fem_sub[t]
    fem_adult_grow[t] <- g[3] * fem_sub[t] + (1 - g[4]) * fem_adult[t]
    fem_cull_grow[t] <- g[4] * fem_adult[t]

    mal_juv_grow[t] <- mal_birth[t] + (1 - g[7]) * mal_juv[t]
    mal_sub_grow[t] <- g[7] * mal_juv[t] + (1 - g[8]) * mal_sub[t]
    mal_adult_grow[t] <- g[8] * mal_sub[t] + (1 - g[9]) * mal_adult[t]
    mal_cull_grow[t] <- g[9] * mal_adult[t]
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
  list(
    days_steady = days_steady,
    structure = structure,
    share = share,
    growth_rate_pop = growth_rate_pop
  )
}

#' Project One Year of Steady-State Population Dynamics
#'
#' Simulates one year of population dynamics under steady-state assumptions using demographic parameters
#' and returns population size statistics and offtake results.
#'
#' @param size_total Numeric. Total population size at the start of the year.
#' @param female_fecundity Numeric. Daily female births per adult female.
#' @param male_fecundity Numeric. Daily male births per adult female.
#' @param pdea Numeric vector of length 10. Daily death probabilities.
#' @param poff Numeric vector of length 10. Daily offtake probabilities.
#' @param g Numeric vector of length 10. Transition probabilities to next age class.
#' @param growth_rate_pop Numeric. Annual population growth rate.
#' @param structure Numeric vector of length 8. Final population share in 8 classes.
#' @param share Numeric vector of length 6. Final population share in 6 grouped classes.
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
    size_total, female_fecundity, male_fecundity, pdea, poff, g,
    growth_rate_pop, structure, share
    ) {

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
      mal_adult_fec <- xini[8]
      mal_cull_fec <- 0
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
      mal_adult_fec[t] <- mal_adult_grow[t - 1]
      mal_cull_fec[t] <- 0
      mal_birth_fec[t] <- fem_adult_fec[t] * male_fecundity
    }

    if (t <= 365) {
      # Apply death rates
      fem_birth[t] <- pdea[1] * fem_birth_fec[t]
      fem_juv[t] <- pdea[2] * fem_juv_fec[t]
      fem_sub[t] <- pdea[3] * fem_sub_fec[t]
      fem_adult[t] <- pdea[4] * fem_adult_fec[t]
      fem_cull[t] <- pdea[5] * fem_cull_fec[t]
      mal_birth[t] <- pdea[6] * mal_birth_fec[t]
      mal_juv[t] <- pdea[7] * mal_juv_fec[t]
      mal_sub[t] <- pdea[8] * mal_sub_fec[t]
      mal_adult[t] <- pdea[9] * mal_adult_fec[t]
      mal_cull[t] <- pdea[10] * mal_cull_fec[t]

      # Apply offtake rates
      fem_birth_death[t] <- poff[1] * fem_birth_fec[t]
      fem_juv_death[t] <- poff[2] * fem_juv_fec[t]
      fem_sub_death[t] <- poff[3] * fem_sub_fec[t]
      fem_adult_death[t] <- poff[4] * fem_adult_fec[t]
      fem_cull_death[t] <- poff[5] * fem_cull_fec[t]
      mal_birth_death[t] <- poff[6] * mal_birth_fec[t]
      mal_juv_death[t] <- poff[7] * mal_juv_fec[t]
      mal_sub_death[t] <- poff[8] * mal_sub_fec[t]
      mal_adult_death[t] <- poff[9] * mal_adult_fec[t]
      mal_cull_death[t] <- poff[10] * mal_cull_fec[t]

      # Compute survivors after deaths and offtakes
      fem_birth[t] <- fem_birth_fec[t] - fem_birth[t] - fem_birth_death[t]
      fem_juv[t] <- fem_juv_fec[t] - fem_juv[t] - fem_juv_death[t]
      fem_sub[t] <- fem_sub_fec[t] - fem_sub[t] - fem_sub_death[t]
      fem_adult[t] <- fem_adult_fec[t] - fem_adult[t] - fem_adult_death[t]
      fem_cull[t] <- fem_cull_fec[t] - fem_cull[t] - fem_cull_death[t]
      mal_birth[t] <- mal_birth_fec[t] - mal_birth[t] - mal_birth_death[t]
      mal_juv[t] <- mal_juv_fec[t] - mal_juv[t] - mal_juv_death[t]
      mal_sub[t] <- mal_sub_fec[t] - mal_sub[t] - mal_sub_death[t]
      mal_adult[t] <- mal_adult_fec[t] - mal_adult[t] - mal_adult_death[t]
      mal_cull[t] <- mal_cull_fec[t] - mal_cull[t] - mal_cull_death[t]

      # Transition to next age classes
      fem_juv_grow[t] <- fem_birth[t] + (1 - g[2]) * fem_juv[t]
      fem_sub_grow[t] <- g[2] * fem_juv[t] + (1 - g[3]) * fem_sub[t]
      fem_adult_grow[t] <- g[3] * fem_sub[t] + (1 - g[4]) * fem_adult[t]
      fem_cull_grow[t] <- g[4] * fem_adult[t]

      mal_juv_grow[t] <- mal_birth[t] + (1 - g[7]) * mal_juv[t]
      mal_sub_grow[t] <- g[7] * mal_juv[t] + (1 - g[8]) * mal_sub[t]
      mal_adult_grow[t] <- g[8] * mal_sub[t] + (1 - g[9]) * mal_adult[t]
      mal_cull_grow[t] <- g[9] * mal_adult[t]
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
  list(
    size = size,
    size_end = size_end,
    size_end_exact = size_end_exact,
    size_avg = size_avg,
    offtake = offtake
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
  list(
    stock_variation = stock_variation,
    offtake_number = offtake_number,
    offtake_share = offtake_share,
    offtake_share_avg = offtake_share_avg,
    offtake_sv_number = offtake_sv_number,
    offtake_sv_share = offtake_sv_share,
    offtake_sv_share_avg = offtake_sv_share_avg
  )
}

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
    adult_female_weight = NA_real_, adult_male_weight = NA_real_,
    birth_weight = NA_real_, slaughter_weight_female = NA_real_,
    slaughter_weight_male = NA_real_, weaning_weight = NA_real_,
    age_first_calving = NA_real_, animal_age = NA_real_
    ) {

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

  list(
    initial_weight = initial_weight,
    potential_final_weight = potential_final_weight,
    slaughter_weight = slaughter_weight
  )
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
calc_avg_weights <- function(
    initial_weight, potential_final_weight, slaughter_weight, offtake_rate
    ) {
  # Weighted final weight: survivors reach potential_final_weight, offtaken animals go to slaughter
  final_weight <- potential_final_weight * (1 - offtake_rate) + slaughter_weight * offtake_rate

  # Average weight across the stage
  average_weight <- (initial_weight + final_weight) / 2

  list(
    average_weight = average_weight,
    final_weight = final_weight
  )
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
  (potential_final_weight - initial_weight) / duration
}
