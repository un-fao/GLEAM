#' Assign nondemographic phase durations to cohort rows
#'
#' Maps herd-level nondemographic phase-duration inputs onto the corresponding
#' cohort-phase rows and fills \code{cohort_duration_days} for \code{FN} and
#' \code{MN}.
#'
#' @param cohort_short Character. Sex- and production-stage-specific cohort code describing the animal group. Supported values include:
#'       \itemize{
#'         \item \code{FA}: adult females (from age at first parturition)
#'         \item \code{FS}: sub-adult females (from weaning to age at first parturition)
#'         \item \code{FJ}: juvenile females (from birth to weaning)
#'         \item \code{MA}: adult males (from age at first breeding)
#'         \item \code{MS}: sub-adult males (from weaning to age at first breeding)
#'         \item \code{MJ}: juvenile males (from birth to weaning)
#'         \item \code{FN}: non-demographic females
#'         \item \code{MN}: non-demographic males
#'       }
#' @param nondemo_productive_phase_id Numeric. Identifier of the productive
#'   phase for nondemographic cohorts \code{FN} and \code{MN}. Takes value
#'   \code{1} for phase 1 and optionally \code{2} for phase 2. Demographic
#'   cohorts use \code{NA}.
#' @param cohort_duration_days Numeric. Amount of time that each animal spends in a specific cohort (days).
#' @param phase1_nondemo_fem_duration_days Numeric. Duration of productive
#'   phase 1 for the female nondemographic cohort (\code{FN}) (days).
#' @param phase2_nondemo_fem_duration_days Numeric. Duration of productive
#'   phase 2 for the female nondemographic cohort (\code{FN}) (days).
#' @param phase1_nondemo_mal_duration_days Numeric. Duration of productive
#'   phase 1 for the male nondemographic cohort (\code{MN}) (days).
#' @param phase2_nondemo_mal_duration_days Numeric. Duration of productive
#'   phase 2 for the male nondemographic cohort (\code{MN}) (days).
#'
#' @return Numeric vector. Updated \code{cohort_duration_days}. Values for
#'   \code{FN} and \code{MN} rows are filled from the herd-level phase-duration
#'   inputs when present; all other rows keep their original values.
#'   
#' @seealso
#' [run_nondemographic_herd_module()]
#' 
#' @export
assign_nondemographic_phase_durations <- function(
    cohort_short,
    nondemo_productive_phase_id,
    cohort_duration_days = NA_real_,
    phase1_nondemo_fem_duration_days = NA_real_,
    phase2_nondemo_fem_duration_days = NA_real_,
    phase1_nondemo_mal_duration_days = NA_real_,
    phase2_nondemo_mal_duration_days = NA_real_
) {
  cohort_duration_days <- as.numeric(cohort_duration_days)
  phase1_nondemo_fem_duration_days <- as.numeric(phase1_nondemo_fem_duration_days)
  phase2_nondemo_fem_duration_days <- as.numeric(phase2_nondemo_fem_duration_days)
  phase1_nondemo_mal_duration_days <- as.numeric(phase1_nondemo_mal_duration_days)
  phase2_nondemo_mal_duration_days <- as.numeric(phase2_nondemo_mal_duration_days)
  
  data.table::fcase(
    cohort_short == "FN" & nondemo_productive_phase_id == 1 & !is.na(phase1_nondemo_fem_duration_days),
    phase1_nondemo_fem_duration_days,
    cohort_short == "FN" & nondemo_productive_phase_id == 2 & !is.na(phase2_nondemo_fem_duration_days),
    phase2_nondemo_fem_duration_days,
    cohort_short == "MN" & nondemo_productive_phase_id == 1 & !is.na(phase1_nondemo_mal_duration_days),
    phase1_nondemo_mal_duration_days,
    cohort_short == "MN" & nondemo_productive_phase_id == 2 & !is.na(phase2_nondemo_mal_duration_days),
    phase2_nondemo_mal_duration_days,
    default = cohort_duration_days
  )
}

#' Calculate total nondemographic durations by herd
#'
#' Aggregates total modeled nondemographic productive-phase durations by herd and
#' sex from \code{FN} and \code{MN} cohort rows.
#'
#' @param cohort_short Character. Sex- and production-stage-specific cohort code describing the animal group. Supported values include:
#'       \itemize{
#'         \item \code{FA}: adult females (from age at first parturition)
#'         \item \code{FS}: sub-adult females (from weaning to age at first parturition)
#'         \item \code{FJ}: juvenile females (from birth to weaning)
#'         \item \code{MA}: adult males (from age at first breeding)
#'         \item \code{MS}: sub-adult males (from weaning to age at first breeding)
#'         \item \code{MJ}: juvenile males (from birth to weaning)
#'         \item \code{FN}: non-demographic females
#'         \item \code{MN}: non-demographic males
#'       }
#' @param cohort_duration_days Numeric. Amount of time that each animal spends in a specific cohort (days).
#'
#' @return A named list with elements:
#' \describe{
#'   \item{total_nondemo_fem_duration_days}{Numeric. Total duration of the
#'   productive nondemographic phases assigned to the female nondemographic
#'   cohort block (\code{FN}) (days).}
#'   \item{total_nondemo_mal_duration_days}{Numeric. Total duration of the
#'   productive nondemographic phases assigned to the male nondemographic cohort
#'   block (\code{MN}) (days).}
#' }
#'
#' @seealso
#' [run_nondemographic_herd_module()]
#' 
#' @export
calc_nondemographic_total_durations <- function(
    cohort_short,
    cohort_duration_days
) {

  list(
    total_nondemo_fem_duration_days = sum(
      cohort_duration_days[cohort_short == "FN"],
      na.rm = TRUE
    ),
    total_nondemo_mal_duration_days = sum(
      cohort_duration_days[cohort_short == "MN"],
      na.rm = TRUE
    )
  )
}


