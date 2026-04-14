test_that("validate_run_nondemographic_herd_module_inputs accepts valid example data", {
  cohort_level_data <- data.table::data.table(
    herd_id = c(1L, 1L, 1L, 1L),
    cohort_short = c("FN", "FN", "MN", "MN"),
    nondemo_productive_phase_id = c(1, 2, 1, 2),
    cohort_duration_days = c(30, 50, 30, 50),
    death_rate = c(0.1, 0.1, 0.1, 0.1)
  )

  herd_level_data <- data.table::data.table(
    herd_id = 1L,
    cohort_stock_fem_annual_nondemo = 100,
    cohort_stock_mal_annual_nondemo = 120,
    rest_between_nondemo_cycles_duration = 20
  )

  expect_no_error(
    validate_run_nondemographic_herd_module_inputs(
      cohort_level_data,
      herd_level_data
    )
  )
})

test_that("validate_run_nondemographic_herd_module_inputs accepts herd-level phase durations", {
  cohort_level_data <- data.table::data.table(
    herd_id = c(1L, 1L, 1L, 1L),
    cohort_short = c("FN", "FN", "MN", "MN"),
    nondemo_productive_phase_id = c(1, 2, 1, 2),
    death_rate = c(0.1, 0.1, 0.1, 0.1)
  )

  herd_level_data <- data.table::data.table(
    herd_id = 1L,
    cohort_stock_fem_annual_nondemo = 100,
    cohort_stock_mal_annual_nondemo = 120,
    rest_between_nondemo_cycles_duration = 20,
    phase1_nondemo_fem_duration_days = 30,
    phase2_nondemo_fem_duration_days = 50,
    phase1_nondemo_mal_duration_days = 30,
    phase2_nondemo_mal_duration_days = 50
  )

  expect_no_error(
    validate_run_nondemographic_herd_module_inputs(
      cohort_level_data,
      herd_level_data
    )
  )
})

test_that("validate_run_nondemographic_herd_module_inputs rejects invalid non-demo cohorts", {
  cohort_level_data <- data.table::data.table(
    herd_id = 1L,
    cohort_short = "FA",
    nondemo_productive_phase_id = 1,
    cohort_duration_days = 30,
    death_rate = 0.1
  )

  herd_level_data <- data.table::data.table(
    herd_id = 1L,
    cohort_stock_fem_annual_nondemo = 100,
    cohort_stock_mal_annual_nondemo = 120,
    rest_between_nondemo_cycles_duration = 20
  )

  expect_error(
    validate_run_nondemographic_herd_module_inputs(
      cohort_level_data,
      herd_level_data
    ),
    "cohort_short"
  )
})

test_that("validate_run_nondemographic_herd_module_inputs rejects missing phase 1", {
  cohort_level_data <- data.table::data.table(
    herd_id = c(1L, 1L),
    cohort_short = c("FN", "MN"),
    nondemo_productive_phase_id = c(2, 1),
    cohort_duration_days = c(50, 30),
    death_rate = c(0.1, 0.1)
  )

  herd_level_data <- data.table::data.table(
    herd_id = 1L,
    cohort_stock_fem_annual_nondemo = 100,
    cohort_stock_mal_annual_nondemo = 120,
    rest_between_nondemo_cycles_duration = 20
  )

  expect_error(
    validate_run_nondemographic_herd_module_inputs(
      cohort_level_data,
      herd_level_data
    ),
    "phase 1 row"
  )
})

test_that("calc_nondemo_cycle_geometry returns expected cycle structure", {
  res <- calc_nondemo_cycle_geometry(
    phase1_nondemo_duration = 30,
    phase2_nondemo_duration = 50,
    rest_between_nondemo_cycles_duration = 20
  )

  expect_equal(res$cycle_length, 100)
  expect_equal(res$number_full_nondemo_cycles, 3)
  expect_equal(res$partial_phase1_nondemo_duration, 30)
  expect_equal(res$partial_phase2_nondemo_duration, 35)
  expect_equal(res$total_nondemo_cycle_starts_to_distribute, 4)
})

test_that("calc_nondemo_start_sizes returns expected entrants per cycle", {
  res <- calc_nondemo_start_sizes(
    cohort_stock_nondemo_annual_entrants = 120,
    total_nondemo_cycle_starts_to_distribute = 4
  )

  expect_type(res, "list")
  expect_equal(res$cohort_stock_nondemo_start_cycle, 30)
})

