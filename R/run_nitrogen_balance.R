#' Run Nitrogen Balance
#'
#' Computes cohort-level nitrogen intake, retention, and excretion (kg N/head/day)
#' for each row of input data. This wrapper applies the core nitrogen balance
#' functions to the provided dataset and appends results.
#'
#' Cohort-level data must include \code{herd_id}, \code{cohort_short},
#' \code{dry_matter_intake}, \code{diet_nitrogen}, and \code{daily_weight_gain}.
#' Herd-level data must include \code{herd_id}, \code{animal} (full name, e.g.
#' \code{Cattle}, \code{Pigs}), and \code{milk_protein_fraction}, \code{milk_yield_day},
#' \code{fibre_yield_year}, \code{litter_size}, \code{parturition_rate},
#' \code{weaning_weight}, \code{birth_weight}, \code{age_first_parturition}.
#' \code{animal} is mapped to a species short code via \code{abbr_animals}.
#'
#' @param cohort_level_data data.table. Cohort-level inputs (one row per herd-cohort).
#' @param herd_level_data data.table. Herd-level inputs (one row per herd).
#' @param show_indicator Logical. Whether to display progress indicators during
#'   calculations.
#'
#' @return A \code{data.table} with cohort-level data plus three columns:
#'   \code{nitrogen_intake}, \code{nitrogen_retention}, \code{nitrogen_excretion}
#'   (kg N/head/day).
#'
#' @seealso
#' \code{\link{compute_nitrogen_intake}}, \code{\link{compute_nitrogen_retention}},
#' \code{\link{compute_nitrogen_excretion}}
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
#' nitrogen_results <- run_nitrogen_balance(
#'   cohort_level_data = nitrogen_balance_chrt_dt,
#'   herd_level_data = nitrogen_balance_hrd_dt
#' )
#' }
#'
#' @importFrom data.table := .I
run_nitrogen_balance <- function(
    cohort_level_data,
    herd_level_data,
    show_indicator = TRUE
) {
  cohort_level_data <- data.table::as.data.table(cohort_level_data)
  herd_level_data <- data.table::as.data.table(herd_level_data)

  # --- Step 1: Validate inputs ------------------------------------------------
  validate_run_nitrogen_balance_inputs(cohort_level_data, herd_level_data)

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
    nitrogen_intake := compute_nitrogen_intake(
      dry_matter_intake = dry_matter_intake,
      diet_nitrogen = diet_nitrogen
    ),
    by = .I
  ]

  # --- Step 4: Retention – N allocated to growth, milk, reproduction, fibre ---
  cohort_level_data[
    ,
    nitrogen_retention := compute_nitrogen_retention(
      species_short = herd_level_data[.SD, on = "herd_id", x.species_short],
      cohort_short = cohort_short,
      milk_protein_fraction = herd_level_data[.SD, on = "herd_id", x.milk_protein_fraction],
      milk_yield_day = herd_level_data[.SD, on = "herd_id", x.milk_yield_day],
      daily_weight_gain = daily_weight_gain,
      fibre_yield_year = herd_level_data[.SD, on = "herd_id", x.fibre_yield_year],
      litter_size = herd_level_data[.SD, on = "herd_id", x.litter_size],
      parturition_rate = herd_level_data[.SD, on = "herd_id", x.parturition_rate],
      weaning_weight = herd_level_data[.SD, on = "herd_id", x.weaning_weight],
      birth_weight = herd_level_data[.SD, on = "herd_id", x.birth_weight],
      age_first_parturition = herd_level_data[.SD, on = "herd_id", x.age_first_parturition]
    ),
    by = .I
  ]

  # --- Step 5: Excretion – N lost (intake - retention) ------------------------
  cohort_level_data[
    ,
    nitrogen_excretion := compute_nitrogen_excretion(
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