#' Calculate nondemographic cycle geometry
#'
#' Calculates the number of full (including productive and resting phase) 
#' and partial nondemographic production cycles
#' that fit within a fixed 365-day time horizon, allowing for
#' up to two productive phases per cycle and an optional resting period between cycles.
#'
#' @param phase1_nondemo_duration Numeric. Duration of productive phase 1 for
#'   the assessed nondemographic cohort (\code{FN} or \code{MN}) (days).
#' @param phase2_nondemo_duration Numeric. Duration of productive phase 2 for
#'   the assessed nondemographic cohort (\code{FN} or \code{MN}) (days).
#' @param rest_between_nondemo_cycles_duration Numeric. Duration of the
#'   resting or empty phase between nondemographic cycles (days).
#' @details
#' A nondemographic production cycle can contain one or two productive phases,
#' followed by an optional resting period before the next cycle starts. The
#' function uses a fixed 365-day time horizon so the horizon matches the
#' demographic herd simulation.
#'
#' A cycle consists of:
#' \itemize{
#'   \item Phase 1 (productive) of length \code{phase1_nondemo_duration}
#'   \item Optional Phase 2 (productive) of length \code{phase2_nondemo_duration}
#'   \item Optional rest between cycles (after the productive phases and before the next cycle starts)
#'         of length \code{rest_between_nondemo_cycles_duration}
#' }
#'
#' The total length of one cycle is calculated as:
#' \deqn{
#' cycle\_length =
#' phase1\_non\_demo\_duration +
#' phase2\_non\_demo\_duration +
#' rest\_between\_non\_demo\_cycles\_duration
#' }
#'
#' The number of complete cycles fully contained within the fixed time horizon is:
#' \deqn{
#' number\_full\_non\_demo\_cycles =
#' \left\lfloor \frac{time\_horizon}{cycle\_length} \right\rfloor
#' }
#'
#' The time remaining after all complete cycles have been allocated is:
#' \deqn{
#' time\_remaining =
#' time\_horizon -
#' number\_full\_non\_demo\_cycles \times cycle\_length
#' }
#'
#' Any time remaining after the full cycles is allocated sequentially
#' to the next cycle.
#'
#' First, the remaining time is used to fill phase 1:
#' \deqn{
#' partial\_phase1\_nondemo\_duration =
#' \min(time\_remaining,\ phase1\_non\_demo\_duration)
#' }
#'
#' The time left after phase 1 is:
#' \deqn{
#' time\_remaining2 =
#' time\_remaining - partial\_phase1\_nondemo\_duration
#' }
#'
#' If:
#' \itemize{
#'   \item phase 2 exists (\code{phase2_nondemo_duration > 0}), and
#'   \item phase 1 was fully completed
#' }
#'
#' then the remaining time is allocated to phase 2:
#' \deqn{
#' partial\_phase2\_nondemo\_duration =
#' \min(time\_remaining2,\ phase2\_non\_demo\_duration)
#' }
#'
#' Each full cycle contributes one cycle start. In addition, if a partial
#' phase 1 is present (i.e. \code{partial_phase1_nondemo_duration > 0}),
#' this indicates that a new cycle has started.
#'
#' Therefore:
#' \deqn{
#' total\_nondemo\_cycle\_starts\_to\_distribute =
#' number\_full\_non\_demo\_cycles +
#' I(partial\_phase1\_nondemo\_duration > 0)
#' }
#' 
#' This function is part of the [run_nondemographic_herd_module()].
#' 
#' @return A named list with elements:
#' \describe{
#'   \item{number_full_nondemo_cycles}{Integer. Number of complete cycles fully
#'   contained within the fixed 365-day time horizon for the assessed
#'   nondemographic cohort (\code{FN} or \code{MN}) (full cycles / simulated
#'   period).}
#'   \item{partial_phase1_nondemo_duration}{Numeric. Duration of the terminal
#'   partial productive phase 1 occurring at the end of the fixed 365-day time
#'   horizon for the assessed nondemographic cohort (\code{FN} or \code{MN})
#'   (days).}
#'   \item{partial_phase2_nondemo_duration}{Numeric. Duration of the terminal
#'   partial productive phase 2 occurring at the end of the fixed 365-day time
#'   horizon for the assessed nondemographic cohort (\code{FN} or \code{MN})
#'   (days).}
#'   \item{total_nondemo_cycle_starts_to_distribute}{Integer. Total number of
#'   cycle starts within the fixed 365-day time horizon for the assessed
#'   nondemographic cohort (\code{FN} or \code{MN}) (cycle starts / simulated
#'   period).}
#'   \item{cycle_length}{Numeric. Total duration of one full nondemographic
#'   cycle, including productive phases and the rest period between cycles
#'   (days).}
#' }
#' 
#' @seealso
#' [run_nondemographic_herd_module()] 
#' 
#' @export

