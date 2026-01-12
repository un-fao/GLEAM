#' Run Herd Simulation
#'
#' This function takes herd- and cohort-level demographic inputs and estimates a steady-state
#' sex–age herd structure compatible with downstream calculations in the Global Livestock
#' Environmental Assessment Model (GLEAM). In addition to cohort population sizes, it derives
#' population growth rates, and offtake numbers. 
#' 
#' 
#' @details
#' The function operates under a \strong{steady-state assumption}: demographic parameters
#' are constant over time, so the population converges to a stable cohort composition and
#' a constant annual growth rate (\eqn{\lambda}). Once this regime is reached, the model
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
#' females and males using \code{female_birth_fraction}. Reproduction is assumed to be
#' distributed over time (no birth pulse).
#'
#' ## Dynamics and parameters
#'
#' Herd dynamics result from:
#' \itemize{
#'   \item births (driven by \code{parturition_rate} and \code{litsize})
#'   \item natural deaths (driven by \code{mort_rate})
#'   \item removals by offtake (driven by \code{offtake_rate})
#'   \item cohort aging / growth transitions (driven by \code{duration})
#' }
#'
#' As in Dynmod, \code{offtake_rate} is interpreted as a \emph{net removal rate} for the cohort
#' (e.g. slaughter), while \code{mort_rate} represents
#' natural mortality excluding offtake.
#'
#' ## Competing risks and conversion to daily probabilities
#'
#' Mortality and offtake are treated as **competing risks** within each cohort: at any time an
#' animal can survive, die, or be offtaken. Annual inputs are converted to daily hazards and then
#' daily probabilities to avoid bias from interference between processes.
#'
#' Internally, the model:
#' \enumerate{
#'   \item Converts annual mortality (\code{mort_rate}) into a daily mortality hazard.
#'   \item Solves for the daily offtake hazard such that the implied offtake probability matches
#'   \code{offtake_rate} under competing risks.
#'   \item Computes daily probabilities of death, offtake, and survival from the hazards.
#' }
#'
#' ## Steady state
#'
#' Under constant parameters, the cohort structure converges to a stable composition and a
#' stable population growth rate (\eqn{\lambda}). This function seeks that steady state by
#' iterating the demographic system starting from \code{initial_structure} until changes in
#' \eqn{\lambda} fall below \code{lambda_threshold}, or until \code{max_years} is reached.
#'
#' Once steady state is reached, the model projects cohort sizes over the assessment period and
#' returns:
#' \itemize{
#'   \item cohort shares (\code{share})
#'   \item cohort sizes at start/end/average (\code{size}, \code{size_end}, \code{size_avg})
#'   \item cohort offtake totals (\code{offtake_number}) and assessment-scaled totals
#'         (\code{offtake_number_assessment})
#'   \item daily transition probabilities (\code{prob_death}, \code{prob_offtake}, \code{prob_survival},
#'         \code{prob_growth})
#' }
#'
#'
#' @references
#' Lesnoff, M. (2013). \emph{DYNMOD: A spreadsheet interface for demographic projections of tropical
#' livestock populations, User’s manual}. CIRAD, Montpellier, France.
#'
#' @param cohort_data A `data.table` with mandatory columns:
#'   \describe{
#'     \item{`herd_id`}{Character. Unique identifier for the herd, repeated for each cohort belonging to the same herd.}
#'     \item{`cohort`}{"Character scalar. Sex- and age-specific cohort code describing the production stage of the animals. Supported values include:
#'   \itemize{
#'     \item \code{FA}: adult females (from age at first parturition)
#'     \item \code{FS}: sub-adult females (from weaning to age at first parturition)
#'     \item \code{FJ}: juvenile females (from birth to weaning)
#'     \item \code{MA}: adult males (from age at first breeding)
#'     \item \code{MS}: sub-adult males (from weaning to age at first breeding)
#'     \item \code{MJ}: juvenile males (from birth to weaning)
#'     }
#'       }
#'     \item{`duration`}{Numeric. Amount of time that each animal spends in a specific cohort (days).}
#'     \item{`offtake_rate`}{Numeric. Annual proportion of animals removed from the herd for each sex-age cohort (fraction).}
#'     \item{`mort_rate`}{Numeric. Fraction of deaths in a herd over a year for each sex-age class (fraction).}
#'   }
#' @param herd_level_data A `data.table` with one row per herd and mandatory columns:
#'   \describe{
#'     \item{`herd_id`}{Character. Unique identifier for the herd, repeated for each cohort belonging to the same herd. Must match `herd_id` values in `cohort_data`.}
#'     \item{`parturition_rate`}{Numeric. Average annual number of parturitions per female animal (# parturitions/reproductive female/year). A herd-level reproductive performance indicator calculated as the total number of parturitions (deliveries) occurring during a year divided by the number of adult females potentially able to give birth during that year.}
#'     \item{`litsize`}{Numeric. Average number of offspring born per parturition (# offsprings/parturition). This value can be calculated as the total number of offspring born divided by the total number of parturitions during the year.}
#'     \item{`female_birth_fraction`}{Numeric. Female birth fraction, defined as the probability that a newborn offspring is female (fraction). Can be calculated  as the number of female offspring born divided by the total number of offspring born.}
#'     \item{`size_total`}{Numeric. Total population size at the start of the year, including all cohorts (# heads).}
#'   }
#' @param initial_structure A named numeric vector of initial population values used to
#'   bootstrap the steady-state simulation. Must be named with cohort codes:
#'   `c(FJ = 100, FS = 50, FA = 30, MJ = 100, MS = 50, MA = 30)`. These values are used
#'   as starting points for the iterative simulation and do not affect the final steady-state
#'   results (only convergence speed).
#' @param max_years Integer. Maximum number of simulation years to run when seeking a
#'   steady-state population structure. The simulation will stop earlier if convergence
#'   is detected. Defaults to `100`.
#' @param lambda_threshold Numeric. Tolerance threshold for detecting convergence in
#'   population growth rate. When the change in growth rate (lambda) across consecutive
#'   time steps falls below this threshold for all cohorts, steady-state is considered
#'   reached. Defaults to `1e-9`.
#' @param show_indicator Logical. Whether to display progress indicators during simulation.
#'   Defaults to `TRUE`.
#'@param assessment_duration Numeric. Length of the assessment period (days).
#'
#' @return A named list with two elements:
#'   \describe{
#'     \item{`cohort_results`}{A `data.table` with one row per cohort containing all original
#'       `cohort_data` columns plus the following simulation results:
#'       \itemize{
#'         \item `share` - Numeric. Final steady-state share of the 6 grouped sex-age classes  (cohorts = (`FJ`, `FS`, `FA`, `MJ`, `MS`, `MA`)) (fraction). Shares should sum to 1.
#'         \item `size` - Numeric. Population size in each of the 6 sex–age cohorts at the start of the year (cohorts = (`FJ`, `FS`, `FA`, `MJ`, `MS`, `MA`)) (# heads). 
#'         \item `size_end` - Numeric. Population size in each of the 6 sex–age cohorts at the end of the year, projected using the steady-state growth rate (cohorts = (`FJ`, `FS`, `FA`, `MJ`, `MS`, `MA`)) (# heads). 
#'         \item `size_avg` - Numeric. Average population size in each of the 6 sex–age cohorts over the year (cohorts = (`FJ`, `FS`, `FA`, `MJ`, `MS`, `MA`)) (# heads). Estimated from cohort_stock_start and cohort_stock_end_projected.
#'         \item `offtake_number` - Numeric. Total number of animals removed via offtake over the year, aggregated to 6 sex–age cohorts (cohorts = (`FJ`, `FS`, `FA`, `MJ`, `MS`, `MA`)) (heads/year)
#'         \item `offtake_number_assessment` - "Numeric. Total number of animals removed via offtake over the assessment period, aggregated to 6 sex–age cohorts (cohorts = (`FJ`, `FS`, `FA`, `MJ`, `MS`, `MA`)) (heads/year)
#'         \item `prob_growth` - Numeric. Probability of growing into the next age class for 6 cohorts (cohorts = (`FJ`, `FS`, `FA`, `MJ`, `MS`, `MA`)) (fraction).
#'       }
#'     }
#'     \item{`herd_results`}{A `data.table` with one row per herd containing all original
#'       `herd_level_data` columns plus the following herd-level simulation results:
#'       \itemize{
#'         \item `growth_rate_pop` - Numeric. Annualized growth rate at which the herd size reaches steady state (fraction).
#'       }
#'     }
#'   }
#'
#' @examples
#' \dontrun{
#' # Load example input data from the package
#' cohort_path <- system.file(
#'   "extdata/example_cohort_data.csv",
#'   package = "gleam"
#' )
#' herd_level_path <- system.file(
#'   "extdata/example_herd_level_data.csv",
#'   package = "gleam"
#' )
#' cohort_data <- data.table::fread(cohort_path)
#' herd_level_data <- data.table::fread(herd_level_path)
#'
#' # Run herd simulation
#' results <- run_herd_simulation(
#' cohort_data = cohort_data, herd_level_data = herd_level_data, assessment_duration = 200
#' )
#'
#' # Access results
#' print(results$cohort_results)
#' print(results$herd_results)
#' }
#'
#' @export
#'
#' @importFrom data.table := .SD .I .N setkey setkeyv uniqueN
run_herd_simulation <- function(
    cohort_data,
    herd_level_data,
    initial_structure = c(FJ = 100, FS = 50, FA = 30, MJ = 100, MS = 50, MA = 30),
    max_years = 100,
    lambda_threshold = 1e-9,
    show_indicator = TRUE,
    assessment_duration = 365
) {

  # --- Step 1: Validate Inputs -----------------------------------------------

  validate_herd_simulation_inputs(cohort_data, herd_level_data)

  # Show progress indicator if requested
  if (show_indicator) {
    cli::cli_status("\U1F552 Running herd simulation, please wait\U2026")
  }

  # --- Step 2: Prepare Data for Processing ------------------------------------

  # Create working copies
  cohort_result <- data.table::copy(cohort_data)
  herd_result <- data.table::copy(herd_level_data)

  # Set keys for fast lookups
  data.table::setkey(cohort_result, herd_id, cohort)
  data.table::setkey(herd_result, herd_id)
  data.table::setkey(herd_level_data, herd_id)

  # Get unique herd IDs to process
  unique_herd_ids <- unique(cohort_result$herd_id)

  # Define valid cohort names (used for result mapping loop)
  cohort_order <- c("FJ", "FS", "FA", "MJ", "MS", "MA")

  # --- Step 3: Process Each Herd ---------------------------------------------
  for (current_herd_id in unique_herd_ids) {

    # Lookup herd-level parameters (single row)
    herd_params <- herd_level_data[herd_id == current_herd_id]

    # Lookup cohort-level data for this herd (should be exactly 6 rows)
    cohort_rows <- cohort_result[herd_id == current_herd_id]

    # Calculate fecundity rates (herd-level)
    # Fecundity rates represent the daily number of births per adult female
    fecundity_result <- compute_fecundity_rates(
      parturition_rate = herd_params$parturition_rate,
      litsize = herd_params$litsize,
      fem_birth_fraction = herd_params$female_birth_fraction
    )

    fem_fec <- fecundity_result$fem_fec
    mal_fec <- fecundity_result$mal_fec

    # Build cohort-specific vectors from long-format data
    # The core scientific functions expect named vectors with one value per cohort
    duration_vec <- cohort_rows$duration
    offtake_rate_vec <- cohort_rows$offtake_rate
    mort_rate_vec <- cohort_rows$mort_rate
    names(duration_vec) <- cohort_rows$cohort
    names(offtake_rate_vec) <- cohort_rows$cohort
    names(mort_rate_vec) <- cohort_rows$cohort

    # Calculate transition probabilities
    # Converts annual rates to daily probabilities for death, offtake, survival, and growth
    transition_result <- compute_transition_probabilities(
      duration = duration_vec,
      offtake_rate = offtake_rate_vec,
      mort_rate = mort_rate_vec
    )

    # Simulate steady-state population structure
    # Runs iterative simulation until population growth rates stabilize
    structure_result <- simulate_steady_state_structure(
      initial_structure = initial_structure,
      max_years = max_years,
      min_lambda_change = lambda_threshold,
      fem_fec = fem_fec,
      mal_fec = mal_fec,
      prob_death = transition_result$prob_death,
      prob_offtake = transition_result$prob_offtake,
      prob_growth = transition_result$prob_growth
    )

    # Project one year of population dynamics
    # Simulates a full year (366 days) under steady-state conditions
    popsize_result <- project_population_size(
      size_total = herd_params$size_total,
      fem_fec = fem_fec,
      mal_fec = mal_fec,
      prob_death = transition_result$prob_death,
      prob_offtake = transition_result$prob_offtake,
      prob_growth = transition_result$prob_growth,
      growth_rate_pop = structure_result$growth_rate_pop,
      structure = structure_result$structure,
      share = structure_result$share
    )

    # Calculate offtake summary statistics
    offtake_result <- summarise_offtake(
      size = popsize_result$size,
      size_end = popsize_result$size_end,
      size_avg = popsize_result$size_avg,
      offtake = popsize_result$offtake,
      assessment_duration = assessment_duration
    )

    # Map simulation results back to cohort-level results
    # Assign values from named vectors to the appropriate cohort rows
    for (cohort_name in cohort_order) {
      cohort_result[
        herd_id == current_herd_id & cohort == cohort_name,
        `:=`(
          share = structure_result$share[cohort_name],
          size = popsize_result$size[cohort_name],
          size_end = popsize_result$size_end[cohort_name],
          size_avg = popsize_result$size_avg[cohort_name],
          offtake_number = offtake_result$offtake_number[cohort_name],
          offtake_number_assessment = offtake_result$offtake_number_assessment[cohort_name],
          offtake_share = offtake_result$offtake_share[cohort_name],
          offtake_share_avg = offtake_result$offtake_share_avg[cohort_name],
          prob_death = transition_result$prob_death[cohort_name],
          prob_offtake = transition_result$prob_offtake[cohort_name],
          prob_survival = transition_result$prob_survival[cohort_name],
          prob_growth = transition_result$prob_growth[cohort_name]
        )
      ]
    }

    # Map herd-level results
    herd_result[
      herd_id == current_herd_id,
      `:=`(growth_rate_pop = structure_result$growth_rate_pop)
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
      cohort_results = cohort_result,
      herd_results = herd_result
    )
  )
}
