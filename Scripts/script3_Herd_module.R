library(data.table)

# FUNCTIONS
source("Functions//01_functions_herd_steady1_dailysteps.R")

# INPUT PARAMETERS
herd.dt <- fread("Inputs//GLEAM_input_herd.csv")

# STEADY 1
# # Function 1: Fecundity -------------------------------------------------------
herd.dt[, c("fecF", "fecM") := S1_01_Fecundity(
  parturition_rate, litsize, female_birth_fraction), by = seq_len(nrow(herd.dt))]

# # Function 2: Probabilities ---------------------------------------------------
# # #  Defining the vector names to be used for outputs, through a run of the function for the first record
vecNames.f2 <- names(unlist(
  S1_02_Probabilities(
    as.numeric(herd.dt[1, .(duration.FJ, duration.FS, duration.FA, duration.MJ, duration.MS, duration.MA)]),
    as.numeric(herd.dt[1, .(offtake_rate.FJ, offtake_rate.FS, offtake_rate.FA, offtake_rate.MJ, offtake_rate.MS, offtake_rate.MA)]),
    as.numeric(herd.dt[1, .(mort_rate.FJ, mort_rate.FS, mort_rate.FA, mort_rate.MJ, mort_rate.MS, mort_rate.MA)])
  )
))
# # #  Running the function for the data table
herd.dt[, (vecNames.f2) := as.list(as.vector(unlist(
  S1_02_Probabilities(
    duration = as.numeric(.(duration.FJ, duration.FS, duration.FA, duration.MJ, duration.MS, duration.MA)),
    offtake_rate = as.numeric(.(offtake_rate.FJ, offtake_rate.FS, offtake_rate.FA, offtake_rate.MJ, offtake_rate.MS, offtake_rate.MA)),
    death_rate = as.numeric(.(mort_rate.FJ, mort_rate.FS, mort_rate.FA, mort_rate.MJ, mort_rate.MS, mort_rate.MA))
  )
))), by = seq_len(nrow(herd.dt))]

# # Function 3: Population Structure ---------------------------------------------------

# # #  Defining default parameters
x_start <- c(100, 50, 30, 100, 50, 30) # these cab be any random values, they are taken directly from the Dynmod worksheet
max_years <- 100
min_lambda_change <- 0.000000001 # these can make a big difference depending on the time steps considered.

# # #  Defining the vector names to be used for outputs, through a run of the function for the first record
vecNames.f3 <- names(unlist(
  S1_03_PopStructure(
    x_start, max_years, min_lambda_change, herd.dt[1, fecF], herd.dt[1, fecM],
    as.numeric(herd.dt[1, c("pdea.FB", "pdea.FJ", "pdea.FS", "pdea.FA", "pdea.FC", "pdea.MB", "pdea.MJ", "pdea.MS", "pdea.MA", "pdea.MC")]),
    as.numeric(herd.dt[1, c("poff.FB", "poff.FJ", "poff.FS", "poff.FA", "poff.FC", "poff.MB", "poff.MJ", "poff.MS", "poff.MA", "poff.MC")]),
    as.numeric(herd.dt[1, c("g.FB", "g.FJ", "g.FS", "g.FA", "g.FC", "g.MB", "g.MJ", "g.MS", "g.MA", "g.MC")])
  )
))

# # #  Running the function for the data table
herd.dt[, (vecNames.f3) := as.list(as.vector(unlist(
  S1_03_PopStructure(
    x_start, max_years, min_lambda_change, fecF, fecM,
    pdea = as.numeric(.(pdea.FB, pdea.FJ, pdea.FS, pdea.FA, pdea.FC, pdea.MB, pdea.MJ, pdea.MS, pdea.MA, pdea.MC)),
    poff = as.numeric(.(poff.FB, poff.FJ, poff.FS, poff.FA, poff.FC, poff.MB, poff.MJ, poff.MS, poff.MA, poff.MC)),
    g = as.numeric(.(g.FB, g.FJ, g.FS, g.FA, g.FC, g.MB, g.MJ, g.MS, g.MA, g.MC))
  )
))), by = seq_len(nrow(herd.dt))]

# # Function 4: Population Size ---------------------------------------------------

