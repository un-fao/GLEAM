#' Configure optional validation for one pipeline or module run
#'
#' @param validate_inputs Controls input validation (default \code{TRUE}).
#'   Set to \code{FALSE} to skip input validation. This is not recommended,
#'   except for large datasets or repeated runs using inputs that have already
#'   been validated. A warning is issued when validation is disabled. Invalid
#'   inputs may lead to incorrect results or calculation errors.
#' @param new_cache Start a fresh rule cache for a pipeline, including nested runs.
#'   Modules within an active run reuse its cache.
#' @return A function that restores the previous options, registered by the caller
#'   with on.exit so cleanup also runs after errors and nested calls.
#' @noRd
setup_validation <- function(validate_inputs, new_cache = FALSE) {
  if (!is.logical(validate_inputs) || length(validate_inputs) != 1L || is.na(validate_inputs)) {
    cli::cli_abort("{.arg validate_inputs} must be TRUE or FALSE.")
  }
  # Warn once when entering an unchecked run, including standalone modules.
  if (!validate_inputs && (!isTRUE(getOption("gleam.validation_active")) || validation_enabled())) {
    cli::cli_warn(paste0(
      "Input validation has been turned off. Potential inconsistencies or invalid ",
      "input values will not be flagged. Use this option with caution and ensure ",
      "that input data have been checked before running the pipeline."
    ))
  }
  # Cache only rule lookups; every input value is still checked.
  cache <- getOption("gleam.validation_cache")
  if (new_cache || !isTRUE(getOption("gleam.validation_active")) || !is.environment(cache)) {
    cache <- new.env(parent = emptyenv())
  }
  previous_validation <- options(
    gleam.validate = validate_inputs,
    gleam.validation_active = TRUE,
    gleam.validation_cache = cache
  )
  function() options(previous_validation)
}

