#' Calculate Volatile Solids (VS)
#'
#' Calculates daily volatile solids (VS) excretion in manure (kg VS/head/day).
#' VS represent the organic fraction of manure dry matter,
#' including both biodegradable and non-biodegradable organic material.
#' VS is a key intermediate variable required for estimating methane (CH4)
#' emissions from manure management systems under IPCC methodologies.
#'
#' @param ration_intake Numeric. Average daily dry matter intake of feed (kg DM/head/day).
#' @param ration_digestibility_fraction Numeric. Average digestibility of the feed ration, expressed as ratio of digestible to gross energy content (fraction).
#' @param ration_urinary_energy_fraction Numeric. Fraction of feed's gross energy that is excreted in urine (fraction).
#' @param ration_ash Numeric. Average ash content of feed, calculated as a fraction of the dry matter intake (kg ash/kg DM).
#'
#' @return Numeric. Total volatile solids (VS) excreted per animal per day, representing the organic material in livestock manure and consisting of both biodegradable and non-biodegradable fractions (kg VS/head/day).
#'
#' @details
#' The IPCC recommends estimating volatile solids (VS) excretion from feed
#' intake and digestibility when country-specific average daily VS excretion
#' rates are not available. The core relationship is provided in
#' **IPCC Equation 10.24 (Volatile solids excretion rates)**, which estimates
#' daily VS excretion as a function of:
#'
#' * Gross energy intake (gross_energy_intake, MJ/day)
#' * Digestibility of the diet (ration_digestibility_fraction)
#' * Urinary energy expressed as a fraction of GE (ration_urinary_energy_fraction)
#' * Ash content of the diet (ration_ash, fraction of dry matter)
#' * A conversion factor representing the average gross energy content of
#'   dry matter (18.45 MJ/kg DM)
#'
#' The general structure of Eq. 10.24 partitions gross energy intake into
#' digestible energy, urinary losses, and ash, and converts the remaining
#' organic matter into volatile solids using the energy density of dry matter.
#'
#' **Implementation note.**
#' This function applies an algebraically simplified formulation from Equation 10.24 of IPCC.
#'
#' In this implementation, the function takes \code{ration_intake} directly
#' as an input. It can be calculated upstream with
#' \code{\link{calc_ration_intake}} as a function of energy requirements and
#' the energy content of the diet.
#'
#' \deqn{
#'   dry\_matter\_intake = \frac{gross\_energy\_intake}{diet\_gross\_energy}
#' }
#'
#' This reflects the use of ration-specific energy content upstream and avoids
#' assuming a fixed gross energy density of 18.45 MJ/kg DM, as in the IPCC
#' default approach.
#'
#' The volatile solids excretion is then calculated as:
#'
#' \deqn{
#' volatile\_solids =
#' dry\_matter\_intake \times
#' (1 - diet\_digestibility\_fraction + urinary\_energy\_fraction) \times
#' (1 - diet\_ash)
#' }
#'
#'   
#' The resulting calculations are algebraically equivalent 
#' to the IPCC approach and fully consistent with Equation 10.24.
#'
#' This function is part of the [run_emissions_manure_module()].
#' 
#' @seealso
#'   \code{\link{run_emissions_manure_module}}
#' 
#' @examples
#' calc_volatile_solids <- calc_volatile_solids(
#'   ration_intake = 5,
#'   ration_digestibility_fraction = 0.6,
#'   ration_urinary_energy_fraction = 0.04,
#'   ration_ash = 0.08
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
    ration_intake,
    ration_digestibility_fraction,
    ration_urinary_energy_fraction,
    ration_ash
) {
  validate_calc_volatile_solids(
    ration_intake, ration_digestibility_fraction, ration_urinary_energy_fraction, ration_ash
  )

  volatile_solids <- ration_intake * (1 - ration_digestibility_fraction + ration_urinary_energy_fraction) * (1 - ration_ash)

  return(volatile_solids)
}

