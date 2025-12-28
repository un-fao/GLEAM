#' Validate inputs for compute_nitrogen_intake
#'
#' @noRd
validate_nitrogen_intake_inputs <- function(dmi, diet_nitrogen) {
  validate_scalar_numeric(dmi, "dmi")
  validate_scalar_numeric(diet_nitrogen, "diet_nitrogen")

  # Basic range checks for nitrogen balance parameters
  if (dmi < 0) {
    cli::cli_abort("{.arg dmi} must be non-negative.")
  }
  if (diet_nitrogen < 0 || diet_nitrogen > 0.1) {
    cli::cli_abort("{.arg diet_nitrogen} must be between 0 and 0.1.")
  }
}

#' Validate inputs for compute_nitrogen_retention
#'
#' @noRd
validate_nitrogen_retention_inputs <- function(
    animal,
    cohort,
    milk_protein = NA_real_,
    milk_yield = NA_real_,
    dwg = NA_real_,
    fibre_prod = NA_real_,
    litsize = NA_real_,
    parturition_rate = NA_real_,
    wkg = NA_real_,
    ckg = NA_real_,
    afc = NA_real_
) {
  # Character inputs
  validate_scalar_character(animal, "animal")
  validate_scalar_character(cohort, "cohort")

  # Validate animal species
  valid_animals <- c("PGS", "CML", "CTL", "BFL", "SHP", "GTS", "CHK")
  if (!animal %in% valid_animals) {
    cli::cli_abort(
      "{.arg animal} must be one of: {cli::format_inline('{valid_animals}')}"
    )
  }

  # Validate cohort
  valid_cohorts <- c("FJ", "FS", "FA", "FC", "MJ", "MS", "MA", "MC")
  if (!cohort %in% valid_cohorts) {
    cli::cli_abort(
      "{.arg cohort} must be one of: {cli::format_inline('{valid_cohorts}')}"
    )
  }

  # Validate requested variables for pigs only
  if (animal == "PGS") {
    if (is.na(dwg)) {
      cli::cli_abort("`dwg` must be supplied for pigs.")
    }
    if (is.na(litsize)) {
      cli::cli_abort("`litsize` must be supplied for pigs.")
    }
    if (is.na(parturition_rate)) {
      cli::cli_abort("`parturition_rate` must be supplied for pigs.")
    }
  }

  # Numeric inputs (allow NA)
  args <- list(
    milk_protein = milk_protein,
    milk_yield = milk_yield,
    dwg = dwg,
    fibre_prod = fibre_prod,
    litsize = litsize,
    parturition_rate = parturition_rate,
    wkg = wkg,
    ckg = ckg,
    afc = afc
  )

  for (arg_name in names(args)) {
    val <- args[[arg_name]]
    if (!is.numeric(val) || length(val) != 1) {
      cli::cli_abort("{.arg {arg_name}} must be a single numeric (scalar). NA is allowed.")
    }
  }

  # Basic range checks for non-NA values
  if (!is.na(milk_protein) && (milk_protein < 0 || milk_protein > 100)) {
    cli::cli_abort("{.arg milk_protein} must be between 0 and 100.")
  }
  if (!is.na(milk_yield) && (milk_yield < 0 || milk_yield > 100)) {
    cli::cli_abort("{.arg milk_yield} must be between 0 and 100.")
  }
  if (!is.na(dwg) && (dwg < 0 || dwg > 5)) {
    cli::cli_abort("{.arg dwg} must be between 0 and 5.")
  }
  if (!is.na(fibre_prod) && (fibre_prod < 0 || fibre_prod > 100)) {
    cli::cli_abort("{.arg fibre_prod} must be between 0 and 100.")
  }
  if (!is.na(wkg) && (wkg < 0 || wkg > 1000)) {
    cli::cli_abort("{.arg wkg} must be between 0 and 1000.")
  }
  if (!is.na(ckg) && (ckg < 0 || ckg > 100)) {
    cli::cli_abort("{.arg ckg} must be between 0 and 100.")
  }
  if (!is.na(afc) && (afc < 0.3 || afc > 9)) {
    cli::cli_abort("{.arg afc} must be between 0.3 and 9")
  }

  # Enforce configured bounds
  validate_param_range(parturition_rate)
  validate_param_range(litsize)
}

#' Validate inputs for compute_nitrogen_excretion
#'
#' @noRd
validate_nitrogen_excretion_inputs <- function(animal, n_intake, n_retention) {
  # Character input
  validate_scalar_character(animal, "animal")

  # Validate animal species
  valid_animals <- c("CTL", "BFL", "CML", "GTS", "SHP", "PGS", "CHK")
  if (!animal %in% valid_animals) {
    cli::cli_abort(
      "{.arg animal} must be one of: {cli::format_inline('{valid_animals}')}"
    )
  }

  # Numeric inputs (allow NA)
  validate_scalar_numeric(n_intake, "n_intake")
  validate_scalar_numeric(n_retention, "n_retention")

  # Basic range checks
  if (n_intake < 0 || n_intake > 10) {
    cli::cli_abort("{.arg n_intake} must be between 0 and 10.")
  }
  if (n_retention < 0 || n_retention > 10) {
    cli::cli_abort("{.arg n_retention} must be between 0 and 10.")
  }
}
