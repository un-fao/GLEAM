#' Validate inputs for run_gleam
#'
#' Validates \code{has_herd_structure} (boolean) and \code{herd_structure}
#' When \code{has_herd_structure} is TRUE, \code{herd_structure} must be provided.
#'
#' @param has_herd_structure Logical. If TRUE, use \code{herd_structure} as
#'   cohort-level input for the weights step; if FALSE, run herd simulation first.
#' @param herd_structure data.table or NULL. Cohort-level table used when
#'   \code{has_herd_structure} is TRUE.
#'
#' @noRd
validate_run_gleam_inputs <- function(
    has_herd_structure,
    herd_structure
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

  # --- If has_herd_structure is TRUE, herd_structure is required -------------
  if (has_herd_structure) {
    if (is.null(herd_structure)) {
      cli::cli_abort(
        "When {.arg has_herd_structure} is TRUE, {.arg herd_structure} must be provided."
      )
    }

    # --- herd_structure must be a data.table ----------------------------------
    if (!data.table::is.data.table(herd_structure)) {
      cli::cli_abort(
        "{.arg herd_structure} must be a data.table."
      )
    }

    if (nrow(herd_structure) == 0) {
      cli::cli_abort(
        "{.arg herd_structure} must contain at least one row."
      )
    }

    # --- Valid cohort codes ---------------------------------------------------
    valid_cohorts <- c("FJ", "FS", "FA", "MJ", "MS", "MA")
    invalid_cohorts <- setdiff(unique(herd_structure$cohort_short), valid_cohorts)
    if (length(invalid_cohorts) > 0) {
      cli::cli_abort(
        "Invalid cohort values in {.arg herd_structure}: {.val {invalid_cohorts}}.
        Must be one of: {.val {valid_cohorts}}"
      )
    }

    # --- Each herd_id must have exactly 6 rows (one per cohort) ----------------
    cohort_completeness <- herd_structure[
      , list(
        count = .N,
        has_all_cohorts = setequal(cohort_short, valid_cohorts),
        missing_cohorts = paste(setdiff(valid_cohorts, cohort_short), collapse = ", ")
      ),
      by = herd_id
    ]

    wrong_count <- cohort_completeness[count != 6L]
    if (nrow(wrong_count) > 0) {
      cli::cli_abort(
        "Each herd_id must have exactly 6 rows in {.arg herd_structure} (one per cohort).
        Found incorrect counts for herd_ids: {.val {wrong_count$herd_id}}"
      )
    }

    incomplete_herds <- cohort_completeness[has_all_cohorts == FALSE]
    if (nrow(incomplete_herds) > 0) {
      missing_info <- incomplete_herds[
        , paste0(herd_id, " (missing: ", missing_cohorts, ")"),
        by = herd_id
      ]$V1
      cli::cli_abort(
        "Each herd_id must have exactly one row for each of the 6 cohorts in {.arg herd_structure}.
        Incomplete or duplicate cohorts found for herd_ids: {.val {missing_info}}"
      )
    }
  }
}
