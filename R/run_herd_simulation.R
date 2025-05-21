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
#' @importFrom stats setNames
run_herd_simulation <- function(
    herd_data,
    initial_structure = c(FJ = 100, FS = 50, FA = 30, MJ = 100, MS = 50, MA = 30),
    max_years = 100,
    lambda_threshold = 1e-9
) {

  # Define cohort name sets used for mortality, structure, and share inputs
  cohorts <- c("FB", "FJ", "FS", "FA", "FC", "MB", "MJ", "MS", "MA", "MC")
  structure_cohorts <- c("FB", "FJ", "FS", "FA", "MB", "MJ", "MS", "MA")
  share_cohorts <- sex_age_classes <- c("FJ", "FS", "FA", "MJ", "MS", "MA")

  # --- Step 1: Compute Core Demographic Parameters -----------------------------

  # Compute fecundity rates
  herd_data[, c("female_fecundity", "male_fecundity") := compute_fecundity_rates(
    part_rate = parturition_rate,
    prolif_rate = litsize,
    fem_birth_ratio = female_birth_fraction
  ), by = seq_len(nrow(herd_data))]

  # Compute transition probabilities
  transition_cols <- names(unlist(
    compute_transition_probabilities(
      duration = setNames(
        unlist(herd_data[1, paste0("duration.", share_cohorts), with = FALSE]),
        share_cohorts
      ),
      offtake_rate = setNames(
        unlist(herd_data[1, paste0("offtake_rate.", share_cohorts), with = FALSE]),
        share_cohorts
      ),
      death_rate = setNames(
        unlist(herd_data[1, paste0("mort_rate.", share_cohorts), with = FALSE]),
        share_cohorts
      )
    )
  ))

  # Apply transition probability computation row-wise
  herd_data[, (transition_cols) := as.list(unlist(
    compute_transition_probabilities(
      duration = setNames(
        unlist(.SD[, paste0("duration.", share_cohorts), with = FALSE]),
        share_cohorts
      ),
      offtake_rate = setNames(
        unlist(.SD[, paste0("offtake_rate.", share_cohorts), with = FALSE]),
        share_cohorts
      ),
      death_rate = setNames(
        unlist(.SD[, paste0("mort_rate.", share_cohorts), with = FALSE]),
        share_cohorts
      )
    )
  )), by = seq_len(nrow(herd_data))]

  # --- Step 2: Simulate Population Dynamics -----------------------------------

  # Simulate steady-state structure

  # Get structure column names from a sample run
  structure_cols <- names(unlist(
    simulate_steady_state_structure(
      initial_structure = initial_structure,
      max_years = max_years,
      min_lambda_change = lambda_threshold,
      female_fecundity = herd_data[1, female_fecundity],
      male_fecundity = herd_data[1, male_fecundity],
      pdea = with(herd_data[1],
                  c(FB = pdea.FB, FJ = pdea.FJ, FS = pdea.FS, FA = pdea.FA, FC = pdea.FC,
                    MB = pdea.MB, MJ = pdea.MJ, MS = pdea.MS, MA = pdea.MA, MC = pdea.MC)
      ),
      poff = with(herd_data[1],
                  c(FB = poff.FB, FJ = poff.FJ, FS = poff.FS, FA = poff.FA, FC = poff.FC,
                    MB = poff.MB, MJ = poff.MJ, MS = poff.MS, MA = poff.MA, MC = poff.MC)
      ),
      g = with(herd_data[1],
               c(FB = g.FB, FJ = g.FJ, FS = g.FS, FA = g.FA, FC = g.FC,
                 MB = g.MB, MJ = g.MJ, MS = g.MS, MA = g.MA, MC = g.MC)
      )
    )
  ))

  # Apply simulation to full data.table, row-wise
  herd_data[, (structure_cols) := as.list(unlist(
    simulate_steady_state_structure(
      initial_structure = initial_structure,
      max_years = max_years,
      min_lambda_change = lambda_threshold,
      female_fecundity = female_fecundity,
      male_fecundity = male_fecundity,
      pdea = c(
        FB = pdea.FB, FJ = pdea.FJ, FS = pdea.FS, FA = pdea.FA, FC = pdea.FC,
        MB = pdea.MB, MJ = pdea.MJ, MS = pdea.MS, MA = pdea.MA, MC = pdea.MC
      ),
      poff = c(
        FB = poff.FB, FJ = poff.FJ, FS = poff.FS, FA = poff.FA, FC = poff.FC,
        MB = poff.MB, MJ = poff.MJ, MS = poff.MS, MA = poff.MA, MC = poff.MC
      ),
      g = c(
        FB = g.FB, FJ = g.FJ, FS = g.FS, FA = g.FA, FC = g.FC,
        MB = g.MB, MJ = g.MJ, MS = g.MS, MA = g.MA, MC = g.MC
      )
    )
  )), by = seq_len(nrow(herd_data))]

  # Project population size

  # Single-row version to extract output column names
  popsize_cols <- names(unlist(
    project_population_size(
      size_total = herd_data[1, size_total],
      female_fecundity = herd_data[1, female_fecundity],
      male_fecundity = herd_data[1, male_fecundity],
      pdea = setNames(unlist(herd_data[1, paste0("pdea.", cohorts), with = FALSE]), cohorts),
      poff = setNames(unlist(herd_data[1, paste0("poff.", cohorts), with = FALSE]), cohorts),
      g = setNames(unlist(herd_data[1, paste0("g." , cohorts), with = FALSE]), cohorts),
      growth_rate_pop = herd_data[1, growth_rate_pop],
      structure = setNames(unlist(herd_data[1, paste0("structure.", structure_cohorts), with = FALSE]), structure_cohorts),
      share = setNames(unlist(herd_data[1, paste0("share.", share_cohorts), with = FALSE]), share_cohorts)
    )
  ))

  # Full-row application inside herd_data
  herd_data[, (popsize_cols) := as.list(unlist(
    project_population_size(
      size_total = size_total,
      female_fecundity = female_fecundity,
      male_fecundity = male_fecundity,
      pdea = setNames(unlist(.SD[, paste0("pdea.", cohorts), with = FALSE]), cohorts),
      poff = setNames(unlist(.SD[, paste0("poff.", cohorts), with = FALSE]), cohorts),
      g = setNames(unlist(.SD[, paste0("g." , cohorts), with = FALSE]), cohorts),
      growth_rate_pop = growth_rate_pop,
      structure = setNames(unlist(.SD[, paste0("structure.", structure_cohorts), with = FALSE]), structure_cohorts),
      share = setNames(unlist(.SD[, paste0("share.", share_cohorts), with = FALSE]), share_cohorts)
    )
  )), by = seq_len(nrow(herd_data))]

  # --- Step 3: Calculate Offtake and Weights ---------------------------------

  # Calculate offtake summary
  offtake_cols <- names(unlist(
    summarise_offtake(
      size = setNames(unlist(herd_data[1, paste0("size.", share_cohorts), with = FALSE]), share_cohorts),
      size_end = setNames(unlist(herd_data[1, paste0("size_end.", share_cohorts), with = FALSE]), share_cohorts),
      size_avg = setNames(unlist(herd_data[1, paste0("size_avg.", share_cohorts), with = FALSE]), share_cohorts),
      offtake = setNames(unlist(herd_data[1, paste0("offtake.", cohorts), with = FALSE]), cohorts)
    )
  ))

  # Apply to full data.table
  herd_data[, (offtake_cols) := as.list(unlist(
    summarise_offtake(
      size = setNames(unlist(.SD[, paste0("size.", share_cohorts), with = FALSE]), share_cohorts),
      size_end = setNames(unlist(.SD[, paste0("size_end.", share_cohorts), with = FALSE]), share_cohorts),
      size_avg = setNames(unlist(.SD[, paste0("size_avg.", share_cohorts), with = FALSE]), share_cohorts),
      offtake = setNames(unlist(.SD[, paste0("offtake.", cohorts), with = FALSE]), cohorts)
    )
  )), by = seq_len(nrow(herd_data))]

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
  herd_merged[, c("initial_weight", "potential_final_weight", "slaughter_weight") :=
                calc_cohort_weights(
                  animal = Animal_short,
                  cohort = cohort,
                  adult_female_weight = AFKG,
                  adult_male_weight = AMKG,
                  birth_weight = ckg,
                  slaughter_weight_female = MFSKG,
                  slaughter_weight_male = MMSKG,
                  weaning_weight = wkg,
                  age_first_calving = afc,
                  animal_age = WA
                ),
              by = .I
  ]

  herd_merged[, c("average_weight", "final_weight") :=
                calc_avg_weights(
                  initial_weight = initial_weight,
                  potential_final_weight = potential_final_weight,
                  slaughter_weight = slaughter_weight,
                  offtake_rate = offtake_rate
                ),
              by = .I
  ]

  herd_merged[, dwg := calc_daily_weight_gain(
    potential_final_weight = potential_final_weight,
    initial_weight = initial_weight,
    duration = duration
  ), by = .I]

  # Assign weaning weights for non-pig cohorts using FS values
  weaning_dt <- herd_merged[
    cohort == "FS" & Animal_short != "PGS",
    .(COUNTRY, ADM0_CODE, Animal_short, LPS_short, HerdType_short, cohort, initial_weight)
  ]

  herd_merged[
    Animal_short != "PGS",
    wkg := weaning_dt[
      .SD,
      on = .(COUNTRY, ADM0_CODE, Animal_short, LPS_short, HerdType_short),
      initial_weight
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
