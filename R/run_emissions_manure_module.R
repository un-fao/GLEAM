#' Run Emissions from Manure Module Pipeline
#'
#' Calculates methane (CH4) and nitrous oxide (N2O) emissions at cohort-level from manure management systems (MMS).
#'
#' @param cohort_level_data data.table. Cohort-level
#'   input table with the following minimum data requirement:
#'   \describe{
#'   \item{herd_id}{Character. Unique identifier for the herd, repeated for each cohort belonging to the same herd.}
#'   \item{cohort_short}{Character. Sex- and age-specific cohort code describing the
#'   production stage of the animals. Supported values include:
#'   \itemize{
#'     \item \code{FA}: adult females (from age at first parturition)
#'     \item \code{FS}: sub-adult females (from weaning to age at first parturition)
#'     \item \code{FJ}: juvenile females (from birth to weaning)
#'     \item \code{MA}: adult males (from age at first breeding)
#'     \item \code{MS}: sub-adult males (from weaning to age at first breeding)
#'     \item \code{MJ}: juvenile males (from birth to weaning)
#'   }}
#'     \item{ration_intake}{Numeric. Average daily dry matter intake of feed (kg DM/head/day).}
#'     \item{ration_digestibility_fraction}{Numeric. Average digestibility of the feed ration, expressed as ratio of digestible to gross energy content (fraction).}
#'     \item{ration_urinary_energy_fraction}{Numeric. Fraction of feed's gross energy that is excreted in urine (fraction).}
#'     \item{ration_ash}{Numeric. Average ash content of feed, calculated as a fraction of the dry matter intake (kg ash/kg DM).}
#'     \item{nitrogen_excretion}{Numeric. Daily nitrogen excretion (kg N/head/day).}
#'   }
#'
#' @param manure_management_system_fraction data.table. Cohort-level MMS fractions
#'   with:
#'   \describe{
#'   \item{herd_id}{Character. Unique identifier for the herd, repeated for each cohort belonging to the same herd.}
#'   \item{cohort_short}{Character. Sex- and age-specific cohort code describing the
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
#'     \item{manure_management_system_fraction}{Numeric. Fraction of total manure excreted by animals in a given herd and cohort that is handled in a specific manure management system. Values ranges from 0 to 1. The sum of all fractions for each herd_id must equal 1.}
#'   }
#'
#' @param manure_management_system_factors data.table. Herd-level MMS factors
#'   with:
#'   \describe{
#'     \item{manure_management_system}{Character. Name identifying the manure management system. The identifiers mms_pasture and mms_burned are reserved for manure deposited on pasture and manure burned for fuel, respectively. No specific naming convention is required for other manure management systems, which are grouped and handled as “other” systems.}
#'     \item{ratio_m3CH4_to_kgCH4}{
#'       Numeric. Conversion factor used to convert methane (CH4) from
#'       volumetric unit (m3) to a mass unit (kg). This value represents the
#'       density of methane. It defaults to 0.67 kg/m3
#'     }
#'     \item{methane_conversion_factor_mcf}{
#'       Numeric. Methane (CH4) conversion factor represents the portion or
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
#'       Numeric. Maximum methane (CH4) producing capacity (B0) for all systems
#'       (m3 CH4/kg VS). The value is region- and species-specific, and represents
#'       the theoretical maximum methane yield per unit of volatile solids.
#'       Default can be selected from Table 10.16 (IPCC, 2019) or from
#'       Tables 10A-4 to 10A-9 (IPCC, 2006).
#'     }
#'     \item{n2o_ef3}{
#'       Numeric. Emission factor for direct nitrous oxide (N2O) emissions for
#'       each manure management system, representing nitrous oxide emitted per
#'       unit of nitrogen from nitrification and denitrification processes
#'       occurring during manure storage and treatment (kg N2O–N per kg N).
#'       Default values can be selected from Table 10.21 and Table 11.1
#'       (for manure deposited on pasture) in IPCC Guidelines (IPCC 2006, 2019).
#'     }
#'     \item{n2o_ef4}{
#'       Numeric. Emission factor for indirect nitrous oxide (N2O) emissions
#'       resulting from atmospheric deposition of volatilised nitrogen
#'       (NH3–N and NOx–N) onto soils and water surfaces (kg N2O–N / (kg NH3–N + NOx–N)).
#'        Default values can be selected from Table 11.3 in IPCC Guidelines (IPCC 2006, 2019).
#'     }
#'     \item{nitrogen_fracgas}{
#'       Numeric. Fraction of manure nitrogen excreted by a given livestock
#'       category that is lost through volatilisation as ammonia (NH3) and
#'       nitrogen oxides (NOx) within a specific manure management system.
#'       This parameter represents the share of excreted nitrogen that is
#'       mineralised and released to the atmosphere during manure collection,
#'       storage, and treatment. It is expressed as a dimensionless fraction (0–1).
#'       Default values are provided in Table 10.22 of IPCC Guidelines (IPCC 2006, 2019).
#'     }
#'     \item{n2o_ef5}{
#'       Numeric. Emission factor for indirect nitrous oxide (N2O) emissions
#'       resulting from nitrogen leaching and runoff, expressed as kilograms of
#'       N2O–N per kilogram of nitrogen leached or lost through runoff (kg N2O–N/kg N).
#'       Default values can be selected from Table 11.3 in IPCC Guidelines (IPCC 2006, 2019).
#'     }
#'     \item{nitrogen_fracleach}{
#'       Numeric. Fraction of manure nitrogen excreted by a given livestock
#'       category that is lost through leaching and runoff from a specific
#'       manure management system. This parameter is highly uncertain and is used
#'       to estimate indirect N2O emissions from nitrogen that enters the
#'       surrounding environment of the storage facility. It is expressed as a
#'       dimensionless fraction (0–1). Default values are provided in Table 10.22
#'       of IPCC Guidelines (IPCC 2006, 2019).
#'     }
#'   }
#'
#' @param show_indicator Logical. Whether to display progress indicators during
#'   the calculation. Defaults to \code{TRUE}.
#'
#' @return cohort_level_data data.table. Input cohort table with added manure
#'   emissions columns:
#'   \describe{
#'     \item{volatile_solids}{Numeric. Total volatile solids (VS) excreted per animal per day, representing the organic material in livestock manure and consisting of both biodegradable and non-biodegradable fractions (kg VS/head/day).}
#'     \item{ch4_manure_pasture}{Numeric. Methane (CH4) emissions from manure deposited on pasture (kg CH4/head/day).}
#'     \item{ch4_manure_burned}{Numeric. Methane (CH4) emissions from manure burned for fuel (kg CH4/head/day).}
#'     \item{ch4_manure_other}{Numeric. Methane (CH4) emissions from manure management systems, excluding emissions from manure deposited on pasture and burned for fuel (kg CH4/head/day).}
#'     \item{ch4_manure_all_noburn}{Numeric. Methane (CH4) emissions from manure management systems, excluding manure burned for fuel (kg CH4/head/day).}
#'     \item{n2o_manure_pasture_direct}{Numeric. Direct nitrous oxide (N2O) emissions from manure deposited on pasture (kg N2O/head/day).}
#'     \item{n2o_manure_burned_direct}{Numeric. Direct nitrous oxide (N2O) emissions from manure burned for fuel (kg N2O/head/day).}
#'     \item{n2o_manure_other_direct}{Numeric. Direct nitrous oxide (N2O) emissions from manure management systems, excluding emissions from manure deposited on pasture and burned for fuel (kg N2O/head/day).}
#'     \item{n2o_manure_all_noburn_direct}{Numeric. Direct nitrous oxide (N2O) emissions from manure management systems, excluding emissions from manure burned for fuel (kg N2O/head/day).}
#'     \item{n2o_manure_pasture_vol}{Numeric. Indirect nitrous oxide (N2O) emissions resulting from atmospheric deposition of volatilised nitrogen (NH3 and NOx) from manure deposited on pasture (kg N2O/head/day).}
#'     \item{n2o_manure_burned_vol}{Numeric. Indirect nitrous oxide (N2O) emissions resulting from atmospheric deposition of volatilised nitrogen (NH3 and NOx) from manure burned for fuel (kg N2O/head/day).}
#'     \item{n2o_manure_other_vol}{Numeric. Indirect nitrous oxide (N2O) emissions resulting from atmospheric deposition of volatilised nitrogen (NH3 and NOx) from manure management systems, excluding manure deposited on pasture and manure burned for fuel (kg N2O/head/day).}
#'     \item{n2o_manure_all_noburn_vol}{Numeric. Indirect nitrous oxide (N2O) emissions resulting from atmospheric deposition of volatilised nitrogen (NH3 and NOx) from manure management systems, excluding losses from manure burned for fuel (kg N2O/head/day).}
#'     \item{n2o_manure_pasture_leach}{Numeric. Indirect nitrous oxide (N2O) emissions resulting from leaching and runoff of manure nitrogen from manure deposited on pasture (kg N2O/head/day).}
#'     \item{n2o_manure_burned_leach}{Numeric. Indirect nitrous oxide (N2O) emissions resulting from leaching and runoff of manure nitrogen from manure burned for fuel (kg N2O/head/day).}
#'     \item{n2o_manure_other_leach}{Numeric. Indirect nitrous oxide (N2O) emissions resulting from leaching and runoff of manure nitrogen from manure management systems, excluding losses from manure deposited on pasture and manure burned for fuel (kg N2O/head/day).}
#'     \item{n2o_manure_all_noburn_leach}{Numeric. Indirect nitrous oxide (N2O) emissions resulting from leaching and runoff of manure nitrogen from manure management systems, excluding losses from manure burned for fuel (kg N2O/head/day).}
#'     \item{n2o_manure_pasture_indirect}{Numeric. Total indirect nitrous oxide (N2O) emissions from manure deposited on pasture. Includes emissions from atmospheric deposition of volatilised nitrogen (NH3 and NOx) and from leaching and runoff of manure nitrogen (kg N2O/head/day).}
#'     \item{n2o_manure_burned_indirect}{Numeric. Total indirect nitrous oxide (N2O) emissions originating from manure burned for fuel. Includes emissions from atmospheric deposition of volatilised nitrogen (NH3 and NOx) and from leaching and runoff of manure nitrogen (kg N2O/head/day).}
#'     \item{n2o_manure_other_indirect}{Numeric. Total indirect nitrous oxide (N2O) emissions originating from manure management systems, excluding manure deposited on pasture and burned for fuel. Includes emissions from atmospheric deposition of volatilised nitrogen (NH3 and NOx) and from leaching and runoff of manure nitrogen.}
#'     \item{n2o_manure_pasture_total}{Numeric. Total nitrous oxide emissions from manure deposited on pasture. Includes direct emissions and indirect emissions from volatilisation, leaching, and runoff (kg N2O/head/day).}
#'     \item{n2o_manure_burned_total}{Numeric. Total nitrous oxide emissions (N2O) from manure burned for fuel. Includes direct emissions and indirect emissions from volatilisation, leaching, and runoff (kg N2O/head/day).}
#'     \item{n2o_manure_other_total}{Numeric. Total nitrous oxide (N2O) emissions from manure management systems, excluding manure deposited on pasture and manure burned for fuel. Includes direct emissions and indirect emissions from volatilisation, leaching, and runoff (kg N2O/head/day).}
#'   }
#'
#' @section Manure management system (MMS) reference:
#' A complete list of MMS names,
#' definitions, and associated emission factors can be accessed in the
#' [GLEAM Data Explorer](https://foodandagricultureorganization.shinyapps.io/GLEAM_Data_Explorer/).
#'
#' @details
#' This function represents the intermediate module of the Global Livestock Environmental
#' Assessment Model (GLEAM) computational pipeline [run_gleam()] to estimate emissions from
#' manure management systems (MMS) and orchestrates a cohort-level implementation of the IPCC manure
#' management methodology.
#'
#' The following calculation sequence is applied:
#' \enumerate{
#'   \item VS excretion is computed from nutritional parameters of the feed ration
#'   (digestibility, urinary energy, and ash) using a simplified formulation of Equation 10.24
#'   (IPCC 2006, 2019) - \code{\link{calc_volatile_solids}}
#'   \item Methane (CH4) emissions from manure management are computed from VS
#'   and MMS-specific factors (MCF and B0) and reported by MMS group (pasture, burned,
#'   and other), consistently with Equation 10.23 (IPCC, 2006, 2019) - \code{\link{calc_ch4_manure}}
#'   \item Direct nitrous oxide (N2O) emissions from manure management are
#'   computed from nitrogen excretion and MMS-specific EF3 values, and reported
#'   by MMS group, consistently with Equation 10.25 (IPCC, 2006, 2019) -  \code{\link{calc_n2o_manure_direct}}
#'   \item Indirect N2O emissions are computed as the sum of:
#'   \itemize{
#'     \item volatilisation-driven N2O using MMS-specific nitrogen losses
#'     (FracGas) and EF4, consistently with Equations 10.26 (IPCC, 2006, 2019),
#'     10.27 (IPCC, 2006), and 10.28 (IPCC, 2019) - \code{\link{calc_n2o_manure_volatilization}}
#'     \item leaching/runoff-driven N2O using MMS-specific nitrogen losses
#'     (FracLeach) and EF5, consistently with Equations 10.28 (IPCC, 2006),
#'     10.27 (IPCC, 2019), and 10.29 (IPCC, 2006, 2019) - \code{\link{calc_n2o_manure_leaching}}
#'   }
#'   \item Total N2O emissions are aggregated by MMS group
#'   (pasture, burned, other) - \code{\link{calc_n2o_manure_total}}
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
#' \code{\link{run_gleam}},
#' \code{\link{calc_volatile_solids}},
#' \code{\link{calc_ch4_manure}},
#' \code{\link{calc_n2o_manure_direct}},
#' \code{\link{calc_n2o_manure_volatilization}},
#' \code{\link{calc_n2o_manure_leaching}},
#' \code{\link{calc_n2o_manure_total}}
#'
#' @examples
#' \donttest{
#' # Load emissions manure inputs (cohort-level and system lookups)
#' emissions_manure_input_chrt_data <- data.table::fread(system.file(
#'   "extdata/run_modules_examples/emissions_manure_input_chrt_data.csv",
#'   package = "gleam"
#' ))
#' manure_management_system_factors <- data.table::fread(system.file(
#'   "extdata/run_modules_examples/manure_management_system_factors.csv",
#'   package = "gleam"
#' ))
#' manure_management_system_fraction <- data.table::fread(system.file(
#'   "extdata/run_modules_examples/manure_management_system_fraction.csv",
#'   package = "gleam"
#' ))
#'
#' results <- run_emissions_manure_module(
#'   cohort_level_data = emissions_manure_input_chrt_data,
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
run_emissions_manure_module <- function(
    cohort_level_data,
    manure_management_system_fraction,
    manure_management_system_factors,
    show_indicator = TRUE
) {
  # --- Step 1: Validate inputs ------------------------------------------------
  validate_run_emissions_manure_module_inputs(
    cohort_level_data = cohort_level_data,
    manure_management_system_fraction = manure_management_system_fraction,
    manure_management_system_factors = manure_management_system_factors
  )

  # Show progress indicator if requested
  if (show_indicator) {
    cli::cli_status("\U1F552 Calculating emissions from manure management systems\u2026")
  }

  # --- Step 2: Prepare inputs -------------------------------------------------
  cohort_level_data <- data.table::copy(cohort_level_data)
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
      ration_intake = ration_intake,
      ration_digestibility_fraction = ration_digestibility_fraction,
      ration_urinary_energy_fraction = ration_urinary_energy_fraction,
      ration_ash = ration_ash
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
      current_cohort <- cohort_short
      mms_rows <- mms_data[herd_id == current_herd_id & cohort_short == current_cohort]

      # Build the list expected by calc_ch4_manure(...)
      mms_list <- build_mms_list(
        mms_rows,
        c("manure_management_system_fraction",
          "methane_conversion_factor_mcf",
          "ch4_max_producing_capacity_bo")
      )

      # calc_ch4_manure() accepts variable MMS inputs via `...`.
      ch4 <- do.call(
        calc_ch4_manure, c(list(volatile_solids = volatile_solids), mms_list)
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
      current_cohort <- cohort_short
      mms_rows <- mms_data[herd_id == current_herd_id & cohort_short == current_cohort]

      # Build the list expected by calc_n2o_manure_direct(...)
      mms_list <- build_mms_list(mms_rows, c("manure_management_system_fraction", "n2o_ef3"))

      # calc_n2o_manure_direct() accepts variable MMS inputs via `...`.
      n2o_direct <- do.call(
        calc_n2o_manure_direct,
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
      "n2o_manure_pasture_vol",
      "n2o_manure_burned_vol",
      "n2o_manure_other_vol",
      "n2o_manure_all_noburn_vol"
    ) := {
      # Select MMS records for this herd/cohort (fractions + factors).
      current_herd_id <- herd_id
      current_cohort <- cohort_short
      mms_rows <- mms_data[herd_id == current_herd_id & cohort_short == current_cohort]

      # Build the list expected by calc_n2o_manure_volatilization(...)
      mms_list <- build_mms_list(
        mms_rows, c("manure_management_system_fraction", "n2o_ef4", "nitrogen_fracgas")
      )

      # calc_n2o_manure_volatilization() accepts variable MMS inputs via `...`.
      n2o_vol <- do.call(
        calc_n2o_manure_volatilization,
        c(list(nitrogen_excretion = nitrogen_excretion), mms_list)
      )
      list(
        n2o_vol$n2o_manure_pasture_vol,
        n2o_vol$n2o_manure_burned_vol,
        n2o_vol$n2o_manure_other_vol,
        n2o_vol$n2o_manure_all_noburn_vol
      )
    },
    by = .I
  ]

  # --- Step 7: Indirect N2O from leaching/runoff ------------------------------
  cohort_level_data[
    ,
    c(
      "n2o_manure_pasture_leach",
      "n2o_manure_burned_leach",
      "n2o_manure_other_leach",
      "n2o_manure_all_noburn_leach"
    ) := {
      # Select MMS records for this herd/cohort (fractions + factors).
      current_herd_id <- herd_id
      current_cohort <- cohort_short
      mms_rows <- mms_data[herd_id == current_herd_id & cohort_short == current_cohort]

      # Build the list expected by calc_n2o_manure_leaching(...)
      mms_list <- build_mms_list(
        mms_rows, c("manure_management_system_fraction", "n2o_ef5", "nitrogen_fracleach")
      )

      # calc_n2o_manure_leaching() accepts variable MMS inputs via `...`.
      n2o_leach <- do.call(
        calc_n2o_manure_leaching,
        c(list(nitrogen_excretion = nitrogen_excretion), mms_list)
      )
      list(
        n2o_leach$n2o_manure_pasture_leach,
        n2o_leach$n2o_manure_burned_leach,
        n2o_leach$n2o_manure_other_leach,
        n2o_leach$n2o_manure_all_noburn_leach
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
      totals <- calc_n2o_manure_total(
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

  # Clear progress indicator if it was shown
  if (show_indicator) {
    cli::cli_status_clear()
    cli::cli_alert_success("Emissions from manure management calculation complete.")
  }

  return(cohort_level_data)
}
