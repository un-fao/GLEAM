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
  ".", "..cols_to_drop", "..final_cols", "ADM0_CODE", "AFKG", "AMKG", "Animal_short",
  "COUNTRY", "HerdType_short", "LPS_short", "MFSKG", "MMSKG", "WA", "afc", "ckg",
  "cohort", "duration", "duration.FA", "duration.FJ", "duration.FS", "duration.MA",
  "duration.MJ", "duration.MS", "dwg", "female_birth_fraction", "fem_fec",
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
  "structure.FS", "structure.MA", "structure.MB", "structure.MJ", "structure.MS",
  "variable", "wkg", "variable_name"
))

utils::globalVariables(c(
  # Columns used in run_feed_rations
  "DE_pigs", "DE_ruminants", "GE", "GLEAM3_name", "HerdType", "LPS",
  "ME_chickens", "ME_pigs", "ME_ruminants", "N_content",
  "diet_dig", "diet_ge", "diet_me", "diet_nitrogen",
  "dig_chickens", "dig_pigs", "dig_ruminants", "value",
  # Variables used with .. for validation
  "..numeric_cols_feed", "..numeric_cols_rations"
))

# Add species abbreviations
abbr_animals <- data.table(
  Animal = c("Cattle", "Buffalo", "Sheep", "Goats", "Chicken", "Pigs", "Camels"),
  Animal_short = c("CTL", "BFL", "SHP", "GTS", "CHK", "PGS", "CML")
)
