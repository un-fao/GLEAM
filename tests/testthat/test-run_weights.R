weights_test_inputs <- function(cohort, species = "CTL") {
  herd <- data.table::data.table(
    herd_id = "h1", live_weight_female_adult = 500,
    live_weight_male_adult = 600, live_weight_at_birth = 35,
    live_weight_at_weaning = 90, live_weight_female_at_slaughter = 480,
    live_weight_male_at_slaughter = 550
  )
  required <- switch(cohort,
    FJ = c("live_weight_female_adult", "live_weight_at_birth", "live_weight_at_weaning"),
    FS = c("live_weight_female_adult", "live_weight_at_weaning", "live_weight_female_at_slaughter"),
    FA = "live_weight_female_adult",
    MJ = c("live_weight_male_adult", "live_weight_at_birth", "live_weight_at_weaning"),
    MS = c("live_weight_male_adult", "live_weight_at_weaning", "live_weight_male_at_slaughter"),
    MA = "live_weight_male_adult"
  )
  list(
    cohort = data.table::data.table(
      herd_id = "h1", species_short = species, cohort_short = cohort,
      cohort_duration_days = 100, offtake_rate = 0.2
    ),
    herd = herd[, c("herd_id", required), with = FALSE],
    full_herd = herd
  )
}

test_that("each supported species/cohort runs with only its required weights", {
  expected <- list(
    FJ = c(500, 35, 90, 90, 62.5, 90, 0.55),
    FS = c(500, 90, 500, 480, 293, 496, 4.1),
    FA = c(500, 500, 500, 500, 500, 500, 0),
    MJ = c(600, 35, 90, 90, 62.5, 90, 0.55),
    MS = c(600, 90, 600, 550, 340, 590, 5.1),
    MA = c(600, 600, 600, 600, 600, 600, 0)
  )
  for (species in gleam_species) {
    for (cohort in gleam_cohorts) {
      d <- weights_test_inputs(cohort, species)
      original_cohort <- data.table::copy(d$cohort)
      original_herd <- data.table::copy(d$herd)
      result <- run_weights_module(d$cohort, d$herd, show_indicator = FALSE)
      values <- result$cohort_level_results[, setdiff(names(result$cohort_level_results), names(d$cohort)), with = FALSE]
      expect_equal(unname(unlist(values)), expected[[cohort]], info = paste(species, cohort))
      expect_equal(result$herd_level_results, original_herd)
      expect_equal(d$cohort, original_cohort)
      expect_equal(d$herd, original_herd)
    }
  }
})

test_that("required weight columns and values cannot be missing", {
  for (cohort in gleam_cohorts) {
    d <- weights_test_inputs(cohort)
    for (variable in setdiff(names(d$herd), "herd_id")) {
      absent <- data.table::copy(d$herd)
      absent[, (variable) := NULL]
      expect_error(run_weights_module(d$cohort, absent, FALSE), "Missing required columns")
      missing <- data.table::copy(d$herd)
      data.table::set(missing, j = variable, value = NA_real_)
      expect_error(run_weights_module(d$cohort, missing, FALSE), "Missing required weight inputs")
    }
  }
})

test_that("weight and cohort input ranges are enforced", {
  d <- weights_test_inputs("FA")
  d$herd[, live_weight_female_adult := -1]
  expect_error(run_weights_module(d$cohort, d$herd, FALSE), "out of range")
  d <- weights_test_inputs("FA")
  d$cohort[, offtake_rate := 1]
  expect_error(run_weights_module(d$cohort, d$herd, FALSE), "out of range")
  d$cohort[, offtake_rate := 0.2]
  d$cohort[, cohort_duration_days := 0]
  expect_error(run_weights_module(d$cohort, d$herd, FALSE), "out of range")
})

test_that("unused weights may be NA in a mixed-species partial-cohort run", {
  female <- weights_test_inputs("FA", "CTL")
  male <- weights_test_inputs("MA", "PGS")
  male$cohort[, herd_id := "h2"]
  male$herd[, herd_id := "h2"]
  cohorts <- data.table::rbindlist(list(female$cohort, male$cohort))
  herds <- data.table::rbindlist(list(male$herd, female$herd), fill = TRUE)
  result <- run_weights_module(cohorts, herds, FALSE)
  expect_equal(result$cohort_level_results$live_weight_cohort_average, c(500, 600))
  herds[herd_id == "h2", live_weight_male_adult := NA_real_]
  expect_error(run_weights_module(cohorts, herds, FALSE), "Missing required weight inputs")
})

