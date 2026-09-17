test_that("module requirements follow the supplied matrix and exact requested pairs", {
  requested <- data.table::data.table(
    species_short = c("CTL", "PGS"), cohort_short = c("FA", "MJ")
  )
  original <- data.table::copy(parameter_rules)
  expect_setequal(
    unique(get_required_parameter_rules(requested, "weights", "herd_level_data")$variable),
    c("live_weight_female_adult", "live_weight_male_adult", "live_weight_at_birth", "live_weight_at_weaning")
  )
  expect_setequal(
    unique(get_required_parameter_rules(requested, "weights", "cohort_level_data")$variable),
    c("herd_id", "species_short", "cohort_short", "cohort_duration_days", "offtake_rate")
  )
  extra <- get_required_parameter_rules(
    data.table::data.table(species_short = "CTL", cohort_short = "MJ"), "weights"
  )[variable == "live_weight_at_birth"]
  extra[, variable := "unrequested_pair"]
  deps <- data.table::rbindlist(list(original, extra))
  expect_false("unrequested_pair" %in% unique(get_required_parameter_rules(
    requested, "weights", "herd_level_data", dependencies = deps
  )$variable))
  expect_equal(parameter_rules, original)
  expect_error(unique(get_required_parameter_rules(requested, "unknown")$variable), "Unknown module filter")
})

test_that("function lookup matches exact names within workbook evidence cells", {
  expect_setequal(
    get_required_function_parameters("FJ", "calc_cohort_weights", "CTL"),
    c("live_weight_female_adult", "live_weight_at_birth", "live_weight_at_weaning")
  )
  expect_equal(get_required_function_parameters("FA", "calc_avg_weights", "CTL"), "offtake_rate")
  expect_equal(get_required_function_parameters("FA", "calc_daily_weight_gain", "CTL"), "cohort_duration_days")
  expect_error(get_required_function_parameters("FA", "calc_avg", "CTL"), "Missing parameter dependency rules")
  normalized <- data.table::copy(parameter_rules)
  data.table::setnames(normalized, "evidence_function", "function")
  expect_equal(
    get_required_function_parameters("FA", "calc_avg_weights", "CTL", dependencies = normalized),
    "offtake_rate"
  )
})

test_that("internal lookups allow derived tables outside the raw-input matrix", {
  requested <- data.table::data.table(species_short = "CTL", cohort_short = "FA")
  expect_equal(unique(get_required_parameter_rules(requested, "aggregation", "allocation_herd_long")$variable), character())
  expect_error(check_required_parameter("FA", input_table_filter = "allocation_herd_long"), "Unknown input table filter")
})

test_that("herd-structure and optional-rule filters preserve their meaning", {
  requested <- data.table::data.table(species_short = "CTL", cohort_short = "FA")
  deps <- get_required_parameter_rules(requested, "weights")
  extra <- data.table::copy(deps[variable == "live_weight_female_adult"])
  extra[, `:=`(variable = "structure_only", has_herd_structure = "TRUE")]
  optional <- data.table::copy(extra)
  optional[, `:=`(variable = "optional_only", requirement = "O", has_herd_structure = "ANY")]
  deps <- data.table::rbindlist(list(deps, extra, optional))
  expect_setequal(
    unique(get_required_parameter_rules(requested, "weights", "herd_level_data", TRUE, deps)$variable),
    c("live_weight_female_adult", "structure_only")
  )
  expect_equal(
    unique(get_required_parameter_rules(requested, "weights", "herd_level_data", FALSE, deps)$variable),
    "live_weight_female_adult"
  )
  deps[, has_herd_structure := "TRUE"]
  expect_error(
    get_required_parameter_rules(requested, "weights", has_herd_structure_filter = FALSE, dependencies = deps),
    "Missing parameter dependency rules.*CTL/FA"
  )
})

test_that("missing dependency coverage cannot silently disable validation", {
  deps <- match_parameter_rule_context(
    parameter_rules[requirement %in% c("R", "O")],
    data.table::CJ(species_short = gleam_species, cohort_short = gleam_cohorts)
  )[!(species_short == "CTL" & cohort_short == "FA")]
  requested <- data.table::data.table(species_short = c("CTL", "PGS"), cohort_short = "FA")
  expect_error(
    unique(get_required_parameter_rules(requested, "weights", "herd_level_data", dependencies = deps)$variable),
    "Missing parameter dependency rules.*CTL/FA"
  )
  expect_error(
    get_required_function_parameters("FA", "calc_cohort_weights", "CTL", dependencies = deps),
    "Missing parameter dependency rules"
  )
  testthat::local_mocked_bindings(parameter_rules = deps, .package = "gleam")
  expect_error(calc_cohort_weights("FA", live_weight_female_adult = 500), "Missing parameter dependency rules")
})

