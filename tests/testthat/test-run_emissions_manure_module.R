# Tests for run_emissions_manure_module()

# Build inputs once at file scope by running prerequisite modules (weights +
# ration quality + energy + enteric + nitrogen). This avoids re-running the
# pipeline for every test.
inp_manure <- local({
  path <- system.file("extdata/run_gleam_examples", package = "gleam")
  cohort_structure <- data.table::fread(
    file.path(path, "master_chrt_lvl_structure_data.csv")
  )
  herd <- data.table::fread(file.path(path, "master_hrd_lvl_data.csv"))
  feed_rations <- data.table::fread(
    file.path(path, "feed_rations_share_chrt.csv")
  )
  feed_params <- data.table::fread(file.path(path, "feed_quality.csv"))
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
  list(
    cohort = cohort,
    mms_fraction = mms_fraction,
    mms_factors = mms_factors
  )
})

# Run the module once at file scope so happy-path tests reuse the cached result
# instead of re-running the module per test.
res_manure <- run_emissions_manure_module(
  cohort_level_data = inp_manure$cohort,
  manure_management_system_fraction = inp_manure$mms_fraction,
  manure_management_system_factors = inp_manure$mms_factors,
  show_indicator = FALSE
)

# ---- Happy path -------------------------------------------------------------

test_that("runs successfully with valid inputs", {
  expect_s3_class(res_manure, "data.table")
  expect_true(nrow(res_manure) > 0)
})

test_that("returns expected manure emission columns", {
  expected_cols <- c(
    "volatile_solids",
    "ch4_manure_pasture", "ch4_manure_burned", "ch4_manure_other",
    "ch4_manure_all_noburn",
    "n2o_manure_pasture_direct", "n2o_manure_burned_direct",
    "n2o_manure_other_direct", "n2o_manure_all_noburn_direct",
    "n2o_manure_pasture_total", "n2o_manure_burned_total",
    "n2o_manure_other_total"
  )
  for (col in expected_cols) {
    expect_true(col %in% names(res_manure), info = paste("missing column:", col))
  }
})

test_that("volatile solids are positive", {
  expect_true(all(res_manure$volatile_solids > 0))
})

test_that("ch4 manure emissions are non-negative", {
  ch4_cols <- c("ch4_manure_pasture", "ch4_manure_burned",
    "ch4_manure_other", "ch4_manure_all_noburn")
  for (col in ch4_cols) {
    expect_true(all(res_manure[[col]] >= 0), info = paste(col, "has negative values"))
  }
})

test_that("n2o manure emissions are non-negative", {
  n2o_cols <- grep("^n2o_manure", names(res_manure), value = TRUE)
  for (col in n2o_cols) {
    expect_true(all(res_manure[[col]] >= 0), info = paste(col, "has negative values"))
  }
})

test_that("preserves original cohort columns", {
  for (col in names(inp_manure$cohort)) {
    expect_true(col %in% names(res_manure), info = paste("missing column:", col))
  }
})

# ---- Input validation --------------------------------------------------------

test_that("rejects NULL cohort_level_data", {
  expect_error(
    run_emissions_manure_module(
      cohort_level_data = NULL,
      manure_management_system_fraction = inp_manure$mms_fraction,
      manure_management_system_factors = inp_manure$mms_factors,
      show_indicator = FALSE
    )
  )
})

test_that("rejects NULL mms_fraction", {
  expect_error(
    run_emissions_manure_module(
      cohort_level_data = inp_manure$cohort,
      manure_management_system_fraction = NULL,
      manure_management_system_factors = inp_manure$mms_factors,
      show_indicator = FALSE
    )
  )
})

test_that("rejects NULL mms_factors", {
  expect_error(
    run_emissions_manure_module(
      cohort_level_data = inp_manure$cohort,
      manure_management_system_fraction = inp_manure$mms_fraction,
      manure_management_system_factors = NULL,
      show_indicator = FALSE
    )
  )
})

test_that("rejects cohort data missing required columns", {
  bad <- data.table::copy(inp_manure$cohort)
  bad[, nitrogen_excretion := NULL]
  expect_error(
    run_emissions_manure_module(
      cohort_level_data = bad,
      manure_management_system_fraction = inp_manure$mms_fraction,
      manure_management_system_factors = inp_manure$mms_factors,
      show_indicator = FALSE
    ),
    "nitrogen_excretion"
  )
})

test_that("rejects mms_fraction missing required columns", {
  bad <- data.table::copy(inp_manure$mms_fraction)
  bad[, manure_management_system_fraction := NULL]
  expect_error(
    run_emissions_manure_module(
      cohort_level_data = inp_manure$cohort,
      manure_management_system_fraction = bad,
      manure_management_system_factors = inp_manure$mms_factors,
      show_indicator = FALSE
    ),
    "manure_management_system_fraction"
  )
})

test_that("rejects mms fractions not summing to 1", {
  bad <- data.table::copy(inp_manure$mms_fraction)
  bad[, manure_management_system_fraction := manure_management_system_fraction * 0.5]
  expect_error(
    run_emissions_manure_module(
      cohort_level_data = inp_manure$cohort,
      manure_management_system_fraction = bad,
      manure_management_system_factors = inp_manure$mms_factors,
      show_indicator = FALSE
    )
  )
})
