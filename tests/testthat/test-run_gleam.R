# Tests for run_gleam() — main pipeline entry point

# Load example data once at file scope to avoid re-reading CSVs in every test.
d_gleam <- local({
  path <- system.file("extdata", "run_gleam_examples", package = "gleam")
  herd_nondemo <- data.table::fread(
    system.file(
      "extdata", "run_modules_examples", "example_herd_level_data.csv",
      package = "gleam"
    )
  )[, .(
    herd_id,
    prop_nondemo_fem_juv,
    prop_nondemo_mal_juv,
    rest_between_nondemo_cycles_duration,
    phase1_nondemo_fem_duration_days,
    phase2_nondemo_fem_duration_days,
    phase1_nondemo_mal_duration_days,
    phase2_nondemo_mal_duration_days
  )]

  herd <- merge(
    data.table::fread(file.path(path, "master_hrd_lvl_data.csv")),
    herd_nondemo,
    by = "herd_id",
    all.x = TRUE
  )
  herd[
    ,
    `:=`(
      prop_nondemo_fem_juv = 0,
      prop_nondemo_mal_juv = 0,
      rest_between_nondemo_cycles_duration = NA_real_,
      phase1_nondemo_fem_duration_days = NA_real_,
      phase2_nondemo_fem_duration_days = NA_real_,
      phase1_nondemo_mal_duration_days = NA_real_,
      phase2_nondemo_mal_duration_days = NA_real_
    )
  ]
  herd[
    ,
    `:=`(
      live_weight_female_nondemographic_start = NA_real_,
      live_weight_male_nondemographic_start = NA_real_,
      live_weight_female_nondemographic_end = live_weight_female_at_slaughter,
      live_weight_male_nondemographic_end = live_weight_male_at_slaughter
    )
  ]

  list(
    cohort_no_structure = data.table::fread(
      file.path(path, "master_chrt_lvl_no_structure_data.csv")
    ),
    cohort_structure = data.table::fread(
      file.path(path, "master_chrt_lvl_structure_data.csv")
    ),
    herd = herd,
    feed_rations = data.table::fread(
      file.path(path, "feed_rations_share_chrt.csv")
    ),
    feed_params = data.table::fread(file.path(path, "feed_quality.csv")),
    feed_emissions = data.table::fread(
      file.path(path, "feed_emission_factors.csv")
    ),
    mms_fraction = data.table::fread(
      file.path(path, "manure_management_system_fraction.csv")
    ),
    mms_factors = data.table::fread(
      file.path(path, "manure_management_system_factors.csv")
    )
  )
})

d_gleam_mixed <- local({
  path <- system.file("extdata", "run_gleam_examples", package = "gleam")
  nondemo_cohorts <- data.table::fread(
    system.file(
      "extdata", "run_modules_examples", "run_all_herd_module_input_chrt_data.csv",
      package = "gleam"
    )
  )[cohort_short %in% c("FN", "MN")]

  herd_nondemo <- data.table::fread(
    system.file(
      "extdata", "run_modules_examples", "example_herd_level_data.csv",
      package = "gleam"
    )
  )[, .(
    herd_id,
    prop_nondemo_fem_juv,
    prop_nondemo_mal_juv,
    rest_between_nondemo_cycles_duration,
    phase1_nondemo_fem_duration_days,
    phase2_nondemo_fem_duration_days,
    phase1_nondemo_mal_duration_days,
    phase2_nondemo_mal_duration_days
  )]

  herd_species_activity <- unique(
    d_gleam$cohort_no_structure[, .(
      herd_id,
      species_short,
      high_activity_fraction,
      low_activity_fraction
    )]
  )

  cohort_no_structure <- data.table::rbindlist(
    list(
      d_gleam$cohort_no_structure,
      merge(nondemo_cohorts, herd_species_activity, by = "herd_id", all.x = TRUE)
    ),
    use.names = TRUE,
    fill = TRUE
  )

  herd <- data.table::copy(d_gleam$herd)
  herd_nondemo_full <- data.table::fread(
    system.file(
      "extdata", "run_modules_examples", "example_herd_level_data.csv",
      package = "gleam"
    )
  )[, .(
    herd_id,
    prop_nondemo_fem_juv,
    prop_nondemo_mal_juv,
    rest_between_nondemo_cycles_duration,
    phase1_nondemo_fem_duration_days,
    phase2_nondemo_fem_duration_days,
    phase1_nondemo_mal_duration_days,
    phase2_nondemo_mal_duration_days
  )]
  herd <- merge(
    herd[, !c(
      "prop_nondemo_fem_juv",
      "prop_nondemo_mal_juv",
      "rest_between_nondemo_cycles_duration",
      "phase1_nondemo_fem_duration_days",
      "phase2_nondemo_fem_duration_days",
      "phase1_nondemo_mal_duration_days",
      "phase2_nondemo_mal_duration_days"
    )],
    herd_nondemo_full,
    by = "herd_id",
    all.x = TRUE
  )

  d_mixed <- d_gleam
  d_mixed$cohort_no_structure <- cohort_no_structure
  d_mixed$herd <- herd
  d_mixed$feed_rations <- data.table::fread(
    file.path(path, "feed_rations_share_chrt.csv")
  )
  d_mixed$mms_fraction <- data.table::fread(
    file.path(path, "manure_management_system_fraction.csv")
  )
  d_mixed
})

