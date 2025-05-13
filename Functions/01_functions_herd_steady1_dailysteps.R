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
  
  output <- list(hdea, hoff, pdea, poff, psur, g)
  names(output) <- c("hdea", "hoff", "pdea", "poff", "psur", "g")
  
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
    x_start, max_years, min_lambda_change,
    female_fecundity, male_fecundity, pdea, poff, g) {
  
  # Initialize output vectors
  Fem_B__x_dy <- Fem_J__x_dy <- Fem_S__x_dy <- Fem_A__x_dy <- Fem_C__x_dy <- NULL
  Mal_B__x_dy <- Mal_J__x_dy <- Mal_S__x_dy <- Mal_A__x_dy <- Mal_C__x_dy <- NULL
  
  Fem_J__x_g <- Fem_S__x_g <- Fem_A__x_g <- Fem_C__x_g <- NULL
  Mal_J__x_g <- Mal_S__x_g <- Mal_A__x_g <- Mal_C__x_g <- NULL
  
  lambda_change <- rep(1, 6)
  
  # Run simulation for up to max_years
  for (t in 1:(max_years * 365 + 1)) {
    if (t == 1) {
      # Time step 1: initialize from starting vector
      ## calculate initial number of individuals taking into account
      ## the daily number of born females and males (female_fecundity/male_fecundity)
      Fem_B__x_fec <- x_start[3] * female_fecundity
      Fem_J__x_fec <- x_start[1]
      Fem_S__x_fec <- x_start[2]
      Fem_A__x_fec <- x_start[3]
      Fem_C__x_fec <- 0
      Mal_B__x_fec <- x_start[3] * male_fecundity
      Mal_J__x_fec <- x_start[4]
      Mal_S__x_fec <- x_start[5]
      Mal_A__x_fec <- x_start[6]
      Mal_C__x_fec <- 0
    } else {
      # Time step >1: propagate individuals from previous day
      ## calculate number of individuals taking into account both female_fecundity/male_fecundity and
      ## the number of individuals that survived the previous month and how they moved in the age classes
      Fem_J__x_fec[t] <- Fem_J__x_g[t - 1]
      Fem_S__x_fec[t] <- Fem_S__x_g[t - 1]
      Fem_A__x_fec[t] <- Fem_A__x_g[t - 1]
      Fem_C__x_fec[t] <- 0
      Fem_B__x_fec[t] <- Fem_A__x_fec[t] * female_fecundity
      Mal_J__x_fec[t] <- Mal_J__x_g[t - 1]
      Mal_S__x_fec[t] <- Mal_S__x_g[t - 1]
      Mal_A__x_fec[t] <- Mal_A__x_g[t - 1]
      Mal_C__x_fec[t] <- 0
      Mal_B__x_fec[t] <- Fem_A__x_fec[t] * male_fecundity
    }
    
    # Compute class-specific growth rate change (lambda)
    if (t > 2) {
      lambda_change <- c(
        Fem_J__x_fec[t] / Fem_J__x_fec[t - 1] - Fem_J__x_fec[t - 1] / Fem_J__x_fec[t - 2],
        Fem_S__x_fec[t] / Fem_S__x_fec[t - 1] - Fem_S__x_fec[t - 1] / Fem_S__x_fec[t - 2],
        Fem_A__x_fec[t] / Fem_A__x_fec[t - 1] - Fem_A__x_fec[t - 1] / Fem_A__x_fec[t - 2],
        Mal_J__x_fec[t] / Mal_J__x_fec[t - 1] - Mal_J__x_fec[t - 1] / Mal_J__x_fec[t - 2],
        Mal_S__x_fec[t] / Mal_S__x_fec[t - 1] - Mal_S__x_fec[t - 1] / Mal_S__x_fec[t - 2],
        Mal_A__x_fec[t] / Mal_A__x_fec[t - 1] - Mal_A__x_fec[t - 1] / Mal_A__x_fec[t - 2]
      )
    }
    
    # Exit early if all 6 lambda changes are below threshold
    if (all(lambda_change < min_lambda_change)) break
    
    # Apply death and offtake rates to each class
    Fem_B__x_dy[t] <- Fem_B__x_fec[t] - pdea[1] * Fem_B__x_fec[t] - poff[1] * Fem_B__x_fec[t]
    Fem_J__x_dy[t] <- Fem_J__x_fec[t] - pdea[2] * Fem_J__x_fec[t] - poff[2] * Fem_J__x_fec[t]
    Fem_S__x_dy[t] <- Fem_S__x_fec[t] - pdea[3] * Fem_S__x_fec[t] - poff[3] * Fem_S__x_fec[t]
    Fem_A__x_dy[t] <- Fem_A__x_fec[t] - pdea[4] * Fem_A__x_fec[t] - poff[4] * Fem_A__x_fec[t]
    Fem_C__x_dy[t] <- Fem_C__x_fec[t] - pdea[5] * Fem_C__x_fec[t] - poff[5] * Fem_C__x_fec[t]
    Mal_B__x_dy[t] <- Mal_B__x_fec[t] - pdea[6] * Mal_B__x_fec[t] - poff[6] * Mal_B__x_fec[t]
    Mal_J__x_dy[t] <- Mal_J__x_fec[t] - pdea[7] * Mal_J__x_fec[t] - poff[7] * Mal_J__x_fec[t]
    Mal_S__x_dy[t] <- Mal_S__x_fec[t] - pdea[8] * Mal_S__x_fec[t] - poff[8] * Mal_S__x_fec[t]
    Mal_A__x_dy[t] <- Mal_A__x_fec[t] - pdea[9] * Mal_A__x_fec[t] - poff[9] * Mal_A__x_fec[t]
    Mal_C__x_dy[t] <- Mal_C__x_fec[t] - pdea[10] * Mal_C__x_fec[t] - poff[10] * Mal_C__x_fec[t]
    
    # Apply transition probabilities (growth to next class)
    Fem_J__x_g[t] <- Fem_B__x_dy[t] + (1 - g[2]) * Fem_J__x_dy[t]
    Fem_S__x_g[t] <- g[2] * Fem_J__x_dy[t] + (1 - g[3]) * Fem_S__x_dy[t]
    Fem_A__x_g[t] <- g[3] * Fem_S__x_dy[t] + (1 - g[4]) * Fem_A__x_dy[t]
    Fem_C__x_g[t] <- g[4] * Fem_A__x_dy[t]
    
    Mal_J__x_g[t] <- Mal_B__x_dy[t] + (1 - g[7]) * Mal_J__x_dy[t]
    Mal_S__x_g[t] <- g[7] * Mal_J__x_dy[t] + (1 - g[8]) * Mal_S__x_dy[t]
    Mal_A__x_g[t] <- g[8] * Mal_S__x_dy[t] + (1 - g[9]) * Mal_A__x_dy[t]
    Mal_C__x_g[t] <- g[9] * Mal_A__x_dy[t]
  }
  
  # Final iteration count
  days_steady <- t
  
  # Extract population state at steady-state
  xend <- c(
    Fem_B__x_fec[days_steady], Fem_J__x_fec[days_steady],
    Fem_S__x_fec[days_steady], Fem_A__x_fec[days_steady],
    Mal_B__x_fec[days_steady], Mal_J__x_fec[days_steady],
    Mal_S__x_fec[days_steady], Mal_A__x_fec[days_steady]
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
  growth_rate_pop <- (Fem_J__x_fec[days_steady] / Fem_J__x_fec[days_steady - 1])^365 - 1
  
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
#' @param pdea Numeric vector of length 10. Daily death probabilities (from `compute_transition_probabilities()`).
#' @param poff Numeric vector of length 10. Daily offtake probabilities (from `compute_transition_probabilities()`).
#' @param g Numeric vector of length 10. Transition probabilities to next age class (from `compute_transition_probabilities()`).
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
    size_total, female_fecundity, male_fecundity, pdea, poff, g,
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
  Fem_B__d <- Fem_J__d <- Fem_S__d <- Fem_A__d <- Fem_C__d <- NULL
  Mal_B__d <- Mal_J__d <- Mal_S__d <- Mal_A__d <- Mal_C__d <- NULL
  
  Fem_B__y <- Fem_J__y <- Fem_S__y <- Fem_A__y <- Fem_C__y <- NULL
  Mal_B__y <- Mal_J__y <- Mal_S__y <- Mal_A__y <- Mal_C__y <- NULL
  
  Fem_B__x_dy <- Fem_J__x_dy <- Fem_S__x_dy <- Fem_A__x_dy <- Fem_C__x_dy <- NULL
  Mal_B__x_dy <- Mal_J__x_dy <- Mal_S__x_dy <- Mal_A__x_dy <- Mal_C__x_dy <- NULL
  
  Fem_J__x_g <- Fem_S__x_g <- Fem_A__x_g <- Fem_C__x_g <- NULL
  Mal_J__x_g <- Mal_S__x_g <- Mal_A__x_g <- Mal_C__x_g <- NULL
  
  # Simulate daily dynamics over 366 days (leap year assumption)
  for (t in 1:366) {
    if (t == 1) {
      # Initialize class sizes using xini and fecundity
      Fem_J__x_fec <- xini[2]
      Fem_S__x_fec <- xini[3]
      Fem_A__x_fec <- xini[4]
      Fem_C__x_fec <- 0
      Fem_B__x_fec <- Fem_A__x_fec * female_fecundity
      
      Mal_J__x_fec <- xini[6]
      Mal_S__x_fec <- xini[7]
      Mal_A__x_fec <- xini[8]
      Mal_C__x_fec <- 0
      Mal_B__x_fec <- Fem_A__x_fec * male_fecundity
    } else {
      # Update fecundity stage from previous day's transitions
      Fem_J__x_fec[t] <- Fem_J__x_g[t - 1]
      Fem_S__x_fec[t] <- Fem_S__x_g[t - 1]
      Fem_A__x_fec[t] <- Fem_A__x_g[t - 1]
      Fem_C__x_fec[t] <- 0
      Fem_B__x_fec[t] <- Fem_A__x_fec[t] * female_fecundity
      
      Mal_J__x_fec[t] <- Mal_J__x_g[t - 1]
      Mal_S__x_fec[t] <- Mal_S__x_g[t - 1]
      Mal_A__x_fec[t] <- Mal_A__x_g[t - 1]
      Mal_C__x_fec[t] <- 0
      Mal_B__x_fec[t] <- Fem_A__x_fec[t] * male_fecundity
    }
    
    if (t <= 365) {
      # Apply death rates
      Fem_B__d[t] <- pdea[1] * Fem_B__x_fec[t]
      Fem_J__d[t] <- pdea[2] * Fem_J__x_fec[t]
      Fem_S__d[t] <- pdea[3] * Fem_S__x_fec[t]
      Fem_A__d[t] <- pdea[4] * Fem_A__x_fec[t]
      Fem_C__d[t] <- pdea[5] * Fem_C__x_fec[t]
      Mal_B__d[t] <- pdea[6] * Mal_B__x_fec[t]
      Mal_J__d[t] <- pdea[7] * Mal_J__x_fec[t]
      Mal_S__d[t] <- pdea[8] * Mal_S__x_fec[t]
      Mal_A__d[t] <- pdea[9] * Mal_A__x_fec[t]
      Mal_C__d[t] <- pdea[10] * Mal_C__x_fec[t]
      
      # Apply offtake rates
      Fem_B__y[t] <- poff[1] * Fem_B__x_fec[t]
      Fem_J__y[t] <- poff[2] * Fem_J__x_fec[t]
      Fem_S__y[t] <- poff[3] * Fem_S__x_fec[t]
      Fem_A__y[t] <- poff[4] * Fem_A__x_fec[t]
      Fem_C__y[t] <- poff[5] * Fem_C__x_fec[t]
      Mal_B__y[t] <- poff[6] * Mal_B__x_fec[t]
      Mal_J__y[t] <- poff[7] * Mal_J__x_fec[t]
      Mal_S__y[t] <- poff[8] * Mal_S__x_fec[t]
      Mal_A__y[t] <- poff[9] * Mal_A__x_fec[t]
      Mal_C__y[t] <- poff[10] * Mal_C__x_fec[t]
      
      # Compute survivors after deaths and offtakes
      Fem_B__x_dy[t] <- Fem_B__x_fec[t] - Fem_B__d[t] - Fem_B__y[t]
      Fem_J__x_dy[t] <- Fem_J__x_fec[t] - Fem_J__d[t] - Fem_J__y[t]
      Fem_S__x_dy[t] <- Fem_S__x_fec[t] - Fem_S__d[t] - Fem_S__y[t]
      Fem_A__x_dy[t] <- Fem_A__x_fec[t] - Fem_A__d[t] - Fem_A__y[t]
      Fem_C__x_dy[t] <- Fem_C__x_fec[t] - Fem_C__d[t] - Fem_C__y[t]
      Mal_B__x_dy[t] <- Mal_B__x_fec[t] - Mal_B__d[t] - Mal_B__y[t]
      Mal_J__x_dy[t] <- Mal_J__x_fec[t] - Mal_J__d[t] - Mal_J__y[t]
      Mal_S__x_dy[t] <- Mal_S__x_fec[t] - Mal_S__d[t] - Mal_S__y[t]
      Mal_A__x_dy[t] <- Mal_A__x_fec[t] - Mal_A__d[t] - Mal_A__y[t]
      Mal_C__x_dy[t] <- Mal_C__x_fec[t] - Mal_C__d[t] - Mal_C__y[t]
      
      # Transition to next age classes
      Fem_J__x_g[t] <- Fem_B__x_dy[t] + (1 - g[2]) * Fem_J__x_dy[t]
      Fem_S__x_g[t] <- g[2] * Fem_J__x_dy[t] + (1 - g[3]) * Fem_S__x_dy[t]
      Fem_A__x_g[t] <- g[3] * Fem_S__x_dy[t] + (1 - g[4]) * Fem_A__x_dy[t]
      Fem_C__x_g[t] <- g[4] * Fem_A__x_dy[t]
      
      Mal_J__x_g[t] <- Mal_B__x_dy[t] + (1 - g[7]) * Mal_J__x_dy[t]
      Mal_S__x_g[t] <- g[7] * Mal_J__x_dy[t] + (1 - g[8]) * Mal_S__x_dy[t]
      Mal_A__x_g[t] <- g[8] * Mal_S__x_dy[t] + (1 - g[9]) * Mal_A__x_dy[t]
      Mal_C__x_g[t] <- g[9] * Mal_A__x_dy[t]
    }
  }
  
  # Compute offtake and final sizes
  offtake <- c(
    sum(Fem_B__y), sum(Fem_J__y), sum(Fem_S__y), sum(Fem_A__y), sum(Fem_C__x_g),
    sum(Mal_B__y), sum(Mal_J__y), sum(Mal_S__y), sum(Mal_A__y), sum(Mal_C__x_g)
  )
  
  size_end_exact <- c(
    Fem_B__x_fec[366], Fem_J__x_fec[366], Fem_S__x_fec[366], Fem_A__x_fec[366],
    Fem_C__x_fec[366],
    Mal_B__x_fec[366], Mal_J__x_fec[366], Mal_S__x_fec[366], Mal_A__x_fec[366],
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



# ## Function 5: Production Offtake
#
# This function takes the following input parameters to summarize the offtakes in one year of a steady-state population:
# * "size":   results from the function "project_population_size": number of individuals in 6 sex-age classes at the beginning of the steady-state year
# * "size_end":     results from the function "project_population_size": number of individuals in 6 sex-age classes at the end of the steady-state year (derived by growth rate)
# * "size_avg":     results from the function "project_population_size": average number of individuals in 6 sex-age classes during a the steady-state year (derived by growth rate)
# * "offtake":      results from the function "project_population_size": number of individuals taken off from 10 sex-age classes during one year of a steady-state population
#
# This function returns the following objects:
# * "stock_variation":      difference in amount of individuals between start and end of a steady-state year for 6 sex-age classes
# * "offtake_number":       number of individuals taken off from 6 sex-age classes during one year of a steady-state population
# * "offtake_share":        offtake rate of 6 sex-age classes for start cohort sizes
# * "offtake_share_avg":    offtake rate of 6 sex-age classes for average cohort sizes
# * "offtake_sv_number":    sum of offtake and stock variation (sv) for 6 sex-age classes during one year of a steady-state population
# * "offtake_sv_share":     rate of offtake and stock variation (sv) of 6 sex-age classes for start cohort sizes
# * "offtake_sv_share_avg": rate of offtake and stock variation (sv) of 6 sex-age classes for average cohort sizes

summarise_offtake <- function(size, size_end, size_avg, offtake) {
  ## summarize offtakes of 10 sex-age classes for 6 sex-age classes, then calculate offtake rate for start and average cohort sizes
  offtake_number <- c(
    sum(offtake[1:2]), offtake[3], sum(offtake[4:5]),
    sum(offtake[6:7]), offtake[8], sum(offtake[9:10])
  )
  offtake_share <- offtake_number / size
  offtake_share_avg <- offtake_number / size_avg
  
  ## calculate stock variation for each sex-age class from numbers at beginning and end of a steady-state year
  stock_variation <- size_end - size
  
  ## calculate sum of offtake and stock variation (sv), then calculate the rate for start and average cohort sizes
  offtake_sv_number <- stock_variation + offtake_number
  #### error? this does not make sense
  
  offtake_sv_share <- offtake_sv_number / size
  offtake_sv_share_avg <- offtake_sv_number / size_avg
  
  names(stock_variation) <- names(offtake_number) <- names(offtake_share) <- names(offtake_share_avg) <- names(offtake_sv_number) <- names(offtake_sv_share) <- names(offtake_sv_share_avg) <- c("FJ", "FS", "FA", "MJ", "MS", "MA")
  
  ## prepare output
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
