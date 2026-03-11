# ---- test calc_energy_allocation_milk ----

test_that("calc_energy_allocation_milk returns correct value for valid inputs", {
  result <- calc_energy_allocation_milk(
    milk_production_fpcm_cohort = 100,
    milk_protein_fraction_standard = 0.033,
    milk_fat_fraction_standard = 0.04,
    milk_lactose_fraction_standard = 0.048
  )

  expect_type(result, "double")
  expect_length(result, 1)
  energy_standard <- (0.0929 * 0.04 + 0.0547 * 0.033 + 0.0395 * 0.048) * 4.184 * 100
  expect_equal(result, energy_standard * 100)
})

test_that("calc_energy_allocation_milk handles zero milk output", {
  result <- calc_energy_allocation_milk(
    milk_production_fpcm_cohort = 0,
    milk_protein_fraction_standard = 0.033,
    milk_fat_fraction_standard = 0.04,
    milk_lactose_fraction_standard = 0.048
  )

  expect_equal(result, 0)
})

test_that("calc_energy_allocation_milk validates bounds", {
  expect_error(
    calc_energy_allocation_milk(
      milk_production_fpcm_cohort = -10,
      milk_protein_fraction_standard = 0.033,
      milk_fat_fraction_standard = 0.04,
      milk_lactose_fraction_standard = 0.048
    ),
    "is out of range"
  )
  expect_error(
    calc_energy_allocation_milk(
      milk_production_fpcm_cohort = 100,
      milk_protein_fraction_standard = 1.5,
      milk_fat_fraction_standard = 0.04,
      milk_lactose_fraction_standard = 0.048
    ),
    "is out of range"
  )
})

# ---- test calc_energy_allocation_meat ----

test_that("calc_energy_allocation_meat returns correct value for cattle female", {
  result <- calc_energy_allocation_meat(
    species_short = "CTL",
    cohort_short = "FA",
    meat_production_live_weight_cohort = 100,
    slaughter_weight_cohort = 500,
    birth_weight = 40
  )

  expect_type(result, "double")
  expect_length(result, 1)
  # For CTL/FA: growth_efficiency_factor = 0.8
  # specific_energy = (22.02 * (((500-40)/2) / (0.8*500))^0.75 * (500-40)^1.097) / 500
  expected_specific <- (22.02 * (((500 - 40) / 2) / (0.8 * 500))^0.75 * (500 - 40)^1.097) / 500
  expect_equal(result, expected_specific * 100)
})

test_that("calc_energy_allocation_meat returns correct value for cattle male", {
  result <- calc_energy_allocation_meat(
    species_short = "CTL",
    cohort_short = "MA",
    meat_production_live_weight_cohort = 150,
    slaughter_weight_cohort = 600,
    birth_weight = 45
  )

  expect_type(result, "double")
  expect_true(!is.na(result))
  expect_true(result >= 0)
  # For CTL/MA: growth_efficiency_factor = 1
})

test_that("calc_energy_allocation_meat returns correct value for camelids", {
  result <- calc_energy_allocation_meat(
    species_short = "CML",
    cohort_short = "FA",
    meat_production_live_weight_cohort = 80,
    slaughter_weight_cohort = 450,
    birth_weight = 35,
    ratio_me_to_ne = 2.33
  )

  expect_type(result, "double")
  expect_true(!is.na(result))
  # For CML: specific_energy = (41.8 * (slaughter - birth) / slaughter) / ratio_me_to_ne
  expected_specific <- (41.8 * (450 - 35) / 450) / 2.33
  expect_equal(result, expected_specific * 80)
})

test_that("calc_energy_allocation_meat returns correct value for sheep female", {
  result <- calc_energy_allocation_meat(
    species_short = "SHP",
    cohort_short = "FA",
    meat_production_live_weight_cohort = 20,
    slaughter_weight_cohort = 60,
    birth_weight = 4
  )

  expect_type(result, "double")
  expect_true(!is.na(result))
  # For SHP/FA: a = 2.1, b = 0.45
  expected_specific <- ((60 - 4) * (2.1 + 0.5 * 0.45 * (4 + 60))) / 60
  expect_equal(result, expected_specific * 20)
})

test_that("calc_energy_allocation_meat returns correct value for sheep male", {
  result <- calc_energy_allocation_meat(
    species_short = "SHP",
    cohort_short = "MA",
    meat_production_live_weight_cohort = 25,
    slaughter_weight_cohort = 70,
    birth_weight = 4.5
  )

  expect_type(result, "double")
  expect_true(!is.na(result))
  # For SHP/MA: a = 4.4, b = 0.32
  expected_specific <- ((70 - 4.5) * (4.4 + 0.5 * 0.32 * (4.5 + 70))) / 70
  expect_equal(result, expected_specific * 25)
})

