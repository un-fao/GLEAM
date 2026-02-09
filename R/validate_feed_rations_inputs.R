#' Validate inputs for run_feed_rations
#'
#' Validates that rations_share and feed_params have the expected structure,
#' required columns, and consistent identifiers.
#'
#' @param rations_share data.table. Feed shares per cohort.
#' @param feed_params data.table. Nutrient parameters for feed items.
#'
#' @noRd
validate_feed_rations_inputs <- function(
    rations_share,
    feed_params
) {
  # --- Basic type and structure checks ----------------------------------------
  if (!data.table::is.data.table(rations_share)) {
    cli::cli_abort("{.arg rations_share} must be a data.table.")
  }
  if (!data.table::is.data.table(feed_params)) {
    cli::cli_abort("{.arg feed_params} must be a data.table.")
  }

  if (nrow(rations_share) == 0) {
    cli::cli_abort("{.arg rations_share} must contain at least one row.")
  }
  if (nrow(feed_params) == 0) {
    cli::cli_abort("{.arg feed_params} must contain at least one row.")
  }

  # --- Required columns validation --------------------------------------------
  required_rations_cols <- c(
    "herd_id", "animal", "feed_name", "feed_id", "cohort_short",
    "feed_ration_fraction"
  )
  required_feed_cols <- c(
    "feed_id", "feed_name", "category", "feed_gross_energy",
    "feed_digestible_energy_ruminant", "feed_digestible_energy_pigs",
    "feed_metabolizable_energy_ruminant", "feed_metabolizable_energy_pigs",
    "feed_metabolizable_energy_chicken", "feed_nitrogen_content"
  )

  missing_rations_cols <- setdiff(required_rations_cols, names(rations_share))
  if (length(missing_rations_cols) > 0) {
    cli::cli_abort(
      "Missing required columns in {.arg rations_share}: {.val {missing_rations_cols}}"
    )
  }

  missing_feed_cols <- setdiff(required_feed_cols, names(feed_params))
  if (length(missing_feed_cols) > 0) {
    cli::cli_abort(
      "Missing required columns in {.arg feed_params}: {.val {missing_feed_cols}}"
    )
  }

  # --- Ration share consistency ------------------------------------------------
  ration_sums <- rations_share[
    ,
    .(feed_ration_sum = sum(feed_ration_fraction)),
    by = .(herd_id, animal, cohort_short)
  ]
  invalid_ration_sums <- ration_sums[abs(feed_ration_sum - 1) > 1e-6]
  if (nrow(invalid_ration_sums) > 0) {
    cli::cli_abort(
      "Feed rations must sum to 1 within each herd_id, animal, and cohort."
    )
  }

  # --- Feed parameter integrity checks ----------------------------------------
  if (anyDuplicated(feed_params$feed_id) > 0) {
    cli::cli_abort("{.arg feed_params$feed_id} must be unique.")
  }

  # Keep feed_id → feed_name mapping consistent across inputs
  # Validate mapping between feed_id and feed_name in rations_share
  feed_name_check <- merge(
    rations_share[, .(feed_id, feed_name)],
    unique(feed_params[, .(feed_id, feed_name)]),
    by = "feed_id",
    all.x = TRUE,
    suffixes = c("_input", "_params")
  )
  mismatched_feed_names <- feed_name_check[
    is.na(feed_name_params) | feed_name_input != feed_name_params,
    unique(feed_id)
  ]
  if (length(mismatched_feed_names) > 0) {
    cli::cli_abort(
      "feed_id values with missing or mismatched feed_name in {.arg feed_params}: {.val {mismatched_feed_names}}"
    )
  }
}
