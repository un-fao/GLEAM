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
#'     \item{herd_id}{Character. Unique identifier for the herd (repeated across cohorts).}
#'     \item{cohort_short}{Character. Sex- and stage-specific cohort code. One of:
#'       \itemize{
#'         \item \code{FA}: adult females (from first parturition onward)
#'         \item \code{FS}: subadult females (weaning to first parturition)
#'         \item \code{FJ}: juvenile females (birth to weaning)
#'         \item \code{MA}: adult males (from first breeding onward)
#'         \item \code{MS}: subadult males (weaning to first breeding)
#'         \item \code{MJ}: juvenile males (birth to weaning)
#'       }}
#'     \item{cohort_duration_days}{Numeric. Time spent in the cohort (days).}
#'     \item{offtake_rate}{Numeric. Annual proportion removed from the cohort (fraction).}
#'   }
#' @param herd_level_data A \code{data.table} with one row per herd. Must include:
#'   \itemize{
#'     \item \code{live_weight_female_adult} Numeric. Adult female live weight (kg).
#'     \item \code{live_weight_male_adult} Numeric. Adult male live weight (kg).
#'     \item \code{birth_weight} Numeric. Live weight at birth (kg).
#'     \item \code{weaning_weight} Numeric. Live weight at weaning (kg).
#'     \item \code{slaughter_weight_female} Numeric. Slaughter live weight for female subadults (kg).
#'     \item \code{slaughter_weight_male} Numeric. Slaughter live weight for male subadults (kg).
#'   }
#'
#' @return A named list with two \code{data.table}s:
#'   \describe{
#'     \item{cohort_level_results}{The input \code{cohort_level_data} with these
#'       additional columns:
#'       \describe{
#'         \item{mature_weight}{Numeric. Mature (adult) live weight for the cohort sex (kg).}
#'         \item{live_weight_cohort_initial}{Numeric. Live weight at cohort start (kg).}
#'         \item{live_weight_cohort_potential_final}{Numeric. Potential live weight at cohort end
#'           in the absence of offtake (kg).}
#'         \item{slaughter_weight_cohort}{Numeric. Live weight at slaughter for removed animals (kg).}
#'         \item{live_weight_cohort_average}{Numeric. Average live weight over the cohort stage (kg).}
#'         \item{live_weight_cohort_final}{Numeric. End-of-stage live weight accounting for offtake (kg).}
#'         \item{daily_weight_gain}{Numeric. Average daily live weight gain (kg/head/day).}
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
#' # Load example input data from the package
#' cohort_path <- system.file(
#'   "extdata/examples/weight_input_cohort_level_data.csv",
#'   package = "gleam"
#' )
#' herd_path <- system.file(
#'   "extdata/examples/weight_input_herd_level_data.csv",
#'   package = "gleam"
#' )
#' cohort_level_data <- data.table::fread(cohort_path)
#' herd_level_data <- data.table::fread(herd_path)
#'
#' # Run weight calculations
#' results <- run_weights_calculations(
#'   cohort_level_data = cohort_level_data,
#'   herd_level_data = herd_level_data
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
    herd_level_data
) {

  # --- Step 1: Validate Inputs -----------------------------------------------
  validate_weights_inputs(cohort_level_data, herd_level_data)

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

  # Return separate result tables
  return(
    list(
      cohort_level_results = cohort_level_data,
      herd_level_results = herd_level_data
    )
  )
}
