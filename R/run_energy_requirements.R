#' Run Energy Requirements and Dry Matter Intake Calculation
#'
#' Computes cohort-level daily energy requirements (MJ/head/day) and feed dry matter intake (kg DM/head/day)
#' by applying the IPCC Tier 2 energy partitioning functions.
#'
#'
#' @param cohort_level_data data.table. Cohort-level input table with the following data requirement:
#'   \describe{
#'     \item{herd_id}{Character. Unique identifier for the herd, repeated for each cohort belonging to the same herd.}
#'     \item{cohort_short}{Character. Sex- and age-specific cohort code describing the production stage of the animals. Supported values include:
#'       \itemize{
#'         \item \code{FA}: adult females (from age at first parturition)
#'         \item \code{FS}: sub-adult females (from weaning to age at first parturition)
#'         \item \code{FJ}: juvenile females (from birth to weaning)
#'         \item \code{MA}: adult males (from age at first breeding)
#'         \item \code{MS}: sub-adult males (from weaning to age at first breeding)
#'         \item \code{MJ}: juvenile males (from birth to weaning)
#'       }}
#'     \item{live_weight_cohort_average}{Numeric. Average live weight over the cohort stage. Computed by accounting for the share of offtaken animals within the cohort, using their slaughter weight, and the potential final weight of animals that remain in the cohort (kg).}
#'     \item{offtake_rate}{Numeric. Annual proportion of animals removed from the herd for each sex-age cohort (fraction).}
#'     \item{low_activity_fraction}{Numeric. Proportion of the assessment period during which the animal performs low-intensity movement typical of stall-feeding or near-field grazing, characterized by minimal walking distances and flat terrain  (fraction).}
#'     \item{high_activity_fraction}{Numeric. Proportion of the assessment period during which the animal engages in sustained locomotion associated with herding or long-distance grazing, typically involving extended walking distances and/or uneven or hilly terrain (fraction).}
#'     \item{live_weight_cohort_initial}{Numeric. Live weight at the beginning of the cohort stage (kg).}
#'     \item{live_weight_cohort_final}{Numeric. Live weight at the end of the cohort stage, accounting for both surviving and offtaken animals. Computed as a weighted average of the potential final weight of surviving animals and the slaughter weight of offtaken animals, based on the offtake rate (kg).}
#'     \item{mature_weight}{Numeric. Mature (adult) live weight that the animal can attain under given biological and management conditions (kg).}
#'     \item{daily_weight_gain}{Numeric. Average live weight gain of the cohort over the cohort stage (kg/head/day).}
#'     \item{cohort_duration_days}{Numeric. Amount of time that each animal spends in a specific cohort (days).}
#'     \item{diet_digestibility_fraction}{Numeric. Average digestibility of the the feed ration, expressed as ratio of digestible to gross energy content (fraction).}
#'     \item{diet_gross_energy}{Numeric. Average gross energy content of the diet (MJ/kg DM).}
#'     \item{diet_metabolizable_energy}{Numeric. Average metabolizable energy content of the diet (MJ/kg DM).}
#'   }
#'
#' @param herd_level_data data.table. Herd-level input table (one row per \code{herd_id}) with the following data requirement:
#'   \describe{
#'     \item{herd_id}{Character. Unique identifier for the herd, repeated for each cohort belonging to the same herd.}
#'     \item{animal}{Character. Livestock category name used to map to a species short code via an
#'     internal lookup table. Supported values include:
#'     \itemize{
#'     \item \code{Cattle}
#'     \item \code{Buffalo}
#'     \item \code{Sheep}
#'     \item \code{Goats}
#'     \item \code{Chicken}
#'     \item \code{Pigs}
#'     \item \code{Camels}
#'     }}
#'     \item{age_first_parturition}{Numeric. Age at first parturition for female breeding animals (days).}
#'     \item{lactating_females_fraction}{Numeric. Proportion of adult females that are lactating during the assessment period (fraction). Required only for species = CML, CTL, BFL, SHP, and GTS.}
#'     \item{milk_yield_day}{Numeric.  Average milk yield per milk-producing animal during the assessment duration (kg/head/day). This value is calculated as the total quantity of milk produced for human consumption by milk-producing animals during the assessment period, divided by the number of milk-producing animals, and the length of the assessment period (days). Required only for species = CML, CTL, BFL, SHP, and GTS.}
#'     \item{milk_fat_fraction}{Numeric. Milk fat fraction (kg fat / kg milk). Required only for species = CML, CTL, BFL, SHP, and GTS.}
#'     \item{non_productive_duration}{Numeric. Period during which the animal is not performing any productive physiological function such as pregnancy or lactation (days). Required only for PGS.}
#'     \item{pregnancy_duration}{Numeric. Duration of pregnancy period (days).}
#'     \item{litter_size}{Numeric. Average number of offspring born per parturition (# offsprings/parturition). This value can be calculated as the total number of offspring born divided by the total number of parturitions during the year.}
#'     \item{death_rate_juvenile}{Numeric. Fraction of deaths in a herd over a year for juvenile cohorts (i.e. FJ and MJ), (fraction).}
#'     \item{birth_weight}{Numeric. Live weight of the animal at birth (kg).}
#'     \item{weaning_weight}{Numeric. Live weight of the animal at weaning (kg).}
#'     \item{lactation_duration}{Numeric. Duration of the lactation period, defined as the number of days during which the animal is lactating (days). Required only for PGS.}
#'     \item{parturition_rate}{Numeric. Average annual number of parturitions per female animal (# parturitions/adult female/year). A herd-level reproductive performance 
#'     indicator calculated as the total number of parturitions (deliveries) occurring during a year divided by the number of adult females potentially able to give birth during that year.}
#'     \item{draught_work_hours_female}{Numeric. Average daily working time per adult female (hours/head/day). Required only for species = CML, CTL, and BFL.}
#'     \item{draught_work_hours_male}{Numeric. Average daily working time per adult male (hours/head/day). Required only for species = CML, CTL, and BFL.}
#'     \item{draught_fraction_female}{Numeric. Fraction of adult females involved in draught work (fraction). Required only for species = CML, CTL, and BFL.}
#'     \item{draught_fraction_male}{Numeric. Fraction of adult males involved in draught work (fraction). Required only for species = CML, CTL, and BFL.}
#'     \item{fibre_yield_year}{Numeric. Annual production yield of fibre, such as wool, cashmere, mohair (kg/head/year). Required only for species = CML, SHP, and GTS.}
#'   }
#'     
#'   
#' @param show_indicator Logical. Whether to display progress indicators during simulation.
#'   Defaults to `TRUE`.
#'
#' @return A `data.table` with the original cohort-level input columns plus the following new variables:
#'   \describe{
#'     \item{energy_requirement_maintenance}{Numeric. Energy required for maintenance, defined as the amount of energy needed to keep the animal at equilibrium such that body energy is neither gained nor lost. 
#'     Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS (MJ/head/day).}
#'     \item{energy_requirement_activity}{Numeric. Energy required for activity, defined as the amount of energy needed to support animal movement and physical activity (MJ/head/day). 
#'     Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS.}
#'     \item{energy_requirement_growth}{Numeric. Energy required for growth (i.e., weight gain) (MJ/head/day). Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS.}
#'     \item{energy_requirement_lactation}{Numeric. Energy required for lactation (MJ/head/day). Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS.}
#'     \item{energy_requirement_work}{Numeric. Energy required for work, used to estimate the energy required for draught power for CTL, BFL and CML (MJ/head/day).
#'     Assumed to be 0 for other species. Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS.}
#'     \item{energy_requirement_fibre_production}{Numeric. Energy required for the synthesis of fibre for SHP, GTS and CML. 
#'     Assumed to be 0 for other species. (MJ/head/day).  Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS (MJ/head/day).}
#'     \item{energy_requirement_pregnancy}{Numeric. Energy required for pregnancy for pregnant females (MJ/head/day). 
#'     Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS.}
#'     \item{net_energy_maintenance_digestible_energy_ratio}{Numeric. Ratio of net energy available for maintenance in the diet to digestible energy consumed (fraction).}
#'     \item{net_energy_growth_digestible_energy_ratio}{Numeric. Ratio of net energy available for growth in the diet to digestible energy consumed (fraction).}
#'     \item{energy_requirement_total}{Numeric. Total daily energy requirement (MJ/head/day). For CTL, BFL, SHP and GTS this is expressed as gross energy intake requirement (GE). 
#'     For CML and PGS the function returns the summed daily metabolizable energy requirement.}
#'     \item{dry_matter_intake}{Numeric. Average daily dry matter intake of feed (kg DM/head/day).}
#'   }
#' 
#' 
#' @details
#' This function joins \code{cohort_level_data} with \code{herd_level_data} by \code{herd_id},
#' maps \code{animal} to a species short code (\code{species_short}) via \code{abbr_animals},
#' and computes IPCC Tier 2 energy partition components and derived feed intake metrics by cohort.
#' 
#' Energy requirements are expressed as:
#' \itemize{
#'   \item \strong{Net energy} for:
#'   \itemize{
#'     \item \code{CTL} (cattle)
#'     \item \code{BFL} (buffalo)
#'     \item \code{SHP} (sheep)
#'     \item \code{GTS} (goats)
#'   }
#'   \item \strong{Metabolizable energy} for:
#'   \itemize{
#'     \item \code{CML} (camels)
#'     \item \code{PGS} (pigs)
#'   }
#' }
#'
#' The following calculation sequence is applied:
#' \enumerate{
#'   \item Maintenance energy is computed using \code{\link{calc_net_energy_maintenance}}.
#'   \item Activity energy is computed using \code{\link{calc_net_energy_activity}}.
#'   \item Growth energy is computed using \code{\link{calc_net_energy_growth}}.
#'   \item Lactation energy is computed using \code{\link{calc_net_energy_lactation}}.
#'   \item Work energy is computed using \code{\link{calc_net_energy_work}}.
#'   \item Fibre production energy is computed using \code{\link{calc_net_energy_fibre}}.
#'   \item Pregnancy energy is computed using \code{\link{calc_net_energy_pregnancy}}.
#'   \item Diet net energy ratios are computed using \code{\link{calc_rem_maintenance}} and
#'   \code{\link{calc_reg_growth}} (ruminants only).
#'   \item Total daily energy requirement is computed using
#'   \code{\link{calc_total_energy_requirement}}.
#'   \item Daily dry matter intake is computed using \code{\link{calc_dry_matter_intake}}.
#' }
#'
#' @seealso
#' \code{\link{calc_net_energy_maintenance}},
#' \code{\link{calc_net_energy_activity}},
#' \code{\link{calc_net_energy_growth}},
#' \code{\link{calc_net_energy_lactation}},
#' \code{\link{calc_net_energy_work}},
#' \code{\link{calc_net_energy_fibre}},
#' \code{\link{calc_net_energy_pregnancy}},
#' \code{\link{calc_rem_maintenance}},
#' \code{\link{calc_reg_growth}},
#' \code{\link{calc_total_energy_requirement}},
#' \code{\link{calc_dry_matter_intake}}
#'
#' @examples
#' \dontrun{
#' # Load energy requirements inputs (cohort and herd-level)
#' energy_requirements_chrt_dt <- data.table::fread(system.file(
#'   "extdata/run_modules_examples/energy_requirements_input_chrt_data.csv",
#'   package = "gleam"
#' ))
#' energy_requirements_hrd_dt <- data.table::fread(system.file(
#'   "extdata/run_modules_examples/energy_requirements_input_hrd_data.csv",
#'   package = "gleam"
#' ))
#'
#' # Run energy requirement and DMI calculations
#' energy_results <- run_energy_requirements(
#'   cohort_level_data = energy_requirements_chrt_dt,
#'   herd_level_data = energy_requirements_hrd_dt
#' )
#' }
#'
#' @importFrom data.table := .I
run_energy_requirements <- function(
    cohort_level_data,
    herd_level_data,
    show_indicator = TRUE
) {
  cohort_level_data <- data.table::as.data.table(cohort_level_data)
  herd_level_data <- data.table::as.data.table(herd_level_data)

  # --- Step 1: Validate inputs ------------------------------------------------
  validate_energy_requirements_inputs(cohort_level_data, herd_level_data)

  # Show progress indicator if requested
  if (show_indicator) {
    cli::cli_status("\U1F552 Calculating energy requirements and DMI, please wait\U2026")
  }

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

  # Clear progress indicator if it was shown
  if (show_indicator) {
    cli::cli_status_clear()
    cli::cli_alert_success("Energy requirements calculation complete.")
  }

  return(cohort_level_data)
}
