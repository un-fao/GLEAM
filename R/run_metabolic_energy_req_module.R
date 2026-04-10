#' Run Metabolic Energy Requirements and Dry Matter Intake Module Pipeline
#'
#' Calculates cohort-level daily energy requirements (MJ/head/day) and ration dry matter intake (kg DM/head/day)
#' by applying the IPCC Tier 2 energy partitioning functions.
#'
#' @param cohort_level_data data.table. Cohort-level input table with the following data requirement:
#'   \describe{
#'     \item{herd_id}{Character. Unique identifier for the herd, repeated for each cohort belonging to the same herd.}
#'     \item{cohort_short}{Character. Sex- and age-specific cohort code describing the production stage of the animals. Supported values include:
#'       \itemize{
#'         \item \code{FA}: adult females (from age at first parturition)
#'         \item \code{FS}: sub-adult females (from weaning to age at first parturition)
#'         \item \code{FJ}: juvenile females (from birth to weaning)
#'         \item \code{FN}: non-demographic females
#'         \item \code{MA}: adult males (from age at first breeding)
#'         \item \code{MS}: sub-adult males (from weaning to age at first breeding)
#'         \item \code{MJ}: juvenile males (from birth to weaning)
#'         \item \code{MN}: non-demographic males
#'       }}
#'     \item{nondemo_productive_phase_id}{Numeric. Optional productive phase identifier
#'     for non-demographic cohorts (\code{FN}, \code{MN}). When present, energy
#'     requirements are computed and retained separately by phase.}
#'     \item{is_egg_producing}{Logical. Indicates whether the cohort is an egg-producing
#'     chicken cohort. Used only for \code{CHK}; may be \code{TRUE} only for
#'     \code{FA} or for \code{FN} in laying phase 2.}
#'     \item{live_weight_cohort_average}{Numeric. Average live weight over the cohort stage. Computed by accounting for the share of offtaken animals within the cohort, using their slaughter weight, and the potential final weight of animals that remain in the cohort (kg).}
#'     \item{offtake_rate}{Numeric. Annual proportion of animals removed from the herd for each sex-age cohort (fraction).}
#'     \item{low_activity_fraction}{Numeric. Proportion of the assessment period during which the animal performs low-intensity movement typical of stall-feeding or near-field grazing, characterized by minimal walking distances and flat terrain  (fraction).}
#'     \item{high_activity_fraction}{Numeric. Proportion of the assessment period during which the animal engages in sustained locomotion associated with herding or long-distance grazing, typically involving extended walking distances and/or uneven or hilly terrain (fraction).}
#'     \item{live_weight_cohort_initial}{Numeric. Live weight at the beginning of the cohort stage (kg).}
#'     \item{live_weight_cohort_final}{Numeric. Live weight at the end of the cohort stage, accounting for both surviving and offtaken animals. Computed as a weighted average of the potential final weight of surviving animals and the slaughter weight of offtaken animals, based on the offtake rate (kg).}
#'     \item{live_weight_mature_stage}{Numeric. Mature (adult) live weight that the animal can attain under given biological and management conditions (kg).}
#'     \item{daily_weight_gain}{Numeric. Average live weight gain of the cohort over the cohort stage (kg/head/day).}
#'     \item{cohort_duration_days}{Numeric. Amount of time that each animal spends in a specific cohort (days). For \code{CHK}, \code{FJ} and \code{MJ} cohorts can default to 3 days.}
#'     \item{ration_digestibility_fraction}{Numeric. Average digestibility of the feed ration, expressed as ratio of digestible to gross energy content (fraction).}
#'     \item{ration_gross_energy}{Numeric. Average gross energy content of the diet (MJ/kg DM).}
#'     \item{ration_metabolizable_energy}{Numeric. Average metabolizable energy content of the diet (MJ/kg DM).}
#'   }
#'
#' @param herd_level_data data.table. Herd-level input table (one row per \code{herd_id}) with the following data requirement:
#'   \describe{
#'     \item{herd_id}{Character. Unique identifier for the herd, repeated for each cohort belonging to the same herd.}
#'     \item{species_short}{Character. Code identifying the livestock species.
#'         Supported values include:
#'         \itemize{
#'         \item \code{PGS}: pigs
#'         \item \code{CML}: camels
#'         \item \code{CTL}: cattle
#'         \item \code{BFL}: buffalo
#'         \item \code{SHP}: sheep
#'         \item \code{GTS}: goats
#'         \item \code{CHK}: chickens
#'         }}
#'     \item{age_first_parturition}{Numeric. Age at first parturition for female breeding animals (days). The alias \code{age_at_first_offspring} is also accepted.}
#'     \item{lactating_females_fraction}{Numeric. Proportion of adult females that are lactating during the assessment period (fraction). Required only for species = CML, CTL, BFL, SHP, and GTS.}
#'     \item{milk_yield_day}{Numeric.  Average milk yield per milk-producing animal during the assessment duration (kg/head/day). This value is calculated as the total quantity of milk produced for human consumption by milk-producing animals during the assessment period, divided by the number of milk-producing animals, and the length of the assessment period (days). Required only for species = CML, CTL, BFL, SHP, and GTS.}
#'     \item{milk_fat_fraction}{Numeric. Milk fat fraction (kg fat / kg milk). Required only for species = CML, CTL, BFL, SHP, and GTS.}
#'     \item{non_productive_duration}{Numeric. Period during which the animal is not performing any productive physiological function such as pregnancy or lactation (days). Required only for PGS.}
#'     \item{pregnancy_duration}{Numeric. Duration of pregnancy period (days).}
#'     \item{litter_size}{Numeric. Average number of offspring born per parturition (# offspring/parturition). For \code{CHK}, this can be interpreted as offspring produced per reproductive event. The alias \code{offspring_per_reproductive_event} is also accepted.}
#'     \item{death_rate_juvenile}{Numeric. Fraction of deaths in a herd over a year for juvenile cohorts (i.e. FJ and MJ), (fraction).}
#'     \item{live_weight_at_birth}{Numeric. Live weight of the animal at birth (kg).}
#'     \item{live_weight_at_weaning}{Numeric. Live weight of the animal at weaning (kg).}
#'     \item{lactation_duration}{Numeric. Duration of the lactation period, defined as the number of days during which the animal is lactating (days). Required only for PGS.}
#'     \item{parturition_rate}{Numeric. Average annual number of parturitions per female animal (# parturitions/adult female/year). For \code{CHK}, this corresponds to eggs laid for reproduction. The alias \code{reproductive_rate} is also accepted.}
#'     \item{average_annual_temperature}{Numeric. Average annual temperature (degrees C). Used for \code{CHK}.}
#'     \item{egg_average_weight}{Numeric. Average egg weight (kg/egg). Used for \code{CHK}. The alias \code{egg_weight} is also accepted and is converted internally from g/egg to kg/egg.}
#'     \item{egg_output_human_consumption}{Numeric. Number of eggs produced for human consumption in one year by the flock (eggs/year). Used for \code{CHK}.}
#'     \item{draught_work_hours_female}{Numeric. Average daily working time per adult female (hours/head/day). Required only for species = CML, CTL, and BFL.}
#'     \item{draught_work_hours_male}{Numeric. Average daily working time per adult male (hours/head/day). Required only for species = CML, CTL, and BFL.}
#'     \item{draught_fraction_female}{Numeric. Fraction of adult females involved in draught work (fraction). Required only for species = CML, CTL, and BFL.}
#'     \item{draught_fraction_male}{Numeric. Fraction of adult males involved in draught work (fraction). Required only for species = CML, CTL, and BFL.}
#'     \item{fibre_yield_year}{Numeric. Annual production yield of fibre, such as wool, cashmere, mohair (kg/head/year). Required only for species = CML, SHP, and GTS.}
#'   }
#'
#' @param show_indicator Logical. Whether to display progress indicators during simulation.
#'   Defaults to `TRUE`.
#'
#' @return A `data.table` with the original cohort-level input columns plus the following
#'   new variables. If \code{nondemo_productive_phase_id} is present in the input,
#'   the returned table preserves phase-specific rows for \code{FN} and \code{MN}:
#'   \describe{
#'     \item{metabolic_energy_req_maintenance}{Numeric. Energy required for maintenance, defined as the amount of energy needed to keep the animal at equilibrium such that body energy is neither gained nor lost.
#'     Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS (MJ/head/day).}
#'     \item{metabolic_energy_req_activity}{Numeric. Energy required for activity, defined as the amount of energy needed to support animal movement and physical activity (MJ/head/day).
#'     Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS.}
#'     \item{metabolic_energy_req_growth}{Numeric. Energy required for growth (i.e., weight gain) (MJ/head/day). Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS.}
#'     \item{metabolic_energy_req_lactation}{Numeric. Energy required for lactation (MJ/head/day). Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS.}
#'     \item{metabolic_energy_req_work}{Numeric. Energy required for work, used to estimate the energy required for draught power for CTL, BFL and CML (MJ/head/day).
#'     Assumed to be 0 for other species. Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS.}
#'     \item{metabolic_energy_req_fibre_production}{Numeric. Energy required for the synthesis of fibre for SHP, GTS and CML.
#'     Assumed to be 0 for other species. (MJ/head/day).  Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS (MJ/head/day).}
#'     \item{metabolic_energy_req_pregnancy}{Numeric. Energy required for pregnancy for pregnant females (MJ/head/day).
#'     Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS.}
#'     \item{net_energy_maintenance_digestible_energy_ratio}{Numeric. Ratio of net energy available for maintenance in the diet to digestible energy consumed (fraction).}
#'     \item{net_energy_growth_digestible_energy_ratio}{Numeric. Ratio of net energy available for growth in the diet to digestible energy consumed (fraction).}
#'     \item{metabolic_energy_req_total}{Numeric. Total daily energy requirement (MJ/head/day). For CTL, BFL, SHP and GTS this is expressed as gross energy intake requirement (GE).
#'     For CML and PGS the function returns the summed daily metabolizable energy requirement.}
#'     \item{ration_intake}{Numeric. Average daily dry matter intake of feed (kg DM/head/day).}
#'   }
#'
#' @details
#' This function joins \code{cohort_level_data} with \code{herd_level_data} by \code{herd_id},
#' uses \code{species_short} directly for all species-specific energy calculations,
#' and computes IPCC Tier 2 energy partition components and derived feed intake metrics by cohort.
#'
#' Energy requirements are expressed as:
#' \itemize{
#'   \item \strong{Net energy} for CTL, BFL, SHP, GTS.
#'   \item \strong{Metabolizable energy} for CML and PGS. 
#' }
#'
#' This function represents the intermediate module of the Global Livestock Environmental
#' Assessment Model (GLEAM) computational pipeline [run_gleam()] to estimate
#' animals' metabolic energy requirements and dry matter intake and performs the following calculation sequence:
#' \enumerate{
#'   \item Maintenance energy is computed using \code{\link{calc_metabolic_energy_req_maintenance}}.
#'   \item Activity energy is computed using \code{\link{calc_metabolic_energy_req_activity}}.
#'   \item Growth energy is computed using \code{\link{calc_metabolic_energy_req_growth}}.
#'   \item Lactation energy is computed using \code{\link{calc_metabolic_energy_req_lactation}}.
#'   \item Work energy is computed using \code{\link{calc_metabolic_energy_req_work}}.
#'   \item Fibre production energy is computed using \code{\link{calc_metabolic_energy_req_fibre}}.
#'   \item Pregnancy energy is computed using \code{\link{calc_metabolic_energy_req_pregnancy}}.
#'   \item Diet net energy ratios are computed using \code{\link{calc_rem_maintenance}} and
#'   \code{\link{calc_reg_growth}} (ruminants only).
#'   \item Total daily energy requirement is computed using
#'   \code{\link{calc_total_metabolic_energy_req}}.
#'   \item Daily dry matter intake is computed using \code{\link{calc_ration_intake}}.
#' }
#'
#' @seealso
#' \code{\link{run_gleam}},
#' \code{\link{calc_metabolic_energy_req_maintenance}},
#' \code{\link{calc_metabolic_energy_req_activity}},
#' \code{\link{calc_metabolic_energy_req_growth}},
#' \code{\link{calc_metabolic_energy_req_lactation}},
#' \code{\link{calc_metabolic_energy_req_work}},
#' \code{\link{calc_metabolic_energy_req_fibre}},
#' \code{\link{calc_metabolic_energy_req_pregnancy}},
#' \code{\link{calc_rem_maintenance}},
#' \code{\link{calc_reg_growth}},
#' \code{\link{calc_total_metabolic_energy_req}},
#' \code{\link{calc_ration_intake}}
#'
#' @examples
#' \donttest{
#' # Load metabolic energy requirements inputs (cohort and herd-level)
#' metabolic_energy_req_chrt_dt <- data.table::fread(system.file(
#'   "extdata/run_modules_examples/metabolic_energy_req_input_chrt_data.csv",
#'   package = "gleam"
#' ))
#' metabolic_energy_req_hrd_dt <- data.table::fread(system.file(
#'   "extdata/run_modules_examples/metabolic_energy_req_input_hrd_data.csv",
#'   package = "gleam"
#' ))
#'
#' # Run metabolic energy requirement and rations calculations
#' results <- run_metabolic_energy_req_module(
#'   cohort_level_data = metabolic_energy_req_chrt_dt,
#'   herd_level_data = metabolic_energy_req_hrd_dt
#' )
#' }
#'
#' @export
#'
#' @importFrom data.table := .I
run_metabolic_energy_req_module <- function(
    cohort_level_data,
    herd_level_data,
    show_indicator = TRUE
) {
  cohort_level_data <- data.table::as.data.table(cohort_level_data)
  herd_level_data <- data.table::as.data.table(herd_level_data)

  # --- Step 1: Validate inputs ------------------------------------------------
  validate_run_metabolic_energy_req_module_inputs(cohort_level_data, herd_level_data)

  # Show progress indicator if requested
  if (show_indicator) {
    cli::cli_status(
      "\U1F552 Calculating metabolic energy requirements and ration, please wait\U2026"
    )
  }

  # --- Step 2: Create working copies ------------------------------------------
  cohort_level_data <- data.table::copy(cohort_level_data)
  herd_level_data <- data.table::copy(herd_level_data)

  # --- Step 3: Maintenance energy (MJ/day) ------------------------------------
  cohort_level_data[
    ,
    metabolic_energy_req_maintenance := calc_metabolic_energy_req_maintenance(
      species_short = herd_level_data[.SD, on = "herd_id", x.species_short],
      cohort_short = cohort_short,
      live_weight_cohort_average = live_weight_cohort_average,
      nondemo_productive_phase_id = nondemo_productive_phase_id,
      lactating_females_fraction = herd_level_data[.SD, on = "herd_id", x.lactating_females_fraction],
      offtake_rate = offtake_rate,
      age_first_parturition = herd_level_data[.SD, on = "herd_id", x.age_first_parturition],
      average_annual_temperature = herd_level_data[.SD, on = "herd_id", x.average_annual_temperature],
      lower_critical_temperature = ifelse(
        herd_level_data[.SD, on = "herd_id", x.species_short] == "CHK",
        18.89,
        NA_real_
      ),
      is_egg_producing = is_egg_producing
    ),
    by = .I
  ]

  # --- Step 4: Activity energy (MJ/day) ---------------------------------------
  cohort_level_data[
    ,
    metabolic_energy_req_activity := calc_metabolic_energy_req_activity(
      species_short = herd_level_data[.SD, on = "herd_id", x.species_short],
      cohort_short = cohort_short,
      metabolic_energy_req_maintenance = metabolic_energy_req_maintenance,
      live_weight_cohort_average = live_weight_cohort_average,
      low_activity_fraction = low_activity_fraction,
      high_activity_fraction = high_activity_fraction
    ),
    by = .I
  ]

  # --- Step 5: Growth energy (MJ/day) -----------------------------------------
  cohort_level_data[
    ,
    metabolic_energy_req_growth := calc_metabolic_energy_req_growth(
      species_short = herd_level_data[.SD, on = "herd_id", x.species_short],
      cohort_short = cohort_short,
      nondemo_productive_phase_id = nondemo_productive_phase_id,
      live_weight_cohort_average = live_weight_cohort_average,
      live_weight_cohort_final = live_weight_cohort_final,
      live_weight_cohort_initial = live_weight_cohort_initial,
      live_weight_mature_stage = live_weight_mature_stage,
      daily_weight_gain = daily_weight_gain,
      offtake_rate = offtake_rate,
      cohort_duration_days = cohort_duration_days,
      is_egg_producing = is_egg_producing
    ),
    by = .I
  ]

  # --- Step 6: Lactation energy (MJ/day) --------------------------------------
  cohort_level_data[
    ,
    metabolic_energy_req_lactation := calc_metabolic_energy_req_lactation(
      species_short = herd_level_data[.SD, on = "herd_id", x.species_short],
      cohort_short = cohort_short,
      lactating_females_fraction = herd_level_data[.SD, on = "herd_id", x.lactating_females_fraction],
      milk_yield_day = herd_level_data[.SD, on = "herd_id", x.milk_yield_day],
      milk_fat_fraction = herd_level_data[.SD, on = "herd_id", x.milk_fat_fraction],
      non_productive_duration = herd_level_data[.SD, on = "herd_id", x.non_productive_duration],
      pregnancy_duration = herd_level_data[.SD, on = "herd_id", x.pregnancy_duration],
      litter_size = herd_level_data[.SD, on = "herd_id", x.litter_size],
      death_rate_juvenile = herd_level_data[.SD, on = "herd_id", x.death_rate_juvenile],
      live_weight_at_birth = herd_level_data[.SD, on = "herd_id", x.live_weight_at_birth],
      live_weight_at_weaning = herd_level_data[.SD, on = "herd_id", x.live_weight_at_weaning],
      lactation_duration = herd_level_data[.SD, on = "herd_id", x.lactation_duration],
      parturition_rate = herd_level_data[.SD, on = "herd_id", x.parturition_rate]
    ),
    by = .I
  ]

  # --- Step 7: Work energy (MJ/day) ------------------------------------------
  cohort_level_data[
    ,
    metabolic_energy_req_work := calc_metabolic_energy_req_work(
      species_short = herd_level_data[.SD, on = "herd_id", x.species_short],
      cohort_short = cohort_short,
      metabolic_energy_req_maintenance = metabolic_energy_req_maintenance,
      draught_work_hours_female = herd_level_data[.SD, on = "herd_id", x.draught_work_hours_female],
      draught_work_hours_male = herd_level_data[.SD, on = "herd_id", x.draught_work_hours_male],
      draught_fraction_female = herd_level_data[.SD, on = "herd_id", x.draught_fraction_female],
      draught_fraction_male = herd_level_data[.SD, on = "herd_id", x.draught_fraction_male]
    ),
    by = .I
  ]

  # --- Step 8: Fibre production energy (MJ/day) ------------------------------
  cohort_level_data[
    ,
    metabolic_energy_req_fibre_production := calc_metabolic_energy_req_fibre(
      species_short = herd_level_data[.SD, on = "herd_id", x.species_short],
      cohort_short = cohort_short,
      fibre_yield_year = herd_level_data[.SD, on = "herd_id", x.fibre_yield_year]
    ),
    by = .I
  ]

  # --- Step 10: Egg deposition energy (MJ/day) -------------------------------------
  cohort_level_data[
    ,
    metabolic_energy_req_egg_deposition := calc_metabolic_energy_req_eggs(
      species_short = herd_level_data[.SD, on = "herd_id", x.species_short],
      cohort_short = cohort_short,
      cohort_stock_size = cohort_stock_size,
      egg_output_human_consumption = herd_level_data[.SD, on = "herd_id", x.egg_output_human_consumption],
      egg_average_weight = herd_level_data[.SD, on = "herd_id", x.egg_average_weight],
      parturition_rate = herd_level_data[.SD, on = "herd_id", x.parturition_rate],
      nondemo_productive_phase_id = nondemo_productive_phase_id,
      is_egg_producing = is_egg_producing
    ),
    by = .I
  ]

  # --- Step 11: Pregnancy energy (MJ/day) -------------------------------------
  cohort_level_data[
    ,
    metabolic_energy_req_pregnancy := calc_metabolic_energy_req_pregnancy(
      species_short = herd_level_data[.SD, on = "herd_id", x.species_short],
      cohort_short = cohort_short,
      metabolic_energy_req_maintenance = metabolic_energy_req_maintenance,
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

  # --- Step 12: Diet NE fractions ---------------------------------------------
  cohort_level_data[
    ,
    net_energy_maintenance_digestible_energy_ratio := calc_rem_maintenance(
      species_short = herd_level_data[.SD, on = "herd_id", x.species_short],
      ration_digestibility_fraction = ration_digestibility_fraction
    ),
    by = .I
  ]

  cohort_level_data[
    ,
    net_energy_growth_digestible_energy_ratio := calc_reg_growth(
      species_short = herd_level_data[.SD, on = "herd_id", x.species_short],
      ration_digestibility_fraction = ration_digestibility_fraction
    ),
    by = .I
  ]

  # --- Step 13: Total ME requirement (MJ/day) ---------------------------------
  cohort_level_data[
    ,
    metabolic_energy_req_total := calc_total_metabolic_energy_req(
      species_short = herd_level_data[.SD, on = "herd_id", x.species_short],
      metabolic_energy_req_maintenance = metabolic_energy_req_maintenance,
      metabolic_energy_req_activity = metabolic_energy_req_activity,
      metabolic_energy_req_lactation = metabolic_energy_req_lactation,
      metabolic_energy_req_work = metabolic_energy_req_work,
      metabolic_energy_req_pregnancy = metabolic_energy_req_pregnancy,
      net_energy_maintenance_digestible_energy_ratio = net_energy_maintenance_digestible_energy_ratio,
      metabolic_energy_req_growth = metabolic_energy_req_growth,
      metabolic_energy_req_fibre_production = metabolic_energy_req_fibre_production,
      metabolic_energy_req_egg_deposition = metabolic_energy_req_egg_deposition,
      net_energy_growth_digestible_energy_ratio = net_energy_growth_digestible_energy_ratio,
      ration_digestibility_fraction = ration_digestibility_fraction
    ),
    by = .I
  ]

  # --- Step 14: Dry matter intake (kg DM/day) ---------------------------------
  cohort_level_data[
    ,
    ration_intake := calc_ration_intake(
      species_short = herd_level_data[.SD, on = "herd_id", x.species_short],
      metabolic_energy_req_total = metabolic_energy_req_total,
      ration_gross_energy = ration_gross_energy,
      ration_metabolizable_energy = ration_metabolizable_energy
    ),
    by = .I
  ]

  # Clear progress indicator if it was shown
  if (show_indicator) {
    cli::cli_status_clear()
    cli::cli_alert_success("Metabolic energy requirements calculation complete.")
  }

  return(cohort_level_data)
}
