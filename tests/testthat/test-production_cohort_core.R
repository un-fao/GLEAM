# ---- test calc_milk_production ----
test_that("calc_milk_production returns expected output structure", {
  result <- calc_milk_production(
    species_short = "CTL",
    cohort_short = "FA",
    milk_yield_day = 10,
    simulation_duration = 365,
    cohort_stock_size = 100,
    lactating_females_fraction = 0.8,
    milk_protein_fraction = 0.033,
    milk_fat_fraction = 0.04,
    milk_lactose_fraction = 0.048,
    milk_protein_fraction_standard = 0.033,
    milk_fat_fraction_standard = 0.04,
    milk_lactose_fraction_standard = 0.048
  )

  expect_type(result, "list")
  expect_named(result, c(
    "milk_production_mass_cohort",
    "milk_production_protein_cohort",
    "milk_production_fpcm_cohort"
  ))
})

test_that("calc_milk_production calculates milk mass production correctly", {
  result <- calc_milk_production(
    species_short = "BFL",
    cohort_short = "FA",
    milk_yield_day = 20,
    simulation_duration = 365,
    cohort_stock_size = 50,
    lactating_females_fraction = 0.75,
    milk_protein_fraction = 0.032,
    milk_fat_fraction = 0.038,
    milk_lactose_fraction = 0.047,
    milk_protein_fraction_standard = 0.033,
    milk_fat_fraction_standard = 0.04,
    milk_lactose_fraction_standard = 0.048
  )

  expected_mass <- 20 * 365 * 50 * 0.75
  expect_equal(result$milk_production_mass_cohort, expected_mass)
})

test_that("calc_milk_production calculates milk protein production correctly", {
  result <- calc_milk_production(
    species_short = "SHP",
    cohort_short = "FA",
    milk_yield_day = 15,
    simulation_duration = 365,
    cohort_stock_size = 80,
    lactating_females_fraction = 0.9,
    milk_protein_fraction = 0.035,
    milk_fat_fraction = 0.042,
    milk_lactose_fraction = 0.049,
    milk_protein_fraction_standard = 0.033,
    milk_fat_fraction_standard = 0.04,
    milk_lactose_fraction_standard = 0.048
  )

  expected_mass <- 15 * 365 * 80 * 0.9
  expected_protein <- expected_mass * 0.035
  expect_equal(result$milk_production_protein_cohort, expected_protein)
})

test_that("calc_milk_production calculates FPCM using energy ratio", {
  result <- calc_milk_production(
    species_short = "SHP",
    cohort_short = "FA",
    milk_yield_day = 12,
    simulation_duration = 365,
    cohort_stock_size = 60,
    lactating_females_fraction = 0.85,
    milk_protein_fraction = 0.033,
    milk_fat_fraction = 0.04,
    milk_lactose_fraction = 0.048,
    milk_protein_fraction_standard = 0.033,
    milk_fat_fraction_standard = 0.04,
    milk_lactose_fraction_standard = 0.048
  )

  # When milk composition equals standard, energy ratio should be 1 and FPCM equals milk production
  expected_mass <- 12 * 365 * 60 * 0.85
  expect_equal(result$milk_production_fpcm_cohort, expected_mass, tolerance = 1e-10)
})

test_that("calc_milk_production calculates FPCM correctly with different composition", {
  result <- calc_milk_production(
    species_short = "GTS",
    cohort_short = "FA",
    milk_yield_day = 12,
    simulation_duration = 365,
    cohort_stock_size = 60,
    lactating_females_fraction = 0.85,
    milk_protein_fraction = 0.034,
    milk_fat_fraction = 0.041,
    milk_lactose_fraction = 0.048,
    milk_protein_fraction_standard = 0.033,
    milk_fat_fraction_standard = 0.04,
    milk_lactose_fraction_standard = 0.048
  )

  # Calculate expected FPCM using energy ratio
  expected_mass <- 12 * 365 * 60 * 0.85
  energy_standard <- 0.0929 * 0.04 + 0.0547 * 0.033 + 0.0395 * 0.048
  energy_milk <- 0.0929 * 0.041 + 0.0547 * 0.034 + 0.0395 * 0.048
  energy_ratio <- energy_milk / energy_standard
  expected_fpcm <- energy_ratio * expected_mass

  expect_equal(result$milk_production_fpcm_cohort, expected_fpcm, tolerance = 1e-6)
})

