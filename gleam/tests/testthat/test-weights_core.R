# ---- test calc_cohort_weights ----
test_that("calc_cohort_weights returns valid weights for juvenile non-pig", {
  result <- calc_cohort_weights(
    cohort_short = "FJ",
    live_weight_female_adult = 500, live_weight_male_adult = 600,
    live_weight_at_birth = 35, live_weight_female_at_slaughter = 480,
    live_weight_male_at_slaughter = 550, live_weight_at_weaning = 90
  )

  expect_named(
    result,
    c(
      "live_weight_mature_stage",
      "live_weight_cohort_initial",
      "live_weight_cohort_potential_final",
      "live_weight_cohort_at_slaughter"
    )
  )
  expect_type(result$live_weight_cohort_initial, "double")
  expect_true(result$live_weight_cohort_initial == 35)
  expect_gt(result$live_weight_cohort_potential_final, result$live_weight_cohort_initial)
  expect_equal(result$live_weight_cohort_potential_final, result$live_weight_cohort_at_slaughter)
})

test_that("calc_cohort_weights returns correct weights for adult female", {
  result <- calc_cohort_weights(
    cohort_short = "FA",
    live_weight_female_adult = 70, live_weight_male_adult = 90,
    live_weight_at_birth = 4, live_weight_female_at_slaughter = 65,
    live_weight_male_at_slaughter = 85, live_weight_at_weaning = 18
  )

  expect_equal(result$live_weight_cohort_initial, 70)
  expect_equal(result$live_weight_cohort_potential_final, 70)
  expect_equal(result$live_weight_cohort_at_slaughter, 70)
})

test_that("calc_cohort_weights handles pig juvenile with weaning weight", {
  result <- calc_cohort_weights(
    cohort_short = "FJ",
    live_weight_female_adult = 180, live_weight_male_adult = 220,
    live_weight_at_birth = 1.5, live_weight_female_at_slaughter = 160,
    live_weight_male_at_slaughter = 200, live_weight_at_weaning = 10
  )

  expect_equal(result$live_weight_cohort_initial, 1.5)
  expect_equal(result$live_weight_cohort_potential_final, 10)
  expect_equal(result$live_weight_cohort_at_slaughter, 10)
})

test_that("calc_cohort_weights interpolates non-demo female weights across two phases", {
  phase1 <- calc_cohort_weights(
    cohort_short = "FN",
    nondemo_productive_phase_id = 1,
    live_weight_female_nondemographic_start = 20,
    live_weight_female_nondemographic_end = 100,
    phase1_nondemo_fem_duration_days = 30,
    phase2_nondemo_fem_duration_days = 50
  )
  phase2 <- calc_cohort_weights(
    cohort_short = "FN",
    nondemo_productive_phase_id = 2,
    live_weight_female_nondemographic_start = 20,
    live_weight_female_nondemographic_end = 100,
    phase1_nondemo_fem_duration_days = 30,
    phase2_nondemo_fem_duration_days = 50
  )

  expect_equal(phase1$live_weight_cohort_initial, 20)
  expect_equal(phase1$live_weight_cohort_potential_final, 50)
  expect_equal(phase2$live_weight_cohort_initial, 50)
  expect_equal(phase2$live_weight_cohort_potential_final, 100)
})

test_that("calc_cohort_weights uses full non-demo range when only phase 1 is present", {
  phase1 <- calc_cohort_weights(
    cohort_short = "MN",
    nondemo_productive_phase_id = 1,
    live_weight_male_nondemographic_start = 30,
    live_weight_male_nondemographic_end = 90,
    phase1_nondemo_mal_duration_days = 20,
    phase2_nondemo_mal_duration_days = 0
  )

  expect_equal(phase1$live_weight_cohort_initial, 30)
  expect_equal(phase1$live_weight_cohort_potential_final, 90)
  expect_equal(phase1$live_weight_cohort_at_slaughter, 90)
})

test_that("calc_cohort_weights allows NA inputs for the unused non-demo sex", {
  mn <- calc_cohort_weights(
    cohort_short = "MN",
    nondemo_productive_phase_id = 1,
    live_weight_female_nondemographic_start = NA_real_,
    live_weight_female_nondemographic_end = NA_real_,
    live_weight_male_nondemographic_start = 30,
    live_weight_male_nondemographic_end = 90,
    phase1_nondemo_fem_duration_days = NA_real_,
    phase2_nondemo_fem_duration_days = NA_real_,
    phase1_nondemo_mal_duration_days = 20,
    phase2_nondemo_mal_duration_days = 0
  )
  fn <- calc_cohort_weights(
    cohort_short = "FN",
    nondemo_productive_phase_id = 1,
    live_weight_female_nondemographic_start = 20,
    live_weight_female_nondemographic_end = 100,
    live_weight_male_nondemographic_start = NA_real_,
    live_weight_male_nondemographic_end = NA_real_,
    phase1_nondemo_fem_duration_days = 30,
    phase2_nondemo_fem_duration_days = 50,
    phase1_nondemo_mal_duration_days = NA_real_,
    phase2_nondemo_mal_duration_days = NA_real_
  )

  expect_equal(mn$live_weight_cohort_initial, 30)
  expect_equal(fn$live_weight_cohort_initial, 20)
})

# ---- test calc_avg_weights ----
test_that("calc_avg_weights returns correct average and final weights", {
  result <- calc_avg_weights(
    cohort_short = "FS",
    live_weight_cohort_initial = 100,
    live_weight_cohort_potential_final = 300,
    live_weight_cohort_at_slaughter = 200,
    offtake_rate = 0.4
  )

  expect_equal(result$live_weight_cohort_final, 260)
  expect_equal(result$live_weight_cohort_average, 180)
})

test_that("calc_avg_weights handles zero offtake", {
  result <- calc_avg_weights("FS", 100, 300, 200, 0)
  expect_equal(result$live_weight_cohort_final, 300)
  expect_equal(result$live_weight_cohort_average, 200)
})

test_that("calc_avg_weights ignores offtake for FN and MN", {
  result_fn <- calc_avg_weights("FN", 30, 80, 60, 0.9)
  result_mn <- calc_avg_weights("MN", 35, 90, 55, 0.8)

  expect_equal(result_fn$live_weight_cohort_final, 80)
  expect_equal(result_fn$live_weight_cohort_average, 55)
  expect_equal(result_mn$live_weight_cohort_final, 90)
  expect_equal(result_mn$live_weight_cohort_average, 62.5)
})

test_that("calc_avg_weights allows offtake_rate equal to 1 for FN and MN", {
  expect_no_error(calc_avg_weights("FN", 30, 80, 60, 1))
  expect_no_error(calc_avg_weights("MN", 35, 90, 55, 1))
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
      live_weight_at_birth = 35,
      live_weight_female_at_slaughter = 480,
      live_weight_male_at_slaughter = 550,
      live_weight_at_weaning = 90
    ),
    "Missing required weight inputs"
  )
})

test_that("calc_cohort_weights rejects missing live_weight_female_at_slaughter for FS", {
  expect_error(
    calc_cohort_weights(
      cohort_short = "FS",
      live_weight_female_adult = 500,
      live_weight_male_adult = 600,
      live_weight_at_birth = 35,
      live_weight_female_at_slaughter = NA_real_,
      live_weight_male_at_slaughter = 550,
      live_weight_at_weaning = 90
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
      live_weight_at_birth = 35,
      live_weight_female_at_slaughter = 480,
      live_weight_male_at_slaughter = 550,
      live_weight_at_weaning = 90
    ),
    "Missing required weight inputs"
  )
})
