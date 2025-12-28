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
#' @param size Numeric vector. Number of heads in the specific cohort.
#' @param assessment_duration Numeric vector. Duration of the assessment (days).
#' @param variable_type Character vector. Variable group classification:
#'   - `"Production"`: Production outputs (already at cohort level)
#'   - `"Emissions"`, `"Feed"`, `"NitrogenBalance"`: Per-head-per-day values
#'
#' @return Numeric vector. Value harmonized at cohort and assessment duration
#'   level (kg/cohort/assessment duration).
#'
#' @export
calc_totals_by_cohort <- function(
    value,
    size,
    assessment_duration,
    variable_type
) {
  # Production variables are already at cohort level for entire assessment
  if (variable_type == "Production") {
    value_total <- value
  } else {
    # Scale per-head-per-day values by cohort size and assessment duration
    value_total <- value * size * assessment_duration
  }

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
#' allocation based on energy requirements (see [run_allocation()]).
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
#' @param gwp Character scalar. IPCC assessment report version to use for
#'   100-year Global Warming Potential factors. Default is `"AR6"`.
#'   Supported options:
#'   \describe{
#'     \item{`"AR6"`}{CH4 = 27, N2O = 273, CO2 = 1. Source: IPCC 2021 -
#'       Chapter 7 - Table 7.15.}
#'     \item{`"AR5_excluding_carbon_feedback"`}{CH4 = 28, N2O = 265, CO2 = 1.
#'       Source: IPCC 2013 - Chapter 8 - Table 8.A.1, excluding carbon feedback.}
#'     \item{`"AR5_including_carbon_feedback"`}{CH4 = 34, N2O = 298, CO2 = 1.
#'       Source: IPCC 2013 - Chapter 8 - Table 8.7, including carbon feedback.}
#'     \item{`"AR4"`}{CH4 = 25, N2O = 298, CO2 = 1. Source: IPCC 2007 -
#'       Chapter TS.2 - Table 2.14.}
#'   }
#'
#' @return A named list with two numeric vectors of the same length as input:
#' \describe{
#'   \item{`value_co2e`}{CO2-equivalent emissions (kg CO2e).}
#'   \item{`gwp`}{Global Warming Potential factor applied to each observation
#'     (kg CO2e/kg gas).}
#' }
#'
#' @export
calc_co2eq <- function(
    gas,
    value_allocated,
    gwp
) {
  # Define GWP factors for each IPCC assessment report
  gwp_factors <- switch(
    gwp,
    AR6 = c(CH4 = 27, N2O = 273, CO2 = 1),
    AR5_excluding_carbon_feedback = c(CH4 = 28, N2O = 265, CO2 = 1),
    AR5_including_carbon_feedback = c(CH4 = 34, N2O = 298, CO2 = 1),
    AR4 = c(CH4 = 25, N2O = 298, CO2 = 1),
    stop("Unsupported GWP version. Must be one of: AR6, AR5_excluding_carbon_feedback, AR5_including_carbon_feedback, AR4")
  )

  # Extract GWP factor for each gas type
  gwp_used <- unname(gwp_factors[gas])

  # Calculate CO2-equivalent emissions
  value_co2e <- value_allocated * gwp_used

  list(
    value_co2e = value_co2e,
    gwp = gwp_used
  )
}
