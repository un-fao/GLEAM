#' Run the GLEAM pipeline
#'
#' Runs the core sequence of model modules to generate cohort-level outputs for a
#' livestock production system: herd simulation (optional), weights, feed rations,
#' energy requirements and DMI, enteric methane direct emissions, nitrogen balance,
#' and direct emissions from manure management systems.
#' Accepts primary inputs only: one cohort-level master table, one herd-level master table,
#' feed rations and feed parameters, and manure management system tables.
#'
#' @param has_herd_structure Logical. If TRUE, use \code{cohort_level_data} directly
#'   as the cohort-level input for the weights module (skip herd simulation). If FALSE,
#'   run herd simulation first using \code{cohort_level_data} and \code{herd_level_data}.
#' @param cohort_level_data data.table. Cohort-level master table. Must have one row
#'   per cohort (6 cohorts per herd: FJ, FS, FA, MJ, MS, MA). Data should not
#'   include columns that GLEAM calculates (validation will block them). May
#'   optionally include \code{ch4_mitigation_factor} (fraction of baseline enteric
#'   CH4 remaining after mitigation, 1 = no mitigation).
#' @param herd_level_data data.table. Herd-level master table (one row per herd).
#'   Must include \code{animal} (full species name, e.g. Cattle, Buffalo).
#' @param feed_rations data.table. Feed ration shares by cohort (see \code{\link{run_feed_rations}}).
#' @param feed_params data.table. Feed nutritional parameters (see \code{\link{run_feed_rations}}).
#' @param manure_management_system_fraction data.table. Cohort-level manure management
#'   system fractions (see \code{\link{run_directemissions_manure}}).
#' @param manure_management_system_factors data.table. Manure management
#'   system factors (see \code{\link{run_directemissions_manure}}).
#' @param show_indicator Logical. Whether to display progress indicators during the pipeline run.
#'
#' @return A cohort-level \code{data.table} containing the outputs produced by the
#'   modules executed within this pipeline call.
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
#'   manure_management_system_fraction = manure_management_system_fraction_dt,
#'   manure_management_system_factors = manure_management_system_factors_dt
#' )
#' print(results)
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
#'   manure_management_system_fraction = manure_management_system_fraction_dt,
#'   manure_management_system_factors = manure_management_system_factors_dt
#' )
#' print(results)
#' }
#' @export
run_gleam <- function(
    has_herd_structure = FALSE,
    cohort_level_data,
    herd_level_data,
    feed_rations,
    feed_params,
    manure_management_system_fraction,
    manure_management_system_factors,
    show_indicator = TRUE
) {

  # --- Step 1: Validate inputs -----------------------------------------------
  validate_run_gleam_inputs(
    has_herd_structure = has_herd_structure,
    cohort_level_data = cohort_level_data,
    herd_level_data = herd_level_data,
    feed_rations = feed_rations,
    feed_params = feed_params,
    manure_management_system_fraction = manure_management_system_fraction,
    manure_management_system_factors = manure_management_system_factors
  )

  # Show progress indicator if requested
  if (show_indicator) {
    cli::cli_h1("\U1F552 Running GLEAM pipeline\U2026")
  }

  # --- Step 2: Run herd simulation (or use provided structure) ----------------
  if (has_herd_structure) {
    gleam_chrt_data <- data.table::as.data.table(cohort_level_data)
  } else {
    herd_results <- run_herd_simulation(
      cohort_level_data = cohort_level_data,
      herd_level_data = herd_level_data,
      show_indicator = show_indicator
    )
    gleam_chrt_data <- herd_results$cohort_level_results
  }

  # --- Step 3: Run weights at cohort level ------------------------------------
  weights_results <- run_weights_calculations(
    cohort_level_data = gleam_chrt_data,
    herd_level_data = herd_level_data,
    show_indicator = show_indicator
  )

  gleam_chrt_data <- weights_results$cohort_level_results

  # --- Step 4: Summarize feed rations and merge -------------------------------
  feed_rations_summary <- run_feed_rations(
    rations_share = feed_rations,
    feed_params = feed_params,
    show_indicator = show_indicator
  )

  gleam_chrt_data <- merge(
    gleam_chrt_data,
    feed_rations_summary,
    by = c("herd_id", "cohort_short")
  )

  # --- Step 5: Run energy requirements and DMI --------------------------------
  gleam_chrt_data <- run_energy_requirements(
    cohort_level_data = gleam_chrt_data,
    herd_level_data = herd_level_data,
    show_indicator = show_indicator
  )

  # --- Step 6: Run enteric methane direct emissions ---------------------------
  # ch4_mitigation_factor is optional cohort-level input
  gleam_chrt_data <- run_directemissions_enteric(
    data = gleam_chrt_data,
    show_indicator = show_indicator
  )

  # --- Step 7: Run nitrogen balance -------------------------------------------
  gleam_chrt_data <- run_nitrogen_balance(
    cohort_level_data = gleam_chrt_data,
    herd_level_data = herd_level_data,
    show_indicator = show_indicator
  )

  # --- Step 8: Run direct emissions from manure management systems ------------
  gleam_chrt_data <- run_directemissions_manure(
    cohort_level_data = gleam_chrt_data,
    manure_management_system_fraction = manure_management_system_fraction,
    manure_management_system_factors = manure_management_system_factors,
    show_indicator = show_indicator
  )

  # Clear progress indicator if it was shown
  if (show_indicator) {
    cli::cli_status_clear()
    cli::cli_rule()
    cli::cli_alert_success("{.strong GLEAM pipeline complete.}")
  }

  return(gleam_chrt_data)
}
