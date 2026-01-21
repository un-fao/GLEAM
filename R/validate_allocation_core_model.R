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
    milk_fpcm_output,
    standard_protein,
    standard_fat,
    standard_lactose
) {
  validate_scalar_numeric(milk_fpcm_output, "milk_fpcm_output")
  validate_scalar_numeric(standard_protein, "standard_protein")
  validate_scalar_numeric(standard_fat, "standard_fat")
  validate_scalar_numeric(standard_lactose, "standard_lactose")

  # Basic bounds: all should be non-negative
  if (milk_fpcm_output < 0) {
    cli::cli_abort("{.arg milk_fpcm_output} must be non-negative.")
  }
  if (standard_protein < 0 || standard_protein > 1) {
    cli::cli_abort("{.arg standard_protein} must be between 0 and 1 (g per 100 g milk).")
  }
  if (standard_fat < 0 || standard_fat > 1) {
    cli::cli_abort("{.arg standard_fat} must be between 0 and 1 (g per 100 g milk).")
  }
  if (standard_lactose < 0 || standard_lactose > 1) {
    cli::cli_abort("{.arg standard_lactose} must be between 0 and 1 (g per 100 g milk).")
  }
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
    animal,
    cohort_code,
    slaughter_liveweight,
    birth_liveweight,
    output_meat_production_liveweight,
    ratio_ne_to_me
) {
  validate_scalar_character(animal, "animal")
  validate_scalar_character(cohort_code, "cohort_code")
  validate_scalar_numeric(slaughter_liveweight, "slaughter_liveweight")
  validate_scalar_numeric(birth_liveweight, "birth_liveweight")
  validate_scalar_numeric(output_meat_production_liveweight, "output_meat_production_liveweight")
  validate_scalar_numeric(ratio_ne_to_me, "ratio_ne_to_me")
  

  # Validate animal species
  # Note: Allocation module uses these specific species codes
  valid_animals <- c("CTL", "BFL", "CML", "SHP", "GTS", "PGS", "CHK")
  if (!animal %in% valid_animals) {
    cli::cli_abort(
      "{.arg animal} must be one of: {cli::format_inline('{valid_animals}')}"
    )
  }

  # Validate cohort codes
  # Note: Allocation module uses a subset of cohort codes (FA, MA, FS, MS, FJ, MJ)
  valid_cohorts <- c("FA", "MA", "FS", "MS", "FJ", "MJ")
  if (!cohort_code %in% valid_cohorts) {
    cli::cli_abort(
      "{.arg cohort_code} must be one of: {cli::format_inline('{valid_cohorts}')}"
    )
  }

  # Basic bounds: weights should be non-negative and reasonable
  if (slaughter_liveweight < 0 || slaughter_liveweight > 2000) {
    cli::cli_abort("{.arg slaughter_liveweight} must be between 0 and 2000 kg.")
  }
  if (ratio_ne_to_me < 0 || ratio_ne_to_me > 1) {
    cli::cli_abort("{.arg ratio_ne_to_me} must be between 0 and 1.")
  }
  if (birth_liveweight < 0 || birth_liveweight > 200) {
    cli::cli_abort("{.arg birth_liveweight} must be between 0 and 200 kg.")
  }
  if (output_meat_production_liveweight < 0) {
    cli::cli_abort("{.arg output_meat_production_liveweight} must be non-negative.")
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
    animal,
    fibre_energy_requirement,
    ratio_ne_to_me,
    assessment_duration,
    size
) {
  validate_scalar_character(animal, "animal")
  validate_scalar_numeric(fibre_energy_requirement, "fibre_energy_requirement")
  validate_scalar_numeric(ratio_ne_to_me, "ratio_ne_to_me")
  validate_scalar_numeric(assessment_duration, "assessment_duration")
  validate_scalar_numeric(size, "size")

  # Validate animal species
  # Note: Allocation module uses these specific species codes
  valid_animals <- c("CTL", "BFL", "CML", "SHP", "GTS", "PGS", "CHK")
  if (!animal %in% valid_animals) {
    cli::cli_abort(
      "{.arg animal} must be one of: {cli::format_inline('{valid_animals}')}"
    )
  }

  # Basic bounds
  if (fibre_energy_requirement < 0) {
    cli::cli_abort("{.arg fibre_energy_requirement} must be non-negative.")
  }
  if (ratio_ne_to_me < 0 || ratio_ne_to_me > 1) {
    cli::cli_abort("{.arg ratio_ne_to_me} must be between 0 and 1.")
  }
  if (assessment_duration <= 0 || assessment_duration > 3650) {
    cli::cli_abort("{.arg assessment_duration} must be between 0 and 3650 days.")
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
    animal,
    work_energy_requirement,
    ratio_ne_to_me,
    assessment_duration,
    size
    
) {
  validate_scalar_character(animal, "animal")
  validate_scalar_numeric(work_energy_requirement, "work_energy_requirement")
  validate_scalar_numeric(ratio_ne_to_me, "ratio_ne_to_me")
  validate_scalar_numeric(assessment_duration, "assessment_duration")
  validate_scalar_numeric(size, "size")
  

  # Validate animal species
  # Note: Allocation module uses these specific species codes
  valid_animals <- c("CTL", "BFL", "CML", "SHP", "GTS", "PGS", "CHK")
  if (!animal %in% valid_animals) {
    cli::cli_abort(
      "{.arg animal} must be one of: {cli::format_inline('{valid_animals}')}"
    )
  }

  # Basic bounds
  if (work_energy_requirement < 0) {
    cli::cli_abort("{.arg work_energy_requirement} must be non-negative.")
  }
  if (ratio_ne_to_me < 0 || ratio_ne_to_me > 1) {
    cli::cli_abort("{.arg ratio_ne_to_me} must be between 0 and 1.")
  }
  if (assessment_duration <= 0 || assessment_duration > 3650) {
    cli::cli_abort("{.arg assessment_duration} must be between 0 and 3650 days.")
  }
}
