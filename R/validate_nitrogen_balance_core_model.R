#' Validate inputs for calc_nitrogen_intake
#'
#' @noRd
validate_nitrogen_intake_inputs <- function(ration_intake, ration_nitrogen) {
  if (!validation_enabled()) return(invisible(NULL))
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
    cohort_duration_days = NA_real_
) {
  if (!validation_enabled()) return(invisible(NULL))
  validate_animal_species(species_short)
  validate_cohort_code(cohort_short)

  # Range checks: only for args used by this species/cohort
  if (species_short == "PGS") {
    if (cohort_short == "FA") {
      validate_param_range(litter_size, species_filter = species_short, cohort_filter = cohort_short)
      validate_param_range(parturition_rate, species_filter = species_short, cohort_filter = cohort_short)
      validate_param_range(live_weight_at_weaning, species_filter = species_short, cohort_filter = cohort_short)
      validate_param_range(live_weight_at_birth, species_filter = species_short, cohort_filter = cohort_short)
    } else if (cohort_short == "FS") {
      validate_param_range(daily_weight_gain, species_filter = species_short, cohort_filter = cohort_short)
      validate_positive_numeric(pregnancy_duration)
      validate_param_range(cohort_duration_days, species_filter = species_short, cohort_filter = cohort_short)
      validate_param_range(litter_size, species_filter = species_short, cohort_filter = cohort_short)
      validate_param_range(live_weight_at_birth, species_filter = species_short, cohort_filter = cohort_short)
    } else {
      validate_param_range(daily_weight_gain, species_filter = species_short, cohort_filter = cohort_short)
    }
  } else if (species_short %in% gleam_species_milk_producers) {
    if (cohort_short == "FA") {
      if (!is.na(milk_protein_fraction)) validate_param_range(milk_protein_fraction, species_filter = species_short, cohort_filter = cohort_short)
      if (!is.na(milk_yield_day)) validate_param_range(milk_yield_day, species_filter = species_short, cohort_filter = cohort_short)
      if (!is.na(daily_weight_gain)) validate_param_range(daily_weight_gain, species_filter = species_short, cohort_filter = cohort_short)
      if (species_short %in% c("SHP", "GTS", "CML") && !is.na(fibre_yield_year)) {
        validate_param_range(fibre_yield_year, species_filter = species_short, cohort_filter = cohort_short)
      }
    } else if (cohort_short %in% c("FS", "MA", "MS")) {
      if (!is.na(daily_weight_gain)) validate_param_range(daily_weight_gain, species_filter = species_short, cohort_filter = cohort_short)
      if (species_short %in% c("SHP", "GTS", "CML") && !is.na(fibre_yield_year)) {
        validate_param_range(fibre_yield_year, species_filter = species_short, cohort_filter = cohort_short)
      }
    } else {
      if (!is.na(daily_weight_gain)) validate_param_range(daily_weight_gain, species_filter = species_short, cohort_filter = cohort_short)
    }
  }

  validate_parameter_relations(list(
    live_weight_at_birth = live_weight_at_birth, live_weight_at_weaning = live_weight_at_weaning,
    milk_yield_day = milk_yield_day, milk_protein_fraction = milk_protein_fraction
  ), "calc_nitrogen_retention", species_short, cohort_short)
}

#' Validate inputs for calc_nitrogen_excretion
#'
#' @noRd
validate_nitrogen_excretion_inputs <- function(species_short, nitrogen_intake, nitrogen_retention) {
  if (!validation_enabled()) return(invisible(NULL))
  validate_animal_species(species_short)
  validate_scalar_numeric(nitrogen_intake)
  validate_scalar_numeric(nitrogen_retention)

  validate_parameter_relations(list(
    nitrogen_intake = nitrogen_intake, nitrogen_retention = nitrogen_retention
  ), "calc_nitrogen_excretion", species_short)
}
