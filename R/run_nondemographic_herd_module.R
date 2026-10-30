#' Run Non-Demographic Herd Module Pipeline
#'
#' This function takes herd- and cohort-level non-demographic inputs and simulates
#' production-cycle dynamics for the non-demographic cohorts used in the Global
#' Livestock Environmental Assessment Model (GLEAM) computational pipeline
#' [run_gleam()]. It computes phase-specific average stock sizes and offtake
#' numbers.
#' Annual average stock and offtake include animals that entered before the
#' assessment year, so productive phases can span year boundaries. Stock is
#' returned unscaled; [run_all_herd_module()] applies any supplied herd-size target.
#'
#' @details
#' The function operates over a \strong{365-day simulation horizon} to maintain
#' consistency with the demographic herd module. For each herd and
#' non-demographic cohort block, it computes how many complete production cycles
#' fit within the horizon, whether an additional partial cycle is present, and
#' how annual entrants should be distributed across cycle starts.
#'
#' A key feature of this implementation is that it applies mortality at the
#' \strong{phase level}. Phase-level mortality fractions are converted to implied
#' daily mortality probabilities, and the resulting daily survival is used to
#' compute end-of-phase stock, average stock over the horizon, and total offtake.
#'
#' ## Model structure
#'
#' The non-demographic population is divided into two cohort blocks:
#' \itemize{
#'   \item \code{FN}: non-demographic female animals
#'   \item \code{MN}: non-demographic male animals
#' }
#'
#' Each cohort block may contain up to two sequential productive phases,
#' identified by \code{nondemo_productive_phase_id = 1} and optionally
#' \code{nondemo_productive_phase_id = 2}. A
#' resting period between cycles is supplied at herd level through
#' \code{rest_between_nondemo_cycles_duration}.
#'
#' ## Dynamics and parameters
#'
#' Non-demographic herd dynamics result from:
#' \itemize{
#'   \item annual entrants into each non-demographic cohort block
#'   \item mortality during each productive phase (\code{death_rate})
#'   \item phase duration (\code{cohort_duration_days}), either supplied directly in the cohort table or derived later from herd-level phase-duration inputs
#'   \item the duration of the resting period between cycles
#' }
#'
#' For each herd and cohort block, the function:
#' \enumerate{
#'   \item identifies phase 1 and optional phase 2 from \code{cohort_level_data}
#'   \item computes cycle geometry using \code{\link{calc_nondemo_cycle_geometry}}
#'   \item distributes annual entrants across cycle starts using \code{\link{calc_nondemo_start_sizes}}
#'   \item simulates stock dynamics within each phase using \code{\link{calc_nondemo_phase}}
#'   \item computes average stock over the assessment horizon using \code{\link{calc_nondemo_avg_stock_phase_horizon}}
#'   \item computes total and assessment-window offtake using \code{\link{calc_nondemo_offtake_total_horizon}}
#' }
#'
#' @param cohort_level_data A `data.table` with one row per herd, cohort block,
#' and productive phase, and the following mandatory columns:
#'   \describe{
#'     \item{`herd_id`}{Character. Unique identifier for the herd, repeated for each cohort block belonging to the same herd.}
#'     \item{`cohort_short`}{Character. Non-demographic cohort code describing the production block of the animals. Supported values include:
#'       \itemize{
#'         \item \code{FN}: non-demographic female animals
#'         \item \code{MN}: non-demographic male animals
#'       }
#'     }
#'     \item{`nondemo_productive_phase_id`}{Numeric. Productive phase identifier within a cycle. \code{1} is required and \code{2} is optional.}
#'     \item{`death_rate`}{Numeric. Fraction of deaths occurring during the productive phase (fraction).}
#'   }
#'   \code{cohort_duration_days} is not required for \code{FN} and \code{MN}
#'   when phase durations are supplied in the herd table.
#' @param herd_level_data A `data.table` with one row per herd, and the following mandatory columns:
#'   \describe{
#'     \item{`herd_id`}{Character. Unique identifier for the herd.}
#'     \item{`cohort_stock_fem_annual_nondemo`}{Numeric. Total annual entrants into the \code{FN} cohort block over the simulated period (# heads / simulated period).}
#'     \item{`cohort_stock_mal_annual_nondemo`}{Numeric. Total annual entrants into the \code{MN} cohort block over the simulated period (# heads / simulated period).}
#'     \item{`rest_between_nondemo_cycles_duration`}{Numeric. Duration of resting/empty phase between cycles for the assessed non-demographic cohort (days).}
#'     \item{`phase1_nondemo_fem_duration_days`}{Numeric. Duration of productive phase 1 for the female non-demographic cohort (\code{FN}) (days).}
#'     \item{`phase2_nondemo_fem_duration_days`}{Numeric. Duration of productive phase 2 for the female non-demographic cohort (\code{FN}) (days).}
#'     \item{`phase1_nondemo_mal_duration_days`}{Numeric. Duration of productive phase 1 for the male non-demographic cohort (\code{MN}) (days).}
#'     \item{`phase2_nondemo_mal_duration_days`}{Numeric. Duration of productive phase 2 for the male non-demographic cohort (\code{MN}) (days).}
#'   }
#' @param simulation_duration Numeric. Length of the reporting period used to scale non-demographic outputs (days).
#'   Defaults to `365`.
#' @param show_indicator Logical. Whether to display progress indicators during simulation.
#'   Defaults to `TRUE`.
#'
#' @return A named list with two elements:
#'   \describe{
#'     \item{`cohort_level_results`}{A `data.table` with one row per retained herd
#'       \eqn{\times} non-demographic cohort block \eqn{\times} productive phase,
#'       containing the original `cohort_level_data` columns plus:
#'       \describe{
#'         \item{`cohort_duration_days`}{Numeric. Productive phase duration used
#'           in the simulation (days). For non-demographic cohorts (\code{FN}
#'           and \code{MN}), \code{cohort_duration_days} is not required when
#'           phase durations are supplied in the herd table. The code fills it
#'           from the herd values, which override any cohort values. If a herd
#'           value is missing, the cohort value is used instead.}
#'         \item{`cohort_stock_size_unscaled`}{Numeric. Average population size by cohort block and productive phase before any later herd-level harmonization (# heads).}
#'         \item{`partial_nondemo_phase_duration`}{Numeric. Duration of the terminal partial productive phase occurring within the fixed 365-day simulation horizon (days).}
#'         \item{`offtake_heads_unscaled`}{Numeric. Total number of animals leaving the cohort block over the fixed 365-day simulation horizon (# heads).}
#'         \item{`offtake_heads_assessment_unscaled`}{Numeric. Total number of animals leaving the cohort block over `simulation_duration` (# heads / simulated period).}         
#'         \item{`number_full_nondemo_cycles`}{Integer. Number of complete cycles fully contained within the fixed 365-day simulation horizon (full cycles / simulated period).}
#'         \item{`total_nondemo_cycle_starts_to_distribute`}{Integer. Total number of cycle starts within the fixed 365-day simulation horizon used to distribute annual entrants (cycle starts / simulated period).}
#'       }}
#'     \item{`herd_level_results`}{A `data.table` with one row per `herd_id`
#'       containing the original `herd_level_data` columns plus:
#'       \describe{
#'         \item{`total_nondemo_fem_duration_days`}{Numeric. Total duration of productive phases assigned to the female non-demographic cohort block (\code{FN}) (days).}
#'         \item{`total_nondemo_mal_duration_days`}{Numeric. Total duration of productive phases assigned to the male non-demographic cohort block (\code{MN}) (days).}
#'       }}
#'   }
#'
#' @seealso
#' \code{\link{calc_nondemo_cycle_geometry}},
#' \code{\link{calc_nondemo_start_sizes}},
#' \code{\link{calc_nondemo_phase}},
#' \code{\link{calc_nondemo_avg_stock_phase_horizon}},
#' \code{\link{calc_nondemo_offtake_total_horizon}}
#'
#' @examples
#' \donttest{
#' # Load non-demographic herd simulation inputs (FN/MN cohorts and annual entrants)
#' nondemo_chrt_dt <- data.table::fread(system.file(
#'   "extdata/run_modules_examples/nondemographic_herd_input_chrt_data.csv",
#'   package = "gleam"
#' ))
#' nondemo_hrd_dt <- data.table::fread(system.file(
#'   "extdata/run_modules_examples/nondemographic_herd_input_hrd_data.csv",
#'   package = "gleam"
#' ))
#'
#' # Run non-demographic herd simulation
#' results <- run_nondemographic_herd_module(
#'   cohort_level_data = nondemo_chrt_dt,
#'   herd_level_data = nondemo_hrd_dt,
#'   simulation_duration = 365,
#'   show_indicator = TRUE
#' )
#' }
#'
#' @export

