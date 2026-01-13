# ---- test calc_net_energy_maintenance ----
test_that("calc_net_energy_maintenance returns correct values for cattle", {
  # Test adult female with milking fraction
  result <- calc_net_energy_maintenance(
    animal = "CTL", cohort = "FA", average_weight = 500,
    milking_fraction = 0.7
  )
  expected <- (500^0.75) * (0.386 * 0.7 + 0.322 * 0.3)
  expect_equal(result, expected)

  # Test juvenile female
  result <- calc_net_energy_maintenance(
    animal = "CTL", cohort = "FJ", average_weight = 200
  )
  expected <- (200^0.75) * 0.322
  expect_equal(result, expected)

  # Test adult male with offtake
  result <- calc_net_energy_maintenance(
    animal = "CTL", cohort = "MA", average_weight = 600,
    offtake_rate = 0.3
  )
  expected <- (600^0.75) * (0.322 * 0.3 + 0.37 * 0.7)
  expect_equal(result, expected)
})

test_that("calc_net_energy_maintenance handles sheep with age at first calving", {
  # Test subadult female with afc
  result <- calc_net_energy_maintenance(
    animal = "SHP", cohort = "FS", average_weight = 40,
    afc = 400
  )
  expected <- (40^0.75) * ((0.236 * (1/400)) + (0.217 * (399/400)))
  expect_equal(result, expected)

  # Test adult female
  result <- calc_net_energy_maintenance(
    animal = "SHP", cohort = "FA", average_weight = 60
  )
  expected <- (60^0.75) * 0.217
  expect_equal(result, expected)
})

test_that("calc_net_energy_maintenance handles pigs with physiological states", {
  result <- calc_net_energy_maintenance(
    animal = "PGS", cohort = "FA", average_weight = 150)

  expected <- (150^0.75) * 0.4435
  expect_equal(result, expected)
})

test_that("calc_net_energy_maintenance handles fixed coefficients", {
  # Test camelids
  result <- calc_net_energy_maintenance(
    animal = "CML", cohort = "FA", average_weight = 400
  )
  expected <- (400^0.75) * 0.435
  expect_equal(result, expected)

  # Test goats
  result <- calc_net_energy_maintenance(
    animal = "GTS", cohort = "FA", average_weight = 50
  )
  expected <- (50^0.75) * 0.315
  expect_equal(result, expected)
})

test_that("calc_net_energy_maintenance calculates correctly for zero milking_fraction", {
  expected <- (500^0.75) * 0.322
  result <- calc_net_energy_maintenance(animal = "CTL", cohort = "FA", average_weight = 500, milking_fraction = 0)
  expect_equal(result, expected, tolerance = 1e-8)
})

test_that("calc_net_energy_maintenance handles offtake extremes", {
  expect_equal(
    calc_net_energy_maintenance(animal = "CTL", cohort = "MA", average_weight = 600, offtake_rate = 0),
    (600^0.75) * 0.37, tolerance = 1e-8
  )
  expect_equal(
    calc_net_energy_maintenance(animal = "CTL", cohort = "MA", average_weight = 600, offtake_rate = 1),
    (600^0.75) * 0.322, tolerance = 1e-8
  )
})

# ---- test calc_net_energy_activity ----
test_that("calc_net_energy_activity returns correct values for cattle", {
  nemain <- 15.0
  result <- calc_net_energy_activity(
    animal = "CTL", cohort = "FA",
    nemain = nemain, average_weight = 500,
    activity_fraction = 0.6, high_activity_fraction = 0.2
  )
  cact <- (0.17 * 0.6) + (0.36 * 0.2)
  expected <- cact * nemain
  expect_equal(result, expected)
})

test_that("calc_net_energy_activity returns correct values for buffalo", {
  nemain <- 18.0
  result <- calc_net_energy_activity(
    animal = "BFL", cohort = "FA",
    nemain = nemain, average_weight = 600,
    activity_fraction = 0.5, high_activity_fraction = 0.2
  )
  cact <- (0.17 * 0.5) + (0.36 * 0.2)
  expected <- cact * nemain
  expect_equal(result, expected)
})