test_that("calc_milk_production handles higher fat content correctly", {
  # Higher fat should result in higher FPCM (energy ratio > 1)
  standard_result <- calc_milk_production(
    species_short = "GTS",
    cohort_short = "FA",
    milk_yield_day = 10,
    simulation_duration = 365,
    cohort_stock_size = 100,
    lactating_females_fraction = 0.8,
    milk_protein_fraction = 0.033,
    milk_fat_fraction = 0.04,
    milk_lactose_fraction = 0.048,
    milk_protein_fraction_standard = 0.033,
    milk_fat_fraction_standard = 0.04,
    milk_lactose_fraction_standard = 0.048
  )

  high_fat_result <- calc_milk_production(
    species_short = "GTS",
    cohort_short = "FA",
    milk_yield_day = 10,
    simulation_duration = 365,
    cohort_stock_size = 100,
    lactating_females_fraction = 0.8,
    milk_protein_fraction = 0.033,
    milk_fat_fraction = 0.05,
    milk_lactose_fraction = 0.048,
    milk_protein_fraction_standard = 0.033,
    milk_fat_fraction_standard = 0.04,
    milk_lactose_fraction_standard = 0.048
  )

  expect_gt(high_fat_result$milk_production_fpcm_cohort, standard_result$milk_production_fpcm_cohort)
})

test_that("calc_milk_production handles zero size", {
  result <- calc_milk_production(
    species_short = "CTL",
    cohort_short = "FA",
    milk_yield_day = 10,
    simulation_duration = 365,
    cohort_stock_size = 0,
    lactating_females_fraction = 0.8,
    milk_protein_fraction = 0.033,
    milk_fat_fraction = 0.04,
    milk_lactose_fraction = 0.048,
    milk_protein_fraction_standard = 0.033,
    milk_fat_fraction_standard = 0.04,
    milk_lactose_fraction_standard = 0.048
  )

  expect_equal(result$milk_production_mass_cohort, 0)
  expect_equal(result$milk_production_protein_cohort, 0)
  expect_equal(result$milk_production_fpcm_cohort, 0)
})

test_that("calc_milk_production handles zero milking fraction", {
  result <- calc_milk_production(
    species_short = "CTL",
    cohort_short = "FA",
    milk_yield_day = 10,
    simulation_duration = 365,
    cohort_stock_size = 100,
    lactating_females_fraction = 0,
    milk_protein_fraction = 0.033,
    milk_fat_fraction = 0.04,
    milk_lactose_fraction = 0.048,
    milk_protein_fraction_standard = 0.033,
    milk_fat_fraction_standard = 0.04,
    milk_lactose_fraction_standard = 0.048
  )

  expect_equal(result$milk_production_mass_cohort, 0)
  expect_equal(result$milk_production_protein_cohort, 0)
  expect_equal(result$milk_production_fpcm_cohort, 0)
})

test_that("calc_milk_production handles validation errors", {
  expect_error(
    calc_milk_production(
      species_short = "CTL",
      cohort_short = "FA",
      milk_yield_day = -10, simulation_duration = 365, cohort_stock_size = 100,
      lactating_females_fraction = 0.8, milk_protein_fraction = 0.033, milk_fat_fraction = 0.04,
      milk_lactose_fraction = 0.048, milk_protein_fraction_standard = 0.033, milk_fat_fraction_standard = 0.04,
      milk_lactose_fraction_standard = 0.048
    ),
    "milk_yield_day"
  )

  expect_error(
    calc_milk_production(
      species_short = "CTL",
      cohort_short = "FA",
      milk_yield_day = 10, simulation_duration = 365, cohort_stock_size = 100,
      lactating_females_fraction = 1.5, milk_protein_fraction = 0.033, milk_fat_fraction = 0.04,
      milk_lactose_fraction = 0.048, milk_protein_fraction_standard = 0.033, milk_fat_fraction_standard = 0.04,
      milk_lactose_fraction_standard = 0.048
    ),
    "lactating_females_fraction"
  )

  expect_error(
    calc_milk_production(
      species_short = "CTL",
      cohort_short = "FA",
      milk_yield_day = 10, simulation_duration = 365, cohort_stock_size = 100,
      lactating_females_fraction = 0.8, milk_protein_fraction = 0.033, milk_fat_fraction = 1.5,
      milk_lactose_fraction = 0.048, milk_protein_fraction_standard = 0.033, milk_fat_fraction_standard = 0.04,
      milk_lactose_fraction_standard = 0.048
    ),
    "milk_fat_fraction"
  )
})

test_that("calc_milk_production returns zeros for PGS", {
  result <- calc_milk_production(
    species_short = "PGS",
    cohort_short = "FA",
    milk_yield_day = 10,
    simulation_duration = 365,
    cohort_stock_size = 100,
    lactating_females_fraction = 0.8,
    milk_protein_fraction = 0.033,
    milk_fat_fraction = 0.04,
    milk_lactose_fraction = 0.048,
    milk_protein_fraction_standard = 0.033,
    milk_fat_fraction_standard = 0.04,
    milk_lactose_fraction_standard = 0.048
  )
  
  expect_named(result, c(
    "milk_production_mass_cohort",
    "milk_production_protein_cohort",
    "milk_production_fpcm_cohort"
  ))
  expect_equal(result$milk_production_mass_cohort, 0)
  expect_equal(result$milk_production_protein_cohort, 0)
  expect_equal(result$milk_production_fpcm_cohort, 0)
})


