# ---- test calc_milk_allocation_energy ----

test_that("calc_milk_allocation_energy returns correct value for valid inputs", {
  result <- calc_milk_allocation_energy(
    milk_production_fpcm_cohort = 100,
    milk_protein_fraction_standard = 0.033,
    milk_fat_fraction_standard = 0.04,
    milk_lactose_fraction_standard = 0.048
  )

  expect_type(result, "double")
  expect_length(result, 1)
  energy_standard <- (0.0929 * 0.04 + 0.0547 * 0.033 + 0.0395 * 0.048) * 4.184 * 100
  expect_equal(result, energy_standard * 100)
})

test_that("calc_milk_allocation_energy handles zero milk output", {
  result <- calc_milk_allocation_energy(
    milk_production_fpcm_cohort = 0,
    milk_protein_fraction_standard = 0.033,
    milk_fat_fraction_standard = 0.04,
    milk_lactose_fraction_standard = 0.048
  )

  expect_equal(result, 0)
})

test_that("calc_milk_allocation_energy validates bounds", {
  expect_error(
    calc_milk_allocation_energy(
      milk_production_fpcm_cohort = -10,
      milk_protein_fraction_standard = 0.033,
      milk_fat_fraction_standard = 0.04,
      milk_lactose_fraction_standard = 0.048
    ),
    "is out of range"
  )
  expect_error(
    calc_milk_allocation_energy(
      milk_production_fpcm_cohort = 100,
      milk_protein_fraction_standard = 1.5,
      milk_fat_fraction_standard = 0.04,
      milk_lactose_fraction_standard = 0.048
    ),
    "is out of range"
  )
})

# ---- test calc_meat_allocation_energy ----

test_that("calc_meat_allocation_energy returns correct value for cattle female", {
  result <- calc_meat_allocation_energy(
    species_short = "CTL",
    cohort_short = "FA",
    meat_production_live_weight_cohort = 100,
    live_weight_cohort_at_slaughter = 500,
    live_weight_at_birth = 40
  )

  expect_type(result, "double")
  expect_length(result, 1)
  # For CTL/FA: growth_efficiency_factor = 0.8
  expected_specific <- (22.02 * (((500 - 40) / 2) / (0.8 * 500))^0.75 * (500 - 40)^1.097) / 500
  expect_equal(result, expected_specific * 100)
})

test_that("calc_meat_allocation_energy returns correct value for cattle male", {
  result <- calc_meat_allocation_energy(
    species_short = "CTL",
    cohort_short = "MA",
    meat_production_live_weight_cohort = 150,
    live_weight_cohort_at_slaughter = 600,
    live_weight_at_birth = 45
  )

  expect_type(result, "double")
  expect_true(!is.na(result))
  expect_true(result >= 0)
  # For CTL/MA: growth_efficiency_factor = 1
})

test_that("calc_meat_allocation_energy returns correct value for camelids", {
  result <- calc_meat_allocation_energy(
    species_short = "CML",
    cohort_short = "FA",
    meat_production_live_weight_cohort = 80,
    live_weight_cohort_at_slaughter = 450,
    live_weight_at_birth = 35,
    ratio_me_to_ne = 2.33
  )

  expect_type(result, "double")
  expect_true(!is.na(result))
  # For CML: specific_energy = (41.8 * (slaughter - birth) / slaughter) / ratio_me_to_ne
  expected_specific <- (41.8 * (450 - 35) / 450) / 2.33
  expect_equal(result, expected_specific * 80)
})

test_that("calc_meat_allocation_energy returns correct value for sheep female", {
  result <- calc_meat_allocation_energy(
    species_short = "SHP",
    cohort_short = "FA",
    meat_production_live_weight_cohort = 20,
    live_weight_cohort_at_slaughter = 60,
    live_weight_at_birth = 4
  )

  expect_type(result, "double")
  expect_true(!is.na(result))
  # For SHP/FA: a = 2.1, b = 0.45
  expected_specific <- ((60 - 4) * (2.1 + 0.5 * 0.45 * (4 + 60))) / 60
  expect_equal(result, expected_specific * 20)
})

