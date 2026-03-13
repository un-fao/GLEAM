#' Validate inputs for calc_diet_digestibility
#'
#' @noRd
validate_diet_digestibility_inputs <- function(
    species_short,
    feed_ration_fraction,
    feed_digestibility_fraction_ruminant,
    feed_digestibility_fraction_pigs,
    feed_digestibility_fraction_chicken
) {
  validate_scalar_character(species_short)
  validate_scalar_numeric(feed_ration_fraction)
  validate_param_range(feed_ration_fraction)

  # Ensure all digestibility inputs are scalar numerics (NA allowed)
  args <- list(
    feed_digestibility_fraction_ruminant = feed_digestibility_fraction_ruminant,
    feed_digestibility_fraction_pigs = feed_digestibility_fraction_pigs,
    feed_digestibility_fraction_chicken = feed_digestibility_fraction_chicken
  )
  for (arg_name in names(args)) {
    val <- args[[arg_name]]
    if (!is.numeric(val) || length(val) != 1) {
      cli::cli_abort("{.arg {arg_name}} must be a single numeric (scalar). NA is allowed.")
    }
    if (!is.na(val)) {
      # Enforce configured bounds
      validate_param_range(val, arg_name = arg_name)
    }
  }

  valid_animals <- c("CTL", "BFL", "CML", "SHP", "GTS", "CHK", "PGS")
  if (!species_short %in% valid_animals) {
    cli::cli_abort(
      "Invalid species_short value: {.val {species_short}}. Must be one of: {.val {valid_animals}}"
    )
  }

  # Require the species-specific digestibility input to be present (non-NA)
  required_by_animal <- if (species_short %in% c("CTL", "BFL", "CML", "SHP", "GTS")) {
    c("feed_digestibility_fraction_ruminant")
  } else if (species_short == "CHK") {
    c("feed_digestibility_fraction_chicken")
  } else {
    c("feed_digestibility_fraction_pigs")
  }

  missing_required <- required_by_animal[vapply(
    required_by_animal,
    function(arg_name) is.na(args[[arg_name]]),
    logical(1)
  )]

  if (length(missing_required) > 0) {
    cli::cli_abort(
      "Missing required digestibility inputs for species_short {.val {species_short}}: {.val {missing_required}}"
    )
  }
}

#' Validate inputs for calc_diet_metabolizable_energy
#'
#' @noRd
validate_diet_metabolizable_energy_inputs <- function(
    species_short,
    feed_ration_fraction,
    feed_metabolizable_energy_ruminant,
    feed_metabolizable_energy_pigs,
    feed_metabolizable_energy_chicken
) {
  validate_scalar_character(species_short)
  validate_scalar_numeric(feed_ration_fraction)
  validate_param_range(feed_ration_fraction)
  # Ensure all metabolizable energy inputs are scalar numerics (NA allowed)
  args <- list(
    feed_metabolizable_energy_ruminant = feed_metabolizable_energy_ruminant,
    feed_metabolizable_energy_pigs = feed_metabolizable_energy_pigs,
    feed_metabolizable_energy_chicken = feed_metabolizable_energy_chicken
  )
  for (arg_name in names(args)) {
    val <- args[[arg_name]]
    if (!is.numeric(val) || length(val) != 1) {
      cli::cli_abort("{.arg {arg_name}} must be a single numeric (scalar). NA is allowed.")
    }
    if (!is.na(val)) {
      # Enforce configured bounds
      validate_param_range(val, arg_name = arg_name)
    }
  }

  valid_animals <- c("CTL", "BFL", "CML", "SHP", "GTS", "CHK", "PGS")
  if (!species_short %in% valid_animals) {
    cli::cli_abort(
      "Invalid species_short value: {.val {species_short}}. Must be one of: {.val {valid_animals}}"
    )
  }

  # Require the species-specific ME input to be present (non-NA)
  required_by_animal <- if (species_short %in% c("CTL", "BFL", "CML", "SHP", "GTS")) {
    c("feed_metabolizable_energy_ruminant")
  } else if (species_short == "CHK") {
    c("feed_metabolizable_energy_chicken")
  } else {
    c("feed_metabolizable_energy_pigs")
  }

  missing_required <- required_by_animal[vapply(
    required_by_animal,
    function(arg_name) is.na(args[[arg_name]]),
    logical(1)
  )]

  if (length(missing_required) > 0) {
    cli::cli_abort(
      "Missing required metabolizable energy inputs for species_short {.val {species_short}}: {.val {missing_required}}"
    )
  }
}

