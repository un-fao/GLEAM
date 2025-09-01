library(data.table)

source("legacy/Functions/00_Preprocessing_functions.R")

wide_dt <- fread(
  system.file("extdata/pre-processing-inputs/GLEAM_input_preproc.csv", package = "gleam")
)

wide_camels_dt <- fread(
  system.file("extdata/pre-processing-inputs/Camelids/camels_inputs.csv", package = "gleam")
)

wide_dt[, MOLT := ifelse(MOLT < 0.5, 0, 1)] #this should be a boolean variable, there's some error in the file
wide_dt[, MALE := ifelse(MALE < 0.5, 0, 1)] #this should be a boolean variable, there's some error in the file

# Rename MMS in camelds_dt to allign with the rest of the dataset
mms_cols <- grep("^MMS", names(wide_camels_dt), value = TRUE)
mms_cols_to_rename <- setdiff(mms_cols, "MMSKG")

# Rename those columns to lowercase
setnames(wide_camels_dt, old = mms_cols_to_rename, new = tolower(mms_cols_to_rename))

# wide_dt re-naming and re-arrangement
wide_dt[Animal_short == "PGS", c("AFC", "AFCM") := get.afc_pigs(AFKG=AFKG,AMKG=AMKG,DWG2=DWG2,WKG=WKG,WA=WA),by=.I]

wide_dt[Animal_short == "CHK", c("LITSIZE") :=
          get.litsize_chk(LPS_short, AF_FRAC, CKG, M2SKG, DR1, DRL2, DR2, DRF, DRM, FRRF, FRMF, BCR,
                          LAYTIME1, MOLTTIME, LAYTIME2, BIDLE, AFC, AFS, A2S, CYCLE, CLTSIZE, HATCH, EGGSYEAR,
                          MALE, MOLT),by=.I]

wide_dt[,c("offtake_rate.FJ", "offtake_rate.FS", "offtake_rate.FA", "offtake_rate.MJ", "offtake_rate.MS", "offtake_rate.MA") :=
          get.offtake_rate(Animal_short =  Animal_short, LPS_short = LPS_short, AFC = AFC, AFCM = AFCM, AFS = AFS, A2S = A2S, CKG =  CKG, WKG =  WKG, AFKG = AFKG, AMKG =  AMKG,
                          M2SKG = M2SKG, MFSKG =  MFSKG, MMSKG =  MMSKG, AF1KG = AF1KG, AF2KG = AF2KG, AM2KG = AM2KG,
                          DR1 =  DR1, DR1M =  DR1M, DR2 = DR2, DRL2 = DRL2, DRR2A =  DRR2A, DRR2B = DRR2B, DRF = DRF, DRM = DRM,
                          FR = FR, FRRF = FRRF, FRMF = FRMF, RRF = RRF, RRM =  RRM, WA = WA, BCR = BCR, DWG2 = DWG2,
                          LAYTIME1 = LAYTIME1, MOLTTIME = MOLTTIME, LAYTIME2 = LAYTIME2, CYCLE = CYCLE, CLTSIZE = CLTSIZE, HATCH = HATCH,
                          EGGSYEAR = EGGSYEAR, LITSIZE = LITSIZE),by=.I]

wide_dt[,c("mort_rate.FJ", "mort_rate.FS", "mort_rate.FA", "mort_rate.MJ", "mort_rate.MS", "mort_rate.MA") :=
          get.mort_rate(Animal_short, LPS_short, DR1, DR1M, DR2, DRL2, DRM, DRR2A, DRR2B, DRF, LAYTIME1, LAYTIME2, MOLTTIME, AFS, AFC, offtake_rate.FS, offtake_rate.MS),by=.I]

wide_dt[,c("duration.FJ", "duration.FS", "duration.FA", "duration.MJ", "duration.MS", "duration.MA") :=
          get.duration(Animal_short, LPS_short, WA, AFC, AFCM, AFS, RRF, LAYTIME1, LAYTIME2, MOLTTIME, mort_rate.FA, mort_rate.MA),by=.I]


# add camels input parameters
wide_dt[,milking_fraction:=0]
wide_dt<-rbind(wide_dt, wide_camels_dt, fill = TRUE)


# add draught_proportion----
wide_dt[, draught_fraction := function_draught_proportion(BCR)]

