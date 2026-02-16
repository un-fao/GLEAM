#' Validate species short code
#'
#' Ensures that the species short code is valid for energy requirements calculations.
#'
#' @param species_short Character. The species short code to validate.
#'
#' @noRd
validate_animal_species <- function(species_short) {
  validate_scalar_character(species_short, "species_short")
  valid_species <- c("CTL", "BFL", "SHP", "GTS", "PGS", "CHK", "CML")
  if (!species_short %in% valid_species) {
    cli::cli_abort(
      "{.arg species_short} must be one of: {cli::format_inline('{valid_species}')}"
    )
  }
}

#' Validate cohort short code
#'
#' Ensures that the cohort short code is valid for energy requirements calculations.
#'
#' @param cohort_short Character. The cohort short code to validate.
#'
#' @noRd
validate_cohort_code <- function(cohort_short) {
  validate_scalar_character(cohort_short, "cohort_short")
  valid_cohorts <- c("FA", "FS", "FJ", "MA", "MS", "MJ")
  if (!cohort_short %in% valid_cohorts) {
    cli::cli_abort(
      "{.arg cohort_short} must be one of: {cli::format_inline('{valid_cohorts}')}"
    )
  }
}

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
    if (!is.na(lactating_females_fraction)) validate_scalar_numeric(lactating_females_fraction, "lactating_females_fraction")
  }

  if (species_short %in% c("CTL", "BFL") && cohort_short %in% c("MA", "MS")) {
    if (!is.na(offtake_rate)) validate_scalar_numeric(offtake_rate, "offtake_rate")
  }

  if (species_short == "SHP" && cohort_short == "FS") {
    if (!is.na(age_first_parturition)) validate_positive_numeric(age_first_parturition, "age_first_parturition")
  }

  if (species_short == "SHP" && cohort_short %in% c("MA", "MS", "MJ")) {
    if (!is.na(offtake_rate)) validate_scalar_numeric(offtake_rate, "offtake_rate")
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
  validate_scalar_numeric(low_activity_fraction, "low_activity_fraction")
  validate_scalar_numeric(high_activity_fraction, "high_activity_fraction")

  validate_fraction(low_activity_fraction, "low_activity_fraction")
  validate_fraction(high_activity_fraction, "high_activity_fraction")

  if ((low_activity_fraction + high_activity_fraction) > 1) {
    cli::cli_abort(
      "Sum of {.field low_activity_fraction} + {.field high_activity_fraction} must be between 0 and 1."
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
  validate_positive_numeric(mature_weight, "mature_weight")
  validate_scalar_numeric(daily_weight_gain, "daily_weight_gain")
  validate_scalar_numeric(offtake_rate, "offtake_rate")
  validate_positive_numeric(cohort_duration_days, "cohort_duration_days")

  if (live_weight_cohort_initial > live_weight_cohort_final) {
    cli::cli_abort("live_weight_cohort_final cannot be higher than live_weight_cohort_initial")
  }

  if (live_weight_cohort_initial > live_weight_cohort_average) {
    cli::cli_abort("live_weight_cohort_average cannot be lower than live_weight_cohort_initial")
  }

  if (live_weight_cohort_average > live_weight_cohort_final) {
    cli::cli_abort("live_weight_cohort_average cannot be higher than live_weight_cohort_final")
  }

  if (cohort_duration_days < 10) {
    cli::cli_warn(
      "{.field cohort_duration_days} is less than 10 days. Results might not be reliable."
    )
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
  validate_scalar_numeric(lactating_females_fraction, "lactating_females_fraction")
  validate_scalar_numeric(milk_yield_day, "milk_yield_day")
  validate_scalar_numeric(milk_fat_fraction, "milk_fat_fraction")
  validate_positive_numeric(parturition_rate, "parturition_rate")
  validate_fraction(lactating_females_fraction, "lactating_females_fraction")
  validate_fraction(milk_fat_fraction, "milk_fat_fraction")

  if (!is.na(birth_weight) && !is.na(weaning_weight) && birth_weight > weaning_weight) {
    cli::cli_abort("birth_weight cannot be higher than weaning_weight")
  }

  if (species_short == "PGS") {
    if (!is.na(non_productive_duration)) validate_scalar_numeric(non_productive_duration, "non_productive_duration")
    if (!is.na(pregnancy_duration)) validate_scalar_numeric(pregnancy_duration, "pregnancy_duration")
    if (!is.na(litter_size)) validate_positive_numeric(litter_size, "litter_size")
    if (!is.na(death_rate_juvenile)) validate_fraction(death_rate_juvenile, "death_rate_juvenile")
    if (!is.na(birth_weight)) validate_positive_numeric(birth_weight, "birth_weight")
    if (!is.na(weaning_weight)) validate_positive_numeric(weaning_weight, "weaning_weight")
    if (!is.na(lactation_duration)) validate_scalar_numeric(lactation_duration, "lactation_duration")
  }

  if (species_short %in% c("SHP", "GTS")) {
    if (!is.na(litter_size)) validate_positive_numeric(litter_size, "litter_size")
    if (!is.na(birth_weight)) validate_positive_numeric(birth_weight, "birth_weight")
    if (!is.na(weaning_weight)) validate_positive_numeric(weaning_weight, "weaning_weight")
  }

  if (species_short %in% c("CTL", "BFL", "CML")) {
    if (!is.na(birth_weight)) validate_positive_numeric(birth_weight, "birth_weight")
    if (!is.na(weaning_weight)) validate_positive_numeric(weaning_weight, "weaning_weight")
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
  validate_scalar_numeric(draught_work_hours_female, "draught_work_hours_female")
  validate_scalar_numeric(draught_work_hours_male, "draught_work_hours_male")
  validate_scalar_numeric(draught_fraction_female, "draught_fraction_female")
  validate_fraction(draught_fraction_female, "draught_fraction_female")
  validate_scalar_numeric(draught_fraction_male, "draught_fraction_male")
  validate_fraction(draught_fraction_male, "draught_fraction_male")

  if (draught_work_hours_female < 0 || draught_work_hours_female > 24) {
    cli::cli_abort("{.arg draught_work_hours_female} must be between 0 and 24.")
  }
  if (draught_work_hours_male < 0 || draught_work_hours_male > 24) {
    cli::cli_abort("{.arg draught_work_hours_male} must be between 0 and 24.")
  }
}

#' Validate inputs for calc_net_energy_fibre
#'
#' @noRd
validate_fibre_inputs <- function(
    species_short,
    cohort_short,
    fibre_yield_year
) {
  validate_animal_species(species_short)
  validate_cohort_code(cohort_short)
  validate_scalar_numeric(fibre_yield_year, "fibre_yield_year")

  if (fibre_yield_year < 0) {
    cli::cli_abort("{.arg fibre_yield_year} must be non-negative.")
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
  validate_positive_numeric(parturition_rate, "parturition_rate")
  validate_positive_numeric(cohort_duration_days, "cohort_duration_days")
  validate_scalar_numeric(offtake_rate, "offtake_rate")

  if (cohort_duration_days < 10) {
    cli::cli_warn(
      "{.field cohort_duration_days} is less than 10 days. This may indicate an unrealistic input."
    )
  }

  if (species_short == "PGS") {
    if (!is.na(litter_size)) validate_positive_numeric(litter_size, "litter_size")
    if (!is.na(pregnancy_duration)) validate_scalar_numeric(pregnancy_duration, "pregnancy_duration")
    if (!is.na(non_productive_duration)) validate_scalar_numeric(non_productive_duration, "non_productive_duration")
    if (!is.na(lactation_duration)) validate_scalar_numeric(lactation_duration, "lactation_duration")
  }

  if (species_short %in% c("SHP", "GTS")) {
    if (!is.na(litter_size)) validate_positive_numeric(litter_size, "litter_size")
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
  validate_fraction(diet_digestibility_fraction, "diet_digestibility_fraction")

  if (diet_digestibility_fraction < 0.5) {
    cli::cli_warn(
      "{.field diet_digestibility_fraction} is below 0.5. This may indicate an unrealistic input."
    )
  }
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
  validate_fraction(diet_digestibility_fraction, "diet_digestibility_fraction")
  if (diet_digestibility_fraction < 0.5) {
    cli::cli_warn(
      "{.field diet_digestibility_fraction} is below 0.5. The results might not be reliable."
    )
  }
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
  validate_fraction(diet_digestibility_fraction, "diet_digestibility_fraction")

  if (diet_digestibility_fraction < 0.5) {
    cli::cli_warn(
      "{.field diet_digestibility_fraction} is below 0.5. The results might not be reliable."
    )
  }

  if (species_short %in% c("CTL", "BFL", "SHP", "GTS")) {
    if (is.na(net_energy_maintenance_digestible_energy_ratio)) {
      cli::cli_abort("{.arg net_energy_maintenance_digestible_energy_ratio} must be provided for ruminants ({species_short}).")
    }
    if (is.na(net_energy_growth_digestible_energy_ratio)) {
      cli::cli_abort("{.arg net_energy_growth_digestible_energy_ratio} must be provided for ruminants ({species_short}).")
    }
    validate_scalar_numeric(net_energy_maintenance_digestible_energy_ratio, "net_energy_maintenance_digestible_energy_ratio")
    validate_scalar_numeric(net_energy_growth_digestible_energy_ratio, "net_energy_growth_digestible_energy_ratio")
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
  validate_positive_numeric(diet_gross_energy, "diet_gross_energy")
  validate_positive_numeric(diet_metabolizable_energy, "diet_metabolizable_energy")

  if (diet_metabolizable_energy < 4) {
    cli::cli_warn(
      "{.field diet_metabolizable_energy} is below 4 MJ/kg DM. This is a low value and may indicate an unrealistic input."
    )
  }

  if (diet_gross_energy < 10) {
    cli::cli_warn(
      "{.field diet_gross_energy} is below 10 MJ/kg DM. This is a low value and may indicate an unrealistic input."
    )
  }
}
