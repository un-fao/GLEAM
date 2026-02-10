#' Calculate Volatile Solids for Manure Emissions
#'
#' Computes daily volatile solids (VS) excretion in manure (kg VS/head/day).
#' VS represents the total organic material excreted (biodegradable + non-biodegradable)
#' and is required to proceed with the estimate of methane emissions from manure management.
#'
#' @param dry_matter_intake Numeric. Daily dry matter intake of feed (kg DM/head/day).
#' @param diet_digestibility_fraction Numeric. Average digestibility of the the feed ration, expressed as ratio of digestible to gross energy content (fraction)
#' @param urinary_energy_fraction Numeric. Average ash content of feed, calculated as a fraction of the dry matter intake (kg ash/kg DM)
#' @param diet_ash Numeric. Fraction of animal's gross energy that is excreted in urine (fraction).
#'
#' @return Numeric. Total volatile solids (volatile_solids) excreted per animal per day, representing the organic material in livestock manure and consisting of both biodegradable and non-biodegradable fractions (kg VS/head/day).
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
#' @examples
#' calc_volatile_solids <- calc_volatile_solids(
#'   dry_matter_intake = 5,
#'   diet_digestibility_fraction = 0.6,
#'   urinary_energy_fraction = 0.04,
#'   diet_ash = 0.08
#' )
#'
#'@references
#' IPCC. (2019). \emph{2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions from
#' Livestock and Manure Management. Equation 10.24.
#'
#' IPCC. (2006). \emph{2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions from
#' Livestock and Manure Management. Equation 10.24.
#' @export
calc_volatile_solids <- function(
    dry_matter_intake,
    diet_digestibility_fraction,
    urinary_energy_fraction = 0.04,
    diet_ash = 0.08
) {
  validate_calc_volatile_solids(dry_matter_intake, diet_digestibility_fraction, urinary_energy_fraction, diet_ash)

  volatile_solids <- dry_matter_intake * (1 - diet_digestibility_fraction + urinary_energy_fraction) * (1 - diet_ash)

  return(volatile_solids)
}