calc_nondemo_cycle_geometry <- function(
    phase1_nondemo_duration,
    phase2_nondemo_duration,
    rest_between_nondemo_cycles_duration
) {
  time_horizon <- 365
  validate_nondemo_cycle_geometry_inputs(
    phase1_nondemo_duration,
    phase2_nondemo_duration,
    rest_between_nondemo_cycles_duration
  )
  
  if (phase1_nondemo_duration <= 0) {
    return(list(
      number_full_nondemo_cycles = 0,
      partial_phase1_nondemo_duration = 0,
      partial_phase2_nondemo_duration = 0,
      total_nondemo_cycle_starts_to_distribute = 0,
      cycle_length = 0
    ))
  }
  
  phase2_exists <- phase2_nondemo_duration > 0
  
  # Compute the total length of one full cycle (days)
  cycle_length <- phase1_nondemo_duration +
    (if (phase2_exists) phase2_nondemo_duration else 0) +
    rest_between_nondemo_cycles_duration
  
  # Compute how many complete cycles fit entirely inside the simulation horizon
  # floor() rounds down to the nearest whole number
  number_full_nondemo_cycles <- ifelse(
    cycle_length > 0,
    floor(time_horizon / cycle_length),
    0
  )  
  # Compute leftover time after running all full cycles (days)
  time_remaining <- time_horizon - number_full_nondemo_cycles * cycle_length
  
  # Allocation of the leftover time to phase1 and phase2 (if additional time remains)
  
  # Initialize durations for at most one partial cycle (defaults to "no partial cycle")
  partial_phase1_nondemo_duration <- 0
  partial_phase2_nondemo_duration <- 0
  
  # If there is leftover time and phase 1 has positive duration,
  # allocate leftover time into a partial phase 1 (capped at full phase 1 duration).
  if (time_remaining > 0 && phase1_nondemo_duration > 0) {
    partial_phase1_nondemo_duration <- min(time_remaining, phase1_nondemo_duration)
    
    # Remaining time after partial phase 1 is allocated
    time_remaining2 <- time_remaining - partial_phase1_nondemo_duration
    
    # Only attempt a partial phase 2 if: phase 2 exists, and phase 1 was fully completed (otherwise you cannot reach phase 2), and then account for rest1 before starting phase 2.
    if (phase2_exists && partial_phase1_nondemo_duration >= phase1_nondemo_duration) {
      
      # Allocate whatever remains to phase 2, capped at the full phase 2 duration
      partial_phase2_nondemo_duration <- min(time_remaining2, phase2_nondemo_duration)
    }
  }
  
  # Count the total number of "cycle starts" across the horizon
  total_nondemo_cycle_starts_to_distribute <- number_full_nondemo_cycles + as.integer(partial_phase1_nondemo_duration > 0)
  
  list(
    number_full_nondemo_cycles = number_full_nondemo_cycles,
    partial_phase1_nondemo_duration = partial_phase1_nondemo_duration,
    partial_phase2_nondemo_duration = partial_phase2_nondemo_duration,
    total_nondemo_cycle_starts_to_distribute = total_nondemo_cycle_starts_to_distribute,
    cycle_length = cycle_length
  )
}