test_that("calc_net_energy_activity handles sheep complexity", {
  result <- calc_net_energy_activity(
    animal = "SHP", cohort = "MS",
    nemain = 8.0, average_weight = 45,
    activity_fraction = 0.5, high_activity_fraction = 0.2
  )
  cact <- (0.0107 * 0.5) +  (0.024 * 0.2)
  expected <- cact * 45
  expect_equal(result, expected)

  # Test adult female sheep (fixed coefficient)
  result <- calc_net_energy_activity(
    animal = "SHP", cohort = "FA",
    nemain = 8.0, average_weight = 60,
    activity_fraction = 0.5, high_activity_fraction = 0.2
  )
  cact <- (0.0107 * 0.5) +  (0.024 * 0.2)
  expected <- cact * 60
  expect_equal(result, expected)
})

test_that("calc_net_energy_activity handles different species", {
  # Test camelids
  result <- calc_net_energy_activity(
    animal = "CML", cohort = "FA",
    nemain = 12.0, average_weight = 400,
    activity_fraction = 0.5, high_activity_fraction = 0
  )
  expected <- (0.1 * 0.5) * 12.0
  expect_equal(result, expected)

  # Test pigs
  result <- calc_net_energy_activity(
    animal = "PGS", cohort = "FA",
    nemain = 10.0, average_weight = 150,
    activity_fraction = 0.5, high_activity_fraction = 0.3
  )
  expected <- 0.125 * (0.5 + 0.3) * 10.0
  expect_equal(result, expected)

  # Test goats
  result <- calc_net_energy_activity(
    animal = "GTS", cohort = "FA",
    nemain = 8.0, average_weight = 50,
    activity_fraction = 0.4, high_activity_fraction = 0.2
  )
  expected <- ((0.019 * 0.4) + (0.024 * 0.2)) * 50
  expect_equal(result, expected)
})

test_that("calc_net_energy_activity handles zero high_activity_fraction for cattle", {
  nemain <- 12.0
  result <- calc_net_energy_activity(
    animal = "CTL", cohort = "FA",
    nemain = nemain, average_weight = 500,
    activity_fraction = 0.6, high_activity_fraction = 0
  )
  cact <- (0.17 * 0.6) + (0.36 * 0)
  expected <- cact * nemain
  expect_equal(result, expected)
})


# ---- test calc_net_energy_growth ----
test_that("calc_net_energy_growth returns correct values for cattle", {
  result <- calc_net_energy_growth(
    animal = "CTL", cohort = "FJ",
    average_weight = 200, final_weight = 300,
    initial_weight = 150, adult_weight = 500, dwg = 0.5, offtake_rate = 0.1, duration = 100
  )
  expected <- 22.02 * ((200 / (0.8 * 500))^0.75) * (0.5^1.097)
  expect_equal(result, expected)

  # Test adult cohort (no growth)
  result <- calc_net_energy_growth(
    animal = "CTL", cohort = "FA",
    average_weight = 500, final_weight = 500,
    initial_weight = 500, adult_weight = 500, dwg = 0, offtake_rate = 0.1, duration = 365
  )
  expect_equal(result, 0)
})

test_that("calc_net_energy_growth handles sheep linear formula", {
  result <- calc_net_energy_growth(
    animal = "SHP", cohort = "FJ",
    average_weight = 30, final_weight = 50,
    initial_weight = 25,  adult_weight = 60, dwg = 0.1, offtake_rate = 0.1, duration = 250
  )
  expected <- ((50 - 25) * (2.1 + 0.5 * 0.45 * (25 + 50))) / 250
  expect_equal(result, expected)

  # Test adult sheep (no growth)
  result <- calc_net_energy_growth(
    animal = "SHP", cohort = "FA",
    average_weight = 60, final_weight = 60,
    initial_weight = 60,  adult_weight = 60, dwg = 0, offtake_rate = 0.1, duration = 365
  )
  expect_equal(result, 0)
})

