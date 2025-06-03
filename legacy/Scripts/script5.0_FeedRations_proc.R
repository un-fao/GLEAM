
# Inputs---
camels_rations <- fread(
  system.file("extdata/Pre_processing/Camelids/camels_rations.csv", package = "gleam")
)
rations <- fread(file.path(
  system.file("extdata/Pre_processing/GLEAM_input_feed_GLEAM3_rations.csv", package = "gleam")
))

rations <- rbind(camels_rations, rations, fill = TRUE)


# preparing the feed basket composition dataframe-----
cohort_levels <- c("FA", "FS", "FJ", "MA", "MS", "MJ")

# filter only the share of feed - feed basket composition
rations_share <- rations[rations$variable == "Share", ]


# assign cohorts to the file - feed basket composition assumed to be the same of each cohort / in the future cohorts-specific feed baskets ####
rations_share <- rations_share[, .(cohort = cohort_levels), by = .(ADM0_CODE, ISO3, COUNTRY, Animal, HerdType, LPS, GLEAM3_name, variable, value, Unit)]

# assign to juveniles cohort the value of 0 - assumed to be milk-fed
rations_share[cohort %in% c("FJ", "MJ"), value := 0]

#create a new GLEAM3_name feed called milk - assign 100% to juveniles and 0 to the rest of the cohorts
milk_entries <- unique(rations_share[, .(ADM0_CODE, ISO3, COUNTRY, Animal, HerdType, LPS, cohort, variable, Unit)])

milk_entries[Animal=="Buffalo", GLEAM3_name := "Raw milk of buffalo"]
milk_entries[Animal=="Cattle", GLEAM3_name := "Raw milk of cattle"]
milk_entries[Animal=="Camels", GLEAM3_name := "Raw milk of camel"]
milk_entries[Animal=="Sheep", GLEAM3_name := "Raw milk of sheep"]
milk_entries[Animal=="Goats", GLEAM3_name := "Raw milk of goats"]
milk_entries[Animal=="Pigs", GLEAM3_name := "Raw milk of pig"]
milk_entries[, value := fifelse(cohort %in% c("FJ", "MJ"), 1, 0)]

# combine with the original data
rations_share <- rbind(rations_share, milk_entries, fill = TRUE)

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


fwrite(
  rations_share, system.file("extdata/GLEAM_input_FeedRations.csv", package = "gleam")
)