#' Calculate nondemographic entrants across production cycles
#'
#' Calculates the total annual number of animals entering a nondemographic cohort
#' into the number of animals entering each production cycle, based on the number
#' of cycle starts occurring within the fixed 365-day horizon.
#'
#' @param cohort_stock_nondemo_annual_entrants Numeric. Total number of animals
#'   entering the nondemographic production pathway over the simulated period
#'   for the assessed cohort block (\code{FN} or \code{MN})
#'   (heads / simulated period).
#'
#' @param total_nondemo_cycle_starts_to_distribute Integer. Total number of
#'   cycle starts within the fixed 365-day time horizon for the assessed
#'   nondemographic cohort (\code{FN} or \code{MN}) (cycle starts / simulated
#'   period).
#'
#' @details
#' The annual entrant stock is evenly distributed across all defined production
#' cycle starts. The number of animals entering each cycle is calculated as:
#'
#' \deqn{
#' cohort\_stock\_nondemo\_start\_cycle =
#' \frac{cohort\_stock\_nondemo\_annual\_entrants}
#' {total\_non\_demo\_cycle\_starts\_to\_distribute}
#' }
#'
#' where:
#' \itemize{
#'   \item \code{cohort\_stock\_nondemo\_start\_cycle} is the number of animals entering each cycle
#'   \item \code{cohort\_stock\_nondemo\_annual\_entrants} is the total annual entrants
#'   \item \code{total\_non\_demo\_cycle\_starts\_to\_distribute} is the number of cycle starts
#' }
#'
#' If \code{total\_nondemo\_cycle\_starts\_to\_distribute} is \code{NULL} or less than or equal
#' to zero, the function assumes that no cycle structure is defined. In this case,
#' all annual entrants are assigned to a single implicit cycle:
#'
#' \deqn{
#' cohort\_stock\_nondemo\_start\_cycle =
#' cohort\_stock\_nondemo\_annual\_entrants
#' }
#'
#' No rounding or integer enforcement is applied:
#'
#' This means fractional values may occur when
#' \code{cohort\_stock\_nondemo\_annual\_entrants} is not perfectly divisible
#' by \code{total\_non\_demo\_cycle\_starts\_to\_distribute}. Handling of integer constraints
#' (if required) is delegated to downstream processes.
#'
#'
#' This function is part of the [run_nondemographic_herd_module()].

#'
#' @return A named list with the following element:
#' \describe{
#'   \item{cohort_stock_nondemo_start_cycle}{Numeric. Number of animals starting
#'   each nondemographic production cycle for the assessed cohort block
#'   (\code{FN} or \code{MN}), calculated by distributing total annual entrants
#'   over the total number of cycle starts (heads / cycle).}
#' }
#'
#' @seealso
#' [run_nondemographic_herd_module()]
#'
#' @export

calc_nondemo_start_sizes <- function(
    cohort_stock_nondemo_annual_entrants,
    total_nondemo_cycle_starts_to_distribute
) {
  validate_nondemo_start_size_inputs(
    cohort_stock_nondemo_annual_entrants,
    total_nondemo_cycle_starts_to_distribute
  )
  
  if (is.null(total_nondemo_cycle_starts_to_distribute) ||
      total_nondemo_cycle_starts_to_distribute <= 0) {
    return(0)
  }
  
  cohort_stock_nondemo_start_cycle <-
    cohort_stock_nondemo_annual_entrants / total_nondemo_cycle_starts_to_distribute
  
  list(
    cohort_stock_nondemo_start_cycle = cohort_stock_nondemo_start_cycle
  )
}

