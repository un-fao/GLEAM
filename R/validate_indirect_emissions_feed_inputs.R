#' Validate inputs for run_feed_production_emissions
#'
#' Validates that rations_share and feed_emissions have the expected structure,
#' required columns, and consistent identifiers.
#'
#' @param rations_share data.table. Feed shares per cohort.
#' @param feed_emissions data.table. Feed production emission factors for feed items.
#'
#' @noRd
validate_feed_indirect_emissions_inputs <- function(
    rations_share,
    feed_emissions
) {
  # --- Basic type and structure checks ----------------------------------------
  if (!data.table::is.data.table(rations_share)) {
    cli::cli_abort("{.arg rations_share} must be a data.table.")
  }
  if (!data.table::is.data.table(feed_emissions)) {
    cli::cli_abort("{.arg feed_emissions} must be a data.table.")
  }
  
  if (nrow(rations_share) == 0) {
    cli::cli_abort("{.arg rations_share} must contain at least one row.")
  }
  if (nrow(feed_emissions) == 0) {
    cli::cli_abort("{.arg feed_emissions} must contain at least one row.")
  }
  
  # --- Required columns validation --------------------------------------------
  required_rations_cols <- c(
    "herd_id", "animal", "feed_name", "feed_id", "cohort_short",
    "feed_ration_fraction"
  )
  
  required_emissions_cols <- c(
    "feed_id",
    "co2_feed_fertilizer",
    "co2_feed_pesticides",
    "co2_feed_crop_operations",
    "co2_feed_luc_nopeat",
    "co2_feed_luc_peat",
    "n2o_feed_fertilizer",
    "n2o_feed_manure_applied",
    "n2o_feed_crop_residues",
    "ch4_feed_rice"
  )
  
  missing_rations_cols <- setdiff(required_rations_cols, names(rations_share))
  if (length(missing_rations_cols) > 0) {
    cli::cli_abort(
      "Missing required columns in {.arg rations_share}: {.val {missing_rations_cols}}"
    )
  }
  
  missing_emissions_cols <- setdiff(required_emissions_cols, names(feed_emissions))
  if (length(missing_emissions_cols) > 0) {
    cli::cli_abort(
      "Missing required columns in {.arg feed_emissions}: {.val {missing_emissions_cols}}"
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
      "Feed rations must sum to 1 within each herd_id, animal, and cohort_short."
    )
  }
  
  # --- Feed emissions integrity checks ----------------------------------------
  if (anyDuplicated(feed_emissions$feed_id) > 0) {
    cli::cli_abort("{.arg feed_emissions$feed_id} must be unique.")
  }
  
  # --- Optional feed_name consistency checks ----------------------------------
  if ("feed_name" %in% names(feed_emissions)) {
    feed_name_check <- merge(
      rations_share[, .(feed_id, feed_name)],
      unique(feed_emissions[, .(feed_id, feed_name)]),
      by = "feed_id",
      all.x = TRUE,
      suffixes = c("_input", "_emissions")
    )
    
    mismatched_feed_names <- feed_name_check[
      is.na(feed_name_emissions) | feed_name_input != feed_name_emissions,
      unique(feed_id)
    ]
    
    if (length(mismatched_feed_names) > 0) {
      cli::cli_abort(
        "feed_id values with missing or mismatched feed_name in {.arg feed_emissions}: {.val {mismatched_feed_names}}"
      )
    }
  }
  
  # --- Emissions value validation (type + range) ------------------------------
  emissions_value_cols <- setdiff(required_emissions_cols, "feed_id")
  
  # 1) Type checks: must be numeric. NA allowed.
  for (col in emissions_value_cols) {
    x <- feed_emissions[[col]]
    if (!is.numeric(x)) {
      cli::cli_abort("{.arg {col}} must be a single numeric (scalar). NA is allowed.")
    }
  }
  
  # 2) Range checks: must be >= 0. NA allowed.
  for (col in emissions_value_cols) {
    x <- feed_emissions[[col]]
    if (any(!is.na(x) & x < 0)) {
      cli::cli_abort("{.arg {col}} must be >= 0.")
    }
  }
}
