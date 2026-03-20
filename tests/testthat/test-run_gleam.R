# Tests for run_gleam() — main pipeline entry point

# Load example data once at file scope to avoid re-reading CSVs in every test.
d_gleam <- local({
  path <- system.file("extdata/run_gleam_examples", package = "gleam")
  list(
    cohort_no_structure = data.table::fread(
      file.path(path, "master_chrt_lvl_no_structure_data.csv")
    ),
    cohort_structure = data.table::fread(
      file.path(path, "master_chrt_lvl_structure_data.csv")
    ),
    herd = data.table::fread(file.path(path, "master_hrd_lvl_data.csv")),
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

# Helper: call run_gleam with defaults, allowing any argument to be overridden.
# Unlike modifyList, this preserves NULL overrides (important for NULL-rejection tests).
run_gleam_default <- function(d, has_herd_structure = FALSE, ...) {
  use_structure <- isTRUE(has_herd_structure)
  defaults <- list(
    has_herd_structure = has_herd_structure,
    cohort_level_data = if (use_structure) d$cohort_structure else d$cohort_no_structure,
    herd_level_data = d$herd,
    feed_rations = d$feed_rations,
    feed_params = d$feed_params,
    feed_emissions = d$feed_emissions,
    manure_management_system_fraction = d$mms_fraction,
    manure_management_system_factors = d$mms_factors,
    show_indicator = FALSE
  )
  overrides <- list(...)
  for (nm in names(overrides)) defaults[nm] <- list(overrides[[nm]])
  do.call(run_gleam, defaults)
}

run_gleam_no_structure <- function(d, ...) run_gleam_default(d, has_herd_structure = FALSE, ...)
run_gleam_with_structure <- function(d, ...) run_gleam_default(d, has_herd_structure = TRUE, ...)

# Run the full pipeline once per path at file scope so that happy-path tests
# reuse the cached result instead of re-running the entire pipeline per test.
# This reduces execution from ~18 pipeline runs down to 2 (+ 3 for the GWP loop).
res_no_structure <- run_gleam_no_structure(d_gleam)
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

# ---- run_gleam: return structure ---------------------------------------------
test_that("run_gleam returns a named list with expected elements", {
  expect_type(res_no_structure, "list")
  expect_named(
    res_no_structure,
    c("cohort_level_results", "herd_level_results", "allocation_long", "aggregation_results"),
    ignore.order = FALSE
  )
})

test_that("aggregation_results has expected sub-elements", {
  expect_named(
    res_no_structure$aggregation_results,
    c("results_emissions", "results_feed", "results_production", "results_nitrogen"),
    ignore.order = FALSE
  )
})

# ---- run_gleam: has_herd_structure = FALSE -----------------------------------
test_that("run_gleam succeeds with has_herd_structure = FALSE", {
  cohort <- res_no_structure$cohort_level_results
  expect_s3_class(cohort, "data.table")
  expect_true(nrow(cohort) > 0)
  expect_true("herd_id" %in% names(cohort))
  expect_true("cohort_short" %in% names(cohort))
})

test_that("run_gleam FALSE path produces weight columns", {
  cohort <- res_no_structure$cohort_level_results
  weight_cols <- c(
    "live_weight_mature_stage", "daily_weight_gain", "live_weight_cohort_average"
  )
  for (col in weight_cols) {
    expect_true(col %in% names(cohort), info = paste("Missing column:", col))
  }
})

test_that("run_gleam FALSE path produces energy columns", {
  cohort <- res_no_structure$cohort_level_results
  energy_cols <- c(
    "metabolic_energy_req_maintenance", "metabolic_energy_req_total", "ration_intake"
  )
  for (col in energy_cols) {
    expect_true(col %in% names(cohort), info = paste("Missing column:", col))
  }
})

test_that("run_gleam FALSE path produces ration quality columns", {
  cohort <- res_no_structure$cohort_level_results
  ration_cols <- c(
    "ration_gross_energy", "ration_digestibility_fraction", "ration_nitrogen"
  )
  for (col in ration_cols) {
    expect_true(col %in% names(cohort), info = paste("Missing column:", col))
  }
})

test_that("run_gleam FALSE path produces enteric emission columns", {
  cohort <- res_no_structure$cohort_level_results
  enteric_cols <- c("ch4_conversion_factor_ym", "ch4_enteric")
  for (col in enteric_cols) {
    expect_true(col %in% names(cohort), info = paste("Missing column:", col))
  }
})

test_that("run_gleam FALSE path produces nitrogen balance columns", {
  cohort <- res_no_structure$cohort_level_results
  nitrogen_cols <- c("nitrogen_intake", "nitrogen_retention", "nitrogen_excretion")
  for (col in nitrogen_cols) {
    expect_true(col %in% names(cohort), info = paste("Missing column:", col))
  }
})

test_that("run_gleam FALSE path produces manure emission columns", {
  cohort <- res_no_structure$cohort_level_results
  manure_cols <- c(
    "volatile_solids",
    "ch4_manure_pasture", "ch4_manure_burned", "ch4_manure_other",
    "n2o_manure_pasture_total", "n2o_manure_burned_total", "n2o_manure_other_total"
  )
  for (col in manure_cols) {
    expect_true(col %in% names(cohort), info = paste("Missing column:", col))
  }
})

test_that("run_gleam FALSE path produces feed emission columns", {
  cohort <- res_no_structure$cohort_level_results
  feed_emission_cols <- c(
    "co2_ration_fertilizer", "co2_ration_pesticides",
    "n2o_ration_fertilizer", "ch4_ration_rice"
  )
  for (col in feed_emission_cols) {
    expect_true(col %in% names(cohort), info = paste("Missing column:", col))
  }
})

test_that("run_gleam FALSE path produces production columns", {
  cohort <- res_no_structure$cohort_level_results
  production_cols <- c(
    "milk_production_fpcm_cohort", "meat_production_live_weight_cohort",
    "meat_production_protein_cohort"
  )
  for (col in production_cols) {
    expect_true(col %in% names(cohort), info = paste("Missing column:", col))
  }
})

test_that("run_gleam FALSE path produces allocation energy columns", {
  cohort <- res_no_structure$cohort_level_results
  allocation_cols <- c(
    "milk_allocation_energy", "meat_allocation_energy",
    "fibre_allocation_energy", "work_allocation_energy"
  )
  for (col in allocation_cols) {
    expect_true(col %in% names(cohort), info = paste("Missing column:", col))
  }
})

test_that("run_gleam FALSE path has all 6 cohorts per herd", {
  cohort <- res_no_structure$cohort_level_results
  expected_cohorts <- c("FA", "FJ", "FS", "MA", "MJ", "MS")
  for (hid in unique(cohort$herd_id)) {
    cohorts <- sort(unique(cohort[herd_id == hid, cohort_short]))
    expect_equal(cohorts, expected_cohorts, info = paste("herd_id:", hid))
  }
})

# ---- run_gleam: has_herd_structure = TRUE ------------------------------------
test_that("run_gleam succeeds with has_herd_structure = TRUE", {
  cohort <- res_with_structure$cohort_level_results
  expect_s3_class(cohort, "data.table")
  expect_true(nrow(cohort) > 0)
  expect_true("herd_id" %in% names(cohort))
  expect_true("cohort_short" %in% names(cohort))
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
test_that("both paths produce same key columns", {
  cohort_false <- res_no_structure$cohort_level_results
  cohort_true <- res_with_structure$cohort_level_results
  shared_cols <- c(
    "herd_id", "cohort_short", "live_weight_mature_stage", "daily_weight_gain",
    "metabolic_energy_req_total", "ration_intake",
    "ration_gross_energy", "ration_digestibility_fraction"
  )
  for (col in shared_cols) {
    expect_true(col %in% names(cohort_false), info = paste("FALSE missing:", col))
    expect_true(col %in% names(cohort_true), info = paste("TRUE missing:", col))
  }
})

test_that("numeric output columns contain no NA values for key fields", {
  cohort <- res_no_structure$cohort_level_results
  key_cols <- c("metabolic_energy_req_total", "ration_intake", "ration_gross_energy")
  for (col in key_cols) {
    expect_false(anyNA(cohort[[col]]), info = paste("NA found in", col))
  }
})

# ---- run_gleam: allocation_long output ---------------------------------------
test_that("allocation_long has expected columns", {
  alloc <- res_no_structure$allocation_long
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
  alloc <- res_no_structure$allocation_long
  expect_true(all(alloc$allocation_share >= 0 & alloc$allocation_share <= 1))
})

# ---- run_gleam: aggregation_results output -----------------------------------
test_that("aggregation results_emissions is non-empty data.table", {
  emissions <- res_no_structure$aggregation_results$results_emissions
  expect_s3_class(emissions, "data.table")
  expect_true(nrow(emissions) > 0)
})

test_that("aggregation results_production is non-empty data.table", {
  production <- res_no_structure$aggregation_results$results_production
  expect_s3_class(production, "data.table")
  expect_true(nrow(production) > 0)
})

test_that("aggregation results_feed is non-empty data.table", {
  feed <- res_no_structure$aggregation_results$results_feed
  expect_s3_class(feed, "data.table")
  expect_true(nrow(feed) > 0)
})

test_that("aggregation results_nitrogen is non-empty data.table", {
  nitrogen <- res_no_structure$aggregation_results$results_nitrogen
  expect_s3_class(nitrogen, "data.table")
  expect_true(nrow(nitrogen) > 0)
})

# ---- run_gleam: GWP options --------------------------------------------------
test_that("run_gleam works with different GWP sets", {
  for (gwp in c("AR6", "AR5_excluding_carbon_feedback", "AR4")) {
    result <- run_gleam_no_structure(d_gleam, global_warming_potential_set = gwp)
    expect_type(result, "list")
    expect_true(
      nrow(result$aggregation_results$results_emissions) > 0,
      info = paste("Empty emissions for GWP:", gwp)
    )
  }
})
