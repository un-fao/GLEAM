#' Calculate Totals by Cohort
#'
#' Calculates the total value for each variable at the cohort level over the
#' entire assessment duration. This function harmonizes values to a common
#' unit (kg/cohort/assessment duration) by accounting for cohort size and
#' assessment duration.
#'
#' Production variables are already expressed at the cohort level for the
#' entire assessment duration, so they are returned as-is. All other variables
#' (emissions, feed, nitrogen balance) are expressed per head per day and need
#' to be scaled by cohort size and assessment duration.
#'
#' @param value Numeric vector. Variable value expressed in:
#'   - kg (unit)/head/day for non-production variables
#'   - kg/cohort/assessment duration for production variables
#' @param cohort_stock_size Numeric. Population size in each of the 6 sex–age cohorts at the
#'  start of the year (# heads). (cohorts = FJ, FS, FA, MJ, MS, MA)
#' @param simulation_duration Numeric. Length of the assessment period (days)
#' @param variable_type Character vector. Variable group classification:
#'   - `"Production"`: Production outputs (already at cohort level)
#'   - `"Emissions"`, `"Feed"`, `"NitrogenBalance"`: Per-head-per-day values
#'
#' @return Numeric vector. Value harmonized at cohort and assessment duration
#'   level (kg/cohort/assessment duration).
#'
#' @export
calc_cohort_totals <- function(
    value,
    cohort_stock_size,
    simulation_duration,
    variable_type
) {
  validate_totals_by_cohort_inputs(
    value, cohort_stock_size, simulation_duration, variable_type
  )

  # Production variables are already at cohort level for entire assessment
  # Use ifelse to handle both scalar and vector inputs
  value_total <- ifelse(
    variable_type == "Production",
    value,
    value * cohort_stock_size * simulation_duration
  )

  return(value_total)
}


#' Calculate Allocated Emissions
#'
#' Applies allocation shares to total emissions to compute emissions
#' attributable to a specific commodity (e.g., meat, milk, fibre).
#'
#' This function multiplies total herd-level emissions by the corresponding
#' allocation share to estimate the share of emissions allocated to a
#' specific output. Allocation shares are typically derived from biophysical
#' allocation based on energy requirements (see [run_allocation_module()]).
#'
#' @param value Numeric vector. Total emissions at herd-level by source
#'   (kg gas).
#' @param allocation_share Numeric vector. Fraction of emissions to allocate
#'   to different commodities (between 0 and 1). Must be the same length
#'   as `value`.
#'
#' @return Numeric vector. Allocated emissions (kg gas) for each
#'   commodity-emission combination.
#'
#' @export
calc_allocated_emissions <- function(
    value,
    allocation_share
) {
  validate_allocated_emissions_inputs(value, allocation_share)

  value_allocated <- value * allocation_share
  return(value_allocated)
}


#' Convert CH4 and N2O Emissions to CO2-Equivalents Using GWP Factors
#'
#' Computes CO2-equivalent (CO2e) emissions for CH4 and N2O based on different
#' 100-year Global Warming Potentials (GWP) reported in IPCC assessment reports.
#' The function is vectorized and returns both the CO2e values and the GWP factor
#' applied for each observation.
#'
#' GWP factors convert emissions of different greenhouse gases to a common
#' CO2-equivalent basis, allowing for comparison and aggregation of emissions
#' from different sources. The function supports multiple IPCC assessment
#' report versions to maintain consistency with different reporting standards.
#'
#' @param gas Character vector. Gas type for each observation. Supported values:
#'   - `"CH4"`: Methane
#'   - `"N2O"`: Nitrous oxide
#'   - `"CO2"`: Carbon dioxide (GWP = 1)
#' @param value_allocated Numeric vector. Emission values expressed in kg of gas
#'   (e.g., kg CH4, kg N2O, or kg CO2). Must be the same length as `gas`.
#' @param global_warming_potential_set Character scalar specifying the 100-year Global Warming Potential
#'   (GWP-100) conversion factors used to express CH₄ and N₂O emissions as CO₂-equivalents.
#'   Must be one of:
#'   \itemize{
#'     \item \code{"AR6"} (default): IPCC Sixth Assessment Report — CH₄ = 27, N₂O = 273
#'     \item \code{"AR5_excluding_carbon_feedback"}: IPCC Fifth Assessment Report
#'       (excluding climate–carbon feedbacks) — CH₄ = 28, N₂O = 265
#'     \item \code{"AR5_including_carbon_feedback"}: IPCC Fifth Assessment Report
#'       (including climate–carbon feedbacks) — CH₄ = 34, N₂O = 298
#'     \item \code{"AR4"}: IPCC Fourth Assessment Report — CH₄ = 25, N₂O = 298
#'   }
#'
#' @return A named list with two numeric vectors of the same length as input:
#' \describe{
#'   \item{`value_co2eq`}{CO2-equivalent emissions (kg CO2e).}
#'   \item{`gwp`}{Global Warming Potential factor applied to each observation
#'     (kg CO2e/kg gas).}
#' }
#'
#' @export
calc_co2eq <- function(
    gas,
    value_allocated,
    global_warming_potential_set
) {
  validate_co2eq_inputs(gas, value_allocated, global_warming_potential_set)

  # Define GWP factors for each IPCC assessment report
  # Note: Validation ensures gwp is valid, so switch will always match
  gwp_factors <- switch(
    global_warming_potential_set,
    AR6 = c(CH4 = 27, N2O = 273, CO2 = 1),
    AR5_excluding_carbon_feedback = c(CH4 = 28, N2O = 265, CO2 = 1),
    AR5_including_carbon_feedback = c(CH4 = 34, N2O = 298, CO2 = 1),
    AR4 = c(CH4 = 25, N2O = 298, CO2 = 1)
  )

  # Extract GWP factor for each gas type
  gwp <- unname(gwp_factors[gas])

  # Calculate CO2-equivalent emissions
  value_co2eq <- value_allocated * gwp

  return(
    list(
      value_co2eq = value_co2eq,
      gwp = gwp
    )
  )
}
