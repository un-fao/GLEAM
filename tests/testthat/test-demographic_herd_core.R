
cohorts <- c("FB", "FJ", "FS", "FA", "FC", "MB", "MJ", "MS", "MA", "MC")
share_cohorts <- c("FJ", "FS", "FA", "MJ", "MS", "MA")
prop_nondemo_zero <- c(FJ = 0, FS = 0, FA = 0, MJ = 0, MS = 0, MA = 0)

# ---- test calc_fecundity_rates ----
test_that("calc_fecundity_rates returns expected output", {
  res <- calc_fecundity_rates(
    reproductive_rate = 0.8,
    offspring_per_reproductive_event = 2,
    birth_fraction_female = 0.5
  )

  expect_type(res, "list")
  expect_named(res, c("fecundity_female", "fecundity_male"))
  expect_equal(res$fecundity_female, 0.8 * 2 * 0.5 / 365)
  expect_equal(res$fecundity_male, 0.8 * 2 * 0.5 / 365)  # symmetrical case
})

# ---- test calc_transition_probabilities ----
test_that("calc_transition_probabilities returns named list with correct lengths", {
  dur <- setNames(rep(365, 6), share_cohorts)
  off <- setNames(rep(0.1, 6), share_cohorts)
  death <- setNames(rep(0.05, 6), share_cohorts)

  res <- calc_transition_probabilities(
    cohort_duration_days = dur,
    offtake_rate = off,
    death_rate = death
  )

  expect_type(res, "list")
  expect_named(res, c(
    "hazard_death", "hazard_offtake", "probability_death",
    "probability_offtake", "probability_survival", "probability_growth"
  ))
  expect_length(res$hazard_death, 6)
  expect_length(res$probability_death, 10)
})

# ---- test calc_steady_state_structure ----
test_that("calc_steady_state_structure converges and returns valid structure", {
  fec <- calc_fecundity_rates(0.8, 2, 0.5)
  trans <- calc_transition_probabilities(
    cohort_duration_days = setNames(rep(365, 6), share_cohorts),
    offtake_rate = setNames(rep(0.1, 6), share_cohorts),
    death_rate = setNames(rep(0.05, 6), share_cohorts)
  )

  result <- calc_steady_state_structure(
    initial_herd_structure = c(
      FJ = 100, FS = 50, FA = 30,
      MJ = 100, MS = 50, MA = 30
    ),
    max_simulation_years = 5,
    min_lambda_change = 1e-6,
    fecundity_female = fec$fecundity_female,
    fecundity_male = fec$fecundity_male,
    probability_death = setNames(trans$probability_death, cohorts),
    probability_offtake = setNames(trans$probability_offtake, cohorts),
    probability_growth = setNames(trans$probability_growth, cohorts),
    proportion_nondemographic = prop_nondemo_zero
  )

  expect_named(
    result,
    c(
      "days_to_steady_state",
      "herd_structure",
      "cohort_share",
      "growth_rate_herd",
      "size_unscaled"
    )
  )
  expect_true(result$days_to_steady_state <= 5 * 365)
  expect_equal(sum(result$herd_structure), 1, tolerance = 1e-6)
})

# ---- test calc_projected_population_size ----
test_that("calc_projected_population_size runs and returns list with expected elements", {
  fec <- calc_fecundity_rates(
    0.8, 2, 0.5
  )
  trans <- calc_transition_probabilities(
    cohort_duration_days = setNames(rep(365, 6), share_cohorts),
    offtake_rate = setNames(rep(0.1, 6), share_cohorts),
    death_rate = setNames(rep(0.05, 6), share_cohorts)
  )

  cohorts <- c("FB", "FJ", "FS", "FA", "FC", "MB", "MJ", "MS", "MA", "MC")

  steady <- calc_steady_state_structure(
    initial_herd_structure = c(
      FJ = 100, FS = 50, FA = 30,
      MJ = 100, MS = 50, MA = 30
    ),
    max_simulation_years = 5, min_lambda_change = 1e-6,
    fecundity_female = fec$fecundity_female,
    fecundity_male = fec$fecundity_male,
    probability_death = setNames(trans$probability_death, cohorts),
    probability_offtake = setNames(trans$probability_offtake, cohorts),
    probability_growth = setNames(trans$probability_growth, cohorts),
    proportion_nondemographic = prop_nondemo_zero
  )

  res <- calc_projected_population_size(
    herd_size_total = 1000,
    fecundity_female = fec$fecundity_female,
    fecundity_male = fec$fecundity_male,
    probability_death = setNames(trans$probability_death, cohorts),
    probability_offtake = setNames(trans$probability_offtake, cohorts),
    probability_growth = setNames(trans$probability_growth, cohorts),
    growth_rate_herd = steady$growth_rate_herd,
    herd_structure = steady$herd_structure,
    cohort_share = steady$cohort_share,
    proportion_nondemographic = prop_nondemo_zero
  )

  expect_named(
    res,
    c(
      "cohort_stock_start",
      "cohort_stock_end_projected",
      "cohort_stock_end_exact_simulated",
      "cohort_stock_average",
      "cohort_stock_annual_nondemographic",
      "cohort_offtake_heads"
    )
  )
  expect_length(res$cohort_stock_start, 6)
})

