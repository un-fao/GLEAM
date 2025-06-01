library(data.table)


ParameterALLNoCohorts <- fread(
  "your_data_directory/GLEAM_ENGINE/data_input/ParameterALLNoCohorts.csv"
)[RegionClass=="Countries",]
GLEAM_bulk <- fread("your_data_directory/GLEAM_ENGINE/data_input/GLEAMDataALL.csv")
country_list <- fread(
  system.file("extdata/Pre_processing/GAULListUsedByGLEAM_GIUSY_20230316.csv", package = "gleam")
)
past_man_frac_df <- fread(
  system.file("extdata/Pre_processing/variables_calc/past_man_frac/faostat_pastmanfrac.csv", package = "gleam")
)


## from width to long
wide_dt <- dcast(ParameterALLNoCohorts, ISO3 + ISO3_num + RegionClass + ADM0_CODE + Animal + HerdType + LPS + COUNTRY ~ varName, value.var = "V1")

## total stock
wide_dt <- merge(
  wide_dt,
  GLEAM_bulk[VarName=="AnimalNumbers" & !is.na(ADM0_CODE),.(Animal,HerdType,LPS,ADM0_CODE,size_total = V1)],
  by = c("Animal","HerdType","LPS","ADM0_CODE"),
  all.x = T
)
wide_dt[,size_total:=ifelse(is.na(size_total), 0, size_total)]


wide_dt[Animal!="Pigs", LITSIZE:=LSIZE]
wide_dt<-wide_dt[,!c("LSIZE", "LCIDE", "LCIDI", "LCIGE", "LCIME", "LCIN")]


## add M49 code to the dataframe
setnames(country_list, "M49 Code", "M49_code")
country_list<-country_list[,.(ADM0_CODE, M49_code)]

wide_dt <- wide_dt[country_list, on = "ADM0_CODE", nomatch = 0] #Adding M49 code to the dataset


## adding the variable "past_man_frac_df", needed to estimate neact
past_man_frac_df<-past_man_frac_df[,.(M49_code, past_man_frac)]
wide_dt <- wide_dt[past_man_frac_df, on = "M49_code", nomatch = 0] #Adding past_man_frac


## Adding weaning age by default to 60 days - to be implemented with real values
wide_dt[Animal %in% c("Cattle", "Buffalo", "Sheep", "Goats"), WA := 60/365]
## Adding febale birth ratio to 50% - to be implemented with real values
wide_dt[, FBR := 0.5]
## armonizing the names of the slaughter weight of fattening animals from pigs with those from ruminants
wide_dt[Animal == "Pigs", MFSKG := M2SKG]
wide_dt[Animal == "Pigs", MMSKG := M2SKG]


## add animal and herdtype abbreviations to "dat"

abbr_animals <- data.frame(Animal = c("Cattle", "Buffalo", "Sheep", "Goats", "Chicken", "Pigs", "Camels"),
                           Animal_short = c("CTL", "BFL", "SHP", "GTS", "CHK", "PGS", "CML"))
wide_dt <- merge(wide_dt, abbr_animals, by = "Animal")

abbr_herdtypes <- data.frame(HerdType = c("Dairy", "Beef", "Chicken", "Pigs"),
                             HerdType_short = c("DRY", "BEF", "CHK", "PGS"))
wide_dt <- merge(wide_dt, abbr_herdtypes, by = "HerdType")

abbr_LPS <- data.frame(LPS = sort(unique(wide_dt$LPS)),
                       LPS_short = c("BCK", "BRL", "GRS", "IND", "MED", "LYR", "MXD"))
wide_dt <- merge(wide_dt, abbr_LPS, by = "LPS")



fwrite(wide_dt, system.file("extdata/GLEAM_input_preproc.csv", package = "gleam"))


