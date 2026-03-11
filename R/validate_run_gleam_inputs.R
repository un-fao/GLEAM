#' Validate inputs for run_gleam
#'
#' Validates \code{has_herd_structure} (boolean), requires direct input tables
#' (\code{cohort_level_data}, \code{herd_level_data}, \code{feed_rations},
#' \code{feed_params}, \code{manure_management_system_fraction},
#' \code{manure_management_system_factors}), and ensures all inputs share the same
#' \code{herd_id} set. Ensures input tables do not contain columns that GLEAM
#' calculates internally (e.g. \code{cohort_stock_size}, \code{daily_weight_gain}).
#' Schema checks for cohort/herd data are done in the respective run_* functions.
#'
#' @param has_herd_structure Logical. If TRUE, use \code{cohort_level_data} as
#'   cohort-level input for the weights step; if FALSE, run herd simulation first.
#' @param cohort_level_data data.table. Cohort-level master table.
#' @param herd_level_data data.table. Herd-level master table.
#' @param feed_rations data.table. Feed ration shares by cohort.
#' @param feed_params data.table. Feed nutritional parameters.
#' @param feed_emissions data.table. Feed production emission factors.
#' @param manure_management_system_fraction data.table. Cohort-level manure
#'   management system fractions.
#' @param manure_management_system_factors data.table. manure management system factors.
#' @param simulation_duration Numeric. Length of the assessment period (days).
#'
#' @noRd
validate_run_gleam_inputs <- function(
    has_herd_structure,
    cohort_level_data,
    herd_level_data,
    feed_rations,
    feed_params,
    feed_emissions,
    manure_management_system_fraction,
    manure_management_system_factors,
    simulation_duration
) {

  # --- simulation_duration: must be a single positive numeric ------------------
  if (
    !is.numeric(simulation_duration) ||
    length(simulation_duration) != 1L ||
    is.na(simulation_duration)
  ) {
    cli::cli_abort("{.arg simulation_duration} must be a single numeric value.")
  }
  if (simulation_duration <= 0) {
    cli::cli_abort("{.arg simulation_duration} must be positive (days).")
  }

  # --- has_herd_structure: must be a single boolean ---------------------------
  if (!is.logical(has_herd_structure) || length(has_herd_structure) != 1L) {
    cli::cli_abort(
      "{.arg has_herd_structure} must be a single logical value (TRUE or FALSE)."
    )
  }
  if (is.na(has_herd_structure)) {
    cli::cli_abort(
      "{.arg has_herd_structure} must be TRUE or FALSE, not NA."
    )
  }

  # --- Direct input tables must be provided (non-null, data.frame) -------------
  if (is.null(cohort_level_data) || !is.data.frame(cohort_level_data)) {
    cli::cli_abort("{.arg cohort_level_data} must be a data frame (e.g. data.table).")
  }
  if (is.null(herd_level_data) || !is.data.frame(herd_level_data)) {
    cli::cli_abort("{.arg herd_level_data} must be a data frame (e.g. data.table).")
  }
  if (is.null(feed_rations) || !is.data.frame(feed_rations)) {
    cli::cli_abort("{.arg feed_rations} must be a data frame (e.g. data.table).")
  }
  if (is.null(feed_params) || !is.data.frame(feed_params)) {
    cli::cli_abort("{.arg feed_params} must be a data frame (e.g. data.table).")
  }
  if (is.null(feed_emissions) || !is.data.frame(feed_emissions)) {
    cli::cli_abort("{.arg feed_emissions} must be a data frame (e.g. data.table).")
  }
  if (is.null(manure_management_system_fraction) || !is.data.frame(manure_management_system_fraction)) {
    cli::cli_abort("{.arg manure_management_system_fraction} must be a data frame (e.g. data.table).")
  }
  if (is.null(manure_management_system_factors) || !is.data.frame(manure_management_system_factors)) {
    cli::cli_abort("{.arg manure_management_system_factors} must be a data frame (e.g. data.table).")
  }

  # --- Required columns in cohort_level_data ----------------------------------
  required_cohort_cols <- c("herd_id", "animal", "cohort_short")
  missing_cohort_cols <- setdiff(required_cohort_cols, names(cohort_level_data))
  if (length(missing_cohort_cols) > 0L) {
    cli::cli_abort(
      "Missing required columns in {.arg cohort_level_data}: {.val {missing_cohort_cols}}.
      {.var animal} (e.g. Cattle, Buffalo) must be present for each cohort."
    )
  }

  # --- Block calculated (intermediate) variables in input tables ---------------
  # Columns that GLEAM computes; users must not provide them as inputs.
  gleam_calculated_columns <- c(
    # Herd simulation (cohort and herd)
    "cohort_stock_size", "offtake_heads", "offtake_heads_assessment", "growth_rate_herd",
    # Weights (cohort)
    "live_weight_mature_stage", "live_weight_cohort_initial", "live_weight_cohort_potential_final",
    "live_weight_cohort_at_slaughter", "live_weight_cohort_average", "live_weight_cohort_final",
    "daily_weight_gain",
    # Production cohort (cohort-level outputs)
    "milk_production_mass_cohort", "milk_production_protein_cohort", "milk_production_fpcm_cohort",
    "fibre_production_cohort",
    "meat_production_live_weight_cohort", "meat_production_carcass_weight_cohort",
    "meat_production_bone_free_meat_cohort", "meat_production_protein_cohort",
    # Feed rations (cohort-level outputs merged into pipeline)
    "ration_gross_energy", "ration_metabolizable_energy", "ration_nitrogen",
    "ration_digestibility_fraction", "ration_urinary_energy_fraction", "ration_ash",
    # Allocation (cohort-level energy allocation terms)
    "energy_allocation_milk", "energy_allocation_meat", "energy_allocation_fibre",
    "energy_allocation_work", "energy_allocation_eggs",
    # Feed emissions (cohort-level diet emission factors)
    "diet_co2_feed_fertilizer", "diet_co2_feed_pesticides",
    "diet_co2_feed_crop_operations", "diet_co2_feed_luc_nopeat", "diet_co2_feed_luc_peat",
    "diet_n2o_feed_fertilizer", "diet_n2o_feed_manure_applied", "diet_n2o_feed_crop_residues",
    "diet_ch4_feed_rice",
    # Energy requirements (cohort)
    "energy_requirement_maintenance", "energy_requirement_activity", "energy_requirement_growth",
    "energy_requirement_lactation", "energy_requirement_work",
    "energy_requirement_fibre_production", "energy_requirement_pregnancy",
    "net_energy_maintenance_digestible_energy_ratio",
    "net_energy_growth_digestible_energy_ratio",
    "energy_requirement_total", "dry_matter_intake",
    # Nitrogen balance (cohort)
    "nitrogen_intake", "nitrogen_retention", "nitrogen_excretion",
    # Enteric direct emissions (cohort)
    "ch4_conversion_factor_ym", "ch4_enteric",
    # Manure direct emissions (cohort)
    "volatile_solids",
    "ch4_manure_pasture", "ch4_manure_burned", "ch4_manure_other", "ch4_manure_all_noburn",
    "n2o_manure_pasture_direct", "n2o_manure_burned_direct", "n2o_manure_other_direct",
    "n2o_manure_all_noburn_direct",
    "n2o_vol_manure_pasture", "n2o_vol_manure_burned", "n2o_vol_manure_other",
    "n2o_vol_manure_all_noburn",
    "n2o_leach_manure_pasture", "n2o_leach_manure_burned", "n2o_leach_manure_other",
    "n2o_leach_manure_all_noburn",
    "n2o_manure_pasture_indirect", "n2o_manure_burned_indirect", "n2o_manure_other_indirect",
    "n2o_manure_pasture_total", "n2o_manure_burned_total", "n2o_manure_other_total"
  )
  # When has_herd_structure is TRUE, the provided herd structure should structure inputs.
  cohort_blocklist <- if (has_herd_structure) {
    setdiff(
      gleam_calculated_columns,
      c("cohort_stock_size", "offtake_heads", "offtake_heads_assessment")
    )
  } else {
    gleam_calculated_columns
  }

  check_no_calculated_columns <- function(data, source_name, blocklist = gleam_calculated_columns) {
    if (is.null(data) || !is.data.frame(data)) return(invisible(NULL))
    provided_calc <- intersect(blocklist, names(data))
    if (length(provided_calc) > 0L) {
      cli::cli_abort(
        "Do not provide these variables in {.var {source_name}}: {.val {provided_calc}}.
        GLEAM calculates them; they are not expected as inputs."
      )
    }
  }

  check_no_calculated_columns(cohort_level_data, "cohort_level_data", blocklist = cohort_blocklist)
  check_no_calculated_columns(herd_level_data, "herd_level_data")
  check_no_calculated_columns(feed_rations, "feed_rations")
  check_no_calculated_columns(feed_emissions, "feed_emissions")
  check_no_calculated_columns(manure_management_system_fraction, "manure_management_system_fraction")
  check_no_calculated_columns(manure_management_system_factors, "manure_management_system_factors")

  # --- Herd ID consistency: same length and content across all inputs ---------
  # Helper: extract sorted unique herd_id from a table, or NULL if missing/empty.
  unique_herd_ids <- function(x) {
    if (is.null(x) || !"herd_id" %in% names(x)) return(NULL)
    ids <- sort(unique(x$herd_id))
    if (length(ids) == 0L) return(NULL)
    ids
  }

  # Build a named list of herd_id sets from every pipeline input that has herd_id.
  # Names identify the source (e.g. "cohort_level_data", "herd_level_data").
  herd_id_sets <- list()

  herd_ids_cohort <- unique_herd_ids(cohort_level_data)
  if (!is.null(herd_ids_cohort)) herd_id_sets[["cohort_level_data"]] <- herd_ids_cohort

  herd_ids_herd <- unique_herd_ids(herd_level_data)
  if (!is.null(herd_ids_herd)) herd_id_sets[["herd_level_data"]] <- herd_ids_herd

  # Weights and feed inputs
  herd_ids_feed <- unique_herd_ids(feed_rations)
  if (!is.null(herd_ids_feed)) herd_id_sets[["feed_rations"]] <- herd_ids_feed

  herd_ids_mms_fraction <- unique_herd_ids(manure_management_system_fraction)
  if (!is.null(herd_ids_mms_fraction)) {
    herd_id_sets[["manure_management_system_fraction"]] <- herd_ids_mms_fraction
  }

  herd_ids_mms_factors <- unique_herd_ids(manure_management_system_factors)
  if (!is.null(herd_ids_mms_factors)) {
    herd_id_sets[["manure_management_system_factors"]] <- herd_ids_mms_factors
  }

  # At least one input must supply a non-empty herd_id set.
  if (length(herd_id_sets) == 0L) {
    cli::cli_abort(
      "No pipeline input with {.var herd_id} found. Input tables must
      contain a non-empty {.var herd_id} column."
    )
  }

  # Ensure every source has exactly the same set of herd_ids (length and content).
  reference_herd_ids <- herd_id_sets[[1L]]
  for (src_name in names(herd_id_sets)) {
    current_herd_ids <- herd_id_sets[[src_name]]
    same_length <- length(current_herd_ids) == length(reference_herd_ids)
    same_content <- setequal(current_herd_ids, reference_herd_ids)
    if (!same_length || !same_content) {
      cli::cli_abort(
        "All pipeline inputs must have the same {.var herd_id} set (same length and content).
        Reference has {.val {reference_herd_ids}}. Mismatch in {.var {src_name}}: {.val {current_herd_ids}}."
      )
    }
  }
}
