# ## Function 1: Fecundity
#
# This function takes the following input parameters:
# * "part_rate":       parturition rate (= probability of an adult female to give birth)
# * "prolif_rate":     prolificacy rate (= mean number of offspring per parturition)
# * "fem_birth_ratio": female birth ratio (= probability that an offspring is female)
#
# This function returns the following objects:
# * "fecF": monthly number of born females generated per adult female
# * "fecM": monthly number of born males generated per adult female

S1_01_Fecundity <- function(part_rate, prolif_rate, fem_birth_ratio) {
  ## calculate fecF and fecM
  fecF <- prolif_rate * fem_birth_ratio * (part_rate / 365)
  fecM <- prolif_rate * (1 - fem_birth_ratio) * (part_rate / 365)
  
  ## prepare output
  output <- list(fecF, fecM)
  names(output) <- c("fecF", "fecM")
  
  return(output)
}



# ## Function 2: Probabilities
#
# This function takes the following input parameters, which should all be vectors of 6 numbers each, representing the 6 sex-age classes:
# * "duration":      length of 6 sex-age classes in days
# * "offtake_rate":  annual offtake rate of 6 sex-age classes
# * "death_rate":    annual death rate of 6 sex-age classes
#
# This function returns the following objects:
# * "hdea": instantaneous mortality hazard rate for 6 sex-age classes
# * "pdea": daily death probability for 10 sex-age classes
# * "poff": daily offtake probability for 10 sex-age classes
# * "psur": daily survival probability for 10 sex-age classes
# * "g":    probability to grow into the next age class for 10 sex-age classes

S1_02_Probabilities <- function(duration, offtake_rate, death_rate) {
  ## In this first part, all calculations are done for 6 sex-age classes
  
  ## calculate hdea (= instantaneous mortality hazard rate):
  hdea <- ifelse(duration < 365, -log(1 - death_rate) / duration, -log(1 - death_rate) / 365)
  
  ## adjust duration: actual sex-age class duration if below 365 days, otherwise set to 365 days:
  duration_max365 <- ifelse(duration < 365, duration, 365)
  
  ## calculate hoff (instantaneous offtake hazard rate) using Newton-Raphson algorithm:
  hoff <- NA
  ## iterate over each sex-age-class
  for (class in 1:6) {
    hdea_adj <- hdea[class] * duration_max365[class] ## adjusted hdea for entire adjusted age-class duration
    ## perform Newton-Raphson algorithm 15 times
    for (t in 1:15) {
      class_hoff <- ifelse(
        t == 1, offtake_rate[class], class_hoff - (class_f / class_deriv)
      )
      class_f <- (class_hoff / (hdea_adj + class_hoff)) * (1 - exp(-hdea_adj - class_hoff)) - offtake_rate[class]
      class_deriv <- (hdea_adj * (1 - exp(-hdea_adj - class_hoff)) + class_hoff * (hdea_adj + class_hoff) * exp(-hdea_adj - class_hoff)) / (hdea_adj + class_hoff)^2
    }
    hoff[class] <- class_hoff / duration_max365[class]
  }
  
  ## In this second part, all calculations are done for the 10 cohorts, i.e. the previous 6 sex-age classes + 2 birth and 2 culling cohorts
  
  ## adjust hdea: birth cohorts have same hoff as juveniles; culling cohorts have same as adults
  hdea_all <- hdea[c(1, 1:3, 3, 4, 4:6, 6)]
  
  ## adjust hoff: birth cohorts have same hoff as juveniles; culling cohorts have same as adults
  hoff_all <- hoff[c(1, 1:3, 3, 4, 4:6, 6)]
  
  ## adjust duration: birth cohorts "obtain" 1 day from juveniles, culling cohorts are set to 1 day
  duration_all <- c(1, duration[1] - 1, duration[c(2:3)], 1, 1, duration[4] - 1, duration[c(5:6)], 1)
  
  ## calculate pdea
  pdea <- (hdea_all / (hdea_all + hoff_all)) * (1 - exp(-(hdea_all + hoff_all)))
  pdea[c(5, 10)] <- 0 ## pdea of C cohorts must be zero
  
  ## calculate poff
  poff <- (hoff_all / (hdea_all + hoff_all)) * (1 - exp(-(hdea_all + hoff_all)))
  poff[c(5, 10)] <- 1 ## poff of C cohorts must be 1
  
  ## calculate psur
  psur <- 1 - pdea - poff
  
  ## calculate g
  g <- (psur^(duration_all - 1) - psur^duration_all) / (1 - psur^duration_all)
  
  ## prepare output
  names(pdea) <- names(poff) <- names(psur) <- names(g) <- c("FB", "FJ", "FS", "FA", "FC", "MB", "MJ", "MS", "MA", "MC")
  names(hdea) <- names(hoff) <- c("FJ", "FS", "FA", "MJ", "MS", "MA")
  output <- list(hdea, hoff, pdea, poff, psur, g)
  names(output) <- c("hdea", "hoff", "pdea", "poff", "psur", "g")
  
  return(output)
}



