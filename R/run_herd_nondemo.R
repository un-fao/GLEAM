#' Run Non-Demographic Herd Simulation
#'
#' Runs the non-demographic (production-cycle) sub-model for each \code{herd_id} and
#' non-demographic cohort block in a long-format input table. The function supports up to
#' two sequential phases per cohort block (identified by \code{phase_id} = 1 and optionally 2),
#' simulates survival through productive phases (and partial remainders), computes average
#' stock over the simulated horizon, and computes total offtake over the assessment period.
#'
#' @param cohort_non_demo_input A \code{data.table} in long format with one row per
#'   \code{herd_id} \eqn{\times} cohort block \eqn{\times} phase.
#'   The table must include the required columns below and **must contain \code{phase_id}**
#'   (used to identify phase 1 and optional phase 2).
#'   \describe{
#'     \item{herd_id}{Character. Herd identifier.}
#'     \item{cohort}{Character. Non-demographic cohort code. Currently, cohort *blocks* are
#'       determined by \code{substr(cohort, 1, 2)} and must be one of:
#'       \itemize{
#'         \item \code{"FN"}: non-demographic female animals
#'         \item \code{"MN"}: non-demographic male animals
#'       }
#'     \item{phase_id}{Integer. Phase within a cycle: \code{1} (required) and \code{2} (optional).}
#'     \item{duration_cycle_productive_phase_non_demo}{Numeric. Length of the productive phase
#'       for the given phase (days).}
#'     \item{mort_rate}{Numeric. Mortality fraction applied over the productive phase for the
#'       given phase (unitless fraction).}
#'   }
#'
#' @param herd_level_data A \code{data.table} with one row per \code{herd_id} providing the
#'   total annual entrants to distribute across cycle starts for each cohort block:
#'   \describe{
#'     \item{herd_id}{Character. Herd identifier (join key).}
#'     \item{cohort_fem_stock_annual_non_demographic}{Numeric. Total annual entrants for the
#'       \code{"FN"} block (heads / simulated period).}
#'     \item{cohort_mal_stock_annual_non_demographic}{Numeric. Total annual entrants for the
#'       \code{"MN"} block (heads / simulated period).}
#'       \item{duration_rest_between_cycles}{Numeric. Duration of resting/empty phase between cycles for the assessed non-demographic cohort (days).}
#'   }
#'
#' @param assessment_duration Numeric. Length of the assessment period (days) used to compute
#'   offtake during the assessment window. Defaults to \code{365}.
#'
#' @details
#' For each \code{herd_id}, the function iterates over cohort blocks (\code{"FN"} and \code{"MN"}).
#' For each block it:
#' \enumerate{
#'   \item Reads phase parameters from \code{phase_id == 1} (and \code{phase_id == 2} if present).
#'   \item Computes cycle geometry over the simulation horizon (fixed at \code{simulated_days = 365}):
#'     number of full cycles plus partial remainder durations for phase 1 and phase 2.
#'   \item Distributes the annual entrants from \code{herd_level_data} across cycle starts
#'     using \code{\link{calc_nondemo_start_sizes}}.
#'   \item Simulates stock dynamics for each phase (full cycle and partial remainder) using
#'     \code{\link{calc_nondemo_phase}}.
#'   \item Computes average stock over the horizon for each phase using
#'     \code{\link{calc_nondemo_avg_stock_phase_horizon}}.
#'   \item Computes total and assessment-window offtake using
#'     \code{\link{calc_nondemo_offtake_total_horizon}}.
#' }
#'
#' Results are written back into the corresponding rows of \code{cohort_non_demo_input}:
#' \describe{
#'   \item{size_avg_unscaled}{Average stock over the simulation horizon (unscaled).}
#'   \item{duration}{Partial remainder duration for that phase (days).}
#'   \item{offtake_number_unscaled}{Total offtake over the full simulated horizon (unscaled).}
#'   \item{offtake_number_assessment_unscaled}{Offtake over \code{assessment_duration} (unscaled).}
#' }
#'
#' The simulation horizon is currently fixed to \code{365} days to align with the demographic
#' herd model outputs used elsewhere in the package.
#'
#' @return A \code{data.table} with the same rows as \code{cohort_non_demo_input} and additional
#'   output columns added/updated:
#'   \code{size_stock_unscaled}, \code{duration}, \code{offtake_number_unscaled},
#'   \code{offtake_number_assessment_unscaled}.
#' }
#'
#' @examples
#' \dontrun{
#' 
#' # Upload input files
#' 
#'cohort_non_demo_input <- fread(system.file(
#'   "extdata/example_cohort_data_nondemographic.csv",
#'   package = "gleam"
#' ))
#'
#' herd_level_data <- fread(system.file(
#'   "extdata/example_herd_level_data_nondemographic.csv",
#'   package = "gleam"
#' ))
#'
#' # Run the code
#' results <- run_non_demographic_herd_simulation(
#'   cohort_non_demo_input = cohort_non_demo_input,
#'   herd_level_data = herd_level_data,
#'   assessment_duration = 365
#' )
#' 
#' # Access the results
#' results
#' 
#' }
#'
#' @export

