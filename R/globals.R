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
utils::globalVariables(c(
  ".", ":=", ".I", ".N", ".SD", "..cols_to_drop", "..final_cols", "ADM0_CODE", "AFKG", "AMKG", "Animal_short",
  "animal_short", "size",
  "COUNTRY", "HerdType_short", "LPS_short", "MFSKG", "MMSKG", "WA", "afc", "ckg",
  "count", "daily_weight_gain", "duration", "duration.FA", "duration.FJ", "duration.FS",
  "cohort_duration_days", "death_rate",
  "duration.MA", "duration.MJ", "duration.MS", "dwg", "female_birth_fraction", "fem_fec",
  "birth_fraction_female", "litter_size", "herd_size_total",
  "fecundity_female", "fecundity_male",
  "herd_id", "has_all_cohorts", "missing_cohorts", "n_unique", "index", "N",  # Variables used in run_demographic_herd_module
  "prob_growth.FA", "prob_growth.FB", "prob_growth.FC", "prob_growth.FJ", "prob_growth.FS",
  "prob_growth.MA", "prob_growth.MB", "prob_growth.MC", "prob_growth.MJ", "prob_growth.MS",
  "growth_rate_pop", "initial_weight", "litsize", "mal_fec", "mort_rate.FA",
  "mort_rate.FJ", "mort_rate.FS", "mort_rate.MA", "mort_rate.MJ", "mort_rate.MS",
  "offtake.FA", "offtake.FB", "offtake.FC", "offtake.FJ", "offtake.FS", "offtake.MA",
  "offtake.MB", "offtake.MC", "offtake.MJ", "offtake.MS", "offtake_rate",
  "offtake_rate.FA", "offtake_rate.FJ", "offtake_rate.FS", "offtake_rate.MA",
  "offtake_rate.MJ", "offtake_rate.MS", "parturition_rate", "prob_death.FA", "prob_death.FB",
  "prob_death", "prob_death.FJ", "prob_death.FS", "prob_death.MA", "prob_death.MB", "prob_death.MC", "prob_death.MJ",
  "prob_death.MS", "prob_death.FC", "prob_offtake.FA", "prob_offtake.FB", "prob_offtake.FC", "prob_offtake.FJ",
  "prob_offtake.FS", "prob_offtake.MA",
  "prob_offtake.MB", "prob_offtake.MC", "prob_offtake.MJ", "prob_offtake.MS",
  "potential_final_weight", "share.FA",
  "share.FJ", "share.FS", "share.MA", "share.MJ", "share.MS", "size.FA", "size.FJ",
  "size.FS", "size.MA", "size.MJ", "size.MS", "size_avg.FA", "size_avg.FJ",
  "size_avg.FS", "size_avg.MA", "size_avg.MJ", "size_avg.MS", "size_end.FA",
  "size_end.FJ", "size_end.FS", "size_end.MA", "size_end.MJ", "size_end.MS",
  "size_total", "slaughter_weight", "structure.FA", "structure.FB", "structure.FJ",
  "probability_death", "probability_offtake", "probability_survival", "probability_growth",
  "cohort_stock_size", "offtake_heads", "offtake_heads_assessment", "growth_rate_herd",
  "structure.FS", "structure.MA", "structure.MB", "structure.MJ", "structure.MS",
  "variable", "wkg", "variable_name", "offtake_number_assessment",
  # Columns used in run_weights_module and validate_weights_inputs
  "cohort", "cohort_short", "cohort_duration_days",
  "live_weight_female_adult", "live_weight_male_adult",
  "live_weight_at_birth", "live_weight_female_at_slaughter", "live_weight_male_at_slaughter", "live_weight_at_weaning",
  "live_weight_cohort_initial", "live_weight_cohort_potential_final",
  "live_weight_cohort_at_slaughter", "live_weight_cohort_average",
  "live_weight_cohort_final"
))

