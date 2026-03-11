#' Validate inputs for run_aggregation_module
#'
#' Validates that cohort_level_data and allocation_herd_long have the expected
#' structure, required columns, and consistent herd_id linkage.
#'
#' @param cohort_level_data data.table. Cohort-level data with calculated variables.
#' @param allocation_herd_long data.table. Herd-level allocation shares in long format.
#' @param simulation_duration Numeric. Length of the assessment period (days).
#' @param global_warming_potential_set Character. GWP-100 option for CO2eq conversion.
#'
#' @noRd
validate_run_aggregation_module_inputs <- function(
    cohort_level_data,
    allocation_herd_long,
    simulation_duration,
    global_warming_potential_set
) {
  # --- Basic type and structure checks ----------------------------------------
  if (!data.table::is.data.table(cohort_level_data)) {
    cli::cli_abort("{.arg cohort_level_data} must be a data.table.")
  }
  if (!data.table::is.data.table(allocation_herd_long)) {
    cli::cli_abort("{.arg allocation_herd_long} must be a data.table.")
  }

  if (nrow(cohort_level_data) == 0) {
    cli::cli_abort("{.arg cohort_level_data} must contain at least one row.")
  }
  if (nrow(allocation_herd_long) == 0) {
    cli::cli_abort("{.arg allocation_herd_long} must contain at least one row.")
  }

  # --- Required columns: cohort level -----------------------------------------
  required_cohort_cols <- c("herd_id", "cohort_short", "cohort_stock_size")
  missing_cohort_cols <- setdiff(required_cohort_cols, names(cohort_level_data))
  if (length(missing_cohort_cols) > 0) {
    cli::cli_abort(
      "Missing required columns in {.arg cohort_level_data}: {.val {missing_cohort_cols}}"
    )
  }

  # Cohort must have either animal or species_short (for mapping to species_short)
  if (!"animal" %in% names(cohort_level_data) && !"species_short" %in% names(cohort_level_data)) {
    cli::cli_abort(
      "{.arg cohort_level_data} must contain either {.var animal} or {.var species_short}."
    )
  }

  # --- Required columns: allocation ------------------------------------------
  required_allocation_cols <- c(
    "herd_id", "species_short", "variable_name",
    "commodity_name", "allocation_share"
  )
  missing_allocation_cols <- setdiff(required_allocation_cols, names(allocation_herd_long))
  if (length(missing_allocation_cols) > 0) {
    cli::cli_abort(
      "Missing required columns in {.arg allocation_herd_long}: {.val {missing_allocation_cols}}"
    )
  }

  # --- simulation_duration validation -----------------------------------------
  if (!is.numeric(simulation_duration) || length(simulation_duration) != 1L || is.na(simulation_duration)) {
    cli::cli_abort("{.arg simulation_duration} must be a single numeric value.")
  }
  if (simulation_duration <= 0) {
    cli::cli_abort("{.arg simulation_duration} must be positive (days).")
  }

  # --- global_warming_potential_set validation ------------------------------
  valid_gwp <- c(
    "AR6", "AR5_excluding_carbon_feedback", "AR5_including_carbon_feedback", "AR4"
  )
  if (!is.character(global_warming_potential_set) || length(global_warming_potential_set) != 1L) {
    cli::cli_abort("{.arg global_warming_potential_set} must be a single character value.")
  }
  if (!global_warming_potential_set %in% valid_gwp) {
    cli::cli_abort(
      "{.arg global_warming_potential_set} must be one of: {.val {valid_gwp}}"
    )
  }

  # --- allocation_share bounds ------------------------------------------------
  if (any(allocation_herd_long$allocation_share < 0, na.rm = TRUE) ||
      any(allocation_herd_long$allocation_share > 1, na.rm = TRUE)) {
    cli::cli_abort(
      "{.var allocation_share} in {.arg allocation_herd_long} must be between 0 and 1."
    )
  }

  # --- Build cohort (herd_id, species_short) set for cross-validation ----------
  cohort_check <- data.table::copy(cohort_level_data)
  if (!"species_short" %in% names(cohort_check) && "animal" %in% names(cohort_check)) {
    cohort_check[abbr_animals, species_short := i.species_short, on = "animal"]
    unmapped <- cohort_check[is.na(species_short), unique(animal)]
    if (length(unmapped) > 0) {
      cli::cli_abort(
        "Unknown {.var animal} values in {.arg cohort_level_data}: {.val {unmapped}}.
        Must be one of: {.val {abbr_animals$animal}}"
      )
    }
  }
  cohort_herd_species <- unique(cohort_check[, .(herd_id, species_short)])
  allocation_herd_species <- unique(allocation_herd_long[, .(herd_id, species_short)])

  # --- Cross-table: cohort herd_ids in allocation ----------------------------
  cohort_herd_ids <- unique(cohort_check$herd_id)
  allocation_herd_ids <- unique(allocation_herd_long$herd_id)

  missing_in_allocation <- setdiff(cohort_herd_ids, allocation_herd_ids)
  if (length(missing_in_allocation) > 0) {
    cli::cli_abort(
      "Herd IDs in {.arg cohort_level_data} not found in {.arg allocation_herd_long}: {.val {missing_in_allocation}}"
    )
  }

  missing_in_cohort <- setdiff(allocation_herd_ids, cohort_herd_ids)
  if (length(missing_in_cohort) > 0) {
    cli::cli_abort(
      "Herd IDs in {.arg allocation_herd_long} not found in {.arg cohort_level_data}: {.val {missing_in_cohort}}"
    )
  }

  # --- Cross-table: (herd_id, species_short) coverage -----------------------
  # Every cohort herd × species must have allocation entries
  cohort_keys <- cohort_herd_species[, paste(herd_id, species_short, sep = "|")]
  allocation_keys <- allocation_herd_species[, paste(herd_id, species_short, sep = "|")]
  missing_keys <- setdiff(cohort_keys, allocation_keys)
  if (length(missing_keys) > 0) {
    cli::cli_abort(
      "Some (herd_id, species_short) combinations in {.arg cohort_level_data} have no ",
      "entries in {.arg allocation_herd_long}: {.val {missing_keys}}"
    )
  }

  # --- Valid cohort_short values ----------------------------------------------
  valid_cohorts <- c("FJ", "FS", "FA", "MJ", "MS", "MA")
  invalid_cohorts <- setdiff(unique(cohort_level_data$cohort_short), valid_cohorts)
  if (length(invalid_cohorts) > 0) {
    cli::cli_abort(
      "Invalid {.var cohort_short} values in {.arg cohort_level_data}: {.val {invalid_cohorts}}.
      Must be one of: {.val {valid_cohorts}}"
    )
  }

  # --- cohort_stock_size non-negative ----------------------------------------
  if (any(cohort_level_data$cohort_stock_size < 0, na.rm = TRUE)) {
    cli::cli_abort(
      "{.var cohort_stock_size} in {.arg cohort_level_data} must be non-negative."
    )
  }
}