# ---- test calc_summary_offtake ----
test_that("calc_summary_offtake returns all expected components", {
  res <- calc_summary_offtake(
    cohort_stock_start = setNames(rep(100, 6), share_cohorts),
    cohort_stock_end_projected = setNames(rep(105, 6), share_cohorts),
    cohort_stock_average = setNames(rep(102, 6), share_cohorts),
    cohort_offtake_heads = setNames(rep(0.01, 10), cohorts),
    simulation_duration = 200
  )

  expect_named(res, c(
    "stock_variation_heads",
    "offtake_heads",
    "offtake_heads_assessment",
    "offtake_rate_to_stock_start",
    "offtake_rate_to_stock_average",
    "offtake_stock_variation_heads",
    "offtake_stock_plus_variation_rate_to_stock_start",
    "offtake_stock_plus_variation_rate_to_stock_average"
  ))
  expect_length(res$offtake_heads, 6)
})

# Herd module and rescaling integration tests

herd_module_test_inputs <- function(herd_ids = 9L) {
  path <- system.file("extdata/run_gleam_examples", package = "gleam")
  read_example <- function(name) {
    data <- data.table::fread(file.path(path, name))
    data <- data[data$herd_id %in% herd_ids]
    data
  }

  list(
    cohort_level_data = read_example("master_chrt_lvl_no_structure_mixed_data.csv"),
    herd_level_data = read_example("master_hrd_lvl_mixed_data.csv")
  )
}

test_that("non-demographic-only long cycles rescale stock and offtake per supplied herd", {
  cohort <- data.table::data.table(
    herd_id = rep(c(1L, 2L), each = 2), cohort_short = "FN",
    nondemo_productive_phase_id = rep(c(1, 2), 2), death_rate = 0
  )
  herd <- data.table::data.table(
    herd_id = c(1L, 2L), herd_size_total = c(100, 50),
    cohort_stock_fem_annual_nondemo = c(100, 200),
    cohort_stock_mal_annual_nondemo = 0, rest_between_nondemo_cycles_duration = 0,
    phase1_nondemo_fem_duration_days = c(400, 365),
    phase2_nondemo_fem_duration_days = 50,
    phase1_nondemo_mal_duration_days = 30, phase2_nondemo_mal_duration_days = 0
  )
  result <- suppressMessages(run_all_herd_module(
    cohort, herd, run_demographic = FALSE, run_nondemographic = TRUE,
    simulation_duration = 182.5
  ))$cohort_level_results
  expect_equal(nrow(result), 4L)
  expect_equal(result[herd_id == 1, cohort_stock_size], 100 * c(400, 50) / 450)
  expect_equal(result[herd_id == 2, cohort_stock_size], 50 * c(365, 50) / 415)
  expect_equal(result[, sum(cohort_stock_size), by = herd_id]$V1, c(100, 50))
  expect_equal(result[herd_id == 1, offtake_heads], c(0, 100 * 365 / 450))
  expect_equal(result[herd_id == 2, offtake_heads], c(0, 50 * 365 / 415))
  expect_equal(result$offtake_heads_assessment, result$offtake_heads / 2)
  expect_true(all(is.finite(result$cohort_stock_size)))

  herd[, herd_size_total := NULL]
  unscaled <- suppressMessages(run_all_herd_module(
    cohort, herd, run_demographic = FALSE, run_nondemographic = TRUE
  ))$cohort_level_results
  expect_equal(unscaled[herd_id == 1, cohort_stock_size], 100 * c(400, 50) / 365)
  expect_equal(unscaled[herd_id == 1, offtake_heads], c(0, 100))
})

