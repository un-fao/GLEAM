#' Run Combined Herd Module Pipeline
#'
#' This function orchestrates the demographic herd module
#' [run_demographic_herd_module()] and the non-demographic herd module
#' [run_nondemographic_herd_module()] within a single wrapper. Depending on the
#' selected logical switches, it runs the demographic module, the
#' non-demographic module, or both, and returns a harmonized herd-module output
#' structure for downstream use in [run_gleam()].
#'
#' @param cohort_level_data A `data.table` with one row per `herd_id` and cohort.
#'   Required rows and columns depend on the selected execution mode:
#'   \itemize{
#'     \item \strong{Case 1 - when `run_demographic = TRUE` and `run_nondemographic = FALSE`:}
#'     `cohort_level_data` must contain rows for the demographic cohorts only
#'     (`FA`, `FJ`, `FS`, `MA`, `MJ`, `MS`). In this case the table must contain
#'     the columns required by [run_demographic_herd_module()]:
#'     \describe{
#'       \item{`herd_id`}{Character or numeric. Unique identifier for the herd,
#'       repeated for each cohort belonging to the same herd.}
#'       \item{`cohort_short`}{Character. Demographic cohort code. Supported
#'       values are `FJ`, `FS`, `FA`, `MJ`, `MS`, and `MA`.}
#'       \item{`cohort_duration_days`}{Numeric. Amount of time that each animal
#'       spends in the demographic cohort (days).}
#'       \item{`offtake_rate`}{Numeric. Annual proportion of animals removed
#'       from the herd for each demographic cohort (fraction).}
#'       \item{`death_rate`}{Numeric. Fraction of deaths in a herd over a year
#'       for each demographic cohort (fraction).}
#'     }
#'     \item \strong{Case 2 - when `run_demographic = FALSE` and `run_nondemographic = TRUE`:}
#'     `cohort_level_data` must contain rows for the non-demographic cohorts
#'     only (`FN`, `MN`). In this case the table must contain the columns
#'     required by [run_nondemographic_herd_module()]:
#'     \describe{
#'       \item{`herd_id`}{Character or numeric. Unique identifier for the herd,
#'       repeated for each non-demographic cohort phase belonging to the same herd.}
#'       \item{`cohort_short`}{Character. Non-demographic cohort code.
#'       Supported values are `FN` for non-demographic female animals and `MN`
#'       for non-demographic male animals.}
#'       \item{`nondemo_productive_phase_id`}{Numeric. Productive phase
#'       identifier within a non-demographic cycle. `1` is required and `2` is
#'       optional.}
#'       \item{`death_rate`}{Numeric. Fraction of deaths occurring during the
#'       non-demographic productive phase (fraction).}
#'     }
#'     \item \strong{Case 3 - when `run_demographic = TRUE` and `run_nondemographic = TRUE`:}
#'     `cohort_level_data` must contain both demographic and non-demographic
#'     rows. In this case the table must satisfy both sets of requirements
#'     described above. Internally, `run_all_herd_module()` splits the combined
#'     input into demographic and non-demographic subsets using `cohort_short`.
#'   }
#'
#' @param herd_level_data A `data.table` with one row per `herd_id`. This table
#'   is required in all execution modes. Required columns depend on the selected
#'   execution mode:
#'   \itemize{
#'     \item \strong{Case 1 - when `run_demographic = TRUE` and `run_nondemographic = FALSE`:}
#'     `herd_level_data` must contain the herd-level inputs required by
#'     [run_demographic_herd_module()]:
#'     \describe{
#'       \item{`herd_id`}{Character or numeric. Unique identifier for the herd.}
#'       \item{`parturition_rate`}{Numeric. Average annual number of
#'       parturitions per female animal (# parturitions/adult female/year).}
#'       \item{`litter_size`}{Numeric. Average number of offspring born per
#'       parturition (# offspring/parturition).}
#'       \item{`birth_fraction_female`}{Numeric. Female birth fraction,
#'       defined as the probability that a newborn offspring is female
#'       (fraction).}
#'       \item{`herd_size_total`}{Numeric. Total population size at the start of
#'       the year, including all cohorts (# heads).}
#'       \item{`prop_nondemo_mal_juv`}{Numeric. Fraction of male juveniles
#'       diverted into the non-demographic stream at the moment they transition
#'       to the next age class (fraction).}
#'       \item{`prop_nondemo_fem_juv`}{Numeric. Fraction of female juveniles
#'       diverted into the non-demographic stream at the moment they transition
#'       to the next age class (fraction).}
#'     }
#'     \item \strong{Case 2 - when `run_demographic = FALSE` and `run_nondemographic = TRUE`:}
#'     `herd_level_data` must contain the herd-level inputs required by
#'     [run_nondemographic_herd_module()]:
#'     \describe{
#'       \item{`herd_id`}{Character or numeric. Unique identifier for the herd.}
#'       \item{`cohort_stock_fem_annual_nondemo`}{Numeric. Total annual entrants
#'       into the `FN` cohort block over the simulated period (# heads /
#'       simulated period).}
#'       \item{`cohort_stock_mal_annual_nondemo`}{Numeric. Total annual entrants
#'       into the `MN` cohort block over the simulated period (# heads /
#'       simulated period).}
#'       \item{`rest_between_nondemo_cycles_duration`}{Numeric. Duration of the
#'       resting or empty phase between non-demographic cycles (days).}
#'       \item{`phase1_nondemo_fem_duration_days`}{Numeric. Duration of
#'       productive phase 1 for the female non-demographic cohort (`FN`) (days).}
#'       \item{`phase2_nondemo_fem_duration_days`}{Numeric. Duration of
#'       productive phase 2 for the female non-demographic cohort (`FN`) (days).}
#'       \item{`phase1_nondemo_mal_duration_days`}{Numeric. Duration of
#'       productive phase 1 for the male non-demographic cohort (`MN`) (days).}
#'       \item{`phase2_nondemo_mal_duration_days`}{Numeric. Duration of
#'       productive phase 2 for the male non-demographic cohort (`MN`) (days).}
#'     }
#'     \item \strong{Case 3 - when `run_demographic = TRUE` and `run_nondemographic = TRUE`:}
#'     `herd_level_data` must contain the demographic herd inputs required by
#'     [run_demographic_herd_module()], plus the non-demographic cycle-duration
#'     inputs required to run [run_nondemographic_herd_module()] after annual
#'     non-demographic entrants are derived internally from the demographic output:
#'     \describe{
#'       \item{`herd_id`}{Character or numeric. Unique identifier for the herd.}
#'       \item{`parturition_rate`}{Numeric. Average annual number of
#'       parturitions per female animal (# parturitions/adult female/year).}
#'       \item{`litter_size`}{Numeric. Average number of offspring born per
#'       parturition (# offspring/parturition).}
#'       \item{`birth_fraction_female`}{Numeric. Female birth fraction,
#'       defined as the probability that a newborn offspring is female
#'       (fraction).}
#'       \item{`herd_size_total`}{Numeric. Total population size at the start of
#'       the year, including all cohorts (# heads).}
#'       \item{`prop_nondemo_mal_juv`}{Numeric. Fraction of male juveniles
#'       diverted into the non-demographic stream at the moment they transition
#'       to the next age class (fraction).}
#'       \item{`prop_nondemo_fem_juv`}{Numeric. Fraction of female juveniles
#'       diverted into the non-demographic stream at the moment they transition
#'       to the next age class (fraction).}
#'       \item{`rest_between_nondemo_cycles_duration`}{Numeric. Duration of the
#'       resting or empty phase between non-demographic cycles (days).}
#'       \item{`phase1_nondemo_fem_duration_days`}{Numeric. Duration of
#'       productive phase 1 for the female non-demographic cohort (`FN`) (days).}
#'       \item{`phase2_nondemo_fem_duration_days`}{Numeric. Duration of
#'       productive phase 2 for the female non-demographic cohort (`FN`) (days).}
#'       \item{`phase1_nondemo_mal_duration_days`}{Numeric. Duration of
#'       productive phase 1 for the male non-demographic cohort (`MN`) (days).}
#'       \item{`phase2_nondemo_mal_duration_days`}{Numeric. Duration of
#'       productive phase 2 for the male non-demographic cohort (`MN`) (days).}
#'     }
#'     In this combined mode, `cohort_stock_fem_annual_nondemo` and
#'     `cohort_stock_mal_annual_nondemo` are omitted because derived internally from the
#'     demographic output and therefore do not need to be supplied as primary
#'     herd-level inputs.
#'     }
#'
#' @param simulation_duration Numeric. Length of the reporting period (days).
#'
#' @param run_demographic Logical. If `TRUE`, run
#'   [run_demographic_herd_module()].
#'
#' @param run_nondemographic Logical. If `TRUE`, run
#'   [run_nondemographic_herd_module()].
#'
#' @details
#' The function supports three execution modes:
#'
#' 1. Demographic only: see [run_demographic_herd_module()] for additional details.
#'
#' 2. Non-demographic only: see [run_nondemographic_herd_module()] for additional details.
#'
#' 3. Demographic and non-demographic together:
#' When `run_demographic = TRUE` and `run_nondemographic = TRUE`, the function:
#' \enumerate{
#'   \item runs [run_demographic_herd_module()] on the demographic subset
#'   \item derives annual non-demographic entrants from the demographic output
#'   \item runs [run_nondemographic_herd_module()] on the non-demographic subset
#'   \item row-binds the two cohort-level result tables
#'   \item harmonizes shared output columns
#'   \item rescales average stock and offtake to the herd total
#' }
#'
#' When both modules are run, annual entrants into the non-demographic blocks
#' are derived from the demographic output:
#' \itemize{
#'   \item female entrants to `FN` are taken from demographic cohort `FJ` as
#'     `cohort_stock_fem_annual_nondemo = cohort_stock_annual_nondemographic`
#'   \item male entrants to `MN` are taken from demographic cohort `MJ` as
#'     `cohort_stock_mal_annual_nondemo = cohort_stock_annual_nondemographic`
#' }
#'
#' These entrant counts are merged with herd-level non-demographic timing inputs
#' such as:
#' \itemize{
#'   \item `rest_between_nondemo_cycles_duration`
#'   \item `phase1_nondemo_fem_duration_days`
#'   \item `phase2_nondemo_fem_duration_days`
#'   \item `phase1_nondemo_mal_duration_days`
#'   \item `phase2_nondemo_mal_duration_days`
#' }
#'
#' After the selected modules run, the function combines their cohort-level
#' outputs using `data.table::rbindlist(..., use.names = TRUE, fill = TRUE)`.
#' This allows demographic and non-demographic rows to share a common schema.
#'
#' The combined cohort output harmonizes, when needed:
#' \itemize{
#'   \item `offtake_heads`
#'   \item `offtake_heads_assessment`
#'   \item `cohort_duration_days`
#'   \item `death_rate`
#'   \item `cohort_stock_size_unscaled`
#'   \item `cohort_stock_size`
#' }
#'
#'
#' The function then rescales the combined cohort 
#' stock and offtake outputs so that the summed cohort average stock matches
#' `herd_size_total` from `herd_level_data`.
#'
#' The rescaling is performed in two steps:
#' \enumerate{
#'   \item `cohort_stock_size_unscaled` is rescaled to `cohort_stock_size`
#'   within each `herd_id`
#'   \item `offtake_heads` and `offtake_heads_assessment` are rescaled
#'   proportionally from the unscaled cohort stock to the scaled cohort stock
#' }
#'
#' When only one module is run, no cross-module rescaling is needed and
#' `cohort_stock_size_unscaled` is simply renamed to `cohort_stock_size`.
#'  
#' @return A named list with two elements:
#' \describe{
#'   \item{`cohort_level_results`}{A `data.table` with one row per retained
#'   cohort. Depending on the selected execution mode, this table contains
#'   demographic rows only, non-demographic rows only, or both in a harmonized
#'   schema. It includes the original cohort-level input columns plus the
#'   following result variables when available:
#'   \describe{
#'     \item{`cohort_stock_size_unscaled`}{Numeric. Average cohort stock before
#'     final harmonization to `herd_size_total` (# heads).}
#'     \item{`cohort_stock_size`}{Numeric. Final average cohort stock after
#'     harmonization of the output schema. When both modules are run together,
#'     this is the rescaled stock size; when only one module is run, this is the
#'     renamed value of `cohort_stock_size_unscaled` (# heads).}
#'     \item{`offtake_heads`}{Numeric. Total number of animals removed from the
#'     cohort over the full 365-day simulation horizon (# heads).}
#'     \item{`offtake_heads_assessment`}{Numeric. Total number of animals removed
#'     from the cohort over `simulation_duration` (# heads / simulated period).}
#'     \item{`cohort_stock_annual_nondemographic`}{Numeric. For demographic
#'     rows only, annual number of animals diverted from the demographic pathway
#'     into the non-demographic pathway (# heads / simulated period).}
#'     \item{`nondemo_productive_phase_id`}{Numeric. For non-demographic rows
#'     only, productive phase identifier within the non-demographic cycle.
#'     Allowed values are `1` and optionally `2`.}
#'     \item{`partial_nondemo_phase_duration`}{Numeric. For non-demographic rows
#'     only, duration of the terminal partial productive phase falling within the
#'     fixed 365-day non-demographic simulation horizon (days).}
#'     \item{`number_full_nondemo_cycles`}{Integer. For non-demographic rows
#'     only, number of complete non-demographic cycles fully contained within the
#'     fixed 365-day simulation horizon (cycles / simulated period).}
#'     \item{`total_nondemo_cycle_starts_to_distribute`}{Integer. For
#'     non-demographic rows only, total number of cycle starts within the fixed
#'     365-day simulation horizon used to distribute annual entrants (cycle
#'     starts / simulated period).}
#'   }}
#'   \item{`herd_level_results`}{A `data.table` with one row per `herd_id`.
#'   Depending on the selected execution mode, this is the herd-level output of
#'   the demographic module, the non-demographic module, or the merged herd-level
#'   output of both modules. It includes the original herd-level input columns
#'   plus the following result variables when available:
#'   \describe{
#'     \item{`growth_rate_herd`}{Numeric. Annualized herd growth rate estimated
#'     by the demographic herd module (fraction).}
#'     \item{`cohort_stock_fem_annual_nondemo`}{Numeric. Annual number of female
#'     animals entering the non-demographic pathway (`FN`) over the simulated
#'     period (# heads / simulated period). When both modules are run, this is
#'     derived internally from the demographic output.}
#'     \item{`cohort_stock_mal_annual_nondemo`}{Numeric. Annual number of male
#'     animals entering the non-demographic pathway (`MN`) over the simulated
#'     period (# heads / simulated period). When both modules are run, this is
#'     derived internally from the demographic output.}
#'     \item{`rest_between_nondemo_cycles_duration`}{Numeric. Duration of the
#'     resting or empty phase between non-demographic cycles (days).}
#'     \item{`total_nondemo_fem_duration_days`}{Numeric. Total duration of the
#'     productive non-demographic phases assigned to the female non-demographic
#'     cohort block (`FN`) (days).}
#'     \item{`total_nondemo_mal_duration_days`}{Numeric. Total duration of the
#'     productive non-demographic phases assigned to the male non-demographic
#'     cohort block (`MN`) (days).}
#'   }}
#' }
#'
#' @seealso
#' [run_gleam()],
#' [run_demographic_herd_module()],
#' [run_nondemographic_herd_module()],
#' [rescale_x_to_y()]
#'
#' @examples
#' \dontrun{ 
#' # Use case 1 - *Run the demographic only*:
#'
#' cohort_path <- system.file(
#'   "extdata/run_modules_examples/herd_simulation_input_chrt_data.csv",
#'   package = "gleam"
#' )
#' herd_level_path <- system.file(
#'   "extdata/run_modules_examples/herd_simulation_input_hrd_data.csv",
#'   package = "gleam"
#' )
#' cohort_data_demographic <- data.table::fread(cohort_path)
#' herd_level_data <- data.table::fread(herd_level_path)
#'
#' out <- run_all_herd_module(
#'   cohort_level_data = cohort_data_demographic,
#'   herd_level_data = herd_level_data,
#'   run_demographic = TRUE,
#'   run_nondemographic = FALSE
#' )
#'
#' 
#' # Access the results
#' names(out)
#' 
#'=====
#'
#' # Use case 2 - *Run the non-demographic only*
#'
#' cohort_nondemo_path <- system.file(
#'   "extdata/run_modules_examples/nondemographic_herd_input_chrt_data.csv",
#'   package = "gleam"
#' )
#' herd_nondemo_path <- system.file(
#'   "extdata/run_modules_examples/nondemographic_herd_input_hrd_data.csv",
#'   package = "gleam"
#' )
#' cohort_nondemo_input <- data.table::fread(cohort_nondemo_path)
#' herd_level_data_nondemo <- data.table::fread(herd_nondemo_path)
#'
#' results <- run_all_herd_module(
#'   cohort_level_data = cohort_nondemo_input,
#'   herd_level_data = herd_level_data_nondemo,
#'   run_demographic = FALSE,
#'   run_nondemographic = TRUE
#' )
#' 
#' 
#' # Access the results
#' names(results)

