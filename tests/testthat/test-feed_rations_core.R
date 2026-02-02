test_that("calc_diet_digestibility selects ruminant digestibility", {
  value <- calc_diet_digestibility(
    animal = "CTL",
    ration = 0.6,
    dig_ruminants = 0.7,
    dig_pigs = 0.5,
    dig_chickens = 0.4
  )
  expect_equal(value, 0.42)
})

test_that("calc_diet_digestibility selects chicken digestibility", {
  value <- calc_diet_digestibility(
    animal = "CHK",
    ration = 0.6,
    dig_ruminants = 0.7,
    dig_pigs = 0.5,
    dig_chickens = 0.4
  )
  expect_equal(value, 0.24)
})

test_that("calc_diet_digestibility selects pig digestibility", {
  value <- calc_diet_digestibility(
    animal = "PGS",
    ration = 0.6,
    dig_ruminants = 0.7,
    dig_pigs = 0.5,
    dig_chickens = 0.4
  )
  expect_equal(value, 0.3)
})

test_that("calc_diet_metabolizable_energy selects ruminant ME", {
  value <- calc_diet_metabolizable_energy(
    animal = "CTL",
    ration = 0.6,
    me_ruminants = 10,
    me_pigs = 12,
    me_chickens = 14
  )
  expect_equal(value, 6)
})

test_that("calc_diet_metabolizable_energy selects chicken ME", {
  value <- calc_diet_metabolizable_energy(
    animal = "CHK",
    ration = 0.6,
    me_ruminants = 10,
    me_pigs = 12,
    me_chickens = 14
  )
  expect_equal(value, 8.4)
})

test_that("calc_diet_metabolizable_energy selects pig ME", {
  value <- calc_diet_metabolizable_energy(
    animal = "PGS",
    ration = 0.6,
    me_ruminants = 10,
    me_pigs = 12,
    me_chickens = 14
  )
  expect_equal(value, 7.2)
})

test_that("calc_diet_metabolizable_energy rejects invalid animal", {
  expect_error(
    calc_diet_metabolizable_energy(
      animal = "DOG",
      ration = 0.6,
      me_ruminants = 10,
      me_pigs = 12,
      me_chickens = 14
    ),
    "Invalid animal value"
  )
})

test_that("calc_diet_digestibility rejects NA inputs", {
  expect_error(
    calc_diet_digestibility(
      animal = "CTL",
      ration = NA_real_,
      dig_ruminants = 0.7,
      dig_pigs = 0.5,
      dig_chickens = 0.4
    ),
    "must be a single numeric value"
  )
})

test_that("calc_diet_metabolizable_energy rejects NA inputs", {
  expect_error(
    calc_diet_metabolizable_energy(
      animal = "CTL",
      ration = 0.6,
      me_ruminants = NA_real_,
      me_pigs = 12,
      me_chickens = 14
    ),
    "Missing required metabolizable energy inputs"
  )
})

test_that("calc_diet_metabolizable_energy allows NA for unused animals", {
  value <- calc_diet_metabolizable_energy(
    animal = "CHK",
    ration = 0.6,
    me_ruminants = NA_real_,
    me_pigs = NA_real_,
    me_chickens = 14
  )
  expect_equal(value, 8.4)
})

test_that("calc_diet_digestibility allows NA for unused animals", {
  value <- calc_diet_digestibility(
    animal = "PGS",
    ration = 0.6,
    dig_ruminants = NA_real_,
    dig_pigs = 0.5,
    dig_chickens = NA_real_
  )
  expect_equal(value, 0.3)
})

test_that("calc_diet_digestibility rejects missing required inputs by animal", {
  expect_error(
    calc_diet_digestibility(
      animal = "CHK",
      ration = 0.6,
      dig_ruminants = 0.7,
      dig_pigs = 0.5,
      dig_chickens = NA_real_
    ),
    "Missing required digestibility inputs"
  )
})

test_that("calc_energy_digestibility_ratio computes ratio", {
  expect_equal(calc_energy_digestibility_ratio(8, 16), 0.5)
})

test_that("calc_energy_digestibility_ratio rejects NA inputs", {
  expect_error(
    calc_energy_digestibility_ratio(NA_real_, 16),
    "must be a single numeric value"
  )
})

test_that("calc_diet_gross_energy computes contribution", {
  expect_equal(calc_diet_gross_energy(0.6, 18), 10.8)
})

test_that("calc_diet_gross_energy rejects NA inputs", {
  expect_error(
    calc_diet_gross_energy(NA_real_, 18),
    "must be a single numeric value"
  )
})

test_that("calc_diet_nitrogen_content computes contribution", {
  expect_equal(calc_diet_nitrogen_content(0.6, 0.02), 0.012)
})

test_that("calc_diet_nitrogen_content rejects NA inputs", {
  expect_error(
    calc_diet_nitrogen_content(0.6, NA_real_),
    "must be a single numeric value"
  )
})
