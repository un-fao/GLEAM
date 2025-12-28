# ---- test calc_on_farm_emissions: basic functionality ----

test_that("calc_on_farm_emissions returns correct value", {
  expect_equal(calc_on_farm_emissions(100, 500), 50)
  expect_equal(calc_on_farm_emissions(1000, 0.5), 0.5)
  expect_equal(calc_on_farm_emissions(0, 500), 0)
  expect_equal(calc_on_farm_emissions(100, 0), 0)
})

# ---- test calc_on_farm_emissions: validation ----

test_that("calc_on_farm_emissions rejects invalid types", {
  expect_error(calc_on_farm_emissions("100", 500), "must be a single numeric value")
  expect_error(calc_on_farm_emissions(100, "500"), "must be a single numeric value")
  expect_error(calc_on_farm_emissions(NA_real_, 500), "must be a single numeric value")
  expect_error(calc_on_farm_emissions(c(100, 200), 500), "must be a single numeric value")
})

test_that("calc_on_farm_emissions rejects negative values", {
  expect_error(calc_on_farm_emissions(-10, 500), "must be non-negative")
  expect_error(calc_on_farm_emissions(100, -500), "must be non-negative")
})
