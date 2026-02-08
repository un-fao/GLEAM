# ---- validate_directemissions_manure_inputs ----------------------------------
make_valid_input <- function() {
  data.table::data.table(
    herd_id = rep(1, 6),
    cohort = c("FJ", "FS", "FA", "MJ", "MS", "MA"),
    dry_matter_intake = c(2, 3, 4, 2, 3, 4),
    diet_digestibility_fraction = rep(0.6, 6),
    nitrogen_excretion = rep(0.9, 6)
  )
}

make_valid_mms_fraction <- function() {
  data.table::data.table(
    herd_id = rep(1, 12),
    cohort = rep(c("FJ", "FS", "FA", "MJ", "MS", "MA"), each = 2),
    manure_management_system = rep(c("mms_pasture", "mms_solid"), times = 6),
    fraction = rep(c(0.7, 0.3), times = 6)
  )
}

make_valid_mms_factors <- function() {
  data.table::data.table(
    herd_id = c(1, 1),
    manure_management_system = c("mms_pasture", "mms_solid"),
    methane_conversion_factor_mcf = c(0.47, 5),
    ch4_max_producing_capacity_bo = c(0.19, 0.13),
    n2o_ef3 = c(0.02, 0.005),
    n2o_ef4 = c(0.14, 0.14),
    n2o_ef5 = c(0.011, 0.011),
    nitrogen_fracgas = c(0.21, 0.12),
    nitrogen_fracleach = c(0.24, 0.02)
  )
}

test_that("validate_directemissions_manure_inputs passes for valid inputs", {
  expect_silent(
    validate_directemissions_manure_inputs(
      make_valid_input(),
      make_valid_mms_fraction(),
      make_valid_mms_factors()
    )
  )
})

test_that("validate_directemissions_manure_inputs rejects missing required columns", {
  input <- data.table::data.table(
    herd_id = 1,
    cohort = "FA",
    dry_matter_intake = 4,
    diet_digestibility_fraction = 0.6
  )
  mms_fraction <- data.table::data.table(
    herd_id = 1,
    cohort = "FA",
    manure_management_system = "mms_pasture",
    fraction = 1
  )
  mms_factors <- data.table::data.table(
    herd_id = 1,
    manure_management_system = "mms_pasture",
    methane_conversion_factor_mcf = 0.47,
    ch4_max_producing_capacity_bo = 0.19,
    n2o_ef3 = 0.02,
    n2o_ef4 = 0.14,
    n2o_ef5 = 0.011,
    nitrogen_fracgas = 0.21,
    nitrogen_fracleach = 0.24
  )
  
  expect_error(
    validate_directemissions_manure_inputs(input, mms_fraction, mms_factors),
    "Missing required columns"
  )
})

test_that("validate_directemissions_manure_inputs rejects non-data.table inputs", {
  expect_error(
    validate_directemissions_manure_inputs(
      data.frame(),
      make_valid_mms_fraction(),
      make_valid_mms_factors()
    ),
    "must be a data.table"
  )
})

test_that("validate_directemissions_manure_inputs rejects empty inputs", {
  expect_error(
    validate_directemissions_manure_inputs(
      make_valid_input()[0],
      make_valid_mms_fraction(),
      make_valid_mms_factors()
    ),
    "must contain at least one row"
  )
})

test_that("validate_directemissions_manure_inputs rejects missing cohorts in input", {
  input <- make_valid_input()[cohort != "MA"]
  
  expect_error(
    validate_directemissions_manure_inputs(
      input,
      make_valid_mms_fraction(),
      make_valid_mms_factors()
    ),
    "exactly 6 rows"
  )
})

test_that("validate_directemissions_manure_inputs rejects duplicate MMS rows", {
  input <- make_valid_input()
  mms_fraction <- make_valid_mms_fraction()
  mms_fraction <- data.table::rbindlist(list(
    mms_fraction,
    data.table::data.table(
      herd_id = 1,
      cohort = "FA",
      manure_management_system = "mms_pasture",
      fraction = 0.7
    )
  ))
  mms_factors <- make_valid_mms_factors()
  
  expect_error(
    validate_directemissions_manure_inputs(input, mms_fraction, mms_factors),
    "Duplicate herd_id"
  )
})

