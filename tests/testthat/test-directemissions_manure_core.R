# ---- test calc_volatile_solids ----
test_that("calc_volatile_solids produces expected results for cattle", {
  result <- calc_volatile_solids(
    animal = "CTL",
    dmi = 5,
    diet_dig = 0.6,
    diet_me = 9,
    diet_ge = 18
  )
  expect_length(result, 1)
  expect_true(result >= 0)
  expect_equal(result, 5 * (1.04 - 0.6) * 0.92)
})

test_that("calc_volatile_solids handles PGS correctly", {
  result <- calc_volatile_solids(
    animal = "PGS",
    dmi = 4,
    diet_dig = 0.7,
    diet_me = 12,
    diet_ge = 20
  )
  expect_equal(result, 4 * (1.02 - 0.7) * 0.94)
})


# test_that("calc_volatile_solids handles CHK correctly", {
#   result <- calc_volatile_solids(
#     animal = "CHK",
#     dmi = 0.1,
#     diet_dig = 0.8,
#     diet_me = 12,
#     diet_ge = 18
#   )
#   expect_equal(result, 0.1 * (1 - 12/18) * 0.70)
# })
# 
# test_that("calc_volatile_solids handles CHK BRL correctly", {
#   result <- calc_volatile_solids(
#     animal = "CHK",
#     dmi = 0.1,
#     diet_dig = 0.8,
#     diet_me = 12,
#     diet_ge = 18,
#   )
#   expect_equal(result, 0.1 * (1 - 12/18) * 0.95)
# })
# 
# test_that("calc_volatile_solids handles CHK non-BRL correctly", {
#   result <- calc_volatile_solids(
#     animal = "CHK",
#     dmi = 0.1,
#     diet_dig = 0.8,
#     diet_me = 12,
#     diet_ge = 18,
#   )
#   expect_equal(result, 0.1 * (1 - 12/18) * 0.89)
# })

test_that("calc_volatile_solids handles validation errors", {
  expect_error(
    calc_volatile_solids("INVALID", 5, 0.6, 9, 18),
    "animal"
  )
  expect_error(
    calc_volatile_solids("CTL", -5, 0.6, 9, 18),
    "dmi"
  )
  expect_error(
    calc_volatile_solids("CTL", 5, 2, 9, 18),
    "diet_dig"
  )
})

# ---- test calc_methane_conversion_factor ----
test_that("calc_methane_conversion_factor produces expected results", {
  result <- calc_methane_conversion_factor(
    mms_pasture = 0.5,
    mms_burned = 0.2,
    mms_other = 0.3,
    ef_mcf_pasture = 30,
    ef_mcf_burned = 20,
    ef_mcf_other = 25
  )
  expect_named(result, c("mcf_pasture", "mcf_burned", "mcf_other"))
  expect_equal(result$mcf_pasture, 0.5 * 30 / 100)
  expect_equal(result$mcf_burned, 0.2 * 20 / 100)
  expect_equal(result$mcf_other, 0.3 * 25 / 100)
})

test_that("calc_methane_conversion_factor handles validation errors", {
  expect_error(
    calc_methane_conversion_factor(-0.5, 0.2, 0.3, 30, 20, 25),
    "mms_pasture"
  )
  expect_error(
    calc_methane_conversion_factor(0.5, 0.2, 0.3, 150, 20, 25),
    "ef_mcf_pasture"
  )
})


# ---- test calc_ch4_emissions ----
test_that("calc_ch4_emissions produces expected results", {
  result <- calc_ch4_emissions(
    vs = 10,
    mcf_pasture = 0.15,
    mcf_burned = 0.2,
    mcf_other = 0.18,
    b0_mms_all = 0.24,
    b0_mms_pasture = 0.22
  )
  expect_named(result, c("ch4_manure_pasture", "ch4_manure_burned", "ch4_manure_other", "ch4_manure_all_noburn"))
  expect_equal(result$ch4_manure_pasture, 10 * 0.67 * 0.15 * 0.22)
  expect_equal(result$ch4_manure_burned, 10 * 0.67 * 0.2 * 0.24)
  expect_equal(result$ch4_manure_other, 10 * 0.67 * 0.18 * 0.24)
  expect_equal(result$ch4_manure_all_noburn, result$ch4_manure_pasture + result$ch4_manure_other)
})

test_that("calc_ch4_emissions handles validation errors", {
  expect_error(
    calc_ch4_emissions(-10, 0.15, 0.2, 0.18, 0.24, 0.22),
    "vs"
  )
  expect_error(
    calc_ch4_emissions(10, 1.5, 0.2, 0.18, 0.24, 0.22),
    "mcf_pasture"
  )
})


# ---- test calc_direct_n2o_emissions ----
test_that("calc_direct_n2o_emissions produces expected results", {
  result <- calc_direct_n2o_emissions(
    n_excretion = 0.05,
    ef3_pasture = 0.001,
    ef3_burned = 0.002,
    ef3_other = 0.0015
  )
  expect_named(result, c("direct_n2o_manure_pasture", "direct_n2o_manure_burned", "direct_n2o_manure_other", "direct_n2o_manure_all_noburn"))
  ratio <- 44/28
  expect_equal(result$direct_n2o_manure_pasture, 0.05 * 0.001 * ratio)
  expect_equal(result$direct_n2o_manure_burned, 0.05 * 0.002 * ratio)
  expect_equal(result$direct_n2o_manure_other, 0.05 * 0.0015 * ratio)
  expect_equal(result$direct_n2o_manure_all_noburn, result$direct_n2o_manure_pasture + result$direct_n2o_manure_other)
})

