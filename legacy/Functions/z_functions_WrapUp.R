
#' Calculate totals of the variables by cohort
#' 
#' This function calculates the totals by cohort for the whole assessment duration.
#' 
#' @param value Numeric value expressed in kg (unit)/head/day, with the exception of the variable_type=="Production", where the unit is kg/cohort/assessment duration.
#' @param size  Numeric value. Cohort-specific variables. Number of heads in the specific cohort.
#' @param assessment_duration  Numeric value representing the duration of the assessment (days)
#' @param variable_type Character vector. Variable type represents the variable group (e.g., Production, Emissions, Feed...etc)
#'
#' @return `value_total` Numeric value. Value for each variables harmonized at cohort and assessment duration level (kg/cohort/assessment duration)
#' @export
#'

calc_totals_by_cohort <- function(value,
                                  size,
                                  assessment_duration,
                                  variable_type) {
  
  if (variable_type == "Production") {
    value_total <- value
    
    
  } else {
    value_total <- value * size * assessment_duration
    
    }
  
  return(value_total)
}



#' Aggregate Cohort-Level Data to Herd-Level
#' 
#' @Yassine: this should be moved somewhere else/ it is created also in the allocation module
#'
#' This function aggregates a dataset from cohort level to herd level by summing
#' specified variables over the defined ID columns.
#' 
#' @param data A `data.table` containing cohort-level data.
#' @param id_cols Character vector of ID variables (e.g., Animal_short, LPS_short, HerdType_short).@Yassine: this should be revised. Record_id should be used.
#' @param vars_to_sum Character vector of column names to be summed during aggregation.
#' @param cohort Character. Cohort code (e.g., "FJ", "MJ", "FS", "MS", "FA", "MA").

#'
#' @return A `data.table` with summed values at the herd level.
#' @export
#'

aggregate_cohort_to_herd <- function(data_cohort, id_cols, vars_to_sum, cohort) {
  
  # Aggregate over cohorts
  data_herd <- data_cohort[
    ,
    lapply(.SD, sum, na.rm = TRUE),
    by = id_cols,
    .SDcols = vars_to_sum
  ]
  
  # Add cohort = "ALL"
  data_herd[, (cohort) := "ALL"]
  
  return(data_herd[])
}

#' Calculate Allocated Emissions
#'
#' Applies allocation shares to total emissions to compute emissions attributable to a specific commodity.
#'
#' This function multiplies total emissions (`emissions`) by the corresponding allocation share (`allocation_share`)
#' to estimate the share of emissions allocated to a specific output (e.g., meat, milk, fibre).
#'
#' @param value Numeric vector. Emissions are expressed at herd-level by source (kg gas).
#' @param allocation_share Numeric vector. Fraction of emissions to allocate to the different commodities (between 0 and 1).
#'
#' @return Numeric vector of allocated emissions (kg gas)
#'
#' @export
calc_allocated_emissions <- function(value, allocation_share) {
  
  value_allocated <- value * allocation_share
  
  return(value_allocated)
}


#' Convert CH4 and N2O emissions to CO2-equivalents using GWP factors
#'
#' Computes CO2-equivalent (CO2e) emissions for CH4 and N2O based on different 100-year 
#' Global Warming Pontentials (GWP) reported in the IPCC assessment reports (AR). The function 
#' is vectorised and returns both the CO2e values and the GWP factor applied
#' for each observation.
#' #'
#' @param gas Character vector indicating the gas type for each observation.
#'   Supported values are \code{"CH4"}, \code{"N2O"} and \code{"CO2"}.
#' @param value_raw Numeric vector of emission values expressed in kg of gas
#'   (e.g. kg CH4, kg N2O or kg CO2).
#' @param gwp Character scalar specifying the IPCC assessment report to use. 100-year Global Warming Potential. 
#'   Default is \code{"AR6"}.
#'   Supported options are:
#'   \describe{
#'     \item{\code{"AR6"}: CH4 = 27, N2O = 273, CO2 = 1}. Source: IPCC 2021 - Chapter 7 - Table 7.15.
#'     \item{\code{"AR5_excluding_carbon_feedback"}: CH4 = 28, N2O = 265, CO2 = 1}.Source: IPCC 2013 - Chapter 8 - Table 8.A.1, with carbon feedback. 
#'     \item{\code{"AR5_including_carbon_feedback"}: CH4 = 34, N2O = 29, CO2 = 1}. Source: IPCC 2013 - Chapter 8 - Table 8.7, with carbon feedback. 
#'     \item{\code{"AR4"}: CH4 = 25, N2O = 298, CO2 = 1}. Source: IPCC 2007 - Chapter TS.2 - Table 2.14. 
#'   }
#'
#' @return A named list with two numeric vectors of the same length as \code{V1} input:
#' \describe{
#'   \item{\code{value_co2e}}{CO2-equivalent emissions (kg CO2e).}
#'   \item{\code{gwp}}{Global Warming Potential factor applied to each observation (kg CO2e/kg gas).}
#' }
#'
#' @export
calc_co2eq <- function(gas, value_allocated, gwp) {
  
  gwp_factors <- switch(
    gwp,
    AR6 = c(CH4 = 27, N2O = 273, CO2=1),
    AR5_excluding_carbon_feedback = c(CH4 = 28,   N2O = 265, CO2=1),
    AR5_including_carbon_feedback = c(CH4 = 34,   N2O = 298, CO2=1),
    AR4 = c(CH4 = 25,   N2O = 298, CO2=1))
  
  gwp_used <- unname(gwp_factors[gas])      # vector same length as gas
  value_co2e  <- value_allocated * gwp_used
  
  list(value_co2e = value_co2e, 
       gwp = gwp_used)
}