# ## Function 3: Population Structure
#
# This function takes the following input parameters:
# * "x_start":            random initial number of individuals for 6 sex-age classes
# * "max_years":          maximum number of years simulated
# * "min_lambda_change":  minimum change in lambda that must be reached in all 6 sex-age classes at the same time to assume a steady state
# * "fecF":               results from the function "S1_01_Fecundity": daily number of born females generated per adult female
# * "fecM":               results from the function "S1_01_Fecundity": daily number of born males generated per adult female
# * "pdea":               results from the function "S1_02_Probabilities": daily death probability for 10 sex-age classes (vector)
# * "poff":               results from the function "S1_02_Probabilities": daily offtake probability for 10 sex-age classes (vector)
# * "g":                  results from the function "S1_02_Probabilities": probability to grow into the next age class for 10 sex-age classes (vector)
#
# This function returns the following objects:
# * "days_steady":        days at which a steady state was reached
# * "structure":          shares of 8 sex-age classes in a steady-state population
# * "share":   shares of 6 sex-age classes in a steady-state population
# * "growth_rate_pop":        the increase in number of individuals in each sex-age class over one year in a steady-state population

S1_03_PopStructure <- function(
    x_start, max_years, min_lambda_change, fecF, fecM, pdea, poff, g) {
  ## initialize empty vectors to be populated in the loop
  Fem_B__x_dy <- Fem_J__x_dy <- Fem_S__x_dy <- Fem_A__x_dy <- Fem_C__x_dy <- NULL
  Mal_B__x_dy <- Mal_J__x_dy <- Mal_S__x_dy <- Mal_A__x_dy <- Mal_C__x_dy <- NULL
  
  Fem_J__x_g <- Fem_S__x_g <- Fem_A__x_g <- Fem_C__x_g <- NULL
  Mal_J__x_g <- Mal_S__x_g <- Mal_A__x_g <- Mal_C__x_g <- NULL
  
  lambda_change <- rep(1, 6)
  
  ## iterate over max_years years
  for (t in 1:(max_years * 365 + 1)) {
    if (t == 1) {
      ## calculate initial number of individuals taking into account
      ## the daily number of born females and males (fecF/fecM)
      Fem_B__x_fec <- x_start[3] * fecF
      Fem_J__x_fec <- x_start[1]
      Fem_S__x_fec <- x_start[2]
      Fem_A__x_fec <- x_start[3]
      Fem_C__x_fec <- 0
      Mal_B__x_fec <- x_start[3] * fecM
      Mal_J__x_fec <- x_start[4]
      Mal_S__x_fec <- x_start[5]
      Mal_A__x_fec <- x_start[6]
      Mal_C__x_fec <- 0
    } else if (t > 1) {
      ## calculate number of individuals taking into account both fecF/fecM and
      ## the number of individuals that survived the previous month and how they moved in the age classes
      Fem_J__x_fec[t] <- Fem_J__x_g[t - 1]
      Fem_S__x_fec[t] <- Fem_S__x_g[t - 1]
      Fem_A__x_fec[t] <- Fem_A__x_g[t - 1]
      Fem_C__x_fec[t] <- 0
      Fem_B__x_fec[t] <- Fem_A__x_fec[t] * fecF
      Mal_J__x_fec[t] <- Mal_J__x_g[t - 1]
      Mal_S__x_fec[t] <- Mal_S__x_g[t - 1]
      Mal_A__x_fec[t] <- Mal_A__x_g[t - 1]
      Mal_C__x_fec[t] <- 0
      Mal_B__x_fec[t] <- Fem_A__x_fec[t] * fecM
    }
    
    ## update change in lambda for all 6 cohorts from step 3 on
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
    
    ## break loop if lambda_change is below a set threshold FOR ALL 6 COHORTS AT A TIME!
    if (all(lambda_change < min_lambda_change)) {
      break
    }
    
    ## calculate number of individuals after deaths and offtakes
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
    
    ## calculate number of individuals after moving to new age classes
    Fem_J__x_g[t] <- Fem_B__x_dy[t] + (1 - g[2]) * Fem_J__x_dy[t]
    Fem_S__x_g[t] <- g[2] * Fem_J__x_dy[t] + (1 - g[3]) * Fem_S__x_dy[t]
    Fem_A__x_g[t] <- g[3] * Fem_S__x_dy[t] + (1 - g[4]) * Fem_A__x_dy[t]
    Fem_C__x_g[t] <- g[4] * Fem_A__x_dy[t]
    Mal_J__x_g[t] <- Mal_B__x_dy[t] + (1 - g[7]) * Mal_J__x_dy[t]
    Mal_S__x_g[t] <- g[7] * Mal_J__x_dy[t] + (1 - g[8]) * Mal_S__x_dy[t]
    Mal_A__x_g[t] <- g[8] * Mal_S__x_dy[t] + (1 - g[9]) * Mal_A__x_dy[t]
    Mal_C__x_g[t] <- g[9] * Mal_A__x_dy[t]
  }
  
  ## determine how many times the simulation was iterated
  days_steady <- t
  
  ## summarize the number of individuals in each cohort at the end of the simulated time period
  xend <- c(
    Fem_B__x_fec[days_steady], Fem_J__x_fec[days_steady],
    Fem_S__x_fec[days_steady], Fem_A__x_fec[days_steady],
    Mal_B__x_fec[days_steady], Mal_J__x_fec[days_steady],
    Mal_S__x_fec[days_steady], Mal_A__x_fec[days_steady]
  )
  
  ## calculate the ratio of each cohort
  structure <- xend / sum(xend)
  names(structure) <- c("FB", "FJ", "FS", "FA", "MB", "MJ", "MS", "MA")
  
  ## calculate the global structure, i.e. join the birth and juvenile cohorts:
  share <- c(
    structure[1] + structure[2], structure[3:4],
    structure[5] + structure[6], structure[7:8]
  )
  names(share) <- c("FJ", "FS", "FA", "MJ", "MS", "MA")
  
  ## calculate the growth rate
  growth_rate_pop <- (Fem_J__x_fec[days_steady] / Fem_J__x_fec[days_steady - 1])^365 - 1
  
  ## prepare output
  output <- list(days_steady, structure, share, growth_rate_pop)
  names(output) <- c("days_steady", "structure", "share", "growth_rate_pop")
  
  return(output)
}



