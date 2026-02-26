#' Validate inputs for compute_nitrogen_intake
#'
#' @noRd
validate_nitrogen_intake_inputs <- function(dry_matter_intake, diet_nitrogen) {
  validate_param_range(dry_matter_intake, "dry_matter_intake")
  validate_param_range(diet_nitrogen, "diet_nitrogen")
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
  valid_cohorts <- c("FJ", "FS", "FA", "MJ", "MS", "MA")
  if (!cohort_short %in% valid_cohorts) {
    cli::cli_abort(
      "{.arg cohort_short} must be one of: {cli::format_inline('{valid_cohorts}')}"
    )
  }

  # Range checks: only for args used by this species/cohort
  if (species_short == "CHK") {
    # nothing to validate
  } else if (species_short == "PGS") {
    if (cohort_short == "FA") {
      validate_param_range(litter_size, "litter_size")
      validate_param_range(parturition_rate, "parturition_rate")
      validate_param_range(weaning_weight, "weaning_weight")
      validate_param_range(birth_weight, "birth_weight")
    } else if (cohort_short == "FS") {
      validate_param_range(daily_weight_gain, "daily_weight_gain")
      validate_param_range(age_first_parturition, "age_first_parturition")
      validate_param_range(litter_size, "litter_size")
      validate_param_range(parturition_rate, "parturition_rate")
      validate_param_range(weaning_weight, "weaning_weight")
      validate_param_range(birth_weight, "birth_weight")
    } else {
      validate_param_range(daily_weight_gain, "daily_weight_gain")
    }
  } else if (species_short %in% c("CTL", "BFL", "SHP", "GTS", "CML")) {
    if (cohort_short == "FA") {
      if (!is.na(milk_protein_fraction)) validate_param_range(milk_protein_fraction, "milk_protein_fraction")
      if (!is.na(milk_yield_day)) validate_param_range(milk_yield_day, "milk_yield_day")
      if (!is.na(daily_weight_gain)) validate_param_range(daily_weight_gain, "daily_weight_gain")
      if (species_short %in% c("SHP", "GTS", "CML") && !is.na(fibre_yield_year)) {
        validate_param_range(fibre_yield_year, "fibre_yield_year")
      }
    } else if (cohort_short %in% c("FS", "MA", "MS")) {
      if (!is.na(daily_weight_gain)) validate_param_range(daily_weight_gain, "daily_weight_gain")
      if (species_short %in% c("SHP", "GTS", "CML") && !is.na(fibre_yield_year)) {
        validate_param_range(fibre_yield_year, "fibre_yield_year")
      }
    } else {
      if (!is.na(daily_weight_gain)) validate_param_range(daily_weight_gain, "daily_weight_gain")
    }
  }

  # Birth weight must be strictly below weaning weight when both are provided
  if (!is.na(birth_weight) && !is.na(weaning_weight) && birth_weight >= weaning_weight) {
    cli::cli_abort(
      "{.arg birth_weight} must be strictly less than {.arg weaning_weight}."
    )
  }
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

  # Excretion = intake - retention; expect nitrogen_intake >= nitrogen_retention for valid excretion
  if (species_short != "CHK" && nitrogen_intake < nitrogen_retention) {
    cli::cli_abort(
      "{.arg nitrogen_intake} must be greater than or equal to {.arg nitrogen_retention}."
    )
  }
}
