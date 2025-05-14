library(data.table)

# FUNCTIONS
source("Functions/01_functions_herd_steady1_dailysteps.R")

# INPUT PARAMETERS
herd_data <- fread("Inputs/GLEAM_input_herd.csv")

# STEADY 1
# # Function 1: Fecundity -------------------------------------------------------
herd_data[, c("female_fecundity", "male_fecundity") := compute_fecundity_rates(
  part_rate = parturition_rate,
  prolif_rate = litsize,
  fem_birth_ratio = female_birth_fraction
), by = seq_len(nrow(herd_data))]

# # Function 2: Probabilities ---------------------------------------------------
# # #  Defining the vector names to be used for outputs, through a run of the function for the first record
vecNames.f2 <- names(unlist(
  compute_transition_probabilities(
    duration = as.numeric(herd_data[1, .(duration.FJ, duration.FS, duration.FA, duration.MJ, duration.MS, duration.MA)]),
    offtake_rate = as.numeric(herd_data[1, .(offtake_rate.FJ, offtake_rate.FS, offtake_rate.FA, offtake_rate.MJ, offtake_rate.MS, offtake_rate.MA)]),
    death_rate = as.numeric(herd_data[1, .(mort_rate.FJ, mort_rate.FS, mort_rate.FA, mort_rate.MJ, mort_rate.MS, mort_rate.MA)])
  )
))
# # #  Running the function for the data table
herd_data[, (vecNames.f2) := as.list(unlist(
  compute_transition_probabilities(
    duration = as.numeric(.(duration.FJ, duration.FS, duration.FA, duration.MJ, duration.MS, duration.MA)),
    offtake_rate = as.numeric(.(offtake_rate.FJ, offtake_rate.FS, offtake_rate.FA, offtake_rate.MJ, offtake_rate.MS, offtake_rate.MA)),
    death_rate = as.numeric(.(mort_rate.FJ, mort_rate.FS, mort_rate.FA, mort_rate.MJ, mort_rate.MS, mort_rate.MA))
  )
)), by = seq_len(nrow(herd_data))]

# # Function 3: Population Structure ---------------------------------------------------

# # #  Defining default parameters
x_start <- c(100, 50, 30, 100, 50, 30) # these cab be any random values, they are taken directly from the Dynmod worksheet
max_years <- 100
min_lambda_change <- 0.000000001 # these can make a big difference depending on the time steps considered.

# # #  Defining the vector names to be used for outputs, through a run of the function for the first record
vecNames.f3 <- names(unlist(
  simulate_steady_state_structure(
    x_start = x_start,
    max_years = max_years,
    min_lambda_change = min_lambda_change,
    female_fecundity = herd_data[1, female_fecundity],
    male_fecundity = herd_data[1, male_fecundity],
    pdea = as.numeric(herd_data[1, c("pdea.FB", "pdea.FJ", "pdea.FS", "pdea.FA", "pdea.FC", "pdea.MB", "pdea.MJ", "pdea.MS", "pdea.MA", "pdea.MC")]),
    poff = as.numeric(herd_data[1, c("poff.FB", "poff.FJ", "poff.FS", "poff.FA", "poff.FC", "poff.MB", "poff.MJ", "poff.MS", "poff.MA", "poff.MC")]),
    g = as.numeric(herd_data[1, c("g.FB", "g.FJ", "g.FS", "g.FA", "g.FC", "g.MB", "g.MJ", "g.MS", "g.MA", "g.MC")])
  )
))

# # #  Running the function for the data table
herd_data[, (vecNames.f3) := as.list(unlist(
  simulate_steady_state_structure(
    x_start = x_start,
    max_years = max_years,
    min_lambda_change = min_lambda_change,
    female_fecundity = female_fecundity,
    male_fecundity = male_fecundity,
    pdea = as.numeric(.(pdea.FB, pdea.FJ, pdea.FS, pdea.FA, pdea.FC, pdea.MB, pdea.MJ, pdea.MS, pdea.MA, pdea.MC)),
    poff = as.numeric(.(poff.FB, poff.FJ, poff.FS, poff.FA, poff.FC, poff.MB, poff.MJ, poff.MS, poff.MA, poff.MC)),
    g = as.numeric(.(g.FB, g.FJ, g.FS, g.FA, g.FC, g.MB, g.MJ, g.MS, g.MA, g.MC))
  )
)), by = seq_len(nrow(herd_data))]

# # Function 4: Population Size ---------------------------------------------------

