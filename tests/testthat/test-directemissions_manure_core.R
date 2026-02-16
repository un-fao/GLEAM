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

# ---- test calc_volatile_solids edge cases ----
test_that("calc_volatile_solids validates inputs", {
  expect_error(calc_volatile_solids(-1, 0.6, 0.04, 0.08))
  expect_error(calc_volatile_solids(1, -0.1, 0.04, 0.08))
  expect_error(calc_volatile_solids(1, 1.1, 0.04, 0.08))
  expect_error(calc_volatile_solids(1, 0.6, -0.01, 0.08))
  expect_error(calc_volatile_solids(1, 0.6, 1.1, 0.08))
  expect_error(calc_volatile_solids(1, 0.6, 0.04, -0.01))
  expect_error(calc_volatile_solids(1, 0.6, 0.04, 1.1))
})

# ---- test calc_ch4_emissions ----
test_that("calc_ch4_emissions computes methane by MMS group", {
  volatile_solids <- 2
  ratio <- 0.67
  mms_burned <- c(
    manure_management_system_fraction = 0.2,
    methane_conversion_factor_mcf = 10,
    ch4_max_producing_capacity_bo = 0.13
  )
  mms_pasture <- c(
    manure_management_system_fraction = 0.3,
    methane_conversion_factor_mcf = 0.47,
    ch4_max_producing_capacity_bo = 0.19
  )
  mms_drylot <- c(
    manure_management_system_fraction = 0.5,
    methane_conversion_factor_mcf = 2,
    ch4_max_producing_capacity_bo = 0.13
  )

  result <- calc_ch4_emissions(
    ratio_m3CH4_to_kgCH4 = ratio,
    volatile_solids = volatile_solids,
    mms_burned = mms_burned,
    mms_pasture = mms_pasture,
    mms_drylot = mms_drylot
  )

  expected_pasture <- volatile_solids * ratio * 0.3 * (0.47 / 100) * 0.19
  expected_burned <- volatile_solids * ratio * 0.2 * (10 / 100) * 0.13
  expected_other <- volatile_solids * ratio * sum(0.5 * 2 * 0.13) / 100

  expect_equal(result$ch4_manure_pasture, expected_pasture)
  expect_equal(result$ch4_manure_burned, expected_burned)
  expect_equal(result$ch4_manure_other, expected_other)
  expect_equal(result$ch4_manure_all_noburn, expected_pasture + expected_other)
})

test_that("calc_ch4_emissions errors when MMS fractions do not sum to 1", {
  expect_error(
    calc_ch4_emissions(
      volatile_solids = 1,
      mms_pasture = c(
        manure_management_system_fraction = 0.6,
        methane_conversion_factor_mcf = 2,
        ch4_max_producing_capacity_bo = 0.13
      ),
      mms_solid = c(
        manure_management_system_fraction = 0.2,
        methane_conversion_factor_mcf = 5,
        ch4_max_producing_capacity_bo = 0.13
      )
    )
  )
})

# ---- test calc_ch4_emissions edge cases ----
test_that("calc_ch4_emissions validates MMS inputs", {
  expect_error(calc_ch4_emissions(volatile_solids = 1, mms_pasture = c(
    manure_management_system_fraction = 1.2,
    methane_conversion_factor_mcf = 2,
    ch4_max_producing_capacity_bo = 0.13
  )))
  expect_error(calc_ch4_emissions(volatile_solids = 1, mms_pasture = c(
    manure_management_system_fraction = 1,
    methane_conversion_factor_mcf = 120,
    ch4_max_producing_capacity_bo = 0.13
  )))
  expect_error(calc_ch4_emissions(volatile_solids = 1, mms_pasture = c(
    manure_management_system_fraction = 1, methane_conversion_factor_mcf = 2
  )))
})

