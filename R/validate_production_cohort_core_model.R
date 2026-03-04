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
  validate_scalar_numeric(milk_yield_day, "milk_yield_day")
  validate_scalar_numeric(simulation_duration, "simulation_duration")
  validate_scalar_numeric(cohort_stock_size, "cohort_stock_size")
  validate_scalar_numeric(lactating_females_fraction, "lactating_females_fraction")
  validate_scalar_numeric(milk_protein_fraction, "milk_protein_fraction")
  validate_scalar_numeric(milk_fat_fraction, "milk_fat_fraction")
  validate_scalar_numeric(milk_lactose_fraction, "milk_lactose_fraction")
  validate_scalar_numeric(milk_protein_fraction_standard, "milk_protein_fraction_standard")
  validate_scalar_numeric(milk_fat_fraction_standard, "milk_fat_fraction_standard")
  validate_scalar_numeric(milk_lactose_fraction_standard, "milk_lactose_fraction_standard")

  # Basic range checks for milk composition (fractions)
  if (milk_protein_fraction < 0 || milk_protein_fraction > 1) {
    cli::cli_abort("{.arg milk_protein_fraction} must be between 0 and 1 (fraction).")
  }
  if (milk_fat_fraction < 0 || milk_fat_fraction > 1) {
    cli::cli_abort("{.arg milk_fat_fraction} must be between 0 and 1 (fraction).")
  }
  if (milk_lactose_fraction < 0 || milk_lactose_fraction > 1) {
    cli::cli_abort("{.arg milk_lactose_fraction} must be between 0 and 1 (fraction).")
  }
  if (lactating_females_fraction < 0 || lactating_females_fraction > 1) {
    cli::cli_abort("{.arg lactating_females_fraction} must be between 0 and 1 (fraction).")
  }
  if (milk_protein_fraction_standard < 0 || milk_protein_fraction_standard > 1) {
    cli::cli_abort("{.arg milk_protein_fraction_standard} must be between 0 and 1 (fraction).")
  }
  if (milk_fat_fraction_standard < 0 || milk_fat_fraction_standard > 1) {
    cli::cli_abort("{.arg milk_fat_fraction_standard} must be between 0 and 1 (fraction).")
  }
  if (milk_lactose_fraction_standard < 0 || milk_lactose_fraction_standard > 1) {
    cli::cli_abort("{.arg milk_lactose_fraction_standard} must be between 0 and 1 (fraction).")
  }

  # Non-negative checks
  if (milk_yield_day < 0) {
    cli::cli_abort("{.arg milk_yield_day} must be non-negative.")
  }
  if (simulation_duration <= 0) {
    cli::cli_abort("{.arg simulation_duration} must be positive.")
  }
  if (cohort_stock_size < 0) {
    cli::cli_abort("{.arg cohort_stock_size} must be non-negative.")
  }
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
  validate_scalar_numeric(fibre_yield_year, "fibre_yield_year")
  validate_scalar_numeric(simulation_duration, "simulation_duration")
  validate_scalar_numeric(cohort_stock_size, "cohort_stock_size")

  # Non-negative checks
  if (fibre_yield_year < 0) {
    cli::cli_abort("{.arg fibre_yield_year} must be non-negative.")
  }
  if (simulation_duration <= 0) {
    cli::cli_abort("{.arg simulation_duration} must be positive.")
  }
  if (cohort_stock_size < 0) {
    cli::cli_abort("{.arg cohort_stock_size} must be non-negative.")
  }
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
  # Scalar numeric inputs
  validate_scalar_numeric(offtake_heads_assessment, "offtake_heads_assessment")
  validate_scalar_numeric(slaughter_weight_cohort, "slaughter_weight_cohort")
  validate_scalar_numeric(carcass_dressing_fraction, "carcass_dressing_fraction")
  validate_scalar_numeric(bone_free_meat_fraction, "bone_free_meat_fraction")
  validate_scalar_numeric(meat_protein_fraction, "meat_protein_fraction")

  # Non-negative checks
  if (offtake_heads_assessment < 0) {
    cli::cli_abort("{.arg offtake_heads_assessment} must be non-negative.")
  }
  if (slaughter_weight_cohort < 0) {
    cli::cli_abort("{.arg slaughter_weight_cohort} must be non-negative.")
  }

  # Fraction checks (0-1 range)
  if (carcass_dressing_fraction < 0 || carcass_dressing_fraction > 1) {
    cli::cli_abort("{.arg carcass_dressing_fraction} must be between 0 and 1 (fraction).")
  }
  if (bone_free_meat_fraction < 0 || bone_free_meat_fraction > 1) {
    cli::cli_abort("{.arg bone_free_meat_fraction} must be between 0 and 1 (fraction).")
  }
  if (meat_protein_fraction < 0 || meat_protein_fraction > 1) {
    cli::cli_abort("{.arg meat_protein_fraction} must be between 0 and 1 (fraction).")
  }
}