#' Calculate a nondemographic productive phase
#'
#' Simulates stock dynamics for a nondemographic productive phase within a
#' production cycle. This function is applied within
#' \code{\link{run_nondemographic_herd_module}} to model productive phase 1 and
#' productive phase 2 under full and terminal (partial) phase durations.
#'
#' @param cohort_stock_nondemo_start_by_phase Numeric. Number of animals
#'   entering a nondemographic productive phase for the assessed cohort
#'   (\code{FN} or \code{MN}) (heads / phase).
#'   When used for productive phase 1, this represents the number of animals starting
#'   each nondemographic production cycle (\code{cohort_stock_nondemo_start_cycle}),
#'   computed using \code{calc_nondemo_start_sizes()}. When used for productive phase 2,
#'   this represents the number of animals surviving productive phase 1 and entering
#'   productive phase 2, obtained as the end stock of the productive phase 1 simulation.
#'
#' @param productive_phase_nondemo_duration Numeric. Duration of the productive
#'   phase within a nondemographic production cycle for the assessed cohort
#'   (\code{FN} or \code{MN}) (days).
#'   When applied to productive phase 1, this parameter corresponds to
#'   \code{phase1_nondemo_duration}. When applied to productive phase 2, it
#'   corresponds to \code{phase2_nondemo_duration}.
#'
#' @param death_rate_nondemo_phase Numeric. Fraction of animals dying during the
#'   productive phase for the assessed nondemographic cohort (\code{FN} or
#'   \code{MN}) (fraction).
#'
#' @param max_simulation_days_nondemo_phase Numeric. Maximum number of days to simulate for the productive phase (days).
#'   Use the full phase duration to simulate a complete productive phase, or a shorter
#'   value to simulate a terminal partial phase within the simulated period.
#'   When applied to productive phase 1, this parameter is set either to the full phase
#'   duration (\code{phase1_nondemo_duration}) or to \code{partial_phase1_nondemo_duration}.
#'   When applied to productive phase 2, it is analogously set to the full phase duration
#'   (\code{phase2_nondemo_duration}) or to \code{partial_phase2_nondemo_duration}.
#'
#' @details
#' The function converts the phase-level mortality probability
#' (\code{death_rate_nondemo_phase}) into an implied daily mortality probability
#' under the assumption of constant
#' daily mortality throughout the phase. The implied daily mortality is derived
#' so that cumulative survival over the full phase duration
#' (\code{productive_phase_nondemo_duration}) is equal to \eqn{1 - death_rate_nondemo_phase}.
#'
#' Daily mortality is calculated as:
#' \deqn{
#' death\_rate\_daily\_nondemo =
#' 1 - (1 - death_rate_nondemo_phase)^{1 / productive_phase_nondemo_duration}
#' }
#'
#' and the corresponding daily survival probability is:
#' \deqn{
#' survival\_rate\_daily\_nondemo =
#' 1 - death\_rate\_daily\_nondemo
#' }
#'
#' The number of simulated days is limited by both the total phase duration
#' and the maximum number of days allowed for the current simulation step:
#' \deqn{
#' time\_simulated\_nondemographic =
#' \min(max_simulation_days_nondemo_phase,\ productive_phase_nondemo_duration)
#' }
#'
#' End-of-phase stock is then calculated by applying constant daily survival
#' to the starting stock over the simulated period:
#' \deqn{
#' cohort\_stock\_nondemo_{end} =
#' cohort\_stock\_nondemo\_start\_by\_phase \times survival\_rate\_daily\_nondemo^{time\_simulated\_nondemographic}
#' }
#'
#' Equivalently:
#' \deqn{
#' cohort\_stock\_nondemo_{end} =
#' cohort\_stock\_nondemo\_start\_by\_phase \times
#' (1 - death\_rate\_daily\_nondemo)^{time\_simulated\_nondemographic}
#' }
#'
#' If \code{productive_phase_nondemo_duration} is \code{NULL} or less than or equal to
#' zero, the function assumes that no productive phase is simulated. In this
#' case, mortality is set to zero, simulated time is set to zero, and both
#' starting and ending stock are returned as zero.
#'
#' No rounding is applied to stock values. Therefore, fractional values may
#' occur in \code{cohort_stock_nondemo$end}.
#'
#' This function is part of the [run_nondemographic_herd_module()].
#' 
#' @return A named list with:
#' \describe{
#'   \item{time_simulated_nondemographic}{Numeric. Number of days simulated for
#'   the productive phase (days).}
#'   \item{cohort_stock_nondemo}{List with:
#'     \describe{
#'       \item{\code{start}}{Numeric. Number of animals at the beginning of the simulated productive phase (heads).}
#'       \item{\code{end}}{Numeric. Number of animals remaining at the end of the simulated productive phase after applying mortality over the simulated time interval (heads).}
#'     }}
#' }
#'
#' @seealso
#' [run_nondemographic_herd_module()]
calc_nondemo_phase <- function(
    cohort_stock_nondemo_start_by_phase,
    productive_phase_nondemo_duration,
    death_rate_nondemo_phase,
    max_simulation_days_nondemo_phase
) {
  validate_nondemo_phase_inputs(
    cohort_stock_nondemo_start_by_phase,
    productive_phase_nondemo_duration,
    death_rate_nondemo_phase,
    max_simulation_days_nondemo_phase
  )
  
  # If phase duration is 0, nothing happens
  if (is.null(productive_phase_nondemo_duration) || productive_phase_nondemo_duration <= 0) {
    return(list(
      time_simulated_nondemographic = 0,
      cohort_stock_nondemo = list(start = 0, end = 0)
    ))
  }
  
  if (is.null(cohort_stock_nondemo_start_by_phase)) cohort_stock_nondemo_start_by_phase <- 0
  cohort_stock_nondemo_start_by_phase <- as.numeric(cohort_stock_nondemo_start_by_phase)
  
  # convert phase mortality to daily mortality and survival rate probability
  death_rate_daily_nondemographic <- 1 - (1 - death_rate_nondemo_phase)^(1 / productive_phase_nondemo_duration)
  survival_rate_daily_nondemographic <- 1 - death_rate_daily_nondemographic
  
  # simulated number of days
  t <- max(0, min(max_simulation_days_nondemo_phase, productive_phase_nondemo_duration))
  
  # Compute end-of-phase stock using constant daily survival. Assumes constant daily mortality.
  end_stock <- cohort_stock_nondemo_start_by_phase * survival_rate_daily_nondemographic^t
  
  list(
    time_simulated_nondemographic = t,
    cohort_stock_nondemo = list(start = cohort_stock_nondemo_start_by_phase, end = end_stock))
}




