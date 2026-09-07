#' Validate inputs for calc_nondemo_cycle_geometry
#'
#' @noRd
validate_nondemo_cycle_geometry_inputs <- function(
    phase1_nondemo_duration,
    phase2_nondemo_duration,
    rest_between_nondemo_cycles_duration
) {
  validate_scalar_numeric(phase1_nondemo_duration)
  validate_scalar_numeric(phase2_nondemo_duration)
  validate_scalar_numeric(rest_between_nondemo_cycles_duration)

  if (phase1_nondemo_duration < 0) {
    cli::cli_abort(
      "{.arg phase1_nondemo_duration} must be greater than or equal to 0."
    )
  }
  if (phase2_nondemo_duration < 0) {
    cli::cli_abort(
      "{.arg phase2_nondemo_duration} must be greater than or equal to 0."
    )
  }
  if (phase1_nondemo_duration > 0) {
    validate_param_range(phase1_nondemo_duration, "cohort_duration_days")
  }
  if (phase2_nondemo_duration > 0) {
    validate_param_range(phase2_nondemo_duration, "cohort_duration_days")
  }
  validate_param_range(rest_between_nondemo_cycles_duration, "duration")
}

#' Validate inputs for calc_nondemo_start_sizes
#'
#' @noRd
validate_nondemo_start_size_inputs <- function(
    cohort_stock_nondemo_annual_entrants,
    total_nondemo_cycle_starts_to_distribute
) {
  validate_scalar_numeric(cohort_stock_nondemo_annual_entrants)
  validate_scalar_numeric(total_nondemo_cycle_starts_to_distribute)

  if (cohort_stock_nondemo_annual_entrants < 0) {
    cli::cli_abort(
      "{.arg cohort_stock_nondemo_annual_entrants} must be greater than or equal to 0."
    )
  }
  if (total_nondemo_cycle_starts_to_distribute < 0) {
    cli::cli_abort(
      "{.arg total_nondemo_cycle_starts_to_distribute} must be greater than or equal to 0."
    )
  }
}

#' Validate inputs for calc_nondemo_phase
#'
#' @noRd
validate_nondemo_phase_inputs <- function(
    cohort_stock_nondemo_start_by_phase,
    productive_phase_nondemo_duration,
    death_rate_nondemo_phase,
    max_simulation_days_nondemo_phase
) {
  validate_scalar_numeric(cohort_stock_nondemo_start_by_phase)
  validate_scalar_numeric(productive_phase_nondemo_duration)
  validate_scalar_numeric(death_rate_nondemo_phase)
  validate_scalar_numeric(max_simulation_days_nondemo_phase)

  if (cohort_stock_nondemo_start_by_phase < 0) {
    cli::cli_abort("{.arg cohort_stock_nondemo_start_by_phase} must be greater than or equal to 0.")
  }
  if (productive_phase_nondemo_duration < 0) {
    cli::cli_abort(
      "{.arg productive_phase_nondemo_duration} must be greater than or equal to 0."
    )
  }
  if (max_simulation_days_nondemo_phase < 0) {
    cli::cli_abort(
      "{.arg max_simulation_days_nondemo_phase} must be greater than or equal to 0."
    )
  }

  if (productive_phase_nondemo_duration > 0) {
    validate_param_range(productive_phase_nondemo_duration, "cohort_duration_days")
  }
  validate_param_range(death_rate_nondemo_phase, "death_rate")
  if (max_simulation_days_nondemo_phase > 0) {
    validate_param_range(max_simulation_days_nondemo_phase, "simulation_duration")
  }
}

#' Validate inputs for calc_nondemo_avg_stock_phase_horizon
#'
#' @noRd
validate_nondemo_avg_stock_inputs <- function(
    full_nondemo_phase_duration,
    partial_nondemo_phase,
    number_full_nondemo_cycles
) {
  for (arg_name in c("full_nondemo_phase_duration", "partial_nondemo_phase")) {
    phase <- get(arg_name)
    if (!is.list(phase) ||
        is.null(phase$time_simulated_nondemographic) ||
        is.null(phase$cohort_stock_nondemo) ||
        is.null(phase$cohort_stock_nondemo$start) ||
        is.null(phase$cohort_stock_nondemo$end)) {
      cli::cli_abort(
        "{.arg {arg_name}} must be a list produced by {.fn calc_nondemo_phase}."
      )
    }
  }

  validate_scalar_numeric(number_full_nondemo_cycles)

  if (number_full_nondemo_cycles < 0) {
    cli::cli_abort(
      "{.arg number_full_nondemo_cycles} must be greater than or equal to 0."
    )
  }
}

#' Validate inputs for calc_nondemo_offtake_total_horizon
#'
#' @noRd
validate_nondemo_offtake_inputs <- function(
    cohort_stock_nondemo_end_phase1,
    cohort_stock_nondemo_end_phase2,
    number_full_nondemo_cycles,
    partial_phase1_nondemo_duration,
    partial_phase2_nondemo_duration,
    phase1_nondemo_duration,
    phase2_nondemo_duration,
    simulation_duration
) {
  numeric_args <- list(
    cohort_stock_nondemo_end_phase1 = cohort_stock_nondemo_end_phase1,
    cohort_stock_nondemo_end_phase2 = cohort_stock_nondemo_end_phase2,
    number_full_nondemo_cycles = number_full_nondemo_cycles,
    partial_phase1_nondemo_duration = partial_phase1_nondemo_duration,
    partial_phase2_nondemo_duration = partial_phase2_nondemo_duration,
    phase1_nondemo_duration = phase1_nondemo_duration,
    phase2_nondemo_duration = phase2_nondemo_duration,
    simulation_duration = simulation_duration
  )

  for (arg_name in names(numeric_args)) {
    validate_scalar_numeric(numeric_args[[arg_name]], arg_name)
    if (numeric_args[[arg_name]] < 0) {
      cli::cli_abort("{.arg {arg_name}} must be greater than or equal to 0.")
    }
  }

  validate_param_range(phase1_nondemo_duration, "cohort_duration_days")
  if (phase2_nondemo_duration > 0) {
    validate_param_range(phase2_nondemo_duration, "cohort_duration_days")
  }
  if (partial_phase1_nondemo_duration > 0) {
    validate_param_range(partial_phase1_nondemo_duration, "cohort_duration_days")
  }
  if (partial_phase2_nondemo_duration > 0) {
    validate_param_range(partial_phase2_nondemo_duration, "cohort_duration_days")
  }
  if (simulation_duration > 0) {
    validate_param_range(simulation_duration, "simulation_duration")
  }
}