# # #  Defining the vector names to be used for outputs, through a run of the function for the first record
vecNames.f4 <- names(unlist(
  S1_04_PopSize(
    herd.dt[1, size_total], herd.dt[1, fecF], herd.dt[1, fecM],
    as.numeric(herd.dt[1, c("pdea.FB", "pdea.FJ", "pdea.FS", "pdea.FA", "pdea.FC", "pdea.MB", "pdea.MJ", "pdea.MS", "pdea.MA", "pdea.MC")]),
    as.numeric(herd.dt[1, c("poff.FB", "poff.FJ", "poff.FS", "poff.FA", "poff.FC", "poff.MB", "poff.MJ", "poff.MS", "poff.MA", "poff.MC")]),
    as.numeric(herd.dt[1, c("g.FB", "g.FJ", "g.FS", "g.FA", "g.FC", "g.MB", "g.MJ", "g.MS", "g.MA", "g.MC")]),
    herd.dt[1, growth_rate_pop],
    as.numeric(herd.dt[1, c("structure.FB", "structure.FJ", "structure.FS", "structure.FA", "structure.MB", "structure.MJ", "structure.MS", "structure.MA")]),
    as.numeric(herd.dt[1, c("share.FJ", "share.FS", "share.FA", "share.MJ", "share.MS", "share.MA")])
  )
))

# # #  Running the function for the data table
herd.dt[, (vecNames.f4) := as.list(as.vector(unlist(
  S1_04_PopSize(
    size_total, fecF, fecM,
    pdea = as.numeric(.(pdea.FB, pdea.FJ, pdea.FS, pdea.FA, pdea.FC, pdea.MB, pdea.MJ, pdea.MS, pdea.MA, pdea.MC)),
    poff = as.numeric(.(poff.FB, poff.FJ, poff.FS, poff.FA, poff.FC, poff.MB, poff.MJ, poff.MS, poff.MA, poff.MC)),
    g = as.numeric(.(g.FB, g.FJ, g.FS, g.FA, g.FC, g.MB, g.MJ, g.MS, g.MA, g.MC)),
    growth_rate_pop,
    structure = as.numeric(.(structure.FB, structure.FJ, structure.FS, structure.FA, structure.MB, structure.MJ, structure.MS, structure.MA)),
    share = as.numeric(.(share.FJ, share.FS, share.FA, share.MJ, share.MS, share.MA))
  )
))), by = seq_len(nrow(herd.dt))]


# # Function 5: Production Offtake ---------------------------------------------------

# # #  Defining the vector names to be used for outputs, through a run of the function for the first record
vecNames.f5 <- names(unlist(
  S1_05_ProdOfftake(
    as.numeric(herd.dt[1, c("size.FJ", "size.FS", "size.FA", "size.MJ", "size.MS", "size.MA")]),
    as.numeric(herd.dt[1, c("size_end.FJ", "size_end.FS", "size_end.FA", "size_end.MJ", "size_end.MS", "size_end.MA")]),
    as.numeric(herd.dt[1, c("size_avg.FJ", "size_avg.FS", "size_avg.FA", "size_avg.MJ", "size_avg.MS", "size_avg.MA")]),
    as.numeric(herd.dt[1, c("offtake.FB", "offtake.FJ", "offtake.FS", "offtake.FA", "offtake.FC", "offtake.MB", "offtake.MJ", "offtake.MS", "offtake.MA", "offtake.MC")])
  )
))

# # #  Running the function for the data table
herd.dt[, (vecNames.f5) := as.list(as.vector(unlist(
  S1_05_ProdOfftake(
    size = as.numeric(.(size.FJ, size.FS, size.FA, size.MJ, size.MS, size.MA)),
    size_end = as.numeric(.(size_end.FJ, size_end.FS, size_end.FA, size_end.MJ, size_end.MS, size_end.MA)),
    size_avg = as.numeric(.(size_avg.FJ, size_avg.FS, size_avg.FA, size_avg.MJ, size_avg.MS, size_avg.MA)),
    offtake = as.numeric(.(offtake.FB, offtake.FJ, offtake.FS, offtake.FA, offtake.FC, offtake.MB, offtake.MJ, offtake.MS, offtake.MA, offtake.MC))
  )
))), by = seq_len(nrow(herd.dt))]

# Output selection
# * Only some of the outputs produced are currently required by GLEAM


# NOW WORKING!!!!!! ---
names(herd.dt)
cols <- names(herd.dt)
start <- which(cols == "LPS")
end <- which(cols == "fibre_prod")
extra_cols <- c(
  "share.FJ", "share.FS", "share.FA", "share.MJ", "share.MS", "share.MA",
  "growth_rate_pop",
  "size.FJ", "size.FS", "size.FA", "size.MJ", "size.MS", "size.MA",
  "offtake_number.FJ", "offtake_number.FS", "offtake_number.FA",
  "offtake_number.MJ", "offtake_number.MS", "offtake_number.MA"
)

fwrite(herd.dt[, c(cols[start:end], extra_cols), with = FALSE], "Inputs/GLEAM_input_herdproc.csv")
rm(start)
rm(end)
rm(extra_cols)