#' Check whether input validation is enabled
#' @noRd
validation_enabled <- function() {
  !isFALSE(getOption("gleam.validate"))
}

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
  if (!validation_enabled()) return(invisible(NULL))
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
  if (!validation_enabled()) return(invisible(NULL))
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
  if (!validation_enabled()) return(invisible(NULL))
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
  if (!validation_enabled()) return(invisible(NULL))
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
  if (!validation_enabled()) return(invisible(NULL))
  validate_scalar_numeric(x, arg_name)
  if (x <= 0) {
    cli::cli_abort("{.arg {arg_name}} must be positive.")
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
  if (!validation_enabled()) return(invisible(NULL))
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

#' Read distinct numeric bounds from the shared parameter rows
#'
#' Range scopes are independent of dependency/comparison scopes. The same bounds
#' may appear on several dependency rows; validate each distinct range only once.
#' @noRd
get_parameter_range_rules <- function(parameter_rules_data = parameter_rules, variable_filter = NULL) {
  selected <- !is.na(parameter_rules_data$lower_bound) | !is.na(parameter_rules_data$upper_bound)
  if (!is.null(variable_filter)) selected <- selected & parameter_rules_data$variable %in% variable_filter
  scope_columns <- if (all(c("range_species_short", "range_cohort_short") %in% names(parameter_rules_data))) {
    c("range_species_short", "range_cohort_short")
  } else c("species_short", "cohort_short")
  columns <- intersect(c("variable", scope_columns, "lower_bound", "lower_inclusive",
                         "upper_bound", "upper_inclusive"), names(parameter_rules_data))
  rules <- parameter_rules_data[which(selected), columns, with = FALSE]
  for (i in seq_along(scope_columns)) {
    column <- c("species_short", "cohort_short")[i]
    if (scope_columns[i] %in% names(rules)) {
      data.table::setnames(rules, scope_columns[i], column)
    } else data.table::set(rules, j = column, value = "ANY")
  }
  unique(rules)
}

#' Validate a numeric parameter (scalar or vector) against predefined bounds
#'
#' Look up `arg_name` in the internal data.table `parameter_rules`, built from
#' `data-raw/parameter_rules.csv`. Numeric bounds are stored alongside dependencies:
#'   - variable
#'   - lower_bound (numeric)
#'   - lower_inclusive (logical)
#'   - upper_bound (numeric)
#'   - upper_inclusive (logical)
#'   - range_species_short and range_cohort_short (codes or ANY for common limits)
#' Common and matching species/cohort limits all apply. Specific rules can
#' tighten the common limits. Without context, only common rules apply.
#'
#' @param x Numeric scalar or named numeric vector to validate.
#' @param arg_name Character scalar: must match one `variable`.
#' @param parameter_rules_data Data.table of rules. Defaults to
#'   range rules from "data-raw/parameter_rules.csv" loaded as internal data.
#' @param species_filter Optional species code for selecting range rules.
#' @param cohort_filter Optional cohort code for selecting range rules.
#'
#' @noRd
validate_param_range <- function(
    x,
    arg_name = deparse(substitute(x)),
    parameter_rules_data = parameter_rules,
    species_filter = NULL,
    cohort_filter = NULL
) {
  if (!validation_enabled()) return(invisible(NULL))

  # Type and missingness checks
  if (!is.numeric(x)) {
    cli::cli_abort("{.arg {arg_name}} must be numeric.")
  }
  if (anyNA(x)) {
    cli::cli_abort("{.arg {arg_name}} must not contain missing values.")
  }

  if (!is.null(species_filter)) validate_animal_species(species_filter)
  if (!is.null(cohort_filter)) validate_cohort_code(cohort_filter)

  cache <- if (missing(parameter_rules_data)) getOption("gleam.validation_cache") else NULL
  cache_key <- paste("range", arg_name, species_filter %||% "", cohort_filter %||% "", sep = "|")
  bounds <- if (!is.null(cache)) cache[[cache_key]] else NULL
  if (is.null(bounds)) {
    rule_row <- get_parameter_range_rules(parameter_rules_data, arg_name)
    if (any(!rule_row$species_short %in% c("ANY", gleam_species)) ||
        any(!rule_row$cohort_short %in% c("ANY", gleam_cohorts))) {
      cli::cli_abort("Invalid species/cohort scope in parameter range rules for {.arg {arg_name}}.")
    }
    rule_row <- rule_row[which(
      rule_row$species_short %in% c("ANY", species_filter) &
        rule_row$cohort_short %in% c("ANY", cohort_filter)
    )]
    if (nrow(rule_row) == 0L) {
      cli::cli_abort(
        "No parameter range rule for {.arg {arg_name}} and the supplied species/cohort context."
      )
    }
    if (anyDuplicated(rule_row, by = c("species_short", "cohort_short"))) {
      cli::cli_abort("Duplicate parameter range rules for {.arg {arg_name}} and the same species/cohort scope.")
    }

    # Intersect applicable limits, preserving strict endpoints.
    minimum_value <- max(rule_row$lower_bound)
    is_lower_strict <- !all(rule_row$lower_inclusive[rule_row$lower_bound == minimum_value])
    maximum_value <- min(rule_row$upper_bound)
    is_upper_strict <- !all(rule_row$upper_inclusive[rule_row$upper_bound == maximum_value])
    if (minimum_value > maximum_value ||
        (minimum_value == maximum_value && (is_lower_strict || is_upper_strict))) {
      cli::cli_abort("Conflicting parameter range rules for {.arg {arg_name}} and the supplied species/cohort context.")
    }
    bounds <- list(minimum = minimum_value, maximum = maximum_value,
                   lower_strict = is_lower_strict, upper_strict = is_upper_strict)
    if (!is.null(cache)) cache[[cache_key]] <- bounds
  }
  minimum_value <- bounds$minimum
  maximum_value <- bounds$maximum
  is_lower_strict <- bounds$lower_strict
  is_upper_strict <- bounds$upper_strict

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
    context_label <- paste(c(species_filter, cohort_filter), collapse = "/")
    context_suffix <- if (nzchar(context_label)) paste0(" for ", context_label) else ""

    cli::cli_abort(
      "{.arg {arg_name}}{label_suffix} = {invalid_value} is out of range{context_suffix};
      expected value should be {lower_operator} {minimum_value} and {upper_operator} {maximum_value}."
    )
  }
}

