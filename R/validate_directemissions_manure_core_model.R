#' Validate inputs for calc_volatile_solids
#'
#' @noRd
validate_manure_inputs <- function(dmi, diet_dig, urinary_energy_fraction, diet_ash) 
{
  # Numeric inputs
  validate_scalar_numeric(dmi, "dmi")
  validate_scalar_numeric(diet_dig, "diet_dig")
  validate_scalar_numeric(urinary_energy_fraction, "urinary_energy_fraction")
  validate_scalar_numeric(diet_ash, "diet_ash")

  # Basic range checks
  if (any(dmi < 0)) {
    cli::cli_abort("{.arg dmi} must be non-negative.")
  }
  if (any(diet_dig < 0 | diet_dig > 1)) {
    cli::cli_abort("{.arg diet_dig} must be between 0 and 1.")
  }
  if (any(urinary_energy_fraction < 0)) {
    cli::cli_abort("{.arg urinary_energy_fraction} must be non-negative.")
  }
  if (any(diet_ash <= 0)) {
    cli::cli_abort("{.arg diet_ash} must be strictly positive.")
  }
}

#' Validate inputs for calc_methane_conversion_factor
#'
#' @noRd
validate_mcf_inputs <- function(mms_pasture, mms_burned, mms_other, ef_mcf_pasture, ef_mcf_burned, ef_mcf_other) {
  validate_scalar_numeric(mms_pasture, "mms_pasture")
  validate_scalar_numeric(mms_burned, "mms_burned")
  validate_scalar_numeric(mms_other, "mms_other")
  validate_scalar_numeric(ef_mcf_pasture, "ef_mcf_pasture")
  validate_scalar_numeric(ef_mcf_burned, "ef_mcf_burned")
  validate_scalar_numeric(ef_mcf_other, "ef_mcf_other")

  # Basic range checks (0-1 for MMS fractions, 0-100 for percentages)
  if (any(mms_pasture < 0 | mms_pasture > 1)) {
    cli::cli_abort("{.arg mms_pasture} must be between 0 and 1.")
  }
  if (any(mms_burned < 0 | mms_burned > 1)) {
    cli::cli_abort("{.arg mms_burned} must be between 0 and 1.")
  }
  if (any(mms_other < 0 | mms_other > 1)) {
    cli::cli_abort("{.arg mms_other} must be between 0 and 1.")
  }
  if (any(ef_mcf_pasture < 0 | ef_mcf_pasture > 100)) {
    cli::cli_abort("{.arg ef_mcf_pasture} must be between 0 and 100.")
  }
  if (any(ef_mcf_burned < 0 | ef_mcf_burned > 100)) {
    cli::cli_abort("{.arg ef_mcf_burned} must be between 0 and 100.")
  }
  if (any(ef_mcf_other < 0 | ef_mcf_other > 100)) {
    cli::cli_abort("{.arg ef_mcf_other} must be between 0 and 100.")
  }
}

#' Validate inputs for calc_ch4_emissions
#'
#' @noRd
validate_ch4_inputs <- function(vs, mcf_pasture, mcf_burned, mcf_other, b0_mms_all, b0_mms_pasture) {
  validate_scalar_numeric(vs, "vs")
  validate_scalar_numeric(mcf_pasture, "mcf_pasture")
  validate_scalar_numeric(mcf_burned, "mcf_burned")
  validate_scalar_numeric(mcf_other, "mcf_other")
  validate_scalar_numeric(b0_mms_all, "b0_mms_all")
  validate_scalar_numeric(b0_mms_pasture, "b0_mms_pasture")

  # Basic range checks
  if (any(vs < 0)) {
    cli::cli_abort("{.arg vs} must be non-negative.")
  }
  if (any(mcf_pasture < 0 | mcf_pasture > 1)) {
    cli::cli_abort("{.arg mcf_pasture} must be between 0 and 1.")
  }
  if (any(mcf_burned < 0 | mcf_burned > 1)) {
    cli::cli_abort("{.arg mcf_burned} must be between 0 and 1.")
  }
  if (any(mcf_other < 0 | mcf_other > 1)) {
    cli::cli_abort("{.arg mcf_other} must be between 0 and 1.")
  }
  if (any(b0_mms_all < 0)) {
    cli::cli_abort("{.arg b0_mms_all} must be non-negative.")
  }
  if (any(b0_mms_pasture < 0)) {
    cli::cli_abort("{.arg b0_mms_pasture} must be non-negative.")
  }
}

#' Validate inputs for calc_direct_n2o_emissions
#'
#' @noRd
validate_direct_n2o_inputs <- function(n_excretion, ef3_pasture, ef3_burned, ef3_other) {
  validate_scalar_numeric(n_excretion, "n_excretion")
  validate_scalar_numeric(ef3_pasture, "ef3_pasture")
  validate_scalar_numeric(ef3_burned, "ef3_burned")
  validate_scalar_numeric(ef3_other, "ef3_other")

  # Basic range checks
  if (any(n_excretion < 0)) {
    cli::cli_abort("{.arg n_excretion} must be non-negative.")
  }
  if (any(ef3_pasture < 0)) {
    cli::cli_abort("{.arg ef3_pasture} must be non-negative.")
  }
  if (any(ef3_burned < 0)) {
    cli::cli_abort("{.arg ef3_burned} must be non-negative.")
  }
  if (any(ef3_other < 0)) {
    cli::cli_abort("{.arg ef3_other} must be non-negative.")
  }
}