test_that("calc_meat_allocation_energy returns correct value for sheep male", {
  result <- calc_meat_allocation_energy(
    species_short = "SHP",
    cohort_short = "MA",
    meat_production_live_weight_cohort = 25,
    live_weight_cohort_at_slaughter = 70,
    live_weight_at_birth = 4.5
  )

  expect_type(result, "double")
  expect_true(!is.na(result))
  # For SHP/MA: a = 4.4, b = 0.32
  expected_specific <- ((70 - 4.5) * (4.4 + 0.5 * 0.32 * (4.5 + 70))) / 70
  expect_equal(result, expected_specific * 25)
})

test_that("calc_meat_allocation_energy returns correct value for goats", {
  result <- calc_meat_allocation_energy(
    species_short = "GTS",
    cohort_short = "FA",
    meat_production_live_weight_cohort = 15,
    live_weight_cohort_at_slaughter = 50,
    live_weight_at_birth = 3.5
  )

  expect_type(result, "double")
  expect_true(!is.na(result))
  # For GTS: a = 5, b = 0.33 (fixed for all cohorts)
  expected_specific <- ((50 - 3.5) * (5 + 0.5 * 0.33 * (3.5 + 50))) / 50
  expect_equal(result, expected_specific * 15)
})

test_that("calc_meat_allocation_energy returns correct value for chickens", {
  result <- calc_meat_allocation_energy(
    species_short = "CHK",
    cohort_short = "FJ",
    meat_production_live_weight_cohort = 10,
    live_weight_cohort_at_slaughter = 2,
    live_weight_at_birth = 0.04
  )

  expected_specific <- (((0.0279 + 0.0202) / 2) * 1000 * (2 - 0.04)) / 2
  expect_equal(result, expected_specific * 10)
})

test_that("calc_meat_allocation_energy uses explicit egg-producing FN flag", {
  result <- calc_meat_allocation_energy(
    species_short = "CHK",
    cohort_short = "FN",
    nondemo_productive_phase_id = 2,
    meat_production_live_weight_cohort = 10,
    live_weight_cohort_at_slaughter = 2,
    live_weight_at_birth = 0.04,
    is_egg_producing = TRUE
  )

  expected_specific <- (((0.0279 + 0.0202) / 2) * 1000 * (2 - 0.04)) / 2
  expect_equal(result, expected_specific * 10)
})

test_that("calc_meat_allocation_energy validates animal species", {
  expect_error(
    calc_meat_allocation_energy(
      species_short = "INVALID",
      cohort_short = "FA",
      meat_production_live_weight_cohort = 100
    ),
    "must be one of"
  )
})

test_that("calc_meat_allocation_energy validates cohort codes", {
  expect_error(
    calc_meat_allocation_energy(
      species_short = "CTL",
      cohort_short = "INVALID",
      meat_production_live_weight_cohort = 100,
      live_weight_cohort_at_slaughter = 500,
      live_weight_at_birth = 40
    ),
    "must be one of"
  )
})

test_that("calc_meat_allocation_energy validates weight bounds for non-PGS", {
  expect_error(
    calc_meat_allocation_energy(
      species_short = "CTL",
      cohort_short = "FA",
      meat_production_live_weight_cohort = 100,
      live_weight_cohort_at_slaughter = -10,
      live_weight_at_birth = 40
    ),
    "is out of range"
  )
  expect_error(
    calc_meat_allocation_energy(
      species_short = "CTL",
      cohort_short = "FA",
      meat_production_live_weight_cohort = 100,
      live_weight_cohort_at_slaughter = 500,
      live_weight_at_birth = 1500
    ),
    "is out of range"
  )
})

test_that("calc_meat_allocation_energy validates ratio_me_to_ne for CML only", {
  expect_error(
    calc_meat_allocation_energy(
      species_short = "CML",
      cohort_short = "FA",
      meat_production_live_weight_cohort = 80,
      live_weight_cohort_at_slaughter = 450,
      live_weight_at_birth = 35,
      ratio_me_to_ne = -1
    ),
    "must be a positive numeric value"
  )
  # Non-CML: ratio_me_to_ne is not validated even if negative
  expect_no_error(
    calc_meat_allocation_energy(
      species_short = "CTL",
      cohort_short = "FA",
      meat_production_live_weight_cohort = 100,
      live_weight_cohort_at_slaughter = 500,
      live_weight_at_birth = 40,
      ratio_me_to_ne = -1
    )
  )
})

# ---- test calc_fibre_allocation_energy ----

