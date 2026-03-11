#' Validate inputs for run_emissions_ration_module
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
      "Feed emissions fractions must sum to 1 within each herd_id, animal, and cohort_short."
    )
  }

  # --- Rations_share key uniqueness -------------------------------------------
  # Prevent duplicate feed lines within a herd/cohort (and animal).
  # Expected grain: one row per feed per herd_id x animal x cohort_short.
  ration_scope <- c("herd_id", "animal", "cohort_short")

  # 1) feed_id must be unique within herd/animal/cohort
  dup_feed_id_rows <- rations_share[
    duplicated(rations_share[, c(ration_scope, "feed_id"), with = FALSE]) |
      duplicated(rations_share[, c(ration_scope, "feed_id"), with = FALSE], fromLast = TRUE),
    c(ration_scope, "feed_id"),
    with = FALSE
  ]

  if (nrow(dup_feed_id_rows) > 0) {
    preview <- utils::head(unique(dup_feed_id_rows), 10)
    cli::cli_abort(c(
      "{.arg rations_share} contains duplicated {.arg feed_id} within herd/cohort/animal.",
      "i" = "Expected unique rows by: {.val {c(ration_scope, 'feed_id')}}",
      "i" = "Duplicate keys (first 10):",
      "x" = paste(utils::capture.output(print(preview)), collapse = "\n")
    ))
  }

  # 2) feed_name must be unique within herd/animal/cohort
  dup_feed_name_rows <- rations_share[
    duplicated(rations_share[, c(ration_scope, "feed_name"), with = FALSE]) |
      duplicated(rations_share[, c(ration_scope, "feed_name"), with = FALSE], fromLast = TRUE),
    c(ration_scope, "feed_name"),
    with = FALSE
  ]

  if (nrow(dup_feed_name_rows) > 0) {
    preview <- utils::head(unique(dup_feed_name_rows), 10)
    cli::cli_abort(c(
      "{.arg rations_share} contains duplicated {.arg feed_name} within herd/cohort/animal.",
      "i" = "Expected unique rows by: {.val {c(ration_scope, 'feed_name')}}",
      "i" = "Duplicate keys (first 10):",
      "x" = paste(utils::capture.output(print(preview)), collapse = "\n")
    ))

  }
  # --- Feed emissions integrity checks ----------------------------------------
  dup_feed_ids <- feed_emissions[
    duplicated(feed_id) | duplicated(feed_id, fromLast = TRUE),
    unique(feed_id)
  ]

  if (length(dup_feed_ids) > 0) {
    cols_to_show <- intersect(c("feed_id", "feed_name"), names(feed_emissions))
    dup_rows <- unique(feed_emissions[feed_id %in% dup_feed_ids, ..cols_to_show])
    preview <- utils::head(dup_rows, 10)

    cli::cli_abort(c(
      "{.arg feed_emissions$feed_id} must be unique.",
      "i" = "Duplicated feed_id(s): {.val {dup_feed_ids}}",
      "i" = "Offending rows (first 10):",
      "x" = paste(utils::capture.output(print(preview)), collapse = "\n")
    ))
  }

  # 2) If feed_name is provided, it must be unique (show which ids share a name)
  if ("feed_name" %in% names(feed_emissions)) {

    dup_feed_names <- feed_emissions[
      !is.na(feed_name) &
        (duplicated(feed_name) | duplicated(feed_name, fromLast = TRUE)),
      unique(feed_name)
    ]

    if (length(dup_feed_names) > 0) {
      # Summarize which feed_ids each duplicated feed_name maps to
      dup_map <- feed_emissions[
        feed_name %in% dup_feed_names,
        .(feed_ids = paste(sort(unique(feed_id)), collapse = ", "),
          n_ids = data.table::uniqueN(feed_id)),
        by = feed_name
      ][order(-n_ids, feed_name)]

      preview <- utils::head(dup_map, 10)

      cli::cli_abort(c(
        "{.arg feed_emissions$feed_name} must be unique.",
        "i" = "Duplicated feed_name(s): {.val {dup_feed_names}}",
        "i" = "feed_name -> feed_id mapping (first 10 names):",
        "x" = paste(utils::capture.output(print(preview)), collapse = "\n")
      ))
    }
  }
  # Cross-check feed_name consistency between rations_share and feed_emissions by feed_id
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