#' Validate inputs for calc_nitrogen_volatilization_fraction
#'
#' @noRd
validate_volatilization_fraction_inputs <- function(mms_pasture, mms_burned, mms_other, ef_fracgas_pasture, ef_fracgas_burned, ef_fracgas_other) {
  validate_scalar_numeric(mms_pasture, "mms_pasture")
  validate_scalar_numeric(mms_burned, "mms_burned")
  validate_scalar_numeric(mms_other, "mms_other")
  validate_scalar_numeric(ef_fracgas_pasture, "ef_fracgas_pasture")
  validate_scalar_numeric(ef_fracgas_burned, "ef_fracgas_burned")
  validate_scalar_numeric(ef_fracgas_other, "ef_fracgas_other")

  # Basic range checks (0-1 for fractions)
  if (any(mms_pasture < 0 | mms_pasture > 1)) {
    cli::cli_abort("{.arg mms_pasture} must be between 0 and 1.")
  }
  if (any(mms_burned < 0 | mms_burned > 1)) {
    cli::cli_abort("{.arg mms_burned} must be between 0 and 1.")
  }
  if (any(mms_other < 0 | mms_other > 1)) {
    cli::cli_abort("{.arg mms_other} must be between 0 and 1.")
  }
  if (any(ef_fracgas_pasture < 0 | ef_fracgas_pasture > 1)) {
    cli::cli_abort("{.arg ef_fracgas_pasture} must be between 0 and 1.")
  }
  if (any(ef_fracgas_burned < 0 | ef_fracgas_burned > 1)) {
    cli::cli_abort("{.arg ef_fracgas_burned} must be between 0 and 1.")
  }
  if (any(ef_fracgas_other < 0 | ef_fracgas_other > 1)) {
    cli::cli_abort("{.arg ef_fracgas_other} must be between 0 and 1.")
  }
}

#' Validate inputs for calc_nitrogen_volatilization
#'
#' @noRd
validate_nitrogen_volatilization_inputs <- function(n_excretion, fracgas_pasture, fracgas_burned, fracgas_other) {
  validate_scalar_numeric(n_excretion, "n_excretion")
  validate_scalar_numeric(fracgas_pasture, "fracgas_pasture")
  validate_scalar_numeric(fracgas_burned, "fracgas_burned")
  validate_scalar_numeric(fracgas_other, "fracgas_other")

  # Basic range checks
  if (any(n_excretion < 0)) {
    cli::cli_abort("{.arg n_excretion} must be non-negative.")
  }
  if (any(fracgas_pasture < 0 | fracgas_pasture > 1)) {
    cli::cli_abort("{.arg fracgas_pasture} must be between 0 and 1.")
  }
  if (any(fracgas_burned < 0 | fracgas_burned > 1)) {
    cli::cli_abort("{.arg fracgas_burned} must be between 0 and 1.")
  }
  if (any(fracgas_other < 0 | fracgas_other > 1)) {
    cli::cli_abort("{.arg fracgas_other} must be between 0 and 1.")
  }
}

#' Validate inputs for calc_n2o_from_volatilization
#'
#' @noRd
validate_n2o_volatilization_inputs <- function(n_vol_pasture, n_vol_burned, n_vol_other, ef4) {
  validate_scalar_numeric(n_vol_pasture, "n_vol_pasture")
  validate_scalar_numeric(n_vol_burned, "n_vol_burned")
  validate_scalar_numeric(n_vol_other, "n_vol_other")
  validate_scalar_numeric(ef4, "ef4")

  # Basic range checks
  if (any(n_vol_pasture < 0)) {
    cli::cli_abort("{.arg n_vol_pasture} must be non-negative.")
  }
  if (any(n_vol_burned < 0)) {
    cli::cli_abort("{.arg n_vol_burned} must be non-negative.")
  }
  if (any(n_vol_other < 0)) {
    cli::cli_abort("{.arg n_vol_other} must be non-negative.")
  }
  if (any(ef4 < 0)) {
    cli::cli_abort("{.arg ef4} must be non-negative.")
  }
}

