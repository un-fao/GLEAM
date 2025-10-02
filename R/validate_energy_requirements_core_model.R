#' Validate animal species code
#'
#' Ensures that the animal code is valid for energy requirements calculations.
#'
#' @param animal Character. The animal species code to validate.
#'
#' @noRd
validate_animal_species <- function(animal) {
  validate_scalar_character(animal, "animal")
  valid_species <- c("CTL", "BFL", "SHP", "GTS", "PGS", "CHK", "CML")
  if (!animal %in% valid_species) {
    cli::cli_abort(
      "{.arg animal} must be one of: {cli::format_inline('{valid_species}')}"
    )
  }
}

#' Validate cohort code
#'
#' Ensures that the cohort code is valid for energy requirements calculations.
#'
#' @param cohort Character. The cohort code to validate.
#'
#' @noRd
validate_cohort_code <- function(cohort) {
  validate_scalar_character(cohort, "cohort")
  valid_cohorts <- c("FA", "FS", "FJ", "MA", "MS", "MJ")
  if (!cohort %in% valid_cohorts) {
    cli::cli_abort(
      "{.arg cohort} must be one of: {cli::format_inline('{valid_cohorts}')}"
    )
  }
}



#' Validate inputs for calc_net_energy_maintenance
#'
#' @noRd
validate_maintenance_inputs <- function(
    animal,
    cohort,
    average_weight,
    milking_fraction = NA_real_,
    offtake_rate = NA_real_,
    afc = NA_real_
) {
  validate_animal_species(animal)
  validate_cohort_code(cohort)
  validate_positive_numeric(average_weight, "average_weight")

  # Validate optional parameters based on animal/cohort combinations

  if (animal %in% c("CTL", "BFL") && cohort == "FA") {
    if (!is.na(milking_fraction)) validate_scalar_numeric(milking_fraction, "milking_fraction")
  }

  if (animal %in% c("CTL", "BFL") && cohort %in% c("MA", "MS")) {
    if (!is.na(offtake_rate)) validate_scalar_numeric(offtake_rate, "offtake_rate")
  }

  if (animal == "SHP" && cohort == "FS") {
    if (!is.na(afc)) validate_positive_numeric(afc, "afc")
  }

  if (animal == "SHP" && cohort %in% c("MA", "MS", "MJ")) {
    if (!is.na(offtake_rate)) validate_scalar_numeric(offtake_rate, "offtake_rate")
  }
}

#' Validate inputs for calc_net_energy_activity
#'
#' @noRd
validate_activity_inputs <- function(
    animal,
    cohort,
    nemain,
    average_weight,
    activity_fraction ,
    high_activity_fraction
) {
  validate_animal_species(animal)
  validate_cohort_code(cohort)
  validate_positive_numeric(nemain, "nemain")
  validate_positive_numeric(average_weight, "average_weight")
  validate_scalar_numeric(activity_fraction, "activity_fraction")
  validate_scalar_numeric(high_activity_fraction, "high_activity_fraction")
  
}

#' Validate inputs for calc_net_energy_growth
#'
#' @noRd
validate_growth_inputs <- function(
    animal,
    cohort,
    average_weight,
    final_weight,
    initial_weight,
    adult_weight,
    dwg,
    offtake_rate,
    duration
) {
  validate_animal_species(animal)
  validate_cohort_code(cohort)
  validate_positive_numeric(average_weight, "average_weight")
  validate_positive_numeric(final_weight, "final_weight")
  validate_positive_numeric(initial_weight, "initial_weight")
  validate_positive_numeric(initial_weight, "adult_weight")
  validate_scalar_numeric(dwg, "dwg")
  validate_scalar_numeric(offtake_rate, "offtake_rate")
  validate_positive_numeric(duration, "duration")
}

#' Validate inputs for calc_net_energy_lactation
#'
#' @noRd
validate_lactation_inputs <- function(
    animal,
    cohort,
    milking_fraction,
    milk_yield,
    milk_fat,
    idle,
    gest,
    litsize,
    dr1,
    ckg,
    wkg,
    lact,
    parturition_rate,
    lambing_interval,
    assessment_duration
) {
  validate_animal_species(animal)
  validate_cohort_code(cohort)
  validate_scalar_numeric(milking_fraction, "milking_fraction")
  validate_scalar_numeric(milk_yield, "milk_yield")
  validate_scalar_numeric(milk_fat, "milk_fat")
  validate_positive_numeric(parturition_rate, "parturition_rate")
  validate_positive_numeric(parturition_rate, "assessment_duration")

  # Validate animal-specific parameters
  if (animal == "PGS") {
    if (!is.na(idle)) validate_scalar_numeric(idle, "idle")
    if (!is.na(gest)) validate_scalar_numeric(gest, "gest")
    if (!is.na(litsize)) validate_positive_numeric(litsize, "litsize")
    if (!is.na(dr1)) validate_scalar_numeric(dr1, "dr1")
    if (!is.na(ckg)) validate_positive_numeric(ckg, "ckg")
    if (!is.na(wkg)) validate_positive_numeric(wkg, "wkg")
    if (!is.na(lact)) validate_scalar_numeric(lact, "lact")
  }

  if (animal %in% c("SHP", "GTS")) {
    if (!is.na(litsize)) validate_positive_numeric(litsize, "litsize")
    if (!is.na(ckg)) validate_positive_numeric(ckg, "ckg")
    if (!is.na(wkg)) validate_positive_numeric(wkg, "wkg")
    if (!is.na(lambing_interval)) validate_positive_numeric(lambing_interval, "lambing_interval")
  }

  if (animal %in% c("CTL", "BFL", "CML")) {
    if (!is.na(ckg)) validate_positive_numeric(ckg, "ckg")
    if (!is.na(wkg)) validate_positive_numeric(wkg, "wkg")
  }
}

