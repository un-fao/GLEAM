# Tests for run_aggregation_module()

# Build full pipeline once at file scope by running all prerequisite modules
# (weights + ration quality + energy + enteric + nitrogen + manure + feed
# emissions + production + allocation). This avoids re-running the entire
# pipeline for every test.
inp_agg <- local({
  path <- system.file("extdata/run_gleam_examples", package = "gleam")
  cohort_structure <- data.table::fread(
    file.path(path, "master_chrt_lvl_structure_data.csv")
  )
  herd <- data.table::fread(file.path(path, "master_hrd_lvl_data.csv"))
  feed_rations <- data.table::fread(
    file.path(path, "feed_rations_share_chrt.csv")
  )
  feed_params <- data.table::fread(file.path(path, "feed_quality.csv"))
  feed_emissions <- data.table::fread(
    file.path(path, "feed_emission_factors.csv")
  )
  mms_fraction <- data.table::fread(
    file.path(path, "manure_management_system_fraction.csv")
  )
  mms_factors <- data.table::fread(
    file.path(path, "manure_management_system_factors.csv")
  )

  wt <- run_weights_module(
    cohort_level_data = cohort_structure,
    herd_level_data = herd,
    show_indicator = FALSE
  )
  rq <- run_ration_quality_module(
    rations_share = feed_rations,
    feed_params = feed_params,
    show_indicator = FALSE
  )
  cohort <- merge(
    wt$cohort_level_results, rq,
    by = c("herd_id", "species_short", "cohort_short")
  )
  cohort <- run_metabolic_energy_req_module(
    cohort_level_data = cohort,
    herd_level_data = herd,
    show_indicator = FALSE
  )
  cohort <- run_emissions_enteric_module(
    cohort_level_data = cohort,
    show_indicator = FALSE
  )
  cohort <- run_nitrogen_balance_module(
    cohort_level_data = cohort,
    herd_level_data = herd,
    show_indicator = FALSE
  )
  cohort <- run_emissions_manure_module(
    cohort_level_data = cohort,
    manure_management_system_fraction = mms_fraction,
    manure_management_system_factors = mms_factors,
    show_indicator = FALSE
  )
  fe <- run_emissions_ration_module(
    rations_share = feed_rations,
    feed_emissions = feed_emissions,
    show_indicator = FALSE
  )
  cohort <- merge(
    cohort, fe,
    by = c("herd_id", "species_short", "cohort_short")
  )
  cohort <- run_production_module(
    cohort_level_data = cohort,
    herd_level_data = herd,
    show_indicator = FALSE
  )
  alloc <- run_allocation_module(
    cohort_level_data = cohort,
    herd_level_data = herd,
    show_indicator = FALSE
  )
  list(
    cohort = alloc$cohort_allocation_inputs,
    allocation_long = alloc$allocation_long
  )
})

# Run the module once at file scope so happy-path tests reuse the cached result
# instead of re-running the module per test.
res_agg <- run_aggregation_module(
  cohort_level_data = inp_agg$cohort,
  allocation_herd_long = inp_agg$allocation_long,
  show_indicator = FALSE
)

# ---- Happy path -------------------------------------------------------------

test_that("runs successfully with valid inputs", {
  expect_type(res_agg, "list")
  expect_named(res_agg, c(
    "results_emissions", "results_feed",
    "results_production", "results_nitrogen"
  ))
})

test_that("results_emissions is a data.table with expected columns", {
  em <- res_agg$results_emissions
  expect_s3_class(em, "data.table")
  expect_true(nrow(em) > 0)
  expected_cols <- c("herd_id", "species_short", "variable_name",
    "commodity_name", "allocation_share")
  for (col in expected_cols) {
    expect_true(col %in% names(em), info = paste("missing column:", col))
  }
})

test_that("results_feed is a non-empty data.table", {
  expect_s3_class(res_agg$results_feed, "data.table")
  expect_true(nrow(res_agg$results_feed) > 0)
})

test_that("results_production is a non-empty data.table", {
  expect_s3_class(res_agg$results_production, "data.table")
  expect_true(nrow(res_agg$results_production) > 0)
})

test_that("results_nitrogen is a non-empty data.table", {
  expect_s3_class(res_agg$results_nitrogen, "data.table")
  expect_true(nrow(res_agg$results_nitrogen) > 0)
})

test_that("different GWP sets produce different CO2eq values", {
  res_ar4 <- run_aggregation_module(
    cohort_level_data = inp_agg$cohort,
    allocation_herd_long = inp_agg$allocation_long,
    global_warming_potential_set = "AR4",
    show_indicator = FALSE
  )
  expect_false(identical(res_agg$results_emissions, res_ar4$results_emissions))
})

test_that("custom simulation_duration works", {
  res <- run_aggregation_module(
    cohort_level_data = inp_agg$cohort,
    allocation_herd_long = inp_agg$allocation_long,
    simulation_duration = 180,
    show_indicator = FALSE
  )
  expect_type(res, "list")
  expect_true(nrow(res$results_emissions) > 0)
})

# ---- Input validation --------------------------------------------------------

test_that("rejects NULL cohort_level_data", {
  expect_error(
    run_aggregation_module(
      cohort_level_data = NULL,
      allocation_herd_long = inp_agg$allocation_long,
      show_indicator = FALSE
    )
  )
})

test_that("rejects NULL allocation_herd_long", {
  expect_error(
    run_aggregation_module(
      cohort_level_data = inp_agg$cohort,
      allocation_herd_long = NULL,
      show_indicator = FALSE
    )
  )
})

test_that("rejects invalid global_warming_potential_set", {
  expect_error(
    run_aggregation_module(
      cohort_level_data = inp_agg$cohort,
      allocation_herd_long = inp_agg$allocation_long,
      global_warming_potential_set = "INVALID",
      show_indicator = FALSE
    ),
    "global_warming_potential_set"
  )
})

test_that("rejects negative simulation_duration", {
  expect_error(
    run_aggregation_module(
      cohort_level_data = inp_agg$cohort,
      allocation_herd_long = inp_agg$allocation_long,
      simulation_duration = -1,
      show_indicator = FALSE
    )
  )
})

test_that("rejects cohort data missing required columns", {
  bad <- data.table::copy(inp_agg$cohort)
  bad[, cohort_stock_size := NULL]
  expect_error(
    run_aggregation_module(
      cohort_level_data = bad,
      allocation_herd_long = inp_agg$allocation_long,
      show_indicator = FALSE
    ),
    "cohort_stock_size"
  )
})

test_that("rejects allocation data missing required columns", {
  bad <- data.table::copy(inp_agg$allocation_long)
  bad[, allocation_share := NULL]
  expect_error(
    run_aggregation_module(
      cohort_level_data = inp_agg$cohort,
      allocation_herd_long = bad,
      show_indicator = FALSE
    ),
    "allocation_share"
  )
})
