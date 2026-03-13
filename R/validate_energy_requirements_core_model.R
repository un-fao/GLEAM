#' Validate inputs for calc_net_energy_maintenance
#'
#' Maintenance always uses live_weight_cohort_average. Optional args (lactating
#' fraction, offtake rate, age at first parturition) are only required and
#' validated when the species/cohort branch uses them.
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
  validate_positive_numeric(live_weight_cohort_average)

  if (species_short %in% c("CTL", "BFL") && cohort_short == "FA") {
    validate_param_range(lactating_females_fraction)
  }

  if (species_short %in% c("CTL", "BFL") && cohort_short %in% c("MA", "MS")) {
    validate_param_range(offtake_rate)
  }

  if (species_short == "SHP" && cohort_short == "FS") {
    validate_param_range(age_first_parturition)
  }

  if (species_short == "SHP" && cohort_short %in% c("MA", "MS", "MJ")) {
    validate_param_range(offtake_rate)
  }
}

#' Validate inputs for calc_net_energy_activity
#'
#' Activity is used for all species/cohorts that receive activity energy; both
#' fractions and their sum are validated.
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
  validate_positive_numeric(energy_requirement_maintenance)
  validate_positive_numeric(live_weight_cohort_average)

  validate_param_range(low_activity_fraction)
  validate_param_range(high_activity_fraction)

  activity_sum <- low_activity_fraction + high_activity_fraction
  if (activity_sum < 0 || activity_sum > 1) {
    cli::cli_abort(
      "Sum of {.field low_activity_fraction} + {.field high_activity_fraction} must be >= 0 and <= 1."
    )
  }
}

#' Validate inputs for calc_net_energy_growth
#'
#' Only the arguments used for the given species and cohort are required and validated.
#' Growth is zero for adult cohorts (FA, MA) in all species; other args may be NA when not used.
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

  # --- Cattle and buffalo: growth only for FS, FJ, MS, MJ ---
  if (species_short %in% c("CTL", "BFL") && cohort_short %in% c("FS", "FJ", "MS", "MJ")) {
    validate_param_range(live_weight_cohort_average)
    validate_param_range(live_weight_cohort_final)
    validate_param_range(live_weight_cohort_initial)
    validate_param_range(mature_weight)
    validate_param_range(daily_weight_gain)
    validate_param_range(cohort_duration_days)
    if (cohort_short %in% c("MS", "MJ")) {
      validate_param_range(offtake_rate)
    }
    if (live_weight_cohort_initial > live_weight_cohort_average) {
      cli::cli_abort("live_weight_cohort_average cannot be lower than live_weight_cohort_initial.")
    }
    if (live_weight_cohort_average > live_weight_cohort_final) {
      cli::cli_abort("live_weight_cohort_average cannot be higher than live_weight_cohort_final.")
    }
    return()
  }

  # --- Camels: growth only for FS, FJ, MS, MJ; only daily_weight_gain is used ---
  if (species_short == "CML" && cohort_short %in% c("FS", "FJ", "MS", "MJ")) {
    validate_param_range(daily_weight_gain)
    return()
  }

  # --- Sheep: growth for FS, FJ, MS, MJ; linear formula uses weights and duration ---
  if (species_short == "SHP" && cohort_short %in% c("FS", "FJ", "MS", "MJ")) {
    validate_param_range(live_weight_cohort_final)
    validate_param_range(live_weight_cohort_initial)
    validate_param_range(cohort_duration_days)
    if (cohort_short %in% c("MS", "MJ")) {
      validate_param_range(offtake_rate)
    }
    if (live_weight_cohort_initial > live_weight_cohort_final) {
      cli::cli_abort("live_weight_cohort_final cannot be lower than live_weight_cohort_initial.")
    }
    return()
  }

  # --- Goats: same as sheep but no offtake_rate in formula ---
  if (species_short == "GTS" && cohort_short %in% c("FS", "FJ", "MS", "MJ")) {
    validate_param_range(live_weight_cohort_final)
    validate_param_range(live_weight_cohort_initial)
    validate_param_range(cohort_duration_days)
    if (live_weight_cohort_initial > live_weight_cohort_final) {
      cli::cli_abort("live_weight_cohort_final cannot be lower than live_weight_cohort_initial.")
    }
    return()
  }

  # --- Pigs: growth only for FS, FJ, MS, MJ; only daily_weight_gain is used ---
  if (species_short == "PGS" && cohort_short %in% c("FS", "FJ", "MS", "MJ")) {
    validate_param_range(daily_weight_gain)
    return()
  }
}

