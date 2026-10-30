# CO2: fertilizer
test_that("calc_co2_ration_fertilizer computes contribution", {
  expect_equal(calc_co2_ration_fertilizer(0.6, 10), 6)
})

test_that("calc_co2_ration_fertilizer allows NA for co2_feed_fertilizer", {
  value <- calc_co2_ration_fertilizer(0.6, NA_real_)
  expect_true(is.na(value))
})

test_that("calc_co2_ration_fertilizer rejects negative co2_feed_fertilizer", {
  expect_error(
    calc_co2_ration_fertilizer(0.6, -1),
    "must be >= 0"
  )
})

test_that("calc_co2_ration_fertilizer rejects invalid co2_feed_fertilizer type/length", {
  expect_error(
    calc_co2_ration_fertilizer(0.6, c(1, 2)),
    "must be a single numeric"
  )
})

test_that("calc_co2_ration_fertilizer rejects NA feed_ration_fraction", {
  expect_error(
    calc_co2_ration_fertilizer(NA_real_, 10),
    "must not contain missing values"
  )
})


# CO2: pesticides
test_that("calc_co2_ration_pesticides computes contribution", {
  expect_equal(calc_co2_ration_pesticides(0.6, 10), 6)
})

test_that("calc_co2_ration_pesticides allows NA for co2_feed_pesticides", {
  value <- calc_co2_ration_pesticides(0.6, NA_real_)
  expect_true(is.na(value))
})

test_that("calc_co2_ration_pesticides rejects negative co2_feed_pesticides", {
  expect_error(
    calc_co2_ration_pesticides(0.6, -1),
    "must be >= 0"
  )
})

test_that("calc_co2_ration_pesticides rejects invalid co2_feed_pesticides type/length", {
  expect_error(
    calc_co2_ration_pesticides(0.6, "10"),
    "must be a single numeric"
  )
})


# CO2: crop operations
test_that("calc_co2_ration_crop_activities computes contribution", {
  expect_equal(calc_co2_ration_crop_activities(0.6, 10), 6)
})

test_that("calc_co2_ration_crop_activities allows NA for co2_feed_crop_activities", {
  value <- calc_co2_ration_crop_activities(0.6, NA_real_)
  expect_true(is.na(value))
})

test_that("calc_co2_ration_crop_activities rejects negative co2_feed_crop_activities", {
  expect_error(
    calc_co2_ration_crop_activities(0.6, -1),
    "must be >= 0"
  )
})

test_that("calc_co2_ration_crop_activities rejects invalid co2_feed_crop_activities type/length", {
  expect_error(
    calc_co2_ration_crop_activities(0.6, c(1, 2)),
    "must be a single numeric"
  )
})


# CO2: LUC no peat
test_that("calc_co2_ration_luc_nopeat computes contribution", {
  expect_equal(calc_co2_ration_luc_nopeat(0.6, 10), 6)
})

test_that("calc_co2_ration_luc_nopeat allows NA for co2_feed_luc_nopeat", {
  value <- calc_co2_ration_luc_nopeat(0.6, NA_real_)
  expect_true(is.na(value))
})

test_that("calc_co2_ration_luc_nopeat rejects invalid co2_feed_luc_nopeat type/length", {
  expect_error(
    calc_co2_ration_luc_nopeat(0.6, c(1, 2)),
    "must be a single numeric"
  )
})


# CO2: LUC peat
test_that("calc_co2_ration_luc_peat computes contribution", {
  expect_equal(calc_co2_ration_luc_peat(0.6, 10), 6)
})

test_that("calc_co2_ration_luc_peat allows NA for co2_feed_luc_peat", {
  value <- calc_co2_ration_luc_peat(0.6, NA_real_)
  expect_true(is.na(value))
})

test_that("calc_co2_ration_luc_peat rejects invalid co2_feed_luc_peat type/length", {
  expect_error(
    calc_co2_ration_luc_peat(0.6, c(1, 2)),
    "must be a single numeric"
  )
})


# N2O: fertilizer
test_that("calc_n2o_ration_fertilizer computes contribution", {
  expect_equal(calc_n2o_ration_fertilizer(0.6, 10), 6)
})

test_that("calc_n2o_ration_fertilizer allows NA for n2o_feed_fertilizer", {
  value <- calc_n2o_ration_fertilizer(0.6, NA_real_)
  expect_true(is.na(value))
})

test_that("calc_n2o_ration_fertilizer rejects negative n2o_feed_fertilizer", {
  expect_error(
    calc_n2o_ration_fertilizer(0.6, -1),
    "must be >= 0"
  )
})

test_that("calc_n2o_ration_fertilizer rejects invalid n2o_feed_fertilizer type/length", {
  expect_error(
    calc_n2o_ration_fertilizer(0.6, "10"),
    "must be a single numeric"
  )
})


# N2O: manure applied
test_that("calc_n2o_ration_manure computes contribution", {
  expect_equal(calc_n2o_ration_manure(0.6, 10), 6)
})

test_that("calc_n2o_ration_manure allows NA for n2o_feed_manure_applied", {
  value <- calc_n2o_ration_manure(0.6, NA_real_)
  expect_true(is.na(value))
})

test_that("calc_n2o_ration_manure rejects negative n2o_feed_manure_applied", {
  expect_error(
    calc_n2o_ration_manure(0.6, -1),
    "must be >= 0"
  )
})

test_that("calc_n2o_ration_manure rejects invalid n2o_feed_manure_applied type/length", {
  expect_error(
    calc_n2o_ration_manure(0.6, c(1, 2)),
    "must be a single numeric"
  )
})


# N2O: crop residues
test_that("calc_n2o_ration_crop_residues computes contribution", {
  expect_equal(calc_n2o_ration_crop_residues(0.6, 10), 6)
})

test_that("calc_n2o_ration_crop_residues allows NA for n2o_feed_crop_residues", {
  value <- calc_n2o_ration_crop_residues(0.6, NA_real_)
  expect_true(is.na(value))
})

test_that("calc_n2o_ration_crop_residues rejects negative n2o_feed_crop_residues", {
  expect_error(
    calc_n2o_ration_crop_residues(0.6, -1),
    "must be >= 0"
  )
})

test_that("calc_n2o_ration_crop_residues rejects invalid n2o_feed_crop_residues type/length", {
  expect_error(
    calc_n2o_ration_crop_residues(0.6, "10"),
    "must be a single numeric"
  )
})


# CH4: rice
test_that("calc_ch4_ration_rice computes contribution", {
  expect_equal(calc_ch4_ration_rice(0.6, 10), 6)
})

test_that("calc_ch4_ration_rice allows NA for ch4_feed_rice", {
  value <- calc_ch4_ration_rice(0.6, NA_real_)
  expect_true(is.na(value))
})

test_that("calc_ch4_ration_rice rejects negative ch4_feed_rice", {
  expect_error(
    calc_ch4_ration_rice(0.6, -1),
    "must be >= 0"
  )
})

test_that("calc_ch4_ration_rice rejects invalid ch4_feed_rice type/length", {
  expect_error(
    calc_ch4_ration_rice(0.6, c(1, 2)),
    "must be a single numeric"
  )
})
