# ---- test calc_cohort_totals ----
# Feed emissions use ration_intake in scaling; pass empty list when not testing feed emissions
feed_emissions_empty <- list()

test_that("calc_cohort_totals returns correct value for Production variables", {
  result <- calc_cohort_totals(
    value = 1000,
    cohort_stock_size = 50,
    ration_intake = 10,
    feed_emissions_list = feed_emissions_empty,
    simulation_duration = 365,
    variable_name = "milk_production_mass_cohort",
    variable_type = "Production"
  )

  expect_type(result, "double")
  expect_length(result, 1)
  # Production variables are returned as-is (not scaled)
  expect_equal(result, 1000)
})

test_that("calc_cohort_totals returns correct value for Emissions variables", {
  result <- calc_cohort_totals(
    value = 0.5,  # kg CH4/head/day
    cohort_stock_size = 100,   # 100 heads
    ration_intake = 5,
    feed_emissions_list = feed_emissions_empty,
    simulation_duration = 365,  # 365 days
    variable_name = "ch4_enteric",
    variable_type = "Emissions"
  )

  expect_type(result, "double")
  expect_length(result, 1)
  # Non-feed emissions: value * cohort_stock_size * simulation_duration
  expect_equal(result, 0.5 * 100 * 365)
})

test_that("calc_cohort_totals returns correct value for Feed emissions (ration_intake scaling)", {
  feed_emissions <- list(
    list(emissions_source = "co2_ration_fertilizer", label = "Feed-Fertilizer_CO2")
  )
  result <- calc_cohort_totals(
    value = 0.1,  # g/100kg DMI
    cohort_stock_size = 100,
    ration_intake = 10,  # kg DM/head/day
    feed_emissions_list = feed_emissions,
    simulation_duration = 365,
    variable_name = "co2_ration_fertilizer",
    variable_type = "Emissions"
  )
  # Feed emissions: value * ration_intake * cohort_stock_size * simulation_duration / 1000
  expect_equal(result, 0.1 * 10 * 100 * 365 / 1000)
})

test_that("calc_cohort_totals returns correct value for Feed variables", {
  result <- calc_cohort_totals(
    value = 10,  # kg DMI/head/day
    cohort_stock_size = 30,
    ration_intake = 10,
    feed_emissions_list = feed_emissions_empty,
    simulation_duration = 365,
    variable_name = "ration_intake",
    variable_type = "Feed"
  )

  expect_equal(result, 10 * 30 * 365)
})

test_that("calc_cohort_totals returns correct value for NitrogenBalance variables", {
  result <- calc_cohort_totals(
    value = 0.2,  # kg N/head/day
    cohort_stock_size = 25,
    ration_intake = 8,
    feed_emissions_list = feed_emissions_empty,
    simulation_duration = 365,
    variable_name = "nitrogen_intake",
    variable_type = "NitrogenBalance"
  )

  expect_equal(result, 0.2 * 25 * 365)
})

test_that("calc_cohort_totals validates variable_type", {
  expect_error(
    calc_cohort_totals(
      value = 100,
      cohort_stock_size = 50,
      ration_intake = 10,
      feed_emissions_list = feed_emissions_empty,
      simulation_duration = 365,
      variable_name = "x",
      variable_type = "Invalid"
    ),
    "must be one of"
  )
})

