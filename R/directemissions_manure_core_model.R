#' Calculate Volatile Solids for Manure Emissions
#'
#' Computes daily volatile solids (VS) excretion in manure (kg VS/head/day).
#' VS represents the total organic material excreted (biodegradable + non-biodegradable)
#' and is required to proceed with the estimate of methane emissions from manure maanagement.
#'
#'
#' @param dmi Numeric. Daily dry matter intake of feed (kg DM/head/day).
#' @param diet_dig Numeric. Average digestibility of the the feed ration, expressed as ratio of digestible to gross energy content (fraction)
#' @param urinary_energy_fraction Numeric. Average ash content of feed, calculated as a fraction of the dry matter intake (kg ash/kg DM)
#' @param diet_ash Numeric. Fraction of animal's gross energy that is excreted in urine (fraction).
#' 
#' @return Numeric. Total volatile solids (VS) excreted per animal per day, representing the organic material in livestock manure and consisting of both biodegradable and non-biodegradable fractions (kg VS/head/day).
#' 
#' @details
#' The IPCC recommends estimating VS from feed intake and digestibility when
#' country-specific average daily VS excretion rates are not available. The core relationship is
#' given in **IPCC Equation 10.24 (Volatile solids excretion rates)**, which uses gross energy (GE)
#' intake, digestibility (DE), urinary energy as a fraction of GE (UE·GE), ash fraction (ASH), and
#' a conversion factor of 18.45 MJ/kg DM.
#'
#' **Implementation note (simplified coefficients).**
#' This package uses simplified algebraic forms by species/method that are consistent with the
#' structure of Eq. 10.24. 
#' Specifically, in IPCC guidelines the the average gross energy content of the ration is used instead 
#' of a fixed value of 18.45 MJ×kg DM-1. Thus, ge / diet_ge equals the daily intake, dmi. 
#'     
#'
#'
#'@references
#' IPCC. (2019). \emph{2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions from
#' Livestock and Manure Management. Equation 10.24.
#'
#' IPCC. (2006). \emph{2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions from
#' Livestock and Manure Management. Equation 10.24.
#' @export
calc_volatile_solids <- function(dmi, diet_dig, urinary_energy_fraction, diet_ash) {
  validate_manure_inputs(dmi, diet_dig, urinary_energy_fraction, diet_ash)
  
  vs <- dmi * (1 - diet_dig + urinary_energy_fraction) * (1 - diet_ash)

  return(vs)
}

#' Calculate Methane Conversion Factor for Manure Management
#'
#' Calculates methane conversion factors (MCF) for different manure management systems
#' by combining manure management system fractions with emission factors.
#'
#' @param mms_pasture Numeric vector of manure management system fraction for pasture (0-1)
#' @param mms_burned Numeric vector of manure management system fraction for burned (0-1)
#' @param mms_other Numeric vector of manure management system fraction for other systems (0-1)
#' @param ef_mcf_pasture Numeric vector of MCF emission factor for pasture (%)
#' @param ef_mcf_burned Numeric vector of MCF emission factor for burned (%)
#' @param ef_mcf_other Numeric vector of MCF emission factor for other systems (%)
#'
#' @return A named list with:
#' \describe{
#'   \item{mcf_pasture}{Methane conversion factor for pasture (dimensionless)}
#'   \item{mcf_burned}{Methane conversion factor for burned (dimensionless)}
#'   \item{mcf_other}{Methane conversion factor for other systems (dimensionless)}
#' }
#'
#' @export
calc_methane_conversion_factor <- function(
    mms_pasture,
    mms_burned,
    mms_other,
    ef_mcf_pasture,
    ef_mcf_burned,
    ef_mcf_other
) {
  validate_mcf_inputs(mms_pasture, mms_burned, mms_other, ef_mcf_pasture, ef_mcf_burned, ef_mcf_other)
  mcf_pasture <- mms_pasture * ef_mcf_pasture / 100
  mcf_burned <- mms_burned * ef_mcf_burned / 100
  mcf_other <- mms_other * ef_mcf_other / 100
  return(list(mcf_pasture = mcf_pasture, mcf_burned = mcf_burned, mcf_other = mcf_other))
}