#' Calculate CH4 emissions from manure management systems
#'
#' Computes daily methane emissions from manure using IPCC-based parameters and
#' separates emissions from pasture, burned manure, and all other manure
#' management systems.
#'
#' @param ratio_m3CH4_kgCH4 Numeric. The conversion factor used to convert methane from a volumetric unit (m³) to a mass unit (kg). This value represents the density of methane. It defaults to 0.67 kg/m³ (at 20°C and 1 atm), which is the standard value defined in the IPCC 2006 and 2019 guidelines.
#'
#' @param volatile_solids Numeric. Total volatile solids (volatile_solids) excreted per animal per day, representing the organic material in livestock manure and consisting of both biodegradable and non-biodegradable fractions (kg VS/head/day).
#'
#' @param ... A variable number of manure management system (MMS) arguments.
#'   Each MMS must be provided as a named numeric vector with exactly the
#'   following fields:
#'   \describe{
#'     \item{manure_management_system_fraction}{Fraction of total manure managed in this system (0–1).
#'       The sum of all fractions must equal 1.}
#'     \item{methane_conversion_factor_mcf}{Methane conversion factor (MCF),
#'       expressed as a percentage.}
#'     \item{ch4_max_producing_capacity_bo}{Maximum methane producing capacity
#'       (B0), in m3 CH4 / kg VS.}
#'   }
#'
#' Two MMS names are treated explicitly when present:
#' \describe{
#'   \item{\code{mms_pasture}}{manure deposited on pasture}
#'   \item{\code{mms_burned}}{manure burned for fuel}
#' }
#' All remaining MMS arguments are grouped and treated as other manure
#' management systems.
#'
#' @return A named list with the following elements (kg CH4/head/day):
#' \describe{
#'   \item{ch4_manure_pasture}{Methane emissions from manure deposited on pasture.}
#'   \item{ch4_manure_burned}{Methane emissions from manure burned for fuel.}
#'   \item{ch4_manure_other}{Methane emissions from all other manure management systems.}
#'   \item{ch4_manure_all_noburn}{Total methane emissions excluding burned manure
#'   (pasture + other systems).}
#' }
#'
#' @examples
#' calc_ch4_emissions(
#'   ratio_m3CH4_kgCH4 = 0.67,
#'   volatile_solids   = 2.024,
#'   mms_burned = c(
#'     manure_management_system_fraction = 0.020,
#'     methane_conversion_factor_mcf = 10,
#'     ch4_max_producing_capacity_bo = 0.13
#'   ),
#'   mms_drylot = c(
#'     manure_management_system_fraction = 0.264,
#'     methane_conversion_factor_mcf = 2,
#'     ch4_max_producing_capacity_bo = 0.13
#'   ),
#'   mms_pasture = c(
#'     manure_management_system_fraction = 0.310,
#'     methane_conversion_factor_mcf = 0.47,
#'     ch4_max_producing_capacity_bo = 0.19
#'   ),
#'   mms_solid = c(
#'     manure_management_system_fraction = 0.406,
#'     methane_conversion_factor_mcf = 5,
#'     ch4_max_producing_capacity_bo = 0.13
#'   )
#' )
#'
#' @export
calc_ch4_emissions <- function(
    ratio_m3CH4_kgCH4 = 0.67,
    volatile_solids,
    ...
) {
  mms_list <- list(...)

  validate_mms_inputs(
    mms_list,
    required_names = c(
      "manure_management_system_fraction",
      "methane_conversion_factor_mcf",
      "ch4_max_producing_capacity_bo"
    ),
    ratio_m3CH4_kgCH4 = ratio_m3CH4_kgCH4,
    volatile_solids   = volatile_solids
  )

  # split special (burned and pasture) vs other MMS
  mms_pasture <- mms_list[["mms_pasture"]]
  mms_burned <- mms_list[["mms_burned"]]
  mms_other <- mms_list[setdiff(names(mms_list), c("mms_pasture", "mms_burned"))]

  # pasture
  ch4_manure_pasture <- if (is.null(mms_pasture)) 0 else
    volatile_solids * ratio_m3CH4_kgCH4 *
    mms_pasture[["manure_management_system_fraction"]] *
    (mms_pasture[["methane_conversion_factor_mcf"]] / 100) *
    mms_pasture[["ch4_max_producing_capacity_bo"]]

  # burned
  ch4_manure_burned <- if (is.null(mms_burned)) 0 else
    volatile_solids * ratio_m3CH4_kgCH4 *
    mms_burned[["manure_management_system_fraction"]] *
    (mms_burned[["methane_conversion_factor_mcf"]] / 100) *
    mms_burned[["ch4_max_producing_capacity_bo"]]

  # all other MMS (scalar product)
  ch4_manure_other <- if (length(mms_other) == 0) 0 else {
    other_term <- vapply(
      mms_other,
      function(mms) {
        mms[["manure_management_system_fraction"]] * mms[["methane_conversion_factor_mcf"]] * mms[["ch4_max_producing_capacity_bo"]]
      },
      numeric(1)
    )
    volatile_solids * ratio_m3CH4_kgCH4 * sum(other_term) / 100
  }

  # total non-burned emissions
  ch4_manure_all_noburn <- ch4_manure_pasture + ch4_manure_other

  return(
    list(
      ch4_manure_pasture = ch4_manure_pasture,
      ch4_manure_burned = ch4_manure_burned,
      ch4_manure_other = ch4_manure_other,
      ch4_manure_all_noburn = ch4_manure_all_noburn
    )
  )
}

