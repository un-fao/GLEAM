
cohorts <- c("FB", "FJ", "FS", "FA", "FC", "MB", "MJ", "MS", "MA", "MC")
share_cohorts <- c("FJ", "FS", "FA", "MJ", "MS", "MA")

# ---- test compute_fecundity_rates ----
test_that("compute_fecundity_rates returns expected output", {
  res <- compute_fecundity_rates(
    parturition_rate = 0.8,
    litsize = 2,
    fem_birth_fraction = 0.5
  )

  expect_type(res, "list")
  expect_named(res, c("fem_fec", "mal_fec"))
  expect_equal(res$fem_fec, 0.8 * 2 * 0.5 / 365)
  expect_equal(res$mal_fec, 0.8 * 2 * 0.5 / 365)  # symmetrical case
})

# ---- test compute_transition_probabilities ----
test_that("compute_transition_probabilities returns named list with correct lengths", {
  dur <- setNames(rep(365, 6), share_cohorts)
  off <- setNames(rep(0.1, 6), share_cohorts)
  death <- setNames(rep(0.05, 6), share_cohorts)

  res <- compute_transition_probabilities(
    duration = dur,
    offtake_rate = off,
    mort_rate = death
  )

  expect_type(res, "list")
  expect_named(res, c("hazard_death", "hazard_offtake", "prob_death", "prob_offtake", "prob_survival", "prob_growth"))
  expect_length(res$hazard_death, 6)
  expect_length(res$prob_death, 10)
})

# ---- test simulate_steady_state_structure ----
test_that("simulate_steady_state_structure converges and returns valid structure", {
  fec <- compute_fecundity_rates(0.8, 2, 0.5)
  trans <- compute_transition_probabilities(
    duration = setNames(rep(365, 6), share_cohorts),
    offtake_rate = setNames(rep(0.1, 6), share_cohorts),
    mort_rate = setNames(rep(0.05, 6), share_cohorts)
  )

  result <- simulate_steady_state_structure(
    initial_structure = c(
      FJ = 100, FS = 50, FA = 30,
      MJ = 100, MS = 50, MA = 30
    ),
    max_years = 5,
    min_lambda_change = 1e-6,
    fem_fec = fec$fem_fec,
    mal_fec = fec$mal_fec,
    prob_death = setNames(trans$prob_death, cohorts),
    prob_offtake = setNames(trans$prob_offtake, cohorts),
    prob_growth = setNames(trans$prob_growth, cohorts)
  )

  expect_named(result, c("days_steady", "structure", "share", "growth_rate_pop"))
  expect_true(result$days_steady <= 5 * 365)
  expect_equal(sum(result$structure), 1, tolerance = 1e-6)
})

# ---- test project_population_size ----
test_that("project_population_size runs and returns list with expected elements", {
  fec <- compute_fecundity_rates(
    0.8, 2, 0.5
  )
  trans <- compute_transition_probabilities(
    duration = setNames(rep(365, 6), share_cohorts),
    offtake_rate = setNames(rep(0.1, 6), share_cohorts),
    mort_rate = setNames(rep(0.05, 6), share_cohorts)
  )

  cohorts <- c("FB", "FJ", "FS", "FA", "FC", "MB", "MJ", "MS", "MA", "MC")

  steady <- simulate_steady_state_structure(
    initial_structure = c(
      FJ = 100, FS = 50, FA = 30,
      MJ = 100, MS = 50, MA = 30
    ),
    max_years = 5, min_lambda_change = 1e-6,
    fem_fec = fec$fem_fec,
    mal_fec = fec$mal_fec,
    prob_death = setNames(trans$prob_death, cohorts),
    prob_offtake = setNames(trans$prob_offtake, cohorts),
    prob_growth = setNames(trans$prob_growth, cohorts)
  )

  res <- project_population_size(
    size_total = 1000,
    fem_fec = fec$fem_fec,
    mal_fec = fec$mal_fec,
    prob_death = setNames(trans$prob_death, cohorts),
    prob_offtake = setNames(trans$prob_offtake, cohorts),
    prob_growth = setNames(trans$prob_growth, cohorts),
    growth_rate_pop = steady$growth_rate_pop,
    structure = steady$structure,
    share = steady$share
  )

  expect_named(res, c("size", "size_end", "size_end_exact", "size_avg", "offtake"))
  expect_length(res$size, 6)
})

# ---- test summarise_offtake ----
test_that("summarise_offtake returns all expected components", {
  res <- summarise_offtake(
    size = setNames(rep(100, 6), share_cohorts),
    size_end = setNames(rep(105, 6), share_cohorts),
    size_avg = setNames(rep(102, 6), share_cohorts),
    offtake = setNames(rep(0.01, 10), cohorts),
    assessment_duration = 200
  )

  expect_named(res, c(
    "stock_variation", "offtake_number", "offtake_number_assessment", "offtake_share", "offtake_share_avg",
    "offtake_sv_number", "offtake_sv_share", "offtake_sv_share_avg"
  ))
  expect_length(res$offtake_number, 6)
})
