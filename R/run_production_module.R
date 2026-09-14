#' Run Production Module Pipeline
#'
#' Calculates cohort-level production outputs over the assessment period by combining
#' cohort-level herd structure inputs with herd-level production parameters.
#' The function returns milk, fibre, and meat outputs for each cohort.
#'
#' @param cohort_level_data data.table. Cohort-level input table (one row per herd-cohort) with the
#'   following data requirement:
#'   \describe{
#'     \item{herd_id}{Character. Unique identifier for the herd, repeated for each cohort belonging to the same herd.}
#' \item{cohort_short}{Character. Sex- and age-specific cohort code describing the production stage of the animals.
#' Supported values include:
#'       \itemize{
#'         \item \code{FA}: adult females (from age at first parturition)
#'         \item \code{FS}: sub-adult females (from weaning to age at first parturition)
#'         \item \code{FJ}: juvenile females (from birth to weaning)
#'         \item \code{FN}: non-demographic females
#'         \item \code{MA}: adult males (from age at first breeding)
#'         \item \code{MS}: sub-adult males (from weaning to age at first breeding)
#'         \item \code{MJ}: juvenile males (from birth to weaning)
#'         \item \code{MN}: non-demographic males
#'       }}
#' \item{nondemo_productive_phase_id}{Numeric. Optional productive phase identifier
#' for non-demographic cohorts (\code{FN}, \code{MN}). When present, production
#' outputs are retained separately by phase.}
#' \item{cohort_stock_size}{Numeric. Average population size for the assessed cohort (# heads).}
#' \item{offtake_heads_assessment}{Numeric. Total number of animals removed via offtake over the assessment period for the assessed cohort (# heads / assessment period).}
#'     \item{live_weight_cohort_at_slaughter}{Numeric. Live weight at slaughter for animals removed from the cohort (kg).}
#'   }
#'
#' @param herd_level_data data.table. Herd-level input table (one row per \code{herd_id}) with the following data
#' requirement:
#'   \describe{
#'     \item{herd_id}{Character. Unique identifier for the herd, repeated for each cohort belonging to the same herd.}
#'     \item{species_short}{Character. Code identifying the livestock species.
#'         Supported values include:
#'         \itemize{
#'         \item \code{PGS}: pigs
#'         \item \code{CML}: camels
#'         \item \code{CTL}: cattle
#'         \item \code{BFL}: buffalo
#'         \item \code{SHP}: sheep
#'         \item \code{GTS}: goats
#'         }}
#' \item{milk_yield_day}{Numeric. Average milk yield per milk-producing animal during the assessment duration
#' (kg/head/day).
#' This value is calculated as the total quantity of milk produced for human consumption by milk-producing animals
#' during the assessment period,
#' divided by the number of milk-producing animals, and the length of the assessment period (days). Required only for
#' species = CML, CTL, BFL, SHP, and GTS.}
#' \item{lactating_females_fraction}{Numeric. Proportion of adult females that are lactating during the assessment
#' period (fraction). Required only for species: CML, CTL, BFL, SHP, and GTS.}
#' \item{milk_protein_fraction}{Numeric. Milk protein fraction (kg protein/kg milk). Required only for species = CML,
#' CTL, BFL, SHP, and GTS.}
#' \item{milk_fat_fraction}{Numeric. Milk fat fraction (kg fat/kg milk). Required only for species = CML, CTL, BFL, SHP,
#' and GTS.}
#' \item{milk_lactose_fraction}{Numeric. Milk lactose fraction (kg lactose/kg milk). Required only for species = CML,
#' CTL, BFL, SHP, and GTS.}
#' \item{milk_protein_fraction_standard}{Numeric. Standard protein content of milk, used to calculate
#' Fat-protein-corrected milk (FPCM), (kg protein/kg milk). Suggested value = 0.033.}
#' \item{milk_fat_fraction_standard}{Numeric. Standard fat content of milk, used to calculate Fat-protein-corrected milk
#' (FPCM), (kg fat/kg milk). Suggested value = 0.04.}
#' \item{milk_lactose_fraction_standard}{Numeric. Standard lactose content of milk, used to calculate
#' Fat-protein-corrected milk (FPCM), (kg lactose/kg milk). Suggested value = 0.048.}
#' \item{fibre_yield_year}{Numeric. Annual production yield of fibre, such as wool, cashmere, mohair (kg/head/year).
#' Required only for species = CML, SHP, and GTS.}
#' \item{carcass_dressing_fraction}{Numeric. Ratio of a slaughtered animal's carcass weight to its live weight
#' (fraction).}
#'     \item{bone_free_meat_fraction}{Numeric. Ratio of bone-free-meat to carcass weight (fraction).}
#'     \item{meat_protein_fraction}{Numeric. Protein content of bone-free-meat (kg protein/kg bone-free-meat).}
#'   }
#'
#' @param simulation_duration Numeric. Length of the assessment period (days).
#' @param show_indicator Logical. Whether to display progress indicators during simulation.
#'   Defaults to `TRUE`.
#'
#' @return A `data.table` with the original cohort-level input columns plus the
#'   following new variables. If \code{nondemo_productive_phase_id} is present in
#'   the input, the returned table preserves phase-specific rows for \code{FN} and
#'   \code{MN}:
#'  \describe{
#' \item{milk_production_mass_cohort}{Numeric. Total milk production produced over the assessment period
#' (kg/cohort/assessment period).}
#' \item{milk_production_protein_cohort}{Numeric. Total milk protein production produced over the assessment period (kg
#' protein/cohort/assessment period).}
#' \item{milk_production_fpcm_cohort}{Numeric. Total fat-protein-corrected milk (FPCM) produced over the assessment
#' period (kg/cohort/assessment period).}
#' \item{fibre_production_cohort}{Numeric. Total fibre produced over the assessment period by cohort (kg
#' /cohort/assessment period).}
#' \item{meat_production_live_weight_cohort}{Numeric . Total meat produced as live weight over the assessment period by
#' cohort (kg/cohort/assessment period).}
#' \item{meat_production_carcass_weight_cohort}{Numeric. Total meat as carcass weight (excluding organs, and other
#' by-products after dressing) produced over the assessment period by cohort (kg/cohort/assessment period).}
#' \item{meat_production_bone_free_meat_cohort}{Numeric. Total bone-free-meat (excluding bones, organs, and other
#' by-products after dressing and bone removal)
#'   produced over the assessment period by cohort (kg/cohort/assessment period).}
#' \item{meat_production_protein_cohort}{Numeric. Total meat protein (excluding bones, organs, and other by-products
#' after dressing and bone removal) produced
#'   over the assessment period by cohort (kg protein/cohort/assessment period).}
#'   }
#'
#' @details
#' This function represents the intermediate module of the Global Livestock Environmental
#' Assessment Model (GLEAM) computational pipeline [run_gleam()] to estimate meat, milk and fibre 
#' production outputs from livestock and performs the following calculation sequence:
#' \enumerate{
#'   \item Milk outputs are computed using \code{\link{calc_milk_production}}
#'   \item Fibre outputs are computed using \code{\link{calc_fibre_production}}
#'   \item Meat outputs are computed using \code{\link{calc_meat_production}}
#' }
#'
#' For species/cohorts where milk or fibre production is not applicable, outputs are returned as zero.
#'
#' @seealso
#' \code{\link{run_gleam}},
#' \code{\link{calc_milk_production}},
#' \code{\link{calc_fibre_production}},
#' \code{\link{calc_meat_production}}
#'
#' @examples
#' \donttest{
#' # Load production inputs (cohort and herd-level)
#' production_chrt_dt <- data.table::fread(system.file(
#'   "extdata/run_modules_examples/production_input_chrt_data.csv",
#'   package = "gleam"
#' ))
#' production_hrd_dt <- data.table::fread(system.file(
#'   "extdata/run_modules_examples/production_input_hrd_data.csv",
#'   package = "gleam"
#' ))
#'
#' # Run production calculations
#' results <- run_production_module(
#'   cohort_level_data = production_chrt_dt,
#'   herd_level_data = production_hrd_dt,
#'   simulation_duration = 365
#' )
#' }
#' @export
#'
#' @importFrom data.table := .I
run_production_module <- function(
    cohort_level_data,
    herd_level_data,
    simulation_duration = 365,
    show_indicator = TRUE
) {
  cohort_level_data <- data.table::as.data.table(cohort_level_data)
  herd_level_data <- data.table::as.data.table(herd_level_data)

  # --- Step 1: Validate inputs ------------------------------------------------
  validate_run_production_module_inputs(cohort_level_data, herd_level_data)
  validate_scalar_numeric(simulation_duration, "simulation_duration")
  if (simulation_duration <= 0) {
    cli::cli_abort("{.arg simulation_duration} must be positive.")
  }

  # Show progress indicator if requested
  if (show_indicator) {
    cli::cli_status("\U1F552 Calculating production (milk, fibre, meat), please wait\U2026")
  }

  # --- Step 2: Create working copy --------------------------------------------
  cohort_level_data <- data.table::copy(cohort_level_data)

  # --- Step 3: Compute milk production outputs --------------------------------
  milk_output_cols <- c(
    "milk_production_mass_cohort",
    "milk_production_protein_cohort",
    "milk_production_fpcm_cohort"
  )

  cohort_level_data[
    ,
    (milk_output_cols) := calc_milk_production(
      species_short = herd_level_data[.SD, on = "herd_id", x.species_short],
      cohort_short = cohort_short,
      milk_yield_day = herd_level_data[.SD, on = "herd_id", x.milk_yield_day],
      simulation_duration = simulation_duration,
      cohort_stock_size = cohort_stock_size,
      lactating_females_fraction = herd_level_data[.SD, on = "herd_id", x.lactating_females_fraction],
      milk_protein_fraction = herd_level_data[.SD, on = "herd_id", x.milk_protein_fraction],
      milk_fat_fraction = herd_level_data[.SD, on = "herd_id", x.milk_fat_fraction],
      milk_lactose_fraction = herd_level_data[.SD, on = "herd_id", x.milk_lactose_fraction],
      milk_protein_fraction_standard = herd_level_data[.SD, on = "herd_id", x.milk_protein_fraction_standard],
      milk_fat_fraction_standard = herd_level_data[.SD, on = "herd_id", x.milk_fat_fraction_standard],
      milk_lactose_fraction_standard = herd_level_data[.SD, on = "herd_id", x.milk_lactose_fraction_standard]
    ),
    by = .I
  ]

  # --- Step 4: Aggregate fibre production -------------------------------------
  # The downstream energy requirements module expects annual fibre tonnage at the cohort level.
  cohort_level_data[
    ,
    fibre_production_cohort := calc_fibre_production(
      species_short = herd_level_data[.SD, on = "herd_id", x.species_short],
      cohort_short = cohort_short,
      fibre_yield_year = herd_level_data[.SD, on = "herd_id", x.fibre_yield_year],
      simulation_duration = simulation_duration,
      cohort_stock_size = cohort_stock_size
    ),
    by = .I
  ]

  # --- Step 5: Compute meat production outputs --------------------------------
  meat_output_cols <- c(
    "meat_production_live_weight_cohort",
    "meat_production_carcass_weight_cohort",
    "meat_production_bone_free_meat_cohort",
    "meat_production_protein_cohort"
  )

  cohort_level_data[
    ,
    (meat_output_cols) := calc_meat_production(
      offtake_heads_assessment = offtake_heads_assessment,
      live_weight_cohort_at_slaughter = live_weight_cohort_at_slaughter,
      carcass_dressing_fraction = herd_level_data[.SD, on = "herd_id", x.carcass_dressing_fraction],
      bone_free_meat_fraction = herd_level_data[.SD, on = "herd_id", x.bone_free_meat_fraction],
      meat_protein_fraction = herd_level_data[.SD, on = "herd_id", x.meat_protein_fraction]
    ),
    by = .I
  ]

  # Clear progress indicator if it was shown
  if (show_indicator) {
    cli::cli_status_clear()
    cli::cli_alert_success("Production cohort calculations completed.")
  }

  return(cohort_level_data)
}