#' Calculate average nondemographic stock over the assessment horizon
#'
#' Computes the average number of animals present during a given nondemographic
#' productive phase over the assessment horizon (default 365 days). Animal-days are
#' calculated for a full phase occurrence and a terminal partial phase occurrence,
#' then aggregated across full cycle repetitions and divided by the horizon length.
#'
#' This function is applied within \code{\link{run_nondemographic_herd_module}} to
#' compute phase-specific average stock for productive phase 1 and productive phase 2.
#'
#' @param full_nondemo_phase_duration List. Output of \code{calc_nondemo_phase()} for a full productive phase simulation.
#'   Must contain \code{time_simulated_nondemographic} (days) and
#'   \code{cohort_stock_nondemo$start}, \code{cohort_stock_nondemo$end}
#'   (heads).
#'
#' @param partial_nondemo_phase List. Output of \code{calc_nondemo_phase()} for a terminal partial productive phase
#'   simulation (truncated duration occurring at the end of the simulated period).
#'   Uses the same structure as \code{full_nondemo_phase_duration}.
#'
#' @param number_full_nondemo_cycles Integer. Number of complete cycles fully
#'   contained within the fixed 365-day simulation window for the assessed
#'   nondemographic cohort (\code{FN} or \code{MN}) (full cycles / simulated
#'   period).
#'
#' @details
#' The function calculates the average stock present in the nondemographic
#' productive phase over the full assessment horizon, expressed as heads per day.
#' It does so by first converting stock trajectories within each simulated phase
#' into animal-days, and then dividing total animal-days by the fixed 365-day
#' simulation horizon.
#'
#' For each phase occurrence, animal-days are approximated using the trapezoidal
#' rule, assuming that stock changes linearly from
#' \code{cohort_stock_nondemo$start} to \code{cohort_stock_nondemo$end} over
#' \code{time_simulated_nondemographic} days. For a given
#' phase:
#' \deqn{
#' animal_days_phase =
#' time_simulated_nondemographic \times
#' \frac{cohort_stock_nondemo$start + cohort_stock_nondemo$end}{2}
#' }
#'
#' This approximation is applied separately to:
#' \itemize{
#'   \item \code{full_nondemo_phase_duration}, representing one full occurrence of
#'   the productive phase, and
#'   \item \code{partial_nondemo_phase}, representing the final partial
#'   occurrence of the productive phase within the assessment horizon.
#' }
#'
#' Animal-days for one full productive phase are computed as:
#' \deqn{
#' ad_full =
#' full_nondemo_phase_duration$time_simulated_nondemographic \times
#' \frac{
#' full_nondemo_phase_duration$cohort_stock_nondemo$start +
#' full_nondemo_phase_duration$cohort_stock_nondemo$end
#' }{2}
#' }
#'
#' Animal-days for one partial productive phase are computed as:
#' \deqn{
#' ad_part =
#' partial_nondemo_phase$time_simulated_nondemographic \times
#' \frac{
#' partial_nondemo_phase$cohort_stock_nondemo$start +
#' partial_nondemo_phase$cohort_stock_nondemo$end
#' }{2}
#' }
#'
#' Total animal-days over the assessment horizon are then:
#' \deqn{
#' total_animal_days =
#' number_full_nondemo_cycles \times ad_full + ad_part
#' }
#'
#' Finally, the average stock over the horizon is calculated as:
#' \deqn{
#' average_stock_phase_horizon =
#' \frac{
#' number_full_nondemo_cycles \times ad_full + ad_part
#' }{365}
#' }
#'
#' If a phase has \code{time_simulated_nondemographic} equal to \code{NULL} or
#' less than or equal to zero, its animal-days contribution is treated as zero.
#'
#' The function assumes linear stock change within each phase and does not apply
#' any rounding. Therefore, fractional animal-days and fractional average stock
#' values may occur.
#'
#' This function is part of the [run_nondemographic_herd_module()].
#'
#' @return A named list with:
#' \describe{
#'   \item{cohort_stock_size_unscaled}{Numeric. Average population size by cohort not yet scaled to the total livestock population (herd_size_total) (# heads).}
#' }
#'
#' @seealso
#' [run_nondemographic_herd_module()]
#'
#' @export

calc_nondemo_avg_stock_phase_horizon <- function(
    full_nondemo_phase_duration,
    partial_nondemo_phase,
    number_full_nondemo_cycles
) {
  time_horizon <- 365
  validate_nondemo_avg_stock_inputs(
    full_nondemo_phase_duration,
    partial_nondemo_phase,
    number_full_nondemo_cycles
  )
  
  # Helper to compute animal-days for a specific phase. 
  avg_stock_per_phase <- function(phase) {
    t <- phase$time_simulated_nondemographic
    if (is.null(t) || t <= 0) return(0)
    start <- phase$cohort_stock_nondemo$start
    end   <- phase$cohort_stock_nondemo$end
    t * (start + end) / 2
  }
  
  
  ad_full <- avg_stock_per_phase(full_nondemo_phase_duration)
  ad_part <- avg_stock_per_phase(partial_nondemo_phase)
  
  cohort_stock_size_unscaled <-
    (number_full_nondemo_cycles * ad_full + ad_part) / time_horizon

  list(
    cohort_stock_size_unscaled = cohort_stock_size_unscaled
  )
}