test_that("calc_cohort_totals validates bounds", {
  expect_error(
    calc_cohort_totals(
      value = 100,
      cohort_stock_size = 0,
      ration_intake = 10,
      feed_emissions_list = feed_emissions_empty,
      simulation_duration = 365,
      variable_name = "ch4_enteric",
      variable_type = "Emissions"
    ),
    "must be positive"
  )
  expect_error(
    calc_cohort_totals(
      value = 100,
      cohort_stock_size = 50,
      ration_intake = 10,
      feed_emissions_list = feed_emissions_empty,
      simulation_duration = -10,
      variable_name = "ch4_enteric",
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
    global_warming_potential_set = "AR6"
  )

  expect_type(result, "list")
  expect_named(result, c("value_co2eq", "gwp"))
  expect_equal(result$value_co2eq, 100 * 27)  # AR6: CH4 = 27
  expect_equal(result$gwp, 27)
})

test_that("calc_co2eq returns correct value for N2O with AR6", {
  result <- calc_co2eq(
    gas = "N2O",
    value_allocated = 10,  # kg N2O
    global_warming_potential_set = "AR6"
  )

  expect_equal(result$value_co2eq, 10 * 273)  # AR6: N2O = 273
  expect_equal(result$gwp, 273)
})

test_that("calc_co2eq returns correct value for CO2", {
  result <- calc_co2eq(
    gas = "CO2",
    value_allocated = 1000,  # kg CO2
    global_warming_potential_set = "AR6"
  )

  expect_equal(result$value_co2eq, 1000 * 1)  # CO2 always = 1
  expect_equal(result$gwp, 1)
})

test_that("calc_co2eq handles AR5_excluding_carbon_feedback", {
  result_ch4 <- calc_co2eq(
    gas = "CH4",
    value_allocated = 100,
    global_warming_potential_set = "AR5_excluding_carbon_feedback"
  )
  expect_equal(result_ch4$value_co2eq, 100 * 28)
  expect_equal(result_ch4$gwp, 28)

  result_n2o <- calc_co2eq(
    gas = "N2O",
    value_allocated = 10,
    global_warming_potential_set = "AR5_excluding_carbon_feedback"
  )
  expect_equal(result_n2o$value_co2eq, 10 * 265)
  expect_equal(result_n2o$gwp, 265)
})

test_that("calc_co2eq handles AR5_including_carbon_feedback", {
  result_ch4 <- calc_co2eq(
    gas = "CH4",
    value_allocated = 100,
    global_warming_potential_set = "AR5_including_carbon_feedback"
  )
  expect_equal(result_ch4$value_co2eq, 100 * 34)
  expect_equal(result_ch4$gwp, 34)

  result_n2o <- calc_co2eq(
    gas = "N2O",
    value_allocated = 10,
    global_warming_potential_set = "AR5_including_carbon_feedback"
  )
  expect_equal(result_n2o$value_co2eq, 10 * 298)
  expect_equal(result_n2o$gwp, 298)
})

test_that("calc_co2eq handles AR4", {
  result_ch4 <- calc_co2eq(
    gas = "CH4",
    value_allocated = 100,
    global_warming_potential_set = "AR4"
  )
  expect_equal(result_ch4$value_co2eq, 100 * 25)
  expect_equal(result_ch4$gwp, 25)

  result_n2o <- calc_co2eq(
    gas = "N2O",
    value_allocated = 10,
    global_warming_potential_set = "AR4"
  )
  expect_equal(result_n2o$value_co2eq, 10 * 298)
  expect_equal(result_n2o$gwp, 298)
})

test_that("calc_co2eq handles vectorized inputs", {
  result <- calc_co2eq(
    gas = c("CH4", "N2O", "CO2"),
    value_allocated = c(100, 10, 1000),
    global_warming_potential_set = "AR6"
  )

  expect_type(result, "list")
  expect_length(result$value_co2eq, 3)
  expect_length(result$gwp, 3)
  expect_equal(result$value_co2eq, c(100 * 27, 10 * 273, 1000 * 1))
  expect_equal(result$gwp, c(27, 273, 1))
})

test_that("calc_co2eq handles zero emissions", {
  result <- calc_co2eq(
    gas = "CH4",
    value_allocated = 0,
    global_warming_potential_set = "AR6"
  )

  expect_equal(result$value_co2eq, 0)
  expect_equal(result$gwp, 27)
})

test_that("calc_co2eq validates GWP version", {
  expect_error(
    calc_co2eq(
      gas = "CH4",
      value_allocated = 100,
      global_warming_potential_set = "INVALID"
    ),
    "must be one of"
  )
})

test_that("calc_co2eq validates input lengths", {
  expect_error(
    calc_co2eq(
      gas = c("CH4", "N2O"),
      value_allocated = c(100, 10, 50),
      global_warming_potential_set = "AR6"
    ),
    "must have the same length"
  )
})

test_that("calc_co2eq validates gas types", {
  expect_error(
    calc_co2eq(
      gas = "INVALID",
      value_allocated = 100,
      global_warming_potential_set = "AR6"
    ),
    "must be one of"
  )
})