#' Calculate CH4 Emissions from Manure
#' 
#' Calculates **methane (CH4) emissions** attributable to manure management pathways using
#' the IPCC Tier 2 framework. The computation follows the structure of IPCC
#' Eq. 10.23 (CH\eqn{_4} emission factor from manure management), but expressed on
#' a daily basis because \code{vs} is provided as kg VS/head/day.
#' 
#' This function expects that methane conversion factors 
#' (\code{mcf_pasture}, \code{mcf_burned}, \code{mcf_other}) are provided as
#' **weighted fractions**, i.e. they have already been multiplied by the relative manure management system shares (mms)
#'
#' @param vs Numeric. Total volatile solids (VS) excreted per animal per day, representing the organic material in livestock manure and consisting of both biodegradable and non-biodegradable fractions (kg VS/head/day).
#' @param mcf_pasture Numeric. Effective methane conversion factor for manure deposited on pasture (mcfpasture), expressed in percent (%), and already weighted by the share of manure deposited on pasture (mmspasture) (percentage)
#' @param mcf_burned Numeric. Effective methane conversion factor for manure burned for fuel (mcfburned), expressed in percent (%), and already weighted by the share of manure burned for fuel (mmsburned) (percentage)
#' @param mcf_other Numeric. Effective methane conversion factor for manure managed in non-pasture, non-burned manure management systems, expressed in percent (%), and already weighted by the share of each corresponding manure management system (e.g., mmsolid, mmsliquid...etc.) (percentage)
#' @param b0_mms_all Numeric. Maximum methane producing capacity for all systems (m³ CH4/kg VS). The value should is region- and species-specific. Default can be selected from Table 10.16 (IPCC, 2019) or from Tables 10A-4 to 10A-9 (IPCC, 2006)
#' @param b0_mms_pasture Numeric. Maximum methane producing capacity for manure deposited on pasture (m³ CH4/kg VS). Default can be selected from Table 10.16 (IPCC, 2019). For IPCC 2006 method, it is assumed to be equal to b0_mms_all.
#' @param ratio_m3CH4_kgCH4 Numeric. Conversion factor from m³ CH4 to kg CH4. Default to 0.67.
#'
#' @return A named list with:
#' \describe{
#'   \item{ch4_manure_pasture}{Numeric. Methane emissions from manure deposited on pasture (kg CH4/head/day))}
#'   \item{ch4_manure_burned}{Numeric. Methane emissions from manure burned for fuel (kg CH4/head/day)}
#'   \item{ch4_manure_other}{Numeric. Methane emissions from manure managed in all other manure management systems, excluding emissions from manure deposired on pasture and burned (kg CH4/head/day)}
#'   \item{ch4_manure_all_noburn}{Numeric. Methane emissions from manure managed in all other manure management systems and deposited on pasture, excluding emissions from burned manure (kg CH4/head/day)}
#' }
#'
#'@details
#'
#'@references
#' IPCC. (2019). \emph{2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions from
#' Livestock and Manure Management. Equation 10.23.
#'
#' IPCC. (2006). \emph{2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions from
#' Livestock and Manure Management. Equation 10.23.
#'
#' @export
calc_ch4_emissions <- function(
    vs,
    mcf_pasture,
    mcf_burned,
    mcf_other,
    b0_mms_all,
    b0_mms_pasture,
    ratio_m3CH4_kgCH4 = 0.67
) {
  validate_ch4_inputs(vs, mcf_pasture, mcf_burned, mcf_other, b0_mms_all, b0_mms_pasture)
  ch4_pasture <- vs * ratio_m3CH4_kgCH4 * mcf_pasture * b0_mms_pasture
  ch4_burned <- vs * ratio_m3CH4_kgCH4 * mcf_burned * b0_mms_all
  ch4_other <- vs * ratio_m3CH4_kgCH4 * mcf_other * b0_mms_all
  ch4_all_noburn <- ch4_pasture + ch4_other
  return(list(
    ch4_manure_pasture = ch4_pasture,
    ch4_manure_burned = ch4_burned,
    ch4_manure_other = ch4_other,
    ch4_manure_all_noburn = ch4_all_noburn
  ))
}