#' Calculate direct N2O emissions from manure management systems
#'
#' Computes daily direct nitrous oxide (N2O) emissions from manure using
#' IPCC-based parameters and separates emissions from pasture, burned manure,
#' and all other manure management systems.
#'
#' @param ratio_N2ON_to_N2O Numeric. Conversion factor from N2O-N (kg N) to N2O
#'   (kg), based on molecular weights. Defaults to 44/28.
#'
#' @param nitrogen_excretion Numeric. Daily nitrogen excretion
#'   (kg N/head/day).
#'
#' @param ... A variable number of manure management system (MMS) arguments.
#'   Each MMS must be provided as a named numeric vector with exactly the
#'   following fields:
#'   \describe{
#'     \item{manure_management_system_fraction}{Fraction of total manure managed in this system (0–1).
#'       The sum of all fractions must equal 1.}
#'     \item{n2o_ef3}{Effective emission factor (EF\eqn{_3}) for manure
#'       management, expressed in kg N2O-N / kg N excreted.}
#'   }
#'
#' Two MMS names are treated explicitly when present:
#' \describe{
#'   \item{\code{mms_pasture}}{manure deposited on pasture}
#'   \item{\code{mms_burned}}{manure burned for fuel}
#' }
#' All remaining MMS arguments are grouped and treated as other manure
#' management systems.
#'
#' @return A named list with the following elements (kg N2O/head/day):
#' \describe{
#'   \item{n2o_manure_pasture_direct}{Direct N2O emissions from manure deposited on pasture.}
#'   \item{n2o_manure_burned_direct}{Direct N2O emissions from manure burned for fuel.}
#'   \item{n2o_manure_other_direct}{Direct N2O emissions from all other manure management systems.}
#'   \item{n2o_manure_all_noburn_direct}{Total direct N2O emissions excluding burned manure
#'   (pasture + other systems).}
#' }
#'
#' @examples
#' calc_direct_n2o_emissions(
#'   ratio_N2ON_to_N2O = 44 / 28,
#'   nitrogen_excretion = 0.9,
#'   mms_burned = c(
#'     manure_management_system_fraction = 0.020,
#'     n2o_ef3  = 0
#'   ),
#'   mms_drylot = c(
#'     manure_management_system_fraction = 0.264,
#'     n2o_ef3  = 0.02
#'   ),
#'   mms_pasture = c(
#'     manure_management_system_fraction = 0.310,
#'     n2o_ef3  = 0.02
#'   ),
#'   mms_solid = c(
#'     manure_management_system_fraction = 0.406,
#'     n2o_ef3  = 0.005
#'   )
#' )
#'
#' @export
calc_direct_n2o_emissions <- function(
    ratio_N2ON_to_N2O = 44 / 28,
    nitrogen_excretion,
    ...
) {
  mms_list <- list(...)

  validate_mms_inputs(
    mms_list,
    required_names = c("manure_management_system_fraction", "n2o_ef3"),
    ratio_N2ON_to_N2O = ratio_N2ON_to_N2O,
    nitrogen_excretion = nitrogen_excretion
  )

  # split special (burned and pasture) vs other MMS
  mms_pasture <- mms_list[["mms_pasture"]]
  mms_burned <- mms_list[["mms_burned"]]
  mms_other <- mms_list[setdiff(names(mms_list), c("mms_pasture", "mms_burned"))]

  # pasture
  n2o_manure_pasture_direct <- if (is.null(mms_pasture)) 0 else
    nitrogen_excretion * ratio_N2ON_to_N2O * mms_pasture[["manure_management_system_fraction"]] *
    mms_pasture[["n2o_ef3"]]

  # burned
  n2o_manure_burned_direct <- if (is.null(mms_burned)) 0 else
    nitrogen_excretion * ratio_N2ON_to_N2O * mms_burned[["manure_management_system_fraction"]] *
    mms_burned[["n2o_ef3"]]

  # all other MMS (scalar product)
  n2o_manure_other_direct <- if (length(mms_other) == 0) 0 else {
    other_term <- vapply(
      mms_other,
      function(mms) mms[["manure_management_system_fraction"]] * mms[["n2o_ef3"]],
      numeric(1)
    )
    nitrogen_excretion * ratio_N2ON_to_N2O * sum(other_term)
  }

  # total non-burned emissions
  n2o_manure_all_noburn_direct <- n2o_manure_pasture_direct + n2o_manure_other_direct

  return(
    list(
      n2o_manure_pasture_direct = n2o_manure_pasture_direct,
      n2o_manure_burned_direct = n2o_manure_burned_direct,
      n2o_manure_other_direct = n2o_manure_other_direct,
      n2o_manure_all_noburn_direct = n2o_manure_all_noburn_direct
    )
  )
}

