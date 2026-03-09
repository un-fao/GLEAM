#' Allocation Pipeline
#'
#' Computes allocation fractions by calculating cohort energy for meat, milk, fibre, work and summarising to herd level.
#' Returns cohort results, herd totals, and long-form shares for associating emissions with commodities.
#'
#' The function implements biophysical allocation based on energy requirements to produce different products,
#' following the IDF (2022) global carbon footprint standard for the dairy sector.
#'
#' @param cohort_level_data data.table. Cohort-level input table with the following data requirement:
#'   \describe{
#'     \item{herd_id}{Character. Unique identifier for the herd, repeated for each cohort belonging to the same herd.}
#'     \item{cohort_short}{Character. Sex- and age-specific cohort code describing the production stage of the animals. Supported values include:
#'       \itemize{
#'         \item \code{FA}: adult females (from age at first parturition)
#'         \item \code{FS}: sub-adult females (from weaning to age at first parturition)
#'         \item \code{FJ}: juvenile females (from birth to weaning)
#'         \item \code{MA}: adult males (from age at first breeding)
#'         \item \code{MS}: sub-adult males (from weaning to age at first breeding)
#'         \item \code{MJ}: juvenile males (from birth to weaning)
#'       }}
#'     \item{milk_production_fpcm_cohort}{Numeric. Total fat-protein-corrected milk (FPCM) produced over the assessment period by cohort (kg/cohort/assessment period).}
#'     \item{slaughter_weight_cohort}{Numeric. Live weight at slaughter for animals removed from the cohort (kg).}
#'     \item{meat_production_live_weight_cohort}{Numeric. Total meat produced as live weight over the assessment period by cohort (kg/cohort/assessment period).}
#'     \item{energy_requirement_fibre_production}{Numeric. Energy required for fibre synthesis (MJ/head/day). Used for SHP, GTS, CML. Assumed 0 for other species.}
#'     \item{cohort_stock_size}{Numeric. Population size in the cohort at the start of the assessment period (heads).}
#'     \item{energy_requirement_work}{Numeric. Energy required for work/draught power (MJ/head/day). Used for CTL, BFL, CML. Assumed 0 for other species.}
#'   }
#'
#' @param herd_level_data data.table. Herd-level input table (one row per \code{herd_id}) with the following data requirement:
#'   \describe{
#'     \item{herd_id}{Character. Unique identifier for the herd.}
#'     \item{animal}{Character. Livestock category name used to map to a species short code via an internal lookup table. Supported values include:
#'       \itemize{
#'         \item \code{Cattle}
#'         \item \code{Buffalo}
#'         \item \code{Sheep}
#'         \item \code{Goats}
#'         \item \code{Chicken}
#'         \item \code{Pigs}
#'         \item \code{Camels}
#'       }}
#'     \item{birth_weight}{Numeric. Live weight of the animal at birth (kg).}
#'     \item{milk_protein_fraction_standard}{Numeric. Standard protein content of milk for FPCM calculation (kg protein/kg milk). Default 0.033.}
#'     \item{milk_fat_fraction_standard}{Numeric. Standard fat content of milk for FPCM calculation (kg fat/kg milk). Default 0.04.}
#'     \item{milk_lactose_fraction_standard}{Numeric. Standard lactose content of milk for FPCM calculation (kg lactose/kg milk). Default 0.048.}
#'     \item{ratio_me_to_ne}{Numeric. Ratio of metabolizable energy to net energy (ME/NE). Used for camelid energy conversion.}
#'   }
#'
#' @param simulation_duration Numeric. Length of the assessment period (days). Defaults to \code{365}.
#' @param allocation_type Character vector that defines the allocation methodology in use. Default= "biophysical-energy"
#' @param show_indicator Logical. Whether to display progress indicators during the pipeline run.
#'
#' @return A named list of two `data.table` objects:
#'   * `cohort_allocation_inputs`: Cohort-level inputs to estimate allocation shares at herd-level.
#'   * `allocation_long`: Herd-level, long-format representation of allocation shares with commodity labels.
#'
#' @examples
#' \dontrun{
#' # Load allocation inputs (cohort and herd-level)
#' allocation_chrt_dt <- data.table::fread(system.file(
#'   "extdata/run_modules_examples/allocation_input_chrt_data.csv",
#'   package = "gleam"
#' ))
#' allocation_hrd_dt <- data.table::fread(system.file(
#'   "extdata/run_modules_examples/allocation_input_hrd_data.csv",
#'   package = "gleam"
#' ))
#' results <- run_allocation(
#' cohort_level_data = allocation_chrt_dt,
#' herd_level_data = allocation_hrd_dt
#' )
#' head(results$allocation_long)
#' }
#'
#' @export
#'
#' @importFrom data.table := .I melt
run_allocation <- function(
    cohort_level_data,
    herd_level_data,
    simulation_duration = 365,
    allocation_type = "biophysical-energy",
    show_indicator = TRUE
) {
  # --- Step 1: Coerce and validate inputs -------------------------------------
  cohort_level_data <- data.table::as.data.table(cohort_level_data)
  herd_level_data <- data.table::as.data.table(herd_level_data)
  validate_run_allocation_inputs(cohort_level_data, herd_level_data)

  # Show progress indicator if requested
  if (show_indicator) {
    cli::cli_status("\U1F552 Computing allocation shares, please wait\U2026")
  }

  # --- Step 2: Create working copies ------------------------------------------
  cohort_level_data <- data.table::copy(cohort_level_data)
  herd_level_data <- data.table::copy(herd_level_data)

  # --- Step 3: Map animal to species_short in herd table ----------------------
  herd_level_data[abbr_animals, species_short := i.species_short, on = "animal"]

  # --- Step 4: Calculate cohort-level energy allocations ----------------------
  # Milk energy allocation: based on FPCM (fat- and protein-corrected milk) output
  cohort_level_data[
    ,
    energy_allocation_milk := calc_energy_allocation_milk(
      milk_production_fpcm_cohort = milk_production_fpcm_cohort,
      milk_protein_fraction_standard = herd_level_data[.SD, on = "herd_id", x.milk_protein_fraction_standard],
      milk_fat_fraction_standard = herd_level_data[.SD, on = "herd_id", x.milk_fat_fraction_standard],
      milk_lactose_fraction_standard = herd_level_data[.SD, on = "herd_id", x.milk_lactose_fraction_standard]
    ),
    by = .I
  ]

  # Meat energy allocation: species- and cohort-specific formulas
  cohort_level_data[
    ,
    energy_allocation_meat := calc_energy_allocation_meat(
      species_short = herd_level_data[.SD, on = "herd_id", x.species_short],
      cohort_short = cohort_short,
      slaughter_weight_cohort = slaughter_weight_cohort,
      birth_weight = herd_level_data[.SD, on = "herd_id", x.birth_weight],
      meat_production_live_weight_cohort = meat_production_live_weight_cohort,
      ratio_me_to_ne = herd_level_data[.SD, on = "herd_id", x.ratio_me_to_ne]
    ),
    by = .I
  ]

  # Fibre energy allocation: applies camelid conversion factor when needed
  cohort_level_data[
    ,
    energy_allocation_fibre := calc_energy_allocation_fibre(
      species_short = herd_level_data[.SD, on = "herd_id", x.species_short],
      cohort_stock_size = cohort_stock_size,
      energy_requirement_fibre_production = energy_requirement_fibre_production,
      ratio_me_to_ne = herd_level_data[.SD, on = "herd_id", x.ratio_me_to_ne],
      simulation_duration = simulation_duration
    ),
    by = .I
  ]

  # Work energy allocation: applies camelid conversion factor when needed
  cohort_level_data[
    ,
    energy_allocation_work := calc_energy_allocation_work(
      species_short = herd_level_data[.SD, on = "herd_id", x.species_short],
      cohort_stock_size = cohort_stock_size,
      energy_requirement_work = energy_requirement_work,
      ratio_me_to_ne = herd_level_data[.SD, on = "herd_id", x.ratio_me_to_ne],
      simulation_duration = simulation_duration
    ),
    by = .I
  ]

  # Eggs energy allocation: placeholder (not currently implemented)
  cohort_level_data[, energy_allocation_eggs := 0]

  # --- Step 5: Aggregate from cohort to herd level --------------------------
  # Sum energy allocations by herd_id to get herd-level totals
  allocation_herd <- aggregate_cohort_to_herd(
    data_cohort = cohort_level_data,
    id_cols = "herd_id",
    vars_to_sum = c(
      "energy_allocation_meat",
      "energy_allocation_milk",
      "energy_allocation_fibre",
      "energy_allocation_work",
      "energy_allocation_eggs"
    ),
    cohort = "cohort_short"
  )

  # Add species_short and animal for downstream --------------------------------
  allocation_herd[
    herd_level_data,
    `:=`(species_short = i.species_short, animal = i.animal),
    on = "herd_id"
  ]

  # --- Step 6: Calculate allocation shares per commodity ----------------------
  allocation_herd[
    ,
    c(
      "allocation_share_meat",
      "allocation_share_milk",
      "allocation_share_fibre",
      "allocation_share_work",
      "allocation_share_eggs"
    ) := calc_allocation_shares(
      species_short = species_short,
      energy_allocation_meat = energy_allocation_meat,
      energy_allocation_milk = energy_allocation_milk,
      energy_allocation_fibre = energy_allocation_fibre,
      energy_allocation_work = energy_allocation_work,
      energy_allocation_eggs = energy_allocation_eggs
    ),
    by = .I
  ]

  allocation_herd[
    ,
    allocation_share_other := NA_real_
  ]

  # --- Step 7: Reshape to long format ----------------------------------------
  # Convert allocation shares from wide to long format for downstream processing
  measure_cols <- c(
    "allocation_share_meat",
    "allocation_share_milk",
    "allocation_share_fibre",
    "allocation_share_work",
    "allocation_share_eggs",
    "allocation_share_other"
  )

  # Reshape allocation shares from wide to long
  allocation_herd_long <- data.table::melt(
    allocation_herd,
    id.vars = c("herd_id", "species_short"),
    measure.vars = measure_cols,
    variable.name = "commodity_name",
    value.name = "allocation_share"
  )

  rename_map <- c(
    allocation_share_meat = "Meat",
    allocation_share_milk = "Milk",
    allocation_share_fibre = "Fibre",
    allocation_share_work = "Work",
    allocation_share_eggs = "Eggs",
    allocation_share_other = "Other"
  )
  # Rename the commodity columns
  allocation_herd_long[
    ,
    commodity_name := rename_map[commodity_name]
  ]

  # Adding a commodity_type column to group commodity into edible and non-edible
  allocation_herd_long[
    commodity_name %in% c("Meat", "Milk", "Eggs"),
    commodity_type := "Edible"
  ]
  allocation_herd_long[
    commodity_name %in% c("Work", "Fibre", "Other"),
    commodity_type := "Non-Edible"
  ]

  # --- Step 8: Assigning allocation to emission sources -----------------------
  allocation_herd_long <- assign_allocation_to_emissions(
    allocation_herd_long = allocation_herd_long,
    emissions_vars = c(
      "ch4_enteric", "ch4_manure_pasture", "ch4_manure_burned", "ch4_manure_other",
      "direct_n2o_manure_pasture", "direct_n2o_manure_burned", "direct_n2o_manure_other",
      "indirect_n2o_manure_burned", "indirect_n2o_manure_pasture", "indirect_n2o_manure_other"
    ),
    commodities = c("Other", "Milk", "Meat", "Fibre", "Work", "Eggs"),
    excluded_vars = c(
      "ch4_manure_pasture", "ch4_manure_burned",
      "direct_n2o_manure_pasture", "direct_n2o_manure_burned",
      "indirect_n2o_manure_burned", "indirect_n2o_manure_pasture"
    ),
    commodity_col = "commodity_name",
    allocation_col = "allocation_share"
  )

  allocation_herd_long[
    ,
    allocation_type := allocation_type
  ]

  # Reorder columns for clarity
  data.table::setcolorder(
    allocation_herd_long,
    c("herd_id", "species_short",
      "variable_name", "commodity_name", "commodity_type",
      "allocation_share", "allocation_type")
  )

  # Clear progress indicator if it was shown
  if (show_indicator) {
    cli::cli_status_clear()
    cli::cli_alert_success("Allocation calculation complete.")
  }

  return(
    list(
      cohort_allocation_inputs = cohort_level_data,
      allocation_long = allocation_herd_long
    )
  )
}