run_nondemographic_herd_module <- function(
    cohort_level_data,
    herd_level_data,
    simulation_duration = 365,
    show_indicator = TRUE
) {
  # --- Step 1: Validate Inputs -----------------------------------------------
  validate_run_nondemographic_herd_module_inputs(
    cohort_level_data,
    herd_level_data
  )

  # Show progress indicator if requested
  if (show_indicator) {
    cli::cli_status("\U1F552 Simulating the non-demographic herd, please wait\U2026")
  }
  
  # --- Step 2: Prepare Data for Processing -----------------------------------
  # Create working copies
  cohort_level_results <- data.table::copy(cohort_level_data)
  herd_level_results <- data.table::copy(herd_level_data)

  # Ensure optional herd-level phase-duration columns exist
  for (nm in c(
    "phase1_nondemo_fem_duration_days",
    "phase2_nondemo_fem_duration_days",
    "phase1_nondemo_mal_duration_days",
    "phase2_nondemo_mal_duration_days"
  )) {
    if (!nm %in% names(herd_level_results)) {
      herd_level_results[, (nm) := NA_real_]
    }
  }

  # Ensure the cohort-level duration column exists
  if (!"cohort_duration_days" %in% names(cohort_level_results)) {
    cohort_level_results[, cohort_duration_days := NA_real_]
  }

  # Assign productive-phase durations to non-demographic cohort rows
  # Herd-level duration inputs override cohort-level values when available
  cohort_level_results[
    ,
    cohort_duration_days := assign_nondemographic_phase_durations(
      cohort_short = cohort_short,
      nondemo_productive_phase_id = nondemo_productive_phase_id,
      cohort_duration_days = cohort_duration_days,
      phase1_nondemo_fem_duration_days = herd_level_results[
        .SD, on = "herd_id"
      ][["phase1_nondemo_fem_duration_days"]],
      phase2_nondemo_fem_duration_days = herd_level_results[
        .SD, on = "herd_id"
      ][["phase2_nondemo_fem_duration_days"]],
      phase1_nondemo_mal_duration_days = herd_level_results[
        .SD, on = "herd_id"
      ][["phase1_nondemo_mal_duration_days"]],
      phase2_nondemo_mal_duration_days = herd_level_results[
        .SD, on = "herd_id"
      ][["phase2_nondemo_mal_duration_days"]]
    ),
    by = .I
  ]

  # Calculate total productive-phase duration for each non-demographic block
  herd_level_results[
    ,
    c(
      "total_nondemo_fem_duration_days",
      "total_nondemo_mal_duration_days"
    ) := calc_nondemographic_total_durations(
      cohort_short = cohort_level_results[herd_id == .BY$herd_id, cohort_short],
      cohort_duration_days = cohort_level_results[herd_id == .BY$herd_id, cohort_duration_days]
    ),
    by = herd_id
  ]

  # --- Step 3: Process Each Herd and Cohort Block ----------------------------
  for (herd_id_selected in unique(cohort_level_results$herd_id)) {
    
    # Lookup cohort- and herd-level inputs for this herd
    herd_rows <- cohort_level_results[herd_id == herd_id_selected]
    blocks <- unique(substr(herd_rows$cohort_short, 1, 2))  # FN and/or MN
    entrants_row <- herd_level_data[herd_id == herd_id_selected]
    
    
    for (cohort_block_selected in blocks) {
      # Select annual entrants for the current non-demographic block
      cohort_stock_nondemo_annual_entrants <- if (cohort_block_selected == "FN") {
        entrants_row$cohort_stock_fem_annual_nondemo
      } else { # Male non-demographic block
        entrants_row$cohort_stock_mal_annual_nondemo
      }
      
      # Identify and order productive phases for the current cohort block
      rows <- herd_rows[substr(cohort_short, 1, 2) == cohort_block_selected]
      data.table::setorder(rows, nondemo_productive_phase_id)
      
      r1 <- rows[nondemo_productive_phase_id == 1][1L, ]
      r2 <- rows[nondemo_productive_phase_id == 2][1L, ]
      has2 <- rows[nondemo_productive_phase_id == 2, .N] > 0
      
      # Extract phase-specific durations and mortality rates
      phase1_nondemo_duration <- r1$cohort_duration_days
      death_rate_phase1 <- r1$death_rate
      
      phase2_nondemo_duration <- if (has2) r2$cohort_duration_days else 0
      death_rate_phase2 <- if (has2) r2$death_rate else 0
      
      rest_between_nondemo_cycles_duration <- entrants_row$rest_between_nondemo_cycles_duration
      
      # Calculate cycle geometry over the fixed simulation horizon
      geom <- calc_nondemo_cycle_geometry(phase1_nondemo_duration = phase1_nondemo_duration, 
                                          phase2_nondemo_duration = phase2_nondemo_duration,
                                          rest_between_nondemo_cycles_duration = rest_between_nondemo_cycles_duration)
      
      # Distribute entrants across cycle starts
      start_size <- calc_nondemo_start_sizes(cohort_stock_nondemo_annual_entrants = cohort_stock_nondemo_annual_entrants,
                                             total_nondemo_cycle_starts_to_distribute = geom$total_nondemo_cycle_starts_to_distribute)
      
      
      # Simulate stock dynamics through productive phase 1
      full_simulation_phase1 <- calc_nondemo_phase(cohort_stock_nondemo_start_by_phase = start_size$cohort_stock_nondemo_start_cycle, 
                                                   productive_phase_nondemo_duration = phase1_nondemo_duration, 
                                                   death_rate_nondemo_phase = death_rate_phase1, 
                                                   max_simulation_days_nondemo_phase = phase1_nondemo_duration)

      
      # Simulate productive phase 2 using the end stock of phase 1
      cohort_stock_start_phase2 <- full_simulation_phase1$cohort_stock_nondemo$end
      
      full_simulation_phase2 <- calc_nondemo_phase(cohort_stock_nondemo_start_by_phase = cohort_stock_start_phase2, 
                                                   productive_phase_nondemo_duration = phase2_nondemo_duration, 
                                                   death_rate_nondemo_phase = death_rate_phase2, 
                                                   max_simulation_days_nondemo_phase = phase2_nondemo_duration)

      
      # Calculate average stock over the simulation horizon
      cohort_stock_avg_phase1 <- calc_nondemo_avg_stock_phase_horizon(
        full_nondemo_phase = full_simulation_phase1,
        total_nondemo_cycle_starts_to_distribute = geom$total_nondemo_cycle_starts_to_distribute
      )$cohort_stock_size_unscaled
      
      cohort_stock_avg_phase2 <- calc_nondemo_avg_stock_phase_horizon(
        full_nondemo_phase = full_simulation_phase2,
        total_nondemo_cycle_starts_to_distribute = geom$total_nondemo_cycle_starts_to_distribute
      )$cohort_stock_size_unscaled

      # Calculate offtake from the last existing productive phase
      # (phase 2 when present; otherwise phase 1)
      off <- calc_nondemo_offtake_total_horizon(
        cohort_stock_nondemo_end_phase1 = full_simulation_phase1$cohort_stock_nondemo$end,
        cohort_stock_nondemo_end_phase2 = full_simulation_phase2$cohort_stock_nondemo$end,
        cohort_stock_nondemo_annual_entrants = cohort_stock_nondemo_annual_entrants,
        cohort_stock_nondemo_start_cycle = start_size$cohort_stock_nondemo_start_cycle,
        number_full_nondemo_cycles = geom$number_full_nondemo_cycles,
        partial_phase1_nondemo_duration = geom$partial_phase1_nondemo_duration,
        partial_phase2_nondemo_duration = geom$partial_phase2_nondemo_duration,
        phase1_nondemo_duration = phase1_nondemo_duration,
        phase2_nondemo_duration = phase2_nondemo_duration,
        simulation_duration = simulation_duration
        
      )
      
      # Map phase 1 results back to the cohort-level table
      cohort_level_results[herd_id == herd_id_selected & cohort_short == r1$cohort_short & nondemo_productive_phase_id == 1, `:=`(
        offtake_rate = 1,
        cohort_stock_size_unscaled = cohort_stock_avg_phase1,
        partial_nondemo_phase_duration = geom$partial_phase1_nondemo_duration,
        offtake_heads_unscaled = off$offtake_heads_nondemo_phase1,
        offtake_heads_assessment_unscaled = off$offtake_heads_assessment_nondemo_phase1,
        number_full_nondemo_cycles = geom$number_full_nondemo_cycles,
        total_nondemo_cycle_starts_to_distribute = geom$total_nondemo_cycle_starts_to_distribute
      )]
      
      # Map phase 2 results when the optional second phase is present
      if (has2) {
        cohort_level_results[herd_id == herd_id_selected & cohort_short == r2$cohort_short & nondemo_productive_phase_id == 2, `:=`(
          offtake_rate = 1,
          cohort_stock_size_unscaled = cohort_stock_avg_phase2,
          partial_nondemo_phase_duration = geom$partial_phase2_nondemo_duration,
          offtake_heads_unscaled = off$offtake_heads_nondemo_phase2,
          offtake_heads_assessment_unscaled = off$offtake_heads_assessment_nondemo_phase2,
          number_full_nondemo_cycles = geom$number_full_nondemo_cycles,
          total_nondemo_cycle_starts_to_distribute = geom$total_nondemo_cycle_starts_to_distribute
        )]
      }
    } # End of loop over non-demographic cohort blocks
  } # End of loop over herds

  # Remove cohort-phase rows with non-positive simulated stock
  if ("cohort_stock_size_unscaled" %in% names(cohort_level_results)) {
    cohort_level_results <- cohort_level_results[
      is.na(cohort_stock_size_unscaled) | cohort_stock_size_unscaled > 0
    ]
  }

  # Clear progress indicator if it was shown
  if (show_indicator) {
    cli::cli_status_clear()
    cli::cli_alert_success("Non-demographic herd simulation complete.")
  }
  
  # Return separate result tables
  list(
    cohort_level_results = cohort_level_results[],
    herd_level_results = herd_level_results[]
  )
}
