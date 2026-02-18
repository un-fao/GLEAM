#' Run Energy Requirements and Dry Matter Intake Calculation (Internal)
#'
#' Computes energy requirements and dry matter intake (DMI) for each row of input data
#' using the GLEAM core model functions. This function is intended for internal workflows
#' and does not perform any file I/O.
#'
#' It adds columns for energy requirements (maintenance, activity, growth, lactation, work,
#' fibre production, pregnancy), diet net energy ratios (REM, REG), total energy requirement
#' and dry matter intake.
#'
#' @param cohort_level_data A `data.table` or `data.frame` with cohort-level inputs and at least:
#'   \itemize{
#'     \item `herd_id` – Herd identifier (foreign key linking to herd-level table).
#'     \item `cohort_short` – Cohort code (`FA`, `FS`, `FJ`, `MA`, `MS`, `MJ`).
#'     \item `live_weight_cohort_average` – Average live weight in the cohort (kg).
#'     \item `offtake_rate` – Annual offtake rate for the cohort (fraction).
#'     \item `low_activity_fraction`, `high_activity_fraction` – Low-/high-activity shares (fractions).
#'     \item `live_weight_cohort_initial`, `live_weight_cohort_final`, `mature_weight` – Weights for growth (kg).
#'     \item `daily_weight_gain` – Daily weight gain (kg/head/day).
#'     \item `cohort_duration_days` – Cohort duration (days).
#'     \item `diet_digestibility_fraction` – Diet digestibility (DE/GE, fraction).
#'     \item `diet_gross_energy`, `diet_metabolizable_energy` – Gross and metabolizable energy (MJ/kg DM).
#'   }
#' @param herd_level_data A `data.table` or `data.frame` with herd-level inputs (one row per herd)
#'  and at least:
#'   \itemize{
#'     \item `herd_id` – Herd identifier (primary key).
#'     \item `animal` – Full species name used to derive species_short (e.g. `"Cattle"`, `"Sheep"`).
#'     \item `age_first_parturition` – Age at first parturition (days).
#'     \item `lactating_females_fraction`, `milk_yield_day`, `milk_fat_fraction` – Lactation parameters.
#'     \item `non_productive_duration`, `pregnancy_duration`, `litter_size`, `death_rate_juvenile`,
#'      `birth_weight`, `weaning_weight`, `lactation_duration`, `parturition_rate` – Reproduction/lactation.
#'     \item `egg_average_weight` – Average egg weight (kg; poultry/egg layers).
#'     \item `draught_work_hours_female`, `draught_work_hours_male` – Daily draught work hours (hours/head/day).
#'     \item `draught_fraction_female`, `draught_fraction_male` – Fractions of adults used for draught work.
#'     \item `fibre_yield_year` – Annual fibre production per head (kg/head/year).
#'   }
#'
#' @return The cohort-level data with new columns: energy_requirement_maintenance,
#' energy_requirement_activity, energy_requirement_growth, energy_requirement_lactation,
#' energy_requirement_work, energy_requirement_fibre_production, energy_requirement_pregnancy,
#' net_energy_maintenance_digestible_energy_ratio, net_energy_growth_digestible_energy_ratio,
#' energy_requirement_total, dry_matter_intake.
#'
#' @examples
#' \dontrun{
#' # Load example herd- and cohort-level inputs from the package
#' herd_path <- system.file(
#'   "extdata/examples/energy_requirements_herd_input_example.csv",
#'   package = "gleam"
#' )
#' cohort_path <- system.file(
#'   "extdata/examples/energy_requirements_cohort_input_example.csv",
#'   package = "gleam"
#' )
#' herd_level_data <- data.table::fread(herd_path)
#' cohort_level_data <- data.table::fread(cohort_path)
#'
#' # Run energy requirement and DMI calculations
#' energy_results <- run_energy_requirements(
#'   cohort_level_data = cohort_level_data,
#'   herd_level_data = herd_level_data
#' )
#' }
#'
#' @importFrom data.table := .I
run_energy_requirements <- function(
    cohort_level_data,
    herd_level_data
) {
  cohort_level_data <- data.table::as.data.table(cohort_level_data)
  herd_level_data <- data.table::as.data.table(herd_level_data)

  # --- Step 1: Validate inputs ------------------------------------------------
  validate_energy_requirements_inputs(cohort_level_data, herd_level_data)

  # --- Step 2: Create working copies ------------------------------------------
  cohort_level_data <- data.table::copy(cohort_level_data)
  herd_level_data <- data.table::copy(herd_level_data)

  # --- Step 3: Map full animal names to species_short (herd table only) -------
  herd_level_data <- merge(
    herd_level_data,
    abbr_animals,
    by = "animal",
    all.x = TRUE
  )

  # --- Step 4: Maintenance energy (MJ/day) ------------------------------------
  cohort_level_data[
    ,
    energy_requirement_maintenance := calc_net_energy_maintenance(
      species_short = herd_level_data[.SD, on = "herd_id", x.species_short],
      cohort_short = cohort_short,
      live_weight_cohort_average = live_weight_cohort_average,
      lactating_females_fraction = herd_level_data[.SD, on = "herd_id", x.lactating_females_fraction],
      offtake_rate = offtake_rate,
      age_first_parturition = herd_level_data[.SD, on = "herd_id", x.age_first_parturition]
    ),
    by = .I
  ]

  # --- Step 5: Activity energy (MJ/day) ---------------------------------------
  cohort_level_data[
    ,
    energy_requirement_activity := calc_net_energy_activity(
      species_short = herd_level_data[.SD, on = "herd_id", x.species_short],
      cohort_short = cohort_short,
      energy_requirement_maintenance = energy_requirement_maintenance,
      live_weight_cohort_average = live_weight_cohort_average,
      low_activity_fraction = low_activity_fraction,
      high_activity_fraction = high_activity_fraction
    ),
    by = .I
  ]

  # --- Step 6: Growth energy (MJ/day) -----------------------------------------
  cohort_level_data[
    ,
    energy_requirement_growth := calc_net_energy_growth(
      species_short = herd_level_data[.SD, on = "herd_id", x.species_short],
      cohort_short = cohort_short,
      live_weight_cohort_average = live_weight_cohort_average,
      live_weight_cohort_final = live_weight_cohort_final,
      live_weight_cohort_initial = live_weight_cohort_initial,
      mature_weight = mature_weight,
      daily_weight_gain = daily_weight_gain,
      offtake_rate = offtake_rate,
      cohort_duration_days = cohort_duration_days
    ),
    by = .I
  ]

  # --- Step 7: Lactation energy (MJ/day) --------------------------------------
  cohort_level_data[
    ,
    energy_requirement_lactation := calc_net_energy_lactation(
      species_short = herd_level_data[.SD, on = "herd_id", x.species_short],
      cohort_short = cohort_short,
      lactating_females_fraction = herd_level_data[.SD, on = "herd_id", x.lactating_females_fraction],
      milk_yield_day = herd_level_data[.SD, on = "herd_id", x.milk_yield_day],
      milk_fat_fraction = herd_level_data[.SD, on = "herd_id", x.milk_fat_fraction],
      non_productive_duration = herd_level_data[.SD, on = "herd_id", x.non_productive_duration],
      pregnancy_duration = herd_level_data[.SD, on = "herd_id", x.pregnancy_duration],
      litter_size = herd_level_data[.SD, on = "herd_id", x.litter_size],
      death_rate_juvenile = herd_level_data[.SD, on = "herd_id", x.death_rate_juvenile],
      birth_weight = herd_level_data[.SD, on = "herd_id", x.birth_weight],
      weaning_weight = herd_level_data[.SD, on = "herd_id", x.weaning_weight],
      lactation_duration = herd_level_data[.SD, on = "herd_id", x.lactation_duration],
      parturition_rate = herd_level_data[.SD, on = "herd_id", x.parturition_rate]
    ),
    by = .I
  ]

  # --- Step 8: Work energy (MJ/day) ------------------------------------------
  cohort_level_data[
    ,
    energy_requirement_work := calc_net_energy_work(
      species_short = herd_level_data[.SD, on = "herd_id", x.species_short],
      cohort_short = cohort_short,
      energy_requirement_maintenance = energy_requirement_maintenance,
      draught_work_hours_female = herd_level_data[.SD, on = "herd_id", x.draught_work_hours_female],
      draught_work_hours_male = herd_level_data[.SD, on = "herd_id", x.draught_work_hours_male],
      draught_fraction_female = herd_level_data[.SD, on = "herd_id", x.draught_fraction_female],
      draught_fraction_male = herd_level_data[.SD, on = "herd_id", x.draught_fraction_male]
    ),
    by = .I
  ]

  # --- Step 9: Fibre production energy (MJ/day) ------------------------------
  cohort_level_data[
    ,
    energy_requirement_fibre_production := calc_net_energy_fibre(
      species_short = herd_level_data[.SD, on = "herd_id", x.species_short],
      cohort_short = cohort_short,
      fibre_yield_year = herd_level_data[.SD, on = "herd_id", x.fibre_yield_year]
    ),
    by = .I
  ]

  # --- Step 10: Pregnancy energy (MJ/day) -------------------------------------
  cohort_level_data[
    ,
    energy_requirement_pregnancy := calc_net_energy_pregnancy(
      species_short = herd_level_data[.SD, on = "herd_id", x.species_short],
      cohort_short = cohort_short,
      energy_requirement_maintenance = energy_requirement_maintenance,
      parturition_rate = herd_level_data[.SD, on = "herd_id", x.parturition_rate],
      litter_size = herd_level_data[.SD, on = "herd_id", x.litter_size],
      pregnancy_duration = herd_level_data[.SD, on = "herd_id", x.pregnancy_duration],
      non_productive_duration = herd_level_data[.SD, on = "herd_id", x.non_productive_duration],
      lactation_duration = herd_level_data[.SD, on = "herd_id", x.lactation_duration],
      cohort_duration_days = cohort_duration_days,
      offtake_rate = offtake_rate
    ),
    by = .I
  ]

  # --- Step 11: Diet NE fractions ---------------------------------------------
  cohort_level_data[
    ,
    net_energy_maintenance_digestible_energy_ratio := calc_rem_maintenance(
      species_short = herd_level_data[.SD, on = "herd_id", x.species_short],
      diet_digestibility_fraction = diet_digestibility_fraction
    ),
    by = .I
  ]

  cohort_level_data[
    ,
    net_energy_growth_digestible_energy_ratio := calc_reg_growth(
      species_short = herd_level_data[.SD, on = "herd_id", x.species_short],
      diet_digestibility_fraction = diet_digestibility_fraction
    ),
    by = .I
  ]

  # --- Step 12: Total ME requirement (MJ/day) ---------------------------------
  cohort_level_data[
    ,
    energy_requirement_total := calc_total_energy_requirement(
      species_short = herd_level_data[.SD, on = "herd_id", x.species_short],
      energy_requirement_maintenance = energy_requirement_maintenance,
      energy_requirement_activity = energy_requirement_activity,
      energy_requirement_lactation = energy_requirement_lactation,
      energy_requirement_work = energy_requirement_work,
      energy_requirement_pregnancy = energy_requirement_pregnancy,
      net_energy_maintenance_digestible_energy_ratio = net_energy_maintenance_digestible_energy_ratio,
      energy_requirement_growth = energy_requirement_growth,
      energy_requirement_fibre_production = energy_requirement_fibre_production,
      energy_requirement_egg_deposition = 0,
      net_energy_growth_digestible_energy_ratio = net_energy_growth_digestible_energy_ratio,
      diet_digestibility_fraction = diet_digestibility_fraction
    ),
    by = .I
  ]

  # --- Step 13: Dry matter intake (kg DM/day) ---------------------------------
  cohort_level_data[
    ,
    dry_matter_intake := calc_dry_matter_intake(
      species_short = herd_level_data[.SD, on = "herd_id", x.species_short],
      energy_requirement_total = energy_requirement_total,
      diet_gross_energy = diet_gross_energy,
      diet_metabolizable_energy = diet_metabolizable_energy
    ),
    by = .I
  ]

  return(cohort_level_data)
}
