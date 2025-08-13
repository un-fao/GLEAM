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
#' Input data must be preloaded. If using example data from the package (located in `inst/extdata`),
#' load it using [system.file()] and [fread()] as shown in the examples.
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
#' @examples
#' \dontrun{
#' # Load example input from the package and run the simulation
#' input_path <- system.file("extdata/GLEAM_input_herd.csv", package = "gleam")
#' herd_data <- data.table::fread(input_path)[1:20, ]
#' sim_results <- run_herd_simulation(herd_data)
#' }
#' @keywords internal
#'
#' @importFrom data.table := .SD .I melt dcast setcolorder
#' @importFrom stats setNames
run_herd_simulation <- function(
    herd_data,
    initial_structure = c(FJ = 100, FS = 50, FA = 30, MJ = 100, MS = 50, MA = 30),
    max_years = 100,
    lambda_threshold = 1e-9,
    show_indicator = TRUE
) {

  # If the user wants feedback, show one persistent "please wait" message.
  if (show_indicator) {
    cli::cli_status("\U1F552 Running herd simulation, please wait\U2026")
  }

  # Capture the initial column names
  base_cols <- names(data.table::copy(herd_data))

  # --- Step 1: Compute Core Demographic Parameters -----------------------------

  # Compute fecundity rates
  herd_data[, c("fem_fec", "mal_fec") := compute_fecundity_rates(
    part_rate = parturition_rate,
    prolif_rate = litsize,
    fem_birth_ratio = female_birth_fraction
  ), by = seq_len(nrow(herd_data))]

  # Compute transition probabilities
  transition_cols <- names(unlist(
    with(herd_data[1], compute_transition_probabilities(
      duration = c(FJ = duration.FJ, FS = duration.FS, FA = duration.FA,
                   MJ = duration.MJ, MS = duration.MS, MA = duration.MA),
      offtake_rate = c(FJ = offtake_rate.FJ, FS = offtake_rate.FS, FA = offtake_rate.FA,
                       MJ = offtake_rate.MJ, MS = offtake_rate.MS, MA = offtake_rate.MA),
      death_rate = c(FJ = mort_rate.FJ, FS = mort_rate.FS, FA = mort_rate.FA,
                     MJ = mort_rate.MJ, MS = mort_rate.MS, MA = mort_rate.MA)
    ))
  ))

  # Apply transition probability computation row-wise
  herd_data[, (transition_cols) := as.list(unlist(
    compute_transition_probabilities(
      duration = c(FJ = duration.FJ, FS = duration.FS, FA = duration.FA,
                   MJ = duration.MJ, MS = duration.MS, MA = duration.MA),
      offtake_rate = c(FJ = offtake_rate.FJ, FS = offtake_rate.FS, FA = offtake_rate.FA,
                       MJ = offtake_rate.MJ, MS = offtake_rate.MS, MA = offtake_rate.MA),
      death_rate = c(FJ = mort_rate.FJ, FS = mort_rate.FS, FA = mort_rate.FA,
                     MJ = mort_rate.MJ, MS = mort_rate.MS, MA = mort_rate.MA)
    )
  )), by = seq_len(nrow(herd_data))]

  # --- Step 2: Simulate Population Dynamics -----------------------------------

  # Simulate steady-state structure

  # Get structure column names from a sample run
  structure_cols <- names(unlist(
    with(herd_data[1], simulate_steady_state_structure(
      initial_structure = initial_structure,
      max_years = max_years,
      min_lambda_change = lambda_threshold,
      fem_fec = fem_fec,
      mal_fec = mal_fec,
      prob_death = c(
        FB = prob_death.FB, FJ = prob_death.FJ, FS = prob_death.FS, FA = prob_death.FA, FC = prob_death.FC,
        MB = prob_death.MB, MJ = prob_death.MJ, MS = prob_death.MS, MA = prob_death.MA, MC = prob_death.MC
      ),
      prob_offtake = c(
        FB = prob_offtake.FB, FJ = prob_offtake.FJ, FS = prob_offtake.FS, FA = prob_offtake.FA, FC = prob_offtake.FC,
        MB = prob_offtake.MB, MJ = prob_offtake.MJ, MS = prob_offtake.MS, MA = prob_offtake.MA, MC = prob_offtake.MC
      ),
      prob_growth = c(
        FB = prob_growth.FB, FJ = prob_growth.FJ, FS = prob_growth.FS, FA = prob_growth.FA, FC = prob_growth.FC,
        MB = prob_growth.MB, MJ = prob_growth.MJ, MS = prob_growth.MS, MA = prob_growth.MA, MC = prob_growth.MC
      )
    ))
  ))

  # Apply simulation to full data.table, row-wise
  herd_data[, (structure_cols) := as.list(unlist(
    simulate_steady_state_structure(
      initial_structure = initial_structure,
      max_years = max_years,
      min_lambda_change = lambda_threshold,
      fem_fec = fem_fec,
      mal_fec = mal_fec,
      prob_death = c(
        FB = prob_death.FB, FJ = prob_death.FJ, FS = prob_death.FS, FA = prob_death.FA, FC = prob_death.FC,
        MB = prob_death.MB, MJ = prob_death.MJ, MS = prob_death.MS, MA = prob_death.MA, MC = prob_death.MC
      ),
      prob_offtake = c(
        FB = prob_offtake.FB, FJ = prob_offtake.FJ, FS = prob_offtake.FS, FA = prob_offtake.FA, FC = prob_offtake.FC,
        MB = prob_offtake.MB, MJ = prob_offtake.MJ, MS = prob_offtake.MS, MA = prob_offtake.MA, MC = prob_offtake.MC
      ),
      prob_growth = c(
        FB = prob_growth.FB, FJ = prob_growth.FJ, FS = prob_growth.FS, FA = prob_growth.FA, FC = prob_growth.FC,
        MB = prob_growth.MB, MJ = prob_growth.MJ, MS = prob_growth.MS, MA = prob_growth.MA, MC = prob_growth.MC
      )
    )
  )), by = seq_len(nrow(herd_data))]

  # Project population size

  # Single-row version to extract output column names
  popsize_cols <- names(unlist(
    with(herd_data[1], project_population_size(
      size_total = size_total,
      fem_fec = fem_fec,
      mal_fec = mal_fec,
      prob_death = c(
        FB = prob_death.FB, FJ = prob_death.FJ, FS = prob_death.FS, FA = prob_death.FA, FC = prob_death.FC,
        MB = prob_death.MB, MJ = prob_death.MJ, MS = prob_death.MS, MA = prob_death.MA, MC = prob_death.MC
      ),
      prob_offtake = c(
        FB = prob_offtake.FB, FJ = prob_offtake.FJ, FS = prob_offtake.FS, FA = prob_offtake.FA, FC = prob_offtake.FC,
        MB = prob_offtake.MB, MJ = prob_offtake.MJ, MS = prob_offtake.MS, MA = prob_offtake.MA, MC = prob_offtake.MC
      ),
      prob_growth = c(
        FB = prob_growth.FB, FJ = prob_growth.FJ, FS = prob_growth.FS, FA = prob_growth.FA, FC = prob_growth.FC,
        MB = prob_growth.MB, MJ = prob_growth.MJ, MS = prob_growth.MS, MA = prob_growth.MA, MC = prob_growth.MC
      ),
      growth_rate_pop = growth_rate_pop,
      structure = c(FB = structure.FB, FJ = structure.FJ, FS = structure.FS, FA = structure.FA,
                    MB = structure.MB, MJ = structure.MJ, MS = structure.MS, MA = structure.MA),
      share = c(FJ = share.FJ, FS = share.FS, FA = share.FA,
                MJ = share.MJ, MS = share.MS, MA = share.MA)
    ))
  ))

  # Full-row application inside herd_data
  herd_data[, (popsize_cols) := as.list(unlist(
    project_population_size(
      size_total = size_total,
      fem_fec = fem_fec,
      mal_fec = mal_fec,
      prob_death = c(
        FB = prob_death.FB, FJ = prob_death.FJ, FS = prob_death.FS, FA = prob_death.FA, FC = prob_death.FC,
        MB = prob_death.MB, MJ = prob_death.MJ, MS = prob_death.MS, MA = prob_death.MA, MC = prob_death.MC
      ),
      prob_offtake = c(
        FB = prob_offtake.FB, FJ = prob_offtake.FJ, FS = prob_offtake.FS, FA = prob_offtake.FA, FC = prob_offtake.FC,
        MB = prob_offtake.MB, MJ = prob_offtake.MJ, MS = prob_offtake.MS, MA = prob_offtake.MA, MC = prob_offtake.MC
      ),
      prob_growth = c(
        FB = prob_growth.FB, FJ = prob_growth.FJ, FS = prob_growth.FS, FA = prob_growth.FA, FC = prob_growth.FC,
        MB = prob_growth.MB, MJ = prob_growth.MJ, MS = prob_growth.MS, MA = prob_growth.MA, MC = prob_growth.MC
      ),
      growth_rate_pop = growth_rate_pop,
      structure = c(FB = structure.FB, FJ = structure.FJ, FS = structure.FS, FA = structure.FA,
                    MB = structure.MB, MJ = structure.MJ, MS = structure.MS, MA = structure.MA),
      share = c(FJ = share.FJ, FS = share.FS, FA = share.FA,
                MJ = share.MJ, MS = share.MS, MA = share.MA)
    )
  )), by = seq_len(nrow(herd_data))]

  # --- Step 3: Calculate Offtake and Weights ---------------------------------

  # Calculate offtake summary
  offtake_cols <- names(unlist(
    with(herd_data[1], summarise_offtake(
      size = c(FJ = size.FJ, FS = size.FS, FA = size.FA,
               MJ = size.MJ, MS = size.MS, MA = size.MA),
      size_end = c(FJ = size_end.FJ, FS = size_end.FS, FA = size_end.FA,
                   MJ = size_end.MJ, MS = size_end.MS, MA = size_end.MA),
      size_avg = c(FJ = size_avg.FJ, FS = size_avg.FS, FA = size_avg.FA,
                   MJ = size_avg.MJ, MS = size_avg.MS, MA = size_avg.MA),
      offtake = c(FB = offtake.FB, FJ = offtake.FJ, FS = offtake.FS, FA = offtake.FA, FC = offtake.FC,
                  MB = offtake.MB, MJ = offtake.MJ, MS = offtake.MS, MA = offtake.MA, MC = offtake.MC)
    ))
  ))

  # Apply to full data.table
  herd_data[, (offtake_cols) := as.list(unlist(
    summarise_offtake(
      size = c(FJ = size.FJ, FS = size.FS, FA = size.FA,
               MJ = size.MJ, MS = size.MS, MA = size.MA),
      size_end = c(FJ = size_end.FJ, FS = size_end.FS, FA = size_end.FA,
                   MJ = size_end.MJ, MS = size_end.MS, MA = size_end.MA),
      size_avg = c(FJ = size_avg.FJ, FS = size_avg.FS, FA = size_avg.FA,
                   MJ = size_avg.MJ, MS = size_avg.MS, MA = size_avg.MA),
      offtake = c(FB = offtake.FB, FJ = offtake.FJ, FS = offtake.FS, FA = offtake.FA, FC = offtake.FC,
                  MB = offtake.MB, MJ = offtake.MJ, MS = offtake.MS, MA = offtake.MA, MC = offtake.MC)
    )
  )), by = seq_len(nrow(herd_data))]

  # --- Step 4: Filter and Prepare Data for Reshaping -------------------------

  # Explicit list of computed columns to keep in the final output
  extra_cols <- c(
    "share.FJ", "share.FS", "share.FA", "share.MJ", "share.MS", "share.MA",
    "growth_rate_pop", "size.FJ", "size.FS", "size.FA", "size.MJ", "size.MS", "size.MA",
    "offtake_number.FJ", "offtake_number.FS", "offtake_number.FA",
    "offtake_number.MJ", "offtake_number.MS", "offtake_number.MA"
  )

  # Merge the original columns with the desired new ones
  # intersect() ensures we keep only columns that actually exist in herd_data
  final_cols <- intersect(unique(c(base_cols, extra_cols)), names(herd_data))

  # Subset herd_data to keep only the intended columns
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
                  adult_fem_weight = AFKG,
                  adult_mal_weight = AMKG,
                  birth_weight = ckg,
                  slaughter_weight_fem = MFSKG,
                  slaughter_weight_mal = MMSKG,
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

  # Clear the spinner and leave a permanent success alert.
  if (show_indicator) {
    cli::cli_status_clear()
    cli::cli_alert_success("Herd simulation complete.")
  }

  return(herd_final)
}
