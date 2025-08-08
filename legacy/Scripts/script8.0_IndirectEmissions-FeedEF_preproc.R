# PRE-PROCESSING OF FEED EF TO:
# 1. Rename a feed item to remove the space
# 2. Merge the file with EF of feed items with the updated values for SYNTHETIC, FISHMEAL, LIME
# 3. Excluding local feed items
# 4. Merge with GLEAM-X full list
# Output: file with feed_items both with GLEAM3 and GLEAM-X nomenclature and grouping

# DATAFRAMES----
library(data.table)
library(readxl)

#GLEAM-x emission factors
feedgleamx_ef <- fread("/Users/lydia/Library/CloudStorage/OneDrive-FoodandAgricultureOrganization/GLEAM scripts and codes/GLEAStat/dataDirectory/outputs/Feed_EF_GLEAMx.csv")
feedgleamx_ef[,Item_group:="GLEAMX"]
feedgleamx_ef<-feedgleamx_ef[Data=="available",] #filtering out only available feed
feedgleamx_ef<-feedgleamx_ef[,.(ADM0_CODE, ISO3, COUNTRY, Item_Name, Trade, SOURCE, Unit, EF, GLEAM3_name, Category, Item_group)]

# Creating a look_up to assign a Category to GLEAM3_name items / ALLIGNED WITH FEED PARAMETERS
feed_params <- as.data.table(read_excel("~/Library/CloudStorage/OneDrive-FoodandAgricultureOrganization/GLEAM scripts and codes/GLEAStat/dataDirectory/Feed_list_complete.xlsx", 
                                        sheet = "Complete_list"))
feed_params[, GLEAM3_name := fcase(
  GLEAM3_name == "SOYOIL", "SOY OIL",
  default = GLEAM3_name  # keep unchanged if no match
)]
feed_params<-feed_params[Data=="available"]

gleam_lookup <- unique(feed_params[, .(GLEAM3_name, Category)])
gleam_lookup<-gleam_lookup[!is.na(GLEAM3_name)]


#GLEAM3 emission factors (Fishmeal, LIMESTONE, SYNTETHIC and BNSTM are 0)
feedgleam3_ef <- fread("/Users/lydia/Library/CloudStorage/OneDrive-FoodandAgricultureOrganization/GLEAM scripts and codes/GLEAStat/dataDirectory/outputs/FeedEF_G3_list.csv")

# Dataset with Fishmeal, Limestone, Syntethic and BNSTM
df_additives <- read_excel("~/Library/CloudStorage/OneDrive-FoodandAgricultureOrganization/GLEAM-X - Net human edible nutrient project/Code and calculations/Inputs//UPDATE_Fishmeal_Synthetic_Lime.xlsx") 

# MERGE GLEAM and ADDITIVES----

# Excluding additives names, as those will be added in the second step
feedgleam3_ef <- feedgleam3_ef[!GLEAM3_name %in% c("SYNTHETIC", "LIMESTONE", "FISHMEAL","WSTRAW", "ZSTOVER", "TOPS", "SWILL", 
                                                   "BNSTEM", "BSTRAW", "GRNBYWET", "LEAVES", "MSTOVER", "PSTRAW", "RSTRAW", "SSTOVER", "BPULP",
                                                   "Raw milk of cattle", "Raw milk of goats", "Raw milk of pig",
                                                   "Raw milk of sheep",  "Raw milk of buffalo"), ]


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

# Creating duplicates for the Trade options / To be revised in the future (?)
trade_vals <- c("With trade", "Local")

# Repeat each row for each trade value
df_additives <- df_additives[, .SD[rep(1, length(trade_vals))][, Trade := trade_vals], 
                                      by = seq_len(nrow(df_additives))][, -"seq_len"]


# Repeat each row for each adm0_code
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

# Assigning the categories to GLEAM3 names
# from look-up table
feedgleam3_ef_withadditives[gleam_lookup, on = "GLEAM3_name", Category := i.Category]

na_categories <- feedgleam3_ef_withadditives[is.na(Category)]
unique(na_categories$GLEAM3_name)

# Manually for the missing items
foodwaste_codes <- c("SWILL")
supplement_codes <- c("FISHMEAL", "LIMESTONE", "SYNTHETIC")
grassleaves_codes <- c("LEAVES")
milk_codes <- c("Raw milk of cattle", 
                "Raw milk of goats",
                "Raw milk of pig",
                "Raw milk of sheep",  
                "Raw milk of buffalo")


feedgleam3_ef_withadditives[GLEAM3_name %in% foodwaste_codes,     Category := "Food Waste"]
feedgleam3_ef_withadditives[GLEAM3_name %in% supplement_codes,  Category := "Additives & supplements"]
feedgleam3_ef_withadditives[GLEAM3_name %in% grassleaves_codes, Category := "Grass and leaves"]
feedgleam3_ef_withadditives[GLEAM3_name %in% milk_codes,        Category := "Milk"]

feedgleam3_ef_withadditives[,Item_group:="GLEAM3"]
feedgleam3_ef_withadditives[,Item_Name:=GLEAM3_name]


df_feedEF <- rbind(feedgleam3_ef_withadditives, feedgleamx_ef, fill = TRUE)


#Standardize with plurals
df_feedEF[Category %in% c("Fodder crop"), Category := "Fodder crops"]

# Creating a Category_short label
category_short_map <- c(
  "Cereals"                 = "Cereals",
  "Fruits and vegetables"   = "FruitsVegetables",
  "Roots and tubers"        = "RootsTubers",
  "Fodder crops"             = "FodderCrops",
  "Grass and leaves"        = "GrassLeaves",
  "By-products"             = "ByProducts",
  "Oil crop cakes"          = "OilCropCakes",
  "Pulses"                  = "Pulses",
  "Oil crops"               = "OilCrops",
  "Other"                   = "Other",
  "Additives & supplements" = "AdditivesSupplements",
  "Crop residues"           = "CropResidues",
  "Milk"                    = "Milk"
)

# add Category_short (keeps original Category if not in the map)
df_feedEF[, Category_short := fcoalesce(unname(category_short_map[Category]), Category)]


df_feedEF[, GLEAM_Method:="GLEAMX"]
df_feedEF[, GLEASTAT_version:="v1"]

df_feedEF <- df_feedEF[, .(ADM0_CODE, Category, Category_short, Item_Name, GLEAM3_name, Item_group,
                           GLEAM_Method, GLEASTAT_version, Trade, SOURCE, EF, Unit)]

# FINAL FILE----
fwrite(df_feedEF, "Inputs/Feed_parameters/GLEAM_Feed_EF.csv")