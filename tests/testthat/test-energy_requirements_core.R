# ---- test calc_net_energy_maintenance ----
test_that("calc_net_energy_maintenance returns correct values for cattle", {
  # Test adult female with lactating fraction
  result <- calc_net_energy_maintenance(
    species_short = "CTL", cohort_short = "FA", live_weight_cohort_average = 500,
    lactating_females_fraction = 0.7
  )
  expected <- (500^0.75) * (0.386 * 0.7 + 0.322 * 0.3)
  expect_equal(result, expected)

  # Test juvenile female
  result <- calc_net_energy_maintenance(
    species_short = "CTL", cohort_short = "FJ", live_weight_cohort_average = 200
  )
  expected <- (200^0.75) * 0.322
  expect_equal(result, expected)

  # Test adult male with offtake
  result <- calc_net_energy_maintenance(
    species_short = "CTL", cohort_short = "MA", live_weight_cohort_average = 600,
    offtake_rate = 0.3
  )
  expected <- (600^0.75) * (0.322 * 0.3 + 0.37 * 0.7)
  expect_equal(result, expected)
})

test_that("calc_net_energy_maintenance handles sheep with age at first parturition", {
  # Test subadult female with age_first_parturition
  result <- calc_net_energy_maintenance(
    species_short = "SHP", cohort_short = "FS", live_weight_cohort_average = 40,
    age_first_parturition = 400
  )
  expected <- (40^0.75) * ((0.236 * (365/400)) + (0.217 * ((400-365)/400)))
  expect_equal(result, expected)

  # Test adult female
  result <- calc_net_energy_maintenance(
    species_short = "SHP", cohort_short = "FA", live_weight_cohort_average = 60
  )
  expected <- (60^0.75) * 0.217
  expect_equal(result, expected)
})

test_that("calc_net_energy_maintenance handles pigs with physiological states", {
  result <- calc_net_energy_maintenance(
    species_short = "PGS", cohort_short = "FA", live_weight_cohort_average = 150)

  expected <- (150^0.75) * 0.4435
  expect_equal(result, expected)
})

test_that("calc_net_energy_maintenance handles fixed coefficients", {
  # Test camelids
  result <- calc_net_energy_maintenance(
    species_short = "CML", cohort_short = "FA", live_weight_cohort_average = 400
  )
  expected <- (400^0.75) * 0.435
  expect_equal(result, expected)

  # Test goats
  result <- calc_net_energy_maintenance(
    species_short = "GTS", cohort_short = "FA", live_weight_cohort_average = 50
  )
  expected <- (50^0.75) * 0.315
  expect_equal(result, expected)
})

test_that("calc_net_energy_maintenance calculates correctly for zero lactating_females_fraction", {
  expected <- (500^0.75) * 0.322
  result <- calc_net_energy_maintenance(species_short = "CTL", cohort_short = "FA", live_weight_cohort_average = 500, lactating_females_fraction = 0)
  expect_equal(result, expected, tolerance = 1e-8)
})

# ---- test calc_net_energy_activity ----
test_that("calc_net_energy_activity returns correct values for cattle", {
  energy_requirement_maintenance <- 15.0
  result <- calc_net_energy_activity(
    species_short = "CTL", cohort_short = "FA",
    energy_requirement_maintenance = energy_requirement_maintenance, live_weight_cohort_average = 500,
    low_activity_fraction = 0.6, high_activity_fraction = 0.2
  )
  cact <- (0.17 * 0.6) + (0.36 * 0.2)
  expected <- cact * energy_requirement_maintenance
  expect_equal(result, expected)
})

test_that("calc_net_energy_activity returns correct values for buffalo", {
  energy_requirement_maintenance <- 18.0
  result <- calc_net_energy_activity(
    species_short = "BFL", cohort_short = "FA",
    energy_requirement_maintenance = energy_requirement_maintenance, live_weight_cohort_average = 600,
    low_activity_fraction = 0.5, high_activity_fraction = 0.2
  )
  cact <- (0.17 * 0.5) + (0.36 * 0.2)
  expected <- cact * energy_requirement_maintenance
  expect_equal(result, expected)
})

