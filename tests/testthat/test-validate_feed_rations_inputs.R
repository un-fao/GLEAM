# ---- validate_feed_rations_inputs --------------------------------------------
test_that("validate_feed_rations_inputs passes for valid inputs", {
  rations_share <- data.table::data.table(
    herd_id = c(1, 1),
    animal = c("Cattle", "Cattle"),
    feed_name = c("MAIZE", "BARLEY"),
    feed_id = c(1, 2),
    cohort_short = c("FJ", "FJ"),
    feed_ration_fraction = c(0.5, 0.5)
  )
  feed_params <- data.table::data.table(
    feed_id = c(1, 2),
    feed_name = c("MAIZE", "BARLEY"),
    category = c("Cereals", "Cereals"),
    feed_gross_energy = c(18, 17),
    feed_digestible_energy_ruminant = c(12, 11),
    feed_digestible_energy_pigs = c(10, 9),
    feed_metabolizable_energy_ruminant = c(11, 10),
    feed_metabolizable_energy_pigs = c(9, 8),
    feed_metabolizable_energy_chicken = c(8, 7),
    feed_nitrogen_content = c(0.02, 0.018),
    feed_urinary_energy_ruminant = c(0.12, 0.11),
    feed_urinary_energy_pigs = c(0.02, 0.02),
    feed_urinary_energy_chicken = c(0.04, 0.03),
    feed_ash_content = c(1.4, 2.6)
  )

  expect_silent(validate_feed_rations_inputs(rations_share, feed_params))
})

test_that("validate_feed_rations_inputs rejects missing rations columns", {
  rations_share <- data.table::data.table(
    herd_id = 1,
    animal = "Cattle",
    feed_name = "MAIZE",
    feed_id = 1,
    cohort_short = "FJ"
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
    feed_nitrogen_content = 0.02,
    feed_urinary_energy_ruminant = 0.12,
    feed_urinary_energy_pigs = 0.02,
    feed_urinary_energy_chicken = 0.04,
    feed_ash_content = 1.4
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
    cohort_short = "FJ",
    feed_ration_fraction = 1
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
    feed_nitrogen_content = c(0.02, 0.02),
    feed_urinary_energy_ruminant = c(0.12, 0.12),
    feed_urinary_energy_pigs = c(0.02, 0.02),
    feed_urinary_energy_chicken = c(0.04, 0.04),
    feed_ash_content = c(1.4, 1.4)
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
    cohort_short = "FJ",
    feed_ration_fraction = 1
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
    feed_nitrogen_content = 0.02,
    feed_urinary_energy_ruminant = 0.12,
    feed_urinary_energy_pigs = 0.02,
    feed_urinary_energy_chicken = 0.04,
    feed_ash_content = 1.4
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
    cohort_short = "FJ",
    feed_ration_fraction = 1
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
    feed_nitrogen_content = 0.02,
    feed_urinary_energy_ruminant = 0.12,
    feed_urinary_energy_pigs = 0.02,
    feed_urinary_energy_chicken = 0.04,
    feed_ash_content = 1.4
  )

  expect_error(
    validate_feed_rations_inputs(rations_share, feed_params),
    "missing or mismatched feed_name"
  )
})
