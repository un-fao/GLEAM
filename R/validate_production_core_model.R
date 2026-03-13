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
  
  if (species_short %in% c("CTL", "BFL", "GTS", "SHP", "CML")) {
    if (cohort_short == "FA") {
    # Scalar numeric inputs (only used for FA)
    validate_scalar_numeric(simulation_duration, "simulation_duration")
    validate_scalar_numeric(cohort_stock_size, "cohort_stock_size")

    # Range checks via parameter_ranges
    validate_param_range(milk_yield_day, "milk_yield_day")
    validate_param_range(lactating_females_fraction, "lactating_females_fraction")
    validate_param_range(milk_protein_fraction, "milk_protein_fraction")
    validate_param_range(milk_fat_fraction, "milk_fat_fraction")
    validate_param_range(milk_lactose_fraction, "milk_lactose_fraction")
    validate_param_range(milk_protein_fraction_standard, "milk_protein_fraction_standard")
    validate_param_range(milk_fat_fraction_standard, "milk_fat_fraction_standard")
    validate_param_range(milk_lactose_fraction_standard, "milk_lactose_fraction_standard")
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
    validate_scalar_numeric(simulation_duration, "simulation_duration")
    validate_scalar_numeric(cohort_stock_size, "cohort_stock_size")

    # Range checks via parameter_ranges
    validate_param_range(fibre_yield_year, "fibre_yield_year")
    }
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
  validate_param_range(offtake_heads_assessment, "offtake_heads_assessment")
  validate_param_range(live_weight_cohort_at_slaughter, "live_weight_cohort_at_slaughter")
  validate_param_range(carcass_dressing_fraction, "carcass_dressing_fraction")
  validate_param_range(bone_free_meat_fraction, "bone_free_meat_fraction")
  validate_param_range(meat_protein_fraction, "meat_protein_fraction")
}
