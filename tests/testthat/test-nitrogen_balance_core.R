# ---- test calc_nitrogen_intake ----
test_that("calc_nitrogen_intake produces expected results", {
  expect_equal(calc_nitrogen_intake(10, 0.03), 0.3)
  expect_equal(calc_nitrogen_intake(0, 0.03), 0)
  expect_equal(calc_nitrogen_intake(5, 0), 0)
  expect_equal(calc_nitrogen_intake(2.5, 0.04), 0.1)
  expect_equal(calc_nitrogen_intake(8, 0.1), 0.8) # upper bound
})

# ---- test calc_nitrogen_retention (cattle) ----
test_that("retention for cattle: milk + growth add up correctly", {
  # milk_protein_fraction is kg protein/kg milk (0-1); 0.032 = 3.2%
  base <- calc_nitrogen_retention(
    "CTL", "FA",
    milk_protein_fraction = 0.032, milk_yield_day = 20,
    daily_weight_gain = 0, fibre_yield_year = 0,
    litter_size = 1, parturition_rate = 1
  )
  with_growth <- calc_nitrogen_retention(
    "CTL", "FA",
    milk_protein_fraction = 0.032, milk_yield_day = 20,
    daily_weight_gain = 0.5, fibre_yield_year = 0,
    litter_size = 1, parturition_rate = 1
  )
  expect_equal(with_growth - base, 0.5 * 0.0326, tolerance = 1e-12)

  none <- calc_nitrogen_retention(
    "CTL", "FA",
    milk_protein_fraction = 0.032, milk_yield_day = 0,
    daily_weight_gain = 0, fibre_yield_year = 0,
    litter_size = 1, parturition_rate = 1
  )
  expect_equal(base - none, 20 * (0.032 / 6.25), tolerance = 1e-12)
  expect_gt(base, 0)
})

# ---- test calc_nitrogen_retention (goats) ----
test_that("retention for goats includes fibre component", {
  base <- calc_nitrogen_retention(
    "GTS", "FA",
    milk_protein_fraction = NA_real_, milk_yield_day = NA_real_,
    daily_weight_gain = 0, fibre_yield_year = 0,
    litter_size = 1, parturition_rate = 1
  )
  with_fibre <- calc_nitrogen_retention(
    "GTS", "FA",
    milk_protein_fraction = NA_real_, milk_yield_day = NA_real_,
    daily_weight_gain = 0, fibre_yield_year = 10,
    litter_size = 1, parturition_rate = 1
  )
  expect_equal(with_fibre - base, (10 / 365) * 0.134, tolerance = 1e-12)
})

# ---- test calc_nitrogen_retention (sheep) ----
test_that("retention for sheep with only fibre is positive", {
  val <- calc_nitrogen_retention(
    "SHP", "FA",
    milk_protein_fraction = NA_real_, milk_yield_day = NA_real_,
    daily_weight_gain = NA_real_, fibre_yield_year = 20,
    litter_size = 1, parturition_rate = 1
  )
  expect_gt(val, 0)
})

# ---- test calc_nitrogen_retention (pigs FA) ----
test_that("retention for pigs FA cohort matches reproductive formula", {
  val <- calc_nitrogen_retention(
    "PGS", "FA",
    litter_size = 10, parturition_rate = 2,
    weaning_weight = 30, birth_weight = 1
  )

  expected <- (
    (0.025 * 10 * 2 * (30 - 1) / 0.98) +
      (0.025 * 10 * 2 * 1)
  ) / 365

  expect_equal(val, expected, tolerance = 1e-12)
})

# ---- test calc_nitrogen_retention (pigs FS) ----
test_that("retention for pigs FS cohort matches reproductive formula", {
  val <- calc_nitrogen_retention(
    "PGS", "FS",
    daily_weight_gain = 0.5,
    litter_size = 12, parturition_rate = 2.2,
    weaning_weight = 20, birth_weight = 1,
    pregnancy_duration = 115, cohort_duration_days = 200
  )

  expected <- 0.025 * 0.5 +
    (0.025 * 12 * (115 / 200) * 1 / 0.806) / 365

  expect_equal(val, expected, tolerance = 1e-12)
})

# ---- test calc_nitrogen_retention (pigs growers) ----
test_that("retention for pigs growers matches 0.025*daily_weight_gain", {
  val <- calc_nitrogen_retention(
    "PGS", "MS",
    daily_weight_gain = 0.8
  )
  expect_equal(val, 0.025 * 0.8, tolerance = 1e-12)
})

# ---- test calc_nitrogen_excretion ----
test_that("excretion subtracts intake and retention", {
  expect_equal(calc_nitrogen_excretion("CTL", 0.5, 0.2), 0.3)
  expect_equal(calc_nitrogen_excretion("PGS", 0.4, 0.1), 0.3)
})

test_that("excretion handles zero retention and errors when intake < retention", {
  expect_equal(calc_nitrogen_excretion("CTL", 0.5, 0), 0.5)
  expect_error(
    calc_nitrogen_excretion("CTL", 0, 0.2),
    "nitrogen_intake.*must be greater than or equal to.*nitrogen_retention"
  )
})
