# ---- test calc_metabolic_energy_req_maintenance ----
test_that("calc_metabolic_energy_req_maintenance returns correct values for cattle", {
  # Test adult female with lactating fraction
  result <- calc_metabolic_energy_req_maintenance(
    species_short = "CTL", cohort_short = "FA", live_weight_cohort_average = 500,
    lactating_females_fraction = 0.7
  )
  expected <- (500^0.75) * (0.386 * 0.7 + 0.322 * 0.3)
  expect_equal(result, expected)

  # Test juvenile female
  result <- calc_metabolic_energy_req_maintenance(
    species_short = "CTL", cohort_short = "FJ", live_weight_cohort_average = 200
  )
  expected <- (200^0.75) * 0.322
  expect_equal(result, expected)

  # Test adult male with offtake
  result <- calc_metabolic_energy_req_maintenance(
    species_short = "CTL", cohort_short = "MA", live_weight_cohort_average = 600,
    offtake_rate = 0.3
  )
  expected <- (600^0.75) * (0.322 * 0.3 + 0.37 * 0.7)
  expect_equal(result, expected)
})

test_that("calc_metabolic_energy_req_maintenance handles sheep with age at first parturition", {
  # Test subadult female with age_first_parturition
  result <- calc_metabolic_energy_req_maintenance(
    species_short = "SHP", cohort_short = "FS", live_weight_cohort_average = 40,
    age_first_parturition = 400
  )
  expected <- (40^0.75) * ((0.236 * (365 / 400)) + (0.217 * ((400 - 365) / 400)))
  expect_equal(result, expected)

  # Test adult female
  result <- calc_metabolic_energy_req_maintenance(
    species_short = "SHP", cohort_short = "FA", live_weight_cohort_average = 60
  )
  expected <- (60^0.75) * 0.217
  expect_equal(result, expected)
})

test_that("calc_metabolic_energy_req_maintenance handles pigs with physiological states", {
  result <- calc_metabolic_energy_req_maintenance(
    species_short = "PGS", cohort_short = "FA", live_weight_cohort_average = 150)

  expected <- (150^0.75) * 0.4435
  expect_equal(result, expected)
})

test_that("calc_metabolic_energy_req_maintenance handles fixed coefficients", {
  # Test camelids
  result <- calc_metabolic_energy_req_maintenance(
    species_short = "CML", cohort_short = "FA", live_weight_cohort_average = 400
  )
  expected <- (400^0.75) * 0.435
  expect_equal(result, expected)

  # Test goats
  result <- calc_metabolic_energy_req_maintenance(
    species_short = "GTS", cohort_short = "FA", live_weight_cohort_average = 50
  )
  expected <- (50^0.75) * 0.315
  expect_equal(result, expected)
})

test_that("calc_metabolic_energy_req_maintenance calculates correctly for zero lactating_females_fraction", {
  expected <- (500^0.75) * 0.322
  result <- calc_metabolic_energy_req_maintenance(
    species_short = "CTL",
    cohort_short = "FA", live_weight_cohort_average = 500, lactating_females_fraction = 0
  )
  expect_equal(result, expected, tolerance = 1e-8)
})

test_that("calc_metabolic_energy_req_maintenance handles chickens", {
  adult <- calc_metabolic_energy_req_maintenance(
    species_short = "CHK",
    cohort_short = "FA",
    live_weight_cohort_average = 2,
    average_annual_temperature = 5,
    is_egg_producing = TRUE
  )
  expect_equal(adult, (2^0.75) * (0.6935 - 0.0099 * 5))

  juvenile <- calc_metabolic_energy_req_maintenance(
    species_short = "CHK",
    cohort_short = "FJ",
    live_weight_cohort_average = 0.04,
    average_annual_temperature = 15,
    lower_critical_temperature = 18
  )
  expect_equal(juvenile, 0.3866 + 0.0282 * (18 - 15))
})