#' Validate inputs for calc_nitrogen_leaching_fraction
#'
#' @noRd
validate_leaching_fraction_inputs <- function(mms_pasture, mms_burned, mms_other, ef_fracleach_pasture, ef_fracleach_burned, ef_fracleach_other) {
  validate_scalar_numeric(mms_pasture, "mms_pasture")
  validate_scalar_numeric(mms_burned, "mms_burned")
  validate_scalar_numeric(mms_other, "mms_other")
  validate_scalar_numeric(ef_fracleach_pasture, "ef_fracleach_pasture")
  validate_scalar_numeric(ef_fracleach_burned, "ef_fracleach_burned")
  validate_scalar_numeric(ef_fracleach_other, "ef_fracleach_other")

  # Basic range checks (0-1 for fractions)
  if (any(mms_pasture < 0 | mms_pasture > 1)) {
    cli::cli_abort("{.arg mms_pasture} must be between 0 and 1.")
  }
  if (any(mms_burned < 0 | mms_burned > 1)) {
    cli::cli_abort("{.arg mms_burned} must be between 0 and 1.")
  }
  if (any(mms_other < 0 | mms_other > 1)) {
    cli::cli_abort("{.arg mms_other} must be between 0 and 1.")
  }
  if (any(ef_fracleach_pasture < 0 | ef_fracleach_pasture > 1)) {
    cli::cli_abort("{.arg ef_fracleach_pasture} must be between 0 and 1.")
  }
  if (any(ef_fracleach_burned < 0 | ef_fracleach_burned > 1)) {
    cli::cli_abort("{.arg ef_fracleach_burned} must be between 0 and 1.")
  }
  if (any(ef_fracleach_other < 0 | ef_fracleach_other > 1)) {
    cli::cli_abort("{.arg ef_fracleach_other} must be between 0 and 1.")
  }
}

#' Validate inputs for calc_nitrogen_leaching
#'
#' @noRd
validate_nitrogen_leaching_inputs <- function(n_excretion, fracleach_pasture, fracleach_burned, fracleach_other) {
  validate_scalar_numeric(n_excretion, "n_excretion")
  validate_scalar_numeric(fracleach_pasture, "fracleach_pasture")
  validate_scalar_numeric(fracleach_burned, "fracleach_burned")
  validate_scalar_numeric(fracleach_other, "fracleach_other")

  # Basic range checks
  if (any(n_excretion < 0)) {
    cli::cli_abort("{.arg n_excretion} must be non-negative.")
  }
  if (any(fracleach_pasture < 0 | fracleach_pasture > 1)) {
    cli::cli_abort("{.arg fracleach_pasture} must be between 0 and 1.")
  }
  if (any(fracleach_burned < 0 | fracleach_burned > 1)) {
    cli::cli_abort("{.arg fracleach_burned} must be between 0 and 1.")
  }
  if (any(fracleach_other < 0 | fracleach_other > 1)) {
    cli::cli_abort("{.arg fracleach_other} must be between 0 and 1.")
  }
}

#' Validate inputs for calc_n2o_from_leaching
#'
#' @noRd
validate_n2o_leaching_inputs <- function(n_leach_pasture, n_leach_burned, n_leach_other, ef5) {
  validate_scalar_numeric(n_leach_pasture, "n_leach_pasture")
  validate_scalar_numeric(n_leach_burned, "n_leach_burned")
  validate_scalar_numeric(n_leach_other, "n_leach_other")
  validate_scalar_numeric(ef5, "ef5")

  # Basic range checks
  if (any(n_leach_pasture < 0)) {
    cli::cli_abort("{.arg n_leach_pasture} must be non-negative.")
  }
  if (any(n_leach_burned < 0)) {
    cli::cli_abort("{.arg n_leach_burned} must be non-negative.")
  }
  if (any(n_leach_other < 0)) {
    cli::cli_abort("{.arg n_leach_other} must be non-negative.")
  }
  if (any(ef5 < 0)) {
    cli::cli_abort("{.arg ef5} must be non-negative.")
  }
}

#' Validate inputs for calc_total_n2o_emissions
#'
#' @noRd
validate_total_n2o_inputs <- function(direct, vol, leach) {
  if (!is.list(direct)) {
    cli::cli_abort("{.arg direct} must be a list.")
  }
  if (!is.list(vol)) {
    cli::cli_abort("{.arg vol} must be a list.")
  }
  if (!is.list(leach)) {
    cli::cli_abort("{.arg leach} must be a list.")
  }

  # Check required list elements
  required_direct <- c(
    "direct_n2o_manure_pasture", "direct_n2o_manure_burned", "direct_n2o_manure_other"
  )
  required_vol <- c(
    "n2o_vol_manure_pasture", "n2o_vol_manure_burned", "n2o_vol_manure_other"
  )
  required_leach <- c(
    "n2o_leach_manure_pasture", "n2o_leach_manure_burned", "n2o_leach_manure_other"
  )

  for (elem in required_direct) {
    if (!elem %in% names(direct)) {
      cli::cli_abort("{.arg direct} must contain element '{elem}'.")
    }
    validate_scalar_numeric(direct[[elem]], paste0("direct$", elem))
  }

  for (elem in required_vol) {
    if (!elem %in% names(vol)) {
      cli::cli_abort("{.arg vol} must contain element '{elem}'.")
    }
    validate_scalar_numeric(vol[[elem]], paste0("vol$", elem))
  }

  for (elem in required_leach) {
    if (!elem %in% names(leach)) {
      cli::cli_abort("{.arg leach} must contain element '{elem}'.")
    }
    validate_scalar_numeric(leach[[elem]], paste0("leach$", elem))
  }
}


