library(data.table)
library(readxl)

#inputs---
# Sourcing from original location:
# feed_params <- as.data.table(read_excel("~/Library/CloudStorage/OneDrive-FoodandAgricultureOrganization/GLEAM scripts and codes/GLEAStat/dataDirectory/Feed_list_complete.xlsx",
#                                         sheet = "Complete_list"))
# 
# fwrite(feed_params,
#        "~/Library/CloudStorage/OneDrive-FoodandAgricultureOrganization/GLEAM scripts and codes/gleam/inst//extdata/Feed_list_complete.csv"
# )

feed_params <-fread(
  system.file("extdata/Feed_list_complete.csv", package = "gleam")
  )


rations_share <- fread(
  system.file("extdata/GLEAM_input_FeedRations.csv", package = "gleam")
)

GLEAM_input_feed_preproc <- fread(
  system.file("extdata/GLEAM_input_feed.csv", package = "gleam")
)


# combining with feed parameters-----
setnames(feed_params, old = c(
  "GLEAM_code", "Item_Name", "GLEAM3_name", "Category", "Data",
  "Item_code_CPC", "Source_Item_code_CPC", "Item_code_FAO", "Source_Item_code_FAO", "Description",
  "Cattle", "Sheep", "Goat", "Pigs", "Chicken", "Species", "FAOSTAT domain",
  "cr_slope", "cr_intercept", "Dry matter content (%)",
  "GE (Mj/kgDM)", "DE_ruminats (Mj/kgDM)", "DE_pigs (Mj/kgDM)",
  "ME_ruminants (Mj/kgDM)", "ME_pigs (Mj/kgDM)", "ME_chickens (Mj/kgDM)",
  "CP (% DM)", "N_content (kg N / kg DM)",
  "Nitrogen digestibility (%)ruminans", "Nitrogen digestibility (%)pigs",
  "Reference1", "Reference2", "Note"
), new = c(
  "GLEAM_code", "Item_Name", "GLEAM3_name", "Category", "data",
  "item_code_cpc", "source_item_code_cpc", "item_code_fao", "source_item_code_fao", "description",
  "cattle", "sheep", "goat", "pigs", "chicken", "species", "faostat_domain",
  "cr_slope", "cr_intercept", "DM",
  "GE", "DE_ruminants", "DE_pigs",
  "ME_ruminants", "ME_pigs", "ME_chickens",
  "CP", "N_content",
  "N_dig_ruminants", "N_dig_pigs",
  "reference1", "reference2", "note"
))


milk_items <- c("Raw milk of cattle",
                "Raw milk of buffalo",
                "Raw milk of camel",
                "Raw milk of sheep",
                "Raw milk of goats",
                "Raw milk of pig")

# Update GLEAM3_NAME where Item_Name matches one of the milk items
feed_params[Item_Name %in% milk_items, GLEAM3_name := Item_Name]



# calculate digestibility
feed_params$dig_ruminants <- feed_params$DE_ruminants / feed_params$GE
feed_params$dig_pigs <- feed_params$DE_pigs / feed_params$GE
feed_params$dig_chickens <- feed_params$ME_chickens / feed_params$GE
feed_params[N_content %in% c("", "-"), N_content := NA]
feed_params[, N_content := as.numeric(N_content)]

feed_params_sel <- feed_params[, .(GLEAM3_name, GE, ME_ruminants, ME_pigs, ME_chickens,
                                   N_content, dig_ruminants, dig_pigs, dig_chickens)]



# group by GLEAM3_name feed items
feed_params_sel_summary <- feed_params_sel[, .(
  GE = mean(na.omit(GE)),
  ME_ruminants = mean(na.omit(ME_ruminants)),
  ME_pigs = mean(na.omit(ME_pigs)),
  ME_chickens = mean(na.omit(ME_chickens)),
  N_content = mean(na.omit(N_content)),
  dig_ruminants = mean(na.omit(dig_ruminants)),
  dig_pigs = mean(na.omit(dig_pigs)),
  dig_chickens = mean(na.omit(dig_chickens))
), by = .(GLEAM3_name)]


# checking the unmatched records
 #rations_share[, in_feed := GLEAM3_name %in% feed_params_sel_summary$GLEAM3_name]
#
# # View unmatched rows
 #unmatched <- rations_share[in_feed == FALSE]
 #unique(unmatched$GLEAM3_name)


# merge with the feed rations
rations_temp <- merge(rations_share, feed_params_sel_summary, by = "GLEAM3_name", all.x = TRUE, allow.cartesian = TRUE)

# calculating the feed value
rations_temp[, `:=` (
  diet_ge = value * GE,
  diet_nitrogen  = value * N_content,

  diet_dig = fifelse(Animal_short %in% c("CTL", "BFL", "CML", "SHP", "GTS"), value * dig_ruminants,
                      fifelse(Animal_short == "CHK", value * dig_chickens,
                              fifelse(Animal_short == "PGS", value * dig_pigs, NA_real_))),

  diet_me = fifelse(Animal_short %in% c("CTL", "BFL", "CML", "SHP", "GTS"), value * ME_ruminants,
                      fifelse(Animal_short == "CHK", value * ME_chickens,
                              fifelse(Animal_short == "PGS", value * ME_pigs, NA_real_)))
)]


# summary by species, COUNTRY, lps, herdtype and cohort
rations_summary <- rations_temp[, .(
  diet_ge       = sum(diet_ge, na.rm = TRUE),
  diet_me       = sum(diet_me, na.rm = TRUE),
  diet_nitrogen = sum(diet_nitrogen, na.rm = TRUE),
  diet_dig      = sum(diet_dig, na.rm = TRUE)
), by = .(Animal_short, COUNTRY, ADM0_CODE, HerdType, LPS, cohort)]


# add feed nutritional parameters
GLEAM_input_feed_preproc <- merge(
  GLEAM_input_feed_preproc,
  rations_summary,
  by = c("Animal_short", "ADM0_CODE", "COUNTRY", "HerdType", "LPS", "cohort"),
  all.x = TRUE,
  allow.cartesian = TRUE
)

fwrite(
  GLEAM_input_feed_preproc, system.file("extdata/GLEAM_input_energyrequirements.csv", package = "gleam")
)


