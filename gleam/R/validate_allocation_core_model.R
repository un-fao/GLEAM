#' Validate inputs for calc_milk_allocation_energy
#'
#' Ensures that inputs for the milk energy allocation calculation
#' are correctly typed and within valid ranges. Specifically:
#' * All inputs must be numeric scalars (length 1, not NA).
#' * \code{milk_production_fpcm_cohort} must be non-negative.
#' * \code{milk_protein_fraction_standard}, \code{milk_fat_fraction_standard}, and
#'   \code{milk_lactose_fraction_standard} must be between 0 and 1
#'   (representing kg per kg milk).
#'
#' This validator is designed for internal use in
#' \code{\link{calc_milk_allocation_energy}}.
#'
#' @param milk_production_fpcm_cohort Numeric scalar. Fat- and protein-corrected
#'   milk production by cohort (kg/assessment period).
#' @param milk_protein_fraction_standard Numeric scalar. Reference protein content
#'   (kg protein per kg milk).
#' @param milk_fat_fraction_standard Numeric scalar. Reference fat content
#'   (kg fat per kg milk).
#' @param milk_lactose_fraction_standard Numeric scalar. Reference lactose content
#'   (kg lactose per kg milk).
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

#' Validate inputs for calc_meat_allocation_energy
#'
#' Ensures that inputs for the meat energy allocation calculation
#' are correctly typed and within valid ranges. Specifically:
#' * \code{species_short} and \code{cohort_short} must be scalar characters.
#' * \code{species_short} must be one of the supported species codes for allocation.
#' * \code{cohort_short} must be one of the valid cohort codes for allocation.
#' * Weight parameters must be within reasonable biological ranges.
#'
#' Valid species for allocation: \code{CTL}, \code{BFL}, \code{CML}, \code{SHP},
#' \code{GTS}, \code{PGS}. Valid cohort codes: \code{FA}, \code{MA},
#' \code{FS}, \code{MS}, \code{FJ}, \code{MJ}.
#'
#' \code{live_weight_cohort_at_slaughter} and \code{live_weight_at_birth} are only required
#' (and validated) for non-PGS species; they default to \code{NA_real_} for pigs.
#' \code{ratio_me_to_ne} is only required (and validated) for CML; defaults to
#' \code{NA_real_}.
#'
#' This validator is designed for internal use in
#' \code{\link{calc_meat_allocation_energy}}.
#'
#' @param species_short Character scalar. Species code
#'   (e.g., \code{CTL}, \code{BFL}, \code{CML}, \code{SHP}, \code{GTS}, \code{PGS}).
#' @param cohort_short Character scalar. Cohort identifier
#'   (e.g., \code{FA}, \code{FS}, \code{FJ}, \code{MA}, \code{MS}, \code{MJ}).
#' @param meat_production_live_weight_cohort Numeric. Total meat produced as live
#'   weight over the assessment period by cohort (kg/cohort/assessment period).
#' @param live_weight_cohort_at_slaughter Numeric scalar. Slaughter liveweight (kg).
#'   Required for non-PGS species; may be \code{NA} for pigs.
#' @param live_weight_at_birth Numeric scalar. Birthweight (kg).
#'   Required for non-PGS species; may be \code{NA} for pigs.
#' @param ratio_me_to_ne Numeric scalar. Ratio of metabolizable energy to net energy
#'   (ME/NE). Required only for CML; may be \code{NA} for other species.
#'
#' @noRd
validate_allocation_meat_inputs <- function(
    species_short,
    cohort_short,
    meat_production_live_weight_cohort,
    live_weight_cohort_at_slaughter = NA_real_,
    live_weight_at_birth = NA_real_,
    ratio_me_to_ne = NA_real_
) {
  validate_animal_species(species_short)
  validate_cohort_code(cohort_short)
  validate_scalar_numeric(meat_production_live_weight_cohort)

  validate_param_range(meat_production_live_weight_cohort)

  # Slaughter and birth weight only needed for non-PGS species
  if (species_short != "PGS") {
    validate_param_range(live_weight_cohort_at_slaughter)
    validate_param_range(live_weight_at_birth)
  }

  # ratio_me_to_ne only needed for CML
  if (species_short == "CML") {
    if (!is.numeric(ratio_me_to_ne) || length(ratio_me_to_ne) != 1 ||
        is.na(ratio_me_to_ne) || ratio_me_to_ne <= 0) {
      cli::cli_abort("{.arg ratio_me_to_ne} must be a positive numeric value (ME/NE).")
    }
  }
}

