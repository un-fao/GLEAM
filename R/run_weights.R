#' Run Weight Calculations
#'
#' Applies weight calculations on a long-format table and returns the same table
#' with weight-related columns appended. This function orchestrates the calculation
#' of initial weights, potential final weights, slaughter weights, average weights,
#' final weights, and daily weight gain for each cohort.
#'
#' @param cohort_level_data A `data.table` with mandatory columns:
#'   \describe{
#'     \item{`herd_id`}{Character. Unique identifier for the herd, repeated for each cohort belonging to the same herd.}
#'     \item{`cohort_short`}{Character scalar. Sex- and age-specific cohort code describing the
#'   production stage of the animals. Supported values include:
#'   \itemize{
#'     \item \code{FA}: adult females (from age at first parturition)
#'     \item \code{FS}: sub-adult females (from weaning to age at first parturition)
#'     \item \code{FJ}: juvenile females (from birth to weaning)
#'     \item \code{MA}: adult males (from age at first breeding)
#'     \item \code{MS}: sub-adult males (from weaning to age at first breeding)
#'     \item \code{MJ}: juvenile males (from birth to weaning)
#'   }}
#'     \item{`cohort_duration_days`}{Numeric. Amount of time that each animal spends in a specific cohort (days).}
#'     \item{`offtake_rate`}{Numeric. Annual proportion of animals removed from the herd for each sex-age cohort (fraction).}
#'   }
#' @param herd_level_data A `data.table` with one row per herd and mandatory columns:
#'   \itemize{
#'     \item `live_weight_female_adult` - Numeric. Live weight of adult females (kg)
#'     \item `live_weight_male_adult` - Numeric. Live weight of adult males (kg)
#'     \item `birth_weight` - Numeric. Live weight of the animal at birth (kg).
#'     \item `slaughter_weight_female` - Numeric. Slaughter weight of female sub-adult animals (kg).
#'     \item `slaughter_weight_male` - Numeric. Slaughter weight of male sub-adult animals (kg).
#'     \item `weaning_weight` - Numeric. Live weight of the animal at weaning (kg)
#'   }
#'
#' @return A named list with two elements:
#'   \describe{
#'     \item{`cohort_level_results`}{A `data.table` with the cohort-level inputs, plus the
#'       following weight-related columns appended:
#'       \itemize{
#'         \item `live_weight_cohort_initial` - Numeric. Live weight at the beginning of the cohort stage (kg).
#'         \item `live_weight_cohort_potential_final` - Numeric. Potential final live weight attainable at the end of the cohort stage in the absence of offtake (kg). (For juveniles: equals weaning weight; For subadults: equals adult live weight; For adults: equals adult live weight)
#'         \item `slaughter_weight_cohort` - Numeric. Live weight at slaughter for animals removed from the cohort (kg).
#'         \item `live_weight_cohort_average` - Numeric. Average live weight over the cohort stage. Computed by accounting for the share of offtaken animals within the cohort, using their slaughter weight, and the potential final weight of animals that remain in the cohort (kg).
#'         \item `live_weight_cohort_final` - Numeric. Live weight at the end of the cohort stage, accounting for both surviving and offtaken animals. Computed in the GLEAM pipeline as a weighted average of the potential final weight of surviving animals and the slaughter weight of offtaken animals, based on the offtake rate (kg).
#'         \item `adult_weight` - Numeric. Mature (adult) live weight that the animal can attain under given biological and management conditions (kg).
#'         \item `daily_weight_gain` - Numeric. Average live weight gain of the cohort over the cohort stage (kg/head/day).
#'       }}
#'     \item{`herd_level_results`}{A `data.table` with the same structure as the input
#'       `herd_level_data` (one row per herd).}
#'   }
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

  # --- Step 2: Calculate Cohort Weights --------------------------------------
  cohort_level_data[
    ,
    c(
      "adult_weight",
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

  # --- Step 3: Calculate Average and Final Weights ---------------------------
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

  # --- Step 4: Calculate Daily Weight Gain -----------------------------------
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
