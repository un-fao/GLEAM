#' Validate inputs for calc_nitrogen_intake
#'
#' @noRd
validate_nitrogen_intake_inputs <- function(ration_intake, ration_nitrogen) {
  validate_param_range(ration_intake)
  validate_param_range(ration_nitrogen)
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
    cohort_duration_days = NA_real_,
    cohort_stock_size = NA_real_,
    egg_output_human_consumption = NA_real_,
    egg_average_weight = NA_real_,
    nondemo_productive_phase_id = NA_real_,
    is_egg_producing = FALSE
) {
  validate_animal_species(species_short)
  validate_cohort_code(cohort_short)
  validate_is_egg_producing_flag(
    species_short = species_short,
    cohort_short = cohort_short,
    is_egg_producing = is_egg_producing,
    nondemo_productive_phase_id = nondemo_productive_phase_id
  )

  # Range checks: only for args used by this species/cohort
  if (species_short == "PGS") {
    if (cohort_short == "FA") {
      validate_param_range(litter_size)
      validate_param_range(parturition_rate)
      validate_param_range(live_weight_at_weaning)
      validate_param_range(live_weight_at_birth)
    } else if (cohort_short == "FS") {
      validate_param_range(daily_weight_gain)
      validate_positive_numeric(pregnancy_duration)
      validate_param_range(cohort_duration_days)
      validate_param_range(litter_size)
      validate_param_range(parturition_rate)
      validate_param_range(live_weight_at_weaning)
      validate_param_range(live_weight_at_birth)
    } else {
      validate_param_range(daily_weight_gain)
    }
  } else if (species_short %in% gleam_species_milk_producers) {
    if (cohort_short == "FA") {
      if (!is.na(milk_protein_fraction)) validate_param_range(milk_protein_fraction)
      if (!is.na(milk_yield_day)) validate_param_range(milk_yield_day)
      if (!is.na(daily_weight_gain)) validate_param_range(daily_weight_gain)
      if (species_short %in% c("SHP", "GTS", "CML") && !is.na(fibre_yield_year)) {
        validate_param_range(fibre_yield_year)
      }
    } else if (cohort_short %in% c("FS", "MA", "MS")) {
      if (!is.na(daily_weight_gain)) validate_param_range(daily_weight_gain)
      if (species_short %in% c("SHP", "GTS", "CML") && !is.na(fibre_yield_year)) {
        validate_param_range(fibre_yield_year)
      }
    } else {
      if (!is.na(daily_weight_gain)) validate_param_range(daily_weight_gain)
    }
  } else if (species_short == "CHK") {
    validate_scalar_numeric(daily_weight_gain)
    if (isTRUE(is_egg_producing)) {
      validate_scalar_numeric(cohort_stock_size)
      validate_positive_numeric(egg_average_weight)
      validate_scalar_numeric(egg_output_human_consumption)
      validate_scalar_numeric(parturition_rate)
      if (cohort_stock_size < 0) {
        cli::cli_abort("{.arg cohort_stock_size} must be greater than or equal to 0.")
      }
      if (egg_output_human_consumption < 0) {
        cli::cli_abort("{.arg egg_output_human_consumption} must be greater than or equal to 0.")
      }
      if (parturition_rate < 0) {
        cli::cli_abort("{.arg parturition_rate} must be greater than or equal to 0.")
      }
    }
  }

  # Birth weight must be strictly below weaning weight when both are provided
  if (
    species_short != "CHK" &&
      !is.na(live_weight_at_birth) &&
      !is.na(live_weight_at_weaning) &&
      live_weight_at_birth >= live_weight_at_weaning
  ) {
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
  if (nitrogen_intake < nitrogen_retention) {
    cli::cli_abort(
      "{.arg nitrogen_intake} must be greater than or equal to {.arg nitrogen_retention}."
    )
  }
}
