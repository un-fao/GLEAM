#' Validate inputs for compute_milk_outputs
#'
#' @noRd
validate_milk_outputs_inputs <- function(
    milk_yield,
    assessment_duration,
    size,
    milking_fraction,
    milk_protein,
    milk_fat,
    lactose,
    standard_protein,
    standard_fat,
    standard_lactose
) {
  # Scalar numeric inputs
  validate_scalar_numeric(milk_yield, "milk_yield")
  validate_scalar_numeric(assessment_duration, "assessment_duration")
  validate_scalar_numeric(size, "size")
  validate_scalar_numeric(milking_fraction, "milking_fraction")
  validate_scalar_numeric(milk_protein, "milk_protein")
  validate_scalar_numeric(milk_fat, "milk_fat")
  validate_scalar_numeric(lactose, "lactose")
  validate_scalar_numeric(standard_protein, "standard_protein")
  validate_scalar_numeric(standard_fat, "standard_fat")
  validate_scalar_numeric(standard_lactose, "standard_lactose")

  # Basic range checks for milk composition (fractions)
  if (milk_protein < 0 || milk_protein > 1) {
    cli::cli_abort("{.arg milk_protein} must be between 0 and 1 (fraction).")
  }
  if (milk_fat < 0 || milk_fat > 1) {
    cli::cli_abort("{.arg milk_fat} must be between 0 and 1 (fraction).")
  }
  if (lactose < 0 || lactose > 1) {
    cli::cli_abort("{.arg lactose} must be between 0 and 1 (fraction).")
  }
  if (milking_fraction < 0 || milking_fraction > 1) {
    cli::cli_abort("{.arg milking_fraction} must be between 0 and 1 (fraction).")
  }
  if (standard_protein < 0 || standard_protein > 1) {
    cli::cli_abort("{.arg standard_protein} must be between 0 and 1 (fraction).")
  }
  if (standard_fat < 0 || standard_fat > 1) {
    cli::cli_abort("{.arg standard_fat} must be between 0 and 1 (fraction).")
  }
  if (standard_lactose < 0 || standard_lactose > 1) {
    cli::cli_abort("{.arg standard_lactose} must be between 0 and 1 (fraction).")
  }

  # Non-negative checks
  if (milk_yield < 0) {
    cli::cli_abort("{.arg milk_yield} must be non-negative.")
  }
  if (assessment_duration <= 0) {
    cli::cli_abort("{.arg assessment_duration} must be positive.")
  }
  if (size < 0) {
    cli::cli_abort("{.arg size} must be non-negative.")
  }
}

#' Validate inputs for compute_fibre_output
#'
#' @noRd
validate_fibre_output_inputs <- function(
    fibre_prod,
    assessment_duration,
    size
) {
  # Scalar numeric inputs
  validate_scalar_numeric(fibre_prod, "fibre_prod")
  validate_scalar_numeric(assessment_duration, "assessment_duration")
  validate_scalar_numeric(size, "size")

  # Non-negative checks
  if (fibre_prod < 0) {
    cli::cli_abort("{.arg fibre_prod} must be non-negative.")
  }
  if (assessment_duration <= 0) {
    cli::cli_abort("{.arg assessment_duration} must be positive.")
  }
  if (size < 0) {
    cli::cli_abort("{.arg size} must be non-negative.")
  }
}

#' Validate inputs for compute_meat_outputs
#'
#' @noRd
validate_meat_outputs_inputs <- function(
    offtake_number,
    slaughter_weight,
    carcass_dressing_percentage,
    bone_free_meat_fraction,
    meat_protein,
    assessment_duration
) {
  # Scalar numeric inputs
  validate_scalar_numeric(offtake_number, "offtake_number")
  validate_scalar_numeric(slaughter_weight, "slaughter_weight")
  validate_scalar_numeric(carcass_dressing_percentage, "carcass_dressing_percentage")
  validate_scalar_numeric(bone_free_meat_fraction, "bone_free_meat_fraction")
  validate_scalar_numeric(meat_protein, "meat_protein")

  # Non-negative checks
  if (offtake_number < 0) {
    cli::cli_abort("{.arg offtake_number} must be non-negative.")
  }
  if (slaughter_weight < 0) {
    cli::cli_abort("{.arg slaughter_weight} must be non-negative.")
  }

  # Fraction checks (0-1 range)
  if (carcass_dressing_percentage < 0 || carcass_dressing_percentage > 1) {
    cli::cli_abort("{.arg carcass_dressing_percentage} must be between 0 and 1 (fraction).")
  }
  if (bone_free_meat_fraction < 0 || bone_free_meat_fraction > 1) {
    cli::cli_abort("{.arg bone_free_meat_fraction} must be between 0 and 1 (fraction).")
  }
  if (meat_protein < 0 || meat_protein > 1) {
    cli::cli_abort("{.arg meat_protein} must be between 0 and 1 (fraction).")
  }
}
