#' Validate a scalar numeric input
#'
#' Ensures that the given argument is a single numeric value (length 1, not NA).
#' This function is used throughout the package to enforce minimal type safety
#' for numeric parameters like rates, durations, weights, etc.
#'
#' @param x The object to validate.
#' @param arg_name String. The name of the argument to use in the error message.
#'   Defaults to the deparsed name of `x`.
#'
#' @noRd
validate_scalar_numeric <- function(x, arg_name = deparse(substitute(x))) {
  # Check if the input is numeric, scalar, and not missing
  if (!is.numeric(x) || length(x) != 1 || is.na(x)) {
    cli::cli_abort("{.arg {arg_name}} must be a single numeric value.")
  }
}

#' Validate a scalar character input
#'
#' Ensures that the input is a single, non-missing character value.
#' This function is typically used to validate identifiers or categorical inputs
#' such as `animal` or `cohort` within model functions.
#'
#' @param x The object to validate.
#' @param arg_name A string. The name of the argument (used in the error message).
#'   Defaults to the deparsed name of `x`.
#'
#' @noRd
validate_scalar_character <- function(x, arg_name = deparse(substitute(x))) {
  if (!is.character(x) || length(x) != 1 || is.na(x)) {
    cli::cli_abort("{.arg {arg_name}} must be a single character value.")
  }
}

#' Validate that input is a named numeric vector of a given length
#'
#' Used to validate cohort-based vectors like durations, offtake rates, death rates, etc.
#' Validate that input is a named numeric vector of a given length and optional names
#'
#' Used to validate cohort-based vectors like durations, offtake rates, death rates, etc.
#' This version checks type, length, presence of names, and (optionally) required names.
#'
#' @param x The object to validate.
#' @param expected_length Integer. Required length of the vector.
#' @param expected_names Character vector. Optional. Set of required names.
#' @param arg_name String. The argument name for error reporting.
#'   Defaults to the deparsed name of `x`.
#'
#' @noRd
validate_named_numeric_vector <- function(
    x, expected_length, expected_names = NULL, arg_name = deparse(substitute(x))
) {
  if (!is.numeric(x) || length(x) != expected_length || is.null(names(x))) {
    cli::cli_abort("{.arg {arg_name}} must be a numeric vector of length {expected_length} with names.")
  }

  if (!is.null(expected_names)) {
    if (!setequal(sort(names(x)), sort(expected_names))) {
      cli::cli_abort(
        "{.arg {arg_name}} must have names: {cli::format_inline('{expected_names}')}"
      )
    }
  }
}

#' Normalize a rate to a bounded range
#'
#' Ensures rate-like inputs remain within valid bounds before being used as scaling factors in downstream computations
#' @param x Numeric scalar or vector to normalize.
#' @param lower Numeric. Minimum allowed value (default: 0).
#' @param upper Numeric. Maximum allowed value (default: 1).
#'
#' @return Numeric values clamped to `[lower, upper]`.
#' @noRd
normalize_rate <- function(x, lower = 0, upper = 1) {
  if (!is.numeric(x)) {
    cli::cli_abort("{.arg x} must be numeric.")
  }
  pmax(lower, pmin(upper, x))
}

#' Validate fraction input (0 to 1)
#'
#' Ensures that the input is a numeric fraction between 0 and 1.
#'
#' @param x The object to validate.
#' @param arg_name String. The name of the argument to use in the error message.
#'   Defaults to the deparsed name of `x`.
#'
#' @noRd
validate_fraction <- function(x, arg_name = deparse(substitute(x))) {
  validate_scalar_numeric(x, arg_name)
  if (x < 0 || x > 1) {
    cli::cli_abort("{.arg {arg_name}} must be between 0 and 1.")
  }
}

#' Validate positive numeric input
#'
#' Ensures that the input is a positive numeric value.
#'
#' @param x The object to validate.
#' @param arg_name String. The name of the argument to use in the error message.
#'   Defaults to the deparsed name of `x`.
#'
#' @noRd
validate_positive_numeric <- function(x, arg_name = deparse(substitute(x))) {
  validate_scalar_numeric(x, arg_name)
  if (x <= 0) {
    cli::cli_abort("{.arg {arg_name}} must be positive.")
  }
}

