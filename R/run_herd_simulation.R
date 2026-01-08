#' Run Herd Simulation
#'
#' Performs the full steady-state demographic simulation of herd cohorts across species,
#' production systems, and countries. This includes modeling of fecundity, mortality, offtake,
#' cohort transitions, population structure, and final population sizes.
#'
#' ## Overview
#'
#' This function accepts separate tables for herd-level and cohort-level data and performs herd
#' structure simulation when required. The simulation process follows these steps:
#'
#' 1. **Input Validation**: Ensures data integrity and required columns
#' 2. **Fecundity Calculation**: Computes daily birth rates for males and females
#' 3. **Transition Probabilities**: Calculates daily probabilities for death, offtake, survival, and growth
#' 4. **Steady-State Simulation**: Simulates population dynamics until convergence
#' 5. **Population Projection**: Projects one year of population dynamics
#' 6. **Offtake Summary**: Calculates offtake statistics
#' 7. **Result Mapping**: Maps simulation results back to separate result tables
#'
#' ## Input Format
#'
#' The function requires two separate input tables:
#'
#' - **`cohort_data`**: One row per cohort (6 rows per herd: FJ, FS, FA, MJ, MS, MA)
#' - **`herd_level_data`**: One row per herd with herd-level parameters
#'
#' Each herd (identified by `herd_id`) must have exactly 6 rows in `cohort_data`, one for each cohort:
#'
#' - **FJ**: Female Juvenile
#' - **FS**: Female Subadult
#' - **FA**: Female Adult
#' - **MJ**: Male Juvenile
#' - **MS**: Male Subadult
#' - **MA**: Male Adult
#'
#' @param cohort_data A `data.table` with mandatory columns:
#'   \describe{
#'     \item{`herd_id`}{Unique identifier for each herd. All cohorts belonging to
#'       the same herd must share the same `herd_id`.}
#'     \item{`cohort`}{Cohort code. Must be one of: "FJ", "FS", "FA", "MJ", "MS", "MA".
#'       Each `herd_id` must have exactly one row for each of these 6 cohorts.}
#'     \item{`duration`}{Duration of the cohort stage in days. This is the time an animal
#'       spends in this particular life stage.}
#'     \item{`offtake_rate`}{Annual offtake rate for the cohort (proportion removed per year).
#'       This represents the fraction of animals removed from the herd (e.g., for slaughter).}
#'     \item{`mort_rate`}{Annual mortality rate for the cohort (proportion dying per year).
#'       This represents natural mortality, excluding offtake.}
#'   }
#' @param herd_level_data A `data.table` with one row per herd and mandatory columns:
#'   \describe{
#'     \item{`herd_id`}{Unique identifier for each herd. Must match `herd_id` values in `cohort_data`.}
#'     \item{`parturition_rate`}{Annual parturition rate (births per adult female per year)}
#'     \item{`litsize`}{Average litter size (offspring per parturition)}
#'     \item{`female_birth_fraction`}{Proportion of births that are female (0-1)}
#'     \item{`size_total`}{Total population size for the herd}
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
#'         \item `share` - Proportion of total population in this cohort at steady-state
#'         \item `size` - Population size in this cohort at the start of the year
#'         \item `size_end` - Population size in this cohort at the end of the year
#'         \item `size_avg` - Average population size in this cohort over the year
#'         \item `offtake_number` - Total number of animals removed via offtake from this cohort
#'         \item `offtake_share` - Offtake rate relative to starting population size
#'         \item `offtake_share_avg` - Offtake rate relative to average population size
#'         \item `prob_death` - Daily probability of death for this cohort
#'         \item `prob_offtake` - Daily probability of offtake for this cohort
#'         \item `prob_survival` - Daily probability of survival (neither death nor offtake)
#'         \item `prob_growth` - Daily probability of transitioning to the next age class
#'       }
#'     }
#'     \item{`herd_results`}{A `data.table` with one row per herd containing all original
#'       `herd_level_data` columns plus the following herd-level simulation results:
#'       \itemize{
#'         \item `growth_rate_pop` - Annual population growth rate at steady-state
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
#' results <- run_herd_simulation(cohort_data, herd_level_data, assessment_duration=200)
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
    assessment_duration
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
