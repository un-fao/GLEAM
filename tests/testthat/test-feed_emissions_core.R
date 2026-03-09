# CO2: fertilizer
test_that("calc_diet_co2_feed_fertilizer computes contribution", {
  expect_equal(calc_diet_co2_feed_fertilizer(0.6, 10), 6)
})

test_that("calc_diet_co2_feed_fertilizer allows NA for co2_feed_fertilizer", {
  value <- calc_diet_co2_feed_fertilizer(0.6, NA_real_)
  expect_true(is.na(value))
})

test_that("calc_diet_co2_feed_fertilizer rejects negative co2_feed_fertilizer", {
  expect_error(
    calc_diet_co2_feed_fertilizer(0.6, -1),
    "must be >= 0"
  )
})

test_that("calc_diet_co2_feed_fertilizer rejects invalid co2_feed_fertilizer type/length", {
  expect_error(
    calc_diet_co2_feed_fertilizer(0.6, c(1, 2)),
    "must be a single numeric"
  )
})

test_that("calc_diet_co2_feed_fertilizer rejects NA feed_ration_fraction", {
  expect_error(
    calc_diet_co2_feed_fertilizer(NA_real_, 10),
    "must not contain missing values"
  )
})


# CO2: pesticides
test_that("calc_diet_co2_feed_pesticides computes contribution", {
  expect_equal(calc_diet_co2_feed_pesticides(0.6, 10), 6)
})

test_that("calc_diet_co2_feed_pesticides allows NA for co2_feed_pesticides", {
  value <- calc_diet_co2_feed_pesticides(0.6, NA_real_)
  expect_true(is.na(value))
})

test_that("calc_diet_co2_feed_pesticides rejects negative co2_feed_pesticides", {
  expect_error(
    calc_diet_co2_feed_pesticides(0.6, -1),
    "must be >= 0"
  )
})

test_that("calc_diet_co2_feed_pesticides rejects invalid co2_feed_pesticides type/length", {
  expect_error(
    calc_diet_co2_feed_pesticides(0.6, "10"),
    "must be a single numeric"
  )
})


# CO2: crop operations
test_that("calc_diet_co2_feed_crop_operations computes contribution", {
  expect_equal(calc_diet_co2_feed_crop_operations(0.6, 10), 6)
})

test_that("calc_diet_co2_feed_crop_operations allows NA for co2_feed_crop_operations", {
  value <- calc_diet_co2_feed_crop_operations(0.6, NA_real_)
  expect_true(is.na(value))
})

test_that("calc_diet_co2_feed_crop_operations rejects negative co2_feed_crop_operations", {
  expect_error(
    calc_diet_co2_feed_crop_operations(0.6, -1),
    "must be >= 0"
  )
})

test_that("calc_diet_co2_feed_crop_operations rejects invalid co2_feed_crop_operations type/length", {
  expect_error(
    calc_diet_co2_feed_crop_operations(0.6, c(1, 2)),
    "must be a single numeric"
  )
})


# CO2: LUC no peat
test_that("calc_diet_co2_feed_luc_nopeat computes contribution", {
  expect_equal(calc_diet_co2_feed_luc_nopeat(0.6, 10), 6)
})

test_that("calc_diet_co2_feed_luc_nopeat allows NA for co2_feed_luc_nopeat", {
  value <- calc_diet_co2_feed_luc_nopeat(0.6, NA_real_)
  expect_true(is.na(value))
})

test_that("calc_diet_co2_feed_luc_nopeat rejects invalid co2_feed_luc_nopeat type/length", {
  expect_error(
    calc_diet_co2_feed_luc_nopeat(0.6, c(1, 2)),
    "must be a single numeric"
  )
})


# CO2: LUC peat
test_that("calc_diet_co2_feed_luc_peat computes contribution", {
  expect_equal(calc_diet_co2_feed_luc_peat(0.6, 10), 6)
})

