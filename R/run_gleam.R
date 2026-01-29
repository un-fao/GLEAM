 #' Run the GLEAM pipeline
 #'
 #' Orchestrates herd simulation (or uses a provided cohort structure) and then
 #' applies weight calculations at the cohort level.
 #'
 #' @param has_structure Logical. If TRUE, use `herd_structure` directly as the
 #'   cohort-level input for the weights module.
 #' @param herd_structure data.table. Cohort-level table used when `has_structure`
 #'   is TRUE.
 #' @param herd_simulation_args List. Arguments passed to `run_herd_simulation()`
 #'   when `has_structure` is FALSE.
 #' @param weights_args List. Must contain `herd_level_data` for
 #'   `run_weights_calculations()`.
 #'
 #' @return A cohort-level `data.table` with weight calculations appended.
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
#' # Run GLEAM using herd simulation outputs
#' results <- run_gleam(
#'   has_structure = FALSE,
#'   herd_simulation_args = list(
#'     cohort_level_data = cohort_level_data,
#'     herd_level_data = herd_level_data
#'   ),
#'   weights_args = list(
#'     herd_level_data = weights_herd_level_data
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
    weights_args
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

  return(gleam_data)
}
