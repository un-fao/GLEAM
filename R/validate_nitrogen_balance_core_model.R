#' Validate inputs for calc_nitrogen_intake
#'
#' @noRd
validate_nitrogen_intake_inputs <- function(ration_intake, ration_nitrogen) {
  validate_param_range(ration_intake, "ration_intake")
  validate_param_range(ration_nitrogen, "ration_nitrogen")
}

#' Validate inputs for calc_nitrogen_retention
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
    live_weight_at_weaning = NA_real_,
    live_weight_at_birth = NA_real_,
    pregnancy_duration = NA_real_,
    cohort_duration_days = NA_real_
) {
  validate_animal_species(species_short)
  validate_cohort_code(cohort_short)

  # Range checks: only for args used by this species/cohort
  if (species_short == "CHK") {
    # nothing to validate
  } else if (species_short == "PGS") {
    if (cohort_short == "FA") {
      validate_param_range(litter_size, "litter_size")
      validate_param_range(parturition_rate, "parturition_rate")
      validate_param_range(live_weight_at_weaning, "live_weight_at_weaning")
      validate_param_range(live_weight_at_birth, "live_weight_at_birth")
    } else if (cohort_short == "FS") {
      validate_param_range(daily_weight_gain, "daily_weight_gain")
      validate_positive_numeric(pregnancy_duration)
      validate_param_range(cohort_duration_days, "cohort_duration_days")
      validate_param_range(litter_size, "litter_size")
      validate_param_range(parturition_rate, "parturition_rate")
      validate_param_range(live_weight_at_weaning, "live_weight_at_weaning")
      validate_param_range(live_weight_at_birth, "live_weight_at_birth")
    } else {
      validate_param_range(daily_weight_gain, "daily_weight_gain")
    }
  } else if (species_short %in% gleam_species_milk_producers) {
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
  if (!is.na(live_weight_at_birth) && !is.na(live_weight_at_weaning) && live_weight_at_birth >= live_weight_at_weaning) {
    cli::cli_abort(
      "{.arg live_weight_at_birth} must be strictly less than {.arg live_weight_at_weaning}."
    )
  }
}

#' Validate inputs for calc_nitrogen_excretion
#'
#' @noRd
validate_nitrogen_excretion_inputs <- function(species_short, nitrogen_intake, nitrogen_retention) {
  validate_animal_species(species_short)
  validate_scalar_numeric(nitrogen_intake)
  validate_scalar_numeric(nitrogen_retention)

  # Excretion = intake - retention; expect nitrogen_intake >= nitrogen_retention for valid excretion
  if (species_short != "CHK" && nitrogen_intake < nitrogen_retention) {
    cli::cli_abort(
      "{.arg nitrogen_intake} must be greater than or equal to {.arg nitrogen_retention}."
    )
  }
}