#' Validate inputs for calc_fibre_allocation_energy
#'
#' Ensures that inputs for the fibre energy allocation calculation
#' are correctly typed and within valid ranges. Specifically:
#' * \code{species_short} must be a scalar character.
#' * \code{species_short} must be one of the supported species codes for allocation.
#' * \code{metabolic_energy_req_fibre_production} must be non-negative
#'   (MJ per head per day).
#' * \code{ratio_me_to_ne} must be positive (used for camelid conversion).
#' * \code{simulation_duration} must be between 0 and 3650 days.
#'
#' Valid species for allocation: \code{CTL}, \code{BFL}, \code{CML}, \code{SHP},
#' \code{GTS}, \code{PGS}. Note: Only sheep (SHP), goats (GTS), and
#' camelids (CML) produce fibre.
#'
#' \code{cohort_stock_size}, \code{metabolic_energy_req_fibre_production}, and
#' \code{simulation_duration} are only required (and validated) for fibre-producing
#' species. \code{ratio_me_to_ne} is only required (and validated) for CML.
#' For non-fibre species the function returns 0; all numeric args may be
#' \code{NA_real_}.
#'
#' This validator is designed for internal use in
#' \code{\link{calc_fibre_allocation_energy}}.
#'
#' @param species_short Character scalar. Species code
#'   (e.g., \code{GTS}, \code{SHP}, \code{CML}).
#' @param cohort_stock_size Numeric. Population size in the cohort at the start
#'   of the assessment period (heads). Required for fibre species; may be
#'   \code{NA} for others.
#' @param metabolic_energy_req_fibre_production Numeric. Fibre energy demand
#'   (MJ per head per day). Required for fibre species; may be \code{NA} for others.
#' @param ratio_me_to_ne Numeric. Ratio of metabolizable energy to net energy
#'   (ME/NE). Required only for CML; may be \code{NA} for other species.
#' @param simulation_duration Numeric. Length of the assessment period (days).
#'   Required for fibre species; may be \code{NA} for others.
#'
#' @noRd
validate_allocation_fibre_inputs <- function(
    species_short,
    cohort_stock_size = NA_real_,
    metabolic_energy_req_fibre_production = NA_real_,
    ratio_me_to_ne = NA_real_,
    simulation_duration = NA_real_
) {
  validate_animal_species(species_short)

  # Non-fibre species: all numeric args are unused — no further validation
  if (!species_short %in% c("SHP", "GTS", "CML")) return()

  validate_param_range(metabolic_energy_req_fibre_production)
  validate_param_range(cohort_stock_size)
  validate_param_range(simulation_duration)

  # ratio_me_to_ne only needed for CML
  if (species_short == "CML") {
    if (!is.numeric(ratio_me_to_ne) || length(ratio_me_to_ne) != 1 ||
        is.na(ratio_me_to_ne) || ratio_me_to_ne <= 0) {
      cli::cli_abort("{.arg ratio_me_to_ne} must be a positive numeric value (ME/NE).")
    }
  }
}

#' Validate inputs for calc_work_allocation_energy
#'
#' Ensures that inputs for the work energy allocation calculation
#' are correctly typed and within valid ranges. Specifically:
#' * \code{species_short} must be a scalar character.
#' * \code{species_short} must be one of the supported species codes for allocation.
#' * \code{metabolic_energy_req_work} must be non-negative (MJ per head per day).
#' * \code{ratio_me_to_ne} must be positive (used for camelid conversion).
#' * \code{simulation_duration} must be between 0 and 3650 days.
#'
#' Valid species for allocation: \code{CTL}, \code{BFL}, \code{CML}, \code{SHP},
#' \code{GTS}, \code{PGS}. Note: Camelids (CML) require the
#' \code{ratio_me_to_ne} conversion factor; other species use direct calculation.
#'
#' \code{species_short}, \code{cohort_stock_size}, \code{metabolic_energy_req_work},
#' and \code{simulation_duration} are required for all species.
#' \code{ratio_me_to_ne} is only required (and validated) for CML; defaults to
#' \code{NA_real_}.
#'
#' This validator is designed for internal use in
#' \code{\link{calc_work_allocation_energy}}.
#'
#' @param species_short Character scalar. Species code
#'   (e.g., \code{CML} for camelids).
#' @param cohort_stock_size Numeric. Population size in the cohort at the start
#'   of the assessment period (heads).
#' @param metabolic_energy_req_work Numeric. Energy required for work/draught power
#'   (MJ per head per day).
#' @param simulation_duration Numeric. Length of the assessment period (days).
#' @param ratio_me_to_ne Numeric. Ratio of metabolizable energy to net energy
#'   (ME/NE). Required only for CML; may be \code{NA} for other species.
#'
#' @noRd
validate_allocation_work_inputs <- function(
    species_short,
    cohort_stock_size,
    metabolic_energy_req_work,
    simulation_duration,
    ratio_me_to_ne = NA_real_
) {
  validate_animal_species(species_short)

  validate_param_range(metabolic_energy_req_work)
  validate_param_range(cohort_stock_size)
  validate_param_range(simulation_duration)

  # ratio_me_to_ne only needed for CML
  if (species_short == "CML") {
    if (!is.numeric(ratio_me_to_ne) || length(ratio_me_to_ne) != 1 ||
        is.na(ratio_me_to_ne) || ratio_me_to_ne <= 0) {
      cli::cli_abort("{.arg ratio_me_to_ne} must be a positive numeric value (ME/NE).")
    }
  }
}