test_that("calc_net_energy_activity handles sheep complexity", {
  result <- calc_net_energy_activity(
    species_short = "SHP", cohort_short = "MS",
    energy_requirement_maintenance = 8.0, live_weight_cohort_average = 45,
    low_activity_fraction = 0.5, high_activity_fraction = 0.2
  )
  cact <- (0.0107 * 0.5) +  (0.024 * 0.2)
  expected <- cact * 45
  expect_equal(result, expected)

  result <- calc_net_energy_activity(
    species_short = "SHP", cohort_short = "FA",
    energy_requirement_maintenance = 8.0, live_weight_cohort_average = 60,
    low_activity_fraction = 0.5, high_activity_fraction = 0.2
  )
  cact <- (0.0107 * 0.5) +  (0.024 * 0.2)
  expected <- cact * 60
  expect_equal(result, expected)
})

test_that("calc_net_energy_activity handles different species", {
  result <- calc_net_energy_activity(
    species_short = "CML", cohort_short = "FA",
    energy_requirement_maintenance = 12.0, live_weight_cohort_average = 400,
    low_activity_fraction = 0.5, high_activity_fraction = 0
  )
  expected <- (0.1 * 0.5) * 12.0
  expect_equal(result, expected)

  result <- calc_net_energy_activity(
    species_short = "PGS", cohort_short = "FA",
    energy_requirement_maintenance = 10.0, live_weight_cohort_average = 150,
    low_activity_fraction = 0.5, high_activity_fraction = 0.3
  )
  expected <- 0.125 * (0.5 + 0.3) * 10.0
  expect_equal(result, expected)

  result <- calc_net_energy_activity(
    species_short = "GTS", cohort_short = "FA",
    energy_requirement_maintenance = 8.0, live_weight_cohort_average = 50,
    low_activity_fraction = 0.4, high_activity_fraction = 0.2
  )
  expected <- ((0.019 * 0.4) + (0.024 * 0.2)) * 50
  expect_equal(result, expected)
})

test_that("calc_net_energy_activity handles zero high_activity_fraction for cattle", {
  energy_requirement_maintenance <- 12.0
  result <- calc_net_energy_activity(
    species_short = "CTL", cohort_short = "FA",
    energy_requirement_maintenance = energy_requirement_maintenance, live_weight_cohort_average = 500,
    low_activity_fraction = 0.6, high_activity_fraction = 0
  )
  cact <- (0.17 * 0.6) + (0.36 * 0)
  expected <- cact * energy_requirement_maintenance
  expect_equal(result, expected)
})


# ---- test calc_net_energy_growth ----
test_that("calc_net_energy_growth returns correct values for cattle", {
  result <- calc_net_energy_growth(
    species_short = "CTL", cohort_short = "FJ",
    live_weight_cohort_average = 200, live_weight_cohort_final = 300,
    live_weight_cohort_initial = 150, mature_weight = 500, daily_weight_gain = 0.5, offtake_rate = 0.1, cohort_duration_days = 100
  )
  expected <- 22.02 * ((200 / (0.8 * 500))^0.75) * (0.5^1.097)
  expect_equal(result, expected)

  result <- calc_net_energy_growth(
    species_short = "CTL", cohort_short = "FA",
    live_weight_cohort_average = 500, live_weight_cohort_final = 500,
    live_weight_cohort_initial = 500, mature_weight = 500, daily_weight_gain = 0, offtake_rate = 0.1, cohort_duration_days = 365
  )
  expect_equal(result, 0)
})