utils::globalVariables(c(
  # Columns used in run_ration_quality_module
  "species_short", "cohort_short", "feed_id", "feed_name", "category", "feed_ration_fraction",
  "feed_gross_energy", "feed_digestible_energy_ruminant", "feed_digestible_energy_pigs",
  "feed_metabolizable_energy_ruminant", "feed_metabolizable_energy_pigs",
  "feed_metabolizable_energy_chicken", "feed_nitrogen_content",
  "feed_urinary_energy_ruminant", "feed_urinary_energy_pigs",
  "feed_urinary_energy_chicken", "feed_ash",
  "feed_name_input", "feed_name_params",
  "ration_gross_energy", "ration_metabolizable_energy",
  "ration_nitrogen", "ration_digestibility_fraction",
  "ration_urinary_energy_fraction", "ration_ash",
  "feed_digestibility_fraction_ruminant", "feed_digestibility_fraction_pigs",
  "feed_digestibility_fraction_chicken",
  "diet_dig", "diet_ge", "diet_me", "feed_ration_sum",
  "ration_intake", "nitrogen_excretion", "volatile_solids", "total_fraction",
  "n2o_manure_pasture_vol", "n2o_manure_burned_vol", "n2o_manure_other_vol",
  "n2o_manure_pasture_leach", "n2o_manure_burned_leach", "n2o_manure_other_leach",
  "n2o_manure_pasture_direct", "n2o_manure_burned_direct", "n2o_manure_other_direct",
  "manure_management_system", "mms_list", "mms_list_fraction", "mms_list_factors",
  "unique_mms_sets",
  # Variables used with .. for validation
  "..numeric_cols_feed", "..numeric_cols_rations", "..cols_to_show",
  # Columns used in run_emissions_manure_module
  "dmi", "n_excretion", "ef4", "ef5", "ration_urinary_energy_fraction", "ration_ash",
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
  "mmslitter", "mmsnolitter", "mmsareobic", "mmsaerproc",
  # Columns used in run_soil_carbon
  "area", "climate_zone", "soil_carbon_reference", "soil_type",
  "management_start", "management_end", "SOC1", "SOC2", "dSOC",
  # Columns used in nitrogen_balance
  "nitrogen_intake", "nitrogen_retention", "nitrogen_excretion",
  "ration_intake", "ration_nitrogen", "daily_weight_gain",
  "species_short", "cohort_short", "milk_protein_fraction", "milk_yield_day",
  "fibre_yield_year", "litter_size", "parturition_rate", "live_weight_at_weaning",
  "live_weight_at_birth", "age_first_parturition",
  # data.table join prefixes used in run_nitrogen_balance
  "x.species_short", "x.milk_protein_fraction", "x.milk_yield_day",
  "x.fibre_yield_year", "x.litter_size", "x.parturition_rate",
  "x.live_weight_at_weaning", "x.live_weight_at_birth", "x.age_first_parturition",
  "Item_Name", "dmi", "milk_yield",
  # Columns used in run_production_cohort (cohort-level + outputs)
  "cohort_stock_size", "offtake_heads_assessment", "live_weight_cohort_at_slaughter",
  "fibre_production_cohort",
  # data.table join prefixes used in run_production_cohort (herd-level lookups)
  "x.milk_yield_day", "x.lactating_females_fraction",
  "x.milk_protein_fraction", "x.milk_fat_fraction", "x.milk_lactose_fraction",
  "x.milk_protein_fraction_standard", "x.milk_fat_fraction_standard", "x.milk_lactose_fraction_standard",
  "x.fibre_yield_year", "x.carcass_dressing_fraction", "x.bone_free_meat_fraction", "x.meat_protein_fraction",
  # Columns used in run_emissions_ration_module and validate_feed_emissions_inputs
  "ch4_feed_rice", "co2_feed_crop_operations", "co2_feed_fertilizer", "co2_feed_luc_nopeat",
  "co2_feed_luc_peat", "co2_feed_pesticides",
  "ch4_ration_rice", "co2_ration_crop_activities", "co2_ration_fertilizer",
  "co2_ration_luc_nopeat", "co2_ration_luc_peat", "co2_ration_pesticides",
  "n2o_ration_crop_residues", "n2o_ration_fertilizer", "n2o_ration_manure_applied",
  "n2o_feed_crop_residues", "n2o_feed_fertilizer", "n2o_feed_manure_applied",
  "feed_name_emissions", "feed_name_input", "n_ids",
  # data.table join prefixes used in run_allocation and run_aggregation
  "i.species_short", "x.ratio_me_to_ne"
))