test_that("calc_net_energy_growth handles pigs", {
  result <- calc_net_energy_growth(
    animal = "PGS", cohort = "FJ",
    average_weight = 50, final_weight = 80,
    initial_weight = 40,  adult_weight = 300, dwg = 0.3, offtake_rate = 0.1, duration = 133
  )
  prot_tissue_frac <- 0.65
  cgro <- (prot_tissue_frac * 0.23 * 54) + ((1 - prot_tissue_frac) * 0.9 * 52.3)
  expected <- 0.3 * cgro
  expect_equal(result, expected)
})

# ---- test calc_net_energy_lactation ----
test_that("calc_net_energy_lactation returns correct values for cattle", {
  result <- calc_net_energy_lactation(
    animal = "CTL", cohort = "FA",
    milking_fraction = 0.8, milk_yield = 20, milk_fat = 0.04,
    idle = 0, gest = 0, litsize = 1, dr1 = 0, ckg = 35, wkg = 90,
    lact = 0, parturition_rate = 0.8
  )
  
  expected <- ((20 * 0.8) + (0.8 * 5 * (90 - 35) / 365)) * (0.04 * 100 * 0.40 + 1.47)
  expect_equal(result, expected)
})

test_that("calc_net_energy_lactation handles sheep with litter size", {
  result <- calc_net_energy_lactation(
    animal = "SHP", cohort = "FA",
    milking_fraction = 0.9, milk_yield = 1.5, milk_fat = 0.06,
    idle = 0, gest = 0, litsize = 1.5, dr1 = 0, ckg = 4, wkg = 18,
    lact = 0, parturition_rate = 1.2
  )
  expected <- ((1.5 * 0.9) + (1.5 * 1.2 * 5 * (18 - 4) / 365)) * 4.6
  expect_equal(result, expected)
})

test_that("calc_net_energy_lactation handles pigs", {
  result <- calc_net_energy_lactation(
    animal = "PGS", cohort = "FA",
    milking_fraction = 0, milk_yield = 0, milk_fat = 0,
    idle = 0.2, gest = 0.3, litsize = 10, dr1 = 0.1, ckg = 1.5, wkg = 8,
    lact = 0.5, parturition_rate = 2.2
  )
  cadj <- 0.5 / (0.2 + 0.3 + 0.5)
  expected <- 10 * (1 - 0.5 * 0.1) * ((0.02059 * (8 - 1.5) * 1000 / 0.5) - (0.3766 / 0.67)) * cadj
  expect_equal(result, expected)
})

# ---- test calc_net_energy_work ----
test_that("calc_net_energy_work returns correct values for working animals", {
  # Test cattle adult male
  result <- calc_net_energy_work(
    animal = "CTL", cohort = "MA",
    nemain = 20.0, work_hours = 4, draught_fraction = 0.3
  )
  expected <- 0.1 * 20.0 * 4 * 0.3
  expect_equal(result, expected)

  # Test non-working cohort
  result <- calc_net_energy_work(
    animal = "CTL", cohort = "FA",
    nemain = 15.0, work_hours = 4, draught_fraction = 0.3
  )
  expect_equal(result, 0)
})

test_that("calc_net_energy_work handles different species", {
  # Test camelids
  result <- calc_net_energy_work(
    animal = "CML", cohort = "MA",
    nemain = 18.0, work_hours = 6, draught_fraction = 0.4
  )
  expected <- 4 * 6 * 0.4
  expect_equal(result, expected)

  # Test species that don't work
  result <- calc_net_energy_work(
    animal = "SHP", cohort = "MA",
    nemain = 10.0, work_hours = 4, draught_fraction = 0.3
  )
  expect_equal(result, 0)
})

# ---- test calc_net_energy_fibre ----
test_that("calc_net_energy_fibre returns correct values for fibre-producing animals", {
  # Test sheep
  result <- calc_net_energy_fibre(
    animal = "SHP", cohort = "FA", fibre_prod = 2.5
  )
  expected <- 24 * 2.5 / 365
  expect_equal(result, expected)

  # Test juvenile sheep (no fibre)
  result <- calc_net_energy_fibre(
    animal = "SHP", cohort = "FJ", fibre_prod = 1.0
  )
  expect_equal(result, 0)
})

