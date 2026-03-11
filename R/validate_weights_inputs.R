#' Validate inputs for run_weights_module
#'
#' Validates that cohort_level_data and herd_level_data have the correct structure,
#' required columns, and proper relationships between them.
#'
#' @param cohort_level_data data.table. Cohort-level data with one row per cohort.
#' @param herd_level_data data.table. Herd-level data with one row per herd.
#'
#' @noRd
validate_weights_inputs <- function(
    cohort_level_data,
    herd_level_data
) {

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

  # --- Required columns validation --------------------------------------------
  required_cohort_cols <- c(
    "herd_id", "cohort_short", "cohort_duration_days", "offtake_rate"
  )
  required_herd_cols <- c(
    "herd_id",
    "live_weight_female_adult",
    "live_weight_male_adult",
    "live_weight_at_birth",
    "live_weight_female_at_slaughter",
    "live_weight_male_at_slaughter",
    "live_weight_at_weaning"
  )

  missing_cohort_cols <- setdiff(required_cohort_cols, names(cohort_level_data))
  if (length(missing_cohort_cols) > 0) {
    cli::cli_abort(
      "Missing required columns in {.arg cohort_level_data}: {.val {missing_cohort_cols}}"
    )
  }

  missing_herd_cols <- setdiff(required_herd_cols, names(herd_level_data))
  if (length(missing_herd_cols) > 0) {
    cli::cli_abort(
      "Missing required columns in {.arg herd_level_data}: {.val {missing_herd_cols}}"
    )
  }

  # --- Cohort data validation -------------------------------------------------
  # Define valid cohort codes
  valid_cohorts <- c("FJ", "FS", "FA", "MJ", "MS", "MA")

  # Check for invalid cohort values
  invalid_cohorts <- setdiff(unique(cohort_level_data$cohort_short), valid_cohorts)
  if (length(invalid_cohorts) > 0) {
    cli::cli_abort(
      "Invalid cohort values in {.arg cohort_level_data}: {.val {invalid_cohorts}}.
      Must be one of: {.val {valid_cohorts}}"
    )
  }

  # Combined validation: check that each herd has exactly 6 cohorts and all required ones
  cohort_completeness <- cohort_level_data[
    , list(
      count = .N,
      has_all_cohorts = setequal(cohort_short, valid_cohorts),
      missing_cohorts = paste(setdiff(valid_cohorts, cohort_short), collapse = ", ")
    ),
    by = herd_id
  ]

  # Check for herds with wrong count
  wrong_count <- cohort_completeness[count != 6]
  if (nrow(wrong_count) > 0) {
    cli::cli_abort(
      "Each herd_id must have exactly 6 rows in {.arg cohort_level_data} (one per cohort).
      Found incorrect counts for herd_ids: {.val {wrong_count$herd_id}}"
    )
  }

  # Check for herds missing required cohorts or having duplicates
  # If count == 6 but has_all_cohorts == FALSE, there must be duplicates
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

  # --- Herd-level data validation ---------------------------------------------
  # Check for duplicate herd_ids in herd_level_data
  herd_id_counts <- herd_level_data[, .N, by = herd_id]
  duplicate_herds <- herd_id_counts[N > 1]
  if (nrow(duplicate_herds) > 0) {
    cli::cli_abort(
      "Each herd_id must appear exactly once in {.arg herd_level_data}.
      Found duplicates for herd_ids: {.val {duplicate_herds$herd_id}}"
    )
  }

  # --- Cross-table validation -------------------------------------------------
  # Validate that herd_ids match between the two tables
  cohort_herd_ids <- unique(cohort_level_data$herd_id)
  herd_level_herd_ids <- unique(herd_level_data$herd_id)

  missing_in_herd_level <- setdiff(cohort_herd_ids, herd_level_herd_ids)
  if (length(missing_in_herd_level) > 0) {
    cli::cli_abort(
      "Herd IDs in {.arg cohort_level_data} not found in {.arg herd_level_data}: {.val {missing_in_herd_level}}"
    )
  }

  missing_in_cohort <- setdiff(herd_level_herd_ids, cohort_herd_ids)
  if (length(missing_in_cohort) > 0) {
    cli::cli_abort(
      "Herd IDs in {.arg herd_level_data} not found in {.arg cohort_level_data}: {.val {missing_in_cohort}}"
    )
  }

  # --- Weight ordering validation (per herd_id) -------------------------------
  # For each herd: live_weight_at_birth must be less than live_weight_female_at_slaughter,
  # live_weight_male_at_slaughter, and live_weight_at_weaning (cohort slaughter weights are
  # derived from these, so this ensures live_weight_at_birth < live_weight_cohort_at_slaughter).
  violations_female <- herd_level_data[
    !is.na(live_weight_at_birth) & !is.na(live_weight_female_at_slaughter) & live_weight_at_birth >= live_weight_female_at_slaughter,
    herd_id
  ]
  if (length(violations_female) > 0) {
    cli::cli_abort(
      "For each herd_id, {.var live_weight_at_birth} must be less than {.var live_weight_female_at_slaughter}.
      Violation(s) for herd_id: {.val {violations_female}}"
    )
  }

  violations_male <- herd_level_data[
    !is.na(live_weight_at_birth) & !is.na(live_weight_male_at_slaughter) & live_weight_at_birth >= live_weight_male_at_slaughter,
    herd_id
  ]
  if (length(violations_male) > 0) {
    cli::cli_abort(
      "For each herd_id, {.var live_weight_at_birth} must be less than {.var live_weight_male_at_slaughter}.
      Violation(s) for herd_id: {.val {violations_male}}"
    )
  }

  violations_weaning <- herd_level_data[
    !is.na(live_weight_at_birth) & !is.na(live_weight_at_weaning) & live_weight_at_birth >= live_weight_at_weaning,
    herd_id
  ]
  if (length(violations_weaning) > 0) {
    cli::cli_abort(
      "For each herd_id, {.var live_weight_at_birth} must be less than {.var live_weight_at_weaning}.
      Violation(s) for herd_id: {.val {violations_weaning}}"
    )
  }
}
