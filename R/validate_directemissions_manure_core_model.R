#' Validate inputs for calc_volatile_solids
#'
#' @noRd
validate_calc_volatile_solids <- function(
    dry_matter_intake,
    diet_digestibility_fraction,
    urinary_energy_fraction,
    diet_ash
) {
  # Enforce configured bounds
  validate_param_range(dry_matter_intake)
  validate_param_range(diet_digestibility_fraction)
  validate_param_range(urinary_energy_fraction)
  validate_param_range(diet_ash)
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

    # Range checks via shared parameter_ranges rules
    if ("manure_management_system_fraction" %in% names(mms)) {
      validate_param_range(
        mms[["manure_management_system_fraction"]],
        arg_name = "manure_management_system_fraction"
      )
    }

    if ("nitrogen_fracgas" %in% names(mms)) {
      validate_param_range(
        mms[["nitrogen_fracgas"]],
        arg_name = "nitrogen_fracgas"
      )
    }

    if ("nitrogen_fracleach" %in% names(mms)) {
      validate_param_range(
        mms[["nitrogen_fracleach"]],
        arg_name = "nitrogen_fracleach"
      )
    }

    if ("methane_conversion_factor_mcf" %in% names(mms)) {
      validate_param_range(
        mms[["methane_conversion_factor_mcf"]],
        arg_name = "methane_conversion_factor_mcf"
      )
    }

    if ("ch4_max_producing_capacity_bo" %in% names(mms)) {
      validate_param_range(
        mms[["ch4_max_producing_capacity_bo"]],
        arg_name = "ch4_max_producing_capacity_bo"
      )
    }

    if ("n2o_ef3" %in% names(mms)) {
      validate_param_range(
        mms[["n2o_ef3"]],
        arg_name = "n2o_ef3"
      )
    }

    if ("n2o_ef4" %in% names(mms)) {
      validate_param_range(
        mms[["n2o_ef4"]],
        arg_name = "n2o_ef4"
      )
    }

    if ("n2o_ef5" %in% names(mms)) {
      validate_param_range(
        mms[["n2o_ef5"]],
        arg_name = "n2o_ef5"
      )
    }
  }

  # the sum of all MMS fractions must equal 1
  total_fraction <- sum(
    vapply(mms_list, function(mms) mms[["manure_management_system_fraction"]], numeric(1))
  )
  if (abs(total_fraction - 1) > 1e-8) {
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
      arg_name = names(scalars)[i]
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
  validate_scalar_numeric(n2o_vol_manure_pasture)
  validate_scalar_numeric(n2o_leach_manure_pasture)
  validate_scalar_numeric(n2o_vol_manure_burned)
  validate_scalar_numeric(n2o_leach_manure_burned)
  validate_scalar_numeric(n2o_vol_manure_other)
  validate_scalar_numeric(n2o_leach_manure_other)
  validate_scalar_numeric(n2o_manure_pasture_direct)
  validate_scalar_numeric(n2o_manure_burned_direct)
  validate_scalar_numeric(n2o_manure_other_direct)
}