test_that("calc_net_energy_fibre handles camelids", {
  result <- calc_net_energy_fibre(
    animal = "CML", cohort = "FA", fibre_prod = 3.0
  )
  expected <- (24 / 0.43) * (3.0 / 365)
  expect_equal(result, expected)
})

test_that("calc_net_energy_fibre returns zero for non-fibre animals", {
  result <- calc_net_energy_fibre(
    animal = "CTL", cohort = "FA", fibre_prod = 1.0
  )
  expect_equal(result, 0)
})

# ---- test calc_net_energy_pregnancy ----
test_that("calc_net_energy_pregnancy returns correct values for cattle", {
  result <- calc_net_energy_pregnancy(
    animal = "CTL", cohort = "FA",
    nemain = 15.0, parturition_rate = 0.8,
   litsize = 1, gest = 283,  
   idle = 10, lact = 30,
   duration = 730, offtake_rate = 0.2
  )
  expected <- 15.0 * 0.1 * 0.8 * 283 / 365
  expect_equal(result, expected)

  # Test subadult female
  result <- calc_net_energy_pregnancy(
    animal = "CTL", cohort = "FS",
    nemain = 12.0, parturition_rate = 0.8,
    litsize = 1, gest = 283, 
    idle = 10, lact = 30,
    duration = 730, offtake_rate = 0.2
  )
  expected <- (12.0 * 0.1) * (283 / 730) * (1 - 0.2)
  expect_equal(result, expected)
})

test_that("calc_net_energy_pregnancy handles sheep with litter size effects", {
  # Test with litter size 1.5
  result <- calc_net_energy_pregnancy(
    animal = "SHP", cohort = "FA",
    nemain = 8.0, parturition_rate = 1.2, 
    litsize = 1.5, gest = 152, 
    idle = 10, lact = 30,
    duration = 700, offtake_rate = 0.1
  )
  cpreg <- (0.077 * 0.5 + 0.126 * 0.5)
  expected <- 8.0 * cpreg * 1.2 * 152 / 365
  expect_equal(result, expected)

  # Test with litter size > 2
  result <- calc_net_energy_pregnancy(
    animal = "SHP", cohort = "FA",
    nemain = 8.0, parturition_rate = 1.2,
    litsize = 2.5, gest = 152, 
    idle = 10, lact = 30,
    duration = 365, offtake_rate = 0.1
  )
  expected <- 8.0 * 0.150 * 1.2 * 152 / 365
  expect_equal(result, expected)
})

test_that("calc_net_energy_pregnancy handles pigs", {
  result <- calc_net_energy_pregnancy(
    animal = "PGS", cohort = "FA",
    nemain = 12.0, parturition_rate = 2.2,
    litsize = 10, gest = 115, 
    idle = 10, lact = 30,
    duration = 365, offtake_rate = 0.1
  )
  expected <- 0.14985 * 10 * 115 / (10 + 115 + 30)
  expect_equal(result, expected)
})

# ---- test calc_rem_maintenance ----
test_that("calc_rem_maintenance returns correct values for ruminants", {
  result <- calc_rem_maintenance("CTL", 0.65)
  expected <- 1.123 - (0.004092 * 65) + (0.00001126 * 65^2) - (25.4 / 65)
  expect_equal(result, expected)

  result <- calc_rem_maintenance("SHP", 0.55)
  expected <- 1.123 - (0.004092 * 55) + (0.00001126 * 55^2) - (25.4 / 55)
  expect_equal(result, expected)
})

test_that("calc_rem_maintenance returns NA for non-ruminants", {
  expect_true(is.na(calc_rem_maintenance("PGS", 0.75)))
  expect_true(is.na(calc_rem_maintenance("CHK", 0.70)))
  expect_true(is.na(calc_rem_maintenance("CML", 0.60)))
})

# ---- test calc_reg_growth ----
test_that("calc_reg_growth returns correct values for ruminants", {
  result <- calc_reg_growth("CTL", 0.65)
  expected <- 1.164 - (0.005160 * 65) + (0.00001308 * 65^2) - (37.4 / 65)
  expect_equal(result, expected)

  result <- calc_reg_growth("GTS", 0.55)
  expected <- 1.164 - (0.005160 * 55) + (0.00001308 * 55^2) - (37.4 / 55)
  expect_equal(result, expected)
})