#' Calculate Direct N2O Emissions from Manure
#'
#' Calculates **direct nitrous oxide (N2O)** emissions from manure management
#' pathways using the IPCC Tier 2 framework. The calculation follows the structure of
#' IPCC Eq. 10.25 (direct N2O emissions from manure management), but is expressed
#' on a **daily basis** because \code{n_excretion} is provided in
#' kg N/head/day.
#'
#' This function expects that the emission-factor inputs
#' (\code{ef3_pasture}, \code{ef3_burned}, \code{ef3_other}) are provided as
#' **effective (already weighted) factors**, i.e. they have already been
#' multiplied by the corresponding manure management system shares (mms).
#'
#' @param n_excretion Numeric. Daily nitrogen excretion (kg N/head/day)
#' @param ef3_pasture Numeric. Effective EF3 factor for manure deposited on pasture (ef3pasture), expressed in kg N2O-N / kg N excreted, and already weighted by the share of manure deposited on pasture (mmspasture) (kg N2O-N / kg N excreted)
#' @param ef3_burned Numeric. Effective EF3 factor for manure burned for fuel (ef3burned), expressed in kg N2O-N / kg N excreted, and already weighted by the share of manure burned for fuel (mmsburned) (kg N2O-N / kg N excreted)
#' @param ef3_other Numeric. Effective EF3 factor for manure managed in non-pasture, non-burned manure management systems, expressed in g N2O-N / kg N excreted, and already weighted by the share of each corresponding manure management system (e.g., mmsolid, mmsliquid...etc.) (kg N2O-N / kg N excreted)
#' @param ration_N2ON_to_N2O Numeric. Conversion factor from kg N2O-N to kg N2O. Default to 44/28.
#'
#' @return A named list with:
#' \describe{
#'   \item{direct_n2o_manure_pasture}{Numeric. Direct nitrous oxide emissions from manure deposited on pasture (kg N2O/head/day)}
#'   \item{direct_n2o_manure_burned}{Numeric. Direct nitrous oxide emissions from manure burned for fuel (kg N2O/head/day)}
#'   \item{direct_n2o_manure_other}{Numeric. Direct nitrous oxide emissions from manure managed in all other manure management systems, excluding emissions from manure deposired on pasture and burned (kg N2O/head/day)}
#'   \item{direct_n2o_manure_all_noburn}{Numeric. Direct nitrous oxide emissions from manure managed in all other manure management systems and deposited on pasture, excluding emissions from burned manure (kg N2O/head/day)}
#' }
#'
#' @references
#' IPCC. (2019). \emph{2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions from
#' Livestock and Manure Management. Equation 10.25.
#'
#' IPCC. (2006). \emph{2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions from
#' Livestock and Manure Management. Equation 10.25.
#' 
#' @export
calc_direct_n2o_emissions <- function(
    n_excretion,
    ef3_pasture,
    ef3_burned,
    ef3_other,
    ration_N2ON_to_N2O = 44/28
) {
  validate_direct_n2o_inputs(n_excretion, ef3_pasture, ef3_burned, ef3_other)
  n2o_pasture <- n_excretion * ef3_pasture * ration_N2ON_to_N2O
  n2o_burned <- n_excretion * ef3_burned * ration_N2ON_to_N2O
  n2o_other <- n_excretion * ef3_other * ration_N2ON_to_N2O
  n2o_all_noburn <- n2o_pasture + n2o_other
  return(list(
    direct_n2o_manure_pasture = n2o_pasture,
    direct_n2o_manure_burned = n2o_burned,
    direct_n2o_manure_other = n2o_other,
    direct_n2o_manure_all_noburn = n2o_all_noburn
  ))
}