# ---- test calc_fibre_production ----
test_that("calc_fibre_production returns expected value", {
  result <- calc_fibre_production(
    species_short = "SHP",
    cohort_short = "FS",
    fibre_yield_year = 0.1,
    simulation_duration = 365,
    cohort_stock_size = 100
  )

  expected <- 0.1 / 365 * 365 * 100
  expect_equal(result, expected)
})

test_that("calc_fibre_production handles zero fibre yield", {
  result <- calc_fibre_production(
    species_short = "SHP",
    cohort_short = "FS",
    fibre_yield_year = 0,
    simulation_duration = 365,
    cohort_stock_size = 100
  )

  expect_equal(result, 0)
})

test_that("calc_fibre_production handles zero size", {
  result <- calc_fibre_production(
    species_short = "SHP",
    cohort_short = "FA",
    fibre_yield_year = 0.1,
    simulation_duration = 365,
    cohort_stock_size = 0
  )

  expect_equal(result, 0)
})

test_that("calc_fibre_production handles different assessment durations", {
  result_365 <- calc_fibre_production(
    species_short = "GTS",
    cohort_short = "MA",
    fibre_yield_year = 0.1,
    simulation_duration = 365,
    cohort_stock_size = 100
  )

  result_180 <- calc_fibre_production(
    species_short = "CML",
    cohort_short = "MA",
    fibre_yield_year = 0.1,
    simulation_duration = 180,
    cohort_stock_size = 100
  )

  expect_equal(result_365 / result_180, 365 / 180)
})

test_that("calc_fibre_production handles large values", {
  result <- calc_fibre_production(
    species_short = "CML",
    cohort_short = "MS",
    fibre_yield_year = 5.0,
    simulation_duration = 365,
    cohort_stock_size = 1000
  )

  expected <- 5.0 / 365 * 365 * 1000
  expect_equal(result, expected)
})

test_that("calc_fibre_production returns zero for non-fibre animals", {
  result <- calc_fibre_production(
    species_short = "PGS",
    cohort_short = "MS",
    fibre_yield_year = 1,
    simulation_duration = 365,
    cohort_stock_size = 1000
  )
  
  expected <- 0
  expect_equal(result, expected)
})


test_that("calc_fibre_production returns zero for non-fibre animals", {
  result <- calc_fibre_production(
    species_short = "CTL",
    cohort_short = "MS",
    fibre_yield_year = 1,
    simulation_duration = 365,
    cohort_stock_size = 1000
  )
  
  expected <- 0
  expect_equal(result, expected)
})


test_that("calc_fibre_production handles validation errors", {
  expect_error(
    calc_fibre_production(species_short = "SHP", cohort_short = "MA", fibre_yield_year = -0.1, simulation_duration = 365, cohort_stock_size = 100),
    "fibre_yield_year"
  )
})


# ---- test calc_meat_production ----
test_that("calc_meat_production returns expected output structure", {
  result <- calc_meat_production(
    offtake_heads_assessment = 10,
    slaughter_weight_cohort = 400,
    carcass_dressing_fraction = 0.55,
    bone_free_meat_fraction = 0.75,
    meat_protein_fraction = 0.20
  )

  expect_type(result, "list")
  expect_named(result, c(
    "meat_production_live_weight_cohort",
    "meat_production_carcass_weight_cohort",
    "meat_production_bone_free_meat_cohort",
    "meat_production_protein_cohort"
  ))
})

test_that("calc_meat_production calculates liveweight correctly", {
  result <- calc_meat_production(
    offtake_heads_assessment = 50,
    slaughter_weight_cohort = 300,
    carcass_dressing_fraction = 0.60,
    bone_free_meat_fraction = 0.80,
    meat_protein_fraction = 0.22
  )

  expected_liveweight <- 50 * 300
  expect_equal(result$meat_production_live_weight_cohort, expected_liveweight)
})

test_that("calc_meat_production calculates carcass weight correctly", {
  result <- calc_meat_production(
    offtake_heads_assessment = 25,
    slaughter_weight_cohort = 450,
    carcass_dressing_fraction = 0.58,
    bone_free_meat_fraction = 0.78,
    meat_protein_fraction = 0.21
  )

  expected_liveweight <- 25 * 450
  expected_carcass <- expected_liveweight * 0.58
  expect_equal(result$meat_production_carcass_weight_cohort, expected_carcass)
})

