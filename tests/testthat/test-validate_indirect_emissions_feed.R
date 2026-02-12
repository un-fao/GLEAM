test_that("validate_feed_indirect_emissions_inputs passes for valid inputs", {
  rations_share <- data.table::data.table(
    herd_id = c(1, 1),
    animal = c("Cattle", "Cattle"),
    feed_name = c("MAIZE", "BARLEY"),
    feed_id = c(1, 2),
    cohort_short = c("FJ", "FJ"),
    feed_ration_fraction = c(0.5, 0.5)
  )
  
  feed_indirect_emissions <- data.table::data.table(
    feed_id = c(1, 2),
    feed_name = c("MAIZE", "BARLEY"),
    co2_feed_fertilizer = c(10, 11),
    co2_feed_pesticides = c(1, 2),
    co2_feed_crop_operations = c(3, 4),
    co2_feed_luc_nopeat = c(5, 6),
    co2_feed_luc_peat = c(NA_real_, 0),
    n2o_feed_fertilizer = c(0.1, 0.2),
    n2o_feed_manure_applied = c(0.3, 0.4),
    n2o_feed_crop_residues = c(0.5, 0.6),
    ch4_feed_rice = c(0, NA_real_)
  )
  
  expect_silent(validate_feed_indirect_emissions_inputs(rations_share, feed_indirect_emissions))
})

test_that("validate_feed_indirect_emissions_inputs rejects missing rations columns", {
  rations_share <- data.table::data.table(
    herd_id = 1,
    animal = "Cattle",
    feed_name = "MAIZE",
    feed_id = 1,
    cohort_short = "FJ"
  )
  
  feed_indirect_emissions <- data.table::data.table(
    feed_id = 1,
    feed_name = "MAIZE",
    co2_feed_fertilizer = 10,
    co2_feed_pesticides = 1,
    co2_feed_crop_operations = 3,
    co2_feed_luc_nopeat = 5,
    co2_feed_luc_peat = NA_real_,
    n2o_feed_fertilizer = 0.1,
    n2o_feed_manure_applied = 0.3,
    n2o_feed_crop_residues = 0.5,
    ch4_feed_rice = 0
  )
  
  expect_error(
    validate_feed_indirect_emissions_inputs(rations_share, feed_indirect_emissions),
    "Missing required columns"
  )
})

test_that("validate_feed_indirect_emissions_inputs rejects missing emissions columns", {
  rations_share <- data.table::data.table(
    herd_id = 1,
    animal = "Cattle",
    feed_name = "MAIZE",
    feed_id = 1,
    cohort_short = "FJ",
    feed_ration_fraction = 1
  )
  
  feed_indirect_emissions <- data.table::data.table(
    feed_id = 1,
    feed_name = "MAIZE",
    co2_feed_fertilizer = 10
    # missing the rest
  )
  
  expect_error(
    validate_feed_indirect_emissions_inputs(rations_share, feed_indirect_emissions),
    "Missing required columns"
  )
})

test_that("validate_feed_indirect_emissions_inputs rejects duplicate feed_id in feed_indirect_emissions", {
  rations_share <- data.table::data.table(
    herd_id = 1,
    animal = "Cattle",
    feed_name = "MAIZE",
    feed_id = 1,
    cohort_short = "FJ",
    feed_ration_fraction = 1
  )
  
  feed_indirect_emissions <- data.table::data.table(
    feed_id = c(1, 1),
    feed_name = c("MAIZE", "MAIZE"),
    co2_feed_fertilizer = c(10, 10),
    co2_feed_pesticides = c(1, 1),
    co2_feed_crop_operations = c(3, 3),
    co2_feed_luc_nopeat = c(5, 5),
    co2_feed_luc_peat = c(NA_real_, NA_real_),
    n2o_feed_fertilizer = c(0.1, 0.1),
    n2o_feed_manure_applied = c(0.3, 0.3),
    n2o_feed_crop_residues = c(0.5, 0.5),
    ch4_feed_rice = c(0, 0)
  )
  
  expect_error(
    validate_feed_indirect_emissions_inputs(rations_share, feed_indirect_emissions),
    "must be unique"
  )
})

test_that("validate_feed_indirect_emissions_inputs rejects missing feed_id in feed_indirect_emissions", {
  rations_share <- data.table::data.table(
    herd_id = 1,
    animal = "Cattle",
    feed_name = "MAIZE",
    feed_id = 2,
    cohort_short = "FJ",
    feed_ration_fraction = 1
  )
  
  feed_indirect_emissions <- data.table::data.table(
    feed_id = 1,
    feed_name = "MAIZE",
    co2_feed_fertilizer = 10,
    co2_feed_pesticides = 1,
    co2_feed_crop_operations = 3,
    co2_feed_luc_nopeat = 5,
    co2_feed_luc_peat = NA_real_,
    n2o_feed_fertilizer = 0.1,
    n2o_feed_manure_applied = 0.3,
    n2o_feed_crop_residues = 0.5,
    ch4_feed_rice = 0
  )
  
  expect_error(
    validate_feed_indirect_emissions_inputs(rations_share, feed_indirect_emissions),
    "missing or mismatched feed_name"
  )
})

test_that("validate_feed_indirect_emissions_inputs rejects mismatched feed_name", {
  rations_share <- data.table::data.table(
    herd_id = 1,
    animal = "Cattle",
    feed_name = "BARLEY",
    feed_id = 1,
    cohort_short = "FJ",
    feed_ration_fraction = 1
  )
  
  feed_indirect_emissions <- data.table::data.table(
    feed_id = 1,
    feed_name = "MAIZE",
    co2_feed_fertilizer = 10,
    co2_feed_pesticides = 1,
    co2_feed_crop_operations = 3,
    co2_feed_luc_nopeat = 5,
    co2_feed_luc_peat = NA_real_,
    n2o_feed_fertilizer = 0.1,
    n2o_feed_manure_applied = 0.3,
    n2o_feed_crop_residues = 0.5,
    ch4_feed_rice = 0
  )
  
  expect_error(
    validate_feed_indirect_emissions_inputs(rations_share, feed_indirect_emissions),
    "missing or mismatched feed_name"
  )
})

test_that("validate_feed_indirect_emissions_inputs rejects non-numeric indirect emissions values", {
  rations_share <- data.table::data.table(
    herd_id = 1,
    animal = "Cattle",
    feed_name = "MAIZE",
    feed_id = 1,
    cohort_short = "FJ",
    feed_ration_fraction = 1
  )
  
  feed_indirect_emissions <- data.table::data.table(
    feed_id = 1,
    feed_name = "MAIZE",
    co2_feed_fertilizer = "10", # invalid type
    co2_feed_pesticides = 1,
    co2_feed_crop_operations = 3,
    co2_feed_luc_nopeat = 5,
    co2_feed_luc_peat = NA_real_,
    n2o_feed_fertilizer = 0.1,
    n2o_feed_manure_applied = 0.3,
    n2o_feed_crop_residues = 0.5,
    ch4_feed_rice = 0
  )
  
  expect_error(
    validate_feed_indirect_emissions_inputs(rations_share, feed_indirect_emissions),
    "must be a single numeric"
  )
})

