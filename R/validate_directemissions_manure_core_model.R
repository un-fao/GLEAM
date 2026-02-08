#' Validate inputs for calc_volatile_solids
#'
#' @noRd
validate_calc_volatile_solids <- function(
    dry_matter_intake,
    diet_digestibility_fraction,
    urinary_energy_fraction,
    diet_ash
) {
  # Numeric inputs
  validate_scalar_numeric(dry_matter_intake, "dry_matter_intake")
  validate_scalar_numeric(diet_digestibility_fraction, "diet_digestibility_fraction")
  validate_scalar_numeric(urinary_energy_fraction, "urinary_energy_fraction")
  validate_scalar_numeric(diet_ash, "diet_ash")
  
  # Basic range checks
  if (any(dry_matter_intake < 0)) {
    cli::cli_abort("{.arg dry_matter_intake} must be non-negative.")
  }
  if (any(diet_digestibility_fraction < 0 | diet_digestibility_fraction > 1)) {
    cli::cli_abort("{.arg diet_digestibility_fraction} must be between 0 and 1.")
  }
  if (any(urinary_energy_fraction < 0 | urinary_energy_fraction > 1)) {
    cli::cli_abort("{.arg urinary_energy_fraction} must be between 0 and 1.")
  }
  if (any(diet_ash < 0 | diet_ash > 1)) {
    cli::cli_abort("{.arg diet_ash} must be between 0 and 1.")
  }
}

#' Validate manure variable characteristics
#'
#' @noRd
validate_mms_characteristics <- function(mms_list, required_names) {
  
  # at least one MMS provided
  if (length(mms_list) == 0) {
    cli::cli_abort("At least one manure management system must be provided.")
  }
  
  # validate each MMS unit
  for (mms in mms_list) {
    
    # must be numeric
    if (!is.numeric(mms)) {
      cli::cli_abort("Each MMS argument must be a numeric vector.")
    }
    
    # must contain exactly the expected named fields
    if (!setequal(names(mms), required_names)) {
      cli::cli_abort(
        c(
          "Each MMS must contain exactly these named values:",
          paste0("* {required_names}")
        )
      )
    }
    
    # must not contain missing values
    if (any(is.na(mms))) {
      cli::cli_abort("MMS values must not contain missing values.")
    }
    
    # fractions must be between 0 and 1
    if ("fraction" %in% names(mms) && (mms[["fraction"]] < 0 || mms[["fraction"]] > 1)) {
      cli::cli_abort("{.arg fraction} must be between 0 and 1.")
    }
    
    if ("nitrogen_fracgas" %in% names(mms) &&
        (mms[["nitrogen_fracgas"]] < 0 || mms[["nitrogen_fracgas"]] > 1)) {
      cli::cli_abort("{.arg nitrogen_fracgas} must be between 0 and 1.")
    }
    
    if ("nitrogen_fracleach" %in% names(mms) &&
        (mms[["nitrogen_fracleach"]] < 0 || mms[["nitrogen_fracleach"]] > 1)) {
      cli::cli_abort("{.arg nitrogen_fracleach} must be between 0 and 1.")
    }
    
    if ("methane_conversion_factor_mcf" %in% names(mms) &&
        (mms[["methane_conversion_factor_mcf"]] < 0 || mms[["methane_conversion_factor_mcf"]] > 100)) {
      cli::cli_abort("{.arg methane_conversion_factor_mcf} must be between 0 and 100.")
    }
    
    if ("ch4_max_producing_capacity_bo" %in% names(mms) &&
        mms[["ch4_max_producing_capacity_bo"]] < 0) {
      cli::cli_abort("{.arg ch4_max_producing_capacity_bo} must be non-negative.")
    }
    
    if ("n2o_ef3" %in% names(mms) && mms[["n2o_ef3"]] < 0) {
      cli::cli_abort("{.arg n2o_ef3} must be non-negative.")
    }
    
    if ("n2o_ef4" %in% names(mms) && mms[["n2o_ef4"]] < 0) {
      cli::cli_abort("{.arg n2o_ef4} must be non-negative.")
    }
    
    if ("n2o_ef5" %in% names(mms) && mms[["n2o_ef5"]] < 0) {
      cli::cli_abort("{.arg n2o_ef5} must be non-negative.")
    }
  }
  
  # the sum of all MMS fractions must equal 1
  total_fraction <- sum(vapply(mms_list, function(mms) mms[["fraction"]], numeric(1)))
  if (!isTRUE(all.equal(total_fraction, 1, tolerance = 1e-8))) {
    cli::cli_abort(
      "The sum of all MMS fractions must be equal to 1 (current sum: {total_fraction})."
    )
  }
}

#' Validate manure function calculations
#'
#' @noRd
validate_mms_inputs <- function(
    mms_list,
    required_names,
    ...
) {
  # validate the structure and content of the MMS list
  validate_mms_characteristics(
    mms_list,
    required_names = required_names
  )
  
  scalars <- list(...)
  
  # validate any additional scalar numeric inputs
  for (i in seq_along(scalars)) {
    validate_scalar_numeric(
      scalars[[i]],
      names(scalars)[i]
    )
  }
}

#' Validate inputs for calc_total_n2o_emissions
#'
#' @noRd
validate_calc_total_n2o_emissions <- function(
    n2o_vol_manure_pasture,
    n2o_leach_manure_pasture,
    n2o_vol_manure_burned,
    n2o_leach_manure_burned,
    n2o_vol_manure_other,
    n2o_leach_manure_other,
    n2o_manure_pasture_direct,
    n2o_manure_burned_direct,
    n2o_manure_other_direct
) {
  # Numeric inputs
  validate_scalar_numeric(n2o_vol_manure_pasture, "n2o_vol_manure_pasture")
  validate_scalar_numeric(n2o_leach_manure_pasture, "n2o_leach_manure_pasture")
  validate_scalar_numeric(n2o_vol_manure_burned, "n2o_vol_manure_burned")
  validate_scalar_numeric(n2o_leach_manure_burned, "n2o_leach_manure_burned")
  validate_scalar_numeric(n2o_vol_manure_other, "n2o_vol_manure_other")
  validate_scalar_numeric(n2o_leach_manure_other, "n2o_leach_manure_other")
  validate_scalar_numeric(n2o_manure_pasture_direct, "n2o_manure_pasture_direct")
  validate_scalar_numeric(n2o_manure_burned_direct, "n2o_manure_burned_direct")
  validate_scalar_numeric(n2o_manure_other_direct, "n2o_manure_other_direct")
}
