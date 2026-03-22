#' Validate inputs for run_emissions_manure_module
#'
#' Validates that cohort-level manure inputs and MMS tables have the expected
#' structure, required columns, and consistent identifiers.
#'
#' @param cohort_level_data data.table. Cohort-level diet and nitrogen inputs for manure emissions.
#' @param manure_management_system_fraction data.table. Cohort-level MMS fractions.
#' @param manure_management_system_factors data.table. Herd-level MMS factors.
#'
#' @noRd
validate_run_emissions_manure_module_inputs <- function(
    cohort_level_data,
    manure_management_system_fraction,
    manure_management_system_factors
) {
  # --- Basic type and structure checks ----------------------------------------
  # Ensure all inputs are data.tables with at least one row
  check_data_table(cohort_level_data, "cohort_level_data")
  check_data_table(manure_management_system_fraction, "manure_management_system_fraction")
  check_data_table(manure_management_system_factors, "manure_management_system_factors")

  # --- Required columns validation --------------------------------------------
  required_input_cols <- c(
    "herd_id", "cohort_short", "ration_intake",
    "ration_digestibility_fraction", "nitrogen_excretion",
    "ration_urinary_energy_fraction", "ration_ash"
  )
  required_fraction_cols <- c(
    "herd_id", "cohort_short", "manure_management_system", "manure_management_system_fraction"
  )
  required_factors_cols <- c(
    "herd_id", "manure_management_system",
    "methane_conversion_factor_mcf", "ch4_max_producing_capacity_bo",
    "n2o_ef3", "n2o_ef4", "n2o_ef5", "nitrogen_fracgas", "nitrogen_fracleach"
  )

  check_required_columns(cohort_level_data, required_input_cols, "cohort_level_data")
  check_required_columns(manure_management_system_fraction, required_fraction_cols, "manure_management_system_fraction")
  check_required_columns(manure_management_system_factors, required_factors_cols, "manure_management_system_factors")

  # --- Missing key values -----------------------------------------------------
  if (any(is.na(cohort_level_data$herd_id)) ||
      any(is.na(cohort_level_data$cohort_short))) {
    cli::cli_abort("{.arg cohort_level_data} must not contain missing herd_id or cohort_short.")
  }
  if (any(is.na(cohort_level_data$ration_urinary_energy_fraction)) ||
      any(is.na(cohort_level_data$ration_ash))) {
    cli::cli_abort("{.arg cohort_level_data} must not contain missing ration_urinary_energy_fraction or ration_ash.")
  }
  if (any(is.na(manure_management_system_fraction$herd_id)) ||
      any(is.na(manure_management_system_fraction$cohort_short)) ||
      any(is.na(manure_management_system_fraction$manure_management_system))) {
    cli::cli_abort("{.arg manure_management_system_fraction} must not contain missing herd_id, cohort_short, or manure_management_system.")
  }
  if (any(is.na(manure_management_system_factors$herd_id)) ||
      any(is.na(manure_management_system_factors$manure_management_system))) {
    cli::cli_abort("{.arg manure_management_system_factors} must not contain missing herd_id or manure_management_system.")
  }

  # --- Cohort data validation -------------------------------------------------
  # Valid cohort codes in both cohort-level tables
  validate_cohort_short_values(cohort_level_data$cohort_short, data_arg = "cohort_level_data")
  validate_cohort_short_values(
    manure_management_system_fraction$cohort_short,
    data_arg = "manure_management_system_fraction"
  )

  # Each herd must have all 6 cohorts in cohort_level_data (one row per herd-cohort)
  check_cohort_completeness(cohort_level_data, "cohort_level_data")

  # Fraction table: each herd must have all 6 cohorts present (may have multiple rows per
  # cohort when multiple manure management systems exist)
  fraction_cohort_completeness <- manure_management_system_fraction[
    , list(
      count = data.table::uniqueN(cohort_short),
      has_all_cohorts = setequal(cohort_short, gleam_cohorts),
      missing_cohorts = paste(setdiff(gleam_cohorts, cohort_short), collapse = ", ")
    ),
    by = herd_id
  ]
  fraction_missing <- fraction_cohort_completeness[has_all_cohorts == FALSE]
  if (nrow(fraction_missing) > 0) {
    missing_info <- fraction_missing[
      , paste0(herd_id, " (missing: ", missing_cohorts, ")"),
      by = herd_id
    ]$V1
    cli::cli_abort(
      "Each herd_id must include all 6 cohorts in {.arg manure_management_system_fraction}.
      Missing cohorts found for herd_ids: {.val {missing_info}}"
    )
  }

  # --- Uniqueness checks ------------------------------------------------------
  duplicate_input <- cohort_level_data[
    , .N, by = .(herd_id, cohort_short)
  ][N > 1]
  if (nrow(duplicate_input) > 0) {
    cli::cli_abort(
      "Duplicate herd_id + cohort combinations in {.arg cohort_level_data}: {.val {duplicate_input$herd_id}}"
    )
  }

  duplicate_fraction <- manure_management_system_fraction[
    , .N, by = .(herd_id, cohort_short, manure_management_system)
  ][N > 1]
  if (nrow(duplicate_fraction) > 0) {
    cli::cli_abort(
      "Duplicate herd_id + cohort + manure_management_system rows in {.arg manure_management_system_fraction}."
    )
  }

  # --- MMS fraction sum-to-one checks (per herd_id + cohort_short) ------------
  fraction_sums <- manure_management_system_fraction[
    ,
    .(total_fraction = sum(manure_management_system_fraction)),
    by = .(herd_id, cohort_short)
  ]
  invalid_sums <- fraction_sums[
    is.na(total_fraction) | abs(total_fraction - 1) > 1e-8
  ]
  if (nrow(invalid_sums) > 0) {
    invalid_herds <- sort(unique(invalid_sums$herd_id))
    cli::cli_abort(
      "For each herd_id and cohort, the sum of MMS fractions in
      {.arg manure_management_system_fraction} must equal 1.
      \nInvalid herd_ids: {.val {invalid_herds}}"
    )
  }

  duplicate_factors <- manure_management_system_factors[
    , .N, by = .(herd_id, manure_management_system)
  ][N > 1]
  if (nrow(duplicate_factors) > 0) {
    cli::cli_abort(
      "Duplicate herd_id + manure_management_system rows in {.arg manure_management_system_factors}."
    )
  }

  # --- MMS consistency checks -------------------------------------------------
  # Every MMS used in fraction must have a corresponding entry in factors.
  # Factors may contain additional MMS entries — that is allowed.
  mms_fraction_by_herd <- manure_management_system_fraction[
    , .(mms_list = list(sort(unique(manure_management_system)))),
    by = herd_id
  ]
  mms_factors_by_herd <- manure_management_system_factors[
    , .(mms_list = list(sort(unique(manure_management_system)))),
    by = herd_id
  ]

  # Every herd_id in fraction must have factors coverage
  missing_in_factors_from_fraction <- setdiff(
    mms_fraction_by_herd$herd_id,
    mms_factors_by_herd$herd_id
  )
  if (length(missing_in_factors_from_fraction) > 0) {
    cli::cli_abort(
      "Herd IDs in {.arg manure_management_system_fraction} not found in
      {.arg manure_management_system_factors}: {.val {missing_in_factors_from_fraction}}"
    )
  }

  merged_mms <- merge(
    mms_fraction_by_herd,
    mms_factors_by_herd,
    by = "herd_id",
    suffixes = c("_fraction", "_factors")
  )

  # Check that every MMS in fraction is covered by factors (subset, not equality)
  missing_mms_coverage <- merged_mms[
    mapply(function(frac, fact) length(setdiff(frac, fact)) > 0,
           mms_list_fraction, mms_list_factors),
    herd_id
  ]
  if (length(missing_mms_coverage) > 0) {
    details <- merged_mms[
      herd_id %in% missing_mms_coverage,
      .(herd_id,
        missing = mapply(function(frac, fact) paste(setdiff(frac, fact), collapse = ", "),
                         mms_list_fraction, mms_list_factors))
    ]
    cli::cli_abort(
      c(
        "Some {.var manure_management_system} values in {.arg manure_management_system_fraction}
        have no matching entry in {.arg manure_management_system_factors}.",
        "i" = "Affected herd_ids and missing systems: {.val {details[, paste0(herd_id, ': ', missing)]}}"
      )
    )
  }

  # MMS list should be the same for all cohorts within a herd in the fraction table
  mms_by_herd_cohort <- manure_management_system_fraction[
    , .(mms_list = list(sort(unique(manure_management_system)))),
    by = .(herd_id, cohort_short)
  ]
  mms_consistency <- mms_by_herd_cohort[
    , .(
      unique_mms_sets = length(unique(vapply(mms_list, paste, collapse = "|", FUN.VALUE = character(1))))
    ),
    by = herd_id
  ]
  inconsistent_herds <- mms_consistency[unique_mms_sets > 1, herd_id]
  if (length(inconsistent_herds) > 0) {
    cli::cli_abort(
      "Within each herd_id, manure_management_system lists must be consistent across cohorts
      in {.arg manure_management_system_fraction}. Inconsistent herds: {.val {inconsistent_herds}}"
    )
  }

  # --- Cross-table herd_id validation -----------------------------------------
  input_herd_ids <- unique(cohort_level_data$herd_id)
  fraction_herd_ids <- unique(manure_management_system_fraction$herd_id)
  factors_herd_ids <- unique(manure_management_system_factors$herd_id)

  # Each herd_id + cohort_short in input must exist in fraction table
  input_pairs <- unique(
    cohort_level_data[, .(herd_id, cohort_short)]
  )
  fraction_pairs <- unique(
    manure_management_system_fraction[, .(herd_id, cohort_short)]
  )
  missing_pairs <- data.table::fsetdiff(input_pairs, fraction_pairs)
  if (nrow(missing_pairs) > 0) {
    missing_info <- missing_pairs[
      , paste0(herd_id, " / ", cohort_short)
    ]
    cli::cli_abort(
      "Missing herd_id + cohort combinations in {.arg manure_management_system_fraction}: {.val {missing_info}}"
    )
  }

  missing_in_fraction <- setdiff(input_herd_ids, fraction_herd_ids)
  if (length(missing_in_fraction) > 0) {
    cli::cli_abort(
      "Herd IDs in {.arg cohort_level_data} not found in
      {.arg manure_management_system_fraction}: {.val {missing_in_fraction}}"
    )
  }

  missing_in_input_from_fraction <- setdiff(fraction_herd_ids, input_herd_ids)
  if (length(missing_in_input_from_fraction) > 0) {
    cli::cli_abort(
      "Herd IDs in {.arg manure_management_system_fraction} not found in
      {.arg cohort_level_data}: {.val {missing_in_input_from_fraction}}"
    )
  }

  missing_in_factors <- setdiff(input_herd_ids, factors_herd_ids)
  if (length(missing_in_factors) > 0) {
    cli::cli_abort(
      "Herd IDs in {.arg cohort_level_data} not found in
      {.arg manure_management_system_factors}: {.val {missing_in_factors}}"
    )
  }

  missing_in_input_from_factors <- setdiff(factors_herd_ids, input_herd_ids)
  if (length(missing_in_input_from_factors) > 0) {
    cli::cli_abort(
      "Herd IDs in {.arg manure_management_system_factors} not found in
      {.arg cohort_level_data}: {.val {missing_in_input_from_factors}}"
    )
  }
}
