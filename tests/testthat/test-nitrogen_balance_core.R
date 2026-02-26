# ---- test compute_nitrogen_intake ----
test_that("compute_nitrogen_intake produces expected results", {
  expect_equal(compute_nitrogen_intake(10, 0.03), 0.3)
  expect_equal(compute_nitrogen_intake(0, 0.03), 0)
  expect_equal(compute_nitrogen_intake(5, 0), 0)
  expect_equal(compute_nitrogen_intake(2.5, 0.04), 0.1)
  expect_equal(compute_nitrogen_intake(8, 0.1), 0.8) # upper bound
})

# ---- test compute_nitrogen_retention (cattle) ----
test_that("retention for cattle: milk + growth add up correctly", {
  base <- compute_nitrogen_retention(
    "CTL", "FA",
    milk_protein_fraction = 32, milk_yield_day = 20,
    daily_weight_gain = 0, fibre_yield_year = 0,
    litter_size = 1, parturition_rate = 1
  )
  with_growth <- compute_nitrogen_retention(
    "CTL", "FA",
    milk_protein_fraction = 32, milk_yield_day = 20,
    daily_weight_gain = 0.5, fibre_yield_year = 0,
    litter_size = 1, parturition_rate = 1
  )
  expect_equal(with_growth - base, 0.5 * 0.0326, tolerance = 1e-12)

  none <- compute_nitrogen_retention(
    "CTL", "FA",
    milk_protein_fraction = 32, milk_yield_day = 0,
    daily_weight_gain = 0, fibre_yield_year = 0,
    litter_size = 1, parturition_rate = 1
  )
  expect_equal(base - none, 20 * (32 / 6.25), tolerance = 1e-12)
  expect_gt(base, 0)
})

# ---- test compute_nitrogen_retention (goats) ----
test_that("retention for goats includes fibre component", {
  base <- compute_nitrogen_retention(
    "GTS", "FA",
    milk_protein_fraction = NA_real_, milk_yield_day = NA_real_,
    daily_weight_gain = 0, fibre_yield_year = 0,
    litter_size = 1, parturition_rate = 1
  )
  with_fibre <- compute_nitrogen_retention(
    "GTS", "FA",
    milk_protein_fraction = NA_real_, milk_yield_day = NA_real_,
    daily_weight_gain = 0, fibre_yield_year = 10,
    litter_size = 1, parturition_rate = 1
  )
  expect_equal(with_fibre - base, (10 / 365) * 0.134, tolerance = 1e-12)
})

# ---- test compute_nitrogen_retention (sheep) ----
test_that("retention for sheep with only fibre is positive", {
  val <- compute_nitrogen_retention(
    "SHP", "FA",
    milk_protein_fraction = NA_real_, milk_yield_day = NA_real_,
    daily_weight_gain = NA_real_, fibre_yield_year = 20,
    litter_size = 1, parturition_rate = 1
  )
  expect_gt(val, 0)
})

# ---- test compute_nitrogen_retention (pigs AF) ----
test_that("retention for pigs FA cohort is positive", {
  val <- compute_nitrogen_retention(
    "PGS", "FA",
    litter_size = 10, parturition_rate = 2,
    weaning_weight = 30, birth_weight = 1, daily_weight_gain = 1
  )
  expect_gt(val, 0)
})

# ---- test compute_nitrogen_retention (pigs FS) ----
test_that("retention for pigs FS cohort includes growth and reproductive", {
  val <- compute_nitrogen_retention(
    "PGS", "FS",
    daily_weight_gain = 0.5,
    litter_size = 12, parturition_rate = 2.2,
    weaning_weight = 20, birth_weight = 1, age_first_parturition = 365
  )
  expect_gt(val, 0)
})

# ---- test compute_nitrogen_retention (pigs growers) ----
test_that("retention for pigs growers matches 0.025*daily_weight_gain", {
  val <- compute_nitrogen_retention(
    "PGS", "MS",
    daily_weight_gain = 0.8, litter_size = 1, parturition_rate = 1
  )
  expect_equal(val, 0.025 * 0.8, tolerance = 1e-12)
})

# ---- test compute_nitrogen_retention (chickens) ----
test_that("retention returns NA for chickens", {
  val <- compute_nitrogen_retention(
    "CHK", "FA",
    litter_size = 1, parturition_rate = 1
  )
  expect_true(is.na(val))
})

# ---- test compute_nitrogen_excretion ----
test_that("excretion subtracts intake and retention", {
  expect_equal(compute_nitrogen_excretion("CTL", 0.5, 0.2), 0.3)
  expect_equal(compute_nitrogen_excretion("PGS", 0.4, 0.1), 0.3)
})

test_that("excretion returns NA for chickens", {
  val <- compute_nitrogen_excretion("CHK", 0.5, 0.2)
  expect_true(is.na(val))
})

test_that("excretion handles zero and negative results", {
  expect_equal(compute_nitrogen_excretion("CTL", 0.5, 0), 0.5)
  expect_equal(compute_nitrogen_excretion("CTL", 0, 0.2), -0.2)
})
