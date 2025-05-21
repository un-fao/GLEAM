
#inputs---
camels_rations<- fread("legacy/Inputs/Pre_processing/Camelids/camels_rations.csv")
rations <- fread(file.path("legacy/Inputs/Pre_processing/GLEAM_input_feed_GLEAM3_rations.csv"))
rations<-rbind(camels_rations, rations, fill = TRUE)


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



fwrite(rations_share, "legacy/Inputs/GLEAM_input_FeedRations.csv")