test_that("calc_reg_growth returns NA for non-ruminants", {
  expect_true(is.na(calc_reg_growth("PGS", 0.75)))
  expect_true(is.na(calc_reg_growth("CHK", 0.70)))
  expect_true(is.na(calc_reg_growth("CML", 0.60)))
})

# ---- test calc_total_energy_requirement ----
test_that("calc_total_energy_requirement returns correct values for cattle", {
  result <- calc_total_energy_requirement(
    animal = "CTL", cohort = "FA",
    nemain = 15.0, neact = 3.0, nelact = 8.0, nework = 0, nepreg = 1.5,
    rem = 0.6, negrow = 0, nefibre = 0, neegg = 0, reg = 0.5, diet_dig = 0.65, afc = 730
  )
  expected <- (((15.0 + 3.0 + 8.0 + 0 + 1.5) / 0.6) + (0 / 0.5)) / 0.65
  expect_equal(result, expected)
})

test_that("calc_total_energy_requirement handles sheep with fibre", {
  result <- calc_total_energy_requirement(
    animal = "SHP", cohort = "FA",
    nemain = 8.0, neact = 1.5, nelact = 4.0, nework = 0, nepreg = 1.0,
    rem = 0.55, negrow = 0, nefibre = 0.2, neegg = 0, reg = 0.45, diet_dig = 0.60, afc = 400
  )
  expected <- (((8.0 + 1.5 + 4.0 + 1.0) / 0.55) + ((0 + 0.2) / 0.45)) / 0.60
  expect_equal(result, expected)
})

test_that("calc_total_energy_requirement handles different species", {
  # Test camelids (direct sum)
  result <- calc_total_energy_requirement(
    animal = "CML", cohort = "FA",
    nemain = 12.0, neact = 2.0, nelact = 6.0, nework = 1.0, nepreg = 1.5,
    rem = NA, negrow = 0, nefibre = 0.3, neegg = 0, reg = NA, diet_dig = 0.70, afc = 730
  )
  expected <- 12.0 + 2.0 + 6.0 + 1.0 + 0.3 + 1.5 + 0
  expect_equal(result, expected)

  # Test pigs
  result <- calc_total_energy_requirement(
    animal = "PGS", cohort = "FA",
    nemain = 10.0, neact = 1.0, nelact = 5.0, nework = 0, nepreg = 2.0,
    rem = NA, negrow = 0, nefibre = 0, neegg = 0, reg = NA, diet_dig = 0.75, afc = 365
  )
  expected <- 10.0 + 1.0 + 5.0 + 2.0 + 0
  expect_equal(result, expected)
})

# ---- test calc_dry_matter_intake ----
test_that("calc_dry_matter_intake uses gross energy for ruminants", {
  result <- calc_dry_matter_intake(
    animal = "CTL", total_energy = 25.0, diet_ge = 18.5, diet_me = 12.0
  )
  expected <- 25.0 / 18.5
  expect_equal(result, expected)

  result <- calc_dry_matter_intake(
    animal = "SHP", total_energy = 12.0, diet_ge = 16.0, diet_me = 10.5
  )
  expected <- 12.0 / 16.0
  expect_equal(result, expected)
})

test_that("calc_dry_matter_intake uses metabolizable energy for monogastrics", {
  result <- calc_dry_matter_intake(
    animal = "PGS", total_energy = 15.0, diet_ge = 18.0, diet_me = 13.5
  )
  expected <- 15.0 / 13.5
  expect_equal(result, expected)

  result <- calc_dry_matter_intake(
    animal = "CHK", total_energy = 8.0, diet_ge = 16.5, diet_me = 11.0
  )
  expected <- 8.0 / 11.0
  expect_equal(result, expected)

  result <- calc_dry_matter_intake(
    animal = "CML", total_energy = 20.0, diet_ge = 17.0, diet_me = 12.5
  )
  expected <- 20.0 / 12.5
  expect_equal(result, expected)
})
