#' Calculate Non-Demographic Cycle Geometry
#'
#' Computes the number of full and partial non-demographic production cycles
#' that fit within a given simulated period of 365 days, assuming a single productive
#' phase per cycle and an optional resting period between cycles.
#'
#' @param duration_phase1_nondemographic Numeric vector. Duration of productive phase 1 for the assessed non-demographic cohort. Plausible cohorts are FN and MN (days).
#' @param duration_phase2_nondemographic Numeric vector. Duration of productive phase 2 for the assessed non-demographic cohort. Plausible cohorts are FN and MN (days).
#' @param duration_rest_between_cycles Numeric. Duration of resting/empty phase between cycles for the assessed non-demographic cohort (days).
#' @param simulated_days Numeric. Length of the simulated period by the demographic herd module (days). Set to 365 days by default.
#'
#' @details
#' A non-demographic production cycle consists of a single productive phase
#' followed by an optional resting period. 
#' 
#' A cycle consists of:
#' \itemize{
#'   \item Phase 1 (productive) of length \code{duration_phase1_nondemographic}
#'   \item Optional Phase 2 (productive) of length \code{duration_phase2_nondemographic}
#'   \item Optional rest between cycles (after the productive phases and before the next cycle starts)
#'         of length \code{duration_rest_between_cycles}
#' }
#'
#' The total cycle length is:
#' \deqn{
#'   cycle\_length =
#'   duration\_phase1\_nondemographic +
#'   I(duration\_phase2\_nondemographic > 0)\times duration\_phase2\_nondemographic +
#'   duration\_rest\_between\_cycles
#' }
#'
#' The function computes:
#' \itemize{
#'   \item \code{number_full_cycles_non_demographic}: number of complete cycles fully contained in \code{simulated_days}
#'   \item \code{partial_phase1_duration}: remaining-time portion that can be spent in phase 1 (capped at phase 1 duration)
#'   \item \code{partial_phase2_duration}: remaining-time portion that can be spent in phase 2 (only if phase 2 exists and phase 1 completes)
#'   \item \code{total_cycle_starts_to_distribute}: number of cycle starts within the horizon (used to distribute entrants)
#' }
#'
#' @return A named list with elements:
#' \describe{
#'   \item{number_full_cycles_non_demographic}{Integer vector. Number of complete cycles (productive phase 1 + rest phase 1 + productive phase 2 + rest phase 2) fully contained within the simulated_days window for the non-demographic cohort assessed (FN or MN) (cycles / simulated days).}
#'   \item{partial_phase1_duration}{Numeric vector. Duration of the partial productive phase 1 occurring at the end of the simulated_days window for the non-demographic cohort assessed (FN or MN) (days).).}
#'   \item{partial_phase2_duration}{Numeric vector. Duration of the partial productive phase 2 occurring at the end of the simulated_days window for the non-demographic cohort assessed (FN or MN) (days).}
#'   \item{total_cycle_starts_to_distribute}{Integer vector. Total number of cycle starts to be distributed within the simulated_days window for the non-demographic cohort assessed (FN or MN) (cycle starts / simulated days).}
#'   \item{cycle_length}{Numeric vector. Total non-demographic cycle length for the assessed cohort (FN or MN) (days).}
#' }
#'
#' @export

