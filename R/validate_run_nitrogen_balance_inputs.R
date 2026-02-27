#' Validate inputs for run_nitrogen_balance
#'
#' Validates that cohort_level_data and herd_level_data have the correct structure,
#' required columns, valid species and cohort codes, and consistent herd_id linkage.
#' Detailed scalar-level checks (ranges, required parameters by species) are handled
#' by the nitrogen balance core model validators.
#'
#' @param cohort_level_data data.table. Cohort-level inputs (one row per herd-cohort).
#' @param herd_level_data data.table. Herd-level inputs (one row per herd).
#'
#' @noRd
validate_run_nitrogen_balance_inputs <- function(cohort_level_data, herd_level_data) {

  # --- Basic type and structure checks ----------------------------------------
  if (!data.table::is.data.table(cohort_level_data)) {
    cli::cli_abort("{.arg cohort_level_data} must be a data.table.")
  }
  if (!data.table::is.data.table(herd_level_data)) {
    cli::cli_abort("{.arg herd_level_data} must be a data.table.")
  }

  if (nrow(cohort_level_data) == 0) {
    cli::cli_abort("{.arg cohort_level_data} must contain at least one row.")
  }
  if (nrow(herd_level_data) == 0) {
    cli::cli_abort("{.arg herd_level_data} must contain at least one row.")
  }

  # --- Required columns: cohort (herd_id, cohort_short, cohort-level vars) ----
  required_cohort_cols <- c(
    "herd_id", "cohort_short",
    "dry_matter_intake", "diet_nitrogen", "daily_weight_gain", "cohort_duration_days"
  )
  missing_cohort_cols <- setdiff(required_cohort_cols, names(cohort_level_data))
  if (length(missing_cohort_cols) > 0) {
    cli::cli_abort(
      "Missing required columns in {.arg cohort_level_data}: {.val {missing_cohort_cols}}"
    )
  }

  # --- Required columns: herd (herd_id, animal, herd-level vars) ---------------
  required_herd_cols <- c(
    "herd_id", "animal",
    "milk_protein_fraction", "milk_yield_day", "fibre_yield_year",
    "litter_size", "parturition_rate",
    "weaning_weight", "birth_weight", "pregnancy_duration"
  )
  missing_herd_cols <- setdiff(required_herd_cols, names(herd_level_data))
  if (length(missing_herd_cols) > 0) {
    cli::cli_abort(
      "Missing required columns in {.arg herd_level_data}: {.val {missing_herd_cols}}"
    )
  }

  # --- Cohort: valid cohort_short, exactly 6 rows per herd_id -----------------
  valid_cohorts <- c("FJ", "FS", "FA", "MJ", "MS", "MA")
  invalid_cohorts <- setdiff(unique(cohort_level_data$cohort_short), valid_cohorts)
  if (length(invalid_cohorts) > 0) {
    cli::cli_abort(
      "Invalid {.var cohort_short} values in {.arg cohort_level_data}: {.val {invalid_cohorts}}.
      Must be one of: {.val {valid_cohorts}}"
    )
  }

  cohort_completeness <- cohort_level_data[
    , list(
      count = .N,
      has_all_cohorts = setequal(cohort_short, valid_cohorts),
      missing_cohorts = paste(setdiff(valid_cohorts, cohort_short), collapse = ", ")
    ),
    by = herd_id
  ]

  wrong_count <- cohort_completeness[count != 6]
  if (nrow(wrong_count) > 0) {
    cli::cli_abort(
      "Each herd_id must have exactly 6 rows in {.arg cohort_level_data} (one per cohort).
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
      "Each herd_id must have exactly one row for each of the 6 cohorts in {.arg cohort_level_data}.
      Incomplete or duplicate cohorts found for herd_ids: {.val {missing_info}}"
    )
  }

  # --- Herd: unique herd_id ---------------------------------------------------
  herd_id_counts <- herd_level_data[, .N, by = herd_id]
  duplicate_herds <- herd_id_counts[N > 1]
  if (nrow(duplicate_herds) > 0) {
    cli::cli_abort(
      "Each herd_id must appear exactly once in {.arg herd_level_data}.
      Found duplicates for herd_ids: {.val {duplicate_herds$herd_id}}"
    )
  }

  # --- Herd: valid animal (full names, mapped via abbr_animals) ---------------
  valid_animals <- c("Cattle", "Buffalo", "Sheep", "Goats", "Chicken", "Pigs", "Camels")
  invalid_animals <- setdiff(unique(herd_level_data$animal), valid_animals)
  if (length(invalid_animals) > 0) {
    cli::cli_abort(
      "Invalid {.var animal} values in {.arg herd_level_data}: {.val {invalid_animals}}.
      Must be one of: {.val {valid_animals}}"
    )
  }

  # --- Cross-table: same herd_id set ------------------------------------------
  cohort_herd_ids <- sort(unique(cohort_level_data$herd_id))
  herd_level_herd_ids <- sort(unique(herd_level_data$herd_id))

  missing_in_herd_level <- setdiff(cohort_herd_ids, herd_level_herd_ids)
  if (length(missing_in_herd_level) > 0) {
    cli::cli_abort(
      "Herd IDs in {.arg cohort_level_data} not found in {.arg herd_level_data}:
      {.val {missing_in_herd_level}}"
    )
  }

  missing_in_cohort <- setdiff(herd_level_herd_ids, cohort_herd_ids)
  if (length(missing_in_cohort) > 0) {
    cli::cli_abort(
      "Herd IDs in {.arg herd_level_data} not found in {.arg cohort_level_data}:
      {.val {missing_in_cohort}}"
    )
  }
}
