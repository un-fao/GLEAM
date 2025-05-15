#' Run Herd Simulation (Internal)
#'
#' Performs the full steady-state demographic simulation of herd cohorts across species,
#' production systems, and countries. This includes modeling of fecundity, mortality, offtake,
#' cohort transitions, population structure, and final population sizes.
#'
#' In addition to demographic simulation, this function reshapes cohort-level variables from wide
#' to long format and back, and calculates key animal weights (initial, final, slaughter, average),
#' as well as daily weight gain (DWG). It also fills in weaning weights for non-pig animals
#' based on FS cohorts.
#'
#' This function is intended for internal use.
#'
#' @param herd_data A `data.table` containing herd-level input parameters per country/animal/LPS.
#'   It must include cohort durations, offtake and mortality rates, fecundity inputs,
#'   liveweights, and classification columns (e.g., `Animal`, `LPS`, `HerdType`, etc.).
#' @param initial_structure A numeric vector of initial values used to simulate population dynamics for the
#'   6 sex-age classes (FJ, FS, FA, MJ, MS, MA). Defaults to `c(100, 50, 30, 100, 50, 30)`.
#' @param max_years Integer. Maximum number of simulation years to run when seeking a steady-state
#'   population structure. Defaults to `100`.
#' @param lambda_threshold Numeric. Tolerance threshold for detecting convergence in growth rate (`lambda`)
#'   changes across cohorts. Defaults to `1e-9`.
#'
#' @return A `data.table` in long format (per cohort) with appended simulation results,
#'   including:
#'   - population structure and sizes
#'   - offtake numbers
#'   - transition probabilities
#'   - cohort-level liveweights and weight gain
#'
#' @keywords internal
#'
#' @importFrom data.table := .SD .I melt dcast setcolorder
run_herd_simulation <- function(
    herd_data,
    initial_structure = c(100, 50, 30, 100, 50, 30),
    max_years = 100,
    lambda_threshold = 1e-9
    ) {

  # --- Step 1: Compute Core Demographic Parameters -----------------------------

  # Compute fecundity rates
  herd_data[, c("female_fecundity", "male_fecundity") := compute_fecundity_rates(
    part_rate = parturition_rate,
    prolif_rate = litsize,
    fem_birth_ratio = female_birth_fraction
  ), by = seq_len(nrow(herd_data))]

  # Compute transition probabilities
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

  # --- Step 2: Simulate Population Dynamics -----------------------------------

  # Simulate steady-state structure
  structure_cols <- names(
    unlist(
      simulate_steady_state_structure(
        initial_structure = initial_structure,
        max_years = max_years,
        min_lambda_change = lambda_threshold,
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
        initial_structure = initial_structure,
        max_years = max_years,
        min_lambda_change = lambda_threshold,
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

  # Project population size
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

  # --- Step 3: Calculate Offtake and Weights ---------------------------------

  # Calculate offtake summary
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

  # --- Step 4: Filter and Prepare Data for Reshaping -------------------------

  # Define columns to keep
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
  herd_data <- herd_data[, ..final_cols]

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

  # --- Step 5: Reshape Data and Calculate Final Metrics ----------------------

  # Reshape to long format
  herd_long <- melt(
    herd_data[, .SD, .SDcols = c(id_cols, cohort_cols)],
    id.vars = id_cols,
    variable.name = "variable",
    value.name = "value"
  )

  # Split variable column into 'item' and 'cohort'
  herd_long[, `:=`(
    item = sub("\\..*$", "", variable),
    cohort = ifelse(
      grepl("\\.", variable),
      sub("^[^.]*\\.", "", variable),
      NA_character_
    )
  )]

  # Reshape to wide by item
  herd_wide <- dcast(
    herd_long,
    LPS + HerdType + Animal + ADM0_CODE + ISO3 + ISO3_num +
      RegionClass + COUNTRY + M49_code + cohort + RegionClass ~ item,
    value.var = "value"
  )

  # Merge with static herd data
  herd_merged <- merge(
    herd_data[, .SD, .SDcols = setdiff(names(herd_data), cohort_cols)],
    herd_wide,
    by = id_cols,
    all.x = TRUE
  )

  # Set preferred column order
  setcolorder(herd_merged, c(
    "LPS", "LPS_short", "HerdType", "HerdType_short",
    "Animal", "Animal_short",
    "ADM0_CODE", "ISO3", "ISO3_num", "M49_code",
    "RegionClass", "COUNTRY"
  ))

  # Calculate weights
  herd_merged[, c("initialLW", "potfinalLW", "slaughterLW") :=
                calc_cohort_weights(
                  Animal_short, cohort, AFKG, AMKG, CKG = ckg, MFSKG, MMSKG, WKG = wkg, AFC = afc, WA
                ),
              by = .I
  ]

  herd_merged[, c("averageLW", "finalLW") :=
                calc_avg_weights(initialLW, potfinalLW, slaughterLW, offtake_rate),
              by = .I
  ]

  herd_merged[, dwg := calc_daily_gain(potfinalLW, initialLW, duration), by = .I]

  # Assign weaning weights for non-pig cohorts using FS values
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

  # Remove unused columns
  cols_to_drop <- c(
    "AFCM", "AFKG", "AMKG", "BCR", "DR1M", "DR2", "DRF", "DRR2A", "DRR2B",
    "DWG2", "FRRF", "LW", "M2SKG", "MFSKG", "RRF", "RRM", "WA", "MMSKG"
  )

  herd_final <- herd_merged[, !..cols_to_drop]

  return(herd_final)
}
