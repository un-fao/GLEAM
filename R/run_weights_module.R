#' Run Weights Module Pipeline
#'
#' Calculates cohort-level live weight metrics by combining cohort-level inputs with
#' herd-level biological parameters. The function appends cohort weights
#' (initial, potential final, slaughter), then derives average and final live
#' weights accounting for offtake, and finally computes average daily live weight
#' gain over each cohort stage.
#'
#' @param cohort_level_data A \code{data.table} in long format with one row per
#'   herd \eqn{\times} cohort. Must include:
#'   \describe{
#'     \item{species_short}{Character. Code identifying the livestock species.
#'         Supported values include:
#'         \itemize{
#'         \item \code{PGS}: pigs
#'         \item \code{CML}: camels
#'         \item \code{CTL}: cattle
#'         \item \code{BFL}: buffalo
#'         \item \code{SHP}: sheep
#'         \item \code{GTS}: goats
#'         \item \code{CHK}: chickens
#'         }}
#'     \item{herd_id}{Character. Unique identifier for the herd, repeated for each cohort belonging to the same herd.}
#'     \item{cohort_short}{Character. Sex- and age-specific cohort code describing the production stage of the animals. Supported values include:
#'       \itemize{
#'         \item \code{FA}: adult females (from age at first parturition)
#'         \item \code{FS}: sub-adult females (from weaning to age at first parturition)
#'         \item \code{FJ}: juvenile females (from birth to weaning)
#'         \item \code{MA}: adult males (from age at first breeding)
#'         \item \code{MS}: sub-adult males (from weaning to age at first breeding)
#'         \item \code{MJ}: juvenile males (from birth to weaning)
#'         \item \code{FN}: non-demographic females
#'         \item \code{MN}: non-demographic males
#'       }}
#'     \item{cohort_duration_days}{Numeric. Amount of time that each animal spends in a specific cohort (days). For \code{CHK}, \code{FJ} and \code{MJ} cohorts can default to 3 days.}
#'     \item{offtake_rate}{Numeric. Annual proportion of animals removed from the herd for each sex-age cohort (fraction).}
#'   }
#'   Optional column:
#'   \describe{
#'     \item{nondemo_productive_phase_id}{Numeric. Productive phase identifier for non-demographic cohorts (\code{FN}, \code{MN}). Allowed values are \code{1} and optionally \code{2}. Demographic cohorts use \code{NA}.}
#'   }
#' @param herd_level_data A \code{data.table} with one row per herd. Must include:
#'   \itemize{
#'     \item \code{live_weight_female_adult} Numeric. Live weight of adult females (kg)
#'     \item \code{live_weight_male_adult} Numeric. Live weight of adult males (kg)
#'     \item \code{live_weight_at_birth} Numeric. Live weight of the animal at birth (kg).
#'     \item \code{live_weight_at_weaning} Numeric. Live weight of the animal at weaning (kg)
#'     \item \code{live_weight_female_at_slaughter} Numeric. Slaughter weight of female sub-adult animals (kg)
#'     \item \code{live_weight_male_at_slaughter} Numeric. Slaughter weight of male sub-adult animals (kg)
#'     \item \code{live_weight_female_nondemographic_start} Numeric. Live weight at the beginning of the female non-demographic cycle (kg), when \code{FN} is present.
#'     \item \code{live_weight_female_nondemographic_end} Numeric. Live weight at the end of the female non-demographic cycle (kg), when \code{FN} is present.
#'     \item \code{live_weight_male_nondemographic_start} Numeric. Live weight at the beginning of the male non-demographic cycle (kg), when \code{MN} is present.
#'     \item \code{live_weight_male_nondemographic_end} Numeric. Live weight at the end of the male non-demographic cycle (kg), when \code{MN} is present.
#'     \item \code{phase1_nondemo_fem_duration_days} Numeric. Productive phase 1 duration for \code{FN} (days), when \code{FN} is present.
#'     \item \code{phase2_nondemo_fem_duration_days} Numeric. Productive phase 2 duration for \code{FN} (days), optional.
#'     \item \code{phase1_nondemo_mal_duration_days} Numeric. Productive phase 1 duration for \code{MN} (days), when \code{MN} is present.
#'     \item \code{phase2_nondemo_mal_duration_days} Numeric. Productive phase 2 duration for \code{MN} (days), optional.
#'   }
#' @param show_indicator Logical. Whether to display progress indicators during calculations.
#'   Defaults to \code{TRUE}.
#'
#' @return A named list with two \code{data.table}s:
#'   \describe{
#'     \item{cohort_level_results}{The input \code{cohort_level_data} with these
#'       additional columns:
#'       \describe{
#'         \item{live_weight_mature_stage}{Numeric. Mature (adult) live weight that the animal can attain under given biological and management conditions (kg).}
#'         \item{live_weight_cohort_initial}{Numeric. Live weight at the beginning of the cohort stage (kg).}
#'         \item{live_weight_cohort_potential_final}{Numeric. Potential final live weight attainable at the end of the cohort stage in the absence of offtake (kg). (For juveniles: equals weaning weight; For subadults: equals adult live weight; For adults: equals adult live weight)}
#'         \item{live_weight_cohort_at_slaughter}{Numeric. Live weight at slaughter for animals removed from the cohort (kg).}
#'         \item{live_weight_cohort_average}{Numeric. Average live weight over the cohort stage. Computed by accounting for the share of offtaken animals within the cohort, using their slaughter weight, and the potential final weight of animals that remain in the cohort (kg).}
#'         \item{live_weight_cohort_final}{Numeric. Live weight at the end of the cohort stage, accounting for both surviving and offtaken animals. Computed as a weighted average of the potential final weight of surviving animals and the slaughter weight of offtaken animals, based on the offtake rate (kg).}
#'         \item{daily_weight_gain}{Numeric. Average live weight gain of the cohort over the cohort stage (kg/head/day).}
#'       }}
#'     \item{herd_level_results}{A copy of the input \code{herd_level_data}.}
#'   }
#'
#' @details
#' This function represents the intermediate module of the Global Livestock Environmental
#' Assessment Model (GLEAM) computational pipeline [run_gleam()] to estimate animals' live
#' weight and is composed of the following steps:
#'
#' \enumerate{
#'   \item \strong{Cohort-stage weight assignment} using \code{\link{calc_cohort_weights}}.
#'     Herd-level biological parameters are matched to each cohort row by
#'     \code{herd_id} via \code{data.table} joins. For non-demographic cohorts
#'     (\code{FN}, \code{MN}), the function uses
#'     \code{nondemo_productive_phase_id} together with herd-level start/end
#'     live weights and phase durations to assign phase-specific initial and
#'     final weights.
#'
#'   \item \strong{Calculation of average and final live weights (accounting for offtake)} using
#'     \code{\link{calc_avg_weights}}. For non-demographic cohorts,
#'     \code{offtake_rate} is ignored and the final weight equals the
#'     phase-specific potential final weight.
#'
#'   \item \strong{Calculation of average daily live weight gain} using
#'     \code{\link{calc_daily_weight_gain}}.
#' }
#'
#'
#' @seealso
#' \code{\link{run_gleam}},
#' \code{\link{calc_cohort_weights}},
#' \code{\link{calc_avg_weights}},
#' \code{\link{calc_daily_weight_gain}},
#'
#' @examples
#' \donttest{
#' path_run_gleam_examples <- system.file("extdata/run_gleam_examples", package = "gleam")
#'
#' master_chrt_lvl_no_structure_dt <- data.table::fread(file.path(
#'   path_run_gleam_examples, "master_chrt_lvl_no_structure_mixed_data.csv"
#' ))
#' master_hrd_lvl_dt <- data.table::fread(file.path(
#'   path_run_gleam_examples, "master_hrd_lvl_mixed_data.csv"
#' ))
#'
#' herd_results <- run_all_herd_module(
#'   cohort_level_data = master_chrt_lvl_no_structure_dt,
#'   herd_level_data = master_hrd_lvl_dt,
#'   simulation_duration = 365,
#'   run_demographic = TRUE,
#'   run_nondemographic = TRUE
#' )
#'
#' results <- run_weights_module(
#'   cohort_level_data = herd_results$cohort_level_results,
#'   herd_level_data = herd_results$herd_level_results,
#'   show_indicator = FALSE
#' )
#'
#' head(results$cohort_level_results)
#' head(results$herd_level_results)
#' }
#'
#' @export
#'
#' @importFrom data.table := .I
run_weights_module <- function(
    cohort_level_data,
    herd_level_data,
    show_indicator = TRUE
) {
  # --- Step 1: Validate Inputs -----------------------------------------------
  validate_run_weights_module_inputs(cohort_level_data, herd_level_data)

  # Show progress indicator if requested
  if (show_indicator) {
    cli::cli_status("\U1F552 Calculating cohort weights, please wait\U2026")
  }

  # --- Step 2: Create working copies -----------------------------------------
  cohort_level_data <- data.table::copy(cohort_level_data)
  herd_level_data <- data.table::copy(herd_level_data)

  if (!"nondemo_productive_phase_id" %in% names(cohort_level_data)) {
    cohort_level_data[, nondemo_productive_phase_id := NA_real_]
  }

  # --- Step 3: Calculate Cohort Weights --------------------------------------
  cohort_level_data[
    ,
    c(
      "live_weight_mature_stage",
      "live_weight_cohort_initial",
      "live_weight_cohort_potential_final",
      "live_weight_cohort_at_slaughter"
    ) := calc_cohort_weights(
      species_short = herd_level_data[.SD, on = "herd_id", x.species_short],
      cohort_short = cohort_short,
      nondemo_productive_phase_id = nondemo_productive_phase_id,
      live_weight_female_adult = herd_level_data[.SD, on = "herd_id", x.live_weight_female_adult],
      live_weight_male_adult = herd_level_data[.SD, on = "herd_id", x.live_weight_male_adult],
      live_weight_at_birth = herd_level_data[.SD, on = "herd_id", x.live_weight_at_birth],
      live_weight_female_at_slaughter = herd_level_data[.SD, on = "herd_id", x.live_weight_female_at_slaughter],
      live_weight_male_at_slaughter = herd_level_data[.SD, on = "herd_id", x.live_weight_male_at_slaughter],
      live_weight_at_weaning = herd_level_data[.SD, on = "herd_id", x.live_weight_at_weaning],
      live_weight_female_nondemographic_start = herd_level_data[.SD, on = "herd_id", x.live_weight_female_nondemographic_start],
      live_weight_male_nondemographic_start = herd_level_data[.SD, on = "herd_id", x.live_weight_male_nondemographic_start],
      live_weight_female_nondemographic_end = herd_level_data[.SD, on = "herd_id", x.live_weight_female_nondemographic_end],
      live_weight_male_nondemographic_end = herd_level_data[.SD, on = "herd_id", x.live_weight_male_nondemographic_end],
      phase1_nondemo_fem_duration_days = herd_level_data[.SD, on = "herd_id", x.phase1_nondemo_fem_duration_days],
      phase2_nondemo_fem_duration_days = herd_level_data[.SD, on = "herd_id", x.phase2_nondemo_fem_duration_days],
      phase1_nondemo_mal_duration_days = herd_level_data[.SD, on = "herd_id", x.phase1_nondemo_mal_duration_days],
      phase2_nondemo_mal_duration_days = herd_level_data[.SD, on = "herd_id", x.phase2_nondemo_mal_duration_days]
    ),
    by = .I
  ]

  # --- Step 4: Calculate Average and Final Weights ---------------------------
  cohort_level_data[
    ,
    c(
      "live_weight_cohort_average",
      "live_weight_cohort_final"
    ) := calc_avg_weights(
      cohort_short = cohort_short,
      live_weight_cohort_initial = live_weight_cohort_initial,
      live_weight_cohort_potential_final = live_weight_cohort_potential_final,
      live_weight_cohort_at_slaughter = live_weight_cohort_at_slaughter,
      offtake_rate = offtake_rate
    ),
    by = .I
  ]

  # --- Step 5: Calculate Daily Weight Gain -----------------------------------
  cohort_level_data[
    ,
    daily_weight_gain := calc_daily_weight_gain(
      live_weight_cohort_potential_final = live_weight_cohort_potential_final,
      live_weight_cohort_initial = live_weight_cohort_initial,
      cohort_duration_days = cohort_duration_days
    ),
    by = .I
  ]

  # Clear progress indicator if it was shown
  if (show_indicator) {
    cli::cli_status_clear()
    cli::cli_alert_success("Cohort weights calculation complete.")
  }

  # Return separate result tables
  return(
    list(
      cohort_level_results = cohort_level_data,
      herd_level_results = herd_level_data
    )
  )
}
