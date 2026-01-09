
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

# ---- test calc_cohort_weights ----
test_that("calc_cohort_weights returns valid weights for juvenile non-pig", {
  result <- calc_cohort_weights(
    animal = "CTL", cohort = "FJ",
    adult_fem_weight = 500, adult_mal_weight = 600,
    birth_weight = 35, slaughter_weight_fem = 480,
    slaughter_weight_mal = 550, weaning_weight = 90,
    age_first_calving = 730, animal_age = 200
  )

  expect_named(result, c("initial_weight", "potential_final_weight", "slaughter_weight"))
  expect_type(result$initial_weight, "double")
  expect_true(result$initial_weight == 35)
  expect_gt(result$potential_final_weight, result$initial_weight)
  expect_equal(result$potential_final_weight, result$slaughter_weight)
})

test_that("calc_cohort_weights returns correct weights for adult female", {
  result <- calc_cohort_weights(
    animal = "SHP", cohort = "FA",
    adult_fem_weight = 70, adult_mal_weight = 90,
    birth_weight = 4, slaughter_weight_fem = 65,
    slaughter_weight_mal = 85, weaning_weight = 18,
    age_first_calving = 400, animal_age = 300
  )

  expect_equal(result$initial_weight, 70)
  expect_equal(result$potential_final_weight, 70)
  expect_equal(result$slaughter_weight, 70)
})

test_that("calc_cohort_weights handles pig juvenile with weaning weight", {
  result <- calc_cohort_weights(
    animal = "PGS", cohort = "FJ",
    adult_fem_weight = 180, adult_mal_weight = 220,
    birth_weight = 1.5, slaughter_weight_fem = 160,
    slaughter_weight_mal = 200, weaning_weight = 10,
    age_first_calving = 365, animal_age = 60
  )

  expect_equal(result$initial_weight, 1.5)
  expect_equal(result$potential_final_weight, 10)
  expect_equal(result$slaughter_weight, 10)
})

# ---- test calc_avg_weights ----
test_that("calc_avg_weights returns correct average and final weights", {
  result <- calc_avg_weights(
    initial_weight = 100,
    potential_final_weight = 300,
    slaughter_weight = 200,
    offtake_rate = 0.4
  )

  expect_equal(result$final_weight, 260)
  expect_equal(result$average_weight, 180)
})

test_that("calc_avg_weights handles zero offtake", {
  result <- calc_avg_weights(100, 300, 200, 0)
  expect_equal(result$final_weight, 300)
  expect_equal(result$average_weight, 200)
})

# ---- test calc_daily_weight_gain ----
test_that("calc_daily_weight_gain computes correct value", {
  gain <- calc_daily_weight_gain(300, 100, 100)
  expect_equal(gain, 2)
})

test_that("calc_daily_weight_gain returns 0 when weights are equal", {
  expect_equal(calc_daily_weight_gain(200, 200, 100), 0)
})

test_that("calc_daily_weight_gain handles negative gain", {
  expect_equal(calc_daily_weight_gain(100, 200, 100), -1)
})