#' Validate non-negative numeric input
#'
#' Ensures that the input is a numeric scalar greater than or equal to zero.
#'
#' @param x The object to validate.
#' @param arg_name String. The name of the argument to use in the error message.
#'   Defaults to the deparsed name of `x`.
#'
#' @noRd
validate_nonnegative_numeric <- function(x, arg_name = deparse(substitute(x))) {
  validate_scalar_numeric(x, arg_name)
  if (x < 0) {
    cli::cli_abort("{.arg {arg_name}} must be greater than or equal to 0.")
  }
}

#' Validate scalar numeric or NA
#'
#' Ensures the input is a single value that is either NA or a numeric >= min_val.
#'
#' @param x The object to validate.
#' @param arg_name String. The name of the argument to use in the error message.
#' @param min_val Numeric. Minimum allowed value when not NA (default 0).
#'
#' @noRd
validate_scalar_numeric_or_na <- function(
    x,
    arg_name = deparse(substitute(x)),
    min_val = 0
) {
  if (length(x) != 1L) {
    cli::cli_abort("{.arg {arg_name}} must be a single numeric (scalar). NA is allowed.")
  }
  if (!is.na(x)) {
    if (!is.numeric(x)) {
      cli::cli_abort("{.arg {arg_name}} must be a single numeric (scalar). NA is allowed.")
    }
    if (x < min_val) {
      cli::cli_abort("{.arg {arg_name}} must be >= {min_val}.")
    }
  }
}

#' Validate cohort-level egg-producing flag for chickens
#'
#' @noRd
validate_is_egg_producing_flag <- function(
    species_short,
    cohort_short,
    is_egg_producing = FALSE,
    nondemo_productive_phase_id = NA_real_
) {
  if (length(is_egg_producing) != 1L) {
    cli::cli_abort("{.arg is_egg_producing} must be a single logical value.")
  }

  if (!is.logical(is_egg_producing) && !is.na(is_egg_producing)) {
    cli::cli_abort("{.arg is_egg_producing} must be logical (TRUE/FALSE).")
  }

  if (!identical(species_short, "CHK")) {
    if (is.na(is_egg_producing) || !isTRUE(is_egg_producing)) {
      return(invisible(FALSE))
    }

    cli::cli_abort("{.arg is_egg_producing} can be TRUE only for {.val CHK}.")
  }

  if (is.na(is_egg_producing)) {
    cli::cli_abort("{.arg is_egg_producing} must be a single non-missing logical value for {.val CHK}.")
  }

  if (!isTRUE(is_egg_producing)) {
    return(invisible(FALSE))
  }

  if (!cohort_short %in% c("FA", "FN")) {
    cli::cli_abort("{.arg is_egg_producing} can be TRUE only for CHK cohorts {.val FA} or {.val FN}.")
  }

  if (identical(cohort_short, "FN") &&
      (is.na(nondemo_productive_phase_id) || nondemo_productive_phase_id != 2)) {
    cli::cli_abort(
      "{.arg is_egg_producing} can be TRUE for {.val FN} only when {.arg nondemo_productive_phase_id} is {.val 2}."
    )
  }

  invisible(TRUE)
}

#' Ensure optional egg-producing flag exists only when relevant
#'
#' Adds \code{is_egg_producing = NA} to cohort-level data when the column is
#' absent and no chicken rows are present in herd-level data. This keeps
#' run-module bodies clean while preserving the rule that the flag is only
#' required for \code{CHK}.
#'
#' @noRd
normalize_optional_is_egg_producing_column <- function(
    cohort_level_data,
    herd_level_data
) {
  if (!"is_egg_producing" %in% names(cohort_level_data) &&
      !"CHK" %in% herd_level_data$species_short) {
    cohort_level_data[, is_egg_producing := as.logical(NA)]
  }

  invisible(NULL)
}

