#' Aggregation Pipeline: Final Herd-Level Results
#'
#' Processes and consolidates livestock emissions, nutrient, and production data
#' from cohort-level inputs to herd-level outputs. It aggregates values,
#' applies allocation shares to emissions by commodity, and converts emissions
#' to CO2-equivalent values based on the selected Global Warming Potential (GWP).
#'
#' This is the final step in the GLEAM workflow, combining all calculated
#' variables (emissions, production, feed, nitrogen balance) into a standardized
#' herd-level output format suitable for reporting and analysis.
#'
#' ## Workflow
#'
#' 1. **Reshape to long format**: Convert cohort-level data from wide to long format
#' 2. **Classify variables**: Group variables into Emissions, Production, Feed, NitrogenBalance
#' 3. **Calculate cohort totals**: Scale per-head-per-day values to cohort totals
#' 4. **Aggregate to herd level**: Sum cohort values to herd-level totals
#' 5. **Merge allocation data**: Combine emissions with allocation shares
#' 6. **Allocate emissions**: Apply allocation shares to emissions by commodity
#' 7. **Convert to CO2eq**: Apply GWP factors to convert CH4 and N2O to CO2-equivalents
#' 8. **Standardize output**: Rename variables, assign units, and format final results
#'
#' @param data_cohort A `data.table` containing cohort-level data with all
#'   calculated variables. Must include:
#'   \describe{
#'     \item{**Feed variables**:}{`dmi` (dry matter intake)}
#'     \item{**Nitrogen balance**:}{`n_intake`, `n_retention`, `n_excretion`}
#'     \item{**Production**:}{`output_milk_*`, `output_meat_*`, `output_fibre_production`}
#'     \item{**Emissions**:}{`ch4_enteric`, `ch4_manure_*`, `direct_n2o_manure_*`,
#'       `indirect_n2o_manure_*`}
#'   }
#'   Required grouping columns: `ADM0_CODE`, `HerdType_short`, `Animal_short`,
#'   `LPS_short`, `cohort`, `assessment_duration`, `size`.
#' @param allocation_herd_long A `data.table` in long format, typically the
#'   output of [run_allocation()]. Must include columns:
#'   \describe{
#'     \item{**Grouping**:}{`ADM0_CODE`, `Animal_short`, `LPS_short`, `HerdType_short`}
#'     \item{**Allocation**:}{`commodity_name` (e.g., "Meat", "Milk", "Fibre"),
#'       `allocation_share` (numeric, 0-1), `allocation_type` (character)}
#'     \item{**Emission source**:}{`variable_name` (emission variable names)}
#'   }
#' @param gwp Character scalar. Global Warming Potential-100 conversion factors
#'   to use. Must be one of:
#'   \itemize{
#'     \item `"AR6"` (default) — IPCC Sixth Assessment Report: CH₄ = 27, N₂O = 273
#'     \item `"AR5_excluding_carbon_feedback"` — IPCC AR5 (excl. feedbacks): CH₄ = 28, N₂O = 265
#'     \item `"AR5_including_carbon_feedback"` — IPCC AR5 (incl. feedbacks): CH₄ = 34, N₂O = 298
#'     \item `"AR4"` — IPCC Fourth Assessment Report: CH₄ = 25, N₂O = 298
#'   }
#'
#' @return A named list containing:
#' \describe{
#'   \item{`data_cohort`}{The original cohort-level data (unchanged).}
#'   \item{`results_herd`}{A `data.table` in long format with:
#'     \itemize{
#'       \item Allocated emissions (both as kg gas and kg CO2eq)
#'       \item Production variables (milk, meat, fibre)
#'       \item Feed and nitrogen balance variables
#'       \item Standardized variable names and units
#'       \item Commodity classifications and allocation metadata
#'     }
#'     Columns include: `ADM0_CODE`, `HerdType_short`, `Animal_short`, `LPS_short`,
#'     `cohort` (set to "ALL"), `variable_type`, `variable_name`, `unit`, `gas`,
#'     `gwp`, `allocation_type`, `allocation_share`, `commodity_type`, `commodity_name`,
#'     `value_total`.
#'   }
#' }
#'
#' @export
#'
#' @importFrom data.table := .I melt fcase setcolorder rbindlist
run_aggregation <- function(
    data_cohort,
    allocation_herd_long,
    gwp = "AR6"
) {
  # --- Input validation -----------------------------------------------------
  if (!data.table::is.data.table(data_cohort) || nrow(data_cohort) == 0) {
    cli::cli_abort("{.arg data_cohort} must be a non-empty data.table.")
  }

  if (!data.table::is.data.table(allocation_herd_long) || nrow(allocation_herd_long) == 0) {
    cli::cli_abort("{.arg allocation_herd_long} must be a non-empty data.table.")
  }

  # Validate required grouping columns
  required_group_cols <- c(
    "ADM0_CODE", "HerdType_short", "Animal_short", "LPS_short",
    "cohort", "assessment_duration", "size"
  )
  miss_group <- setdiff(required_group_cols, names(data_cohort))
  if (length(miss_group)) {
    cli::cli_abort("Missing required grouping columns in {.arg data_cohort}: {miss_group}.")
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

  # --- Step 1: Define variable groups ---------------------------------------
  feed_vars <- c("dmi")
  nitrogen_balance_vars <- c("dmi", "n_intake", "n_retention", "n_excretion")
  production_vars <- c(
    "output_milk_mass_production", "output_milk_protein_production",
    "output_milk_fpcm_production",
    "output_meat_production_liveweight", "output_meat_production_carcassweight",
    "output_meat_production_meat", "output_meat_production_protein",
    "output_fibre_production"
  )
  emissions_vars <- c(
    "ch4_enteric", "ch4_manure_pasture", "ch4_manure_burned", "ch4_manure_other",
    "direct_n2o_manure_pasture", "direct_n2o_manure_burned", "direct_n2o_manure_other",
    "indirect_n2o_manure_burned", "indirect_n2o_manure_pasture", "indirect_n2o_manure_other"
  )

  # Check that required variables exist in data_cohort
  all_vars <- unique(
    c(feed_vars, nitrogen_balance_vars, production_vars, emissions_vars)
  )
  available_vars <- intersect(all_vars, names(data_cohort))
  if (length(available_vars) == 0) {
    cli::cli_abort(
      "No recognized variables found in {.arg data_cohort}. ",
      "Expected variables include: {.val {all_vars}}"
    )
  }

  # --- Step 2: Reshape data_cohort to long format --------------------------
  data_cohort_long <- melt(
    data_cohort,
    id.vars = c(
      "ADM0_CODE",
      "HerdType_short",
      "Animal_short",
      "LPS_short",
      "cohort",
      "assessment_duration",
      "size"
    ),
    measure.vars = available_vars,
    variable.name = "variable_name",
    value.name = "value",
    na.rm = FALSE
  )

  # --- Step 3: Classify variables by type ----------------------------------
  data_cohort_long[
    , variable_type := fcase(
      variable_name %in% feed_vars, "Feed",
      variable_name %in% nitrogen_balance_vars, "NitrogenBalance",
      variable_name %in% production_vars, "Production",
      variable_name %in% emissions_vars, "Emissions",
      default = "Other"
    )
  ]

  # --- Step 4: Calculate totals by cohort -----------------------------------
  # Scale per-head-per-day values to cohort totals over assessment duration
  data_cohort_long[
    , value_total := calc_totals_by_cohort(
      value = value,
      size = size,
      assessment_duration = assessment_duration,
      variable_type = variable_type
    ),
    by = .I
  ]

  # --- Step 5: Aggregate from cohort to herd level --------------------------
  # Sum all cohort values to get herd-level totals
  data_herd_long <- aggregate_cohort_to_herd(
    data_cohort = data_cohort_long,
    id_cols = c(
      "ADM0_CODE",
      "HerdType_short",
      "Animal_short",
      "LPS_short",
      "variable_type",
      "variable_name"
    ),
    vars_to_sum = "value_total",
    cohort = "cohort"
  )

  # --- Step 6: Merge emissions with allocation data --------------------------
  # Only emissions need allocation; other variables are assigned to "ALL"
  data_herd_long_allocation <- merge(
    data_herd_long[variable_type == "Emissions", ],
    allocation_herd_long,
    by = c("ADM0_CODE", "HerdType_short", "Animal_short", "LPS_short", "variable_name"),
    all = TRUE
  )

  # --- Step 7: Allocate emissions to commodities -----------------------------
  data_herd_long_allocation[
    , value_allocated := calc_allocated_emissions(
      value = value_total,
      allocation_share = allocation_share
    )
  ]

  # --- Step 8: Identify gas type for GWP conversion -------------------------
  data_herd_long_allocation[
    , gas := fcase(
      grepl("^ch4", variable_name, ignore.case = TRUE), "CH4",
      grepl("n2o", variable_name, ignore.case = TRUE), "N2O",
      default = NA_character_
    )
  ]

  # --- Step 9: Convert to CO2-equivalents ------------------------------------
  data_herd_long_allocation[
    , c("value_allocated_co2e", "gwp") := calc_co2eq(
      gas = gas,
      value_allocated = value_allocated,
      gwp = gwp
    )
  ]

  # --- Step 10: Cleaning-up emissions variables ------------------------------
  subset_allocatedco2e <- data_herd_long_allocation[
    variable_type == "Emissions",
    .(
      ADM0_CODE, HerdType_short, Animal_short, LPS_short,
      variable_name, gas, variable_type, commodity_name,
      allocation_share, commodity_type, value_total = value_allocated_co2e,
      allocation_type, gwp
    )
  ]
  subset_allocatedco2e[, unit := "kg co2eq"]

  # --- Step 11: Combine the Emissions results allocated with other variables --
  results_herd <- rbindlist(
    list(
      subset_allocatedco2e,
      data_herd_long[variable_type != "Emissions"]
    ),
    use.names = TRUE,
    fill = TRUE
  )

  # --- Step 12: Cleaning-up the table ----------------------------------------

  # 12.1 Production
  results_herd[
    , unit := fcase(
      variable_name %in% c("output_milk_mass_production", "output_fibre_production"), "kg",
      variable_name %in% c("output_milk_protein_production", "output_meat_production_protein"), "kg protein",
      variable_name %in% c("output_milk_fpcm_production"), "kg fat-protein corrected",
      variable_name %in% c("output_meat_production_liveweight"), "kg live weight",
      variable_name %in% c("output_meat_production_carcassweight"), "kg carcass weight",
      variable_name %in% c("output_meat_production_meat"), "kg bone-free meat",
      default = unit
    )
  ]

  results_herd[
    , commodity_name := fcase(
      variable_name %in% c("output_milk_mass_production", "output_milk_protein_production", "output_milk_fpcm_production"), "Milk",
      variable_name %in% c("output_meat_production_liveweight", "output_meat_production_carcassweight", "output_meat_production_meat", "output_meat_production_protein"), "Meat",
      variable_name == "output_fibre_production", "Fibre",
      default = commodity_name
    )
  ][
    , commodity_type := fcase(
      variable_type %in% c("Production"), "Edible",
      default = commodity_type
    )
  ]

  # 12.2 Feed & N balance
  results_herd[
    , unit := fcase(
      variable_name %in% c("DryMatterIntake"), "kg dry matter",
      variable_name %in% c("NitrogenIntake", "NitrogenRetention", "NitrogenExcretion"), "kg N",
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
    allocation_type := NA
  ]

  results_herd[
    !variable_type %in% c("Emissions"),
    gwp := 1
  ]

  results_herd[, cohort := "ALL"]

  # --- Step 13: Renaming variables -------------------------------------------
  # Ensure variable_name is a factor for levels() assignment
  if (!is.factor(results_herd$variable_name)) {
    results_herd[, variable_name := as.factor(variable_name)]
  }

  levels(results_herd$variable_name) <- c(
    size = "LivestockNumbers",
    ch4_enteric = "Enteric",
    ch4_manure_pasture = "Manure-pasture",
    ch4_manure_burned = "Manure-burned",
    ch4_manure_other = "Manure-other",
    direct_n2o_manure_pasture = "ManureDirect-pasture",
    direct_n2o_manure_burned = "ManureDirect-burned",
    direct_n2o_manure_other = "ManureDirect-other",
    indirect_n2o_manure_burned = "ManureIndirect-burned",
    indirect_n2o_manure_pasture = "ManureIndirect-pasture",
    indirect_n2o_manure_other = "ManureIndirect-other",
    dmi = "DryMatterIntake",
    n_intake = "NitrogenIntake",
    n_retention = "NitrogenRetention",
    n_excretion = "NitrogenExcretion",
    output_milk_mass_production = "MilkRaw",
    output_milk_protein_production = "MilkProtein",
    output_milk_fpcm_production = "MilkFatProteinCorrected",
    output_meat_production_liveweight = "MeatLiveWeight",
    output_meat_production_carcassweight = "MeatCarcassWeight",
    output_meat_production_meat = "MeatBoneFree",
    output_meat_production_protein = "MeatProtein",
    output_fibre_production = "Fibre"
  )[levels(results_herd$variable_name)]

  # --- Step 14: Variables order ----------------------------------------------
  variable_order <- c(
    "ADM0_CODE",
    "HerdType_short",
    "Animal_short",
    "LPS_short",
    "cohort",
    "variable_type",
    "variable_name",
    "unit",
    "gas",
    "gwp",
    "allocation_type",
    "allocation_share",
    "commodity_type",
    "commodity_name",
    "value_total"
  )

  setcolorder(
    results_herd,
    intersect(variable_order, names(results_herd))
  )

  # --- Return results --------------------------------------------------------
  return(
    list(
      data_cohort = data_cohort,
      results_herd = results_herd
    )
  )
}