test_that("calc_metabolic_energy_req_maintenance uses explicit egg-producing FN flag", {
  result <- calc_metabolic_energy_req_maintenance(
    species_short = "CHK",
    cohort_short = "FN",
    nondemo_productive_phase_id = 2,
    live_weight_cohort_average = 1.8,
    average_annual_temperature = 18,
    is_egg_producing = TRUE
  )

  expected <- max(0, (1.8^0.75) * (0.6935 - 0.0099 * 18))
  expect_equal(result, expected)
})

# ---- test calc_metabolic_energy_req_activity ----
test_that("calc_metabolic_energy_req_activity returns correct values for cattle", {
  metabolic_energy_req_maintenance <- 15.0
  result <- calc_metabolic_energy_req_activity(
    species_short = "CTL", cohort_short = "FA",
    metabolic_energy_req_maintenance = metabolic_energy_req_maintenance,
    live_weight_cohort_average = 500,
    low_activity_fraction = 0.6, high_activity_fraction = 0.2
  )
  cact <- (0.17 * 0.6) + (0.36 * 0.2)
  expected <- cact * metabolic_energy_req_maintenance
  expect_equal(result, expected)
})

test_that("calc_metabolic_energy_req_activity returns correct values for buffalo", {
  metabolic_energy_req_maintenance <- 18.0
  result <- calc_metabolic_energy_req_activity(
    species_short = "BFL", cohort_short = "FA",
    metabolic_energy_req_maintenance = metabolic_energy_req_maintenance,
    live_weight_cohort_average = 600,
    low_activity_fraction = 0.5, high_activity_fraction = 0.2
  )
  cact <- (0.17 * 0.5) + (0.36 * 0.2)
  expected <- cact * metabolic_energy_req_maintenance
  expect_equal(result, expected)
})

test_that("calc_metabolic_energy_req_activity handles sheep complexity", {
  result <- calc_metabolic_energy_req_activity(
    species_short = "SHP", cohort_short = "MS",
    metabolic_energy_req_maintenance = 8.0, live_weight_cohort_average = 45,
    low_activity_fraction = 0.5, high_activity_fraction = 0.2
  )
  cact <- (0.0107 * 0.5) +  (0.024 * 0.2)
  expected <- cact * 45
  expect_equal(result, expected)

  result <- calc_metabolic_energy_req_activity(
    species_short = "SHP", cohort_short = "FA",
    metabolic_energy_req_maintenance = 8.0, live_weight_cohort_average = 60,
    low_activity_fraction = 0.5, high_activity_fraction = 0.2
  )
  cact <- (0.0107 * 0.5) +  (0.024 * 0.2)
  expected <- cact * 60
  expect_equal(result, expected)
})

test_that("calc_metabolic_energy_req_activity handles different species", {
  result <- calc_metabolic_energy_req_activity(
    species_short = "CML", cohort_short = "FA",
    metabolic_energy_req_maintenance = 12.0, live_weight_cohort_average = 400,
    low_activity_fraction = 0.5, high_activity_fraction = 0
  )
  expected <- (0.1 * 0.5) * 12.0
  expect_equal(result, expected)

  result <- calc_metabolic_energy_req_activity(
    species_short = "PGS", cohort_short = "FA",
    metabolic_energy_req_maintenance = 10.0, live_weight_cohort_average = 150,
    low_activity_fraction = 0.5, high_activity_fraction = 0.3
  )
  expected <- 0.125 * (0.5 + 0.3) * 10.0
  expect_equal(result, expected)

  result <- calc_metabolic_energy_req_activity(
    species_short = "GTS", cohort_short = "FA",
    metabolic_energy_req_maintenance = 8.0, live_weight_cohort_average = 50,
    low_activity_fraction = 0.4, high_activity_fraction = 0.2
  )
  expected <- ((0.019 * 0.4) + (0.024 * 0.2)) * 50
  expect_equal(result, expected)
})

