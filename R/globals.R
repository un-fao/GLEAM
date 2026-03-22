# Global Variable Declarations for R CMD Check
#
# This file declares global variables used throughout the package,
# particularly within `data.table` expressions and other non-standard
# evaluation contexts. These variables are not bound in a standard way,
# which can trigger NOTES during R CMD check such as:
# "no visible binding for global variable ...".
#
# Registering them here using `utils::globalVariables()` prevents these
# spurious NOTES while maintaining code readability and idiomatic use
# of `data.table` syntax.
#
# This is a standard and CRAN-friendly practice for packages using
# dynamic column references or pipelines.

# --- data.table operators and shared identifiers ----------------------------
utils::globalVariables(c(
  ".", ":=", ".I", ".N", ".SD",
  "herd_id", "cohort_short", "species_short",
  "N", "count", "index", "n_unique", "V1"
))

# --- run_demographic_herd_module --------------------------------------------
utils::globalVariables(c(
  "birth_fraction_female", "cohort_duration_days", "death_rate",
  "duration", "duration.FA", "duration.FJ", "duration.FS",
  "duration.MA", "duration.MJ", "duration.MS",
  "fecundity_female", "fecundity_male", "fem_fec",
  "female_birth_fraction", "has_all_cohorts", "herd_size_total",
  "litter_size", "mal_fec", "missing_cohorts",
  "mort_rate.FA", "mort_rate.FJ", "mort_rate.FS",
  "mort_rate.MA", "mort_rate.MJ", "mort_rate.MS",
  "offtake.FA", "offtake.FB", "offtake.FC", "offtake.FJ", "offtake.FS",
  "offtake.MA", "offtake.MB", "offtake.MC", "offtake.MJ", "offtake.MS",
  "offtake_rate",
  "offtake_rate.FA", "offtake_rate.FJ", "offtake_rate.FS",
  "offtake_rate.MA", "offtake_rate.MJ", "offtake_rate.MS",
  "parturition_rate",
  "potential_final_weight",
  "prob_death", "prob_death.FA", "prob_death.FB", "prob_death.FC",
  "prob_death.FJ", "prob_death.FS", "prob_death.MA", "prob_death.MB",
  "prob_death.MC", "prob_death.MJ", "prob_death.MS",
  "prob_growth.FA", "prob_growth.FB", "prob_growth.FC", "prob_growth.FJ",
  "prob_growth.FS", "prob_growth.MA", "prob_growth.MB", "prob_growth.MC",
  "prob_growth.MJ", "prob_growth.MS",
  "prob_offtake.FA", "prob_offtake.FB", "prob_offtake.FC", "prob_offtake.FJ",
  "prob_offtake.FS", "prob_offtake.MA", "prob_offtake.MB", "prob_offtake.MC",
  "prob_offtake.MJ", "prob_offtake.MS",
  "probability_death", "probability_growth",
  "probability_offtake", "probability_survival",
  "cohort_stock_size", "growth_rate_herd",
  "offtake_heads", "offtake_heads_assessment",
  "share.FA", "share.FJ", "share.FS", "share.MA", "share.MJ", "share.MS",
  "size.FA", "size.FJ", "size.FS", "size.MA", "size.MJ", "size.MS",
  "size_avg.FA", "size_avg.FJ", "size_avg.FS",
  "size_avg.MA", "size_avg.MJ", "size_avg.MS",
  "size_end.FA", "size_end.FJ", "size_end.FS",
  "size_end.MA", "size_end.MJ", "size_end.MS",
  "structure.FA", "structure.FB", "structure.FJ", "structure.FS",
  "structure.MA", "structure.MB", "structure.MJ", "structure.MS"
))

# --- run_weights_module -----------------------------------------------------
utils::globalVariables(c(
  "cohort", "cohort_duration_days",
  "daily_weight_gain", "offtake_rate",
  "live_weight_at_birth", "live_weight_at_weaning",
  "live_weight_female_adult", "live_weight_male_adult",
  "live_weight_female_at_slaughter", "live_weight_male_at_slaughter",
  "live_weight_cohort_initial", "live_weight_cohort_potential_final",
  "live_weight_cohort_at_slaughter", "live_weight_cohort_average",
  "live_weight_cohort_final", "live_weight_mature_stage",
  # x.* join prefixes
  "x.live_weight_at_birth", "x.live_weight_at_weaning",
  "x.live_weight_female_adult", "x.live_weight_male_adult",
  "x.live_weight_female_at_slaughter", "x.live_weight_male_at_slaughter"
))

