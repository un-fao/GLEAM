# Independent fixtures for the direct emissions entry point.
d_direct <- local({
  path <- system.file("extdata/run_gleam_examples", package = "gleam")
  read_input <- function(name) data.table::fread(file.path(path, name))
  list(
    cohort_no_structure = read_input("master_chrt_lvl_no_structure_data.csv"),
    cohort_structure = read_input("master_chrt_lvl_structure_data.csv"),
    herd = read_input("master_hrd_lvl_data.csv"),
    feed_rations = read_input("feed_rations_share_chrt.csv"),
    feed_params = read_input("feed_quality.csv"),
    feed_emissions = read_input("feed_emission_factors.csv"),
    mms_fraction = read_input("manure_management_system_fraction.csv"),
    mms_factors = read_input("manure_management_system_factors.csv")
  )
})

direct_quality <- run_ration_quality_module(
  d_direct$feed_rations, d_direct$feed_params, show_indicator = FALSE
)
data.table::setkeyv(direct_quality, c("herd_id", "species_short", "cohort_short"))
direct_quality_cols <- setdiff(
  names(direct_quality), c("herd_id", "species_short", "cohort_short")
)

direct_inputs <- function(has_herd_structure = TRUE, primary = FALSE) {
  cohort <- if (has_herd_structure) {
    d_direct$cohort_structure
  } else {
    d_direct$cohort_no_structure
  }
  if (primary) {
    cohort <- merge(
      cohort, direct_quality, by = c("herd_id", "species_short", "cohort_short")
    )
  }
  args <- list(
    has_herd_structure = has_herd_structure,
    cohort_level_data = cohort,
    herd_level_data = d_direct$herd,
    manure_management_system_fraction = d_direct$mms_fraction,
    manure_management_system_factors = d_direct$mms_factors,
    show_indicator = FALSE
  )
  if (!primary) {
    args$feed_rations <- d_direct$feed_rations
    args$feed_params <- d_direct$feed_params
  }
  data.table::copy(args)
}

test_that("the direct input validator accepts both nutritional input modes", {
  for (has_structure in c(TRUE, FALSE)) {
    for (primary in c(TRUE, FALSE)) {
      for (factors_only in c(TRUE, FALSE)) {
        args <- direct_inputs(has_structure, primary = primary)
        args$show_indicator <- NULL
        args$emission_factors_only <- factors_only
        expect_invisible(do.call(validate_run_emissions_direct_inputs, args))
      }
    }
  }
})

test_that("the direct input validator checks pipeline inputs in both nutritional modes", {
  invalid_inputs <- list(
    has_herd_structure = NA,
    simulation_duration = 0,
    global_warming_potential_set = "unknown",
    cohort_level_data = NULL,
    herd_level_data = NULL,
    manure_management_system_fraction = NULL,
    manure_management_system_factors = NULL
  )
  for (primary in c(TRUE, FALSE)) {
    for (field in names(invalid_inputs)) {
      args <- direct_inputs(primary = primary)
      args$show_indicator <- NULL
      args[field] <- invalid_inputs[field]
      expect_error(do.call(validate_run_emissions_direct_inputs, args), field)
    }
  }
})

test_that("primary nutrition matches feed-derived results with either herd path", {
  for (has_structure in c(TRUE, FALSE)) {
    feed_result <- do.call(run_emissions_direct, direct_inputs(has_structure))
    primary_result <- do.call(
      run_emissions_direct, direct_inputs(has_structure, primary = TRUE)
    )

    # Normalize keys and column order because the primary values enter earlier.
    data.table::setkeyv(
      primary_result$cohort_level_results, c("herd_id", "species_short", "cohort_short")
    )
    data.table::setkeyv(
      feed_result$cohort_level_results, c("herd_id", "species_short", "cohort_short")
    )
    data.table::setcolorder(
      primary_result$cohort_level_results, names(feed_result$cohort_level_results)
    )
    expect_equal(primary_result, feed_result)
    expect_equal(
      primary_result$cohort_level_results[, ..direct_quality_cols],
      direct_quality[, ..direct_quality_cols]
    )
    expect_false(any(grepl("_ration_", names(feed_result$cohort_level_results))))
    emissions <- feed_result$aggregation_results$results_emissions
    expect_gt(nrow(emissions), 0)
    expect_true(all(grepl("^(ch4|n2o)_(enteric|manure)", emissions$variable_name)))
    expect_true(all(is.finite(emissions$value_total_allocated_co2eq)))

    for (primary in c(FALSE, TRUE)) {
      factors <- local({
        # Fail if any skipped module is invoked, even if its output is discarded.
        testthat::local_mocked_bindings(
          run_production_module = function(...) stop("Production must be skipped"),
          run_allocation_module = function(...) stop("Allocation must be skipped"),
          run_aggregation_module = function(...) stop("Aggregation must be skipped"),
          .package = "gleam"
        )
        args <- direct_inputs(has_structure, primary = primary)
        args$emission_factors_only <- TRUE
        production_only_cols <- c(
          "milk_protein_fraction_standard", "milk_fat_fraction_standard",
          "milk_lactose_fraction_standard", "carcass_dressing_fraction",
          "bone_free_meat_fraction", "meat_protein_fraction"
        )
        args$herd_level_data[, (production_only_cols) := NULL]
        do.call(run_emissions_direct, args)
      })
      expect_named(factors, names(feed_result))
      expect_null(factors$allocation_long)
      expect_null(factors$aggregation_results)
      factor_cols <- names(factors$cohort_level_results)
      expect_false(any(grepl("_production_|_allocation_", factor_cols)))
      data.table::setkeyv(
        factors$cohort_level_results, c("herd_id", "species_short", "cohort_short")
      )
      expect_equal(
        factors$cohort_level_results,
        feed_result$cohort_level_results[, factor_cols, with = FALSE]
      )
    }
  }
})

