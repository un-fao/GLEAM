# ---- test calc_cohort_weights ----
test_that("calc_cohort_weights returns valid weights for juvenile non-pig", {
  result <- calc_cohort_weights(
    cohort_short = "FJ",
    live_weight_female_adult = 500, live_weight_male_adult = 600,
    birth_weight = 35, slaughter_weight_female = 480,
    slaughter_weight_male = 550, weaning_weight = 90
  )

  expect_named(
    result,
    c(
      "mature_weight",
      "live_weight_cohort_initial",
      "live_weight_cohort_potential_final",
      "slaughter_weight_cohort"
    )
  )
  expect_type(result$live_weight_cohort_initial, "double")
  expect_true(result$live_weight_cohort_initial == 35)
  expect_gt(result$live_weight_cohort_potential_final, result$live_weight_cohort_initial)
  expect_equal(result$live_weight_cohort_potential_final, result$slaughter_weight_cohort)
})

test_that("calc_cohort_weights returns correct weights for adult female", {
  result <- calc_cohort_weights(
    cohort_short = "FA",
    live_weight_female_adult = 70, live_weight_male_adult = 90,
    birth_weight = 4, slaughter_weight_female = 65,
    slaughter_weight_male = 85, weaning_weight = 18
  )

  expect_equal(result$live_weight_cohort_initial, 70)
  expect_equal(result$live_weight_cohort_potential_final, 70)
  expect_equal(result$slaughter_weight_cohort, 70)
})

test_that("calc_cohort_weights handles pig juvenile with weaning weight", {
  result <- calc_cohort_weights(
    cohort_short = "FJ",
    live_weight_female_adult = 180, live_weight_male_adult = 220,
    birth_weight = 1.5, slaughter_weight_female = 160,
    slaughter_weight_male = 200, weaning_weight = 10
  )

  expect_equal(result$live_weight_cohort_initial, 1.5)
  expect_equal(result$live_weight_cohort_potential_final, 10)
  expect_equal(result$slaughter_weight_cohort, 10)
})

# ---- test calc_avg_weights ----
test_that("calc_avg_weights returns correct average and final weights", {
  result <- calc_avg_weights(
    live_weight_cohort_initial = 100,
    live_weight_cohort_potential_final = 300,
    slaughter_weight_cohort = 200,
    offtake_rate = 0.4
  )

  expect_equal(result$live_weight_cohort_final, 260)
  expect_equal(result$live_weight_cohort_average, 180)
})

test_that("calc_avg_weights handles zero offtake", {
  result <- calc_avg_weights(100, 300, 200, 0)
  expect_equal(result$live_weight_cohort_final, 300)
  expect_equal(result$live_weight_cohort_average, 200)
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

# ---- test cohort-specific validation ----
test_that("calc_cohort_weights rejects missing live_weight_female_adult for FJ", {
  expect_error(
    calc_cohort_weights(
      cohort_short = "FJ",
      live_weight_female_adult = NA_real_,
      live_weight_male_adult = 600,
      birth_weight = 35,
      slaughter_weight_female = 480,
      slaughter_weight_male = 550,
      weaning_weight = 90
    ),
    "Missing required weight inputs"
  )
})

test_that("calc_cohort_weights rejects missing slaughter_weight_female for FS", {
  expect_error(
    calc_cohort_weights(
      cohort_short = "FS",
      live_weight_female_adult = 500,
      live_weight_male_adult = 600,
      birth_weight = 35,
      slaughter_weight_female = NA_real_,
      slaughter_weight_male = 550,
      weaning_weight = 90
    ),
    "Missing required weight inputs"
  )
})

test_that("calc_cohort_weights rejects missing live_weight_male_adult for MA", {
  expect_error(
    calc_cohort_weights(
      cohort_short = "MA",
      live_weight_female_adult = 500,
      live_weight_male_adult = NA_real_,
      birth_weight = 35,
      slaughter_weight_female = 480,
      slaughter_weight_male = 550,
      weaning_weight = 90
    ),
    "Missing required weight inputs"
  )
})
