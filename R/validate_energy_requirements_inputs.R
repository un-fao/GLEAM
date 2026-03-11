#' Validate inputs for run_metabolic_energy_req_module
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
    "herd_id", "cohort_short",
    "live_weight_cohort_average", "offtake_rate",
    "low_activity_fraction", "high_activity_fraction",
    "live_weight_cohort_initial", "live_weight_cohort_final", "live_weight_mature_stage",
    "daily_weight_gain", "cohort_duration_days",
    "ration_digestibility_fraction", "ration_gross_energy", "ration_metabolizable_energy"
  )
  required_herd_cols <- c(
    "herd_id", "animal",
    "age_first_parturition", "lactating_females_fraction", "milk_yield_day", "milk_fat_fraction",
    "non_productive_duration", "pregnancy_duration", "litter_size", "death_rate_juvenile",
    "live_weight_at_birth", "live_weight_at_weaning",
    "lactation_duration", "parturition_rate", "egg_average_weight",
    "draught_work_hours_female", "draught_work_hours_male",
    "draught_fraction_female", "draught_fraction_male",
    "fibre_yield_year"
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

  invalid_cohorts <- setdiff(unique(cohort_level_data$cohort_short), valid_cohorts)
  if (length(invalid_cohorts) > 0) {
    cli::cli_abort(
      "Invalid cohort_short values in {.arg cohort_level_data}: {.val {invalid_cohorts}}.
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
  # low_activity_fraction + high_activity_fraction >= 0 and <= 1 per row
  cohort_level_data[
    , activity_sum := low_activity_fraction + high_activity_fraction
  ]
  bad_activity_high <- cohort_level_data[activity_sum > 1, .(herd_id, cohort_short)]
  bad_activity_low <- cohort_level_data[activity_sum < 0, .(herd_id, cohort_short)]
  cohort_level_data[, activity_sum := NULL]
  if (nrow(bad_activity_high) > 0) {
    bad_info <- bad_activity_high[, paste0(herd_id, " / ", cohort_short)]
    cli::cli_abort(
      "For each row, {.field low_activity_fraction} + {.field high_activity_fraction} must be <= 1.
      Violation(s): {.val {bad_info}}"
    )
  }
  if (nrow(bad_activity_low) > 0) {
    bad_info <- bad_activity_low[, paste0(herd_id, " / ", cohort_short)]
    cli::cli_abort(
      "For each row, {.field low_activity_fraction} + {.field high_activity_fraction} must be >= 0.
      Violation(s): {.val {bad_info}}"
    )
  }

  # live_weight_cohort_initial <= live_weight_cohort_average <= live_weight_cohort_final (skip if any NA)
  inconsistent_weights <- cohort_level_data[
    !is.na(live_weight_cohort_initial) & !is.na(live_weight_cohort_average) & !is.na(live_weight_cohort_final) &
      (live_weight_cohort_initial > live_weight_cohort_average | live_weight_cohort_average > live_weight_cohort_final),
    .(herd_id, cohort_short)
  ]
  if (nrow(inconsistent_weights) > 0) {
    bad_info <- inconsistent_weights[, paste0(herd_id, " / ", cohort_short)]
    cli::cli_abort(
      "For each row, {.field live_weight_cohort_initial} <= {.field live_weight_cohort_average} <= {.field live_weight_cohort_final} must hold.
      Violation(s): {.val {bad_info}}"
    )
  }

  # --- Numeric consistency (herd-level) ----------------------------------------
  # live_weight_at_birth < live_weight_at_weaning where both present (strict)
  bad_birth_weaning <- herd_level_data[
    !is.na(live_weight_at_birth) & !is.na(live_weight_at_weaning) & live_weight_at_birth >= live_weight_at_weaning,
    herd_id
  ]
  if (length(bad_birth_weaning) > 0) {
    cli::cli_abort(
      "For each herd, {.field live_weight_at_birth} must be strictly less than {.field live_weight_at_weaning}.
      Violation(s) for herd_id: {.val {bad_birth_weaning}}"
    )
  }
}
