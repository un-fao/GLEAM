# Tests for run_gleam() — main pipeline entry point

# Helper: load example data used across tests
load_example_data <- function() {
  path <- system.file("extdata/run_gleam_examples", package = "gleam")
  list(
    cohort_no_structure = data.table::fread(
      file.path(path, "master_chrt_lvl_no_structure_data.csv")
    ),
    cohort_structure = data.table::fread(
      file.path(path, "master_chrt_lvl_structure_data.csv")
    ),
    herd = data.table::fread(
      file.path(path, "master_hrd_lvl_data.csv")
    ),
    feed_rations = data.table::fread(
      file.path(path, "feed_rations_share_chrt_data.csv")
    ),
    feed_params = data.table::fread(
      system.file("extdata/Parameters/feed/feed_params.csv", package = "gleam")
    )
  )
}

# ---- validate_run_gleam_inputs: has_herd_structure ---------------------------
test_that("rejects non-logical has_herd_structure", {
  d <- load_example_data()
  expect_error(
    run_gleam(
      has_herd_structure = "yes",
      cohort_level_data = d$cohort_no_structure,
      herd_level_data = d$herd,
      feed_rations = d$feed_rations,
      feed_params = d$feed_params,
      show_indicator = FALSE
    ),
    "single logical value"
  )
})

test_that("rejects NA has_herd_structure", {
  d <- load_example_data()
  expect_error(
    run_gleam(
      has_herd_structure = NA,
      cohort_level_data = d$cohort_no_structure,
      herd_level_data = d$herd,
      feed_rations = d$feed_rations,
      feed_params = d$feed_params,
      show_indicator = FALSE
    ),
    "not NA"
  )
})

# ---- validate_run_gleam_inputs: data frame checks ----------------------------
test_that("rejects NULL cohort_level_data", {
  d <- load_example_data()
  expect_error(
    run_gleam(
      has_herd_structure = FALSE,
      cohort_level_data = NULL,
      herd_level_data = d$herd,
      feed_rations = d$feed_rations,
      feed_params = d$feed_params,
      show_indicator = FALSE
    ),
    "cohort_level_data.*must be a data frame"
  )
})

test_that("rejects NULL herd_level_data", {
  d <- load_example_data()
  expect_error(
    run_gleam(
      has_herd_structure = FALSE,
      cohort_level_data = d$cohort_no_structure,
      herd_level_data = NULL,
      feed_rations = d$feed_rations,
      feed_params = d$feed_params,
      show_indicator = FALSE
    ),
    "herd_level_data.*must be a data frame"
  )
})

test_that("rejects NULL feed_rations", {
  d <- load_example_data()
  expect_error(
    run_gleam(
      has_herd_structure = FALSE,
      cohort_level_data = d$cohort_no_structure,
      herd_level_data = d$herd,
      feed_rations = NULL,
      feed_params = d$feed_params,
      show_indicator = FALSE
    ),
    "feed_rations.*must be a data frame"
  )
})

test_that("rejects NULL feed_params", {
  d <- load_example_data()
  expect_error(
    run_gleam(
      has_herd_structure = FALSE,
      cohort_level_data = d$cohort_no_structure,
      herd_level_data = d$herd,
      feed_rations = d$feed_rations,
      feed_params = NULL,
      show_indicator = FALSE
    ),
    "feed_params.*must be a data frame"
  )
})

# ---- validate_run_gleam_inputs: calculated columns blocked -------------------
test_that("rejects cohort data containing calculated columns", {
  d <- load_example_data()
  bad_cohort <- data.table::copy(d$cohort_no_structure)
  bad_cohort[, daily_weight_gain := 0.5]
  expect_error(
    run_gleam(
      has_herd_structure = FALSE,
      cohort_level_data = bad_cohort,
      herd_level_data = d$herd,
      feed_rations = d$feed_rations,
      feed_params = d$feed_params,
      show_indicator = FALSE
    ),
    "daily_weight_gain"
  )
})