utils::globalVariables(c(
  # Columns used in run_allocation
  "slaughterLW", "initialLW", "meat_production_live_weight_cohort",
  "milk_production_fpcm_cohort", "nefibre", "nework",
  "milk_allocation_energy", "meat_allocation_energy",
  "fibre_allocation_energy", "work_allocation_energy", "egg_allocation_energy",
  "total_allocation_energy", "meat_share_allocation", "milk_share_allocation",
  "work_share_allocation", "fibre_share_allocation", "eggs_share_allocation",
  "allocation_share_other", "allocation_herd_long_all",  # Variables used in run_allocation
  "commodity_name", "commodity_type", "V1"
))

utils::globalVariables(c(
  # Columns created by update joins in run_weights_module
  "x.live_weight_female_adult", "x.live_weight_male_adult", "x.live_weight_at_birth",
  "x.live_weight_female_at_slaughter", "x.live_weight_male_at_slaughter", "x.live_weight_at_weaning"
))

utils::globalVariables(c(
  # Columns used in run_metabolic_energy_req_module (cohort-level and results)
  "cohort_short", "live_weight_cohort_average", "offtake_rate", "low_activity_fraction", "high_activity_fraction",
  "live_weight_cohort_initial", "live_weight_cohort_final", "live_weight_mature_stage", "daily_weight_gain", "cohort_duration_days",
  "ration_digestibility_fraction", "ration_gross_energy", "ration_metabolizable_energy",
  "metabolic_energy_req_maintenance", "metabolic_energy_req_activity", "metabolic_energy_req_growth", "metabolic_energy_req_lactation",
  "metabolic_energy_req_work", "metabolic_energy_req_fibre_production", "metabolic_energy_req_pregnancy",
  "net_energy_maintenance_digestible_energy_ratio", "net_energy_growth_digestible_energy_ratio",
  "metabolic_energy_req_total", "ration_intake", "activity_sum", "species_short",
  # herd-level lookups (x.* from herd_level_data[.SD, on = "herd_id", x.col])
  "x.species_short", "x.lactating_females_fraction", "x.age_first_parturition", "x.milk_yield_day", "x.milk_fat_fraction",
  "x.non_productive_duration", "x.pregnancy_duration", "x.litter_size", "x.death_rate_juvenile", "x.live_weight_at_birth", "x.live_weight_at_weaning",
  "x.lactation_duration", "x.parturition_rate", "x.draught_work_hours_female", "x.draught_work_hours_male",
  "x.draught_fraction_female", "x.draught_fraction_male", "x.fibre_yield_year",
  # validate_run_metabolic_energy_req_module_inputs
  "has_all_cohorts", "missing_cohorts", "live_weight_at_birth", "live_weight_at_weaning"
))

utils::globalVariables(c(
  # Columns used in run_energy_on_farm
  "energy_onfarm", "VarName", "RefYear", "Item", "V1", "GWP",
  "onfarm_emissions", "Unit",
  # Variables used with .. for column selection
  "..energy_select_cols", "..emission_factor_merge_cols", "..output_cols",
  # Columns used in indirectemissions feed
  "EF", "Item_Name", "Trade", "TradeOption_selected", "dmi_byfeed", "dmi_total",
  "feed_emissions_kgGas", "feed_share",
  # Columns added by run_emissions_enteric_module
  "ch4_enteric", "ch4_mitigation_factor", "ch4_conversion_factor_ym",
  "species_short", "cohort_short", "ration_digestibility_fraction",
  "ration_gross_energy", "ration_intake",
  # Columns used in run_aggregation
  "value", "value_total", "value_total_gas", "value_total_allocated_gas",
  "value_allocated", "value_allocated_co2e", "gwp_factor",
  "variable_type", "variable_name", "unit", "gas", "allocation_share",
  "commodity_name", "commodity_type",
  "assessment_duration", "simulation_duration", "cohort_stock_size"  # run_aggregation and herd_simulation
))