#' Validate comparisons between parameters from the shared rules table
#'
#' Comparison rows specify an operator and another variable, with species,
#' cohort and validation_function scope. Missing operands are handled by the
#' existing required-input checks. Only complete numeric pairs are compared.
#' The positive_if_positive operator requires the variable to be positive
#' whenever comparison_variable is positive.
#' @noRd
validate_parameter_relations <- function(
    inputs, function_filter, species_filter = NULL, cohort_filter = NULL,
    parameter_rules_data = parameter_rules
) {
  if (!validation_enabled()) return(invisible(NULL))
  validate_scalar_character(function_filter)
  if (!is.null(species_filter)) validate_animal_species(species_filter)
  if (!is.null(cohort_filter)) validate_cohort_code(cohort_filter)
  cache <- if (missing(parameter_rules_data)) getOption("gleam.validation_cache") else NULL
  cache_key <- paste("comparison", function_filter, species_filter %||% "", cohort_filter %||% "", sep = "|")
  rules <- if (!is.null(cache)) cache[[cache_key]] else NULL
  if (is.null(rules)) {
    if (!"comparison_operator" %in% names(parameter_rules_data)) return(invisible(TRUE))
    rules <- unique(parameter_rules_data[which(
      !is.na(parameter_rules_data$comparison_operator) & nzchar(parameter_rules_data$comparison_operator)
    ), .(variable, species_short, cohort_short, comparison_operator, comparison_variable, validation_function)])
    matches_function <- vapply(strsplit(rules$validation_function, ";", fixed = TRUE), function(functions) {
      any(trimws(functions) %in% c("ANY", function_filter))
    }, logical(1))
    rules <- rules[which(matches_function)]
    if (any(!rules$species_short %in% c("ANY", gleam_species)) ||
        any(!rules$cohort_short %in% c("ANY", gleam_cohorts))) {
      cli::cli_abort("Invalid species/cohort scope in parameter comparison rules for {.fn {function_filter}}.")
    }
    rules <- rules[which(
      rules$species_short %in% c("ANY", species_filter) &
        rules$cohort_short %in% c("ANY", cohort_filter)
    )]
    if (!is.null(cache)) cache[[cache_key]] <- rules
  }
  operators <- c("<" = "less than", "<=" = "less than or equal to",
                 ">" = "greater than", ">=" = "greater than or equal to",
                 "==" = "equal to", "!=" = "different from",
                 "positive_if_positive" = "positive when the reference is positive")
  if (any(!rules$comparison_operator %in% names(operators)) ||
      anyNA(rules$comparison_variable) || any(!nzchar(rules$comparison_variable))) {
    cli::cli_abort("Invalid parameter comparison rule for {.fn {function_filter}}.")
  }
  for (i in seq_len(nrow(rules))) {
    variable <- rules$variable[i]
    reference <- rules$comparison_variable[i]
    if (!all(c(variable, reference) %in% names(inputs))) next
    left <- inputs[[variable]]
    right <- inputs[[reference]]
    if (length(left) != length(right)) {
      cli::cli_abort("{.arg {variable}} and {.arg {reference}} must have the same length for comparison.")
    }
    complete <- !is.na(left) & !is.na(right)
    if (!any(complete)) next
    if (!is.numeric(left) || !is.numeric(right)) {
      cli::cli_abort("{.arg {variable}} and {.arg {reference}} must be numeric for comparison.")
    }
    operator <- rules$comparison_operator[i]
    valid <- switch(operator,
      "<" = left < right, "<=" = left <= right,
      ">" = left > right, ">=" = left >= right,
      "==" = left == right, "!=" = left != right,
      "positive_if_positive" = right <= 0 | left > 0
    )
    invalid <- which(complete & !valid)
    if (length(invalid)) {
      row <- invalid[1L]
      label <- if ("herd_id" %in% names(inputs)) paste0("herd ", inputs$herd_id[row]) else paste0("position ", row)
      context <- paste(c(species_filter, cohort_filter), collapse = "/")
      if (operator == "positive_if_positive") {
        cli::cli_abort(
          "{.arg {variable}} must be greater than 0 when {.arg {reference}} is greater than 0.
          Found {left[row]} and {right[row]} at {label} {.val {context}}."
        )
      }
      comparison <- unname(operators[operator])
      cli::cli_abort(
        "{.arg {variable}} must be {comparison} {.arg {reference}} ({operator}).
        Found {left[row]} and {right[row]} at {label} {.val {context}}."
      )
    }
  }
  invisible(TRUE)
}