calc_nondemo_cycle_geometry <- function(
    duration_phase1_nondemographic,
    duration_phase2_nondemographic,
    duration_rest_between_cycles,
    simulated_days
) {
  
  if (duration_phase1_nondemographic <= 0) {
    return(list(
      number_full_cycles_non_demographic = 0,
      partial_phase1_duration = 0,
      partial_phase2_duration = 0,
      total_cycle_starts_to_distribute = 0,
      cycle_length = 0
    ))
  }
  
  phase2_exists <- duration_phase2_nondemographic > 0
  
  # Compute the total length of one full cycle (days)
  cycle_length <- duration_phase1_nondemographic +
    (if (phase2_exists) duration_phase2_nondemographic else 0) +
    duration_rest_between_cycles
  
  # Compute how many complete cycles fit entirely inside the simulation horizon
  # floor() rounds down to the nearest whole number
  number_full_cycles_non_demographic <- ifelse(
    cycle_length > 0,
    floor(simulated_days / cycle_length),
    0
  )  
  # Compute leftover time after running all full cycles (days)
  time_remaining <- simulated_days - number_full_cycles_non_demographic * cycle_length
  
  # Allocation of the leftover time to phase1 and phase2 (if additional time remains)
  
  # Initialize durations for at most one partial cycle (defaults to "no partial cycle")
  partial_phase1_duration <- 0
  partial_phase2_duration <- 0
  
  # If there is leftover time and phase 1 has positive duration,
  # allocate leftover time into a partial phase 1 (capped at full phase 1 duration).
  if (time_remaining > 0 && duration_phase1_nondemographic > 0) {
    partial_phase1_duration <- min(time_remaining, duration_phase1_nondemographic)
    
    # Remaining time after partial phase 1 is allocated
    time_remaining2 <- time_remaining - partial_phase1_duration
    
    # Only attempt a partial phase 2 if: phase 2 exists, and phase 1 was fully completed (otherwise you cannot reach phase 2), and then account for rest1 before starting phase 2.
    if (phase2_exists && partial_phase1_duration >= duration_phase1_nondemographic) {
      
      # Allocate whatever remains to phase 2, capped at the full phase 2 duration
      partial_phase2_duration <- min(time_remaining2, duration_phase2_nondemographic)
    }
  }
  
  # Count the total number of "cycle starts" across the horizon
  total_cycle_starts_to_distribute <- number_full_cycles_non_demographic + as.integer(partial_phase1_duration > 0)
  
  list(
    number_full_cycles_non_demographic = number_full_cycles_non_demographic,
    partial_phase1_duration = partial_phase1_duration,
    partial_phase2_duration = partial_phase2_duration,
    total_cycle_starts_to_distribute = total_cycle_starts_to_distribute,
    cycle_length = cycle_length
  )
}


#' Allocate Non-Demographic Entrants Across Production Cycles
#'
#' Converts the total annual number of animals entering a non-demographic cohort
#' into the number of animals entering each production cycle, based on the number
#' of cycles occurring within the simulated period.
#'
#' @param cohort_stock_annual_non_demographic Numeric vector. Total number of animals entering the non-demographic model over the simulated period
#'   (heads / simulated period). The simulated period is set by default to 365 days to align with the demographic herd model.
#'
#' @param total_cycle_starts_to_distribute Integer vector. Total number of cycle starts to be distributed within the simulated_days window for the non-demographic cohort assessed (FN or MN) (cycle starts/simulated days).
#'
#' @details
#' The annual cohort stock is evenly distributed across all production cycles.
#'
#' If \code{total_cycle_starts_to_distribute} is less than or equal to zero, the function
#' assumes that no cycle structure is defined and assigns all entrants to a single
#' cycle.
#'
#' @return A named list with the following element:
#' \describe{
#'   \item{cohort_stock_start_cycle_non_demographic}{Numeric vector. Number of animals starting each non-demographic production cycle for the assessed cohort (FN or MN), 
#'   calculated by distributing the total cohort stock over the total number of cycle starts (heads / cycle).}
#' }
#'
#' @export

calc_nondemo_start_sizes <- function(
    cohort_stock_annual_non_demographic,
    total_cycle_starts_to_distribute
) {
  
  if (is.null(total_cycle_starts_to_distribute) ||
      total_cycle_starts_to_distribute <= 0) {
    return(0)
  }
  
  cohort_stock_start_cycle_non_demographic <-
    cohort_stock_annual_non_demographic / total_cycle_starts_to_distribute
  
  list(
    cohort_stock_start_cycle_non_demographic = cohort_stock_start_cycle_non_demographic
  )
}

