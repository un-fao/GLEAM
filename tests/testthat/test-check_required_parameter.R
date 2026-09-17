test_that("the public helper accepts cohort lists without input data", {
  rules <- gleam::check_required_parameter(
    cohort_short = c("FA", "MA"),
    module_filter = NULL,
    has_herd_structure_filter = TRUE
  )
  expect_s3_class(rules, "data.table")
  expect_setequal(unique(rules$cohort_short), c("FA", "MA"))
  expect_setequal(unique(rules$species_short), gleam_species)
  expect_true(all(rules$has_herd_structure %in% c("TRUE", "ANY")))
  expect_false("herd_size_total" %in% rules$variable)
  expect_true("cohort_stock_size" %in% rules$variable)
  expect_false("ch4_mitigation_factor" %in% rules$variable)
})

test_that("weight requirements are specific to the selected cohorts", {
  female <- check_required_parameter(
    "FA", module_filter = "run_weights", species_short = "CTL",
    input_table_filter = "herd_level_data"
  )
  expect_equal(female$variable, "live_weight_female_adult")
  expect_equal(female$species_short, "CTL")
  expect_equal(female$cohort_short, "FA")

  adults <- check_required_parameter(
    c("MA", "FA", "FA"), module_filter = "weights", species_short = c("CTL", "PGS", "CTL"),
    input_table_filter = "herd_level_data"
  )
  expect_equal(nrow(adults), 4L)
  expect_true(all(adults[cohort_short == "FA", variable] == "live_weight_female_adult"))
  expect_true(all(adults[cohort_short == "MA", variable] == "live_weight_male_adult"))
})

test_that("optional mitigation is excluded from required columns in every pipeline mode", {
  for (module in c("enteric", "run_gleam")) for (mode in c(FALSE, TRUE)) {
    rules <- check_required_parameter(
      gleam_cohorts, module_filter = module, has_herd_structure_filter = mode,
      input_table_filter = "cohort_level_data"
    )[variable == "ch4_mitigation_factor"]
    expect_equal(nrow(rules), 0L)
  }
})

test_that("multiple input tables return their combined requirements without duplicates", {
  tables <- c("cohort_level_data", "herd_level_data")
  rules <- check_required_parameter(
    "FJ", module_filter = "run_gleam", has_herd_structure_filter = TRUE,
    species_short = "CTL", input_table_filter = tables
  )
  expect_setequal(unique(rules$input_table), tables)
  for (table in tables) {
    expect_equal(rules[input_table == table], check_required_parameter(
      "FJ", module_filter = "run_gleam", has_herd_structure_filter = TRUE,
      species_short = "CTL", input_table_filter = table
    ))
  }
  expect_equal(rules, check_required_parameter(
    "FJ", module_filter = "run_gleam", has_herd_structure_filter = TRUE,
    species_short = "CTL", input_table_filter = c(tables, tables)
  ))
})

test_that("run_gleam explicitly selects pipeline requirements in both modes", {
  for (mode in list(NULL, TRUE, FALSE)) {
    expect_equal(
      check_required_parameter(c("FA", "MA"), module_filter = "run_gleam",
                                     has_herd_structure_filter = mode),
      check_required_parameter(c("FA", "MA"), has_herd_structure_filter = mode)
    )
  }
})

test_that("the pipeline column controls requirements independently of module flags", {
  deps <- data.table::copy(parameter_rules)
  deps[variable == "live_weight_female_adult", run_gleam := ""]
  testthat::local_mocked_bindings(parameter_rules = deps, .package = "gleam")
  for (module in list(NULL, "run_gleam")) {
    rules <- check_required_parameter("FA", module_filter = module, species_short = "CTL")
    expect_false("live_weight_female_adult" %in% rules$variable)
  }
  weights <- check_required_parameter("FA", module_filter = "weights", species_short = "CTL")
  expect_true("live_weight_female_adult" %in% weights$variable)
})

