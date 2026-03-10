# ---- test calc_totals_by_cohort ----

test_that("calc_totals_by_cohort returns correct value for Production variables", {
  result <- calc_totals_by_cohort(
    value = 1000,
    cohort_stock_size = 50,
    simulation_duration = 365,
    variable_type = "Production"
  )

  expect_type(result, "double")
  expect_length(result, 1)
  # Production variables are returned as-is (not scaled)
  expect_equal(result, 1000)
})

test_that("calc_totals_by_cohort returns correct value for Emissions variables", {
  result <- calc_totals_by_cohort(
    value = 0.5,  # kg CH4/head/day
    cohort_stock_size = 100,   # 100 heads
    simulation_duration = 365,  # 365 days
    variable_type = "Emissions"
  )

  expect_type(result, "double")
  expect_length(result, 1)
  # Emissions: value * cohort_stock_size * simulation_duration
  expect_equal(result, 0.5 * 100 * 365)
})

test_that("calc_totals_by_cohort returns correct value for Feed variables", {
  result <- calc_totals_by_cohort(
    value = 10,  # kg DMI/head/day
    cohort_stock_size = 30,
    simulation_duration = 365,
    variable_type = "Feed"
  )

  expect_equal(result, 10 * 30 * 365)
})

test_that("calc_totals_by_cohort returns correct value for NitrogenBalance variables", {
  result <- calc_totals_by_cohort(
    value = 0.2,  # kg N/head/day
    cohort_stock_size = 25,
    simulation_duration = 365,
    variable_type = "NitrogenBalance"
  )

  expect_equal(result, 0.2 * 25 * 365)
})

test_that("calc_totals_by_cohort handles vectorized inputs", {
  result <- calc_totals_by_cohort(
    value = c(1000, 0.5, 10),
    cohort_stock_size = c(50, 100, 30),
    simulation_duration = c(365, 365, 365),
    variable_type = c("Production", "Emissions", "Feed")
  )

  expect_type(result, "double")
  expect_length(result, 3)
  expect_equal(result[1], 1000)  # Production: as-is
  expect_equal(result[2], 0.5 * 100 * 365)  # Emissions: scaled
  expect_equal(result[3], 10 * 30 * 365)  # Feed: scaled
})

test_that("calc_totals_by_cohort validates input lengths", {
  expect_error(
    calc_totals_by_cohort(
      value = c(100, 200),
      cohort_stock_size = c(50, 100, 150),
      simulation_duration = 365,
      variable_type = "Production"
    ),
    "must have the same length"
  )
})

test_that("calc_totals_by_cohort validates variable_type", {
  expect_error(
    calc_totals_by_cohort(
      value = 100,
      cohort_stock_size = 50,
      simulation_duration = 365,
      variable_type = "Invalid"
    ),
    "must be one of"
  )
})

test_that("calc_totals_by_cohort validates bounds", {
  expect_error(
    calc_totals_by_cohort(
      value = -10,
      cohort_stock_size = 50,
      simulation_duration = 365,
      variable_type = "Emissions"
    ),
    "must be non-negative"
  )
  expect_error(
    calc_totals_by_cohort(
      value = 100,
      cohort_stock_size = 0,
      simulation_duration = 365,
      variable_type = "Emissions"
    ),
    "must be positive"
  )
  expect_error(
    calc_totals_by_cohort(
      value = 100,
      cohort_stock_size = 50,
      simulation_duration = -10,
      variable_type = "Emissions"
    ),
    "must be positive"
  )
})

# ---- test calc_allocated_emissions ----

test_that("calc_allocated_emissions returns correct value for valid inputs", {
  result <- calc_allocated_emissions(
    value = 1000,  # kg CH4
    allocation_share = 0.6  # 60% to meat
  )

  expect_type(result, "double")
  expect_length(result, 1)
  expect_equal(result, 1000 * 0.6)
})

test_that("calc_allocated_emissions handles zero allocation", {
  result <- calc_allocated_emissions(
    value = 1000,
    allocation_share = 0
  )

  expect_equal(result, 0)
})

test_that("calc_allocated_emissions handles full allocation", {
  result <- calc_allocated_emissions(
    value = 1000,
    allocation_share = 1
  )

  expect_equal(result, 1000)
})

test_that("calc_allocated_emissions handles vectorized inputs", {
  result <- calc_allocated_emissions(
    value = c(1000, 500, 200),
    allocation_share = c(0.6, 0.4, 0.8)
  )

  expect_type(result, "double")
  expect_length(result, 3)
  expect_equal(result, c(1000 * 0.6, 500 * 0.4, 200 * 0.8))
})

test_that("calc_allocated_emissions validates input lengths", {
  expect_error(
    calc_allocated_emissions(
      value = c(100, 200),
      allocation_share = c(0.5, 0.6, 0.7)
    ),
    "must have the same length"
  )
})