test_that("calc_direct_n2o_emissions handles validation errors", {
  expect_error(
    calc_direct_n2o_emissions(-0.05, 0.001, 0.002, 0.0015),
    "n_excretion"
  )
  expect_error(
    calc_direct_n2o_emissions(0.05, -0.001, 0.002, 0.0015),
    "ef3_pasture"
  )
})


# ---- test calc_nitrogen_volatilization_fraction ----
test_that("calc_nitrogen_volatilization_fraction produces expected results", {
  result <- calc_nitrogen_volatilization_fraction(
    mms_pasture = 0.5,
    mms_burned = 0.2,
    mms_other = 0.3,
    ef_fracgas_pasture = 0.1,
    ef_fracgas_burned = 0.15,
    ef_fracgas_other = 0.12
  )
  expect_named(result, c("fracgas_pasture", "fracgas_burned", "fracgas_other"))
  expect_equal(result$fracgas_pasture, 0.5 * 0.1)
  expect_equal(result$fracgas_burned, 0.2 * 0.15)
  expect_equal(result$fracgas_other, 0.3 * 0.12)
})

test_that("calc_nitrogen_volatilization_fraction handles validation errors", {
  expect_error(
    calc_nitrogen_volatilization_fraction(-0.5, 0.2, 0.3, 0.1, 0.15, 0.12),
    "mms_pasture"
  )
})

# ---- test calc_nitrogen_volatilization ----
test_that("calc_nitrogen_volatilization produces expected results", {
  result <- calc_nitrogen_volatilization(
    n_excretion = 0.05,
    fracgas_pasture = 0.05,
    fracgas_burned = 0.03,
    fracgas_other = 0.036
  )
  expect_named(result, c("n_vol_manure_pasture", "n_vol_manure_burned", "n_vol_manure_other", "n_vol_manure_all_noburn"))
  expect_equal(result$n_vol_manure_pasture, 0.05 * 0.05)
  expect_equal(result$n_vol_manure_burned, 0.05 * 0.03)
  expect_equal(result$n_vol_manure_other, 0.05 * 0.036)
})

# ---- test calc_n2o_from_volatilization ----
test_that("calc_n2o_from_volatilization produces expected results", {
  result <- calc_n2o_from_volatilization(
    n_vol_pasture = 0.0025,
    n_vol_burned = 0.0015,
    n_vol_other = 0.0018,
    ef4 = 0.01
  )
  expect_named(result, c("n2o_vol_manure_pasture", "n2o_vol_manure_burned", "n2o_vol_manure_other", "n2o_vol_manure_all_noburn"))
  ratio <- 44/28
  expect_equal(result$n2o_vol_manure_pasture, 0.0025 * 0.01 * ratio)
})

# ---- test calc_nitrogen_leaching_fraction ----
test_that("calc_nitrogen_leaching_fraction produces expected results", {
  result <- calc_nitrogen_leaching_fraction(
    mms_pasture = 0.5,
    mms_burned = 0.2,
    mms_other = 0.3,
    ef_fracleach_pasture = 0.1,
    ef_fracleach_burned = 0.12,
    ef_fracleach_other = 0.11
  )
  expect_named(result, c("fracleach_pasture", "fracleach_burned", "fracleach_other"))
  expect_equal(result$fracleach_pasture, 0.5 * 0.1)
})

# ---- test calc_nitrogen_leaching ----
test_that("calc_nitrogen_leaching produces expected results", {
  result <- calc_nitrogen_leaching(
    n_excretion = 0.05,
    fracleach_pasture = 0.05,
    fracleach_burned = 0.024,
    fracleach_other = 0.033
  )
  expect_named(result, c("n_leach_manure_pasture", "n_leach_manure_burned", "n_leach_manure_other", "n_leach_manure_all_noburn"))
  expect_equal(result$n_leach_manure_pasture, 0.05 * 0.05)
})

# ---- test calc_n2o_from_leaching ----
test_that("calc_n2o_from_leaching produces expected results", {
  result <- calc_n2o_from_leaching(
    n_leach_pasture = 0.0025,
    n_leach_burned = 0.0012,
    n_leach_other = 0.00165,
    ef5 = 0.0075
  )
  expect_named(result, c("n2o_leach_manure_pasture", "n2o_leach_manure_burned", "n2o_leach_manure_other", "n2o_leach_manure_all_noburn"))
  ratio <- 44/28
  expect_equal(result$n2o_leach_manure_pasture, 0.0025 * 0.0075 * ratio)
})

# ---- test calc_total_n2o_emissions ----
test_that("calc_total_n2o_emissions produces expected results", {
  direct <- list(
    direct_n2o_manure_pasture = 0.001,
    direct_n2o_manure_burned = 0.0005,
    direct_n2o_manure_other = 0.0015
  )
  vol <- list(
    n2o_vol_manure_pasture = 0.002,
    n2o_vol_manure_burned = 0.001,
    n2o_vol_manure_other = 0.0025
  )
  leach <- list(
    n2o_leach_manure_pasture = 0.0005,
    n2o_leach_manure_burned = 0.0003,
    n2o_leach_manure_other = 0.0006
  )

  result <- calc_total_n2o_emissions(direct, vol, leach)
  expect_named(
    result, c("indirect_n2o_manure_pasture", "indirect_n2o_manure_burned", "indirect_n2o_manure_other",
              "total_n2o_manure_pasture", "total_n2o_manure_burned", "total_n2o_manure_other")
  )
  expect_equal(result$indirect_n2o_manure_pasture, 0.002 + 0.0005)
  expect_equal(result$total_n2o_manure_pasture, 0.001 + 0.002 + 0.0005)
})

test_that("calc_total_n2o_emissions handles validation errors", {
  expect_error(
    calc_total_n2o_emissions(list(), list(), list()),
    "direct"
  )
})
