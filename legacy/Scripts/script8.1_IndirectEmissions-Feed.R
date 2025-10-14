# Inputs----
gleam_feedEF<-fread("inst/extdata/Feed_parameters/GLEAM_Feed_EF.csv")[, ADM0_CODE := as.factor(ADM0_CODE)]

gleam_dmi <- fread("inst/extdata/GLEAM_input_directemissions_enteric.csv")[
  , .(ADM0_CODE = as.factor(ADM0_CODE), Animal, Animal_short, LPS, LPS_short, HerdType, HerdType_short, COUNTRY, ISO3, ISO3_num, M49_code, cohort, dmi)
]
gleam_dmi[is.na(dmi), dmi := 0]

gleam_feedbasket<-fread("inst/extdata/GLEAM_input_FeedRations.csv")[, ADM0_CODE := as.factor(ADM0_CODE)]

#Functions-----
source("legacy/Functions/6_functions_indirectemissions-Feed.R")

# Dry Matter intake by feed-----
# Output: kg DM/head/day per feed item

gleam_dmi <- calculate_intake_byfeed(
  gleam_dmi[, .(ADM0_CODE, ISO3, Animal_short, HerdType_short, LPS_short, cohort, dmi_total = dmi)],
  gleam_feedbasket[, .(ADM0_CODE, Animal_short, HerdType_short, LPS_short, cohort, GLEAM3_name, feed_share = value)],
  by_merge = c("ADM0_CODE", "Animal_short", "HerdType_short", "LPS_short", "cohort")
)

gleam_feed_emissions <- calculate_feed_emissions(
  gleam_dmi,
  gleam_feedEF,
  feed_id_col = "GLEAM3_name",
  by_merge = c("ADM0_CODE", "GLEAM3_name"),
  trade_preferences = list("BPULP" = "Without Trade") 
  # Example of usecase / the idea is that the default feature is "with trade" but then user can specify the condition for specific feed items
)
