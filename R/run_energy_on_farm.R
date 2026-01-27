#' Energy On-Farm Pipeline (Internal)
#'
#' Computes on-farm energy emissions by merging herd-level consumption data with country-specific emission factors.
#' Returns structured output suitable for downstream emission accounting workflows.
#'
#' @param energy_inputs Herd-level input table provided as data.frame or data.table.
#' @param emission_factors Emission factor lookup table provided as data.frame or data.table.
#' @param reference_year Character or integer reference year for emission factors (default: "2019").
#' @param energy_source Character string specifying energy source: "Electricity only" or "Electricity and heat".
#'
#' @return A `data.table` with columns:
#'   ADM0_CODE, Animal, Animal_short, LPS, LPS_short, HerdType, HerdType_short,
#'   VarName, GWP (if present), Item, onfarm_emissions, Unit, V1.
#'
#' @examples
#' \dontrun{
#' # Load example input from the package and run the energy on-farm calculation
#' energy_inputs_path <- system.file("extdata/GLEAM_input_herd.csv", package = "gleam")
#' emission_factors_path <- system.file(
#'   "extdata/Electricity_parameters/IEA_ElectricityGrid.csv",
#'   package = "gleam"
#' )
#' energy_inputs <- data.table::fread(energy_inputs_path)
#' emission_factors <- data.table::fread(emission_factors_path)
#' result <- run_energy_on_farm(
#'   energy_inputs = energy_inputs,
#'   emission_factors = emission_factors,
#'   reference_year = "2019",
#'   energy_source = "Electricity only"
#' )
#' head(result[, .(ADM0_CODE, Animal_short, VarName, Item, onfarm_emissions)])
#' }
#'
#' @keywords internal
#'
#' @importFrom data.table := .I
run_energy_on_farm <- function(
    energy_inputs,
    emission_factors,
    reference_year = "2019",
    energy_source = "Electricity only"
) {
  # --- Input validation
  # Validate that inputs are data.frames (or data.tables) with at least one row
  if (!inherits(energy_inputs, "data.frame") || nrow(energy_inputs) == 0) {
    cli::cli_abort("Input must be a non-empty data.frame or data.table.")
  }
  if (!inherits(emission_factors, "data.frame") || nrow(emission_factors) == 0) {
    cli::cli_abort(
      "{.arg emission_factors} must be a non-empty data.frame or data.table."
    )
  }

  # Validate required columns for energy inputs (herd-level consumption data)
  required_energy_columns <- c(
    "ADM0_CODE",
    "Animal",
    "Animal_short",
    "LPS",
    "LPS_short",
    "HerdType",
    "HerdType_short",
    "energy_onfarm"
  )

  # Validate required columns for emission factors (country-level lookup table)
  required_emission_factor_columns <- c(
    "ADM0_CODE",
    "RefYear",
    "VarName",
    "Item",
    "V1"
  )

  miss_energy <- setdiff(required_energy_columns, names(energy_inputs))
  if (length(miss_energy)) {
    cli::cli_abort(
      c(
        "Missing required columns in {.arg energy_inputs}:" = paste(miss_energy, collapse = ", ")
      )
    )
  }

  miss_emission <- setdiff(required_emission_factor_columns, names(emission_factors))
  if (length(miss_emission)) {
    cli::cli_abort(
      c(
        "Missing required columns in {.arg emission_factors}:" = paste(miss_emission, collapse = ", ")
      )
    )
  }

  # --- Data type preparation
  # Ensure ADM0_CODE is integer for proper joining (required for merge operations)
  energy_inputs[, ADM0_CODE := as.integer(ADM0_CODE)]

  # --- Energy source mapping
  # Map user-friendly energy source names to internal VarName values used in emission factors
  energy_source_varname <- switch(
    energy_source,
    "Electricity only" = "Electricity",
    "Electricity and heat" = "ElectricityHeat"
  )
  if (is.null(energy_source_varname)) {
    cli::cli_abort(
      "Unknown {.arg energy_source}: '{energy_source}'. Use 'Electricity only' or 'Electricity and heat'."
    )
  }

  # --- Reference year selection
  # Find available years for the selected energy source, sorted for easy comparison
  available_years <- sort(
    unique(
      emission_factors[VarName == energy_source_varname & !is.na(RefYear), RefYear]
    )
  )
  if (length(available_years) == 0) {
    cli::cli_abort("No emission factors found for VarName = '{energy_source_varname}'.")
  }

  # Select the reference year: use exact match if available, otherwise use closest available year
  if (reference_year %in% available_years) {
    selected_year <- reference_year
  } else {
    selected_year <- available_years[which.min(abs(available_years - reference_year))]
    cli::cli_warn(
      "No emissions factor available for reference year {reference_year}. Using {selected_year} instead."
    )
  }

  # Filter emission factors to the selected year and energy source type
  emission_factor_subset <- emission_factors[
    RefYear == selected_year & VarName == energy_source_varname
  ]

  # --- Data preparation for merge
  # Select relevant columns from energy inputs for merging
  energy_select_cols <- c(
    "ADM0_CODE",
    "Animal",
    "Animal_short",
    "LPS",
    "LPS_short",
    "HerdType",
    "HerdType_short",
    "energy_onfarm"
  )

  # Select emission factor columns for merging (GWP is optional and included if present)
  emission_factor_merge_cols <- c("ADM0_CODE", "VarName", "Item", "V1")
  if ("GWP" %in% names(emission_factor_subset)) {
    emission_factor_merge_cols <- c("ADM0_CODE", "VarName", "GWP", "Item", "V1")
  }

  # --- Merge energy inputs with emission factors
  # Join by ADM0_CODE to match country-level emission factors with herd-level energy consumption
  # allow.cartesian = TRUE allows one-to-many joins (one country can have multiple emission factor items)
  merged_dt <- merge(
    energy_inputs[, ..energy_select_cols],
    emission_factor_subset[, ..emission_factor_merge_cols],
    by = "ADM0_CODE",
    allow.cartesian = TRUE
  )

  # --- Calculate on-farm emissions
  # Apply core calculation: emissions = energy_onfarm * emission_factor / 1000
  # This converts energy consumption (MJ) to emissions (kg CO2-eq) using country-specific factors
  # Processed row by row for consistency with other modules
  merged_dt[, onfarm_emissions := calc_on_farm_emissions(
    energy_onfarm = energy_onfarm,
    emission_factor = V1
  ), by = .I]

  # Generate unit labels such as "kgCO2", "kgCH4", or "kgN2O" based on the Item column
  merged_dt[, Unit := ifelse(grepl("^kg", Item), Item, paste0("kg", Item))]

  # --- Prepare output columns
  # Select and order output columns in a consistent format
  output_cols <- c(
    "ADM0_CODE",
    "Animal",
    "Animal_short",
    "LPS",
    "LPS_short",
    "HerdType",
    "HerdType_short",
    "VarName"
  )
  # Include GWP if present (some emission factor tables include this metadata)
  if ("GWP" %in% names(merged_dt)) {
    output_cols <- c(output_cols, "GWP")
  }
  # Append calculation results and metadata columns
  output_cols <- c(output_cols, "Item", "onfarm_emissions", "Unit", "V1")

  return(merged_dt[, ..output_cols])
}
