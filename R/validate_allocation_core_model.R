#' Validate inputs for calc_energy_allocation_milk
#'
#' Ensures that inputs for the milk energy allocation calculation
#' are correctly typed and within valid ranges. Specifically:
#' * All inputs must be numeric scalars (length 1, not NA).
#' * `milk_fpcm_output` must be non-negative.
#' * `standard_protein`, `standard_fat`, and `standard_lactose` must be
#'   between 0 and 1 (representing g per 100 g milk).
#'
#' This validator is designed for internal use in
#' [calc_energy_allocation_milk()].
#'
#' @param milk_fpcm_output Numeric scalar. Fat- and protein-corrected milk production (kg).
#' @param standard_protein Numeric scalar. Reference protein content (g per 100 g milk).
#' @param standard_fat Numeric scalar. Reference fat content (g per 100 g milk).
#' @param standard_lactose Numeric scalar. Reference lactose content (g per 100 g milk).
#'
#' @noRd
validate_allocation_milk_inputs <- function(
    milk_production_fpcm_cohort,
    milk_protein_fraction_standard,
    milk_fat_fraction_standard,
    milk_lactose_fraction_standard
) {
  # Range checks via parameter_ranges
  validate_param_range(milk_production_fpcm_cohort)
  validate_param_range(milk_protein_fraction_standard)
  validate_param_range(milk_fat_fraction_standard)
  validate_param_range(milk_lactose_fraction_standard)
}

#' Validate inputs for calc_energy_allocation_meat
#'
#' Ensures that inputs for the meat energy allocation calculation
#' are correctly typed and within valid ranges. Specifically:
#' * `animal` and `cohort_code` must be scalar characters.
#' * All numeric inputs must be numeric scalars (length 1, not NA).
#' * `animal` must be one of the supported species codes for allocation.
#' * `cohort_code` must be one of the valid cohort codes for allocation.
#' * Weight parameters must be within reasonable biological ranges.
#'
#' Valid animal species for allocation: `CTL`, `BFL`, `CML`, `SHP`, `GTS`, `PGS`, `CHK`.
#' Valid cohort codes for allocation: `FA`, `MA`, `FS`, `MS`, `FJ`, `MJ`.
#'
#' This validator is designed for internal use in
#' [calc_energy_allocation_meat()].
#'
#' @param animal Character scalar. Species code (e.g., "CTL", "BFL", "CML", "SHP", "GTS", "PGS", "CHK").
#' @param cohort_code Character scalar. Cohort identifier (e.g., "FA", "FS", "FJ", "MA", "MS", "MJ").
#' @param slaughter_liveweight Numeric scalar. Slaughter liveweight (kg).
#' @param birth_liveweight Numeric scalar. Birthweight (kg).
#' @param output_meat_production_liveweight Numeric. Total meat produced as live weight over the assessment period by cohort (kg/cohort/year).
#'
#' @noRd
validate_allocation_meat_inputs <- function(
    species_short,
    cohort_short,
    slaughter_weight_cohort,
    birth_weight,
    meat_production_live_weight_cohort,
    ratio_me_to_ne
) {
  validate_scalar_character(species_short, "species_short")
  validate_scalar_character(cohort_short, "cohort_short")
  validate_scalar_numeric(ratio_me_to_ne, "ratio_me_to_ne")

  # Validate animal species
  valid_animals <- c("CTL", "BFL", "CML", "SHP", "GTS", "PGS", "CHK")
  if (!species_short %in% valid_animals) {
    cli::cli_abort(
      "{.arg species_short} must be one of: {cli::format_inline('{valid_animals}')}"
    )
  }

  # Validate cohort codes
  valid_cohorts <- c("FA", "MA", "FS", "MS", "FJ", "MJ")
  if (!cohort_short %in% valid_cohorts) {
    cli::cli_abort(
      "{.arg cohort_short} must be one of: {cli::format_inline('{valid_cohorts}')}"
    )
  }

  # Range checks via parameter_ranges
  validate_param_range(slaughter_weight_cohort)
  validate_param_range(birth_weight)
  validate_param_range(meat_production_live_weight_cohort)

  if (ratio_me_to_ne <= 0) {
    cli::cli_abort("{.arg ratio_me_to_ne} must be positive (ME/NE).")
  }
}