#' Validate a numeric parameter (scalar or vector) against predefined bounds
#'
#' Look up `arg_name` in the internal data.table `parameter_ranges`
#' (loaded from sysdata.rda) which must contain exactly one row with:
#'   - variable_name
#'   - lower_bound (numeric)
#'   - lower_inclusive (logical)
#'   - upper_bound (numeric)
#'   - upper_inclusive (logical)
#'
#' @param x Numeric scalar or named numeric vector to validate.
#' @param arg_name Character scalar: must match one `variable_name`.
#' @param parameter_ranges_data Data.table of rules. Defaults to
#'   "data-raw/parameter_ranges.csv" loaded as internal data.
#'
#' @noRd
validate_param_range <- function(
    x,
    arg_name = deparse(substitute(x)),
    parameter_ranges_data = parameter_ranges
) {

  # Type and missingness checks
  if (!is.numeric(x)) {
    cli::cli_abort("{.arg {arg_name}} must be numeric.")
  }
  if (anyNA(x)) {
    cli::cli_abort("{.arg {arg_name}} must not contain missing values.")
  }

  # Look up the single rule row
  rule_row <- parameter_ranges_data[variable_name == arg_name]
  if (nrow(rule_row) != 1L) {
    cli::cli_abort(
      "Internal error: expected exactly one rule for {.arg {arg_name}}, found {nrow(rule_row)}."
    )
  }

  # Extract bounds and inclusivity
  minimum_value <- rule_row$lower_bound
  is_lower_strict <- !rule_row$lower_inclusive
  maximum_value <- rule_row$upper_bound
  is_upper_strict <- !rule_row$upper_inclusive

  # Prepare the values vector and its labels
  numeric_values <- as.numeric(x)
  value_labels <- names(x) %||% seq_along(numeric_values)

  # Perform vectorized bound checks
  violates_lower <- if (is_lower_strict) {
    numeric_values <= minimum_value
  } else {
    numeric_values < minimum_value
  }
  violates_upper <- if (is_upper_strict) {
    numeric_values >= maximum_value
  } else {
    numeric_values > maximum_value
  }
  invalid_indices <- which(violates_lower | violates_upper)

  # If any violation, report the first with full context
  if (length(invalid_indices)) {
    first_index <- invalid_indices[1]
    invalid_value <- numeric_values[first_index]
    invalid_label <- value_labels[first_index]

    # Omit brackets for single, unnamed scalar
    label_suffix <- if (length(numeric_values) == 1L && is.null(names(x))) {
      ""
    } else {
      paste0("[", invalid_label, "]")
    }

    lower_operator <- if (is_lower_strict) ">" else "\u2265"
    upper_operator <- if (is_upper_strict) "<" else "\u2264"

    cli::cli_abort(
      "{.arg {arg_name}}{label_suffix} = {invalid_value} is out of range;
      expected value should be {lower_operator} {minimum_value} and {upper_operator} {maximum_value}."
    )
  }
}

#' Validate species short code
#'
#' Ensures that the species short code is valid for energy requirements calculations.
#'
#' @param species_short Character. The species short code to validate.
#'
#' @noRd
validate_animal_species <- function(species_short) {
  validate_scalar_character(species_short)
  if (!species_short %in% gleam_species) {
    cli::cli_abort(
      "{.arg species_short} must be one of: {cli::format_inline('{gleam_species}')}"
    )
  }
}

#' Validate cohort short code
#'
#' Ensures that the cohort short code is valid for energy requirements calculations.
#'
#' @param cohort_short Character. The cohort short code to validate.
#'
#' @noRd
validate_cohort_code <- function(cohort_short) {
  validate_scalar_character(cohort_short)
  if (!cohort_short %in% gleam_cohorts) {
    cli::cli_abort(
      "{.arg cohort_short} must be one of: {cli::format_inline('{gleam_cohorts}')}"
    )
  }
}

#' Validate species_short values in a column or vector
#'
#' Ensures that all unique values in \code{x} are valid species short codes.
#' Used by run-level validators when checking \code{species_short} columns in
#' data.tables.
#'
#' @param x Character vector of species codes (e.g. from \code{data$species_short}).
#' @param column_name String. Name of the column for error messages (default:
#'   \code{"species_short"}).
#' @param data_arg String. Name of the data argument for error messages (e.g.
#'   \code{"cohort_level_data"}, \code{"herd_level_data"}, \code{"data"}).
#'
#' @noRd
validate_species_short_values <- function(
    x,
    column_name = "species_short",
    data_arg = "data"
) {
  invalid <- setdiff(unique(x), gleam_species)
  if (length(invalid) > 0) {
    cli::cli_abort(
      "Invalid {.var {column_name}} values in {.arg {data_arg}}: {.val {invalid}}.
      Must be one of: {.val {gleam_species}}"
    )
  }
}