test_that("calc_nondemo_offtake_total_horizon follows assessment-year cycle starts", {
  res <- calc_nondemo_offtake_total_horizon(
    cohort_stock_nondemo_end_phase1 = 90,
    cohort_stock_nondemo_end_phase2 = 80,
    cohort_stock_nondemo_annual_entrants = 120,
    cohort_stock_nondemo_start_cycle = 30,
    number_full_nondemo_cycles = 3,
    partial_phase1_nondemo_duration = 30,
    partial_phase2_nondemo_duration = 50,
    phase1_nondemo_duration = 30,
    phase2_nondemo_duration = 50,
    simulation_duration = 365
  )

  expect_equal(res$offtake_heads_nondemo_phase1, 0)
  expect_equal(res$offtake_heads_nondemo_phase2, 120 * (80 / 30))
  expect_equal(res$offtake_heads_assessment_nondemo_phase2, 120 * (80 / 30))
})

test_that("calc_nondemo_offtake_total_horizon keeps annual offtake when cycle exceeds 365 days", {
  res <- calc_nondemo_offtake_total_horizon(
    cohort_stock_nondemo_end_phase1 = 90,
    cohort_stock_nondemo_end_phase2 = 75,
    cohort_stock_nondemo_annual_entrants = 120,
    cohort_stock_nondemo_start_cycle = 120,
    number_full_nondemo_cycles = 0,
    partial_phase1_nondemo_duration = 200,
    partial_phase2_nondemo_duration = 0,
    phase1_nondemo_duration = 200,
    phase2_nondemo_duration = 150,
    simulation_duration = 365
  )

  expect_equal(res$offtake_heads_nondemo_phase1, 0)
  expect_equal(res$offtake_heads_nondemo_phase2, 75)
  expect_equal(res$offtake_heads_assessment_nondemo_phase2, 75)
})

test_that("calc_nondemo_phase returns zero stock for zero-duration phases", {
  res <- calc_nondemo_phase(
    cohort_stock_nondemo_start_by_phase = 25,
    productive_phase_nondemo_duration = 0,
    death_rate_nondemo_phase = 0,
    max_simulation_days_nondemo_phase = 0
  )

  expect_equal(res$time_simulated_nondemographic, 0)
  expect_equal(res$cohort_stock_nondemo$start, 0)
  expect_equal(res$cohort_stock_nondemo$end, 0)
})

test_that("run_nondemographic_herd_module returns expected output columns", {
  cohort_level_data <- data.table::data.table(
    herd_id = c(1L, 1L, 1L, 1L),
    cohort_short = c("FN", "FN", "MN", "MN"),
    nondemo_productive_phase_id = c(1, 2, 1, 2),
    cohort_duration_days = c(30, 50, 30, 50),
    death_rate = c(0.1, 0.1, 0.1, 0.1)
  )

  herd_level_data <- data.table::data.table(
    herd_id = 1L,
    cohort_stock_fem_annual_nondemo = 100,
    cohort_stock_mal_annual_nondemo = 120,
    rest_between_nondemo_cycles_duration = 20
  )

  res <- run_nondemographic_herd_module(
    cohort_level_data = cohort_level_data,
    herd_level_data = herd_level_data,
    simulation_duration = 365
  )

  expect_type(res, "list")
  expect_named(res, c("cohort_level_results", "herd_level_results"))
  expect_s3_class(res$cohort_level_results, "data.table")
  expect_s3_class(res$herd_level_results, "data.table")
  expect_equal(nrow(res$cohort_level_results), 4)
  expect_true("cohort_stock_size_unscaled" %in% names(res$cohort_level_results))
  expect_true("partial_nondemo_phase_duration" %in% names(res$cohort_level_results))
  expect_true("offtake_heads" %in% names(res$cohort_level_results))
  expect_true("offtake_heads_assessment" %in% names(res$cohort_level_results))
  expect_true("offtake_rate" %in% names(res$cohort_level_results))
  expect_true(all(res$cohort_level_results$offtake_rate == 1))
  expect_true("total_nondemo_fem_duration_days" %in% names(res$herd_level_results))
  expect_true("total_nondemo_mal_duration_days" %in% names(res$herd_level_results))
  expect_equal(res$herd_level_results$total_nondemo_fem_duration_days, 80)
  expect_equal(res$herd_level_results$total_nondemo_mal_duration_days, 80)
})