test_that("calc_fibre_allocation_energy returns correct value for sheep", {
  result <- calc_fibre_allocation_energy(
    species_short = "SHP",
    cohort_stock_size = 100,
    metabolic_energy_req_fibre_production = 5,
    simulation_duration = 365
  )

  expect_type(result, "double")
  expect_length(result, 1)
  expect_equal(result, 5 * 365 * 100)
})

test_that("calc_fibre_allocation_energy returns correct value for goats", {
  result <- calc_fibre_allocation_energy(
    species_short = "GTS",
    cohort_stock_size = 100,
    metabolic_energy_req_fibre_production = 4,
    simulation_duration = 365
  )

  expect_equal(result, 4 * 365 * 100)
})

test_that("calc_fibre_allocation_energy returns correct value for camelids", {
  result <- calc_fibre_allocation_energy(
    species_short = "CML",
    cohort_stock_size = 100,
    metabolic_energy_req_fibre_production = 6,
    ratio_me_to_ne = 2.33,
    simulation_duration = 365
  )

  expect_type(result, "double")
  # For camelids: (metabolic_energy_req / ratio_me_to_ne) * simulation_duration * cohort_stock_size
  expect_equal(result, (6 / 2.33) * 365 * 100)
})

test_that("calc_fibre_allocation_energy returns zero for non-fibre species (no extra args needed)", {
  expect_equal(calc_fibre_allocation_energy(species_short = "CTL"), 0)
  expect_equal(calc_fibre_allocation_energy(species_short = "BFL"), 0)
  expect_equal(calc_fibre_allocation_energy(species_short = "PGS"), 0)
})

test_that("calc_fibre_allocation_energy validates inputs", {
  expect_error(
    calc_fibre_allocation_energy(species_short = "INVALID"),
    "must be one of"
  )
  expect_error(
    calc_fibre_allocation_energy(
      species_short = "SHP",
      cohort_stock_size = 100,
      metabolic_energy_req_fibre_production = -5,
      simulation_duration = 365
    ),
    "is out of range"
  )
  # ratio_me_to_ne only validated for CML, not SHP
  expect_no_error(
    calc_fibre_allocation_energy(
      species_short = "SHP",
      cohort_stock_size = 100,
      metabolic_energy_req_fibre_production = 5,
      ratio_me_to_ne = -0.1,
      simulation_duration = 365
    )
  )
  expect_error(
    calc_fibre_allocation_energy(
      species_short = "CML",
      cohort_stock_size = 100,
      metabolic_energy_req_fibre_production = 5,
      ratio_me_to_ne = -0.1,
      simulation_duration = 365
    ),
    "must be a positive numeric value"
  )
})

# ---- test calc_work_allocation_energy ----

test_that("calc_work_allocation_energy returns correct value for camelids", {
  result <- calc_work_allocation_energy(
    species_short = "CML",
    cohort_stock_size = 100,
    metabolic_energy_req_work = 10,
    simulation_duration = 365,
    ratio_me_to_ne = 2.33
  )

  expect_type(result, "double")
  expect_length(result, 1)
  # For camelids: (work_energy * simulation_duration * cohort_stock_size) / ratio_me_to_ne
  expect_equal(result, (10 * 365 * 100) / 2.33)
})

test_that("calc_work_allocation_energy returns correct value for non-camelids (ratio_me_to_ne not needed)", {
  result <- calc_work_allocation_energy(
    species_short = "CTL",
    cohort_stock_size = 100,
    metabolic_energy_req_work = 8,
    simulation_duration = 365
  )

  expect_type(result, "double")
  # For non-camelids: direct calculation (ratio not applied)
  expect_equal(result, 8 * 365 * 100)
})

test_that("calc_work_allocation_energy handles zero energy requirement", {
  result <- calc_work_allocation_energy(
    species_short = "CTL",
    cohort_stock_size = 100,
    metabolic_energy_req_work = 0,
    simulation_duration = 365
  )

  expect_equal(result, 0)
})