test_that("calc_net_energy_growth handles sheep linear formula", {
  result <- calc_net_energy_growth(
    species_short = "SHP", cohort_short = "FJ",
    live_weight_cohort_average = 30, live_weight_cohort_final = 50,
    live_weight_cohort_initial = 25, mature_weight = 60, daily_weight_gain = 0.1, offtake_rate = 0.1, cohort_duration_days = 250
  )
  expected <- ((50 - 25) * (2.1 + 0.5 * 0.45 * (25 + 50))) / 250
  expect_equal(result, expected)

  result <- calc_net_energy_growth(
    species_short = "SHP", cohort_short = "FA",
    live_weight_cohort_average = 60, live_weight_cohort_final = 60,
    live_weight_cohort_initial = 60, mature_weight = 60, daily_weight_gain = 0, offtake_rate = 0.1, cohort_duration_days = 365
  )
  expect_equal(result, 0)
})

test_that("calc_net_energy_growth handles pigs", {
  result <- calc_net_energy_growth(
    species_short = "PGS", cohort_short = "FJ",
    live_weight_cohort_average = 50, live_weight_cohort_final = 80,
    live_weight_cohort_initial = 40, mature_weight = 300, daily_weight_gain = 0.3, offtake_rate = 0.1, cohort_duration_days = 133
  )
  prot_tissue_frac <- 0.65
  cgro <- (prot_tissue_frac * 0.23 * 54) + ((1 - prot_tissue_frac) * 0.9 * 52.3)
  expected <- 0.3 * cgro
  expect_equal(result, expected)
})

# ---- test calc_net_energy_lactation ----
test_that("calc_net_energy_lactation returns correct values for cattle", {
  result <- calc_net_energy_lactation(
    species_short = "CTL", cohort_short = "FA",
    lactating_females_fraction = 0.8, milk_yield_day = 20, milk_fat_fraction = 0.04,
    non_productive_duration = 0, pregnancy_duration = 0, litter_size = 1, death_rate_juvenile = 0, birth_weight = 35, weaning_weight = 90,
    lactation_duration = 0, parturition_rate = 0.8
  )
  expected <- ((20 * 0.8) + (0.8 * 5 * (90 - 35) / 365)) * (0.04 * 100 * 0.40 + 1.47)
  expect_equal(result, expected)
})

test_that("calc_net_energy_lactation handles sheep with litter size", {
  result <- calc_net_energy_lactation(
    species_short = "SHP", cohort_short = "FA",
    lactating_females_fraction = 0.9, milk_yield_day = 1.5, milk_fat_fraction = 0.06,
    non_productive_duration = 0, pregnancy_duration = 0, litter_size = 1.5, death_rate_juvenile = 0, birth_weight = 4, weaning_weight = 18,
    lactation_duration = 0, parturition_rate = 1.2
  )
  expected <- ((1.5 * 0.9) + (1.5 * 1.2 * 5 * (18 - 4) / 365)) * 4.6
  expect_equal(result, expected)
})

test_that("calc_net_energy_lactation handles pigs", {
  result <- calc_net_energy_lactation(
    species_short = "PGS", cohort_short = "FA",
    lactating_females_fraction = 0, milk_yield_day = 0, milk_fat_fraction = 0,
    non_productive_duration = 0.2, pregnancy_duration = 0.3, litter_size = 10, death_rate_juvenile = 0.1, birth_weight = 1.5, weaning_weight = 8,
    lactation_duration = 0.5, parturition_rate = 2.2
  )
  cadj <- 0.5 / (0.2 + 0.3 + 0.5)
  expected <- 10 * (1 - 0.5 * 0.1) * ((0.02059 * (8 - 1.5) * 1000 / 0.5) - (0.3766 / 0.67)) * cadj
  expect_equal(result, expected)
})