test_that("calc_energy_allocation_meat returns correct value for goats", {
  result <- calc_energy_allocation_meat(
    species_short = "GTS",
    cohort_short = "FA",
    meat_production_live_weight_cohort = 15,
    slaughter_weight_cohort = 50,
    birth_weight = 3.5
  )

  expect_type(result, "double")
  expect_true(!is.na(result))
  # For GTS: a = 5, b = 0.33 (fixed for all cohorts)
  expected_specific <- ((50 - 3.5) * (5 + 0.5 * 0.33 * (3.5 + 50))) / 50
  expect_equal(result, expected_specific * 15)
})

test_that("calc_energy_allocation_meat validates animal species", {
  expect_error(
    calc_energy_allocation_meat(
      species_short = "INVALID",
      cohort_short = "FA",
      meat_production_live_weight_cohort = 100
    ),
    "must be one of"
  )
})

test_that("calc_energy_allocation_meat validates cohort codes", {
  expect_error(
    calc_energy_allocation_meat(
      species_short = "CTL",
      cohort_short = "INVALID",
      meat_production_live_weight_cohort = 100,
      slaughter_weight_cohort = 500,
      birth_weight = 40
    ),
    "must be one of"
  )
})

test_that("calc_energy_allocation_meat validates weight bounds for non-PGS", {
  expect_error(
    calc_energy_allocation_meat(
      species_short = "CTL",
      cohort_short = "FA",
      meat_production_live_weight_cohort = 100,
      slaughter_weight_cohort = -10,
      birth_weight = 40
    ),
    "is out of range"
  )
  expect_error(
    calc_energy_allocation_meat(
      species_short = "CTL",
      cohort_short = "FA",
      meat_production_live_weight_cohort = 100,
      slaughter_weight_cohort = 500,
      birth_weight = 1500
    ),
    "is out of range"
  )
})

test_that("calc_energy_allocation_meat validates ratio_me_to_ne for CML only", {
  expect_error(
    calc_energy_allocation_meat(
      species_short = "CML",
      cohort_short = "FA",
      meat_production_live_weight_cohort = 80,
      slaughter_weight_cohort = 450,
      birth_weight = 35,
      ratio_me_to_ne = -1
    ),
    "must be a positive numeric value"
  )
  # Non-CML: ratio_me_to_ne is not validated even if negative
  expect_no_error(
    calc_energy_allocation_meat(
      species_short = "CTL",
      cohort_short = "FA",
      meat_production_live_weight_cohort = 100,
      slaughter_weight_cohort = 500,
      birth_weight = 40,
      ratio_me_to_ne = -1
    )
  )
})

# ---- test calc_energy_allocation_fibre ----

test_that("calc_energy_allocation_fibre returns correct value for sheep", {
  result <- calc_energy_allocation_fibre(
    species_short = "SHP",
    cohort_stock_size = 100,
    energy_requirement_fibre_production = 5,
    simulation_duration = 365
  )

  expect_type(result, "double")
  expect_length(result, 1)
  expect_equal(result, 5 * 365 * 100)
})

test_that("calc_energy_allocation_fibre returns correct value for goats", {
  result <- calc_energy_allocation_fibre(
    species_short = "GTS",
    cohort_stock_size = 100,
    energy_requirement_fibre_production = 4,
    simulation_duration = 365
  )

  expect_equal(result, 4 * 365 * 100)
})

test_that("calc_energy_allocation_fibre returns correct value for camelids", {
  result <- calc_energy_allocation_fibre(
    species_short = "CML",
    cohort_stock_size = 100,
    energy_requirement_fibre_production = 6,
    ratio_me_to_ne = 2.33,
    simulation_duration = 365
  )

  expect_type(result, "double")
  # For camelids: (energy_requirement / ratio_me_to_ne) * simulation_duration * cohort_stock_size
  expect_equal(result, (6 / 2.33) * 365 * 100)
})

test_that("calc_energy_allocation_fibre returns zero for non-fibre species (no extra args needed)", {
  expect_equal(calc_energy_allocation_fibre(species_short = "CTL"), 0)
  expect_equal(calc_energy_allocation_fibre(species_short = "BFL"), 0)
  expect_equal(calc_energy_allocation_fibre(species_short = "PGS"), 0)
})

test_that("calc_energy_allocation_fibre validates inputs", {
  expect_error(
    calc_energy_allocation_fibre(species_short = "INVALID"),
    "must be one of"
  )
  expect_error(
    calc_energy_allocation_fibre(
      species_short = "SHP",
      cohort_stock_size = 100,
      energy_requirement_fibre_production = -5,
      simulation_duration = 365
    ),
    "is out of range"
  )
  # ratio_me_to_ne only validated for CML, not SHP
  expect_no_error(
    calc_energy_allocation_fibre(
      species_short = "SHP",
      cohort_stock_size = 100,
      energy_requirement_fibre_production = 5,
      ratio_me_to_ne = -0.1,
      simulation_duration = 365
    )
  )
  expect_error(
    calc_energy_allocation_fibre(
      species_short = "CML",
      cohort_stock_size = 100,
      energy_requirement_fibre_production = 5,
      ratio_me_to_ne = -0.1,
      simulation_duration = 365
    ),
    "must be a positive numeric value"
  )
})

