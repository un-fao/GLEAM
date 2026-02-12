#' Calculate Volatile Solids for Manure Emissions
#'
#' Computes daily volatile solids (VS) excretion in manure (kg VS head⁻¹ day⁻¹).
#' VS represent the organic fraction of manure dry matter,
#' including both biodegradable and non-biodegradable organic material.
#' VS is a key intermediate variable required for estimating methane (CH₄)
#' emissions from manure management systems under IPCC methodologies.
#'
#' @param dry_matter_intake Numeric. Average daily dry matter intake of feed (kg dry matter/head/day).
#' @param diet_digestibility_fraction Numeric. Average digestibility of the the feed ration, expressed as ratio of digestible to gross energy content (fraction).
#' @param urinary_energy_fraction Numeric. Fraction of feed's gross energy that is excreted in urine (fraction).
#' @param diet_ash Numeric. Average ash content of feed, calculated as a fraction of the dry matter intake (kg ash/kg DM).
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
#' * Gross energy intake (gross_energy_intake, MJ day⁻¹)
#' * Digestibility of the diet (diet_digestibility_fraction)
#' * Urinary energy expressed as a fraction of GE (urinary_energy_fraction)
#' * Ash fraction of the diet (diet_ash, fraction of dry matter)
#' * A conversion factor representing the average gross energy content of
#'   dry matter (18.45 MJ kg⁻¹ DM)
#'
#' The general structure of Eq. 10.24 partitions gross energy intake into
#' digestible energy, urinary losses, and ash, and converts the remaining
#' organic matter into volatile solids using the energy density of dry matter.
#'
#' **Implementation note.**
#' This function applies an algebraically simplified formulation from Equation 10.24 of IPCC.
#'
#' In this implementation, the function takes \code{dry_matter_intake} directly
#' as an input. It can be calculated upstream with
#' \code{\link{calc_dry_matter_intake}} as a function of energy requirements and
#' the energy content of the diet.
#'
#' This reflects the use of ration-specific energy content upstream and avoids
#' assuming a fixed gross energy density of 18.45 MJ kg⁻¹ DM, as in the IPCC
#' default approach.
#'
#' \deqn{
#'   dry\_matter\_intake = \frac{gross\_energy\_intake}{diet\_gross\_energy}
#' }
#'
#' The volatile solids excretion is then calculated as:
#'
#' \deqn{
#'   volatile\_solids =
#'   dry\_matter\_intake \times (1 - diet\_digestibility\_fraction + urinary\_energy\_fraction)
#'   \times (1 - diet\_ash)
#' }
#'
#'   
#' The resulting calculations are algebraically equivalent 
#' to the IPCC approach and fully consistent with Equation 10.24.
#'
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
    urinary_energy_fraction,
    diet_ash
) {
  validate_calc_volatile_solids(
    dry_matter_intake, diet_digestibility_fraction, urinary_energy_fraction, diet_ash
  )

  volatile_solids <- dry_matter_intake * (1 - diet_digestibility_fraction + urinary_energy_fraction) * (1 - diet_ash)

  return(volatile_solids)
}