test_that("rescale_x_to_y preserves proportions and reaches the target total", {
  result <- rescale_x_to_y(c(20, 30, 50), 100, 250)

  expect_equal(result, c(50, 75, 125))
  expect_equal(sum(result), 250)
})

test_that("rescale_x_to_y keeps zero stocks finite and supports row-specific references", {
  result <- rescale_x_to_y(c(0, 4, 6), c(0, 8, 12), c(100, 80, 240))

  expect_equal(result, c(0, 40, 120))
  expect_true(all(is.finite(result)))
})

test_that("demographic simulation without diversion preserves the herd population", {
  data <- herd_module_test_inputs()
  cohort <- data$cohort_level_data[!cohort_short %in% c("FN", "MN")]
  herd <- data$herd_level_data
  herd[, `:=`(prop_nondemo_fem_juv = 0, prop_nondemo_mal_juv = 0)]

  result <- run_demographic_herd_module(cohort, herd, show_indicator = FALSE)
  output <- result$cohort_level_results

  expect_setequal(output$cohort_short, c("FA", "FJ", "FS", "MA", "MJ", "MS"))
  expect_equal(sum(output$cohort_stock_size_scaled), herd$herd_size_total)
  expect_true(all(is.finite(output$cohort_stock_size_unscaled)))
  expect_true(all(output$cohort_stock_size_unscaled > 0))
  expect_equal(output$cohort_stock_annual_nondemographic, rep(0, 6))
  expect_true(is.finite(result$herd_level_results$growth_rate_herd))
})

test_that("demographic simulation reports juvenile diversion and scales the assessment period", {
  data <- herd_module_test_inputs()
  cohort <- data$cohort_level_data[!cohort_short %in% c("FN", "MN")]

  annual <- run_demographic_herd_module(cohort, data$herd_level_data, show_indicator = FALSE)
  half_year <- run_demographic_herd_module(
    cohort, data$herd_level_data, simulation_duration = 182.5, show_indicator = FALSE
  )
  output <- annual$cohort_level_results

  expect_true(all(output[cohort_short %in% c("FJ", "MJ"), cohort_stock_annual_nondemographic] > 0))
  expect_equal(output[!cohort_short %in% c("FJ", "MJ"), cohort_stock_annual_nondemographic], rep(0, 4))
  expect_equal(half_year$cohort_level_results$cohort_stock_size_scaled, output$cohort_stock_size_scaled)
  expect_equal(half_year$cohort_level_results$offtake_heads_scaled, output$offtake_heads_scaled)
  expect_equal(
    half_year$cohort_level_results$offtake_heads_assessment_scaled,
    output$offtake_heads_assessment_scaled / 2
  )
})

test_that("demographic-only runs warn before excluding non-demographic rows", {
  data <- herd_module_test_inputs()

  expect_warning(
    result <- suppressMessages(run_all_herd_module(
      data$cohort_level_data, data$herd_level_data,
      run_demographic = TRUE, run_nondemographic = FALSE
    )),
    "are ignored because"
  )

  expect_setequal(result$cohort_level_results$cohort_short, c("FA", "FJ", "FS", "MA", "MJ", "MS"))
  expect_equal(sum(result$cohort_level_results$cohort_stock_size), data$herd_level_data$herd_size_total)
})

