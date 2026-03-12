#' Calculate Totals by Cohort
#'
#' Computes the total value for each variable at the cohort level over the
#' full assessment period. Values are harmonized to a common unit
#' (\code{kg/cohort/assessment duration}) by accounting for cohort stock size
#' and simulation duration.
#'
#' @param value Numeric. Variable value expressed as (unit)/head/day for non-production variables and (unit)/cohort/assessment duration for production variables. Production variables are those included in production_list.
#' @param cohort_stock_size Numeric. Average population size in each of the 6 sex–age cohorts (# heads). (cohorts=FJ, FS, FA, MJ, MS, MA).
#' @param ration_intake Numeric. Average daily dry matter intake of feed (kg DM/head/day).
#' @param feed_emissions_list List of emission-source definitions for feed-related
#'   emissions. Each element is a list with two character fields:
#'   \describe{
#'     \item{emissions_source}{List of variables = "co2_ration_fertilizer",
#'     "co2_ration_pesticides", "co2_ration_crop_activities",
#'     "co2_ration_luc_nopeat", "co2_ration_luc_peat",
#'     "n2o_ration_fertilizer", "n2o_ration_manure_applied",
#'     "n2o_ration_crop_residues", "ch4_ration_rice"}
#'     \item{label}{Human-readable output label.}
#'   }
#' @param simulation_duration Numeric. Length of the assessment period (days).
#' @param variable_type Character. Variable group classification.
#'   Supported values include:
#'   \itemize{
#'     \item \code{"Production"}: variables already expressed at the cohort level
#'       for the full assessment duration
#'     \item \code{"Emissions"}: variables expressed per head per day
#'     \item \code{"Feed"}: variables expressed per head per day
#'     \item \code{"NitrogenBalance"}: variables expressed per head per day
#'   }
#' @param variable_name Character. Names of emission variables to which
#'     allocation should be applied (e.g., "ch4_enteric", "ch4_manure_pasture",
#'     "ch4_manure_burned", "ch4_manure_other", "n2o_manure_pasture_direct",
#'     "n2o_manure_burned_direct", "n2o_manure_other_direct",
#'     "n2o_manure_burned_indirect", "n2o_manure_pasture_indirect",
#'     "n2o_manure_other_indirect", "co2_ration_fertilizer",
#'     "co2_ration_pesticides", "co2_ration_crop_activities",
#'     "co2_ration_luc_nopeat", "co2_ration_luc_peat",
#'     "n2o_ration_fertilizer", "n2o_ration_manure_applied",
#'     "n2o_ration_crop_residues", "ch4_ration_rice")
#'
#' @return Numeric. Variable value expressed as (unit)/cohort/assessment duration for all variables. 
#'
#' @details
#' Production variables are already expressed at the cohort level for the
#' entire assessment duration and are therefore returned unchanged.
#' All other variables (emissions, feed, and nitrogen balance) are expressed
#' per head per day and are scaled by cohort stock size and simulation
#' duration to obtain cohort-level totals.
#' 
#' For production variables:
#' \deqn{value\_total = value}
#'
#' For emissions (except emissions from feed), feed, and nitrogen balance variables:
#' \deqn{value\_total = value \times cohort\_stock\_size \times simulation\_duration}
#'
#' For emissions from feed:
#' \deqn{value\_total = value \times ration\_intake \times cohort\_stock\_size \times simulation\_duration / 100}
#' 
#' @export
calc_cohort_totals <- function(
    value,
    cohort_stock_size,
    ration_intake,
    feed_emissions_list,
    simulation_duration,
    variable_name,
    variable_type
) {
  validate_totals_by_cohort_inputs(
    value, cohort_stock_size, simulation_duration, variable_type
  )

  # Production variables are already at cohort level for entire assessment
  # Use ifelse to handle both scalar and vector inputs
  value_total <- if (variable_type == "Production") {
    
    value
    
  } else if (variable_type == "Emissions" && variable_name %in% feed_emissions_list) {
    
    value * ration_intake * cohort_stock_size * simulation_duration / 1000
    
  } else {
    
    value * cohort_stock_size * simulation_duration
  }
    
  return(value_total)
}


