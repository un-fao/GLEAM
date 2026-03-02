#' Run weight calculations
#'
#' Computes cohort-level live weight metrics by combining cohort-level inputs with
#' herd-level biological parameters. The function appends cohort weights
#' (initial, potential final, slaughter), then derives average and final live
#' weights accounting for offtake, and finally computes average daily live weight
#' gain over each cohort stage.
#'
#' @param cohort_level_data A \code{data.table} in long format with one row per
#'   herd \eqn{\times} cohort. Must include:
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
#'     \item{cohort_duration_days}{Numeric. Amount of time that each animal spends in a specific cohort (days).}
#'     \item{offtake_rate}{Numeric. Annual proportion of animals removed from the herd for each sex-age cohort (fraction).}
#'   }
#' @param herd_level_data A \code{data.table} with one row per herd. Must include:
#'   \itemize{
#'     \item \code{live_weight_female_adult} Numeric. Live weight of adult females (kg)
#'     \item \code{live_weight_male_adult} Numeric. Live weight of adult males (kg)
#'     \item \code{birth_weight} Numeric. Live weight of the animal at birth (kg).
#'     \item \code{weaning_weight} Numeric. Live weight of the animal at weaning (kg)
#'     \item \code{slaughter_weight_female} Numeric. Slaughter weight of female sub-adult animals (kg)
#'     \item \code{slaughter_weight_male} Numeric. Slaughter weight of male sub-adult animals (kg)
#'   }
#' @param show_indicator Logical. Whether to display progress indicators during calculations.
#'
#' @return A named list with two \code{data.table}s:
#'   \describe{
#'     \item{cohort_level_results}{The input \code{cohort_level_data} with these
#'       additional columns:
#'       \describe{
#'         \item{mature_weight}{Numeric. Mature (adult) live weight that the animal can attain under given biological and management conditions (kg).}
#'         \item{live_weight_cohort_initial}{Numeric. Live weight at the beginning of the cohort stage (kg).}
#'         \item{live_weight_cohort_potential_final}{Numeric. Potential final live weight attainable at the end of the cohort stage in the absence of offtake (kg). (For juveniles: equals weaning weight; For subadults: equals adult live weight; For adults: equals adult live weight)}
#'         \item{slaughter_weight_cohort}{Numeric. Live weight at slaughter for animals removed from the cohort (kg).}
#'         \item{live_weight_cohort_average}{Numeric. Average live weight over the cohort stage. Computed by accounting for the share of offtaken animals within the cohort, using their slaughter weight, and the potential final weight of animals that remain in the cohort (kg).}
#'         \item{live_weight_cohort_final}{Numeric. Live weight at the end of the cohort stage, accounting for both surviving and offtaken animals. Computed as a weighted average of the potential final weight of surviving animals and the slaughter weight of offtaken animals, based on the offtake rate (kg).}
#'         \item{daily_weight_gain}{Numeric. Average live weight gain of the cohort over the cohort stage (kg/head/day).}
#'       }}
#'     \item{herd_level_results}{A copy of the input \code{herd_level_data}.}
#'   }
#'
#' @details
#' The calculation pipeline is composed of the following steps:
#'
#' \enumerate{
#'   \item \strong{Cohort-stage weight assignment} using \code{\link{calc_cohort_weights}}.
#'     Herd-level biological parameters are matched to each cohort row by
#'     \code{herd_id} via \code{data.table} joins.
#'
#'   \item \strong{Calculation of average and final live weights (accounting for offtake)} using
#'     \code{\link{calc_avg_weights}}.
#'
#'   \item \strong{Calculation of average daily live weight gain} using
#'     \code{\link{calc_daily_weight_gain}}.
#' }
#'
#' All cohort-level computations are evaluated row-wise using
#' \code{by = .I} from \pkg{data.table}.
#'
#' @seealso
#' \code{\link{calc_cohort_weights}},
#' \code{\link{calc_avg_weights}},
#' \code{\link{calc_daily_weight_gain}},
#'
#' @examples
#' \dontrun{
#' # Load weights inputs (cohort- and herd-level)
#' weights_chrt_dt <- data.table::fread(system.file(
#'   "extdata/run_modules_examples/weights_input_chrt_data.csv",
#'   package = "gleam"
#' ))
#' weights_hrd_dt <- data.table::fread(system.file(
#'   "extdata/run_modules_examples/weights_input_hrd_data.csv",
#'   package = "gleam"
#' ))
#'
#' # Run weight calculations
#' results <- run_weights_calculations(
#'   cohort_level_data = weights_chrt_dt,
#'   herd_level_data = weights_hrd_dt
#' )
#'
#' # Access results
#' print(results$cohort_level_results)
#' print(results$herd_level_results)
#' }
#'
#' @export
#'
#' @importFrom data.table := .I
run_weights_calculations <- function(
    cohort_level_data,
    herd_level_data,
    show_indicator = TRUE
) {

  # --- Step 1: Validate Inputs -----------------------------------------------
  validate_weights_inputs(cohort_level_data, herd_level_data)

  # Show progress indicator if requested
  if (show_indicator) {
    cli::cli_status("\U1F552 Calculating cohort weights, please wait\U2026")
  }

  # --- Step 2: Create working copies -----------------------------------------
  cohort_level_data <- data.table::copy(cohort_level_data)
  herd_level_data <- data.table::copy(herd_level_data)

  # --- Step 3: Calculate Cohort Weights --------------------------------------
  cohort_level_data[
    ,
    c(
      "mature_weight",
      "live_weight_cohort_initial",
      "live_weight_cohort_potential_final",
      "slaughter_weight_cohort"
    ) := calc_cohort_weights(
      cohort_short = cohort_short,
      live_weight_female_adult = herd_level_data[.SD, on = "herd_id", x.live_weight_female_adult],
      live_weight_male_adult = herd_level_data[.SD, on = "herd_id", x.live_weight_male_adult],
      birth_weight = herd_level_data[.SD, on = "herd_id", x.birth_weight],
      slaughter_weight_female = herd_level_data[.SD, on = "herd_id", x.slaughter_weight_female],
      slaughter_weight_male = herd_level_data[.SD, on = "herd_id", x.slaughter_weight_male],
      weaning_weight = herd_level_data[.SD, on = "herd_id", x.weaning_weight]
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
      live_weight_cohort_initial = live_weight_cohort_initial,
      live_weight_cohort_potential_final = live_weight_cohort_potential_final,
      slaughter_weight_cohort = slaughter_weight_cohort,
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
