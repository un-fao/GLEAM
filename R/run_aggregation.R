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
#'     \item{**Feed variables**:}{`dry_matter_intake` (kg DM/head/day)}
#'     \item{**Nitrogen balance**:}{`nitrogen_intake`, `nitrogen_retention`, `nitrogen_excretion`}
#'     \item{**Production**:}{`milk_production_*_cohort`, `meat_production_*_cohort`, `fibre_production_cohort`}
#'     \item{**Emissions**:}{`ch4_enteric`, `ch4_manure_*`, `direct_n2o_manure_*`,
#'       `indirect_n2o_manure_*`}
#'   }
#'   Required grouping columns: `herd_id`, `animal` (full species name, e.g. Cattle, Buffalo;
#'   mapped to \code{species_short} internally), `cohort_short`, `simulation_duration`,
#'   \code{cohort_stock_size}.
#'
#' @param allocation_herd_long A `data.table` in long format, typically the
#'   output of [run_allocation()]. Must include columns:
#'   \describe{
#'     \item{**Grouping**:}{`herd_id`, `species_short`}
#'     \item{**Allocation**:}{`commodity_name` (e.g., "Meat", "Milk", "Fibre"),
#'       `allocation_share` (numeric, 0-1)}
#'     \item{**Emission source**:}{`variable_name` (emission variable names)}
#'   }
#' @param gwp Character scalar specifying the 100-year Global Warming Potential
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
#' # Load cohort-level aggregation input (output from run_gleam or equivalent)
#' cohort_dt <- data.table::fread(system.file(
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
#' results <- run_aggregation(
#'   cohort_level_data = cohort_dt,
#'   allocation_herd_long = allocation_long,
#'   gwp = "AR6"
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
run_aggregation <- function(
    cohort_level_data,
    allocation_herd_long,
    gwp = "AR6"
) {
  # --- Input validation -------------------------------------------------------
  cohort_level_data <- data.table::as.data.table(cohort_level_data)
  if (nrow(cohort_level_data) == 0) {
    cli::cli_abort("{.arg cohort_level_data} must be a non-empty data.table.")
  }

  if (!data.table::is.data.table(allocation_herd_long) || nrow(allocation_herd_long) == 0) {
    cli::cli_abort("{.arg allocation_herd_long} must be a non-empty data.table.")
  }

  # Map animal to species_short
  if (!"species_short" %in% names(cohort_level_data) && "animal" %in% names(cohort_level_data)) {
    cohort_level_data[abbr_animals, species_short := i.species_short, on = "animal"]
  }

  # Validate required grouping columns
  required_group_cols <- c(
    "herd_id", "species_short",
    "cohort_short", "simulation_duration", "cohort_stock_size"
  )
  miss_group <- setdiff(required_group_cols, names(cohort_level_data))
  if (length(miss_group)) {
    cli::cli_abort("Missing required grouping columns in {.arg cohort_level_data}: {miss_group}.")
  }

  # Validate GWP option
  valid_gwp <- c(
    "AR6", "AR5_excluding_carbon_feedback", "AR5_including_carbon_feedback", "AR4"
  )
  if (!gwp %in% valid_gwp) {
    cli::cli_abort(
      "{.arg gwp} must be one of: {.val {valid_gwp}}"
    )
  }

  # --- Step 1: Define variable groups -----------------------------------------
  feed_vars <- c("dry_matter_intake")
  nitrogen_balance_vars <- c("nitrogen_intake", "nitrogen_retention", "nitrogen_excretion")
  production_vars <- c(
    "milk_production_mass_cohort", "milk_production_protein_cohort",
    "milk_production_fpcm_cohort",
    "meat_production_live_weight_cohort", "meat_production_carcass_weight_cohort",
    "meat_production_bone_free_meat_cohort", "meat_production_protein_cohort",
    "fibre_production_cohort"
  )
  emissions_vars <- c(
    "ch4_enteric", "ch4_manure_pasture", "ch4_manure_burned", "ch4_manure_other",
    "n2o_manure_pasture_direct", "n2o_manure_burned_direct", "n2o_manure_other_direct",
    "n2o_manure_burned_indirect", "n2o_manure_pasture_indirect", "n2o_manure_other_indirect",
    "diet_co2_feed_fertilizer", "diet_co2_feed_pesticides", "diet_co2_feed_crop_operations",
    "diet_co2_feed_luc_nopeat", "diet_co2_feed_luc_peat", "diet_n2o_feed_fertilizer",
    "diet_n2o_feed_manure_applied", "diet_n2o_feed_crop_residues", "diet_ch4_feed_rice"
  )

  # Check that required variables exist in cohort_level_data
  all_vars <- unique(
    c(feed_vars, nitrogen_balance_vars, production_vars, emissions_vars)
  )
  available_vars <- intersect(all_vars, names(cohort_level_data))
  if (length(available_vars) == 0) {
    cli::cli_abort(
      "No recognized variables found in {.arg cohort_level_data}. Expected variables include: {.val {all_vars}}"
    )
  }

  # --- Step 2: Reshape cohort_level_data to long format -----------------------
  data_cohort_long <- data.table::melt(
    cohort_level_data,
    id.vars = c(
      "herd_id",
      "species_short",
      "cohort_short",
      "simulation_duration",
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
  # Scale per-head-per-day values to cohort totals over assessment duration
  data_cohort_long[
    , value_total := calc_totals_by_cohort(
      value = value,
      cohort_stock_size = cohort_stock_size,
      simulation_duration = simulation_duration,
      variable_type = variable_type
    ),
    by = .I
  ]

  # --- Step 5: Aggregate from cohort to herd level ----------------------------
  # Sum all cohort values to get herd-level totals
  data_herd_long <- aggregate_cohort_to_herd(
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

  # --- Step 6: Merge emissions with allocation data ---------------------------
  # Only emissions need allocation; other variables are assigned to "ALL"
  data_herd_long_allocation <- merge(
    data_herd_long[variable_type == "Emissions", ],
    allocation_herd_long,
    by = c("herd_id", "species_short", "variable_name")
  )

  # --- Step 7: Allocate emissions to commodities ------------------------------
  data_herd_long_allocation[
    , value_allocated := calc_allocated_emissions(
      value = value_total,
      allocation_share = allocation_share
    ),
    by = .I
  ]

  # --- Step 8: Identify gas type for GWP conversion ---------------------------
  data_herd_long_allocation[
    , gas := data.table::fcase(
      grepl("^ch4", variable_name, ignore.case = TRUE), "CH4",
      grepl("n2o", variable_name, ignore.case = TRUE), "N2O",
      default = NA_character_
    )
  ]

  # --- Step 9: Convert to CO2-equivalents -------------------------------------
  data_herd_long_allocation[
    , c("value_allocated_co2e", "gwp") := calc_co2eq(
      gas = gas,
      value_allocated = value_allocated,
      gwp = gwp
    ),
    by = .I
  ]

  # --- Step 10: Cleaning-up emissions variables -------------------------------
  subset_allocatedco2e <- data_herd_long_allocation[
    ,
    .(
      herd_id, species_short,
      variable_name, gas, variable_type, commodity_name,
      allocation_share, commodity_type, value_total = value_allocated_co2e,
      gwp
    )
  ]
  subset_allocatedco2e[, unit := "kg co2eq"]

  # --- Step 11: Combine the Emissions results allocated with other variables --
  results_herd <- data.table::rbindlist(
    list(
      subset_allocatedco2e,
      data_herd_long[variable_type != "Emissions"]
    ),
    use.names = TRUE,
    fill = TRUE
  )

  # --- Step 12: Cleaning-up the table -----------------------------------------

  # 12.1 Production
  results_herd[
    , unit := data.table::fcase(
      variable_name %in% c("milk_production_mass_cohort", "fibre_production_cohort"), "kg",
      variable_name %in% c("milk_production_protein_cohort", "meat_production_protein_cohort"), "kg protein",
      variable_name %in% c("milk_production_fpcm_cohort"), "kg fat-protein corrected",
      variable_name %in% c("meat_production_live_weight_cohort"), "kg live weight",
      variable_name %in% c("meat_production_carcass_weight_cohort"), "kg carcass weight",
      variable_name %in% c("meat_production_bone_free_meat_cohort"), "kg bone-free meat",
      default = unit
    )
  ]

  results_herd[
    , commodity_name := data.table::fcase(
      variable_name %in% c("milk_production_mass_cohort", "milk_production_protein_cohort", "milk_production_fpcm_cohort"), "Milk",
      variable_name %in% c("meat_production_live_weight_cohort", "meat_production_carcass_weight_cohort", "meat_production_bone_free_meat_cohort", "meat_production_protein_cohort"), "Meat",
      variable_name == "fibre_production_cohort", "Fibre",
      default = commodity_name
    )
  ][
    , commodity_type := data.table::fcase(
      variable_type %in% c("Production"), "Edible",
      default = commodity_type
    )
  ]

  # 12.2 Feed & N balance
  results_herd[
    , unit := data.table::fcase(
      variable_name %in% c("dry_matter_intake"), "kg dry matter",
      variable_name %in% c("nitrogen_intake", "nitrogen_retention", "nitrogen_excretion"), "kg N",
      default = unit
    )
  ]

  results_herd[
    !variable_type %in% c("Emissions", "Production"),
    commodity_name := "ALL"
  ]

  results_herd[
    !variable_type %in% c("Emissions"),
    allocation_share := 1
  ]

  results_herd[
    !variable_type %in% c("Emissions"),
    gwp := 1
  ]

  results_herd[, cohort_short := "ALL"]

  # --- Step 13: Renaming variables --------------------------------------------
  # Ensure variable_name is a factor for levels() assignment
  if (!is.factor(results_herd$variable_name)) {
    results_herd[, variable_name := as.factor(variable_name)]
  }

  levels(results_herd$variable_name) <- c(
    size = "LivestockNumbers",
    ch4_enteric = "Enteric_CH4",
    ch4_manure_pasture = "Manure-Pasture_CH4",
    ch4_manure_burned = "Manure-Burned_CH4",
    ch4_manure_other = "Manure-Other_CH4",
    n2o_manure_pasture_direct = "ManureDirect-Pasture_N2O",
    n2o_manure_burned_direct = "ManureDirect-Burned_N2O",
    n2o_manure_other_direct = "ManureDirect-Other_N2O",
    n2o_manure_burned_indirect = "ManureIndirect-Burned_N2O",
    n2o_manure_pasture_indirect = "ManureIndirect-Pasture_N2O",
    n2o_manure_other_indirect = "ManureIndirect-Other_N2O",
    diet_co2_feed_fertilizer = "Feed-Fertilizer_CO2",
    diet_co2_feed_pesticides = "Feed-Pesticides_CO2",
    diet_co2_feed_crop_operations = "Feed-CropOperations_CO2",
    diet_co2_feed_luc_nopeat = "Feed-LandUseChange_CO2",
    diet_co2_feed_luc_peat = "Feed-PeatDrainage_CO2",
    diet_n2o_feed_fertilizer = "Feed-Fertilizer_N2O",
    diet_n2o_feed_manure_applied = "Feed-ManureApplication_N2O",
    diet_n2o_feed_crop_residues = "Feed-CropResidues_N2O",
    diet_ch4_feed_rice = "Feed-Rice_CH4",
    dry_matter_intake = "DryMatterIntake",
    nitrogen_intake = "NitrogenIntake",
    nitrogen_retention = "NitrogenRetention",
    nitrogen_excretion = "NitrogenExcretion",
    milk_production_mass_cohort = "MilkRaw",
    milk_production_protein_cohort = "MilkProtein",
    milk_production_fpcm_cohort = "MilkFatProteinCorrected",
    meat_production_live_weight_cohort = "MeatLiveWeight",
    meat_production_carcass_weight_cohort = "MeatCarcassWeight",
    meat_production_bone_free_meat_cohort = "MeatBoneFree",
    meat_production_protein_cohort = "MeatProtein",
    fibre_production_cohort = "Fibre"
  )[levels(results_herd$variable_name)]

  # --- Step 14: Variables order -----------------------------------------------
  variable_order <- c(
    "herd_id",
    "species_short",
    "cohort_short",
    "variable_type",
    "variable_name",
    "unit",
    "gas",
    "gwp",
    "allocation_share",
    "commodity_type",
    "commodity_name",
    "value_total"
  )

  data.table::setcolorder(
    results_herd,
    intersect(variable_order, names(results_herd))
  )

  # --- Return results ---------------------------------------------------------
  return(
    list(
      cohort_level_results = cohort_level_data,
      results_herd = results_herd
    )
  )
}