test_that("emission_factors_only requires a single non-missing logical value", {
  for (bad_value in list(NULL, NA, 1, "TRUE", logical(), c(TRUE, FALSE))) {
    args <- direct_inputs()
    args["emission_factors_only"] <- list(bad_value)
    expect_error(
      do.call(run_emissions_direct, args),
      "emission_factors_only.*single logical value"
    )
    args$show_indicator <- NULL
    expect_error(
      do.call(validate_run_emissions_direct_inputs, args),
      "emission_factors_only.*single logical value"
    )
  }
})

test_that("direct emissions match the same sources in the full pipeline", {
  args <- direct_inputs()
  direct <- do.call(run_emissions_direct, args)
  args$feed_emissions <- d_direct$feed_emissions
  full <- do.call(run_gleam, args)

  full_emissions <- full$aggregation_results$results_emissions
  expect_equal(
    direct$aggregation_results$results_emissions,
    full_emissions[grepl("^(ch4|n2o)_(enteric|manure)", variable_name)]
  )
})

test_that("user-supplied nitrogen changes nitrogen intake and manure emissions", {
  args <- direct_inputs(primary = TRUE)
  baseline <- do.call(run_emissions_direct, args)
  args$cohort_level_data[, ration_nitrogen := ration_nitrogen * 1.1]
  changed <- do.call(run_emissions_direct, args)
  before <- baseline$cohort_level_results
  after <- changed$cohort_level_results

  expect_equal(after$ration_nitrogen, before$ration_nitrogen * 1.1)
  expect_equal(after$nitrogen_intake, before$nitrogen_intake * 1.1)
  expect_equal(after$ch4_enteric, before$ch4_enteric)
  expect_true(any(after$n2o_manure_other_direct > before$n2o_manure_other_direct))
})

test_that("omitted feed tables require every primary nutritional quality column", {
  args <- direct_inputs()
  args$feed_rations <- NULL
  args$feed_params <- NULL
  expect_error(do.call(run_emissions_direct, args), "primary nutritional quality")

  for (col in direct_quality_cols) {
    args <- direct_inputs(primary = TRUE)
    args$cohort_level_data[, (col) := NULL]
    expect_error(do.call(run_emissions_direct, args), col)
  }
})

test_that("feed tables must be supplied together, including with primary quality", {
  for (primary in c(TRUE, FALSE)) {
    for (field in c("feed_rations", "feed_params")) {
      args <- direct_inputs(primary = primary)
      args$feed_rations <- d_direct$feed_rations
      args$feed_params <- d_direct$feed_params
      args[[field]] <- NULL
      expect_error(do.call(run_emissions_direct, args), "together, or omit both")
    }
  }
})

test_that("primary quality cannot be combined with feed-derived quality", {
  args <- direct_inputs(primary = TRUE)
  args$feed_rations <- d_direct$feed_rations
  args$feed_params <- d_direct$feed_params
  expect_error(do.call(run_emissions_direct, args), "Do not provide.*ration_gross_energy")
})

test_that("primary quality uses the model's numeric and range validation", {
  for (col in direct_quality_cols) {
    for (bad_value in list(NA_real_, "unknown", -1, Inf)) {
      args <- direct_inputs(primary = TRUE)
      args$cohort_level_data[[col]] <- rep(bad_value, nrow(args$cohort_level_data))
      expect_error(do.call(run_emissions_direct, args), col)
    }
  }
})

test_that("primary mode retains other pipeline input checks", {
  args <- direct_inputs(primary = TRUE)
  args$cohort_level_data[, daily_weight_gain := 0.5]
  expect_error(do.call(run_emissions_direct, args), "Do not provide.*daily_weight_gain")

  args <- direct_inputs(primary = TRUE)
  args$herd_level_data[, herd_id := paste0(herd_id, "_bad")]
  expect_error(do.call(run_emissions_direct, args), "same.*herd_id")

  args <- direct_inputs(primary = TRUE)
  args$manure_management_system_factors <- NULL
  expect_error(do.call(run_emissions_direct, args), "manure_management_system_factors")
})

test_that("direct emissions require all six cohorts in every input and output mode", {
  for (has_structure in c(FALSE, TRUE)) {
    for (primary in c(FALSE, TRUE)) {
      for (factors_only in c(FALSE, TRUE)) {
        args <- direct_inputs(has_herd_structure = has_structure, primary = primary)
        args$cohort_level_data <- args$cohort_level_data[cohort_short == "FA"]
        args$emission_factors_only <- factors_only
        expect_error(do.call(run_emissions_direct, args), "exactly 6 rows")
      }
    }
  }
})