test_that("calc_metabolic_energy_req_activity handles zero high_activity_fraction for cattle", {
  metabolic_energy_req_maintenance <- 12.0
  result <- calc_metabolic_energy_req_activity(
    species_short = "CTL", cohort_short = "FA",
    metabolic_energy_req_maintenance = metabolic_energy_req_maintenance,
    live_weight_cohort_average = 500,
    low_activity_fraction = 0.6, high_activity_fraction = 0
  )
  cact <- (0.17 * 0.6) + (0.36 * 0)
  expected <- cact * metabolic_energy_req_maintenance
  expect_equal(result, expected)
})

test_that("calc_metabolic_energy_req_activity handles chickens", {
  result <- calc_metabolic_energy_req_activity(
    species_short = "CHK", cohort_short = "FA",
    metabolic_energy_req_maintenance = 1.2,
    live_weight_cohort_average = 2,
    low_activity_fraction = 0.4, high_activity_fraction = 0.3
  )

  expect_equal(result, 1.2 * 0.7 * 0.25)
})


# ---- test calc_metabolic_energy_req_growth ----
test_that("calc_metabolic_energy_req_growth returns correct values for cattle", {
  result <- calc_metabolic_energy_req_growth(
    species_short = "CTL", cohort_short = "FJ",
    live_weight_cohort_average = 200, live_weight_cohort_final = 300,
    live_weight_cohort_initial = 150, live_weight_mature_stage = 500,
    daily_weight_gain = 0.5, offtake_rate = 0.1, cohort_duration_days = 100
  )
  expected <- 22.02 * ((200 / (0.8 * 500))^0.75) * (0.5^1.097)
  expect_equal(result, expected)

  result <- calc_metabolic_energy_req_growth(
    species_short = "CTL", cohort_short = "FA",
    live_weight_cohort_average = 500, live_weight_cohort_final = 500,
    live_weight_cohort_initial = 500, live_weight_mature_stage = 500,
    daily_weight_gain = 0, offtake_rate = 0.1, cohort_duration_days = 365
  )
  expect_equal(result, 0)
})

test_that("calc_metabolic_energy_req_growth handles sheep linear formula", {
  result <- calc_metabolic_energy_req_growth(
    species_short = "SHP", cohort_short = "FJ",
    live_weight_cohort_average = 30, live_weight_cohort_final = 50,
    live_weight_cohort_initial = 25, live_weight_mature_stage = 60,
    daily_weight_gain = 0.1, offtake_rate = 0.1, cohort_duration_days = 250
  )
  expected <- ((50 - 25) * (2.1 + 0.5 * 0.45 * (25 + 50))) / 250
  expect_equal(result, expected)

  result <- calc_metabolic_energy_req_growth(
    species_short = "SHP", cohort_short = "FA",
    live_weight_cohort_average = 60, live_weight_cohort_final = 60,
    live_weight_cohort_initial = 60, live_weight_mature_stage = 60,
    daily_weight_gain = 0, offtake_rate = 0.1, cohort_duration_days = 365
  )
  expect_equal(result, 0)
})

test_that("calc_metabolic_energy_req_growth handles pigs", {
  result <- calc_metabolic_energy_req_growth(
    species_short = "PGS", cohort_short = "FJ",
    live_weight_cohort_average = 50, live_weight_cohort_final = 80,
    live_weight_cohort_initial = 40, live_weight_mature_stage = 300,
    daily_weight_gain = 0.3, offtake_rate = 0.1, cohort_duration_days = 133
  )
  prot_tissue_frac <- 0.65
  cgro <- (prot_tissue_frac * 0.23 * 54) + ((1 - prot_tissue_frac) * 0.9 * 52.3)
  expected <- 0.3 * cgro
  expect_equal(result, expected)
})

test_that("calc_metabolic_energy_req_growth handles chickens", {
  juvenile <- calc_metabolic_energy_req_growth(
    species_short = "CHK", cohort_short = "FJ",
    daily_weight_gain = 0.02
  )
  expect_equal(juvenile, 0.02 * 0.0202 * 1000)

  adult <- calc_metabolic_energy_req_growth(
    species_short = "CHK", cohort_short = "FA",
    daily_weight_gain = 0.01,
    is_egg_producing = TRUE
  )
  expect_equal(adult, 0.01 * 0.0279 * 1000)
})

