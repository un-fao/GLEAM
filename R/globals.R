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
  "animal_short",
  "COUNTRY", "HerdType_short", "LPS_short", "MFSKG", "MMSKG", "WA", "afc", "ckg",
  "cohort", "count", "daily_weight_gain", "duration", "duration.FA", "duration.FJ", "duration.FS",
  "cohort_duration_days", "death_rate",
  "duration.MA", "duration.MJ", "duration.MS", "dwg", "female_birth_fraction", "fem_fec",
  "birth_fraction_female", "litter_size", "herd_size_total",
  "fecundity_female", "fecundity_male",
  "herd_id", "has_all_cohorts", "missing_cohorts", "n_unique", "index", "N",  # Variables used in run_herd_simulation
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
  # Columns used in run_weights_calculations
  "cohort", "cohort_short", "cohort_duration_days",
  "live_weight_female_adult", "live_weight_male_adult",
  "birth_weight", "slaughter_weight_female", "slaughter_weight_male", "weaning_weight",
  "live_weight_cohort_initial", "live_weight_cohort_potential_final",
  "slaughter_weight_cohort", "live_weight_cohort_average",
  "live_weight_cohort_final", "animal", "animal_short"
))

utils::globalVariables(c(
  # Columns used in run_feed_rations
  "animal", "animal_short", "feed_id", "feed_name", "category", "feed_ration_fraction",
  "feed_gross_energy", "feed_digestible_energy_ruminant", "feed_digestible_energy_pigs",
  "feed_metabolizable_energy_ruminant", "feed_metabolizable_energy_pigs",
  "feed_metabolizable_energy_chicken", "feed_nitrogen_content",
  "feed_name_input", "feed_name_params",
  "diet_gross_energy", "diet_metabolizable_energy",
  "diet_nitrogen", "diet_digestibility_fraction",
  "feed_digestibility_fraction_ruminant", "feed_digestibility_fraction_pigs",
  "feed_digestibility_fraction_chicken",
  "diet_dig", "diet_ge", "diet_me", "feed_ration_sum",
  "dry_matter_intake", "nitrogen_excretion", "volatile_solids",
  "n2o_vol_manure_pasture", "n2o_vol_manure_burned", "n2o_vol_manure_other",
  "n2o_leach_manure_pasture", "n2o_leach_manure_burned", "n2o_leach_manure_other",
  "n2o_manure_pasture_direct", "n2o_manure_burned_direct", "n2o_manure_other_direct",
  "manure_management_system", "mms_list", "mms_list_fraction", "mms_list_factors",
  "unique_mms_sets",
  # Variables used with .. for validation
  "..numeric_cols_feed", "..numeric_cols_rations",
  # Columns used in run_directemissions_manure
  "dmi", "n_excretion", "ef4", "ef5", "mms_all_b0", "mms_all", "mmspasture_b0", "mmspasture",
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
  "n_intake", "n_retention", "n_excretion", "fibre_prod", "milk_protein",
  "Item_Name", "dmi", "milk_yield",
  # Columns used in run_production_cohort
  "Value", "lactose", "milk_yield", "size", "milking_fraction", "milk_protein",
  "milk_fat", "fibre_cohorts_size", "fibre_prod",
  "output_fibre_production", "offtake_number", "carcass_dressing_percentage",
  "bone_free_meat_fraction", "meat_protein"
))

utils::globalVariables(c(
  # Columns used in run_allocation
  "slaughterLW", "initialLW", "output_meat_production_liveweight",
  "output_milk_fpcm_production", "nefibre", "nework",
  "energy_allocation_milk", "energy_allocation_meat",
  "energy_allocation_fibre", "energy_allocation_work", "energy_allocation_eggs",
  "total_allocation_energy", "allocation_share_meat", "allocation_share_milk",
  "allocation_share_work", "allocation_share_fibre", "allocation_share_eggs",
  "allocation_share_other", "allocation_herd_long_all",  # Variables used in run_allocation
  "commodity_name", "commodity_type", "V1"
))

utils::globalVariables(c(
  # Columns created by update joins in run_weights_calculations
  "x.live_weight_female_adult", "x.live_weight_male_adult", "x.birth_weight",
  "x.slaughter_weight_female", "x.slaughter_weight_male", "x.weaning_weight"
))

utils::globalVariables(c(
  # Columns used in run_energy_requirements
  "average_weight", "dmi", "dr1", "draught_fraction", "fibre_prod",
  "final_weight", "gest", "getot", "idle", "lact", "lambing_interval",
  "milk_fat", "milk_yield", "milking_fraction", "high_activity_fraction", "neact",
  "neegg", "nefibre", "negrow", "nelact", "nemain", "nepreg",
  "nework", "activity_fraction", "reg", "rem", "work_hours",
  "work_hours_female", "work_hours_male", "draught_fraction_female",
  "draught_fraction_male",
  "adult_weight"  # Variable used in run_energy_requirements
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
  # Columns added by run_directemissions_enteric
  "ym", "ch4_enteric",
  # Columns used in run_aggregation
  "value", "value_total", "value_allocated", "value_allocated_co2e", "gwp_factor",
  "variable_type", "variable_name", "unit", "gas", "allocation_share",
  "allocation_type", "commodity_name", "commodity_type",
  "assessment_duration"  # Variable used in run_aggregation
))

# Add species abbreviations
abbr_animals <- data.table::data.table(
  animal = c("Cattle", "Buffalo", "Sheep", "Goats", "Chicken", "Pigs", "Camels"),
  animal_short = c("CTL", "BFL", "SHP", "GTS", "CHK", "PGS", "CML")
)