test_that("empty and misspelled weight requirements are rejected", {
  deps <- data.table::copy(parameter_rules)
  deps[run_weights == "X" & cohort_short == "FA" & variable == "live_weight_female_adult", requirement := "O"]
  testthat::local_mocked_bindings(parameter_rules = deps, .package = "gleam")
  expect_error(calc_cohort_weights("FA"), "Invalid weight parameter dependency rules")
  deps[run_weights == "X" & cohort_short == "FA" & variable == "live_weight_female_adult", `:=`(
    variable = "misspelled_weight", requirement = "R"
  )]
  expect_error(calc_cohort_weights("FA"), "Invalid weight parameter dependency rules")
})

test_that("run_weights passes species to core validation without merging other species rules", {
  deps <- data.table::copy(parameter_rules)
  extra <- get_required_parameter_rules(
    data.table::data.table(species_short = "PGS", cohort_short = "FA"), "weights"
  )[variable == "live_weight_female_adult"]
  extra[, variable := "live_weight_male_adult"]
  deps <- data.table::rbindlist(list(deps, extra))
  testthat::local_mocked_bindings(parameter_rules = deps, .package = "gleam")
  expect_error(calc_cohort_weights("FA", live_weight_female_adult = 500), "differ by species")
  cohorts <- data.table::data.table(
    herd_id = "h1", species_short = "CTL", cohort_short = "FA",
    offtake_rate = 0, cohort_duration_days = 100
  )
  herd <- data.table::data.table(herd_id = "h1", live_weight_female_adult = 500)
  expect_no_error(run_weights_module(cohorts, herd, FALSE))
  cohorts[, species_short := "PGS"]
  herd[, live_weight_male_adult := NA_real_]
  expect_error(run_weights_module(cohorts, herd, FALSE), "Missing required weight inputs")
  herd[, live_weight_male_adult := 600]
  expect_no_error(run_weights_module(cohorts, herd, FALSE))
})

test_that("required values are checked only on their species/cohort rows", {
  context <- data.table::data.table(
    herd_id = c("milk", "male"), species_short = "CTL", cohort_short = c("FA", "MA")
  )
  rules <- unique(get_required_parameter_rules(context, "production", "herd_level_data")$variable)
  herd <- data.table::data.table(herd_id = context$herd_id, species_short = "CTL")
  for (parameter in setdiff(rules, c("herd_id", "species_short"))) {
    data.table::set(herd, j = parameter, value = 1)
  }
  herd[herd_id == "male", milk_yield_day := NA_real_]
  expect_no_error(check_module_input_columns(
    herd, c("herd_id", "species_short"), "herd_level_data", "production", context
  ))
  herd[herd_id == "milk", milk_yield_day := NA_real_]
  expect_error(check_module_input_columns(
    herd, c("herd_id", "species_short"), "herd_level_data", "production", context
  ), "milk_yield_day.*missing values")
})

test_that("standalone calculations accept omitted inputs only on unused branches", {
  expect_equal(calc_metabolic_energy_req_growth("CTL", "FA"), 0)
  expect_equal(calc_metabolic_energy_req_lactation("PGS", "MS"), 0)
  expect_equal(calc_metabolic_energy_req_pregnancy("CTL", "MJ"), 0)
  expect_equal(calc_metabolic_energy_req_work("SHP", "FA"), 0)
  expect_equal(calc_metabolic_energy_req_fibre("CTL", "FA"), 0)
  expect_equal(calc_fibre_production("CTL", "FA", simulation_duration = 365), 0)
  expect_equal(calc_milk_allocation_energy(0), 0)
  expect_equal(calc_ration_metabolizable_energy("PGS", 0.5, feed_metabolizable_energy_pigs = 12), 6)
  expect_error(calc_metabolic_energy_req_maintenance("SHP", "MS", 50, offtake_rate = 0.1), "age_first_parturition")
  expect_error(calc_nitrogen_retention("CTL", "FA", daily_weight_gain = 0), "milk_protein_fraction|milk_yield_day")
  expect_error(calc_milk_allocation_energy(10), "milk_protein_fraction_standard")

  # These branches formerly required reproductive inputs used only by FA.
  expect_equal(calc_metabolic_energy_req_pregnancy(
    "CTL", "FS", metabolic_energy_req_maintenance = 30,
    pregnancy_duration = 280, cohort_duration_days = 500, offtake_rate = 0.1
  ), 30 * 0.1 * 280 / 500 * 0.9)
  expect_equal(calc_metabolic_energy_req_pregnancy(
    "PGS", "FS", litter_size = 12, pregnancy_duration = 115,
    cohort_duration_days = 200, offtake_rate = 0.1
  ), 0.14985 * 12 * 115 / 200 * 0.9)
  expect_equal(calc_nitrogen_retention(
    "PGS", "FS", daily_weight_gain = 0.5, litter_size = 12,
    live_weight_at_birth = 1, pregnancy_duration = 115, cohort_duration_days = 200
  ), 0.025 * 0.5 + (0.025 * 12 * (115 / 200) / 0.806) / 365)
})

