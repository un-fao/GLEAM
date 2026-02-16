#' Calculate Feed Intake Metrics
#'
#' Computes cohort-level dietary energy, digestibility, and nitrogen intake
#' from feed rations and nutritional parameters. Assumes inputs are pre-cleaned.
#'
#' @param rations_share A data.table containing feed shares per cohort. Must include:
#'   - `herd_id`, `animal`, `feed_name`, `feed_id`, `cohort_short`, and
#'     `feed_ration_fraction`.
#'   - Note that `feed_name` is optional but should be consistent with `feed_id`
#'   for a coherent result.
#' @param feed_params A data.table of nutrient parameters. Must include:
#'   - `feed_id`, `feed_gross_energy`,
#'     `feed_digestible_energy_ruminant`, `feed_digestible_energy_pigs`,
#'     `feed_metabolizable_energy_ruminant`, `feed_metabolizable_energy_pigs`,
#'     `feed_metabolizable_energy_chicken`, `feed_nitrogen_content`,
#'     `feed_urinary_energy_ruminant`, `feed_urinary_energy_pigs`,
#'      `feed_ash_content`.
#'   - Note that `category` and `feed_name` are optional but should be consistent with `feed_id`
#'   for a coherent result.
#'
#' @return A data.table summarized by `herd_id`, `animal`, and `cohort_short` with:
#'   - `diet_gross_energy`, `diet_metabolizable_energy`,
#'     `diet_nitrogen`, `diet_digestibility_fraction`,
#'     `urinary_energy_fraction`, `diet_ash`
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
  # --- Step 1: Validate inputs -----------------------------------------------
  validate_feed_rations_inputs(rations_share, feed_params)

  # --- Step 2: Create working copies -----------------------------------------
  rations_share <- data.table::copy(rations_share)
  feed_params <- data.table::copy(feed_params)

  # --- Step 3: Compute digestibility ratios ----------------------------------
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
  # --- Step 4: Merge ration shares with feed parameters ----------------------
  rations_detailed <- merge(
    rations_share,
    feed_params,
    by = "feed_id",
  )
  # Map animal to species_short for digestibility and energy calculations
  rations_detailed <- merge(
    rations_detailed,
    abbr_animals,
    by.x = "animal",
    by.y = "animal"
  )

  # Check for any unmatched animals after the merge
  if (any(is.na(rations_detailed$species_short))) {
    unknown_animals <- unique(rations_detailed[is.na(species_short), animal])
    cli::cli_abort(
      "Unknown {.arg animal} values in {.arg rations_share}: {.val {unknown_animals}}"
    )
  }

  # --- Step 5: Calculate cohort feed contributions ---------------------------
  rations_detailed[
    ,
    diet_gross_energy := calc_diet_gross_energy(
      feed_ration_fraction = feed_ration_fraction,
      feed_gross_energy = feed_gross_energy
    ),
    by = .I
  ]

  # Calculate nitrogen contribution
  rations_detailed[
    ,
    diet_nitrogen := calc_diet_nitrogen_content(
      feed_ration_fraction = feed_ration_fraction,
      feed_nitrogen_content = feed_nitrogen_content
    ),
    by = .I
  ]

  # Calculate digestibility fraction
  rations_detailed[
    ,
    diet_digestibility_fraction := calc_diet_digestibility(
      species_short = species_short,
      feed_ration_fraction = feed_ration_fraction,
      feed_digestibility_fraction_ruminant = feed_digestibility_fraction_ruminant,
      feed_digestibility_fraction_pigs = feed_digestibility_fraction_pigs,
      feed_digestibility_fraction_chicken = feed_digestibility_fraction_chicken
    ),
    by = .I
  ]

  # Calculate metabolizable energy contribution
  rations_detailed[
    ,
    diet_metabolizable_energy := calc_diet_metabolizable_energy(
      species_short = species_short,
      feed_ration_fraction = feed_ration_fraction,
      feed_metabolizable_energy_ruminant = feed_metabolizable_energy_ruminant,
      feed_metabolizable_energy_pigs = feed_metabolizable_energy_pigs,
      feed_metabolizable_energy_chicken = feed_metabolizable_energy_chicken
    ),
    by = .I
  ]

  # Calculate urinary energy fraction
  rations_detailed[
    ,
    urinary_energy_fraction := calc_urinary_energy_fraction(
      species_short = species_short,
      feed_ration_fraction = feed_ration_fraction,
      feed_urinary_energy_ruminant = feed_urinary_energy_ruminant,
      feed_urinary_energy_pigs = feed_urinary_energy_pigs,
    ),
    by = .I
  ]

  rations_detailed[
    ,
    diet_ash := calc_diet_ash(
      feed_ration_fraction = feed_ration_fraction,
      feed_ash_content = feed_ash_content
    ),
    by = .I
  ]

  # --- Step 6: Summarize dietary metrics at cohort level ---------------------
  rations_summary <- rations_detailed[
    ,
    .(
      diet_gross_energy = sum(diet_gross_energy),
      diet_metabolizable_energy = sum(diet_metabolizable_energy),
      diet_nitrogen = sum(diet_nitrogen),
      diet_digestibility_fraction = sum(diet_digestibility_fraction),
      urinary_energy_fraction = sum(urinary_energy_fraction),
      diet_ash = sum(diet_ash)
    ),
    by = .(herd_id, animal, cohort_short)
  ]

  return(rations_summary)
}
