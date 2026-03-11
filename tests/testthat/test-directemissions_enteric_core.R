cohorts_small <- c("FJ", "FS", "FA", "MJ", "MS", "MA")

# ---- test calc_conversion_factor_ym ----
test_that("calc_conversion_factor_ym validates inputs and computes YM", {
  # Valid cattle case
  ch4_ym <- calc_conversion_factor_ym("CTL", "FA", 0.6)
  expect_type(ch4_ym, "double")
  expect_gt(ch4_ym, 0)

  # Digestibility bounds
  expect_error(calc_conversion_factor_ym("CTL", "FA", -0.1))
  expect_error(calc_conversion_factor_ym("CTL", "FA", 1.1))

  # Boundary values for digestibility
  expect_equal(calc_conversion_factor_ym("CTL", "FA", 0), 9.75)
  expect_equal(calc_conversion_factor_ym("CTL", "FA", 1), 4.75)

  # Pigs: adult vs juvenile
  expect_equal(calc_conversion_factor_ym("PGS", "FA", 0.65), 1.01)
  expect_equal(calc_conversion_factor_ym("PGS", "FJ", 0.65), 0)

  # Small ruminants/camels: juvenile/subadult vs adult
  ym_juv <- calc_conversion_factor_ym("SHP", "FJ", 0)
  ym_adult <- calc_conversion_factor_ym("SHP", "FA", 0.65) # 9.75 rule
  expect_lt(ym_juv, ym_adult)

  # Buffalo: same formula as cattle
  expect_equal(
    calc_conversion_factor_ym("BFL", "FA", 0.6),
    calc_conversion_factor_ym("CTL", "FA", 0.6)
  )

  # Invalid species should error
  expect_error(calc_conversion_factor_ym("XXX", "FA", 0.65))
})

# ---- test calc_ch4_enteric ----
test_that("calc_ch4_enteric validates inputs and returns expected numeric", {
  # Valid cattle case with consistent YM
  ch4_ym <- calc_conversion_factor_ym("CTL", "FA", 0.6)
  ch4 <- calc_ch4_enteric(
    species_short = "CTL",
    ch4_conversion_factor_ym = ch4_ym,
    ch4_mitigation_factor = 1,
    diet_gross_energy = 18.4,
    dry_matter_intake = 10
  )
  expect_type(ch4, "double")
  expect_true(ch4 > 0)

  # Zero inputs give zero emissions
  expect_equal(
    calc_ch4_enteric("CTL", 0, 1, 18, 10), 0
  )
  expect_equal(
    calc_ch4_enteric("CTL", 5, 1, 18, 0), 0
  )

  # Invalid arguments
  expect_error(calc_ch4_enteric("CTL", -1, 1, 18, 10))  # ym < 0
  expect_error(calc_ch4_enteric("CTL", 5, 1, -1, 10))   # diet_gross_energy < 0
  expect_error(calc_ch4_enteric("CTL", 5, 1, 18, -1))  # dry_matter_intake < 0

  # Emissions must be non-negative
  expect_gte(ch4, 0)
})
