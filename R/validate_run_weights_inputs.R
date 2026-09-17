#' Validate inputs for run_weights_module
#'
#' Validates that cohort_level_data and herd_level_data have the correct structure,
#' required columns, and proper relationships between them.
#'
#' @param cohort_level_data data.table. Cohort-level data with one row per cohort.
#' @param herd_level_data data.table. Herd-level data with one row per herd.
#'
#' @noRd
validate_run_weights_module_inputs <- function(
    cohort_level_data,
    herd_level_data
) {
  if (!validation_enabled()) return(invisible(NULL))
  # --- Basic type and structure checks ----------------------------------------
  # Ensure inputs are data.tables with at least one row
  check_data_table(cohort_level_data, "cohort_level_data")
  check_data_table(herd_level_data, "herd_level_data")

  # --- Required columns -------------------------------------------------------
  # Structural columns
  structural_cohort_cols <- c(
    "herd_id",
    "species_short",
    "cohort_short"
  )
  check_required_columns(cohort_level_data, structural_cohort_cols, "cohort_level_data")
  check_required_columns(herd_level_data, "herd_id", "herd_level_data")


  # --- Supported species and cohorts ----------------------------------------
  validate_species_short_values(
    cohort_level_data$species_short,
    data_arg = "cohort_level_data"
  )

  validate_cohort_short_values(
    cohort_level_data$cohort_short,
    data_arg = "cohort_level_data"
  )

  # Module-specific columns
  rules <- get_required_parameter_rules(cohort_level_data, module_filter = "weights")
  required_cohort_cols <- rules[input_table == "cohort_level_data", unique(variable)]
  required_herd_cols <- rules[input_table == "herd_level_data", unique(variable)]

  check_required_columns(cohort_level_data, unique(c(structural_cohort_cols, required_cohort_cols)), "cohort_level_data")
  check_required_columns(herd_level_data, unique(c("herd_id", required_herd_cols)), "herd_level_data")

  check_contextual_parameter_ranges(cohort_level_data, cohort_level_data)

  # Weights are joined by herd_id, so each herd must describe one species.
  herd_species <- unique(cohort_level_data[, .(herd_id, species_short)])
  mixed_species_herds <- herd_species[, .N, by = herd_id][N > 1L, herd_id]
  if (length(mixed_species_herds) > 0L) {
    cli::cli_abort("Each herd_id must have a single species_short. Violation(s) for herd_id: {.val {mixed_species_herds}}")
  }
  if ("species_short" %in% names(herd_level_data)) {
    validate_species_short_values(herd_level_data$species_short, data_arg = "herd_level_data")
    mismatched <- herd_species[!herd_level_data, on = .(herd_id, species_short), herd_id]
    if (length(mismatched) > 0L) {
      cli::cli_abort("species_short must agree between cohort_level_data and herd_level_data for herd_id: {.val {mismatched}}")
    }
  }

  # --- Check for duplicated cohorts ------------------------------------------
  check_cohort_uniqueness(cohort_level_data)

  # --- Herd: one row per herd_id -----------------------------------------------
  check_herd_id_unique(herd_level_data, "herd_level_data")

  # --- Cross-table: same herd_id set -------------------------------------------
  check_herd_id_consistency(
    cohort_level_data, herd_level_data,
    "cohort_level_data", "herd_level_data"
  )

  check_contextual_parameter_ranges(herd_level_data, cohort_level_data, "run_weights_module")

  invisible(TRUE)
}
