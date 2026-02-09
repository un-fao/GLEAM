#' Run the GLEAM pipeline
#'
#' Runs the core sequence of model modules to generate cohort-level outputs for a
#' livestock production system.
#'
#' @param has_structure Logical. If TRUE, use `herd_structure` directly as the
#'   cohort-level input for the weights module.
#' @param herd_structure data.table. Cohort-level table used when `has_structure`
#'   is TRUE.
#' @param herd_simulation_args List. Arguments passed to `run_herd_simulation()` when
#'   `has_structure` is FALSE.
#' @param weights_args List. Arguments passed to `run_weights_calculations()`.
#' @param feed_rations_args List. Arguments passed to `run_feed_rations()`.
#'
#' @return A cohort-level `data.table` containing the outputs produced by the
#'   modules executed within this pipeline call.
#'
#' @examples
#' \dontrun{
#' # Load example herd simulation inputs
#' cohort_path <- system.file(
#'   "extdata/examples/herd_simulation_input_cohort_level_data.csv",
#'   package = "gleam"
#' )
#' herd_path <- system.file(
#'   "extdata/examples/herd_simulation_input_herd_level_data.csv",
#'   package = "gleam"
#' )
#' cohort_level_data <- data.table::fread(cohort_path)
#' herd_level_data <- data.table::fread(herd_path)
#'
#' # Load herd-level weights
#' weights_herd_path <- system.file(
#'   "extdata/examples/weight_input_herd_level_data.csv",
#'   package = "gleam"
#' )
#' weights_herd_level_data <- data.table::fread(weights_herd_path)
#'
#' # Load feed rations inputs
#' feed_params <- data.table::fread(
#'   system.file("extdata/Parameters/feed/feed_params.csv", package = "gleam")
#' )
#' feed_rations <- data.table::fread(
#'   system.file("extdata/examples/feed_rations_share_example.csv", package = "gleam")
#' )
#'
#' # Run GLEAM using herd simulation outputs
#' results <- run_gleam(
#'   has_structure = FALSE,
#'   herd_simulation_args = list(
#'     cohort_level_data = cohort_level_data,
#'     herd_level_data = herd_level_data
#'   ),
#'   weights_args = list(
#'     herd_level_data = weights_herd_level_data
#'   ),
#'   feed_rations_args = list(
#'     feed_rations = feed_rations,
#'     feed_params = feed_params
#'   )
#' )
#'
#' # Access results
#' print(results)
#' }
#' @export
run_gleam <- function(
    has_structure = FALSE,
    herd_structure = NULL,
    herd_simulation_args,
    weights_args,
    feed_rations_args
) {
  # --- Step 1: Run herd simulation (or use provided structure) ----------------
  if (isTRUE(has_structure)) {
    gleam_data <- herd_structure
  } else {
    herd_results <- do.call(run_herd_simulation, herd_simulation_args)
    gleam_data <- herd_results$cohort_level_results
  }

  # --- Step 2: Run weights at cohort level ------------------------------------
  weights_results <- run_weights_calculations(
    cohort_level_data = gleam_data,
    herd_level_data = weights_args$herd_level_data
  )

  gleam_data <- weights_results$cohort_level_results

  # --- Step 3: Merge feed rations and run feed --------------------------------
  gleam_data <- merge(
    gleam_data,
    feed_rations_args$feed_rations,
    by = c("herd_id", "cohort_short")
  )

  gleam_data <- run_feed_rations(
    rations_share = gleam_data,
    feed_params = feed_rations_args$feed_params
  )

  return(gleam_data)
}
