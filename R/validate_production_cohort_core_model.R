#' Validate inputs for compute_milk_outputs
#'
#' @noRd
validate_milk_outputs_inputs <- function(
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

  validate_cohort_code(cohort_short)

  # Scalar numeric inputs
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

#' Validate inputs for compute_fibre_output
#'
#' @noRd
validate_fibre_output_inputs <- function(
    cohort_short,
    fibre_yield_year,
    simulation_duration,
    cohort_stock_size
) {

  validate_cohort_code(cohort_short)

  # Scalar numeric inputs
  validate_scalar_numeric(simulation_duration, "simulation_duration")
  validate_scalar_numeric(cohort_stock_size, "cohort_stock_size")

  # Range checks via parameter_ranges
  validate_param_range(fibre_yield_year, "fibre_yield_year")
}

#' Validate inputs for compute_meat_outputs
#'
#' @noRd
validate_meat_outputs_inputs <- function(
    offtake_heads_assessment,
    slaughter_weight_cohort,
    carcass_dressing_fraction,
    bone_free_meat_fraction,
    meat_protein_fraction
) {

  # Range checks via parameter_ranges
  validate_param_range(offtake_heads_assessment, "offtake_heads_assessment")
  validate_param_range(slaughter_weight_cohort, "slaughter_weight_cohort")
  validate_param_range(carcass_dressing_fraction, "carcass_dressing_fraction")
  validate_param_range(bone_free_meat_fraction, "bone_free_meat_fraction")
  validate_param_range(meat_protein_fraction, "meat_protein_fraction")
}
