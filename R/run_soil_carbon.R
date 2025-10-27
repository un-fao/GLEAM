#' Run Soil Carbon Stock Change Calculation (Internal)
#'
#' Executes the soil organic carbon (SOC) stock change pipeline.
#' Applies the core soil carbon model row-by-row to an input dataset using
#' parameter tables for management factors, soil type references, and land-use change factors.
#'
#' @param data Data.table. Input dataset containing columns:
#'   `area`, `climate_zone`, `soil_carbon_reference` (optional), `soil_type`,
#'   `management_start`, `management_end`.
#' @param management_params Data.table. Management factors by climate zone
#'   and management type. Must have columns: `climate_zone`, `management_type`, `V1`.
#' @param soil_type_params Data.table. SOC reference values by climate zone
#'   and soil type. Must have columns: `climate_zone`, `soil_type`, `V1`.
#' @param luc_factors Data.table. Land-use change factors by climate zone.
#'   Must have columns: `climate_zone`, `V1`.
#'
#' @return Data.table. The input data with three new columns:
#'   \describe{
#'     \item{SOC1}{SOC stock at start (t C total).}
#'     \item{SOC2}{SOC stock at end (t C total).}
#'     \item{dSOC}{Annual SOC change (t C/year total).}
#'   }
#'
#' @examples
#' \dontrun{
#' input <- data.table::fread(
#'   system.file("extdata/soc_input_data.csv", package = "gleam")
#' )
#' data_out <- run_soil_carbon(
#'   data = input,
#'   management_params = data.table::fread(system.file(
#'     "extdata/SoilCarbon_parameters/soc_factor_management.csv",
#'     package = "gleam")),
#'   soil_type_params = data.table::fread(system.file(
#'     "extdata/SoilCarbon_parameters/soc_socref_soiltype.csv",
#'     package = "gleam")),
#'   luc_factors = data.table::fread(system.file(
#'     "extdata/SoilCarbon_parameters/soc_luc_factor.csv",
#'     package = "gleam"))
#' )
#' }
#'
#' @keywords internal
#'
#' @export
run_soil_carbon <- function(
    data,
    management_params,
    soil_type_params,
    luc_factors
) {
  # Validate input structure
  if (!data.table::is.data.table(data)) {
    cli::cli_abort("{.arg data} must be a data.table.")
  }

  # Check for required columns (soil_carbon_reference is optional)
  required <- c(
    "area", "climate_zone", "soil_type",
    "management_start", "management_end"
  )
  missing_cols <- setdiff(required, names(data))
  if (length(missing_cols) > 0) {
    cli::cli_abort("Missing required columns: {missing_cols}.")
  }

  # Apply core function row-by-row
  data[, c("SOC1", "SOC2", "dSOC") := calc_soil_carbon(
    area = area,
    climate_zone = climate_zone,
    soil_carbon_reference = if ("soil_carbon_reference" %in% names(data)) soil_carbon_reference else NA_real_,
    soil_type = soil_type,
    management_start = management_start,
    management_end = management_end,
    management_params = management_params,
    soil_type_params = soil_type_params,
    luc_factors = luc_factors
  ), by = .I]

  return(data)
}
