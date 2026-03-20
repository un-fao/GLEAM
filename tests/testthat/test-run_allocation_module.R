# Tests for run_allocation_module()

# Build inputs once at file scope by running prerequisite modules (weights +
# ration quality + energy + production). This avoids re-running the pipeline
# for every test.
inp_alloc <- local({
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
  cohort <- run_production_module(
    cohort_level_data = cohort,
    herd_level_data = herd,
    show_indicator = FALSE
  )
  list(cohort = cohort, herd = herd)
})

# Run the module once at file scope so happy-path tests reuse the cached result
# instead of re-running the module per test.
res_alloc <- run_allocation_module(
  cohort_level_data = inp_alloc$cohort,
  herd_level_data = inp_alloc$herd,
  show_indicator = FALSE
)

# ---- Happy path -------------------------------------------------------------

test_that("runs successfully with valid inputs", {
  expect_type(res_alloc, "list")
  expect_named(res_alloc, c("cohort_allocation_inputs", "allocation_long"))
})

test_that("cohort_allocation_inputs has energy allocation columns", {
  expected_cols <- c(
    "milk_allocation_energy", "meat_allocation_energy",
    "fibre_allocation_energy", "work_allocation_energy",
    "egg_allocation_energy"
  )
  for (col in expected_cols) {
    expect_true(col %in% names(res_alloc$cohort_allocation_inputs),
      info = paste("missing column:", col))
  }
})

test_that("allocation_long has expected structure", {
  alloc <- res_alloc$allocation_long
  expect_s3_class(alloc, "data.table")
  expected_cols <- c(
    "herd_id", "species_short", "variable_name",
    "commodity_name", "commodity_type", "allocation_share"
  )
  for (col in expected_cols) {
    expect_true(col %in% names(alloc), info = paste("missing column:", col))
  }
})

test_that("allocation shares are between 0 and 1", {
  shares <- res_alloc$allocation_long$allocation_share
  expect_true(all(shares >= 0 - 1e-10))
  expect_true(all(shares <= 1 + 1e-10))
})

test_that("allocation shares sum to 1 per variable per herd", {
  alloc <- res_alloc$allocation_long
  sums <- alloc[, .(total = sum(allocation_share)),
    by = .(herd_id, variable_name)]
  expect_true(all(abs(sums$total - 1) < 1e-6),
    info = "allocation shares should sum to 1 per variable per herd")
})

test_that("energy allocation values are non-negative", {
  energy_cols <- c(
    "milk_allocation_energy", "meat_allocation_energy",
    "fibre_allocation_energy", "work_allocation_energy",
    "egg_allocation_energy"
  )
  for (col in energy_cols) {
    expect_true(all(res_alloc$cohort_allocation_inputs[[col]] >= 0),
      info = paste(col, "has negative values"))
  }
})

# ---- Input validation --------------------------------------------------------

test_that("rejects NULL cohort_level_data", {
  expect_error(
    run_allocation_module(
      cohort_level_data = NULL,
      herd_level_data = inp_alloc$herd,
      show_indicator = FALSE
    )
  )
})

test_that("rejects NULL herd_level_data", {
  expect_error(
    run_allocation_module(
      cohort_level_data = inp_alloc$cohort,
      herd_level_data = NULL,
      show_indicator = FALSE
    )
  )
})

test_that("rejects cohort data missing required columns", {
  bad <- data.table::copy(inp_alloc$cohort)
  bad[, milk_production_fpcm_cohort := NULL]
  expect_error(
    run_allocation_module(
      cohort_level_data = bad,
      herd_level_data = inp_alloc$herd,
      show_indicator = FALSE
    ),
    "milk_production_fpcm_cohort"
  )
})

test_that("rejects herd data missing required columns", {
  bad <- data.table::copy(inp_alloc$herd)
  bad[, ratio_me_to_ne := NULL]
  expect_error(
    run_allocation_module(
      cohort_level_data = inp_alloc$cohort,
      herd_level_data = bad,
      show_indicator = FALSE
    ),
    "ratio_me_to_ne"
  )
})
