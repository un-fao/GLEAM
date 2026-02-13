#' Run Direct Emissions From Manure
#'
#' Run emissions (cohort-level) from manure management systems (MMS)
#'
#' @param directemissions_manure_input_cohort_level_data data.table. Cohort-level
#'   input table with the following minimum data requirement:
#'   \describe{
#'   \item{herd_id}{Character. Unique identifier for the herd, repeated for each cohort belonging to the same herd.}
#'   \item{cohort}{Character. Sex- and age-specific cohort code describing the
#'   production stage of the animals. Supported values include:
#'   \itemize{
#'     \item \code{FA}: adult females (from age at first parturition)
#'     \item \code{FS}: sub-adult females (from weaning to age at first parturition)
#'     \item \code{FJ}: juvenile females (from birth to weaning)
#'     \item \code{MA}: adult males (from age at first breeding)
#'     \item \code{MS}: sub-adult males (from weaning to age at first breeding)
#'     \item \code{MJ}: juvenile males (from birth to weaning)
#'   }}
#'     \item{dry_matter_intake}{Numeric. Average daily dry matter intake of feed (kg DM/head/day).}
#'     \item{diet_digestibility_fraction}{Numeric. Average digestibility of the feed ration, expressed as ratio of digestible to gross energy content (fraction).}
#'     \item{urinary_energy_fraction}{Numeric. Fraction of feed's gross energy that is excreted in urine (fraction).}
#'     \item{diet_ash}{Numeric. Average ash content of feed, calculated as a fraction of the dry matter intake (kg ash/kg DM).}
#'     \item{nitrogen_excretion}{Numeric. Daily nitrogen excretion (kg N/head/day).}
#'   }
#'
#' @param manure_management_system_fraction data.table. Cohort-level MMS fractions
#'   with:
#'   \describe{
#'   \item{herd_id}{Character. Unique identifier for the herd, repeated for each cohort belonging to the same herd.}
#'   \item{cohort}{Character. Sex- and age-specific cohort code describing the
#'   production stage of the animals. Supported values include:
#'   \itemize{
#'     \item \code{FA}: adult females (from age at first parturition)
#'     \item \code{FS}: sub-adult females (from weaning to age at first parturition)
#'     \item \code{FJ}: juvenile females (from birth to weaning)
#'     \item \code{MA}: adult males (from age at first breeding)
#'     \item \code{MS}: sub-adult males (from weaning to age at first breeding)
#'     \item \code{MJ}: juvenile males (from birth to weaning)
#'   }}
#'     \item{manure_management_system}{Character. Name identifying the manure management system. The identifiers mms_pasture and mms_burned are reserved for manure deposited on pasture and manure burned for fuel, respectively. No specific naming convention is required for other manure management systems, which are grouped and handled as “other” systems.}
#'     \item{manure_management_system_fraction}{Numeric. Fraction of total manure excreted by animals in a given herd and cohort that is handled in a specific manure management system. Values range from 0 to 1. The sum of all fractions for each herd_id must equal 1.}
#'   }
#'
#' @param manure_management_system_factors data.table. Herd-level MMS factors
#'   with:
#'   \describe{
#'     \item{manure_management_system}{Character. Name identifying the manure management system. The identifiers mms_pasture and mms_burned are reserved for manure deposited on pasture and manure burned for fuel, respectively. No specific naming convention is required for other manure management systems, which are grouped and handled as “other” systems.}
#'     \item{ratio_m3CH4_to_kgCH4}{
#'       Numeric. Conversion factor used to convert methane (CH₄) from 
#'       volumetric unit (m³) to a mass unit (kg). This value represents the 
#'       density of methane. It defaults to 0.67 kg/m³
#'     }
#'     \item{methane_conversion_factor_mcf}{
#'       Numeric. Methane (CH₄) conversion factor represents the portion or 
#'       degree of the maximum methane producing capacity (Bo) that is effectively 
#'       achieved within a specific manure management system. It represents the 
#'       extent to which the theoretical methane yield is realized based on 
#'       management practices and environmental conditions, specifically the 
#'       temperature of the system, the retention time of the organic material, 
#'       and the degree of anaerobic conditions present. The value theoretically 
#'       ranges from 0 to 100 percent. Default values can be selected from 
#'       Table 10.17 of IPCC guidelines (IPCC 2006, 2019).
#'     }
#'     \item{ch4_max_producing_capacity_bo}{
#'       Numeric. Maximum methane (CH₄) producing capacity (B0) for all systems 
#'       (m³ CH₄/kg VS). The value is region- and species-specific, and represents 
#'       the theoretical maximum methane yield per unit of volatile solids. 
#'       Default can be selected from Table 10.16 (IPCC, 2019) or from 
#'       Tables 10A-4 to 10A-9 (IPCC, 2006).
#'     }
#'     \item{n2o_ef3}{
#'       Numeric. Emission factor for direct nitrous oxide (N₂O) emissions for 
#'       each manure management system, representing nitrous oxide emitted per 
#'       unit of nitrogen from nitrification and denitrification processes 
#'       occuring during manure storage and treatment (kg N₂O–N per kg N). 
#'       Default values can be selected from Table 10.21 and Table 11.1 
#'       (for manure deposited on pasture) in IPCC Guidelines (IPCC 2006, 2019).
#'     }
#'     \item{n2o_ef4}{
#'       Numeric. Emission factor for indirect nitrous oxide (N₂O) emissions 
#'       resulting from atmospheric deposition of volatilised nitrogen 
#'       (NH₃–N and NOₓ–N) onto soils and water surfaces (kg N₂O–N / (kg NH₃–N + NOₓ–N)).
#'        Default values can be selected from Table 11.3 in IPCC Guidelines (IPCC 2006, 2019).
#'     }
#'     \item{nitrogen_fracgas}{
#'       Numeric. Fraction of manure nitrogen excreted by a given livestock 
#'       category that is lost through volatilisation as ammonia (NH₃) and 
#'       nitrogen oxides (NOₓ) within a specific manure management system. 
#'       This parameter represents the share of excreted nitrogen that is 
#'       mineralised and released to the atmosphere during manure collection, 
#'       storage, and treatment. It is expressed as a dimensionless fraction (0–1). 
#'       Default values are provided in Table 10.22 of IPCC Guidelines (IPCC 2006, 2019).
#'     }
#'     \item{n2o_ef5}{
#'       Numeric. Emission factor for indirect nitrous oxide (N₂O) emissions 
#'       resulting from nitrogen leaching and runoff, expressed as kilograms of 
#'       N₂O–N per kilogram of nitrogen leached or lost through runoff (kg N₂O–N/kg N). 
#'       Default values can be selected from Table 11.3 in IPCC Guidelines (IPCC 2006, 2019).
#'     }
#'     \item{nitrogen_fracleach}{
#'       Numeric. Fraction of manure nitrogen excreted by a given livestock 
#'       category that is lost through leaching and runoff from a specific 
#'       manure management system. This parameter is highly uncertain and is used 
#'       to estimate indirect N₂O emissions from nitrogen that enters the 
#'       surrounding environment of the storage facility. It is expressed as a 
#'       dimensionless fraction (0–1). Default values are provided in Table 10.22 
#'       of IPCC Guidelines (IPCC 2006, 2019).
#'     }
#'   }
#'
#' @return cohort_level_data data.table. Input cohort table with added manure
#'   emissions columns:
#'   \describe{
#'     \item{volatile_solids}{Numeric. Total volatile solids (VS) excreted per animal per day, representing the organic material in livestock manure and consisting of both biodegradable and non-biodegradable fractions (kg VS/head/day).}
#'     \item{ch4_manure_pasture}{Numeric. Methane (CH₄) emissions from manure deposited on pasture (kg CH₄/head/day).}
#'     \item{ch4_manure_burned}{Numeric. Methane (CH₄) emissions from manure burned for fuel (kg CH₄/head/day).}
#'     \item{ch4_manure_other}{Numeric. Methane (CH₄) emissions from manure management systems, excluding emissions from manure deposited on pasture and burned for fuel (kg CH₄/head/day).}
#'     \item{ch4_manure_all_noburn}{Numeric. Methane (CH₄) emissions from manure management systems, excluding manure burned for fuel (kg CH₄/head/day).}
#'     \item{n2o_manure_pasture_direct}{Numeric. Direct nitrous oxide (N₂O) emissions from manure deposited on pasture (kg N₂O/head/day).}
#'     \item{n2o_manure_burned_direct}{Numeric. Direct nitrous oxide (N₂O) emissions from manure burned for fuel (kg N₂O/head/day).}
#'     \item{n2o_manure_other_direct}{Numeric. Direct nitrous oxide (N₂O) emissions from manure management systems, excluding emissions from manure deposited on pasture and burned for fuel (kg N₂O/head/day).}
#'     \item{n2o_manure_all_noburn_direct}{Numeric. Direct nitrous oxide (N₂O) emissions from manure management systems, excluding emissions from manure burned for fuel (kg N₂O/head/day).}
#'     \item{n2o_vol_manure_pasture}{Numeric. Indirect nitrous oxide (N₂O) emissions resulting from atmospheric deposition of volatilised nitrogen (NH₃ and NOₓ) from manure deposited on pasture (kg N₂O/head/day).}
#'     \item{n2o_vol_manure_burned}{Numeric. Indirect nitrous oxide (N₂O) emissions resulting from atmospheric deposition of volatilised nitrogen (NH₃ and NOₓ) from manure burned for fuel (kg N₂O/head/day).}
#'     \item{n2o_vol_manure_other}{Numeric. Indirect nitrous oxide (N₂O) emissions resulting from atmospheric deposition of volatilised nitrogen (NH₃ and NOₓ) from manure management systems, excluding manure deposited on pasture and manure burned for fuel (kg N₂O/head/day).}
#'     \item{n2o_vol_manure_all_noburn}{Numeric. Indirect nitrous oxide (N₂O) emissions resulting from atmospheric deposition of volatilised nitrogen (NH₃ and NOₓ) from manure management systems, excluding losses from manure burned for fuel (kg N₂O/head/day).}
#'     \item{n2o_leach_manure_pasture}{Numeric. Indirect nitrous oxide (N₂O) emissions resulting from leaching and runoff of manure nitrogen from manure deposited on pasture (kg N₂O/head/day).}
#'     \item{n2o_leach_manure_burned}{Numeric. Indirect nitrous oxide (N₂O) emissions resulting from leaching and runoff of manure nitrogen from manure burned for fuel (kg N₂O/head/day).}
#'     \item{n2o_leach_manure_other}{Numeric. Indirect nitrous oxide (N₂O) emissions resulting from leaching and runoff of manure nitrogen from manure management systems, excluding losses from manure deposited on pasture and manure burned for fuel (kg N₂O/head/day).}
#'     \item{n2o_leach_manure_all_noburn}{Numeric. Indirect nitrous oxide (N₂O) emissions resulting from leaching and runoff of manure nitrogen from manure management systems, excluding losses from manure burned for fuel (kg N₂O/head/day).}
#'     \item{n2o_manure_pasture_indirect}{Numeric. Total indirect nitrous oxide (N₂O) emissions from manure deposited on pasture. Includes emissions from atmospheric deposition of volatilised nitrogen (NH₃ and NOₓ) and from leaching and runoff of manure nitrogen (kg N₂O/head/day).}
#'     \item{n2o_manure_burned_indirect}{Numeric. Total indirect nitrous oxide (N₂O) emissions originating from manure burned for fuel. Includes emissions from atmospheric deposition of volatilised nitrogen (NH₃ and NOₓ) and from leaching and runoff of manure nitrogen (kg N₂O/head/day).}
#'     \item{n2o_manure_other_indirect}{Numeric. Total indirect nitrous oxide (N₂O) emissions originating from manure management systems, excluding manure deposited on pasture and burned for fuel. Includes emissions from atmospheric deposition of volatilised nitrogen (NH₃ and NOₓ) and from leaching and runoff of manure nitrogen.}
#'     \item{n2o_manure_pasture_total}{Numeric. Total nitrous oxide emissions from manure deposited on pasture. Includes direct emissions and indirect emissions from volatilisation, leaching, and runoff (kg N₂O/head/day).}
#'     \item{n2o_manure_burned_total}{Numeric. Total nitrous oxide emissions (N₂O) from manure burned for fuel. Includes direct emissions and indirect emissions from volatilisation, leaching, and runoff (kg N₂O/head/day).}
#'     \item{n2o_manure_other_total}{Numeric. Total nitrous oxide (N₂O) emissions from manure management systems, excluding manure deposited on pasture and manure burned for fuel. Includes direct emissions and indirect emissions from volatilisation, leaching, and runoff (kg N₂O/head/day).}
#'   }
#'
#' @section Manure management system (MMS) reference:
#' A complete list of MMS names,
#' definitions, and associated emission factors is provided in the
#' following reference documents:
#'
#' \itemize{
#'   \item \href{gleam/legacy/Resources/mms_definitions.html}{MMS names and definitions}
#'   \item \href{gleam/legacy/Resources/mms_emission-factors.html}{MMS emission factors}
#' }
#'
#' These documents provide guidance on IPCC MMS and the
#' corresponding methane (CH₄) and nitrous oxide (N₂O) parameters
#' (MCF, B₀, EF3, EF4, EF5, fracgas, fracleach).
#' 
#' @details
#' This function orchestrates a cohort-level implementation of the IPCC manure
#' management methodology using volatile solids (VS), manure management system
#' (MMS) allocation fractions, and MMS-specific emission factors.
#' Run-level validation is performed on input table structure and key consistency.
#' In particular, for each \code{herd_id}, the set of MMS identifiers must be
#' consistent between \code{manure_management_system_fraction} and
#' \code{manure_management_system_factors}.
#'
#'
#' The following calculation sequence is applied:
#' \enumerate{
#'   \item VS excretion is computed from nutritional parameters of the feed ration 
#'   (digestibility, urinary energy, and ash) using a simplified formulation of Equation 10.24
#'   (IPCC 2006, 2019) - \code{\link{calc_volatile_solids}}
#'   \item Methane (CH₄) emissions from manure management are computed from VS
#'   and MMS-specific factors (MCF and B₀) and reported by MMS group (pasture, burned,
#'   and other), consistently with Equation 10.23 (IPCC, 2006, 2019) - \code{\link{calc_ch4_emissions}}
#'   \item Direct nitrous oxide (N₂O) emissions from manure management are
#'   computed from nitrogen excretion and MMS-specific EF3 values, and reported
#'   by MMS group, consistently with Equation 10.25 (IPCC, 2006, 2019) -  \code{\link{calc_direct_n2o_emissions}}
#'   \item Indirect N₂O emissions are computed as the sum of:
#'   \itemize{
#'     \item volatilisation-driven N₂O using MMS-specific nitrogen losses
#'     (FracGas) and EF4, consistently with Equations 10.26 (IPCC, 2006, 2019), 
#'     10.27 (IPCC, 2006), and 10.28 (IPCC, 2019) - \code{\link{calc_n2o_from_volatilization}}
#'     \item leaching/runoff-driven N₂O using MMS-specific nitrogen losses
#'     (FracLeach) and EF5, consistently with Equations 10.28 (IPCC, 2006), 
#'     10.27 (IPCC, 2019), and 10.29 (IPCC, 2006, 2019) - \code{\link{calc_n2o_from_leaching}}
#'   }
#'   \item Total N₂O emissions are aggregated by MMS group
#'   (pasture, burned, other) - \code{\link{calc_total_n2o_emissions}}
#' }
#'
#' The approach corresponds to a Tier 2 implementation as:
#' \itemize{
#'   \item VS is derived from ration-level inputs rather than using fixed daily
#'   excretion defaults, and
#'   \item emissions are allocated across MMS categories using herd/cohort MMS
#'   fractions and MMS-specific parameters.
#' }
#' @seealso
#' \code{\link{calc_volatile_solids}},
#' \code{\link{calc_ch4_emissions}},
#' \code{\link{calc_direct_n2o_emissions}},
#' \code{\link{calc_n2o_from_volatilization}},
#' \code{\link{calc_n2o_from_leaching}},
#' \code{\link{calc_total_n2o_emissions}}
#'
#' @examples
#' \dontrun{
#' manure_management_system_factors <- data.table::fread(
#'   system.file(
#'     "extdata/examples/manure_management_system_factors.csv",
#'     package = "gleam"
#'   )
#' )
#' manure_management_system_fraction <- data.table::fread(
#'   system.file(
#'     "extdata/examples/manure_management_system_fraction.csv",
#'     package = "gleam"
#'   )
#' )
#' directemissions_manure_input_cohort_level_data <- data.table::fread(
#'   system.file(
#'     "extdata/examples/directemissions_manure_input_cohort_level_data.csv",
#'     package = "gleam"
#'   )
#' )
#'
#' result <- run_directemissions_manure(
#'   directemissions_manure_input_cohort_level_data = directemissions_manure_input_cohort_level_data,
#'   manure_management_system_fraction = manure_management_system_fraction,
#'   manure_management_system_factors = manure_management_system_factors
#' )
#' }
#'
#' @references
#' IPCC. (2019). \emph{2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories},
#' Volume 4, Chapter 10: Emissions from Livestock and Manure Management.
#' Equations 10.23, 10.24, 10.25, 10.26, 10.27, 10.28, and 10.29.
#'
#' IPCC. (2006). \emph{2006 IPCC Guidelines for National Greenhouse Gas Inventories},
#' Volume 4, Chapter 10: Emissions from Livestock and Manure Management.
#' Equations 10.23, 10.24, 10.25, 10.26, 10.27, 10.28, and 10.29.
#' 
#' @export
#'
#' @importFrom data.table := .I
run_directemissions_manure <- function(
    directemissions_manure_input_cohort_level_data,
    manure_management_system_fraction,
    manure_management_system_factors
) {
  # --- Step 1: Validate inputs ------------------------------------------------
  validate_directemissions_manure_inputs(
    directemissions_manure_input_cohort_level_data = directemissions_manure_input_cohort_level_data,
    manure_management_system_fraction = manure_management_system_fraction,
    manure_management_system_factors = manure_management_system_factors
  )

  # --- Step 2: Prepare inputs -------------------------------------------------
  cohort_level_data <- data.table::copy(directemissions_manure_input_cohort_level_data)
  mms_fraction <- data.table::copy(manure_management_system_fraction)
  mms_factors <- data.table::copy(manure_management_system_factors)

  # Join cohort fractions with herd-level MMS factors
  mms_data <- merge(
    mms_fraction,
    mms_factors,
    by = c("herd_id", "manure_management_system")
  )

  # Build the MMS list expected by scientific core functions.
  # Each MMS becomes a named numeric vector with specific fields.
  build_mms_list <- function(mms_rows, fields) {
    if (nrow(mms_rows) == 0) {
      return(list())
    }

    # Keep only MMS id plus required fields, then split by MMS name.
    mms_subset <- mms_rows[, c("manure_management_system", fields), with = FALSE]
    mms_split <- split(mms_subset, mms_subset$manure_management_system)

    # Convert each MMS to a named numeric vector of required fields.
    mms_list <- lapply(mms_split, function(mms_df) {
      unlist(mms_df[1, fields, with = FALSE], use.names = TRUE)
    })

    return(mms_list)
  }

  # --- Step 3: Volatile solids (VS) -------------------------------------------
  cohort_level_data[
    ,
    volatile_solids := calc_volatile_solids(
      dry_matter_intake = dry_matter_intake,
      diet_digestibility_fraction = diet_digestibility_fraction,
      urinary_energy_fraction = urinary_energy_fraction,
      diet_ash = diet_ash
    ),
    by = .I
  ]

  # --- Step 4: CH4 from manure (pasture, burned, other, total non-burned) -----
  cohort_level_data[
    ,
    c(
      "ch4_manure_pasture",
      "ch4_manure_burned",
      "ch4_manure_other",
      "ch4_manure_all_noburn"
    ) := {
      # Select MMS records for this herd/cohort (fractions + factors).
      current_herd_id <- herd_id
      current_cohort <- cohort
      mms_rows <- mms_data[herd_id == current_herd_id & cohort == current_cohort]

      # Build the list expected by calc_ch4_emissions(...)
      mms_list <- build_mms_list(
        mms_rows,
        c("manure_management_system_fraction",
          "methane_conversion_factor_mcf",
          "ch4_max_producing_capacity_bo")
      )

      # calc_ch4_emissions() accepts variable MMS inputs via `...`.
      ch4 <- do.call(
        calc_ch4_emissions, c(list(volatile_solids = volatile_solids), mms_list)
      )
      list(
        ch4$ch4_manure_pasture,
        ch4$ch4_manure_burned,
        ch4$ch4_manure_other,
        ch4$ch4_manure_all_noburn
      )
    },
    by = .I
  ]

  # --- Step 5: Direct N2O from manure (pasture, burned, other, total non-burned) ----
  cohort_level_data[
    ,
    c(
      "n2o_manure_pasture_direct",
      "n2o_manure_burned_direct",
      "n2o_manure_other_direct",
      "n2o_manure_all_noburn_direct"
    ) := {
      # Select MMS records for this herd/cohort (fractions + factors).
      current_herd_id <- herd_id
      current_cohort <- cohort
      mms_rows <- mms_data[herd_id == current_herd_id & cohort == current_cohort]

      # Build the list expected by calc_direct_n2o_emissions(...)
      mms_list <- build_mms_list(mms_rows, c("manure_management_system_fraction", "n2o_ef3"))

      # calc_direct_n2o_emissions() accepts variable MMS inputs via `...`.
      n2o_direct <- do.call(
        calc_direct_n2o_emissions,
        c(list(nitrogen_excretion = nitrogen_excretion), mms_list)
      )
      list(
        n2o_direct$n2o_manure_pasture_direct,
        n2o_direct$n2o_manure_burned_direct,
        n2o_direct$n2o_manure_other_direct,
        n2o_direct$n2o_manure_all_noburn_direct
      )
    },
    by = .I
  ]

  # --- Step 6: Indirect N2O from volatilization -------------------------------
  cohort_level_data[
    ,
    c(
      "n2o_vol_manure_pasture",
      "n2o_vol_manure_burned",
      "n2o_vol_manure_other",
      "n2o_vol_manure_all_noburn"
    ) := {
      # Select MMS records for this herd/cohort (fractions + factors).
      current_herd_id <- herd_id
      current_cohort <- cohort
      mms_rows <- mms_data[herd_id == current_herd_id & cohort == current_cohort]

      # Build the list expected by calc_n2o_from_volatilization(...)
      mms_list <- build_mms_list(
        mms_rows, c("manure_management_system_fraction", "n2o_ef4", "nitrogen_fracgas")
      )

      # calc_n2o_from_volatilization() accepts variable MMS inputs via `...`.
      n2o_vol <- do.call(
        calc_n2o_from_volatilization,
        c(list(nitrogen_excretion = nitrogen_excretion), mms_list)
      )
      list(
        n2o_vol$n2o_vol_manure_pasture,
        n2o_vol$n2o_vol_manure_burned,
        n2o_vol$n2o_vol_manure_other,
        n2o_vol$n2o_vol_manure_all_noburn
      )
    },
    by = .I
  ]

  # --- Step 7: Indirect N2O from leaching/runoff ------------------------------
  cohort_level_data[
    ,
    c(
      "n2o_leach_manure_pasture",
      "n2o_leach_manure_burned",
      "n2o_leach_manure_other",
      "n2o_leach_manure_all_noburn"
    ) := {
      # Select MMS records for this herd/cohort (fractions + factors).
      current_herd_id <- herd_id
      current_cohort <- cohort
      mms_rows <- mms_data[herd_id == current_herd_id & cohort == current_cohort]

      # Build the list expected by calc_n2o_from_leaching(...)
      mms_list <- build_mms_list(
        mms_rows, c("manure_management_system_fraction", "n2o_ef5", "nitrogen_fracleach")
      )

      # calc_n2o_from_leaching() accepts variable MMS inputs via `...`.
      n2o_leach <- do.call(
        calc_n2o_from_leaching,
        c(list(nitrogen_excretion = nitrogen_excretion), mms_list)
      )
      list(
        n2o_leach$n2o_leach_manure_pasture,
        n2o_leach$n2o_leach_manure_burned,
        n2o_leach$n2o_leach_manure_other,
        n2o_leach$n2o_leach_manure_all_noburn
      )
    },
    by = .I
  ]

  # --- Step 8: Total N2O (direct + indirect) ---------------------------------
  cohort_level_data[
    ,
    c(
      "n2o_manure_pasture_indirect",
      "n2o_manure_burned_indirect",
      "n2o_manure_other_indirect",
      "n2o_manure_pasture_total",
      "n2o_manure_burned_total",
      "n2o_manure_other_total"
    ) := {
      totals <- calc_total_n2o_emissions(
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
      list(
        totals$n2o_manure_pasture_indirect,
        totals$n2o_manure_burned_indirect,
        totals$n2o_manure_other_indirect,
        totals$n2o_manure_pasture_total,
        totals$n2o_manure_burned_total,
        totals$n2o_manure_other_total
      )
    },
    by = .I
  ]

  return(cohort_level_data)
}
