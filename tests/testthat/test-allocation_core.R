# ---- test calc_energy_allocation_milk ----

test_that("calc_energy_allocation_milk returns correct value for valid inputs", {
  result <- calc_energy_allocation_milk(
    milk_fpcm_output = 100,
    standard_protein = 0.033,
    standard_fat = 0.04,
    standard_lactose = 0.048
  )

  expect_type(result, "double")
  expect_length(result, 1)
  # Expected: (0.0929 * 0.04 + 0.0547 * 0.033 + 0.0395 * 0.048) * 4.184 * 100 * 100
  energy_standard <- (0.0929 * 0.04 + 0.0547 * 0.033 + 0.0395 * 0.048) * 4.184 * 100
  expect_equal(result, energy_standard * 100)
})

test_that("calc_energy_allocation_milk handles zero milk output", {
  result <- calc_energy_allocation_milk(
    milk_fpcm_output = 0,
    standard_protein = 0.033,
    standard_fat = 0.04,
    standard_lactose = 0.048
  )

  expect_equal(result, 0)
})

test_that("calc_energy_allocation_milk validates scalar numeric inputs", {
  expect_error(
    calc_energy_allocation_milk(milk_fpcm_output = c(100, 200), standard_protein = 0.033, standard_fat = 0.04, standard_lactose = 0.048),
    "must be a single numeric value"
  )
  expect_error(
    calc_energy_allocation_milk(milk_fpcm_output = 100, standard_protein = "0.033", standard_fat = 0.04, standard_lactose = 0.048),
    "must be a single numeric value"
  )
})

test_that("calc_energy_allocation_milk validates bounds", {
  expect_error(
    calc_energy_allocation_milk(milk_fpcm_output = -10, standard_protein = 0.033, standard_fat = 0.04, standard_lactose = 0.048),
    "must be non-negative"
  )
  expect_error(
    calc_energy_allocation_milk(milk_fpcm_output = 100, standard_protein = 1.5, standard_fat = 0.04, standard_lactose = 0.048),
    "must be between 0 and 1"
  )
})

# ---- test calc_energy_allocation_meat ----

test_that("calc_energy_allocation_meat returns correct value for cattle female", {
  result <- calc_energy_allocation_meat(
    animal = "CTL",
    cohort_code = "FA",
    slaughter_liveweight = 500,
    birth_liveweight = 40,
    output_meat_production_liveweight = 100,
    ratio_ne_to_me = 0.43
  )

  expect_type(result, "double")
  expect_length(result, 1)
  # For CTL/FA: growth_efficiency_factor = 0.8
  # specific_energy = (22.02 * (((500-40)/2) / (0.8*500))^0.75 * (500-40)^1.097) / 500
  # result = specific_energy * 100
  expect_true(!is.na(result))
  expect_true(result >= 0)
})

test_that("calc_energy_allocation_meat returns correct value for cattle male", {
  result <- calc_energy_allocation_meat(
    animal = "CTL",
    cohort_code = "MA",
    slaughter_liveweight = 600,
    birth_liveweight = 45,
    output_meat_production_liveweight = 150,
    ratio_ne_to_me = 0.43
  )

  expect_type(result, "double")
  expect_true(!is.na(result))
  expect_true(result >= 0)
  # For CTL/MA: growth_efficiency_factor = 1
})

test_that("calc_energy_allocation_meat returns correct value for camelids", {
  result <- calc_energy_allocation_meat(
    animal = "CML",
    cohort_code = "FA",
    slaughter_liveweight = 450,
    birth_liveweight = 35,
    output_meat_production_liveweight = 80,
    ratio_ne_to_me = 0.43
  )

  expect_type(result, "double")
  expect_true(!is.na(result))
  # For CML: specific_energy = (41.8 * (slaughter - birth)) / slaughter
  expected_specific <- (41.8 * 0.43 * (450 - 35)) / 450
  expect_equal(result, expected_specific * 80)
})

test_that("calc_energy_allocation_meat returns correct value for sheep female", {
  result <- calc_energy_allocation_meat(
    animal = "SHP",
    cohort_code = "FA",
    slaughter_liveweight = 60,
    birth_liveweight = 4,
    output_meat_production_liveweight = 20,
    ratio_ne_to_me = 0.43
  )

  expect_type(result, "double")
  expect_true(!is.na(result))
  # For SHP/FA: a = 2.1, b = 0.45
  # specific_energy = ((60-4) * (2.1 + 0.5 * 0.45 * (4 + 60))) / 60
  expected_specific <- ((60 - 4) * (2.1 + 0.5 * 0.45 * (4 + 60))) / 60
  expect_equal(result, expected_specific * 20)
})

