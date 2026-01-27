# ---- test compute_milk_outputs ----
test_that("compute_milk_outputs returns expected output structure", {
  result <- compute_milk_outputs(
    milk_yield = 10,
    assessment_duration = 365,
    size = 100,
    milking_fraction = 0.8,
    milk_protein = 0.033,
    milk_fat = 0.04,
    lactose = 0.048,
    standard_protein = 0.033,
    standard_fat = 0.04,
    standard_lactose = 0.048
  )

  expect_type(result, "list")
  expect_named(result, c(
    "output_milk_mass_production",
    "output_milk_protein_production",
    "output_milk_fpcm_production"
  ))
})

test_that("compute_milk_outputs calculates milk mass production correctly", {
  result <- compute_milk_outputs(
    milk_yield = 20,
    assessment_duration = 365,
    size = 50,
    milking_fraction = 0.75,
    milk_protein = 0.032,
    milk_fat = 0.038,
    lactose = 0.047,
    standard_protein = 0.033,
    standard_fat = 0.04,
    standard_lactose = 0.048
  )

  expected_mass <- 20 * 365 * 50 * 0.75
  expect_equal(result$output_milk_mass_production, expected_mass)
})

test_that("compute_milk_outputs calculates milk protein production correctly", {
  result <- compute_milk_outputs(
    milk_yield = 15,
    assessment_duration = 365,
    size = 80,
    milking_fraction = 0.9,
    milk_protein = 0.035,
    milk_fat = 0.042,
    lactose = 0.049,
    standard_protein = 0.033,
    standard_fat = 0.04,
    standard_lactose = 0.048
  )

  expected_mass <- 15 * 365 * 80 * 0.9
  expected_protein <- expected_mass * 0.035
  expect_equal(result$output_milk_protein_production, expected_protein)
})

test_that("compute_milk_outputs calculates FPCM using energy ratio", {
  result <- compute_milk_outputs(
    milk_yield = 12,
    assessment_duration = 365,
    size = 60,
    milking_fraction = 0.85,
    milk_protein = 0.033,
    milk_fat = 0.04,
    lactose = 0.048,
    standard_protein = 0.033,
    standard_fat = 0.04,
    standard_lactose = 0.048
  )

  # When milk composition equals standard, energy ratio should be 1 and FPCM equals milk production
  expected_mass <- 12 * 365 * 60 * 0.85
  expect_equal(result$output_milk_fpcm_production, expected_mass, tolerance = 1e-10)
})

test_that("compute_milk_outputs calculates FPCM correctly with different composition", {
  result <- compute_milk_outputs(
    milk_yield = 12,
    assessment_duration = 365,
    size = 60,
    milking_fraction = 0.85,
    milk_protein = 0.034,
    milk_fat = 0.041,
    lactose = 0.048,
    standard_protein = 0.033,
    standard_fat = 0.04,
    standard_lactose = 0.048
  )

  # Calculate expected FPCM using energy ratio
  expected_mass <- 12 * 365 * 60 * 0.85
  energy_standard <- 0.0929 * 0.04 + 0.0547 * 0.033 + 0.0395 * 0.048
  energy_milk <- 0.0929 * 0.041 + 0.0547 * 0.034 + 0.0395 * 0.048
  energy_ratio <- energy_milk / energy_standard
  expected_fpcm <- energy_ratio * expected_mass

  expect_equal(result$output_milk_fpcm_production, expected_fpcm, tolerance = 1e-6)
})

test_that("compute_milk_outputs handles higher fat content correctly", {
  # Higher fat should result in higher FPCM (energy ratio > 1)
  standard_result <- compute_milk_outputs(
    milk_yield = 10,
    assessment_duration = 365,
    size = 100,
    milking_fraction = 0.8,
    milk_protein = 0.033,
    milk_fat = 0.04,
    lactose = 0.048,
    standard_protein = 0.033,
    standard_fat = 0.04,
    standard_lactose = 0.048
  )

  high_fat_result <- compute_milk_outputs(
    milk_yield = 10,
    assessment_duration = 365,
    size = 100,
    milking_fraction = 0.8,
    milk_protein = 0.033,
    milk_fat = 0.05,
    lactose = 0.048,
    standard_protein = 0.033,
    standard_fat = 0.04,
    standard_lactose = 0.048
  )

  expect_gt(high_fat_result$output_milk_fpcm_production, standard_result$output_milk_fpcm_production)
})

test_that("compute_milk_outputs handles zero size", {
  result <- compute_milk_outputs(
    milk_yield = 10,
    assessment_duration = 365,
    size = 0,
    milking_fraction = 0.8,
    milk_protein = 0.033,
    milk_fat = 0.04,
    lactose = 0.048,
    standard_protein = 0.033,
    standard_fat = 0.04,
    standard_lactose = 0.048
  )

  expect_equal(result$output_milk_mass_production, 0)
  expect_equal(result$output_milk_protein_production, 0)
  expect_equal(result$output_milk_fpcm_production, 0)
})

