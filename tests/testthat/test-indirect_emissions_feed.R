# ---- test compute_dmi_by_feed ----
test_that("compute_dmi_by_feed calculates correctly", {
  expect_equal(compute_dmi_by_feed(10, 0.5), 5)
  expect_equal(compute_dmi_by_feed(0, 0.5), 0)
  expect_equal(compute_dmi_by_feed(10, 0), 0)
  expect_equal(compute_dmi_by_feed(NA, 0.5), 0)
  expect_equal(compute_dmi_by_feed(10, NA), 0)
})

test_that("compute_dmi_by_feed handles edge cases", {
  # Test with very small values
  expect_equal(compute_dmi_by_feed(0.001, 0.1), 0.0001)

  # Test with feed share at boundaries
  expect_equal(compute_dmi_by_feed(10, 0), 0)
  expect_equal(compute_dmi_by_feed(10, 1), 10)

  # Test with zero DMI
  expect_equal(compute_dmi_by_feed(0, 0.5), 0)
})

test_that("compute_dmi_by_feed validates inputs", {
  # Test non-numeric inputs
  expect_error(compute_dmi_by_feed("10", 0.5), "must be a single numeric value")
  expect_error(compute_dmi_by_feed(10, "0.5"), "must be a single numeric value")

  # Test vector inputs
  expect_error(compute_dmi_by_feed(c(10, 20), 0.5), "must be a single numeric value")
  expect_error(compute_dmi_by_feed(10, c(0.5, 0.3)), "must be a single numeric value")

  # Test invalid feed share values
  expect_error(compute_dmi_by_feed(10, -0.1), "must be between 0 and 1")
  expect_error(compute_dmi_by_feed(10, 1.1), "must be between 0 and 1")

  # Test negative DMI
  expect_error(compute_dmi_by_feed(-10, 0.5), "must be non-negative")
})

# ---- test compute_feed_emissions ----
test_that("compute_feed_emissions calculates correctly", {
  expect_equal(compute_feed_emissions(dmi_byfeed = 5, emission_factor = 0.1), 0.5)
  expect_equal(compute_feed_emissions(dmi_byfeed = 0, emission_factor = 0.1), 0)
  expect_equal(compute_feed_emissions(dmi_byfeed = 5, emission_factor = 0), 0)
  expect_equal(compute_feed_emissions(dmi_byfeed = NA, emission_factor = 0.1), 0)
  expect_equal(compute_feed_emissions(dmi_byfeed = 5, emission_factor = NA), 0)
})

test_that("compute_feed_emissions handles edge cases", {
  # Test with very small values
  expect_equal(compute_feed_emissions(dmi_byfeed = 0.001, emission_factor = 0.1), 0.0001)

  # Test with zero values
  expect_equal(compute_feed_emissions(dmi_byfeed = 0, emission_factor = 0.1), 0)
  expect_equal(compute_feed_emissions(dmi_byfeed = 5, emission_factor = 0), 0)

  # Test with high values
  expect_equal(compute_feed_emissions(dmi_byfeed = 100, emission_factor = 0.5), 50)
})

test_that("compute_feed_emissions validates inputs", {
  # Test non-numeric inputs
  expect_error(compute_feed_emissions(dmi_byfeed = "5", emission_factor = 0.1), "must be a single numeric value")
  expect_error(compute_feed_emissions(dmi_byfeed = 5, emission_factor = "0.1"), "must be a single numeric value")

  # Test vector inputs
  expect_error(compute_feed_emissions(dmi_byfeed = c(5, 10), emission_factor = 0.1), "must be a single numeric value")
  expect_error(compute_feed_emissions(dmi_byfeed = 5, emission_factor = c(0.1, 0.2)), "must be a single numeric value")

  # Test negative values
  expect_error(compute_feed_emissions(dmi_byfeed = -5, emission_factor = 0.1), "must be non-negative")
  expect_error(compute_feed_emissions(dmi_byfeed = 5, emission_factor = -0.1), "must be non-negative")
})