#' Validate species short code
#'
#' Ensures that the species short code is valid for energy requirements calculations.
#'
#' @param species_short Character. The species short code to validate.
#'
#' @noRd
validate_animal_species <- function(species_short) {
  if (!validation_enabled()) return(invisible(NULL))
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
  if (!validation_enabled()) return(invisible(NULL))
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
  if (!validation_enabled()) return(invisible(NULL))
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
  if (!validation_enabled()) return(invisible(NULL))
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

#' Check cohort completeness: exactly 6 rows per herd_id, all 6 cohort codes present
#'
#' Each herd must have exactly 6 rows (one per FJ, FS, FA, MJ, MS, MA) with no
#' duplicates or missing cohorts. Assumes validate_cohort_short_values was
#' already called on the cohort_short column.
#'
#' @param cohort_level_data data.table with herd_id and cohort_short.
#' @param data_arg String. Argument name for error messages.
#' @noRd
check_cohort_completeness <- function(cohort_level_data, data_arg = "cohort_level_data") {
  # Aggregate per herd: row count and whether all 6 cohorts are present
  cohort_completeness <- cohort_level_data[
    , list(
      count = .N,
      has_all_cohorts = setequal(cohort_short, gleam_cohorts),
      missing_cohorts = paste(setdiff(gleam_cohorts, cohort_short), collapse = ", ")
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

#' Check requested cohorts without requiring an entire demographic herd
#' @noRd
check_cohort_uniqueness <- function(cohort_level_data, data_arg = "cohort_level_data") {
  duplicates <- cohort_level_data[, .N, by = .(herd_id, cohort_short)][N > 1L]
  if (nrow(duplicates)) {
    cli::cli_abort("Each herd_id x cohort_short combination in {.arg {data_arg}} must be unique.")
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

# --- Matrix-based parameter requirements ------------------------------------

#' List required matrix inputs for one or more cohorts
#'
#' Inspect required columns without supplying input tables or running model
#' calculations. Requirements are selected for every combination of the requested
#' species and cohorts.
#'
#' @param cohort_short Character vector of one or more cohort codes:
#'   \code{FA}, \code{MA}, \code{FS}, \code{MS}, \code{FJ}, or \code{MJ}.
#' @param module_filter Optional matrix column: \code{run_demographic_herd},
#'   \code{run_weights}, \code{run_ration_quality}, \code{run_metabolic_energy_req},
#'   \code{run_emissions_enteric}, \code{run_nitrogen_balance},
#'   \code{run_emissions_manure}, \code{run_emissions_ration},
#'   \code{run_production}, \code{run_allocation}, or \code{run_aggregation}.
#'   Existing short module names, such as \code{weights}, are also accepted.
#'   \code{run_gleam} selects the
#'   pipeline using the matrix's \code{run_gleam} column; \code{NULL} is equivalent.
#' @param has_herd_structure_filter Logical. Use \code{TRUE} for a supplied herd
#'   structure or \code{FALSE} for demographic simulation. \code{NULL} includes
#'   both modes. Rules marked \code{ANY} apply to either mode.
#' @param species_short Optional character vector of species codes:
#'   \code{CTL}, \code{BFL}, \code{SHP}, \code{GTS}, \code{PGS}, or \code{CML}.
#'   \code{NULL} includes all supported species, retaining their separate rules.
#' @param input_table_filter Optional character vector of input table names:
#'   \code{cohort_level_data},
#'   \code{herd_level_data}, \code{feed_rations}, \code{feed_params},
#'   \code{feed_emissions}, \code{manure_management_system_fraction}, or
#'   \code{manure_management_system_factors}. \code{NULL} includes all tables.
#'
#' @return A \code{data.table} with \code{input_table}, \code{variable},
#'   \code{species_short}, \code{cohort_short}, and \code{has_herd_structure},
#'   containing one row per required column, input table, species, and cohort.
#'   Overlapping herd-structure rules are combined: \code{ANY} covers both
#'   \code{TRUE} and \code{FALSE}. A valid filter with no required inputs returns
#'   an empty table with the same columns.
#'
#' @details
#' In \code{parameter_rules}, \code{ANY} in \code{species_short} or
#' \code{cohort_short} applies to every supported species or cohort. This helper
#' reports those shared rules using the requested species and cohort codes.
#' Dependency requirements and numeric bounds occupy columns on the same rows.
#' Bounds use \code{range_species_short} and \code{range_cohort_short}, allowing
#' common limits to accompany dependencies that apply only to specific cohorts.
#' This function reports matrix requirements. Structural identifiers and
#' calculated inputs retain their existing validation. Current pig/camel activity
#' equations also require both activity fractions; methane density uses the
#' existing default when omitted from the factor table.
#' Demographic herd execution requires all six cohorts and its complete input
#' schema, including when \code{run_gleam(has_herd_structure = FALSE)} is used.
#'
#' @seealso \code{\link{run_gleam}}, \code{\link{run_weights_module}}
#' @examples
#' check_required_parameter(
#'   cohort_short = c("FA", "MA"),
#'   module_filter = "run_gleam",
#'   has_herd_structure_filter = TRUE
#' )
#'
#' check_required_parameter(
#'   cohort_short = "FA",
#'   species_short = "CTL",
#'   module_filter = "run_weights",
#'   input_table_filter = c("cohort_level_data", "herd_level_data")
#' )
#' @export
check_required_parameter <- function(
    cohort_short,
    module_filter = NULL,
    has_herd_structure_filter = NULL,
    species_short = NULL,
    input_table_filter = NULL
) {
  if (!is.character(cohort_short) || length(cohort_short) == 0L) {
    cli::cli_abort("{.arg cohort_short} must be a non-empty character vector of cohort codes.")
  }
  validate_cohort_short_values(cohort_short, data_arg = "cohort_short")
  if (is.null(species_short)) species_short <- gleam_species
  if (!is.character(species_short) || length(species_short) == 0L) {
    cli::cli_abort("{.arg species_short} must be a non-empty character vector of species codes.")
  }
  validate_species_short_values(species_short, data_arg = "species_short")
  requested <- data.table::CJ(
    species_short = unique(species_short), cohort_short = unique(cohort_short)
  )
  rules <- get_required_parameter_rules(
    requested, module_filter, input_table_filter, has_herd_structure_filter
  )
  unknown_tables <- setdiff(input_table_filter, parameter_rules[requirement %in% c("R", "O"), input_table])
  if (length(unknown_tables) > 0L) {
    cli::cli_abort("Unknown input table filter: {.val {unknown_tables}}.")
  }
  # ANY already includes TRUE/FALSE; report each required column only once.
  result <- rules[, .(
    has_herd_structure = if ("ANY" %in% has_herd_structure ||
      all(c("TRUE", "FALSE") %in% has_herd_structure)) "ANY" else has_herd_structure[1L]
  ), by = .(input_table, variable, species_short, cohort_short)]
  data.table::setorderv(result, names(result))
  result
}

#' Match shared ANY rules and require coverage of each requested species/cohort
#'
#' Call before selecting required rows: optional rules count as coverage, while
#' missing rules must not silently disable validation.
#' @noRd
match_parameter_rule_context <- function(rules, requested) {
  for (column in c("species_short", "cohort_short")) {
    requested_codes <- unique(requested[[column]])
    rules <- rules[which(rules[[column]] %in% c("ANY", requested_codes))]

    # Apply each ANY rule to every requested code.
    shared_rows <- which(rules[[column]] == "ANY")
    if (length(shared_rows)) {
      shared_rules <- rules[rep(shared_rows, each = length(requested_codes))]
      data.table::set(
        shared_rules, j = column,
        value = rep(requested_codes, times = length(shared_rows))
      )
      rules <- data.table::rbindlist(list(rules[-shared_rows], shared_rules))
    }
  }

  # Keep only the requested pairs, rather than every possible combination.
  rules <- rules[requested, on = .(species_short, cohort_short), nomatch = 0]
  covered_pairs <- unique(rules[, .(species_short, cohort_short)])
  missing_pairs <- requested[!covered_pairs, on = .(species_short, cohort_short)]
  if (nrow(missing_pairs) > 0L) {
    pairs <- paste(missing_pairs$species_short, missing_pairs$cohort_short, sep = "/")
    cli::cli_abort(
      "Missing parameter dependency rules for species/cohort: {.val {pairs}} under the requested filters."
    )
  }
  rules
}

#' Select required dependency rows, retaining their species/cohort applicability
#' @noRd
get_required_parameter_rules <- function(
    cohort_level_data,
    module_filter = NULL,
    input_table_filter = NULL,
    has_herd_structure_filter = NULL,
    dependencies = parameter_rules
) {
  check_data_table(cohort_level_data, "cohort_level_data")
  check_required_columns(cohort_level_data, c("species_short", "cohort_short"), "cohort_level_data")
  validate_species_short_values(cohort_level_data$species_short)
  validate_cohort_short_values(cohort_level_data$cohort_short)
  check_data_table(dependencies, "parameter_rules")
  check_required_columns(
    dependencies,
    c("species_short", "cohort_short", "input_table", "requirement", "variable", "has_herd_structure"),
    "parameter_rules"
  )
  if (!is.null(input_table_filter)) {
    if (!is.character(input_table_filter) || length(input_table_filter) == 0L || anyNA(input_table_filter)) {
      cli::cli_abort("{.arg input_table_filter} must be a non-empty character vector of input table names.")
    }
  }
  rules <- dependencies[which(dependencies$requirement %in% c("R", "O"))]
  requested <- unique(cohort_level_data[, .(species_short, cohort_short)])

  # Accept both matrix column names and their short aliases.
  if (is.null(module_filter)) {
    module_filter <- "run_gleam"
  }
  validate_scalar_character(module_filter)
  module_lookup <- c(
    demographic = "run_demographic_herd",
    weights = "run_weights",
    ration_quality = "run_ration_quality",
    metabolic_energy = "run_metabolic_energy_req",
    enteric = "run_emissions_enteric",
    nitrogen = "run_nitrogen_balance",
    manure = "run_emissions_manure",
    feed_emissions = "run_emissions_ration",
    production = "run_production",
    allocation = "run_allocation",
    aggregation = "run_aggregation",
    run_gleam = "run_gleam"
  )
  module_column <- if (module_filter %in% module_lookup) {
    module_filter
  } else {
    unname(module_lookup[module_filter])
  }
  if (is.na(module_column)) {
    cli::cli_abort("Unknown module filter: {.val {module_filter}}.")
  }
  check_required_columns(rules, module_column, "parameter_rules")
  rules <- rules[get(module_column) == "X"]

  if (!is.null(has_herd_structure_filter)) {
    if (!is.logical(has_herd_structure_filter) ||
        length(has_herd_structure_filter) != 1L || is.na(has_herd_structure_filter)) {
      cli::cli_abort("{.arg has_herd_structure_filter} must be TRUE or FALSE.")
    }
    herd_structure <- as.character(has_herd_structure_filter)
    rules <- rules[has_herd_structure %in% c("ANY", herd_structure)]
  }
  rules <- match_parameter_rule_context(rules, requested)

  # A module may legitimately need no herd/feed inputs for a requested cohort.
  # Check module coverage before restricting the input table.
  if (!is.null(input_table_filter)) {
    rules <- rules[input_table %in% input_table_filter]
  }
  rules[requirement == "R"]
}

#' Resolve species/cohort context without changing public module input schemas
#' @noRd
get_parameter_context <- function(cohort_level_data, herd_level_data = NULL) {
  context <- data.table::as.data.table(cohort_level_data)
  check_required_columns(context, c("herd_id", "cohort_short"), "cohort_level_data")
  keys <- intersect(c("herd_id", "species_short", "cohort_short", "feed_id"), names(context))
  context <- unique(context[, keys, with = FALSE])
  if (!"species_short" %in% names(context)) {
    if (!is.null(herd_level_data) && "species_short" %in% names(herd_level_data)) {
      species <- unique(data.table::as.data.table(herd_level_data)[, .(herd_id, species_short)])
      context <- merge(context, species, by = "herd_id", all.x = TRUE)
    } else {
      # Species-independent entry points (e.g. demographics) retain their API.
      context <- context[rep(seq_len(.N), each = length(gleam_species))]
      context[, species_short := rep(gleam_species, length.out = .N)]
    }
  } else if (!is.null(herd_level_data) && "species_short" %in% names(herd_level_data)) {
    species <- data.table::as.data.table(herd_level_data)[, .(herd_id, species_short)]
    if (nrow(context[!species, on = .(herd_id, species_short)])) {
      cli::cli_abort("species_short must agree between cohort_level_data and herd_level_data for each herd_id.")
    }
  }
  context
}

#' Check external module inputs from the matrix and retain structural/derived checks
#' @noRd
check_module_input_columns <- function(
    data, required_cols, arg_name, module_filter, cohort_level_data,
    herd_level_data = NULL, input_table_filter = arg_name,
    has_herd_structure_filter = NULL, always_required = character(),
    defaulted_parameters = character(), function_filter = NULL
) {
  data <- data.table::as.data.table(data)
  context <- get_parameter_context(cohort_level_data, herd_level_data)
  rules <- get_required_parameter_rules(
    cohort_level_data = context,
    module_filter = module_filter,
    input_table_filter = input_table_filter,
    has_herd_structure_filter = has_herd_structure_filter
  )
  omitted_defaults <- setdiff(defaulted_parameters, names(data))
  rules <- rules[!variable %in% omitted_defaults]

  # The matrix selects external parameters. Keep the module's own checks for
  # identifiers and values calculated by earlier pipeline steps.
  id_columns <- c(
    "herd_id", "species_short", "cohort_short",
    "feed_id", "feed_name", "manure_management_system"
  )
  external_parameters <- parameter_rules[
    requirement %in% c("R", "O") & input_table == input_table_filter, variable
  ]
  matrix_parameters <- setdiff(external_parameters, id_columns)
  structural_columns <- setdiff(required_cols, matrix_parameters)
  required_parameters <- setdiff(rules$variable, id_columns)
  required_columns <- unique(c(
    structural_columns, required_parameters, always_required
  ))
  check_required_columns(data, required_columns, arg_name)

  # NA is allowed only on rows where this parameter is not required. For feed
  # parameters, feed_id restricts the check to feeds used by the relevant species.
  for (parameter in required_parameters) {
    applicable_pairs <- unique(rules[
      variable == parameter, .(species_short, cohort_short)
    ])
    matching_context <- context[
      applicable_pairs, on = .(species_short, cohort_short), nomatch = 0
    ]
    common_columns <- intersect(names(data), names(matching_context))
    join_keys <- intersect(id_columns, common_columns)
    rows <- if (length(join_keys)) {
      requested_rows <- unique(matching_context[, join_keys, with = FALSE])
      if (nrow(requested_rows[!data, on = join_keys])) {
        cli::cli_abort("Missing required rows in {.arg {arg_name}} for {.var {parameter}} and the requested species/cohorts.")
      }
      unique(data[requested_rows, on = join_keys, which = TRUE, nomatch = 0])
    } else {
      seq_len(nrow(data))
    }
    if (anyNA(data[[parameter]][rows])) {
      cli::cli_abort("Required parameter {.var {parameter}} in {.arg {arg_name}} must not contain missing values for the requested species/cohorts.")
    }
  }
  range_context <- context
  if (!"species_short" %in% names(cohort_level_data) &&
      !"species_short" %in% names(herd_level_data)) {
    # Dependency lookup covers all species for species-independent APIs;
    # range checks must not treat those possible species as supplied context.
    range_context <- data.table::copy(context)
    range_context[, species_short := NA_character_]
  }
  check_contextual_parameter_ranges(data, range_context, function_filter)
  invisible(TRUE)
}

#' Apply additional range limits to input rows with known species/cohort context
#' @noRd
check_contextual_parameter_ranges <- function(data, context, function_filter = NULL) {
  if (!all(c("species_short", "cohort_short") %in% names(parameter_rules))) return(invisible(TRUE))
  range_rules <- get_parameter_range_rules()
  scoped <- range_rules[species_short != "ANY" | cohort_short != "ANY", variable]
  parameters <- intersect(names(data), scoped)
  if (length(parameters) == 0L && is.null(function_filter)) return(invisible(TRUE))
  pairs <- unique(context[, .(species_short, cohort_short)])
  keys <- intersect(c("herd_id", "species_short", "cohort_short", "feed_id", "manure_management_system"),
                    intersect(names(data), names(context)))
  for (i in seq_len(nrow(pairs))) {
    applicable <- context[pairs[i], on = .(species_short, cohort_short), nomatch = 0]
    rows <- if (length(keys)) {
      unique(data[unique(applicable[, keys, with = FALSE]), on = keys, which = TRUE, nomatch = 0])
    } else seq_len(nrow(data))
    for (parameter in parameters) {
      values <- data[[parameter]][rows]
      names(values) <- rows
      # Presence and required-value checks are handled separately.
      values <- values[!is.na(values)]
      if (length(values)) validate_param_range(
        values, parameter,
        species_filter = if (is.na(pairs$species_short[i])) NULL else pairs$species_short[i],
        cohort_filter = pairs$cohort_short[i]
      )
    }
    if (!is.null(function_filter)) validate_parameter_relations(
      as.list(data[rows]), function_filter,
      species_filter = if (is.na(pairs$species_short[i])) NULL else pairs$species_short[i],
      cohort_filter = pairs$cohort_short[i]
    )
  }
  invisible(TRUE)
}

#' Prepare input vectors once, allowing parameters unused by the requested cohorts
#'
#' Resolve herd rows in cohort order once, then reuse direct vector lookups in
#' calculations. Missing unused columns are represented by NA without changing
#' the input tables or adding columns to module outputs.
#' @noRd
get_optional_parameters <- function(data, parameters, rows = NULL) {
  row_indices <- if (is.null(rows)) {
    seq_len(nrow(data))
  } else {
    data[rows[, .(herd_id)], on = "herd_id", which = TRUE]
  }
  parameter_available <- parameters %in% names(data)
  values <- lapply(seq_along(parameters), function(i) {
    if (parameter_available[i]) {
      data[[parameters[i]]][row_indices]
    } else {
      rep(NA_real_, length(row_indices))
    }
  })
  stats::setNames(values, parameters)
}

#' Find required function inputs for a cohort and optional species
#'
#' Without a species filter, requirements must agree across supported species.
#' This preserves species-independent scalar calls without merging conflicting
#' species-specific requirements.
#' @noRd
get_required_function_parameters <- function(
    cohort_filter = NULL,
    function_filter,
    species_filter = NULL,
    input_table_filter = NULL,
    dependencies = parameter_rules,
    check_coverage = TRUE
) {
  if (!is.null(cohort_filter)) validate_cohort_code(cohort_filter)
  validate_scalar_character(function_filter)
  species_values <- gleam_species
  if (!is.null(species_filter)) {
    validate_animal_species(species_filter)
    species_values <- species_filter
  }
  if (!is.null(input_table_filter)) validate_scalar_character(input_table_filter)
  cache <- if (missing(dependencies)) getOption("gleam.validation_cache") else NULL
  cache_key <- paste(
    "function", function_filter, species_filter %||% "", cohort_filter %||% "",
    input_table_filter %||% "", check_coverage, sep = "|"
  )
  cached_parameters <- if (!is.null(cache)) cache[[cache_key]] else NULL
  if (!is.null(cached_parameters)) return(cached_parameters)
  check_data_table(dependencies, "parameter_rules")
  check_required_columns(
    dependencies,
    c("species_short", "cohort_short", "input_table", "requirement", "variable"),
    "parameter_rules"
  )
  dependencies <- dependencies[which(dependencies$requirement %in% c("R", "O"))]
  # The matrix can list several function names or wildcard patterns per row.
  # Also accept the normalized function column used by existing callers.
  function_column <- if ("function" %in% names(dependencies)) "function" else "evidence_function"
  check_required_columns(dependencies, function_column, "parameter_rules")
  evidence <- unique(dependencies[[function_column]])
  matching_evidence <- evidence[vapply(
    strsplit(evidence, "[;/]"),
    function(functions) {
      functions <- trimws(functions)
      if (function_filter %in% functions) return(TRUE)
      patterns <- functions[grepl("*", functions, fixed = TRUE)]
      any(vapply(patterns, function(pattern) {
        grepl(utils::glob2rx(pattern), function_filter)
      }, logical(1)))
    },
    logical(1)
  )]
  selected <- dependencies[[function_column]] %in% matching_evidence &
    dependencies$species_short %in% c("ANY", species_values)
  if (!is.null(cohort_filter)) {
    selected <- selected & dependencies$cohort_short %in% c("ANY", cohort_filter)
  }
  if (!is.null(input_table_filter)) {
    selected <- selected & dependencies$input_table == input_table_filter
  }
  rules <- dependencies[which(selected), .(species_short, cohort_short, variable, requirement)]
  if (check_coverage) {
    requested <- data.table::CJ(
      species_short = species_values,
      cohort_short = if (is.null(cohort_filter)) gleam_cohorts else cohort_filter
    )
    rules <- match_parameter_rule_context(rules, requested)
  }
  rules <- rules[which(rules$requirement == "R")]
  if (is.null(species_filter) && check_coverage) {
    required_by_species <- lapply(species_values, function(species) {
      sort(unique(rules$variable[rules$species_short == species]))
    })
    if (length(unique(required_by_species)) > 1L) {
      cli::cli_abort(
        "Required parameters differ by species for {.val {function_filter}}; supply {.arg species_filter}."
      )
    }
  }
  required <- unique(rules$variable)
  if (!is.null(cache)) cache[[cache_key]] <- required
  required
}

#' Validate matrix inputs used by a standalone calculation
#'
#' The evidence column groups functions and is not a complete function schema.
#' Select only formal arguments and retain the existing branch/range validators
#' for calculated inputs and code dependencies absent from the evidence column.
#' @noRd
validate_function_required_parameters <- function(
    function_filter, inputs, species_filter = NULL, cohort_filter = NULL
) {
  if (!validation_enabled()) return(invisible(NULL))
  # Some evidence is recorded against the module that calls the calculation.
  aliases <- c(
    calc_ration_digestibility = "run_ration_quality_module",
    calc_projected_population_size = "run_demographic_herd_module",
    calc_cohort_totals = "run_aggregation_module",
    calc_fibre_allocation_energy = "calc_meat_allocation_energy",
    calc_work_allocation_energy = "calc_meat_allocation_energy",
    calc_ch4_enteric = "enteric module"
  )
  evidence_filter <- if (grepl("^calc_(co2|n2o|ch4)_ration_", function_filter)) {
    "run_emissions_ration_module"
  } else if (function_filter %in% names(aliases)) {
    unname(aliases[function_filter])
  } else function_filter
  required <- get_required_function_parameters(
    cohort_filter = cohort_filter,
    function_filter = evidence_filter,
    species_filter = species_filter,
    check_coverage = FALSE
  )
  # Shared evidence cells also describe other calculations. These inputs are
  # only consumed by the following branches in the current code.
  if (function_filter == "calc_metabolic_energy_req_maintenance") {
    uses_offtake_rate <-
      (species_filter %in% c("CTL", "BFL") && cohort_filter %in% c("MA", "MS")) ||
      (species_filter == "SHP" && cohort_filter %in% gleam_cohorts_male)
    if (!uses_offtake_rate) {
      required <- setdiff(required, "offtake_rate")
    }
  }
  if (function_filter == "calc_metabolic_energy_req_pregnancy" && cohort_filter != "FS") {
    required <- setdiff(required, c("offtake_rate", "cohort_duration_days"))
  }
  if (function_filter == "calc_nitrogen_retention" &&
      !(species_filter == "PGS" && cohort_filter == "FS")) {
    required <- setdiff(required, "cohort_duration_days")
  }
  if (function_filter == "calc_feed_digestibility_fraction") {
    # This function returns both species' ratios; either energy may be absent.
    required <- setdiff(required, c("feed_digestible_energy_ruminant", "feed_digestible_energy_pigs"))
  }
  # A calculation passes its environment so only required arguments are read.
  # Table-based callers can pass a named list instead.
  inputs_are_environment <- is.environment(inputs)
  arguments <- if (inputs_are_environment) {
    names(formals(get(function_filter, mode = "function")))
  } else {
    names(inputs)
  }
  for (parameter in intersect(required, arguments)) {
    value <- if (inputs_are_environment) {
      get(parameter, envir = inputs, inherits = FALSE)
    } else {
      inputs[[parameter]]
    }
    if (length(value) == 0L || anyNA(value)) {
      cli::cli_abort("Missing required input {.arg {parameter}} for {.fn {function_filter}} and the requested species/cohort.")
    }
  }
  invisible(TRUE)
}
