# Tests for run_nitrogen_balance_module()

# Build inputs once at file scope by running prerequisite modules (weights +
# ration quality + energy + enteric). This avoids re-running the pipeline
# for every test.
inp_nitrogen <- local({
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
  cohort <- run_emissions_enteric_module(
    cohort_level_data = cohort,
    show_indicator = FALSE
  )
  list(cohort = cohort, herd = herd)
})

# Run the module once at file scope so happy-path tests reuse the cached result
# instead of re-running the module per test.
res_nitrogen <- run_nitrogen_balance_module(
  cohort_level_data = inp_nitrogen$cohort,
  herd_level_data = inp_nitrogen$herd,
  show_indicator = FALSE
)

# ---- Happy path -------------------------------------------------------------

test_that("runs successfully with valid inputs", {
  expect_s3_class(res_nitrogen, "data.table")
  expect_true(nrow(res_nitrogen) > 0)
})

test_that("returns expected nitrogen columns", {
  expected_cols <- c("nitrogen_intake", "nitrogen_retention", "nitrogen_excretion")
  for (col in expected_cols) {
    expect_true(col %in% names(res_nitrogen), info = paste("missing column:", col))
  }
})

test_that("nitrogen intake is positive", {
  expect_true(all(res_nitrogen$nitrogen_intake > 0))
})

test_that("nitrogen excretion is non-negative", {
  expect_true(all(res_nitrogen$nitrogen_excretion >= 0))
})

test_that("nitrogen balance: intake >= retention", {
  expect_true(all(res_nitrogen$nitrogen_intake >= res_nitrogen$nitrogen_retention - 1e-10))
})

test_that("nitrogen balance: excretion = intake - retention", {
  diff <- abs(res_nitrogen$nitrogen_excretion -
    (res_nitrogen$nitrogen_intake - res_nitrogen$nitrogen_retention))
  expect_true(all(diff < 1e-10))
})

test_that("preserves original cohort columns", {
  for (col in names(inp_nitrogen$cohort)) {
    expect_true(col %in% names(res_nitrogen), info = paste("missing column:", col))
  }
})

# ---- Input validation --------------------------------------------------------

test_that("rejects NULL cohort_level_data", {
  expect_error(
    run_nitrogen_balance_module(
      cohort_level_data = NULL,
      herd_level_data = inp_nitrogen$herd,
      show_indicator = FALSE
    )
  )
})

test_that("rejects NULL herd_level_data", {
  expect_error(
    run_nitrogen_balance_module(
      cohort_level_data = inp_nitrogen$cohort,
      herd_level_data = NULL,
      show_indicator = FALSE
    )
  )
})

test_that("rejects cohort data missing required columns", {
  bad <- data.table::copy(inp_nitrogen$cohort)
  bad[, ration_nitrogen := NULL]
  expect_error(
    run_nitrogen_balance_module(
      cohort_level_data = bad,
      herd_level_data = inp_nitrogen$herd,
      show_indicator = FALSE
    ),
    "ration_nitrogen"
  )
})

test_that("rejects herd data missing required columns", {
  bad <- data.table::copy(inp_nitrogen$herd)
  bad[, milk_protein_fraction := NULL]
  expect_error(
    run_nitrogen_balance_module(
      cohort_level_data = inp_nitrogen$cohort,
      herd_level_data = bad,
      show_indicator = FALSE
    ),
    "milk_protein_fraction"
  )
})
