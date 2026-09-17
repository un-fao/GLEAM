test_that("conditional positivity checks each row only when its reference is positive", {
  rule <- data.table::data.table(
    variable = "value", species_short = "ANY", cohort_short = "ANY",
    comparison_operator = "positive_if_positive", comparison_variable = "trigger",
    validation_function = "example"
  )
  expect_no_error(validate_parameter_relations(
    list(value = c(0, 0.01, 0), trigger = c(0, 1, NA_real_)),
    "example", parameter_rules_data = rule
  ))
  expect_error(validate_parameter_relations(
    list(herd_id = c("valid", "invalid"), value = c(0, 0), trigger = c(0, 0.01)),
    "example", parameter_rules_data = rule
  ), "(?s)value.*greater than 0.*trigger.*herd invalid", perl = TRUE)
})

milk_rule_scalar_inputs <- list(
  species_short = "CTL", cohort_short = "FA", milk_yield_day = 10,
  simulation_duration = 365, cohort_stock_size = 100, lactating_females_fraction = 0.5,
  milk_protein_fraction = 0.033, milk_fat_fraction = 0.04, milk_lactose_fraction = 0.048,
  milk_protein_fraction_standard = 0.033, milk_fat_fraction_standard = 0.04,
  milk_lactose_fraction_standard = 0.048
)

test_that("milk calculations enforce positive yield and composition for milk-producing FA", {
  for (species in gleam_species_milk_producers) {
    args <- milk_rule_scalar_inputs
    args$species_short <- species
    expect_no_error(do.call(calc_milk_production, args))
    for (variable in c("milk_yield_day", "milk_fat_fraction", "milk_protein_fraction")) {
      invalid <- args
      invalid[[variable]] <- 0
      expect_error(do.call(calc_milk_production, invalid), paste0(variable, ".*greater than 0"))
    }
    args$lactating_females_fraction <- 0
    args$milk_yield_day <- 0
    args$milk_fat_fraction <- 0
    args$milk_protein_fraction <- 0
    expect_equal(unname(unlist(do.call(calc_milk_production, args))), rep(0, 3))
    # Positive yield still requires positive composition even if lactating fraction is zero.
    args$milk_yield_day <- 1
    expect_error(do.call(calc_milk_production, args), "milk_fat_fraction.*greater than 0")
  }
  for (cohort in setdiff(gleam_cohorts, "FA")) {
    args <- milk_rule_scalar_inputs
    args$cohort_short <- cohort
    args$milk_yield_day <- 0
    expect_equal(unname(unlist(do.call(calc_milk_production, args))), rep(0, 3))
  }
  args <- milk_rule_scalar_inputs
  args$species_short <- "PGS"
  args$milk_yield_day <- 0
  expect_equal(unname(unlist(do.call(calc_milk_production, args))), rep(0, 3))
})

test_that("the shared rules also apply to standalone lactation and nitrogen calculations", {
  args <- list(
    species_short = "CTL", cohort_short = "FA", lactating_females_fraction = 0.5,
    milk_yield_day = 10, milk_fat_fraction = 0.04,
    parturition_rate = 1, live_weight_at_birth = 35, live_weight_at_weaning = 90
  )
  expect_no_error(do.call(calc_metabolic_energy_req_lactation, args))
  invalid <- args
  invalid$milk_yield_day <- 0
  expect_error(do.call(calc_metabolic_energy_req_lactation, invalid), "milk_yield_day.*greater than 0")
  invalid <- args
  invalid$milk_fat_fraction <- 0
  expect_error(do.call(calc_metabolic_energy_req_lactation, invalid), "milk_fat_fraction.*greater than 0")
  expect_error(calc_nitrogen_retention(
    "CTL", "FA", milk_yield_day = 10, milk_protein_fraction = 0, daily_weight_gain = 0
  ), "milk_protein_fraction.*greater than 0")
  expect_equal(calc_nitrogen_retention(
    "CTL", "FA", milk_yield_day = 0, milk_protein_fraction = 0, daily_weight_gain = 0
  ), 0)
})

test_that("module input checks report the herd with inconsistent milk inputs", {
  path <- system.file("extdata/run_modules_examples", package = "gleam")
  cases <- list(
    production = c("milk_yield_day", "milk_fat_fraction", "milk_protein_fraction"),
    metabolic_energy_req = c("milk_yield_day", "milk_fat_fraction"),
    nitrogen_balance = "milk_protein_fraction"
  )
  for (module in names(cases)) {
    cohorts <- data.table::fread(file.path(path, paste0(module, "_input_chrt_data.csv")))[herd_id == 1]
    herd <- data.table::fread(file.path(path, paste0(module, "_input_hrd_data.csv")))[herd_id == 1]
    validate <- get(paste0("validate_run_", module, "_module_inputs"))
    for (variable in cases[[module]]) {
      invalid <- data.table::copy(herd)
      data.table::set(invalid, j = variable, value = 0)
      expect_error(validate(cohorts, invalid), paste0("(?s)", variable, ".*greater than 0.*herd 1"), perl = TRUE)
    }
  }
})

test_that("changing the central conditional rule changes milk validation", {
  args <- milk_rule_scalar_inputs
  args$milk_fat_fraction <- 0
  expect_error(do.call(calc_milk_production, args), "milk_fat_fraction.*greater than 0")
  rules <- data.table::copy(parameter_rules)
  rules[variable == "milk_fat_fraction", comparison_operator := ""]
  testthat::local_mocked_bindings(parameter_rules = rules, .package = "gleam")
  expect_no_error(do.call(calc_milk_production, args))
})