# --- run_ration_quality_module ----------------------------------------------
utils::globalVariables(c(
  "category", "feed_id", "feed_name", "feed_ration_fraction", "feed_ration_sum",
  "feed_ash", "feed_gross_energy",
  "feed_digestible_energy_ruminant", "feed_digestible_energy_pigs",
  "feed_metabolizable_energy_ruminant", "feed_metabolizable_energy_pigs",
  "feed_nitrogen_content",
  "feed_urinary_energy_ruminant", "feed_urinary_energy_pigs",
  "feed_digestibility_fraction_ruminant", "feed_digestibility_fraction_pigs",
  "feed_name_input", "feed_name_params",
  "ration_ash", "ration_digestibility_fraction", "ration_gross_energy",
  "ration_intake", "ration_metabolizable_energy",
  "ration_nitrogen", "ration_urinary_energy_fraction"
))

# --- run_metabolic_energy_req_module ----------------------------------------
utils::globalVariables(c(
  "activity_sum",
  "high_activity_fraction", "low_activity_fraction",
  "live_weight_cohort_average",
  "metabolic_energy_req_activity", "metabolic_energy_req_fibre_production",
  "metabolic_energy_req_growth", "metabolic_energy_req_lactation",
  "metabolic_energy_req_maintenance", "metabolic_energy_req_pregnancy",
  "metabolic_energy_req_total", "metabolic_energy_req_work",
  "net_energy_growth_digestible_energy_ratio",
  "net_energy_maintenance_digestible_energy_ratio",
  # x.* join prefixes from herd_level_data
  "x.age_first_parturition",
  "x.death_rate_juvenile",
  "x.draught_fraction_female", "x.draught_fraction_male",
  "x.draught_work_hours_female", "x.draught_work_hours_male",
  "x.fibre_yield_year",
  "x.lactating_females_fraction", "x.lactation_duration",
  "x.litter_size",
  "x.live_weight_at_birth", "x.live_weight_at_weaning",
  "x.milk_fat_fraction", "x.milk_yield_day",
  "x.non_productive_duration", "x.parturition_rate",
  "x.pregnancy_duration", "x.species_short"
))

# --- run_nitrogen_balance_module --------------------------------------------
utils::globalVariables(c(
  "age_first_parturition",
  "milk_protein_fraction", "milk_yield_day",
  "fibre_yield_year",
  "nitrogen_excretion", "nitrogen_intake", "nitrogen_retention",
  # x.* join prefixes from herd_level_data
  "x.age_first_parturition",
  "x.fibre_yield_year", "x.litter_size",
  "x.live_weight_at_birth", "x.live_weight_at_weaning",
  "x.milk_protein_fraction", "x.milk_yield_day",
  "x.parturition_rate", "x.pregnancy_duration",
  "x.species_short"
))

# --- run_emissions_enteric_module -------------------------------------------
utils::globalVariables(c(
  "ch4_conversion_factor_ym", "ch4_enteric", "ch4_mitigation_factor"
))

