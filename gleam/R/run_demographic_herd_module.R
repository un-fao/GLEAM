#' Run Demographic Herd Module Pipeline
#'
#' This function takes herd- and cohort-level demographic inputs and estimates a steady-state
#' sex–age herd structure compatible with downstream calculations in the Global Livestock
#' Environmental Assessment Model (GLEAM) computational pipeline [run_gleam()]. 
#' In addition to cohort population sizes, it derives
#' population growth rates, and offtake numbers.
#' The steady state is defined as a constant sex–age cohort structure over time,
#' with population size potentially growing or declining at a constant rate. 
#'
#' @details
#' The function operates under a \strong{steady-state assumption}: demographic parameters
#' are constant over time, so the population converges to a stable cohort composition and
#' a constant annual growth rate. Once this regime is reached, the model
#' computes cohort population sizes (start/end/average), cohort shares, and offtake totals.
#'
#' A key feature of this implementation is that it applies demography at a \strong{daily}
#' resolution. Annual mortality and offtake inputs are converted into daily hazards and
#' daily transition probabilities under competing risks (death vs. offtake vs. survival).
#'
#' Conceptually, this corresponds to the steady-state demographic approach implemented in
#' Dynmod \emph{STEADY1} (Lesnoff, 2013), adapted here to a daily time-step formulation within
#' an R workflow and fully integrated into the GLEAM computational pipeline.
#'
#' ## Model structure
#'
#' The population is divided by sex (female/male) and age class (juvenile/subadult/adult),
#' represented by six cohorts:
#' \itemize{
#'   \item \code{FJ}, \code{FS}, \code{FA} (female juvenile, subadult, adult)
#'   \item \code{MJ}, \code{MS}, \code{MA} (male juvenile, subadult, adult)
#' }
#'
#' Only adult females (\code{FA}) contribute to reproduction. Births are distributed between
#' females and males using \code{birth_fraction_female}. Reproduction is assumed to be
#' distributed over time (no birth pulse). Daily fecundity rates are computed in
#' \code{\link{calc_fecundity_rates}}.
#'
#' ## Dynamics and parameters
#'
#' Herd dynamics result from:
#' \itemize{
#'   \item births (driven by \code{parturition_rate} and \code{litter_size})
#'   \item natural deaths (driven by \code{death_rate})
#'   \item removals by offtake (driven by \code{offtake_rate})
#'   \item cohort aging / growth transitions (driven by \code{cohort_duration_days})
#'   \item optional diversion of animals from the demographic pathway into the non-demographic
#'   pathway at cohort transitions
#' }
#'
#' As in Dynmod, \code{offtake_rate} is interpreted as a \emph{net removal rate} for the cohort
#' (e.g. slaughter), while \code{death_rate} represents
#' natural mortality excluding offtake.
#'
#' ## Diversion into the non-demographic block
#'
#' This implementation can divert part of the demographic flow into the
#' non-demographic block. Diversion is controlled at herd level through:
#' \itemize{
#'   \item \code{prop_nondemo_fem_juv}: fraction of female juveniles diverted when transitioning
#'   from \code{FJ -> FS}
#'   \item \code{prop_nondemo_mal_juv}: fraction of male juveniles diverted when transitioning
#'   from \code{MJ -> MS}
#' }
#'
#' Internally, these herd-level inputs are expanded into the named vector
#' \code{proportion_nondemographic}, which is aligned with the six demographic
#' cohorts (\code{FJ}, \code{FS}, \code{FA}, \code{MJ}, \code{MS}, \code{MA}).
#' In the current demographic herd module, only the juvenile entries are populated
#' from user inputs and the remaining cohort entries are set to zero.
#'
#' Diversion is applied after the model computes the number of animals leaving a
#' cohort through aging or progression, and before those animals are added to the
#' next demographic cohort. For example:
#' \itemize{
#'   \item a share of \code{FJ -> FS} transitions is removed from the demographic female flow
#'   and counted as entrants to the female non-demographic block
#'   \item a share of \code{MJ -> MS} transitions is removed from the demographic male flow
#'   and counted as entrants to the male non-demographic block
#' }
#'
#' The diverted animals are reported in
#' \code{cohort_stock_annual_nondemographic}, which represents the annual number
#' of animals leaving the demographic model and entering the non-demographic
#' component. When diversion fractions are set to zero, demographic transitions
#' reduce to the original no-diversion case.
#'
#' ## Competing risks and conversion to daily probabilities
#'
#' Mortality and offtake are treated as **competing risks** within each cohort: at any time an
#' animal can survive, die, or be offtaken.Annual inputs are converted to daily hazards and then
#' daily transition probabilities in \code{\link{calc_transition_probabilities}}.
#'
#' Internally, the model:
#' \enumerate{
#'   \item Converts annual mortality (\code{death_rate}) into a daily mortality hazard.
#'   \item Solves for the daily offtake hazard such that the implied offtake probability matches
#'   \code{offtake_rate} under competing risks.
#'   \item Computes daily probabilities of death, offtake, and survival from the hazards.
#' }
#'
#' ## Steady state
#'
#' Under constant parameters, the cohort structure converges to a stable composition and a
#' stable population growth rate. This function seeks that steady state by
#' iterating the demographic system (see \code{\link{calc_steady_state_structure}}) starting from \code{initial_herd_structure} until changes 
#' in cohort-specific growth rates of sex–age cohort proportions (\eqn{\lambda}) fall below \code{min_lambda_change},
#' or until \code{max_simulation_years} is reached.
#'
#' ## Projection of population size
#' 
#' The steady-state solution obtained here provides:
#' \itemize{
#'   \item cohort shares used to scale herd-level population sizes,
#'   \item a stable annual herd growth rate,
#'   \item internally consistent death, offtake, and survival probabilities.
#' }
#'
#' These outputs are subsequently used to project one year of population dynamics 
#' (\code{\link{calc_projected_population_size}}) and to summarise annual offtake and stock variation
#' (\code{\link{calc_summary_offtake}}).
#' In both the steady-state and projected-population calculations, diversion to the
#' non-demographic block is treated as a competing outflow on the relevant cohort
#' transition, separate from death and offtake.
#' 
#'
#' @references
#' Lesnoff, M. (2013). \emph{DYNMOD: A spreadsheet interface for demographic projections of tropical
#' livestock populations, User's manual}. CIRAD, Montpellier, France.
#'
#' @param cohort_level_data A `data.table` with the one row per herd and cohort, and the following mandatory columns:
#'   \describe{
#'     \item{`herd_id`}{Character. Unique identifier for the herd, repeated for each cohort belonging to the same herd.}
#'     \item{`cohort_short`}{Character. Sex- and age-specific cohort code describing the production stage of the animals. Supported values include:
#'   \itemize{
#'     \item \code{FA}: adult females (from age at first parturition)
#'     \item \code{FS}: sub-adult females (from weaning to age at first parturition)
#'     \item \code{FJ}: juvenile females (from birth to weaning)
#'     \item \code{MA}: adult males (from age at first breeding)
#'     \item \code{MS}: sub-adult males (from weaning to age at first breeding)
#'     \item \code{MJ}: juvenile males (from birth to weaning)
#'     }
#'       }
#'     \item{`cohort_duration_days`}{Numeric vector of length 6. Amount of time that each animal spends in a specific cohort (days).}
#'     \item{`offtake_rate`}{Numeric vector of length 6. Annual proportion of animals removed from the herd for each sex-age cohort (fraction).}
#'     \item{`death_rate`}{Numeric vector of length 6. Fraction of deaths in a herd over a year for each sex-age cohort (fraction).}
#'   }
#' @param herd_level_data A `data.table` with one row per herd, and the following mandatory columns:
#'   \describe{
#'     \item{`herd_id`}{Character. Unique identifier for the herd, repeated for each cohort belonging to the same herd.}
#'     \item{`parturition_rate`}{Numeric. Average annual number of parturitions per female animal (# parturitions/adult female/year). A herd-level reproductive performance indicator calculated as the total number of parturitions (deliveries) occurring during a year divided by the number of adult females potentially able to give birth during that year.}
#'     \item{`litter_size`}{Numeric. Average number of offspring born per parturition (# offspring/parturition). This value can be calculated as the total number of offspring born divided by the total number of parturitions during the year.}
#'     \item{`birth_fraction_female`}{Numeric. Female birth fraction, defined as the probability that a newborn offspring is female (fraction). Can be calculated  as the number of female offspring born divided by the total number of offspring born.}
#'     \item{`herd_size_total`}{Numeric. Total population size at the start of the year, including all cohorts (# heads).}
#'     \item{`prop_nondemo_mal_juv`}{Numeric. Fraction of male juveniles diverted into the non-demographic stream at the moment they transition to the next age class (fraction).}
#'     \item{`prop_nondemo_fem_juv`}{Numeric. Fraction of female juveniles diverted into the non-demographic stream at the moment they transition to the next age class (fraction).}
#'   }
#' @param initial_herd_structure Named numeric vector of length 6. Initial number of individuals in each of the 6 sex-age cohorts used 
#' to bootstrap the steady-state simulation (# heads).These values are used as starting points for the iterative simulation and 
#' do not affect the final steady-state results (only convergence speed). Default is `c(FJ = 100, FS = 50, FA = 30, MJ = 100, MS = 50, MA = 30)`. 
#' @param max_simulation_years Numeric. Maximum number of years to simulate (years). Defaults to `100`.
#' @param min_lambda_change Numeric. Convergence threshold for changes in cohort-specific growth rates of sex–age cohort proportions (lambda).
#' Iterations of the herd simulation stop when the absolute change in lambda between successive iterations falls below this threshold. Defaults to `1e-9`.
#' @param show_indicator Logical. Whether to display progress indicators during simulation.
#'   Defaults to `TRUE`.
#'@param simulation_duration Numeric. Length of the assessment period (days).
#'
#' @return A named list with two elements:
#'   \describe{
#'     \item{`cohort_level_results`}{A `data.table` with one row per herd and cohort containing all original
#'       `cohort_level_data` columns plus the following simulation results:
#'       \itemize{
#'         \item `cohort_stock_size_unscaled` - Numeric. Average population size in each of the 6 demographic sex–age cohorts (cohorts = `FJ`, `FS`, `FA`, `MJ`, `MS`, `MA`), not yet scaled to the total livestock population (herd_size_total), (# heads).
#'         This corresponds to `cohort_stock_average` returned by \code{\link{calc_projected_population_size}}.
#'         \item `cohort_stock_annual_nondemographic` Numeric. Total number of animals entering the non-demographic component of the model over the simulated period, disaggregated by demographic sex–age cohorts (cohorts = `FJ`, `FS`, `FA`, `MJ`, `MS`, `MA`) (heads).
#'         \item `offtake_heads` - Numeric vector of length 6. Total number of animals removed via offtake over the year, aggregated to 6 sex–age cohorts (heads/year) (cohorts = `FJ`, `FS`, `FA`, `MJ`, `MS`, `MA`).
#'         \item `offtake_heads_assessment` - Numeric vector of length 6. Total number of animals removed via offtake over the assessment period, aggregated to 6 sex–age cohorts (heads/assessment period) (cohorts = `FJ`, `FS`, `FA`, `MJ`, `MS`, `MA`).
#'       }
#'     }
#'     \item{`herd_level_results`}{A `data.table` with one row per herd containing all original
#'       `herd_level_data` columns plus the following herd-level simulation results:
#'       \itemize{
#'         \item `growth_rate_herd` - Numeric. Annualized growth rate at which the herd size reaches steady state (fraction).
#'       }
#'     }
#'   }
#'
#' @seealso
#' \code{\link{calc_fecundity_rates}},
#' \code{\link{calc_transition_probabilities}},
#' \code{\link{calc_steady_state_structure}},
#' \code{\link{calc_projected_population_size}},
#' \code{\link{calc_summary_offtake}}
#' 
#' @examples
#' \donttest{
#' # Load herd simulation inputs (cohort- and herd-level)
#' herd_simulation_chrt_dt <- data.table::fread(system.file(
#'   "extdata/run_modules_examples/herd_simulation_input_chrt_data.csv",
#'   package = "gleam"
#' ))
#' herd_simulation_hrd_dt <- data.table::fread(system.file(
#'   "extdata/run_modules_examples/herd_simulation_input_hrd_data.csv",
#'   package = "gleam"
#' ))
#'
#' # Run herd simulation
#' results <- run_demographic_herd_module(
#'   cohort_level_data = herd_simulation_chrt_dt,
#'   herd_level_data = herd_simulation_hrd_dt,
#'   simulation_duration = 365,
#'   show_indicator = FALSE
#' )
#'
#' # Access results
#' names(results)
#' }
#'
#' @export
#'
#' @importFrom data.table := .SD .I .N setkey setkeyv uniqueN
run_demographic_herd_module <- function(
    cohort_level_data,
    herd_level_data,
    initial_herd_structure = c(FJ = 100, FS = 50, FA = 30, MJ = 100, MS = 50, MA = 30),
    max_simulation_years = 100,
    min_lambda_change = 1e-9,
    show_indicator = TRUE,
    simulation_duration = 365
) {

  # --- Step 1: Validate Inputs -----------------------------------------------
  validate_run_demographic_herd_module_inputs(cohort_level_data, herd_level_data)

  # Show progress indicator if requested
  if (show_indicator) {
    cli::cli_status("\U1F552 Simulating the herd structure, please wait\U2026")
  }

  # --- Step 2: Prepare Data for Processing -----------------------------------
  # Create working copies
  cohort_level_results <- data.table::copy(cohort_level_data)
  herd_level_results <- data.table::copy(herd_level_data)

  # Set keys for fast lookups
  data.table::setkey(cohort_level_results, herd_id, cohort_short)
  data.table::setkey(herd_level_results, herd_id)
  data.table::setkey(herd_level_data, herd_id)

  # Get unique herd IDs to process
  unique_herd_ids <- unique(cohort_level_results$herd_id)

  # Define valid cohort names (used for result mapping loop)
  cohort_order <- gleam_cohorts_demographic

  # --- Step 3: Process Each Herd ---------------------------------------------
  for (current_herd_id in unique_herd_ids) {

    # Lookup herd-level parameters (single row)
    herd_params <- herd_level_data[herd_id == current_herd_id]

    # Lookup cohort-level data for this herd (should be exactly 6 rows)
    cohort_rows <- cohort_level_results[herd_id == current_herd_id]
    
    # Non demographic cohorts vector, which applies the
    # diversion during juvenile → sub-adult transitions.
    proportion_nondemographic <- c(
      FJ = herd_params$prop_nondemo_fem_juv,
      FS = 0,
      FA = 0,
      MJ = herd_params$prop_nondemo_mal_juv,
      MS = 0,
      MA = 0
    )

    # Calculate fecundity rates (herd-level)
    # Fecundity rates represent the daily number of births per adult female
    fecundity_result <- calc_fecundity_rates(
      parturition_rate = herd_params$parturition_rate,
      litter_size = herd_params$litter_size,
      birth_fraction_female = herd_params$birth_fraction_female
    )

    fecundity_female <- fecundity_result$fecundity_female
    fecundity_male <- fecundity_result$fecundity_male

    # Build cohort-specific vectors from long-format data
    # The core scientific functions expect named vectors with one value per cohort
    duration_vec <- cohort_rows$cohort_duration_days
    offtake_rate_vec <- cohort_rows$offtake_rate
    death_rate_vec <- cohort_rows$death_rate
    names(duration_vec) <- cohort_rows$cohort_short
    names(offtake_rate_vec) <- cohort_rows$cohort_short
    names(death_rate_vec) <- cohort_rows$cohort_short

    # Calculate transition probabilities
    # Converts annual rates to daily probabilities for death, offtake, survival, and growth
    transition_result <- calc_transition_probabilities(
      cohort_duration_days = duration_vec,
      offtake_rate = offtake_rate_vec,
      death_rate = death_rate_vec
    )

    # Simulate steady-state population structure
    # Runs iterative simulation until population growth rates stabilize
    structure_result <- calc_steady_state_structure(
      initial_herd_structure = initial_herd_structure,
      max_simulation_years = max_simulation_years,
      min_lambda_change = min_lambda_change,
      fecundity_female = fecundity_female,
      fecundity_male = fecundity_male,
      probability_death = transition_result$probability_death,
      probability_offtake = transition_result$probability_offtake,
      probability_growth = transition_result$probability_growth,
      proportion_nondemographic = proportion_nondemographic
    )

    # Project one year of population dynamics
    # Simulates a full year (366 days) under steady-state conditions
    popsize_result <- calc_projected_population_size(
      herd_size_total = herd_params$herd_size_total,
      fecundity_female = fecundity_female,
      fecundity_male = fecundity_male,
      probability_death = transition_result$probability_death,
      probability_offtake = transition_result$probability_offtake,
      probability_growth = transition_result$probability_growth,
      growth_rate_herd = structure_result$growth_rate_herd,
      herd_structure = structure_result$herd_structure,
      cohort_share = structure_result$cohort_share,
      proportion_nondemographic = proportion_nondemographic
    )

    # Calculate offtake summary statistics
    offtake_result <- calc_summary_offtake(
      cohort_stock_start = popsize_result$cohort_stock_start,
      cohort_stock_end_projected = popsize_result$cohort_stock_end_projected,
      cohort_stock_average = popsize_result$cohort_stock_average,
      cohort_offtake_heads = popsize_result$cohort_offtake_heads,
      simulation_duration = simulation_duration
    )

    # Map simulation results back to cohort-level results
    # Assign values from named vectors to the appropriate cohort rows
    for (cohort_name in cohort_order) {
      cohort_level_results[
        herd_id == current_herd_id & cohort_short == cohort_name,
        `:=`(
          cohort_stock_size_unscaled = popsize_result$cohort_stock_average[cohort_name],
          cohort_stock_annual_nondemographic = popsize_result$cohort_stock_annual_nondemographic[cohort_name],
          offtake_heads = offtake_result$offtake_heads[cohort_name],
          offtake_heads_assessment = offtake_result$offtake_heads_assessment[cohort_name]
        )
      ]
    }

    # Map herd-level results
    herd_level_results[
      herd_id == current_herd_id,
      `:=`(growth_rate_herd = structure_result$growth_rate_herd)
    ]

  } # End of loop over herds

  # Clear progress indicator if it was shown
  if (show_indicator) {
    cli::cli_status_clear()
    cli::cli_alert_success("Herd simulation complete.")
  }

  # Return separate result tables
  return(
    list(
      cohort_level_results = cohort_level_results,
      herd_level_results = herd_level_results
    )
  )
}
