library(data.table)

# Load required functions
source("Functions/02_functions_afterHerd_preprocessing.R")

# Read processed herd data
herd_data <- fread("Inputs/GLEAM_input_herdproc.csv")

# Define ID and cohort-specific columns
id_cols <- c(
  "LPS", "HerdType", "Animal", "ADM0_CODE", "ISO3",
  "ISO3_num", "M49_code", "RegionClass", "COUNTRY"
)

cohort_cols <- c(
  "offtake_rate.FJ", "offtake_rate.FS", "offtake_rate.FA",
  "offtake_rate.MJ", "offtake_rate.MS", "offtake_rate.MA",
  "mort_rate.FJ", "mort_rate.FS", "mort_rate.FA",
  "mort_rate.MJ", "mort_rate.MS", "mort_rate.MA",
  "duration.FJ", "duration.FS", "duration.FA",
  "duration.MJ", "duration.MS", "duration.MA",
  "share.FJ", "share.FS", "share.FA",
  "share.MJ", "share.MS", "share.MA",
  "size.FJ", "size.FS", "size.FA",
  "size.MJ", "size.MS", "size.MA",
  "offtake_number.FJ", "offtake_number.FS", "offtake_number.FA",
  "offtake_number.MJ", "offtake_number.MS", "offtake_number.MA"
)

# Separate out non-cohort data and prepare long-format data
herd_meta <- herd_data[, .SD, .SDcols = setdiff(names(herd_data), cohort_cols)]
herd_long <- herd_data[, .SD, .SDcols = c(id_cols, cohort_cols)]

# Reshape to long format
long_dt <- melt(
  herd_long,
  id.vars = id_cols,
  variable.name = "variable",
  value.name = "value"
)

# Split variable column into 'item' and 'cohort'
long_dt[, `:=`(
  item = sub("\\..*$", "", variable),
  cohort = ifelse(
    grepl("\\.", variable),
    sub("^[^.]*\\.", "", variable),
    NA_character_
  )
)]

# Reshape to wide by item
herd_wide <- dcast(
  long_dt,
  LPS + HerdType + Animal + ADM0_CODE + ISO3 + ISO3_num +
    RegionClass + COUNTRY + M49_code + cohort + RegionClass ~ item,
  value.var = "value"
)

# Merge with static herd data
herd_merged <- merge(herd_meta, herd_wide, by = id_cols, all.x = TRUE)

# Set preferred column order
setcolorder(herd_merged, c(
  "LPS", "LPS_short", "HerdType", "HerdType_short",
  "Animal", "Animal_short",
  "ADM0_CODE", "ISO3", "ISO3_num", "M49_code",
  "RegionClass", "COUNTRY"
))

# Add cohort-specific weights
herd_merged[, c("initialLW", "potfinalLW", "slaughterLW") :=
              calc_cohort_weights(
                Animal_short, cohort, AFKG, AMKG, CKG = ckg, MFSKG, MMSKG, WKG = wkg, AFC = afc, WA
              ),
            by = .I
]

# Add average and final weights
herd_merged[, c("averageLW", "finalLW") :=
              calc_avg_weights(initialLW, potfinalLW, slaughterLW, offtake_rate),
            by = .I
]

# Add daily weight gain
herd_merged[, dwg := calc_daily_gain(potfinalLW, initialLW, duration), by = .I]

# Assign weaning weights (WKG) for non-pig cohorts using FS values
weaning_dt <- herd_merged[
  cohort == "FS" & Animal_short != "PGS",
  .(COUNTRY, ADM0_CODE, Animal_short, LPS_short, HerdType_short, cohort, initialLW)
]

herd_merged[
  Animal_short != "PGS",
  wkg := weaning_dt[
    .SD,
    on = .(COUNTRY, ADM0_CODE, Animal_short, LPS_short, HerdType_short),
    initialLW
  ]
]

# Drop unused columns
cols_to_drop <- c(
  "AFCM", "AFKG", "AMKG", "BCR", "DR1M", "DR2", "DRF", "DRR2A", "DRR2B",
  "DWG2", "FRRF", "LW", "M2SKG", "MFSKG", "RRF", "RRM", "WA", "MMSKG"
)

herd_final <- herd_merged[, !..cols_to_drop]

# Optional: assign final object
GLEAM_input_feed_preproc <- herd_final