# ## Function 4: Population Size
#
# This function takes the following input parameters to simulate one year of a steady-state population:
# * "size_total": the total population size at the beginning of the year
# * "fecF":             results from the function "S1_01_Fecundity": daily number of born females generated per adult female
# * "fecM":             results from the function "S1_01_Fecundity": daily number of born males generated per adult female
# * "pdea":             results from the function "S1_02_Probabilities": daily death probability for 10 sex-age classes (vector)
# * "poff":             results from the function "S1_02_Probabilities": daily offtake probability for 10 sex-age classes (vector)
# * "g":                results from the function "S1_02_Probabilities": probability to grow into the next age class for 10 sex-age classes (vector)
# * "growth_rate_pop":      results from the function "S1_03_PopStructure": the increase in number of individuals in each sex-age class over one year in a steady-state population
# * "structure":        results from the function "S1_03_PopStructure": shares of 8 sex-age classes in a steady-state population (vector)
# * "share": results from the function "S1_03_PopStructure": shares of 6 sex-age classes in a steady-state population (vector)
#
# This function returns the following objects:
# * "size":     number of individuals in 6 sex-age classes at the beginning of the steady-state year
# * "size_end":       number of individuals in 6 sex-age classes at the end of the steady-state year (derived by growth rate)
# * "size_end_exact": number of individuals in 10 sex-age classes at the end of the steady-state year (derived by simulation)
# * "size_avg":       average number of individuals in 6 sex-age classes during a the steady-state year (derived by growth rate)
# * "offtake":        number of individuals taken off from 10 sex-age classes during one year of a steady-state population