#' Calculate methane (CH₄) emissions from manure management systems
#'
#' Computes daily methane emissions from manure management using IPCC-based parameters and
#' separates emissions from pasture, burned manure, and all other manure
#' management systems.
#'
#' @param ratio_m3CH4_to_kgCH4 Numeric. Conversion factor used to convert methane (CH₄) from volumetric unit (m³) to a mass unit (kg). This value represents the density of methane. It defaults to 0.67 kg/m³.
#'
#' @param volatile_solids Numeric. Total volatile solids (VS) excreted per animal per day, representing the organic material in livestock manure and consisting of both biodegradable and non-biodegradable fractions (kg VS/head/day).
#'
#' @param ... A variable number of manure management system (MMS) arguments.
#'   Each MMS must be provided as a named numeric vector with exactly the
#'   following fields:
#'   \describe{
#'     \item{manure_management_system_fraction}{
#'       Numeric. Fraction of total manure excreted by animals in a given herd
#'       and cohort that is handled in a specific manure management system.
#'       Values range from 0 to 1. The sum of all fractions for each herd_id
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
#'       Table 10.17 of the IPCC guidelines.
#'     }
#'     \item{ch4_max_producing_capacity_bo}{
#'       Numeric. Maximum methane producing capacity (\eqn{B_0}) for all manure
#'       management systems (m³ CH₄ kg⁻¹ VS). The value is region- and
#'       species-specific. Default values may be selected from Table 10.16
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
#' @return A named list with the following elements (kg CH₄ head⁻¹ day⁻¹):
#' \describe{
#'   \item{ch4_manure_pasture}{Numeric. Methane (CH₄) emissions from manure deposited on pasture (kg CH₄ head⁻¹ day⁻¹).}
#'   \item{ch4_manure_burned}{Numeric. Methane (CH₄) emissions from manure burned for fuel (kg CH₄ head⁻¹ day⁻¹).}
#'   \item{ch4_manure_other}{Numeric. Methane (CH₄) emissions from manure management systems, excluding emissions from manure deposited on pasture and burned for fuel (kg CH₄ head⁻¹ day⁻¹).}
#'   \item{ch4_manure_all_noburn}{Numeric. Methane (CH₄) emissions from manure management systems, excluding manure burned for fuel (kg CH₄ head⁻¹ day⁻¹).}
#' }
#'
#' @details
#' This calculation follows the structure of IPCC Equation 10.23 for
#' methane CH₄ emission factors from manure management.
#'
#' In the IPCC formulation, emissions are determined by combining:
#' \itemize{
#'   \item daily volatile solids excretion (\code{volatile_solids}),
#'   \item the maximum methane-producing capacity (\code{b0}),
#'   \item the methane conversion factor (\code{mcf}) for each manure
#'         management system,
#'   \item and the fraction of manure handled in each system
#'         (\code{manure_management_system_fraction}).
#' }
#'
#' Applying the IPCC conversion factor from m³ CH₄ to kg CH₄
#' (0.67), daily methane emissions are calculated as:
#'
#' \deqn{
#'   CH₄ =
#'   volatile\_solids \times b0 \times 0.67 \times
#'   \sum \left( \frac{mcf}{100} \times manure\_management\_system\_fraction \right)
#' }
#'
#' where:
#' \describe{
#'   \item{\code{b0}}{
#'     Maximum methane-producing capacity
#'     (m³ CH₄ kg⁻¹ VS), representing the theoretical maximum
#'     methane yield per unit of volatile solids.
#'   }
#'   \item{\code{mcf}}{
#'     Methane conversion factor (percent), representing the proportion
#'     of \code{b0} achieved under the specified manure management system
#'     and climate conditions.
#'   }
#' }
#'
#' The summation is taken over all manure management systems included in
#' the calculation. Results are expressed at daily resolution
#' (kg CH₄ head⁻¹ day⁻¹), consistent with Equation 10.23 after
#' adapting the original annual formulation to a daily basis.
#'
#' @examples
#' calc_ch4_emissions(
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
#' @references
#' IPCC. (2019). \emph{2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions from
#' Livestock and Manure Management. Equation 10.23.
#'
#' IPCC. (2006). \emph{2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions from
#' Livestock and Manure Management. Equation 10.23.
#' @export