test_that("calc_metabolic_energy_req_growth uses explicit egg-producing FN flag", {
  result <- calc_metabolic_energy_req_growth(
    species_short = "CHK",
    cohort_short = "FN",
    nondemo_productive_phase_id = 2,
    daily_weight_gain = 0.01,
    is_egg_producing = TRUE
  )

  expect_equal(result, 0.01 * 0.0279 * 1000)
})

test_that("calc_metabolic_energy_req_growth uses broiler coefficient for non-laying FN", {
  result <- calc_metabolic_energy_req_growth(
    species_short = "CHK",
    cohort_short = "FN",
    nondemo_productive_phase_id = 1,
    daily_weight_gain = 0.01,
    is_egg_producing = FALSE
  )

  expect_equal(result, 0.01 * 0.0202 * 1000)
})

test_that("calc_metabolic_energy_req_eggs handles chickens", {
  result <- calc_metabolic_energy_req_eggs(
    species_short = "CHK",
    cohort_short = "FA",
    cohort_stock_size = 100,
    egg_output_human_consumption = 36500,
    egg_average_weight = 0.06,
    parturition_rate = 120,
    is_egg_producing = TRUE
  )

  egg_mass <- ((36500 / 365 / 100) + (120 / 365)) * 0.06
  expect_equal(result, egg_mass * 10.04)
  expect_equal(
    calc_metabolic_energy_req_eggs(
      species_short = "CHK",
      cohort_short = "FS",
      cohort_stock_size = 100,
      egg_output_human_consumption = 36500,
      egg_average_weight = 0.06,
      parturition_rate = 120
    ),
    0
  )
})

test_that("calc_metabolic_energy_req_eggs uses explicit egg-producing FN flag", {
  result <- calc_metabolic_energy_req_eggs(
    species_short = "CHK",
    cohort_short = "FN",
    nondemo_productive_phase_id = 2,
    cohort_stock_size = 100,
    egg_output_human_consumption = 36500,
    egg_average_weight = 0.06,
    parturition_rate = 120,
    is_egg_producing = TRUE
  )

  egg_mass <- ((36500 / 365 / 100) + (120 / 365)) * 0.06
  expect_equal(result, egg_mass * 10.04)
  expect_equal(
    calc_metabolic_energy_req_eggs(
      species_short = "CHK",
      cohort_short = "FN",
      nondemo_productive_phase_id = 1,
      cohort_stock_size = 100,
      egg_output_human_consumption = 36500,
      egg_average_weight = 0.06,
      parturition_rate = 120
    ),
    0
  )
})

test_that("calc_metabolic_energy_req_eggs validates egg-producing flag placement", {
  expect_error(
    calc_metabolic_energy_req_eggs(
      species_short = "CHK",
      cohort_short = "FS",
      cohort_stock_size = 100,
      egg_output_human_consumption = 36500,
      egg_average_weight = 0.06,
      parturition_rate = 120,
      is_egg_producing = TRUE
    ),
    "can be TRUE only for CHK cohorts.*FA.*FN"
  )

  expect_error(
    calc_metabolic_energy_req_eggs(
      species_short = "CHK",
      cohort_short = "FN",
      nondemo_productive_phase_id = 1,
      cohort_stock_size = 100,
      egg_output_human_consumption = 36500,
      egg_average_weight = 0.06,
      parturition_rate = 120,
      is_egg_producing = TRUE
    ),
    "can be TRUE for.*FN.*only when.*2"
  )
})