# Helper: call run_gleam with defaults, allowing any argument to be overridden.
# Unlike modifyList, this preserves NULL overrides (important for NULL-rejection tests).
run_gleam_default <- function(data, has_herd_structure = FALSE, ...) {
  use_structure <- isTRUE(has_herd_structure)
  cohort_selected <- if (use_structure) data$cohort_structure else data$cohort_no_structure
  run_demographic_default <- any(cohort_selected$cohort_short %in% gleam_cohorts_demographic, na.rm = TRUE)
  run_nondemographic_default <- any(cohort_selected$cohort_short %in% c("FN", "MN"), na.rm = TRUE)
  defaults <- list(
    has_herd_structure = has_herd_structure,
    cohort_level_data = cohort_selected,
    herd_level_data = data$herd,
    feed_rations = data$feed_rations,
    feed_params = data$feed_params,
    feed_emissions = data$feed_emissions,
    manure_management_system_fraction = data$mms_fraction,
    manure_management_system_factors = data$mms_factors,
    run_demographic = run_demographic_default,
    run_nondemographic = run_nondemographic_default,
    show_indicator = FALSE
  )
  overrides <- list(...)
  for (nm in names(overrides)) defaults[nm] <- list(overrides[[nm]])
  do.call(run_gleam, defaults)
}

run_gleam_no_structure <- function(d, ...) run_gleam_default(d, has_herd_structure = FALSE, ...)
run_gleam_with_structure <- function(d, ...) run_gleam_default(d, has_herd_structure = TRUE, ...)

# Cache only the prebuilt-structure happy path. The no-structure path triggers
# herd simulation, which is covered in herd-module tests and is too expensive to
# run at file scope in this test file.
res_with_structure <- run_gleam_with_structure(d_gleam)

# ---- validate_run_gleam_inputs: has_herd_structure ---------------------------
test_that("rejects non-logical has_herd_structure", {
  expect_error(
    run_gleam_default(d_gleam, has_herd_structure = "yes"),
    "single logical value"
  )
})

test_that("rejects NA has_herd_structure", {
  expect_error(
    run_gleam_default(d_gleam, has_herd_structure = NA),
    "not NA"
  )
})

test_that("existing herd structure ignores herd-simulation defaults", {
  expect_no_error(
    run_gleam(
      has_herd_structure = TRUE,
      cohort_level_data = d_gleam$cohort_structure,
      herd_level_data = data.table::fread(
        file.path(system.file("extdata", "run_gleam_examples", package = "gleam"), "master_hrd_lvl_data.csv")
      ),
      feed_rations = d_gleam$feed_rations,
      feed_params = d_gleam$feed_params,
      feed_emissions = d_gleam$feed_emissions,
      manure_management_system_fraction = d_gleam$mms_fraction,
      manure_management_system_factors = d_gleam$mms_factors,
      show_indicator = FALSE
    )
  )
})

# ---- validate_run_gleam_inputs: simulation_duration --------------------------
test_that("rejects non-numeric simulation_duration", {
  expect_error(
    run_gleam_no_structure(d_gleam, simulation_duration = "365"),
    "simulation_duration.*numeric"
  )
})

