#' Run Energy Requirements and Dry Matter Intake Calculation (Internal)
#'
#' Computes energy requirements and dry matter intake (DMI) for each row of input data
#' using the GLEAM core model functions. This function is intended for internal workflows
#' and does not perform any file I/O.
#'
#' It adds columns for net energy for maintenance (nemain), activity (neact), growth (negrow),
#' lactation (nelact), work (nework), fibre production (nefibre), pregnancy (nepreg), diet net energy
#' fractions (rem, reg), total metabolizable energy requirement (getot) and dry matter intake (dmi).
#'
#' @param data A `data.table` or `data.frame` containing all required columns for energy requirements
#'   (see core model functions documentation for required fields).
#'
#' @return The input data with new columns: nemain, neact, negrow, nelact, nework,
#' nefibre, nepreg, rem, reg, getot, dmi.
#'
#' @examples
#' \dontrun{
#' # Load example input from the package and run the function
#' input_path <- system.file("extdata/GLEAM_input_energyrequirements.csv", package = "gleam")
#' data <- data.table::fread(input_path)
#' energy_results <- run_energy_requirements(data)
#' }
#'
#' @keywords internal
run_energy_requirements <- function(data) {
  # Internal checks: ensure essential structure
  if (!inherits(data, "data.frame") || nrow(data) == 0) {
    cli::cli_abort("Input must be a non-empty data.frame or data.table.")
  }

  required <- c(
    "Animal_short","cohort","afc","average_weight","milking_fraction",
    "offtake_rate","idle","gest","lact","litsize","ckg",
    "work_hours","draught_fraction","fibre_prod",
    "parturition_rate","duration",
    "diet_dig","diet_ge","diet_me",
    "slaughter_weight","initial_weight",  "activity_fraction","high_activity_fraction",
    "final_weight","dwg",
    "milk_yield","milk_fat","dr1","wkg","lambing_interval"
  )
  miss <- setdiff(required, names(data))
  if (length(miss)) {
    cli::cli_abort("Missing required columns: {paste(miss, collapse = ', ')}")
  }


  # 1. Maintenance energy (MJ/day)
  data[, nemain := calc_net_energy_maintenance(
    animal = Animal_short,
    cohort = cohort,
    average_weight = average_weight,
    milking_fraction = milking_fraction,
    offtake_rate = offtake_rate,
    afc = afc
  ), by = .I]

  # 2. Activity energy (MJ/day)
  data[, neact := calc_net_energy_activity(
    animal = Animal_short,
    cohort = cohort,
    nemain = nemain,
    average_weight = average_weight,
    activity_fraction = activity_fraction,
    high_activity_fraction = high_activity_fraction
  ), by = .I]

  # 3. Growth energy (MJ/day)
  data[, negrow := calc_net_energy_growth(
    animal = Animal_short,
    cohort = cohort,
    average_weight = average_weight,
    final_weight = final_weight,
    initial_weight = initial_weight,
    adult_weight = adult_weight,
    dwg = dwg,
    offtake_rate = offtake_rate,
    duration = duration
  ), by = .I]

  # 4. Lactation energy (MJ/day)
  data[, nelact := calc_net_energy_lactation(
    animal = Animal_short,
    cohort = cohort,
    milking_fraction = milking_fraction,
    milk_yield = milk_yield,
    milk_fat = milk_fat,
    idle = idle,
    gest = gest,
    litsize = litsize,
    dr1 = dr1,
    ckg = ckg,
    wkg = wkg,
    lact = lact,
    parturition_rate = parturition_rate,
    lambing_interval = lambing_interval,
    assessment_duration = 365
  ), by = .I]

  # 5. Work energy (MJ/day)
  data[, nework := calc_net_energy_work(
    animal = Animal_short,
    cohort = cohort,
    nemain = nemain,
    work_hours = work_hours,
    draught_fraction = draught_fraction
  ), by = .I]

  # 6. Fibre production energy (MJ/day)
  data[, nefibre := calc_net_energy_fibre(
    animal = Animal_short,
    cohort = cohort,
    fibre_prod = fibre_prod
  ), by = .I]

  # 7. Pregnancy energy (MJ/day)
  data[, nepreg := calc_net_energy_pregnancy(
    animal = Animal_short,
    cohort = cohort,
    nemain = nemain,
    parturition_rate = parturition_rate,
    litsize = litsize,
    gest = gest,
    duration = duration,
    offtake_rate = offtake_rate
  ), by = .I]

  # 8–9. Diet NE fractions for maintenance & growth
  data[, rem := calc_rem_maintenance(
    animal = Animal_short,
    diet_dig = diet_dig
  ), by = .I]

  data[, reg := calc_reg_growth(
    animal = Animal_short,
    diet_dig = diet_dig
  ), by = .I]

  # 10. Total ME requirement (MJ/day)
  data[, getot := calc_total_energy_requirement(
    animal = Animal_short,
    cohort = cohort,
    nemain = nemain,
    neact = neact,
    nelact = nelact,
    nework = nework,
    nepreg = nepreg,
    rem = rem,
    negrow = negrow,
    nefibre = nefibre,
    neegg = 0,
    reg = reg,
    diet_dig = diet_dig,
    afc = afc
  ), by = .I]

  # 11. Dry matter intake (kg DM/day)
  data[, dmi := calc_dry_matter_intake(
    animal = Animal_short,
    total_energy = getot,
    diet_ge = diet_ge,
    diet_me = diet_me
  ), by = .I]

  return(data)
}
