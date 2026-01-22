#' Run Weight Calculations
#'
#' Applies weight calculations on a long-format table and returns the same table
#' with weight-related columns appended. This function orchestrates the calculation
#' of initial weights, potential final weights, slaughter weights, average weights,
#' final weights, and daily weight gain for each cohort.
#'
#' @param data A `data.table` in long format (one row per cohort) with mandatory columns:
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
#'     \item{`Animal_short`} {Character. Code identifying the livestock species.
#'   Supported values include:
#'   \itemize{
#'     \item \code{PGS}: pigs
#'     \item \code{CML}: camels
#'     \item \code{CTL}: cattle
#'     \item \code{BFL}: buffalo
#'     \item \code{SHP}: sheep
#'     \item \code{GTS}: goats
#'   }}
#'     \item{`offtake_rate`}{Numeric. Annual proportion of animals removed from the herd for each sex-age cohort (fraction).}
#'   }
#'   Additional required columns for weight calculations:
#'   \itemize{
#'     \item `AFKG` - Numeric. Live weight of adult females (kg)
#'     \item `AMKG` - Numeric. Live weight of adult males (kg)
#'     \item `ckg` - Numeric. Live weight of the animal at birth (kg).
#'     \item `MFSKG` - Numeric. Slaughter weight of female sub-adult animals (kg).
#'     \item `MMSKG` - Numeric. Slaughter weight of male sub-adult animals (kg).
#'     \item `wkg` - Numeric. Live weight of the animal at weaning (kg)
#'     \item `afc` - Numeric. Age at first parturition for female breeding animals (years)
#'     \item `WA` - Numeric. Average age of the juvenile animals at weaning (days)
#'   }
#'
#' @return A `data.table` with the same structure as input, with the following
#'   weight-related columns appended:
#'   \describe{
#'     \item{`initial_weight`}{Numeric. Live weight at the beginning of the cohort stage (kg).}
#'     \item{`potential_final_weight`}{Numeric. Potential final live weight attainable at the end of the cohort stage in the absence of offtake (kg). (For juveniles: equals weaning weight; For subadults: equals adult live weight; For adults: equals adult live weight)}
#'     \item{`slaughter_weight`}{Numeric. Live weight at slaughter for animals removed from the cohort (kg).}
#'     \item{`average_weight`}{Numeric. Average live weight over the cohort stage. Computed by accounting for the share of offtaken animals within the cohort, using their slaughter weight, and the potential final weight of animals that remain in the cohort (kg).}
#'     \item{`final_weight`}{Numeric. Live weight at the end of the cohort stage, accounting for both surviving and offtaken animals. Computed in the GLEAM pipeline as a weighted average of the potential final weight of surviving animals and the slaughter weight of offtaken animals, based on the offtake rate (kg).}
#'     \item{`adult_weight`}{Numeric. Mature (adult) live weight that the animal can attain under given biological and management conditions (kg).}
#'     \item{`dwg`}{Numeric. Average live weight gain of the cohort over the cohort stage (kg/head/day).}
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
  data[, daily_weight_gain := calc_daily_weight_gain(
    potential_final_weight = potential_final_weight,
    initial_weight = initial_weight,
    duration = duration
  ), by = .I]

  return(data)
}
