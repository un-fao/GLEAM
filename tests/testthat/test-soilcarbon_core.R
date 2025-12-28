# ---- test calc_soil_carbon with provided reference ----
test_that("calc_soil_carbon with provided soil_carbon_reference returns expected results", {
  # Create mock parameter tables
  management_params <- data.table::data.table(
    climate_zone = "TropicalMoist",
    management_type = c("ImprovedMediumInput", "ImprovedHighInput"),
    V1 = c(1.17, 1.25)
  )

  luc_factors <- data.table::data.table(
    climate_zone = "TropicalMoist",
    V1 = 1.0
  )

  # Soil type params not used when reference provided
  soil_type_params <- data.table::data.table(
    climate_zone = "TropicalMoist",
    soil_type = "HighActivityClay",
    V1 = 40
  )

  result <- calc_soil_carbon(
    area = 100,
    climate_zone = "TropicalMoist",
    soil_carbon_reference = 40,
    soil_type = "HighActivityClay",
    management_start = "ImprovedMediumInput",
    management_end = "ImprovedHighInput",
    management_params = management_params,
    soil_type_params = soil_type_params,
    luc_factors = luc_factors
  )

  expect_type(result, "list")
  expect_named(result, c("SOC1", "SOC2", "dSOC"))

  # Check calculations: SOC1 = 100 * 40 * 1.17 * 1.0 = 4680
  expect_equal(result$SOC1, 100 * 40 * 1.17 * 1.0, tolerance = 1e-10)

  # Check calculations: SOC2 = 100 * 40 * 1.25 * 1.0 = 5000
  expect_equal(result$SOC2, 100 * 40 * 1.25 * 1.0, tolerance = 1e-10)

  # Check calculations: dSOC = (5000 - 4680) / 20 = 16
  expect_equal(result$dSOC, (5000 - 4680) / 20, tolerance = 1e-10)
})

# ---- test calc_soil_carbon with lookup from soil_type_params ----
test_that("calc_soil_carbon lookup from soil_type_params works correctly", {
  # Create mock parameter tables
  management_params <- data.table::data.table(
    climate_zone = "WarmTemperateDry",
    management_type = c("SeverelyDegraded", "NonDegraded"),
    V1 = c(0.75, 1.0)
  )

  soil_type_params <- data.table::data.table(
    climate_zone = "WarmTemperateDry",
    soil_type = "Sandy",
    V1 = 24
  )

  luc_factors <- data.table::data.table(
    climate_zone = "WarmTemperateDry",
    V1 = 1.0
  )

  result <- calc_soil_carbon(
    area = 50,
    climate_zone = "WarmTemperateDry",
    soil_carbon_reference = NA_real_,
    soil_type = "Sandy",
    management_start = "SeverelyDegraded",
    management_end = "NonDegraded",
    management_params = management_params,
    soil_type_params = soil_type_params,
    luc_factors = luc_factors
  )

  expect_type(result, "list")
  expect_named(result, c("SOC1", "SOC2", "dSOC"))

  # Check calculations: SOC1 = 50 * 24 * 0.75 * 1.0 = 900
  expect_equal(result$SOC1, 50 * 24 * 0.75 * 1.0, tolerance = 1e-10)

  # Check calculations: SOC2 = 50 * 24 * 1.0 * 1.0 = 1200
  expect_equal(result$SOC2, 50 * 24 * 1.0 * 1.0, tolerance = 1e-10)

  # Check calculations: dSOC = (1200 - 900) / 20 = 15
  expect_equal(result$dSOC, (1200 - 900) / 20, tolerance = 1e-10)
})

# ---- test calc_soil_carbon handles zero area ----
test_that("calc_soil_carbon handles zero area correctly", {
  management_params <- data.table::data.table(
    climate_zone = "TropicalMoist",
    management_type = c("ImprovedMediumInput", "ImprovedHighInput"),
    V1 = c(1.17, 1.25)
  )

  soil_type_params <- data.table::data.table(
    climate_zone = "TropicalMoist",
    soil_type = "HighActivityClay",
    V1 = 40
  )

  luc_factors <- data.table::data.table(
    climate_zone = "TropicalMoist",
    V1 = 1.0
  )

  result <- calc_soil_carbon(
    area = 0,
    climate_zone = "TropicalMoist",
    soil_carbon_reference = 40,
    soil_type = "HighActivityClay",
    management_start = "ImprovedMediumInput",
    management_end = "ImprovedHighInput",
    management_params = management_params,
    soil_type_params = soil_type_params,
    luc_factors = luc_factors
  )

  expect_equal(result$SOC1, 0)
  expect_equal(result$SOC2, 0)
  expect_equal(result$dSOC, 0)
})

# ---- test calc_soil_carbon error handling for missing soil_type_params ----
test_that("calc_soil_carbon errors when soil_type_params lookup fails", {
  management_params <- data.table::data.table(
    climate_zone = "TropicalMoist",
    management_type = c("ImprovedMediumInput", "ImprovedHighInput"),
    V1 = c(1.17, 1.25)
  )

  # Missing soil type for this climate zone
  soil_type_params <- data.table::data.table(
    climate_zone = "DifferentZone",
    soil_type = "HighActivityClay",
    V1 = 40
  )

  luc_factors <- data.table::data.table(
    climate_zone = "TropicalMoist",
    V1 = 1.0
  )

  expect_error(
    calc_soil_carbon(
      area = 100,
      climate_zone = "TropicalMoist",
      soil_carbon_reference = NA_real_,
      soil_type = "HighActivityClay",
      management_start = "ImprovedMediumInput",
      management_end = "ImprovedHighInput",
      management_params = management_params,
      soil_type_params = soil_type_params,
      luc_factors = luc_factors
    ),
    "No SOCref found"
  )
})

