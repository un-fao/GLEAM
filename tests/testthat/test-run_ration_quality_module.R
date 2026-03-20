# Tests for run_ration_quality_module()

# Load example data once at file scope to avoid re-reading CSVs in every test.
d_rq <- local({
  path <- system.file("extdata/run_gleam_examples", package = "gleam")
  list(
    feed_rations = data.table::fread(
      file.path(path, "feed_rations_share_chrt.csv")
    ),
    feed_params = data.table::fread(file.path(path, "feed_quality.csv"))
  )
})

# Run the module once at file scope so happy-path tests reuse the cached result
# instead of re-running the module per test.
res_rq <- run_ration_quality_module(
  rations_share = d_rq$feed_rations,
  feed_params = d_rq$feed_params,
  show_indicator = FALSE
)

# ---- Happy path -------------------------------------------------------------

test_that("runs successfully with valid inputs", {
  expect_s3_class(res_rq, "data.table")
  expect_true(nrow(res_rq) > 0)
})

test_that("returns expected nutritional columns", {
  expected_cols <- c(
    "herd_id", "species_short", "cohort_short",
    "ration_gross_energy", "ration_metabolizable_energy",
    "ration_nitrogen", "ration_digestibility_fraction",
    "ration_urinary_energy_fraction", "ration_ash"
  )
  for (col in expected_cols) {
    expect_true(col %in% names(res_rq), info = paste("missing column:", col))
  }
})

test_that("returns one row per herd x cohort", {
  n_combos <- uniqueN(d_rq$feed_rations[, .(herd_id, cohort_short)])
  expect_equal(nrow(res_rq), n_combos)
})

test_that("ration_digestibility_fraction is between 0 and 1", {
  expect_true(all(res_rq$ration_digestibility_fraction > 0))
  expect_true(all(res_rq$ration_digestibility_fraction <= 1))
})

test_that("ration_gross_energy is positive", {
  expect_true(all(res_rq$ration_gross_energy > 0))
})

test_that("ration_nitrogen is positive", {
  expect_true(all(res_rq$ration_nitrogen > 0))
})

# ---- Input validation --------------------------------------------------------

test_that("rejects NULL rations_share", {
  expect_error(
    run_ration_quality_module(
      rations_share = NULL,
      feed_params = d_rq$feed_params,
      show_indicator = FALSE
    )
  )
})

test_that("rejects NULL feed_params", {
  expect_error(
    run_ration_quality_module(
      rations_share = d_rq$feed_rations,
      feed_params = NULL,
      show_indicator = FALSE
    )
  )
})

test_that("rejects rations_share missing required columns", {
  bad <- data.table::copy(d_rq$feed_rations)
  bad[, feed_ration_fraction := NULL]
  expect_error(
    run_ration_quality_module(
      rations_share = bad,
      feed_params = d_rq$feed_params,
      show_indicator = FALSE
    ),
    "feed_ration_fraction"
  )
})

test_that("rejects feed_params missing required columns", {
  bad <- data.table::copy(d_rq$feed_params)
  bad[, feed_gross_energy := NULL]
  expect_error(
    run_ration_quality_module(
      rations_share = d_rq$feed_rations,
      feed_params = bad,
      show_indicator = FALSE
    ),
    "feed_gross_energy"
  )
})

test_that("rejects rations that don't sum to 1", {
  bad <- data.table::copy(d_rq$feed_rations)
  bad[, feed_ration_fraction := feed_ration_fraction * 0.5]
  expect_error(
    run_ration_quality_module(
      rations_share = bad,
      feed_params = d_rq$feed_params,
      show_indicator = FALSE
    ),
    "sum"
  )
})

test_that("rejects non-data.frame rations_share", {
  expect_error(
    run_ration_quality_module(
      rations_share = "not a data frame",
      feed_params = d_rq$feed_params,
      show_indicator = FALSE
    )
  )
})
