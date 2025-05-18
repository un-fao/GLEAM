library(data.table)

# Load herd simulation functions
source("Functions/01_functions_herd_steady1_dailysteps.R")

# Read input
herd_data <- fread("Inputs/GLEAM_input_herd.csv")

# --- Function 1: Fecundity ------------------------------------------------------
herd_data[, c("female_fecundity", "male_fecundity") := compute_fecundity_rates(
  part_rate = parturition_rate,
  prolif_rate = litsize,
  fem_birth_ratio = female_birth_fraction
), by = seq_len(nrow(herd_data))]

# --- Function 2: Transition Probabilities ---------------------------------------
transition_cols <- names(
  unlist(
    compute_transition_probabilities(
      duration = as.numeric(
        herd_data[1, .(
          duration.FJ, duration.FS, duration.FA, duration.MJ, duration.MS, duration.MA
        )]
      ),
      offtake_rate = as.numeric(
        herd_data[1, .(
          offtake_rate.FJ, offtake_rate.FS, offtake_rate.FA, offtake_rate.MJ,
          offtake_rate.MS, offtake_rate.MA
        )]
      ),
      death_rate = as.numeric(
        herd_data[1, .(
          mort_rate.FJ, mort_rate.FS, mort_rate.FA, mort_rate.MJ, mort_rate.MS,
          mort_rate.MA
        )]
      )
    )
  )
)

herd_data[, (transition_cols) := as.list(
  unlist(
    compute_transition_probabilities(
      duration = as.numeric(
        .(duration.FJ, duration.FS, duration.FA, duration.MJ, duration.MS, duration.MA)
      ),
      offtake_rate = as.numeric(
        .(offtake_rate.FJ, offtake_rate.FS, offtake_rate.FA, offtake_rate.MJ,
          offtake_rate.MS, offtake_rate.MA)
      ),
      death_rate = as.numeric(
        .(mort_rate.FJ, mort_rate.FS, mort_rate.FA, mort_rate.MJ, mort_rate.MS, mort_rate.MA)
      )
    )
  )
), by = seq_len(nrow(herd_data))]

# --- Function 3: Steady-State Structure -----------------------------------------
x_start <- c(100, 50, 30, 100, 50, 30)
max_years <- 100
lambda_tol <- 1e-9

structure_cols <- names(
  unlist(
    simulate_steady_state_structure(
      x_start = x_start,
      max_years = max_years,
      min_lambda_change = lambda_tol,
      female_fecundity = herd_data[1, female_fecundity],
      male_fecundity = herd_data[1, male_fecundity],
      pdea = as.numeric(
        herd_data[1, c(
          "pdea.FB", "pdea.FJ", "pdea.FS", "pdea.FA", "pdea.FC", "pdea.MB", "pdea.MJ",
          "pdea.MS", "pdea.MA", "pdea.MC"
        )]
      ),
      poff = as.numeric(
        herd_data[1, c(
          "poff.FB", "poff.FJ", "poff.FS", "poff.FA", "poff.FC", "poff.MB", "poff.MJ",
          "poff.MS", "poff.MA", "poff.MC"
        )]
      ),
      g = as.numeric(
        herd_data[1, c(
          "g.FB", "g.FJ", "g.FS", "g.FA", "g.FC", "g.MB", "g.MJ", "g.MS", "g.MA", "g.MC"
        )]
      )
    )
  )
)

herd_data[, (structure_cols) := as.list(
  unlist(
    simulate_steady_state_structure(
      x_start = x_start,
      max_years = max_years,
      min_lambda_change = lambda_tol,
      female_fecundity = female_fecundity,
      male_fecundity = male_fecundity,
      pdea = as.numeric(
        .(pdea.FB, pdea.FJ, pdea.FS, pdea.FA, pdea.FC, pdea.MB, pdea.MJ, pdea.MS, pdea.MA, pdea.MC)
      ),
      poff = as.numeric(
        .(poff.FB, poff.FJ, poff.FS, poff.FA, poff.FC, poff.MB, poff.MJ, poff.MS, poff.MA, poff.MC)
      ),
      g = as.numeric(
        .(g.FB, g.FJ, g.FS, g.FA, g.FC, g.MB, g.MJ, g.MS, g.MA, g.MC)
      )
    )
  )
), by = seq_len(nrow(herd_data))]