#' Calculate Nitrogen Volatilization Fraction
#'
#' Calculates the fraction of nitrogen lost via volatilization from different
#' manure management systems.
#'
#' @param mms_pasture Numeric vector of manure management system fraction for pasture (0-1)
#' @param mms_burned Numeric vector of manure management system fraction for burned (0-1)
#' @param mms_other Numeric vector of manure management system fraction for other systems (0-1)
#' @param ef_fracgas_pasture Numeric vector of volatilization fraction for pasture (0-1)
#' @param ef_fracgas_burned Numeric vector of volatilization fraction for burned (0-1)
#' @param ef_fracgas_other Numeric vector of volatilization fraction for other systems (0-1)
#'
#' @return A named list with:
#' \describe{
#'   \item{fracgas_pasture}{Volatilization fraction for pasture (dimensionless)}
#'   \item{fracgas_burned}{Volatilization fraction for burned (dimensionless)}
#'   \item{fracgas_other}{Volatilization fraction for other systems (dimensionless)}
#' }
#'
#' @export
calc_nitrogen_volatilization_fraction <- function(
    mms_pasture,
    mms_burned,
    mms_other,
    ef_fracgas_pasture,
    ef_fracgas_burned,
    ef_fracgas_other
) {
  validate_volatilization_fraction_inputs(
    mms_pasture, mms_burned, mms_other, ef_fracgas_pasture, ef_fracgas_burned, ef_fracgas_other
  )
  fracgas_pasture <- mms_pasture * ef_fracgas_pasture
  fracgas_burned <- mms_burned * ef_fracgas_burned
  fracgas_other <- mms_other * ef_fracgas_other
  return(list(
    fracgas_pasture = fracgas_pasture,
    fracgas_burned = fracgas_burned,
    fracgas_other = fracgas_other
  ))
}

#' Calculate Nitrogen Volatilization
#'
#' Computes nitrogen lost through volatilization as NH3 and NOx from manure
#' management pathways. The calculation follows the IPCC structure
#' (Eq. 10.26), but is expressed on a **daily** basis because \code{n_excretion}
#' is provided in kg N/head/day.
#'
#' This function expects volatilization fractions
#' (\code{fracgas_pasture}, \code{fracgas_burned}, \code{fracgas_other}) to be provided as
#' **effective (already weighted)** fractions, i.e. each fraction has already
#' been multiplied by the corresponding manure management system share (mms).
#'
#' @param n_excretion Numeric. Daily nitrogen excretion (kg N/head/day)
#' @param fracgas_pasture Numeric. Effective fraction of excreted nitrogen volatilized as NH₃ and NOₓ from manure deposited on pasture, already weighted by the share of manure deposited on pasture (mmspasture) (fraction).
#' @param fracgas_burned Numeric. Effective fraction of excreted nitrogen volatilized as NH₃ and NOₓ from manure burned for fuel, already weighted by the share of manure burned (mmsburned) (fraction).
#' @param fracgas_other Numeric. Effective fraction of excreted nitrogen volatilized as NH₃ and NOₓ from manure managed in non-pasture, non-burned manure management systems, already weighted by the shares of the corresponding systems (fraction).
#'
#' @return A named list with:
#' \describe{
#'   \item{n_vol_manure_pasture}{Numeric. Amount of manure nitrogen lost through volatilisation of NH₃ and NOₓ from manure deposited on pasture (kg N/head/day)}
#'   \item{n_vol_manure_burned}{Numeric. Amount of manure nitrogen lost through volatilisation of NH₃ and NOₓ from manure burned for fuel (kg N/head/day)}
#'   \item{n_vol_manure_other}{Numeric. Amount of manure nitrogen lost through volatilisation of NH₃ and NOₓ from manure managed in all other systems, excluding losses from manure deposited on pasture and burned for fuel (kg N/head/day)}
#'   \item{n_vol_manure_all_noburn}{Numeric. Amount of manure nitrogen lost through volatilisation of NH₃ and NOₓ from manure managed in all other systems and deposited on pasture, excluding losses from manure burned for fuel (kg N/head/day)}
#' }
#'
#' @references
#' IPCC. (2019). \emph{2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions from
#' Livestock and Manure Management. Equation 10.26.
#'
#' IPCC. (2006). \emph{2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions from
#' Livestock and Manure Management. Equation 10.26.
#' 
#' @export
calc_nitrogen_volatilization <- function(
    n_excretion,
    fracgas_pasture,
    fracgas_burned,
    fracgas_other
) {
  validate_nitrogen_volatilization_inputs(n_excretion, fracgas_pasture, fracgas_burned, fracgas_other)
  n_vol_pasture <- n_excretion * fracgas_pasture
  n_vol_burned <- n_excretion * fracgas_burned
  n_vol_other <- n_excretion * fracgas_other
  n_vol_all_noburn <- n_vol_pasture + n_vol_other
  return(list(
    n_vol_manure_pasture = n_vol_pasture,
    n_vol_manure_burned = n_vol_burned,
    n_vol_manure_other = n_vol_other,
    n_vol_manure_all_noburn = n_vol_all_noburn
  ))
}