# ---- test calc_direct_n2o_emissions ----
test_that("calc_direct_n2o_emissions computes direct N2O by MMS group", {
  n_excretion <- 0.9
  mms_burned <- c(manure_management_system_fraction = 0.2, n2o_ef3 = 0)
  mms_pasture <- c(manure_management_system_fraction = 0.3, n2o_ef3 = 0.02)
  mms_drylot <- c(manure_management_system_fraction = 0.5, n2o_ef3 = 0.01)

  result <- calc_direct_n2o_emissions(
    nitrogen_excretion = n_excretion,
    mms_burned = mms_burned,
    mms_pasture = mms_pasture,
    mms_drylot = mms_drylot
  )

  expected_pasture <- n_excretion * (44 / 28) * 0.3 * 0.02
  expected_burned <- n_excretion * (44 / 28) * 0.2 * 0
  expected_other <- n_excretion * (44 / 28) * sum(0.5 * 0.01)

  expect_equal(result$n2o_manure_pasture_direct, expected_pasture)
  expect_equal(result$n2o_manure_burned_direct, expected_burned)
  expect_equal(result$n2o_manure_other_direct, expected_other)
  expect_equal(result$n2o_manure_all_noburn_direct, expected_pasture + expected_other)
})

# ---- test calc_direct_n2o_emissions edge cases ----
test_that("calc_direct_n2o_emissions validates MMS inputs", {
  expect_error(calc_direct_n2o_emissions(nitrogen_excretion = 0.9, mms_pasture = c(
    manure_management_system_fraction = 1.1, n2o_ef3 = 0.02
  )))
  expect_error(calc_direct_n2o_emissions(nitrogen_excretion = 0.9, mms_pasture = c(
    manure_management_system_fraction = 1, n2o_ef3 = -0.01
  )))
})

# ---- test calc_n2o_from_volatilization ----
test_that("calc_n2o_from_volatilization computes indirect N2O by MMS group", {
  n_excretion <- 0.9
  mms_burned <- c(manure_management_system_fraction = 0.2,
                  n2o_ef4 = 0.14, nitrogen_fracgas = 0)
  mms_pasture <- c(manure_management_system_fraction = 0.3,
                   n2o_ef4 = 0.14, nitrogen_fracgas = 0.21)
  mms_drylot <- c(manure_management_system_fraction = 0.5,
                  n2o_ef4 = 0.14, nitrogen_fracgas = 0.3)

  result <- calc_n2o_from_volatilization(
    nitrogen_excretion = n_excretion,
    mms_burned = mms_burned,
    mms_pasture = mms_pasture,
    mms_drylot = mms_drylot
  )

  expected_pasture <- n_excretion * (44 / 28) * 0.3 * 0.21 * 0.14
  expected_burned <- n_excretion * (44 / 28) * 0.2 * 0 * 0.14
  expected_other <- n_excretion * (44 / 28) * sum(0.5 * 0.3 * 0.14)

  expect_equal(result$n2o_vol_manure_pasture, expected_pasture)
  expect_equal(result$n2o_vol_manure_burned, expected_burned)
  expect_equal(result$n2o_vol_manure_other, expected_other)
  expect_equal(result$n2o_vol_manure_all_noburn, expected_pasture + expected_other)
})

# ---- test calc_n2o_from_volatilization edge cases ----
test_that("calc_n2o_from_volatilization validates MMS inputs", {
  expect_error(calc_n2o_from_volatilization(nitrogen_excretion = 0.9, mms_pasture = c(
    manure_management_system_fraction = 1.1, n2o_ef4 = 0.14, nitrogen_fracgas = 0.21
  )))
  expect_error(calc_n2o_from_volatilization(nitrogen_excretion = 0.9, mms_pasture = c(
    manure_management_system_fraction = 1, n2o_ef4 = -0.01, nitrogen_fracgas = 0.21
  )))
  expect_error(calc_n2o_from_volatilization(nitrogen_excretion = 0.9, mms_pasture = c(
    manure_management_system_fraction = 1, n2o_ef4 = 0.14, nitrogen_fracgas = 1.2
  )))
})

