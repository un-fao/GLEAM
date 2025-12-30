#' Calculate Volatile Solids for Manure Emissions
#'
#' Calculates volatile solids (VS) production from animal feed intake and diet composition
#' using IPCC methodology for different animal types and production systems.
#'
#' @param animal Character. Animal type (CTL, BFL, CML, SHP, GTS, PGS, CHK)
#' @param lps_short Character. Livestock production system
#' @param dmi Numeric. Dry matter intake (kg/head/day)
#' @param diet_dig Numeric. Diet digestibility (0-1)
#' @param diet_me Numeric. Metabolizable energy content (MJ/kg DM)
#' @param diet_ge Numeric. Gross energy content (MJ/kg DM)
#' @param ipcc_method Character. IPCC method ('2006' or '2019')
#'
#' @return Numeric. Volatile solids (kg VS/head/day)
#'
#' @export
calc_volatile_solids <- function(animal, dmi, diet_dig, diet_me, diet_ge) {
  validate_manure_inputs(animal, dmi, diet_dig, diet_me, diet_ge)

  # Row-by-row calculation (scalar values)
  if (animal %in% c("CTL", "BFL", "CML", "SHP", "GTS")) {
    # Case 1: CTL, BFL, CML, SHP, GTS
    vs <- dmi * (1.04 - diet_dig) * 0.92
  } else if (animal == "PGS") {
    # Case 2: PGS (2019)
    vs <- dmi * (1.02 - diet_dig) * 0.94
  } else {
    vs <- 0
  }

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
#' Calculates methane emissions from manure management systems using volatile solids,
#' methane conversion factors, and maximum methane producing capacity (B0).
#'
#' @param vs Numeric vector of volatile solids (kg VS/head/day)
#' @param mcf_pasture Numeric vector of methane conversion factor for pasture (dimensionless)
#' @param mcf_burned Numeric vector of methane conversion factor for burned (dimensionless)
#' @param mcf_other Numeric vector of methane conversion factor for other systems (dimensionless)
#' @param b0_mms_all Numeric vector of maximum methane producing capacity for all systems (m³ CH4/kg VS)
#' @param b0_mms_pasture Numeric vector of maximum methane producing capacity for pasture (m³ CH4/kg VS)
#' @param ratio_m3CH4_kgCH4 Numeric. Conversion factor from m³ CH4 to kg CH4. Defaults to 0.67.
#'
#' @return A named list with:
#' \describe{
#'   \item{ch4_manure_pasture}{CH4 emissions from pasture (kg CH4/head/day)}
#'   \item{ch4_manure_burned}{CH4 emissions from burned manure (kg CH4/head/day)}
#'   \item{ch4_manure_other}{CH4 emissions from other systems (kg CH4/head/day)}
#'   \item{ch4_manure_all_noburn}{Total CH4 emissions excluding burned (kg CH4/head/day)}
#' }
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
#' Calculates direct nitrous oxide emissions from manure management systems
#' using nitrogen excretion and EF3 emission factors.
#'
#' @param n_excretion Numeric vector of nitrogen excretion (kg N/head/day)
#' @param ef3_pasture Numeric vector of EF3 emission factor for pasture (kg N2O-N/kg N)
#' @param ef3_burned Numeric vector of EF3 emission factor for burned (kg N2O-N/kg N)
#' @param ef3_other Numeric vector of EF3 emission factor for other systems (kg N2O-N/kg N)
#' @param ratio_N2O_N2ON Numeric. Conversion factor from kg N2O-N to kg N2O. Defaults to 44/28.
#'
#' @return A named list with:
#' \describe{
#'   \item{direct_n2o_manure_pasture}{Direct N2O emissions from pasture (kg N2O/head/day)}
#'   \item{direct_n2o_manure_burned}{Direct N2O emissions from burned manure (kg N2O/head/day)}
#'   \item{direct_n2o_manure_other}{Direct N2O emissions from other systems (kg N2O/head/day)}
#'   \item{direct_n2o_manure_all_noburn}{Total direct N2O emissions excluding burned (kg N2O/head/day)}
#' }
#'
#' @export
calc_direct_n2o_emissions <- function(
    n_excretion,
    ef3_pasture,
    ef3_burned,
    ef3_other,
    ratio_N2O_N2ON = 44/28
) {
  validate_direct_n2o_inputs(n_excretion, ef3_pasture, ef3_burned, ef3_other)
  n2o_pasture <- n_excretion * ef3_pasture * ratio_N2O_N2ON
  n2o_burned <- n_excretion * ef3_burned * ratio_N2O_N2ON
  n2o_other <- n_excretion * ef3_other * ratio_N2O_N2ON
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
#' Calculates nitrogen lost via volatilization from manure management systems
#' using nitrogen excretion and volatilization fractions.
#'
#' @param n_excretion Numeric vector of nitrogen excretion (kg N/head/day)
#' @param fracgas_pasture Numeric vector of volatilization fraction for pasture (0-1)
#' @param fracgas_burned Numeric vector of volatilization fraction for burned (0-1)
#' @param fracgas_other Numeric vector of volatilization fraction for other systems (0-1)
#'
#' @return A named list with:
#' \describe{
#'   \item{n_vol_manure_pasture}{Nitrogen volatilized from pasture (kg N/head/day)}
#'   \item{n_vol_manure_burned}{Nitrogen volatilized from burned manure (kg N/head/day)}
#'   \item{n_vol_manure_other}{Nitrogen volatilized from other systems (kg N/head/day)}
#'   \item{n_vol_manure_all_noburn}{Total nitrogen volatilized excluding burned (kg N/head/day)}
#' }
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
#' Calculates nitrous oxide emissions from volatilized nitrogen using EF4 emission factors.
#'
#' @param n_vol_pasture Numeric vector of nitrogen volatilized from pasture (kg N/head/day)
#' @param n_vol_burned Numeric vector of nitrogen volatilized from burned manure (kg N/head/day)
#' @param n_vol_other Numeric vector of nitrogen volatilized from other systems (kg N/head/day)
#' @param ef4 Numeric vector of EF4 emission factor (kg N2O-N/kg N)
#' @param ratio_N2O_N2ON Numeric. Conversion factor from kg N2O-N to kg N2O. Defaults to 44/28.
#'
#' @return A named list with:
#' \describe{
#'   \item{n2o_vol_manure_pasture}{N2O emissions from volatilized nitrogen from pasture (kg N2O/head/day)}
#'   \item{n2o_vol_manure_burned}{N2O emissions from volatilized nitrogen from burned manure (kg N2O/head/day)}
#'   \item{n2o_vol_manure_other}{N2O emissions from volatilized nitrogen from other systems (kg N2O/head/day)}
#'   \item{n2o_vol_manure_all_noburn}{Total N2O emissions from volatilization excluding burned (kg N2O/head/day)}
#' }
#'
#' @export
calc_n2o_from_volatilization <- function(
    n_vol_pasture,
    n_vol_burned,
    n_vol_other,
    ef4,
    ratio_N2O_N2ON = 44/28
) {
  validate_n2o_volatilization_inputs(n_vol_pasture, n_vol_burned, n_vol_other, ef4)
  n2o_pasture <- n_vol_pasture * ef4 * ratio_N2O_N2ON
  n2o_burned <- n_vol_burned * ef4 * ratio_N2O_N2ON
  n2o_other <- n_vol_other * ef4 * ratio_N2O_N2ON
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
#' Calculates nitrogen lost via leaching from manure management systems
#' using nitrogen excretion and leaching fractions.
#'
#' @param n_excretion Numeric vector of nitrogen excretion (kg N/head/day)
#' @param fracleach_pasture Numeric vector of leaching fraction for pasture (0-1)
#' @param fracleach_burned Numeric vector of leaching fraction for burned (0-1)
#' @param fracleach_other Numeric vector of leaching fraction for other systems (0-1)
#'
#' @return A named list with:
#' \describe{
#'   \item{n_leach_manure_pasture}{Nitrogen leached from pasture (kg N/head/day)}
#'   \item{n_leach_manure_burned}{Nitrogen leached from burned manure (kg N/head/day)}
#'   \item{n_leach_manure_other}{Nitrogen leached from other systems (kg N/head/day)}
#'   \item{n_leach_manure_all_noburn}{Total nitrogen leached excluding burned (kg N/head/day)}
#' }
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
#' Calculates nitrous oxide emissions from leached nitrogen using EF5 emission factors.
#'
#' @param n_leach_pasture Numeric vector of nitrogen leached from pasture (kg N/head/day)
#' @param n_leach_burned Numeric vector of nitrogen leached from burned manure (kg N/head/day)
#' @param n_leach_other Numeric vector of nitrogen leached from other systems (kg N/head/day)
#' @param ef5 Numeric vector of EF5 emission factor (kg N2O-N/kg N)
#' @param ratio_N2O_N2ON Numeric. Conversion factor from kg N2O-N to kg N2O. Defaults to 44/28.
#'
#' @return A named list with:
#' \describe{
#'   \item{n2o_leach_manure_pasture}{N2O emissions from leached nitrogen from pasture (kg N2O/head/day)}
#'   \item{n2o_leach_manure_burned}{N2O emissions from leached nitrogen from burned manure (kg N2O/head/day)}
#'   \item{n2o_leach_manure_other}{N2O emissions from leached nitrogen from other systems (kg N2O/head/day)}
#'   \item{n2o_leach_manure_all_noburn}{Total N2O emissions from leaching excluding burned (kg N2O/head/day)}
#' }
#'
#' @export
calc_n2o_from_leaching <- function(
    n_leach_pasture,
    n_leach_burned,
    n_leach_other,
    ef5,
    ratio_N2O_N2ON = 44/28
) {
  validate_n2o_leaching_inputs(n_leach_pasture, n_leach_burned, n_leach_other, ef5)
  n2o_pasture <- n_leach_pasture * ef5 * ratio_N2O_N2ON
  n2o_burned <- n_leach_burned * ef5 * ratio_N2O_N2ON
  n2o_other <- n_leach_other * ef5 * ratio_N2O_N2ON
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
#' Calculates total nitrous oxide emissions (direct + indirect) from manure management systems.
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
#'   \item{indirect_n2o_manure_pasture}{Indirect N2O emissions from pasture (kg N2O/head/day)}
#'   \item{indirect_n2o_manure_burned}{Indirect N2O emissions from burned manure (kg N2O/head/day)}
#'   \item{indirect_n2o_manure_other}{Indirect N2O emissions from other systems (kg N2O/head/day)}
#'   \item{total_n2o_manure_pasture}{Total N2O emissions from pasture (kg N2O/head/day)}
#'   \item{total_n2o_manure_burned}{Total N2O emissions from burned manure (kg N2O/head/day)}
#'   \item{total_n2o_manure_other}{Total N2O emissions from other systems (kg N2O/head/day)}
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
