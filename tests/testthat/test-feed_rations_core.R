# ---- calc_diet_digestibility -------------------------------------------------
test_that("calc_diet_digestibility selects ruminant digestibility", {
  value <- calc_diet_digestibility(
    species_short = "CTL",
    feed_ration_fraction = 0.6,
    feed_digestibility_fraction_ruminant = 0.7,
    feed_digestibility_fraction_pigs = 0.5,
    feed_digestibility_fraction_chicken = 0.4
  )
  expect_equal(value, 0.42)
})

test_that("calc_diet_digestibility selects chicken digestibility", {
  value <- calc_diet_digestibility(
    species_short = "CHK",
    feed_ration_fraction = 0.6,
    feed_digestibility_fraction_ruminant = 0.7,
    feed_digestibility_fraction_pigs = 0.5,
    feed_digestibility_fraction_chicken = 0.4
  )
  expect_equal(value, 0.24)
})

test_that("calc_diet_digestibility selects pig digestibility", {
  value <- calc_diet_digestibility(
    species_short = "PGS",
    feed_ration_fraction = 0.6,
    feed_digestibility_fraction_ruminant = 0.7,
    feed_digestibility_fraction_pigs = 0.5,
    feed_digestibility_fraction_chicken = 0.4
  )
  expect_equal(value, 0.3)
})

# ---- calc_diet_metabolizable_energy ------------------------------------------
test_that("calc_diet_metabolizable_energy selects ruminant ME", {
  value <- calc_diet_metabolizable_energy(
    species_short = "CTL",
    feed_ration_fraction = 0.6,
    feed_metabolizable_energy_ruminant = 10,
    feed_metabolizable_energy_pigs = 12,
    feed_metabolizable_energy_chicken = 14
  )
  expect_equal(value, 6)
})

test_that("calc_diet_metabolizable_energy selects chicken ME", {
  value <- calc_diet_metabolizable_energy(
    species_short = "CHK",
    feed_ration_fraction = 0.6,
    feed_metabolizable_energy_ruminant = 10,
    feed_metabolizable_energy_pigs = 12,
    feed_metabolizable_energy_chicken = 14
  )
  expect_equal(value, 8.4)
})

test_that("calc_diet_metabolizable_energy selects pig ME", {
  value <- calc_diet_metabolizable_energy(
    species_short = "PGS",
    feed_ration_fraction = 0.6,
    feed_metabolizable_energy_ruminant = 10,
    feed_metabolizable_energy_pigs = 12,
    feed_metabolizable_energy_chicken = 14
  )
  expect_equal(value, 7.2)
})

test_that("calc_diet_metabolizable_energy rejects invalid species_short", {
  expect_error(
    calc_diet_metabolizable_energy(
      species_short = "DOG",
      feed_ration_fraction = 0.6,
      feed_metabolizable_energy_ruminant = 10,
      feed_metabolizable_energy_pigs = 12,
      feed_metabolizable_energy_chicken = 14
    ),
    "Invalid species_short value"
  )
})

test_that("calc_diet_digestibility rejects NA inputs", {
  expect_error(
    calc_diet_digestibility(
      species_short = "CTL",
      feed_ration_fraction = NA_real_,
      feed_digestibility_fraction_ruminant = 0.7,
      feed_digestibility_fraction_pigs = 0.5,
      feed_digestibility_fraction_chicken = 0.4
    ),
    "must be a single numeric value"
  )
})

test_that("calc_diet_metabolizable_energy rejects NA inputs", {
  expect_error(
    calc_diet_metabolizable_energy(
      species_short = "CTL",
      feed_ration_fraction = 0.6,
      feed_metabolizable_energy_ruminant = NA_real_,
      feed_metabolizable_energy_pigs = 12,
      feed_metabolizable_energy_chicken = 14
    ),
    "Missing required metabolizable energy inputs"
  )
})

test_that("calc_diet_metabolizable_energy allows NA for unused animals", {
  value <- calc_diet_metabolizable_energy(
    species_short = "CHK",
    feed_ration_fraction = 0.6,
    feed_metabolizable_energy_ruminant = NA_real_,
    feed_metabolizable_energy_pigs = NA_real_,
    feed_metabolizable_energy_chicken = 14
  )
  expect_equal(value, 8.4)
})

test_that("calc_diet_digestibility allows NA for unused animals", {
  value <- calc_diet_digestibility(
    species_short = "PGS",
    feed_ration_fraction = 0.6,
    feed_digestibility_fraction_ruminant = NA_real_,
    feed_digestibility_fraction_pigs = 0.5,
    feed_digestibility_fraction_chicken = NA_real_
  )
  expect_equal(value, 0.3)
})

test_that("calc_diet_digestibility rejects missing required inputs by species_short", {
  expect_error(
    calc_diet_digestibility(
      species_short = "CHK",
      feed_ration_fraction = 0.6,
      feed_digestibility_fraction_ruminant = 0.7,
      feed_digestibility_fraction_pigs = 0.5,
      feed_digestibility_fraction_chicken = NA_real_
    ),
    "Missing required digestibility inputs"
  )
})