#' Calculate indirect N2O emissions from manure volatilization
#'
#' Computes daily indirect nitrous oxide (N2O) emissions resulting from
#' atmospheric deposition of volatilized nitrogen (NH3–N and NOx–N) from manure
#' management systems and separates emissions from pasture, burned manure, and
#' all other manure management systems.
#'
#' @param ratio_N2ON_to_N2O Numeric. Conversion factor from N2O-N (kg N) to N2O
#'   (kg), based on molecular weights. Defaults to 44/28.
#'
#' @param nitrogen_excretion Numeric. Daily nitrogen excretion
#'   (kg N/head/day).
#'
#' @param ... A variable number of manure management system (MMS) arguments.
#'   Each MMS must be provided as a named numeric vector with exactly the
#'   following fields:
#'   \describe{
#'     \item{manure_management_system_fraction}{Fraction of total manure managed in this system (0–1).
#'       The sum of all fractions must equal 1.}
#'     \item{n2o_ef4}{Emission factor for indirect N2O emissions resulting from
#'       atmospheric deposition of volatilized nitrogen (NH3–N and NOx–N) onto
#'       soils and water surfaces, expressed in
#'       kg N2O–N / (kg NH3–N + kg NOx–N).}
#'     \item{nitrogen_fracgas}{Fraction of nitrogen volatilized as NH3–N and
#'       NOx–N for this manure management system (0–1).}
#'   }
#'
#' Two MMS names are treated explicitly when present:
#' \describe{
#'   \item{\code{mms_pasture}}{manure deposited on pasture}
#'   \item{\code{mms_burned}}{manure burned for fuel}
#' }
#' All remaining MMS arguments are grouped and treated as other manure
#' management systems.
#'
#' @return A named list with the following elements (kg N2O/head/day):
#' \describe{
#'   \item{n2o_vol_manure_pasture}{Indirect N2O emissions from volatilization of manure deposited on pasture.}
#'   \item{n2o_vol_manure_burned}{Indirect N2O emissions from volatilization of manure burned for fuel.}
#'   \item{n2o_vol_manure_other}{Indirect N2O emissions from volatilization of manure in all other manure management systems.}
#'   \item{n2o_vol_manure_all_noburn}{Total indirect N2O emissions from manure volatilization excluding burned manure
#'   (pasture + other systems).}
#' }
#'
#' @examples
#' calc_n2o_from_volatilization(
#'   ratio_N2ON_to_N2O = 44 / 28,
#'   nitrogen_excretion = 0.9,
#'   mms_burned = c(
#'     manure_management_system_fraction = 0.020,
#'     n2o_ef4 = 0.14,
#'     nitrogen_fracgas = 0
#'   ),
#'   mms_drylot = c(
#'     manure_management_system_fraction = 0.264,
#'     n2o_ef4 = 0.14,
#'     nitrogen_fracgas = 0.3
#'   ),
#'   mms_pasture = c(
#'     manure_management_system_fraction = 0.310,
#'     n2o_ef4 = 0.14,
#'     nitrogen_fracgas = 0.21
#'   ),
#'   mms_solid = c(
#'     manure_management_system_fraction = 0.406,
#'     n2o_ef4 = 0.14,
#'     nitrogen_fracgas = 0.45
#'   )
#' )
#' @export
calc_n2o_from_volatilization <- function(
    ratio_N2ON_to_N2O = 44 / 28,
    nitrogen_excretion,
    ...
) {

  mms_list <- list(...)

  validate_mms_inputs(
    mms_list,
    required_names = c("manure_management_system_fraction", "n2o_ef4", "nitrogen_fracgas"),
    ratio_N2ON_to_N2O = ratio_N2ON_to_N2O,
    nitrogen_excretion = nitrogen_excretion
  )

  # split special (burned and pasture) vs other MMS
  mms_pasture <- mms_list[["mms_pasture"]]
  mms_burned <- mms_list[["mms_burned"]]
  mms_other <- mms_list[setdiff(names(mms_list), c("mms_pasture", "mms_burned"))]

  # pasture
  n2o_vol_manure_pasture <- if (is.null(mms_pasture)) 0 else
    nitrogen_excretion * ratio_N2ON_to_N2O *
    mms_pasture[["manure_management_system_fraction"]] * mms_pasture[["nitrogen_fracgas"]] *
    mms_pasture[["n2o_ef4"]]

  # burned
  n2o_vol_manure_burned <- if (is.null(mms_burned)) 0 else
    nitrogen_excretion * ratio_N2ON_to_N2O *
    mms_burned[["manure_management_system_fraction"]] * mms_burned[["nitrogen_fracgas"]] *
    mms_burned[["n2o_ef4"]]

  # all other MMS (scalar product)
  n2o_vol_manure_other <- if (length(mms_other) == 0) 0 else {

    other_term <- vapply(
      mms_other,
      function(mms) {
        mms[["manure_management_system_fraction"]] * mms[["nitrogen_fracgas"]] * mms[["n2o_ef4"]]
      },
      numeric(1)
    )

    nitrogen_excretion * ratio_N2ON_to_N2O * sum(other_term)
  }

  # total non-burned emissions
  n2o_vol_manure_all_noburn <- n2o_vol_manure_pasture + n2o_vol_manure_other

  return(
    list(
      n2o_vol_manure_pasture = n2o_vol_manure_pasture,
      n2o_vol_manure_burned = n2o_vol_manure_burned,
      n2o_vol_manure_other = n2o_vol_manure_other,
      n2o_vol_manure_all_noburn = n2o_vol_manure_all_noburn
    )
  )
}

