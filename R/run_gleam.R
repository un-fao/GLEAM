#' Run GLEAM Main Pipeline
#'
#' Runs the Global Livestock Environmental Assessment Model (GLEAM) computational workflow
#' on cohort-level (long-format) herd data. The function orchestrates the core scientific
#' modules to compute feed intake, livestock energy requirements, nitrogen balance, direct emissions from
#' enteric fermentation and manure management, production outputs, and allocates emissions
#' by commodity. All species are supported except CHK (chickens), which are excluded from this pipeline.
#' Final results are provided at herd-level  (including CO₂-equivalent emissions using GWP-100 factors).
#' 
#' 
#' @param data A `data.table` (one row per cohort) containing all
#'   required input columns (see details). 
#' @param has_herd Logical. If `FALSE`, runs herd simulation to compute herd structure.
#'   If `TRUE`, assumes herd structure \code{size} is already provided in input.
#'   Defaults to `FALSE`.
#' @param gwp Character. Global Warming Potential-100 conversion factors to use.
#'   Must be one of: "AR6" (default), "AR5_excluding_carbon_feedback",
#'   "AR5_including_carbon_feedback", "AR4".
#' @param allocation_type Character. Allocation methodology. Defaults to "biophysical-energy".
#' @param assessment_duration Numeric. Assessment period in days. Defaults to `365`.
#' 
#' @details
#' \strong{What this function does.}
#' \code{run_gleam()} is the primary entry point for the package. The pipeline executes the following modules in sequence:
#'
#' 1. **Herd Simulation** (optional): Simulates steady-state herd structure
#' 2. **Weights**: Calculates average weights and daily weight gain
#' 3. **Energy Requirements & DMI**: Computes net energy requirements and dry matter intake
#' 4. **Direct Emissions - Enteric**: Calculates enteric methane emissions
#' 5. **Nitrogen Balance**: Computes nitrogen intake, retention, and excretion
#' 6. **Direct Emissions - Manure**: Calculates \eqn{CH[4]} and \eqn{N[2]O} emissions from manure management
#' 7. **Production**: Computes milk, meat, and fibre outputs
#' 8. **Allocation**: Calculates biophysical energy allocation shares
#' 9. **Aggregation**: Finalizes results with \eqn{CO[2]}-equivalent conversions
#' 
#' \strong{Input format and cohort structure.}
#' 
#' The input must be a \code{data.table} (or coercible to \code{data.table}) with one row per cohort.
#' A herd identifier column \code{herd_id} is required. In the standard GLEAM cohort structure,
#' each herd is represented by six cohorts: \code{FJ, FS, FA, MJ, MS, MA}. 
#' 
#' \strong{General identifiers:}
#' \itemize{
#'   \item \code{herd_id} — Character. Unique identifier for the herd, repeated for each cohort belonging to the same herd.
#'   \item \code{Animal_short} — Character. Code identifying the livestock species.
#'     Supported values include \code{PGS} (pigs), \code{CML} (camels), \code{CTL} (cattle),
#'     \code{BFL} (buffalo), \code{SHP} (sheep), \code{GTS} (goats).
#'   \item \code{cohort} — Character scalar. Sex- and age-specific cohort code describing the
#'   production stage of the animals. Supported values include:
#'   \itemize{
#'     \item \code{FA}: adult females (from age at first parturition)
#'     \item \code{FS}: sub-adult females (from weaning to age at first parturition)
#'     \item \code{FJ}: juvenile females (from birth to weaning)
#'     \item \code{MA}: adult males (from age at first breeding)
#'     \item \code{MS}: sub-adult males (from weaning to age at first breeding)
#'     \item \code{MJ}: juvenile males (from birth to weaning)
#'   }
#' }
#' 
#' \emph{If herd simulation runs (\code{has_herd = FALSE}):}
#' \itemize{
#'   \item \code{duration} — Numeric. Amount of time that each animal spends in a specific cohort (days).
#'   \item \code{offtake_rate} — Numeric. Annual proportion of animals removed from the herd for each sex-age cohort (fraction).
#'   \item \code{mort_rate} — Numeric. Fraction of deaths in a herd over a year for each sex-age class (fraction).
#'   \item \code{parturition_rate} — Numeric. Average annual number of parturitions per female animal (#/female/year). Repeated across cohorts.
#'   \item \code{litsize} — Numeric. Average number of offspring born per parturition (#/parturition). Repeated across cohorts.
#'   \item \code{female_birth_fraction} — Numeric. Probability that a newborn offspring is female (fraction). Repeated across cohorts.
#'   \item \code{size_total} — Numeric. Total herd size (heads). Repeated across cohorts.
#' }
#'
#' \emph{If herd simulation is skipped (\code{has_herd = TRUE}):}
#' \itemize{
#'   \item \code{duration} — Numeric. Amount of time that each animal spends in a specific cohort (days).
#'   \item \code{offtake_rate} — Numeric. Annual proportion of animals removed from the herd for each sex-age cohort (fraction).
#'   \item \code{offtake_number_assessment} — Numeric. Total number of animals removed via offtake over the assessment period (heads/assessment period).
#'   \item \code{parturition_rate} — Numeric. Average annual number of parturitions per female animal (#/female/year). Repeated across cohorts.
#'   \item \code{litsize} — Numeric. Average number of offspring born per parturition (#/parturition). Repeated across cohorts.
#'   \item \code{size} — Numeric. Population size in each of the six sex–age cohorts at the start of the assessment period (heads).
#' }
#'
#' \strong{Weights and growth:}
#' \itemize{
#'   \item \code{afc} — Numeric. Age at first parturition for female breeding animals (years).
#'   \item \code{ckg} — Numeric. Live weight of the animal at birth (kg).
#'   \item \code{wkg} — Numeric. Live weight of the animal at weaning (kg).
#'   \item \code{initial_weight} — Numeric. Live weight at the beginning of the cohort stage (kg).
#'   \item \code{potential_final_weight} — Numeric. Potential final live weight attainable at the end of the cohort stage in the absence of offtake (kg).
#'   \item \code{slaughter_weight} — Numeric. Live weight at slaughter for animals removed from the cohort (kg).
#'   \item \code{adult_weight} — Numeric. Mature (adult) live weight attainable under given conditions (kg).
#'   \item \code{offtake_rate} — Numeric. Annual proportion of animals removed from the herd for each sex-age cohort (fraction).
#' }
#'
#' \strong{Diet, Animal activity, reproduction, and lactation parameters:}
#' \itemize{
#'   \item \code{diet_ge} — Numeric. Average gross energy content of the diet (MJ/kg DM).
#'   \item \code{diet_dig} — Numeric. Average digestibility of the feed ration, expressed as ratio of digestible to gross energy content (fraction).
#'   \item \code{diet_me} — Numeric. Average metabolizable energy content of the diet (MJ/kg DM).
#'   
#'   \item \code{diet_nitrogen} — Numeric. Average nitrogen content of diet (kg N/kg DM).
#'   \item \code{milking_fraction} — Numeric. Share of adult females lactating within the assessment duration. Applies to species = CML, CTL, BFL, SHP, GTS. (fraction).
#'   \item \code{activity_fraction} — Numeric. Proportion of the assessment period during which the animal performs low-intensity movement typical of stall-feeding or near-field grazing, characterized by minimal walking distances and flat terrain  (fraction).
#'   \item \code{high_activity_fraction} — Numeric. Proportion of the assessment period during which the animal engages in sustained locomotion associated with herding or long-distance grazing, typically involving extended walking distances and/or uneven or hilly terrain (fraction).
#'   \item \code{draught_fraction} — Numeric. Fraction of adult males involved in draught work (fraction).
#'   \item \code{work_hours} — Numeric. Average daily working time per animal for CTL, BFL and CML, expressed as hours worked per head per day  (hours/head/day). 
#'   \item \code{gest} — Numeric. Duration of pregnancy period (days).
#'   \item \code{lact} — Numeric. Duration of the lactation period, defined as the number of days during which the animal is lactating (days). Required only for \code{PGS}.
#'   \item \code{idle} —Numeric. Period during which the animal is not performing any productive physiological function such as pregnancy or lactation (days). Required only for \code{PGS}.
#'   \item \code{dr1} — Numeric. Fraction of deaths in a herd over a year for juvenile cohorts (i.e. FJ and MJ), (fraction).
#' }
#'
#' \strong{Production inputs:}
#' \itemize{
#'   \item \code{milk_yield} — Numeric.  Average milk yield per milk-producing animal during the assessment duration (kg/head/day). This value can be calculated by dividing the total milk destinated to human consumption produced per milk-producing animal over the assessment duration by the length of the assessment period.
#'   \item \code{milk_fat} — Numeric. Milk fat fraction (kg fat/kg milk).
#'   \item \code{milk_protein} — Numeric. Milk protein fraction (kg potein/kg milk).
#'   \item \code{lactose} — Numeric. Milk lactose fraction (kg lactose/kg milk).
#'   \item \code{fibre_prod} — Numeric. Annual production yield of fibre, such as wool, cashmere, mohair (kg/head/year).
#'   \item \code{carcass_dressing_percentage} — Numeric. Ratio of a slaughtered animal's carcass weight to its live weight (fraction).
#'   \item \code{bone_free_meat_fraction} — Numeric. Ratio of bone-free-meat to carcass weight (fraction)
#'   \item \code{meat_protein} — Numeric. Protein content of bone-free-meat (kg protein/kg bone-free-meat)
#' }
#'
#' \strong{Manure management and emission factors:}
#' \itemize{
#'   \item \code{b0_mms_all} — Numeric. Maximum methane producing capacity for all systems (m³ CH4/kg VS). The value is region- and species-specific. Default can be selected from Table 10.16 (IPCC, 2019) or from Tables 10A-4 to 10A-9 (IPCC, 2006)
#'   \item \code{b0_mms_pasture} — Numeric. Maximum methane producing capacity for manure deposited on pasture (m³ CH4/kg VS). Default can be selected from Table 10.16 (IPCC, 2019). For IPCC 2006 method, it is assumed to be equal to b0_mms_all.
#'   \item \code{mcf_pasture} — Numeric. Effective methane conversion factor for manure deposited on pasture (mcfpasture), expressed in percent (%), and already weighted by the share of manure deposited on pasture (mmspasture) (percentage)
#'   \item \code{mcf_burned} — Numeric. Effective methane conversion factor for manure burned for fuel (mcfburned), expressed in percent (%), and already weighted by the share of manure burned for fuel (mmsburned) (percentage)
#'   \item \code{mcf_other} — Numeric. Effective methane conversion factor for manure managed in non-pasture, non-burned manure management systems, expressed in percent (%), and already weighted by the share of each corresponding manure management system (e.g., mmsolid, mmsliquid...etc.) (percentage)
#'   \item \code{ef3_pasture} — Numeric. Effective EF3 factor for manure deposited on pasture (ef3pasture), expressed in kg N2O-N / kg N excreted, and already weighted by the share of manure deposited on pasture (mmspasture) (kg N2O-N / kg N excreted)
#'   \item \code{ef3_burned} — Numeric. Effective EF3 for manure burned for fuel (kg N\eqn{_2}O-N/kg N excreted).
#'   \item \code{ef3_other} — Numeric. Effective EF3 factor for manure managed in non-pasture, non-burned manure management systems, expressed in g N2O-N / kg N excreted, and already weighted by the share of each corresponding manure management system (e.g., mmsolid, mmsliquid...etc.) (kg N2O-N / kg N excreted)
#'   \item \code{ef4} — Numeric. Emission factor for indirect nitrous oxide (N₂O) emissions resulting from atmospheric deposition of volatilised nitrogen (NH₃–N and NOₓ–N) onto soils and water surfaces (kg N₂O–N / (kg NH₃–N + NOₓ–N)).
#'   \item \code{ef5} — Numeric. Emission factor for indirect nitrous oxide emissions resulting from nitrogen leaching and runoff, expressed as kilograms of N₂O–N per kilogram of nitrogen leached or lost through runoff (kg N₂O–N / kg N leached and runoff).
#'   \item \code{fracgas_pasture} — Numeric. Effective fraction of excreted nitrogen volatilized as NH₃ and NOₓ from manure deposited on pasture, already weighted by the share of manure deposited on pasture (mmspasture) (fraction).
#'   \item \code{fracgas_burned} — Numeric. Effective fraction of excreted nitrogen volatilized as NH₃ and NOₓ from manure burned for fuel, already weighted by the share of manure burned (mmsburned) (fraction).
#'   \item \code{fracgas_other} — Numeric. Effective fraction of excreted nitrogen volatilized as NH₃ and NOₓ from manure managed in non-pasture, non-burned manure management systems, already weighted by the shares of the corresponding systems (fraction).
#'   \item \code{fracleach_pasture} — Numeric. Effective fraction of excreted nitrogen lost through leaching and runoff from manure deposited on pasture, already weighted by the share of manure deposited on pasture (mmspasture) (fraction).
#'   \item \code{fracleach_burned} — Numeric. Effective fraction of excreted nitrogen lost through leaching and runoff from manure burned for fuel, already weighted by the share of manure burned (mmsburned) (fraction).
#'   \item \code{fracleach_other} — Numeric. Effective fraction of excreted nitrogen lost through leaching and runoff from manure managed in non-pasture, non-burned manure management systems, already weighted by the shares of the corresponding manure management systems (e.g. solid storage, drylot, liquid/slurry) (fraction).
#' }
#'
#' \strong{Global warming potential (used in aggregation).}
#' \itemize{
#'   \item \code{gwp} — Character. Global Warming Potential (GWP-100) option used to convert CH4 and N2O to CO2eq. Supported values: "AR6" (CH4=27, N2O=273), "AR5_excluding_carbon_feedback" (CH4=28, N2O=265), "AR5_including_carbon_feedback" (CH4=34, N2O=298), "AR4" (CH4=25, N2O=298).
#' }
#' 
#' 
#' \strong{Important behavior (conditional execution).}
#' Modules are executed only if the required input columns are present. If the inputs for a module
#' are missing, that module is skipped and downstream variables depending on it may not be produced.
#' 
#' @return A named list containing:
#' \describe{
#'   \item{`data_cohort`}{The raw cohort-level data with all calculated variables.}
#'   \item{`results_herd`}{Herd-level results in long format with allocated emissions and production variables.}
#' }
#'
#' @examples
#' \dontrun{
#' # Load example data and run GLEAM pipeline
#' data <- data.table::fread(
#'   system.file("extdata/example_run_gleam_ipcc2006.csv", package = "gleam")
#' )
#' result <- run_gleam(data, has_herd = FALSE)
#' }
#'
#' @export
#'
#' @importFrom data.table := .I
run_gleam <- function(
    data,
    has_herd = FALSE,
    gwp = "AR6",
    allocation_type = "biophysical-energy",
    assessment_duration = 365
) {
  # Convert to data.table if needed
  if (!data.table::is.data.table(data)) {
    data <- data.table::as.data.table(data)
  }

  # --- Module 1: Herd Simulation (optional) -----------------------------------
  if (has_herd == FALSE) {
    data <- run_herd_simulation(
      herd_data = data,
      initial_structure = c(FJ = 100, FS = 50, FA = 30, MJ = 100, MS = 50, MA = 30),
      max_years = 100,
      lambda_threshold = 1e-9,
      show_indicator = FALSE
    )
  }

  # Ensure assessment_duration column exists
  if (!"assessment_duration" %in% names(data)) {
    data[, assessment_duration := assessment_duration]
  }

  # --- Module 2: Weights ------------------------------------------------------
  # Calculate average weights and daily weight gain
  # Note: calc_cohort_weights() is not used - weights are expected in input

  # Calculate average weights
  if (all(c("initial_weight", "potential_final_weight", "slaughter_weight", "offtake_rate") %in% names(data))) {
    weight_result <- data[, calc_avg_weights(
      initial_weight = initial_weight,
      potential_final_weight = potential_final_weight,
      slaughter_weight = slaughter_weight,
      offtake_rate = offtake_rate
    ), by = .I]

    data[, average_weight := weight_result$average_weight]
    data[, final_weight := weight_result$final_weight]
  }

  # Calculate daily weight gain
  if (all(c("potential_final_weight", "initial_weight", "duration") %in% names(data))) {
    data[, dwg := calc_daily_weight_gain(
      potential_final_weight = potential_final_weight,
      initial_weight = initial_weight,
      duration = duration
    ), by = .I]
  }

  # --- Module 3: Energy Requirements & DMI ------------------------------------
  # Note: adult_weight should be provided as input (not calculated)

  # 1. Maintenance energy (MJ/day)
  if (all(c("Animal_short", "cohort", "average_weight", "milking_fraction", "offtake_rate", "afc") %in% names(data))) {
    data[, nemain := calc_net_energy_maintenance(
      animal = Animal_short,
      cohort = cohort,
      average_weight = average_weight,
      milking_fraction = milking_fraction,
      offtake_rate = offtake_rate,
      afc = afc
    ), by = .I]
  }

  # 2. Activity energy (MJ/day)
  if (all(c("Animal_short", "cohort", "nemain", "average_weight", "activity_fraction", "high_activity_fraction") %in% names(data))) {
    data[, neact := calc_net_energy_activity(
      animal = Animal_short,
      cohort = cohort,
      nemain = nemain,
      average_weight = average_weight,
      activity_fraction = activity_fraction,
      high_activity_fraction = high_activity_fraction
    ), by = .I]
  }

  # 3. Growth energy (MJ/day)
  if (all(c("Animal_short", "cohort", "average_weight", "final_weight", "initial_weight", "adult_weight", "dwg", "offtake_rate", "duration") %in% names(data))) {
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
  }

  # 4. Lactation energy (MJ/day)
  if (all(c("Animal_short", "cohort", "milking_fraction", "milk_yield", "milk_fat", "idle", "gest", "litsize", "dr1", "ckg", "wkg", "lact", "parturition_rate", "lambing_interval") %in% names(data))) {
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
      assessment_duration = assessment_duration
    ), by = .I]
  }

  # 5. Work energy (MJ/day)
  if (all(c("Animal_short", "cohort", "nemain", "work_hours", "draught_fraction") %in% names(data))) {
    data[, nework := calc_net_energy_work(
      animal = Animal_short,
      cohort = cohort,
      nemain = nemain,
      work_hours = work_hours,
      draught_fraction = draught_fraction
    ), by = .I]
  }

  # 6. Fibre production energy (MJ/day)
  if (all(c("Animal_short", "cohort", "fibre_prod") %in% names(data))) {
    data[, nefibre := calc_net_energy_fibre(
      animal = Animal_short,
      cohort = cohort,
      fibre_prod = fibre_prod
    ), by = .I]
  }

  # 7. Pregnancy energy (MJ/day)
  if (all(c("Animal_short", "cohort", "nemain", "parturition_rate", "litsize", "gest", "duration", "offtake_rate") %in% names(data))) {
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
  }

  # 8-9. Diet NE fractions for maintenance & growth
  if (all(c("Animal_short", "diet_dig") %in% names(data))) {
    data[, rem := calc_rem_maintenance(
      animal = Animal_short,
      diet_dig = diet_dig
    ), by = .I]

    data[, reg := calc_reg_growth(
      animal = Animal_short,
      diet_dig = diet_dig
    ), by = .I]
  }

  # 10. Total ME requirement (MJ/day)
  if (all(c("Animal_short", "cohort", "nemain", "neact", "nelact", "nework", "nepreg", "rem", "negrow", "nefibre", "diet_dig", "afc") %in% names(data))) {
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
  }

  # 11. Dry matter intake (kg DM/day)
  if (all(c("Animal_short", "getot", "diet_ge", "diet_me") %in% names(data))) {
    data[, dmi := calc_dry_matter_intake(
      animal = Animal_short,
      total_energy = getot,
      diet_ge = diet_ge,
      diet_me = diet_me
    ), by = .I]
  }

  # --- Module 4: Direct Emissions - Enteric ------------------------------------
  if (all(c("Animal_short", "cohort", "diet_dig") %in% names(data))) {
    data[, ym := compute_methane_conversion_factor(
      animal = Animal_short,
      cohort = cohort,
      diet_dig = diet_dig
    ), by = .I]
  }

  if (all(c("Animal_short", "cohort", "ym", "diet_ge", "dmi") %in% names(data))) {
    data[, ch4_enteric := compute_daily_enteric_emissions(
      animal = Animal_short,
      cohort = cohort,
      ym = ym,
      diet_ge = diet_ge,
      dmi = dmi
    ), by = .I]
  }

  # --- Module 5: Nitrogen Balance ---------------------------------------------
  if (all(c("dmi", "diet_nitrogen") %in% names(data))) {
    data[, n_intake := compute_nitrogen_intake(
      dmi = dmi,
      diet_nitrogen = diet_nitrogen
    ), by = .I]
  }

  if (all(c("Animal_short", "cohort", "milk_protein", "milk_yield", "dwg", "fibre_prod", "litsize", "parturition_rate", "wkg", "ckg", "afc") %in% names(data))) {
    data[, n_retention := compute_nitrogen_retention(
      animal = Animal_short,
      cohort = cohort,
      milk_protein = milk_protein,
      milk_yield = milk_yield,
      dwg = dwg,
      fibre_prod = fibre_prod,
      litsize = litsize,
      parturition_rate = parturition_rate,
      wkg = wkg,
      ckg = ckg,
      afc = afc
    ), by = .I]
  }

  if (all(c("Animal_short", "n_intake", "n_retention") %in% names(data))) {
    data[, n_excretion := compute_nitrogen_excretion(
      animal = Animal_short,
      n_intake = n_intake,
      n_retention = n_retention
    ), by = .I]
  }

  # --- Module 6: Direct Emissions - Manure ------------------------------------
  # Directly call 9 scientific functions (skip calc_methane_conversion_factor,
  # calc_nitrogen_volatilization_fraction, calc_nitrogen_leaching_fraction)
  # Parameters (MCF, EF3, EF4, EF5, fracgas, fracleach, B0) should be in input

  # 1. Volatile Solids
  if (all(c("Animal_short", "LPS_short", "dmi", "diet_dig", "diet_me", "diet_ge", "ipcc_method") %in% names(data))) {
    data[, vs := calc_volatile_solids(
      animal = Animal_short,
      dmi = dmi,
      diet_dig = diet_dig,
      diet_me = diet_me,
      diet_ge = diet_ge
    ), by = .I]
  }

  # 2. CH4 emissions from manure
  # MCF values should be provided in input (mcf_pasture, mcf_burned, mcf_other)
  # B0 values should be provided in input (b0_mms_all, b0_mms_pasture)
  if (all(c("vs", "mcf_pasture", "mcf_burned", "mcf_other", "b0_mms_all", "b0_mms_pasture") %in% names(data))) {
    ch4_result <- data[, calc_ch4_emissions(
      vs = vs,
      mcf_pasture = mcf_pasture,
      mcf_burned = mcf_burned,
      mcf_other = mcf_other,
      b0_mms_all = b0_mms_all,
      b0_mms_pasture = b0_mms_pasture
    ), by = .I]

    data[, ch4_manure_pasture := ch4_result$ch4_manure_pasture]
    data[, ch4_manure_burned := ch4_result$ch4_manure_burned]
    data[, ch4_manure_other := ch4_result$ch4_manure_other]
    data[, ch4_manure_all_noburn := ch4_result$ch4_manure_all_noburn]
  }

  # 3. Direct N2O emissions from manure
  # EF3 values should be provided in input (ef3_pasture, ef3_burned, ef3_other)
  if (all(c("n_excretion", "ef3_pasture", "ef3_burned", "ef3_other") %in% names(data))) {
    direct_n2o_result <- data[, calc_direct_n2o_emissions(
      n_excretion = n_excretion,
      ef3_pasture = ef3_pasture,
      ef3_burned = ef3_burned,
      ef3_other = ef3_other
    ), by = .I]

    data[, direct_n2o_manure_pasture := direct_n2o_result$direct_n2o_manure_pasture]
    data[, direct_n2o_manure_burned := direct_n2o_result$direct_n2o_manure_burned]
    data[, direct_n2o_manure_other := direct_n2o_result$direct_n2o_manure_other]
    data[, direct_n2o_manure_all_noburn := direct_n2o_result$direct_n2o_manure_all_noburn]
  }

  # 4. Nitrogen volatilization
  # fracgas values should be provided in input (fracgas_pasture, fracgas_burned, fracgas_other)
  if (all(c("n_excretion", "fracgas_pasture", "fracgas_burned", "fracgas_other") %in% names(data))) {
    n_vol_result <- data[, calc_nitrogen_volatilization(
      n_excretion = n_excretion,
      fracgas_pasture = fracgas_pasture,
      fracgas_burned = fracgas_burned,
      fracgas_other = fracgas_other
    ), by = .I]

    data[, n_vol_manure_pasture := n_vol_result$n_vol_manure_pasture]
    data[, n_vol_manure_burned := n_vol_result$n_vol_manure_burned]
    data[, n_vol_manure_other := n_vol_result$n_vol_manure_other]
    data[, n_vol_manure_all_noburn := n_vol_result$n_vol_manure_all_noburn]
  }

  # 5. N2O from volatilization
  # EF4 should be provided in input
  if (all(c("n_vol_manure_pasture", "n_vol_manure_burned", "n_vol_manure_other", "ef4") %in% names(data))) {
    n2o_vol_result <- data[, calc_n2o_from_volatilization(
      n_vol_pasture = n_vol_manure_pasture,
      n_vol_burned = n_vol_manure_burned,
      n_vol_other = n_vol_manure_other,
      ef4 = ef4
    ), by = .I]

    data[, n2o_vol_manure_pasture := n2o_vol_result$n2o_vol_manure_pasture]
    data[, n2o_vol_manure_burned := n2o_vol_result$n2o_vol_manure_burned]
    data[, n2o_vol_manure_other := n2o_vol_result$n2o_vol_manure_other]
    data[, n2o_vol_manure_all_noburn := n2o_vol_result$n2o_vol_manure_all_noburn]
  }

  # 6. Nitrogen leaching
  # fracleach values should be provided in input (fracleach_pasture, fracleach_burned, fracleach_other)
  if (all(c("n_excretion", "fracleach_pasture", "fracleach_burned", "fracleach_other") %in% names(data))) {
    n_leach_result <- data[, calc_nitrogen_leaching(
      n_excretion = n_excretion,
      fracleach_pasture = fracleach_pasture,
      fracleach_burned = fracleach_burned,
      fracleach_other = fracleach_other
    ), by = .I]

    data[, n_leach_manure_pasture := n_leach_result$n_leach_manure_pasture]
    data[, n_leach_manure_burned := n_leach_result$n_leach_manure_burned]
    data[, n_leach_manure_other := n_leach_result$n_leach_manure_other]
    data[, n_leach_manure_all_noburn := n_leach_result$n_leach_manure_all_noburn]
  }

  # 7. N2O from leaching
  # EF5 should be provided in input
  if (all(c("n_leach_manure_pasture", "n_leach_manure_burned", "n_leach_manure_other", "ef5") %in% names(data))) {
    n2o_leach_result <- data[, calc_n2o_from_leaching(
      n_leach_pasture = n_leach_manure_pasture,
      n_leach_burned = n_leach_manure_burned,
      n_leach_other = n_leach_manure_other,
      ef5 = ef5
    ), by = .I]

    data[, n2o_leach_manure_pasture := n2o_leach_result$n2o_leach_manure_pasture]
    data[, n2o_leach_manure_burned := n2o_leach_result$n2o_leach_manure_burned]
    data[, n2o_leach_manure_other := n2o_leach_result$n2o_leach_manure_other]
    data[, n2o_leach_manure_all_noburn := n2o_leach_result$n2o_leach_manure_all_noburn]
  }

  # 8. Total N2O emissions
  if (all(c("direct_n2o_manure_pasture", "direct_n2o_manure_burned", "direct_n2o_manure_other",
            "n2o_vol_manure_pasture", "n2o_vol_manure_burned", "n2o_vol_manure_other",
            "n2o_leach_manure_pasture", "n2o_leach_manure_burned", "n2o_leach_manure_other") %in% names(data))) {
    total_n2o_result <- data[, calc_total_n2o_emissions(
      direct = list(
        direct_n2o_manure_pasture = direct_n2o_manure_pasture,
        direct_n2o_manure_burned = direct_n2o_manure_burned,
        direct_n2o_manure_other = direct_n2o_manure_other
      ),
      vol = list(
        n2o_vol_manure_pasture = n2o_vol_manure_pasture,
        n2o_vol_manure_burned = n2o_vol_manure_burned,
        n2o_vol_manure_other = n2o_vol_manure_other
      ),
      leach = list(
        n2o_leach_manure_pasture = n2o_leach_manure_pasture,
        n2o_leach_manure_burned = n2o_leach_manure_burned,
        n2o_leach_manure_other = n2o_leach_manure_other
      )
    ), by = .I]

    data[, indirect_n2o_manure_burned := total_n2o_result$indirect_n2o_manure_burned]
    data[, indirect_n2o_manure_pasture := total_n2o_result$indirect_n2o_manure_pasture]
    data[, indirect_n2o_manure_other := total_n2o_result$indirect_n2o_manure_other]
    data[, total_n2o_manure_burned := total_n2o_result$total_n2o_manure_burned]
    data[, total_n2o_manure_pasture := total_n2o_result$total_n2o_manure_pasture]
    data[, total_n2o_manure_other := total_n2o_result$total_n2o_manure_other]
  }

  # --- Module 7: Production ---------------------------------------------------

  # Milk production outputs
  if (all(c(
    "milk_yield", "size", "milking_fraction", "milk_protein", "milk_fat", "lactose"
  ) %in% names(data))) {
    milk_output_cols <- c(
      "output_milk_mass_production",
      "output_milk_protein_production",
      "output_milk_fpcm_production"
    )
    data[, (milk_output_cols) := compute_milk_outputs(
      milk_yield = milk_yield,
      assessment_duration = assessment_duration,
      size = size,
      milking_fraction = milking_fraction,
      milk_protein = milk_protein,
      milk_fat = milk_fat,
      lactose = lactose,
      standard_protein = 0.033,
      standard_fat = 0.04,
      standard_lactose = 0.048
    ), by = .I]
  }

  # Fibre production
  if (all(c("fibre_prod", "size") %in% names(data))) {
    data[, output_fibre_production := compute_fibre_output(
      fibre_prod = fibre_prod,
      assessment_duration = assessment_duration,
      size = size
    ), by = .I]
  }

  # Meat production outputs
  if (all(c("offtake_number", "slaughter_weight", "carcass_dressing_percentage",
            "bone_free_meat_fraction", "meat_protein") %in% names(data))) {
    meat_output_cols <- c(
      "output_meat_production_liveweight",
      "output_meat_production_carcassweight",
      "output_meat_production_meat",
      "output_meat_production_protein"
    )
    data[, (meat_output_cols) := compute_meat_outputs(
      offtake_number = offtake_number,
      slaughter_weight = slaughter_weight,
      carcass_dressing_percentage = carcass_dressing_percentage,
      bone_free_meat_fraction = bone_free_meat_fraction,
      meat_protein = meat_protein
    ), by = .I]
  }

  # Clean up temporary lactose column
  if ("lactose" %in% names(data)) {
    data[, lactose := NULL]
  }

  # --- Module 8: Allocation ---------------------------------------------------
  # Calculate cohort-level energy allocations
  if (all(c("output_milk_fpcm_production") %in% names(data))) {
    data[, energy_allocation_milk := calc_energy_allocation_milk(
      milk_fpcm_output = output_milk_fpcm_production,
      standard_protein = 0.033,
      standard_fat = 0.04,
      standard_lactose = 0.048
    ), by = .I]
  }

  if (all(c("Animal_short", "cohort", "slaughter_weight", "ckg", "output_meat_production_liveweight") %in% names(data))) {
    data[, energy_allocation_meat := calc_energy_allocation_meat(
      animal = Animal_short,
      cohort_code = cohort,
      slaughter_liveweight = slaughter_weight,
      birth_liveweight = ckg,
      meat_output_liveweight = output_meat_production_liveweight
    ), by = .I]
  }

  if (all(c("Animal_short", "nefibre") %in% names(data))) {
    data[, energy_allocation_fibre := calc_energy_allocation_fibre(
      animal = Animal_short,
      fibre_energy_requirement = nefibre,
      ratio_ne_to_me = 0.43,  # ratio_ne_me_camelids default
      assessment_duration = assessment_duration
    ), by = .I]
  }

  if (all(c("Animal_short", "nework") %in% names(data))) {
    data[, energy_allocation_work := calc_energy_allocation_work(
      animal = Animal_short,
      work_energy_requirement = nework,
      ratio_ne_to_me = 0.43,  # ratio_ne_me_camelids default
      assessment_duration = assessment_duration
    ), by = .I]
  }

  data[, energy_allocation_eggs := 0]

  # Aggregate from cohort to herd level
  if (all(c("energy_allocation_meat", "energy_allocation_milk", "energy_allocation_fibre",
            "energy_allocation_work", "energy_allocation_eggs") %in% names(data))) {
    allocation_herd <- aggregate_cohort_to_herd(
      data_cohort = data,
      id_cols = c("herd_id", "Animal_short", "LPS_short"),
      vars_to_sum = c("energy_allocation_meat",
                      "energy_allocation_milk",
                      "energy_allocation_fibre",
                      "energy_allocation_work",
                      "energy_allocation_eggs"),
      cohort = "cohort"
    )

    # Calculate allocation shares
    allocation_herd[, c("allocation_share_meat",
                        "allocation_share_milk",
                        "allocation_share_fibre",
                        "allocation_share_work",
                        "allocation_share_eggs") :=
                      calc_allocation_shares(
                        animal = Animal_short,
                        energy_allocation_meat = energy_allocation_meat,
                        energy_allocation_milk = energy_allocation_milk,
                        energy_allocation_fibre = energy_allocation_fibre,
                        energy_allocation_work = energy_allocation_work,
                        energy_allocation_eggs = energy_allocation_eggs
                      ),
                    by = .I]

    allocation_herd[, allocation_share_other := NA_real_]

    # Reshape to long format
    allocation_herd_long <- data.table::melt(
      allocation_herd,
      id.vars = c("herd_id", "Animal_short", "LPS_short"),
      measure.vars = c("allocation_share_meat",
                       "allocation_share_milk",
                       "allocation_share_fibre",
                       "allocation_share_work",
                       "allocation_share_eggs",
                       "allocation_share_other"),
      variable.name = "commodity_name",
      value.name = "allocation_share"
    )

    # Rename commodity columns
    rename_map <- c(
      allocation_share_meat = "Meat",
      allocation_share_milk = "Milk",
      allocation_share_fibre = "Fibre",
      allocation_share_work = "Work",
      allocation_share_eggs = "Eggs",
      allocation_share_other = "Other"
    )
    allocation_herd_long[, commodity_name := rename_map[commodity_name]]

    # Add commodity_type
    allocation_herd_long[commodity_name %in% c("Meat", "Milk", "Eggs"), commodity_type := "Edible"]
    allocation_herd_long[commodity_name %in% c("Work", "Fibre", "Other"), commodity_type := "Non-Edible"]

    # Assign allocation to emissions
    allocation_herd_long <- assign_allocation_to_emissions(
      allocation_herd_long = allocation_herd_long,
      emissions_vars = c(
        "ch4_enteric", "ch4_manure_pasture", "ch4_manure_burned", "ch4_manure_other",
        "direct_n2o_manure_pasture", "direct_n2o_manure_burned", "direct_n2o_manure_other",
        "indirect_n2o_manure_burned", "indirect_n2o_manure_pasture", "indirect_n2o_manure_other"
      ),
      commodities = c("Other", "Milk", "Meat", "Fibre", "Work", "Eggs"),
      excluded_vars = c(
        "ch4_manure_pasture", "ch4_manure_burned",
        "direct_n2o_manure_pasture", "direct_n2o_manure_burned",
        "indirect_n2o_manure_burned", "indirect_n2o_manure_pasture"
      ),
      commodity_col = "commodity_name",
      allocation_col = "allocation_share"
    )

    allocation_herd_long[, allocation_type := allocation_type]
  } else {
    # If allocation inputs are missing, create empty allocation table
    allocation_herd_long <- data.table::data.table()
  }

  # --- Module 9: Aggregation (Wrap-up) ----------------------------------------
  if (nrow(allocation_herd_long) > 0 && nrow(data) > 0) {
    aggregation_result <- run_aggregation(
      data_cohort = data,
      allocation_herd_long = allocation_herd_long,
      gwp = gwp
    )

    return(
      list(
        data_cohort = aggregation_result$data_cohort,
        results_herd = aggregation_result$results_herd
      )
    )
  } else {
    # Return cohort data only if allocation/aggregation cannot be performed
    return(
      list(
        data_cohort = data,
        results_herd = data.table::data.table()
      )
    )
  }
}