#' Calculate N2O Emissions from Nitrogen Volatilization
#'
#' Converts volatilized manure nitrogen (NH\eqn{_3} and NO\eqn{_x}) into indirect
#' nitrous oxide (N\eqn{_2}O) emissions using the IPCC emission factor \code{EF4}.
#'
#' The calculation is implemented on a **daily basis** because volatilized nitrogen
#' inputs are provided as kg N/head/day.
#'
#' @param n_vol_pasture Numeric. Amount of manure nitrogen lost through volatilisation of NH₃ and NOₓ from manure deposited on pasture (kg N/head/day).
#' @param n_vol_burned Numeric. Amount of manure nitrogen lost through volatilisation of NH₃ and NOₓ from manure burned for fuel (kg N/head/day).
#' @param n_vol_other "Numeric. Amount of manure nitrogen lost through volatilisation of NH₃ and NOₓ from manure managed in all other systems, excluding losses from manure deposited on pasture and burned for fuel (kg N/head/day).
#' @param ef4 Numeric. Emission factor for indirect nitrous oxide (N₂O) emissions resulting from atmospheric deposition of volatilized nitrogen (NH₃–N and NOₓ–N) onto soils and water surfaces (kg N₂O–N / (kg NH₃–N + NOₓ–N)).
#' @param ration_N2ON_to_N2O Numeric. Conversion factor from kg N2O-N to kg N2O. Default to 44/28
#'
#' @return A named list with:
#' \describe{
#'   \item{n2o_vol_manure_pasture}{Numeric. Indirect nitrous oxide emissions resulting from atmospheric deposition of volatilized nitrogen (NH₃ and NOₓ) originating from manure deposited on pasture (kg N2O/head/day)}
#'   \item{n2o_vol_manure_burned}{Numeric. Indirect nitrous oxide emissions resulting from atmospheric deposition of volatilized nitrogen (NH₃ and NOₓ) originating from manure burned for fuel (kg N2O/head/day)}
#'   \item{n2o_vol_manure_other}{Numeric. Indirect nitrous oxide (N₂O) emissions resulting from atmospheric deposition of volatilized nitrogen (NH₃ and NOₓ) originating from manure managed in all other manure management systems, excluding manure deposited on pasture and manure burned for fuel (kg N2O/head/day)}
#'   \item{n2o_vol_manure_all_noburn}{Numeric. Indirect nitrous oxide (N₂O) emissions resulting from atmospheric deposition of volatilized nitrogen (NH₃ and NOₓ) originating from manure managed in all non-burned manure management systems, including manure deposited on pasture (kg N2O/head/day)}
#' }
#' @references
#' IPCC. (2019). \emph{2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions from
#' Livestock and Manure Management. Equation 10.28.
#'
#' IPCC. (2006). \emph{2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions from
#' Livestock and Manure Management. Equation 10.28.
#'
#' @export
calc_n2o_from_volatilization <- function(
    n_vol_pasture,
    n_vol_burned,
    n_vol_other,
    ef4,
    ration_N2ON_to_N2O = 44/28
) {
  validate_n2o_volatilization_inputs(n_vol_pasture, n_vol_burned, n_vol_other, ef4)
  n2o_pasture <- n_vol_pasture * ef4 * ration_N2ON_to_N2O
  n2o_burned <- n_vol_burned * ef4 * ration_N2ON_to_N2O
  n2o_other <- n_vol_other * ef4 * ration_N2ON_to_N2O
  n2o_all_noburn <- n2o_pasture + n2o_other
  return(list(
    n2o_vol_manure_pasture = n2o_pasture,
    n2o_vol_manure_burned = n2o_burned,
    n2o_vol_manure_other = n2o_other,
    n2o_vol_manure_all_noburn = n2o_all_noburn
  ))
}