test_that("rejects non-positive simulation_duration", {
  expect_error(
    run_gleam_no_structure(d_gleam, simulation_duration = 0),
    "simulation_duration.*positive"
  )
})

# ---- validate_run_gleam_inputs: global_warming_potential_set -----------------
test_that("rejects invalid global_warming_potential_set", {
  expect_error(
    run_gleam_no_structure(d_gleam, global_warming_potential_set = "AR3"),
    "global_warming_potential_set"
  )
})

# ---- validate_run_gleam_inputs: data frame checks ----------------------------
test_that("rejects NULL cohort_level_data", {
  expect_error(
    run_gleam_no_structure(d_gleam, cohort_level_data = NULL),
    "cohort_level_data.*must be a data frame"
  )
})

test_that("rejects NULL herd_level_data", {
  expect_error(
    run_gleam_no_structure(d_gleam, herd_level_data = NULL),
    "herd_level_data.*must be a data frame"
  )
})

test_that("rejects NULL feed_rations", {
  expect_error(
    run_gleam_no_structure(d_gleam, feed_rations = NULL),
    "feed_rations.*must be a data frame"
  )
})

test_that("rejects NULL feed_params", {
  expect_error(
    run_gleam_no_structure(d_gleam, feed_params = NULL),
    "feed_params.*must be a data frame"
  )
})

test_that("rejects NULL feed_emissions", {
  expect_error(
    run_gleam_no_structure(d_gleam, feed_emissions = NULL),
    "feed_emissions.*must be a data frame"
  )
})

test_that("rejects NULL manure_management_system_fraction", {
  expect_error(
    run_gleam_no_structure(d_gleam, manure_management_system_fraction = NULL),
    "manure_management_system_fraction.*must be a data frame"
  )
})

test_that("rejects NULL manure_management_system_factors", {
  expect_error(
    run_gleam_no_structure(d_gleam, manure_management_system_factors = NULL),
    "manure_management_system_factors.*must be a data frame"
  )
})

# ---- validate_run_gleam_inputs: calculated columns blocked -------------------
test_that("rejects cohort data containing calculated columns", {
  bad_cohort <- data.table::copy(d_gleam$cohort_no_structure)
  bad_cohort[, daily_weight_gain := 0.5]
  expect_error(
    run_gleam_no_structure(d_gleam, cohort_level_data = bad_cohort),
    "daily_weight_gain"
  )
})

test_that("blocks cohort_stock_size in no-structure mode", {
  bad_cohort <- data.table::copy(d_gleam$cohort_no_structure)
  bad_cohort[, cohort_stock_size := 100]
  expect_error(
    run_gleam_no_structure(d_gleam, cohort_level_data = bad_cohort),
    "cohort_stock_size"
  )
})

test_that("allows cohort_stock_size in structure mode", {
  expect_true("cohort_stock_size" %in% names(d_gleam$cohort_structure))
})

# ---- validate_run_gleam_inputs: herd_id consistency -------------------------
test_that("rejects mismatched herd_id across inputs", {
  bad_herd <- data.table::copy(d_gleam$herd)
  bad_herd[, herd_id := paste0(herd_id, "_bad")]
  expect_error(
    run_gleam_no_structure(d_gleam, herd_level_data = bad_herd),
    "same.*herd_id"
  )
})

test_that("rejects missing FN rows when prop_nondemo_fem_juv is positive", {
  bad_cohort <- data.table::copy(d_gleam_mixed$cohort_no_structure)
  bad_cohort <- bad_cohort[!(herd_id == 9 & cohort_short == "FN")]

  expect_error(
    run_gleam_no_structure(d_gleam_mixed, cohort_level_data = bad_cohort),
    "Missing .*FN.*herd_id.*9"
  )
})

test_that("rejects missing MN rows when prop_nondemo_mal_juv is positive", {
  bad_cohort <- data.table::copy(d_gleam_mixed$cohort_no_structure)
  bad_cohort <- bad_cohort[!(herd_id == 1 & cohort_short == "MN")]

  expect_error(
    run_gleam_no_structure(d_gleam_mixed, cohort_level_data = bad_cohort),
    "Missing .*MN.*herd_id.*1"
  )
})

