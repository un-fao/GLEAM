#' Run Herd Simulation
#'
#' Performs the full steady-state demographic simulation of herd cohorts across species,
#' production systems, and countries. This includes modeling of fecundity, mortality, offtake,
#' cohort transitions, population structure, and final population sizes.
#'
#' ## Overview
#'
#' This function accepts a long-format table with one row per cohort and performs herd
#' structure simulation when required. The simulation process follows these steps:
#'
#' 1. **Input Validation**: Ensures data integrity and required columns
#' 2. **Fecundity Calculation**: Computes daily birth rates for males and females
#' 3. **Transition Probabilities**: Calculates daily probabilities for death, offtake, survival, and growth
#' 4. **Steady-State Simulation**: Simulates population dynamics until convergence
#' 5. **Population Projection**: Projects one year of population dynamics
#' 6. **Offtake Summary**: Calculates offtake statistics
#' 7. **Result Mapping**: Maps simulation results back to long-format rows
#'
#' ## Input Format
#'
#' The input must be a table. Each herd (identified by `herd_id`)
#' must have exactly 6 rows, one for each cohort: FJ, FS, FA, MJ, MS, MA.
#'
#' - **FJ**: Female Juvenile
#' - **FS**: Female Subadult
#' - **FA**: Female Adult
#' - **MJ**: Male Juvenile
#' - **MS**: Male Subadult
#' - **MA**: Male Adult
#'
#' @param herd_data A `data.table` with mandatory columns:
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
#'   Additional required columns for herd-level parameters (these should be identical across
#'   all cohorts for a given `herd_id`):
#'   \itemize{
#'     \item `parturition_rate` - Annual parturition rate (births per adult female per year)
#'     \item `litsize` - Average litter size (offspring per parturition)
#'     \item `female_birth_fraction` - Proportion of births that are female (0-1)
#'     \item `size_total` - Total population size for the herd
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
#'
#' @return A `data.table` with all original input
#'   columns preserved, plus the following simulation results appended:
#'   \describe{
#'     \item{`share`}{Proportion of total population in this cohort at steady-state}
#'     \item{`growth_rate_pop`}{Annual population growth rate at steady-state}
#'     \item{`size`}{Population size in this cohort at the start of the year}
#'     \item{`size_end`}{Population size in this cohort at the end of the year}
#'     \item{`size_avg`}{Average population size in this cohort over the year}
#'     \item{`offtake_number`}{Total number of animals removed via offtake from this cohort}
#'     \item{`offtake_share`}{Offtake rate relative to starting population size}
#'     \item{`offtake_share_avg`}{Offtake rate relative to average population size}
#'     \item{`prob_death`}{Daily probability of death for this cohort}
#'     \item{`prob_offtake`}{Daily probability of offtake for this cohort}
#'     \item{`prob_survival`}{Daily probability of survival (neither death nor offtake)}
#'     \item{`prob_growth`}{Daily probability of transitioning to the next age class}
#'   }
#'
#' @examples
#' \dontrun{
#' # Load example input data from the package
#' example_path <- system.file(
#'   "extdata/example_herd_data.csv",
#'   package = "gleam"
#' )
#' herd_data <- data.table::fread(example_path)
#'
#' # Run herd simulation
#' results <- run_herd_simulation(herd_data)
#'
#' # View results
#' print(results)
#' }
#'
#' @export
#'
#' @importFrom data.table := .SD .I .N setkey setkeyv uniqueN
run_herd_simulation <- function(
    herd_data,
    initial_structure = c(FJ = 100, FS = 50, FA = 30, MJ = 100, MS = 50, MA = 30),
    max_years = 100,
    lambda_threshold = 1e-9,
    show_indicator = TRUE
) {

  # --- Step 1: Validate Inputs -----------------------------------------------

  # Validate that input is a data.table
  if (!data.table::is.data.table(herd_data)) {
    cli::cli_abort("{.arg herd_data} must be a data.table.")
  }

  # Check for empty input and row count
  if (nrow(herd_data) == 0 || nrow(herd_data) %% 6 != 0) {
    cli::cli_abort(
      "{.arg herd_data} ust contain at least one row and a number rows divisible by 6."
    )
  }

  # Define required columns for validation
  required_cols <- c(
    "herd_id", # Unique identifier for each herd
    "cohort", # Cohort code (FJ, FS, FA, MJ, MS, MA)
    "duration", # Duration of cohort stage in days
    "offtake_rate", # Annual offtake rate
    "mort_rate", # Annual mortality rate
    "parturition_rate", # Herd-level: annual parturition rate
    "litsize", # Herd-level: average litter size
    "female_birth_fraction", # Herd-level: proportion of female births
    "size_total" # Herd-level: total population size
  )

  # Check for missing required columns
  missing_cols <- setdiff(required_cols, names(herd_data))
  if (length(missing_cols) > 0) {
    cli::cli_abort("Missing required columns: {.val {missing_cols}}")
  }

  # Validate cohort values - must be one of the 6 valid cohort codes
  valid_cohorts <- c("FJ", "FS", "FA", "MJ", "MS", "MA")
  invalid_cohorts <- setdiff(unique(herd_data$cohort), valid_cohorts)
  if (length(invalid_cohorts) > 0) {
    cli::cli_abort(
      "Invalid cohort values: {.val {invalid_cohorts}}. ",
      "Must be one of: {.val {valid_cohorts}}"
    )
  }

  # Validate that each herd has exactly 6 cohorts (one for each valid cohort)
  # This is critical because the simulation requires all 6 cohorts to function correctly
  cohort_counts <- herd_data[, .N, by = herd_id]
  herds_with_wrong_count <- cohort_counts[N != 6]
  if (nrow(herds_with_wrong_count) > 0) {
    cli::cli_abort(
      "Each herd_id must have exactly 6 rows (one per cohort). ",
      "Found incorrect counts for herd_ids: {.val {herds_with_wrong_count$herd_id}}"
    )
  }

  # Validate that each herd has all 6 required cohorts (no duplicates, no missing)
  herd_cohort_completeness <- herd_data[
    , list(has_all_cohorts = setequal(cohort, valid_cohorts)),
    by = herd_id
  ]
  incomplete_herds <- herd_cohort_completeness[has_all_cohorts == FALSE, herd_id]
  if (length(incomplete_herds) > 0) {
    cli::cli_abort(
      "Each herd_id must have exactly one row for each of the 6 cohorts. ",
      "Incomplete herds: {.val {incomplete_herds}}"
    )
  }

  # Validate that herd-level parameters are consistent across cohorts within each herd
  # These parameters should be identical for all cohorts of the same herd
  herd_level_cols <- c(
    "parturition_rate", "litsize", "female_birth_fraction", "size_total"
  )
  for (col in herd_level_cols) {
    inconsistent <- herd_data[
      , list(n_unique = data.table::uniqueN(get(col))),
      by = herd_id
    ][n_unique > 1]
    if (nrow(inconsistent) > 0) {
      cli::cli_warn(
        "Herd-level parameter {.field {col}} differs across cohorts for herds: ",
        "{.val {inconsistent$herd_id}}. Using first value for each herd."
      )
    }
  }

  # Show progress indicator if requested
  if (show_indicator) {
    cli::cli_status("\U1F552 Running herd simulation, please wait\U2026")
  }

  # --- Step 2: Prepare Data for Processing ------------------------------------

  # Create working copy (data.table operations modify in-place, so we copy to preserve original)
  result <- data.table::copy(herd_data)

  # Set keys for fast lookups by herd_id and cohort
  # This dramatically speeds up filtering operations
  data.table::setkey(result, herd_id, cohort)

  # Get unique herd IDs to process
  unique_herd_ids <- unique(result$herd_id)

  # Define the standard cohort order used throughout the simulation
  # This order matches what the core scientific functions expect
  cohort_order <- c("FJ", "FS", "FA", "MJ", "MS", "MA")

  # --- Step 3: Process Each Herd ---------------------------------------------

  for (current_herd_id in unique_herd_ids) {

    # Extract data for this herd
    # Get all rows belonging to this herd (should be exactly 6 rows)
    herd_rows <- result[herd_id == current_herd_id]

    # Extract herd-level parameters (same for all cohorts in a herd)
    herd_params <- herd_rows[1]

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
    # in the correct order (FJ, FS, FA, MJ, MS, MA)

    # Create lookup table to map cohorts to standard order
    cohort_lookup <- data.table::data.table(
      cohort = cohort_order,
      index = seq_along(cohort_order)
    )
    data.table::setkey(cohort_lookup, cohort)

    # Extract and order values to build vectors in correct sequence
    herd_rows_indexed <- cohort_lookup[herd_rows, on = "cohort"]
    herd_rows_ordered <- herd_rows_indexed[order(index)]

    # Build vectors in correct order and name them
    duration_vec <- herd_rows_ordered$duration
    offtake_rate_vec <- herd_rows_ordered$offtake_rate
    mort_rate_vec <- herd_rows_ordered$mort_rate
    names(duration_vec) <- names(offtake_rate_vec) <- names(mort_rate_vec) <- cohort_order

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
      offtake = popsize_result$offtake
    )

    # Map simulation results back to long-format rows
    # Assign values from named vectors to the appropriate cohort rows
    for (cohort_name in cohort_order) {
      # Assign simulation results to this cohort's row
      matching_rows <- result[herd_id == current_herd_id & cohort == cohort_name]

      if (nrow(matching_rows) > 0) {
        result[herd_id == current_herd_id & cohort == cohort_name,
               `:=`(
                 share = structure_result$share[cohort_name],
                 growth_rate_pop = structure_result$growth_rate_pop,
                 size = popsize_result$size[cohort_name],
                 size_end = popsize_result$size_end[cohort_name],
                 size_avg = popsize_result$size_avg[cohort_name],
                 offtake_number = offtake_result$offtake_number[cohort_name],
                 offtake_share = offtake_result$offtake_share[cohort_name],
                 offtake_share_avg = offtake_result$offtake_share_avg[cohort_name],
                 prob_death = transition_result$prob_death[cohort_name],
                 prob_offtake = transition_result$prob_offtake[cohort_name],
                 prob_survival = transition_result$prob_survival[cohort_name],
                 prob_growth = transition_result$prob_growth[cohort_name]
               )]
      }
    }

  } # End of loop over herds

  # Clear progress indicator if it was shown
  if (show_indicator) {
    cli::cli_status_clear()
    cli::cli_alert_success("Herd simulation complete.")
  }

  return(result)
}