test_that("compute_milk_outputs handles zero milking fraction", {
  result <- compute_milk_outputs(
    milk_yield = 10,
    assessment_duration = 365,
    size = 100,
    milking_fraction = 0,
    milk_protein = 0.033,
    milk_fat = 0.04,
    lactose = 0.048,
    standard_protein = 0.033,
    standard_fat = 0.04,
    standard_lactose = 0.048
  )

  expect_equal(result$output_milk_mass_production, 0)
  expect_equal(result$output_milk_protein_production, 0)
  expect_equal(result$output_milk_fpcm_production, 0)
})

test_that("compute_milk_outputs handles validation errors", {
  expect_error(
    compute_milk_outputs(
      milk_yield = -10, assessment_duration = 365, size = 100,
      milking_fraction = 0.8, milk_protein = 0.033, milk_fat = 0.04,
      lactose = 0.048, standard_protein = 0.033, standard_fat = 0.04,
      standard_lactose = 0.048
    ),
    "milk_yield"
  )

  expect_error(
    compute_milk_outputs(
      milk_yield = 10, assessment_duration = 365, size = 100,
      milking_fraction = 1.5, milk_protein = 0.033, milk_fat = 0.04,
      lactose = 0.048, standard_protein = 0.033, standard_fat = 0.04,
      standard_lactose = 0.048
    ),
    "milking_fraction"
  )

  expect_error(
    compute_milk_outputs(
      milk_yield = 10, assessment_duration = 365, size = 100,
      milking_fraction = 0.8, milk_protein = 0.033, milk_fat = 1.5,
      lactose = 0.048, standard_protein = 0.033, standard_fat = 0.04,
      standard_lactose = 0.048
    ),
    "milk_fat"
  )
})


# ---- test compute_fibre_output ----
test_that("compute_fibre_output returns expected value", {
  result <- compute_fibre_output(
    fibre_prod = 0.1,
    assessment_duration = 365,
    size = 100
  )

  expected <- 0.1 / 365 * 365 * 100
  expect_equal(result, expected)
})

test_that("compute_fibre_output handles zero fibre yield", {
  result <- compute_fibre_output(
    fibre_prod = 0,
    assessment_duration = 365,
    size = 100
  )

  expect_equal(result, 0)
})

test_that("compute_fibre_output handles zero size", {
  result <- compute_fibre_output(
    fibre_prod = 0.1,
    assessment_duration = 365,
    size = 0
  )

  expect_equal(result, 0)
})

test_that("compute_fibre_output handles different assessment durations", {
  result_365 <- compute_fibre_output(
    fibre_prod = 0.1,
    assessment_duration = 365,
    size = 100
  )

  result_180 <- compute_fibre_output(
    fibre_prod = 0.1,
    assessment_duration = 180,
    size = 100
  )

  expect_equal(result_365 / result_180, 365 / 180)
})

test_that("compute_fibre_output handles large values", {
  result <- compute_fibre_output(
    fibre_prod = 5.0,
    assessment_duration = 365,
    size = 1000
  )

  expected <- 5.0 / 365 * 365 * 1000
  expect_equal(result, expected)
})

test_that("compute_fibre_output handles validation errors", {
  expect_error(
    compute_fibre_output(fibre_prod = -0.1, assessment_duration = 365, size = 100),
    "fibre_prod"
  )

  expect_error(
    compute_fibre_output(fibre_prod = 0.1, assessment_duration = 0, size = 100),
    "assessment_duration"
  )

  expect_error(
    compute_fibre_output(fibre_prod = 0.1, assessment_duration = 365, size = -100),
    "size"
  )
})


# ---- test compute_meat_outputs ----
test_that("compute_meat_outputs returns expected output structure", {
  result <- compute_meat_outputs(
    offtake_number_assessment = 10,
    slaughter_weight = 400,
    carcass_dressing_percentage = 0.55,
    bone_free_meat_fraction = 0.75,
    meat_protein = 0.20
  )

  expect_type(result, "list")
  expect_named(result, c(
    "output_meat_production_liveweight",
    "output_meat_production_carcassweight",
    "output_meat_production_meat",
    "output_meat_production_protein"
  ))
})

test_that("compute_meat_outputs calculates liveweight correctly", {
  result <- compute_meat_outputs(
    offtake_number_assessment = 50,
    slaughter_weight = 300,
    carcass_dressing_percentage = 0.60,
    bone_free_meat_fraction = 0.80,
    meat_protein = 0.22
  )

  expected_liveweight <- 50 * 300
  expect_equal(result$output_meat_production_liveweight, expected_liveweight)
})

