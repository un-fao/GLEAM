library(data.table)

# upload functions
source("Functions/02_functions_afterHerd_preprocessing.R")


# upload inputs
out_herd.dt <- fread("Inputs//GLEAM_input_herdproc.csv")

id.vars <- c(
  "LPS", "HerdType", "Animal", "ADM0_CODE", "ISO3",
  "ISO3_num", "M49_code", "RegionClass", "COUNTRY"
) # columns as id
cohort.vars <- c(
  "offtake_rate.FJ", "offtake_rate.FS", "offtake_rate.FA",
  "offtake_rate.MJ", "offtake_rate.MS", "offtake_rate.MA",
  "mort_rate.FJ", "mort_rate.FS", "mort_rate.FA",
  "mort_rate.MJ", "mort_rate.MS", "mort_rate.MA",
  "duration.FJ", "duration.FS", "duration.FA",
  "duration.MJ", "duration.MS", "duration.MA",
  "share.FJ", "share.FS", "share.FA", "share.MJ", "share.MS", "share.MA",
  "size.FJ", "size.FS", "size.FA", "size.MJ", "size.MS", "size.MA",
  "offtake_number.FJ", "offtake_number.FS", "offtake_number.FA",
  "offtake_number.MJ", "offtake_number.MS", "offtake_number.MA"
)

herd_pop <- out_herd.dt[, .SD, .SDcols = setdiff(names(out_herd.dt), cohort.vars)]

herd_tolong <- out_herd.dt[, .SD, .SDcols = c(id.vars, cohort.vars)]

# Reshape from wide to long format
long_format <- melt(
  herd_tolong,
  id.vars = id.vars,
  variable.name = "variable",
  value.name = "value"
)

# Split the 'variable' into 'item' and 'cohort' using a custom approach
long_format[, `:=`(
  item = sub("\\..*$", "", variable), # Remove everything after the period
  cohort = ifelse(
    grepl("\\.", variable), # Check if there is a period
    sub("^[^.]*\\.", "", variable), # Remove everything before and including the period
    NA_character_
  ) # Assign NA if there is no period
)]


long_format <- dcast(
  long_format,
  LPS + HerdType + Animal + ADM0_CODE + ISO3 + ISO3_num + RegionClass +
    COUNTRY + M49_code + cohort + RegionClass ~ item,
  value.var = "value"
)

GLEAM_input_feed_preproc <- merge(herd_pop, long_format, by = id.vars, all.x = TRUE)

setcolorder(
  GLEAM_input_feed_preproc,
  c(
    "LPS", "LPS_short", "HerdType", "HerdType_short",
    "Animal", "Animal_short",
    "ADM0_CODE", "ISO3", "ISO3_num", "M49_code",
    "RegionClass", "COUNTRY"
  )
)


# add weights----
GLEAM_input_feed_preproc[, c("initialLW", "potfinalLW", "slaughterLW") :=
                           get.stepLW(
                             Animal_short, cohort, AFKG, AMKG, CKG = ckg, MFSKG,
                             MMSKG, WKG = wkg, AFC = afc, WA
                           ),
                         by = .I]

GLEAM_input_feed_preproc[, c("averageLW", "finalLW") :=
                           get.otherLW(initialLW, potfinalLW, slaughterLW, offtake_rate),
                         by = .I]

# add new daily weight gain----
GLEAM_input_feed_preproc[, "dwg" :=
                           get.dwg(potfinalLW, initialLW, duration),
                         by = .I]

# new column need to be generated with WKG also for other species than PIGS (it is used in energy requirements)
# FS and MS have the same weaning weight - filtering only for one
weaning.dt <- GLEAM_input_feed_preproc[cohort %in% c("FS") & Animal_short != "PGS", .(
  COUNTRY, ADM0_CODE, Animal_short, LPS_short, HerdType_short, cohort,
  initialLW
)]
GLEAM_input_feed_preproc[
  Animal_short != "PGS",
  wkg := weaning.dt[
    .SD, on = .(COUNTRY, ADM0_CODE, Animal_short, LPS_short, HerdType_short), initialLW
  ]
]

# select only needed columns
drop <- c(
  "AFCM", "AFKG", "AMKG", "BCR", "DR1M", "DR2", "DRF", "DRR2A", "DRR2B",
  "DWG2", "FRRF", "LW", "M2SKG", "MFSKG", "RRF", "RRM", "WA", "MMSKG"
)

GLEAM_input_feed_preproc <- GLEAM_input_feed_preproc[, !..drop]

fwrite(GLEAM_input_feed_preproc, "Inputs/GLEAM_input_feed.csv")