#' Calculate total nondemographic offtake over the assessment horizon
#'
#' Calculates total offtake (animals exiting the system) for a nondemographic
#' cohort (FN or MN) over the assessment period using a steady-state throughput
#' formulation.
#'
#' This function is applied within \code{\link{run_nondemographic_herd_module}} after
#' productive phases have been simulated with \code{calc_nondemo_phase()} and end-of-
#' phase stock sizes have been obtained.
#'
#' @param cohort_stock_nondemo_end_phase1
#'   Numeric. Number of animals remaining at the end of one complete
#'   nondemographic productive phase 1 after applying phase-specific mortality
#'   (# heads / cycle). Typically obtained as \code{cohort_stock_nondemo$end} from
#'   \code{\link{calc_nondemo_phase}} when simulating a full phase 1.
#'
#' @param cohort_stock_nondemo_end_phase2
#'   Numeric. Number of animals remaining at the end of one complete
#'   nondemographic productive phase 2 after applying phase-specific mortality
#'   (# heads / cycle). Typically obtained as \code{cohort_stock_nondemo$end} from
#'   \code{\link{calc_nondemo_phase}} when simulating a full phase 2. Used only
#'   when phase 2 exists.
#'
#' @param cohort_stock_nondemo_annual_entrants
#'   Numeric. Total annual number of animals entering the nondemographic block
#'   over the fixed 365-day horizon (# heads / simulated period).
#'
#' @param cohort_stock_nondemo_start_cycle
#'   Numeric. Number of animals starting one nondemographic production cycle
#'   (# heads / cycle).
#'
#' @param number_full_nondemo_cycles
#'   Integer. Number of complete nondemographic production cycles fully
#'   contained within the simulated period (cycles / simulated period). This is
#'   calculated by \code{\link{calc_nondemo_cycle_geometry}}.
#'
#' @param partial_phase1_nondemo_duration
#'   Numeric. Duration of the terminal partial productive phase 1 occurring at
#'   the end of the simulated period (days). Used only to determine whether the
#'   final partial phase 1 reaches completion; terminal partial phases do not
#'   contribute to offtake. This is calculated by
#'   \code{\link{calc_nondemo_cycle_geometry}}.
#'
#' @param partial_phase2_nondemo_duration
#'   Numeric. Duration of the terminal partial productive phase 2 occurring at
#'   the end of the simulated period (days). Used only to determine whether the
#'   final partial phase 2 reaches completion; terminal partial phases do not
#'   contribute to offtake. This is calculated by
#'   \code{\link{calc_nondemo_cycle_geometry}}.
#'
#' @param phase1_nondemo_duration
#'   Numeric. Full duration of productive phase 1 for the assessed
#'   nondemographic cohort block (\code{FN} or \code{MN}) (days). This duration is used
#'   as input to both \code{\link{calc_nondemo_cycle_geometry}} and
#'   \code{\link{calc_nondemo_phase}}.
#'
#' @param phase2_nondemo_duration
#'   Numeric. Full duration of productive phase 2 for the assessed
#'   nondemographic cohort block (\code{FN} or \code{MN}) (days). Use \code{0} when no second
#'   productive phase exists. This duration is used as input to both
#'   \code{\link{calc_nondemo_cycle_geometry}} and
#'   \code{\link{calc_nondemo_phase}}.
#'
#' @param simulation_duration Numeric. Length of the assessment period (days).
#'
#' @details
#' Offtake is assumed to occur only at the end of the last existing productive
#' phase in the cycle (phase 2 if present, otherwise phase 1). The function
#' uses a fixed 365-day simulated horizon so the nondemographic pathway stays
#' aligned with the demographic herd simulation.
#'
#' Annual offtake is estimated as annual entrants into the nondemographic block
#' multiplied by survival to the terminal productive phase. If productive
#' phase 2 exists (\code{phase2_nondemo_duration > 0}), terminal survival is:
#' \deqn{survival\_{terminal} = \frac{cohort\_stock\_nondemo\_end\_phase2}{cohort\_stock\_nondemo\_start\_cycle}}
#' Otherwise, terminal survival is taken from phase 1:
#' \deqn{survival\_{terminal} = \frac{cohort\_stock\_nondemo\_end\_phase1}{cohort\_stock\_nondemo\_start\_cycle}}
#'
#' Simulated annual offtake is then:
#' \deqn{offtake\_{sim} = cohort\_stock\_nondemo\_annual\_entrants \times survival\_{terminal}}
#'
#' Offtake totals are scaled to the reporting period by converting to an average
#' daily offtake rate over the fixed 365-day simulated horizon and multiplying by
#' \code{simulation_duration}:
#' \deqn{offtake\_{assessment} = offtake\_{sim} \times \frac{simulation\_duration}{365}}
#'
#' This function is part of the [run_nondemographic_herd_module()].
#'
#' @return A named list with:
#' \describe{
#'   \item{offtake_heads_nondemo_phase1}{Numeric. Total number of animals
#'   removed at the end of productive phase 1 of the nondemographic block over
#'   the fixed 365-day horizon (heads).}
#'   \item{offtake_heads_nondemo_phase2}{Numeric. Total number of animals
#'   removed at the end of productive phase 2 of the nondemographic block over
#'   the fixed 365-day horizon (heads).}
#'   \item{offtake_heads_assessment_nondemo_phase1}{Numeric. Total number of
#'   animals removed at the end of productive phase 1 of the nondemographic
#'   block over \code{simulation_duration} (heads / simulated period).}
#'   \item{offtake_heads_assessment_nondemo_phase2}{Numeric. Total number of
#'   animals removed at the end of productive phase 2 of the nondemographic
#'   block over \code{simulation_duration} (heads / simulated period).}
#' }
#'
#' @seealso
#' \code{\link{calc_nondemo_phase}},
#' \code{\link{run_nondemographic_herd_module}}
#'
#' @export


