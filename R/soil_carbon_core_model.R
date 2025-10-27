#' Calculate Soil Organic Carbon Stock Change
#'
#' Computes the change in soil organic carbon (SOC) stock between two management states over a 20-year period.
#' This is a Tier 1 stock-change equation with a fixed 20-year transition period.
#'
#' @param area Numeric. Land area (ha).
#' @param climate_zone Character. IPCC climate zone code (e.g., "TropicalMoist", "WarmTemperateDry").
#' @param soil_carbon_reference Numeric. Reference SOC value (t C/ha, optional). If missing, will be looked up from `soil_type_params`.
#' @param soil_type Character. IPCC soil type code (e.g., "HighActivityClay", "LowActivityClay", "Sandy", "Spodic"). Required if `soil_carbon_reference` is missing.
#' @param management_start Character. Starting management type (e.g., "ImprovedMediumInput", "SeverelyDegraded").
#' @param management_end Character. Ending management type (e.g., "NonDegraded", "HighIntensityGrazing").
#' @param management_params Data.table. Stock change factors for management regime (dimensionless). Must have columns: `climate_zone`, `management_type`, `V1`.
#' @param soil_type_params Data.table. Reference SOC values by climate zone and soil type (t C/ha). Must have columns: `climate_zone`, `soil_type`, `V1`.
#' @param luc_factors Data.table. Stock change factors for land use or land-use change type (dimensionless). Must have columns: `climate_zone`, `V1`.
#'
#' @return List. Contains:
#' \describe{
#'   \item{SOC1}{Soil organic carbon stock at the beginning of the period (t C total).}
#'   \item{SOC2}{Soil organic carbon stock at the end of the period (t C total).}
#'   \item{dSOC}{Annual change in soil carbon stock over 20 years (t C/year total).}
#' }
#'
#' @details
#' The core calculation is:
#' \deqn{SOC1 = area \times socRef \times mgmtFactor_{start} \times lucFactor}
#' \deqn{SOC2 = area \times socRef \times mgmtFactor_{end} \times lucFactor}
#' \deqn{dSOC = (SOC2 - SOC1) / 20}
#'
#' @export
calc_soil_carbon <- function(
    area,
    climate_zone,
    soil_carbon_reference = NA_real_,
    soil_type,
    management_start,
    management_end,
    management_params,
    soil_type_params,
    luc_factors
) {

  # Validate inputs
  validate_soilcarbon_inputs(
    area, climate_zone, soil_carbon_reference, soil_type,
    management_start, management_end,
    management_params, soil_type_params, luc_factors
  )

  # Use provided soil_carbon_reference, or fallback to lookup from soil_type_params
  if (is.na(soil_carbon_reference)) {
    cz <- climate_zone
    st <- soil_type

    socRef <- soil_type_params[
      climate_zone == cz & soil_type == st,
      V1
    ]

    if (length(socRef) == 0 || anyNA(socRef)) {
      cli::cli_abort(
        "No SOCref found for climate zone {.val {climate_zone}} and soil type {.val {soil_type}}."
      )
    }

    # Extract scalar value
    if (length(socRef) > 1) {
      cli::cli_warn("Multiple SOC references found; using the first one.")
      socRef <- socRef[1]
    }
  } else {
    socRef <- soil_carbon_reference
  }

  # Lookup management factors
  cz <- climate_zone
  mgmt1 <- management_start
  mgmt2 <- management_end

  mgmtFactor1 <- management_params[
    climate_zone == cz & management_type == mgmt1,
    V1
  ]
  mgmtFactor2 <- management_params[
    climate_zone == cz & management_type == mgmt2,
    V1
  ]

  if (length(mgmtFactor1) == 0 || anyNA(mgmtFactor1)) {
    cli::cli_abort("No management factor found for starting management.")
  }
  if (length(mgmtFactor1) > 1) {
    cli::cli_warn("Multiple management factors found for start; using the first one.")
    mgmtFactor1 <- mgmtFactor1[1]
  }

  if (length(mgmtFactor2) == 0 || anyNA(mgmtFactor2)) {
    cli::cli_abort("No management factor found for ending management.")
  }
  if (length(mgmtFactor2) > 1) {
    cli::cli_warn("Multiple management factors found for end; using the first one.")
    mgmtFactor2 <- mgmtFactor2[1]
  }

  # Lookup land-use change factors (same for both start and end)
  luFactor <- luc_factors[climate_zone == cz, V1]

  if (length(luFactor) == 0 || anyNA(luFactor)) {
    cli::cli_abort("No land-use change factor found for climate zone {.val {climate_zone}}.")
  }
  if (length(luFactor) > 1) {
    cli::cli_warn("Multiple land-use change factors found; using the first one.")
    luFactor <- luFactor[1]
  }

  # Core calculations
  SOC1 <- area * socRef * mgmtFactor1 * luFactor
  SOC2 <- area * socRef * mgmtFactor2 * luFactor
  dSOC <- (SOC2 - SOC1) / 20

  # Return results
  return(list(
    SOC1 = as.numeric(SOC1),
    SOC2 = as.numeric(SOC2),
    dSOC = as.numeric(dSOC)
  ))
}
