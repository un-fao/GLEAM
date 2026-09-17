test_that("comparison operators check complete numeric pairs", {
  rule <- data.table::data.table(
    variable = "left", species_short = "ANY", cohort_short = "ANY",
    comparison_operator = "<", comparison_variable = "right", validation_function = "example"
  )
  cases <- list("<" = c(1, 2, 2), "<=" = c(2, 2, 3), ">" = c(3, 2, 2),
                ">=" = c(2, 2, 1), "==" = c(2, 2, 1), "!=" = c(1, 2, 2))
  for (operator in names(cases)) {
    rule[, comparison_operator := operator]
    values <- cases[[operator]]
    expect_no_error(validate_parameter_relations(
      list(left = values[1], right = values[2]), "example", parameter_rules_data = rule
    ))
    expect_error(validate_parameter_relations(
      list(left = values[3], right = values[2]), "example", parameter_rules_data = rule
    ), "left.*must be.*right")
  }
  rule[, comparison_operator := "<"]
  expect_no_error(validate_parameter_relations(
    list(left = c(NA_real_, 1), right = c(0, 2)), "example", parameter_rules_data = rule
  ))
  expect_no_error(validate_parameter_relations(list(left = 1), "example", parameter_rules_data = rule))
  expect_error(validate_parameter_relations(
    list(left = c(1, 3), right = c(2, 2)), "example", parameter_rules_data = rule
  ), "position 2")
  expect_error(validate_parameter_relations(
    list(left = 1, right = c(2, 3)), "example", parameter_rules_data = rule
  ), "same length")
  expect_error(validate_parameter_relations(
    list(left = "1", right = 2), "example", parameter_rules_data = rule
  ), "numeric")
  rule[, comparison_operator := "=>"]
  expect_error(validate_parameter_relations(
    list(left = 1, right = 2), "example", parameter_rules_data = rule
  ), "Invalid parameter comparison rule")
})

test_that("comparisons retain species, cohort and exact function scope", {
  rule <- data.table::data.table(
    variable = "left", species_short = "CTL", cohort_short = "FJ",
    comparison_operator = "<", comparison_variable = "right", validation_function = "example;another_example"
  )
  inputs <- list(left = 2, right = 1)
  for (fn in c("example", "another_example")) {
    expect_error(validate_parameter_relations(inputs, fn, "CTL", "FJ", rule), "must be less than")
  }
  expect_no_error(validate_parameter_relations(inputs, "exam", "CTL", "FJ", rule))
  expect_no_error(validate_parameter_relations(inputs, "example", "PGS", "FJ", rule))
  expect_no_error(validate_parameter_relations(inputs, "example", "CTL", "FA", rule))
  expect_no_error(validate_parameter_relations(inputs, "example", parameter_rules_data = rule))
})

test_that("changing a matrix operator affects scalar and module weight validation", {
  cohorts <- data.table::data.table(
    herd_id = "h1", species_short = "CTL", cohort_short = "FJ", offtake_rate = 0, cohort_duration_days = 100
  )
  herd <- data.table::data.table(
    herd_id = "h1", live_weight_female_adult = 500, live_weight_at_birth = 40, live_weight_at_weaning = 40
  )
  args <- c(list(cohort_short = "FJ", species_short = "CTL"), as.list(herd[, !"herd_id"]))
  expect_error(do.call(calc_cohort_weights, args), "must be less than")
  expect_error(run_weights_module(cohorts, herd, FALSE), "must be less than")
  ranges <- data.table::copy(parameter_rules)
  ranges[nzchar(comparison_operator) & cohort_short == "FJ" &
           validation_function == "calc_cohort_weights;run_weights_module", comparison_operator := "<="]
  testthat::local_mocked_bindings(parameter_rules = ranges, .package = "gleam")
  expect_no_error(do.call(calc_cohort_weights, args))
  expect_no_error(run_weights_module(cohorts, herd, FALSE))
})

test_that("growth comparisons apply only to the branches that use weights", {
  args <- list(
    species_short = "CTL", cohort_short = "FJ", live_weight_cohort_initial = 100,
    live_weight_cohort_average = 100, live_weight_cohort_final = 150,
    live_weight_mature_stage = 500, daily_weight_gain = 0.5, offtake_rate = 0.1, cohort_duration_days = 100
  )
  expect_no_error(do.call(calc_metabolic_energy_req_growth, args))
  ranges <- data.table::copy(parameter_rules)
  ranges[nzchar(comparison_operator) & species_short == "CTL" & cohort_short == "FJ" &
           variable == "live_weight_cohort_initial" & validation_function == "calc_metabolic_energy_req_growth",
         comparison_operator := "<"]
  testthat::local_mocked_bindings(parameter_rules = ranges, .package = "gleam")
  expect_error(do.call(calc_metabolic_energy_req_growth, args), "live_weight_cohort_initial.*must be less than")
  args$species_short <- "CML"
  expect_no_error(do.call(calc_metabolic_energy_req_growth, args))
  args$species_short <- "CTL"
  args$cohort_short <- "FA"
  expect_no_error(do.call(calc_metabolic_energy_req_growth, args))
})

test_that("adult weight calculations do not inherit lactation comparisons", {
  expect_no_error(calc_cohort_weights(
    "FA", species_short = "CTL", live_weight_female_adult = 500,
    live_weight_at_birth = 100, live_weight_at_weaning = 50
  ))
  expect_equal(calc_metabolic_energy_req_lactation(
    "CTL", "FJ", live_weight_at_birth = 100, live_weight_at_weaning = 50
  ), 0)
  expect_error(calc_nitrogen_retention(
    "PGS", "FA", litter_size = 10, parturition_rate = 2,
    live_weight_at_birth = 30, live_weight_at_weaning = 30
  ), "must be less than")
})
