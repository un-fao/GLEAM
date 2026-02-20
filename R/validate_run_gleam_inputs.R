#' Validate inputs for run_gleam
#'
#' Validates \code{has_herd_structure} (boolean), requires \code{herd_structure}
#' when TRUE, and ensures all input tables share the same \code{herd_id} set
#' (same length and same content). Schema checks for cohort/herd data are done
#' in the respective run_* functions (e.g. \code{run_herd_simulation}).
#'
#' @param has_herd_structure Logical. If TRUE, use \code{herd_structure} as
#'   cohort-level input for the weights step; if FALSE, run herd simulation first.
#' @param herd_structure data.table or NULL. Required when \code{has_herd_structure} is TRUE.
#' @param herd_simulation_args List.
#' @param weights_args List.
#' @param feed_rations_args List.
#' @param energy_requirements_args List.
#'
#' @noRd
validate_run_gleam_inputs <- function(
    has_herd_structure,
    herd_structure,
    herd_simulation_args,
    weights_args,
    feed_rations_args,
    energy_requirements_args
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

  # --- When has_herd_structure is TRUE, herd_structure must be provided -------
  if (has_herd_structure && is.null(herd_structure)) {
    cli::cli_abort(
      "When {.arg has_herd_structure} is TRUE, {.arg herd_structure} must be provided."
    )
  }

  # --- Herd ID consistency: same length and content across all inputs ---------
  # Helper: extract sorted unique herd_id from a table, or NULL if missing/empty.
  unique_herd_ids <- function(x) {
    if (is.null(x) || !"herd_id" %in% names(x)) return(NULL)
    ids <- sort(unique(x$herd_id))
    if (length(ids) == 0L) return(NULL)
    ids
  }

  # Build a named list of herd_id sets from every pipeline input that has herd_id.
  # Names identify the source (e.g. "herd_structure", "weights_args$herd_level_data").
  herd_id_sets <- list()

  # Cohort/herd source: either herd_structure (user-provided) or herd_simulation args.
  if (has_herd_structure) {
    herd_ids_structure <- unique_herd_ids(herd_structure)
    if (!is.null(herd_ids_structure)) herd_id_sets[["herd_structure"]] <- herd_ids_structure
  } else {
    herd_ids_simulation_cohort <- unique_herd_ids(herd_simulation_args$cohort_level_data)
    if (!is.null(herd_ids_simulation_cohort)) {
      herd_id_sets[["herd_simulation_args$cohort_level_data"]] <- herd_ids_simulation_cohort
    }
    herd_ids_simulation_herd <- unique_herd_ids(herd_simulation_args$herd_level_data)
    if (!is.null(herd_ids_simulation_herd)) {
      herd_id_sets[["herd_simulation_args$herd_level_data"]] <- herd_ids_simulation_herd
    }
  }

  # Weights and feed inputs
  herd_ids_weights <- unique_herd_ids(weights_args$herd_level_data)
  if (!is.null(herd_ids_weights)) herd_id_sets[["weights_args$herd_level_data"]] <- herd_ids_weights

  herd_ids_feed <- unique_herd_ids(feed_rations_args$feed_rations)
  if (!is.null(herd_ids_feed)) herd_id_sets[["feed_rations_args$feed_rations"]] <- herd_ids_feed

  # Energy requirements inputs
  herd_ids_energy_herd <- unique_herd_ids(energy_requirements_args$herd_level_data)
  if (!is.null(herd_ids_energy_herd)) {
    herd_id_sets[["energy_requirements_args$herd_level_data"]] <- herd_ids_energy_herd
  }

  herd_ids_energy_cohort <- unique_herd_ids(energy_requirements_args$cohort_level_data)
  if (!is.null(herd_ids_energy_cohort)) {
    herd_id_sets[["energy_requirements_args$cohort_level_data"]] <- herd_ids_energy_cohort
  }

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