test_that("calc_meat_production calculates boneless meat correctly", {
  result <- calc_meat_production(
    offtake_heads_assessment = 30,
    slaughter_weight_cohort = 350,
    carcass_dressing_fraction = 0.55,
    bone_free_meat_fraction = 0.70,
    meat_protein_fraction = 0.20
  )

  expected_liveweight <- 30 * 350
  expected_carcass <- expected_liveweight * 0.55
  expected_meat <- expected_carcass * 0.70
  expect_equal(result$meat_production_bone_free_meat_cohort, expected_meat)
})

test_that("calc_meat_production calculates meat protein correctly", {
  result <- calc_meat_production(
    offtake_heads_assessment = 20,
    slaughter_weight_cohort = 400,
    carcass_dressing_fraction = 0.56,
    bone_free_meat_fraction = 0.75,
    meat_protein_fraction = 0.23
  )

  expected_liveweight <- 20 * 400
  expected_carcass <- expected_liveweight * 0.56
  expected_meat <- expected_carcass * 0.75
  expected_protein <- expected_meat * 0.23
  expect_equal(result$meat_production_protein_cohort, expected_protein)
})

test_that("calc_meat_production handles zero offtake", {
  result <- calc_meat_production(
    offtake_heads_assessment = 0,
    slaughter_weight_cohort = 400,
    carcass_dressing_fraction = 0.55,
    bone_free_meat_fraction = 0.75,
    meat_protein_fraction = 0.20
  )

  expect_equal(result$meat_production_live_weight_cohort, 0)
  expect_equal(result$meat_production_carcass_weight_cohort, 0)
  expect_equal(result$meat_production_bone_free_meat_cohort, 0)
  expect_equal(result$meat_production_protein_cohort, 0)
})

test_that("calc_meat_production handles zero slaughter weight", {
  result <- calc_meat_production(
    offtake_heads_assessment = 10,
    slaughter_weight_cohort = 0,
    carcass_dressing_fraction = 0.55,
    bone_free_meat_fraction = 0.75,
    meat_protein_fraction = 0.20
  )

  expect_equal(result$meat_production_live_weight_cohort, 0)
  expect_equal(result$meat_production_carcass_weight_cohort, 0)
  expect_equal(result$meat_production_bone_free_meat_cohort, 0)
  expect_equal(result$meat_production_protein_cohort, 0)
})

test_that("calc_meat_production verifies sequential calculation chain", {
  result <- calc_meat_production(
    offtake_heads_assessment = 100,
    slaughter_weight_cohort = 300,
    carcass_dressing_fraction = 0.50,
    bone_free_meat_fraction = 0.80,
    meat_protein_fraction = 0.25
  )

  # Verify the chain: liveweight -> carcass -> meat -> protein
  liveweight <- result$meat_production_live_weight_cohort
  carcass <- result$meat_production_carcass_weight_cohort
  meat <- result$meat_production_bone_free_meat_cohort
  protein <- result$meat_production_protein_cohort

  expect_equal(carcass, liveweight * 0.50)
  expect_equal(meat, carcass * 0.80)
  expect_equal(protein, meat * 0.25)
})

test_that("calc_meat_production handles validation errors", {
  expect_error(
    calc_meat_production(
      offtake_heads_assessment = -10, slaughter_weight_cohort = 400,
      carcass_dressing_fraction = 0.55, bone_free_meat_fraction = 0.75,
      meat_protein_fraction = 0.20
    ),
    "offtake_heads_assessment"
  )

  expect_error(
    calc_meat_production(
      offtake_heads_assessment = 10, slaughter_weight_cohort = -400,
      carcass_dressing_fraction = 0.55, bone_free_meat_fraction = 0.75,
      meat_protein_fraction = 0.20
    ),
    "slaughter_weight_cohort"
  )

  expect_error(
    calc_meat_production(
      offtake_heads_assessment = 10, slaughter_weight_cohort = 400,
      carcass_dressing_fraction = 1.5, bone_free_meat_fraction = 0.75,
      meat_protein_fraction = 0.20
    ),
    "carcass_dressing_fraction"
  )

  expect_error(
    calc_meat_production(
      offtake_heads_assessment = 10, slaughter_weight_cohort = 400,
      carcass_dressing_fraction = 0.55, bone_free_meat_fraction = -0.1,
      meat_protein_fraction = 0.20
    ),
    "bone_free_meat_fraction"
  )

  expect_error(
    calc_meat_production(
      offtake_heads_assessment = 10, slaughter_weight_cohort = 400,
      carcass_dressing_fraction = 0.55, bone_free_meat_fraction = 0.75,
      meat_protein_fraction = 1.5
    ),
    "meat_protein_fraction"
  )
})