#' Validate inputs for calc_net_energy_lactation
#'
#' Lactation is computed only for cohort FA. Only the arguments used for that species
#' are required and validated; others may be NA.
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

  # Lactation is only computed for adult females (FA)
  if (cohort_short != "FA") return()

  # --- Cattle, buffalo, camels: milk yield, fat, parturition, birth/weaning weights ---
  if (species_short %in% c("CTL", "BFL", "CML")) {
    validate_param_range(lactating_females_fraction)
    validate_param_range(milk_yield_day)
    validate_param_range(milk_fat_fraction)
    validate_param_range(parturition_rate)
    validate_param_range(birth_weight)
    validate_param_range(weaning_weight)
    if (birth_weight >= weaning_weight) {
      cli::cli_abort("{.arg birth_weight} must be strictly less than {.arg weaning_weight}.")
    }
    return()
  }

  # --- Sheep and goats: same as above plus litter_size ---
  if (species_short %in% c("SHP", "GTS")) {
    validate_param_range(lactating_females_fraction)
    validate_param_range(milk_yield_day)
    validate_param_range(milk_fat_fraction)
    validate_param_range(parturition_rate)
    validate_param_range(litter_size)
    validate_param_range(birth_weight)
    validate_param_range(weaning_weight)
    if (birth_weight >= weaning_weight) {
      cli::cli_abort("{.arg birth_weight} must be strictly less than {.arg weaning_weight}.")
    }
    return()
  }

  # --- Pigs: litter size, death rate, birth/weaning weights, reproductive durations ---
  if (species_short == "PGS") {
    validate_param_range(litter_size)
    validate_fraction(death_rate_juvenile)
    validate_param_range(birth_weight)
    validate_param_range(weaning_weight)
    validate_positive_numeric(lactation_duration)
    validate_positive_numeric(non_productive_duration)
    validate_positive_numeric(pregnancy_duration)
    if (birth_weight >= weaning_weight) {
      cli::cli_abort("{.arg birth_weight} must be strictly less than {.arg weaning_weight}.")
    }
    return()
  }
}

#' Validate inputs for calc_net_energy_work
#'
#' Work energy is computed only for CTL, BFL, CML and only for adult cohorts (MA, FA).
#' Other species/cohorts return 0; draught args may be NA when not used.
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

  # Work is only computed for draught species (CTL, BFL, CML) and adult cohorts (MA, FA)
  if (!species_short %in% c("CTL", "BFL", "CML") || !cohort_short %in% c("MA", "FA")) return()

  # Cattle and buffalo: use maintenance and draught hours/fractions (sex-specific)
  if (species_short %in% c("CTL", "BFL")) {
    validate_positive_numeric(energy_requirement_maintenance)
    if (cohort_short == "MA") {
      validate_param_range(draught_work_hours_male)
      validate_param_range(draught_fraction_male)
    } else {
      validate_param_range(draught_work_hours_female)
      validate_param_range(draught_fraction_female)
    }
    return()
  }

  # Camels: draught hours and fractions only (no maintenance in formula)
  if (cohort_short == "MA") {
    validate_param_range(draught_work_hours_male)
    validate_param_range(draught_fraction_male)
  } else {
    validate_param_range(draught_work_hours_female)
    validate_param_range(draught_fraction_female)
  }
}

#' Validate inputs for calc_net_energy_fibre
#'
#' Fibre is only computed for SHP, GTS, CML and only for cohorts FA, FS, MA, MS.
#' For those cases fibre_yield_year is required and must be >= 0.
#' For non-fibre species (CTL, BFL, PGS, CHK) fibre_yield_year must be NA.
#' For fibre species but juvenile cohorts (FJ, MJ) fibre is not used; NA is allowed.
#'
#' @noRd
validate_fibre_inputs <- function(
    species_short,
    cohort_short,
    fibre_yield_year
) {
  validate_animal_species(species_short)
  validate_cohort_code(cohort_short)

  # Non-fibre species: fibre_yield_year must be NA (not applicable)
  if (!species_short %in% c("SHP", "GTS", "CML")) return()

  # Fibre species but juvenile cohorts: fibre not computed; no further validation
  if (!cohort_short %in% c("FA", "FS", "MA", "MS")) return()

  # Fibre-producing cohort: require and validate fibre_yield_year
  validate_param_range(fibre_yield_year)
}

