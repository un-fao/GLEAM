# PRE-PROCESSING OF FEED EF TO:
# 1. Rename a feed item to remove the space
# 2. Merge the file with EF of feed items with the updated values for SYNTHETIC, FISHMEAL, LIME
# 3. Excluding local feed items

# DATAFRAMES----
library(data.table)
library(readxl)
#GLEAM emission factors (Fishmeal, LIMESTONE, SYNTETHIC and BNSTM are 0)
feedgleam3_ef <- fread("/Users/lydia/Library/CloudStorage/OneDrive-FoodandAgricultureOrganization/GLEAM scripts and codes/GLEAStat/dataDirectory/outputs/FeedEF_G3_list.csv")

# Dataset with Fishmeal, Limestone, Syntethic and BNSTM
df_additives <- read_excel("~/Library/CloudStorage/OneDrive-FoodandAgricultureOrganization/GLEAM-X - Net human edible nutrient project/Code and calculations/Inputs//UPDATE_Fishmeal_Synthetic_Lime.xlsx") 

# MERGE GLEAM and ADDITIVES----

# Excluding additives names, as those will be added in the second step
feedgleam3_ef <- feedgleam3_ef[!GLEAM3_name %in% c("SYNTHETIC", "LIMESTONE", "FISHMEAL","WSTRAW", "ZSTOVER", "TOPS", "SWILL", 
                                                   "BNSTEM", "BSTRAW", "GRNBYWET", "LEAVES", "MSTOVER", "PSTRAW", "RSTRAW", "SSTOVER", "BPULP",
                                                   "Raw milk of cattle", "Raw milk of goats", "Raw milk of pig",
                                                   "Raw milk of sheep",  "Raw milk of buffalo"), ]


# Renaming, to allign with the feed basket names
feedgleam3_ef[, GLEAM3_name := fcase(
  GLEAM3_name == "SOY OIL", "SOYOIL",
  default = GLEAM3_name  # keep unchanged if no match
)]

# Arranging the additives dataset so that it includes FISHMEAL, SYNTHETIC and LIMESTONE value for all countries (repeated) + BNSTEAM = 0, currently missing in the EF df
df_additives<-as.data.table(df_additives)[,.(GLEAM3_name, GLEAM3, Unit, SOURCE)]
setnames(df_additives, "GLEAM3", "EF")
feed_items <- c("WSTRAW", "ZSTOVER", "TOPS", "SWILL", 
                "BNSTEM", "BPULP", "BSTRAW", "GRNBYWET", 
                "LEAVES", "MSTOVER", "PSTRAW", "RSTRAW", "SSTOVER",  "Raw milk of cattle", "Raw milk of goats", "Raw milk of pig",
                "Raw milk of sheep",  "Raw milk of buffalo")

# Create a data.table with one row per item
new_rows <- data.table(
  GLEAM3_name = feed_items,
  Unit = "kgCO2/kgDM",
  SOURCE = "CO2FOSSIL",
  EF = 0
)

# Bind to the existing df_additives
df_additives <- rbind(df_additives, new_rows, fill = TRUE)


ADM0_df <- unique(feedgleam3_ef[, .(ADM0_CODE = factor(ADM0_CODE), ISO3, COUNTRY)])

# Expand df_additives for each unique ADM0
df_additives_expanded <- df_additives[rep(1:.N, times = nrow(ADM0_df))]

# Repeat ADM0_df for each row of df_additives
ADM0_expanded <- ADM0_df[rep(1:.N, each = nrow(df_additives))]

# Bind EF and ADDITIVES df together
df_additives_expanded[, `:=`(
  ADM0_CODE = ADM0_expanded$ADM0_CODE,
  ISO3 = ADM0_expanded$ISO3,
  COUNTRY = ADM0_expanded$COUNTRY
)]

feedgleam3_ef_withadditives <- rbind(feedgleam3_ef, df_additives_expanded, fill = TRUE)

# FINAL FILE----
gleam_feedEF <- feedgleam3_ef_withadditives[,.(GLEAM3_name, SOURCE, ADM0_CODE, Trade, Unit, EF)] #selecting a limited number of variables


fwrite(
  gleam_feedEF, "inst/extdata/GLEAM_FeedEF.csv")

