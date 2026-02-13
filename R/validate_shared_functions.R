#' Validate a scalar numeric input
#'
#' Ensures that the given argument is a single numeric value (length 1, not NA).
#' This function is used throughout the package to enforce minimal type safety
#' for numeric parameters like rates, durations, weights, etc.
#'
#' @param x The object to validate.
#' @param arg_name String. The name of the argument to use in the error message.
#'
#' @noRd
validate_scalar_numeric <- function(x, arg_name) {
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
#'
#' @noRd
validate_scalar_character <- function(x, arg_name) {
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
#' @param arg_name String. The argument name for error reporting (not evaluated).
#' @param expected_length Integer. Required length of the vector.
#' @param expected_names Character vector. Optional. Set of required names.
#'
#' @noRd
validate_named_numeric_vector <- function(
    x, arg_name, expected_length, expected_names = NULL
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
#' Clamps numeric values to the provided lower/upper bounds while preserving NA.
#' This is used when rates are reused as scaling factors in downstream modules.
#'
#' @param x Numeric scalar or vector to normalize.
#' @param lower Numeric. Minimum allowed value (default: 0).
#' @param upper Numeric. Maximum allowed value (default: 1).
#'
#' @return Numeric values clamped to [lower, upper], with NA preserved.
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
#'
#' @noRd
validate_fraction <- function(x, arg_name) {
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
#'
#' @noRd
validate_positive_numeric <- function(x, arg_name) {
  validate_scalar_numeric(x, arg_name)
  if (x <= 0) {
    cli::cli_abort("{.arg {arg_name}} must be positive.")
  }
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
#' @param parameter_ranges_data Data.table of rules. Defaults to "data-raw/parameter_ranges.csv" loaded as internal data.
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
  is_lower_strict <- !isTRUE(rule_row$lower_inclusive)
  maximum_value <- rule_row$upper_bound
  is_upper_strict <- !isTRUE(rule_row$upper_inclusive)

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
