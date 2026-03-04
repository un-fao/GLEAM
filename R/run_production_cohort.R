#' Run Production Cohort
#'
#' Drives the production cohort workflow to translate cohort-level and herd-level
#' inputs into annualised milk, fibre, and meat outputs for each cohort row.
#' Validates the two input tables, computes the three production streams with the
#' core helpers, and writes the derived columns back into the cohort data.table.
#'
#' Input data must be loaded beforehand. Package examples live under
#' \code{inst/extdata/run_modules_examples} and can be accessed via
#' \code{system.file()} together with \code{data.table::fread()}.
#'
#' @param cohort_level_data data.table. Cohort-level production inputs (one row per herd-cohort)
#'   with columns:
#'   \describe{
#'     \item{herd_id}{Unique identifier for the herd, repeated for each cohort belonging to the same herd.}
#'     \item{cohort_short}{Sex- and age-specific cohort code (FJ, FS, FA, MJ, MS, MA).}
#'     \item{cohort_stock_size}{Population size in each of the 6 sex–age cohorts at the start of the year (heads).}
#'     \item{offtake_heads_assessment}{Numeric. Total number of animals removed via offtake over the assessment period, aggregated to 6 sex–age cohorts (cohorts = FJ, FS, FA, MJ, MS, MA) (heads/year).}
#'     \item{slaughter_weight_cohort}{Numeric. Live weight at slaughter for animals removed from the cohort (kg).}
#'   }
#'
#' @param herd_level_data data.table. Herd-level inputs (one row per \code{herd_id}) with columns:
#'   \describe{
#'     \item{herd_id}{Unique identifier for the herd.}
#'     \item{milk_yield_day}{Numeric. Average milk yield per milk-producing animal during the assessment duration (kg/head/day).}
#'     \item{lactating_females_fraction}{Numeric. Share of adult females lactating within the assessment duration. Applies to species = CML, CTL, BFL, SHP, GTS. (fraction).}
#'     \item{milk_protein_fraction}{Numeric. Milk protein fraction (kg protein/kg milk).}
#'     \item{milk_fat_fraction}{Numeric. Milk fat fraction (kg fat/kg milk).}
#'     \item{milk_lactose_fraction}{Numeric. Milk lactose fraction (kg lactose/kg milk).}
#'     \item{milk_protein_fraction_standard}{Numeric. Standard protein content of milk used for FPCM (kg protein/kg milk). Default 0.033.}
#'     \item{milk_fat_fraction_standard}{Numeric. Standard fat content of milk used for FPCM (kg fat/kg milk). Default 0.04.}
#'     \item{milk_lactose_fraction_standard}{Numeric. Standard lactose content of milk used for FPCM (kg lactose/kg milk). Default 0.048.}
#'     \item{fibre_yield_year}{Numeric. Annual production yield of fibre, such as wool, cashmere, mohair (kg/head/year).}
#'     \item{carcass_dressing_fraction}{Numeric. Ratio of a slaughtered animal's carcass weight to its live weight (fraction).}
#'     \item{bone_free_meat_fraction}{Numeric. Ratio of bone-free-meat to carcass weight (fraction).}
#'     \item{meat_protein_fraction}{Numeric. Protein content of bone-free-meat (fraction).}
#'   }
#'
#' @param simulation_duration Numeric. Length of the assessment period (days). Defaults to \code{365}.
#' @param show_indicator Logical. Whether to display progress indicators during the calculation.
#'   Defaults to \code{TRUE}.
#'
#' @return data.table. The input \code{cohort_level_data} with the following columns appended:
#'
#' **Milk production outputs**
#' \item{milk_production_mass_cohort}{Total milk produced over the assessment period (kg milk / cohort / assessment period).}
#' \item{milk_production_protein_cohort}{Total milk protein produced over the assessment period (kg protein / cohort / assessment period).}
#' \item{milk_production_fpcm_cohort}{Total fat-protein-corrected milk (FPCM) produced over the assessment period, calculated using IDF (2022) energy-based correction with standard composition (kg FPCM / cohort / assessment period).}
#'
#' **Fibre production outputs**
#' \item{fibre_production_cohort}{Total fibre produced over the assessment period (kg fibre / cohort / assessment period).}
#'
#' **Meat production outputs**
#' \item{meat_production_live_weight_cohort}{Total meat produced expressed as live weight removed via offtake (kg live weight / cohort / assessment period).}
#' \item{meat_production_carcass_weight_cohort}{Total carcass weight produced after dressing (kg carcass weight / cohort / assessment period).}
#' \item{meat_production_bone_free_meat_cohort}{Total bone-free meat produced (kg meat / cohort / assessment period).}
#' \item{meat_production_protein_cohort}{Total meat protein produced (kg protein / cohort / assessment period).}
#'
#' @examples
#' \dontrun{
#' # Load production cohort inputs (cohort and herd-level)
#' production_cohort_chrt_dt <- data.table::fread(system.file(
#'   "extdata/run_modules_examples/production_cohort_input_chrt_data.csv",
#'   package = "gleam"
#' ))
#' production_cohort_hrd_dt <- data.table::fread(system.file(
#'   "extdata/run_modules_examples/production_cohort_input_hrd_data.csv",
#'   package = "gleam"
#' ))
#'
#' # Run production cohort calculations
#' results <- run_production_cohort(
#'   cohort_level_data = production_cohort_chrt_dt,
#'   herd_level_data = production_cohort_hrd_dt,
#'   simulation_duration = 365
#' )
#' }
#' @export
#'
#' @importFrom data.table := .I
run_production_cohort <- function(
    cohort_level_data,
    herd_level_data,
    simulation_duration = 365,
    show_indicator = TRUE
) {
  cohort_level_data <- data.table::as.data.table(cohort_level_data)
  herd_level_data <- data.table::as.data.table(herd_level_data)

  # --- Step 1: Validate inputs ------------------------------------------------
  validate_run_production_cohort_inputs(cohort_level_data, herd_level_data)
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
    (milk_output_cols) := compute_milk_outputs(
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
    fibre_production_cohort := compute_fibre_output(
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
    (meat_output_cols) := compute_meat_outputs(
      offtake_heads_assessment = offtake_heads_assessment,
      slaughter_weight_cohort = slaughter_weight_cohort,
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
