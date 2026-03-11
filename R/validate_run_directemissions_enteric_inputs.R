#' Validate inputs for run_emissions_enteric_module
#'
#' Validates that cohort-level data has the correct structure, required columns,
#' valid cohort and species codes, and exactly 6 cohorts per herd_id.
#'
#' @param data data.table. Cohort-level data with one row per herd x cohort.
#'
#' @noRd
validate_run_emissions_enteric_module_inputs <- function(data) {

  # --- Basic type and structure checks ----------------------------------------
  if (!data.table::is.data.table(data)) {
    cli::cli_abort("{.arg data} must be a data.table.")
  }

  if (nrow(data) == 0) {
    cli::cli_abort("{.arg data} must contain at least one row.")
  }

  # --- Required columns validation --------------------------------------------
  required_cols <- c(
    "herd_id", "animal", "cohort_short", "diet_digestibility_fraction",
    "diet_gross_energy", "dry_matter_intake"
  )
  missing_cols <- setdiff(required_cols, names(data))
  if (length(missing_cols) > 0) {
    cli::cli_abort(
      "Missing required columns in {.arg data}: {.val {missing_cols}}"
    )
  }

  # --- Valid cohort and animal (full name) codes ------------------------------
  valid_cohorts <- c("FJ", "FS", "FA", "MJ", "MS", "MA")
  valid_animals_full <- c("Cattle", "Buffalo", "Sheep", "Goats", "Chicken", "Pigs", "Camels")

  invalid_cohorts <- setdiff(unique(data$cohort_short), valid_cohorts)
  if (length(invalid_cohorts) > 0) {
    cli::cli_abort(
      "Invalid {.var cohort_short} values in {.arg data}: {.val {invalid_cohorts}}.
      Must be one of: {.val {valid_cohorts}}"
    )
  }

  invalid_animals <- setdiff(unique(data$animal), valid_animals_full)
  if (length(invalid_animals) > 0) {
    cli::cli_abort(
      "Invalid {.var animal} values in {.arg data}: {.val {invalid_animals}}.
      Must be one of: {.val {valid_animals_full}}"
    )
  }

  # --- Cohort completeness per herd_id ----------------------------------------
  # Each herd_id must have exactly 6 rows (one per cohort).
  cohort_completeness <- data[
    ,
    list(
      count = .N,
      has_all_cohorts = setequal(cohort_short, valid_cohorts),
      missing_cohorts = paste(setdiff(valid_cohorts, cohort_short), collapse = ", ")
    ),
    by = herd_id
  ]

  wrong_count <- cohort_completeness[count != 6]
  if (nrow(wrong_count) > 0) {
    cli::cli_abort(
      "Each herd_id must have exactly 6 rows in {.arg data} (one per cohort).
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
      "Each herd_id must have exactly one row for each of the 6 cohorts in {.arg data}.
      Incomplete or duplicate cohorts found for herd_ids: {.val {missing_info}}"
    )
  }
}