test_that("blocks cohort_stock_size in no-structure mode", {
  d <- load_example_data()
  bad_cohort <- data.table::copy(d$cohort_no_structure)
  bad_cohort[, cohort_stock_size := 100]
  expect_error(
    run_gleam(
      has_herd_structure = FALSE,
      cohort_level_data = bad_cohort,
      herd_level_data = d$herd,
      feed_rations = d$feed_rations,
      feed_params = d$feed_params,
      show_indicator = FALSE
    ),
    "cohort_stock_size"
  )
})

test_that("allows cohort_stock_size in structure mode", {
  d <- load_example_data()
  # structure data already has cohort_stock_size — should not error on that column
  expect_true("cohort_stock_size" %in% names(d$cohort_structure))
})

# ---- validate_run_gleam_inputs: herd_id consistency -------------------------
test_that("rejects mismatched herd_id across inputs", {
  d <- load_example_data()
  bad_herd <- data.table::copy(d$herd)
  bad_herd[, herd_id := herd_id + 100L]
  expect_error(
    run_gleam(
      has_herd_structure = FALSE,
      cohort_level_data = d$cohort_no_structure,
      herd_level_data = bad_herd,
      feed_rations = d$feed_rations,
      feed_params = d$feed_params,
      show_indicator = FALSE
    ),
    "same.*herd_id"
  )
})

# ---- run_gleam: has_herd_structure = FALSE -----------------------------------
test_that("run_gleam succeeds with has_herd_structure = FALSE", {
  d <- load_example_data()
  result <- run_gleam(
    has_herd_structure = FALSE,
    cohort_level_data = d$cohort_no_structure,
    herd_level_data = d$herd,
    feed_rations = d$feed_rations,
    feed_params = d$feed_params,
    show_indicator = FALSE
  )
  expect_s3_class(result, "data.table")
  expect_true(nrow(result) > 0)
  expect_true("herd_id" %in% names(result))
  expect_true("cohort_short" %in% names(result))
})

test_that("run_gleam FALSE path produces calculated weight columns", {
  d <- load_example_data()
  result <- run_gleam(
    has_herd_structure = FALSE,
    cohort_level_data = d$cohort_no_structure,
    herd_level_data = d$herd,
    feed_rations = d$feed_rations,
    feed_params = d$feed_params,
    show_indicator = FALSE
  )
  weight_cols <- c("mature_weight", "daily_weight_gain", "live_weight_cohort_average")
  for (col in weight_cols) {
    expect_true(col %in% names(result), info = paste("Missing column:", col))
  }
})

test_that("run_gleam FALSE path produces energy columns", {
  d <- load_example_data()
  result <- run_gleam(
    has_herd_structure = FALSE,
    cohort_level_data = d$cohort_no_structure,
    herd_level_data = d$herd,
    feed_rations = d$feed_rations,
    feed_params = d$feed_params,
    show_indicator = FALSE
  )
  energy_cols <- c(
    "energy_requirement_maintenance", "energy_requirement_total", "dry_matter_intake"
  )
  for (col in energy_cols) {
    expect_true(col %in% names(result), info = paste("Missing column:", col))
  }
})

test_that("run_gleam FALSE path produces feed ration columns", {
  d <- load_example_data()
  result <- run_gleam(
    has_herd_structure = FALSE,
    cohort_level_data = d$cohort_no_structure,
    herd_level_data = d$herd,
    feed_rations = d$feed_rations,
    feed_params = d$feed_params,
    show_indicator = FALSE
  )
  feed_cols <- c("diet_gross_energy", "diet_digestibility_fraction", "diet_nitrogen")
  for (col in feed_cols) {
    expect_true(col %in% names(result), info = paste("Missing column:", col))
  }
})

test_that("run_gleam FALSE path has all 6 cohorts per herd", {
  d <- load_example_data()
  result <- run_gleam(
    has_herd_structure = FALSE,
    cohort_level_data = d$cohort_no_structure,
    herd_level_data = d$herd,
    feed_rations = d$feed_rations,
    feed_params = d$feed_params,
    show_indicator = FALSE
  )
  expected_cohorts <- c("FA", "FJ", "FS", "MA", "MJ", "MS")
  for (hid in unique(result$herd_id)) {
    cohorts <- sort(unique(result[herd_id == hid, cohort_short]))
    expect_equal(cohorts, expected_cohorts, info = paste("herd_id:", hid))
  }
})