test_that("calc_work_allocation_energy validates inputs", {
  expect_error(
    calc_work_allocation_energy(
      species_short = "INVALID",
      cohort_stock_size = 100,
      metabolic_energy_req_work = 10,
      simulation_duration = 365
    ),
    "must be one of"
  )
  expect_error(
    calc_work_allocation_energy(
      species_short = "CTL",
      cohort_stock_size = 100,
      metabolic_energy_req_work = -5,
      simulation_duration = 365
    ),
    "is out of range"
  )
  expect_error(
    calc_work_allocation_energy(
      species_short = "CTL",
      cohort_stock_size = 100,
      metabolic_energy_req_work = 10,
      simulation_duration = 5000
    ),
    "is out of range"
  )
  # ratio_me_to_ne only validated for CML
  expect_error(
    calc_work_allocation_energy(
      species_short = "CML",
      cohort_stock_size = 100,
      metabolic_energy_req_work = 10,
      simulation_duration = 365,
      ratio_me_to_ne = -0.1
    ),
    "must be a positive numeric value"
  )
  expect_no_error(
    calc_work_allocation_energy(
      species_short = "CTL",
      cohort_stock_size = 100,
      metabolic_energy_req_work = 10,
      simulation_duration = 365,
      ratio_me_to_ne = -0.1
    )
  )
})

# ---- test calc_egg_allocation_energy ----

test_that("calc_egg_allocation_energy returns expected value for chickens", {
  result <- calc_egg_allocation_energy(
    species_short = "CHK",
    cohort_short = "FA",
    egg_production_mass_cohort = 100,
    is_egg_producing = TRUE
  )

  expect_equal(result, 100 * 10.04)
  expect_equal(
    calc_egg_allocation_energy(
      species_short = "CHK",
      cohort_short = "FS",
      egg_production_mass_cohort = 100
    ),
    0
  )
})

test_that("calc_egg_allocation_energy returns expected value for egg-producing chicken FN", {
  result <- calc_egg_allocation_energy(
    species_short = "CHK",
    cohort_short = "FN",
    nondemo_productive_phase_id = 2,
    egg_production_mass_cohort = 100,
    is_egg_producing = TRUE
  )

  expect_equal(result, 100 * 10.04)
})

test_that("calc_egg_allocation_energy validates egg-producing flag placement", {
  expect_error(
    calc_egg_allocation_energy(
      species_short = "CHK",
      cohort_short = "FS",
      egg_production_mass_cohort = 100,
      is_egg_producing = TRUE
    ),
    "can be TRUE only for CHK cohorts.*FA.*FN"
  )

  expect_error(
    calc_egg_allocation_energy(
      species_short = "CHK",
      cohort_short = "FN",
      nondemo_productive_phase_id = 1,
      egg_production_mass_cohort = 100,
      is_egg_producing = TRUE
    ),
    "can be TRUE for.*FN.*only when.*2"
  )
})

test_that("run_allocation_module example inputs work with explicit egg columns", {
  cohort_path <- local({
    p <- testthat::test_path(
      "..", "..", "inst", "extdata", "run_modules_examples", "allocation_input_chrt_data.csv"
    )
    if (file.exists(p)) p else system.file(
      "extdata", "run_modules_examples", "allocation_input_chrt_data.csv",
      package = "gleam"
    )
  })
  herd_path <- local({
    p <- testthat::test_path(
      "..", "..", "inst", "extdata", "run_modules_examples", "allocation_input_hrd_data.csv"
    )
    if (file.exists(p)) p else system.file(
      "extdata", "run_modules_examples", "allocation_input_hrd_data.csv",
      package = "gleam"
    )
  })

  cohort_level_data <- data.table::fread(
    cohort_path,
    sep = "\t"
  )
  herd_level_data <- data.table::fread(
    herd_path,
    sep = "\t"
  )

  result <- run_allocation_module(
    cohort_level_data = cohort_level_data,
    herd_level_data = herd_level_data,
    simulation_duration = 365,
    show_indicator = FALSE
  )

  expect_true("egg_allocation_energy" %in% names(result$cohort_allocation_inputs))
  expect_true("allocation_long" %in% names(result))
})