#' Validate inputs for calc_feed_digestibility_fraction
#'
#' @noRd
validate_feed_digestibility_inputs <- function(
    feed_digestible_energy_ruminant,
    feed_digestible_energy_pigs,
    feed_metabolizable_energy_chicken,
    feed_gross_energy
) {
  args <- list(
    feed_digestible_energy_ruminant = feed_digestible_energy_ruminant,
    feed_digestible_energy_pigs = feed_digestible_energy_pigs,
    feed_metabolizable_energy_chicken = feed_metabolizable_energy_chicken,
    feed_gross_energy = feed_gross_energy
  )
  for (arg_name in names(args)) {
    val <- args[[arg_name]]
    if (!is.numeric(val)) {
      cli::cli_abort("{.arg {arg_name}} must be numeric.")
    }
  }
  if (anyNA(feed_gross_energy)) {
    cli::cli_abort("{.arg feed_gross_energy} must not contain missing values.")
  }

  # Enforce configured bounds
  validate_param_range(feed_gross_energy)
}

#' Validate inputs for calc_diet_gross_energy
#'
#' @noRd
validate_diet_gross_energy_inputs <- function(feed_ration_fraction, feed_gross_energy) {
  # Ration and GE must be numeric scalars
  validate_scalar_numeric(feed_ration_fraction)
  validate_scalar_numeric(feed_gross_energy)

  # Enforce configured bounds
  validate_param_range(feed_ration_fraction)
  validate_param_range(feed_gross_energy)
}

#' Validate inputs for calc_diet_nitrogen_content
#'
#' @noRd
validate_diet_nitrogen_inputs <- function(feed_ration_fraction, feed_nitrogen_content) {
  # Ration and nitrogen content must be numeric scalars
  validate_scalar_numeric(feed_ration_fraction)
  validate_scalar_numeric(feed_nitrogen_content)

  # Enforce configured bounds
  validate_param_range(feed_ration_fraction)
  validate_param_range(feed_nitrogen_content)
}

#' Validate inputs for calc_urinary_energy_fraction
#'
#' @noRd
validate_urinary_energy_inputs <- function(
    species_short,
    feed_ration_fraction,
    feed_urinary_energy_ruminant,
    feed_urinary_energy_pigs,
    feed_urinary_energy_chicken
) {
  validate_scalar_character(species_short)
  validate_scalar_numeric(feed_ration_fraction)
  validate_param_range(feed_ration_fraction)

  args <- list(
    feed_urinary_energy_ruminant = feed_urinary_energy_ruminant,
    feed_urinary_energy_pigs = feed_urinary_energy_pigs,
    feed_urinary_energy_chicken = feed_urinary_energy_chicken
  )
  for (arg_name in names(args)) {
    val <- args[[arg_name]]
    if (!is.numeric(val) || length(val) != 1) {
      cli::cli_abort("{.arg {arg_name}} must be a single numeric (scalar). NA is allowed.")
    }
    if (!is.na(val)) {
      validate_param_range(val, arg_name = arg_name)
    }
  }

  valid_animals <- c("CTL", "BFL", "CML", "SHP", "GTS", "CHK", "PGS")
  if (!species_short %in% valid_animals) {
    cli::cli_abort(
      "Invalid species_short value: {.val {species_short}}. Must be one of: {.val {valid_animals}}"
    )
  }

  required_by_animal <- if (species_short %in% c("CTL", "BFL", "CML", "SHP", "GTS")) {
    c("feed_urinary_energy_ruminant")
  } else if (species_short == "CHK") {
    c("feed_urinary_energy_chicken")
  } else {
    c("feed_urinary_energy_pigs")
  }

  missing_required <- required_by_animal[vapply(
    required_by_animal,
    function(arg_name) is.na(args[[arg_name]]),
    logical(1)
  )]

  if (length(missing_required) > 0) {
    cli::cli_abort(
      "Missing required urinary energy inputs for species_short {.val {species_short}}: {.val {missing_required}}"
    )
  }
}

#' Validate inputs for calc_diet_ash
#'
#' @noRd
validate_diet_ash_inputs <- function(feed_ration_fraction, feed_ash_content) {
  validate_scalar_numeric(feed_ration_fraction)
  validate_scalar_numeric(feed_ash_content)

  validate_param_range(feed_ration_fraction)
  validate_param_range(feed_ash_content)
}
