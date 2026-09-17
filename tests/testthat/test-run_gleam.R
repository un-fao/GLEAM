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
run_gleam_default <- function(data, has_herd_structure = FALSE, ...) {
  use_structure <- isTRUE(has_herd_structure)
  defaults <- list(
    has_herd_structure = has_herd_structure,
    cohort_level_data = if (use_structure) data$cohort_structure else data$cohort_no_structure,
    herd_level_data = data$herd,
    feed_rations = data$feed_rations,
    feed_params = data$feed_params,
    feed_emissions = data$feed_emissions,
    manure_management_system_fraction = data$mms_fraction,
    manure_management_system_factors = data$mms_factors,
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
# This reduces execution from ~18 pipeline runs down to 2.
res_no_structure <- run_gleam_no_structure(d_gleam)
res_with_structure <- run_gleam_with_structure(d_gleam)

test_that("all run functions accept only TRUE or FALSE for validate_inputs", {
  run_functions <- grep("^run_", getNamespaceExports("gleam"), value = TRUE)
  for (function_name in run_functions) {
    for (flag in list(NA, NULL, logical(), c(TRUE, FALSE), 0, 1, "FALSE")) {
      expect_error(
        do.call(getExportedValue("gleam", function_name), list(validate_inputs = flag)),
        "validate_inputs.*must be TRUE or FALSE"
      )
    }
  }
})

test_that("unchecked pipeline skips validators and preserves results in both modes", {
  previous <- options("gleam.validate", "gleam.validation_active", "gleam.validation_cache")
  # A real range lookup would fail with an empty rules table.
  testthat::local_mocked_bindings(
    parameter_rules = parameter_rules[0L], .package = "gleam"
  )
  for (mode in c(FALSE, TRUE)) {
    warnings <- character()
    result <- withCallingHandlers(
      run_gleam_default(d_gleam, has_herd_structure = mode, validate_inputs = c(enabled = FALSE)),
      warning = function(w) {
        warnings <<- c(warnings, conditionMessage(w))
        invokeRestart("muffleWarning")
      }
    )
    expect_length(warnings, 1L)
    expect_match(warnings, "Input validation has been turned off")
    expected <- if (mode) res_with_structure else res_no_structure
    expect_equal(result, expected, ignore_attr = TRUE)
    expect_identical(options("gleam.validate", "gleam.validation_active", "gleam.validation_cache"), previous)
  }
  expect_warning(
    expect_error(run_gleam_default(d_gleam, validate_inputs = TRUE), "parameter_rules.*must contain at least one row"),
    NA
  )
})

test_that("validation is restored after nested runs and calculation errors", {
  previous <- options("gleam.validate", "gleam.validation_active", "gleam.validation_cache")
  testthat::local_mocked_bindings(
    run_weights_module = function(...) {
      expect_false(validation_enabled())
      expect_error(run_gleam(simulation_duration = 0), "simulation_duration.*positive")
      expect_false(validation_enabled())
      stop("Example calculation failure")
    },
    .package = "gleam"
  )
  expect_warning(
    expect_error(run_gleam_with_structure(d_gleam, validate_inputs = FALSE), "Example calculation failure"),
    "Input validation has been turned off"
  )
  expect_identical(options("gleam.validate", "gleam.validation_active", "gleam.validation_cache"), previous)
  expect_error(calc_cohort_weights("invalid"), "cohort_short")
})

test_that("standalone modules skip validation only when requested", {
  previous <- options("gleam.validate", "gleam.validation_active", "gleam.validation_cache")
  expected <- run_weights_module(
    d_gleam$cohort_structure, d_gleam$herd, show_indicator = FALSE
  )
  testthat::local_mocked_bindings(
    parameter_rules = parameter_rules[0L], .package = "gleam"
  )
  expect_warning(
    result <- run_weights_module(
      d_gleam$cohort_structure, d_gleam$herd, show_indicator = FALSE, validate_inputs = FALSE
    ),
    "Input validation has been turned off"
  )
  expect_equal(result, expected, ignore_attr = TRUE)
  expect_identical(options("gleam.validate", "gleam.validation_active", "gleam.validation_cache"), previous)
  expect_error(
    run_weights_module(d_gleam$cohort_structure, d_gleam$herd, show_indicator = FALSE),
    "parameter_rules.*must contain at least one row"
  )
  expect_identical(options("gleam.validate", "gleam.validation_active", "gleam.validation_cache"), previous)
})

test_that("standalone modules restore validation after calculation errors", {
  previous <- options("gleam.validate", "gleam.validation_active", "gleam.validation_cache")
  testthat::local_mocked_bindings(
    calc_cohort_weights = function(...) {
      expect_false(validation_enabled())
      stop("Example calculation failure")
    },
    .package = "gleam"
  )
  expect_warning(
    expect_error(
      run_weights_module(
        d_gleam$cohort_structure, d_gleam$herd, show_indicator = FALSE, validate_inputs = FALSE
      ),
      "Example calculation failure"
    ),
    "Input validation has been turned off"
  )
  expect_identical(options("gleam.validate", "gleam.validation_active", "gleam.validation_cache"), previous)
})

test_that("both pipeline modes reject an empty rule table", {
  testthat::local_mocked_bindings(parameter_rules = parameter_rules[0L], .package = "gleam")
  for (mode in c(FALSE, TRUE)) {
    expect_error(run_gleam_default(d_gleam, has_herd_structure = mode),
                 "parameter_rules.*must contain at least one row")
  }
})

test_that("modules share the pipeline cache and nested pipelines restore it", {
  previous <- options("gleam.validate", "gleam.validation_active", "gleam.validation_cache")
  caches <- list()
  original_setup <- setup_validation
  original_weights <- run_weights_module
  testthat::local_mocked_bindings(
    setup_validation = function(validate_inputs, new_cache = FALSE) {
      restore <- original_setup(validate_inputs, new_cache)
      caches[[length(caches) + 1L]] <<- getOption("gleam.validation_cache")
      restore
    },
    run_weights_module = function(...) {
      outer_cache <- getOption("gleam.validation_cache")
      expect_true(is.environment(outer_cache))
      original_weights(...)
      expect_identical(caches[[2L]], outer_cache)
      expect_error(run_gleam(simulation_duration = 0), "simulation_duration.*positive")
      expect_false(identical(caches[[3L]], outer_cache))
      expect_identical(getOption("gleam.validation_cache"), outer_cache)
      stop("Example calculation failure")
    },
    .package = "gleam"
  )
  expect_error(run_gleam_with_structure(d_gleam), "Example calculation failure")
  expect_length(caches, 3L)
  expect_identical(options("gleam.validate", "gleam.validation_active", "gleam.validation_cache"), previous)
  expect_error(calc_cohort_weights("invalid"), "cohort_short")
})

test_that("cached rules still validate later values for the same species and cohort", {
  bad_herd <- data.table::copy(d_gleam$herd)
  bound <- max(bad_herd$live_weight_female_adult)
  rules <- data.table::copy(parameter_rules)
  rules[variable == "live_weight_female_adult", upper_bound := bound]
  testthat::local_mocked_bindings(parameter_rules = rules, .package = "gleam")
  bad_herd[herd_id == 2, live_weight_female_adult := bound + 1]
  expect_error(run_gleam_with_structure(d_gleam, herd_level_data = bad_herd),
               "live_weight_female_adult.*out of range.*CTL/")
})

test_that("both pipeline modes default missing mitigation to one and preserve supplied factors", {
  small <- lapply(d_gleam, function(data) {
    if ("herd_id" %in% names(data)) data[herd_id == 1L] else data.table::copy(data)
  })
  for (mode in c(FALSE, TRUE)) {
    cohorts <- data.table::copy(if (mode) small$cohort_structure else small$cohort_no_structure)
    baseline <- if (mode) res_with_structure else res_no_structure
    expect_false("ch4_mitigation_factor" %in% names(cohorts))
    expect_true(all(baseline$cohort_level_results$ch4_mitigation_factor == 1))
    cohorts[, ch4_mitigation_factor := 1]
    cohorts[1L, ch4_mitigation_factor := NA_real_]
    expect_error(run_gleam_default(small, has_herd_structure = mode,
      cohort_level_data = cohorts), "ch4_mitigation_factor")
    cohorts[, ch4_mitigation_factor := rep(c(0, 0.5, 1), length.out = .N)]
    result <- run_gleam_default(small, has_herd_structure = mode, cohort_level_data = cohorts)
    actual <- result$cohort_level_results
    reference <- baseline$cohort_level_results[
      actual, on = .(herd_id, cohort_short), ch4_enteric
    ]
    expect_equal(actual$ch4_enteric, reference * actual$ch4_mitigation_factor)
    expect_equal(actual[cohorts, on = .(herd_id, cohort_short), ch4_mitigation_factor],
                 cohorts$ch4_mitigation_factor)
  }
})

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

# Preserve structural/calculated fields while removing unused matrix inputs.
matrix_inputs_for_cohort <- function(data, context, table_filter, module = NULL) {
  required <- unique(get_required_parameter_rules(context, module, table_filter, TRUE)$variable)
  external <- parameter_rules[requirement %in% c("R", "O") & input_table == table_filter, variable]
  structural <- c("herd_id", "species_short", "cohort_short", "feed_id", "feed_name", "manure_management_system")
  # Current pig/camel equations use these fractions despite their matrix rows.
  code_required <- c("low_activity_fraction", "high_activity_fraction")
  remove <- setdiff(external, c(required, structural, code_required))
  data[, setdiff(names(data), remove), with = FALSE]
}

test_that("the pipeline supports each species/cohort with only applicable external inputs", {
  for (hid in c(1, 3, 5, 7, 9, 11)) for (cohort in gleam_cohorts) {
    context <- d_gleam$cohort_structure[herd_id == hid & cohort_short == cohort]
    feed <- d_gleam$feed_rations[herd_id == hid & cohort_short == cohort]
    args <- list(
      cohort_level_data = context,
      herd_level_data = d_gleam$herd[herd_id == hid],
      feed_rations = feed,
      feed_params = d_gleam$feed_params[feed_id %in% feed$feed_id],
      feed_emissions = d_gleam$feed_emissions[feed_id %in% feed$feed_id],
      manure_management_system_fraction = d_gleam$mms_fraction[herd_id == hid & cohort_short == cohort],
      manure_management_system_factors = d_gleam$mms_factors[herd_id == hid]
    )
    for (nm in names(args)) args[[nm]] <- matrix_inputs_for_cohort(args[[nm]], context, nm)
    before <- lapply(args, data.table::copy)
    result <- do.call(run_gleam, c(args, list(has_herd_structure = TRUE, show_indicator = FALSE)))
    actual <- result$cohort_level_results
    expected <- res_with_structure$cohort_level_results[herd_id == hid & cohort_short == cohort]
    compare <- c("live_weight_cohort_average", "daily_weight_gain", "metabolic_energy_req_total",
                 "ration_intake", "nitrogen_retention", "ch4_enteric", "milk_production_fpcm_cohort")
    expect_equal(actual[, ..compare], expected[, ..compare], ignore_attr = TRUE,
                 info = paste(context$species_short, cohort))
    # Pipeline/modules must not add unused input columns to callers' tables.
    expect_equal(lapply(args, names), lapply(before, names))
  }
})

test_that("standalone modules accept separate cohorts and omit unrelated external inputs", {
  modules <- list(
    weights = run_weights_module, metabolic_energy = run_metabolic_energy_req_module,
    nitrogen = run_nitrogen_balance_module, production = run_production_module,
    allocation = run_allocation_module, manure = run_emissions_manure_module,
    enteric = run_emissions_enteric_module, aggregation = run_aggregation_module,
    ration_quality = run_ration_quality_module, feed_emissions = run_emissions_ration_module
  )
  for (i in seq_along(gleam_cohorts)) {
    hid <- c(1, 3, 5, 7, 9, 11)[i]
    cohort <- gleam_cohorts[i]
    context <- res_with_structure$cohort_level_results[herd_id == hid & cohort_short == cohort]
    feed <- d_gleam$feed_rations[herd_id == hid & cohort_short == cohort]
    for (module in names(modules)) {
      args <- list(
        cohort_level_data = context, herd_level_data = d_gleam$herd[herd_id == hid],
        feed_rations = feed, feed_params = d_gleam$feed_params[feed_id %in% feed$feed_id],
        feed_emissions = d_gleam$feed_emissions[feed_id %in% feed$feed_id],
        manure_management_system_fraction = d_gleam$mms_fraction[herd_id == hid & cohort_short == cohort],
        manure_management_system_factors = d_gleam$mms_factors[herd_id == hid],
        allocation_herd_long = res_with_structure$allocation_long[herd_id == hid]
      )
      for (nm in names(args)) args[[nm]] <- matrix_inputs_for_cohort(args[[nm]], context, nm, module)
      names(args)[names(args) == "feed_rations"] <- "rations_share"
      args <- args[intersect(names(args), names(formals(modules[[module]])))]
      expect_no_error(do.call(modules[[module]], c(args, list(show_indicator = FALSE))))
    }
  }
})

test_that("pipeline catches missing applicable inputs before calculation", {
  bad <- data.table::copy(d_gleam$herd)
  bad[herd_id == 1, milk_yield_day := NA_real_]
  expect_error(run_gleam_with_structure(d_gleam, herd_level_data = bad), "milk_yield_day.*missing values")
  expect_error(run_gleam_no_structure(d_gleam,
    cohort_level_data = d_gleam$cohort_no_structure[cohort_short == "FA"]), "exactly 6 rows")
})

test_that("both pipeline modes use comparison operators from the shared matrix", {
  ranges <- data.table::copy(parameter_rules)
  ranges[nzchar(comparison_operator) & cohort_short == "FJ" &
           validation_function == "calc_cohort_weights;run_weights_module", comparison_operator := ">"]
  testthat::local_mocked_bindings(parameter_rules = ranges, .package = "gleam")
  for (mode in c(FALSE, TRUE)) {
    expect_error(run_gleam_default(d_gleam, has_herd_structure = mode),
                 "live_weight_at_birth.*must be greater than.*live_weight_at_weaning")
  }
})