# ---- run_gleam: return structure ---------------------------------------------
test_that("run_gleam returns a named list with expected elements", {
  expect_type(res_with_structure, "list")
  expect_named(
    res_with_structure,
    c("cohort_level_results", "herd_level_results", "allocation_long", "aggregation_results"),
    ignore.order = FALSE
  )
})

test_that("aggregation_results has expected sub-elements", {
  expect_named(
    res_with_structure$aggregation_results,
    c("results_emissions", "results_feed", "results_production", "results_nitrogen"),
    ignore.order = FALSE
  )
})

# ---- run_gleam: has_herd_structure = TRUE ------------------------------------
test_that("run_gleam succeeds with has_herd_structure = TRUE", {
  cohort <- res_with_structure$cohort_level_results
  expect_s3_class(cohort, "data.table")
  expect_true(nrow(cohort) > 0)
  expect_true("herd_id" %in% names(cohort))
  expect_true("cohort_short" %in% names(cohort))
})

test_that("run_gleam TRUE path produces weight columns", {
  cohort <- res_with_structure$cohort_level_results
  weight_cols <- c(
    "live_weight_mature_stage", "daily_weight_gain", "live_weight_cohort_average"
  )
  for (col in weight_cols) {
    expect_true(col %in% names(cohort), info = paste("Missing column:", col))
  }
})

test_that("run_gleam TRUE path produces energy columns", {
  cohort <- res_with_structure$cohort_level_results
  energy_cols <- c(
    "metabolic_energy_req_maintenance", "metabolic_energy_req_total", "ration_intake"
  )
  for (col in energy_cols) {
    expect_true(col %in% names(cohort), info = paste("Missing column:", col))
  }
})

test_that("run_gleam TRUE path produces ration quality columns", {
  cohort <- res_with_structure$cohort_level_results
  ration_cols <- c(
    "ration_gross_energy", "ration_digestibility_fraction", "ration_nitrogen"
  )
  for (col in ration_cols) {
    expect_true(col %in% names(cohort), info = paste("Missing column:", col))
  }
})

test_that("run_gleam TRUE path produces enteric emission columns", {
  cohort <- res_with_structure$cohort_level_results
  enteric_cols <- c("ch4_conversion_factor_ym", "ch4_enteric")
  for (col in enteric_cols) {
    expect_true(col %in% names(cohort), info = paste("Missing column:", col))
  }
})

test_that("run_gleam TRUE path produces nitrogen balance columns", {
  cohort <- res_with_structure$cohort_level_results
  nitrogen_cols <- c("nitrogen_intake", "nitrogen_retention", "nitrogen_excretion")
  for (col in nitrogen_cols) {
    expect_true(col %in% names(cohort), info = paste("Missing column:", col))
  }
})

test_that("run_gleam TRUE path produces manure emission columns", {
  cohort <- res_with_structure$cohort_level_results
  manure_cols <- c(
    "volatile_solids",
    "ch4_manure_pasture", "ch4_manure_burned", "ch4_manure_other",
    "n2o_manure_pasture_total", "n2o_manure_burned_total", "n2o_manure_other_total"
  )
  for (col in manure_cols) {
    expect_true(col %in% names(cohort), info = paste("Missing column:", col))
  }
})

test_that("run_gleam TRUE path produces feed emission columns", {
  cohort <- res_with_structure$cohort_level_results
  feed_emission_cols <- c(
    "co2_ration_fertilizer", "co2_ration_pesticides",
    "n2o_ration_fertilizer", "ch4_ration_rice"
  )
  for (col in feed_emission_cols) {
    expect_true(col %in% names(cohort), info = paste("Missing column:", col))
  }
})

test_that("run_gleam TRUE path produces production columns", {
  cohort <- res_with_structure$cohort_level_results
  production_cols <- c(
    "milk_production_fpcm_cohort", "meat_production_live_weight_cohort",
    "meat_production_protein_cohort"
  )
  for (col in production_cols) {
    expect_true(col %in% names(cohort), info = paste("Missing column:", col))
  }
})

