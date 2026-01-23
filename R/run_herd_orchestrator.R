#' Run Demographic and/or Non-Demographic Herd Simulations
#'
#' Orchestrates the demographic herd simulation and the non-demographic production-cycle
#' simulation. Depending on the selected switches, it runs the demographic module, the
#' non-demographic module, or both, then returns a consistent output structure for
#' downstream processing.
#'
#' @param cohort_demo_data Optional \code{data.table}. Optional \code{data.table}. Cohort-level input data required by the
#'   demographic herd model (one row per \code{herd_id} and demographic cohort).
#'   Must be provided when \code{run_demographic = TRUE}.
#'   See \code{\link{run_herd_simulation}} for details on required columns and format.
#'
#' @param herd_level_data A \code{data.table} with one row per \code{herd_id}.
#'   Required regardless of execution mode.
#'
#'   When \code{run_demographic = TRUE}, this table provides herd-level inputs for the
#'   demographic model and must contain the variables required by
#'   \code{\link{run_herd_simulation}}.
#'
#'   When \code{run_non_demographic = TRUE}, the table is used for post-processing and
#'   rescaling of cohort outputs and must contain at least \code{herd_id} and
#'   \code{size_total}.
#'
#' @param cohort_non_demo_input Optional \code{data.table}. Input table for the non-demographic
#'   model. Must be provided when \code{run_non_demographic = TRUE}. It contains
#'   one or more rows per \code{herd_id} and non-demographic cohort block (e.g. \code{"FN"},
#'   \code{"MN"}) and may include multiple phases (e.g. \code{phase_id} 1/2) depending on how
#'   \code{\link{run_non_demographic_herd_simulation}} is configured.
#'
#' @param assessment_duration Numeric. Length of the assessment period (days). Passed to
#'   the demographic model and used by the non-demographic model to compute assessment-window
#'   offtake. 
#'
#' @param run_demographic Logical. If \code{TRUE}, runs the demographic herd simulation via
#'   \code{\link{run_herd_simulation}}.
#'
#' @param run_non_demographic Logical. If \code{TRUE}, runs the non-demographic pipeline via
#'   \code{\link{run_non_demographic_herd_simulation}}.
#'
#' @details
#' The function supports three execution modes:
#' \describe{
#'   \item{\strong{Demographic only} (\code{run_demographic = TRUE}, \code{run_non_demographic = FALSE})}{
#'     Runs \code{\link{run_herd_simulation}} and returns demographic cohort and herd results.
#'   }
#'   \item{\strong{Non-demographic only} (\code{run_demographic = FALSE}, \code{run_non_demographic = TRUE})}{
#'     Runs \code{\link{run_non_demographic_herd_simulation}} and returns non-demographic
#'     cohort results; \code{herd_results} is \code{NULL}.
#'   }
#'   \item{\strong{Both modules} (\code{run_demographic = TRUE}, \code{run_non_demographic = TRUE})}{
#'     Runs both modules and returns a single combined cohort table formed by row-binding
#'     the demographic cohort results with the non-demographic results (union of columns,
#'     missing values filled with \code{NA}).
#'   }
#' }
#'
#' \strong{Deriving non-demographic entrants from demographic outputs.}
#' When both modules are run and \code{cohort_non_demo_input} is provided, the function derives
#' herd-level annual entrants for the non-demographic simulation from the demographic cohort
#' output and passes them to the non-demographic model as \code{herd_level_data_non_demo}:
#' \itemize{
#'   \item Female non-demographic entrants are taken from demographic cohort \code{"FJ"} and stored as
#'     \code{cohort_fem_stock_annual_non_demographic}.
#'   \item Male non-demographic entrants are taken from demographic cohort \code{"MJ"} and stored as
#'     \code{cohort_mal_stock_annual_non_demographic}.
#' }
#' These values are used by \code{\link{run_non_demographic_herd_simulation}} to allocate entrants
#' into non-demographic cycles.
#'
#' \strong{Post-processing and rescaling.}
#' After combining demographic and non-demographic cohort outputs, the function rescales:
#' \itemize{
#'   \item \code{size_stock_unscaled} \eqn{\rightarrow} \code{size_stock} so that, within each \code{herd_id},
#'     cohort average sizes sum to \code{size_total} (from \code{herd_level_data}).
#'   \item \code{offtake_number_unscaled} and \code{offtake_number_assessment_unscaled} \eqn{\rightarrow}
#'     \code{offtake_number} and \code{offtake_number_assessment} proportionally to the size rescaling.
#' }
#' Temporary unscaled/intermediate columns are dropped before returning the final cohort table.
#'
#' @return A named list with:
#' \describe{
#'   \item{cohort_results}{A \code{data.table} of cohort-level results. If both modules are run,
#'     this is the combined demographic + non-demographic table. If only one module is run,
#'     this is the output cohort table from that module (after the rescaling step described above).}
#'   \item{herd_results}{A \code{data.table} of herd-level results from the demographic simulation
#'     when \code{run_demographic = TRUE}; otherwise \code{NULL}.}
#' }
#'
#' @examples
#' \dontrun{ 
#' # Use case 1 - *Run the demographic only*:
#' 
#' # Load example input data from the package
#' cohort_path <- system.file(
#'   "extdata/example_cohort_data.csv",
#'   package = "gleam"
#' )
#' herd_level_path <- system.file(
#'   "extdata/example_herd_level_data.csv",
#'   package = "gleam"
#' )
#' cohort_data_demographic <- data.table::fread(cohort_path)
#' herd_level_data <- data.table::fread(herd_level_path)
#' 
#' 
#' # Run the model
#' out <- run_herd_orchestrator(
#'   cohort_demo_data = cohort_data_demographic,
#'   herd_level_data = herd_level_data,
#'   run_demographic = TRUE,
#'   run_non_demographic = FALSE
#' )
#'
#' 
#' # Access the results
#' demo_cohort_results <- out$cohort_results
#' demo_cohort_results
#' demo_herd_results   <- out$herd_results
#' demo_herd_results
#' 
#'=====
#'
#' # Use case 2 - *Run the non-demographic only*
#' 
#' # Load example input data from the package
#' 
#' cohort_non_demo_input <- system.file(
#'   "extdata/example_cohort_data_nondemographic.csv",
#'   package = "gleam"
#' )
#' cohort_non_demo_input <- data.table::fread(cohort_non_demo_input)
#' 
#' herd_level_data_non_demo <- system.file(
#'   "extdata/example_herd_level_data_nondemographic.csv",
#'   package = "gleam"
#' )
#' herd_level_data_non_demo <- data.table::fread(herd_level_data_non_demo)
#'
#' # Run the model
#' results <- run_herd_orchestrator(
#'   herd_level_data = herd_level_data_non_demo,
#'   cohort_non_demo_data = cohort_non_demo_input,
#'   run_demographic = FALSE,
#'   run_non_demographic = TRUE
#' )
#' 
#' 
#' # Access the results
#' results$cohort_results

