process_feed_rations <- function(rations_share, feed_params, input_feed) {
  # Rename columns
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
  ), skip_absent = TRUE)

  # Update milk GLEAM3_name
  milk_items <- c(
    "Raw milk of cattle", "Raw milk of buffalo", "Raw milk of camel",
    "Raw milk of sheep", "Raw milk of goats", "Raw milk of pig"
  )
  feed_params[Item_Name %in% milk_items, GLEAM3_name := Item_Name]

  # Compute digestibility
  feed_params[, dig_ruminants := DE_ruminants / GE]
  feed_params[, dig_pigs := DE_pigs / GE]
  feed_params[, dig_chickens := ME_chickens / GE]
  feed_params[N_content %in% c("", "-"), N_content := NA]
  feed_params[, N_content := as.numeric(N_content)]

  # Keep relevant columns only
  feed_params_sel <- feed_params[, .(
    GLEAM3_name, GE, ME_ruminants, ME_pigs, ME_chickens,
    N_content, dig_ruminants, dig_pigs, dig_chickens
  )]

  # Aggregate nutrient content per GLEAM3_name
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

  # Harmonize GLEAM3_name
  rations_share[GLEAM3_name %in% c("CORN", "MAIZEN", "MAIZES", "CMAIZE"), GLEAM3_name := "MAIZE"]
  rations_share[GLEAM3_name %in% c("WHEATN", "WHEATS", "CWHEAT"), GLEAM3_name := "WHEAT"]
  rations_share[GLEAM3_name %in% c("CBARLEY"), GLEAM3_name := "BARLEY"]
  rations_share[GLEAM3_name %in% c("CMLOILSDS"), GLEAM3_name := "MLOILSDS"]
  rations_share[GLEAM3_name %in% c("CMLSOY"), GLEAM3_name := "MLSOY"]
  rations_share[GLEAM3_name %in% c("CSORGHUM"), GLEAM3_name := "SORGHUM"]
  rations_share[GLEAM3_name %in% c("CSOY"), GLEAM3_name := "SOY"]
  rations_share[GLEAM3_name %in% c("CCASSAVA"), GLEAM3_name := "CASSAVA"]
  rations_share[GLEAM3_name %in% c("CGRNBYDRY"), GLEAM3_name := "GRNBYDRY"]
  rations_share[GLEAM3_name %in% c("CPULSES"), GLEAM3_name := "PULSES"]
  rations_share[GLEAM3_name %in% c("CMLCTTN"), GLEAM3_name := "MLCTTN"]
  rations_share[GLEAM3_name %in% c("CMILLET"), GLEAM3_name := "MILLET"]
  rations_share[GLEAM3_name %in% c("CRICE"), GLEAM3_name := "RICE"]
  rations_share[GLEAM3_name %in% c("LIME"), GLEAM3_name := "LIMESTONE"]

  # Merge with feed parameters
  rations_temp <- merge(
    rations_share, feed_params_sel_summary,
    by = "GLEAM3_name", all.x = TRUE, allow.cartesian = TRUE
  )

  # Add Animal_short
  abbr_animals <- data.table(
    Animal = c("Cattle", "Buffalo", "Sheep", "Goats", "Chicken", "Pigs", "Camels"),
    Animal_short = c("CTL", "BFL", "SHP", "GTS", "CHK", "PGS", "CML")
  )
  rations_temp <- merge(rations_temp, abbr_animals, by = "Animal", all.x = TRUE)

  # Calculate feed contributions
  rations_temp[, `:=`(
    diet_ge = value * GE,
    diet_nitrogen = value * N_content,
    diet_dig = fifelse(
      Animal_short %in% c("CTL", "BFL", "CML", "SHP", "GTS"), value * dig_ruminants,
      fifelse(Animal_short == "CHK", value * dig_chickens,
              fifelse(Animal_short == "PGS", value * dig_pigs, NA_real_))
    ),
    diet_me = fifelse(
      Animal_short %in% c("CTL", "BFL", "CML", "SHP", "GTS"), value * ME_ruminants,
      fifelse(Animal_short == "CHK", value * ME_chickens,
              fifelse(Animal_short == "PGS", value * ME_pigs, NA_real_))
    )
  )]

  # Summarize feed contributions by species, country, and cohort
  rations_summary <- rations_temp[, .(
    diet_ge = sum(diet_ge, na.rm = TRUE),
    diet_me = sum(diet_me, na.rm = TRUE),
    diet_nitrogen = sum(diet_nitrogen, na.rm = TRUE),
    diet_dig = sum(diet_dig, na.rm = TRUE)
  ), by = .(Animal_short, COUNTRY, ADM0_CODE, HerdType, LPS, cohort)]

  # Merge into input_feed
  result <- merge(
    input_feed,
    rations_summary,
    by = c("Animal_short", "ADM0_CODE", "COUNTRY", "HerdType", "LPS", "cohort"),
    all.x = TRUE,
    allow.cartesian = TRUE
  )

  return(result)
}