test_that("run_allocation_module requires explicit egg/allocation columns", {
  cohort_path <- local({
    p <- testthat::test_path(
      "..", "..", "inst", "extdata", "run_modules_examples", "allocation_input_chrt_data.csv"
    )
    if (file.exists(p)) p else system.file(
      "extdata", "run_modules_examples", "allocation_input_chrt_data.csv",
      package = "gleam"
    )
  })
  herd_path <- local({
    p <- testthat::test_path(
      "..", "..", "inst", "extdata", "run_modules_examples", "allocation_input_hrd_data.csv"
    )
    if (file.exists(p)) p else system.file(
      "extdata", "run_modules_examples", "allocation_input_hrd_data.csv",
      package = "gleam"
    )
  })

  cohort_level_data <- data.table::fread(
    cohort_path,
    sep = "\t"
  )
  herd_level_data <- data.table::fread(
    herd_path,
    sep = "\t"
  )

  expect_error(
    run_allocation_module(
      cohort_level_data = cohort_level_data[, !"egg_production_mass_cohort"],
      herd_level_data = herd_level_data,
      simulation_duration = 365,
      show_indicator = FALSE
    ),
    "egg_production_mass_cohort"
  )

  non_chk_cohort <- cohort_level_data[species_short != "CHK"][, !"is_egg_producing"]
  non_chk_herd <- herd_level_data[species_short != "CHK"]

  expect_no_error(
    run_allocation_module(
      cohort_level_data = non_chk_cohort,
      herd_level_data = non_chk_herd,
      simulation_duration = 365,
      show_indicator = FALSE
    )
  )

  expect_error(
    run_allocation_module(
      cohort_level_data = cohort_level_data[, !"is_egg_producing"],
      herd_level_data = herd_level_data,
      simulation_duration = 365,
      show_indicator = FALSE
    ),
    "is_egg_producing"
  )
})

# ---- test calc_allocation_shares ----

test_that("calc_allocation_shares returns meat=1 and others=0 for pigs (PGS)", {
  result <- calc_allocation_shares(
    species_short = "PGS",
    meat_allocation_energy = NA,
    milk_allocation_energy = 0,
    fibre_allocation_energy = 0,
    work_allocation_energy = 0,
    egg_allocation_energy = 0
  )

  expect_equal(result$meat_share_allocation, 1)
  expect_equal(result$milk_share_allocation, 0)
  expect_equal(result$fibre_share_allocation, 0)
  expect_equal(result$work_share_allocation, 0)
  expect_equal(result$eggs_share_allocation, 0)
})

test_that("calc_allocation_shares returns correct proportions for milk and meat", {
  result <- calc_allocation_shares(
    species_short = "CTL",
    meat_allocation_energy = 300,
    milk_allocation_energy = 700,
    fibre_allocation_energy = 0,
    work_allocation_energy = 0,
    egg_allocation_energy = 0
  )

  expect_equal(result$meat_share_allocation, 0.3)
  expect_equal(result$milk_share_allocation, 0.7)
  expect_equal(result$fibre_share_allocation, 0)
  expect_equal(result$work_share_allocation, 0)
  expect_equal(result$eggs_share_allocation, 0)
})

test_that("calc_allocation_shares shares sum to 1", {
  result <- calc_allocation_shares(
    species_short = "SHP",
    meat_allocation_energy = 200,
    milk_allocation_energy = 0,
    fibre_allocation_energy = 300,
    work_allocation_energy = 0,
    egg_allocation_energy = 0
  )

  total <- result$meat_share_allocation + result$milk_share_allocation +
    result$fibre_share_allocation + result$work_share_allocation +
    result$eggs_share_allocation

  expect_equal(total, 1)
  expect_equal(result$meat_share_allocation, 0.4)
  expect_equal(result$fibre_share_allocation, 0.6)
})

test_that("calc_allocation_shares returns a named list with 5 elements", {
  result <- calc_allocation_shares(
    species_short = "CTL",
    meat_allocation_energy = 500,
    milk_allocation_energy = 500,
    fibre_allocation_energy = 0,
    work_allocation_energy = 0,
    egg_allocation_energy = 0
  )

  expect_type(result, "list")
  expect_named(result, c(
    "meat_share_allocation", "milk_share_allocation",
    "fibre_share_allocation", "work_share_allocation", "eggs_share_allocation"
  ))
})

test_that("calc_allocation_shares includes eggs for chickens", {
  result <- calc_allocation_shares(
    species_short = "CHK",
    meat_allocation_energy = 20,
    milk_allocation_energy = 0,
    fibre_allocation_energy = 0,
    work_allocation_energy = 0,
    egg_allocation_energy = 80
  )

  expect_equal(result$meat_share_allocation, 0.2)
  expect_equal(result$eggs_share_allocation, 0.8)
})