calc_nondemo_offtake_total_horizon <- function(
    cohort_stock_nondemo_end_phase1,  # survivors at end of a full phase1
    cohort_stock_nondemo_end_phase2,  # survivors at end of a full phase2
    cohort_stock_nondemo_annual_entrants,
    cohort_stock_nondemo_start_cycle,
    number_full_nondemo_cycles,
    partial_phase1_nondemo_duration,
    partial_phase2_nondemo_duration,
    phase1_nondemo_duration,
    phase2_nondemo_duration,
    simulation_duration
) {
  time_horizon <- 365
  validate_nondemo_offtake_inputs(
    cohort_stock_nondemo_end_phase1,
    cohort_stock_nondemo_end_phase2,
    number_full_nondemo_cycles,
    partial_phase1_nondemo_duration,
    partial_phase2_nondemo_duration,
    phase1_nondemo_duration,
    phase2_nondemo_duration,
    simulation_duration
  )
  
  # Decide which phases "exist"
  phase1_exists <- phase1_nondemo_duration > 0
  phase2_exists <- phase2_nondemo_duration > 0
  
  # normalize inputs
  if (is.null(simulation_duration) || length(simulation_duration) == 0) simulation_duration <- 0
  if (is.null(cohort_stock_nondemo_end_phase1) || length(cohort_stock_nondemo_end_phase1) == 0) cohort_stock_nondemo_end_phase1 <- 0
  if (is.null(cohort_stock_nondemo_end_phase2) || length(cohort_stock_nondemo_end_phase2) == 0) cohort_stock_nondemo_end_phase2 <- 0
  if (is.null(cohort_stock_nondemo_annual_entrants) || length(cohort_stock_nondemo_annual_entrants) == 0)
    cohort_stock_nondemo_annual_entrants <- 0
  if (is.null(cohort_stock_nondemo_start_cycle) || length(cohort_stock_nondemo_start_cycle) == 0)
    cohort_stock_nondemo_start_cycle <- 0
  if (is.null(number_full_nondemo_cycles) || length(number_full_nondemo_cycles) == 0)
    number_full_nondemo_cycles <- 0
  if (is.null(phase1_nondemo_duration) || length(phase1_nondemo_duration) == 0)
    phase1_nondemo_duration <- 0
  if (is.null(phase2_nondemo_duration) || length(phase2_nondemo_duration) == 0)
    phase2_nondemo_duration <- 0
  
  survival_to_terminal_phase <- if (cohort_stock_nondemo_start_cycle > 0) {
    if (phase2_exists) {
      cohort_stock_nondemo_end_phase2 / cohort_stock_nondemo_start_cycle
    } else {
      cohort_stock_nondemo_end_phase1 / cohort_stock_nondemo_start_cycle
    }
  } else {
    0
  }

  if (phase2_exists) {
    offtake_heads_nondemo_phase2 <- cohort_stock_nondemo_annual_entrants * survival_to_terminal_phase
    offtake_heads_nondemo_phase1 <- 0
  } else {
    offtake_heads_nondemo_phase1 <- cohort_stock_nondemo_annual_entrants * survival_to_terminal_phase
    offtake_heads_nondemo_phase2 <- 0
  }
  
  offtake_heads_assessment_nondemo_phase1 <- offtake_heads_nondemo_phase1 / time_horizon * simulation_duration
  offtake_heads_assessment_nondemo_phase2 <- offtake_heads_nondemo_phase2 / time_horizon * simulation_duration
  
  if (length(offtake_heads_assessment_nondemo_phase1) == 0) offtake_heads_assessment_nondemo_phase1 <- 0
  if (length(offtake_heads_assessment_nondemo_phase2) == 0) offtake_heads_assessment_nondemo_phase2 <- 0
  
  list(
    offtake_heads_nondemo_phase1 = offtake_heads_nondemo_phase1,
    offtake_heads_nondemo_phase2 = offtake_heads_nondemo_phase2,
    offtake_heads_assessment_nondemo_phase1 = offtake_heads_assessment_nondemo_phase1,
    offtake_heads_assessment_nondemo_phase2 = offtake_heads_assessment_nondemo_phase2
  )
}