test_that("calc_diet_co2_feed_luc_peat allows NA for co2_feed_luc_peat", {
  value <- calc_diet_co2_feed_luc_peat(0.6, NA_real_)
  expect_true(is.na(value))
})

test_that("calc_diet_co2_feed_luc_peat rejects invalid co2_feed_luc_peat type/length", {
  expect_error(
    calc_diet_co2_feed_luc_peat(0.6, c(1, 2)),
    "must be a single numeric"
  )
})


# N2O: fertilizer
test_that("calc_diet_n2o_feed_fertilizer computes contribution", {
  expect_equal(calc_diet_n2o_feed_fertilizer(0.6, 10), 6)
})

test_that("calc_diet_n2o_feed_fertilizer allows NA for n2o_feed_fertilizer", {
  value <- calc_diet_n2o_feed_fertilizer(0.6, NA_real_)
  expect_true(is.na(value))
})

test_that("calc_diet_n2o_feed_fertilizer rejects negative n2o_feed_fertilizer", {
  expect_error(
    calc_diet_n2o_feed_fertilizer(0.6, -1),
    "must be >= 0"
  )
})

test_that("calc_diet_n2o_feed_fertilizer rejects invalid n2o_feed_fertilizer type/length", {
  expect_error(
    calc_diet_n2o_feed_fertilizer(0.6, "10"),
    "must be a single numeric"
  )
})


# N2O: manure applied
test_that("calc_diet_n2o_feed_manure_applied computes contribution", {
  expect_equal(calc_diet_n2o_feed_manure_applied(0.6, 10), 6)
})

test_that("calc_diet_n2o_feed_manure_applied allows NA for n2o_feed_manure_applied", {
  value <- calc_diet_n2o_feed_manure_applied(0.6, NA_real_)
  expect_true(is.na(value))
})

test_that("calc_diet_n2o_feed_manure_applied rejects negative n2o_feed_manure_applied", {
  expect_error(
    calc_diet_n2o_feed_manure_applied(0.6, -1),
    "must be >= 0"
  )
})

test_that("calc_diet_n2o_feed_manure_applied rejects invalid n2o_feed_manure_applied type/length", {
  expect_error(
    calc_diet_n2o_feed_manure_applied(0.6, c(1, 2)),
    "must be a single numeric"
  )
})


# N2O: crop residues
test_that("calc_diet_n2o_feed_crop_residues computes contribution", {
  expect_equal(calc_diet_n2o_feed_crop_residues(0.6, 10), 6)
})

test_that("calc_diet_n2o_feed_crop_residues allows NA for n2o_feed_crop_residues", {
  value <- calc_diet_n2o_feed_crop_residues(0.6, NA_real_)
  expect_true(is.na(value))
})

test_that("calc_diet_n2o_feed_crop_residues rejects negative n2o_feed_crop_residues", {
  expect_error(
    calc_diet_n2o_feed_crop_residues(0.6, -1),
    "must be >= 0"
  )
})

test_that("calc_diet_n2o_feed_crop_residues rejects invalid n2o_feed_crop_residues type/length", {
  expect_error(
    calc_diet_n2o_feed_crop_residues(0.6, "10"),
    "must be a single numeric"
  )
})


# CH4: rice
test_that("calc_diet_ch4_feed_rice computes contribution", {
  expect_equal(calc_diet_ch4_feed_rice(0.6, 10), 6)
})

test_that("calc_diet_ch4_feed_rice allows NA for ch4_feed_rice", {
  value <- calc_diet_ch4_feed_rice(0.6, NA_real_)
  expect_true(is.na(value))
})

test_that("calc_diet_ch4_feed_rice rejects negative ch4_feed_rice", {
  expect_error(
    calc_diet_ch4_feed_rice(0.6, -1),
    "must be >= 0"
  )
})

test_that("calc_diet_ch4_feed_rice rejects invalid ch4_feed_rice type/length", {
  expect_error(
    calc_diet_ch4_feed_rice(0.6, c(1, 2)),
    "must be a single numeric"
  )
})