test_that("matrix checks reject missing feed rows and inconsistent species", {
  context <- data.table::data.table(
    herd_id = 1L, species_short = "CTL", cohort_short = "FA", feed_id = 2L
  )
  required <- unique(get_required_parameter_rules(context, "ration_quality", "feed_params")$variable)
  feed <- data.table::data.table(feed_id = 1L)
  for (parameter in required) data.table::set(feed, j = parameter, value = 1)
  expect_error(check_module_input_columns(
    feed, "feed_id", "feed_params", "ration_quality", context
  ), "Missing required rows.*feed_params")
  herd <- data.table::data.table(herd_id = 1L, species_short = "PGS")
  expect_error(get_parameter_context(context, herd), "species_short must agree")
})

test_that("ANY dependencies match each requested pair without adding other pairs", {
  deps <- data.table::data.table(
    variable = c("common", "cattle", "adult_female", "pig_juvenile", "unrequested"),
    species_short = c("ANY", "CTL", "ANY", "PGS", "CTL"),
    cohort_short = c("ANY", "ANY", "FA", "MJ", "MJ"),
    input_table = "herd_level_data", requirement = "R", has_herd_structure = "ANY",
    run_weights = "X", run_gleam = "X", evidence_function = "example"
  )
  requested <- data.table::data.table(
    species_short = c("CTL", "PGS"), cohort_short = c("FA", "MJ")
  )
  before <- data.table::copy(deps)
  for (module in c("weights", "run_gleam")) {
    rules <- get_required_parameter_rules(requested, module, dependencies = deps)
    expect_setequal(rules[species_short == "CTL", variable], c("common", "cattle", "adult_female"))
    expect_setequal(rules[species_short == "PGS", variable], c("common", "pig_juvenile"))
    expect_equal(nrow(rules), 5L)
    expect_true(all(rules[species_short == "CTL", cohort_short] == "FA"))
    expect_true(all(rules[species_short == "PGS", cohort_short] == "MJ"))
  }
  for (coverage in c(FALSE, TRUE)) {
    expect_setequal(get_required_function_parameters(
      "FA", "example", "CTL", dependencies = deps, check_coverage = coverage
    ), c("common", "cattle", "adult_female"))
    expect_setequal(get_required_function_parameters(
      "MJ", "example", "PGS", dependencies = deps, check_coverage = coverage
    ), c("common", "pig_juvenile"))
  }
  expect_error(get_required_function_parameters(
    "FA", "example", dependencies = deps
  ), "differ by species")
  expect_equal(deps, before)
})

test_that("ANY coverage preserves optional rules and detects missing cohort scopes", {
  deps <- data.table::data.table(
    variable = "optional", species_short = "ANY", cohort_short = "FA",
    input_table = "herd_level_data", requirement = "O", has_herd_structure = "ANY",
    run_weights = "X", evidence_function = "example"
  )
  requested <- data.table::data.table(species_short = "CTL", cohort_short = "FA")
  expect_equal(unique(get_required_parameter_rules(requested, "weights", dependencies = deps)$variable), character())
  expect_equal(get_required_function_parameters("FA", "example", dependencies = deps), character())
  requested[, cohort_short := "MJ"]
  expect_error(unique(get_required_parameter_rules(requested, "weights", dependencies = deps)$variable), "CTL/MJ")
  expect_error(get_required_function_parameters("MJ", "example", "CTL", dependencies = deps), "CTL/MJ")
  deps[, cohort_short := "ANY"]
  expect_equal(get_required_function_parameters(function_filter = "example", dependencies = deps), character())
})

test_that("common source dependencies are stored once using ANY", {
  mitigation <- parameter_rules[variable == "ch4_mitigation_factor"]
  expect_equal(nrow(mitigation), 1L)
  expect_equal(mitigation$species_short, "ANY")
  expect_equal(mitigation$cohort_short, "ANY")
  expect_equal(mitigation$requirement, "O")
  expect_equal(mitigation$lower_bound, 0)
  expect_equal(mitigation$upper_bound, 1)
  expect_equal(mitigation$range_species_short, "ANY")
  expect_equal(mitigation$range_cohort_short, "ANY")
  expect_false("rule_type" %in% names(parameter_rules))
  female_weight <- parameter_rules[
    variable == "live_weight_female_adult" & run_weights == "X"
  ]
  expect_equal(nrow(female_weight), 3L)
  expect_true(all(female_weight$species_short == "ANY"))
  expect_setequal(female_weight$cohort_short, c("FA", "FS", "FJ"))
})