#' Validate inputs for calc_net_energy_work
#'
#' @noRd
validate_work_inputs <- function(
    animal,
    cohort,
    nemain,
    work_hours,
    draught_fraction
) {
  validate_animal_species(animal)
  validate_cohort_code(cohort)
  validate_positive_numeric(nemain, "nemain")
  validate_scalar_numeric(work_hours, "work_hours")
  validate_scalar_numeric(draught_fraction, "draught_fraction")

  if (work_hours < 0 || work_hours > 24) {
    cli::cli_abort("{.arg work_hours} must be between 0 and 24.")
  }
}

#' Validate inputs for calc_net_energy_fibre
#'
#' @noRd
validate_fibre_inputs <- function(
    animal,
    cohort,
    fibre_prod
) {
  validate_animal_species(animal)
  validate_cohort_code(cohort)
  validate_scalar_numeric(fibre_prod, "fibre_prod")

  if (fibre_prod < 0) {
    cli::cli_abort("{.arg fibre_prod} must be non-negative.")
  }
}

#' Validate inputs for calc_net_energy_pregnancy
#'
#' @noRd
validate_pregnancy_inputs <- function(
    animal,
    cohort,
    nemain,
    parturition_rate,
    litsize,
    gest,
    duration,
    offtake_rate
) {
  validate_animal_species(animal)
  validate_cohort_code(cohort)
  validate_positive_numeric(nemain, "nemain")
  validate_positive_numeric(parturition_rate, "parturition_rate")
  validate_positive_numeric(duration, "duration")
  validate_scalar_numeric(offtake_rate, "offtake_rate")

  # Validate animal-specific parameters
  if (animal == "PGS") {
    if (!is.na(litsize)) validate_positive_numeric(litsize, "litsize")
    if (!is.na(gest)) validate_scalar_numeric(gest, "gest")
  }

  if (animal %in% c("SHP", "GTS")) {
    if (!is.na(litsize)) validate_positive_numeric(litsize, "litsize")
  }
}

#' Validate inputs for calc_rem_maintenance
#'
#' @noRd
validate_rem_inputs <- function(
    animal,
    diet_dig
) {
  validate_animal_species(animal)
  validate_scalar_numeric(diet_dig, "diet_dig")
}

#' Validate inputs for calc_reg_growth
#'
#' @noRd
validate_reg_inputs <- function(
    animal,
    diet_dig
) {
  validate_animal_species(animal)
  validate_scalar_numeric(diet_dig, "diet_dig")
}

#' Validate inputs for calc_total_energy_requirement
#'
#' @noRd
validate_total_energy_inputs <- function(
    animal,
    cohort,
    nemain,
    neact,
    nelact,
    nework,
    nepreg,
    rem,
    negrow,
    nefibre,
    neegg,
    reg,
    diet_dig,
    afc
) {
  validate_animal_species(animal)
  validate_cohort_code(cohort)
  validate_scalar_numeric(nemain, "nemain")
  validate_scalar_numeric(neact, "neact")
  validate_scalar_numeric(nelact, "nelact")
  validate_scalar_numeric(nework, "nework")
  validate_scalar_numeric(nepreg, "nepreg")
  validate_scalar_numeric(negrow, "negrow")
  validate_scalar_numeric(nefibre, "nefibre")
  #validate_scalar_numeric(neegg, "neegg")
  validate_scalar_numeric(diet_dig, "diet_dig")

  # Validate REM and REG based on animal type
  if (animal %in% c("CTL", "BFL", "SHP", "GTS")) {
    if (is.na(rem)) {
      cli::cli_abort("{.arg rem} must be provided for ruminants ({animal}).")
    }
    if (is.na(reg)) {
      cli::cli_abort("{.arg reg} must be provided for ruminants ({animal}).")
    }
    validate_scalar_numeric(rem, "rem")
    validate_scalar_numeric(reg, "reg")
  }

  # Validate afc for sheep and goats
  if (animal %in% c("SHP", "GTS")) {
    if (!is.na(afc)) validate_positive_numeric(afc, "afc")
  }
}

#' Validate inputs for calc_dry_matter_intake
#'
#' @noRd
validate_dmi_inputs <- function(
    animal,
    total_energy,
    diet_ge,
    diet_me
) {
  validate_animal_species(animal)
  validate_positive_numeric(total_energy, "total_energy")
  validate_positive_numeric(diet_ge, "diet_ge")
  validate_positive_numeric(diet_me, "diet_me")
}