#' Simulate a Non-Demographic Production Cycle
#'
#' Simulates stock dynamics for a non-demographic productive phase within a
#' production cycle. This function is applied within
#' \code{run_non_demographic_herd_simulation()} to model productive phase 1 and
#' productive phase 2 under full and terminal (partial) phase durations.
#'
#' @param start_stock
#'   Numeric vector. Number of animals entering a non-demographic productive phase
#'   for the assessed cohort (FN or MN) (heads / phase).
#'
#'   When used for productive phase 1, this represents the number of animals starting
#'   each non-demographic production cycle (\code{cohort_stock_start_cycle_non_demographic}),
#'   computed using \code{calc_nondemo_start_sizes()}. When used for productive phase 2,
#'   this represents the number of animals surviving productive phase 1 and entering
#'   productive phase 2, obtained as the end stock of the productive phase 1 simulation.
#'
#' @param duration_phase_non_demo
#'   Numeric vector. Duration of the productive phase within a non-demographic
#'   production cycle for the assessed cohort (FN or MN) (days).
#'
#'   When applied to productive phase 1, this parameter corresponds to
#'   \code{duration_phase1_nondemographic}. When applied to productive phase 2, it
#'   corresponds to \code{duration_phase2_nondemographic}.
#'
#' @param mort_rate_phase
#'   Numeric vector. Mortality rate applied during the productive phase for the
#'   assessed non-demographic cohort (FN or MN), expressed as the fraction of animals
#'   dying over the full phase duration (fraction).
#'
#'   When applied to productive phase 1, this parameter corresponds to
#'   \code{mort_rate_phase1}. When applied to productive phase 2, it corresponds to
#'   \code{mort_rate_phase2}.
#'
#' @param max_simulation_days_phase
#'   Numeric vector. Maximum number of days to simulate for the productive phase (days).
#'   Use the full phase duration to simulate a complete productive phase, or a shorter
#'   value to simulate a terminal partial phase within the simulated period.
#'
#'   When applied to productive phase 1, this parameter is set either to the full phase
#'   duration (\code{duration_phase1_nondemographic}) or to \code{partial_phase1_duration}.
#'   When applied to productive phase 2, it is analogously set to the full phase duration
#'   (\code{duration_phase2_nondemographic}) or to \code{partial_phase2_duration}.
#'
#' @details
#' The function converts the phase-level mortality probability (\code{mort_rate_phase})
#' into an implied daily mortality probability such that cumulative survival over
#' \code{duration_phase_non_demo} days equals \code{1 - mort_rate_phase}, assuming
#' constant daily survival. The number of simulated days is:
#' \deqn{t = \min(\mathrm{max\_simulation\_days\_phase}, \mathrm{duration\_phase\_non\_demo})}
#' End-of-phase stock is computed as:
#' \deqn{end = start \times s^t}
#' where \eqn{s = 1 - \mathrm{death\_rate\_daily\_non\_demographic}}.
#'
#' @return A named list with:
#' \describe{
#'   \item{death_rate_daily_non_demographic}{Numeric vector. Implied daily mortality
#'   probability for the productive phase (fraction).}
#'   \item{time_simulated_non_demographic}{Numeric vector. Number of days simulated for
#'   the productive phase (days).}
#'   \item{stock}{List with the number of heads at the beginning (\code{start}) and end
#'   (\code{end}) of the simulated productive phase (heads).}
#' }
#'
#' @examples