S1_04_PopSize <- function(
    size_total, fecF, fecM, pdea, poff, g, growth_rate_pop, structure, share) {
  ## calculate intitial size of all 8 sex-age classes
  xini <- size_total * structure
  
  ### calculate head numbers for each sex-age class at beginning and end of the year, and the average:
  size <- size_total * share
  size_end <- (1 + growth_rate_pop) * size
  size_avg <- (size + ((1 + growth_rate_pop) * size)) / 2
  
  ### calculate share of each sex-age class of the total same-sex population
  structure_intrasex <- c(size[1:3] / sum(size[1:3]), size[4:6] / sum(size[4:6]))
  
  # Simulate steady-state population over one year
  
  ## initialize empty vectors to be populated in the loop
  Fem_B__d <- Fem_J__d <- Fem_S__d <- Fem_A__d <- Fem_C__d <- NULL
  Mal_B__d <- Mal_J__d <- Mal_S__d <- Mal_A__d <- Mal_C__d <- NULL
  
  Fem_B__y <- Fem_J__y <- Fem_S__y <- Fem_A__y <- Fem_C__y <- NULL
  Mal_B__y <- Mal_J__y <- Mal_S__y <- Mal_A__y <- Mal_C__y <- NULL
  
  Fem_B__x_dy <- Fem_J__x_dy <- Fem_S__x_dy <- Fem_A__x_dy <- Fem_C__x_dy <- NULL
  Mal_B__x_dy <- Mal_J__x_dy <- Mal_S__x_dy <- Mal_A__x_dy <- Mal_C__x_dy <- NULL
  
  Fem_J__x_g <- Fem_S__x_g <- Fem_A__x_g <- Fem_C__x_g <- NULL
  Mal_J__x_g <- Mal_S__x_g <- Mal_A__x_g <- Mal_C__x_g <- NULL
  
  for (t in 1:366) {
    if (t == 1) {
      ## calculate initial number of individuals taking into account
      ## the daily number of born females and males (fecF/fecM)
      Fem_J__x_fec <- xini[2]
      Fem_S__x_fec <- xini[3]
      Fem_A__x_fec <- xini[4]
      Fem_C__x_fec <- 0
      Fem_B__x_fec <- Fem_A__x_fec * fecF
      Mal_J__x_fec <- xini[6]
      Mal_S__x_fec <- xini[7]
      Mal_A__x_fec <- xini[8]
      Mal_C__x_fec <- 0
      Mal_B__x_fec <- Fem_A__x_fec * fecM
    } else if (t > 1) {
      ## calculate number of individuals taking into account both fecF/fecM and
      ## the number of individuals that survived the previous day and how they moved in the age classes
      Fem_J__x_fec[t] <- Fem_J__x_g[t - 1]
      Fem_S__x_fec[t] <- Fem_S__x_g[t - 1]
      Fem_A__x_fec[t] <- Fem_A__x_g[t - 1]
      Fem_C__x_fec[t] <- 0
      Fem_B__x_fec[t] <- Fem_A__x_fec[t] * fecF
      Mal_J__x_fec[t] <- Mal_J__x_g[t - 1]
      Mal_S__x_fec[t] <- Mal_S__x_g[t - 1]
      Mal_A__x_fec[t] <- Mal_A__x_g[t - 1]
      Mal_C__x_fec[t] <- 0
      Mal_B__x_fec[t] <- Fem_A__x_fec[t] * fecM
    }
    
    if (t %in% c(1:365)) {
      ## calculate number of individuals that die
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
      
      ## calculate number of individuals that are taken off
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
      
      ## calculate number of individuals after deaths and offtakes
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
      
      ## calculate number of individuals after moving to new age classes
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
  
  deaths_number <- c(
    sum(Fem_B__d) + sum(Fem_J__d), sum(Fem_S__d), sum(Fem_A__d),
    sum(Mal_B__d) + sum(Mal_J__d), sum(Mal_S__d), sum(Mal_A__d)
  )
  deaths_share <- deaths_number / size
  deaths_share_avg <- deaths_number / ((size + ((1 + growth_rate_pop) * size)) / 2)
  
  offtake <- c(
    sum(Fem_B__y), sum(Fem_J__y), sum(Fem_S__y), sum(Fem_A__y), sum(Fem_C__x_g),
    sum(Mal_B__y), sum(Mal_J__y), sum(Mal_S__y), sum(Mal_A__y), sum(Mal_C__x_g)
  )
  
  size_end_exact <- c(
    Fem_B__x_fec[366], Fem_J__x_fec[366], Fem_S__x_fec[366],
    Fem_A__x_fec[366], Fem_C__x_fec[366], Mal_B__x_fec[366],
    Mal_J__x_fec[366], Mal_S__x_fec[366], Mal_A__x_fec[366], Mal_C__x_fec[366]
  )
  
  names(size_end_exact) <- names(offtake) <- c("FB", "FJ", "FS", "FA", "FC", "MB", "MJ", "MS", "MA", "MC")
  names(size) <- names(size_end) <- names(size_avg) <- c("FJ", "FS", "FA", "MJ", "MS", "MA")
  
  ##### may it be an error that they once calculate the end sizes with
  ##### the growth rate and one use the 366th step of the daily simulation in the original DYNMOD ?
  
  ## prepare output
  output <- list(size, size_end, size_end_exact, size_avg, offtake)
  names(output) <- c("size", "size_end", "size_end_exact", "size_avg", "offtake")
  
  return(output)
}



# ## Function 5: Production Offtake
#
# This function takes the following input parameters to summarize the offtakes in one year of a steady-state population:
# * "size":   results from the function "S1_04_PopSize": number of individuals in 6 sex-age classes at the beginning of the steady-state year
# * "size_end":     results from the function "S1_04_PopSize": number of individuals in 6 sex-age classes at the end of the steady-state year (derived by growth rate)
# * "size_avg":     results from the function "S1_04_PopSize": average number of individuals in 6 sex-age classes during a the steady-state year (derived by growth rate)
# * "offtake":      results from the function "S1_04_PopSize": number of individuals taken off from 10 sex-age classes during one year of a steady-state population
#
# This function returns the following objects:
# * "stock_variation":      difference in amount of individuals between start and end of a steady-state year for 6 sex-age classes
# * "offtake_number":       number of individuals taken off from 6 sex-age classes during one year of a steady-state population
# * "offtake_share":        offtake rate of 6 sex-age classes for start cohort sizes
# * "offtake_share_avg":    offtake rate of 6 sex-age classes for average cohort sizes
# * "offtake_sv_number":    sum of offtake and stock variation (sv) for 6 sex-age classes during one year of a steady-state population
# * "offtake_sv_share":     rate of offtake and stock variation (sv) of 6 sex-age classes for start cohort sizes
# * "offtake_sv_share_avg": rate of offtake and stock variation (sv) of 6 sex-age classes for average cohort sizes

S1_05_ProdOfftake <- function(size, size_end, size_avg, offtake) {
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



# ## Function 6: Production Commodities [TO BE CORRECTED !!!]
#
# This function takes the following input parameters:
# * "dry_matter_req":  dry matter requirements in % of kg liveweight per day, for each of the 6 sex-age classes
# * "liveweight":      weight per animal in kg, for each of the 6 sex-age classes
# * "carcass":         carcass yield in percent
# * "financial_value": value per animal, for each of the 6 sex-age classes, in currency X
# * "milking_length":  length of milking period in days
# * "milk":            milk yield per day during the milking period, in liters
# * "skin":            skin and hides yield per animal in kg, for each of the 6 sex-age classes
# * "wool":            wool yield per animal in kg, for each of the 3 age-classes
# * "manure":          manure produced per animal and day in kg, for each of the 3 age-classes
# * "part_rate":       parturition rate (= probability of an adult female to give birth)
# * "prolif_rate":     prolificacy rate (= mean number of offspring per parturition)
# * "fem_birth_ratio": female birth ratio (= probability that an offspring is female)
# * "duration":        length of 6 sex-age classes in months
# * "S1_02_results":    results from the function "S1_02_Probabilities"
# * "S1_04_results":    results from the function "S1_04_PopSize"
# * "S1_05_results":    results from the function "S1_05_ProdOfftake"
#
# This function returns the following objects:
# * "liveweight_stock":   live weight of the living stock, in kg
# * "liveweight_offtake": live weight of the individuals taken off, in kg
# * "liveweight_sv":      live weight of the stock variation, in kg
# * "meat_stock":         meat that can potentially be produced from the living stock, in kg
# * "meat_offtake":       meat produced from the individuals taken off, in kg
# * "meat_sv":            meat produced from the stock variation
# * "financial_stock":    financial value of the living stock, in currency X
# * "financial_offtake":  financial value of the individuals taken off, in currency X
# * "financial_sv":       financial value of the stock variation, in currency X
# * "milk_total":         total amount of produced milk, in liters
# * "milk_female":        milk produced per adult female, in liters
# * "skin_total":         total amount of produced skins and hides, in kg
# * "wool_total":         total amount of produced wool, in kg
# * "manure_total":       total amount of produced manure, in kg
# * "subad_adF":          Productivity expressed as number of new sub-adults per adult female
# * "ad_adF":             Productivity expressed as number of new adults per adult female
# * "feed_req":           Total feeding requirement of dry matter in kg

S1_06_ProdCommodities <- function(
    dry_matter_req, liveweight, carcass, financial_value, milking_length,
    milk, skin, wool, manure, part_rate, prolif_rate, fem_birth_ratio,
    duration, S1_02_results, S1_04_results, S1_05_results) {
  hdea <- S1_02_results$hdea
  size <- S1_04_results$size
  size_end_exact <- S1_04_results$size_end_exact
  offtake <- S1_04_results$offtake
  stock_variation <- S1_05_results$stock_variation
  
  ## calculate live weight equivalents of stock, offtakes and stock variation
  size_end_adj <- c(
    sum(size_end_exact[c(1:2)]), size_end_exact[3], sum(size_end_exact[c(4:5)]),
    sum(size_end_exact[c(6:7)]), size_end_exact[8], sum(size_end_exact[c(9:10)])
  )
  
  liveweight_stock <- sum((size_end_adj + size) / 2 * liveweight)
  liveweight_offtake <- sum(offtake * c(
    liveweight[1], liveweight[c(1:3)], liveweight[3],
    liveweight[4], liveweight[c(4:6)], liveweight[6]
  ))
  liveweight_sv <- sum((size_end_adj * liveweight) - (size * liveweight))
  
  ## calculate meat equivalents of stock, offtakes and stock variation
  meat_stock <- liveweight_stock * carcass
  meat_offtake <- liveweight_offtake * carcass
  meat_sv <- liveweight_sv * carcass
  
  ## calculate financial equivalents of stock, offtakes and stock variation
  financial_stock <- sum((size_end_adj * financial_value) + (size * financial_value)) / 2
  financial_offtake <- sum(offtake * c(
    financial_value[1], financial_value[c(1:3)], financial_value[3],
    financial_value[4], financial_value[c(4:6)], financial_value[6]
  ))
  financial_sv <- sum((size_end_adj - size) * financial_value)
  
  ## calculate total milk production and milk produced per adult female
  milk_total <- ((size[3] + size_end_adj[3]) / 2) * part_rate / 12 * milking_length * milk * 12
  milk_female <- milk_total / size[3]
  
  #### this may be an error in the original DYNMOD? should be average number of adult females instead of initial number
  
  ## calculate total skin production
  skin_total <- sum(offtake * c(skin[1], skin[c(1:3)], skin[3], skin[4], skin[c(4:6)], skin[6]))
  
  ## calculate total wool production
  wool_total <- sum(((size_end_adj + size) / 2) * rep(wool, 2))
  
  ## calculate total manure production
  manure_total <- sum(((size_end_adj + size) / 2) * rep(manure, 2) * 365)
  
  ## calculate productivity
  subad_adF <- exp(-duration[1] * hdea[1]) * part_rate * prolif_rate * fem_birth_ratio + exp(-duration[4] * hdea[4]) * (1 - fem_birth_ratio) * part_rate * prolif_rate
  ad_adF <- exp(-duration[2] * hdea[2]) * exp(-duration[1] * hdea[1]) * part_rate * prolif_rate * fem_birth_ratio + exp(-duration[5] * hdea[5]) * exp(-duration[4] * hdea[4]) * (1 - fem_birth_ratio) * part_rate * prolif_rate
  
  ## calculate total feeding requirement
  feed_req <- sum(
    (size_end_adj * liveweight + size * liveweight) / 2 * dry_matter_req * 365
  )
  
  ## plot live weight, meat and financial equivalents
  plotdata <- data.frame(
    equivalent = c(
      rep("live weight (kg)", 3), rep("meat (kg)", 3),
      rep("financial value (currency)", 3)
    ),
    indicator = rep(c("living stock", "offtake", "stock variation")),
    value = c(
      liveweight_stock, liveweight_offtake, liveweight_sv,
      meat_stock, meat_offtake, meat_sv,
      financial_stock, financial_offtake, financial_sv
    )
  )
  
  plotdata$equivalent <- factor(
    plotdata$equivalent,
    levels = c("live weight (kg)", "meat (kg)", "financial value (currency)")
  )
  
  plot_equivalents <- ggplot(
    plotdata, aes(x = indicator, y = value, fill = indicator)
  ) +
    geom_bar(stat = "identity") +
    facet_wrap(~equivalent, scales = "free") +
    geom_text(
      aes(label = round(value, digits = 0), color = indicator), vjust = -0.25
    ) +
    scale_fill_manual("", values = viridis(6)[c(3:5)]) +
    scale_color_manual("", values = viridis(6)[c(3:5)]) +
    ylab("") +
    xlab("") +
    theme(
      axis.text.x = element_blank(),
      axis.ticks.x = element_blank()
    ) +
    guides(color = "none")
  
  ## prepare output
  names(milk_total) <- names(milk_female) <- names(subad_adF) <- names(ad_adF) <- NULL
  
  output <- list(
    liveweight_stock, liveweight_offtake, liveweight_sv,
    meat_stock, meat_offtake, meat_sv,
    financial_stock, financial_offtake, financial_sv,
    milk_total, milk_female,
    skin_total, wool_total, manure_total,
    subad_adF, ad_adF, feed_req, plot_equivalents
  )
  names(output) <- c(
    "liveweight_stock", "liveweight_offtake", "liveweight_sv",
    "meat_stock", "meat_offtake", "meat_sv",
    "financial_stock", "financial_offtake", "financial_sv",
    "milk_total", "milk_female",
    "skin_total", "wool_total", "manure_total",
    "subad_adF", "ad_adF", "feed_req", "plot_equivalents"
  )
  return(output)
}
