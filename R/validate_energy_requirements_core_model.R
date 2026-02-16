#' Validate inputs for calc_net_energy_maintenance
#'
#' @noRd
validate_maintenance_inputs <- function(
    species_short,
    cohort_short,
    live_weight_cohort_average,
    lactating_females_fraction = NA_real_,
    offtake_rate = NA_real_,
    age_first_parturition = NA_real_
) {
  validate_animal_species(species_short)
  validate_cohort_code(cohort_short)
  validate_positive_numeric(live_weight_cohort_average, "live_weight_cohort_average")

  if (species_short %in% c("CTL", "BFL") && cohort_short == "FA") {
    validate_scalar_numeric(lactating_females_fraction, "lactating_females_fraction")
    validate_param_range(lactating_females_fraction, "lactating_females_fraction")
  }

  if (species_short %in% c("CTL", "BFL") && cohort_short %in% c("MA", "MS")) {
    validate_scalar_numeric(offtake_rate, "offtake_rate")
    validate_param_range(offtake_rate, "offtake_rate")
  }

  if (species_short == "SHP" && cohort_short == "FS") {
    validate_positive_numeric(age_first_parturition, "age_first_parturition")
    validate_param_range(age_first_parturition, "age_first_parturition")
  }

  if (species_short == "SHP" && cohort_short %in% c("MA", "MS", "MJ")) {
    validate_scalar_numeric(offtake_rate, "offtake_rate")
    validate_param_range(offtake_rate, "offtake_rate")
  }
}

#' Validate inputs for calc_net_energy_activity
#'
#' @noRd
validate_activity_inputs <- function(
    species_short,
    cohort_short,
    energy_requirement_maintenance,
    live_weight_cohort_average,
    low_activity_fraction,
    high_activity_fraction
) {
  validate_animal_species(species_short)
  validate_cohort_code(cohort_short)
  validate_positive_numeric(energy_requirement_maintenance, "energy_requirement_maintenance")
  validate_positive_numeric(live_weight_cohort_average, "live_weight_cohort_average")

  validate_param_range(low_activity_fraction, "low_activity_fraction")
  validate_param_range(high_activity_fraction, "high_activity_fraction")

  activity_sum <- low_activity_fraction + high_activity_fraction
  if (activity_sum < 0 || activity_sum > 1) {
    cli::cli_abort(
      "Sum of {.field low_activity_fraction} + {.field high_activity_fraction} must be >= 0 and <= 1."
    )
  }
}

#' Validate inputs for calc_net_energy_growth
#'
#' @noRd
validate_growth_inputs <- function(
    species_short,
    cohort_short,
    live_weight_cohort_average,
    live_weight_cohort_final,
    live_weight_cohort_initial,
    mature_weight,
    daily_weight_gain,
    offtake_rate,
    cohort_duration_days
) {
  validate_animal_species(species_short)
  validate_cohort_code(cohort_short)
  validate_positive_numeric(live_weight_cohort_average, "live_weight_cohort_average")
  validate_positive_numeric(live_weight_cohort_final, "live_weight_cohort_final")
  validate_positive_numeric(live_weight_cohort_initial, "live_weight_cohort_initial")
  validate_param_range(mature_weight, "mature_weight")
  validate_param_range(daily_weight_gain, "daily_weight_gain")
  validate_param_range(offtake_rate, "offtake_rate")
  validate_param_range(cohort_duration_days, "cohort_duration_days")

  if (live_weight_cohort_initial > live_weight_cohort_final) {
    cli::cli_abort("live_weight_cohort_final cannot be higher than live_weight_cohort_initial")
  }

  if (live_weight_cohort_initial > live_weight_cohort_average) {
    cli::cli_abort("live_weight_cohort_average cannot be lower than live_weight_cohort_initial")
  }

  if (live_weight_cohort_average > live_weight_cohort_final) {
    cli::cli_abort("live_weight_cohort_average cannot be higher than live_weight_cohort_final")
  }
}

#' Validate inputs for calc_net_energy_lactation
#'
#' @noRd
validate_lactation_inputs <- function(
    species_short,
    cohort_short,
    lactating_females_fraction,
    milk_yield_day,
    milk_fat_fraction,
    non_productive_duration,
    pregnancy_duration,
    litter_size,
    death_rate_juvenile,
    birth_weight,
    weaning_weight,
    lactation_duration,
    parturition_rate
) {
  validate_animal_species(species_short)
  validate_cohort_code(cohort_short)
  validate_param_range(lactating_females_fraction, "lactating_females_fraction")
  validate_param_range(milk_yield_day, "milk_yield_day")
  validate_param_range(milk_fat_fraction, "milk_fat_fraction")
  validate_param_range(parturition_rate, "parturition_rate")

  if (!is.na(birth_weight) && !is.na(weaning_weight) && birth_weight >= weaning_weight) {
    cli::cli_abort("{.arg birth_weight} must be strictly less than {.arg weaning_weight}.")
  }
  validate_param_range(birth_weight, "birth_weight")
  validate_param_range(weaning_weight, "weaning_weight")

  if (species_short == "PGS") {
    validate_scalar_numeric(non_productive_duration, "non_productive_duration")
    validate_scalar_numeric(pregnancy_duration, "pregnancy_duration")
    validate_param_range(litter_size, "litter_size")
    validate_fraction(death_rate_juvenile, "death_rate_juvenile")
    validate_scalar_numeric(lactation_duration, "lactation_duration")
  }

  if (species_short %in% c("SHP", "GTS")) {
    validate_param_range(litter_size, "litter_size")
  }
}