# ---- test calc_net_energy_work ----
test_that("calc_net_energy_work returns correct values for working animals", {
  result <- calc_net_energy_work(
    species_short = "CTL", cohort_short = "MA",
    energy_requirement_maintenance = 20.0,
    draught_work_hours_female = 2,
    draught_work_hours_male = 4,
    draught_fraction_female = 0.5,
    draught_fraction_male = 0.3
  )
  expected <- 0.1 * 20.0 * 4 * 0.3
  expect_equal(result, expected)

  result <- calc_net_energy_work(
    species_short = "CTL", cohort_short = "FA",
    energy_requirement_maintenance = 15.0,
    draught_work_hours_female = 2,
    draught_work_hours_male = 4,
    draught_fraction_female = 0.5,
    draught_fraction_male = 0.3
  )
  expected <- 0.1 * 15.0 * 2 * 0.5
  expect_equal(result, expected)
})

test_that("calc_net_energy_work handles different species", {
  result <- calc_net_energy_work(
    species_short = "CML", cohort_short = "MA",
    energy_requirement_maintenance = 18.0,
    draught_work_hours_female = 2,
    draught_work_hours_male = 6,
    draught_fraction_female = 0.5,
    draught_fraction_male = 0.4
  )
  expected <- 4 * 6 * 0.4
  expect_equal(result, expected)

  result <- calc_net_energy_work(
    species_short = "SHP", cohort_short = "MA",
    energy_requirement_maintenance = 10.0,
    draught_work_hours_female = 8,
    draught_work_hours_male = 4,
    draught_fraction_female = 0.3,
    draught_fraction_male = 0.3
  )
  expect_equal(result, 0)
})

# ---- test calc_net_energy_fibre ----
test_that("calc_net_energy_fibre returns correct values for fibre-producing animals", {
  result <- calc_net_energy_fibre(
    species_short = "SHP", cohort_short = "FA", fibre_yield_year = 2.5
  )
  expected <- 24 * 2.5 / 365
  expect_equal(result, expected)

  result <- calc_net_energy_fibre(
    species_short = "SHP", cohort_short = "FJ", fibre_yield_year = 1.0
  )
  expect_equal(result, 0)
})

test_that("calc_net_energy_fibre handles camelids", {
  result <- calc_net_energy_fibre(
    species_short = "CML", cohort_short = "FA", fibre_yield_year = 3.0
  )
  expected <- (24 / 0.43) * (3.0 / 365)
  expect_equal(result, expected)
})

test_that("calc_net_energy_fibre returns zero for non-fibre animals", {
  result <- calc_net_energy_fibre(
    species_short = "CTL", cohort_short = "FA", fibre_yield_year = 1.0
  )
  expect_equal(result, 0)
})

# ---- test calc_net_energy_pregnancy ----
test_that("calc_net_energy_pregnancy returns correct values for cattle", {
  result <- calc_net_energy_pregnancy(
    species_short = "CTL", cohort_short = "FA",
    energy_requirement_maintenance = 15.0, parturition_rate = 0.8,
    litter_size = 1, pregnancy_duration = 283,
    non_productive_duration = 10, lactation_duration = 30,
    cohort_duration_days = 730, offtake_rate = 0.2
  )
  expected <- 15.0 * 0.1 * 0.8 * 283 / 365
  expect_equal(result, expected)

  result <- calc_net_energy_pregnancy(
    species_short = "CTL", cohort_short = "FS",
    energy_requirement_maintenance = 12.0, parturition_rate = 0.8,
    litter_size = 1, pregnancy_duration = 283,
    non_productive_duration = 10, lactation_duration = 30,
    cohort_duration_days = 730, offtake_rate = 0.2
  )
  expected <- (12.0 * 0.1) * (283 / 730) * (1 - 0.2)
  expect_equal(result, expected)
})

