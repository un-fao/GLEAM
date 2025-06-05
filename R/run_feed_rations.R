#' Calculate Feed Intake Metrics
#'
#' Computes cohort-level dietary energy, digestibility, and nitrogen intake
#' from feed rations and nutritional parameters. Assumes inputs are pre-cleaned.
#'
#' @param rations_share A data.table containing feed shares per cohort. Must include:
#'   - `Animal`, `GLEAM3_name`, `COUNTRY`, `ADM0_CODE`, `HerdType`, `LPS`, `cohort`, and `value`.
#' @param feed_params A data.table of nutrient parameters. Must include:
#'   - `GLEAM3_name`, `GE`, `DE_ruminants`, `DE_pigs`, `ME_ruminants`, `ME_pigs`, `ME_chickens`, `N_content`.
#' @param input_feed A data.table of cohort-level baseline GLEAM data. Must include:
#'   - `Animal_short`, `ADM0_CODE`, `COUNTRY`, `HerdType`, `LPS`, `cohort`.
#'
#' @return A data.table matching `input_feed` enriched with dietary metrics:
#'   - `diet_ge`, `diet_me`, `diet_nitrogen`, `diet_dig`
#'
#' @examples
#' \dontrun{
#' # Load cleaned example input from the package and compute feed intake metrics
#' feed_params <- data.table::fread(
#'   system.file("extdata/Feed_parameters.csv", package = "gleam")
#' )
#'
#' rations_share <- data.table::fread(
#'   system.file("extdata/GLEAM_input_FeedRations.csv", package = "gleam")
#' )
#'
#' input_feed <- data.table::fread(
#'   system.file("extdata/GLEAM_input_feed.csv", package = "gleam")
#' )
#'
#' result <- calculate_feed_intake_metrics(rations_share, feed_params, input_feed)
#' }
#' @export
#'
#' @importFrom data.table fifelse data.table
calculate_feed_intake_metrics <- function(rations_share, feed_params, input_feed) {
  # Compute digestibility ratios
  feed_params[, `:=`(
    dig_ruminants  = DE_ruminants / GE,
    dig_pigs       = DE_pigs / GE,
    dig_chickens   = ME_chickens / GE
  )]

  # Select relevant nutrient columns
  feed_params_nutrients <- feed_params[, .(
    GLEAM3_name, GE, ME_ruminants, ME_pigs, ME_chickens,
    N_content, dig_ruminants, dig_pigs, dig_chickens
  )]

  # Average nutritional values across feed types
  cols_to_average <- c(
    "GE", "ME_ruminants", "ME_pigs", "ME_chickens",
    "N_content", "dig_ruminants", "dig_pigs", "dig_chickens"
  )

  feed_params_summary <- feed_params_nutrients[
    , lapply(.SD, function(x) mean(x, na.rm = TRUE)),
    by = GLEAM3_name,
    .SDcols = cols_to_average
  ]

  # Merge ration shares with feed parameters
  rations_detailed <- merge(
    rations_share, feed_params_summary,
    by = "GLEAM3_name", all.x = TRUE, allow.cartesian = TRUE
  )

  # Add species abbreviations
  abbr_animals <- data.table(
    Animal = c("Cattle", "Buffalo", "Sheep", "Goats", "Chicken", "Pigs", "Camels"),
    Animal_short = c("CTL", "BFL", "SHP", "GTS", "CHK", "PGS", "CML")
  )
  rations_detailed <- merge(rations_detailed, abbr_animals, by = "Animal", all.x = TRUE)

  # Calculate cohort feed contributions: GE, ME, digestibility, nitrogen
  rations_detailed[, `:=`(
    diet_ge = value * GE,
    diet_nitrogen = value * N_content,
    diet_dig = fifelse(
      Animal_short %in% c("CTL", "BFL", "CML", "SHP", "GTS"), value * dig_ruminants,
      fifelse(Animal_short == "CHK", value * dig_chickens,
              fifelse(Animal_short == "PGS", value * dig_pigs, NA_real_))
    ),
    diet_me = fifelse(
      Animal_short %in% c("CTL", "BFL", "CML", "SHP", "GTS"), value * ME_ruminants,
      fifelse(Animal_short == "CHK", value * ME_chickens,
              fifelse(Animal_short == "PGS", value * ME_pigs, NA_real_))
    )
  )]

  # Summarize dietary metrics at the cohort level
  rations_summary <- rations_detailed[, .(
    diet_ge = sum(diet_ge, na.rm = TRUE),
    diet_me = sum(diet_me, na.rm = TRUE),
    diet_nitrogen = sum(diet_nitrogen, na.rm = TRUE),
    diet_dig = sum(diet_dig, na.rm = TRUE)
  ), by = .(Animal_short, COUNTRY, ADM0_CODE, HerdType, LPS, cohort)]

  # Merge back with input data and return output
  merge(
    input_feed,
    rations_summary,
    by = c("Animal_short", "ADM0_CODE", "COUNTRY", "HerdType", "LPS", "cohort"),
    all.x = TRUE,
    allow.cartesian = TRUE
  )
}