# ---- test calc_n2o_from_leaching ----
test_that("calc_n2o_from_leaching computes indirect N2O by MMS group", {
  n_excretion <- 0.9
  mms_burned <- c(manure_management_system_fraction = 0.2,
                  n2o_ef5 = 0.011, nitrogen_fracleach = 0)
  mms_pasture <- c(manure_management_system_fraction = 0.3,
                   n2o_ef5 = 0.011, nitrogen_fracleach = 0.24)
  mms_drylot <- c(manure_management_system_fraction = 0.5,
                  n2o_ef5 = 0.011, nitrogen_fracleach = 0.035)

  result <- calc_n2o_from_leaching(
    nitrogen_excretion = n_excretion,
    mms_burned = mms_burned,
    mms_pasture = mms_pasture,
    mms_drylot = mms_drylot
  )

  expected_pasture <- n_excretion * (44 / 28) * 0.3 * 0.24 * 0.011
  expected_burned <- n_excretion * (44 / 28) * 0.2 * 0 * 0.011
  expected_other <- n_excretion * (44 / 28) * sum(0.5 * 0.035 * 0.011)

  expect_equal(result$n2o_leach_manure_pasture, expected_pasture)
  expect_equal(result$n2o_leach_manure_burned, expected_burned)
  expect_equal(result$n2o_leach_manure_other, expected_other)
  expect_equal(result$n2o_leach_manure_all_noburn, expected_pasture + expected_other)
})

# ---- test calc_n2o_from_leaching edge cases ----
test_that("calc_n2o_from_leaching validates MMS inputs", {
  expect_error(calc_n2o_from_leaching(nitrogen_excretion = 0.9, mms_pasture = c(
    manure_management_system_fraction = 1.1, n2o_ef5 = 0.011, nitrogen_fracleach = 0.24
  )))
  expect_error(calc_n2o_from_leaching(nitrogen_excretion = 0.9, mms_pasture = c(
    manure_management_system_fraction = 1, n2o_ef5 = -0.01, nitrogen_fracleach = 0.24
  )))
  expect_error(calc_n2o_from_leaching(nitrogen_excretion = 0.9, mms_pasture = c(
    manure_management_system_fraction = 1, n2o_ef5 = 0.011, nitrogen_fracleach = 1.2
  )))
})

# ---- test calc_total_n2o_emissions ----
test_that("calc_total_n2o_emissions aggregates direct and indirect N2O", {
  result <- calc_total_n2o_emissions(
    n2o_vol_manure_pasture = 0.0129,
    n2o_leach_manure_pasture = 0.0012,
    n2o_vol_manure_burned = 0,
    n2o_leach_manure_burned = 0,
    n2o_vol_manure_other = 0.052,
    n2o_leach_manure_other = 0.00027,
    n2o_manure_pasture_direct = 0.009,
    n2o_manure_burned_direct = 0,
    n2o_manure_other_direct = 0.01033
  )

  expect_equal(result$n2o_manure_pasture_indirect, 0.0129 + 0.0012)
  expect_equal(result$n2o_manure_burned_indirect, 0)
  expect_equal(result$n2o_manure_other_indirect, 0.052 + 0.00027)
  expect_equal(result$n2o_manure_pasture_total, 0.0129 + 0.0012 + 0.009)
  expect_equal(result$n2o_manure_burned_total, 0)
  expect_equal(result$n2o_manure_other_total, 0.052 + 0.00027 + 0.01033)
})

# ---- test calc_total_n2o_emissions edge cases ----
test_that("calc_total_n2o_emissions validates scalar numeric inputs", {
  expect_error(calc_total_n2o_emissions(
    n2o_vol_manure_pasture = "0.01",
    n2o_leach_manure_pasture = 0.0012,
    n2o_vol_manure_burned = 0,
    n2o_leach_manure_burned = 0,
    n2o_vol_manure_other = 0.052,
    n2o_leach_manure_other = 0.00027,
    n2o_manure_pasture_direct = 0.009,
    n2o_manure_burned_direct = 0,
    n2o_manure_other_direct = 0.01033
  ))
})
