#' Calculate Feed Intake Metrics
#'
#' Computes cohort-level dietary energy, digestibility, and nitrogen intake
#' from feed rations and nutritional parameters. Assumes inputs are pre-cleaned.
#'
#' @param rations_share A data.table containing feed shares per cohort. Must include:
#'   - `herd_id`, `animal`, `feed_name`, `feed_id`, `cohort_short`, and
#'     `feed_ration_fraction`.
#' @param feed_params A data.table of nutrient parameters. Must include:
#'   - `feed_id`, `feed_name`, `category`, `feed_gross_energy`,
#'     `feed_digestible_energy_ruminant`, `feed_digestible_energy_pigs`,
#'     `feed_metabolizable_energy_ruminant`, `feed_metabolizable_energy_pigs`,
#'     `feed_metabolizable_energy_chicken`, `feed_nitrogen_content`.
#'
#' @return A data.table summarized by `herd_id`, `animal`, and `cohort_short` with:
#'   - `diet_gross_energy`, `diet_metabolizable_energy`,
#'     `diet_nitrogen`, `diet_digestibility_fraction`
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
#' @export
#'
#' @importFrom data.table fifelse data.table
run_feed_rations <- function(
    rations_share,
    feed_params = data.table::fread(
      system.file("extdata/Parameters/feed/feed_params.csv", package = "gleam")
    )
) {
  # --- Step 1: Validate inputs ------------------------------------------------
  validate_feed_rations_inputs(rations_share, feed_params)

  # --- Step 2: Compute digestibility ratios -----------------------------------
  feed_params[
    ,
    c(
      "feed_digestibility_fraction_ruminant",
      "feed_digestibility_fraction_pigs",
      "feed_digestibility_fraction_chicken"
    ) := calc_feed_digestibility_fraction(
      feed_digestible_energy_ruminant = feed_digestible_energy_ruminant,
      feed_digestible_energy_pigs = feed_digestible_energy_pigs,
      feed_metabolizable_energy_chicken = feed_metabolizable_energy_chicken,
      feed_gross_energy = feed_gross_energy
    ),
    by = .I
  ]
  # --- Step 3: Merge ration shares with feed parameters -----------------------
  rations_detailed <- merge(
    rations_share,
    feed_params,
    by = "feed_id",
  )

  rations_detailed <- merge(
    rations_detailed,
    abbr_animals,
    by.x = "animal",
    by.y = "animal"
  )

  if (any(is.na(rations_detailed$animal_short))) {
    unknown_animals <- unique(rations_detailed[is.na(animal_short), animal])
    cli::cli_abort(
      "Unknown {.arg animal} values in {.arg rations_share}: {.val {unknown_animals}}"
    )
  }

  # --- Step 4: Calculate cohort feed contributions ----------------------------
  rations_detailed[
    ,
    diet_gross_energy := calc_diet_gross_energy(
      feed_ration_fraction = feed_ration_fraction,
      feed_gross_energy = feed_gross_energy
    ),
    by = .I
  ]

  rations_detailed[
    ,
    diet_nitrogen := calc_diet_nitrogen_content(
      feed_ration_fraction = feed_ration_fraction,
      feed_nitrogen_content = feed_nitrogen_content
    ),
    by = .I
  ]

  rations_detailed[
    ,
    diet_digestibility_fraction := calc_diet_digestibility(
      species_short = animal_short,
      feed_ration_fraction = feed_ration_fraction,
      feed_digestibility_fraction_ruminant = feed_digestibility_fraction_ruminant,
      feed_digestibility_fraction_pigs = feed_digestibility_fraction_pigs,
      feed_digestibility_fraction_chicken = feed_digestibility_fraction_chicken
    ),
    by = .I
  ]

  rations_detailed[
    ,
    diet_metabolizable_energy := calc_diet_metabolizable_energy(
      species_short = animal_short,
      feed_ration_fraction = feed_ration_fraction,
      feed_metabolizable_energy_ruminant = feed_metabolizable_energy_ruminant,
      feed_metabolizable_energy_pigs = feed_metabolizable_energy_pigs,
      feed_metabolizable_energy_chicken = feed_metabolizable_energy_chicken
    ),
    by = .I
  ]

  # --- Step 5: Summarize dietary metrics at cohort level ----------------------
  rations_summary <- rations_detailed[
    ,
    .(
      diet_gross_energy = sum(diet_gross_energy, na.rm = TRUE),
      diet_metabolizable_energy = sum(diet_metabolizable_energy, na.rm = TRUE),
      diet_nitrogen = sum(diet_nitrogen, na.rm = TRUE),
      diet_digestibility_fraction = sum(diet_digestibility_fraction, na.rm = TRUE)
    ),
    by = .(herd_id, animal, cohort_short)
  ]

  return(rations_summary)
}