#' Validate inputs for calc_net_energy_pregnancy
#'
#' Pregnancy is computed only for female cohorts (FA, FS) and only for CTL, BFL, CML, SHP, GTS, PGS.
#' CHK is not applicable. Only the arguments used for that species and cohort are required and validated.
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

  if (species_short == "CHK") return()
  if (!cohort_short %in% c("FA", "FS")) return()

  # --- Cattle and buffalo: FA uses parturition + pregnancy duration; FS uses duration + offtake ---
  if (species_short %in% c("CTL", "BFL")) {
    validate_positive_numeric(energy_requirement_maintenance)
    validate_param_range(parturition_rate)
    validate_positive_numeric(pregnancy_duration)
    if (cohort_short == "FA") return()
    validate_param_range(cohort_duration_days)
    validate_param_range(offtake_rate)
    return()
  }

  # --- Camels: FA uses maintenance + parturition; FS uses maintenance + duration + offtake ---
  if (species_short == "CML") {
    validate_positive_numeric(energy_requirement_maintenance)
    if (cohort_short == "FA") {
      validate_param_range(parturition_rate)
      return()
    }
    validate_positive_numeric(pregnancy_duration)
    validate_param_range(cohort_duration_days)
    validate_param_range(offtake_rate)
    return()
  }

  # --- Sheep and goats: FA uses maintenance + parturition + litter + pregnancy; FS uses duration + offtake ---
  if (species_short %in% c("SHP", "GTS")) {
    validate_positive_numeric(energy_requirement_maintenance)
    if (cohort_short == "FA") {
      validate_param_range(parturition_rate)
      validate_param_range(litter_size)
      validate_positive_numeric(pregnancy_duration)
      return()
    }
    validate_positive_numeric(pregnancy_duration)
    validate_param_range(cohort_duration_days)
    validate_param_range(offtake_rate)
    return()
  }

  # --- Pigs: FA uses litter + gest/lact/idle durations; FS also uses cohort_duration and offtake ---
  if (species_short == "PGS") {
    validate_param_range(litter_size)
    validate_positive_numeric(pregnancy_duration)
    validate_positive_numeric(non_productive_duration)
    validate_positive_numeric(lactation_duration)
    if (cohort_short == "FA") return()
    validate_param_range(cohort_duration_days)
    validate_param_range(offtake_rate)
    return()
  }
}

#' Validate inputs for calc_rem_maintenance
#'
#' diet_digestibility_fraction is only used (and required) for ruminants (CTL, BFL, SHP, GTS).
#' For PGS, CHK, CML the function returns NA and the argument may be NA.
#'
#' @noRd
validate_rem_inputs <- function(
    species_short,
    diet_digestibility_fraction
) {
  validate_animal_species(species_short)
  if (!species_short %in% c("CTL", "BFL", "SHP", "GTS")) return()
  validate_param_range(diet_digestibility_fraction)
}

#' Validate inputs for calc_reg_growth
#'
#' diet_digestibility_fraction is only used (and required) for ruminants (CTL, BFL, SHP, GTS).
#' For PGS, CHK, CML the function returns NA and the argument may be NA.
#'
#' @noRd
validate_reg_inputs <- function(
    species_short,
    diet_digestibility_fraction
) {
  validate_animal_species(species_short)
  if (!species_short %in% c("CTL", "BFL", "SHP", "GTS")) return()
  validate_param_range(diet_digestibility_fraction)
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
  validate_scalar_numeric(energy_requirement_maintenance)
  validate_scalar_numeric(energy_requirement_activity)
  validate_scalar_numeric(energy_requirement_lactation)
  validate_scalar_numeric(energy_requirement_work)
  validate_scalar_numeric(energy_requirement_pregnancy)
  validate_scalar_numeric(energy_requirement_growth)
  validate_scalar_numeric(energy_requirement_fibre_production)
  validate_param_range(diet_digestibility_fraction)

  if (species_short %in% c("CTL", "BFL", "SHP", "GTS")) {
    validate_scalar_numeric(net_energy_maintenance_digestible_energy_ratio)
    validate_scalar_numeric(net_energy_growth_digestible_energy_ratio)
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
  validate_positive_numeric(energy_requirement_total)
  validate_param_range(diet_gross_energy)
  validate_param_range(diet_metabolizable_energy)
}
