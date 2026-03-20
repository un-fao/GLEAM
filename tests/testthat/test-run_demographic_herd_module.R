# Tests for run_demographic_herd_module()

# Load example data once at file scope to avoid re-reading CSVs in every test.
d_demo <- local({
  path <- system.file("extdata/run_gleam_examples", package = "gleam")
  list(
    cohort = data.table::fread(
      file.path(path, "master_chrt_lvl_no_structure_data.csv")
    ),
    herd = data.table::fread(file.path(path, "master_hrd_lvl_data.csv"))
  )
})

# Run the module once at file scope so happy-path tests reuse the cached result
# instead of re-running the module per test.
res_demo <- run_demographic_herd_module(
  cohort_level_data = d_demo$cohort,
  herd_level_data = d_demo$herd,
  show_indicator = FALSE
)

# ---- Happy path -------------------------------------------------------------

test_that("runs successfully with valid inputs", {
  expect_type(res_demo, "list")
  expect_named(res_demo, c("cohort_level_results", "herd_level_results"))
})

test_that("cohort_level_results is a data.table with expected columns", {
  crt <- res_demo$cohort_level_results
  expect_s3_class(crt, "data.table")
  expect_true(nrow(crt) > 0)
  expected_cols <- c("cohort_stock_size", "offtake_heads", "offtake_heads_assessment")
  for (col in expected_cols) {
    expect_true(col %in% names(crt), info = paste("missing column:", col))
  }
})

test_that("herd_level_results contains growth_rate_herd", {
  hrd <- res_demo$herd_level_results
  expect_s3_class(hrd, "data.table")
  expect_true("growth_rate_herd" %in% names(hrd))
})

test_that("cohort_stock_size is positive for all cohorts", {
  expect_true(all(res_demo$cohort_level_results$cohort_stock_size > 0))
})

test_that("preserves all original cohort columns", {
  for (col in names(d_demo$cohort)) {
    expect_true(col %in% names(res_demo$cohort_level_results),
      info = paste("missing original column:", col))
  }
})

test_that("returns 6 cohorts per herd", {
  counts <- res_demo$cohort_level_results[, .N, by = herd_id]
  expect_true(all(counts$N == 6))
})

# ---- Input validation --------------------------------------------------------

test_that("rejects NULL cohort_level_data", {
  expect_error(
    run_demographic_herd_module(
      cohort_level_data = NULL,
      herd_level_data = d_demo$herd,
      show_indicator = FALSE
    )
  )
})

test_that("rejects NULL herd_level_data", {
  expect_error(
    run_demographic_herd_module(
      cohort_level_data = d_demo$cohort,
      herd_level_data = NULL,
      show_indicator = FALSE
    )
  )
})

test_that("rejects cohort data missing required columns", {
  bad <- data.table::copy(d_demo$cohort)
  bad[, death_rate := NULL]
  expect_error(
    run_demographic_herd_module(
      cohort_level_data = bad,
      herd_level_data = d_demo$herd,
      show_indicator = FALSE
    ),
    "death_rate"
  )
})

test_that("rejects herd data missing required columns", {
  bad <- data.table::copy(d_demo$herd)
  bad[, parturition_rate := NULL]
  expect_error(
    run_demographic_herd_module(
      cohort_level_data = d_demo$cohort,
      herd_level_data = bad,
      show_indicator = FALSE
    ),
    "parturition_rate"
  )
})

test_that("rejects non-data.frame cohort_level_data", {
  expect_error(
    run_demographic_herd_module(
      cohort_level_data = "not a data frame",
      herd_level_data = d_demo$herd,
      show_indicator = FALSE
    )
  )
})

test_that("rejects mismatched herd_ids between cohort and herd data", {
  bad_herd <- d_demo$herd[herd_id == 1]
  expect_error(
    run_demographic_herd_module(
      cohort_level_data = d_demo$cohort,
      herd_level_data = bad_herd,
      show_indicator = FALSE
    )
  )
})

# ---- Parameter tests ---------------------------------------------------------

test_that("show_indicator FALSE suppresses output", {
  expect_silent(
    res <- run_demographic_herd_module(
      cohort_level_data = d_demo$cohort,
      herd_level_data = d_demo$herd,
      show_indicator = FALSE
    )
  )
  expect_type(res, "list")
})

test_that("custom simulation_duration works", {
  res <- run_demographic_herd_module(
    cohort_level_data = d_demo$cohort,
    herd_level_data = d_demo$herd,
    simulation_duration = 180,
    show_indicator = FALSE
  )
  expect_type(res, "list")
  expect_true(nrow(res$cohort_level_results) > 0)
})