# # #  Defining the vector names to be used for outputs, through a run of the function for the first record
vecNames.f4 <- names(unlist(
  project_population_size(
    size_total = herd_data[1, size_total],
    female_fecundity = herd_data[1, female_fecundity],
    male_fecundity = herd_data[1, male_fecundity],
    pdea = as.numeric(herd_data[1, c("pdea.FB", "pdea.FJ", "pdea.FS", "pdea.FA", "pdea.FC", "pdea.MB", "pdea.MJ", "pdea.MS", "pdea.MA", "pdea.MC")]),
    poff = as.numeric(herd_data[1, c("poff.FB", "poff.FJ", "poff.FS", "poff.FA", "poff.FC", "poff.MB", "poff.MJ", "poff.MS", "poff.MA", "poff.MC")]),
    g = as.numeric(herd_data[1, c("g.FB", "g.FJ", "g.FS", "g.FA", "g.FC", "g.MB", "g.MJ", "g.MS", "g.MA", "g.MC")]),
    growth_rate_pop = herd_data[1, growth_rate_pop],
    structure = as.numeric(herd_data[1, c("structure.FB", "structure.FJ", "structure.FS", "structure.FA", "structure.MB", "structure.MJ", "structure.MS", "structure.MA")]),
    share = as.numeric(herd_data[1, c("share.FJ", "share.FS", "share.FA", "share.MJ", "share.MS", "share.MA")])
  )
))

# # #  Running the function for the data table
herd_data[, (vecNames.f4) := as.list(unlist(
  project_population_size(
    size_total = size_total,
    female_fecundity = female_fecundity,
    male_fecundity = male_fecundity,
    pdea = as.numeric(.(pdea.FB, pdea.FJ, pdea.FS, pdea.FA, pdea.FC, pdea.MB, pdea.MJ, pdea.MS, pdea.MA, pdea.MC)),
    poff = as.numeric(.(poff.FB, poff.FJ, poff.FS, poff.FA, poff.FC, poff.MB, poff.MJ, poff.MS, poff.MA, poff.MC)),
    g = as.numeric(.(g.FB, g.FJ, g.FS, g.FA, g.FC, g.MB, g.MJ, g.MS, g.MA, g.MC)),
    growth_rate_pop = growth_rate_pop,
    structure = as.numeric(.(structure.FB, structure.FJ, structure.FS, structure.FA, structure.MB, structure.MJ, structure.MS, structure.MA)),
    share = as.numeric(.(share.FJ, share.FS, share.FA, share.MJ, share.MS, share.MA))
  )
)), by = seq_len(nrow(herd_data))]


# # Function 5: Production Offtake ---------------------------------------------------

# # #  Defining the vector names to be used for outputs, through a run of the function for the first record
vecNames.f5 <- names(unlist(
  summarise_offtake(
    size = as.numeric(herd_data[1, c("size.FJ", "size.FS", "size.FA", "size.MJ", "size.MS", "size.MA")]),
    size_end = as.numeric(herd_data[1, c("size_end.FJ", "size_end.FS", "size_end.FA", "size_end.MJ", "size_end.MS", "size_end.MA")]),
    size_avg = as.numeric(herd_data[1, c("size_avg.FJ", "size_avg.FS", "size_avg.FA", "size_avg.MJ", "size_avg.MS", "size_avg.MA")]),
    offtake = as.numeric(herd_data[1, c("offtake.FB", "offtake.FJ", "offtake.FS", "offtake.FA", "offtake.FC", "offtake.MB", "offtake.MJ", "offtake.MS", "offtake.MA", "offtake.MC")])
  )
))

# # #  Running the function for the data table
herd_data[, (vecNames.f5) := as.list(unlist(
  summarise_offtake(
    size = as.numeric(.(size.FJ, size.FS, size.FA, size.MJ, size.MS, size.MA)),
    size_end = as.numeric(.(size_end.FJ, size_end.FS, size_end.FA, size_end.MJ, size_end.MS, size_end.MA)),
    size_avg = as.numeric(.(size_avg.FJ, size_avg.FS, size_avg.FA, size_avg.MJ, size_avg.MS, size_avg.MA)),
    offtake = as.numeric(.(offtake.FB, offtake.FJ, offtake.FS, offtake.FA, offtake.FC, offtake.MB, offtake.MJ, offtake.MS, offtake.MA, offtake.MC))
  )
)), by = seq_len(nrow(herd_data))]

# Output selection
# * Only some of the outputs produced are currently required by GLEAM


# NOW WORKING!!!!!! ---
names(herd_data)
cols <- names(herd_data)
start <- which(cols == "LPS")
end <- which(cols == "fibre_prod")
extra_cols <- c(
  "share.FJ", "share.FS", "share.FA", "share.MJ", "share.MS", "share.MA",
  "growth_rate_pop",
  "size.FJ", "size.FS", "size.FA", "size.MJ", "size.MS", "size.MA",
  "offtake_number.FJ", "offtake_number.FS", "offtake_number.FA",
  "offtake_number.MJ", "offtake_number.MS", "offtake_number.MA"
)

fwrite(herd_data[, c(cols[start:end], extra_cols), with = FALSE], "Inputs/GLEAM_input_herdproc.csv")
rm(start)
rm(end)
rm(extra_cols)