test_that("run_nondemographic_herd_module assigns cohort durations from herd-level inputs", {
  cohort_level_data <- data.table::data.table(
    herd_id = c(1L, 1L, 1L, 1L),
    cohort_short = c("FN", "FN", "MN", "MN"),
    nondemo_productive_phase_id = c(1, 2, 1, 2),
    death_rate = c(0.1, 0.1, 0.1, 0.1)
  )

  herd_level_data <- data.table::data.table(
    herd_id = 1L,
    cohort_stock_fem_annual_nondemo = 100,
    cohort_stock_mal_annual_nondemo = 120,
    rest_between_nondemo_cycles_duration = 20,
    phase1_nondemo_fem_duration_days = 30,
    phase2_nondemo_fem_duration_days = 50,
    phase1_nondemo_mal_duration_days = 30,
    phase2_nondemo_mal_duration_days = 50
  )

  res <- run_nondemographic_herd_module(
    cohort_level_data = cohort_level_data,
    herd_level_data = herd_level_data,
    simulation_duration = 365
  )

  expect_equal(
    res$cohort_level_results[cohort_short == "FN" & nondemo_productive_phase_id == 1, cohort_duration_days],
    30
  )
  expect_equal(
    res$cohort_level_results[cohort_short == "FN" & nondemo_productive_phase_id == 2, cohort_duration_days],
    50
  )
  expect_equal(
    res$cohort_level_results[cohort_short == "MN" & nondemo_productive_phase_id == 1, cohort_duration_days],
    30
  )
  expect_equal(
    res$cohort_level_results[cohort_short == "MN" & nondemo_productive_phase_id == 2, cohort_duration_days],
    50
  )
  expect_equal(res$herd_level_results$total_nondemo_fem_duration_days, 80)
  expect_equal(res$herd_level_results$total_nondemo_mal_duration_days, 80)
})

test_that("run_nondemographic_herd_module works without cohort_duration_days column", {
  cohort_level_data <- data.table::data.table(
    herd_id = c(1L, 1L, 1L, 1L),
    cohort_short = c("FN", "FN", "MN", "MN"),
    nondemo_productive_phase_id = c(1, 2, 1, 2),
    death_rate = c(0.1, 0.1, 0.1, 0.1)
  )

  herd_level_data <- data.table::data.table(
    herd_id = 1L,
    cohort_stock_fem_annual_nondemo = 100,
    cohort_stock_mal_annual_nondemo = 120,
    rest_between_nondemo_cycles_duration = 20,
    phase1_nondemo_fem_duration_days = 30,
    phase2_nondemo_fem_duration_days = 50,
    phase1_nondemo_mal_duration_days = 30,
    phase2_nondemo_mal_duration_days = 50
  )

  res <- run_nondemographic_herd_module(
    cohort_level_data = cohort_level_data,
    herd_level_data = herd_level_data,
    simulation_duration = 365
  )

  expect_false("cohort_duration_days" %in% names(cohort_level_data))
  expect_equal(
    res$cohort_level_results[, cohort_duration_days],
    c(30, 50, 30, 50)
  )
})

test_that("run_nondemographic_herd_module drops zero-stock non-demo rows", {
  cohort_level_data <- data.table::data.table(
    herd_id = c(1L, 1L),
    cohort_short = c("FN", "MN"),
    nondemo_productive_phase_id = c(1, 1),
    death_rate = c(0.1, 0.1)
  )

  herd_level_data <- data.table::data.table(
    herd_id = 1L,
    cohort_stock_fem_annual_nondemo = 0,
    cohort_stock_mal_annual_nondemo = 100,
    rest_between_nondemo_cycles_duration = 20,
    phase1_nondemo_fem_duration_days = 20,
    phase2_nondemo_fem_duration_days = 0,
    phase1_nondemo_mal_duration_days = 20,
    phase2_nondemo_mal_duration_days = 0
  )

  res <- run_nondemographic_herd_module(
    cohort_level_data = cohort_level_data,
    herd_level_data = herd_level_data,
    simulation_duration = 365
  )

  expect_false(any(
    res$cohort_level_results$cohort_short == "FN"
  ))
  expect_true(any(
    res$cohort_level_results$cohort_short == "MN"
  ))
  expect_true(all(res$cohort_level_results$cohort_stock_size_unscaled > 0))
})
