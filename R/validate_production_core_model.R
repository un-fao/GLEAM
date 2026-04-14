#' Validate inputs for calc_milk_production
#'
#' Milk calculations are only used for cohort FA (adult females). Validation of
#' milk-related parameters and ranges is performed only when cohort_short == "FA".
#'
#' @noRd
validate_milk_outputs_inputs <- function(
    species_short,
    cohort_short,
    milk_yield_day,
    simulation_duration,
    cohort_stock_size,
    lactating_females_fraction,
    milk_protein_fraction,
    milk_fat_fraction,
    milk_lactose_fraction,
    milk_protein_fraction_standard,
    milk_fat_fraction_standard,
    milk_lactose_fraction_standard
) {
  validate_animal_species(species_short)
  validate_cohort_code(cohort_short)
  
  if (species_short %in% gleam_species_milk_producers) {
    if (cohort_short == "FA") {
    # Scalar numeric inputs (only used for FA)
    validate_scalar_numeric(simulation_duration)
    validate_scalar_numeric(cohort_stock_size)

    # Range checks via parameter_ranges
    validate_param_range(milk_yield_day)
    validate_param_range(lactating_females_fraction)
    validate_param_range(milk_protein_fraction)
    validate_param_range(milk_fat_fraction)
    validate_param_range(milk_lactose_fraction)
    validate_param_range(milk_protein_fraction_standard)
    validate_param_range(milk_fat_fraction_standard)
    validate_param_range(milk_lactose_fraction_standard)
    }
  }
}

#' Validate inputs for calc_fibre_production
#'
#' Fibre calculations are only used for cohorts FA, FS, MA, MS. Validation of
#' fibre-related parameters and ranges is performed only for those cohorts.
#'
#' @noRd
validate_fibre_output_inputs <- function(
    species_short,
    cohort_short,
    fibre_yield_year,
    simulation_duration,
    cohort_stock_size
) {

  validate_cohort_code(cohort_short)
  
  if (species_short %in% c("GTS", "SHP", "CML")) {
    if (cohort_short %in% c("FA", "FS", "MA", "MS")) {
    # Scalar numeric inputs (only used for fibre-producing cohorts)
    validate_scalar_numeric(simulation_duration)
    validate_scalar_numeric(cohort_stock_size)

    # Range checks via parameter_ranges
    validate_param_range(fibre_yield_year)
    }
    }
}

#' Validate inputs for calc_egg_production
#'
#' @noRd
validate_egg_output_inputs <- function(
    species_short,
    cohort_short,
    egg_output_human_consumption,
    egg_average_weight,
    simulation_duration,
    egg_protein_fraction,
    nondemo_productive_phase_id = NA_real_,
    is_egg_producing = FALSE
) {
  validate_animal_species(species_short)
  validate_cohort_code(cohort_short)
  validate_is_egg_producing_flag(
    species_short = species_short,
    cohort_short = cohort_short,
    is_egg_producing = is_egg_producing,
    nondemo_productive_phase_id = nondemo_productive_phase_id
  )

  if (!isTRUE(is_egg_producing)) return()

  validate_scalar_numeric(egg_output_human_consumption)
  validate_positive_numeric(egg_average_weight)
  validate_scalar_numeric(simulation_duration)
  validate_scalar_numeric(egg_protein_fraction)

  if (egg_output_human_consumption < 0) {
    cli::cli_abort("{.arg egg_output_human_consumption} must be greater than or equal to 0.")
  }
  if (egg_protein_fraction < 0 || egg_protein_fraction > 1) {
    cli::cli_abort("{.arg egg_protein_fraction} must be between 0 and 1.")
  }
}

#' Validate inputs for calc_meat_production
#'
#' @noRd
validate_meat_outputs_inputs <- function(
    offtake_heads_assessment,
    live_weight_cohort_at_slaughter,
    carcass_dressing_fraction,
    bone_free_meat_fraction,
    meat_protein_fraction
) {

  # Range checks via parameter_ranges
  validate_param_range(offtake_heads_assessment)
  validate_param_range(live_weight_cohort_at_slaughter)
  validate_param_range(carcass_dressing_fraction)
  validate_param_range(bone_free_meat_fraction)
  validate_param_range(meat_protein_fraction)
}