#' Calculate Allocated Emissions
#'
#' Computes emissions attributable to specific commodities by applying
#' allocation shares to total herd-level emissions.
#'
#' @param value Numeric. Total herd-level emissions by source before allocation to commodities (kg gas).
#' @param allocation_share Numeric. Allocation share assigned to the commodity for the corresponding emission source (fraction).
#'
#' @return Numeric. Allocated emissions for each commodity–emission combination (kg gas).
#' 
#' @details
#' Allocation shares represent the fraction of total emissions assigned to
#' each commodity (e.g., meat, milk, fibre).
#' See [run_allocation_module()] for additional details.
#' 
#' Allocated emissions are calculated as:
#'
#' \deqn{value\_allocated = value \times allocation\_share}
#'
#' @seealso 
#' [run_allocation_module()]
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


#' Convert CH₄ and N₂O emissions to CO₂-equivalents (CO₂eq) using GWP factors
#'
#' Computes CO₂-equivalent (CO₂eq) emissions for CH₄ and N₂O based on
#' 100-year Global Warming Potentials (GWP) reported in IPCC assessment reports.
#'
#' @param gas Character. Gas type for each observation. Supported values:
#'   \itemize{
#'     \item \code{"CH4"}: methane (CH₄)
#'     \item \code{"N2O"}: nitrous oxide (N₂O)
#'     \item \code{"CO2"}: carbon dioxide (CO₂)
#'   }
#' @param value_allocated  Numeric. Allocated emissions for each commodity–emission combination (kg gas).
#' @param global_warming_potential_set Character. Settings for the
#'   100-year Global Warming Potential (GWP-100) conversion factors used to
#'   express CH₄ and N₂O emissions as CO₂eq. Must be one of:
#'   \itemize{
#'     \item \code{"AR6"}: IPCC Sixth Assessment Report (IPCC, 2021) — CH4 = 27, N2O = 273
#'     \item \code{"AR5_excluding_carbon_feedback"}: IPCC Fifth Assessment
#'       Report (excluding climate–carbon feedbacks) (IPCC, 2013)  — CH4 = 28, N2O = 265
#'     \item \code{"AR5_including_carbon_feedback"}: IPCC Fifth Assessment
#'       Report (including climate–carbon feedbacks) (IPCC, 2013) — CH4 = 34, N2O = 298
#'     \item \code{"AR4"}: IPCC Fourth Assessment Report (IPCC, 2007) — CH4 = 25, N2O = 298
#'   }
#'
#' @return List with elements:
#' \describe{
#'   \item{value_co2eq}{Numeric vector. Emissions expressed as CO₂-equivalents (kg CO₂e).}
#'   \item{gwp}{Numeric vector. Global Warming Potential factor applied to each observation (kg CO₂e/kg gas).}
#' }
#'
#' @details
#' CO2-equivalent emissions are calculated as:
#'
#' \deqn{value\_co2eq = value\_allocated \times gwp}
#'
#' where \code{gwp} is the gas-specific 100-year Global Warming Potential
#' factor from the selected IPCC assessment report.
#'
#' @references
#' IPCC (2007). Climate Change 2007: The Physical Science Basis. Contribution
#' of Working Group I to the Fourth Assessment Report of the Intergovernmental
#' Panel on Climate Change.
#'
#' IPCC (2013). Climate Change 2013: The Physical Science Basis. Contribution
#' of Working Group I to the Fifth Assessment Report of the Intergovernmental
#' Panel on Climate Change.
#'
#' IPCC (2021). Climate Change 2021: The Physical Science Basis. Contribution
#' of Working Group I to the Sixth Assessment Report of the Intergovernmental
#' Panel on Climate Change.
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