test_that("compute_meat_outputs calculates carcass weight correctly", {
  result <- compute_meat_outputs(
    offtake_number_assessment = 25,
    slaughter_weight = 450,
    carcass_dressing_percentage = 0.58,
    bone_free_meat_fraction = 0.78,
    meat_protein = 0.21
  )

  expected_liveweight <- 25 * 450
  expected_carcass <- expected_liveweight * 0.58
  expect_equal(result$output_meat_production_carcassweight, expected_carcass)
})

test_that("compute_meat_outputs calculates boneless meat correctly", {
  result <- compute_meat_outputs(
    offtake_number_assessment = 30,
    slaughter_weight = 350,
    carcass_dressing_percentage = 0.55,
    bone_free_meat_fraction = 0.70,
    meat_protein = 0.20
  )

  expected_liveweight <- 30 * 350
  expected_carcass <- expected_liveweight * 0.55
  expected_meat <- expected_carcass * 0.70
  expect_equal(result$output_meat_production_meat, expected_meat)
})

test_that("compute_meat_outputs calculates meat protein correctly", {
  result <- compute_meat_outputs(
    offtake_number_assessment = 20,
    slaughter_weight = 400,
    carcass_dressing_percentage = 0.56,
    bone_free_meat_fraction = 0.75,
    meat_protein = 0.23
    )

  expected_liveweight <- 20 * 400
  expected_carcass <- expected_liveweight * 0.56
  expected_meat <- expected_carcass * 0.75
  expected_protein <- expected_meat * 0.23
  expect_equal(result$output_meat_production_protein, expected_protein)
})

test_that("compute_meat_outputs handles zero offtake", {
  result <- compute_meat_outputs(
    offtake_number_assessment = 0,
    slaughter_weight = 400,
    carcass_dressing_percentage = 0.55,
    bone_free_meat_fraction = 0.75,
    meat_protein = 0.20
  )

  expect_equal(result$output_meat_production_liveweight, 0)
  expect_equal(result$output_meat_production_carcassweight, 0)
  expect_equal(result$output_meat_production_meat, 0)
  expect_equal(result$output_meat_production_protein, 0)
})

test_that("compute_meat_outputs handles zero slaughter weight", {
  result <- compute_meat_outputs(
    offtake_number_assessment = 10,
    slaughter_weight = 0,
    carcass_dressing_percentage = 0.55,
    bone_free_meat_fraction = 0.75,
    meat_protein = 0.20
  )

  expect_equal(result$output_meat_production_liveweight, 0)
  expect_equal(result$output_meat_production_carcassweight, 0)
  expect_equal(result$output_meat_production_meat, 0)
  expect_equal(result$output_meat_production_protein, 0)
})

test_that("compute_meat_outputs verifies sequential calculation chain", {
  result <- compute_meat_outputs(
    offtake_number_assessment = 100,
    slaughter_weight = 300,
    carcass_dressing_percentage = 0.50,
    bone_free_meat_fraction = 0.80,
    meat_protein = 0.25
  )

  # Verify the chain: liveweight -> carcass -> meat -> protein
  liveweight <- result$output_meat_production_liveweight
  carcass <- result$output_meat_production_carcassweight
  meat <- result$output_meat_production_meat
  protein <- result$output_meat_production_protein

  expect_equal(carcass, liveweight * 0.50)
  expect_equal(meat, carcass * 0.80)
  expect_equal(protein, meat * 0.25)
})

test_that("compute_meat_outputs handles validation errors", {
  expect_error(
    compute_meat_outputs(
      offtake_number_assessment = -10, slaughter_weight = 400,
      carcass_dressing_percentage = 0.55, bone_free_meat_fraction = 0.75,
      meat_protein = 0.20
    ),
    "offtake_number_assessment"
  )

  expect_error(
    compute_meat_outputs(
      offtake_number_assessment = 10, slaughter_weight = -400,
      carcass_dressing_percentage = 0.55, bone_free_meat_fraction = 0.75,
      meat_protein = 0.20
    ),
    "slaughter_weight"
  )

  expect_error(
    compute_meat_outputs(
      offtake_number_assessment = 10, slaughter_weight = 400,
      carcass_dressing_percentage = 1.5, bone_free_meat_fraction = 0.75,
      meat_protein = 0.20
    ),
    "carcass_dressing_percentage"
  )

  expect_error(
    compute_meat_outputs(
      offtake_number_assessment = 10, slaughter_weight = 400,
      carcass_dressing_percentage = 0.55, bone_free_meat_fraction = -0.1,
      meat_protein = 0.20
    ),
    "bone_free_meat_fraction"
  )

  expect_error(
    compute_meat_outputs(
      offtake_number_assessment = 10, slaughter_weight = 400,
      carcass_dressing_percentage = 0.55, bone_free_meat_fraction = 0.75,
      meat_protein = 1.5
    ),
    "meat_protein"
  )
})