# ---- test calc_soil_carbon error handling for missing management factors ----
test_that("calc_soil_carbon errors when management factor lookup fails", {
  # Missing starting management
  management_params <- data.table::data.table(
    climate_zone = "TropicalMoist",
    management_type = "ImprovedHighInput",
    V1 = 1.25
  )

  soil_type_params <- data.table::data.table(
    climate_zone = "TropicalMoist",
    soil_type = "HighActivityClay",
    V1 = 40
  )

  luc_factors <- data.table::data.table(
    climate_zone = "TropicalMoist",
    V1 = 1.0
  )

  expect_error(
    calc_soil_carbon(
      area = 100,
      climate_zone = "TropicalMoist",
      soil_carbon_reference = 40,
      soil_type = "HighActivityClay",
      management_start = "SeverelyDegraded",
      management_end = "ImprovedHighInput",
      management_params = management_params,
      soil_type_params = soil_type_params,
      luc_factors = luc_factors
    ),
    "No management factor found for starting"
  )
})

# ---- test calc_soil_carbon with positive carbon increase ----
test_that("calc_soil_carbon correctly calculates positive carbon increase", {
  management_params <- data.table::data.table(
    climate_zone = "CoolTemperateMoist",
    management_type = c("Degraded", "ImprovedHighInput"),
    V1 = c(0.85, 1.2)
  )

  soil_type_params <- data.table::data.table(
    climate_zone = "CoolTemperateMoist",
    soil_type = "Volcanic",
    V1 = 81
  )

  luc_factors <- data.table::data.table(
    climate_zone = "CoolTemperateMoist",
    V1 = 1.0
  )

  result <- calc_soil_carbon(
    area = 75,
    climate_zone = "CoolTemperateMoist",
    soil_carbon_reference = NA_real_,
    soil_type = "Volcanic",
    management_start = "Degraded",
    management_end = "ImprovedHighInput",
    management_params = management_params,
    soil_type_params = soil_type_params,
    luc_factors = luc_factors
  )

  # With improvement, SOC2 should be higher than SOC1
  expect_gt(result$SOC2, result$SOC1)
  expect_gt(result$dSOC, 0)  # Positive change

  # Verify the calculation
  expected_SOC1 <- 75 * 81 * 0.85 * 1.0
  expected_SOC2 <- 75 * 81 * 1.2 * 1.0
  expected_dSOC <- (expected_SOC2 - expected_SOC1) / 20

  expect_equal(result$SOC1, expected_SOC1, tolerance = 1e-10)
  expect_equal(result$SOC2, expected_SOC2, tolerance = 1e-10)
  expect_equal(result$dSOC, expected_dSOC, tolerance = 1e-10)
})

# ---- test calc_soil_carbon with negative carbon change (degradation) ----
test_that("calc_soil_carbon correctly calculates negative carbon change", {
  management_params <- data.table::data.table(
    climate_zone = "WarmTemperateDry",
    management_type = c("NonDegraded", "HighIntensityGrazing"),
    V1 = c(1.0, 0.7)
  )

  soil_type_params <- data.table::data.table(
    climate_zone = "WarmTemperateDry",
    soil_type = "Sandy",
    V1 = 24
  )

  luc_factors <- data.table::data.table(
    climate_zone = "WarmTemperateDry",
    V1 = 1.0
  )

  result <- calc_soil_carbon(
    area = 100,
    climate_zone = "WarmTemperateDry",
    soil_carbon_reference = NA_real_,
    soil_type = "Sandy",
    management_start = "NonDegraded",
    management_end = "HighIntensityGrazing",
    management_params = management_params,
    soil_type_params = soil_type_params,
    luc_factors = luc_factors
  )

  # With degradation, SOC2 should be lower than SOC1
  expect_lt(result$SOC2, result$SOC1)
  expect_lt(result$dSOC, 0)  # Negative change

  # Verify the calculation
  expected_SOC1 <- 100 * 24 * 1.0 * 1.0
  expected_SOC2 <- 100 * 24 * 0.7 * 1.0
  expected_dSOC <- (expected_SOC2 - expected_SOC1) / 20

  expect_equal(result$SOC1, expected_SOC1, tolerance = 1e-10)
  expect_equal(result$SOC2, expected_SOC2, tolerance = 1e-10)
  expect_equal(result$dSOC, expected_dSOC, tolerance = 1e-10)
})

# ---- test calc_soil_carbon returns numeric values ----
test_that("calc_soil_carbon returns numeric values", {
  management_params <- data.table::data.table(
    climate_zone = "TropicalMoist",
    management_type = c("ImprovedMediumInput", "ImprovedHighInput"),
    V1 = c(1.17, 1.25)
  )

  soil_type_params <- data.table::data.table(
    climate_zone = "TropicalMoist",
    soil_type = "HighActivityClay",
    V1 = 40
  )

  luc_factors <- data.table::data.table(
    climate_zone = "TropicalMoist",
    V1 = 1.0
  )

  result <- calc_soil_carbon(
    area = 100,
    climate_zone = "TropicalMoist",
    soil_carbon_reference = 40,
    soil_type = "HighActivityClay",
    management_start = "ImprovedMediumInput",
    management_end = "ImprovedHighInput",
    management_params = management_params,
    soil_type_params = soil_type_params,
    luc_factors = luc_factors
  )

  expect_type(result$SOC1, "double")
  expect_type(result$SOC2, "double")
  expect_type(result$dSOC, "double")
})
