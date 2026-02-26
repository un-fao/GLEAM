#' Validate inputs for compute_nitrogen_intake
#'
#' @noRd
validate_nitrogen_intake_inputs <- function(dry_matter_intake, diet_nitrogen) {
  validate_scalar_numeric(dry_matter_intake, "dry_matter_intake")
  validate_scalar_numeric(diet_nitrogen, "diet_nitrogen")

  # Basic range checks for nitrogen balance parameters
  if (dry_matter_intake < 0) {
    cli::cli_abort("{.arg dry_matter_intake} must be non-negative.")
  }
  if (diet_nitrogen < 0 || diet_nitrogen > 0.1) {
    cli::cli_abort("{.arg diet_nitrogen} must be between 0 and 0.1.")
  }
}

#' Validate inputs for compute_nitrogen_retention
#'
#' @noRd
validate_nitrogen_retention_inputs <- function(
    species_short,
    cohort_short,
    milk_protein_fraction = NA_real_,
    milk_yield_day = NA_real_,
    daily_weight_gain = NA_real_,
    fibre_yield_year = NA_real_,
    litter_size = NA_real_,
    parturition_rate = NA_real_,
    weaning_weight = NA_real_,
    birth_weight = NA_real_,
    age_first_parturition = NA_real_
) {
  # Character inputs
  validate_scalar_character(species_short, "species_short")
  validate_scalar_character(cohort_short, "cohort_short")

  # Validate animal species
  valid_species <- c("PGS", "CML", "CTL", "BFL", "SHP", "GTS", "CHK")
  if (!species_short %in% valid_species) {
    cli::cli_abort(
      "{.arg species_short} must be one of: {cli::format_inline('{valid_species}')}"
    )
  }

  # Validate cohort
  valid_cohorts <- c("FJ", "FS", "FA", "FC", "MJ", "MS", "MA", "MC")
  if (!cohort_short %in% valid_cohorts) {
    cli::cli_abort(
      "{.arg cohort_short} must be one of: {cli::format_inline('{valid_cohorts}')}"
    )
  }

  # Validate requested variables for pigs only
  if (species_short == "PGS") {
    if (is.na(daily_weight_gain)) {
      cli::cli_abort("`daily_weight_gain` must be supplied for pigs.")
    }
    if (is.na(litter_size)) {
      cli::cli_abort("`litter_size` must be supplied for pigs.")
    }
    if (is.na(parturition_rate)) {
      cli::cli_abort("`parturition_rate` must be supplied for pigs.")
    }
  }

  # Numeric inputs (allow NA)
  args <- list(
    milk_protein_fraction = milk_protein_fraction,
    milk_yield_day = milk_yield_day,
    daily_weight_gain = daily_weight_gain,
    fibre_yield_year = fibre_yield_year,
    litter_size = litter_size,
    parturition_rate = parturition_rate,
    weaning_weight = weaning_weight,
    birth_weight = birth_weight,
    age_first_parturition = age_first_parturition
  )

  for (arg_name in names(args)) {
    val <- args[[arg_name]]
    if (!is.numeric(val) || length(val) != 1) {
      cli::cli_abort("{.arg {arg_name}} must be a single numeric (scalar). NA is allowed.")
    }
  }

  # Basic range checks for non-NA values
  if (!is.na(milk_protein_fraction) && (milk_protein_fraction < 0 || milk_protein_fraction > 100)) {
    cli::cli_abort("{.arg milk_protein_fraction} must be between 0 and 100.")
  }
  if (!is.na(milk_yield_day) && (milk_yield_day < 0 || milk_yield_day > 100)) {
    cli::cli_abort("{.arg milk_yield_day} must be between 0 and 100.")
  }
  if (!is.na(daily_weight_gain) && (daily_weight_gain < 0 || daily_weight_gain > 5)) {
    cli::cli_abort("{.arg daily_weight_gain} must be between 0 and 5.")
  }
  if (!is.na(fibre_yield_year) && (fibre_yield_year < 0 || fibre_yield_year > 100)) {
    cli::cli_abort("{.arg fibre_yield_year} must be between 0 and 100.")
  }
  if (!is.na(weaning_weight) && (weaning_weight < 0 || weaning_weight > 1000)) {
    cli::cli_abort("{.arg weaning_weight} must be between 0 and 1000.")
  }
  if (!is.na(birth_weight) && (birth_weight < 0 || birth_weight > 100)) {
    cli::cli_abort("{.arg birth_weight} must be between 0 and 100.")
  }
  if (!is.na(age_first_parturition) && (age_first_parturition < 110 || age_first_parturition > 3300)) {
    cli::cli_abort("{.arg age_first_parturition} must be between 110 and 3300.")
  }

  # Enforce configured bounds
  validate_param_range(parturition_rate)
  validate_param_range(litter_size)
}

#' Validate inputs for compute_nitrogen_excretion
#'
#' @noRd
validate_nitrogen_excretion_inputs <- function(species_short, nitrogen_intake, nitrogen_retention) {
  # Character input
  validate_scalar_character(species_short, "species_short")

  # Validate animal species
  valid_species <- c("CTL", "BFL", "CML", "GTS", "SHP", "PGS", "CHK")
  if (!species_short %in% valid_species) {
    cli::cli_abort(
      "{.arg species_short} must be one of: {cli::format_inline('{valid_species}')}"
    )
  }

  validate_scalar_numeric(nitrogen_intake, "nitrogen_intake")
  validate_scalar_numeric(nitrogen_retention, "nitrogen_retention")
}