calc_nondemo_phase <- function(
    start_stock,
    duration_phase_non_demo,
    mort_rate_phase,
    max_simulation_days_phase
) {
  
  # If phase duration is 0, nothing happens
  if (is.null(duration_phase_non_demo) || duration_phase_non_demo <= 0) {
    return(list(
      death_rate_daily_non_demographic = 0,
      time_simulated_non_demographic = 0,
      stock = list(start = 0, end = 0)
    ))
  }
  
  if (is.null(start_stock)) start_stock <- 0
  start_stock <- as.numeric(start_stock)
  
  # convert phase mortality to daily mortality and survival rate probability
  death_rate_daily_non_demographic <- 1 - (1 - mort_rate_phase)^(1 / duration_phase_non_demo)
  survival_rate_daily_non_demographic <- 1 - death_rate_daily_non_demographic
  
  # simulated number of days
  t <- max(0, min(max_simulation_days_phase, duration_phase_non_demo))
  
  # Compute end-of-phase stock using constant daily survival. Assumes constant daily mortality.
  end_stock <- start_stock * survival_rate_daily_non_demographic^t
  
  list(
    death_rate_daily_non_demographic = death_rate_daily_non_demographic,
    time_simulated_non_demographic = t,
    stock = list(start = start_stock, end = end_stock))
}




#' Calculate Average Non-Demographic Stock Over the Assessment Horizon
#'
#' Computes the average number of animals present during a given non-demographic
#' productive phase over the assessment horizon (default 365 days). Animal-days are
#' calculated for a full phase occurrence and a terminal partial phase occurrence,
#' then aggregated across full cycle repetitions and divided by the horizon length.
#'
#' This function is applied within \code{run_non_demographic_herd_simulation()} to
#' compute phase-specific average stock for productive phase 1 and productive phase 2.
#'
#' @param full_phase
#'   List. Output of \code{calc_nondemo_phase()} for a full productive phase simulation.
#'   Must contain \code{time_simulated_non_demographic} (days) and \code{stock$start},
#'   \code{stock$end} (heads).
#'
#' @param partial_phase
#'   List. Output of \code{calc_nondemo_phase()} for a terminal partial productive phase
#'   simulation (truncated duration occurring at the end of the simulated period).
#'   Uses the same structure as \code{full_phase}.
#'
#' @param number_full_cycles_non_demographic
#'   Integer vector. Number of complete non-demographic production cycles fully contained
#'   within the simulated period (cycles / simulated period).
#'
#' @param simulated_days
#'   Numeric vector. Length of the assessment horizon (days). Set to 365 days by default.
#'
#' @details
#' Animal-days are computed for each phase occurrence using a trapezoidal (linear)
#' approximation, assuming stock changes linearly from the start to the end of the
#' productive phase. For duration \eqn{t}, start stock \eqn{start}, and end stock \eqn{end}:
#' \deqn{animal\_days = t \times \frac{start + end}{2}}
#'
#' Total animal-days over the horizon are computed as:
#' \deqn{total = number\_full\_cycles\_non\_demographic \times animal\_days\_{full} + animal\_days\_{partial}}
#'
#' The average stock over the horizon is \code{total / simulated_days}.
#'
#' @return Numeric vector. Average number of animals present per day in the productive
#' phase over the assessment horizon (heads).
#'
#' @export

calc_nondemo_avg_stock_phase_horizon <- function(
    full_phase,
    partial_phase,
    number_full_cycles_non_demographic,
    simulated_days = 365
) {
  
  # Helper to compute animal-days for a specific phase. 
  avg_stock_per_phase <- function(phase) {
    t <- phase$time_simulated_non_demographic
    if (is.null(t) || t <= 0) return(0)
    start <- phase$stock$start
    end   <- phase$stock$end
    t * (start + end) / 2 # average number of animals in the phase (start+end)/2 * number of days in that specific phase
  }
  
  
  #Compute animal-days for one full phase occurrence
  ad_full <- avg_stock_per_phase(full_phase)
  
  #Compute animal-days for one partial phase occurrence
  ad_part <- avg_stock_per_phase(partial_phase)
  
  # Aggregate animal-days across the entire horizon
  (number_full_cycles_non_demographic * ad_full + ad_part) / simulated_days
}



