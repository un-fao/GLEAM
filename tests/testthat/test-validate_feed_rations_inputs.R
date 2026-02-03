# ---- validate_feed_rations_inputs --------------------------------------------
test_that("validate_feed_rations_inputs passes for valid inputs", {
  rations_share <- data.table::data.table(
    herd_id = 1,
    animal = "Cattle",
    feed_name = "MAIZE",
    feed_id = 1,
    cohort = "FJ",
    feed_ration_fraction = 0.5
  )
  feed_params <- data.table::data.table(
    feed_id = 1,
    feed_name = "MAIZE",
    category = "Cereals",
    feed_gross_energy = 18,
    feed_digestible_energy_ruminant = 12,
    feed_digestible_energy_pigs = 10,
    feed_metabolizable_energy_ruminant = 11,
    feed_metabolizable_energy_pigs = 9,
    feed_metabolizable_energy_chicken = 8,
    feed_nitrogen_content = 0.02
  )

  expect_silent(validate_feed_rations_inputs(rations_share, feed_params))
})

test_that("validate_feed_rations_inputs rejects missing rations columns", {
  rations_share <- data.table::data.table(
    herd_id = 1,
    animal = "Cattle",
    feed_name = "MAIZE",
    feed_id = 1,
    cohort = "FJ"
  )
  feed_params <- data.table::data.table(
    feed_id = 1,
    feed_name = "MAIZE",
    category = "Cereals",
    feed_gross_energy = 18,
    feed_digestible_energy_ruminant = 12,
    feed_digestible_energy_pigs = 10,
    feed_metabolizable_energy_ruminant = 11,
    feed_metabolizable_energy_pigs = 9,
    feed_metabolizable_energy_chicken = 8,
    feed_nitrogen_content = 0.02
  )

  expect_error(
    validate_feed_rations_inputs(rations_share, feed_params),
    "Missing required columns"
  )
})

test_that("validate_feed_rations_inputs rejects duplicate feed_id in feed_params", {
  rations_share <- data.table::data.table(
    herd_id = 1,
    animal = "Cattle",
    feed_name = "MAIZE",
    feed_id = 1,
    cohort = "FJ",
    feed_ration_fraction = 0.5
  )
  feed_params <- data.table::data.table(
    feed_id = c(1, 1),
    feed_name = c("MAIZE", "MAIZE"),
    category = c("Cereals", "Cereals"),
    feed_gross_energy = c(18, 18),
    feed_digestible_energy_ruminant = c(12, 12),
    feed_digestible_energy_pigs = c(10, 10),
    feed_metabolizable_energy_ruminant = c(11, 11),
    feed_metabolizable_energy_pigs = c(9, 9),
    feed_metabolizable_energy_chicken = c(8, 8),
    feed_nitrogen_content = c(0.02, 0.02)
  )

  expect_error(
    validate_feed_rations_inputs(rations_share, feed_params),
    "must be unique"
  )
})

test_that("validate_feed_rations_inputs rejects missing feed_id in feed_params", {
  rations_share <- data.table::data.table(
    herd_id = 1,
    animal = "Cattle",
    feed_name = "MAIZE",
    feed_id = 2,
    cohort = "FJ",
    feed_ration_fraction = 0.5
  )
  feed_params <- data.table::data.table(
    feed_id = 1,
    feed_name = "MAIZE",
    category = "Cereals",
    feed_gross_energy = 18,
    feed_digestible_energy_ruminant = 12,
    feed_digestible_energy_pigs = 10,
    feed_metabolizable_energy_ruminant = 11,
    feed_metabolizable_energy_pigs = 9,
    feed_metabolizable_energy_chicken = 8,
    feed_nitrogen_content = 0.02
  )

  expect_error(
    validate_feed_rations_inputs(rations_share, feed_params),
    "missing or mismatched feed_name"
  )
})

test_that("validate_feed_rations_inputs rejects mismatched feed_name", {
  rations_share <- data.table::data.table(
    herd_id = 1,
    animal = "Cattle",
    feed_name = "BARLEY",
    feed_id = 1,
    cohort = "FJ",
    feed_ration_fraction = 0.5
  )
  feed_params <- data.table::data.table(
    feed_id = 1,
    feed_name = "MAIZE",
    category = "Cereals",
    feed_gross_energy = 18,
    feed_digestible_energy_ruminant = 12,
    feed_digestible_energy_pigs = 10,
    feed_metabolizable_energy_ruminant = 11,
    feed_metabolizable_energy_pigs = 9,
    feed_metabolizable_energy_chicken = 8,
    feed_nitrogen_content = 0.02
  )

  expect_error(
    validate_feed_rations_inputs(rations_share, feed_params),
    "missing or mismatched feed_name"
  )
})
