# Tests for run_gleam() — main pipeline entry point

run_gleam_examples_path <- local({
  p <- testthat::test_path("..", "..", "inst", "extdata", "run_gleam_examples")
  if (dir.exists(p)) p else system.file("extdata", "run_gleam_examples", package = "gleam")
})

demographic_cohorts <- c("FA", "FJ", "FS", "MA", "MJ", "MS")

# Load example data once at file scope to avoid re-reading CSVs in every test.
d_gleam <- local({
  path <- run_gleam_examples_path
  cohort_no_structure <- data.table::fread(
    file.path(path, "master_chrt_lvl_no_structure_mixed_data.csv")
  )
  cohort_structure <- data.table::fread(
    file.path(path, "master_chrt_lvl_structure_data.csv")
  )
  herd <- data.table::fread(file.path(path, "master_hrd_lvl_mixed_data.csv"))
  fn_herds <- unique(cohort_no_structure[cohort_short == "FN", herd_id])
  mn_herds <- unique(cohort_no_structure[cohort_short == "MN", herd_id])
  herd[is.na(prop_nondemo_fem_juv), prop_nondemo_fem_juv := 0]
  herd[is.na(prop_nondemo_mal_juv), prop_nondemo_mal_juv := 0]
  herd[!herd_id %in% fn_herds, prop_nondemo_fem_juv := 0]
  herd[!herd_id %in% mn_herds, prop_nondemo_mal_juv := 0]
  herd[is.na(live_weight_female_nondemographic_end), live_weight_female_nondemographic_end := live_weight_female_at_slaughter]
  herd[is.na(live_weight_male_nondemographic_end), live_weight_male_nondemographic_end := live_weight_male_at_slaughter]

  list(
    cohort_no_structure = cohort_no_structure,
    cohort_structure = cohort_structure,
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

# The current full-pipeline master already includes the mixed herd cohorts.
d_gleam_mixed <- d_gleam

d_gleam_chk_industrial <- local({
  path <- run_gleam_examples_path

  list(
    cohort_no_structure = data.table::fread(
      file.path(path, "master_chrt_lvl_no_structure_nondemo_data.csv")
    ),
    herd = data.table::fread(
      file.path(path, "master_hrd_lvl_nondemo_data.csv")
    ),
    feed_rations = data.table::fread(
      file.path(path, "feed_rations_share_chrt_nondemo.csv")
    ),
    feed_params = data.table::fread(file.path(path, "feed_quality.csv")),
    feed_emissions = data.table::fread(
      file.path(path, "feed_emission_factors.csv")
    ),
    mms_fraction = data.table::fread(
      file.path(path, "manure_management_system_fraction_nondemo.csv")
    ),
    mms_factors = data.table::fread(
      file.path(path, "manure_management_system_factors_nondemo.csv")
    )
  )
})

# Helper: call run_gleam with defaults, allowing any argument to be overridden.
# Unlike modifyList, this preserves NULL overrides (important for NULL-rejection tests).
run_gleam_default <- function(data, has_herd_structure = FALSE, ...) {
  use_structure <- isTRUE(has_herd_structure)
  cohort_selected <- if (use_structure) data$cohort_structure else data$cohort_no_structure
  run_demographic_default <- any(cohort_selected$cohort_short %in% demographic_cohorts, na.rm = TRUE)
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
        file.path(run_gleam_examples_path, "master_hrd_lvl_mixed_data.csv")
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
  bad_herd[, `:=`(
    prop_nondemo_fem_juv = 0,
    prop_nondemo_mal_juv = 0
  )]
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
    "Missing .*FN.*herd_id.*9|proportion_nondemographic"
  )
})

test_that("rejects missing MN rows when prop_nondemo_mal_juv is positive", {
  bad_cohort <- data.table::copy(d_gleam_mixed$cohort_no_structure)
  bad_cohort <- bad_cohort[!(herd_id == 1 & cohort_short == "MN")]

  expect_error(
    run_gleam_no_structure(d_gleam_mixed, cohort_level_data = bad_cohort),
    "Missing .*MN.*herd_id.*1|proportion_nondemographic"
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

test_that("run_gleam TRUE path preserves the structured cohort set per herd", {
  cohort <- res_with_structure$cohort_level_results
  for (hid in unique(cohort$herd_id)) {
    result_rows <- cohort[herd_id == hid, .(cohort_short, nondemo_productive_phase_id)]
    input_rows <- d_gleam$cohort_structure[
      herd_id == hid, .(cohort_short, nondemo_productive_phase_id)
    ]
    data.table::setorder(result_rows, cohort_short, nondemo_productive_phase_id)
    data.table::setorder(input_rows, cohort_short, nondemo_productive_phase_id)
    expect_equal(result_rows, input_rows, info = paste("herd_id:", hid))
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
  input_sizes <- d_gleam$cohort_structure[, .(
    herd_id, cohort_short, nondemo_productive_phase_id, cohort_stock_size
  )]
  result_sizes <- cohort[, .(
    herd_id, cohort_short, nondemo_productive_phase_id, cohort_stock_size
  )]
  data.table::setorder(input_sizes, herd_id, cohort_short, nondemo_productive_phase_id)
  data.table::setorder(result_sizes, herd_id, cohort_short, nondemo_productive_phase_id)
  expect_equal(result_sizes, input_sizes, ignore_attr = TRUE)
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


d_gleam_mixed_chickens <- lapply(d_gleam, function(data) {
  if ("herd_id" %in% names(data)) data[herd_id %in% c(14, 15)] else data.table::copy(data)
})
d_gleam_mixed_chickens$herd <- data.table::fread(file.path(
  run_gleam_examples_path, "master_hrd_lvl_mixed_data.csv"
))[herd_id %in% c(14, 15)]

test_that("run_gleam rejects missing demographic rations instead of dropping cohorts", {
  missing_demographic <- d_gleam_mixed_chickens$feed_rations[
    !cohort_short %in% demographic_cohorts
  ]
  error <- expect_error(
    suppressMessages(run_gleam_no_structure(d_gleam_mixed_chickens,
      feed_rations = missing_demographic
    )),
    "Missing feed rations"
  )
  expect_match(conditionMessage(error), "14 / CHK / FA / NA", fixed = TRUE)
  expect_match(conditionMessage(error), "15 / CHK / MS / NA", fixed = TRUE)
})

test_that("run_gleam requires ration coverage for each non-demographic phase", {
  missing_phase <- d_gleam_mixed_chickens$feed_rations[
    !(herd_id == 14 & cohort_short == "FN" & nondemo_productive_phase_id == 2)
  ]
  for (has_structure in c(FALSE, TRUE)) {
    error <- expect_error(
      suppressMessages(run_gleam_default(d_gleam_mixed_chickens,
        has_herd_structure = has_structure, feed_rations = missing_phase
      )),
      "Missing feed rations"
    )
    expect_match(conditionMessage(error), "14 / CHK / FN / 2", fixed = TRUE)
  }
})

test_that("shipped mixed chicken examples retain every cohort and total herd stock", {
  result <- suppressMessages(run_gleam_no_structure(d_gleam_mixed_chickens))
  output <- result$cohort_level_results
  key_cols <- c("herd_id", "species_short", "cohort_short", "nondemo_productive_phase_id")
  actual_keys <- output[, ..key_cols]
  expected_keys <- d_gleam_mixed_chickens$cohort_no_structure[, ..key_cols]
  data.table::setorderv(actual_keys, key_cols)
  data.table::setorderv(expected_keys, key_cols)
  expect_equal(as.data.frame(actual_keys), as.data.frame(expected_keys))

  for (id in c(14, 15)) {
    expect_equal(
      sum(output[herd_id == id, cohort_stock_size]),
      d_gleam_mixed_chickens$herd[herd_id == id, herd_size_total]
    )
  }
  expect_true(all(output$ration_intake > 0))
  expect_true(all(output$ch4_manure_other > 0))
  expect_equal(
    sum(result$aggregation_results$results_feed[variable_name == "ration_intake", value_total]),
    sum(output$ration_intake * output$cohort_stock_size) * 365
  )
})

test_that("non-demographic fraction examples match the cohort phases", {
  key_cols <- c("herd_id", "cohort_short", "nondemo_productive_phase_id")
  expected <- unique(d_gleam_chk_industrial$cohort_no_structure[, ..key_cols])
  data.table::setorderv(expected, key_cols)
  fractions <- list(
    feed_ration_fraction = d_gleam_chk_industrial$feed_rations,
    manure_management_system_fraction = d_gleam_chk_industrial$mms_fraction
  )
  for (fraction_col in names(fractions)) {
    data <- fractions[[fraction_col]]
    actual <- unique(data[, ..key_cols])
    data.table::setorderv(actual, key_cols)
    expect_equal(actual, expected)
    totals <- data[, lapply(.SD, sum), by = key_cols, .SDcols = fraction_col]
    expect_equal(totals[[fraction_col]], rep(1, nrow(totals)))
  }
})

test_that("industrial chickens complete the non-demographic-only pipeline", {
  input <- data.table::fread(file.path(
    run_gleam_examples_path, "master_chrt_lvl_no_structure_nondemo_data.csv"
  ))
  expect_equal(nrow(input), 6L)
  expect_true(all(input$cohort_short %in% c("FN", "MN")))
  expect_setequal(input$herd_id, c(14L, 15L))
  expect_equal(
    d_gleam_chk_industrial$mms_factors,
    d_gleam$mms_factors[herd_id %in% input$herd_id]
  )

  expect_no_warning(
    result <- suppressMessages(run_gleam_no_structure(d_gleam_chk_industrial))
  )
  output <- result$cohort_level_results

  expect_equal(nrow(output), nrow(d_gleam_chk_industrial$cohort_no_structure))
  expect_true(all(output$species_short == "CHK"))
  expect_true(all(output$cohort_short %in% c("FN", "MN")))
  expect_true(all(output$cohort_stock_size > 0))
  expect_true(all(is.finite(output$ration_intake)))
  expect_true(all(output$ration_intake > 0))
  expect_equal(output$ch4_enteric, rep(0, nrow(output)))
  expect_gt(sum(output$meat_production_live_weight_cohort), 0)
  expect_equal(
    sum(result$aggregation_results$results_feed[variable_name == "ration_intake", value_total]),
    sum(output$ration_intake * output$cohort_stock_size) * 365
  )
  expect_true(all(vapply(result$aggregation_results, nrow, integer(1)) > 0L))
})

test_that("the non-demographic pipeline allows omitted demographic production inputs", {
  optional_cols <- c(
    "live_weight_female_adult", "live_weight_male_adult", "live_weight_at_weaning",
    "live_weight_female_at_slaughter", "live_weight_male_at_slaughter",
    "milk_yield_day", "lactating_females_fraction",
    "milk_protein_fraction", "milk_fat_fraction", "milk_lactose_fraction",
    "milk_protein_fraction_standard", "milk_fat_fraction_standard", "milk_lactose_fraction_standard",
    "fibre_yield_year"
  )
  legacy_herd <- data.table::copy(d_gleam_chk_industrial$herd)
  missing_cols <- setdiff(optional_cols, names(legacy_herd))
  if (length(missing_cols) > 0L) {
    legacy_herd[, (missing_cols) := NA_real_]
  }
  legacy <- suppressMessages(run_gleam_no_structure(
    d_gleam_chk_industrial, herd_level_data = legacy_herd
  ))

  reduced_herd <- data.table::copy(legacy_herd)
  reduced_herd[, (optional_cols) := NULL]
  expect_no_warning(result <- suppressMessages(run_gleam_no_structure(
    d_gleam_chk_industrial, herd_level_data = reduced_herd
  )))
  expect_false(any(optional_cols %in% names(reduced_herd)))
  expect_equal(result$cohort_level_results, legacy$cohort_level_results)
  expect_equal(result$allocation_long, legacy$allocation_long)
  expect_equal(result$aggregation_results, legacy$aggregation_results)
})

# Simulated-herd pipeline integration tests

d_gleam_diversion <- lapply(d_gleam, function(data) {
  if ("herd_id" %in% names(data)) data[data$herd_id == 9] else data.table::copy(data)
})
d_gleam_diversion$cohort_no_structure <- data.table::fread(system.file(
  "extdata/run_gleam_examples/master_chrt_lvl_no_structure_mixed_data.csv", package = "gleam"
))[herd_id == 9]
d_gleam_diversion$herd <- data.table::fread(system.file(
  "extdata/run_gleam_examples/master_hrd_lvl_mixed_data.csv", package = "gleam"
))[herd_id == 9]

test_that("the full pipeline simulates a demographic herd without supplied population sizes", {
  data <- data.table::copy(d_gleam_diversion)
  data$cohort_no_structure <- data$cohort_no_structure[!cohort_short %in% c("FN", "MN")]
  data$herd[, `:=`(prop_nondemo_fem_juv = 0, prop_nondemo_mal_juv = 0)]
  expect_false("cohort_stock_size" %in% names(data$cohort_no_structure))

  result <- suppressMessages(run_gleam_no_structure(data,
    run_demographic = TRUE,
    run_nondemographic = FALSE, show_indicator = FALSE
  ))

  expect_equal(nrow(result$cohort_level_results), 6L)
  expect_equal(sum(result$cohort_level_results$cohort_stock_size), data$herd$herd_size_total)
  expect_true(all(result$cohort_level_results$ration_intake > 0))
  expect_true(all(vapply(result$aggregation_results, nrow, integer(1)) > 0L))
})

test_that("the full pipeline simulates diversion and retains both non-demographic phases downstream", {
  data <- data.table::copy(d_gleam_diversion)
  expect_false("cohort_stock_size" %in% names(data$cohort_no_structure))
  expect_gt(data$herd$prop_nondemo_fem_juv, 0)
  expect_gt(data$herd$prop_nondemo_mal_juv, 0)

  result <- suppressMessages(run_gleam_no_structure(data,
    run_demographic = TRUE,
    run_nondemographic = TRUE, show_indicator = FALSE
  ))
  output <- result$cohort_level_results
  nondemo <- output[cohort_short %in% c("FN", "MN")]
  key_cols <- c("herd_id", "cohort_short", "nondemo_productive_phase_id")

  actual_keys <- output[, ..key_cols]
  expected_keys <- data$cohort_no_structure[, ..key_cols]
  data.table::setorderv(actual_keys, key_cols)
  data.table::setorderv(expected_keys, key_cols)
  expect_equal(as.data.frame(actual_keys), as.data.frame(expected_keys))
  expect_equal(nrow(nondemo), 4L)
  expect_true(all(nondemo$cohort_stock_size > 0))
  expect_equal(sum(output$cohort_stock_size), data$herd$herd_size_total)
  expect_equal(
    result$herd_level_results$cohort_stock_fem_annual_nondemo,
    output[cohort_short == "FJ", cohort_stock_annual_nondemographic]
  )
  expect_equal(
    result$herd_level_results$cohort_stock_mal_annual_nondemo,
    output[cohort_short == "MJ", cohort_stock_annual_nondemographic]
  )

  downstream <- c(
    "live_weight_cohort_average", "ration_gross_energy", "ration_intake",
    "metabolic_energy_req_total", "ch4_enteric", "nitrogen_excretion",
    "volatile_solids", "ch4_manure_other", "n2o_manure_other_total",
    "co2_ration_fertilizer", "meat_production_live_weight_cohort", "meat_allocation_energy"
  )
  expect_true(all(downstream %in% names(nondemo)))
  expect_true(all(is.finite(as.matrix(nondemo[, ..downstream]))))
  expect_true(all(nondemo$ration_intake > 0))
  expect_true(all(nondemo$nitrogen_excretion > 0))
  expect_gt(sum(nondemo$meat_production_live_weight_cohort), 0)
  expect_equal(
    result$aggregation_results$results_feed[variable_name == "ration_intake", value_total],
    sum(output$ration_intake * output$cohort_stock_size) * 365
  )
  expect_true(all(vapply(result$aggregation_results, nrow, integer(1)) > 0L))
})

test_that("long non-demographic phases retain stock, offtake and downstream production", {
  data <- data.table::copy(d_gleam_diversion)
  data$herd[, `:=`(
    phase1_nondemo_fem_duration_days = 400,
    phase2_nondemo_fem_duration_days = 50,
    phase1_nondemo_mal_duration_days = 400,
    phase2_nondemo_mal_duration_days = 50
  )]
  result <- suppressMessages(run_gleam_no_structure(data,
    run_demographic = TRUE, run_nondemographic = TRUE, show_indicator = FALSE
  ))
  output <- result$cohort_level_results
  phase2 <- output[cohort_short %in% c("FN", "MN") & nondemo_productive_phase_id == 2]
  expect_equal(nrow(phase2), 2L)
  expect_equal(sum(output$cohort_stock_size), data$herd$herd_size_total)
  expect_true(all(phase2$cohort_stock_size > 0))
  expect_true(all(phase2$offtake_heads_assessment > 0))
  expect_true(all(phase2$meat_production_live_weight_cohort > 0))
  fields <- c("ration_intake", "nitrogen_excretion", "ch4_manure_other")
  expect_true(all(is.finite(as.matrix(phase2[, ..fields]))))
  expect_true(all(phase2$ration_intake > 0))
})