test_that("non-demographic-only runs use caller inputs rather than inherited workspace data", {
  cohort <- data.table::data.table(
    herd_id = 1L, cohort_short = c("FN", "MN"),
    nondemo_productive_phase_id = 1, death_rate = 0
  )
  herd <- data.table::data.table(
    herd_id = 1L, cohort_stock_fem_annual_nondemo = 100,
    cohort_stock_mal_annual_nondemo = 200, rest_between_nondemo_cycles_duration = 0,
    phase1_nondemo_fem_duration_days = 365, phase2_nondemo_fem_duration_days = 0,
    phase1_nondemo_mal_duration_days = 365, phase2_nondemo_mal_duration_days = 0
  )
  stray <- data.table::copy(herd)
  stray[, `:=`(cohort_stock_fem_annual_nondemo = 1000, cohort_stock_mal_annual_nondemo = 2000)]
  runner <- run_all_herd_module
  environment(runner) <- list2env(
    list(herd_level_data_nondemo = stray), parent = environment(run_all_herd_module)
  )

  expected <- suppressMessages(run_all_herd_module(
    cohort, herd, run_demographic = FALSE, run_nondemographic = TRUE
  ))
  actual <- suppressMessages(runner(
    cohort, herd, run_demographic = FALSE, run_nondemographic = TRUE
  ))

  expect_equal(actual, expected)
  expect_equal(actual$cohort_level_results$cohort_stock_size, c(100, 200))
  expect_equal(actual$cohort_level_results$offtake_heads_assessment, c(100, 200))
})

test_that("mixed herd runs connect juvenile diversion to non-demographic entrants", {
  data <- herd_module_test_inputs()
  demographic <- run_demographic_herd_module(
    data$cohort_level_data[!cohort_short %in% c("FN", "MN")],
    data$herd_level_data, show_indicator = FALSE
  )
  result <- suppressMessages(run_all_herd_module(
    data$cohort_level_data, data$herd_level_data,
    run_demographic = TRUE, run_nondemographic = TRUE
  ))
  output <- result$cohort_level_results

  expect_equal(nrow(output), 10L)
  expect_true(all(output[cohort_short %in% c("FN", "MN"), cohort_stock_size] > 0))
  expect_equal(sum(output$cohort_stock_size), data$herd_level_data$herd_size_total)
  expect_equal(
    result$herd_level_results$cohort_stock_fem_annual_nondemo,
    demographic$cohort_level_results[cohort_short == "FJ", cohort_stock_annual_nondemographic]
  )
  expect_equal(
    result$herd_level_results$cohort_stock_mal_annual_nondemo,
    demographic$cohort_level_results[cohort_short == "MJ", cohort_stock_annual_nondemographic]
  )
})

test_that("the combined herd validator accepts all three supported modes", {
  data <- herd_module_test_inputs()
  cohort <- data$cohort_level_data
  herd <- data$herd_level_data

  expect_no_warning(validate_run_all_herd_module_inputs(
    cohort[!cohort_short %in% c("FN", "MN")], herd, TRUE, FALSE
  ))
  expect_no_warning(validate_run_all_herd_module_inputs(
    cohort[cohort_short %in% c("FN", "MN")], herd, FALSE, TRUE
  ))
  expect_no_warning(validate_run_all_herd_module_inputs(cohort, herd, TRUE, TRUE))
})

test_that("the combined herd validator rejects invalid mode flags and missing demographic rows", {
  data <- herd_module_test_inputs()
  cohort <- data$cohort_level_data
  herd <- data$herd_level_data

  for (flag in list(NA, "TRUE", c(TRUE, FALSE))) {
    expect_error(validate_run_all_herd_module_inputs(cohort, herd, flag, TRUE), "single logical")
    expect_error(validate_run_all_herd_module_inputs(cohort, herd, TRUE, flag), "single logical")
  }
  expect_error(validate_run_all_herd_module_inputs(cohort, herd, FALSE, FALSE), "At least one")
  expect_error(validate_run_all_herd_module_inputs(
    cohort[cohort_short %in% c("FN", "MN")], herd, TRUE, TRUE
  ), "requires demographic rows")
  expect_error(validate_run_all_herd_module_inputs(NULL, herd, TRUE, FALSE), "must be provided")
})

test_that("the combined herd validator warns when selected modes omit or lack non-demographic rows", {
  data <- herd_module_test_inputs()

  expect_warning(validate_run_all_herd_module_inputs(
    data$cohort_level_data, data$herd_level_data, TRUE, FALSE
  ), "are ignored because")
  expect_warning(validate_run_all_herd_module_inputs(
    data$cohort_level_data[!cohort_short %in% c("FN", "MN")], data$herd_level_data, TRUE, TRUE
  ), "no non-demographic rows")
})
