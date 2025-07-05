#' Run Energy Requirements and Dry Matter Intake Calculation (Internal)
#'
#' Computes energy requirements and dry matter intake (DMI) for each row of input data
#' using the GLEAM core model functions. This function is intended for internal workflows
#' and does not perform any file I/O.
#'
#' It adds columns for net energy for maintenance (nemain), activity (neact), growth (negrow),
#' lactation (nelact), work (nework), fibre production (nefibre), pregnancy (nepreg), diet net energy
#' fractions (rem, reg), total metabolizable energy requirement (getot), embedded meat energy (nemeat),
#' and dry matter intake (dmi
#'
#' @param data A `data.table` or `data.frame` containing all required columns for energy requirements
#'   (see core model functions documentation for required fields).
#'
#' @return The input data with new columns: nemain, neact, negrow, nelact, nework,
#' nefibre, nepreg, rem, reg, getot, nemeat, dmi.
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
  stopifnot(is.data.frame(data))
  if (nrow(data) == 0) stop("Input data has 0 rows.")
  required <- c(
    "Animal_short","cohort","afc","average_weight","milking_fraction",
    "offtake_rate","idle","gest","lact","litsize","ckg",
    "work_hours","draught_fraction","fibre_prod",
    "parturition_rate","duration",
    "diet_dig","diet_ge","diet_me",
    "slaughter_weight","initial_weight"
  )
  miss <- setdiff(required, names(data))
  if (length(miss)) stop("Missing required columns: ", paste(miss, collapse = ", "))

  # 1. Maintenance energy (MJ/day)
  data[, nemain := calc_net_energy_maintenance(
    animal = Animal_short,
    cohort = cohort,
    average_weight = average_weight,
    idle = idle,
    gest = gest,
    lact = lact,
    litsize = litsize,
    ckg = ckg,
    milking_fraction = milking_fraction,
    offtake_rate = offtake_rate,
    afc = afc
  ), by = seq_len(nrow(data))]

  # 2. Activity energy (MJ/day)
  data[, neact := calc_net_energy_activity(
    animal = Animal_short,
    cohort = cohort,
    past_man_frac = past_man_frac,
    mmspasture = mmspasture,
    nemain = nemain,
    average_weight = average_weight,
    offtake_rate = offtake_rate
  ), by = seq_len(nrow(data))]

  # 3. Growth energy (MJ/day)
  data[, negrow := calc_net_energy_growth(
    animal = Animal_short,
    cohort = cohort,
    average_weight = average_weight,
    final_weight = final_weight,
    initial_weight = initial_weight,
    dwg = dwg,
    offtake_rate = offtake_rate,
    duration = duration
  ), by = seq_len(nrow(data))]

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
    lambing_interval = lambing_interval
  ), by = seq_len(nrow(data))]

  # 5. Work energy (MJ/day)
  data[, nework := calc_net_energy_work(
    animal = Animal_short,
    cohort = cohort,
    nemain = nemain,
    work_hours = work_hours,
    draught_fraction = draught_fraction
  ), by = seq_len(nrow(data))]

  # 6. Fibre production energy (MJ/day)
  data[, nefibre := calc_net_energy_fibre(
    animal = Animal_short,
    cohort = cohort,
    fibre_prod = fibre_prod
  ), by = seq_len(nrow(data))]

  # 7. Pregnancy energy (MJ/day)
  data[, nepreg := calc_net_energy_pregnancy(
    animal = Animal_short,
    cohort = cohort,
    nemain = nemain,
    parturition_rate = parturition_rate,
    idle = idle,
    lact = lact,
    litsize = litsize,
    gest = gest,
    duration = duration,
    offtake_rate = offtake_rate
  ), by = seq_len(nrow(data))]

  # 8–9. Diet NE fractions for maintenance & growth
  data[, rem := calc_rem_maintenance(
    animal = Animal_short,
    diet_dig = diet_dig
  ), by = seq_len(nrow(data))]

  data[, reg := calc_reg_growth(
    animal = Animal_short,
    diet_dig = diet_dig
  ), by = seq_len(nrow(data))]

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
    neegg = neegg,
    reg = reg,
    diet_dig = diet_dig,
    afc = afc
  ), by = seq_len(nrow(data))]

  # 11. Embedded meat energy (MJ/head)
  data[, nemeat := calc_net_energy_meat(
    animal = Animal_short,
    cohort = cohort,
    ckg = ckg, afc = afc,
    slaughter_weight = slaughter_weight,
    initial_weight = initial_weight
  ), by = seq_len(nrow(data))]

  # 12. Dry matter intake (kg DM/day)
  data[, dmi := calc_dry_matter_intake(
    animal = Animal_short,
    total_energy = getot,
    diet_ge = diet_ge,
    diet_me = diet_me
  ), by = seq_len(nrow(data))]

  return(data)
}