#' Calculate Total Non-Demographic Offtake Over the Assessment Horizon
#'
#' Computes total offtake (animals exiting the system) for a non-demographic cohort
#' (FN or MN) over the simulated period (default 365 days), based on the number of
#' complete production cycles fully contained within the simulated period. Offtake
#' is assumed to occur only at the end of the last existing productive phase in the
#' cycle (phase 2 if present, otherwise phase 1). Terminal (partial) phases at the
#' end of the simulated period do not contribute to offtake.
#'
#' This function is applied within \code{run_non_demographic_herd_simulation()} after
#' productive phases have been simulated with \code{calc_nondemo_phase()} and end-of-
#' phase stock sizes have been obtained.
#'
#' @param stock_end_phase1
#'   Numeric vector. Number of animals surviving to the end of a full productive
#'   phase 1 in a non-demographic production cycle (heads).
#'
#' @param stock_end_phase2
#'   Numeric vector. Number of animals surviving to the end of a full productive
#'   phase 2 in a non-demographic production cycle (heads).
#'
#' @param number_full_cycles_non_demographic
#'   Integer vector. Number of complete non-demographic production cycles fully
#'   contained within the simulated period (cycles / simulated period).
#'
#' @param partial_phase1_duration
#'   Numeric vector. Duration of the terminal partial productive phase 1 occurring at
#'   the end of the simulated period (days). Included for interface consistency but
#'   not used in the offtake calculation when only complete cycles are considered.
#'
#' @param partial_phase2_duration
#'   Numeric vector. Duration of the terminal partial productive phase 2 occurring at
#'   the end of the simulated period (days). Included for interface consistency but
#'   not used in the offtake calculation when only complete cycles are considered.
#'
#' @param duration_phase1_nondemographic
#'   Numeric vector. Duration of productive phase 1 for the assessed non-demographic
#'   cohort; plausible cohorts are FN and MN (days).
#'
#' @param duration_phase2_nondemographic
#'   Numeric vector. Duration of productive phase 2 for the assessed non-demographic
#'   cohort; plausible cohorts are FN and MN (days).
#'
#' @param assessment_duration
#'   Numeric vector. Length of the assessment period over which offtake should be
#'   reported (days).
#'
#' @param simulated_days
#'   Numeric vector. Length of the simulated period used to compute cycle counts
#'   (days). Set to 365 days by default.
#'
#' @details
#' Offtake is computed from complete cycles only. Let \eqn{N} be the number of complete
#' cycles within the simulated period (\code{number_full_cycles_non_demographic}). If
#' productive phase 2 exists (\code{duration_phase2_nondemographic > 0}), total offtake
#' over the simulated period is:
#' \deqn{offtake\_{sim} = N \times stock\_end\_phase2}
#' Otherwise, offtake is taken from phase 1:
#' \deqn{offtake\_{sim} = N \times stock\_end\_phase1}
#'
#' Offtake totals are scaled to the assessment period by converting to an average daily
#' offtake rate over \code{simulated_days} and multiplying by \code{assessment_duration}:
#' \deqn{offtake\_{assessment} = offtake\_{sim} \times \frac{assessment\_duration}{simulated\_days}}
#'
#' @return A named list with:
#' \describe{
#'   \item{offtake_number_phase1}{Numeric vector. Total number of animals removed at the
#'   end of productive phase 1 over the simulated period (heads).}
#'   \item{offtake_number_phase2}{Numeric vector. Total number of animals removed at the
#'   end of productive phase 2 over the simulated period (heads).}
#'   \item{offtake_assessment_phase1}{Numeric vector. Number of animals removed at the
#'   end of productive phase 1 over the assessment period (heads).}
#'   \item{offtake_assessment_phase2}{Numeric vector. Number of animals removed at the
#'   end of productive phase 2 over the assessment period (heads).}
#' }
#'
#' @seealso
#' \code{\link{calc_nondemo_phase}},
#' \code{\link{run_non_demographic_herd_simulation}}
#'
#' @export