run_non_demographic_herd_simulation <- function(
    cohort_non_demo_input,
    herd_level_data,
    assessment_duration = 365
) {
  
  stopifnot(data.table::is.data.table(cohort_non_demo_input))
  stopifnot(data.table::is.data.table(herd_level_data))
  
  req <- c(
    "herd_id","cohort",
    "duration_cycle_productive_phase_non_demo",
    "mort_rate"
  )
  miss <- setdiff(req, names(cohort_non_demo_input))
  if (length(miss)) stop("Missing required columns: ", paste(miss, collapse = ", "))
  
  req <- c(
    "herd_id",
    "cohort_fem_stock_annual_non_demographic",
    "cohort_mal_stock_annual_non_demographic",
    "duration_rest_between_cycles"
  )
  miss <- setdiff(req, names(herd_level_data))
  if (length(miss)) stop("Missing required columns: ", paste(miss, collapse = ", "))
  
  
  res <- data.table::copy(cohort_non_demo_input)
  data.table::setkey(res, herd_id, cohort, phase_id)
  
  for (hid in unique(res$herd_id)) {
    
    herd_rows <- res[herd_id == hid]
    blocks <- unique(substr(herd_rows$cohort, 1, 2))  # e.g. FN, MN
    entrants_row <- herd_level_data[herd_id == hid]
    
    
    for (b in blocks) {
      
      if (!(b %in% c("FN","MN"))) next
      
      cohort_stock_annual_entrants <- if (b == "FN") {
        entrants_row$cohort_fem_stock_annual_non_demographic
      } else { # b == "MN"
        entrants_row$cohort_mal_stock_annual_non_demographic
      }
      
      rows <- herd_rows[substr(cohort, 1, 2) == b]
      data.table::setorder(rows, phase_id)
      
      r1 <- rows[phase_id == 1][1]
      r2 <- rows[phase_id == 2][1]
      has2 <- rows[phase_id == 2, .N] > 0
      
      # ---- Step 2: read parameters ---
      duration_phase1_nondemographic <- r1$duration_cycle_productive_phase_non_demo
      mort_rate_phase1 <- r1$mort_rate
      
      duration_phase2_nondemographic <- if (has2) r2$duration_cycle_productive_phase_non_demo else 0
      mort_rate_phase2 <- if (has2) r2$mort_rate else 0
      
      duration_rest_between_cycles<-entrants_row$duration_rest_between_cycles
      
      # ---- Step 3: geometry ----
      geom <- calc_nondemo_cycle_geometry(duration_phase1_nondemographic, 
                                          duration_phase2_nondemographic, 
                                          duration_rest_between_cycles, 
                                          simulated_days = 365)
      
      
      # ---- Step 4: calculate entrants to phase 1  ----
      start_size <- calc_nondemo_start_sizes(cohort_stock_annual_non_demographic = cohort_stock_annual_entrants,
                                             total_cycle_starts_to_distribute = geom$total_cycle_starts_to_distribute)
      
      
      
      # ---- Step 5: simulate phase 1 (full + partial) ----
      full_simulation_phase1 <- calc_nondemo_phase(start_stock = start_size, 
                                                   duration_phase_non_demo = duration_phase1_nondemographic, 
                                                   mort_rate_phase = mort_rate_phase1, 
                                                   max_simulation_days_phase = duration_phase1_nondemographic)
      
      
      partial_simulation_phase1 <- calc_nondemo_phase(
        start_stock = start_size,
        duration_phase_non_demo = duration_phase1_nondemographic,
        mort_rate_phase = mort_rate_phase1,
        max_simulation_days_phase = geom$partial_phase1_duration)
      
      
      # ---- Step 6: simulate phase 2 (linked start = end of phase 1) ----
      cohort_stock_start_phase2 <- full_simulation_phase1$stock$end
      
      full_simulation_phase2 <- calc_nondemo_phase(start_stock = cohort_stock_start_phase2, 
                                                   duration_phase_non_demo = duration_phase2_nondemographic, 
                                                   mort_rate_phase = mort_rate_phase2, 
                                                   max_simulation_days_phase = duration_phase2_nondemographic)
      
      
      partial_simulation_phase2 <- calc_nondemo_phase(
        start_stock = cohort_stock_start_phase2,
        duration_phase_non_demo = duration_phase2_nondemographic,
        mort_rate_phase = mort_rate_phase2,
        max_simulation_days_phase = geom$partial_phase2_duration)
      
      
      # ---- Step 7: average stock ----
      cohort_stock_avg_phase1 <- calc_nondemo_avg_stock_phase_horizon(
        full_phase = full_simulation_phase1,
        partial_phase = partial_simulation_phase1,
        number_full_cycles_non_demographic = geom$number_full_cycles_non_demographic,
        simulated_days = 365
      )
      
      cohort_stock_avg_phase2 <- calc_nondemo_avg_stock_phase_horizon(
        full_phase = full_simulation_phase2,
        partial_phase = partial_simulation_phase2,
        number_full_cycles_non_demographic = geom$number_full_cycles_non_demographic,
        simulated_days = 365
      )
      
      
      # ---- Step 8: offtake (only last existing phase) ----
      off <- calc_nondemo_offtake_total_horizon(
        stock_end_phase1 = full_simulation_phase1$stock$end,
        stock_end_phase2 = full_simulation_phase2$stock$end,
        number_full_cycles_non_demographic = geom$number_full_cycles_non_demographic,
        partial_phase1_duration = geom$partial_phase1_duration,
        partial_phase2_duration = geom$partial_phase2_duration,
        duration_phase1_nondemographic = duration_phase1_nondemographic,
        duration_phase2_nondemographic = duration_phase2_nondemographic,
        assessment_duration = assessment_duration,
        simulated_days = 365
        
      )
      
      # ---- Step 9: write back FN1/MN1 ----
      # phase 1 row
      res[herd_id == hid & cohort == r1$cohort & phase_id == 1, `:=`(
        size_stock_unscaled = cohort_stock_avg_phase1,
        duration = geom$partial_phase1_duration,
        offtake_number_unscaled = off$offtake_number_phase1,
        offtake_number_assessment_unscaled = off$offtake_assessment_phase1
      )]
      
      # phase 2 row
      if (has2) {
        res[herd_id == hid & cohort == r2$cohort & phase_id == 2, `:=`(
          size_stock_unscaled = cohort_stock_avg_phase2,
          duration = geom$partial_phase2_duration,
          offtake_number_unscaled = off$offtake_number_phase2,
          offtake_number_assessment_unscaled = off$offtake_assessment_phase2
        )]
      }
    }
  }
  
  res[]
}