#'=====
#'
#' # Use case 3 - *Run both the demographic and non-demographic*:
#'
#' cohort_combined_path <- system.file(
#'   "extdata/run_modules_examples/run_all_herd_module_input_chrt_data.csv",
#'   package = "gleam"
#' )
#' herd_level_path <- system.file(
#'   "extdata/run_modules_examples/example_herd_level_data.csv",
#'   package = "gleam"
#' )
#' cohort_level_data <- data.table::fread(cohort_combined_path)
#' herd_level_data <- data.table::fread(herd_level_path)
#'
#' out <- run_all_herd_module(
#'   cohort_level_data = cohort_level_data,
#'   herd_level_data = herd_level_data,
#'   run_demographic = TRUE,
#'   run_nondemographic = TRUE
#' )
#'
#' # Access the results
#' names(out)
#' demo_herd <- out$herd_level_results
#' demo_herd
#' }
#'
#' @export



run_all_herd_module <- function(
    cohort_level_data = NULL,
    herd_level_data = NULL,
    simulation_duration = 365,
    run_demographic = TRUE,
    run_nondemographic = TRUE
) {
  
  if (!is.null(cohort_level_data) && !data.table::is.data.table(cohort_level_data)) {
    cohort_level_data <- data.table::as.data.table(cohort_level_data)
  }
  if (!is.null(herd_level_data) && !data.table::is.data.table(herd_level_data)) {
    herd_level_data <- data.table::as.data.table(herd_level_data)
  }

  validate_run_all_herd_module_inputs(
    cohort_level_data = cohort_level_data,
    herd_level_data = herd_level_data,
    run_demographic = run_demographic,
    run_nondemographic = run_nondemographic
  )
  
  cohort_level_data_demographic <- NULL
  cohort_level_data_nondemographic <- NULL
  
  cohort_level_data_demographic <- cohort_level_data[
    !is.na(cohort_short) & cohort_short %in% gleam_cohorts_demographic
  ]
  
  cohort_level_data_nondemographic <- cohort_level_data[
    !is.na(cohort_short) & cohort_short %in% c("FN", "MN")
  ]
  
  demo_results <- NULL
  nondemo_results <- NULL
  
  # =========================================================
  # 1) Run DEMOGRAPHIC MODULE
  # =========================================================
  if (isTRUE(run_demographic)) {
    demo_results <- run_demographic_herd_module(
      cohort_level_data = cohort_level_data_demographic,
      herd_level_data = herd_level_data,
      simulation_duration = simulation_duration
    )
    
    # ---- Derive non-demographic entrants from demographic output ----
    herd_duration_cols <- intersect(
      c(
        "rest_between_nondemo_cycles_duration",
        "phase1_nondemo_fem_duration_days",
        "phase2_nondemo_fem_duration_days",
        "phase1_nondemo_mal_duration_days",
        "phase2_nondemo_mal_duration_days"
      ),
      names(herd_level_data)
    )
    herd_duration_rest <- herd_level_data[, c("herd_id", herd_duration_cols), with = FALSE]
    
    fem_entrants <- demo_results$cohort_level_results[
      cohort_short == "FJ",
      .(herd_id,
        cohort_stock_fem_annual_nondemo = cohort_stock_annual_nondemographic)
    ]
    
    mal_entrants <- demo_results$cohort_level_results[
      cohort_short == "MJ",
      .(herd_id,
        cohort_stock_mal_annual_nondemo = cohort_stock_annual_nondemographic)
    ]
    
    herd_level_data_nondemo <- merge(fem_entrants, mal_entrants, by = "herd_id", all = TRUE)
    herd_level_data_nondemo <- merge(herd_level_data_nondemo, herd_duration_rest, by = "herd_id", all = TRUE)
    if (!is.null(cohort_level_data_nondemographic) && nrow(cohort_level_data_nondemographic) > 0) {
      herd_level_data_nondemo <- herd_level_data_nondemo[
        herd_id %in% unique(cohort_level_data_nondemographic$herd_id)
      ]
    }
    
  }
  
  # =========================================================
  # 2) Run NON-DEMOGRAPHIC MODULE
  # =========================================================
  if (isTRUE(run_nondemographic)) {
    if (nrow(cohort_level_data_nondemographic) > 0) {
      
      # If demographic not run → expect full herd_level_data provided externally
          if (!exists("herd_level_data_nondemo")) {
                herd_level_data_nondemo <- herd_level_data[
                  herd_id %in% unique(cohort_level_data_nondemographic$herd_id)
                ]
            }
      
      nondemo_results <- run_nondemographic_herd_module(
        cohort_level_data = cohort_level_data_nondemographic,
        herd_level_data = herd_level_data_nondemo,
        simulation_duration = simulation_duration
      )
      
    }
  }
  
  # =========================================================
  # 3) COMBINE RESULTS
  # =========================================================
  cohort_level_results <- data.table::rbindlist(
    list(
      if (!is.null(demo_results)) demo_results$cohort_level_results,
      if (!is.null(nondemo_results)) nondemo_results$cohort_level_results
    ),
    use.names = TRUE,
    fill = TRUE
  )

  if (!"offtake_heads" %in% names(cohort_level_results)) {
    cohort_level_results[, offtake_heads := NA_real_]
  }
  if (!"offtake_heads_assessment" %in% names(cohort_level_results)) {
    cohort_level_results[, offtake_heads_assessment := NA_real_]
  }
  
  if ("duration_cycle_productive_phase_nondemo" %in% names(cohort_level_results)) {
    cohort_level_results[
      !is.na(duration_cycle_productive_phase_nondemo) &
        (is.na(cohort_duration_days) | cohort_duration_days == ""),
      cohort_duration_days := duration_cycle_productive_phase_nondemo
    ]
    cohort_level_results[, duration_cycle_productive_phase_nondemo := NULL]
  }
  
  if ("mort_rate" %in% names(cohort_level_results)) {
    cohort_level_results[
      !is.na(mort_rate) & (is.na(death_rate) | death_rate == ""),
      death_rate := mort_rate
    ]
    cohort_level_results[, mort_rate := NULL]
  }
  
  # =========================================================
  # 4) RESCALING (ONLY IF DEMOGRAPHIC RUN)
  # =========================================================
  if (isTRUE(run_demographic) && isTRUE(run_nondemographic)) {
    
    # total unscaled size per herd
    tmp <- cohort_level_results[
      , .(size_for_rescaling = sum(cohort_stock_size_unscaled, na.rm = TRUE)),
      by = herd_id
    ]
    
    cohort_level_results[tmp, size_for_rescaling := i.size_for_rescaling, on = "herd_id"]
    cohort_level_results[herd_level_data, herd_size_total := i.herd_size_total, on = "herd_id"]
    
    # ---- Rescale sizes ----
    cohort_level_results[, cohort_stock_size := rescale_x_to_y(
      x_scaled_variable  = cohort_stock_size_unscaled,
      x_reference_from   = size_for_rescaling,
      y_scaling_variable = herd_size_total
    )]
    
    # ---- Rescale offtake ----
    cohort_level_results[, offtake_heads := rescale_x_to_y(
      x_scaled_variable  = offtake_heads,
      x_reference_from   = cohort_stock_size_unscaled,
      y_scaling_variable = cohort_stock_size
    )]
    
    cohort_level_results[, offtake_heads_assessment := rescale_x_to_y(
      x_scaled_variable  = offtake_heads_assessment,
      x_reference_from   = cohort_stock_size_unscaled,
      y_scaling_variable = cohort_stock_size
    )]
    
    # ---- Clean temporary columns ----
    cols_to_drop <- intersect(
      c(
        "size_for_rescaling",
        "herd_size_total"
      ),
      names(cohort_level_results)
    )
    if (length(cols_to_drop) > 0) {
      cohort_level_results[, (cols_to_drop) := NULL]
    }
    
  } else {
    
    # If only one module → just rename
    data.table::setnames(
      cohort_level_results,
      old = "cohort_stock_size_unscaled",
      new = "cohort_stock_size",
      skip_absent = TRUE
    )
    
  }
  
  herd_level_results <- NULL

  if (!is.null(demo_results) && !is.null(nondemo_results)) {
    herd_level_results <- data.table::copy(demo_results$herd_level_results)
    herd_level_results[
      nondemo_results$herd_level_results,
      `:=`(
        cohort_stock_fem_annual_nondemo = i.cohort_stock_fem_annual_nondemo,
        cohort_stock_mal_annual_nondemo = i.cohort_stock_mal_annual_nondemo,
        rest_between_nondemo_cycles_duration = i.rest_between_nondemo_cycles_duration,
        total_nondemo_fem_duration_days = i.total_nondemo_fem_duration_days,
        total_nondemo_mal_duration_days = i.total_nondemo_mal_duration_days
      ),
      on = "herd_id"
    ]
  } else if (!is.null(demo_results)) {
    herd_level_results <- demo_results$herd_level_results
  } else if (!is.null(nondemo_results)) {
    herd_level_results <- nondemo_results$herd_level_results
  }

  # =========================================================
  # 5) RETURN
  # =========================================================
  return(list(
    cohort_level_results = cohort_level_results,
    herd_level_results   = herd_level_results
  ))
}