# ---- test calc_metabolic_energy_req_lactation ----
test_that("calc_metabolic_energy_req_lactation returns correct values for cattle", {
  result <- calc_metabolic_energy_req_lactation(
    species_short = "CTL", cohort_short = "FA",
    lactating_females_fraction = 0.8, milk_yield_day = 20,
    milk_fat_fraction = 0.04,
    non_productive_duration = 0, pregnancy_duration = 0,
    litter_size = 1, death_rate_juvenile = 0,
    live_weight_at_birth = 35, live_weight_at_weaning = 90,
    lactation_duration = 0, parturition_rate = 0.8
  )
  expected <- ((20 * 0.8) + (0.8 * 5 * (90 - 35) / 365)) * (0.04 * 100 * 0.40 + 1.47)
  expect_equal(result, expected)
})

test_that("calc_metabolic_energy_req_lactation handles sheep with litter size", {
  result <- calc_metabolic_energy_req_lactation(
    species_short = "SHP", cohort_short = "FA",
    lactating_females_fraction = 0.9,
    milk_yield_day = 1.5, milk_fat_fraction = 0.06,
    non_productive_duration = 0,
    pregnancy_duration = 0, litter_size = 1.5,
    death_rate_juvenile = 0, live_weight_at_birth = 4, live_weight_at_weaning = 18,
    lactation_duration = 0, parturition_rate = 1.2
  )
  expected <- ((1.5 * 0.9) + (1.5 * 1.2 * 5 * (18 - 4) / 365)) * 4.6
  expect_equal(result, expected)
})

test_that("calc_metabolic_energy_req_lactation handles pigs", {
  result <- calc_metabolic_energy_req_lactation(
    species_short = "PGS", cohort_short = "FA",
    lactating_females_fraction = 0, milk_yield_day = 0, milk_fat_fraction = 0,
    non_productive_duration = 0.2, pregnancy_duration = 0.3,
    litter_size = 10, death_rate_juvenile = 0.1,
    live_weight_at_birth = 1.5, live_weight_at_weaning = 8,
    lactation_duration = 0.5, parturition_rate = 2.2
  )
  cadj <- 0.5 / (0.2 + 0.3 + 0.5)
  expected <- 10 * (1 - 0.5 * 0.1) * ((0.02059 * (8 - 1.5) * 1000 / 0.5) - (0.3766 / 0.67)) * cadj
  expect_equal(result, expected)
})

# ---- test calc_metabolic_energy_req_work ----
test_that("calc_metabolic_energy_req_work returns correct values for working animals", {
  result <- calc_metabolic_energy_req_work(
    species_short = "CTL", cohort_short = "MA",
    metabolic_energy_req_maintenance = 20.0,
    draught_work_hours_female = 2,
    draught_work_hours_male = 4,
    draught_fraction_female = 0.5,
    draught_fraction_male = 0.3
  )
  expected <- 0.1 * 20.0 * 4 * 0.3
  expect_equal(result, expected)

  result <- calc_metabolic_energy_req_work(
    species_short = "CTL", cohort_short = "FA",
    metabolic_energy_req_maintenance = 15.0,
    draught_work_hours_female = 2,
    draught_work_hours_male = 4,
    draught_fraction_female = 0.5,
    draught_fraction_male = 0.3
  )
  expected <- 0.1 * 15.0 * 2 * 0.5
  expect_equal(result, expected)
})

test_that("calc_metabolic_energy_req_work handles different species", {
  result <- calc_metabolic_energy_req_work(
    species_short = "CML", cohort_short = "MA",
    metabolic_energy_req_maintenance = 18.0,
    draught_work_hours_female = 2,
    draught_work_hours_male = 6,
    draught_fraction_female = 0.5,
    draught_fraction_male = 0.4
  )
  expected <- 4 * 6 * 0.4
  expect_equal(result, expected)

  result <- calc_metabolic_energy_req_work(
    species_short = "SHP", cohort_short = "MA",
    metabolic_energy_req_maintenance = 10.0,
    draught_work_hours_female = 8,
    draught_work_hours_male = 4,
    draught_fraction_female = 0.3,
    draught_fraction_male = 0.3
  )
  expect_equal(result, 0)
})

