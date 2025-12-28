#' GLEAM Pipeline: Complete Livestock Assessment Workflow
#'
#' This function orchestrates the complete GLEAM workflow, processing livestock data
#' through herd simulation, feed rations, and energy requirements calculations. It serves as the
#' main entry point for running comprehensive livestock assessments.
#'
#' The pipeline follows this sequence:
#' 1. Load and validate herd input data
#' 2. Run herd simulation to get population dynamics
#' 3. Run feed rations to calculate dietary metrics
#' 4. Calculate energy requirements and dry matter intake
#' 5. Return results
#'
#' @param herd_data_path Character. Path to the GLEAM herd input CSV file.
#'   Defaults to the package example data.
#' @param rations_share_path Character. Path to feed rations CSV file.
#'   Defaults to the package example data.
#' @param feed_params_path Character. Path to feed parameters CSV file.
#'   Defaults to the package example data.
#' @param initial_structure Numeric vector. Initial population structure for simulation.
#'   Defaults to `c(FJ = 100, FS = 50, FA = 30, MJ = 100, MS = 50, MA = 30)`.
#' @param max_years Integer. Maximum simulation years for steady-state convergence.
#'   Defaults to `100`.
#' @param lambda_threshold Numeric. Convergence threshold for population growth rate.
#'   Defaults to `1e-9`.
#' @param show_progress Logical. Whether to display progress indicators.
#'   Defaults to `TRUE`.
#'
#' @return A `data.table` containing the complete GLEAM assessment results with:
#'   - Original herd input data
#'   - Population simulation results (structure, offtake, transitions)
#'   - Feed ration calculations (diet_ge, diet_me, diet_dig, diet_nitrogen)
#'   - Energy requirements (maintenance, activity, growth, lactation, work, fibre, pregnancy)
#'   - Dry matter intake calculations
#'   - Cohort-level weight metrics
#'
#' @examples
#' \dontrun{
#' # Run the complete pipeline with default settings
#' results <- run_gleam()
#' }
#'
#' @export
run_gleam <- function(
    herd_data_path = NULL,
    rations_share_path = NULL,
    feed_params_path = NULL,
    initial_structure = c(FJ = 100, FS = 50, FA = 30, MJ = 100, MS = 50, MA = 30),
    max_years = 100,
    lambda_threshold = 1e-9,
    show_progress = TRUE
) {

  # --- Step 1: Load and Validate Input Data ---------------------------------

  if (show_progress) {
    cli::cli_h1("Starting GLEAM Pipeline")
    cli::cli_status("Loading input data...")
  }

  # Load herd data (use package example if no path provided)
  if (is.null(herd_data_path)) {
    herd_data_path <- system.file("extdata/GLEAM_input_herd.csv", package = "gleam")
    if (herd_data_path == "") {
      stop("Package example data not found. Please provide a valid herd_data_path.")
    }
  }

  # Load feed rations data
  if (is.null(rations_share_path)) {
    rations_share_path <- system.file("extdata/GLEAM_input_FeedRations.csv", package = "gleam")
    if (rations_share_path == "") {
      stop("Package example feed rations data not found. Please provide a valid rations_share_path.")
    }
  }

  # Load feed parameters data
  if (is.null(feed_params_path)) {
    feed_params_path <- system.file("extdata/Feed_parameters.csv", package = "gleam")
    if (feed_params_path == "") {
      stop("Package example feed parameters data not found. Please provide a valid feed_params_path.")
    }
  }

  # Load and validate herd data
  if (!file.exists(herd_data_path)) {
    stop("Herd data file not found: ", herd_data_path)
  }

  herd_data <- data.table::fread(herd_data_path)[
    size_total >= 1,
  ][1:2]

  if (nrow(herd_data) == 0) {
    stop("Herd data file is empty or could not be read.")
  }

  # Load feed data
  rations_share <- data.table::fread(rations_share_path)
  feed_params <- data.table::fread(feed_params_path)

  # --- Step 2: Run Herd Simulation ------------------------------------------

  if (show_progress) {
    cli::cli_status("Running herd simulation...")
  }

  # Run herd simulation to get population dynamics
  herd_sim_results <- run_herd_simulation(
    herd_data = herd_data,
    initial_structure = initial_structure,
    max_years = max_years,
    lambda_threshold = lambda_threshold,
    show_indicator = FALSE
  )

  if (show_progress) {
    cli::cli_status("Herd simulation completed")
  }

  # --- Step 3: Run Feed Rations ---------------------------------------------

  if (show_progress) {
    cli::cli_status("Calculating feed rations...")
  }

  # Run feed rations calculation
  feed_results <- run_feed_rations(
    rations_share = rations_share,
    feed_params = feed_params,
    input_feed = herd_sim_results
  )

  if (show_progress) {
    cli::cli_status("Feed rations calculated")
  }

  # --- Step 4: Run Energy Requirements --------------------------------------

  if (show_progress) {
    cli::cli_status("Calculating energy requirements...")
  }

  # Keep only rows with valid positive average_weight values
  feed_results <- feed_results[average_weight > 0]
  feed_results$Animal_short <-  "CTL"
  feed_results <-  feed_results[final_weight > 0]
  # Run energy requirements calculation
  energy_results <- run_energy_requirements(feed_results)

  if (show_progress) {
    cli::cli_status("Energy requirements calculated")
  }

  return(energy_results)
}
