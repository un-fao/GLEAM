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
  "duration.MJ", "duration.MS", "dwg", "female_birth_fraction", "female_fecundity",
  "g.FA", "g.FB", "g.FC", "g.FJ", "g.FS", "g.MA", "g.MB", "g.MC", "g.MJ", "g.MS",
  "growth_rate_pop", "initial_weight", "litsize", "male_fecundity", "mort_rate.FA",
  "mort_rate.FJ", "mort_rate.FS", "mort_rate.MA", "mort_rate.MJ", "mort_rate.MS",
  "offtake.FA", "offtake.FB", "offtake.FC", "offtake.FJ", "offtake.FS", "offtake.MA",
  "offtake.MB", "offtake.MC", "offtake.MJ", "offtake.MS", "offtake_rate",
  "offtake_rate.FA", "offtake_rate.FJ", "offtake_rate.FS", "offtake_rate.MA",
  "offtake_rate.MJ", "offtake_rate.MS", "parturition_rate", "pdea.FA", "pdea.FB",
  "pdea.FC", "pdea.FJ", "pdea.FS", "pdea.MA", "pdea.MB", "pdea.MC", "pdea.MJ",
  "pdea.MS", "poff.FA", "poff.FB", "poff.FC", "poff.FJ", "poff.FS", "poff.MA",
  "poff.MB", "poff.MC", "poff.MJ", "poff.MS", "potential_final_weight", "share.FA",
  "share.FJ", "share.FS", "share.MA", "share.MJ", "share.MS", "size.FA", "size.FJ",
  "size.FS", "size.MA", "size.MJ", "size.MS", "size_avg.FA", "size_avg.FJ",
  "size_avg.FS", "size_avg.MA", "size_avg.MJ", "size_avg.MS", "size_end.FA",
  "size_end.FJ", "size_end.FS", "size_end.MA", "size_end.MJ", "size_end.MS",
  "size_total", "slaughter_weight", "structure.FA", "structure.FB", "structure.FJ",
  "structure.FS", "structure.MA", "structure.MB", "structure.MJ", "structure.MS",
  "variable", "wkg"
))