#' Validate inputs for calc_net_energy_work
#'
#' @noRd
validate_work_inputs <- function(
    species_short,
    cohort_short,
    energy_requirement_maintenance,
    draught_work_hours_female,
    draught_work_hours_male,
    draught_fraction_female,
    draught_fraction_male
) {
  validate_animal_species(species_short)
  validate_cohort_code(cohort_short)
  validate_positive_numeric(energy_requirement_maintenance, "energy_requirement_maintenance")
  validate_param_range(draught_work_hours_female, "draught_work_hours_female")
  validate_param_range(draught_work_hours_male, "draught_work_hours_male")
  validate_param_range(draught_fraction_female, "draught_fraction_female")
  validate_param_range(draught_fraction_male, "draught_fraction_male")
}

#' Validate inputs for calc_net_energy_fibre
#'
#' For fibre-producing species (SHP, GTS, CML), fibre_yield_year must be >= 0.
#' For other species (CTL, BFL, PGS, CHK), fibre_yield_year must be NA.
#'
#' @noRd
validate_fibre_inputs <- function(
    species_short,
    cohort_short,
    fibre_yield_year
) {
  validate_animal_species(species_short)
  validate_cohort_code(cohort_short)

  if (species_short %in% c("SHP", "GTS", "CML")) {
    validate_param_range(fibre_yield_year, "fibre_yield_year")
  }
}

#' Validate inputs for calc_net_energy_pregnancy
#'
#' @noRd
validate_pregnancy_inputs <- function(
    species_short,
    cohort_short,
    energy_requirement_maintenance,
    parturition_rate,
    litter_size,
    pregnancy_duration,
    non_productive_duration,
    lactation_duration,
    cohort_duration_days,
    offtake_rate
) {
  validate_animal_species(species_short)
  validate_cohort_code(cohort_short)
  validate_positive_numeric(energy_requirement_maintenance, "energy_requirement_maintenance")
  validate_param_range(parturition_rate, "parturition_rate")
  validate_param_range(cohort_duration_days, "cohort_duration_days")
  validate_param_range(offtake_rate, "offtake_rate")

  if (species_short == "PGS") {
    validate_param_range(litter_size, "litter_size")
    validate_scalar_numeric(pregnancy_duration, "pregnancy_duration")
    validate_scalar_numeric(non_productive_duration, "non_productive_duration")
    validate_scalar_numeric(lactation_duration, "lactation_duration")
  }

  if (species_short %in% c("SHP", "GTS")) {
    validate_param_range(litter_size, "litter_size")
  }
}

#' Validate inputs for calc_rem_maintenance
#'
#' @noRd
validate_rem_inputs <- function(
    species_short,
    diet_digestibility_fraction
) {
  validate_animal_species(species_short)
  validate_scalar_numeric(diet_digestibility_fraction, "diet_digestibility_fraction")
  validate_param_range(diet_digestibility_fraction, "diet_digestibility_fraction")
}

#' Validate inputs for calc_reg_growth
#'
#' @noRd
validate_reg_inputs <- function(
    species_short,
    diet_digestibility_fraction
) {
  validate_animal_species(species_short)
  validate_scalar_numeric(diet_digestibility_fraction, "diet_digestibility_fraction")
  validate_param_range(diet_digestibility_fraction, "diet_digestibility_fraction")
}

#' Validate inputs for calc_total_energy_requirement
#'
#' @noRd
validate_total_energy_inputs <- function(
    species_short,
    energy_requirement_maintenance,
    energy_requirement_activity,
    energy_requirement_lactation,
    energy_requirement_work,
    energy_requirement_pregnancy,
    net_energy_maintenance_digestible_energy_ratio,
    energy_requirement_growth,
    energy_requirement_fibre_production,
    energy_requirement_egg_deposition,
    net_energy_growth_digestible_energy_ratio,
    diet_digestibility_fraction
) {
  validate_animal_species(species_short)
  validate_scalar_numeric(energy_requirement_maintenance, "energy_requirement_maintenance")
  validate_scalar_numeric(energy_requirement_activity, "energy_requirement_activity")
  validate_scalar_numeric(energy_requirement_lactation, "energy_requirement_lactation")
  validate_scalar_numeric(energy_requirement_work, "energy_requirement_work")
  validate_scalar_numeric(energy_requirement_pregnancy, "energy_requirement_pregnancy")
  validate_scalar_numeric(energy_requirement_growth, "energy_requirement_growth")
  validate_scalar_numeric(energy_requirement_fibre_production, "energy_requirement_fibre_production")
  validate_scalar_numeric(diet_digestibility_fraction, "diet_digestibility_fraction")
  validate_param_range(diet_digestibility_fraction, "diet_digestibility_fraction")

  if (species_short %in% c("CTL", "BFL", "SHP", "GTS")) {
    validate_scalar_numeric(
      net_energy_maintenance_digestible_energy_ratio,
      "net_energy_maintenance_digestible_energy_ratio"
    )
    validate_scalar_numeric(
      net_energy_growth_digestible_energy_ratio,
      "net_energy_growth_digestible_energy_ratio"
    )
  }
}

#' Validate inputs for calc_dry_matter_intake
#'
#' @noRd
validate_dmi_inputs <- function(
    species_short,
    energy_requirement_total,
    diet_gross_energy,
    diet_metabolizable_energy
) {
  validate_animal_species(species_short)
  validate_positive_numeric(energy_requirement_total, "energy_requirement_total")
  validate_param_range(diet_gross_energy, "diet_gross_energy")
  validate_param_range(diet_metabolizable_energy, "diet_metabolizable_energy")
}