#' Validate cohort_short values in a column or vector
#'
#' Ensures that all unique values in \code{x} are valid cohort short codes.
#' Used by run-level validators when checking \code{cohort_short} columns in
#' data.tables.
#'
#' @param x Character vector of cohort codes (e.g. from \code{data$cohort_short}).
#' @param column_name String. Name of the column for error messages (default:
#'   \code{"cohort_short"}).
#' @param data_arg String. Name of the data argument for error messages (e.g.
#'   \code{"cohort_level_data"}, \code{"herd_level_data"}, \code{"data"}).
#'
#' @noRd
validate_cohort_short_values <- function(
    x,
    column_name = "cohort_short",
    data_arg = "data"
) {
  invalid <- setdiff(unique(x), gleam_cohorts)
  if (length(invalid) > 0) {
    cli::cli_abort(
      "Invalid {.var {column_name}} values in {.arg {data_arg}}: {.val {invalid}}.
      Must be one of: {.val {gleam_cohorts}}"
    )
  }
}

# --- Run-level validation helpers (cohort + herd structure) --------------------
# Shared checks used by validate_run_*_inputs across weights, demographic_herd,
# metabolic_energy_req, nitrogen_balance, production, emissions, allocation.

#' Check that a table is a non-empty data.table
#'
#' Validates type and presence of at least one row. Used at the start of
#' run-level validators.
#'
#' @param x Object to check.
#' @param arg_name String. Argument name for error messages.
#' @noRd
check_data_table <- function(x, arg_name) {
  if (!data.table::is.data.table(x)) {
    cli::cli_abort("{.arg {arg_name}} must be a data.table.")
  }
  if (nrow(x) == 0) {
    cli::cli_abort("{.arg {arg_name}} must contain at least one row.")
  }
}

#' Check that a data.table has all required columns
#'
#' Reports which required columns are missing. Call after check_data_table.
#'
#' @param data data.table.
#' @param required_cols Character vector of column names.
#' @param arg_name String. Argument name for error messages.
#' @noRd
check_required_columns <- function(data, required_cols, arg_name) {
  missing <- setdiff(required_cols, names(data))
  if (length(missing) > 0) {
    cli::cli_abort(
      "Missing required columns in {.arg {arg_name}}: {.val {missing}}"
    )
  }
}

#' Check cohort completeness: require all 6 demographic cohorts per herd_id
#'
#' Each herd must include the 6 demographic cohorts (FJ, FS, FA, MJ, MS, MA)
#' with no duplicates among those cohorts. Additional cohorts such as FN and MN
#' are allowed. Assumes validate_cohort_short_values was already called on the
#' cohort_short column.
#'
#' @param cohort_level_data data.table with herd_id and cohort_short.
#' @param data_arg String. Argument name for error messages.
#' @noRd
check_cohort_completeness <- function(cohort_level_data, data_arg = "cohort_level_data") {
  demographic_rows <- cohort_level_data[
    cohort_short %in% gleam_cohorts_demographic
  ]

  # Aggregate per herd on the demographic subset only
  cohort_completeness <- demographic_rows[
    , list(
      count = .N,
      has_all_cohorts = setequal(cohort_short, gleam_cohorts_demographic),
      missing_cohorts = paste(setdiff(gleam_cohorts_demographic, cohort_short), collapse = ", ")
    ),
    by = herd_id
  ]
  wrong_count <- cohort_completeness[count != 6]
  if (nrow(wrong_count) > 0) {
    cli::cli_abort(
      "Each herd_id must have exactly 6 rows in {.arg {data_arg}} (one per cohort).
      Found incorrect counts for herd_ids: {.val {wrong_count$herd_id}}"
    )
  }
  incomplete_herds <- cohort_completeness[has_all_cohorts == FALSE]
  if (nrow(incomplete_herds) > 0) {
    missing_info <- incomplete_herds[
      , paste0(herd_id, " (missing: ", missing_cohorts, ")"),
      by = herd_id
    ]$V1
    cli::cli_abort(
      "Each herd_id must have exactly one row for each of the 6 cohorts in {.arg {data_arg}}.
      Incomplete or duplicate cohorts found for herd_ids: {.val {missing_info}}"
    )
  }
}

