#' Aggregation Pipeline: Final Herd-Level Results
#'
#' This function represents the final step of the Global Livestock Environmental
#' Assessment Model (GLEAM) computational pipeline.
#' It consolidates cohort-level outputs into standardized herd-level totals for reporting.
#' The function (i) scales per-head-per-day variables to cohort totals over the assessment
#' period, (ii) aggregates cohorts to herd level, (iii) allocates emissions to commodities
#' using allocation shares, and (iv) converts CH₄ and N₂O emissions to CO₂-equivalents using
#' a selected GWP-100 option.
#'
#'
#' The function follows this workflow:
#' \enumerate{
#'   \item \strong{Reshape to long format.} Cohort-level variables are converted from wide to long
#'     format using \code{data.table::melt()}.
#'   \item \strong{Classify variables.} Group variables into Emissions, Production, Feed, Nitrogen Balance.
#'   \item \strong{Scale to totals.} Variables expressed per head per day are converted to cohort totals
#'     over the assessment period using \code{cohort_stock_size} and \code{simulation_duration}.
#'   \item \strong{Aggregate to herd level.} Cohort totals are summed to herd totals within each
#'     \code{herd_id × species_short} group.
#'   \item \strong{Merge allocation data:} Combine emissions with allocation shares.
#'   \item \strong{Allocate emissions.} Emission totals are merged with
#'     \code{allocation_herd_long} and multiplied by \code{allocation_share} to obtain
#'     commodity-specific emissions. Non-emission variables are assigned to commodity \code{"ALL"}
#'     with \code{allocation_share = 1}.
#'   \item \strong{Convert to CO₂eq.} Allocated CH₄ and N₂O emissions are converted to CO₂eq using
#'     the selected GWP-100 option. Results are stored as \code{value_total} with \code{unit = "kg CO₂eq"}.
#'   \item \strong{Standardize output:} Rename variables, assign units, and format final results.
#' }
#'
#'
#'
#' @param cohort_level_data A `data.table` containing cohort-level data with all
#'   calculated variables. Must include:
#'   \describe{
#'     \item{**Feed variables**:}{`ration_intake` (kg DM/head/day)}
#'     \item{**Nitrogen balance**:}{`nitrogen_intake`, `nitrogen_retention`, `nitrogen_excretion`}
#'     \item{**Production**:}{`milk_production_*_cohort`, `meat_production_*_cohort`, `fibre_production_cohort`}
#'     \item{**Emissions**:}{`ch4_enteric`, `ch4_manure_*`, `direct_n2o_manure_*`,
#'       `indirect_n2o_manure_*`}
#'   }
#'   Required grouping columns: `herd_id`, `animal` (full species name, e.g. Cattle, Buffalo;
#'   mapped to \code{species_short} internally), `cohort_short`, \code{cohort_stock_size}.
#'
#' @param allocation_herd_long A `data.table` in long format, typically the
#'   output of [run_allocation_module()]. Must include columns:
#'   \describe{
#'     \item{**Grouping**:}{`herd_id`, `species_short`}
#'     \item{**Allocation**:}{`commodity_name` (e.g., "Meat", "Milk", "Fibre"),
#'       `allocation_share` (numeric, 0-1)}
#'     \item{**Emission source**:}{`variable_name` (emission variable names)}
#'   }
#' @param global_warming_potential_set Character scalar specifying the 100-year Global Warming Potential
#'   (GWP-100) conversion factors used to express CH₄ and N₂O emissions as CO₂-equivalents.
#'   Must be one of:
#'   \itemize{
#'     \item \code{"AR6"} (default): IPCC Sixth Assessment Report — CH₄ = 27, N₂O = 273
#'     \item \code{"AR5_excluding_carbon_feedback"}: IPCC Fifth Assessment Report
#'       (excluding climate–carbon feedbacks) — CH₄ = 28, N₂O = 265
#'     \item \code{"AR5_including_carbon_feedback"}: IPCC Fifth Assessment Report
#'       (including climate–carbon feedbacks) — CH₄ = 34, N₂O = 298
#'     \item \code{"AR4"}: IPCC Fourth Assessment Report — CH₄ = 25, N₂O = 298
#'   }
#' @param simulation_duration Numeric. Length of the assessment period (days). Used to
#'   scale per-head-per-day variables to cohort totals. Defaults to \code{365}.
#'
#' @return A named list containing:
#' \describe{
#'   \item{`cohort_level_results`}{The raw cohort-level input data and results.}
#'   \item{`results_herd`}{A `data.table` in long format with:
#'     \itemize{
#'       \item Allocated emissions (already converted in kgCO2eq)
#'       \item Production variables (milk, meat, fibre)
#'       \item Feed and nitrogen balance variables
#'       \item Standardized variable names and units
#'       \item Commodity classifications and allocation metadata
#'     }
#'     Columns include: `herd_id`, `species_short`,
#'     `cohort_short` (set to "ALL"), `variable_type`, `variable_name`, `unit`, `gas`,
#'     `gwp`, `allocation_share`, `commodity_type`, `commodity_name`,
#'     `value_total`.
#'   }
#' }
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
#' @references
#' IPCC (2021). *Climate Change 2021: The Physical Science Basis*.
#' Contribution of Working Group I to the Sixth Assessment Report of the
#' Intergovernmental Panel on Climate Change. Cambridge University Press.
#'
#' IPCC (2013). *Climate Change 2013: The Physical Science Basis*.
#' Contribution of Working Group I to the Fifth Assessment Report of the
#' Intergovernmental Panel on Climate Change. Cambridge University Press.
#'
#' IPCC (2007). *Climate Change 2007: The Physical Science Basis*.
#' Contribution of Working Group I to the Fourth Assessment Report of the
#' Intergovernmental Panel on Climate Change. Cambridge University Press.
#'
#'
#' @importFrom data.table := .I melt fcase setcolorder rbindlist
run_aggregation_module <- function(
    cohort_level_data,
    allocation_herd_long,
    simulation_duration = 365,
    global_warming_potential_set = "AR6"
) {
  # --- Input validation -------------------------------------------------------
  cohort_level_data <- data.table::as.data.table(cohort_level_data)
  validate_run_aggregation_module_inputs(
    cohort_level_data = cohort_level_data,
    allocation_herd_long = allocation_herd_long,
    simulation_duration = simulation_duration,
    global_warming_potential_set = global_warming_potential_set
  )

  # Map animal to species_short
  cohort_level_data[abbr_animals, species_short := i.species_short, on = "animal"]

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

  emissions_list <- list(
    list(emissions_source = "ch4_enteric", label = "Enteric_CH4"),
    list(emissions_source = "ch4_manure_pasture", label = "Manure-Pasture_CH4"),
    list(emissions_source = "ch4_manure_burned", label = "Manure-Burned_CH4"),
    list(emissions_source = "ch4_manure_other", label = "Manure-Other_CH4"),

    list(emissions_source = "n2o_manure_pasture_direct", label = "ManureDirect-Pasture_N2O"),
    list(emissions_source = "n2o_manure_burned_direct", label = "ManureDirect-Burned_N2O"),
    list(emissions_source = "n2o_manure_other_direct", label = "ManureDirect-Other_N2O"),

    list(emissions_source = "n2o_manure_burned_indirect", label = "ManureIndirect-Burned_N2O"),
    list(emissions_source = "n2o_manure_pasture_indirect", label = "ManureIndirect-Pasture_N2O"),
    list(emissions_source = "n2o_manure_other_indirect", label = "ManureIndirect-Other_N2O"),

    list(emissions_source = "diet_co2_feed_fertilizer", label = "Feed-Fertilizer_CO2"),
    list(emissions_source = "diet_co2_feed_pesticides", label = "Feed-Pesticides_CO2"),
    list(emissions_source = "diet_co2_feed_crop_operations", label = "Feed-CropOperations_CO2"),
    list(emissions_source = "diet_co2_feed_luc_nopeat", label = "Feed-LandUseChange_CO2"),
    list(emissions_source = "diet_co2_feed_luc_peat", label = "Feed-PeatDrainage_CO2"),

    list(emissions_source = "diet_n2o_feed_fertilizer", label = "Feed-Fertilizer_N2O"),
    list(emissions_source = "diet_n2o_feed_manure_applied", label = "Feed-ManureApplication_N2O"),
    list(emissions_source = "diet_n2o_feed_crop_residues", label = "Feed-CropResidues_N2O"),

    list(emissions_source = "diet_ch4_feed_rice", label = "Feed-Rice_CH4")
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
      "cohort_stock_size"
    ),
    measure.vars = available_vars,
    variable.name = "variable_name",
    value.name = "value"
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
      simulation_duration = simulation_duration,
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

  # --- Step 6: Subsetting datframes by variable_type ----------------------------
  data_herd_long_production <- data_herd_long[variable_type == "Production"]
  data_herd_long_nitrogen <- data_herd_long[variable_type == "NitrogenBalance"]
  data_herd_long_feed <- data_herd_long[variable_type == "Feed"]

  # --- Step 7: Subsetting emissions dataframe and merge emissions with allocation data ---------------------------
  # Only emissions need allocation; other variables are assigned to "ALL"
  data_herd_long_emissions<- merge(
    data_herd_long[
      variable_type == "Emissions",
      .(herd_id, species_short, variable_type, variable_name, value_total_kgGas = value_total)
    ],
    allocation_herd_long,
    by = c("herd_id", "species_short", "variable_name")
  )

  # --- Step 8: Allocate emissions to commodities ------------------------------
  data_herd_long_emissions[
    , value_total_allocated_kgGas := calc_allocated_emissions(
      value = value_total_kgGas,
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

  # --- Step 10: Convert to CO2-equivalents -------------------------------------
  data_herd_long_emissions[
    , c("value_total_allocated_co2eq", "gwp") := calc_co2eq(
      gas = gas,
      value_allocated = value_total_allocated_kgGas,
      global_warming_potential_set = global_warming_potential_set
    ),
    by = .I
  ]

  # --- Step 11: Cleaning-up output tables -----------------------------------------

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