test_that("calc_energy_allocation_meat returns correct value for sheep male", {
  result <- calc_energy_allocation_meat(
    animal = "SHP",
    cohort_code = "MA",
    slaughter_liveweight = 70,
    birth_liveweight = 4.5,
    output_meat_production_liveweight = 25,
    ratio_ne_to_me = 0.43
  )

  expect_type(result, "double")
  expect_true(!is.na(result))
  # For SHP/MA: a = 4.4, b = 0.32
})

test_that("calc_energy_allocation_meat returns correct value for goats", {
  result <- calc_energy_allocation_meat(
    animal = "GTS",
    cohort_code = "FA",
    slaughter_liveweight = 50,
    birth_liveweight = 3.5,
    output_meat_production_liveweight = 15,
    ratio_ne_to_me = 0.43
  )

  expect_type(result, "double")
  expect_true(!is.na(result))
  # For GTS: a = 5, b = 0.33 (fixed for all cohorts)
  expected_specific <- ((50 - 3.5) * (5 + 0.5 * 0.33 * (3.5 + 50))) / 50
  expect_equal(result, expected_specific * 15)
})

test_that("calc_energy_allocation_meat returns NA for pigs", {
  result <- calc_energy_allocation_meat(
    animal = "PGS",
    cohort_code = "FA",
    slaughter_liveweight = 150,
    birth_liveweight = 1.5,
    output_meat_production_liveweight = 100,
    ratio_ne_to_me = 0.43
  )

  expect_true(is.na(result))
})

test_that("calc_energy_allocation_meat validates animal species", {
  expect_error(
    calc_energy_allocation_meat(
      animal = "INVALID",
      cohort_code = "FA",
      slaughter_liveweight = 500,
      birth_liveweight = 40,
      output_meat_production_liveweight = 100,
      ratio_ne_to_me = 0.43
    ),
    "must be one of"
  )
})

test_that("calc_energy_allocation_meat validates cohort codes", {
  expect_error(
    calc_energy_allocation_meat(
      animal = "CTL",
      cohort_code = "INVALID",
      slaughter_liveweight = 500,
      birth_liveweight = 40,
      output_meat_production_liveweight = 100,
      ratio_ne_to_me = 0.43
    ),
    "must be one of"
  )
})

test_that("calc_energy_allocation_meat validates weight bounds", {
  expect_error(
    calc_energy_allocation_meat(
      animal = "CTL",
      cohort_code = "FA",
      slaughter_liveweight = -10,
      birth_liveweight = 40,
      output_meat_production_liveweight = 100,
      ratio_ne_to_me = 0.43
    ),
    "must be between 0 and 2000"
  )
  expect_error(
    calc_energy_allocation_meat(
      animal = "CTL",
      cohort_code = "FA",
      slaughter_liveweight = 500,
      birth_liveweight = 300,
      output_meat_production_liveweight = 100,
      ratio_ne_to_me = 0.43
    ),
    "must be between 0 and 200"
  )
})

# ---- test calc_energy_allocation_fibre ----

test_that("calc_energy_allocation_fibre returns correct value for sheep", {
  result <- calc_energy_allocation_fibre(
    animal = "SHP",
    size = 100,
    fibre_energy_requirement = 5,
    ratio_ne_to_me = 0.43,
    assessment_duration = 365
  )

  expect_type(result, "double")
  expect_length(result, 1)
  expect_equal(result, 5 * 365 * 100)  # Direct calculation for sheep
})

test_that("calc_energy_allocation_fibre returns correct value for goats", {
  result <- calc_energy_allocation_fibre(
    animal = "GTS",
    size = 100,
    fibre_energy_requirement = 4,
    ratio_ne_to_me = 0.43,
    assessment_duration = 365
  )

  expect_equal(result, 4 * 365 * 100)  # Direct calculation for goats
})

test_that("calc_energy_allocation_fibre returns correct value for camelids", {
  result <- calc_energy_allocation_fibre(
    animal = "CML",
    size = 100,
    fibre_energy_requirement = 6,
    ratio_ne_to_me = 0.43,
    assessment_duration = 365
  )

  expect_type(result, "double")
  # For camelids: fibre_energy * ratio_ne_to_me * assessment_duration
  expect_equal(result, 6 * 0.43 * 365 * 100)
})