test_that("subadult equality is accepted and reversed weights are rejected at both levels", {
  for (cohort in c("FS", "MS")) {
    d <- weights_test_inputs(cohort)
    variable <- if (cohort == "FS") "live_weight_female_at_slaughter" else "live_weight_male_at_slaughter"
    data.table::set(d$herd, j = variable, value = 90)
    expect_true(validate_run_weights_module_inputs(d$cohort, d$herd))
    expect_no_error(run_weights_module(d$cohort, d$herd, FALSE))
    data.table::set(d$herd, j = variable, value = 89)
    expect_error(validate_run_weights_module_inputs(d$cohort, d$herd), "less than or equal")
    args <- c(list(cohort_short = cohort), as.list(d$herd[, -"herd_id"]))
    expect_error(do.call(calc_cohort_weights, args), "less than or equal")
  }
  d <- weights_test_inputs("FJ")
  d$herd[, live_weight_at_weaning := live_weight_at_birth]
  expect_error(run_weights_module(d$cohort, d$herd, FALSE), "must be less than")
})

test_that("species and cohort identities agree with herd-level joins", {
  d <- weights_test_inputs("FA")
  expect_error(run_weights_module(data.table::rbindlist(list(d$cohort, d$cohort)), d$herd, FALSE), "must be unique")
  mixed <- data.table::copy(d$cohort)
  mixed[, `:=`(species_short = "PGS", cohort_short = "MA")]
  expect_error(run_weights_module(data.table::rbindlist(list(d$cohort, mixed)), d$full_herd, FALSE), "single species_short")
  d$herd[, species_short := "PGS"]
  expect_error(run_weights_module(d$cohort, d$herd, FALSE), "species_short must agree")
  d$herd[, species_short := "CTL"]
  expect_no_error(run_weights_module(d$cohort, d$herd, FALSE))
  d$cohort[, species_short := "UNKNOWN"]
  expect_error(run_weights_module(d$cohort, d$herd, FALSE), "Invalid.*species_short")
})

test_that("the complete bundled weights example runs", {
  path <- system.file("extdata/run_modules_examples", package = "gleam")
  cohorts <- data.table::fread(file.path(path, "weights_input_chrt_data.csv"))
  herds <- data.table::fread(file.path(path, "weights_input_hrd_data.csv"))
  cohorts[, species_short := "CTL"]
  result <- run_weights_module(cohorts, herds, FALSE)
  expect_equal(nrow(result$cohort_level_results), nrow(cohorts))
  expect_false(anyNA(result$cohort_level_results))
})


test_that("optional validation skips scoped limits and comparisons for separate cohorts", {
  d <- weights_test_inputs("FA", "CTL")
  specific <- data.table::copy(parameter_rules[variable == "live_weight_female_adult"][1L])
  specific[, `:=`(range_species_short = "CTL", range_cohort_short = "FA", upper_bound = 400)]
  testthat::local_mocked_bindings(
    parameter_rules = data.table::rbindlist(list(parameter_rules, specific)), .package = "gleam"
  )
  expect_error(run_weights_module(d$cohort, d$herd, FALSE), "out of range.*CTL/FA")
  expect_warning(
    result <- run_weights_module(d$cohort, d$herd, FALSE, validate_inputs = FALSE),
    "Input validation has been turned off"
  )
  expect_equal(result$cohort_level_results$live_weight_cohort_average, 500)
  d <- weights_test_inputs("FJ", "CTL")
  d$herd[, live_weight_at_weaning := live_weight_at_birth]
  expect_error(run_weights_module(d$cohort, d$herd, FALSE), "must be less than")
  expect_warning(
    result <- run_weights_module(d$cohort, d$herd, FALSE, validate_inputs = FALSE),
    "Input validation has been turned off"
  )
  expect_equal(result$cohort_level_results$daily_weight_gain, 0)
  expect_error(run_weights_module(d$cohort, d$herd, FALSE), "must be less than")
})


test_that("prepared inputs preserve cohort order across repeated and shuffled herds", {
  cohorts <- data.table::data.table(
    herd_id = c("h2", "h1", "h2", "h1"),
    species_short = "CTL", cohort_short = c("FJ", "MA", "FA", "FA"),
    cohort_duration_days = 100, offtake_rate = 0.2
  )
  herds <- data.table::data.table(
    herd_id = c("h1", "h2"), live_weight_female_adult = c(500, 700),
    live_weight_male_adult = c(600, NA_real_), live_weight_at_birth = c(NA_real_, 45),
    live_weight_at_weaning = c(NA_real_, 95)
  )
  original_cohorts <- data.table::copy(cohorts)
  original_herds <- data.table::copy(herds)
  for (flag in c(TRUE, FALSE)) {
    if (flag) {
      result <- run_weights_module(cohorts, herds, FALSE)
    } else {
      expect_warning(
        result <- run_weights_module(cohorts, herds, FALSE, validate_inputs = FALSE),
        "Input validation has been turned off"
      )
    }
    expect_equal(result$cohort_level_results$herd_id, cohorts$herd_id)
    expect_equal(result$cohort_level_results$cohort_short, cohorts$cohort_short)
    expect_equal(result$cohort_level_results$live_weight_cohort_average, c(70, 600, 700, 500))
    expect_equal(result$herd_level_results, original_herds)
    expect_equal(cohorts, original_cohorts)
    expect_equal(herds, original_herds)
  }
})