#' Calculate indirect N2O emissions from manure leaching and runoff
#'
#' Computes daily indirect nitrous oxide (N2O) emissions resulting from nitrogen
#' leaching and runoff from manure management systems and separates emissions
#' from pasture, burned manure, and all other manure management systems.
#'
#' @param ratio_N2ON_to_N2O Numeric. Conversion factor from N2O-N (kg N) to N2O
#'   (kg), based on molecular weights. Defaults to 44/28.
#'
#' @param nitrogen_excretion Numeric. Daily nitrogen excretion
#'   (kg N/head/day).
#'
#' @param ... A variable number of manure management system (MMS) arguments.
#'   Each MMS must be provided as a named numeric vector with exactly the
#'   following fields:
#'   \describe{
#'     \item{manure_management_system_fraction}{Fraction of total manure managed in this system (0–1).
#'       The sum of all fractions must equal 1.}
#'     \item{n2o_ef5}{Emission factor for indirect nitrous oxide emissions
#'       resulting from nitrogen leaching and runoff, expressed as
#'       kg N2O–N / kg N leached and runoff.}
#'     \item{nitrogen_fracleach}{Fraction of nitrogen lost through leaching and
#'       runoff for this manure management system (0–1).}
#'   }
#'
#' Two MMS names are treated explicitly when present:
#' \describe{
#'   \item{\code{mms_pasture}}{manure deposited on pasture}
#'   \item{\code{mms_burned}}{manure burned for fuel}
#' }
#' All remaining MMS arguments are grouped and treated as other manure
#' management systems.
#'
#' @return A named list with the following elements (kg N2O/head/day):
#' \describe{
#'   \item{n2o_leach_manure_pasture}{Indirect N2O emissions from manure leaching and runoff on pasture.}
#'   \item{n2o_leach_manure_burned}{Indirect N2O emissions from manure leaching and runoff from burned manure.}
#'   \item{n2o_leach_manure_other}{Indirect N2O emissions from manure leaching and runoff in all other manure management systems.}
#'   \item{n2o_leach_manure_all_noburn}{Total indirect N2O emissions from manure leaching and runoff excluding burned manure
#'   (pasture + other systems).}
#' }
#'
#' @examples
#' calc_n2o_from_leaching(
#'   ratio_N2ON_to_N2O = 44 / 28,
#'   nitrogen_excretion = 0.9,
#'   mms_burned = c(
#'     manure_management_system_fraction = 0.020,
#'     n2o_ef5 = 0.011,
#'     nitrogen_fracleach = 0
#'   ),
#'   mms_drylot = c(
#'     manure_management_system_fraction = 0.264,
#'     n2o_ef5 = 0.011,
#'     nitrogen_fracleach = 0.035
#'   ),
#'   mms_pasture = c(
#'     manure_management_system_fraction = 0.310,
#'     n2o_ef5 = 0.011,
#'     nitrogen_fracleach = 0.24
#'   ),
#'   mms_solid = c(
#'     manure_management_system_fraction = 0.406,
#'     n2o_ef5 = 0.011,
#'     nitrogen_fracleach = 0.02
#'   )
#' )
#' @export
calc_n2o_from_leaching <- function(
    ratio_N2ON_to_N2O = 44 / 28,
    nitrogen_excretion,
    ...
) {

  mms_list <- list(...)

  validate_mms_inputs(
    mms_list,
    required_names = c("manure_management_system_fraction", "n2o_ef5", "nitrogen_fracleach"),
    ratio_N2ON_to_N2O = ratio_N2ON_to_N2O,
    nitrogen_excretion = nitrogen_excretion
  )

  # split special (burned and pasture) vs other MMS
  mms_pasture <- mms_list[["mms_pasture"]]
  mms_burned <- mms_list[["mms_burned"]]
  mms_other <- mms_list[setdiff(names(mms_list), c("mms_pasture", "mms_burned"))]

  # pasture
  n2o_leach_manure_pasture <- if (is.null(mms_pasture)) 0 else
    nitrogen_excretion * ratio_N2ON_to_N2O *
    mms_pasture[["manure_management_system_fraction"]] * mms_pasture[["nitrogen_fracleach"]] *
    mms_pasture[["n2o_ef5"]]

  # burned
  n2o_leach_manure_burned <- if (is.null(mms_burned)) 0 else
    nitrogen_excretion * ratio_N2ON_to_N2O *
    mms_burned[["manure_management_system_fraction"]] * mms_burned[["nitrogen_fracleach"]] *
    mms_burned[["n2o_ef5"]]

  # all other MMS (scalar product)
  n2o_leach_manure_other <- if (length(mms_other) == 0) 0 else {

    other_term <- vapply(
      mms_other,
      function(mms) {
        mms[["manure_management_system_fraction"]] * mms[["nitrogen_fracleach"]] * mms[["n2o_ef5"]]
      },
      numeric(1)
    )

    nitrogen_excretion * ratio_N2ON_to_N2O * sum(other_term)
  }

  # total non-burned emissions
  n2o_leach_manure_all_noburn <- n2o_leach_manure_pasture + n2o_leach_manure_other

  return(
    list(
      n2o_leach_manure_pasture = n2o_leach_manure_pasture,
      n2o_leach_manure_burned = n2o_leach_manure_burned,
      n2o_leach_manure_other = n2o_leach_manure_other,
      n2o_leach_manure_all_noburn = n2o_leach_manure_all_noburn
    )
  )
}