#' Calculate methane (CH4) emissions from manure management systems
#'
#' Calculates daily methane emissions from manure management using IPCC-based parameters and
#' separates emissions from manure deposited on pasture, manure burned for fuel, and all other manure
#' management systems.
#'
#' @param ratio_m3CH4_to_kgCH4 Numeric. Conversion factor used to convert methane (CH4) 
#' from volumetric unit (m3) to a mass unit (kg). This value represents the density of methane. It defaults to 0.67 kg/m3.
#'
#' @param volatile_solids Numeric. Total volatile solids (VS) excreted per animal per day, 
#' representing the organic material in livestock manure and consisting of both biodegradable and non-biodegradable fractions (kg VS/head/day).
#'
#' @param ... A variable number of manure management system (MMS) arguments.
#'   Each MMS must be provided as a named numeric vector with exactly the
#'   following fields:
#'   \describe{
#'     \item{manure_management_system_fraction}{
#'       Numeric. Fraction of total manure excreted by animals in a given herd
#'       and cohort that is handled in a specific manure management system.
#'       Values ranges from 0 to 1. The sum of all fractions for each herd_id
#'       must equal 1.
#'     }
#'     \item{methane_conversion_factor_mcf}{
#'       Numeric. Methane conversion factor represents the portion or degree of
#'       the maximum methane producing capacity (\eqn{B_0}) that is effectively
#'       achieved within a specific manure management system. It represents the
#'       extent to which the theoretical methane yield is realized based on
#'       management practices and environmental conditions, specifically the
#'       temperature of the system, the retention time of the organic material,
#'       and the degree of anaerobic conditions present. The value theoretically
#'       ranges from 0 to 100 percent. Default values can be selected from
#'       Table 10.17 of the IPCC guidelines (IPCC 2006, 2019).
#'     }
#'     \item{ch4_max_producing_capacity_bo}{
#'       Numeric. Maximum methane producing capacity (\eqn{B_0}) for all manure
#'       management systems (m3 CH4 / kg VS). The value is region- and
#'       species-specific, and represents the theoretical maximum methane yield 
#'       per unit of volatile solids.. Default values may be selected from Table 10.16
#'       (IPCC, 2019) or from Tables 10A-4 to 10A-9 (IPCC, 2006).
#'     }
#'   }
#'
#' Two MMS names are treated explicitly when present:
#' \describe{
#'   \item{\code{mms_pasture}}{Manure deposited on pasture.}
#'   \item{\code{mms_burned}}{Manure burned for fuel.}
#' }
#' All remaining MMS arguments are grouped and treated as other manure
#' management systems.
#'
#' @return A named list with the following elements:
#' \describe{
#'   \item{ch4_manure_pasture}{Numeric. Methane (CH4) emissions from manure deposited on pasture (kg CH4/head/day).}
#'   \item{ch4_manure_burned}{Numeric. Methane (CH4) emissions from manure burned for fuel (kg CH4/head/day).}
#'   \item{ch4_manure_other}{Numeric. Methane (CH4) emissions from manure management systems, excluding emissions from manure deposited on pasture and burned for fuel (kg CH4/head/day).}
#'   \item{ch4_manure_all_noburn}{Numeric. Methane (CH4) emissions from manure management systems, excluding manure burned for fuel (kg CH4/head/day).}
#' }
#'
#' @details
#' This calculation follows the structure of IPCC Equation 10.23 for
#' methane (CH4) emission factors from manure management.
#'
#' In the IPCC formulation, emissions are determined by combining:
#' \itemize{
#'   \item daily volatile solids excretion (\code{volatile_solids}) - see \code{\link{calc_volatile_solids}},
#'   \item the maximum methane-producing capacity (\code{b0}),
#'   \item the methane conversion factor (\code{mcf}) for each manure
#'         management system,
#'   \item and the fraction of manure handled in each system
#'         (\code{manure_management_system_fraction}).
#' }
#'
#' Applying the IPCC conversion factor from m3 CH4 to kg CH4
#' (0.67), daily methane emissions are calculated as:
#'
#' \deqn{
#'   CH4 =
#'   volatile\_solids \times b0 \times 0.67 \times
#'   \sum \left( \frac{mcf}{100} \times manure\_management\_system\_fraction \right)
#' }
#'
#' The summation is taken over all manure management systems included in
#' the calculation. Results are expressed at daily resolution
#' (kg CH4/head/day), consistent with Equation 10.23 after
#' adapting the original annual formulation to a daily basis.
#' 
#' This function is part of the [run_emissions_manure_module()].
#' 
#' @seealso
#'   \code{\link{run_emissions_manure_module}},
#'   \code{\link{calc_volatile_solids}}
#'
#' @examples
#' calc_ch4_manure(
#'   ratio_m3CH4_to_kgCH4 = 0.67,
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
#' This function is part of the [run_emissions_manure_module()].
#' 
#' @seealso
#'   \code{\link{run_emissions_manure_module}},
#'   \code{\link{calc_volatile_solids}}
#'
#' @references
#' IPCC. (2019). \emph{2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions from
#' Livestock and Manure Management. Equation 10.23.
#'
#' IPCC. (2006). \emph{2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions from
#' Livestock and Manure Management. Equation 10.23.
#' @export