test_that("run_gleam TRUE path produces allocation energy columns", {
  cohort <- res_with_structure$cohort_level_results
  allocation_cols <- c(
    "milk_allocation_energy", "meat_allocation_energy",
    "fibre_allocation_energy", "work_allocation_energy"
  )
  for (col in allocation_cols) {
    expect_true(col %in% names(cohort), info = paste("Missing column:", col))
  }
})

test_that("run_gleam TRUE path has all 6 cohorts per herd", {
  cohort <- res_with_structure$cohort_level_results
  expected_cohorts <- c("FA", "FJ", "FS", "MA", "MJ", "MS")
  for (hid in unique(cohort$herd_id)) {
    cohorts <- sort(unique(cohort[herd_id == hid, cohort_short]))
    expect_equal(cohorts, expected_cohorts, info = paste("herd_id:", hid))
  }
})

test_that("run_gleam TRUE path produces calculated columns", {
  cohort <- res_with_structure$cohort_level_results
  expected_cols <- c(
    "live_weight_mature_stage", "daily_weight_gain",
    "metabolic_energy_req_total", "ration_intake",
    "ration_gross_energy"
  )
  for (col in expected_cols) {
    expect_true(col %in% names(cohort), info = paste("Missing column:", col))
  }
})

test_that("run_gleam TRUE path preserves cohort_stock_size from input", {
  cohort <- res_with_structure$cohort_level_results
  expect_true("cohort_stock_size" %in% names(cohort))
  input_sizes <- d_gleam$cohort_structure[, .(herd_id, cohort_short, cohort_stock_size)]
  data.table::setkey(input_sizes, herd_id, cohort_short)
  result_sizes <- cohort[, .(herd_id, cohort_short, cohort_stock_size)]
  data.table::setkey(result_sizes, herd_id, cohort_short)
  expect_equal(result_sizes$cohort_stock_size, input_sizes$cohort_stock_size)
})

# ---- run_gleam: output consistency -------------------------------------------
test_that("TRUE path includes key shared output columns", {
  cohort <- res_with_structure$cohort_level_results
  shared_cols <- c(
    "herd_id", "cohort_short", "live_weight_mature_stage", "daily_weight_gain",
    "metabolic_energy_req_total", "ration_intake",
    "ration_gross_energy", "ration_digestibility_fraction"
  )
  for (col in shared_cols) {
    expect_true(col %in% names(cohort), info = paste("Missing:", col))
  }
})

test_that("numeric output columns contain no NA values for key fields", {
  cohort <- res_with_structure$cohort_level_results
  key_cols <- c("metabolic_energy_req_total", "ration_intake", "ration_gross_energy")
  for (col in key_cols) {
    expect_false(anyNA(cohort[[col]]), info = paste("NA found in", col))
  }
})

# ---- run_gleam: allocation_long output ---------------------------------------
test_that("allocation_long has expected columns", {
  alloc <- res_with_structure$allocation_long
  expect_s3_class(alloc, "data.table")
  expected_cols <- c(
    "herd_id", "species_short", "variable_name",
    "commodity_name", "commodity_type", "allocation_share"
  )
  for (col in expected_cols) {
    expect_true(col %in% names(alloc), info = paste("Missing column:", col))
  }
})

test_that("allocation_long allocation_share is between 0 and 1", {
  alloc <- res_with_structure$allocation_long
  expect_true(all(alloc$allocation_share >= 0 & alloc$allocation_share <= 1))
})

# ---- run_gleam: aggregation_results output -----------------------------------
test_that("aggregation results_emissions is non-empty data.table", {
  emissions <- res_with_structure$aggregation_results$results_emissions
  expect_s3_class(emissions, "data.table")
  expect_true(nrow(emissions) > 0)
})

test_that("aggregation results_production is non-empty data.table", {
  production <- res_with_structure$aggregation_results$results_production
  expect_s3_class(production, "data.table")
  expect_true(nrow(production) > 0)
})

test_that("aggregation results_feed is non-empty data.table", {
  feed <- res_with_structure$aggregation_results$results_feed
  expect_s3_class(feed, "data.table")
  expect_true(nrow(feed) > 0)
})

test_that("aggregation results_nitrogen is non-empty data.table", {
  nitrogen <- res_with_structure$aggregation_results$results_nitrogen
  expect_s3_class(nitrogen, "data.table")
  expect_true(nrow(nitrogen) > 0)
})