#' Check non-demographic phase completeness by herd and cohort block
#'
#' Each herd_id and non-demographic cohort_short combination must contain
#' exactly one \code{nondemo_productive_phase_id == 1} row, at most one
#' \code{nondemo_productive_phase_id == 2} row,
#' and no other phase identifiers.
#'
#' @param cohort_level_data data.table with herd_id, cohort_short and nondemo_productive_phase_id.
#' @param data_arg String. Argument name for error messages.
#' @noRd
check_nondemographic_phase_completeness <- function(
    cohort_level_data,
    data_arg = "cohort_level_data"
) {
  invalid_phase_rows <- cohort_level_data[!(nondemo_productive_phase_id %in% c(1, 2))]
  if (nrow(invalid_phase_rows) > 0) {
    cli::cli_abort(
      "{.arg {data_arg}} must use only {.val 1} or {.val 2} in {.var nondemo_productive_phase_id}.
      Invalid rows found for herd/cohort combinations: {.val {paste0(invalid_phase_rows$herd_id, '/', invalid_phase_rows$cohort_short)}}"
    )
  }

  phase_summary <- cohort_level_data[
    ,
    .(
      n_phase_1 = sum(nondemo_productive_phase_id == 1),
      n_phase_2 = sum(nondemo_productive_phase_id == 2)
    ),
    by = .(herd_id, cohort_short)
  ]

  invalid_structure <- phase_summary[n_phase_1 != 1 | n_phase_2 > 1]
  if (nrow(invalid_structure) > 0) {
    invalid_keys <- invalid_structure[
      ,
      paste0(
        herd_id, "/", cohort_short,
        " (phase1=", n_phase_1, ", phase2=", n_phase_2, ")"
      )
    ]
    cli::cli_abort(
      "Each herd/cohort block in {.arg {data_arg}} must have exactly one phase 1 row
      and at most one phase 2 row. Invalid blocks: {.val {invalid_keys}}"
    )
  }
}

#' Check that herd_id appears exactly once per row in herd-level data
#'
#' @param herd_level_data data.table with herd_id column.
#' @param arg_name String. Argument name for error messages.
#' @noRd
check_herd_id_unique <- function(herd_level_data, arg_name = "herd_level_data") {
  herd_id_counts <- herd_level_data[, .N, by = herd_id]
  duplicate_herds <- herd_id_counts[N > 1]
  if (nrow(duplicate_herds) > 0) {
    cli::cli_abort(
      "Each herd_id must appear exactly once in {.arg {arg_name}}.
      Found duplicates for herd_ids: {.val {duplicate_herds$herd_id}}"
    )
  }
}

#' Check that cohort_level_data and herd_level_data share the same herd_id set
#'
#' @param cohort_level_data data.table with herd_id.
#' @param herd_level_data data.table with herd_id.
#' @param cohort_arg String. Argument name for cohort table in error messages.
#' @param herd_arg String. Argument name for herd table in error messages.
#' @noRd
check_herd_id_consistency <- function(
    cohort_level_data,
    herd_level_data,
    cohort_arg = "cohort_level_data",
    herd_arg = "herd_level_data"
) {
  cohort_herd_ids <- unique(cohort_level_data$herd_id)
  herd_level_herd_ids <- unique(herd_level_data$herd_id)
  missing_in_herd_level <- setdiff(cohort_herd_ids, herd_level_herd_ids)
  if (length(missing_in_herd_level) > 0) {
    cli::cli_abort(
      "Herd IDs in {.arg {cohort_arg}} not found in {.arg {herd_arg}}: {.val {missing_in_herd_level}}"
    )
  }
  missing_in_cohort <- setdiff(herd_level_herd_ids, cohort_herd_ids)
  if (length(missing_in_cohort) > 0) {
    cli::cli_abort(
      "Herd IDs in {.arg {herd_arg}} not found in {.arg {cohort_arg}}: {.val {missing_in_cohort}}"
    )
  }
}
