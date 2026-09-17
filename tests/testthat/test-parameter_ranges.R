test_that("bundled ranges remain common to every species and cohort", {
  ranges <- get_parameter_range_rules()
  expect_true(all(ranges$species_short == "ANY"))
  expect_true(all(ranges$cohort_short == "ANY"))
  expect_equal(anyDuplicated(ranges$variable), 0L)
  for (species in gleam_species) {
    for (cohort in gleam_cohorts) {
      expect_no_error(validate_param_range(
        c(0, 1000), "live_weight_at_birth", species_filter = species, cohort_filter = cohort
      ))
      expect_error(validate_param_range(
        1001, "live_weight_at_birth", species_filter = species, cohort_filter = cohort
      ), "out of range")
    }
  }
})

test_that("bounds on dependency rows keep their independent range scope", {
  rules <- data.table::data.table(
    variable = c("herd_id", "example_parameter"), species_short = "ANY",
    cohort_short = c("ANY", "FA"), requirement = "R", input_table = "herd_level_data",
    has_herd_structure = "ANY", run_weights = "X",
    lower_bound = c(NA_real_, 0), lower_inclusive = c(NA, TRUE),
    upper_bound = c(NA_real_, 10), upper_inclusive = c(NA, TRUE),
    range_species_short = c("", "ANY"), range_cohort_short = c("", "ANY")
  )
  context <- data.table::data.table(species_short = "CTL", cohort_short = "FA")
  expect_setequal(unique(get_required_parameter_rules(context, "weights", dependencies = rules)$variable),
                  c("herd_id", "example_parameter"))
  context[, cohort_short := "MA"]
  expect_equal(unique(get_required_parameter_rules(context, "weights", dependencies = rules)$variable), "herd_id")
  # The common bounds still apply outside the dependency's cohort and without context.
  expect_no_error(validate_param_range(10, "example_parameter", rules))
  expect_error(validate_param_range(11, "example_parameter", rules, "CTL", "MA"), "out of range")
  rules[variable == "example_parameter", upper_bound := 5]
  expect_error(validate_param_range(6, "example_parameter", rules, "CTL", "FA"), "out of range")
})

test_that("matching species and cohort rules tighten common limits", {
  rules <- data.table::data.table(
    variable = "example_parameter", species_short = c("ANY", "CTL", "ANY", "CTL"),
    cohort_short = c("ANY", "ANY", "FJ", "FJ"),
    lower_bound = 0, lower_inclusive = TRUE,
    upper_bound = c(100, 10, 7, 5), upper_inclusive = TRUE
  )
  original <- data.table::copy(rules)
  expect_no_error(validate_param_range(90, "example_parameter", rules))
  expect_no_error(validate_param_range(9, "example_parameter", rules, "CTL", "FA"))
  expect_error(validate_param_range(11, "example_parameter", rules, "CTL", "FA"), "CTL/FA")
  expect_no_error(validate_param_range(7, "example_parameter", rules, "PGS", "FJ"))
  expect_error(validate_param_range(8, "example_parameter", rules, "PGS", "FJ"), "PGS/FJ")
  expect_no_error(validate_param_range(5, "example_parameter", rules, "CTL", "FJ"))
  expect_error(validate_param_range(c(first = 5, second = 6), "example_parameter", rules, "CTL", "FJ"), "second.*out of range")
  expect_equal(rules, original)
})

test_that("scoped range endpoints, conflicts and invalid rules are checked", {
  rules <- data.table::data.table(
    variable = "example_parameter", species_short = c("ANY", "CTL"), cohort_short = "ANY",
    lower_bound = 0, lower_inclusive = c(TRUE, FALSE),
    upper_bound = 10, upper_inclusive = c(TRUE, FALSE)
  )
  expect_no_error(validate_param_range(c(0, 10), "example_parameter", rules, "PGS"))
  expect_error(validate_param_range(0, "example_parameter", rules, "CTL"), "out of range")
  expect_error(validate_param_range(10, "example_parameter", rules, "CTL"), "out of range")
  duplicate <- data.table::rbindlist(list(rules, rules[1]))
  expect_no_error(validate_param_range(5, "example_parameter", duplicate))
  duplicate[3L, upper_bound := 9]
  expect_error(validate_param_range(5, "example_parameter", duplicate), "Duplicate parameter range")
  conflict <- data.table::copy(rules)
  conflict[species_short == "CTL", lower_bound := 10]
  expect_error(validate_param_range(5, "example_parameter", conflict, "CTL"), "Conflicting parameter range")
  invalid <- data.table::copy(rules)
  invalid[species_short == "CTL", species_short := "CTLL"]
  expect_error(validate_param_range(5, "example_parameter", invalid), "Invalid species/cohort scope")
  expect_error(validate_param_range(5, "example_parameter", rules, "DOG"), "species_short")
  expect_error(validate_param_range(5, "example_parameter", rules, "CTL", "XX"), "cohort_short")
  expect_error(validate_param_range(5, "absent_parameter", rules), "No parameter range rule")
  legacy <- rules[1, !c("species_short", "cohort_short")]
  expect_no_error(validate_param_range(10, "example_parameter", legacy, "CTL", "FA"))
  expect_named(legacy, c("variable", "lower_bound", "lower_inclusive", "upper_bound", "upper_inclusive"))
})

