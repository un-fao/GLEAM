# Tests for run_weights_module()

# Load example data once at file scope to avoid re-reading CSVs in every test.
d_wt <- local({
  path <- system.file("extdata/run_gleam_examples", package = "gleam")
  list(
    cohort_no_structure = data.table::fread(
      file.path(path, "master_chrt_lvl_no_structure_data.csv")
    ),
    cohort_structure = data.table::fread(
      file.path(path, "master_chrt_lvl_structure_data.csv")
    ),
    herd = data.table::fread(file.path(path, "master_hrd_lvl_data.csv"))
  )
})

# Run the module once at file scope so happy-path tests reuse the cached result
# instead of re-running the module per test.
res_wt <- run_weights_module(
  cohort_level_data = d_wt$cohort_structure,
  herd_level_data = d_wt$herd,
  show_indicator = FALSE
)

# ---- Happy path -------------------------------------------------------------

test_that("runs successfully with valid inputs (no structure)", {
  herd_res <- run_demographic_herd_module(
    cohort_level_data = d_wt$cohort_no_structure,
    herd_level_data = d_wt$herd,
    show_indicator = FALSE
  )
  res <- run_weights_module(
    cohort_level_data = herd_res$cohort_level_results,
    herd_level_data = herd_res$herd_level_results,
    show_indicator = FALSE
  )
  expect_type(res, "list")
  expect_named(res, c("cohort_level_results", "herd_level_results"))
})

test_that("runs successfully with structure data", {
  expect_type(res_wt, "list")
})

test_that("cohort_level_results has expected weight columns", {
  crt <- res_wt$cohort_level_results
  expect_s3_class(crt, "data.table")
  expected_cols <- c(
    "live_weight_mature_stage", "live_weight_cohort_initial",
    "live_weight_cohort_potential_final", "live_weight_cohort_at_slaughter",
    "live_weight_cohort_average", "live_weight_cohort_final",
    "daily_weight_gain"
  )
  for (col in expected_cols) {
    expect_true(col %in% names(crt), info = paste("missing column:", col))
  }
})

test_that("average weights are positive", {
  expect_true(all(res_wt$cohort_level_results$live_weight_cohort_average > 0))
})

test_that("initial weight <= average weight", {
  crt <- res_wt$cohort_level_results
  expect_true(all(crt$live_weight_cohort_initial <= crt$live_weight_cohort_average + 1e-6))
})

test_that("preserves all original cohort columns", {
  for (col in names(d_wt$cohort_structure)) {
    expect_true(col %in% names(res_wt$cohort_level_results),
      info = paste("missing original column:", col))
  }
})

# ---- Input validation --------------------------------------------------------

test_that("rejects NULL cohort_level_data", {
  expect_error(
    run_weights_module(
      cohort_level_data = NULL,
      herd_level_data = d_wt$herd,
      show_indicator = FALSE
    )
  )
})

test_that("rejects NULL herd_level_data", {
  expect_error(
    run_weights_module(
      cohort_level_data = d_wt$cohort_structure,
      herd_level_data = NULL,
      show_indicator = FALSE
    )
  )
})

test_that("rejects cohort data missing required columns", {
  bad <- data.table::copy(d_wt$cohort_structure)
  bad[, offtake_rate := NULL]
  expect_error(
    run_weights_module(
      cohort_level_data = bad,
      herd_level_data = d_wt$herd,
      show_indicator = FALSE
    ),
    "offtake_rate"
  )
})

test_that("rejects herd data missing weight columns", {
  bad <- data.table::copy(d_wt$herd)
  bad[, live_weight_female_adult := NULL]
  expect_error(
    run_weights_module(
      cohort_level_data = d_wt$cohort_structure,
      herd_level_data = bad,
      show_indicator = FALSE
    ),
    "live_weight_female_adult"
  )
})

test_that("rejects birth weight >= slaughter weight", {
  bad_herd <- data.table::copy(d_wt$herd)
  bad_herd[1, live_weight_at_birth := 999]
  expect_error(
    run_weights_module(
      cohort_level_data = d_wt$cohort_structure,
      herd_level_data = bad_herd,
      show_indicator = FALSE
    ),
    "live_weight_at_birth"
  )
})

test_that("rejects mismatched herd_ids", {
  bad_herd <- d_wt$herd[herd_id == 1]
  expect_error(
    run_weights_module(
      cohort_level_data = d_wt$cohort_structure,
      herd_level_data = bad_herd,
      show_indicator = FALSE
    )
  )
})
