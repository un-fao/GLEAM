# ---- test calc_volatile_solids ----
test_that("calc_volatile_solids produces expected results", {
  result <- calc_volatile_solids(
    dry_matter_intake = 5,
    diet_digestibility_fraction = 0.6,
    urinary_energy_fraction = 0.04,
    diet_ash = 0.08
  )
  expect_length(result, 1)
  expect_true(result >= 0)
  expect_equal(result, 5 * (1 - 0.6 + 0.04) * (1 - 0.08))
})

test_that("calc_volatile_solids produces expected results", {
  result <- calc_volatile_solids(
    dry_matter_intake = 4,
    diet_digestibility_fraction = 0.7,
    urinary_energy_fraction = 0.02,
    diet_ash = 0.06
  )
  expect_equal(result, 4 * (1 - 0.7 + 0.02) * (1 - 0.06))
})

# TODO Yassine: Continue tests using "manure_emissions_example_calculation (1).xlsx"