calc_nondemo_offtake_total_horizon <- function(
    stock_end_phase1,  # survivors at end of a full phase1 (from full_phase1$stock$end)
    stock_end_phase2,  # survivors at end of a full phase2 (from full_phase2$stock$end)
    number_full_cycles_non_demographic,
    partial_phase1_duration,
    partial_phase2_duration,
    duration_phase1_nondemographic,
    duration_phase2_nondemographic,
    assessment_duration,
    simulated_days = 365
) {
  
  # Decide which phases "exist"
  phase1_exists <- duration_phase1_nondemographic > 0
  phase2_exists <- duration_phase2_nondemographic > 0
  
  # normalize inputs
  if (is.null(assessment_duration) || length(assessment_duration) == 0) assessment_duration <- 0
  if (is.null(stock_end_phase1) || length(stock_end_phase1) == 0) stock_end_phase1 <- 0
  if (is.null(stock_end_phase2) || length(stock_end_phase2) == 0) stock_end_phase2 <- 0
  if (is.null(number_full_cycles_non_demographic) || length(number_full_cycles_non_demographic) == 0)
    number_full_cycles_non_demographic <- 0
  if (is.null(duration_phase1_nondemographic) || length(duration_phase1_nondemographic) == 0)
    duration_phase1_nondemographic <- 0
  if (is.null(duration_phase2_nondemographic) || length(duration_phase2_nondemographic) == 0)
    duration_phase2_nondemographic <- 0
  
  
  # Completed partial indicators
  completed_partial_phase1 <- as.integer(phase1_exists && partial_phase1_duration >= duration_phase1_nondemographic)
  completed_partial_phase2 <- as.integer(phase2_exists && partial_phase2_duration >= duration_phase2_nondemographic)
  
  # Completed ends within horizon / ount how many offtake events occur
  completed_phase_ends <- max(0, number_full_cycles_non_demographic)
  
  
  # Offtake ONLY from the last existing phase:
  # - if phase2 exists, take offtake from phase2 and force phase1 offtake = 0
  # - else take offtake from phase1
  if (phase2_exists) {
    offtake_number_phase2 <- stock_end_phase2 * completed_phase_ends
    offtake_number_phase1 <- 0
  } else {
    offtake_number_phase1 <- stock_end_phase1 * completed_phase_ends
    offtake_number_phase2 <- 0
  }
  
  # Offtake numbers scaled to the assessment_duration
  offtake_assessment_phase1 <- offtake_number_phase1 / simulated_days * assessment_duration
  offtake_assessment_phase2 <- offtake_number_phase2 / simulated_days * assessment_duration
  
  if (length(offtake_assessment_phase1) == 0) offtake_assessment_phase1 <- 0
  if (length(offtake_assessment_phase2) == 0) offtake_assessment_phase2 <- 0
  
  list(
    offtake_number_phase1 = offtake_number_phase1,
    offtake_number_phase2 = offtake_number_phase2,
    offtake_assessment_phase1 = offtake_assessment_phase1,
    offtake_assessment_phase2 = offtake_assessment_phase2
  )
}


#' Rescale a variable from one reference total to another
#'
#' Rescales a vector of values expressed relative to an original reference
#' (`x_reference_from`) so that they sum (or scale proportionally) to a new
#' target reference (`y_scaling_variable`). Zero values are preserved as zero.
#'
#' This function is vectorised and is typically used to rescale cohort- or
#' group-level quantities (e.g. sizes, emissions, offtake) from one total
#' population or stock size to another.
#'
#' @param x_scaled_variable Numeric vector. Values to be rescaled.
#' @param x_reference_from Numeric vector or scalar. Original reference total
#'   used to scale `x_scaled_variable`.
#' @param y_scaling_variable Numeric vector or scalar. Target reference total
#'   to which `x_scaled_variable` should be rescaled.
#'
#' @return
#' Numeric vector of the same length as `x_scaled_variable`, containing the
#' rescaled values.
#'
#' @export
rescale_x_to_y <- function(
    x_scaled_variable,
    x_reference_from,
    y_scaling_variable
) {
  ifelse(
    x_scaled_variable == 0,
    0,
    x_scaled_variable / x_reference_from * y_scaling_variable
  )
}