#'=====
#'
#' # Use case 3 - Run both the demographic and non-demographic:
#' 
#' # Load example input data from the package
#' cohort_non_demo_input <- system.file(
#'   "extdata/example_cohort_data_nondemographic.csv",
#'   package = "gleam"
#' )
#' cohort_non_demo_input <- data.table::fread(cohort_non_demo_input)
#' 
#' cohort_path <- system.file(
#'   "extdata/example_cohort_data.csv",
#'   package = "gleam"
#' )
#' cohort_demo_data <- data.table::fread(cohort_path)
#' 
#' herd_level_path <- system.file(
#'   "extdata/example_herd_level_data.csv",
#'   package = "gleam"
#' )
#' herd_level_data <- data.table::fread(herd_level_path)
#' 
#' out <- run_herd_orchestrator(
#'   cohort_demo_data = cohort_demo_data,
#'   herd_level_data = herd_level_data,
#'   cohort_non_demo_data = cohort_non_demo_input,
#'   run_demographic = TRUE,
#'   run_non_demographic = TRUE
#' )
#' 
#' # Access the results
#' combined_cohort <- out$cohort_results
#' combined_cohort
#' demo_herd <- out$herd_results
#' demo_herd
#' }
#'
#' @export


run_herd_orchestrator <- function(
    cohort_demo_data = NULL,
    herd_level_data = NULL,
    cohort_non_demo_data = NULL,
    assessment_duration = 365,
    run_demographic = TRUE,
    run_non_demographic = TRUE
) {
  
  nondemo_input_used <- NULL
  demo_results <- NULL
  nondemo_results <- NULL
  
  # --- 1) Run demographic if requested ---
  if (isTRUE(run_demographic)) {
    if (is.null(cohort_demo_data) || is.null(herd_level_data)) {
      stop("To run demographic simulation, provide cohort_data and herd_level_data.")
    }
    
    demo_results <- run_herd_simulation(
      cohort_data = cohort_demo_data,
      herd_level_data = herd_level_data,
      initial_structure = c(FJ = 100, FS = 50, FA = 30, MJ = 100, MS = 50, MA = 30),
      max_years = 100,
      lambda_threshold = 1e-9,
      show_indicator = TRUE,
      assessment_duration = assessment_duration
    )
    
    
    herd_duration_rest<-herd_level_data[,.(herd_id, duration_rest_between_cycles)]
    
    cohort_fem_stock_annual_non_demographic <-
      demo_results$cohort_results[
        cohort == "FJ",
        .(herd_id, cohort_fem_stock_annual_non_demographic=cohort_stock_annual_non_demographic)
      ]
    
    cohort_mal_stock_annual_non_demographic <-
      demo_results$cohort_results[
        cohort == "MJ",
        .(herd_id, cohort_mal_stock_annual_non_demographic=cohort_stock_annual_non_demographic)
      ]
    
    
    herd_level_data_non_demo <- merge(
      cohort_fem_stock_annual_non_demographic,
      cohort_mal_stock_annual_non_demographic,
      by = "herd_id",
      all = TRUE
    )
    
    herd_level_data_non_demo <- merge(
      herd_level_data_non_demo,
      herd_duration_rest,
      by = "herd_id",
      all = TRUE
    )   
    
  }
  
  # --- 2) Run non-demographic if requested ---
  if (isTRUE(run_non_demographic)) {
    
    if (is.null(cohort_non_demo_data)) {
      warning("run_non_demographic=TRUE but cohort_non_demo_input is NULL. Non-demographic pipeline was not run.")
    } else {
      nondemo_input_used <- data.table::copy(cohort_non_demo_data)
      
      
      # If you actually intend to use nondemo_params_by_herd, pass it through:
      nondemo_results <- run_non_demographic_herd_simulation(cohort_non_demo_input=cohort_non_demo_data,
                                                             herd_level_data=herd_level_data_non_demo,
                                                             assessment_duration = assessment_duration)
      
      
    }
  }
  
  cohort_out <- data.table::rbindlist(
    list(
      if (!is.null(demo_results)) demo_results$cohort_results,
      nondemo_results
    ),
    use.names = TRUE,
    fill = TRUE
  )
  
  if (isTRUE(run_demographic) && isTRUE(run_non_demographic)) {
    
    
    
    # --- if the demographic module is run -- > rescale sizes to herd totals and rescale offtake accordingly
    
    tmp <- cohort_out[, .(size_for_rescaling = sum(size_stock_unscaled)), by = herd_id]
    cohort_out[tmp, size_for_rescaling := i.size_for_rescaling, on = .(herd_id)]
    cohort_out[herd_level_data, size_total := i.size_total, on = .(herd_id)]
    
    cohort_out[, size_stock := rescale_x_to_y(
      x_scaled_variable  = size_stock_unscaled,
      x_reference_from   = size_for_rescaling,
      y_scaling_variable = size_total
    )]
    
    
    cohort_out[, offtake_number_assessment := rescale_x_to_y(
      x_scaled_variable  = offtake_number_assessment_unscaled,
      x_reference_from   = size_stock_unscaled,
      y_scaling_variable = size_stock
    )]
    
    
    cohort_out[, offtake_number := rescale_x_to_y(
      x_scaled_variable  = offtake_number_unscaled,
      x_reference_from   = size_stock_unscaled,
      y_scaling_variable = size_stock
    )]
    
    cohort_out[, c(
      "size_stock_unscaled",
      "offtake_number_unscaled",
      "offtake_number_assessment_unscaled",
      "size_for_rescaling",
      "size_total"
    ) := NULL]
    
  } else {
    
    # --- no rescaling; just rename unscaled outputs to final names ---
    data.table::setnames(
      cohort_out,
      old = c("size_stock_unscaled", "offtake_number_unscaled", "offtake_number_assessment_unscaled"),
      new = c("size_stock",        "offtake_number",         "offtake_number_assessment"),
      skip_absent = TRUE
    )
  }
  return(list(
    cohort_results = cohort_out,
    herd_results   = if (!is.null(demo_results)) demo_results$herd_results else NULL
  ))
}