test_that("species and herd-structure differences remain visible", {
  production <- check_required_parameter(
    c("FA", "MA"), species_short = c("PGS", "CTL"), module_filter = "production"
  )
  milk <- production[variable == "milk_yield_day"]
  expect_equal(milk$species_short, "CTL")
  expect_equal(milk$cohort_short, "FA")

  simulated <- check_required_parameter("FA", species_short = "CTL", has_herd_structure_filter = FALSE)
  expect_true("herd_size_total" %in% simulated$variable)
  expect_false("cohort_stock_size" %in% simulated$variable)
  expect_true(all(simulated$has_herd_structure %in% c("FALSE", "ANY")))
})

test_that("invalid filters are rejected and valid empty results are allowed", {
  for (cohort in list(character(), NULL, 1, list("FA"), NA_character_, "XX")) {
    expect_error(check_required_parameter(cohort), "cohort_short")
  }
  for (species in list(character(), 1, NA_character_, "DOG")) {
    expect_error(check_required_parameter("FA", species_short = species), "species_short")
  }
  expect_error(check_required_parameter("FA", module_filter = "weight"), "Unknown module filter")
  expect_error(check_required_parameter("FA", input_table_filter = "herd_data"), "Unknown input table filter")
  expect_error(check_required_parameter("FA", input_table_filter = c("herd_level_data", "herd_data")), "Unknown input table filter.*herd_data")
  for (tables in list(character(), 1, list("herd_level_data"), NA_character_, c("herd_level_data", NA_character_))) {
    expect_error(check_required_parameter("FA", input_table_filter = tables), "input_table_filter")
  }
  expect_error(check_required_parameter("FA", has_herd_structure_filter = NA), "TRUE or FALSE")
  empty <- check_required_parameter("FA", module_filter = "weights", input_table_filter = "feed_params")
  expect_equal(nrow(empty), 0L)
  expect_named(empty, c("input_table", "variable", "species_short", "cohort_short", "has_herd_structure"))
})

test_that("inspecting rules does not modify the dependency matrix", {
  before <- data.table::copy(parameter_rules)
  check_required_parameter(c("FA", "MA"), species_short = "CTL")
  expect_equal(parameter_rules, before)
})

test_that("overlapping pipeline rules report each required column once", {
  rules <- check_required_parameter(
    cohort_short = "FA", module_filter = NULL,
    has_herd_structure_filter = FALSE, species_short = "CTL",
    input_table_filter = "herd_level_data"
  )
  expect_equal(anyDuplicated(rules$variable), 0L)
  expect_equal(nrow(rules[variable == "parturition_rate"]), 1L)
  expect_equal(rules[variable == "parturition_rate", has_herd_structure], "ANY")
  expect_equal(rules[variable == "herd_size_total", has_herd_structure], "FALSE")
  # The distinct source rules remain available to the model validators.
  expect_setequal(parameter_rules[
    requirement %in% c("R", "O") & species_short %in% c("ANY", "CTL") &
      cohort_short %in% c("ANY", "FA") & variable == "parturition_rate",
    has_herd_structure
  ], c("ANY", "FALSE"))
})

test_that("combined mode reporting respects the selected mode", {
  deps <- data.table::copy(parameter_rules)
  both_modes <- deps[
    requirement %in% c("R", "O") & species_short %in% c("ANY", "CTL") &
      cohort_short %in% c("ANY", "FA") & variable == "parturition_rate"
  ]
  both_modes[, `:=`(variable = "both_modes_parameter", species_short = "CTL", cohort_short = "FA")]
  both_modes[has_herd_structure == "ANY", has_herd_structure := "TRUE"]
  deps <- data.table::rbindlist(list(deps, both_modes))
  testthat::local_mocked_bindings(parameter_rules = deps, .package = "gleam")
  for (mode in list(NULL, FALSE, TRUE)) {
    result <- check_required_parameter("FA", species_short = "CTL", has_herd_structure_filter = mode)
    expected <- if (is.null(mode)) "ANY" else as.character(mode)
    expect_equal(result[variable == "both_modes_parameter", has_herd_structure], expected)
  }
})