# --- Function 4: Population Size -----------------------------------------------
popsize_cols <- names(
  unlist(
    project_population_size(
      size_total = herd_data[1, size_total],
      female_fecundity = herd_data[1, female_fecundity],
      male_fecundity = herd_data[1, male_fecundity],
      pdea = as.numeric(
        herd_data[1, c("pdea.FB", "pdea.FJ", "pdea.FS", "pdea.FA", "pdea.FC", "pdea.MB", "pdea.MJ",
                     "pdea.MS", "pdea.MA", "pdea.MC")]
      ),
      poff = as.numeric(
        herd_data[1, c("poff.FB", "poff.FJ", "poff.FS", "poff.FA", "poff.FC", "poff.MB", "poff.MJ",
                     "poff.MS", "poff.MA", "poff.MC")]
      ),
      g = as.numeric(
        herd_data[1, c("g.FB", "g.FJ", "g.FS", "g.FA", "g.FC", "g.MB", "g.MJ", "g.MS", "g.MA", "g.MC")]
      ),
      growth_rate_pop = herd_data[1, growth_rate_pop],
      structure = as.numeric(
        herd_data[1, c("structure.FB", "structure.FJ", "structure.FS", "structure.FA",
                     "structure.MB", "structure.MJ", "structure.MS", "structure.MA")]
      ),
      share = as.numeric(
        herd_data[1, c("share.FJ", "share.FS", "share.FA", "share.MJ", "share.MS", "share.MA")]
      )
    )
  )
)

herd_data[, (popsize_cols) := as.list(
  unlist(
    project_population_size(
      size_total = size_total,
      female_fecundity = female_fecundity,
      male_fecundity = male_fecundity,
      pdea = as.numeric(
        .(pdea.FB, pdea.FJ, pdea.FS, pdea.FA, pdea.FC, pdea.MB, pdea.MJ, pdea.MS, pdea.MA, pdea.MC)
      ),
      poff = as.numeric(
        .(poff.FB, poff.FJ, poff.FS, poff.FA, poff.FC, poff.MB, poff.MJ, poff.MS, poff.MA, poff.MC)
      ),
      g = as.numeric(
        .(g.FB, g.FJ, g.FS, g.FA, g.FC, g.MB, g.MJ, g.MS, g.MA, g.MC)
      ),
      growth_rate_pop = growth_rate_pop,
      structure = as.numeric(
        .(structure.FB, structure.FJ, structure.FS, structure.FA, structure.MB, structure.MJ,
          structure.MS, structure.MA)
      ),
      share = as.numeric(
        .(share.FJ, share.FS, share.FA, share.MJ, share.MS, share.MA)
      )
    )
  )
), by = seq_len(nrow(herd_data))]

# --- Function 5: Offtake Summary -----------------------------------------------
offtake_cols <- names(
  unlist(
    summarise_offtake(
      size = as.numeric(
        herd_data[1, c("size.FJ", "size.FS", "size.FA", "size.MJ", "size.MS", "size.MA")]
      ),
      size_end = as.numeric(
        herd_data[1, c("size_end.FJ", "size_end.FS", "size_end.FA", "size_end.MJ", "size_end.MS",
                     "size_end.MA")]
      ),
      size_avg = as.numeric(
        herd_data[1, c("size_avg.FJ", "size_avg.FS", "size_avg.FA", "size_avg.MJ", "size_avg.MS",
                     "size_avg.MA")]
      ),
      offtake = as.numeric(
        herd_data[1, c("offtake.FB", "offtake.FJ", "offtake.FS", "offtake.FA", "offtake.FC",
                     "offtake.MB", "offtake.MJ", "offtake.MS", "offtake.MA", "offtake.MC")]
      )
    )
  )
)

herd_data[, (offtake_cols) := as.list(
  unlist(
    summarise_offtake(
      size = as.numeric(
        .(size.FJ, size.FS, size.FA, size.MJ, size.MS, size.MA)
      ),
      size_end = as.numeric(
        .(size_end.FJ, size_end.FS, size_end.FA, size_end.MJ, size_end.MS, size_end.MA)
      ),
      size_avg = as.numeric(
        .(size_avg.FJ, size_avg.FS, size_avg.FA, size_avg.MJ, size_avg.MS, size_avg.MA)
      ),
      offtake = as.numeric(
        .(offtake.FB, offtake.FJ, offtake.FS, offtake.FA, offtake.FC, offtake.MB, offtake.MJ,
          offtake.MS, offtake.MA, offtake.MC)
      )
    )
  )
), by = seq_len(nrow(herd_data))]

# --- Output Export ------------------------------------------------------------
cols_all <- names(herd_data)
col_start <- which(cols_all == "LPS")
col_end <- which(cols_all == "fibre_prod")

extra_cols <- c(
  "share.FJ", "share.FS", "share.FA", "share.MJ", "share.MS", "share.MA",
  "growth_rate_pop", "size.FJ", "size.FS", "size.FA", "size.MJ", "size.MS", "size.MA",
  "offtake_number.FJ", "offtake_number.FS", "offtake_number.FA",
  "offtake_number.MJ", "offtake_number.MS", "offtake_number.MA"
)

final_cols <- c(cols_all[col_start:col_end], extra_cols)

#fwrite(herd_data[, ..final_cols], "Inputs/GLEAM_input_herdproc.csv")
#rm(col_start, col_end, extra_cols)
