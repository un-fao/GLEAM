# Tests for run_production_module()

# Build inputs once at file scope by running the weights module (production
# needs cohort_stock_size, offtake_heads_assessment,
# live_weight_cohort_at_slaughter). This avoids re-running the pipeline
# for every test.
inp_prod <- local({
  path <- system.file("extdata/run_gleam_examples", package = "gleam")
  cohort_structure <- data.table::fread(
    file.path(path, "master_chrt_lvl_structure_data.csv")
  )
  herd <- data.table::fread(file.path(path, "master_hrd_lvl_data.csv"))

  wt <- run_weights_module(
    cohort_level_data = cohort_structure,
    herd_level_data = herd,
    show_indicator = FALSE
  )
  list(cohort = wt$cohort_level_results, herd = herd)
})

# Run the module once at file scope so happy-path tests reuse the cached result
# instead of re-running the module per test.
res_prod <- run_production_module(
  cohort_level_data = inp_prod$cohort,
  herd_level_data = inp_prod$herd,
  show_indicator = FALSE
)

# ---- Happy path -------------------------------------------------------------

test_that("runs successfully with valid inputs", {
  expect_s3_class(res_prod, "data.table")
  expect_true(nrow(res_prod) > 0)
})

test_that("returns expected production columns", {
  expected_cols <- c(
    "milk_production_mass_cohort", "milk_production_protein_cohort",
    "milk_production_fpcm_cohort", "fibre_production_cohort",
    "meat_production_live_weight_cohort", "meat_production_carcass_weight_cohort",
    "meat_production_bone_free_meat_cohort", "meat_production_protein_cohort"
  )
  for (col in expected_cols) {
    expect_true(col %in% names(res_prod), info = paste("missing column:", col))
  }
})

test_that("production values are non-negative", {
  prod_cols <- c(
    "milk_production_mass_cohort", "milk_production_fpcm_cohort",
    "fibre_production_cohort", "meat_production_live_weight_cohort",
    "meat_production_carcass_weight_cohort"
  )
  for (col in prod_cols) {
    expect_true(all(res_prod[[col]] >= 0), info = paste(col, "has negative values"))
  }
})

test_that("carcass weight <= live weight for meat", {
  expect_true(all(
    res_prod$meat_production_carcass_weight_cohort <=
      res_prod$meat_production_live_weight_cohort + 1e-6
  ))
})

test_that("bone_free_meat <= carcass weight", {
  expect_true(all(
    res_prod$meat_production_bone_free_meat_cohort <=
      res_prod$meat_production_carcass_weight_cohort + 1e-6
  ))
})

test_that("custom simulation_duration works", {
  res_365 <- res_prod
  res_180 <- run_production_module(
    cohort_level_data = inp_prod$cohort,
    herd_level_data = inp_prod$herd,
    simulation_duration = 180,
    show_indicator = FALSE
  )
  expect_true(all(
    res_180$milk_production_mass_cohort <= res_365$milk_production_mass_cohort + 1e-6
  ))
})

test_that("preserves original cohort columns", {
  for (col in names(inp_prod$cohort)) {
    expect_true(col %in% names(res_prod), info = paste("missing column:", col))
  }
})

# ---- Input validation --------------------------------------------------------

test_that("rejects NULL cohort_level_data", {
  expect_error(
    run_production_module(
      cohort_level_data = NULL,
      herd_level_data = inp_prod$herd,
      show_indicator = FALSE
    )
  )
})

test_that("rejects NULL herd_level_data", {
  expect_error(
    run_production_module(
      cohort_level_data = inp_prod$cohort,
      herd_level_data = NULL,
      show_indicator = FALSE
    )
  )
})

test_that("rejects cohort data missing required columns", {
  bad <- data.table::copy(inp_prod$cohort)
  bad[, cohort_stock_size := NULL]
  expect_error(
    run_production_module(
      cohort_level_data = bad,
      herd_level_data = inp_prod$herd,
      show_indicator = FALSE
    ),
    "cohort_stock_size"
  )
})

test_that("rejects herd data missing required columns", {
  bad <- data.table::copy(inp_prod$herd)
  bad[, milk_yield_day := NULL]
  expect_error(
    run_production_module(
      cohort_level_data = inp_prod$cohort,
      herd_level_data = bad,
      show_indicator = FALSE
    ),
    "milk_yield_day"
  )
})

test_that("rejects negative simulation_duration", {
  expect_error(
    run_production_module(
      cohort_level_data = inp_prod$cohort,
      herd_level_data = inp_prod$herd,
      simulation_duration = -1,
      show_indicator = FALSE
    )
  )
})
