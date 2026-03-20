# Tests for run_emissions_enteric_module()

# Build inputs once at file scope by running prerequisite modules (weights +
# ration quality + energy). This avoids re-running the pipeline for every test.
inp_enteric <- local({
  path <- system.file("extdata/run_gleam_examples", package = "gleam")
  cohort_structure <- data.table::fread(
    file.path(path, "master_chrt_lvl_structure_data.csv")
  )
  herd <- data.table::fread(file.path(path, "master_hrd_lvl_data.csv"))
  feed_rations <- data.table::fread(
    file.path(path, "feed_rations_share_chrt.csv")
  )
  feed_params <- data.table::fread(file.path(path, "feed_quality.csv"))

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
  cohort
})

# Run the module once at file scope so happy-path tests reuse the cached result
# instead of re-running the module per test.
res_enteric <- run_emissions_enteric_module(
  cohort_level_data = inp_enteric,
  show_indicator = FALSE
)

# ---- Happy path -------------------------------------------------------------

test_that("runs successfully with valid inputs", {
  expect_s3_class(res_enteric, "data.table")
  expect_true(nrow(res_enteric) > 0)
})

test_that("returns expected enteric emission columns", {
  expected_cols <- c(
    "ch4_conversion_factor_ym", "ch4_enteric", "ch4_mitigation_factor"
  )
  for (col in expected_cols) {
    expect_true(col %in% names(res_enteric), info = paste("missing column:", col))
  }
})

test_that("enteric emissions are non-negative", {
  expect_true(all(res_enteric$ch4_enteric >= 0))
})

test_that("ym factor is non-negative", {
  expect_true(all(res_enteric$ch4_conversion_factor_ym >= 0))
})

test_that("default mitigation factor is 1", {
  expect_true(all(res_enteric$ch4_mitigation_factor == 1))
})

test_that("preserves original cohort columns", {
  for (col in names(inp_enteric)) {
    expect_true(col %in% names(res_enteric), info = paste("missing column:", col))
  }
})

# ---- Input validation --------------------------------------------------------

test_that("rejects NULL cohort_level_data", {
  expect_error(
    run_emissions_enteric_module(
      cohort_level_data = NULL,
      show_indicator = FALSE
    )
  )
})

test_that("rejects cohort data missing required columns", {
  bad <- data.table::copy(inp_enteric)
  bad[, ration_intake := NULL]
  expect_error(
    run_emissions_enteric_module(
      cohort_level_data = bad,
      show_indicator = FALSE
    ),
    "ration_intake"
  )
})

test_that("rejects non-data.frame input", {
  expect_error(
    run_emissions_enteric_module(
      cohort_level_data = "not a data frame",
      show_indicator = FALSE
    )
  )
})
