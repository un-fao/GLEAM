#' Validate inputs for run_energy_requirements
#'
#' Validates that cohort_level_data and herd_level_data have the correct structure,
#' required columns, valid cohort and animal values, and consistent herd_id linkage.
#'
#' @param cohort_level_data data.table. Cohort-level inputs (one row per herd-cohort).
#' @param herd_level_data data.table. Herd-level inputs (one row per herd).
#'
#' @noRd
validate_energy_requirements_inputs <- function(
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
    "herd_id", "cohort",
    "average_weight", "offtake_rate",
    "activity_fraction", "high_activity_fraction",
    "initial_weight", "final_weight", "adult_weight",
    "dwg", "duration",
    "diet_dig", "diet_ge", "diet_me",
    "lambing_interval"
  )
  required_herd_cols <- c(
    "herd_id", "animal",
    "afc", "milking_fraction", "milk_yield", "milk_fat",
    "idle", "gest", "litsize", "dr1", "ckg", "wkg",
    "lact", "parturition_rate", "egg_weight",
    "work_hours_female", "work_hours_male",
    "draught_fraction_female", "draught_fraction_male",
    "fibre_prod"
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
  valid_cohorts <- c("FJ", "FS", "FA", "MJ", "MS", "MA")

  invalid_cohorts <- setdiff(unique(cohort_level_data$cohort), valid_cohorts)
  if (length(invalid_cohorts) > 0) {
    cli::cli_abort(
      "Invalid cohort values in {.arg cohort_level_data}: {.val {invalid_cohorts}}.
      Must be one of: {.val {valid_cohorts}}"
    )
  }

  cohort_completeness <- cohort_level_data[
    , list(
      count = .N,
      has_all_cohorts = setequal(cohort, valid_cohorts),
      missing_cohorts = paste(setdiff(valid_cohorts, cohort), collapse = ", ")
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

  # --- Herd-level data validation ---------------------------------------------
  herd_id_counts <- herd_level_data[, .N, by = herd_id]
  duplicate_herds <- herd_id_counts[N > 1]
  if (nrow(duplicate_herds) > 0) {
    cli::cli_abort(
      "Each herd_id must appear exactly once in {.arg herd_level_data}.
      Found duplicates for herd_ids: {.val {duplicate_herds$herd_id}}"
    )
  }

  valid_animals <- c("Cattle", "Buffalo", "Sheep", "Goats", "Chicken", "Pigs", "Camels")
  invalid_animals <- setdiff(unique(herd_level_data$animal), valid_animals)
  if (length(invalid_animals) > 0) {
    cli::cli_abort(
      "Invalid {.field animal} values in {.arg herd_level_data}: {.val {invalid_animals}}.
      Must be one of: {.val {valid_animals}}"
    )
  }

  # --- Cross-table validation -------------------------------------------------
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

  # --- Numeric consistency (cohort-level) ---------------------------------------
  # activity_fraction + high_activity_fraction <= 1 per row
  cohort_level_data[
    , activity_sum := activity_fraction + high_activity_fraction
  ]
  bad_activity <- cohort_level_data[activity_sum > 1, .(herd_id, cohort)]
  cohort_level_data[, activity_sum := NULL]
  if (nrow(bad_activity) > 0) {
    bad_info <- bad_activity[, paste0(herd_id, " / ", cohort)]
    cli::cli_abort(
      "For each row, {.field activity_fraction} + {.field high_activity_fraction} must be <= 1.
      Violation(s): {.val {bad_info}}"
    )
  }

  # initial_weight <= average_weight <= final_weight (skip if any NA)
  inconsistent_weights <- cohort_level_data[
    !is.na(initial_weight) & !is.na(average_weight) & !is.na(final_weight) &
      (initial_weight > average_weight | average_weight > final_weight),
    .(herd_id, cohort)
  ]
  if (nrow(inconsistent_weights) > 0) {
    bad_info <- inconsistent_weights[, paste0(herd_id, " / ", cohort)]
    cli::cli_abort(
      "For each row, {.field initial_weight} <= {.field average_weight} <= {.field final_weight} must hold.
      Violation(s): {.val {bad_info}}"
    )
  }

  # --- Numeric consistency (herd-level) ----------------------------------------
  # ckg <= wkg where both present
  bad_ckg_wkg <- herd_level_data[
    !is.na(ckg) & !is.na(wkg) & ckg > wkg,
    herd_id
  ]
  if (length(bad_ckg_wkg) > 0) {
    cli::cli_abort(
      "For each herd, {.field ckg} must be <= {.field wkg}.
      Violation(s) for herd_id: {.val {bad_ckg_wkg}}"
    )
  }
}
