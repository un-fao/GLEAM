# Run from the package root: Rscript data-raw/generate_module_examples.R
# Rebuild standalone module inputs from the mixed full-pipeline example.
# Derived values come from run_gleam(); herd-only workflow choices are set below.

local({
  pkgload::load_all(".", quiet = TRUE)
  library(data.table)

  source_path <- "inst/extdata/run_gleam_examples"
  output_path <- "inst/extdata/run_modules_examples"
  read_master <- function(file) fread(file.path(source_path, file))
  cohort <- read_master("master_chrt_lvl_no_structure_mixed_data.csv")
  herd <- read_master("master_hrd_lvl_mixed_data.csv")
  rations <- read_master("feed_rations_share_chrt.csv")
  feeds <- read_master("feed_quality.csv")
  feed_emissions <- read_master("feed_emission_factors.csv")
  manure_fractions <- read_master("manure_management_system_fraction.csv")
  manure_factors <- read_master("manure_management_system_factors.csv")

  pipeline <- run_gleam(
    has_herd_structure = FALSE,
    run_demographic = TRUE,
    run_nondemographic = TRUE,
    cohort_level_data = cohort,
    herd_level_data = herd,
    feed_rations = rations,
    feed_params = feeds,
    feed_emissions = feed_emissions,
    manure_management_system_fraction = manure_fractions,
    manure_management_system_factors = manure_factors,
    simulation_duration = 365,
    global_warming_potential_set = "AR6",
    show_indicator = FALSE
  )
  calculated_cohort <- pipeline$cohort_level_results
  calculated_herd <- pipeline$herd_level_results

  phase <- "nondemo_productive_phase_id"
  cohort_keys <- c("herd_id", "cohort_short", phase)
  herd_keys <- c("herd_id", "species_short")
  phase_durations <- c(
    "phase1_nondemo_fem_duration_days", "phase2_nondemo_fem_duration_days",
    "phase1_nondemo_mal_duration_days", "phase2_nondemo_mal_duration_days"
  )
  demo_cohort_cols <- c(
    "herd_id", "cohort_short", "cohort_duration_days", "offtake_rate", "death_rate"
  )
  demo_herd_cols <- c(
    "herd_id", "reproductive_rate", "offspring_per_reproductive_event", "birth_fraction_female",
    "herd_size_total", "prop_nondemo_fem_juv", "prop_nondemo_mal_juv"
  )
  milk_standard_cols <- c(
    "milk_protein_fraction_standard", "milk_fat_fraction_standard",
    "milk_lactose_fraction_standard"
  )
  egg_cols <- c("egg_human_consumption_yield", "egg_average_weight")
  examples <- list()
  add_input <- function(file, data, columns) {
    examples[[paste0(file, ".csv")]] <<- data[, unique(columns), with = FALSE]
  }

  # Herd inputs are direct master subsets. Non-demographic annual entrants
  # come from juvenile diversion in the same mixed simulation.
  demographic <- cohort[!cohort_short %in% c("FN", "MN")]
  nondemographic <- cohort[cohort_short %in% c("FN", "MN")]
  add_input("herd_simulation_input_chrt_data", demographic, demo_cohort_cols)
  add_input("herd_simulation_input_hrd_data", herd, demo_herd_cols)
  add_input("herd_all_input_chrt_data", cohort, c(cohort_keys, demo_cohort_cols))
  add_input("herd_all_input_hrd_data", herd, c(
    demo_herd_cols, "rest_between_nondemo_cycles_duration", phase_durations
  ))
  add_input("nondemographic_herd_input_chrt_data", nondemographic, c(
    cohort_keys, "death_rate"
  ))
  add_input("nondemographic_herd_input_hrd_data",
    calculated_herd[herd_id %in% nondemographic$herd_id], c(
      "herd_id", "cohort_stock_fem_annual_nondemo", "cohort_stock_mal_annual_nondemo",
      "rest_between_nondemo_cycles_duration", phase_durations
    ))

  # The combined herd module also demonstrates the standalone CHK workflow
  # and a demographic-only workflow with juvenile diversion disabled.
  nondemo_only_cohort <- read_master("master_chrt_lvl_no_structure_nondemo_data.csv")
  nondemo_only_herd <- read_master("master_hrd_lvl_nondemo_data.csv")
  add_input("herd_all_nondemo_input_chrt_data", nondemo_only_cohort, c(
    cohort_keys, "death_rate"
  ))
  add_input("herd_all_nondemo_input_hrd_data", nondemo_only_herd, c(
    "herd_id", "cohort_stock_fem_annual_nondemo", "cohort_stock_mal_annual_nondemo",
    "rest_between_nondemo_cycles_duration", phase_durations
  ))
  demo_only_herd <- copy(herd)
  demo_only_herd[, `:=`(prop_nondemo_fem_juv = 0, prop_nondemo_mal_juv = 0)]
  add_input("herd_all_demo_input_chrt_data", demographic, demo_cohort_cols)
  add_input("herd_all_demo_input_hrd_data", demo_only_herd, demo_herd_cols)

  # Weights use simulated durations/offtake rates. In mixed runs, run_gleam()
  # also sets diverted animals' starting weights to the herd weaning weight.
  add_input("weights_input_chrt_data", calculated_cohort, c(
    cohort_keys, "cohort_duration_days", "offtake_rate"
  ))
  add_input("weights_input_hrd_data", calculated_herd, c(
    herd_keys, "live_weight_female_adult", "live_weight_male_adult",
    "live_weight_at_birth", "live_weight_at_weaning",
    "live_weight_female_at_slaughter", "live_weight_male_at_slaughter",
    "live_weight_female_nondemographic_start", "live_weight_male_nondemographic_start",
    "live_weight_female_nondemographic_end", "live_weight_male_nondemographic_end",
    phase_durations
  ))

  # Shared ration inputs serve quality and feed-emission calculations.
  add_input("feed_rations_share_chrt", rations, c(
    cohort_keys, "species_short", "feed_id", "feed_name", "feed_ration_fraction"
  ))
  add_input("feed_quality", feeds[feed_id %in% rations$feed_id], c(
    "feed_id", "feed_gross_energy", "feed_digestible_energy_ruminant",
    "feed_digestible_energy_pigs", "feed_metabolizable_energy_ruminant",
    "feed_metabolizable_energy_pigs", "feed_metabolizable_energy_chicken",
    "feed_nitrogen_content", "feed_urinary_energy_ruminant",
    "feed_urinary_energy_pigs", "feed_ash"
  ))
  add_input("feed_emission_factors", feed_emissions[feed_id %in% rations$feed_id], c(
    "feed_id", "co2_feed_fertilizer", "co2_feed_pesticides",
    "co2_feed_crop_activities", "co2_feed_luc_nopeat", "co2_feed_luc_peat",
    "n2o_feed_fertilizer", "n2o_feed_manure_applied", "n2o_feed_crop_residues",
    "ch4_feed_rice"
  ))

  add_input("metabolic_energy_req_input_chrt_data", calculated_cohort, c(
    cohort_keys, "live_weight_cohort_average", "offtake_rate",
    "low_activity_fraction", "high_activity_fraction", "live_weight_cohort_initial",
    "live_weight_cohort_final", "live_weight_mature_stage", "daily_weight_gain",
    "cohort_duration_days", "ration_digestibility_fraction", "ration_gross_energy",
    "ration_metabolizable_energy", "is_egg_producing"
  ))
  add_input("metabolic_energy_req_input_hrd_data", herd, c(
    herd_keys, "age_first_parturition", "lactating_females_fraction",
    "milk_yield_day", "milk_fat_fraction", "non_productive_duration",
    "pregnancy_duration", "offspring_per_reproductive_event", "death_rate_juvenile",
    "live_weight_at_birth", "live_weight_at_weaning", "lactation_duration",
    "reproductive_rate", "draught_work_hours_female", "draught_work_hours_male",
    "draught_fraction_female", "draught_fraction_male", "fibre_yield_year",
    "average_annual_temperature", egg_cols
  ))
  add_input("emissions_enteric_input_chrt_data", calculated_cohort, c(
    cohort_keys, "species_short", "ration_digestibility_fraction",
    "ration_gross_energy", "ration_intake"
  ))
  add_input("nitrogen_balance_input_chrt_data", calculated_cohort, c(
    cohort_keys, "ration_intake", "ration_nitrogen", "daily_weight_gain",
    "cohort_duration_days", "is_egg_producing"
  ))
  add_input("nitrogen_balance_input_hrd_data", herd, c(
    herd_keys, "milk_protein_fraction", "milk_yield_day", "fibre_yield_year",
    "offspring_per_reproductive_event", "reproductive_rate", "live_weight_at_weaning",
    "live_weight_at_birth", "pregnancy_duration", egg_cols
  ))
  add_input("emissions_manure_input_chrt_data", calculated_cohort, c(
    cohort_keys, "ration_intake", "ration_digestibility_fraction",
    "nitrogen_excretion", "ration_urinary_energy_fraction", "ration_ash"
  ))
  add_input("manure_management_system_fraction", manure_fractions, c(
    cohort_keys, "manure_management_system", "manure_management_system_fraction"
  ))
  add_input("manure_management_system_factors", manure_factors, c(
    "herd_id", "manure_management_system", "methane_conversion_factor_mcf",
    "ch4_max_producing_capacity_bo", "n2o_ef3", "n2o_ef4", "n2o_ef5",
    "nitrogen_fracgas", "nitrogen_fracleach"
  ))
  add_input("production_input_chrt_data", calculated_cohort, c(
    cohort_keys, "cohort_stock_size", "offtake_heads_assessment",
    "live_weight_cohort_at_slaughter", "is_egg_producing"
  ))
  add_input("production_input_hrd_data", herd, c(
    herd_keys, "milk_yield_day", "lactating_females_fraction",
    "milk_protein_fraction", "milk_fat_fraction", "milk_lactose_fraction",
    milk_standard_cols, "fibre_yield_year", "carcass_dressing_fraction",
    "bone_free_meat_fraction", "meat_protein_fraction", egg_cols
  ))
  add_input("allocation_input_chrt_data", calculated_cohort, c(
    cohort_keys, "milk_production_fpcm_cohort", "live_weight_cohort_at_slaughter",
    "meat_production_live_weight_cohort", "metabolic_energy_req_fibre_production",
    "cohort_stock_size", "metabolic_energy_req_work", "egg_production_mass_cohort",
    "is_egg_producing"
  ))
  add_input("allocation_input_hrd_data", herd, c(
    herd_keys, "live_weight_at_birth", milk_standard_cols, "ratio_me_to_ne"
  ))

  ns <- asNamespace("gleam")
  aggregation_vars <- unique(c(
    vapply(get("gleam_feed_meta", ns), `[[`, character(1), "feed_source"),
    vapply(get("gleam_nitrogen_balance_meta", ns), `[[`, character(1), "nitrogen_balance_source"),
    vapply(get("gleam_production_meta", ns), `[[`, character(1), "production_source"),
    vapply(get("gleam_emissions_meta", ns), `[[`, character(1), "emissions_source")
  ))
  aggregation_cohort <- copy(calculated_cohort)
  aggregation_cohort[, (aggregation_vars) := lapply(.SD, as.numeric),
    .SDcols = aggregation_vars]
  add_input("aggregation_input_chrt_data", aggregation_cohort, c(
    cohort_keys, "species_short", "cohort_stock_size", "ration_intake", aggregation_vars
  ))
  add_input("aggregation_allocation_input_data", pipeline$allocation_long, c(
    herd_keys, "variable_name", "commodity_name", "commodity_type", "allocation_share"
  ))

  # Keep the existing tab-separated format and enough precision for derived data.
  for (file in names(examples)) {
    fwrite(examples[[file]], file.path(output_path, file), sep = "\t",
      na = "NA", forceDecimal = TRUE)
  }
  message("Updated ", length(examples), " module example files from the full-pipeline masters.")
})
