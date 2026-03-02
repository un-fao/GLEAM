#' Calculate Feed Intake Metrics
#'
#' Computes cohort-level diet nutritional metrics (gross and metabolizable energy
#' content, digestibility, nitrogen content, urinary energy losses, and ash
#' content) from cohort-level feed ration composition shares and feed component nutrient
#' parameters.
#'
#' @param rations_share data.table. Cohort-level feed ration composition shares with the
#'   following minimum data requirement:
#'   \describe{
#'     \item{herd_id}{Character. Unique identifier for the herd, repeated for each
#'     cohort belonging to the same herd.}
#'     \item{animal}{
#'     Character. Livestock category name used to map to a species short code via an
#'     internal lookup table. Supported values include:
#'     \itemize{
#'     \item \code{Cattle}
#'     \item \code{Buffalo}
#'     \item \code{Sheep}
#'     \item \code{Goats}
#'     \item \code{Chicken}
#'     \item \code{Pigs}
#'     \item \code{Camels}
#'     }
#'     }
#'     \item{cohort_short}{
#'     Character. Sex- and age-specific cohort code describing the production stage
#'     of the animals. Supported values include:
#'     \itemize{
#'     \item \code{FA}: adult females (from age at first parturition)
#'     \item \code{FS}: sub-adult females (from weaning to age at first parturition)
#'     \item \code{FJ}: juvenile females (from birth to weaning)
#'     \item \code{MA}: adult males (from age at first breeding)
#'     \item \code{MS}: sub-adult males (from weaning to age at first breeding)
#'     \item \code{MJ}: juvenile males (from birth to weaning)
#'   }
#'   }
#'     \item{feed_id}{Character. Unique identifier for the feed component, used to join feed ration data (\code{rations_share}) with feed nutritional parameters table (\code{feed_params}). Must be unique.}
#'     \item{feed_name}{Character. feed component name (optional, for readability and
#'     reporting). If provided, it should uniquely identify the same feed component as \code{feed_id}.}
#'     \item{feed_ration_fraction}{Numeric. Proportion of a specific feed component in the total ration, expressed as its fraction of diet dry matter intake (fraction).
#'     Within each herd_id and cohort, proportions should sum to 1.}
#'   }
#'
#' @param feed_params data.table. Feed nutritional parameters with the following
#'   minimum data requirement:
#'   \describe{
#'     \item{feed_id}{Character. Unique identifier for the feed component, used to join feed ration data (\code{rations_share}) with feed nutritional parameters table (\code{feed_params}). Must be unique.}
#'     \item{feed_gross_energy}{Numeric. Gross energy content of a feed component,
#'     representing the total chemical energy released upon complete combustion of
#'     the feed (MJ/kg DM).}
#'     \item{feed_digestible_energy_ruminant}{Numeric. Digestible energy content of
#'     a feed component for ruminants, representing the energy absorbed by the animal
#'     after fecal losses (MJ/kg DM).}
#'     \item{feed_digestible_energy_pigs}{Numeric. Digestible energy content of a
#'     feed component for pigs, representing the energy absorbed by the animal after
#'     fecal losses (MJ/kg DM).}
#'     \item{feed_metabolizable_energy_ruminant}{Numeric. Metabolizable energy
#'     content of a feed component for ruminants, representing digestible energy minus
#'     energy losses in urine and gaseous products of digestion (MJ/kg DM).}
#'     \item{feed_metabolizable_energy_pigs}{Numeric. Metabolizable energy content
#'     of a feed component for pigs, representing digestible energy minus energy losses
#'     in urine and gaseous products of digestion (MJ/kg DM).}
#'     \item{feed_metabolizable_energy_chicken}{Numeric. Metabolizable energy
#'     content of a feed component for chickens, representing digestible energy minus
#'     energy losses in uric acid and gaseous products of digestion (MJ/kg DM).}
#'     \item{feed_nitrogen_content}{Numeric. Nitrogen content of a feed component
#'     (kg N/kg DM).}
#'     \item{feed_urinary_energy_ruminant}{Numeric. Fraction of feed's gross energy
#'     that is excreted in urine for ruminants (fraction).}
#'     \item{feed_urinary_energy_pigs}{Numeric. Fraction of feed's gross energy
#'     that is excreted in urine for pigs (fraction).}
#'     \item{feed_ash_content}{Numeric. Average ash content by feed component, calculated
#'     as a fraction of the dry matter intake (g ash/100g DM).}
#'     \item{category}{Character. Feed category (optional). If provided, it should be
#'     used consistently  with \code{feed_id}, for a coherent result.}
#'     \item{feed_name}{Character. feed component name (optional, for readability and
#'     reporting). If provided, it should uniquely identify the same feed component as \code{feed_id}.}
#'   }
#'
#' @param show_indicator Logical. Whether to display progress indicators during calculations.
#'
#' @return data.table. Cohort-level nutritional metrics summarized by \code{herd_id},
#'   \code{animal}, and \code{cohort_short} with the following columns:
#'   \describe{
#'     \item{diet_gross_energy}{Numeric. Average gross energy content of the diet
#'     (MJ/kg DM).}
#'     \item{diet_metabolizable_energy}{Numeric. Average metabolizable energy
#'     content of the diet (MJ/kg DM).}
#'     \item{diet_nitrogen}{Numeric. Average nitrogen content of diet (kg N/kg DM).}
#'     \item{diet_digestibility_fraction}{Numeric. Average digestibility of the feed
#'     ration, expressed as ratio of digestible (or metabolizable, for poultry) to
#'     gross energy content (fraction).}
#'     \item{urinary_energy_fraction}{Numeric. Fraction of feed's gross energy that
#'     is excreted in urine (fraction).}
#'     \item{diet_ash}{Numeric. Average ash content of feed, calculated as a fraction
#'     of the dry matter intake (kg ash/kg DM).}
#'   }
#'
#' @details
#' This function joins \code{rations_share} with \code{feed_params} by \code{feed_id},
#' maps \code{animal} to a species short code, and computes ration-weighted nutritional
#' metrics by cohort.
#'
#' The following calculation sequence is applied:
#' \enumerate{
#'   \item Species-specific digestibility ratios are computed from energy parameters
#'   and \code{feed_gross_energy} using \code{\link{calc_feed_digestibility_fraction}}.
#'   \item Contributions of each feed component are computed as ration-weighted values:
#'   \itemize{
#'     \item gross energy using \code{\link{calc_diet_gross_energy}}
#'     \item nitrogen using \code{\link{calc_diet_nitrogen_content}}
#'     \item digestibility using \code{\link{calc_diet_digestibility}}
#'     \item metabolizable energy using \code{\link{calc_diet_metabolizable_energy}}
#'     \item urinary energy fraction using \code{\link{calc_urinary_energy_fraction}}
#'     \item ash using \code{\link{calc_diet_ash}}
#'   }
#'   \item Cohort-level nutritional metrics are obtained for the whole feed ration by summing contributions across
#'   feed components within each \code{herd_id}, \code{animal}, and \code{cohort_short}.
#' }
#'
#' @seealso
#' \code{\link{calc_feed_digestibility_fraction}},
#' \code{\link{calc_diet_gross_energy}},
#' \code{\link{calc_diet_nitrogen_content}},
#' \code{\link{calc_diet_digestibility}},
#' \code{\link{calc_diet_metabolizable_energy}},
#' \code{\link{calc_urinary_energy_fraction}},
#' \code{\link{calc_diet_ash}}
#'
#' @examples
#' \dontrun{
#' # Load feed rations inputs (cohort-level shares and feed parameters)
#' feed_rations_chrt_dt <- data.table::fread(system.file(
#'   "extdata/run_modules_examples/feed_rations_share_chrt_data.csv",
#'   package = "gleam"
#' ))
#' feed_params_dt <- data.table::fread(system.file(
#'   "extdata/Parameters/feed/feed_params.csv",
#'   package = "gleam"
#' ))
#'
#' result <- run_feed_rations(
#'   rations_share = feed_rations_chrt_dt,
#'   feed_params = feed_params_dt
#' )
#' }
#' @export
#'
#' @importFrom data.table fifelse data.table
run_feed_rations <- function(
    rations_share,
    feed_params,
    show_indicator = TRUE
) {
  # --- Step 1: Validate inputs -----------------------------------------------
  validate_feed_rations_inputs(rations_share, feed_params)

  # Show progress indicator if requested
  if (show_indicator) {
    cli::cli_status("\U1F552 Aggregating feed rations, please wait\U2026")
  }

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

  # Clear progress indicator if it was shown
  if (show_indicator) {
    cli::cli_status_clear()
    cli::cli_alert_success("Feed rations aggregation complete.")
  }

  return(rations_summary)
}