#' Calculate total N2O emissions from manure
#'
#' Aggregates direct and indirect nitrous oxide (N2O) emissions from manure by
#' manure management system group (pasture, burned manure and all other systems).
#' Indirect emissions include contributions from volatilisation and from leaching
#' and runoff.
#'
#' @param n2o_vol_manure_pasture Numeric. Indirect N2O emissions from manure
#'   deposited on pasture due to atmospheric deposition of volatilised nitrogen
#'   (kg N2O/head/day).
#' @param n2o_leach_manure_pasture Numeric. Indirect N2O emissions from manure
#'   deposited on pasture due to leaching and runoff of nitrogen
#'   (kg N2O/head/day).
#' @param n2o_vol_manure_burned Numeric. Indirect N2O emissions from manure burned
#'   for fuel due to atmospheric deposition of volatilised nitrogen
#'   (kg N2O/head/day).
#' @param n2o_leach_manure_burned Numeric. Indirect N2O emissions from manure
#'   burned for fuel due to leaching and runoff of nitrogen
#'   (kg N2O/head/day).
#' @param n2o_vol_manure_other Numeric. Indirect N2O emissions from manure managed
#'   in all other manure management systems due to atmospheric deposition of
#'   volatilised nitrogen (kg N2O/head/day).
#' @param n2o_leach_manure_other Numeric. Indirect N2O emissions from manure
#'   managed in all other manure management systems due to leaching and runoff of
#'   nitrogen (kg N2O/head/day).
#' @param n2o_manure_pasture_direct Numeric. Direct N2O emissions from manure
#'   deposited on pasture (kg N2O/head/day).
#' @param n2o_manure_burned_direct Numeric. Direct N2O emissions from manure
#'   burned for fuel (kg N2O/head/day).
#' @param n2o_manure_other_direct Numeric. Direct N2O emissions from manure
#'   managed in all other manure management systems (kg N2O/head/day).
#'
#' @details
#' The following aggregations are applied:
#' \deqn{n2o\_manure\_pasture\_indirect = n2o\_vol\_manure\_pasture + n2o\_leach\_manure\_pasture}
#' \deqn{n2o\_manure\_burned\_indirect = n2o\_vol\_manure\_burned + n2o\_leach\_manure\_burned}
#' \deqn{n2o\_manure\_other\_indirect = n2o\_vol\_manure\_other + n2o\_leach\_manure\_other}
#'
#' \deqn{n2o\_manure\_pasture\_total = n2o\_manure\_pasture\_indirect + n2o\_manure\_pasture\_direct}
#' \deqn{n2o\_manure\_burned\_total = n2o\_manure\_burned\_indirect + n2o\_manure\_burned\_direct}
#' \deqn{n2o\_manure\_other\_total = n2o\_manure\_other\_indirect + n2o\_manure\_other\_direct}
#'
#' @return A named list with:
#' \describe{
#'   \item{n2o_manure_pasture_indirect}{Numeric. Total indirect nitrous oxide emissions originating from manure deposited on pasture, including emissions from atmospheric deposition of volatilised nitrogen (NH3 and NOx) and from leaching and runoff of manure nitrogen (kg N2O/head/day).}
#'   \item{n2o_manure_burned_indirect}{Numeric. Total indirect nitrous oxide emissions originating from manure burned for fuel, including emissions from atmospheric deposition of volatilised nitrogen (NH3 and NOx) and from leaching and runoff of manure nitrogen (kg N2O/head/day).}
#'   \item{n2o_manure_other_indirect}{Numeric. Total indirect nitrous oxide emissions originating from manure managed in all other manure management systems, excluding manure deposited on pasture and manure burned for fuel, including emissions from atmospheric deposition of volatilised nitrogen (NH3 and NOx) and from leaching and runoff of manure nitrogen (kg N2O/head/day).}
#'   \item{n2o_manure_pasture_total}{Numeric. Total nitrous oxide emissions from manure deposited on pasture, including direct emissions and indirect emissions from volatilisation, leaching and runoff (kg N2O/head/day).}
#'   \item{n2o_manure_burned_total}{Numeric. Total nitrous oxide emissions from manure burned for fuel, including direct emissions and indirect emissions from volatilisation, leaching and runoff (kg N2O/head/day).}
#'   \item{n2o_manure_other_total}{Numeric. Total nitrous oxide emissions from manure managed in all other manure management systems, excluding manure deposited on pasture and manure burned for fuel, including direct emissions and indirect emissions from volatilisation, leaching and runoff (kg N2O/head/day).}
#' }
#'
#' @examples
#' calc_total_n2o_emissions(
#'   n2o_vol_manure_pasture = 0.0129,
#'   n2o_leach_manure_pasture = 0.0012,
#'   n2o_vol_manure_burned = 0,
#'   n2o_leach_manure_burned = 0,
#'   n2o_vol_manure_other = 0.052,
#'   n2o_leach_manure_other = 0.00027,
#'   n2o_manure_pasture_direct = 0.009,
#'   n2o_manure_burned_direct = 0,
#'   n2o_manure_other_direct = 0.01033
#' )
#'
#' @export
calc_total_n2o_emissions <- function(
    n2o_vol_manure_pasture,
    n2o_leach_manure_pasture,
    n2o_vol_manure_burned,
    n2o_leach_manure_burned,
    n2o_vol_manure_other,
    n2o_leach_manure_other,
    n2o_manure_pasture_direct,
    n2o_manure_burned_direct,
    n2o_manure_other_direct
) {
  validate_calc_total_n2o_emissions(
    n2o_vol_manure_pasture = n2o_vol_manure_pasture,
    n2o_leach_manure_pasture = n2o_leach_manure_pasture,
    n2o_vol_manure_burned = n2o_vol_manure_burned,
    n2o_leach_manure_burned = n2o_leach_manure_burned,
    n2o_vol_manure_other = n2o_vol_manure_other,
    n2o_leach_manure_other = n2o_leach_manure_other,
    n2o_manure_pasture_direct = n2o_manure_pasture_direct,
    n2o_manure_burned_direct = n2o_manure_burned_direct,
    n2o_manure_other_direct = n2o_manure_other_direct
  )

  # indirect components
  n2o_manure_pasture_indirect <- n2o_vol_manure_pasture + n2o_leach_manure_pasture
  n2o_manure_burned_indirect <- n2o_vol_manure_burned + n2o_leach_manure_burned
  n2o_manure_other_indirect <- n2o_vol_manure_other + n2o_leach_manure_other

  # total components
  n2o_manure_pasture_total <- n2o_manure_pasture_indirect + n2o_manure_pasture_direct
  n2o_manure_burned_total <- n2o_manure_burned_indirect + n2o_manure_burned_direct
  n2o_manure_other_total <- n2o_manure_other_indirect + n2o_manure_other_direct

  return(
    list(
      n2o_manure_pasture_indirect = n2o_manure_pasture_indirect,
      n2o_manure_burned_indirect = n2o_manure_burned_indirect,
      n2o_manure_other_indirect = n2o_manure_other_indirect,
      n2o_manure_pasture_total = n2o_manure_pasture_total,
      n2o_manure_burned_total = n2o_manure_burned_total,
      n2o_manure_other_total = n2o_manure_other_total
    )
  )
}
