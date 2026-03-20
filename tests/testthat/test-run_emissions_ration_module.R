# Tests for run_emissions_ration_module()

# Load example data once at file scope to avoid re-reading CSVs in every test.
d_er <- local({
  path <- system.file("extdata/run_gleam_examples", package = "gleam")
  list(
    feed_rations = data.table::fread(
      file.path(path, "feed_rations_share_chrt.csv")
    ),
    feed_emissions = data.table::fread(
      file.path(path, "feed_emission_factors.csv")
    )
  )
})

# Run the module once at file scope so happy-path tests reuse the cached result
# instead of re-running the module per test.
res_er <- run_emissions_ration_module(
  rations_share = d_er$feed_rations,
  feed_emissions = d_er$feed_emissions,
  show_indicator = FALSE
)

# ---- Happy path -------------------------------------------------------------

test_that("runs successfully with valid inputs", {
  expect_s3_class(res_er, "data.table")
  expect_true(nrow(res_er) > 0)
})

test_that("returns expected emission columns", {
  expected_cols <- c(
    "herd_id", "species_short", "cohort_short",
    "co2_ration_fertilizer", "co2_ration_pesticides",
    "co2_ration_crop_activities", "co2_ration_luc_nopeat",
    "co2_ration_luc_peat", "n2o_ration_fertilizer",
    "n2o_ration_manure_applied", "n2o_ration_crop_residues",
    "ch4_ration_rice"
  )
  for (col in expected_cols) {
    expect_true(col %in% names(res_er), info = paste("missing column:", col))
  }
})

test_that("returns one row per herd x cohort", {
  n_combos <- uniqueN(d_er$feed_rations[, .(herd_id, cohort_short)])
  expect_equal(nrow(res_er), n_combos)
})

test_that("emission values are non-negative", {
  emission_cols <- c(
    "co2_ration_fertilizer", "co2_ration_pesticides",
    "co2_ration_crop_activities", "n2o_ration_fertilizer",
    "n2o_ration_manure_applied", "n2o_ration_crop_residues",
    "ch4_ration_rice"
  )
  for (col in emission_cols) {
    expect_true(all(res_er[[col]] >= 0, na.rm = TRUE),
      info = paste(col, "has negative values"))
  }
})

# ---- Input validation --------------------------------------------------------

test_that("rejects NULL rations_share", {
  expect_error(
    run_emissions_ration_module(
      rations_share = NULL,
      feed_emissions = d_er$feed_emissions,
      show_indicator = FALSE
    )
  )
})

test_that("rejects NULL feed_emissions", {
  expect_error(
    run_emissions_ration_module(
      rations_share = d_er$feed_rations,
      feed_emissions = NULL,
      show_indicator = FALSE
    )
  )
})

test_that("rejects feed_emissions missing required columns", {
  bad <- data.table::copy(d_er$feed_emissions)
  bad[, co2_feed_fertilizer := NULL]
  expect_error(
    run_emissions_ration_module(
      rations_share = d_er$feed_rations,
      feed_emissions = bad,
      show_indicator = FALSE
    ),
    "co2_feed_fertilizer"
  )
})

test_that("rejects rations_share missing feed_id", {
  bad <- data.table::copy(d_er$feed_rations)
  bad[, feed_id := NULL]
  expect_error(
    run_emissions_ration_module(
      rations_share = bad,
      feed_emissions = d_er$feed_emissions,
      show_indicator = FALSE
    ),
    "feed_id"
  )
})