# ---- test calc_metabolic_energy_req_fibre ----
test_that("calc_metabolic_energy_req_fibre returns correct values for fibre-producing animals", {
  result <- calc_metabolic_energy_req_fibre(
    species_short = "SHP", cohort_short = "FA", fibre_yield_year = 2.5
  )
  expected <- 24 * 2.5 / 365
  expect_equal(result, expected)

  result <- calc_metabolic_energy_req_fibre(
    species_short = "SHP", cohort_short = "FJ", fibre_yield_year = 1.0
  )
  expect_equal(result, 0)
})

test_that("calc_metabolic_energy_req_fibre handles camelids", {
  result <- calc_metabolic_energy_req_fibre(
    species_short = "CML", cohort_short = "FA", fibre_yield_year = 3.0
  )
  expected <- (24 / 0.43) * (3.0 / 365)
  expect_equal(result, expected)
})

test_that("calc_metabolic_energy_req_fibre returns zero for non-fibre animals", {
  result <- calc_metabolic_energy_req_fibre(
    species_short = "CTL", cohort_short = "FA", fibre_yield_year = 1.0
  )
  expect_equal(result, 0)
})

# ---- test calc_metabolic_energy_req_pregnancy ----
test_that("calc_metabolic_energy_req_pregnancy returns correct values for cattle", {
  result <- calc_metabolic_energy_req_pregnancy(
    species_short = "CTL", cohort_short = "FA",
    metabolic_energy_req_maintenance = 15.0, parturition_rate = 0.8,
    litter_size = 1, pregnancy_duration = 283,
    non_productive_duration = 10, lactation_duration = 30,
    cohort_duration_days = 730, offtake_rate = 0.2
  )
  expected <- 15.0 * 0.1 * 0.8 * 283 / 365
  expect_equal(result, expected)

  result <- calc_metabolic_energy_req_pregnancy(
    species_short = "CTL", cohort_short = "FS",
    metabolic_energy_req_maintenance = 12.0, parturition_rate = 0.8,
    litter_size = 1, pregnancy_duration = 283,
    non_productive_duration = 10, lactation_duration = 30,
    cohort_duration_days = 730, offtake_rate = 0.2
  )
  expected <- (12.0 * 0.1) * (283 / 730) * (1 - 0.2)
  expect_equal(result, expected)
})

test_that("calc_metabolic_energy_req_pregnancy handles sheep with litter size effects", {
  result <- calc_metabolic_energy_req_pregnancy(
    species_short = "SHP", cohort_short = "FA",
    metabolic_energy_req_maintenance = 8.0, parturition_rate = 1.2,
    litter_size = 1.5, pregnancy_duration = 152,
    non_productive_duration = 10, lactation_duration = 30,
    cohort_duration_days = 700, offtake_rate = 0.1
  )
  cpreg <- (0.077 * 0.5 + 0.126 * 0.5)
  expected <- 8.0 * cpreg * 1.2 * 152 / 365
  expect_equal(result, expected)

  result <- calc_metabolic_energy_req_pregnancy(
    species_short = "SHP", cohort_short = "FA",
    metabolic_energy_req_maintenance = 8.0, parturition_rate = 1.2,
    litter_size = 2.5, pregnancy_duration = 152,
    non_productive_duration = 10, lactation_duration = 30,
    cohort_duration_days = 365, offtake_rate = 0.1
  )
  expected <- 8.0 * 0.150 * 1.2 * 152 / 365
  expect_equal(result, expected)
})

test_that("calc_metabolic_energy_req_pregnancy handles pigs", {
  result <- calc_metabolic_energy_req_pregnancy(
    species_short = "PGS", cohort_short = "FA",
    metabolic_energy_req_maintenance = 12.0, parturition_rate = 2.2,
    litter_size = 10, pregnancy_duration = 115,
    non_productive_duration = 10, lactation_duration = 30,
    cohort_duration_days = 365, offtake_rate = 0.1
  )
  expected <- 0.14985 * 10 * 115 / (10 + 115 + 30)
  expect_equal(result, expected)
})