calc_ch4_manure <- function(
    ratio_m3CH4_to_kgCH4 = 0.67,
    volatile_solids,
    ...
) {
  # Enforce configured bounds
  validate_param_range(ratio_m3CH4_to_kgCH4)
  validate_param_range(volatile_solids)

  mms_list <- list(...)

  validate_mms_inputs(
    mms_list,
    required_names = c(
      "manure_management_system_fraction",
      "methane_conversion_factor_mcf",
      "ch4_max_producing_capacity_bo"
    ),
    ratio_m3CH4_to_kgCH4 = ratio_m3CH4_to_kgCH4,
    volatile_solids   = volatile_solids
  )

  # split special (burned and pasture) vs other MMS
  mms_pasture <- mms_list[["mms_pasture"]]
  mms_burned <- mms_list[["mms_burned"]]
  mms_other <- mms_list[setdiff(names(mms_list), c("mms_pasture", "mms_burned"))]

  # pasture
  ch4_manure_pasture <- if (is.null(mms_pasture)) 0 else
    volatile_solids * ratio_m3CH4_to_kgCH4 *
    mms_pasture[["manure_management_system_fraction"]] *
    (mms_pasture[["methane_conversion_factor_mcf"]] / 100) *
    mms_pasture[["ch4_max_producing_capacity_bo"]]

  # burned
  ch4_manure_burned <- if (is.null(mms_burned)) 0 else
    volatile_solids * ratio_m3CH4_to_kgCH4 *
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
    volatile_solids * ratio_m3CH4_to_kgCH4 * sum(other_term) / 100
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

#' Calculate direct Nitrous Oxide (N2O) emissions from manure management systems
#'
#' Calculates daily direct nitrous oxide (N2O) emissions from manure management
#' using IPCC-based parameters and separates emissions from manure deposited on pasture,
#' manure burned for fuel, and all other manure management systems.
#'
#' @param ratio_N2ON_to_N2O Numeric. Conversion factor from kg N2O–N to kg N2O,
#'   based on molecular weights. Defaults to 44/28.
#'
#' @param nitrogen_excretion Numeric. Daily nitrogen excretion
#'   (kg N/head/day).
#'
#' @param ... A variable number of manure management system (MMS) arguments.
#'   Each MMS must be provided as a named numeric vector with exactly the
#'   following fields:
#'   \describe{
#'     \item{manure_management_system_fraction}{
#'       Numeric. Fraction of total manure excreted by animals in a given
#'       herd and cohort that is handled in a specific manure management
#'       system. Value ranges from 0 to 1. The sum of all fractions for each herd_id must equal 1.
#'     }
#'     \item{n2o_ef3}{
#'       Numeric. Emission factor for direct nitrous oxide (N2O)
#'       emissions for each manure management system, representing
#'       nitrous oxide emitted per unit of nitrogen from nitrification
#'       and denitrification processes occurring during manure storage
#'       and treatment (kg N2O–N per kg N).
#'       Default values may be selected from Table 10.21 and Table 11.1
#'       (for manure deposited on pasture) in IPCC Guidelines (IPCC 2006, 2019).
#'     }
#'   }
#'
#' Two MMS names are treated explicitly when present:
#' \describe{
#'   \item{\code{mms_pasture}}{Manure deposited on pasture.}
#'   \item{\code{mms_burned}}{Manure burned for fuel.}
#' }
#' All remaining MMS arguments are grouped and treated as other manure
#' management systems.
#'
#' @return A named list with the following elements:
#' \describe{
#'   \item{n2o_manure_pasture_direct}{
#'     Numeric. Direct nitrous oxide (N2O) emissions from manure
#'     deposited on pasture (kg N2O/head/day).
#'   }
#'   \item{n2o_manure_burned_direct}{
#'     Numeric. Direct nitrous oxide (N2O) emissions from manure
#'     burned for fuel (kg N2O/head/day).
#'   }
#'   \item{n2o_manure_other_direct}{
#'     Numeric. Direct nitrous oxide (N2O) emissions from manure
#'     management systems, excluding emissions from manure deposited
#'     on pasture and burned for fuel (kg N2O/head/day).
#'   }
#'   \item{n2o_manure_all_noburn_direct}{
#'     Numeric. Direct nitrous oxide (N2O) emissions from manure
#'     management systems, excluding manure burned for fuel
#'     (kg N2O/head/day).
#'   }
#' }
#'
#'
#' @examples
#' calc_n2o_manure_direct(
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
#' @details
#' This calculation follows the Tier 2 methodology for direct
#' nitrous oxide (N2O) emissions from manure management as defined
#' in the IPCC Guidelines (Equation 10.25).
#'
#' In the IPCC formulation, annual direct emissions are:
#'
#' \deqn{
#'   N2O_{D(mm)} =
#'   \frac{44}{28}
#'   \sum_{S} \left(
#'     N \times AWMS_S \times EF3_S
#'   \right)
#' }
#'
#' where:
#' \describe{
#'   \item{\eqn{N2O_D(mm)}}{Direct N2O emissions from Manure Management.}
#'   \item{\eqn{44/28}}{Conversion factor from N2O–N to N2O.}
#'   \item{\eqn{N}}{Nitrogen excreted (kg N).}
#'   \item{\eqn{AWMS_S}}{Fraction of excreted nitrogen managed in manure
#'     management system \eqn{S}.}
#'   \item{\eqn{EF3_S}}{Direct emission factor for system \eqn{S}
#'     (kg N2O–N per kg N managed).}
#' }
#'
#' In this implementation, calculations are performed at daily,
#' per-head resolution using \code{nitrogen_excretion}
#' (kg N/head/day) - see also \code{\link{calc_nitrogen_excretion}}.
#' 
#' Daily emissions are computed as:
#'
#' \deqn{
#' \begin{aligned}
#' N2O &= nitrogen\_excretion \times ratio\_N2ON\_to\_N2O \times \\
#' & \sum \left(
#' manure\_management\_system\_fraction \times n2o\_ef3
#' \right)
#' \end{aligned}
#' }
#' 
#' This function is part of the [run_emissions_manure_module()].
#' 
#' @seealso
#'   \code{\link{run_emissions_manure_module}}
#' 
#' @references
#' IPCC. (2019). \emph{2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions from
#' Livestock and Manure Management. Equation 10.25.
#'
#' IPCC. (2006). \emph{2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions from
#' Livestock and Manure Management. Equation 10.25.
#' 
#' @export
calc_n2o_manure_direct <- function(
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

#' Calculate indirect Nitrous Oxide (N2O) emissions from manure volatilization
#'
#' Calculates daily indirect nitrous oxide (N2O) emissions resulting from
#' atmospheric deposition of volatilised nitrogen (NH3–N and NOx–N) from manure
#' management systems and separates emissions from manure deposited on pasture, manure burned for fuel, and
#' all other manure management systems.
#'
#' @param ratio_N2ON_to_N2O Numeric. Conversion factor from kg N2O–N to kg N2O,
#'   based on molecular weights. Defaults to 44/28.
#'
#' @param nitrogen_excretion Numeric. Daily nitrogen excretion
#'   (kg N/head/day).
#'
#' @param ... A variable number of manure management system (MMS) arguments.
#'   Each MMS must be provided as a named numeric vector with exactly the
#'   following fields:
#'   \describe{
#'     \item{manure_management_system_fraction}{
#'       Numeric. Fraction of total manure excreted by animals in a given herd
#'       and cohort that is handled in a specific manure management system.
#'       Values ranges from 0 to 1. The sum of all fractions for each herd_id
#'       must equal 1.
#'     }
#'     \item{n2o_ef4}{
#'       Numeric. Emission factor for indirect nitrous oxide (N2O) emissions
#'       resulting from atmospheric deposition of volatilised nitrogen
#'       (NH3–N and NOx–N) onto soils and water surfaces
#'       (kg N2O–N per kg NH3–N + NOx–N).
#'       Default values can be selected from Table 11.3 in IPCC Guidelines (IPCC 2006, 2019).
#'     }
#'     \item{nitrogen_fracgas}{
#'       Numeric. Fraction of manure nitrogen excreted by a given livestock
#'       category that is lost through volatilisation as ammonia (NH3)
#'       and nitrogen oxides (NOx) within a specific manure management system.
#'       This parameter represents the share of excreted nitrogen that is
#'       mineralised and released to the atmosphere during manure collection,
#'       storage, and treatment. It is expressed as a dimensionless fraction
#'       (0–1). Default values are provided in Table 10.22 of IPCC Guidelines (IPCC 2006, 2019).
#'     }
#'   }
#'
#' Two MMS names are treated explicitly when present:
#' \describe{
#'   \item{\code{mms_pasture}}{Manure deposited on pasture.}
#'   \item{\code{mms_burned}}{Manure burned for fuel.}
#' }
#' All remaining MMS arguments are grouped and treated as other manure
#' management systems.
#'
#' @return A named list with the following elements:
#' \describe{
#'   \item{n2o_manure_pasture_vol}{
#'     Numeric. Indirect nitrous oxide (N2O) emissions resulting from
#'     atmospheric deposition of volatilised nitrogen (NH3 and NOx)
#'     from manure deposited on pasture (kg N2O/head/day).
#'   }
#'   \item{n2o_manure_burned_vol}{
#'     Numeric. Indirect nitrous oxide (N2O) emissions resulting from
#'     atmospheric deposition of volatilised nitrogen (NH3 and NOx)
#'     from manure burned for fuel (kg N2O/head/day).
#'   }
#'   \item{n2o_manure_other_vol}{
#'     Numeric. Indirect nitrous oxide (N2O) emissions resulting from
#'     atmospheric deposition of volatilised nitrogen (NH3 and NOx)
#'     from manure management systems, excluding manure deposited on
#'     pasture and manure burned for fuel (kg N2O/head/day).
#'   }
#'   \item{n2o_manure_all_noburn_vol}{
#'     Numeric. Indirect nitrous oxide (N2O) emissions resulting from
#'     atmospheric deposition of volatilised nitrogen (NH3 and NOx)
#'     from manure management systems, excluding losses from manure
#'     burned for fuel (kg N2O/head/day).
#'   }
#' }
#'
#' @examples
#' calc_n2o_manure_volatilization(
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
#' 
#' @details
#' This calculation follows the Tier 2 methodology for indirect N2O 
#' emissions from manure management as defined in the IPCC Guidelines in Equations 10.26 (IPCC, 2006, 2019), 
#' 10.27 (IPCC, 2006) and 10.28 (IPCC, 2019).
#'
#' In the IPCC formulation, indirect emissions from atmospheric deposition
#' of volatilised nitrogen are calculated as:
#'
#' \deqn{
#'   N2O_{G(mm)} =
#'   \frac{44}{28}
#'   \sum_{S} \left(
#'     N \times AWMS_S \times FracGas_{S} \times EF4
#'   \right)
#' }
#'
#' where:
#' \describe{
#'   \item{\eqn{N2O_G(mm)}}{Indirect N2O emissions due to volatilization of N from Manure Management.}
#'   \item{\eqn{44/28}}{Conversion factor from N2O-N to N2O.}
#'   \item{\eqn{N}}{Nitrogen excreted (kg N).}
#'   \item{\eqn{AWMS_S}}{Fraction of excreted nitrogen managed in manure
#'     management system \eqn{S}.}
#'   \item{\eqn{FracGas_{S}}}{Fraction of nitrogen volatilised as NH3–N and NOx–N in manure management system \eqn{S}.}
#'   \item{\eqn{EF4}}{Emission factor for indirect N2O emissions from atmospheric deposition (kg N2O-N per kg NH3–N + NOx–N).}
#' }
#'
#' In this implementation, calculations are performed at daily,
#' per-head resolution using \code{nitrogen_excretion}
#' (kg N/head/day):
#'
#' \deqn{
#' \begin{aligned}
#' N_2O &= nitrogen\_excretion \times ratio\_N2ON\_to\_N2O \times \\
#' & \sum_{S} \left(
#' manure\_management\_system\_fraction \times
#' nitrogen\_fracgas \times
#' n2o\_ef4
#' \right)
#' \end{aligned}
#' }
#' 
#' This function is part of the [run_emissions_manure_module()].
#' 
#' @seealso
#'   \code{\link{run_emissions_manure_module}}
#' 
#' @references
#' IPCC. (2019). \emph{2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions from
#' Livestock and Manure Management. Equation 10.26; 10.28.
#'
#' IPCC. (2006). \emph{2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions from
#' Livestock and Manure Management. Equation 10.26; 10.27.
#' 
#' @export
calc_n2o_manure_volatilization <- function(
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
  n2o_manure_pasture_vol <- if (is.null(mms_pasture)) 0 else
    nitrogen_excretion * ratio_N2ON_to_N2O *
    mms_pasture[["manure_management_system_fraction"]] * mms_pasture[["nitrogen_fracgas"]] *
    mms_pasture[["n2o_ef4"]]

  # burned
  n2o_manure_burned_vol <- if (is.null(mms_burned)) 0 else
    nitrogen_excretion * ratio_N2ON_to_N2O *
    mms_burned[["manure_management_system_fraction"]] * mms_burned[["nitrogen_fracgas"]] *
    mms_burned[["n2o_ef4"]]

  # all other MMS (scalar product)
  n2o_manure_other_vol <- if (length(mms_other) == 0) 0 else {

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
  n2o_manure_all_noburn_vol <- n2o_manure_pasture_vol + n2o_manure_other_vol

  return(
    list(
      n2o_manure_pasture_vol = n2o_manure_pasture_vol,
      n2o_manure_burned_vol = n2o_manure_burned_vol,
      n2o_manure_other_vol = n2o_manure_other_vol,
      n2o_manure_all_noburn_vol = n2o_manure_all_noburn_vol
    )
  )
}

#' Calculate indirect Nitrous Oxide (N2O) emissions from manure leaching and runoff
#'
#' Calculates daily indirect nitrous oxide (N2O) emissions resulting from nitrogen
#' leaching and runoff from manure management systems and separates emissions
#' from manure deposited on pasture, manure burned for fuel, and all other manure management systems.
#'
#' @param ratio_N2ON_to_N2O Numeric. Conversion factor from kg N2O–N to kg N2O,
#'   based on molecular weights. Defaults to 44/28.
#'
#' @param nitrogen_excretion Numeric. Daily nitrogen excretion
#'   (kg N/head/day).
#'
#' @param ... A variable number of manure management system (MMS) arguments.
#'   Each MMS must be provided as a named numeric vector with exactly the
#'   following fields:
#'   \describe{
#'     \item{manure_management_system_fraction}{
#'       Numeric. Fraction of total manure excreted by animals in a given herd
#'       and cohort that is handled in a specific manure management system.
#'       Values ranges from 0 to 1. The sum of all fractions for each herd_id
#'       must equal 1.
#'     }
#'     \item{n2o_ef5}{
#'       Numeric. Emission factor for indirect nitrous oxide (N2O) emissions
#'       resulting from nitrogen leaching and runoff, expressed as kilograms of
#'       N2O–N per kilogram of nitrogen leached or lost through runoff
#'       (kg N2O–N / kg N). Default values can be selected from Table 11.3 in 
#'       IPCC Guidelines (IPCC 2006, 2019).
#'     }
#'     \item{nitrogen_fracleach}{
#'       Numeric. Fraction of manure nitrogen excreted by a given livestock
#'       category that is lost through leaching and runoff from a specific manure
#'       management system. This parameter is highly uncertain and is used to
#'       estimate indirect N2O emissions from nitrogen that enters the surrounding
#'       environment of the storage facility. It is expressed as a dimensionless
#'       fraction (0–1). Default values are provided in Table 10.22 of 
#'       IPCC Guidelines (IPCC 2006, 2019).
#'     }
#'   }
#'
#' Two MMS names are treated explicitly when present:
#' \describe{
#'   \item{\code{mms_pasture}}{Manure deposited on pasture.}
#'   \item{\code{mms_burned}}{Manure burned for fuel.}
#' }
#' All remaining MMS arguments are grouped and treated as other manure
#' management systems.
#'
#' @return A named list with the following elements
#' \describe{
#'   \item{n2o_manure_pasture_leach}{
#'     Numeric. Indirect nitrous oxide (N2O) emissions resulting from leaching and
#'     runoff of manure nitrogen from manure deposited on pasture
#'     (kg N2O/head/day).
#'   }
#'   \item{n2o_manure_burned_leach}{
#'     Numeric. Indirect nitrous oxide (N2O) emissions resulting from leaching and
#'     runoff of manure nitrogen from manure burned for fuel
#'     (kg N2O/head/day).
#'   }
#'   \item{n2o_manure_other_leach}{
#'     Numeric. Indirect nitrous oxide (N2O) emissions resulting from leaching and
#'     runoff of manure nitrogen from manure management systems, excluding losses
#'     from manure deposited on pasture and manure burned for fuel
#'     (kg N2O/head/day).
#'   }
#'   \item{n2o_manure_all_noburn_leach}{
#'     Numeric. Indirect nitrous oxide (N2O) emissions resulting from leaching and
#'     runoff of manure nitrogen from manure management systems, excluding losses
#'     from manure burned for fuel (kg N2O/head/day).
#'   }
#' }
#'
#' @examples
#' calc_n2o_manure_leaching(
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
#' 
#' @details
#' This calculation follows the Tier 2 methodology for indirect N2O emissions
#' from manure management as defined in Equations 10.28 (IPCC, 2006), 10.27 (IPCC, 2019), 
#' and 10.29 (IPCC, 2006, 2019).
#'
#' In the IPCC formulation, indirect emissions associated with nitrogen leaching
#' and runoff are calculated as:
#'
#' \deqn{
#'   N2O_{L(mm)} =
#'   \frac{44}{28}
#'   \sum_{S} \left(
#'     N \times AWMS_S  \times FracLeach_{S} \times EF5
#'   \right)
#' }
#'
#' where:
#' \describe{
#'   \item{\eqn{N2O_L(mm)}}{Indirect N2O emissions due to leaching and runoff from Manure Management.}
#'   \item{\eqn{44/28}}{Conversion factor from N2O–N to N2O.}
#'   \item{\eqn{N}}{Nitrogen excreted (kg N).}
#'   \item{\eqn{AWMS_S}}{Fraction of excreted nitrogen managed in manure
#'     management system \eqn{S}.}
#'   \item{\eqn{FracLeach_{S}}}{Fraction of nitrogen lost through leaching and runoff in manure management system \eqn{S}.}
#'   \item{\eqn{EF5}}{Emission factor for indirect N2O emissions from leaching and runoff (kg N2O–N per kg N leached or lost through runoff).}
#' }
#'
#' In this implementation, calculations are performed at daily, per-head
#' resolution using \code{nitrogen_excretion} (kg N/head/day):
#'
#' \deqn{
#' \begin{aligned}
#' N_2O &= nitrogen\_excretion \times ratio\_N2ON\_to\_N2O \times \\
#' & \sum_{S} \left(
#' manure\_management\_system\_fraction \times
#' nitrogen\_fracleach \times
#' n2o\_ef5
#' \right)
#' \end{aligned}
#' }
#'
#' This function is part of the [run_emissions_manure_module()].
#' 
#' @seealso
#'   \code{\link{run_emissions_manure_module}}
#'
#' @references
#' IPCC. (2019). \emph{2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories},
#' Chapter 10: Emissions from Livestock and Manure Management. Equations 10.27; 10.29.
#'
#' IPCC. (2006). \emph{2006 IPCC Guidelines for National Greenhouse Gas Inventories},
#' Volume 4, Chapter 10: Emissions from Livestock and Manure Management. Equations 10.28; 10.29.
#' @export
calc_n2o_manure_leaching <- function(
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
  n2o_manure_pasture_leach <- if (is.null(mms_pasture)) 0 else
    nitrogen_excretion * ratio_N2ON_to_N2O *
    mms_pasture[["manure_management_system_fraction"]] * mms_pasture[["nitrogen_fracleach"]] *
    mms_pasture[["n2o_ef5"]]

  # burned
  n2o_manure_burned_leach <- if (is.null(mms_burned)) 0 else
    nitrogen_excretion * ratio_N2ON_to_N2O *
    mms_burned[["manure_management_system_fraction"]] * mms_burned[["nitrogen_fracleach"]] *
    mms_burned[["n2o_ef5"]]

  # all other MMS (scalar product)
  n2o_manure_other_leach <- if (length(mms_other) == 0) 0 else {

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
  n2o_manure_all_noburn_leach <- n2o_manure_pasture_leach + n2o_manure_other_leach

  return(
    list(
      n2o_manure_pasture_leach = n2o_manure_pasture_leach,
      n2o_manure_burned_leach = n2o_manure_burned_leach,
      n2o_manure_other_leach = n2o_manure_other_leach,
      n2o_manure_all_noburn_leach = n2o_manure_all_noburn_leach
    )
  )
}

#' Calculate total Nitrous Oxide (N2O) emissions from manure
#'
#' Aggregates direct and indirect nitrous oxide (N2O) emissions from manure, by
#' manure management system group (deposited on pasture, burned for fuel, and all other systems). 
#' Indirect emissions include contributions from volatilization and from leaching
#' and runoff.
#'
#' @param n2o_manure_pasture_vol Numeric. Indirect nitrous oxide (N2O) emissions
#'   resulting from atmospheric deposition of volatilised nitrogen (NH3 and NOx)
#'   from manure deposited on pasture (kg N2O/head/day).
#' @param n2o_manure_pasture_leach Numeric. Indirect nitrous oxide (N2O) emissions
#'   resulting from leaching and runoff of manure nitrogen from manure deposited on
#'   pasture (kg N2O/head/day).
#' @param n2o_manure_burned_vol Numeric. Indirect nitrous oxide (N2O) emissions
#'   resulting from atmospheric deposition of volatilised nitrogen (NH3 and NOx)
#'   from manure burned for fuel (kg N2O/head/day).
#' @param n2o_manure_burned_leach Numeric. Indirect nitrous oxide (N2O) emissions
#'   resulting from leaching and runoff of manure nitrogen from manure burned for
#'   fuel (kg N2O/head/day).
#' @param n2o_manure_other_vol Numeric. Indirect nitrous oxide (N2O) emissions
#'   resulting from atmospheric deposition of volatilised nitrogen (NH3 and NOx)
#'   from manure management systems, excluding manure deposited on pasture and
#'   manure burned for fuel (kg N2O/head/day).
#' @param n2o_manure_other_leach Numeric. Indirect nitrous oxide (N2O) emissions
#'   resulting from leaching and runoff of manure nitrogen from manure management
#'   systems, excluding losses from manure deposited on pasture and manure burned
#'   for fuel (kg N2O/head/day).
#' @param n2o_manure_pasture_direct Numeric. Direct nitrous oxide (N2O) emissions
#'   from manure deposited on pasture (kg N2O/head/day).
#' @param n2o_manure_burned_direct Numeric. Direct nitrous oxide (N2O) emissions
#'   from manure burned for fuel (kg N2O/head/day).
#' @param n2o_manure_other_direct Numeric. Direct nitrous oxide (N2O) emissions
#'   from manure management systems, excluding emissions from manure deposited on
#'   pasture and burned for fuel (kg N2O/head/day).
#'
#' @details
#' The following aggregations are applied:
#' \deqn{
#'   n2o\_manure\_pasture\_indirect =
#'   n2o\_vol\_manure\_pasture + n2o\_leach\_manure\_pasture
#' }
#' \deqn{
#'   n2o\_manure\_burned\_indirect =
#'   n2o\_vol\_manure\_burned + n2o\_leach\_manure\_burned
#' }
#' \deqn{
#'   n2o\_manure\_other\_indirect =
#'   n2o\_vol\_manure\_other + n2o\_leach\_manure\_other
#' }
#' \deqn{
#'   n2o\_manure\_pasture\_total =
#'   n2o\_manure\_pasture\_indirect + n2o\_manure\_pasture\_direct
#' }
#' \deqn{
#'   n2o\_manure\_burned\_total =
#'   n2o\_manure\_burned\_indirect + n2o\_manure\_burned\_direct
#' }
#' \deqn{
#'   n2o\_manure\_other\_total =
#'   n2o\_manure\_other\_indirect + n2o\_manure\_other\_direct
#' }
#'
#' @return A named list with:
#' \describe{
#'   \item{n2o_manure_pasture_indirect}{
#'     Numeric. Total indirect nitrous oxide (N2O) emissions from manure deposited
#'     on pasture. Includes emissions from atmospheric deposition of volatilised
#'     nitrogen (NH3 and NOx) and from leaching and runoff of manure nitrogen
#'     (kg N2O/head/day).
#'   }
#'   \item{n2o_manure_burned_indirect}{
#'     Numeric. Total indirect nitrous oxide (N2O) emissions originating from
#'     manure burned for fuel. Includes emissions from atmospheric deposition of
#'     volatilised nitrogen (NH3 and NOx) and from leaching and runoff of manure
#'     nitrogen (kg N2O/head/day).
#'   }
#'   \item{n2o_manure_other_indirect}{
#'     Numeric. Total indirect nitrous oxide (N2O) emissions originating from
#'     manure management systems, excluding manure deposited on pasture and
#'     manure burned for fuel. Includes emissions from atmospheric deposition of
#'     volatilised nitrogen (NH3 and NOx) and from leaching and runoff of manure
#'     nitrogen (kg N2O/head/day).
#'   }
#'   \item{n2o_manure_pasture_total}{
#'     Numeric. Total nitrous oxide (N2O) emissions from manure deposited on
#'     pasture. Includes direct emissions and indirect emissions from
#'     volatilisation, leaching, and runoff (kg N2O/head/day).
#'   }
#'   \item{n2o_manure_burned_total}{
#'     Numeric. Total nitrous oxide (N2O) emissions from manure burned for fuel.
#'     Includes direct emissions and indirect emissions from volatilisation,
#'     leaching, and runoff (kg N2O/head/day).
#'   }
#'   \item{n2o_manure_other_total}{
#'     Numeric. Total nitrous oxide (N2O) emissions from manure management
#'     systems, excluding manure deposited on pasture and manure burned for fuel.
#'     Includes direct emissions and indirect emissions from volatilisation,
#'     leaching, and runoff (kg N2O/head/day).
#'   }
#' }
#'
#' This function is part of the [run_emissions_manure_module()].
#' 
#' @examples
#' calc_n2o_manure_total(
#'   n2o_manure_pasture_vol = 0.0129,
#'   n2o_manure_pasture_leach = 0.0012,
#'   n2o_manure_burned_vol = 0,
#'   n2o_manure_burned_leach = 0,
#'   n2o_manure_other_vol = 0.052,
#'   n2o_manure_other_leach = 0.00027,
#'   n2o_manure_pasture_direct = 0.009,
#'   n2o_manure_burned_direct = 0,
#'   n2o_manure_other_direct = 0.01033
#' )
#' 
#' @seealso
#'   \code{\link{run_emissions_manure_module}}
#'
#' @export
calc_n2o_manure_total <- function(
    n2o_manure_pasture_vol,
    n2o_manure_pasture_leach,
    n2o_manure_burned_vol,
    n2o_manure_burned_leach,
    n2o_manure_other_vol,
    n2o_manure_other_leach,
    n2o_manure_pasture_direct,
    n2o_manure_burned_direct,
    n2o_manure_other_direct
) {
  validate_calc_n2o_manure_total(
    n2o_manure_pasture_vol = n2o_manure_pasture_vol,
    n2o_manure_pasture_leach = n2o_manure_pasture_leach,
    n2o_manure_burned_vol = n2o_manure_burned_vol,
    n2o_manure_burned_leach = n2o_manure_burned_leach,
    n2o_manure_other_vol = n2o_manure_other_vol,
    n2o_manure_other_leach = n2o_manure_other_leach,
    n2o_manure_pasture_direct = n2o_manure_pasture_direct,
    n2o_manure_burned_direct = n2o_manure_burned_direct,
    n2o_manure_other_direct = n2o_manure_other_direct
  )

  # indirect components
  n2o_manure_pasture_indirect <- n2o_manure_pasture_vol + n2o_manure_pasture_leach
  n2o_manure_burned_indirect <- n2o_manure_burned_vol + n2o_manure_burned_leach
  n2o_manure_other_indirect <- n2o_manure_other_vol + n2o_manure_other_leach

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