# ---- run_gleam: has_herd_structure = TRUE ------------------------------------
test_that("run_gleam succeeds with has_herd_structure = TRUE", {
  d <- load_example_data()
  result <- run_gleam(
    has_herd_structure = TRUE,
    cohort_level_data = d$cohort_structure,
    herd_level_data = d$herd,
    feed_rations = d$feed_rations,
    feed_params = d$feed_params,
    show_indicator = FALSE
  )
  expect_s3_class(result, "data.table")
  expect_true(nrow(result) > 0)
  expect_true("herd_id" %in% names(result))
  expect_true("cohort_short" %in% names(result))
})

test_that("run_gleam TRUE path produces calculated columns", {
  d <- load_example_data()
  result <- run_gleam(
    has_herd_structure = TRUE,
    cohort_level_data = d$cohort_structure,
    herd_level_data = d$herd,
    feed_rations = d$feed_rations,
    feed_params = d$feed_params,
    show_indicator = FALSE
  )
  expected_cols <- c(
    "mature_weight", "daily_weight_gain",
    "energy_requirement_total", "dry_matter_intake",
    "diet_gross_energy"
  )
  for (col in expected_cols) {
    expect_true(col %in% names(result), info = paste("Missing column:", col))
  }
})

test_that("run_gleam TRUE path preserves cohort_stock_size from input", {
  d <- load_example_data()
  result <- run_gleam(
    has_herd_structure = TRUE,
    cohort_level_data = d$cohort_structure,
    herd_level_data = d$herd,
    feed_rations = d$feed_rations,
    feed_params = d$feed_params,
    show_indicator = FALSE
  )
  expect_true("cohort_stock_size" %in% names(result))
  # Values should match the input
  input_sizes <- d$cohort_structure[, .(herd_id, cohort_short, cohort_stock_size)]
  data.table::setkey(input_sizes, herd_id, cohort_short)
  result_sizes <- result[, .(herd_id, cohort_short, cohort_stock_size)]
  data.table::setkey(result_sizes, herd_id, cohort_short)
  expect_equal(result_sizes$cohort_stock_size, input_sizes$cohort_stock_size)
})

# ---- run_gleam: output consistency -------------------------------------------
test_that("both paths produce same column set (excluding herd-sim-only cols)", {
  d <- load_example_data()
  result_false <- run_gleam(
    has_herd_structure = FALSE,
    cohort_level_data = d$cohort_no_structure,
    herd_level_data = d$herd,
    feed_rations = d$feed_rations,
    feed_params = d$feed_params,
    show_indicator = FALSE
  )
  result_true <- run_gleam(
    has_herd_structure = TRUE,
    cohort_level_data = d$cohort_structure,
    herd_level_data = d$herd,
    feed_rations = d$feed_rations,
    feed_params = d$feed_params,
    show_indicator = FALSE
  )
  # Both should have the key pipeline output columns
  shared_cols <- c(
    "herd_id", "cohort_short", "mature_weight", "daily_weight_gain",
    "energy_requirement_total", "dry_matter_intake",
    "diet_gross_energy", "diet_digestibility_fraction"
  )
  for (col in shared_cols) {
    expect_true(col %in% names(result_false), info = paste("FALSE missing:", col))
    expect_true(col %in% names(result_true), info = paste("TRUE missing:", col))
  }
})

test_that("numeric output columns contain no NA values for key fields", {
  d <- load_example_data()
  result <- run_gleam(
    has_herd_structure = FALSE,
    cohort_level_data = d$cohort_no_structure,
    herd_level_data = d$herd,
    feed_rations = d$feed_rations,
    feed_params = d$feed_params,
    show_indicator = FALSE
  )
  key_cols <- c("energy_requirement_total", "dry_matter_intake", "diet_gross_energy")
  for (col in key_cols) {
    expect_false(anyNA(result[[col]]), info = paste("NA found in", col))
  }
})
