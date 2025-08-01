library(readxl)
#inputs---
camels_rations <- fread(
  system.file("extdata/Pre_processing/Camelids/camels_rations.csv", package = "gleam")
)
rations <- fread(file.path(
  system.file("extdata/Pre_processing/GLEAM_input_feed_GLEAM3_rations.csv", package = "gleam")
))
rations <- rbind(camels_rations, rations, fill = TRUE)

country_income_class <- read_excel("~/Library/CloudStorage/OneDrive-FoodandAgricultureOrganization/GLEAM scripts and codes/Working scripts/GLEAM-X/Inputs/Pre_processing/WorldBank_income_CLASS_2025_07_02.xlsx")
country_income_class<-as.data.table(country_income_class)


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


# Harmonizing the feed GLEAM3_names names with the ones of feed EF
rations_share[, GLEAM3_name := fcase(
  GLEAM3_name == "GRAINSIL", "FDDRSIL",
  GLEAM3_name %in% c("MAIZEN", "MAIZES", "CMAIZE", "CORN"), "MAIZE",
  GLEAM3_name %in% c("CWHEAT", "WHEATS", "WHEATN"), "WHEAT",
  GLEAM3_name == "CBARLEY", "BARLEY",
  GLEAM3_name == "CMLOILSDS", "MLOILSDS",
  GLEAM3_name=="CGRNBYDRY", "GRNBYDRY",
  GLEAM3_name == "CMLSOY", "MLSOY",
  GLEAM3_name == "LIME", "LIMESTONE",
  GLEAM3_name == "CSORGHUM", "SORGHUM",
  GLEAM3_name == "CSOY", "SOY",
  GLEAM3_name == "CCASSAVA", "CASSAVA",
  GLEAM3_name == "CPULSES", "PULSES",
  GLEAM3_name == "SOY OIL", "SOYOIL",
  GLEAM3_name == "CMLCTTN", "MLCTTN",
  GLEAM3_name == "CMILLET", "MILLET",
  GLEAM3_name == "CRICE", "RICE",
  default = GLEAM3_name  # keep unchanged if no match
)]


# Assigning GRASSF/GRASSH_cultivated to high income economies (from World Bank classification: https://datahelpdesk.worldbank.org/knowledgebase/articles/906519-world-bank-country-and-lending-groups)
gleam_feedbasket <- merge(
  rations_share,
  country_income_class[, .(Economy, Code, `Income group`)],
  by.x = "ISO3",
  by.y = "Code",
  all.x = TRUE
)


# Assuming DMI is a data.table
gleam_feedbasket[GLEAM3_name %in% c("GRASSH", "GRASSH2") & `Income group` == "High income", GLEAM3_name := "GRASSH_cultivated"]
gleam_feedbasket[GLEAM3_name %in% c("GRASSH", "GRASSH2") & (`Income group` != "High income" | is.na(`Income group`)), 
                 GLEAM3_name := "GRASSH_uncultivated"]

gleam_feedbasket[GLEAM3_name == "GRASSLEGH" & `Income group` == "High income", GLEAM3_name := "GRASSLEGH_cultivated"]
gleam_feedbasket[GLEAM3_name == "GRASSLEGH" & (`Income group` != "High income" | is.na(`Income group`)), 
                 GLEAM3_name := "GRASSLEGH_uncultivated"]

gleam_feedbasket[GLEAM3_name == "GRASSF" & `Income group` == "High income", GLEAM3_name := "GRASSF_cultivated"]
gleam_feedbasket[GLEAM3_name == "GRASSF" & (`Income group` != "High income" | is.na(`Income group`)), 
                 GLEAM3_name := "GRASSF_uncultivated"]

gleam_feedbasket[GLEAM3_name == "GRASSLEGF" & `Income group` == "High income", GLEAM3_name := "GRASSLEGF_cultivated"]
gleam_feedbasket[GLEAM3_name == "GRASSLEGF" & (`Income group` != "High income" | is.na(`Income group`)), 
                 GLEAM3_name := "GRASSLEGF_uncultivated"]



fwrite(
  rations_share, system.file("extdata/GLEAM_input_FeedRations.csv", package = "gleam")
)