test_that("validate_directemissions_manure_inputs rejects mismatched MMS lists", {
  input <- make_valid_input()
  mms_fraction <- make_valid_mms_fraction()
  mms_factors <- data.table::data.table(
    herd_id = c(1, 1),
    manure_management_system = c("mms_pasture", "mms_drylot"),
    methane_conversion_factor_mcf = c(0.47, 2),
    ch4_max_producing_capacity_bo = c(0.19, 0.13),
    n2o_ef3 = c(0.02, 0.005),
    n2o_ef4 = c(0.14, 0.14),
    n2o_ef5 = c(0.011, 0.011),
    nitrogen_fracgas = c(0.21, 0.12),
    nitrogen_fracleach = c(0.24, 0.02)
  )
  
  expect_error(
    validate_directemissions_manure_inputs(input, mms_fraction, mms_factors),
    "Mismatch in manure_management_system lists"
  )
})

test_that("validate_directemissions_manure_inputs rejects missing herd_id in factors", {
  input <- make_valid_input()
  mms_fraction <- make_valid_mms_fraction()
  mms_factors <- data.table::data.table(
    herd_id = c(2, 2),
    manure_management_system = c("mms_pasture", "mms_solid"),
    methane_conversion_factor_mcf = c(0.47, 5),
    ch4_max_producing_capacity_bo = c(0.19, 0.13),
    n2o_ef3 = c(0.02, 0.005),
    n2o_ef4 = c(0.14, 0.14),
    n2o_ef5 = c(0.011, 0.011),
    nitrogen_fracgas = c(0.21, 0.12),
    nitrogen_fracleach = c(0.24, 0.02)
  )
  
  expect_error(
    validate_directemissions_manure_inputs(input, mms_fraction, mms_factors),
    "not found in"
  )
})

test_that("validate_directemissions_manure_inputs rejects missing herd_id + cohort combinations", {
  input <- make_valid_input()
  mms_fraction <- data.table::data.table(
    herd_id = rep(1, 10),
    cohort = rep(c("FJ", "FS", "FA", "MJ", "MS"), each = 2),
    manure_management_system = rep(c("mms_pasture", "mms_solid"), times = 5),
    fraction = rep(c(0.7, 0.3), times = 5)
  )
  mms_factors <- make_valid_mms_factors()
  
  expect_error(
    validate_directemissions_manure_inputs(input, mms_fraction, mms_factors),
    "must include all 6 cohorts"
  )
})

test_that("validate_directemissions_manure_inputs rejects invalid cohort values", {
  input <- make_valid_input()
  input$cohort[1] <- "XX"

  expect_error(
    validate_directemissions_manure_inputs(
      input,
      make_valid_mms_fraction(),
      make_valid_mms_factors()
    ),
    "Invalid cohort values"
  )
})

test_that("validate_directemissions_manure_inputs rejects invalid cohorts in MMS fraction", {
  mms_fraction <- make_valid_mms_fraction()
  mms_fraction$cohort[1] <- "XX"

  expect_error(
    validate_directemissions_manure_inputs(
      make_valid_input(),
      mms_fraction,
      make_valid_mms_factors()
    ),
    "Invalid cohort values"
  )
})

test_that("validate_directemissions_manure_inputs rejects inconsistent MMS lists by cohort", {
  mms_fraction <- make_valid_mms_fraction()
  mms_fraction <- mms_fraction[!(herd_id == 1 & cohort == "FA")]
  mms_fraction <- data.table::rbindlist(list(
    mms_fraction,
    data.table::data.table(
      herd_id = 1,
      cohort = "FA",
      manure_management_system = "mms_drylot",
      fraction = 1
    )
  ))
  mms_factors <- data.table::rbindlist(list(
    make_valid_mms_factors(),
    data.table::data.table(
      herd_id = 1,
      manure_management_system = "mms_drylot",
      methane_conversion_factor_mcf = 2,
      ch4_max_producing_capacity_bo = 0.12,
      n2o_ef3 = 0.01,
      n2o_ef4 = 0.14,
      n2o_ef5 = 0.011,
      nitrogen_fracgas = 0.2,
      nitrogen_fracleach = 0.05
    )
  ))

  expect_error(
    validate_directemissions_manure_inputs(
      make_valid_input(),
      mms_fraction,
      mms_factors
    ),
    "must be consistent across cohorts"
  )
})
