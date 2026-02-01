#' Calculate Feed Intake Metrics
#'
#' Computes cohort-level dietary energy, digestibility, and nitrogen intake
#' from feed rations and nutritional parameters. Assumes inputs are pre-cleaned.
#'
#' @param rations_share A data.table containing feed shares per cohort. Must include:
#'   - `herd_id`, `animal`, `feed_name`, `feed_id`, `cohort`, and `ration`.
#' @param feed_params A data.table of nutrient parameters. Must include:
#'   - `feed_id`, `feed_name`, `category`, `GE`, `DE_ruminants`, `DE_pigs`,
#'     `ME_ruminants`, `ME_pigs`, `ME_chickens`, `N_content`.
#'
#' @return A data.table summarized by `herd_id`, `animal`, and `cohort` with:
#'   - `diet_ge`, `diet_me`, `diet_nitrogen`, `diet_dig`
#'
#' @examples
#' \dontrun{
#' # Load cleaned example input from the package and compute feed intake metrics
#' feed_params <- data.table::fread(
#'   system.file("extdata/Parameters/feed/feed_params.csv", package = "gleam")
#' )
#'
#' rations_share <- data.table::fread(
#'   system.file("extdata/examples/feed_rations_share_example.csv", package = "gleam")
#' )
#'
#' result <- run_feed_rations(rations_share, feed_params)
#' }
#' @keywords internal
#'
#' @importFrom data.table fifelse data.table
run_feed_rations <- function(
    rations_share,
    feed_params = data.table::fread(
      system.file("extdata/Parameters/feed/feed_params.csv", package = "gleam")
    )
) {
  # --- Input validation --------------------------------------------------------
  if (!data.table::is.data.table(rations_share)) {
    cli::cli_abort("{.arg rations_share} must be a data.table.")
  }
  if (!data.table::is.data.table(feed_params)) {
    cli::cli_abort("{.arg feed_params} must be a data.table.")
  }

  required_rations_cols <- c(
    "herd_id", "animal", "feed_name", "feed_id", "cohort", "ration"
  )
  required_feed_cols <- c(
    "feed_id", "feed_name", "category", "GE", "DE_ruminants", "DE_pigs",
    "ME_ruminants", "ME_pigs", "ME_chickens", "N_content"
  )

  missing_rations_cols <- setdiff(required_rations_cols, names(rations_share))
  if (length(missing_rations_cols) > 0) {
    cli::cli_abort(
      "Missing required columns in {.arg rations_share}: {.val {missing_rations_cols}}"
    )
  }

  missing_feed_cols <- setdiff(required_feed_cols, names(feed_params))
  if (length(missing_feed_cols) > 0) {
    cli::cli_abort(
      "Missing required columns in {.arg feed_params}: {.val {missing_feed_cols}}"
    )
  }

  if (anyDuplicated(feed_params$feed_id) > 0) {
    cli::cli_abort("{.arg feed_params$feed_id} must be unique.")
  }

  # Validate mapping between feed_id and feed_name in rations_share
  feed_name_check <- merge(
    rations_share[, .(feed_id, feed_name)],
    unique(feed_params[, .(feed_id, feed_name)]),
    by = "feed_id",
    all.x = TRUE,
    suffixes = c("_input", "_params")
  )
  mismatched_feed_names <- feed_name_check[
    is.na(feed_name_params) | feed_name_input != feed_name_params,
    unique(feed_id)
  ]
  if (length(mismatched_feed_names) > 0) {
    cli::cli_abort(
      "feed_id values with missing or mismatched feed_name in {.arg feed_params}: {.val {mismatched_feed_names}}"
    )
  }

  # Compute digestibility ratios
  feed_params[
    ,
    `:=`(
      dig_ruminants  = DE_ruminants / GE,
      dig_pigs       = DE_pigs / GE,
      dig_chickens   = ME_chickens / GE
    )
  ]

  # Merge ration shares with feed parameters
  rations_detailed <- merge(
    rations_share, feed_params,
    by = "feed_id", all.x = TRUE, allow.cartesian = TRUE
  )

  rations_detailed <- merge(
    rations_detailed,
    abbr_animals,
    by.x = "animal",
    by.y = "animal",
    all.x = TRUE
  )

  if (any(is.na(rations_detailed$animal_short))) {
    unknown_animals <- unique(rations_detailed[is.na(animal_short), animal])
    cli::cli_abort(
      "Unknown {.arg animal} values in {.arg rations_share}: {.val {unknown_animals}}"
    )
  }

  # Calculate cohort feed contributions: GE, ME, digestibility, nitrogen
  rations_detailed[
    ,
    `:=`(
      diet_ge = ration * GE,
      diet_nitrogen = ration * N_content,
      diet_dig = data.table::fifelse(
        animal_short %in% c("CTL", "BFL", "CML", "SHP", "GTS"), ration * dig_ruminants,
        data.table::fifelse(animal_short == "CHK", ration * dig_chickens,
                            data.table::fifelse(animal_short == "PGS", ration * dig_pigs, NA_real_))
      ),
      diet_me = data.table::fifelse(
        animal_short %in% c("CTL", "BFL", "CML", "SHP", "GTS"), ration * ME_ruminants,
        data.table::fifelse(animal_short == "CHK", ration * ME_chickens,
                            data.table::fifelse(animal_short == "PGS", ration * ME_pigs, NA_real_))
      )
    )
  ]

  # Summarize dietary metrics at the cohort level
  rations_summary <- rations_detailed[
    ,
    .(
      diet_ge = sum(diet_ge, na.rm = TRUE),
      diet_me = sum(diet_me, na.rm = TRUE),
      diet_nitrogen = sum(diet_nitrogen, na.rm = TRUE),
      diet_dig = sum(diet_dig, na.rm = TRUE)
    ),
    by = .(herd_id, animal, cohort)
  ]

  return(rations_summary)
}
