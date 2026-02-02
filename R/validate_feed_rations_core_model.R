#' Validate inputs for calc_diet_digestibility
#'
#' @noRd
validate_diet_digestibility_inputs <- function(
    animal,
    ration,
    dig_ruminants,
    dig_pigs,
    dig_chickens
) {
  validate_scalar_character(animal, "animal")
  validate_scalar_numeric(ration, "ration")

  # Ensure all digestibility inputs are scalar numerics (NA allowed)
  args <- list(
    dig_ruminants = dig_ruminants,
    dig_pigs = dig_pigs,
    dig_chickens = dig_chickens
  )
  for (arg_name in names(args)) {
    val <- args[[arg_name]]
    if (!is.numeric(val) || length(val) != 1) {
      cli::cli_abort("{.arg {arg_name}} must be a single numeric (scalar). NA is allowed.")
    }
  }

  valid_animals <- c("CTL", "BFL", "CML", "SHP", "GTS", "CHK", "PGS")
  if (!animal %in% valid_animals) {
    cli::cli_abort(
      "Invalid animal value: {.val {animal}}. Must be one of: {.val {valid_animals}}"
    )
  }

  # Require the species-specific digestibility input to be present (non-NA)
  required_by_animal <- if (animal %in% c("CTL", "BFL", "CML", "SHP", "GTS")) {
    c("dig_ruminants")
  } else if (animal == "CHK") {
    c("dig_chickens")
  } else {
    c("dig_pigs")
  }

  missing_required <- required_by_animal[vapply(
    required_by_animal,
    function(arg_name) isTRUE(is.na(args[[arg_name]])),
    logical(1)
  )]

  if (length(missing_required) > 0) {
    cli::cli_abort(
      "Missing required digestibility inputs for animal {.val {animal}}: {.val {missing_required}}"
    )
  }
}

#' Validate inputs for calc_diet_metabolizable_energy
#'
#' @noRd
validate_diet_metabolizable_energy_inputs <- function(
    animal,
    ration,
    me_ruminants,
    me_pigs,
    me_chickens
) {
  validate_scalar_character(animal, "animal")
  validate_scalar_numeric(ration, "ration")
  # Ensure all metabolizable energy inputs are scalar numerics (NA allowed)
  args <- list(
    me_ruminants = me_ruminants,
    me_pigs = me_pigs,
    me_chickens = me_chickens
  )
  for (arg_name in names(args)) {
    val <- args[[arg_name]]
    if (!is.numeric(val) || length(val) != 1) {
      cli::cli_abort("{.arg {arg_name}} must be a single numeric (scalar). NA is allowed.")
    }
  }

  valid_animals <- c("CTL", "BFL", "CML", "SHP", "GTS", "CHK", "PGS")
  if (!animal %in% valid_animals) {
    cli::cli_abort(
      "Invalid animal value: {.val {animal}}. Must be one of: {.val {valid_animals}}"
    )
  }

  # Require the species-specific ME input to be present (non-NA)
  required_by_animal <- if (animal %in% c("CTL", "BFL", "CML", "SHP", "GTS")) {
    c("me_ruminants")
  } else if (animal == "CHK") {
    c("me_chickens")
  } else {
    c("me_pigs")
  }

  missing_required <- required_by_animal[vapply(
    required_by_animal,
    function(arg_name) isTRUE(is.na(args[[arg_name]])),
    logical(1)
  )]

  if (length(missing_required) > 0) {
    cli::cli_abort(
      "Missing required metabolizable energy inputs for animal {.val {animal}}: {.val {missing_required}}"
    )
  }
}

#' Validate inputs for calc_energy_digestibility_ratio
#'
#' @noRd
validate_energy_digestibility_inputs <- function(
    energy_digestible,
    energy_gross
) {
  # Scalar numeric checks (no NA)
  validate_scalar_numeric(energy_digestible, "energy_digestible")
  validate_scalar_numeric(energy_gross, "energy_gross")
}

#' Validate inputs for calc_diet_gross_energy
#'
#' @noRd
validate_diet_gross_energy_inputs <- function(ration, ge) {
  # Ration and GE must be numeric scalars
  validate_scalar_numeric(ration, "ration")
  validate_scalar_numeric(ge, "ge")
}

#' Validate inputs for calc_diet_nitrogen_content
#'
#' @noRd
validate_diet_nitrogen_inputs <- function(ration, n_content) {
  # Ration and nitrogen content must be numeric scalars
  validate_scalar_numeric(ration, "ration")
  validate_scalar_numeric(n_content, "n_content")
}