# ---- calc_feed_digestibility_fraction -----------------------------------------
test_that("calc_feed_digestibility_fraction computes ratios", {
  results <- calc_feed_digestibility_fraction(
    feed_digestible_energy_ruminant = 8,
    feed_digestible_energy_pigs = 7,
    feed_metabolizable_energy_chicken = 6,
    feed_gross_energy = 16
  )

  expect_equal(
    results,
    list(
      feed_digestibility_fraction_ruminant = 0.5,
      feed_digestibility_fraction_pigs = 0.4375,
      feed_digestibility_fraction_chicken = 0.375
    )
  )
})

# test_that("calc_feed_digestibility_fraction rejects NA inputs", {
#   expect_error(
#     calc_feed_digestibility_fraction(
#       feed_digestible_energy_ruminant = NA_real_,
#       feed_digestible_energy_pigs = 7,
#       feed_metabolizable_energy_chicken = 6,
#       feed_gross_energy = 16
#     ),
#     "must be a single numeric value"
#   )
# })

# ---- calc_diet_gross_energy --------------------------------------------------
test_that("calc_diet_gross_energy computes contribution", {
  expect_equal(calc_diet_gross_energy(0.6, 18), 10.8)
})

test_that("calc_diet_gross_energy rejects NA inputs", {
  expect_error(
    calc_diet_gross_energy(NA_real_, 18),
    "must be a single numeric value"
  )
})

# ---- calc_diet_nitrogen_content ----------------------------------------------
test_that("calc_diet_nitrogen_content computes contribution", {
  expect_equal(calc_diet_nitrogen_content(0.6, 0.02), 0.012)
})

test_that("calc_diet_nitrogen_content rejects NA inputs", {
  expect_error(
    calc_diet_nitrogen_content(0.6, NA_real_),
    "must be a single numeric value"
  )
})

# ---- calc_urinary_energy_fraction --------------------------------------------
test_that("calc_urinary_energy_fraction selects ruminant urinary energy", {
  value <- calc_urinary_energy_fraction(
    species_short = "CTL",
    feed_ration_fraction = 0.6,
    feed_urinary_energy_ruminant = 0.12,
    feed_urinary_energy_pigs = 0.02,
    feed_urinary_energy_chicken = 0.04
  )
  expect_equal(value, 0.072)
})

test_that("calc_urinary_energy_fraction selects chicken urinary energy", {
  value <- calc_urinary_energy_fraction(
    species_short = "CHK",
    feed_ration_fraction = 0.6,
    feed_urinary_energy_ruminant = 0.12,
    feed_urinary_energy_pigs = 0.02,
    feed_urinary_energy_chicken = 0.04
  )
  expect_equal(value, 0.024)
})

test_that("calc_urinary_energy_fraction selects pig urinary energy", {
  value <- calc_urinary_energy_fraction(
    species_short = "PGS",
    feed_ration_fraction = 0.6,
    feed_urinary_energy_ruminant = 0.12,
    feed_urinary_energy_pigs = 0.02,
    feed_urinary_energy_chicken = 0.04
  )
  expect_equal(value, 0.012)
})

test_that("calc_urinary_energy_fraction rejects invalid species_short", {
  expect_error(
    calc_urinary_energy_fraction(
      species_short = "DOG",
      feed_ration_fraction = 0.6,
      feed_urinary_energy_ruminant = 0.12,
      feed_urinary_energy_pigs = 0.02,
      feed_urinary_energy_chicken = 0.04
    ),
    "Invalid species_short value"
  )
})

test_that("calc_urinary_energy_fraction allows NA for unused animals", {
  value <- calc_urinary_energy_fraction(
    species_short = "CHK",
    feed_ration_fraction = 0.6,
    feed_urinary_energy_ruminant = NA_real_,
    feed_urinary_energy_pigs = NA_real_,
    feed_urinary_energy_chicken = 0.04
  )
  expect_equal(value, 0.024)
})

test_that("calc_urinary_energy_fraction rejects missing required inputs", {
  expect_error(
    calc_urinary_energy_fraction(
      species_short = "CHK",
      feed_ration_fraction = 0.6,
      feed_urinary_energy_ruminant = 0.12,
      feed_urinary_energy_pigs = 0.02,
      feed_urinary_energy_chicken = NA_real_
    ),
    "Missing required urinary energy inputs"
  )
})

# ---- calc_diet_ash ----------------------------------------------------------
test_that("calc_diet_ash computes contribution", {
  expect_equal(calc_diet_ash(0.6, 10), 0.06)
})

test_that("calc_diet_ash rejects NA inputs", {
  expect_error(
    calc_diet_ash(NA_real_, 10),
    "must be a single numeric value"
  )
})
