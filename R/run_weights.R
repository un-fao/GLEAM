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
#'     \item{`cohort`}{Character scalar. Sex- and age-specific cohort code describing the
#'   production stage of the animals. Supported values include:
#'   \itemize{
#'     \item \code{FA}: adult females (from age at first parturition)
#'     \item \code{FS}: sub-adult females (from weaning to age at first parturition)
#'     \item \code{FJ}: juvenile females (from birth to weaning)
#'     \item \code{MA}: adult males (from age at first breeding)
#'     \item \code{MS}: sub-adult males (from weaning to age at first breeding)
#'     \item \code{MJ}: juvenile males (from birth to weaning)
#'   }}
#'     \item{`duration`}{Numeric. Amount of time that each animal spends in a specific cohort (days).}
#'     \item{`offtake_rate`}{Numeric. Annual proportion of animals removed from the herd for each sex-age cohort (fraction).}
#'   }
#' @param herd_level_data A `data.table` with one row per herd and mandatory columns:
#'   \itemize{
#'     \item `adult_fem_weight` - Numeric. Live weight of adult females (kg)
#'     \item `adult_mal_weight` - Numeric. Live weight of adult males (kg)
#'     \item `birth_weight` - Numeric. Live weight of the animal at birth (kg).
#'     \item `slaughter_weight_fem` - Numeric. Slaughter weight of female sub-adult animals (kg).
#'     \item `slaughter_weight_mal` - Numeric. Slaughter weight of male sub-adult animals (kg).
#'     \item `weaning_weight` - Numeric. Live weight of the animal at weaning (kg)
#'   }
#'
#' @return A named list with two elements:
#'   \describe{
#'     \item{`cohort_level_results`}{A `data.table` with the cohort-level inputs, plus the
#'       following weight-related columns appended:
#'       \itemize{
#'         \item `initial_weight` - Numeric. Live weight at the beginning of the cohort stage (kg).
#'         \item `potential_final_weight` - Numeric. Potential final live weight attainable at the end of the cohort stage in the absence of offtake (kg). (For juveniles: equals weaning weight; For subadults: equals adult live weight; For adults: equals adult live weight)
#'         \item `slaughter_weight` - Numeric. Live weight at slaughter for animals removed from the cohort (kg).
#'         \item `average_weight` - Numeric. Average live weight over the cohort stage. Computed by accounting for the share of offtaken animals within the cohort, using their slaughter weight, and the potential final weight of animals that remain in the cohort (kg).
#'         \item `final_weight` - Numeric. Live weight at the end of the cohort stage, accounting for both surviving and offtaken animals. Computed in the GLEAM pipeline as a weighted average of the potential final weight of surviving animals and the slaughter weight of offtaken animals, based on the offtake rate (kg).
#'         \item `adult_weight` - Numeric. Mature (adult) live weight that the animal can attain under given biological and management conditions (kg).
#'         \item `daily_weight_gain` - Numeric. Average live weight gain of the cohort over the cohort stage (kg/head/day).
#'       }}
#'     }
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
run_weights_calculations <- function(cohort_level_data, herd_level_data) {
  # Validate input
  if (!data.table::is.data.table(cohort_level_data)) {
    cli::cli_abort("{.arg cohort_level_data} must be a data.table.")
  }
  if (!data.table::is.data.table(herd_level_data)) {
    cli::cli_abort("{.arg herd_level_data} must be a data.table.")
  }

  # Required columns for weight calculations
  required_cohort_cols <- c(
    "herd_id",
    "cohort",
    "duration",
    "offtake_rate"
  )
  required_herd_cols <- c(
    "herd_id",
    "adult_fem_weight",
    "adult_mal_weight",
    "birth_weight",
    "slaughter_weight_fem",
    "slaughter_weight_mal",
    "weaning_weight"
  )

  missing_cohort_cols <- setdiff(required_cohort_cols, names(cohort_level_data))
  if (length(missing_cohort_cols) > 0) {
    cli::cli_abort("Missing required columns: {.val {missing_cohort_cols}}")
  }
  missing_herd_cols <- setdiff(required_herd_cols, names(herd_level_data))
  if (length(missing_herd_cols) > 0) {
    cli::cli_abort("Missing required columns: {.val {missing_herd_cols}}")
  }

  herd_id_counts <- herd_level_data[, .N, by = herd_id]
  duplicate_herds <- herd_id_counts[N > 1]
  if (nrow(duplicate_herds) > 0) {
    cli::cli_abort(
      "Each herd_id must appear exactly once in {.arg herd_level_data}.
      Found duplicates for herd_ids: {.val {duplicate_herds$herd_id}}"
    )
  }

  cohort_herd_ids <- unique(cohort_level_data$herd_id)
  herd_level_herd_ids <- unique(herd_level_data$herd_id)
  missing_in_herd_level <- setdiff(cohort_herd_ids, herd_level_herd_ids)
  if (length(missing_in_herd_level) > 0) {
    cli::cli_abort(
      "Herd IDs in {.arg cohort_level_data} not found in {.arg herd_level_data}: {.val {missing_in_herd_level}}"
    )
  }

  cohort_level_data[
    ,
    c(
      "adult_weight", "initial_weight", "potential_final_weight", "slaughter_weight"
    ) := calc_cohort_weights(
      cohort = cohort,
      adult_fem_weight = herd_level_data[.SD, on = "herd_id", x.adult_fem_weight],
      adult_mal_weight = herd_level_data[.SD, on = "herd_id", x.adult_mal_weight],
      birth_weight = herd_level_data[.SD, on = "herd_id", x.birth_weight],
      slaughter_weight_fem = herd_level_data[.SD, on = "herd_id", x.slaughter_weight_fem],
      slaughter_weight_mal = herd_level_data[.SD, on = "herd_id", x.slaughter_weight_mal],
      weaning_weight = herd_level_data[.SD, on = "herd_id", x.weaning_weight]
    ),
    by = .I
  ]

  # Calculate average and final weights
  cohort_level_data[
    ,
    c("average_weight", "final_weight") := calc_avg_weights(
      initial_weight = initial_weight,
      potential_final_weight = potential_final_weight,
      slaughter_weight = slaughter_weight,
      offtake_rate = offtake_rate
    ),
    by = .I
  ]

  # Calculate daily weight gain
  cohort_level_data[
    ,
    daily_weight_gain := calc_daily_weight_gain(
      potential_final_weight = potential_final_weight,
      initial_weight = initial_weight,
      duration = duration
    ),
    by = .I
  ]

  return(
    list(
      cohort_level_results = cohort_level_data,
      herd_level_results = herd_level_data
    )
  )
}