# ---- test calc_rem_maintenance ----
test_that("calc_rem_maintenance returns correct values for ruminants", {
  result <- calc_rem_maintenance(species_short = "CTL", ration_digestibility_fraction = 0.65)
  expected <- 1.123 - (0.004092 * 65) + (0.00001126 * 65^2) - (25.4 / 65)
  expect_equal(result, expected)

  result <- calc_rem_maintenance(species_short = "SHP", ration_digestibility_fraction = 0.55)
  expected <- 1.123 - (0.004092 * 55) + (0.00001126 * 55^2) - (25.4 / 55)
  expect_equal(result, expected)
})

test_that("calc_rem_maintenance returns NA for non-ruminants", {
  expect_true(is.na(
    calc_rem_maintenance(species_short = "PGS", ration_digestibility_fraction = 0.75)
  ))
  expect_true(is.na(
    calc_rem_maintenance(species_short = "CML", ration_digestibility_fraction = 0.60)
  ))
})

# ---- test calc_reg_growth ----
test_that("calc_reg_growth returns correct values for ruminants", {
  result <- calc_reg_growth(species_short = "CTL", ration_digestibility_fraction = 0.65)
  expected <- 1.164 - (0.005160 * 65) + (0.00001308 * 65^2) - (37.4 / 65)
  expect_equal(result, expected)

  result <- calc_reg_growth(species_short = "GTS", ration_digestibility_fraction = 0.55)
  expected <- 1.164 - (0.005160 * 55) + (0.00001308 * 55^2) - (37.4 / 55)
  expect_equal(result, expected)
})

test_that("calc_reg_growth returns NA for non-ruminants", {
  expect_true(is.na(calc_reg_growth(species_short = "PGS", ration_digestibility_fraction = 0.75)))
  expect_true(is.na(calc_reg_growth(species_short = "CML", ration_digestibility_fraction = 0.60)))
})

# ---- test calc_total_metabolic_energy_req ----
test_that("calc_total_metabolic_energy_req returns correct values for cattle", {
  result <- calc_total_metabolic_energy_req(
    species_short = "CTL",
    metabolic_energy_req_maintenance = 15.0,
    metabolic_energy_req_activity = 3.0,
    metabolic_energy_req_lactation = 8.0,
    metabolic_energy_req_work = 0,
    metabolic_energy_req_pregnancy = 1.5,
    net_energy_maintenance_digestible_energy_ratio = 0.6,
    metabolic_energy_req_growth = 0,
    metabolic_energy_req_fibre_production = 0,
    metabolic_energy_req_egg_deposition = 0,
    net_energy_growth_digestible_energy_ratio = 0.5,
    ration_digestibility_fraction = 0.65
  )
  expected <- (((15.0 + 3.0 + 8.0 + 0 + 1.5) / 0.6) + (0 / 0.5)) / 0.65
  expect_equal(result, expected)
})

test_that("calc_total_metabolic_energy_req handles sheep with fibre", {
  result <- calc_total_metabolic_energy_req(
    species_short = "SHP",
    metabolic_energy_req_maintenance = 8.0,
    metabolic_energy_req_activity = 1.5,
    metabolic_energy_req_lactation = 4.0,
    metabolic_energy_req_work = 0,
    metabolic_energy_req_pregnancy = 1.0,
    net_energy_maintenance_digestible_energy_ratio = 0.55,
    metabolic_energy_req_growth = 0,
    metabolic_energy_req_fibre_production = 0.2,
    metabolic_energy_req_egg_deposition = 0,
    net_energy_growth_digestible_energy_ratio = 0.45,
    ration_digestibility_fraction = 0.60
  )
  expected <- (((8.0 + 1.5 + 4.0 + 1.0) / 0.55) + ((0 + 0.2) / 0.45)) / 0.60
  expect_equal(result, expected)
})

