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
#' @param cohort_level_data A `data.table` or `data.frame` with cohort-level inputs and at least:
#'   \itemize{
#'     \item `herd_id` – Herd identifier (foreign key linking to herd-level table).
#'     \item `cohort` – Cohort code (`FA`, `FS`, `FJ`, `MA`, `MS`, `MJ`).
#'     \item `average_weight` – Average live weight in the cohort (kg).
#'     \item `offtake_rate` – Annual offtake rate for the cohort (fraction).
#'     \item `activity_fraction`, `high_activity_fraction` – Low-/high-activity shares (fractions).
#'     \item `initial_weight`, `final_weight`, `adult_weight` – Weights used for growth calculations (kg).
#'     \item `dwg` – Daily weight gain (kg/head/day).
#'     \item `duration` – Cohort duration (days).
#'     \item `diet_dig` – Diet digestibility (DE/GE, fraction).
#'     \item `diet_ge`, `diet_me` – Gross and metabolizable energy densities (MJ/kg DM).
#'     \item `lambing_interval` – Lambing interval (days) for small ruminants (kept for completeness).
#'   }
#' @param herd_level_data A `data.table` or `data.frame` with herd-level inputs (one row per herd)
#'  and at least:
#'   \itemize{
#'     \item `herd_id` – Herd identifier (primary key).
#'     \item `animal` – Full species name used to derive internal short codes (e.g. `"Cattle"`, `"Sheep"`).
#'     \item `afc` – Age at first calving/parturition (days).
#'     \item `milking_fraction`, `milk_yield`, `milk_fat` – Lactation parameters.
#'     \item `idle`, `gest`, `litsize`, `dr1`, `ckg`, `wkg`, `lact`, `parturition_rate`
#'      – Reproduction and lactation inputs.
#'     \item `egg_weight` – Average egg weight (kg; used only for poultry/egg layers).
#'     \item `work_hours_female`, `work_hours_male` – Daily working hours for adult females/males
#'      (hours/head/day).
#'     \item `draught_fraction_female`, `draught_fraction_male` – Fractions of adult females/males
#'      used for draught work.
#'     \item `fibre_prod` – Annual fibre production per head (kg/head/year).
#'   }
#'
#' @return The input data with new columns: nemain, neact, negrow, nelact, nework,
#' nefibre, nepreg, rem, reg, getot, dmi.
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

  # --- Step 1: Validate inputs -------------------------------------------------
  validate_energy_requirements_inputs(cohort_level_data, herd_level_data)

  # --- Step 2: Create working copies ------------------------------------------
  cohort_level_data <- data.table::copy(cohort_level_data)
  herd_level_data <- data.table::copy(herd_level_data)

  # --- Step 3: Map full animal names to species_short (herd table only) ------
  herd_level_data <- merge(
    herd_level_data,
    abbr_animals,
    by = "animal",
    all.x = TRUE
  )

  # --- Step 4: Maintenance energy (MJ/day) ------------------------------------
  cohort_level_data[
    ,
    nemain := calc_net_energy_maintenance(
      animal = herd_level_data[.SD, on = "herd_id", x.species_short],
      cohort = cohort,
      average_weight = average_weight,
      milking_fraction = herd_level_data[.SD, on = "herd_id", x.milking_fraction],
      offtake_rate = offtake_rate,
      afc = herd_level_data[.SD, on = "herd_id", x.afc]
    ),
    by = .I
  ]

  # --- Step 5: Activity energy (MJ/day) ---------------------------------------
  cohort_level_data[
    ,
    neact := calc_net_energy_activity(
      animal = herd_level_data[.SD, on = "herd_id", x.species_short],
      cohort = cohort,
      nemain = nemain,
      average_weight = average_weight,
      activity_fraction = activity_fraction,
      high_activity_fraction = high_activity_fraction
    ),
    by = .I
  ]

  # --- Step 6: Growth energy (MJ/day) -----------------------------------------
  cohort_level_data[
    ,
    negrow := calc_net_energy_growth(
      animal = herd_level_data[.SD, on = "herd_id", x.species_short],
      cohort = cohort,
      average_weight = average_weight,
      final_weight = final_weight,
      initial_weight = initial_weight,
      adult_weight = adult_weight,
      dwg = dwg,
      offtake_rate = offtake_rate,
      duration = duration
    ),
    by = .I
  ]

  # --- Step 7: Lactation energy (MJ/day) --------------------------------------
  cohort_level_data[
    ,
    nelact := calc_net_energy_lactation(
      animal = herd_level_data[.SD, on = "herd_id", x.species_short],
      cohort = cohort,
      milking_fraction = herd_level_data[.SD, on = "herd_id", x.milking_fraction],
      milk_yield = herd_level_data[.SD, on = "herd_id", x.milk_yield],
      milk_fat = herd_level_data[.SD, on = "herd_id", x.milk_fat],
      idle = herd_level_data[.SD, on = "herd_id", x.idle],
      gest = herd_level_data[.SD, on = "herd_id", x.gest],
      litsize = herd_level_data[.SD, on = "herd_id", x.litsize],
      dr1 = herd_level_data[.SD, on = "herd_id", x.dr1],
      ckg = herd_level_data[.SD, on = "herd_id", x.ckg],
      wkg = herd_level_data[.SD, on = "herd_id", x.wkg],
      lact = herd_level_data[.SD, on = "herd_id", x.lact],
      parturition_rate = herd_level_data[.SD, on = "herd_id", x.parturition_rate]
    ),
    by = .I
  ]

  # --- Step 8: Work energy (MJ/day) ------------------------------------------
  cohort_level_data[
    ,
    nework := calc_net_energy_work(
      animal = herd_level_data[.SD, on = "herd_id", x.species_short],
      cohort = cohort,
      nemain = nemain,
      work_hours_female = herd_level_data[.SD, on = "herd_id", x.work_hours_female],
      work_hours_male = herd_level_data[.SD, on = "herd_id", x.work_hours_male],
      draught_fraction_female = herd_level_data[.SD, on = "herd_id", x.draught_fraction_female],
      draught_fraction_male = herd_level_data[.SD, on = "herd_id", x.draught_fraction_male]
    ),
    by = .I
  ]

  # --- Step 9: Fibre production energy (MJ/day) ------------------------------
  cohort_level_data[
    ,
    nefibre := calc_net_energy_fibre(
      animal = herd_level_data[.SD, on = "herd_id", x.species_short],
      cohort = cohort,
      fibre_prod = herd_level_data[.SD, on = "herd_id", x.fibre_prod]
    ),
    by = .I
  ]

  # --- Step 10: Pregnancy energy (MJ/day) -------------------------------------
  cohort_level_data[
    ,
    nepreg := calc_net_energy_pregnancy(
      animal = herd_level_data[.SD, on = "herd_id", x.species_short],
      cohort = cohort,
      nemain = nemain,
      parturition_rate = herd_level_data[.SD, on = "herd_id", x.parturition_rate],
      litsize = herd_level_data[.SD, on = "herd_id", x.litsize],
      gest = herd_level_data[.SD, on = "herd_id", x.gest],
      idle = herd_level_data[.SD, on = "herd_id", x.idle],
      lact = herd_level_data[.SD, on = "herd_id", x.lact],
      duration = duration,
      offtake_rate = offtake_rate
    ),
    by = .I
  ]

  # --- Step 11: Diet NE fractions (rem, reg) -----------------------------------
  cohort_level_data[
    ,
    rem := calc_rem_maintenance(
      animal = herd_level_data[.SD, on = "herd_id", x.species_short],
      diet_dig = diet_dig
    ),
    by = .I
  ]

  cohort_level_data[
    ,
    reg := calc_reg_growth(
      animal = herd_level_data[.SD, on = "herd_id", x.species_short],
      diet_dig = diet_dig
    ),
    by = .I
  ]

  # --- Step 12: Total ME requirement (MJ/day) ----------------------------------
  cohort_level_data[
    ,
    getot := calc_total_energy_requirement(
      animal = herd_level_data[.SD, on = "herd_id", x.species_short],
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
      diet_dig = diet_dig
    ),
    by = .I
  ]

  # --- Step 13: Dry matter intake (kg DM/day) ----------------------------------
  cohort_level_data[
    ,
    dmi := calc_dry_matter_intake(
      animal = herd_level_data[.SD, on = "herd_id", x.species_short],
      total_energy = getot,
      diet_ge = diet_ge,
      diet_me = diet_me
    ),
    by = .I
  ]

  return(cohort_level_data)
}