#' Validate inputs for calc_energy_allocation_fibre
#'
#' Ensures that inputs for the fibre energy allocation calculation
#' are correctly typed and within valid ranges. Specifically:
#' * `animal` must be a scalar character.
#' * All numeric inputs must be numeric scalars (length 1, not NA).
#' * `animal` must be one of the supported species codes for allocation.
#' * `fibre_energy_requirement` must be non-negative (MJ per head per day).
#' * `ratio_ne_to_me` must be between 0 and 1 (used for camelid conversion).
#' * `assessment_duration` must be between 0 and 3650 days.
#'
#' Valid animal species for allocation: `CTL`, `BFL`, `CML`, `SHP`, `GTS`, `PGS`, `CHK`.
#' Note: Only sheep (SHP), goats (GTS), and camelids (CML) produce fibre.
#'
#' This validator is designed for internal use in
#' [calc_energy_allocation_fibre()].
#'
#' @param animal Character scalar. Species code (e.g., "GTS", "SHP", "CML").
#' @param fibre_energy_requirement Numeric scalar. Fibre energy demand (MJ per head per day).
#' @param ratio_ne_to_me Numeric scalar. Net-to-metabolizable energy conversion ratio (used for camelids).
#' @param assessment_duration Numeric scalar. Assessment duration (days).
#'
#' @noRd
validate_allocation_fibre_inputs <- function(
    species_short,
    cohort_stock_size,
    energy_requirement_fibre_production,
    ratio_me_to_ne,
    simulation_duration
) {
  validate_scalar_character(species_short, "species_short")
  validate_scalar_numeric(energy_requirement_fibre_production, "energy_requirement_fibre_production")
  validate_scalar_numeric(ratio_me_to_ne, "ratio_me_to_ne")
  validate_scalar_numeric(simulation_duration, "simulation_duration")
  validate_scalar_numeric(cohort_stock_size, "cohort_stock_size")
  validate_param_range(ratio_me_to_ne)

  valid_animals <- c("CTL", "BFL", "CML", "SHP", "GTS", "PGS", "CHK")
  if (!species_short %in% valid_animals) {
    cli::cli_abort(
      "{.arg species_short} must be one of: {cli::format_inline('{valid_animals}')}"
    )
  }

  if (energy_requirement_fibre_production < 0) {
    cli::cli_abort("{.arg energy_requirement_fibre_production} must be non-negative.")
  }
  if (ratio_me_to_ne <= 0) {
    cli::cli_abort("{.arg ratio_me_to_ne} must be positive (ME/NE).")
  }
  if (simulation_duration <= 0 || simulation_duration > 3650) {
    cli::cli_abort("{.arg simulation_duration} must be between 0 and 3650 days.")
  }
  if (cohort_stock_size < 0) {
    cli::cli_abort("{.arg cohort_stock_size} must be non-negative.")
  }
}

#' Validate inputs for calc_energy_allocation_work
#'
#' Ensures that inputs for the work energy allocation calculation
#' are correctly typed and within valid ranges. Specifically:
#' * `animal` must be a scalar character.
#' * All numeric inputs must be numeric scalars (length 1, not NA).
#' * `animal` must be one of the supported species codes for allocation.
#' * `work_energy_requirement` must be non-negative (MJ per head per day).
#' * `ratio_ne_to_me` must be between 0 and 1 (used for camelid conversion).
#' * `assessment_duration` must be between 0 and 3650 days.
#'
#' Valid animal species for allocation: `CTL`, `BFL`, `CML`, `SHP`, `GTS`, `PGS`, `CHK`.
#' Note: Camelids (CML) require the `ratio_ne_to_me` conversion factor,
#' while other species use direct calculation.
#'
#' This validator is designed for internal use in
#' [calc_energy_allocation_work()].
#'
#' @param animal Character scalar. Species code (e.g., "CML" for camelids).
#' @param work_energy_requirement Numeric scalar. Work energy demand (MJ per head per day).
#' @param ratio_ne_to_me Numeric scalar. Net-to-metabolizable energy conversion ratio (used for camelids).
#' @param assessment_duration Numeric scalar. Assessment duration (days).
#'
#' @noRd
validate_allocation_work_inputs <- function(
    species_short,
    cohort_stock_size,
    energy_requirement_work,
    ratio_me_to_ne,
    simulation_duration
) {
  validate_scalar_character(species_short, "species_short")
  validate_scalar_numeric(energy_requirement_work, "energy_requirement_work")
  validate_scalar_numeric(ratio_me_to_ne, "ratio_me_to_ne")
  validate_scalar_numeric(simulation_duration, "simulation_duration")
  validate_scalar_numeric(cohort_stock_size, "cohort_stock_size")
  validate_param_range(ratio_me_to_ne)

  valid_animals <- c("CTL", "BFL", "CML", "SHP", "GTS", "PGS", "CHK")
  if (!species_short %in% valid_animals) {
    cli::cli_abort(
      "{.arg species_short} must be one of: {cli::format_inline('{valid_animals}')}"
    )
  }

  if (energy_requirement_work < 0) {
    cli::cli_abort("{.arg energy_requirement_work} must be non-negative.")
  }
  if (ratio_me_to_ne <= 0) {
    cli::cli_abort("{.arg ratio_me_to_ne} must be positive (ME/NE).")
  }
  if (simulation_duration <= 0 || simulation_duration > 3650) {
    cli::cli_abort("{.arg simulation_duration} must be between 0 and 3650 days.")
  }
  if (cohort_stock_size < 0) {
    cli::cli_abort("{.arg cohort_stock_size} must be non-negative.")
  }
}