test_that("calc_net_energy_pregnancy handles sheep with litter size effects", {
  result <- calc_net_energy_pregnancy(
    species_short = "SHP", cohort_short = "FA",
    energy_requirement_maintenance = 8.0, parturition_rate = 1.2,
    litter_size = 1.5, pregnancy_duration = 152,
    non_productive_duration = 10, lactation_duration = 30,
    cohort_duration_days = 700, offtake_rate = 0.1
  )
  cpreg <- (0.077 * 0.5 + 0.126 * 0.5)
  expected <- 8.0 * cpreg * 1.2 * 152 / 365
  expect_equal(result, expected)

  result <- calc_net_energy_pregnancy(
    species_short = "SHP", cohort_short = "FA",
    energy_requirement_maintenance = 8.0, parturition_rate = 1.2,
    litter_size = 2.5, pregnancy_duration = 152,
    non_productive_duration = 10, lactation_duration = 30,
    cohort_duration_days = 365, offtake_rate = 0.1
  )
  expected <- 8.0 * 0.150 * 1.2 * 152 / 365
  expect_equal(result, expected)
})

test_that("calc_net_energy_pregnancy handles pigs", {
  result <- calc_net_energy_pregnancy(
    species_short = "PGS", cohort_short = "FA",
    energy_requirement_maintenance = 12.0, parturition_rate = 2.2,
    litter_size = 10, pregnancy_duration = 115,
    non_productive_duration = 10, lactation_duration = 30,
    cohort_duration_days = 365, offtake_rate = 0.1
  )
  expected <- 0.14985 * 10 * 115 / (10 + 115 + 30)
  expect_equal(result, expected)
})

# ---- test calc_rem_maintenance ----
test_that("calc_rem_maintenance returns correct values for ruminants", {
  result <- calc_rem_maintenance(species_short = "CTL", diet_digestibility_fraction = 0.65)
  expected <- 1.123 - (0.004092 * 65) + (0.00001126 * 65^2) - (25.4 / 65)
  expect_equal(result, expected)

  result <- calc_rem_maintenance(species_short = "SHP", diet_digestibility_fraction = 0.55)
  expected <- 1.123 - (0.004092 * 55) + (0.00001126 * 55^2) - (25.4 / 55)
  expect_equal(result, expected)
})

test_that("calc_rem_maintenance returns NA for non-ruminants", {
  expect_true(is.na(calc_rem_maintenance(species_short = "PGS", diet_digestibility_fraction = 0.75)))
  expect_true(is.na(calc_rem_maintenance(species_short = "CHK", diet_digestibility_fraction = 0.70)))
  expect_true(is.na(calc_rem_maintenance(species_short = "CML", diet_digestibility_fraction = 0.60)))
})

# ---- test calc_reg_growth ----
test_that("calc_reg_growth returns correct values for ruminants", {
  result <- calc_reg_growth(species_short = "CTL", diet_digestibility_fraction = 0.65)
  expected <- 1.164 - (0.005160 * 65) + (0.00001308 * 65^2) - (37.4 / 65)
  expect_equal(result, expected)

  result <- calc_reg_growth(species_short = "GTS", diet_digestibility_fraction = 0.55)
  expected <- 1.164 - (0.005160 * 55) + (0.00001308 * 55^2) - (37.4 / 55)
  expect_equal(result, expected)
})

test_that("calc_reg_growth returns NA for non-ruminants", {
  expect_true(is.na(calc_reg_growth(species_short = "PGS", diet_digestibility_fraction = 0.75)))
  expect_true(is.na(calc_reg_growth(species_short = "CHK", diet_digestibility_fraction = 0.70)))
  expect_true(is.na(calc_reg_growth(species_short = "CML", diet_digestibility_fraction = 0.60)))
})

# ---- test calc_total_energy_requirement ----
test_that("calc_total_energy_requirement returns correct values for cattle", {
  result <- calc_total_energy_requirement(
    species_short = "CTL",
    energy_requirement_maintenance = 15.0, energy_requirement_activity = 3.0, energy_requirement_lactation = 8.0, energy_requirement_work = 0, energy_requirement_pregnancy = 1.5,
    net_energy_maintenance_digestible_energy_ratio = 0.6, energy_requirement_growth = 0, energy_requirement_fibre_production = 0, energy_requirement_egg_deposition = 0, net_energy_growth_digestible_energy_ratio = 0.5, diet_digestibility_fraction = 0.65
  )
  expected <- (((15.0 + 3.0 + 8.0 + 0 + 1.5) / 0.6) + (0 / 0.5)) / 0.65
  expect_equal(result, expected)
})

