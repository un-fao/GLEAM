#' Run the GLEAM pipeline
#'
#' Runs the core sequence of model modules to generate cohort-level outputs for a
#' livestock production system.
#'
#' @param has_herd_structure Logical. If TRUE, use `herd_structure` directly as the
#'   cohort-level input for the weights module; if FALSE, run herd simulation first.
#' @param herd_structure data.table or NULL. Cohort-level table used when
#'   `has_herd_structure` is TRUE. Required when `has_herd_structure` is TRUE;
#'   ignored otherwise. Must have one row per cohort (6 cohorts per herd: FJ, FS,
#'   FA, MJ, MS, MA) and at least these required columns:
#'   \describe{
#'     \item{`herd_id`}{Character or numeric. Herd identifier (one value per herd).}
#'     \item{`cohort_short`}{Character. Cohort code: one of \code{FJ}, \code{FS},
#'       \code{FA}, \code{MJ}, \code{MS}, \code{MA}.}
#'     \item{`cohort_duration_days`}{Numeric. Time spent in the cohort (days).}
#'     \item{`offtake_rate`}{Numeric. Annual proportion of animals removed from the
#'       cohort (fraction, 0--1).}
#'   }
#'   Additional columns (e.g. \code{cohort_stock_size}, \code{offtake_heads_assessment})
#'   are allowed and will be passed through the pipeline.
#' @param herd_simulation_args List. Arguments passed to `run_herd_simulation()` when
#'   `has_herd_structure` is FALSE.
#' @param weights_args List. Arguments passed to `run_weights_calculations()`.
#' @param feed_rations_args List. Arguments passed to `run_feed_rations()`.
#' @param energy_requirements_args List. Arguments passed to `run_energy_requirements()`.
#'   Must include \code{herd_level_data}. May include \code{cohort_level_data}: cohort-level
#'   columns not produced by the pipeline (e.g. \code{low_activity_fraction},
#'   \code{high_activity_fraction} are merged in by \code{herd_id}
#'   and \code{cohort_short} before the energy step. If omitted, those columns must already
#'   exist in the pipeline data.
#' @param show_indicator Logical. Whether to display progress indicators during the pipeline run.
#'
#' @return A cohort-level `data.table` containing the outputs produced by the
#'   modules executed within this pipeline call.
#'
#' @examples
#' # Example 1: run pipeline when you don't have herd structure (herd simulation runs first).
#' \dontrun{
#' # Load herd simulation inputs (cohort and herd-level)
#' herd_simulation_chrt_dt <- data.table::fread(system.file(
#'   "extdata/examples/herd_simulation_input_chrt_data.csv",
#'   package = "gleam"
#' ))
#' herd_simulation_hrd_dt <- data.table::fread(system.file(
#'   "extdata/examples/herd_simulation_input_hrd_data.csv",
#'   package = "gleam"
#' ))
#'
#' # Load weights herd-level inputs
#' weights_hrd_dt <- data.table::fread(system.file(
#'   "extdata/examples/weights_input_hrd_data.csv",
#'   package = "gleam"
#' ))
#'
#' # Load feed rations inputs (cohort-level shares and feed parameters)
#' feed_rations_chrt_dt <- data.table::fread(system.file(
#'   "extdata/examples/feed_rations_share_chrt_data.csv",
#'   package = "gleam"
#' ))
#' feed_params_dt <- data.table::fread(system.file(
#'   "extdata/Parameters/feed/feed_params.csv",
#'   package = "gleam"
#' ))
#'
#' # Define argument lists for each pipeline step
#' herd_simulation_args <- list(
#'   cohort_level_data = herd_simulation_chrt_dt,
#'   herd_level_data = herd_simulation_hrd_dt
#' )
#' weights_args <- list(
#'   herd_level_data = weights_hrd_dt
#' )
#' feed_rations_args <- list(
#'   feed_rations = feed_rations_chrt_dt,
#'   feed_params = feed_params_dt
#' )
#' energy_requirements_hrd_dt <- data.table::fread(system.file(
#'   "extdata/examples/energy_requirements_input_hrd_data.csv",
#'   package = "gleam"
#' ))
#' energy_requirements_chrt_dt <- data.table::fread(system.file(
#'   "extdata/examples/energy_requirements_input_chrt_data.csv",
#'   package = "gleam"
#' ))
#' energy_requirements_args <- list(
#'   herd_level_data = energy_requirements_hrd_dt,
#'   cohort_level_data = energy_requirements_chrt_dt
#' )
#'
#' # Run GLEAM using herd simulation outputs
#' results <- run_gleam(
#'   has_herd_structure = FALSE,
#'   herd_simulation_args = herd_simulation_args,
#'   weights_args = weights_args,
#'   feed_rations_args = feed_rations_args,
#'   energy_requirements_args = energy_requirements_args
#' )
#'
#' # Access results
#' print(results)
#' }
#'
#' # Example 2: run pipeline when you already have cohort-level herd structure (skip herd simulation).
#' \dontrun{
#' # Load pre-aggregated herd structure (cohort-level, with required columns for the rest of pipeline)
#' herd_structure_dt <- data.table::fread(system.file(
#'   "extdata/examples/herd_structure_chrt_data.csv",
#'   package = "gleam"
#' ))
#'
#' # Load weights and feed inputs (same as above)
#' weights_hrd_dt <- data.table::fread(system.file(
#'   "extdata/examples/weights_input_hrd_data.csv",
#'   package = "gleam"
#' ))
#' feed_rations_chrt_dt <- data.table::fread(system.file(
#'   "extdata/examples/feed_rations_share_chrt_data.csv",
#'   package = "gleam"
#' ))
#' feed_params_dt <- data.table::fread(system.file(
#'   "extdata/Parameters/feed/feed_params.csv",
#'   package = "gleam"
#' ))
#'
#' weights_args <- list(herd_level_data = weights_hrd_dt)
#' feed_rations_args <- list(
#'   feed_rations = feed_rations_chrt_dt,
#'   feed_params = feed_params_dt
#' )
#' energy_requirements_hrd_dt <- data.table::fread(system.file(
#'   "extdata/examples/energy_requirements_input_hrd_data.csv",
#'   package = "gleam"
#' ))
#' energy_requirements_chrt_dt <- data.table::fread(system.file(
#'   "extdata/examples/energy_requirements_input_chrt_data.csv",
#'   package = "gleam"
#' ))
#' energy_requirements_args <- list(
#'   herd_level_data = energy_requirements_hrd_dt,
#'   cohort_level_data = energy_requirements_chrt_dt
#' )
#'
#' # Run GLEAM using provided herd structure (skip herd simulation)
#' results <- run_gleam(
#'   has_herd_structure = TRUE,
#'   herd_structure = herd_structure_dt,
#'   herd_simulation_args = list(),
#'   weights_args = weights_args,
#'   feed_rations_args = feed_rations_args,
#'   energy_requirements_args = energy_requirements_args
#' )
#'
#' print(results)
#' }
#' @export
run_gleam <- function(
    has_herd_structure = FALSE,
    herd_structure = NULL,
    herd_simulation_args,
    weights_args,
    feed_rations_args,
    energy_requirements_args,
    show_indicator = TRUE
) {

  # --- Step 1: Validate inputs -----------------------------------------------
  validate_run_gleam_inputs(
    has_herd_structure = has_herd_structure,
    herd_structure = herd_structure,
    herd_simulation_args = herd_simulation_args,
    weights_args = weights_args,
    feed_rations_args = feed_rations_args,
    energy_requirements_args = energy_requirements_args
  )

  # Show progress indicator if requested
  if (show_indicator) {
    cli::cli_h1("\U1F552 Running GLEAM pipeline\U2026")
  }

  # --- Step 2: Run herd simulation (or use provided structure) ----------------
  if (has_herd_structure) {
    gleam_chrt_data <- herd_structure
  } else {
    herd_args <- c(herd_simulation_args, list(show_indicator = show_indicator))
    herd_results <- do.call(run_herd_simulation, herd_args)
    gleam_chrt_data <- herd_results$cohort_level_results
  }

  # --- Step 3: Run weights at cohort level ------------------------------------
  weights_results <- run_weights_calculations(
    cohort_level_data = gleam_chrt_data,
    herd_level_data = weights_args$herd_level_data,
    show_indicator = show_indicator
  )

  gleam_chrt_data <- weights_results$cohort_level_results

  # --- Step 4: Summarize feed rations and merge -------------------------------
  feed_rations_summary <- run_feed_rations(
    rations_share = feed_rations_args$feed_rations,
    feed_params = feed_rations_args$feed_params,
    show_indicator = show_indicator
  )

  gleam_chrt_data <- merge(
    gleam_chrt_data,
    feed_rations_summary,
    by = c("herd_id", "cohort_short")
  )

  # --- Step 5: Run energy requirements and DMI --------------------------------
  # Merge in cohort-level energy columns not produced by the pipeline
  energy_cohort <- data.table::as.data.table(energy_requirements_args$cohort_level_data)
  extra_cols <- setdiff(names(energy_cohort), names(gleam_chrt_data))
  if (length(extra_cols) > 0) {
    cols_to_merge <- c("herd_id", "cohort_short", extra_cols)
    gleam_chrt_data <- merge(
      gleam_chrt_data,
      energy_cohort[, cols_to_merge, with = FALSE],
      by = c("herd_id", "cohort_short"),
      all.x = TRUE
    )
  }

  gleam_chrt_data <- run_energy_requirements(
    cohort_level_data = gleam_chrt_data,
    herd_level_data = energy_requirements_args$herd_level_data,
    show_indicator = show_indicator
  )

  # Clear progress indicator if it was shown
  if (show_indicator) {
    cli::cli_rule()
    cli::cli_alert_success("{.strong GLEAM pipeline complete.}")
  }

  return(gleam_chrt_data)
}
