#' Validate Inputs for Soil Carbon Model
#'
#' Ensures that all required inputs for the soil organic carbon (SOC)
#' calculation are correctly specified and consistent in type and length.
#'
#' @param area Numeric. Land area (ha).
#' @param climate_zone Character. Climate zone code.
#' @param soil_carbon_reference Numeric. Reference SOC value (t C/ha, optional).
#' @param soil_type Character. Soil type code.
#' @param management_start Character. Starting management type.
#' @param management_end Character. Ending management type.
#' @param management_params Data.table. Management factors by climate zone and
#'   management type.
#' @param soil_type_params Data.table. SOC reference values by climate zone and
#'   soil type.
#' @param luc_factors Data.table. Land-use change factors by climate zone.
#'
#' @noRd
validate_soilcarbon_inputs <- function(
    area,
    climate_zone,
    soil_carbon_reference,
    soil_type,
    management_start,
    management_end,
    management_params,
    soil_type_params,
    luc_factors
) {
  validate_scalar_numeric(area, "area")
  validate_scalar_character(climate_zone, "climate_zone")
  validate_scalar_character(soil_type, "soil_type")
  validate_scalar_character(management_start, "management_start")
  validate_scalar_character(management_end, "management_end")

  # Optional numeric SOC reference
  if (!is.na(soil_carbon_reference)) {
    validate_scalar_numeric(soil_carbon_reference, "soil_carbon_reference")
  }

  # Data.table structure checks
  if (!data.table::is.data.table(management_params)) {
    cli::cli_abort("{.arg management_params} must be a data.table.")
  }
  if (!data.table::is.data.table(soil_type_params)) {
    cli::cli_abort("{.arg soil_type_params} must be a data.table.")
  }
  if (!data.table::is.data.table(luc_factors)) {
    cli::cli_abort("{.arg luc_factors} must be a data.table.")
  }

  # Required column presence
  required_cols_mgmt <- c("climate_zone", "management_type", "V1")
  required_cols_soil <- c("climate_zone", "soil_type", "V1")
  required_cols_luc  <- c("climate_zone", "V1")

  if (!all(required_cols_mgmt %in% names(management_params))) {
    cli::cli_abort(
      "Missing columns in {.arg management_params}:
      {setdiff(required_cols_mgmt, names(management_params))}."
    )
  }
  if (!all(required_cols_soil %in% names(soil_type_params))) {
    cli::cli_abort(
      "Missing columns in {.arg soil_type_params}:
      {setdiff(required_cols_soil, names(soil_type_params))}."
    )
  }
  if (!all(required_cols_luc %in% names(luc_factors))) {
    cli::cli_abort(
      "Missing columns in {.arg luc_factors}:
      {setdiff(required_cols_luc, names(luc_factors))}."
    )
  }
}