# ---- test calc_energy_allocation_work ----

test_that("calc_energy_allocation_work returns correct value for camelids", {
  result <- calc_energy_allocation_work(
    species_short = "CML",
    cohort_stock_size = 100,
    energy_requirement_work = 10,
    simulation_duration = 365,
    ratio_me_to_ne = 2.33
  )

  expect_type(result, "double")
  expect_length(result, 1)
  # For camelids: (work_energy * simulation_duration * cohort_stock_size) / ratio_me_to_ne
  expect_equal(result, (10 * 365 * 100) / 2.33)
})

test_that("calc_energy_allocation_work returns correct value for non-camelids (ratio_me_to_ne not needed)", {
  result <- calc_energy_allocation_work(
    species_short = "CTL",
    cohort_stock_size = 100,
    energy_requirement_work = 8,
    simulation_duration = 365
  )

  expect_type(result, "double")
  # For non-camelids: direct calculation (ratio not applied)
  expect_equal(result, 8 * 365 * 100)
})

test_that("calc_energy_allocation_work handles zero energy requirement", {
  result <- calc_energy_allocation_work(
    species_short = "CTL",
    cohort_stock_size = 100,
    energy_requirement_work = 0,
    simulation_duration = 365
  )

  expect_equal(result, 0)
})

test_that("calc_energy_allocation_work validates inputs", {
  expect_error(
    calc_energy_allocation_work(
      species_short = "INVALID",
      cohort_stock_size = 100,
      energy_requirement_work = 10,
      simulation_duration = 365
    ),
    "must be one of"
  )
  expect_error(
    calc_energy_allocation_work(
      species_short = "CTL",
      cohort_stock_size = 100,
      energy_requirement_work = -5,
      simulation_duration = 365
    ),
    "is out of range"
  )
  expect_error(
    calc_energy_allocation_work(
      species_short = "CTL",
      cohort_stock_size = 100,
      energy_requirement_work = 10,
      simulation_duration = 5000
    ),
    "is out of range"
  )
  # ratio_me_to_ne only validated for CML
  expect_error(
    calc_energy_allocation_work(
      species_short = "CML",
      cohort_stock_size = 100,
      energy_requirement_work = 10,
      simulation_duration = 365,
      ratio_me_to_ne = -0.1
    ),
    "must be a positive numeric value"
  )
  expect_no_error(
    calc_energy_allocation_work(
      species_short = "CTL",
      cohort_stock_size = 100,
      energy_requirement_work = 10,
      simulation_duration = 365,
      ratio_me_to_ne = -0.1
    )
  )
})

# ---- test calc_allocation_shares ----

test_that("calc_allocation_shares returns meat=1 and others=0 for pigs (PGS)", {
  result <- calc_allocation_shares(
    species_short = "PGS",
    energy_allocation_meat = NA,
    energy_allocation_milk = 0,
    energy_allocation_fibre = 0,
    energy_allocation_work = 0,
    energy_allocation_eggs = 0
  )

  expect_equal(result$allocation_share_meat, 1)
  expect_equal(result$allocation_share_milk, 0)
  expect_equal(result$allocation_share_fibre, 0)
  expect_equal(result$allocation_share_work, 0)
  expect_equal(result$allocation_share_eggs, 0)
})

test_that("calc_allocation_shares returns correct proportions for milk and meat", {
  result <- calc_allocation_shares(
    species_short = "CTL",
    energy_allocation_meat = 300,
    energy_allocation_milk = 700,
    energy_allocation_fibre = 0,
    energy_allocation_work = 0,
    energy_allocation_eggs = 0
  )

  expect_equal(result$allocation_share_meat, 0.3)
  expect_equal(result$allocation_share_milk, 0.7)
  expect_equal(result$allocation_share_fibre, 0)
  expect_equal(result$allocation_share_work, 0)
  expect_equal(result$allocation_share_eggs, 0)
})

test_that("calc_allocation_shares shares sum to 1", {
  result <- calc_allocation_shares(
    species_short = "SHP",
    energy_allocation_meat = 200,
    energy_allocation_milk = 0,
    energy_allocation_fibre = 300,
    energy_allocation_work = 0,
    energy_allocation_eggs = 0
  )

  total <- result$allocation_share_meat + result$allocation_share_milk +
    result$allocation_share_fibre + result$allocation_share_work +
    result$allocation_share_eggs

  expect_equal(total, 1)
  expect_equal(result$allocation_share_meat, 0.4)
  expect_equal(result$allocation_share_fibre, 0.6)
})

test_that("calc_allocation_shares returns a named list with 5 elements", {
  result <- calc_allocation_shares(
    species_short = "CTL",
    energy_allocation_meat = 500,
    energy_allocation_milk = 500,
    energy_allocation_fibre = 0,
    energy_allocation_work = 0,
    energy_allocation_eggs = 0
  )

  expect_type(result, "list")
  expect_named(result, c(
    "allocation_share_meat", "allocation_share_milk",
    "allocation_share_fibre", "allocation_share_work", "allocation_share_eggs"
  ))
})
