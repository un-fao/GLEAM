#' Run Allocation Shares
#'
#' Computes biophysical allocation shares for livestock commodities by calculating
#' cohort-level energy requirements for meat, milk, fibre, work, and eggs,
#' aggregating these terms to herd level, and assigning allocation shares to
#' emission variables.
#'
#' @param cohort_level_data Cohort-level input table with the following data requirement:
#'   \describe{
#'     \item{herd_id}{Character. Unique identifier for the herd, repeated for each cohort belonging to the same herd.}
#' \item{cohort_short}{Character. Sex- and age-specific cohort code describing the production stage of the animals.
#' Supported values include:
#'       \itemize{
#'         \item \code{FA}: adult females (from age at first parturition)
#'         \item \code{FS}: sub-adult females (from weaning to age at first parturition)
#'         \item \code{FJ}: juvenile females (from birth to weaning)
#'         \item \code{MA}: adult males (from age at first breeding)
#'         \item \code{MS}: sub-adult males (from weaning to age at first breeding)
#'         \item \code{MJ}: juvenile males (from birth to weaning)
#'       }}
#'       \item{milk_production_fpcm_cohort}{NNumeric. Total fat-protein-corrected milk (FPCM) produced over the assessment
#'       period (kg/cohort/assessment period). Suggest standard fat and protein contents = 0.04 and 0.033.}
#'       \item{slaughter_weight_cohort}{Numeric. Live weight at slaughter for animals removed from the cohort (kg).}
#'       \item{meat_production_live_weight_cohort}{Numeric. Total meat produced as live weight over the assessment period by
#'       cohort (kg/cohort/assessment period).}
#'       \item{energy_requirement_fibre_production}{Numeric. Energy required for the synthesis of fibre for SHP, GTS and CML.
#'       Assumed to be 0 for other species. (MJ/head/day). Expressed as net energy for SHP and GTS and as metabolizable energy
#'       for CML.}
#'       \item{cohort_stock_size}{Numeric. Average population size in each of the 6 sex–age cohorts (# heads). (cohorts=FJ,
#'       FS, FA, MJ, MS, MA).}
#'       \item{energy_requirement_work}{Numeric. Energy required for work, used to estimate the energy required for draught
#'       power for CTL, BFL and CML. (MJ/head/day) Assumed to be 0 for other species. Expressed as net energy for CTL, BFL,
#'       SHP, GTS and as metabolizable energy for CML and PGS.}
#'   }
#'
#' @param herd_level_data data.table. Herd-level input table (one row per \code{herd_id}) with the following data
#' requirement:
#'   \describe{
#'    \item{herd_id}{Character. Unique identifier for the herd, repeated for each cohort belonging
#'     to the same herd.}
#'       \item{animal}{Character. Livestock category name used to map to a species short code via an
#'        internal lookup table. Supported values include:
#'        \itemize{
#'        \item \code{Cattle}
#'        \item \code{Buffalo}
#'        \item \code{Sheep}
#'        \item \code{Goats}
#'        \item \code{Chicken}
#'        \item \code{Pigs}
#'        \item \code{Camels}
#'        }}
#'     \item{birth_weight}{Numeric. Live weight of the animal at birth (kg).}
#'     \item{milk_protein_fraction_standard}{Numeric. Standard protein content of milk, used to calculate
#'     Fat-protein-corrected milk (FPCM), (kg protein/kg milk). Suggested value = 0.033.}
#'     \item{milk_fat_fraction_standard}{umeric. Standard fat content of milk, used to calculate Fat-protein-corrected milk
#'     (FPCM), (kg fat/kg milk). Suggested value = 0.04.}
#'     \item{milk_lactose_fraction_standard}{ Numeric. Standard lactose content of milk, used to calculate
#'     Fat-protein-corrected milk (FPCM) , (kg lactose/kg milk). Suggested value = 0.048.}
#'     \item{ratio_me_to_ne}{Numeric. Ratio of metabolizable energy converted to net energy (fraction). Used for
#'     species_short = CML.}
#'   }
#'
#' @param simulation_duration Numeric. Length of the assessment period (days).
#' @param show_indicator Logical. Whether to display progress indicators during simulation.
#'   Defaults to `TRUE`.
#'
#' @return A named list of two `data.table` objects:
#'   \describe{
#'     \item{cohort_allocation_inputs}{A `data.table` with the original
#'     cohort-level input columns plus the following new variables:
#'       \describe{
#'       \item{energy_allocation_milk}{Numeric. Energy required to produce total milk output by cohort (MJ/cohort/assessment
#'       period). }
#'       \item{energy_allocation_meat}{Numeric. Energy required by a given sex–age cohort for total meat output by cohort
#'       during the assessment period,
#'       equal to the energy needed to produce all live-weight gain to reach the target slaughter weight (MJ/cohort/assessment
#'       period). }
#'       \item{energy_allocation_fibre}{Numeric. Energy required to produce all fibre output by cohort (MJ/cohort/assessment
#'       period).}
#'       \item{energy_allocation_work}{Numeric. Energy required to provide all draught power (traction/work) by cohort
#'       (MJ/cohort/assessment period).}
#'       \item{energy_allocation_eggs}{Numeric. Energy required for egg production over the assessment period
#'       (MJ/cohort/assessment period). Currently set to 0.}
#'       }}
#'     \item{allocation_long}{A herd-level `data.table` in long format with one
#'     row per herd, commodity, and emission variable combination, containing the
#'     following columns:
#'       \describe{
#'         \item{herd_id}{Character. Unique identifier for the herd.}
#'         \item{species_short}{Character. Code identifying the livestock species.
#'         Supported values include:
#'         \itemize{
#'         \item \code{PGS}: pigs
#'         \item \code{CML}: camels
#'         \item \code{CTL}: cattle
#'         \item \code{BFL}: buffalo
#'         \item \code{SHP}: sheep
#'         \item \code{GTS}: goats
#'         }}
#'         \item{variable_name}{Character. Names of emission variables to which allocation should be applied (e.g.,
#'         "ch4_enteric", "ch4_manure_pasture", "ch4_manure_burned", "ch4_manure_other",
#'         "n2o_manure_pasture_direct", "n2o_manure_burned_direct", "n2o_manure_other_direct",
#'         "n2o_manure_burned_indirect", "n2o_manure_pasture_indirect", "n2o_manure_other_indirect",
#'         "diet_co2_feed_fertilizer", "diet_co2_feed_pesticides", "diet_co2_feed_crop_operations",
#'         "diet_co2_feed_luc_nopeat", "diet_co2_feed_luc_peat", "diet_n2o_feed_fertilizer",
#'         "diet_n2o_feed_manure_applied", "diet_n2o_feed_crop_residues", "diet_ch4_feed_rice")}
#'         \item{commodity_name}{Character. List of commodity categories to which emissions may be allocated.
#'         List=c("Other","Milk","Meat","Fibre","Work","Eggs")}
#'         \item{commodity_type}{Character. Commodity (commodity_name) grouping, either
#'         \code{"Edible"} or \code{"Non-Edible"}.}
#'         \item{allocation_share}{Numeric. Allocation share assigned to the
#'         commodity for the corresponding emission variable (fraction).}
#'       }}
#'   }
#' @details
#' This function implements the allocation pipeline used to derive biophysical
#' allocation shares for livestock commodities in multifunctional production
#' systems.
#'
#' The approach follows the IDF standard for the dairy sector, adapted for
#' livestock systems in which emissions are apportioned among multiple products
#' according to their physiological energy requirements. In accordance with
#' ISO 14044:2006, known biophysical relationships may be used to assign shared
#' inputs and outputs of a production system to individual products or sub-units.
#'
#' The pipeline consists of the following steps:
#'
#' \enumerate{
#'   \item Calculation of cohort-level energy allocation terms for meat, milk,
#'   fibre, work, and eggs using
#'   \code{\link{calc_energy_allocation_meat}},
#'   \code{\link{calc_energy_allocation_milk}},
#'   \code{\link{calc_energy_allocation_fibre}},
#'   \code{\link{calc_energy_allocation_work}}, and
#'   \code{calc_energy_allocation_eggs}.
#'
#'   \item Aggregation of cohort-level energy terms to herd level using
#'   \code{\link{aggregate_cohort_to_herd}}.
#'
#'   \item Calculation of herd-level allocation shares for commodities using
#'   \code{\link{calc_allocation_shares}}.
#'
#'   \item Reshaping of allocation shares to long format and assignment of shares
#'   to emission variables using
#'   \code{\link{assign_allocation_to_emissions}}.
#' }
#'
#' Commodity-specific allocation shares represent the fraction of total herd-level
#' energy requirements attributable to each commodity. These shares are then used
#' to assign emissions to meat, milk, fibre, work, eggs, or the residual category
#' \code{"Other"}.
#'
#' Emissions from manure burned for fuel and manure deposited on pasture are not
#' allocated to livestock commodities. These flows are assigned fully to
#' \code{"Other"} in accordance with the rules implemented in
#' \code{\link{assign_allocation_to_emissions}}.
#'
#' @seealso
#' \code{\link{compute_milk_outputs}},
#' \code{\link{compute_meat_outputs}},
#' \code{\link{run_production_cohort}},
#' \code{\link{calc_energy_allocation_meat}},
#' \code{\link{calc_energy_allocation_milk}},
#' \code{\link{calc_energy_allocation_fibre}},
#' \code{\link{calc_energy_allocation_work}},
#' \code{calc_energy_allocation_eggs},
#' \code{\link{aggregate_cohort_to_herd}},
#' \code{\link{calc_allocation_shares}},
#' \code{\link{assign_allocation_to_emissions}}
#'
#' @references
#' ISO. (2006). \emph{Environmental management — Life cycle assessment —
#' Requirements and guidelines (ISO 14044:2006)}. International Organization for
#' Standardization, Geneva.
#'
#' IDF. (2022). \emph{The IDF Global Carbon Footprint Standard for the Dairy
#' Sector}. Bulletin of the IDF No. 520/2022. International Dairy Federation,
#' Brussels.
#'
#' Thoma, G., and Nemecek, T. (2020). Allocation between milk and meat in dairy
#' LCA: Critical discussion of the IDF’s standard methodology. In
#' \emph{Proceedings of the 12th International Conference on Life Cycle Assessment
#' of Food (LCAFood 2020)} (pp. 83--89), 13--16 October, Berlin, Germany.
#'
#' FAO. (2016a). \emph{Environmental performance of large ruminant supply chains:
#' Guidelines for assessment}. Livestock Environmental Assessment and Performance
#' (LEAP) Partnership. FAO, Rome, Italy.
#'
#' FAO. (2016b). \emph{Greenhouse gas emissions and fossil energy use from small
#' ruminant supply chains: Guidelines for assessment}. Livestock Environmental
#' Assessment and Performance (LEAP) Partnership. FAO, Rome, Italy.
#'
#' FAO. (2016c). \emph{Greenhouse gas emissions and fossil energy use from poultry
#' supply chains: Guidelines for assessment}. Livestock Environmental Assessment
#' and Performance (LEAP) Partnership. FAO, Rome, Italy.
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
    cohort_short = "cohort_short"
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
    allocation_share_other := 0
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
      "n2o_manure_pasture_direct", "n2o_manure_burned_direct", "n2o_manure_other_direct",
      "n2o_manure_burned_indirect", "n2o_manure_pasture_indirect", "n2o_manure_other_indirect",
      "diet_co2_feed_fertilizer", "diet_co2_feed_pesticides", "diet_co2_feed_crop_operations",
      "diet_co2_feed_luc_nopeat", "diet_co2_feed_luc_peat", "diet_n2o_feed_fertilizer",
      "diet_n2o_feed_manure_applied", "diet_n2o_feed_crop_residues", "diet_ch4_feed_rice"
    ),
    commodities = c("Other", "Milk", "Meat", "Fibre", "Work", "Eggs"),
    excluded_vars = c(
      "ch4_manure_pasture", "ch4_manure_burned",
      "n2o_manure_pasture_direct", "n2o_manure_burned_direct",
      "n2o_manure_burned_indirect", "n2o_manure_pasture_indirect"
    ),
    commodity_col = "commodity_name",
    allocation_col = "allocation_share"
  )

  # Reorder columns for clarity
  data.table::setcolorder(
    allocation_herd_long,
    c("herd_id", "species_short",
      "variable_name", "commodity_name", "commodity_type",
      "allocation_share")
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