test_that("calc_total_energy_requirement handles sheep with fibre", {
  result <- calc_total_energy_requirement(
    species_short = "SHP",
    energy_requirement_maintenance = 8.0, energy_requirement_activity = 1.5, energy_requirement_lactation = 4.0, energy_requirement_work = 0, energy_requirement_pregnancy = 1.0,
    net_energy_maintenance_digestible_energy_ratio = 0.55, energy_requirement_growth = 0, energy_requirement_fibre_production = 0.2, energy_requirement_egg_deposition = 0, net_energy_growth_digestible_energy_ratio = 0.45, diet_digestibility_fraction = 0.60
  )
  expected <- (((8.0 + 1.5 + 4.0 + 1.0) / 0.55) + ((0 + 0.2) / 0.45)) / 0.60
  expect_equal(result, expected)
})

test_that("calc_total_energy_requirement handles different species", {
  result <- calc_total_energy_requirement(
    species_short = "CML",
    energy_requirement_maintenance = 12.0, energy_requirement_activity = 2.0, energy_requirement_lactation = 6.0, energy_requirement_work = 1.0, energy_requirement_pregnancy = 1.5,
    net_energy_maintenance_digestible_energy_ratio = NA, energy_requirement_growth = 0, energy_requirement_fibre_production = 0.3, energy_requirement_egg_deposition = 0, net_energy_growth_digestible_energy_ratio = NA, diet_digestibility_fraction = 0.70
  )
  expected <- 12.0 + 2.0 + 6.0 + 1.0 + 0.3 + 1.5 + 0
  expect_equal(result, expected)

  result <- calc_total_energy_requirement(
    species_short = "PGS",
    energy_requirement_maintenance = 10.0, energy_requirement_activity = 1.0, energy_requirement_lactation = 5.0, energy_requirement_work = 0, energy_requirement_pregnancy = 2.0,
    net_energy_maintenance_digestible_energy_ratio = NA, energy_requirement_growth = 0, energy_requirement_fibre_production = 0, energy_requirement_egg_deposition = 0, net_energy_growth_digestible_energy_ratio = NA, diet_digestibility_fraction = 0.75
  )
  expected <- 10.0 + 1.0 + 5.0 + 2.0 + 0
  expect_equal(result, expected)
})

# ---- test calc_dry_matter_intake ----
test_that("calc_dry_matter_intake uses gross energy for ruminants", {
  result <- calc_dry_matter_intake(
    species_short = "CTL", energy_requirement_total = 25.0, diet_gross_energy = 18.5, diet_metabolizable_energy = 12.0
  )
  expected <- 25.0 / 18.5
  expect_equal(result, expected)

  result <- calc_dry_matter_intake(
    species_short = "SHP", energy_requirement_total = 12.0, diet_gross_energy = 16.0, diet_metabolizable_energy = 10.5
  )
  expected <- 12.0 / 16.0
  expect_equal(result, expected)
})

test_that("calc_dry_matter_intake uses metabolizable energy for monogastrics", {
  result <- calc_dry_matter_intake(
    species_short = "PGS", energy_requirement_total = 15.0, diet_gross_energy = 18.0, diet_metabolizable_energy = 13.5
  )
  expected <- 15.0 / 13.5
  expect_equal(result, expected)

  result <- calc_dry_matter_intake(
    species_short = "CHK", energy_requirement_total = 8.0, diet_gross_energy = 16.5, diet_metabolizable_energy = 11.0
  )
  expected <- 8.0 / 11.0
  expect_equal(result, expected)

  result <- calc_dry_matter_intake(
    species_short = "CML", energy_requirement_total = 20.0, diet_gross_energy = 17.0, diet_metabolizable_energy = 12.5
  )
  expected <- 20.0 / 12.5
  expect_equal(result, expected)
})
