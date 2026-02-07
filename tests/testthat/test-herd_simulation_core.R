
cohorts <- c("FB", "FJ", "FS", "FA", "FC", "MB", "MJ", "MS", "MA", "MC")
share_cohorts <- c("FJ", "FS", "FA", "MJ", "MS", "MA")

# ---- test compute_fecundity_rates ----
test_that("compute_fecundity_rates returns expected output", {
  res <- compute_fecundity_rates(
    parturition_rate = 0.8,
    litter_size = 2,
    birth_fraction_female = 0.5
  )

  expect_type(res, "list")
  expect_named(res, c("fecundity_female", "fecundity_male"))
  expect_equal(res$fecundity_female, 0.8 * 2 * 0.5 / 365)
  expect_equal(res$fecundity_male, 0.8 * 2 * 0.5 / 365)  # symmetrical case
})

# ---- test compute_transition_probabilities ----
test_that("compute_transition_probabilities returns named list with correct lengths", {
  dur <- setNames(rep(365, 6), share_cohorts)
  off <- setNames(rep(0.1, 6), share_cohorts)
  death <- setNames(rep(0.05, 6), share_cohorts)

  res <- compute_transition_probabilities(
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

# ---- test simulate_steady_state_structure ----
test_that("simulate_steady_state_structure converges and returns valid structure", {
  fec <- compute_fecundity_rates(0.8, 2, 0.5)
  trans <- compute_transition_probabilities(
    cohort_duration_days = setNames(rep(365, 6), share_cohorts),
    offtake_rate = setNames(rep(0.1, 6), share_cohorts),
    death_rate = setNames(rep(0.05, 6), share_cohorts)
  )

  result <- simulate_steady_state_structure(
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
    probability_growth = setNames(trans$probability_growth, cohorts)
  )

  expect_named(result, c("days_to_steady_state", "herd_structure", "cohort_share", "growth_rate_herd"))
  expect_true(result$days_to_steady_state <= 5 * 365)
  expect_equal(sum(result$herd_structure), 1, tolerance = 1e-6)
})

# ---- test project_population_size ----
test_that("project_population_size runs and returns list with expected elements", {
  fec <- compute_fecundity_rates(
    0.8, 2, 0.5
  )
  trans <- compute_transition_probabilities(
    cohort_duration_days = setNames(rep(365, 6), share_cohorts),
    offtake_rate = setNames(rep(0.1, 6), share_cohorts),
    death_rate = setNames(rep(0.05, 6), share_cohorts)
  )

  cohorts <- c("FB", "FJ", "FS", "FA", "FC", "MB", "MJ", "MS", "MA", "MC")

  steady <- simulate_steady_state_structure(
    initial_herd_structure = c(
      FJ = 100, FS = 50, FA = 30,
      MJ = 100, MS = 50, MA = 30
    ),
    max_simulation_years = 5, min_lambda_change = 1e-6,
    fecundity_female = fec$fecundity_female,
    fecundity_male = fec$fecundity_male,
    probability_death = setNames(trans$probability_death, cohorts),
    probability_offtake = setNames(trans$probability_offtake, cohorts),
    probability_growth = setNames(trans$probability_growth, cohorts)
  )

  res <- project_population_size(
    herd_size_total = 1000,
    fecundity_female = fec$fecundity_female,
    fecundity_male = fec$fecundity_male,
    probability_death = setNames(trans$probability_death, cohorts),
    probability_offtake = setNames(trans$probability_offtake, cohorts),
    probability_growth = setNames(trans$probability_growth, cohorts),
    growth_rate_herd = steady$growth_rate_herd,
    herd_structure = steady$herd_structure,
    cohort_share = steady$cohort_share
  )

  expect_named(
    res,
    c(
      "cohort_stock_start",
      "cohort_stock_end_projected",
      "cohort_stock_end_exact_simulated",
      "cohort_stock_average",
      "cohort_offtake_heads"
    )
  )
  expect_length(res$cohort_stock_start, 6)
})

# ---- test summarise_offtake ----
test_that("summarise_offtake returns all expected components", {
  res <- summarise_offtake(
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