test_that("calc_total_metabolic_energy_req handles different species", {
  result <- calc_total_metabolic_energy_req(
    species_short = "CML",
    metabolic_energy_req_maintenance = 12.0,
    metabolic_energy_req_activity = 2.0,
    metabolic_energy_req_lactation = 6.0,
    metabolic_energy_req_work = 1.0,
    metabolic_energy_req_pregnancy = 1.5,
    net_energy_maintenance_digestible_energy_ratio = NA,
    metabolic_energy_req_growth = 0,
    metabolic_energy_req_fibre_production = 0.3,
    metabolic_energy_req_egg_deposition = 0,
    net_energy_growth_digestible_energy_ratio = NA,
    ration_digestibility_fraction = 0.70
  )
  expected <- 12.0 + 2.0 + 6.0 + 1.0 + 0.3 + 1.5 + 0
  expect_equal(result, expected)

  result <- calc_total_metabolic_energy_req(
    species_short = "PGS",
    metabolic_energy_req_maintenance = 10.0,
    metabolic_energy_req_activity = 1.0,
    metabolic_energy_req_lactation = 5.0,
    metabolic_energy_req_work = 0,
    metabolic_energy_req_pregnancy = 2.0,
    net_energy_maintenance_digestible_energy_ratio = NA,
    metabolic_energy_req_growth = 0,
    metabolic_energy_req_fibre_production = 0,
    metabolic_energy_req_egg_deposition = 0,
    net_energy_growth_digestible_energy_ratio = NA,
    ration_digestibility_fraction = 0.75
  )
  expected <- 10.0 + 1.0 + 5.0 + 2.0 + 0
  expect_equal(result, expected)
})

test_that("calc_total_metabolic_energy_req handles chickens", {
  result <- calc_total_metabolic_energy_req(
    species_short = "CHK",
    metabolic_energy_req_maintenance = 1.5,
    metabolic_energy_req_activity = 0.3,
    metabolic_energy_req_lactation = 0,
    metabolic_energy_req_work = 0,
    metabolic_energy_req_pregnancy = 0,
    net_energy_maintenance_digestible_energy_ratio = NA,
    metabolic_energy_req_growth = 0.4,
    metabolic_energy_req_fibre_production = 0,
    metabolic_energy_req_egg_deposition = 0.7,
    net_energy_growth_digestible_energy_ratio = NA,
    ration_digestibility_fraction = 0.75
  )
  expect_equal(result, 1.5 + 0.3 + 0.4 + 0.7)
})

# ---- test calc_ration_intake ----
test_that("calc_ration_intake uses gross energy for ruminants", {
  result <- calc_ration_intake(
    species_short = "CTL", metabolic_energy_req_total = 25.0,
    ration_gross_energy = 18.5, ration_metabolizable_energy = 12.0
  )
  expected <- 25.0 / 18.5
  expect_equal(result, expected)

  result <- calc_ration_intake(
    species_short = "SHP", metabolic_energy_req_total = 12.0,
    ration_gross_energy = 16.0, ration_metabolizable_energy = 10.5
  )
  expected <- 12.0 / 16.0
  expect_equal(result, expected)
})

test_that("calc_ration_intake uses metabolizable energy for chickens", {
  result <- calc_ration_intake(
    species_short = "CHK",
    metabolic_energy_req_total = 5,
    ration_gross_energy = 18,
    ration_metabolizable_energy = 12.5
  )
  expect_equal(result, 5 / 12.5)
})

test_that("calc_ration_intake uses metabolizable energy for monogastrics", {
  result <- calc_ration_intake(
    species_short = "PGS", metabolic_energy_req_total = 15.0,
    ration_gross_energy = 18.0, ration_metabolizable_energy = 13.5
  )
  expected <- 15.0 / 13.5
  expect_equal(result, expected)

  result <- calc_ration_intake(
    species_short = "CML", metabolic_energy_req_total = 20.0,
    ration_gross_energy = 17.0, ration_metabolizable_energy = 12.5
  )
  expected <- 20.0 / 12.5
  expect_equal(result, expected)
})