test_that("standalone weights and modules use their supplied range context", {
  specific <- data.table::copy(parameter_rules[variable == "live_weight_female_adult"][1L])
  specific[, `:=`(range_species_short = "CTL", range_cohort_short = "FA", upper_bound = 400)]
  ranges <- data.table::rbindlist(list(parameter_rules, specific))
  testthat::local_mocked_bindings(parameter_rules = ranges, .package = "gleam")
  expect_error(calc_cohort_weights("FA", live_weight_female_adult = 500, species_short = "CTL"), "out of range.*CTL/FA")
  expect_no_error(calc_cohort_weights("FA", live_weight_female_adult = 500, species_short = "PGS"))
  # Omitting species continues to use the common bounds.
  expect_no_error(calc_cohort_weights("FA", live_weight_female_adult = 500))
  cohorts <- data.table::data.table(
    herd_id = c("cattle", "pigs"), species_short = c("CTL", "PGS"),
    cohort_short = "FA", offtake_rate = 0, cohort_duration_days = 365
  )
  herd <- data.table::data.table(herd_id = c("cattle", "pigs"), live_weight_female_adult = c(350, 500))
  expect_no_error(run_weights_module(cohorts, herd, FALSE))
  herd[herd_id == "cattle", live_weight_female_adult := 500]
  expect_error(run_weights_module(cohorts, herd, FALSE), "out of range.*CTL/FA")
})

test_that("contextual range checks match feed IDs and allow missing optional values", {
  specific <- data.table::copy(parameter_rules[variable == "feed_gross_energy"][1L])
  specific[, `:=`(range_species_short = "CTL", range_cohort_short = "FJ", upper_bound = 20)]
  testthat::local_mocked_bindings(
    parameter_rules = data.table::rbindlist(list(parameter_rules, specific)), .package = "gleam"
  )
  context <- data.table::data.table(
    herd_id = 1:2, species_short = c("CTL", "PGS"), cohort_short = "FJ", feed_id = 1:2
  )
  feed <- data.table::data.table(feed_id = 1:3, feed_gross_energy = c(15, 40, 100))
  expect_no_error(check_contextual_parameter_ranges(feed, context))
  feed[feed_id == 1, feed_gross_energy := 25]
  expect_error(check_contextual_parameter_ranges(feed, context), "CTL/FJ")
  feed[feed_id == 1, feed_gross_energy := NA_real_]
  expect_no_error(check_contextual_parameter_ranges(feed, context))
})

test_that("both pipeline modes apply scoped ranges before calculations", {
  specific <- data.table::copy(parameter_rules[variable == "live_weight_female_adult"][1L])
  specific[, `:=`(range_species_short = "CTL", range_cohort_short = "FA", upper_bound = 1)]
  testthat::local_mocked_bindings(
    parameter_rules = data.table::rbindlist(list(parameter_rules, specific)), .package = "gleam"
  )
  path <- system.file("extdata/run_gleam_examples", package = "gleam")
  for (mode in c(FALSE, TRUE)) {
    cohort_file <- if (mode) "master_chrt_lvl_structure_data.csv" else "master_chrt_lvl_no_structure_data.csv"
    cohorts <- data.table::fread(file.path(path, cohort_file))[herd_id == 1]
    if (mode) cohorts <- cohorts[cohort_short == "FA"]
    selected_cohorts <- cohorts$cohort_short
    feed <- data.table::fread(file.path(path, "feed_rations_share_chrt.csv"))[herd_id == 1 & cohort_short %in% selected_cohorts]
    expect_error(run_gleam(
      has_herd_structure = mode, cohort_level_data = cohorts,
      herd_level_data = data.table::fread(file.path(path, "master_hrd_lvl_data.csv"))[herd_id == 1],
      feed_rations = feed,
      feed_params = data.table::fread(file.path(path, "feed_quality.csv"))[feed_id %in% feed$feed_id],
      feed_emissions = data.table::fread(file.path(path, "feed_emission_factors.csv"))[feed_id %in% feed$feed_id],
      manure_management_system_fraction = data.table::fread(file.path(path, "manure_management_system_fraction.csv"))[herd_id == 1 & cohort_short %in% selected_cohorts],
      manure_management_system_factors = data.table::fread(file.path(path, "manure_management_system_factors.csv"))[herd_id == 1],
      show_indicator = FALSE
    ), "out of range.*CTL/FA")
  }
})