test_that("calc_allocated_emissions validates bounds", {
  expect_error(
    calc_allocated_emissions(
      value = -100,
      allocation_share = 0.5
    ),
    "must be non-negative"
  )
  expect_error(
    calc_allocated_emissions(
      value = 100,
      allocation_share = -0.1
    ),
    "must be between 0 and 1"
  )
  expect_error(
    calc_allocated_emissions(
      value = 100,
      allocation_share = 1.5
    ),
    "must be between 0 and 1"
  )
})

# ---- test calc_co2eq ----

test_that("calc_co2eq returns correct value for CH4 with AR6", {
  result <- calc_co2eq(
    gas = "CH4",
    value_allocated = 100,  # kg CH4
    gwp = "AR6"
  )

  expect_type(result, "list")
  expect_named(result, c("value_co2e", "gwp"))
  expect_equal(result$value_co2e, 100 * 27)  # AR6: CH4 = 27
  expect_equal(result$gwp, 27)
})

test_that("calc_co2eq returns correct value for N2O with AR6", {
  result <- calc_co2eq(
    gas = "N2O",
    value_allocated = 10,  # kg N2O
    gwp = "AR6"
  )

  expect_equal(result$value_co2e, 10 * 273)  # AR6: N2O = 273
  expect_equal(result$gwp, 273)
})

test_that("calc_co2eq returns correct value for CO2", {
  result <- calc_co2eq(
    gas = "CO2",
    value_allocated = 1000,  # kg CO2
    gwp = "AR6"
  )

  expect_equal(result$value_co2e, 1000 * 1)  # CO2 always = 1
  expect_equal(result$gwp, 1)
})

test_that("calc_co2eq handles AR5_excluding_carbon_feedback", {
  result_ch4 <- calc_co2eq(
    gas = "CH4",
    value_allocated = 100,
    gwp = "AR5_excluding_carbon_feedback"
  )
  expect_equal(result_ch4$value_co2e, 100 * 28)
  expect_equal(result_ch4$gwp, 28)

  result_n2o <- calc_co2eq(
    gas = "N2O",
    value_allocated = 10,
    gwp = "AR5_excluding_carbon_feedback"
  )
  expect_equal(result_n2o$value_co2e, 10 * 265)
  expect_equal(result_n2o$gwp, 265)
})

test_that("calc_co2eq handles AR5_including_carbon_feedback", {
  result_ch4 <- calc_co2eq(
    gas = "CH4",
    value_allocated = 100,
    gwp = "AR5_including_carbon_feedback"
  )
  expect_equal(result_ch4$value_co2e, 100 * 34)
  expect_equal(result_ch4$gwp, 34)

  result_n2o <- calc_co2eq(
    gas = "N2O",
    value_allocated = 10,
    gwp = "AR5_including_carbon_feedback"
  )
  expect_equal(result_n2o$value_co2e, 10 * 298)
  expect_equal(result_n2o$gwp, 298)
})

test_that("calc_co2eq handles AR4", {
  result_ch4 <- calc_co2eq(
    gas = "CH4",
    value_allocated = 100,
    gwp = "AR4"
  )
  expect_equal(result_ch4$value_co2e, 100 * 25)
  expect_equal(result_ch4$gwp, 25)

  result_n2o <- calc_co2eq(
    gas = "N2O",
    value_allocated = 10,
    gwp = "AR4"
  )
  expect_equal(result_n2o$value_co2e, 10 * 298)
  expect_equal(result_n2o$gwp, 298)
})

test_that("calc_co2eq handles vectorized inputs", {
  result <- calc_co2eq(
    gas = c("CH4", "N2O", "CO2"),
    value_allocated = c(100, 10, 1000),
    gwp = "AR6"
  )

  expect_type(result, "list")
  expect_length(result$value_co2e, 3)
  expect_length(result$gwp, 3)
  expect_equal(result$value_co2e, c(100 * 27, 10 * 273, 1000 * 1))
  expect_equal(result$gwp, c(27, 273, 1))
})

test_that("calc_co2eq handles zero emissions", {
  result <- calc_co2eq(
    gas = "CH4",
    value_allocated = 0,
    gwp = "AR6"
  )

  expect_equal(result$value_co2e, 0)
  expect_equal(result$gwp, 27)
})

test_that("calc_co2eq validates GWP version", {
  expect_error(
    calc_co2eq(
      gas = "CH4",
      value_allocated = 100,
      gwp = "INVALID"
    ),
    "must be one of"
  )
})

test_that("calc_co2eq validates input lengths", {
  expect_error(
    calc_co2eq(
      gas = c("CH4", "N2O"),
      value_allocated = c(100, 10, 50),
      gwp = "AR6"
    ),
    "must have the same length"
  )
})

test_that("calc_co2eq validates gas types", {
  expect_error(
    calc_co2eq(
      gas = "INVALID",
      value_allocated = 100,
      gwp = "AR6"
    ),
    "must be one of"
  )
})

test_that("calc_co2eq validates value_allocated bounds", {
  expect_error(
    calc_co2eq(
      gas = "CH4",
      value_allocated = -10,
      gwp = "AR6"
    ),
    "must be non-negative"
  )
})