#' Calculate Nitrogen Leaching Fraction
#'
#' Calculates the fraction of nitrogen lost via leaching from different
#' manure management systems.
#'
#' @param mms_pasture Numeric vector of manure management system fraction for pasture (0-1)
#' @param mms_burned Numeric vector of manure management system fraction for burned (0-1)
#' @param mms_other Numeric vector of manure management system fraction for other systems (0-1)
#' @param ef_fracleach_pasture Numeric vector of leaching fraction for pasture (0-1)
#' @param ef_fracleach_burned Numeric vector of leaching fraction for burned (0-1)
#' @param ef_fracleach_other Numeric vector of leaching fraction for other systems (0-1)
#'
#' @return A named list with:
#' \describe{
#'   \item{fracleach_pasture}{Leaching fraction for pasture (dimensionless)}
#'   \item{fracleach_burned}{Leaching fraction for burned (dimensionless)}
#'   \item{fracleach_other}{Leaching fraction for other systems (dimensionless)}
#' }
#'
#' @export
calc_nitrogen_leaching_fraction <- function(
    mms_pasture,
    mms_burned,
    mms_other,
    ef_fracleach_pasture,
    ef_fracleach_burned,
    ef_fracleach_other
) {
  validate_leaching_fraction_inputs(
    mms_pasture, mms_burned, mms_other, ef_fracleach_pasture, ef_fracleach_burned, ef_fracleach_other
  )
  fracleach_pasture <- mms_pasture * ef_fracleach_pasture
  fracleach_burned <- mms_burned * ef_fracleach_burned
  fracleach_other <- mms_other * ef_fracleach_other
  return(list(
    fracleach_pasture = fracleach_pasture,
    fracleach_burned = fracleach_burned,
    fracleach_other = fracleach_other
  ))
}

#' Calculate Nitrogen Leaching
#'
#' Calculates the amount of manure nitrogen lost via **leaching and runoff**
#' from manure management systems (kg N/head/day). This follows the IPCC
#' structure of Eq. 10.27, but expressed on a **daily** basis because
#' \code{n_excretion} is provided in kg N/head/day.
#' 
#' The function assumes leaching/runoff fractions - (\code{fracleach_pasture}, \code{fracleach_burned}, \code{fracleach_other}) -
#' are provided as **effective
#' weighted fractions**, i.e. they have already been multiplied by the
#' corresponding manure management system shares (mms fractions).
#'
#' @param n_excretion Numeric. Daily nitrogen excretion (kg N/head/day)
#' @param fracleach_pasture Numeric. Effective fraction of excreted nitrogen lost through leaching and runoff from manure deposited on pasture, already weighted by the share of manure deposited on pasture (mmspasture) (fraction).
#' @param fracleach_burned Numeric. Effective fraction of excreted nitrogen lost through leaching and runoff from manure burned for fuel, already weighted by the share of manure burned (mmsburned) (fraction).
#' @param fracleach_other Numeric. Effective fraction of excreted nitrogen lost through leaching and runoff from manure managed in non-pasture, non-burned manure management systems, already weighted by the shares of the corresponding manure management systems (e.g. solid storage, drylot, liquid/slurry) (fraction).
#'
#' @return A named list with:
#' \describe{
#'   \item{n_leach_manure_pasture}{Numeric. Amount of manure nitrogen lost through leaching and runoff from manure deposited on pasture (kg N/head/day).}
#'   \item{n_leach_manure_burned}{Numeric. Amount of manure nitrogen lost through leaching and runoff from manure burned for fuel (kg N/head/day).}
#'   \item{n_leach_manure_other}{Numeric. Amount of manure nitrogen lost through leaching and runoff from manure managed in all other systems, excluding losses from manure deposited on pasture and manure burned for fuel (kg N/head/day).}
#'   \item{n_leach_manure_all_noburn}{Numeric. Amount of manure nitrogen lost through leaching and runoff from manure managed in all other systems and deposited on pasture, excluding losses from manure burned for fuel (kg N/head/day).}
#' }
#'
#' @references
#' IPCC. (2019). \emph{2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions from
#' Livestock and Manure Management. Equation 10.27.
#'
#' IPCC. (2006). \emph{2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions from
#' Livestock and Manure Management. Equation 10.27.
#' 
#' @export
calc_nitrogen_leaching <- function(
    n_excretion,
    fracleach_pasture,
    fracleach_burned,
    fracleach_other
) {
  validate_nitrogen_leaching_inputs(n_excretion, fracleach_pasture, fracleach_burned, fracleach_other)
  n_leach_pasture <- n_excretion * fracleach_pasture
  n_leach_burned <- n_excretion * fracleach_burned
  n_leach_other <- n_excretion * fracleach_other
  n_leach_all_noburn <- n_leach_pasture + n_leach_other
  return(list(
    n_leach_manure_pasture = n_leach_pasture,
    n_leach_manure_burned = n_leach_burned,
    n_leach_manure_other = n_leach_other,
    n_leach_manure_all_noburn = n_leach_all_noburn
  ))
}

