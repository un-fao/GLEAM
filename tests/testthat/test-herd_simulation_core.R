# ---- test compute_fecundity_rates ----
test_that("compute_fecundity_rates returns expected output", {
  res <- compute_fecundity_rates(
    part_rate = 0.8,
    prolif_rate = 2,
    fem_birth_ratio = 0.5
  )

  expect_type(res, "list")
  expect_named(res, c("female_fecundity", "male_fecundity"))
  expect_equal(res$female_fecundity, 0.8 * 2 * 0.5 / 365)
  expect_equal(res$male_fecundity, 0.8 * 2 * 0.5 / 365)  # symmetrical case
})

# ---- test compute_transition_probabilities ----
test_that("compute_transition_probabilities returns named list with correct lengths", {
  dur <- rep(365, 6)
  off <- rep(0.1, 6)
  death <- rep(0.05, 6)

  res <- compute_transition_probabilities(
    duration = dur,
    offtake_rate = off,
    death_rate = death
  )

  expect_type(res, "list")
  expect_named(res, c("hdea", "hoff", "pdea", "poff", "psur", "g"))
  expect_length(res$hdea, 6)
  expect_length(res$pdea, 10)
})

# ---- test simulate_steady_state_structure ----
test_that("simulate_steady_state_structure converges and returns valid structure", {
  fec <- compute_fecundity_rates(0.8, 2, 0.5)
  trans <- compute_transition_probabilities(
    duration = rep(365, 6),
    offtake_rate = rep(0.1, 6),
    death_rate = rep(0.05, 6)
  )

  result <- simulate_steady_state_structure(
    initial_structure = c(100, 50, 30, 100, 50, 30),
    max_years = 5,
    min_lambda_change = 1e-6,
    female_fecundity = fec$female_fecundity,
    male_fecundity = fec$male_fecundity,
    pdea = trans$pdea,
    poff = trans$poff,
    g = trans$g
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
    rep(365, 6), rep(0.1, 6), rep(0.05, 6)
  )
  steady <- simulate_steady_state_structure(
    initial_structure = c(100, 50, 30, 100, 50, 30),
    max_years = 5, min_lambda_change = 1e-6,
    female_fecundity = fec$female_fecundity,
    male_fecundity = fec$male_fecundity,
    pdea = trans$pdea,
    poff = trans$poff,
    g = trans$g
  )

  res <- project_population_size(
    size_total = 1000,
    female_fecundity = fec$female_fecundity,
    male_fecundity = fec$male_fecundity,
    pdea = trans$pdea,
    poff = trans$poff,
    g = trans$g,
    growth_rate_pop = steady$growth_rate_pop,
    structure = steady$structure,
    share = steady$share
  )

  expect_named(res, c("size", "size_end", "size_end_exact", "size_avg", "offtake"))
  expect_length(res$size, 6)
})

# ---- test summarise_offtake ----
test_that("summarise_offtake returns all expected components", {
  offtake <- setNames(rep(10, 10), c("FB", "FJ", "FS", "FA", "FC", "MB", "MJ", "MS", "MA", "MC"))
  res <- summarise_offtake(
    size = rep(100, 6),
    size_end = rep(110, 6),
    size_avg = rep(105, 6),
    offtake = offtake
  )

  expect_named(res, c(
    "stock_variation", "offtake_number", "offtake_share", "offtake_share_avg",
    "offtake_sv_number", "offtake_sv_share", "offtake_sv_share_avg"
  ))
  expect_length(res$offtake_number, 6)
})

# ---- test calc_cohort_weights ----
test_that("calc_cohort_weights returns valid weights for juvenile non-pig", {
  result <- calc_cohort_weights(
    animal = "CTL", cohort = "FJ",
    adult_female_weight = 500, adult_male_weight = 600,
    birth_weight = 35, slaughter_weight_female = 480,
    slaughter_weight_male = 550, weaning_weight = 90,
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
    adult_female_weight = 70, adult_male_weight = 90,
    birth_weight = 4, slaughter_weight_female = 65,
    slaughter_weight_male = 85, weaning_weight = 18,
    age_first_calving = 400, animal_age = 300
  )

  expect_equal(result$initial_weight, 70)
  expect_equal(result$potential_final_weight, 70)
  expect_equal(result$slaughter_weight, 70)
})

test_that("calc_cohort_weights handles pig juvenile with weaning weight", {
  result <- calc_cohort_weights(
    animal = "PGS", cohort = "FJ",
    adult_female_weight = 180, adult_male_weight = 220,
    birth_weight = 1.5, slaughter_weight_female = 160,
    slaughter_weight_male = 200, weaning_weight = 10,
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