# --- run_emissions_manure_module --------------------------------------------
utils::globalVariables(c(
  "dmi", "ef4", "ef5",
  "manure_management_system", "mms_list", "mms_list_fraction", "mms_list_factors",
  "unique_mms_sets", "total_fraction",
  "volatile_solids",
  "n2o_manure_burned_direct", "n2o_manure_burned_leach", "n2o_manure_burned_vol",
  "n2o_manure_other_direct", "n2o_manure_other_leach", "n2o_manure_other_vol",
  "n2o_manure_pasture_direct", "n2o_manure_pasture_leach", "n2o_manure_pasture_vol",
  "mms_all_b0", "mms_all", "mmspasture_b0", "mmspasture",
  "mmsdaily", "mmssolid", "mmssolidcov", "mmssolidbulk", "mmssolidadd", "mmsdrylot",
  "mmspit1", "mmspit3", "mmspit4", "mmspit6", "mmspit12",
  "mmsliquid1", "mmsliquid3", "mmsliquid4", "mmsliquid6", "mmsliquid12",
  "mmsliquidnatcov1", "mmsliquidnatcov3", "mmsliquidnatcov4", "mmsliquidnatcov6", "mmsliquidnatcov12",
  "mmsliquidsolcov1", "mmsliquidsolcov3", "mmsliquidsolcov4", "mmsliquidsolcov6", "mmsliquidsolcov12",
  "mmslagoon", "mmsbiogaslowleak1", "mmsbiogaslowleak2", "mmsbiogaslowleak3",
  "mmsbiogashighleak1", "mmsbiogashighleak2", "mmsbiogashighleak3",
  "mmsburned", "mmsdeepnomix2", "mmsdeepnomix1", "mmsdeepmix2", "mmsdeepmix1",
  "mmscompostves", "mmscompoststat", "mmscompostint", "mmscompostpass",
  "mmslitter", "mmsnolitter", "mmsareobic", "mmsaerproc"
))

# --- run_emissions_ration_module --------------------------------------------
utils::globalVariables(c(
  "ch4_feed_rice", "ch4_ration_rice",
  "co2_feed_crop_activities", "co2_feed_fertilizer",
  "co2_feed_luc_nopeat", "co2_feed_luc_peat", "co2_feed_pesticides",
  "co2_ration_crop_activities", "co2_ration_fertilizer",
  "co2_ration_luc_nopeat", "co2_ration_luc_peat", "co2_ration_pesticides",
  "n2o_feed_crop_residues", "n2o_feed_fertilizer", "n2o_feed_manure_applied",
  "n2o_ration_crop_residues", "n2o_ration_fertilizer", "n2o_ration_manure_applied",
  "feed_name_emissions", "n_ids",
  "..cols_to_show", "..numeric_cols_feed", "..numeric_cols_rations"
))

# --- run_production_module --------------------------------------------------
utils::globalVariables(c(
  "fibre_production_cohort",
  "milk_yield", "milk_yield_day",
  "x.bone_free_meat_fraction", "x.carcass_dressing_fraction",
  "x.fibre_yield_year",
  "x.lactating_females_fraction",
  "x.meat_protein_fraction",
  "x.milk_fat_fraction",
  "x.milk_fat_fraction_standard", "x.milk_lactose_fraction",
  "x.milk_lactose_fraction_standard", "x.milk_protein_fraction",
  "x.milk_protein_fraction_standard", "x.milk_yield_day",
  "x.species_short"
))

# --- run_allocation_module --------------------------------------------------
utils::globalVariables(c(
  "allocation_share", "allocation_share_other", "allocation_herd_long_all",
  "commodity_name", "commodity_type",
  "fibre_allocation_energy",
  "meat_allocation_energy", "meat_production_live_weight_cohort",
  "metabolic_energy_req_fibre_production", "metabolic_energy_req_work",
  "milk_allocation_energy", "milk_production_fpcm_cohort",
  "total_allocation_energy",
  "meat_share_allocation", "milk_share_allocation",
  "work_share_allocation", "fibre_share_allocation",
  "eggs_share_allocation",
  "work_allocation_energy", "egg_allocation_energy",
  "i.species_short",
  "x.live_weight_at_birth", "x.milk_fat_fraction_standard",
  "x.milk_lactose_fraction_standard", "x.milk_protein_fraction_standard",
  "x.ratio_me_to_ne", "x.species_short"
))

# --- run_aggregation_module -------------------------------------------------
utils::globalVariables(c(
  "allocation_share",
  "gas", "gwp_factor",
  "simulation_duration",
  "value", "value_allocated", "value_total",
  "value_total_allocated_gas", "value_total_gas",
  "variable_name", "variable_type",
  "unit"
))

# --- run_soil_carbon_module -------------------------------------------------
utils::globalVariables(c(
  "area", "climate_zone", "dSOC",
  "management_end", "management_start",
  "SOC1", "SOC2",
  "soil_carbon_reference", "soil_type",
  "Item", "GWP", "Unit", "COUNTRY"
))

# --- column-selection helpers (.. prefix) -----------------------------------
utils::globalVariables(c(
  "..cols_to_drop", "..final_cols"
))
