#' Run Weight Calculations
#'
#' Applies weight calculations on a long-format table and returns the same table
#' with weight-related columns appended. This function orchestrates the calculation
#' of initial weights, potential final weights, slaughter weights, average weights,
#' final weights, and daily weight gain for each cohort.
#'
#' @param data A `data.table` in long format (one row per cohort) with mandatory columns:
#'   \describe{
#'     \item{`herd_id`}{Unique identifier for each herd. All cohorts belonging to
#'       the same herd must share the same `herd_id`.}
#'     \item{`cohort`}{Cohort code (e.g., "FJ", "FS", "FA", "MJ", "MS", "MA"). Required for
#'       determining which weight calculation logic to apply.}
#'     \item{`duration`}{Duration of the cohort stage (in days).}
#'     \item{`Animal_short`}{Animal species code (e.g., "PGS", "CML", "CTL", "BFL", "SHP", "GTS").}
#'     \item{`offtake_rate`}{Offtake rate for the cohort.}
#'   }
#'   Additional required columns for weight calculations:
#'   \itemize{
#'     \item `AFKG` - Adult female weight (kg)
#'     \item `AMKG` - Adult male weight (kg)
#'     \item `ckg` - Birth weight (kg)
#'     \item `MFSKG` - Slaughter weight female (kg)
#'     \item `MMSKG` - Slaughter weight male (kg)
#'     \item `wkg` - Weaning weight (kg)
#'     \item `afc` - Age at first calving (days)
#'     \item `WA` - Animal age at current stage (days)
#'   }
#'
#' @return A `data.table` with the same structure as input, with the following
#'   weight-related columns appended:
#'   \describe{
#'     \item{`initial_weight`}{Initial live weight at the start of the cohort stage.}
#'     \item{`potential_final_weight`}{Potential final live weight if no offtake occurs.}
#'     \item{`slaughter_weight`}{Slaughter live weight.}
#'     \item{`average_weight`}{Average live weight over the stage.}
#'     \item{`final_weight`}{Final live weight after accounting for survivors and offtaken animals.}
#'     \item{`adult_weight`}{Numeric. Adult weight that could be reached by the animal (kg).}
#'     \item{`dwg`}{Daily weight gain (kg/day).}
#'   }
#'
#' @export
#'
#' @importFrom data.table := .I
run_weights_calculations <- function(data) {
  # Validate input
  if (!data.table::is.data.table(data)) {
    cli::cli_abort("{.arg data} must be a data.table.")
  }

  # Required columns for weight calculations
  required_cols <- c(
    "cohort",
    "duration",
    "Animal_short",
    "offtake_rate",
    "AFKG", # Adult female weight
    "AMKG", # Adult male weight
    "ckg", # Birth weight
    "MFSKG", # Slaughter weight female
    "MMSKG", # Slaughter weight male
    "wkg", # Weaning weight (must be provided in input data)
    "afc", # Age at first calving
    "WA" # Animal age at current stage
  )
  missing_cols <- setdiff(required_cols, names(data))
  if (length(missing_cols) > 0) {
    cli::cli_abort("Missing required columns: {.val {missing_cols}}")
  }

  # Calculate initial, potential final, and slaughter weights
  data[, c(
    "initial_weight", "potential_final_weight", "slaughter_weight"
  ) := calc_cohort_weights(
    animal = Animal_short,
    cohort = cohort,
    adult_fem_weight = AFKG,
    adult_mal_weight = AMKG,
    birth_weight = ckg,
    slaughter_weight_fem = MFSKG,
    slaughter_weight_mal = MMSKG,
    weaning_weight = wkg,
    age_first_calving = afc,
    animal_age = WA
  ),
  by = .I
  ]

  # Calculate average and final weights
  data[, c("average_weight", "final_weight") :=
         calc_avg_weights(
           initial_weight = initial_weight,
           potential_final_weight = potential_final_weight,
           slaughter_weight = slaughter_weight,
           offtake_rate = offtake_rate
         ),
       by = .I
  ]

  # Create a new variable (adult_weight)
  data[, adult_weight := data.table::fifelse(
    cohort %in% c("FA", "FS", "FJ"),
    average_weight[cohort == "FA"][1], # female adult ref for this group
    data.table::fifelse(
      cohort %in% c("MA", "MS", "MJ"),
      average_weight[cohort == "MA"][1], # male adult ref for this group
      NA_real_
    )
  ), by = .(herd_id, Animal_short)]

  # Calculate daily weight gain
  data[, dwg := calc_daily_weight_gain(
    potential_final_weight = potential_final_weight,
    initial_weight = initial_weight,
    duration = duration
  ), by = .I]

  return(data)
}
