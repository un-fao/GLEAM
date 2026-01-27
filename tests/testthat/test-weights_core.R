# ---- test calc_cohort_weights ----
test_that("calc_cohort_weights returns valid weights for juvenile non-pig", {
  result <- calc_cohort_weights(
    cohort = "FJ",
    adult_fem_weight = 500, adult_mal_weight = 600,
    birth_weight = 35, slaughter_weight_fem = 480,
    slaughter_weight_mal = 550, weaning_weight = 90
  )

  expect_named(
    result,
    c("adult_weight", "initial_weight", "potential_final_weight", "slaughter_weight")
  )
  expect_type(result$initial_weight, "double")
  expect_true(result$initial_weight == 35)
  expect_gt(result$potential_final_weight, result$initial_weight)
  expect_equal(result$potential_final_weight, result$slaughter_weight)
})

test_that("calc_cohort_weights returns correct weights for adult female", {
  result <- calc_cohort_weights(
    cohort = "FA",
    adult_fem_weight = 70, adult_mal_weight = 90,
    birth_weight = 4, slaughter_weight_fem = 65,
    slaughter_weight_mal = 85, weaning_weight = 18
  )

  expect_equal(result$initial_weight, 70)
  expect_equal(result$potential_final_weight, 70)
  expect_equal(result$slaughter_weight, 70)
})

test_that("calc_cohort_weights handles pig juvenile with weaning weight", {
  result <- calc_cohort_weights(
    cohort = "FJ",
    adult_fem_weight = 180, adult_mal_weight = 220,
    birth_weight = 1.5, slaughter_weight_fem = 160,
    slaughter_weight_mal = 200, weaning_weight = 10
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
