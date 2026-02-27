#' Validate inputs for run_gleam
#'
#' Validates \code{has_herd_structure} (boolean), requires direct input tables
#' (\code{cohort_level_data}, \code{herd_level_data}, \code{feed_rations},
#' \code{feed_params}), and ensures cohort/herd/feed_rations share the same
#' \code{herd_id} set. Ensures input tables do not contain columns that GLEAM
#' calculates internally (e.g. \code{cohort_stock_size}, \code{daily_weight_gain}).
#' Schema checks for cohort/herd data are done in the respective run_* functions.
#'
#' @param has_herd_structure Logical. If TRUE, use \code{cohort_level_data} as
#'   cohort-level input for the weights step; if FALSE, run herd simulation first.
#' @param cohort_level_data data.table. Cohort-level master table.
#' @param herd_level_data data.table. Herd-level master table.
#' @param feed_rations data.table. Feed ration shares by cohort.
#' @param feed_params data.table. Feed nutritional parameters.
#'
#' @noRd
validate_run_gleam_inputs <- function(
    has_herd_structure,
    cohort_level_data,
    herd_level_data,
    feed_rations,
    feed_params
) {

  # --- has_herd_structure: must be a single boolean ---------------------------
  if (!is.logical(has_herd_structure) || length(has_herd_structure) != 1L) {
    cli::cli_abort(
      "{.arg has_herd_structure} must be a single logical value (TRUE or FALSE)."
    )
  }
  if (is.na(has_herd_structure)) {
    cli::cli_abort(
      "{.arg has_herd_structure} must be TRUE or FALSE, not NA."
    )
  }

  # --- Direct input tables must be provided (non-null, data.frame) -------------
  if (is.null(cohort_level_data) || !is.data.frame(cohort_level_data)) {
    cli::cli_abort("{.arg cohort_level_data} must be a data frame (e.g. data.table).")
  }
  if (is.null(herd_level_data) || !is.data.frame(herd_level_data)) {
    cli::cli_abort("{.arg herd_level_data} must be a data frame (e.g. data.table).")
  }
  if (is.null(feed_rations) || !is.data.frame(feed_rations)) {
    cli::cli_abort("{.arg feed_rations} must be a data frame (e.g. data.table).")
  }
  if (is.null(feed_params) || !is.data.frame(feed_params)) {
    cli::cli_abort("{.arg feed_params} must be a data frame (e.g. data.table).")
  }

  # --- Block calculated (intermediate) variables in input tables ---------------
  # Columns that GLEAM computes; users must not provide them as inputs.
  gleam_calculated_columns <- c(
    # Herd simulation (cohort and herd)
    "cohort_stock_size", "offtake_heads", "offtake_heads_assessment", "growth_rate_herd",
    # Weights (cohort)
    "mature_weight", "live_weight_cohort_initial", "live_weight_cohort_potential_final",
    "slaughter_weight_cohort", "live_weight_cohort_average", "live_weight_cohort_final",
    "daily_weight_gain",
    # Feed rations (cohort-level outputs merged into pipeline)
    "diet_gross_energy", "diet_metabolizable_energy", "diet_nitrogen",
    "diet_digestibility_fraction", "urinary_energy_fraction", "diet_ash",
    # Energy requirements (cohort)
    "energy_requirement_maintenance", "energy_requirement_activity", "energy_requirement_growth",
    "energy_requirement_lactation", "energy_requirement_work",
    "energy_requirement_fibre_production", "energy_requirement_pregnancy",
    "net_energy_maintenance_digestible_energy_ratio",
    "net_energy_growth_digestible_energy_ratio",
    "energy_requirement_total", "dry_matter_intake",
    # Nitrogen balance (cohort)
    "nitrogen_intake", "nitrogen_retention", "nitrogen_excretion",
    # Enteric direct emissions (cohort)
    "ch4_conversion_factor_ym", "ch4_enteric"
  )
  # When has_herd_structure is TRUE, the provided herd structure should structure inputs.
  cohort_blocklist <- if (has_herd_structure) {
    setdiff(
      gleam_calculated_columns,
      c("cohort_stock_size", "offtake_heads", "offtake_heads_assessment")
    )
  } else {
    gleam_calculated_columns
  }

  check_no_calculated_columns <- function(data, source_name, blocklist = gleam_calculated_columns) {
    if (is.null(data) || !is.data.frame(data)) return(invisible(NULL))
    provided_calc <- intersect(blocklist, names(data))
    if (length(provided_calc) > 0L) {
      cli::cli_abort(
        "Do not provide these variables in {.var {source_name}}: {.val {provided_calc}}.
        GLEAM calculates them; they are not expected as inputs."
      )
    }
  }

  check_no_calculated_columns(cohort_level_data, "cohort_level_data", blocklist = cohort_blocklist)
  check_no_calculated_columns(herd_level_data, "herd_level_data")
  check_no_calculated_columns(feed_rations, "feed_rations")

  # --- Herd ID consistency: same length and content across all inputs ---------
  # Helper: extract sorted unique herd_id from a table, or NULL if missing/empty.
  unique_herd_ids <- function(x) {
    if (is.null(x) || !"herd_id" %in% names(x)) return(NULL)
    ids <- sort(unique(x$herd_id))
    if (length(ids) == 0L) return(NULL)
    ids
  }

  # Build a named list of herd_id sets from every pipeline input that has herd_id.
  # Names identify the source (e.g. "cohort_level_data", "herd_level_data").
  herd_id_sets <- list()

  herd_ids_cohort <- unique_herd_ids(cohort_level_data)
  if (!is.null(herd_ids_cohort)) herd_id_sets[["cohort_level_data"]] <- herd_ids_cohort

  herd_ids_herd <- unique_herd_ids(herd_level_data)
  if (!is.null(herd_ids_herd)) herd_id_sets[["herd_level_data"]] <- herd_ids_herd

  # Weights and feed inputs
  herd_ids_feed <- unique_herd_ids(feed_rations)
  if (!is.null(herd_ids_feed)) herd_id_sets[["feed_rations"]] <- herd_ids_feed

  # At least one input must supply a non-empty herd_id set.
  if (length(herd_id_sets) == 0L) {
    cli::cli_abort(
      "No pipeline input with {.var herd_id} found. Input tables must
      contain a non-empty {.var herd_id} column."
    )
  }

  # Ensure every source has exactly the same set of herd_ids (length and content).
  reference_herd_ids <- herd_id_sets[[1L]]
  for (src_name in names(herd_id_sets)) {
    current_herd_ids <- herd_id_sets[[src_name]]
    same_length <- length(current_herd_ids) == length(reference_herd_ids)
    same_content <- setequal(current_herd_ids, reference_herd_ids)
    if (!same_length || !same_content) {
      cli::cli_abort(
        "All pipeline inputs must have the same {.var herd_id} set (same length and content).
        Reference has {.val {reference_herd_ids}}. Mismatch in {.var {src_name}}: {.val {current_herd_ids}}."
      )
    }
  }
}
