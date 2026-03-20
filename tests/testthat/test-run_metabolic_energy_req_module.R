# Tests for run_metabolic_energy_req_module()

# Build inputs once at file scope by running prerequisite modules (weights +
# ration quality). This avoids re-running the pipeline for every test.
inp_energy <- local({
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
  list(cohort = cohort, herd = herd)
})

# Run the module once at file scope so happy-path tests reuse the cached result
# instead of re-running the module per test.
res_energy <- run_metabolic_energy_req_module(
  cohort_level_data = inp_energy$cohort,
  herd_level_data = inp_energy$herd,
  show_indicator = FALSE
)

# ---- Happy path -------------------------------------------------------------

test_that("runs successfully with valid inputs", {
  expect_s3_class(res_energy, "data.table")
  expect_true(nrow(res_energy) > 0)
})

test_that("returns expected energy columns", {
  expected_cols <- c(
    "metabolic_energy_req_maintenance", "metabolic_energy_req_activity",
    "metabolic_energy_req_growth", "metabolic_energy_req_lactation",
    "metabolic_energy_req_work", "metabolic_energy_req_fibre_production",
    "metabolic_energy_req_pregnancy", "metabolic_energy_req_total",
    "ration_intake"
  )
  for (col in expected_cols) {
    expect_true(col %in% names(res_energy), info = paste("missing column:", col))
  }
})

test_that("total energy requirement is positive", {
  expect_true(all(res_energy$metabolic_energy_req_total > 0))
})

test_that("ration_intake (DMI) is positive", {
  expect_true(all(res_energy$ration_intake > 0))
})

test_that("maintenance energy is positive for all cohorts", {
  expect_true(all(res_energy$metabolic_energy_req_maintenance > 0))
})

test_that("energy components are non-negative", {
  components <- c(
    "metabolic_energy_req_activity", "metabolic_energy_req_growth",
    "metabolic_energy_req_lactation", "metabolic_energy_req_work",
    "metabolic_energy_req_fibre_production", "metabolic_energy_req_pregnancy"
  )
  for (col in components) {
    expect_true(all(res_energy[[col]] >= 0), info = paste(col, "has negative values"))
  }
})

test_that("preserves original cohort columns", {
  for (col in names(inp_energy$cohort)) {
    expect_true(col %in% names(res_energy), info = paste("missing column:", col))
  }
})

# ---- Input validation --------------------------------------------------------

test_that("rejects NULL cohort_level_data", {
  expect_error(
    run_metabolic_energy_req_module(
      cohort_level_data = NULL,
      herd_level_data = inp_energy$herd,
      show_indicator = FALSE
    )
  )
})

test_that("rejects NULL herd_level_data", {
  expect_error(
    run_metabolic_energy_req_module(
      cohort_level_data = inp_energy$cohort,
      herd_level_data = NULL,
      show_indicator = FALSE
    )
  )
})

test_that("rejects cohort data missing required columns", {
  bad <- data.table::copy(inp_energy$cohort)
  bad[, ration_digestibility_fraction := NULL]
  expect_error(
    run_metabolic_energy_req_module(
      cohort_level_data = bad,
      herd_level_data = inp_energy$herd,
      show_indicator = FALSE
    ),
    "ration_digestibility_fraction"
  )
})

test_that("rejects herd data missing required columns", {
  bad <- data.table::copy(inp_energy$herd)
  bad[, milk_yield_day := NULL]
  expect_error(
    run_metabolic_energy_req_module(
      cohort_level_data = inp_energy$cohort,
      herd_level_data = bad,
      show_indicator = FALSE
    ),
    "milk_yield_day"
  )
})

test_that("rejects activity fractions summing > 1", {
  bad <- data.table::copy(inp_energy$cohort)
  bad[1, low_activity_fraction := 0.9]
  bad[1, high_activity_fraction := 0.9]
  expect_error(
    run_metabolic_energy_req_module(
      cohort_level_data = bad,
      herd_level_data = inp_energy$herd,
      show_indicator = FALSE
    ),
    "activity_fraction"
  )
})
