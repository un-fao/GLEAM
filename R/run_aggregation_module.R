#' Run Aggregation Pipeline: Final Herd-Level Results
#'
#' This function represents the final step of the Global Livestock Environmental
#' Assessment Model (GLEAM) computational pipeline. It generates final herd-level
#' results by aggregating key cohort-level outputs, scaling variables over the
#' assessment duration, allocating emissions to commodities, and converting CH₄
#' and N₂O emissions to CO₂-equivalents (CO₂eq) using selected 100-year Global
#' Warming Potential (GWP-100) factors.
#'
#' @param cohort_level_data data.table. Cohort-level input table with the following data requirement:
#'   \describe{
#'     \item{herd_id}{Character. Unique identifier for the herd, repeated for each cohort belonging to the same herd.}
#'     \item{species_short}{Character. Livestock species code. Supported values include:
#'       \itemize{
#'         \item \code{CTL}: cattle
#'         \item \code{BFL}: buffalo
#'         \item \code{SHP}: sheep
#'         \item \code{GTS}: goats
#'         \item \code{CHK}: chickens
#'         \item \code{PGS}: pigs
#'         \item \code{CML}: camels
#'       }}
#'     \item{cohort_short}{Character. Sex- and age-specific cohort code. Supported values include:
#'       \itemize{
#'         \item \code{FA}: adult females
#'         \item \code{FS}: sub-adult females
#'         \item \code{FJ}: juvenile females
#'         \item \code{MA}: adult males
#'         \item \code{MS}: sub-adult males
#'         \item \code{MJ}: juvenile males
#'       }}
#'     \item{cohort_stock_size}{Numeric. Average population size in each of the 6 sex–age cohorts (# heads). (cohorts=FJ, FS, FA, MJ, MS, MA).}
#'     \item{\strong{Feed variables}}{
#'       \describe{
#'         \item{ration_intake}{Numeric. Average daily dry matter intake of feed (kg DM/head/day).}
#'       }
#'     }
#'     \item{\strong{Nitrogen balance variables}}{
#'       \describe{
#'         \item{nitrogen_intake}{Numeric. Daily nitrogen intake (kg N/head/day)}
#'         \item{nitrogen_retention}{Numeric. Daily nitrogen retention in animal body tissues and products (e.g., growth, pregnancy, milk...) (kg N/head/day).}
#'         \item{nitrogen_excretion}{Numeric. Daily nitrogen excretion (kg N/head/day)}
#'       }
#'     }
#'     \item{\strong{Production variables}}{
#'       \describe{
#'         \item{milk_production_mass_cohort}{Numeric. Total milk production produced over the assessment period (kg/cohort/assessment period).}
#'         \item{milk_production_protein_cohort}{Numeric. Total milk protein production produced over the assessment period (kg protein/cohort/assessment period).}
#'         \item{milk_production_fpcm_cohort}{Numeric. Total fat-protein-corrected milk (FPCM) produced over the assessment period (kg/cohort/assessment period).}
#'         \item{meat_production_live_weight_cohort}{Numeric . Total meat produced as live weight over the assessment period by cohort (kg/cohort/assessment period).}
#'         \item{meat_production_carcass_weight_cohort}{Numeric. Total meat as carcass weight (excluding organs, and other by-products after dressing) produced over the assessment period by cohort (kg/cohort/assessment period).}
#'         \item{meat_production_bone_free_meat_cohort}{Numeric. Total bone-free-meat (excluding bones, organs, and other by-products after dressing and bone removal) produced over the assessment period by cohort (kg/cohort/assessment period)}
#'         \item{meat_production_protein_cohort}{Numeric. Total meat protein (excluding bones, organs, and other by-products after dressing and bone removal) produced over the assessment period by cohort (kg protein/cohort/assessment period).}
#'         \item{fibre_production_cohort}{Numeric. Total fibre produced over the assessment period by cohort (kg/cohort/assessment period)}
#'       }
#'     }
#'     \item{\strong{Emission variables}}{
#'       \describe{
#'         \item{ch4_enteric}{Numeric. Average daily enteric methane (CH₄) emissions (kg CH₄/head/day).}
#'         \item{ch4_manure_pasture}{Numeric. Methane (CH₄) emissions from manure deposited on pasture (kg CH₄/head/day)}
#'         \item{ch4_manure_burned}{Numeric. Methane (CH₄) emissions from manure burned for fuel (kg CH₄/head/day)}
#'         \item{ch4_manure_other}{Numeric. Methane (CH₄) emissions from manure management systems, excluding emissions from manure deposited on pasture and burned for fuel (kg CH₄/head/day)}
#'         \item{n2o_manure_pasture_direct}{Numeric. Direct nitrous oxide (N₂O) emissions from manure deposited on pasture (kg N₂O/head/day)}
#'         \item{n2o_manure_burned_direct}{Numeric. Direct nitrous oxide (N₂O) emissions from manure burned for fuel (kg N₂O/head/day)}
#'         \item{n2o_manure_other_direct}{Numeric. Direct nitrous oxide (N₂O) emissions from manure management systems, excluding emissions from manure deposited on pasture and burned for fuel (kg N₂O/head/day)}
#'         \item{n2o_manure_burned_indirect}{Numeric. Total indirect nitrous oxide (N₂O) emissions from manure deposited on pasture. Includes emissions from atmospheric deposition of volatilised nitrogen (NH₃ and NOₓ) and from leaching and runoff of manure nitrogen (kg N₂O/head/day).}
#'         \item{n2o_manure_pasture_indirect}{Numeric. Total indirect nitrous oxide (N₂O) emissions originating from manure burned for fuel. Includes emissions from atmospheric deposition of volatilised nitrogen (NH₃ and NOₓ) and from leaching and runoff of manure nitrogen (kg N₂O/head/day).}
#'         \item{n2o_manure_other_indirect}{Numeric. Total indirect nitrous oxide (N₂O) emissions originating from manure management systems, excluding manure deposited on pasture and burned for fuel. Includes emissions from atmospheric deposition of volatilised nitrogen (NH₃ and NOₓ) and from leaching and runoff of manure nitrogen (kg N₂O/head/day).}
#'         \item{co2_ration_fertilizer}{Numeric. Diet-level average carbon dioxide (CO₂) emission factor from fertilizer manufacture in feed production (g CO₂/kg DM).}
#'         \item{co2_ration_pesticides}{Numeric. Diet-level average carbon dioxide (CO₂) emission factor from pesticide manufacture in feed production (g CO₂/kg DM).}
#'         \item{co2_ration_crop_activities}{Numeric. Diet-level average carbon dioxide (CO₂) emission factor from on-field agricultural activities in feed production (g CO₂/kg DM).}
#'         \item{co2_ration_luc_nopeat}{Numeric. Diet-level average carbon dioxide (CO₂) emission factor from land-use change (excluding peatland drainage) in feed production (g CO₂/kg DM).}
#'         \item{co2_ration_luc_peat}{Numeric. Diet-level average carbon dioxide (CO₂) emission factor from  peatland drainage in feed production (g CO₂/kg DM).}
#'         \item{n2o_ration_fertilizer}{Numeric. Diet-level average nitrous oxide (N₂O) emission factor from fertilizer use in feed production (g N₂O/kg DM).}
#'         \item{n2o_ration_manure_applied}{Numeric. Diet-level average nitrous oxide (N₂O) emission factor from manure applied to or deposited on soil in feed production (g N₂O/kg DM).}
#'         \item{n2o_ration_crop_residues}{Numeric. Diet-level average nitrous oxide (N₂O) emission factor from crop residues decomposition in feed production (g N₂O/kg DM).}
#'         \item{ch4_ration_rice}{Numeric. Diet-level average methane (CH₄) emission factor from rice cultivation in feed production (g CH₄/kg DM).}
#'       }
#'     }
#'   }
#'
#' @param allocation_herd_long data.table. Herd-level allocation table in long format, typically generated by [run_allocation_module()], with the following data requirements:
#'   \describe{
#'     \item{herd_id}{Character. Unique identifier for the herd, repeated for each cohort belonging
#'     to the same herd.}
#'     \item{species_short}{Character. Code identifying the livestock species.
#'     Supported values include:
#'       \itemize{
#'         \item \code{PGS}: pigs
#'         \item \code{CML}: camels
#'         \item \code{CTL}: cattle
#'         \item \code{BFL}: buffalo
#'         \item \code{SHP}: sheep
#'         \item \code{GTS}: goats
#'       }}
#'     \item{variable_name}{Character. Names of emission variables to which
#'     allocation should be applied (e.g., "ch4_enteric", "ch4_manure_pasture",
#'     "ch4_manure_burned", "ch4_manure_other", "n2o_manure_pasture_direct",
#'     "n2o_manure_burned_direct", "n2o_manure_other_direct",
#'     "n2o_manure_burned_indirect", "n2o_manure_pasture_indirect",
#'     "n2o_manure_other_indirect", "co2_ration_fertilizer",
#'     "co2_ration_pesticides", "co2_ration_crop_activities",
#'     "co2_ration_luc_nopeat", "co2_ration_luc_peat",
#'     "n2o_ration_fertilizer", "n2o_ration_manure_applied",
#'     "n2o_ration_crop_residues", "ch4_ration_rice")}
#'     \item{commodity_name}{Character. List of commodity categories to which emissions may be allocated.
#'     List = c("None", "Milk", "Meat", "Fibre", "Work", "Eggs")}
#'     \item{commodity_type}{Character. Commodity (commodity_name) grouping, either
#'     \code{"Edible"} or \code{"Non-Edible"}.}
#'     \item{allocation_share}{Numeric. Allocation share assigned to the commodity for the corresponding emission source (fraction).}
#'   }
#'
#' @param simulation_duration Numeric. Length of the assessment period (days).
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
#' @param show_indicator Logical. Whether to display progress indicators during
#'   the pipeline run. Defaults to `TRUE`.
#'
#' @return A named list with the following elements:
#' \describe{
#'   \item{results_emissions}{A \code{data.table} containing herd-level emissions
#'   scaled to the assessment duration and allocated to commodities. Includes gas type,
#'   allocation shares, commodity metadata, GWP factors, and emissions expressed both as
#'   allocated gas mass (kg gas) and as CO₂-equivalents (kg CO₂eq).}
#'
#'   \item{results_feed}{A \code{data.table} containing herd-level feed variables,
#'   aggregated at herd level and scaled to the assessment duration.}
#'
#'   \item{results_production}{A \code{data.table} containing herd-level production
#'   variables aggregated from cohort-level values over the assessment duration.}
#'
#'   \item{results_nitrogen}{A \code{data.table} containing herd-level nitrogen
#'   balance variables aggregated from cohort-level values and scaled to the
#'   assessment duration.}
#' }
#'
#' @details
#' This function performs the following calculation sequence:
#' \enumerate{
#'   \item Cohort-level variables are reshaped from wide to long format.
#'   \item Variables are classified into \code{"Feed"}, \code{"NitrogenBalance"}, \code{"Production"}, and \code{"Emissions"}.
#'   \item Cohort totals are calculated using [calc_cohort_totals()]. Production variables are retained as provided, whereas emissions, feed, and nitrogen balance variables are scaled using cohort stock size and simulation duration.
#'   \item Cohort totals are aggregated to herd level within each \code{herd_id × species_short × variable_type × variable_name} group.
#'   \item Herd-level emissions are merged with commodity allocation shares from \code{allocation_herd_long}.
#'   \item Emissions are allocated to commodities using [calc_allocated_emissions()].
#'   \item Gas type is identified from the emission variable name as \code{"CH4"}, \code{"N2O"}, or \code{"CO2"}.
#'   \item Allocated CH₄, N₂O, and CO₂ emissions are converted to CO₂-equivalents (CO₂eq) using [calc_co2eq()] and the selected GWP-100 option.
#'   \item Final output tables are produced summarising herd-level results for emissions, feed, production, and nitrogen balance variables.
#' }
#'
#' @seealso
#' [calc_cohort_totals()],
#' [calc_cohort_to_herd_aggregation()],
#' [calc_allocated_emissions()],
#' [calc_co2eq()],
#' [run_allocation_module()]
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Load cohort-level aggregation input
#' aggregation_chrt_dt <- data.table::fread(system.file(
#'   "extdata/run_modules_examples/aggregation_input_chrt_data.csv",
#'   package = "gleam"
#' ))
#'
#' # Load allocation shares (herd-level, long format)
#' allocation_long <- data.table::fread(system.file(
#'   "extdata/run_modules_examples/aggregation_allocation_input_data.csv",
#'   package = "gleam"
#' ))
#'
#' # Run aggregation
#' results <- run_aggregation_module(
#'   cohort_level_data = aggregation_chrt_dt,
#'   allocation_herd_long = allocation_long,
#'   simulation_duration = 365,
#'   global_warming_potential_set = "AR6"
#' )
#' head(results$results_herd)
#' }
#'
#' @importFrom data.table := .I melt fcase setcolorder rbindlist
run_aggregation_module <- function(
    cohort_level_data,
    allocation_herd_long,
    simulation_duration = 365,
    global_warming_potential_set = "AR6",
    show_indicator = TRUE
) {
  # --- Input validation -------------------------------------------------------
  cohort_level_data <- data.table::as.data.table(cohort_level_data)
  validate_run_aggregation_module_inputs(
    cohort_level_data = cohort_level_data,
    allocation_herd_long = allocation_herd_long,
    simulation_duration = simulation_duration,
    global_warming_potential_set = global_warming_potential_set
  )

  # Show progress indicator if requested
  if (show_indicator) {
    cli::cli_status("\U1F552 Aggregating results, please wait\U2026")
  }

  # --- Step 1: Define variable groups -----------------------------------------
  feed_list <- list(
    list(
      feed_source = "ration_intake",
      label = "DryMatterIntake",
      unit = "kg dry matter"
    )
  )

  feed_vars <- sapply(feed_list, `[[`, "feed_source")

  nitrogen_balance_list <- list(
    list(
      nitrogen_balance_source = "nitrogen_intake",
      label = "NitrogenIntake",
      unit = "kg N"
    ),
    list(
      nitrogen_balance_source = "nitrogen_retention",
      label = "NitrogenRetention",
      unit = "kg N"
    ),
    list(
      nitrogen_balance_source = "nitrogen_excretion",
      label = "NitrogenExcretion",
      unit = "kg N"
    )
  )

  nitrogen_balance_vars <- sapply(nitrogen_balance_list, `[[`, "nitrogen_balance_source")

  production_list <- list(
    list(
      production_source = "milk_production_mass_cohort",
      label = "MilkRaw",
      unit = "kg",
      commodity_name = "Milk",
      commodity_type = "Edible"
    ),
    list(
      production_source = "milk_production_protein_cohort",
      label = "MilkProtein",
      unit = "kg protein",
      commodity_name = "Milk",
      commodity_type = "Edible"
    ),
    list(
      production_source = "milk_production_fpcm_cohort",
      label = "MilkFatProteinCorrected",
      unit = "kg fat-protein corrected",
      commodity_name = "Milk",
      commodity_type = "Edible"
    ),
    list(
      production_source = "meat_production_live_weight_cohort",
      label = "MeatLiveWeight",
      unit = "kg live weight",
      commodity_name = "Meat",
      commodity_type = "Edible"
    ),
    list(
      production_source = "meat_production_carcass_weight_cohort",
      label = "MeatCarcassWeight",
      unit = "kg carcass weight",
      commodity_name = "Meat",
      commodity_type = "Edible"
    ),
    list(
      production_source = "meat_production_bone_free_meat_cohort",
      label = "MeatBoneFree",
      unit = "kg bone-free meat",
      commodity_name = "Meat",
      commodity_type = "Edible"
    ),
    list(
      production_source = "meat_production_protein_cohort",
      label = "MeatProtein",
      unit = "kg protein",
      commodity_name = "Meat",
      commodity_type = "Edible"
    ),
    list(
      production_source = "fibre_production_cohort",
      label = "Fibre",
      unit = "kg",
      commodity_name = "Fibre",
      commodity_type = "Edible"
    )
  )

  production_vars <- sapply(production_list, `[[`, "production_source")

  feed_emissions_list <- list(
    list(emissions_source = "co2_ration_fertilizer", label = "Feed-Fertilizer_CO2"),
    list(emissions_source = "co2_ration_pesticides", label = "Feed-Pesticides_CO2"),
    list(emissions_source = "co2_ration_crop_activities", label = "Feed-CropOperations_CO2"),
    list(emissions_source = "co2_ration_luc_nopeat", label = "Feed-LandUseChange_CO2"),
    list(emissions_source = "co2_ration_luc_peat", label = "Feed-PeatDrainage_CO2"),

    list(emissions_source = "n2o_ration_fertilizer", label = "Feed-Fertilizer_N2O"),
    list(emissions_source = "n2o_ration_manure_applied", label = "Feed-ManureApplication_N2O"),
    list(emissions_source = "n2o_ration_crop_residues", label = "Feed-CropResidues_N2O"),

    list(emissions_source = "ch4_ration_rice", label = "Feed-Rice_CH4")
  )

  emissions_list <- c(
    list(
      list(emissions_source = "ch4_enteric", label = "Enteric_CH4"),
      list(emissions_source = "ch4_manure_pasture", label = "Manure-Pasture_CH4"),
      list(emissions_source = "ch4_manure_burned", label = "Manure-Burned_CH4"),
      list(emissions_source = "ch4_manure_other", label = "Manure-Other_CH4"),

      list(emissions_source = "n2o_manure_pasture_direct", label = "ManureDirect-Pasture_N2O"),
      list(emissions_source = "n2o_manure_burned_direct", label = "ManureDirect-Burned_N2O"),
      list(emissions_source = "n2o_manure_other_direct", label = "ManureDirect-Other_N2O"),

      list(emissions_source = "n2o_manure_burned_indirect", label = "ManureIndirect-Burned_N2O"),
      list(emissions_source = "n2o_manure_pasture_indirect", label = "ManureIndirect-Pasture_N2O"),
      list(emissions_source = "n2o_manure_other_indirect", label = "ManureIndirect-Other_N2O")
    ),
    feed_emissions_list
  )

  emissions_vars <- sapply(emissions_list, `[[`, "emissions_source")

  # Check that required variables exist in cohort_level_data
  all_vars <- unique(
    c(feed_vars, nitrogen_balance_vars, production_vars, emissions_vars)
  )
  available_vars <- intersect(all_vars, names(cohort_level_data))
  if (length(available_vars) == 0) {
    cli::cli_abort(
      "No recognized variables found in {.arg cohort_level_data}.
      Expected variables include: {.val {all_vars}}"
    )
  }

  # --- Step 2: Reshape cohort_level_data to long format -----------------------
  data_cohort_long <- data.table::melt(
    cohort_level_data,
    id.vars = c(
      "herd_id",
      "species_short",
      "cohort_short",
      "cohort_stock_size",
      "ration_intake"
    ),
    measure.vars = available_vars,
    variable.name = "variable_name",
    value.name = "value",
    variable.factor = FALSE
  )

  # --- Step 3: Classify variables by type -------------------------------------
  data_cohort_long[
    , variable_type := data.table::fcase(
      variable_name %in% feed_vars, "Feed",
      variable_name %in% nitrogen_balance_vars, "NitrogenBalance",
      variable_name %in% production_vars, "Production",
      variable_name %in% emissions_vars, "Emissions",
      default = "Other"
    )
  ]

  # --- Step 4: Calculate totals by cohort -------------------------------------
  # Scale per-head-per-day values to cohort totals over simulation duration
  data_cohort_long[
    , value_total := calc_cohort_totals(
      value = value,
      cohort_stock_size = cohort_stock_size,
      ration_intake = ration_intake,
      feed_emissions_list = feed_emissions_list,
      simulation_duration = simulation_duration,
      variable_name = variable_name,
      variable_type = variable_type
    ),
    by = .I
  ]

  # --- Step 5: Aggregate from cohort to herd level ----------------------------
  # Sum all cohort values to get herd-level totals
  data_herd_long <- calc_cohort_to_herd_aggregation(
    data_cohort = data_cohort_long,
    id_cols = c(
      "herd_id",
      "species_short",
      "variable_type",
      "variable_name"
    ),
    vars_to_sum = "value_total",
    cohort_short = "cohort_short"
  )

  # --- Step 6: Subsetting datframes by variable_type --------------------------
  data_herd_long_production <- data_herd_long[variable_type == "Production"]
  data_herd_long_nitrogen <- data_herd_long[variable_type == "NitrogenBalance"]
  data_herd_long_feed <- data_herd_long[variable_type == "Feed"]

  # --- Step 7: Subsetting emissions dataframe and merge emissions with allocation data
  # Only emissions need allocation; other variables are assigned to "ALL"
  data_herd_long_emissions <- merge(
    data_herd_long[
      variable_type == "Emissions",
      .(herd_id, species_short, variable_type, variable_name, value_total_gas = value_total)
    ],
    allocation_herd_long,
    by = c("herd_id", "species_short", "variable_name")
  )

  # --- Step 8: Allocate emissions to commodities ------------------------------
  data_herd_long_emissions[
    , value_total_allocated_gas := calc_allocated_emissions(
      value = value_total_gas,
      allocation_share = allocation_share
    ),
    by = .I
  ]

  # --- Step 9: Identify gas type for GWP conversion ---------------------------
  data_herd_long_emissions[
    , gas := data.table::fcase(
      grepl("ch4", variable_name, ignore.case = TRUE), "CH4",
      grepl("n2o", variable_name, ignore.case = TRUE), "N2O",
      grepl("co2", variable_name, ignore.case = TRUE), "CO2"
    )
  ]

  # --- Step 10: Convert to CO2-equivalents ------------------------------------
  data_herd_long_emissions[
    , c("value_total_allocated_co2eq", "gwp") := calc_co2eq(
      gas = gas,
      value_allocated = value_total_allocated_gas,
      global_warming_potential_set = global_warming_potential_set
    ),
    by = .I
  ]

  # --- Step 11: Cleaning-up output tables -------------------------------------

  # 11.1 Emissions
  emissions_dt <- data.table::rbindlist(emissions_list)
  data.table::setnames(emissions_dt, "emissions_source", "variable_name")

  data_herd_long_emissions <- merge(
    data_herd_long_emissions,
    emissions_dt,
    by = "variable_name"
  )

  # 12.2 Production
  production_dt <- data.table::rbindlist(production_list)
  data.table::setnames(production_dt, "production_source", "variable_name")

  data_herd_long_production <- merge(
    data_herd_long_production,
    production_dt,
    by = "variable_name"
  )

  # 12.3 Feed
  feed_dt <- data.table::rbindlist(feed_list)
  data.table::setnames(feed_dt, "feed_source", "variable_name")

  data_herd_long_feed <- merge(
    data_herd_long_feed,
    feed_dt,
    by = "variable_name"
  )

  # 12.4 Nitrogen balance
  nitrogen_balance_dt <- data.table::rbindlist(nitrogen_balance_list)
  data.table::setnames(nitrogen_balance_dt, "nitrogen_balance_source", "variable_name")

  data_herd_long_nitrogen <- merge(
    data_herd_long_nitrogen,
    nitrogen_balance_dt,
    by = "variable_name"
  )

  # Clear progress indicator if it was shown
  if (show_indicator) {
    cli::cli_status_clear()
    cli::cli_alert_success("Aggregation complete.")
  }

  # --- Return results ---------------------------------------------------------
  return(
    list(
      results_emissions = data_herd_long_emissions,
      results_feed = data_herd_long_feed,
      results_production = data_herd_long_production,
      results_nitrogen = data_herd_long_nitrogen
    )
  )
}