calc_ch4_emissions <- function(
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

#' Calculate direct Nitrous Oxide (N₂O) emissions from manure management systems
#'
#' Computes daily direct nitrous oxide (N₂O) emissions from manure management
#' using IPCC-based parameters and separates emissions from pasture,
#' burned manure, and all other manure management systems.
#'
#' @param ratio_N2ON_to_N2O Numeric. Conversion factor from kg N₂O–N to kg N₂O,
#'   based on molecular weights. Defaults to 44/28.
#'
#' @param nitrogen_excretion Numeric. Daily nitrogen excretion
#'   (kg N head⁻¹ day⁻¹).
#'
#' @param ... A variable number of manure management system (MMS) arguments.
#'   Each MMS must be provided as a named numeric vector with exactly the
#'   following fields:
#'   \describe{
#'     \item{manure_management_system_fraction}{
#'       Numeric. Fraction of total manure excreted by animals in a given
#'       herd and cohort that is handled in a specific manure management
#'       system (0–1). The sum of all fractions for each herd_id must equal 1.
#'     }
#'     \item{n2o_ef3}{
#'       Numeric. Emission factor for direct nitrous oxide (N₂O)
#'       emissions for each manure management system, representing
#'       nitrous oxide emitted per unit of nitrogen from nitrification
#'       and denitrification processes occurring during manure storage
#'       and treatment (kg N₂O–N per kg N).
#'       Default values may be selected from Table 10.21 and Table 11.1
#'       (for manure deposited on pasture) in the 2006 and 2019 IPCC Guidelines.
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
#'   (kg N₂O head⁻¹ day⁻¹):
#' \describe{
#'   \item{n2o_manure_pasture_direct}{
#'     Numeric. Direct nitrous oxide (N₂O) emissions from manure
#'     deposited on pasture (kg N₂O head⁻¹ day⁻¹).
#'   }
#'   \item{n2o_manure_burned_direct}{
#'     Numeric. Direct nitrous oxide (N₂O) emissions from manure
#'     burned for fuel (kg N₂O head⁻¹ day⁻¹).
#'   }
#'   \item{n2o_manure_other_direct}{
#'     Numeric. Direct nitrous oxide (N₂O) emissions from manure
#'     management systems, excluding emissions from manure deposited
#'     on pasture and burned for fuel (kg N₂O head⁻¹ day⁻¹).
#'   }
#'   \item{n2o_manure_all_noburn_direct}{
#'     Numeric. Direct nitrous oxide (N₂O) emissions from manure
#'     management systems, excluding manure burned for fuel
#'     (kg N₂O head⁻¹ day⁻¹).
#'   }
#' }
#'
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
#' @details
#' This calculation follows the Tier 2 methodology for direct
#' nitrous oxide (N₂O) emissions from manure management as defined
#' in the IPCC Guidelines (Equation 10.25).
#'
#' In the IPCC formulation, annual direct emissions are:
#'
#' \deqn{
#'   N₂O_{D,mm} =
#'   \frac{44}{28}
#'   \sum \left(
#'     N \times AWMS_S \times EF3_S
#'   \right)
#' }
#'
#' where:
#' \describe{
#'   \item{\eqn{44/28}}{Conversion factor from N₂O–N to N₂O.}
#'   \item{\eqn{N}}{Nitrogen excreted (kg N).}
#'   \item{\eqn{AWMS_S}}{Fraction of excreted nitrogen managed in manure
#'     management system \eqn{S}.}
#'   \item{\eqn{EF3_S}}{Direct emission factor for system \eqn{S}
#'     (kg N₂O–N per kg N managed).}
#' }
#'
#' In this implementation, calculations are performed at daily,
#' per-head resolution using \code{nitrogen_excretion}
#' (kg N head⁻¹ day⁻¹). Daily emissions are computed as:
#'
#' \deqn{
#'   N₂O =
#'   nitrogen\_excretion \times ratio\_N2ON\_to\_N2O \times
#'   \sum \left(
#'     manure\_management\_system\_fraction \times n2o\_ef3
#'   \right)
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

#' Calculate indirect Nitrous Oxide (N₂O) emissions from manure volatilization
#'
#' Computes daily indirect nitrous oxide (N₂O) emissions resulting from
#' atmospheric deposition of volatilised nitrogen (NH₃–N and NOₓ–N) from manure
#' management systems and separates emissions from pasture, burned manure, and
#' all other manure management systems.
#'
#' @param ratio_N2ON_to_N2O Numeric. Conversion factor from kg N₂O–N to kg N₂O,
#'   based on molecular weights. Defaults to 44/28.
#'
#' @param nitrogen_excretion Numeric. Daily nitrogen excretion
#'   (kg N head⁻¹ day⁻¹).
#'
#' @param ... A variable number of manure management system (MMS) arguments.
#'   Each MMS must be provided as a named numeric vector with exactly the
#'   following fields:
#'   \describe{
#'     \item{manure_management_system_fraction}{
#'       Numeric. Fraction of total manure excreted by animals in a given herd
#'       and cohort that is handled in a specific manure management system.
#'       Values range from 0 to 1. The sum of all fractions for each herd_id
#'       must equal 1.
#'     }
#'     \item{n2o_ef4}{
#'       Numeric. Emission factor for indirect nitrous oxide (N₂O) emissions
#'       resulting from atmospheric deposition of volatilised nitrogen
#'       (NH₃–N and NOₓ–N) onto soils and water surfaces
#'       (kg N₂O–N per kg NH₃–N + NOₓ–N).
#'       Default values can be selected from Table 11.3 in the 2006 and
#'       2019 IPCC Guidelines.
#'     }
#'     \item{nitrogen_fracgas}{
#'       Numeric. Fraction of manure nitrogen excreted by a given livestock
#'       category that is lost through volatilisation as ammonia (NH₃)
#'       and nitrogen oxides (NOₓ) within a specific manure management system.
#'       This parameter represents the share of excreted nitrogen that is
#'       mineralised and released to the atmosphere during manure collection,
#'       storage, and treatment. It is expressed as a dimensionless fraction
#'       (0–1). Default values are provided in Table 10.22 of the 2006 and
#'       2019 IPCC Guidelines.
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
#'   (kg N₂O head⁻¹ day⁻¹):
#' \describe{
#'   \item{n2o_vol_manure_pasture}{
#'     Numeric. Indirect nitrous oxide (N₂O) emissions resulting from
#'     atmospheric deposition of volatilised nitrogen (NH₃ and NOₓ)
#'     from manure deposited on pasture (kg N₂O head⁻¹ day⁻¹).
#'   }
#'   \item{n2o_vol_manure_burned}{
#'     Numeric. Indirect nitrous oxide (N₂O) emissions resulting from
#'     atmospheric deposition of volatilised nitrogen (NH₃ and NOₓ)
#'     from manure burned for fuel (kg N₂O head⁻¹ day⁻¹).
#'   }
#'   \item{n2o_vol_manure_other}{
#'     Numeric. Indirect nitrous oxide (N₂O) emissions resulting from
#'     atmospheric deposition of volatilised nitrogen (NH₃ and NOₓ)
#'     from manure management systems, excluding manure deposited on
#'     pasture and manure burned for fuel (kg N₂O head⁻¹ day⁻¹).
#'   }
#'   \item{n2o_vol_manure_all_noburn}{
#'     Numeric. Indirect nitrous oxide (N₂O) emissions resulting from
#'     atmospheric deposition of volatilised nitrogen (NH₃ and NOₓ)
#'     from manure management systems, excluding losses from manure
#'     burned for fuel (kg N₂O head⁻¹ day⁻¹).
#'   }
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
#' 
#' @details
#' This calculation follows the Tier 2 methodology for indirect N₂O 
#' emissions from manure management as defined in the IPCC
#' Guidelines (Equations 10.26 and 10.28).
#'
#' In the IPCC formulation, indirect emissions from atmospheric deposition
#' of volatilised nitrogen are calculated as:
#'
#' \deqn{
#'   N₂O_{vol} =
#'   \frac{44}{28}
#'   \sum_{S} \left(
#'     N \times FracGas_{S} \times EF4_{S}
#'   \right)
#' }
#'
#' where:
#' \describe{
#'   \item{\eqn{44/28}}{Conversion factor from N₂O-N to N₂O.}
#'   \item{\eqn{N}}{Nitrogen excreted (kg N).}
#'   \item{\eqn{FracGas_{S}}}{Fraction of nitrogen volatilised as NH₃–N and NOₓ–N in manure management system \eqn{S}.}
#'   \item{\eqn{EF4_{S}}}{Emission factor for indirect N₂O emissions from atmospheric deposition (kg N₂O-N per kg NH₃–N + NOₓ–N).}
#' }
#'
#' In this implementation, calculations are performed at daily,
#' per-head resolution using \code{nitrogen_excretion}
#' (kg N head⁻¹ day⁻¹):
#'
#' \deqn{
#'   N₂O =
#'   nitrogen\_excretion \times ratio\_N2ON\_to\_N2O \times
#'   \sum_{S} \left(
#'     manure\_management\_system\_fraction \times
#'     nitrogen\_fracgas \times
#'     n2o\_ef4
#'   \right)
#' }
#' 
#' @references
#' IPCC. (2019). \emph{2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions from
#' Livestock and Manure Management. Equation 10.26; 10.28.
#'
#' IPCC. (2006). \emph{2006 IPCC Guidelines for National Greenhouse Gas Inventories}, Chapter 10: Emissions from
#' Livestock and Manure Management. Equation 10.26; 10.28.
#' 
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

#' Calculate indirect Nitrous Oxide (N₂O) emissions from manure leaching and runoff
#'
#' Computes daily indirect nitrous oxide (N₂O) emissions resulting from nitrogen
#' leaching and runoff from manure management systems and separates emissions
#' from pasture, burned manure, and all other manure management systems.
#'
#' @param ratio_N2ON_to_N2O Numeric. Conversion factor from kg N₂O–N to kg N₂O,
#'   based on molecular weights. Defaults to 44/28.
#'
#' @param nitrogen_excretion Numeric. Daily nitrogen excretion
#'   (kg N head⁻¹ day⁻¹).
#'
#' @param ... A variable number of manure management system (MMS) arguments.
#'   Each MMS must be provided as a named numeric vector with exactly the
#'   following fields:
#'   \describe{
#'     \item{manure_management_system_fraction}{
#'       Numeric. Fraction of total manure excreted by animals in a given herd
#'       and cohort that is handled in a specific manure management system.
#'       Values range from 0 to 1. The sum of all fractions for each herd_id
#'       must equal 1.
#'     }
#'     \item{n2o_ef5}{
#'       Numeric. Emission factor for indirect nitrous oxide (N₂O) emissions
#'       resulting from nitrogen leaching and runoff, expressed as kilograms of
#'       N₂O–N per kilogram of nitrogen leached or lost through runoff
#'       (kg N₂O–N / kg N). Default values can be selected from Table 11.3 in the
#'       2006 and 2019 IPCC Guidelines.
#'     }
#'     \item{nitrogen_fracleach}{
#'       Numeric. Fraction of manure nitrogen excreted by a given livestock
#'       category that is lost through leaching and runoff from a specific manure
#'       management system. This parameter is highly uncertain and is used to
#'       estimate indirect N₂O emissions from nitrogen that enters the surrounding
#'       environment of the storage facility. It is expressed as a dimensionless
#'       fraction (0–1). Default values are provided in Table 10.22 of the 2006
#'       and 2019 IPCC Guidelines.
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
#'   (kg N₂O head⁻¹ day⁻¹):
#' \describe{
#'   \item{n2o_leach_manure_pasture}{
#'     Numeric. Indirect nitrous oxide (N₂O) emissions resulting from leaching and
#'     runoff of manure nitrogen from manure deposited on pasture
#'     (kg N₂O head⁻¹ day⁻¹).
#'   }
#'   \item{n2o_leach_manure_burned}{
#'     Numeric. Indirect nitrous oxide (N₂O) emissions resulting from leaching and
#'     runoff of manure nitrogen from manure burned for fuel
#'     (kg N₂O head⁻¹ day⁻¹).
#'   }
#'   \item{n2o_leach_manure_other}{
#'     Numeric. Indirect nitrous oxide (N₂O) emissions resulting from leaching and
#'     runoff of manure nitrogen from manure management systems, excluding losses
#'     from manure deposited on pasture and manure burned for fuel
#'     (kg N₂O head⁻¹ day⁻¹).
#'   }
#'   \item{n2o_leach_manure_all_noburn}{
#'     Numeric. Indirect nitrous oxide (N₂O) emissions resulting from leaching and
#'     runoff of manure nitrogen from manure management systems, excluding losses
#'     from manure burned for fuel (kg N₂O head⁻¹ day⁻¹).
#'   }
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
#' 
#' @details
#' This calculation follows the Tier 2 methodology for indirect N₂O emissions
#' from manure management as defined in the IPCC Guidelines (Equation 10.28).
#'
#' In the IPCC formulation, indirect emissions associated with nitrogen leaching
#' and runoff are calculated as:
#'
#' \deqn{
#'   N₂O_{leach} =
#'   \frac{44}{28}
#'   \sum_{S} \left(
#'     N \times FracLeach_{S} \times EF5_{S}
#'   \right)
#' }
#'
#' where:
#' \describe{
#'   \item{\eqn{44/28}}{Conversion factor from N₂O–N to N₂O.}
#'   \item{\eqn{N}}{Nitrogen excreted (kg N).}
#'   \item{\eqn{FracLeach_{S}}}{Fraction of nitrogen lost through leaching and runoff in manure management system \eqn{S}.}
#'   \item{\eqn{EF5_{S}}}{Emission factor for indirect N₂O emissions from leaching and runoff (kg N₂O–N per kg N leached or lost through runoff).}
#' }
#'
#' In this implementation, calculations are performed at daily, per-head
#' resolution using \code{nitrogen_excretion} (kg N head⁻¹ day⁻¹):
#'
#' \deqn{
#'   N₂O =
#'   nitrogen\_excretion \times ratio\_N2ON\_to\_N2O \times
#'   \sum_{S} \left(
#'     manure\_management\_system\_fraction \times
#'     nitrogen\_fracleach \times
#'     n2o\_ef5
#'   \right)
#' }
#'
#' @references
#' IPCC. (2019). \emph{2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories},
#' Chapter 10: Emissions from Livestock and Manure Management. Equations 10.27; 10.29.
#'
#' IPCC. (2006). \emph{2006 IPCC Guidelines for National Greenhouse Gas Inventories},
#' Volume 4, Chapter 10: Emissions from Livestock and Manure Management. Equations 10.27; 10.29.
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

#' Calculate total N₂O emissions from manure
#'
#' Aggregates direct and indirect nitrous oxide (N₂O) emissions from manure by
#' manure management system group (pasture, burned manure and all other systems).
#' Indirect emissions include contributions from volatilisation and from leaching
#' and runoff.
#'
#' @param n2o_vol_manure_pasture Numeric. Indirect nitrous oxide (N₂O) emissions
#'   resulting from atmospheric deposition of volatilised nitrogen (NH₃ and NOₓ)
#'   from manure deposited on pasture (kg N₂O head⁻¹ day⁻¹).
#' @param n2o_leach_manure_pasture Numeric. Indirect nitrous oxide (N₂O) emissions
#'   resulting from leaching and runoff of manure nitrogen from manure deposited on
#'   pasture (kg N₂O head⁻¹ day⁻¹).
#' @param n2o_vol_manure_burned Numeric. Indirect nitrous oxide (N₂O) emissions
#'   resulting from atmospheric deposition of volatilised nitrogen (NH₃ and NOₓ)
#'   from manure burned for fuel (kg N₂O head⁻¹ day⁻¹).
#' @param n2o_leach_manure_burned Numeric. Indirect nitrous oxide (N₂O) emissions
#'   resulting from leaching and runoff of manure nitrogen from manure burned for
#'   fuel (kg N₂O head⁻¹ day⁻¹).
#' @param n2o_vol_manure_other Numeric. Indirect nitrous oxide (N₂O) emissions
#'   resulting from atmospheric deposition of volatilised nitrogen (NH₃ and NOₓ)
#'   from manure management systems, excluding manure deposited on pasture and
#'   manure burned for fuel (kg N₂O head⁻¹ day⁻¹).
#' @param n2o_leach_manure_other Numeric. Indirect nitrous oxide (N₂O) emissions
#'   resulting from leaching and runoff of manure nitrogen from manure management
#'   systems, excluding losses from manure deposited on pasture and manure burned
#'   for fuel (kg N₂O head⁻¹ day⁻¹).
#' @param n2o_manure_pasture_direct Numeric. Direct nitrous oxide (N₂O) emissions
#'   from manure deposited on pasture (kg N₂O head⁻¹ day⁻¹).
#' @param n2o_manure_burned_direct Numeric. Direct nitrous oxide (N₂O) emissions
#'   from manure burned for fuel (kg N₂O head⁻¹ day⁻¹).
#' @param n2o_manure_other_direct Numeric. Direct nitrous oxide (N₂O) emissions
#'   from manure management systems, excluding emissions from manure deposited on
#'   pasture and burned for fuel (kg N₂O head⁻¹ day⁻¹).
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
#'     Numeric. Total indirect nitrous oxide (N₂O) emissions from manure deposited
#'     on pasture. Includes emissions from atmospheric deposition of volatilised
#'     nitrogen (NH₃ and NOₓ) and from leaching and runoff of manure nitrogen
#'     (kg N₂O head⁻¹ day⁻¹).
#'   }
#'   \item{n2o_manure_burned_indirect}{
#'     Numeric. Total indirect nitrous oxide (N₂O) emissions originating from
#'     manure burned for fuel. Includes emissions from atmospheric deposition of
#'     volatilised nitrogen (NH₃ and NOₓ) and from leaching and runoff of manure
#'     nitrogen (kg N₂O head⁻¹ day⁻¹).
#'   }
#'   \item{n2o_manure_other_indirect}{
#'     Numeric. Total indirect nitrous oxide (N₂O) emissions originating from
#'     manure management systems, excluding manure deposited on pasture and
#'     manure burned for fuel. Includes emissions from atmospheric deposition of
#'     volatilised nitrogen (NH₃ and NOₓ) and from leaching and runoff of manure
#'     nitrogen (kg N₂O head⁻¹ day⁻¹).
#'   }
#'   \item{n2o_manure_pasture_total}{
#'     Numeric. Total nitrous oxide (N₂O) emissions from manure deposited on
#'     pasture. Includes direct emissions and indirect emissions from
#'     volatilisation, leaching, and runoff (kg N₂O head⁻¹ day⁻¹).
#'   }
#'   \item{n2o_manure_burned_total}{
#'     Numeric. Total nitrous oxide (N₂O) emissions from manure burned for fuel.
#'     Includes direct emissions and indirect emissions from volatilisation,
#'     leaching, and runoff (kg N₂O head⁻¹ day⁻¹).
#'   }
#'   \item{n2o_manure_other_total}{
#'     Numeric. Total nitrous oxide (N₂O) emissions from manure management
#'     systems, excluding manure deposited on pasture and manure burned for fuel.
#'     Includes direct emissions and indirect emissions from volatilisation,
#'     leaching, and runoff (kg N₂O head⁻¹ day⁻¹).
#'   }
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
