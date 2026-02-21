cohorts_small <- c("FJ", "FS", "FA", "MJ", "MS", "MA")

# ---- test compute_methane_conversion_factor ----
test_that("compute_methane_conversion_factor validates inputs and computes YM", {
  # Valid cattle case
  ch4_ym <- compute_methane_conversion_factor("CTL", "FA", 0.6)
  expect_type(ch4_ym, "double")
  expect_gt(ch4_ym, 0)

  # Digestibility bounds
  expect_error(compute_methane_conversion_factor("CTL", "FA", -0.1))
  expect_error(compute_methane_conversion_factor("CTL", "FA", 1.1))

  # Boundary values for digestibility
  expect_equal(compute_methane_conversion_factor("CTL", "FA", 0), 9.75)
  expect_equal(compute_methane_conversion_factor("CTL", "FA", 1), 4.75)

  # Pigs: adult vs juvenile
  expect_equal(compute_methane_conversion_factor("PGS", "FA", 0.65), 1.01)
  expect_equal(compute_methane_conversion_factor("PGS", "FJ", 0.65), 0)

  # Small ruminants/camels: juvenile/subadult vs adult
  ym_juv <- compute_methane_conversion_factor("SHP", "FJ", 0)
  ym_adult <- compute_methane_conversion_factor("SHP", "FA", 0.65) # 9.75 rule
  expect_lt(ym_juv, ym_adult)

  # Buffalo: same formula as cattle
  expect_equal(
    compute_methane_conversion_factor("BFL", "FA", 0.6),
    compute_methane_conversion_factor("CTL", "FA", 0.6)
  )

  # Chickens: always NA
  expect_true(is.na(compute_methane_conversion_factor("CHK", "FA", 0.65)))

  # Invalid species should error
  expect_error(compute_methane_conversion_factor("XXX", "FA", 0.65))
})

# ---- test compute_daily_enteric_emissions ----
test_that("compute_daily_enteric_emissions validates inputs and returns expected numeric", {
  # Valid cattle case with consistent YM
  ch4_ym <- compute_methane_conversion_factor("CTL", "FA", 0.6)
  ch4 <- compute_daily_enteric_emissions(
    species_short = "CTL",
    ch4_conversion_factor_ym = ch4_ym,
    ch4_mitigation_factor = 1,
    diet_gross_energy = 18.4,
    dry_matter_intake = 10
  )
  expect_type(ch4, "double")
  expect_true(ch4 > 0)

  # Chickens: emissions NA
  ym_ch <- compute_methane_conversion_factor("CHK", "FA", 0.7)
  ch4_ch <- compute_daily_enteric_emissions(
    "CHK", ym_ch, 1, 16, 0.1
  )
  expect_true(is.na(ch4_ch))

  # Zero inputs give zero emissions
  expect_equal(
    compute_daily_enteric_emissions("CTL", 0, 1, 18, 10), 0
  )
  expect_equal(
    compute_daily_enteric_emissions("CTL", 5, 1, 18, 0), 0
  )

  # Invalid arguments
  expect_error(compute_daily_enteric_emissions("CTL", -1, 1, 18, 10))  # ym < 0
  expect_error(compute_daily_enteric_emissions("CTL", 5, 1, 0, 10))   # diet_gross_energy <= 0
  expect_error(compute_daily_enteric_emissions("CTL", 5, 1, 18, -1))  # dry_matter_intake < 0

  # Emissions must be non-negative
  expect_gte(ch4, 0)
})