#' Calculate N2O Emissions from Nitrogen Leaching
#'
#' Converts leached/runoff manure nitrogen losses (kg N/head/day) into indirect
#' nitrous oxide (N\eqn{_2}O) emissions using the emission factor \code{ef5}
#' (kg N2O-N per kg N leached/runoff), consistent with the IPCC framework
#' for indirect N2O from leaching/runoff. 
#'
#' The calculation is implemented on a **daily basis** because volatilized nitrogen
#' inputs are provided as kg N/head/day.
#' 
#' @param n_leach_pasture Numeric. Amount of manure nitrogen lost through leaching and runoff from manure deposited on pasture (kg N/head/day).
#' @param n_leach_burned Numeric. Amount of manure nitrogen lost through leaching and runoff from manure burned for fuel (kg N/head/day).
#' @param n_leach_other Numeric. Amount of manure nitrogen lost through leaching and runoff from manure managed in all other systems, excluding losses from manure deposited on pasture and manure burned for fuel (kg N/head/day).
#' @param ef5 Numeric. Emission factor for indirect nitrous oxide emissions resulting from nitrogen leaching and runoff, expressed as kilograms of N₂O–N per kilogram of nitrogen leached or lost through runoff (kg N₂O–N / kg N leached and runoff).
#' @param ration_N2ON_to_N2O Numeric. Conversion factor from kg N2O-N to kg N2O. Default to 44/28.
#'
#' @return A named list with:
#' \describe{
#'   \item{n2o_leach_manure_pasture}{Numeric. Indirect nitrous oxide emissions resulting from leaching and runoff of manure nitrogen originating from manure deposited on pasture (kg N₂O/head/day).}
#'   \item{n2o_leach_manure_burned}{Numeric. Indirect nitrous oxide emissions resulting from leaching and runoff of manure nitrogen originating from manure burned for fuel (kg N₂O/head/day).}
#'   \item{n2o_leach_manure_other}{Numeric. Indirect nitrous oxide emissions resulting from leaching and runoff of manure nitrogen originating from manure managed in all other systems, excluding manure deposited on pasture and manure burned for fuel (kg N₂O/head/day).}
#'   \item{n2o_leach_manure_all_noburn}{Numeric. Indirect nitrous oxide emissions resulting from leaching and runoff of manure nitrogen originating from all non-burned manure management systems, including manure deposited on pasture (kg N₂O/head/day).}
#' }
#'
#'#' @references
#' IPCC. (2019). \emph{2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions from
#' Livestock and Manure Management. Equation 10.29.
#'
#' IPCC. (2006). \emph{2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions from
#' Livestock and Manure Management. Equation 10.29.
#' 
#' @export
calc_n2o_from_leaching <- function(
    n_leach_pasture,
    n_leach_burned,
    n_leach_other,
    ef5,
    ration_N2ON_to_N2O = 44/28
) {
  validate_n2o_leaching_inputs(n_leach_pasture, n_leach_burned, n_leach_other, ef5)
  n2o_pasture <- n_leach_pasture * ef5 * ration_N2ON_to_N2O
  n2o_burned <- n_leach_burned * ef5 * ration_N2ON_to_N2O
  n2o_other <- n_leach_other * ef5 * ration_N2ON_to_N2O
  n2o_all_noburn <- n2o_pasture + n2o_other
  return(list(
    n2o_leach_manure_pasture = n2o_pasture,
    n2o_leach_manure_burned = n2o_burned,
    n2o_leach_manure_other = n2o_other,
    n2o_leach_manure_all_noburn = n2o_all_noburn
  ))
}

