# ---- validate_feed_rations_inputs --------------------------------------------
test_that("validate_feed_rations_inputs passes for valid inputs", {
  rations_share <- data.table::data.table(
    herd_id = 1,
    animal = "Cattle",
    feed_name = "MAIZE",
    feed_id = 1,
    cohort = "FJ",
    ration = 0.5
  )
  feed_params <- data.table::data.table(
    feed_id = 1,
    feed_name = "MAIZE",
    category = "Cereals",
    GE = 18,
    DE_ruminants = 12,
    DE_pigs = 10,
    ME_ruminants = 11,
    ME_pigs = 9,
    ME_chickens = 8,
    N_content = 0.02
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
    GE = 18,
    DE_ruminants = 12,
    DE_pigs = 10,
    ME_ruminants = 11,
    ME_pigs = 9,
    ME_chickens = 8,
    N_content = 0.02
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
    ration = 0.5
  )
  feed_params <- data.table::data.table(
    feed_id = c(1, 1),
    feed_name = c("MAIZE", "MAIZE"),
    category = c("Cereals", "Cereals"),
    GE = c(18, 18),
    DE_ruminants = c(12, 12),
    DE_pigs = c(10, 10),
    ME_ruminants = c(11, 11),
    ME_pigs = c(9, 9),
    ME_chickens = c(8, 8),
    N_content = c(0.02, 0.02)
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
    ration = 0.5
  )
  feed_params <- data.table::data.table(
    feed_id = 1,
    feed_name = "MAIZE",
    category = "Cereals",
    GE = 18,
    DE_ruminants = 12,
    DE_pigs = 10,
    ME_ruminants = 11,
    ME_pigs = 9,
    ME_chickens = 8,
    N_content = 0.02
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
    ration = 0.5
  )
  feed_params <- data.table::data.table(
    feed_id = 1,
    feed_name = "MAIZE",
    category = "Cereals",
    GE = 18,
    DE_ruminants = 12,
    DE_pigs = 10,
    ME_ruminants = 11,
    ME_pigs = 9,
    ME_chickens = 8,
    N_content = 0.02
  )

  expect_error(
    validate_feed_rations_inputs(rations_share, feed_params),
    "missing or mismatched feed_name"
  )
})