# add milking_fraction----
wide_dt[HerdType_short=="DRY", milking_fraction:=1]
wide_dt[HerdType_short!="DRY" & Animal_short!="CML", milking_fraction:=0]


#RENAMING VARIABLES DRAFT------------

# To rename variables at the end of script1

#CLEANING

# Fiber production----
wide_dt[, fibre_prod := rowSums(.SD, na.rm = TRUE), .SDcols = c("CSH", "MHR", "WOOL")]
wide_dt <- wide_dt[,!c("CSH", "MHR", "WOOL")]
# Summing-up fiber production and create a new column called "prod_fiber"
# CSH / total amount of cashmere produced by system
# MHR / total amount of mohair produced by the system
# WOOL /total amount of wool produced by the system

# Removing variables----

wide_dt <- wide_dt[,!c("ACT", "DCR", "POPULATION", "AF_FRAC", "DISCARGE", "DISCHARGE", "DWG", "FISHPOND", "INCINERATION", "PUBLSEWAGE")]
# ACT - OLD Variable used to determine the "activity level" by LPS / Not used
# DCR - Dairy cow to total stock of population ratio / Not used
# POPULATION - Something wrong with population. This data is taken in Script 1 from GLEAM_bulk
# AF_FRAC - sows to total herd / Not used at the moment
# DISCHARGE & DISCARGE - Used by NUE / Not used at the moment
# DWG - daily weight gain / Not used at the moment
# FISHPOND, INCINERATION, PUBLSEWAGE - used in NUE / Not used at the moment
# CLIM ???????

#chicken_only_variables <- c("A2S", "AF1KG", "AF2KG", "AFS", "AM1KG", "AM2KG", "BIDLE", "CLTSIZE", "CYCLE",
#                            "DRL2", "DRM", "EGGSYEAR", "EGGWGHT", "EGG_PROTEIN", "FRMF", "HATCH",
#                            "LAYTIME1", "LAYTIME2", "MALE", "MOLT", "MOLTTIME")

#wide_dt <- wide_dt[, !chicken_only_variables, with = FALSE]
# // THOSE VARIABLES ARE ONLY FOR CHICKENS. FOR NOW I WOULD KEEP THEM OUT TO AVOID MESS

# PROPOSAL:
# KEEPING WITH ALL CAPITAL LETTERS THE VARIABLES THAT CAN BE REMOVED AFTER THE HERD PREPROC
col_rename_map <- c(
  AFC = "afc",
  WKG= "wkg",
  BFM = "bone_free_meat_fraction",
  CKG = "ckg",
  DR1 = "dr1",
  DRESS = "carcass_dressing_percentage",
  FR = "parturition_rate",
  FBR = "female_birth_fraction",
  GEST = "gest",
  HOUR = "work_hours",
  IDLE = "idle",
  LACT = "lact",
  LINT = "lambing_interval",
  LITSIZE = "litsize",
  MET_PROTEIN = "meat_protein",
  MLK_FAT = "milk_fat",
  MLK_PROTEIN = "milk_protein",
  MLK_YIELD = "milk_yield"
)
setnames(wide_dt, old = names(col_rename_map), new = unname(col_rename_map))









# Reorder
setcolorder(wide_dt, c(
  "LPS", "LPS_short", "HerdType", "HerdType_short",
  "Animal", "Animal_short",
  "ADM0_CODE", "ISO3", "ISO3_num", "M49_code", "COUNTRY",
  "RegionClass",  "CLIM", "CLIMATE_ZONE", "TEMPERATURE",  "AFCM",
  "AFKG", "AMKG", "BCR", "DR1M", "DR2", "DRF", "DRR2A", "DRR2B",
  "DWG2", "FRRF", "FRMF","LW", "M2SKG", "MFSKG","MMSKG", "RRF", "RRM", "BIDLE",
  "CLTSIZE","CYCLE","HATCH","LAYTIME1","LAYTIME2","MOLTTIME","MALE","MOLT","WA"
))


# Assigning 1 to all litsize
wide_dt[!(Animal_short %in% c("PGS", "CHK")), litsize := 1]


wide_dt[, energy_onfarm:=0] #this should be in kWh

# Assigning "parturition rate" to chickens, correponding to eggs hatching rate
wide_dt[Animal_short %in% c("CHK"), parturition_rate := HATCH]

# END VARIABLES RENAMING-----

fwrite(
  wide_dt, system.file("extdata/GLEAM_input_herd.csv", package = "gleam")
)