#' Calculate Total N2O Emissions from Manure
#'
#' The function aggregates **direct** and **indirect** nitrous oxide emissions attributable to
#' manure management, expressed on a **head/day** basis.
#' 
#' @param direct List containing direct N2O emissions with elements:
#'   direct_n2o_manure_pasture, direct_n2o_manure_burned, direct_n2o_manure_other
#' @param vol List containing N2O emissions from volatilization with elements:
#'   n2o_vol_manure_pasture, n2o_vol_manure_burned, n2o_vol_manure_other
#' @param leach List containing N2O emissions from leaching with elements:
#'   n2o_leach_manure_pasture, n2o_leach_manure_burned, n2o_leach_manure_other
#'
#' @return A named list with:
#' \describe{
#'   \item{indirect_n2o_manure_pasture}{Numeric. Total indirect nitrous oxide (emissions originating from manure deposited on pasture, including emissions from atmospheric deposition of volatilised nitrogen (NH₃ and NOₓ) and from leaching and runoff of manure nitrogen (kg N₂O/head/day).}
#'   \item{indirect_n2o_manure_burned}{Numeric. Total indirect nitrous oxide emissions originating from manure burned for fuel, including emissions from atmospheric deposition of volatilised nitrogen (NH₃ and NOₓ) and from leaching and runoff of manure nitrogen (kg N₂O/head/day).}
#'   \item{indirect_n2o_manure_other}{Numeric. Total indirect nitrous oxide emissions originating from manure managed in all other manure management systems, excluding manure deposited on pasture and manure burned for fuel, including emissions from atmospheric deposition of volatilised nitrogen (NH₃ and NOₓ) and from leaching and runoff of manure nitrogen}
#'   \item{total_n2o_manure_pasture}{Numeric. Total nitrous oxide emissions from manure deposited on pasture, including direct emissions and indirect emissions from volatilisation, leaching, and runoff (kg N₂O/head/day).}
#'   \item{total_n2o_manure_burned}{Numeric. Total nitrous oxide emissions from manure burned for fuel, including direct emissions and indirect emissions from volatilisation, leaching, and runoff (kg N₂O/head/day).}
#'   \item{total_n2o_manure_other}{Numeric. Total nitrous oxide emissions from manure managed in all other manure management systems, excluding manure deposited on pasture and manure burned for fuel, including direct emissions and indirect emissions from volatilisation, leaching, and runoff (kg N₂O/head/day).}
#' }
#'
#' @export
calc_total_n2o_emissions <- function(
    direct,
    vol,
    leach
) {
  validate_total_n2o_inputs(direct, vol, leach)
  indirect_pasture <- vol$n2o_vol_manure_pasture + leach$n2o_leach_manure_pasture
  indirect_burned <- vol$n2o_vol_manure_burned + leach$n2o_leach_manure_burned
  indirect_other <- vol$n2o_vol_manure_other + leach$n2o_leach_manure_other

  total_pasture <- direct$direct_n2o_manure_pasture + indirect_pasture
  total_burned <- direct$direct_n2o_manure_burned + indirect_burned
  total_other <- direct$direct_n2o_manure_other + indirect_other

  return(list(
    indirect_n2o_manure_pasture = indirect_pasture,
    indirect_n2o_manure_burned = indirect_burned,
    indirect_n2o_manure_other = indirect_other,
    total_n2o_manure_pasture = total_pasture,
    total_n2o_manure_burned = total_burned,
    total_n2o_manure_other = total_other
  ))
}
