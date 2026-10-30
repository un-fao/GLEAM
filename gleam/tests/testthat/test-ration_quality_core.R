# ---- calc_ration_digestibility -------------------------------------------------
test_that("calc_ration_digestibility selects ruminant digestibility", {
  value <- calc_ration_digestibility(
    species_short = "CTL",
    feed_ration_fraction = 0.6,
    feed_digestibility_fraction_ruminant = 0.7,
    feed_digestibility_fraction_pigs = 0.5
  )
  expect_equal(value, 0.42)
})

test_that("calc_ration_digestibility selects pig digestibility", {
  value <- calc_ration_digestibility(
    species_short = "PGS",
    feed_ration_fraction = 0.6,
    feed_digestibility_fraction_ruminant = 0.7,
    feed_digestibility_fraction_pigs = 0.5
  )
  expect_equal(value, 0.3)
})

# ---- calc_ration_metabolizable_energy ------------------------------------------
test_that("calc_ration_metabolizable_energy selects ruminant ME", {
  value <- calc_ration_metabolizable_energy(
    species_short = "CTL",
    feed_ration_fraction = 0.6,
    feed_metabolizable_energy_ruminant = 10,
    feed_metabolizable_energy_pigs = 12
  )
  expect_equal(value, 6)
})

test_that("calc_ration_metabolizable_energy selects pig ME", {
  value <- calc_ration_metabolizable_energy(
    species_short = "PGS",
    feed_ration_fraction = 0.6,
    feed_metabolizable_energy_ruminant = 10,
    feed_metabolizable_energy_pigs = 12
  )
  expect_equal(value, 7.2)
})

test_that("calc_ration_metabolizable_energy rejects invalid species_short", {
  expect_error(
    calc_ration_metabolizable_energy(
      species_short = "DOG",
      feed_ration_fraction = 0.6,
      feed_metabolizable_energy_ruminant = 10,
      feed_metabolizable_energy_pigs = 12
    ),
    "`species_short` must be one of"
  )
})

test_that("calc_ration_digestibility rejects NA inputs", {
  expect_error(
    calc_ration_digestibility(
      species_short = "CTL",
      feed_ration_fraction = NA_real_,
      feed_digestibility_fraction_ruminant = 0.7,
      feed_digestibility_fraction_pigs = 0.5
    ),
    "must be a single numeric value"
  )
})

test_that("calc_ration_metabolizable_energy rejects NA inputs", {
  expect_error(
    calc_ration_metabolizable_energy(
      species_short = "CTL",
      feed_ration_fraction = 0.6,
      feed_metabolizable_energy_ruminant = NA_real_,
      feed_metabolizable_energy_pigs = 12
    ),
    "Missing required metabolizable energy inputs"
  )
})

test_that("calc_ration_digestibility allows NA for unused animals", {
  value <- calc_ration_digestibility(
    species_short = "PGS",
    feed_ration_fraction = 0.6,
    feed_digestibility_fraction_ruminant = NA_real_,
    feed_digestibility_fraction_pigs = 0.5
  )
  expect_equal(value, 0.3)
})

test_that("calc_ration_digestibility rejects missing required inputs by species_short", {
  expect_error(
    calc_ration_digestibility(
      species_short = "PGS",
      feed_ration_fraction = 0.6,
      feed_digestibility_fraction_ruminant = 0.7,
      feed_digestibility_fraction_pigs = NA_real_
    ),
    "Missing required digestibility inputs"
  )
})

# ---- calc_feed_digestibility_fraction -----------------------------------------
test_that("calc_feed_digestibility_fraction computes ratios", {
  results <- calc_feed_digestibility_fraction(
    feed_digestible_energy_ruminant = 8,
    feed_digestible_energy_pigs = 7,
    feed_gross_energy = 16
  )

  expect_equal(
    results,
    list(
      feed_digestibility_fraction_ruminant = 0.5,
      feed_digestibility_fraction_pigs = 0.4375
    )
  )
})

test_that("calc_feed_digestibility_fraction treats NA numerator as zero", {
  results <- calc_feed_digestibility_fraction(
    feed_digestible_energy_ruminant = NA_real_,
    feed_digestible_energy_pigs = 7,
    feed_gross_energy = 16
  )

  expect_equal(
    results,
    list(
      feed_digestibility_fraction_ruminant = 0,
      feed_digestibility_fraction_pigs = 0.4375
    )
  )
})

# ---- calc_ration_gross_energy --------------------------------------------------
test_that("calc_ration_gross_energy computes contribution", {
  expect_equal(calc_ration_gross_energy(0.6, 18), 10.8)
})

test_that("calc_ration_gross_energy rejects NA inputs", {
  expect_error(
    calc_ration_gross_energy(NA_real_, 18),
    "must be a single numeric value"
  )
})

# ---- calc_ration_nitrogen_content ----------------------------------------------
test_that("calc_ration_nitrogen_content computes contribution", {
  expect_equal(calc_ration_nitrogen_content(0.6, 0.02), 0.012)
})

test_that("calc_ration_nitrogen_content rejects NA inputs", {
  expect_error(
    calc_ration_nitrogen_content(0.6, NA_real_),
    "must be a single numeric value"
  )
})

# ---- calc_ration_urinary_energy_fraction --------------------------------------------
test_that("calc_ration_urinary_energy_fraction selects ruminant urinary energy", {
  value <- calc_ration_urinary_energy_fraction(
    species_short = "CTL",
    feed_ration_fraction = 0.6,
    feed_urinary_energy_ruminant = 0.12,
    feed_urinary_energy_pigs = 0.02
  )
  expect_equal(value, 0.072)
})

test_that("calc_ration_urinary_energy_fraction selects pig urinary energy", {
  value <- calc_ration_urinary_energy_fraction(
    species_short = "PGS",
    feed_ration_fraction = 0.6,
    feed_urinary_energy_ruminant = 0.12,
    feed_urinary_energy_pigs = 0.02
  )
  expect_equal(value, 0.012)
})

test_that("calc_ration_urinary_energy_fraction rejects invalid species_short", {
  expect_error(
    calc_ration_urinary_energy_fraction(
      species_short = "DOG",
      feed_ration_fraction = 0.6,
      feed_urinary_energy_ruminant = 0.12,
      feed_urinary_energy_pigs = 0.02
    ),
    "`species_short` must be one of"
  )
})

test_that("calc_ration_urinary_energy_fraction allows NA for unused animals", {
  value <- calc_ration_urinary_energy_fraction(
    species_short = "PGS",
    feed_ration_fraction = 0.6,
    feed_urinary_energy_ruminant = NA_real_,
    feed_urinary_energy_pigs = 0.02
  )
  expect_equal(value, 0.012)
})

test_that("calc_ration_urinary_energy_fraction rejects missing required inputs", {
  expect_error(
    calc_ration_urinary_energy_fraction(
      species_short = "PGS",
      feed_ration_fraction = 0.6,
      feed_urinary_energy_ruminant = 0.12,
      feed_urinary_energy_pigs = NA_real_
    ),
    "Missing required urinary energy inputs"
  )
})

# ---- calc_ration_ash ----------------------------------------------------------
test_that("calc_ration_ash computes contribution", {
  expect_equal(calc_ration_ash(0.6, 10), 0.06)
})

test_that("calc_ration_ash rejects NA inputs", {
  expect_error(
    calc_ration_ash(NA_real_, 10),
    "must be a single numeric value"
  )
})
