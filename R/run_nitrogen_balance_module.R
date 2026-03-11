#' Run Nitrogen Balance
#'
#' Computes cohort-level daily nitrogen intake, retention, and excretion (kg N/head/day)
#' by applying IPCC Tier 2 approach.
#'
#' @param cohort_level_data data.table. Cohort-level input table with the following data requirement:
#'  \describe{
#'     \item{herd_id}{Character. Unique identifier for the herd, repeated for each cohort belonging to the same herd.}
#'     \item{cohort_short}{Character. Sex- and age-specific cohort code describing the production stage of the animals.
#'     Supported values include:
#'       \itemize{
#'         \item \code{FA}: adult females (from age at first parturition)
#'         \item \code{FS}: sub-adult females (from weaning to age at first parturition)
#'         \item \code{FJ}: juvenile females (from birth to weaning)
#'         \item \code{MA}: adult males (from age at first breeding)
#'         \item \code{MS}: sub-adult males (from weaning to age at first breeding)
#'         \item \code{MJ}: juvenile males (from birth to weaning)
#'       }}
#'     \item{dry_matter_intake}{Numeric. Average daily dry matter intake of feed (kg DM/head/day).}
#'     \item{diet_nitrogen}{Numeric. Average nitrogen content of diet (kg N/kg DM).}
#'     \item{daily_weight_gain}{Numeric. Average live weight gain of the cohort over the cohort stage (kg/head/day).}
#'     \item{cohort_duration_days}{Numeric. Amount of time that each animal spends in a specific cohort (days).}
#'   }
#'
#' @param herd_level_data data.table. Herd-level input table (one row per \code{herd_id}) with
#' the following data requirement:
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
#'    \item{milk_protein_fraction}{Numeric. Milk protein fraction (kg protein / kg milk).
#'    Required only for species = CML, CTL, BFL, SHP, and GTS.}
#'     \item{milk_yield_day}{Numeric. Average milk yield per milk-producing animal during
#'     the assessment duration (kg/head/day). This value is calculated as the total quantity
#'     of milk produced for human consumption by milk-producing animals during the assessment period,
#'     divided by the number of milk-producing animals, and the length of the assessment period (days).
#'     Required only for species = CML, CTL, BFL, SHP, and GTS.}
#'     \item{fibre_yield_year}{Numeric. Annual production yield of fibre, such as
#'     wool, cashmere, mohair (kg/head/year).
#'     Required only for species = CML, SHP, and GTS.}
#'     \item{litter_size}{Numeric. Average number of offspring born per parturition (# offsprings/parturition).
#'     This value can be calculated as the total number of offspring born divided
#'     by the total number of parturitions during the year.}
#'     \item{parturition_rate}{Numeric. Average annual number of parturitions per
#'     female animal (# parturitions/adult female/year).
#'     A herd-level reproductive performance indicator calculated as the total
#'     number of parturitions (deliveries) occurring during
#'     a year divided by the number of adult females potentially able to give birth during that year.}
#'     \item{live_weight_at_weaning}{Numeric. Live weight of the animal at weaning (kg).}
#'     \item{live_weight_at_birth}{Numeric. Live weight of the animal at birth (kg).}
#'     \item{pregnancy_duration}{Numeric. Duration of pregnancy period (days).}
#'   }
#'
#' @param show_indicator Logical. Whether to display progress indicators during simulation.
#'   Defaults to `TRUE`.
#'
#' @return A \code{data.table}  with the original cohort-level input columns plus the following new variables:
#'   \describe{
#'     \item{nitrogen_intake}{Numeric. Daily nitrogen intake (kg N/head/day).}
#'     \item{nitrogen_retention}{Numeric. Daily nitrogen retention in animal body
#'     tissues and products (e.g., growth, pregnancy, milk...) (kg N/head/day)}
#'     \item{nitrogen_excretion}{Numeric. Daily nitrogen excretion (kg N/head/day).}
#'   }
#'
#' @details
#' This function joins \code{cohort_level_data} with \code{herd_level_data} by \code{herd_id},
#' maps \code{animal} to species short code (\code{species_short}) via \code{abbr_animals},
#' and computes cohort-level nitrogen balance components following the IPCC Tier 2 structure.
#'
#' The following calculation sequence is applied:
#' \enumerate{
#'   \item Daily nitrogen intake is computed using \code{\link{calc_nitrogen_intake}}
#'   from \code{dry_matter_intake} and \code{diet_nitrogen}.
#'   \item Daily nitrogen retention is computed using \code{\link{calc_nitrogen_retention}}
#'   from cohort-level and herd-level species parameters.
#'   \item Daily nitrogen excretion is computed using \code{\link{calc_nitrogen_excretion}}
#'   as intake minus retention (species-specific validation applied).
#' }
#'
#'
#' @seealso
#' \code{\link{calc_nitrogen_intake}},
#' \code{\link{calc_nitrogen_retention}},
#' \code{\link{calc_nitrogen_excretion}}
#'
#' @examples
#' \dontrun{
#' # Load nitrogen balance inputs (cohort and herd-level)
#' nitrogen_balance_chrt_dt <- data.table::fread(system.file(
#'   "extdata/run_modules_examples/nitrogen_balance_input_chrt_data.csv",
#'   package = "gleam"
#' ))
#' nitrogen_balance_hrd_dt <- data.table::fread(system.file(
#'   "extdata/run_modules_examples/nitrogen_balance_input_hrd_data.csv",
#'   package = "gleam"
#' ))
#'
#' # Run nitrogen balance calculations
#' results <- run_nitrogen_balance_module(
#'   cohort_level_data = nitrogen_balance_chrt_dt,
#'   herd_level_data = nitrogen_balance_hrd_dt
#' )
#' }
#'
#' @importFrom data.table := .I
run_nitrogen_balance_module <- function(
    cohort_level_data,
    herd_level_data,
    show_indicator = TRUE
) {
  cohort_level_data <- data.table::as.data.table(cohort_level_data)
  herd_level_data <- data.table::as.data.table(herd_level_data)

  # --- Step 1: Validate inputs ------------------------------------------------
  validate_run_nitrogen_balance_module_inputs(cohort_level_data, herd_level_data)

  if (show_indicator) {
    cli::cli_status("\U1F552 Calculating nitrogen balance, please wait\U2026")
  }

  # --- Step 2: Create working copies; map animal -> species_short (herd) ------
  cohort_level_data <- data.table::copy(cohort_level_data)
  herd_level_data <- data.table::copy(herd_level_data)

  herd_level_data <- merge(
    herd_level_data,
    abbr_animals,
    by = "animal",
    all.x = TRUE
  )

  # --- Step 3: Intake – N consumed per head/day -------------------------------
  cohort_level_data[
    ,
    nitrogen_intake := calc_nitrogen_intake(
      dry_matter_intake = dry_matter_intake,
      diet_nitrogen = diet_nitrogen
    ),
    by = .I
  ]

  # --- Step 4: Retention – N allocated to growth, milk, reproduction, fibre ---
  cohort_level_data[
    ,
    nitrogen_retention := calc_nitrogen_retention(
      species_short = herd_level_data[.SD, on = "herd_id", x.species_short],
      cohort_short = cohort_short,
      milk_protein_fraction = herd_level_data[.SD, on = "herd_id", x.milk_protein_fraction],
      milk_yield_day = herd_level_data[.SD, on = "herd_id", x.milk_yield_day],
      daily_weight_gain = daily_weight_gain,
      fibre_yield_year = herd_level_data[.SD, on = "herd_id", x.fibre_yield_year],
      litter_size = herd_level_data[.SD, on = "herd_id", x.litter_size],
      parturition_rate = herd_level_data[.SD, on = "herd_id", x.parturition_rate],
      live_weight_at_weaning = herd_level_data[.SD, on = "herd_id", x.live_weight_at_weaning],
      live_weight_at_birth = herd_level_data[.SD, on = "herd_id", x.live_weight_at_birth],
      pregnancy_duration = herd_level_data[.SD, on = "herd_id", x.pregnancy_duration],
      cohort_duration_days = cohort_duration_days
    ),
    by = .I
  ]

  # --- Step 5: Excretion – N lost (intake - retention) ------------------------
  cohort_level_data[
    ,
    nitrogen_excretion := calc_nitrogen_excretion(
      species_short = herd_level_data[.SD, on = "herd_id", x.species_short],
      nitrogen_intake = nitrogen_intake,
      nitrogen_retention = nitrogen_retention
    ),
    by = .I
  ]

  # Clear progress indicator if it was shown
  if (show_indicator) {
    cli::cli_status_clear()
    cli::cli_alert_success("Nitrogen balance calculation complete.")
  }

  return(cohort_level_data)
}
