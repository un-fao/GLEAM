#' Run the GLEAM pipeline
#'
#' Runs the core sequence of model modules to generate cohort-level outputs for a
#' livestock production system: herd simulation (optional), weights, feed rations,
#' energy requirements and DMI, enteric methane direct emissions, nitrogen balance,
#' direct emissions from manure management systems, feed emissions, production (milk, fibre, meat),
#' and allocation shares.
#' Accepts primary inputs only: one cohort-level master table, one herd-level master table,
#' feed rations, feed parameters, feed emissions, and manure management system tables.
#'
#' @param has_herd_structure Logical. If TRUE, use \code{cohort_level_data} directly
#'   as the cohort-level input for the weights module (skip herd simulation). If FALSE,
#'   run herd simulation first using \code{cohort_level_data} and \code{herd_level_data}.
#' @param cohort_level_data data.table. Cohort-level master table. Must have one row
#'   per cohort (6 cohorts per herd: FJ, FS, FA, MJ, MS, MA) and must include
#'   \code{animal} (full species name, e.g. Cattle, Buffalo) for each cohort. Data
#'   should not include columns that GLEAM calculates (validation will block them).
#'   May optionally include \code{ch4_mitigation_factor} (fraction of baseline enteric
#'   CH4 remaining after mitigation, 1 = no mitigation).
#' @param herd_level_data data.table. Herd-level master table (one row per herd).
#'   Must include \code{animal} (full species name, e.g. Cattle, Buffalo).
#' @param feed_rations data.table. Feed ration shares by cohort (see \code{\link{run_ration_quality_module}}).
#' @param feed_params data.table. Feed nutritional parameters (see \code{\link{run_ration_quality_module}}).
#' @param feed_emissions data.table. Feed production emission factors (see \code{\link{run_emissions_ration_module}}).
#' @param manure_management_system_fraction data.table. Cohort-level manure management
#'   system fractions (see \code{\link{run_emissions_manure_module}}).
#' @param manure_management_system_factors data.table. Manure management
#'   system factors (see \code{\link{run_emissions_manure_module}}).
#' @param simulation_duration Numeric. Length of the assessment period (days). Used by the herd
#'   simulation module (when \code{has_herd_structure} is FALSE) and by the production module
#'   (milk, fibre, meat). Defaults to \code{365}.
#' @param global_warming_potential_set Character. GWP-100 option for converting CH₄ and N₂O to CO₂-equivalents
#'   in aggregation results. One of \code{"AR6"} (default), \code{"AR5_excluding_carbon_feedback"},
#'   \code{"AR5_including_carbon_feedback"}, \code{"AR4"}.
#' @param show_indicator Logical. Whether to display progress indicators during the pipeline run.
#'
#' @return A named list containing:
#'   \describe{
#'     \item{cohort_level_results}{Cohort-level \code{data.table} with all computed
#'       outputs.}
#'     \item{herd_level_results}{Herd-level \code{data.table} (one row per herd).
#'       When \code{has_herd_structure} is FALSE, includes herd simulation outputs
#'       such as \code{growth_rate_herd}; otherwise returns the input
#'       \code{herd_level_data}.}
#'     \item{allocation_long}{Herd-level \code{data.table} in long format (one row
#'       per herd, emission variable, and commodity) with allocation shares.}
#'     \item{aggregation_results}{Named list from \code{\link{run_aggregation_module}} with herd-level
#'       totals: \code{results_emissions} (allocated emissions in kg CO₂eq),
#'       \code{results_feed}, \code{results_production}, \code{results_nitrogen}.}
#'   }
#'
#' @examples
#' # Example 1: You do NOT have herd structure — use cohort input for herd simulation.
#' # Pipeline runs herd simulation first, then the rest of the pipeline.
#' \dontrun{
#' path_run_gleam_examples <- system.file("extdata/run_gleam_examples", package = "gleam")
#'
#' master_chrt_lvl_no_structure_dt <- data.table::fread(file.path(
#'   path_run_gleam_examples, "master_chrt_lvl_no_structure_data.csv"
#' ))
#' master_hrd_lvl_dt <- data.table::fread(
#' file.path(path_run_gleam_examples, "master_hrd_lvl_data.csv")
#' )
#' feed_rations_chrt_dt <- data.table::fread(
#' file.path(path_run_gleam_examples, "feed_rations_share_chrt_data.csv")
#' )
#' feed_params_dt <- data.table::fread(system.file(
#'   "extdata/Parameters/feed/feed_params.csv",
#'   package = "gleam"
#' ))
#' feed_emissions_dt <- data.table::fread(system.file(
#'   "extdata/Parameters/feed/feed_emission_factors.csv",
#'   package = "gleam"
#' ))
#'
#' manure_management_system_fraction_dt <- data.table::fread(
#'   file.path(path_run_gleam_examples, "manure_management_system_fraction.csv")
#' )
#' manure_management_system_factors_dt <- data.table::fread(
#'   file.path(path_run_gleam_examples, "manure_management_system_factors.csv")
#' )
#'
#' results <- run_gleam(
#'   has_herd_structure = FALSE,
#'   cohort_level_data = master_chrt_lvl_no_structure_dt,
#'   herd_level_data = master_hrd_lvl_dt,
#'   feed_rations = feed_rations_chrt_dt,
#'   feed_params = feed_params_dt,
#'   feed_emissions = feed_emissions_dt,
#'   manure_management_system_fraction = manure_management_system_fraction_dt,
#'   manure_management_system_factors = manure_management_system_factors_dt,
#'   simulation_duration = 365
#' )
#' print(results$cohort_level_results)
#' print(results$allocation_long)
#' }
#'
#' # Example 2: You already HAVE herd structure — use cohort table and skip herd simulation.
#' # Pipeline skips herd simulation and uses this as the starting cohort table.
#' \dontrun{
#' path_run_gleam_examples <- system.file("extdata/run_gleam_examples", package = "gleam")
#'
#' master_chrt_lvl_structure_dt <- data.table::fread(file.path(
#'   path_run_gleam_examples, "master_chrt_lvl_structure_data.csv"
#' ))
#' master_hrd_lvl_dt <- data.table::fread(
#' file.path(path_run_gleam_examples, "master_hrd_lvl_data.csv")
#' )
#' feed_rations_chrt_dt <- data.table::fread(
#' file.path(path_run_gleam_examples, "feed_rations_share_chrt_data.csv")
#' )
#' feed_params_dt <- data.table::fread(system.file(
#'   "extdata/Parameters/feed/feed_params.csv",
#'   package = "gleam"
#' ))
#' feed_emissions_dt <- data.table::fread(system.file(
#'   "extdata/Parameters/feed/feed_emission_factors.csv",
#'   package = "gleam"
#' ))
#'
#' manure_management_system_fraction_dt <- data.table::fread(
#'   file.path(path_run_gleam_examples, "manure_management_system_fraction.csv")
#' )
#' manure_management_system_factors_dt <- data.table::fread(
#'   file.path(path_run_gleam_examples, "manure_management_system_factors.csv")
#' )
#'
#' results <- run_gleam(
#'   has_herd_structure = TRUE,
#'   cohort_level_data = master_chrt_lvl_structure_dt,
#'   herd_level_data = master_hrd_lvl_dt,
#'   feed_rations = feed_rations_chrt_dt,
#'   feed_params = feed_params_dt,
#'   feed_emissions = feed_emissions_dt,
#'   manure_management_system_fraction = manure_management_system_fraction_dt,
#'   manure_management_system_factors = manure_management_system_factors_dt,
#'   simulation_duration = 365,
#'   global_warming_potential_set = "AR6"
#' )
#' print(results$cohort_level_results)
#' print(results$allocation_long)
#' }
#' @export
run_gleam <- function(
    has_herd_structure = FALSE,
    cohort_level_data,
    herd_level_data,
    feed_rations,
    feed_params,
    feed_emissions,
    manure_management_system_fraction,
    manure_management_system_factors,
    simulation_duration = 365,
    global_warming_potential_set = "AR6",
    show_indicator = TRUE
) {

  # --- Step 1: Validate inputs ------------------------------------------------
  validate_run_gleam_inputs(
    has_herd_structure = has_herd_structure,
    cohort_level_data = cohort_level_data,
    herd_level_data = herd_level_data,
    feed_rations = feed_rations,
    feed_params = feed_params,
    feed_emissions = feed_emissions,
    manure_management_system_fraction = manure_management_system_fraction,
    manure_management_system_factors = manure_management_system_factors,
    simulation_duration = simulation_duration
  )

  # Show progress indicator if requested
  if (show_indicator) {
    cli::cli_h1("\U1F552 Running GLEAM pipeline\U2026")
  }

  # --- Step 2: Run herd simulation (or use provided structure) ----------------
  if (has_herd_structure) {
    gleam_chrt_data <- data.table::as.data.table(cohort_level_data)
    gleam_hrd_data <- data.table::as.data.table(herd_level_data)
  } else {
    herd_results <- run_demographic_herd_module(
      cohort_level_data = cohort_level_data,
      herd_level_data = herd_level_data,
      simulation_duration = simulation_duration,
      show_indicator = show_indicator
    )
    gleam_chrt_data <- herd_results$cohort_level_results
    gleam_hrd_data <- herd_results$herd_level_results
  }

  # --- Step 3: Run weights at cohort level ------------------------------------
  weights_results <- run_weights_module(
    cohort_level_data = gleam_chrt_data,
    herd_level_data = herd_level_data,
    show_indicator = show_indicator
  )

  gleam_chrt_data <- weights_results$cohort_level_results

  # --- Step 4: Summarize feed rations and merge -------------------------------
  feed_rations_summary <- run_ration_quality_module(
    rations_share = feed_rations,
    feed_params = feed_params,
    show_indicator = show_indicator
  )

  gleam_chrt_data <- merge(
    gleam_chrt_data,
    feed_rations_summary,
    by = c("herd_id", "animal", "cohort_short")
  )

  # --- Step 5: Run energy requirements and DMI --------------------------------
  gleam_chrt_data <- run_metabolic_energy_req_module(
    cohort_level_data = gleam_chrt_data,
    herd_level_data = herd_level_data,
    show_indicator = show_indicator
  )

  # --- Step 6: Run enteric methane direct emissions ---------------------------
  # ch4_mitigation_factor is optional cohort-level input
  gleam_chrt_data <- run_emissions_enteric_module(
    cohort_level_data = gleam_chrt_data,
    show_indicator = show_indicator
  )

  # --- Step 7: Run nitrogen balance -------------------------------------------
  gleam_chrt_data <- run_nitrogen_balance_module(
    cohort_level_data = gleam_chrt_data,
    herd_level_data = herd_level_data,
    show_indicator = show_indicator
  )

  # --- Step 8: Run direct emissions from manure management systems ------------
  gleam_chrt_data <- run_emissions_manure_module(
    cohort_level_data = gleam_chrt_data,
    manure_management_system_fraction = manure_management_system_fraction,
    manure_management_system_factors = manure_management_system_factors,
    show_indicator = show_indicator
  )

  # --- Step 9: Run feed emissions (diet-level emission factors) ---------------
  feed_emissions_summary <- run_emissions_ration_module(
    rations_share = feed_rations,
    feed_emissions = feed_emissions,
    show_indicator = show_indicator
  )
  gleam_chrt_data <- merge(
    gleam_chrt_data,
    feed_emissions_summary,
    by = c("herd_id", "animal", "cohort_short")
  )

  # --- Step 10: Run production (milk, fibre, meat) at cohort level ------------
  gleam_chrt_data <- run_production_module(
    cohort_level_data = gleam_chrt_data,
    herd_level_data = herd_level_data,
    simulation_duration = simulation_duration,
    show_indicator = show_indicator
  )

  # --- Step 11: Run allocation (energy allocation terms and commodity shares) -
  allocation_results <- run_allocation_module(
    cohort_level_data = gleam_chrt_data,
    herd_level_data = gleam_hrd_data,
    simulation_duration = simulation_duration,
    show_indicator = show_indicator
  )
  gleam_chrt_data <- allocation_results$cohort_allocation_inputs

  # --- Step 12: Run aggregation (herd-level totals, allocated emissions in CO₂eq) ----
  aggregation_results <- run_aggregation_module(
    cohort_level_data = gleam_chrt_data,
    allocation_herd_long = allocation_results$allocation_long,
    simulation_duration = simulation_duration,
    global_warming_potential_set = global_warming_potential_set
  )

  # Clear progress indicator if it was shown
  if (show_indicator) {
    cli::cli_status_clear()
    cli::cli_rule()
    cli::cli_alert_success("{.strong GLEAM pipeline complete.}")
  }

  return(
    list(
      cohort_level_results = gleam_chrt_data,
      herd_level_results = gleam_hrd_data,
      allocation_long = allocation_results$allocation_long,
      aggregation_results = list(
        results_emissions = aggregation_results$results_emissions,
        results_feed = aggregation_results$results_feed,
        results_production = aggregation_results$results_production,
        results_nitrogen = aggregation_results$results_nitrogen
      )
    )
  )
}