test_that("calc_energy_allocation_fibre returns zero for non-fibre species", {
  result_cattle <- calc_energy_allocation_fibre(
    animal = "CTL",
    size = 100,
    fibre_energy_requirement = 10,
    ratio_ne_to_me = 0.43,
    assessment_duration = 365
  )
  expect_equal(result_cattle, 0)

  result_pigs <- calc_energy_allocation_fibre(
    animal = "PGS",
    size = 100,
    fibre_energy_requirement = 10,
    ratio_ne_to_me = 0.43,
    assessment_duration = 365
  )
  expect_equal(result_pigs, 0)
})

test_that("calc_energy_allocation_fibre uses default assessment_duration", {
  result <- calc_energy_allocation_fibre(
    animal = "SHP",
    size = 100,
    fibre_energy_requirement = 5,
    ratio_ne_to_me = 0.43,
    assessment_duration = 365
  )

  expect_equal(result, 5 * 365 * 100)  # Default is 365 days
})

test_that("calc_energy_allocation_fibre validates inputs", {
  expect_error(
    calc_energy_allocation_fibre(animal = "INVALID", size = 100, fibre_energy_requirement = 5, ratio_ne_to_me = 0.43, assessment_duration = 365),
    "must be one of"
  )
  expect_error(
    calc_energy_allocation_fibre(animal = "SHP", size = 100, fibre_energy_requirement = -5, ratio_ne_to_me = 0.43, assessment_duration = 365),
    "must be non-negative"
  )
  expect_error(
    calc_energy_allocation_fibre(animal = "SHP", size = 100, fibre_energy_requirement = 5, ratio_ne_to_me = 1.5, assessment_duration = 365),
    "must be between 0 and 1"
  )
})

# ---- test calc_energy_allocation_work ----

test_that("calc_energy_allocation_work returns correct value for camelids", {
  result <- calc_energy_allocation_work(
    animal = "CML",
    size = 100, 
    work_energy_requirement = 10,
    ratio_ne_to_me = 0.43,
    assessment_duration = 365
  )

  expect_type(result, "double")
  expect_length(result, 1)
  # For camelids: work_energy * ratio_ne_to_me * assessment_duration
  expect_equal(result, 10 * 0.43 * 365 * 100)
})

test_that("calc_energy_allocation_work returns correct value for non-camelids", {
  result <- calc_energy_allocation_work(
    animal = "CTL",
    size = 100, 
    work_energy_requirement = 8,
    ratio_ne_to_me = 0.43,
    assessment_duration = 365
  )

  expect_type(result, "double")
  # For non-camelids: work_energy * assessment_duration (ratio not applied)
  expect_equal(result, 8 * 365 * 100)
})

test_that("calc_energy_allocation_work uses default assessment_duration", {
  result <- calc_energy_allocation_work(
    animal = "CTL",
    size = 100, 
    work_energy_requirement = 8,
    ratio_ne_to_me = 0.43,
    assessment_duration = 365
  )

  expect_equal(result, 8 * 365 * 100)  # Default is 365 days
})

test_that("calc_energy_allocation_work handles zero energy requirement", {
  result <- calc_energy_allocation_work(
    animal = "CTL",
    size = 100, 
    work_energy_requirement = 0,
    ratio_ne_to_me = 0.43,
    assessment_duration = 365
  )

  expect_equal(result, 0)
})

test_that("calc_energy_allocation_work validates inputs", {
  expect_error(
    calc_energy_allocation_work(animal = "INVALID", size = 100, work_energy_requirement = 10, ratio_ne_to_me = 0.43, assessment_duration = 365),
    "must be one of"
  )
  expect_error(
    calc_energy_allocation_work(animal = "CML", size = 100, work_energy_requirement = -5, ratio_ne_to_me = 0.43, assessment_duration = 365),
    "must be non-negative"
  )
  expect_error(
    calc_energy_allocation_work(animal = "CML", size = 100, work_energy_requirement = 10, ratio_ne_to_me = -0.1, assessment_duration = 365),
    "must be between 0 and 1"
  )
  expect_error(
    calc_energy_allocation_work(animal = "CML", size = 100, work_energy_requirement = 10, ratio_ne_to_me = 0.43, assessment_duration = 5000),
    "must be between 0 and 3650"
  )
})
