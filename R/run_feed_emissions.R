#' Calculate cohort-level average greenhouse gas (GHG) emission factors for feed rations
#'
#' Computes cohort-level average greenhouse gas (GHG) emission factors from feed production by
#' weighting emission factors of individual feed components by diet composition.
#' Returns diet-level average GHG emission factors by gas and emission source for each cohort.
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
#'     \item{feed_id}{Character. Unique identifier for the feed component, used
#'     to join feed ration data with feed parameter tables.}
#'     \item{feed_name}{Character. Feed component name (optional, for readability and
#'     reporting). If provided, it should uniquely identify the same feed component as \code{feed_id}.}
#'     \item{feed_ration_fraction}{Numeric. Proportion of a specific feed component in the total ration, expressed as its fraction of diet dry matter intake (fraction).
#'     Within each herd_id and cohort, proportions should sum to 1.}
#'   }
#'
#' @param feed_emissions data.table. Emission factors of individual feed components with the
#'   following data requirement:
#'   \describe{
#'     \item{feed_id}{Character. Unique identifier for the feed component, used
#'     to join feed ration data with feed parameter tables.}
#'     \item{feed_name}{Character. Feed component name (optional, for readability and
#'     reporting). If provided, it should uniquely identify the same feed component as \code{feed_id}.}
#'     \item{co2_feed_fertilizer}{Numeric. Carbon dioxide (CO₂) emission factor of a
#'     feed component, representing CO₂ emissions from fertilizer manufacture in feed
#'     production, expressed per kilogram of dry matter intake (g CO₂/kg DM).}
#'     \item{co2_feed_pesticides}{Numeric. Carbon dioxide (CO₂) emission factor of a
#'     feed component, representing CO₂ emissions from pesticide manufacture in feed
#'     production, expressed per kilogram of dry matter intake (g CO₂/kg DM).}
#'     \item{co2_feed_crop_operations}{Numeric. Carbon dioxide (CO₂) emission factor of a
#'     feed component, representing CO₂ emissions from on-field agricultural activities in
#'     feed production, expressed per kilogram of dry matter intake (kg CO₂/kg DM).}
#'     \item{co2_feed_luc_nopeat}{Numeric. Carbon dioxide (CO₂) emission factor of a
#'     feed component, representing CO₂ emissions from land-use change in feed production
#'     (excluding peatland drainage), expressed per kilogram of dry matter intake (g CO₂/kg DM).}
#'     \item{co2_feed_luc_peat}{Numeric. Carbon dioxide (CO₂) emission factor of a
#'     feed component, representing CO₂ emissions from peatland drainage in feed production,
#'     expressed per kilogram of dry matter intake (g CO₂/kg DM).}
#'     \item{n2o_feed_fertilizer}{Numeric. Nitrous oxide (N₂O) emission factor of a
#'     feed component, representing N₂O emissions from fertilizer use in feed production,
#'     expressed per kg of dry matter intake (g N₂O/kg DM).}
#'     \item{n2o_feed_manure_applied}{Numeric. Nitrous oxide (N₂O) emission factor of a
#'     feed component, representing N₂O emissions from manure applied to or deposited
#'     on soil in feed production, expressed per kg of dry matter intake (g N₂O/kg DM).}
#'     \item{n2o_feed_crop_residues}{Numeric. Nitrous oxide (N₂O) emission factor of a
#'     feed component, representing N₂O emissions from crop residues decomposition in
#'     feed production, expressed per kg of dry matter intake (g N₂O/kg DM).}
#'     \item{ch4_feed_rice}{Numeric. Methane (CH₄) emission factor of a feed component,
#'     representing CH₄ emissions from rice cultivation in feed production,
#'     expressed per kg of dry matter intake (g CH₄/kg DM).}
#'   }
#'
#' @param show_indicator Logical. Whether to display progress indicators during calculations.
#'
#' @return data.table. Cohort-level emission factors summarized by \code{herd_id},
#'   \code{animal}, and \code{cohort_short} with the following columns:
#'   \describe{
#'     \item{diet_co2_feed_fertilizer}{
#'       Numeric. Diet-level average carbon dioxide (CO₂) emission factor from
#'       fertilizer manufacture in feed production (g CO₂/kg DM).
#'     }
#'     \item{diet_co2_feed_pesticides}{
#'       Numeric. Diet-level average carbon dioxide (CO₂) emission factor from
#'       pesticide manufacture in feed production (g CO₂/kg DM).
#'     }
#'     \item{diet_co2_feed_crop_operations}{
#'       Numeric. Diet-level average carbon dioxide (CO₂) emission factor from
#'       on-field agricultural activities in feed production (g CO₂/kg DM).
#'     }
#'     \item{diet_co2_feed_luc_nopeat}{
#'       Numeric. Diet-level average carbon dioxide (CO₂) emission factor from
#'       land-use change (excluding peatland drainage) in feed production (g CO₂/kg DM).
#'     }
#'     \item{diet_co2_feed_luc_peat}{
#'       Numeric. Diet-level average carbon dioxide (CO₂) emission factor from
#'       peatland drainage in feed production (g CO₂/kg DM).
#'     }
#'     \item{diet_n2o_feed_fertilizer}{
#'       Numeric. Diet-level average nitrous oxide (N₂O) emission factor from
#'       fertilizer use in feed production (g N₂O/kg DM).
#'     }
#'     \item{diet_n2o_feed_manure_applied}{
#'       Numeric. Diet-level average nitrous oxide (N₂O) emission factor from
#'       manure applied to or deposited on soil in feed production (g N₂O/kg DM).
#'     }
#'     \item{diet_n2o_feed_crop_residues}{
#'       Numeric. Diet-level average nitrous oxide (N₂O) emission factor from
#'       crop residues decomposition in feed production (g N₂O/kg DM).
#'     }
#'     \item{diet_ch4_feed_rice}{
#'       Numeric. Diet-level average methane (CH₄) emission factor from
#'       rice cultivation in feed production (g CH₄/kg DM).
#'     }
#'   }
#'
#' @details
#' This function joins \code{rations_share} with \code{feed_emissions} by \code{feed_id},
#' maps \code{animal} to a species short code, and computes ration-weighted emission
#' factors by cohort.
#'
#' The following calculation sequence is applied:
#' \enumerate{
#'
#'   \item \strong{Merge ration shares with emission factors} at the feed-component level using \code{\link[base]{merge}} on
#'   \code{feed_id} (left join: \code{all.x = TRUE}).
#'
#'   \item \strong{Compute feed-component contributions} (row-wise) for each emission source by
#'   multiplying the ration share of each feed component (\code{feed_ration_fraction})
#'   by the corresponding feed emission factor.
#'   Each contribution is computed using the specific helper below (called with \code{by = .I}):
#'   \itemize{
#'     \item CO₂ fertilizer: \code{\link{calc_diet_co2_feed_fertilizer}}
#'     \item CO₂ pesticides: \code{\link{calc_diet_co2_feed_pesticides}}
#'     \item CO₂ crop operations: \code{\link{calc_diet_co2_feed_crop_operations}}
#'     \item CO₂ land-use change (no peat): \code{\link{calc_diet_co2_feed_luc_nopeat}}
#'     \item CO₂ land-use change (peat): \code{\link{calc_diet_co2_feed_luc_peat}}
#'     \item N₂O fertilizer: \code{\link{calc_diet_n2o_feed_fertilizer}}
#'     \item N₂O manure applied: \code{\link{calc_diet_n2o_feed_manure_applied}}
#'     \item N₂O crop residues: \code{\link{calc_diet_n2o_feed_crop_residues}}
#'     \item CH₄ rice cultivation: \code{\link{calc_diet_ch4_feed_rice}}
#'   }
#'
#'   \item \strong{Aggregate to cohort-level diet emission factors} by summing feed-component contributions
#'   across all feeds within each group \code{(herd_id, animal, cohort_short)}.
#' }
#'
#' For each emission source, cohort-level dietary emission factors are computed as:
#'
#' \deqn{
#'   \mathrm{diet\_ef} =
#'   \sum_{i=1}^{n}
#'   \left(
#'     \mathrm{feed\_ration\_fraction}_{i}
#'     \times
#'     \mathrm{feed\_ef}_{i}
#'   \right)
#' }
#'
#' @seealso
#' \code{\link{calc_diet_co2_feed_fertilizer}},
#' \code{\link{calc_diet_co2_feed_pesticides}},
#' \code{\link{calc_diet_co2_feed_crop_operations}},
#' \code{\link{calc_diet_co2_feed_luc_nopeat}},
#' \code{\link{calc_diet_co2_feed_luc_peat}},
#' \code{\link{calc_diet_n2o_feed_fertilizer}},
#' \code{\link{calc_diet_n2o_feed_manure_applied}},
#' \code{\link{calc_diet_n2o_feed_crop_residues}},
#' \code{\link{calc_diet_ch4_feed_rice}}
#'
#' @examples
#' \dontrun{
#' # Load cleaned example input from the package and compute the calculation of feed emission factors
#'
#' # Load table with ration shares
#' rations_share <- data.table::fread(system.file(
#'   "extdata/run_modules_examples/feed_rations_share_chrt_data.csv",
#'   package = "gleam"
#' ))
#'
#' # Load table with feed emission factors
#' feed_emissions <- data.table::fread(system.file(
#'   "extdata/Parameters/feed/feed_emission_factors.csv",
#'   package = "gleam"
#' ))
#'
#' # Run the code
#' result <- run_feed_emissions(
#'   rations_share = rations_share,
#'   feed_emissions = feed_emissions
#' )
#' }
#' @export

run_feed_emissions <- function(
    rations_share,
    feed_emissions,
    show_indicator = TRUE
) {
  # --- Step 1: Validate inputs ------------------------------------------------
  validate_feed_indirect_emissions_inputs(rations_share, feed_emissions)

  # Show progress indicator if requested
  if (show_indicator) {
    cli::cli_status("\U1F552 Aggregating feed emissions, please wait\U2026")
  }

  # --- Step 2: Create working copies ------------------------------------------
  rations_share <- data.table::copy(rations_share)
  feed_emissions <- data.table::copy(feed_emissions)

  # --- Step 3: Merge ration shares with feed emission parameters --------------
  feed_emissions_detailed <- merge(
    rations_share,
    feed_emissions,
    by = "feed_id",
    all.x = TRUE
  )

  # --- Step 4: Calculate cohort feed contributions ----------------------------
  feed_emissions_detailed[
    ,
    diet_co2_feed_fertilizer := calc_diet_co2_feed_fertilizer(
      feed_ration_fraction = feed_ration_fraction,
      co2_feed_fertilizer = co2_feed_fertilizer
    ),
    by = .I
  ]

  feed_emissions_detailed[
    ,
    diet_co2_feed_pesticides := calc_diet_co2_feed_pesticides(
      feed_ration_fraction = feed_ration_fraction,
      co2_feed_pesticides = co2_feed_pesticides
    ),
    by = .I
  ]

  feed_emissions_detailed[
    ,
    diet_co2_feed_crop_operations := calc_diet_co2_feed_crop_operations(
      feed_ration_fraction = feed_ration_fraction,
      co2_feed_crop_operations = co2_feed_crop_operations
    ),
    by = .I
  ]

  feed_emissions_detailed[
    ,
    diet_co2_feed_luc_nopeat := calc_diet_co2_feed_luc_nopeat(
      feed_ration_fraction = feed_ration_fraction,
      co2_feed_luc_nopeat = co2_feed_luc_nopeat
    ),
    by = .I
  ]

  feed_emissions_detailed[
    ,
    diet_co2_feed_luc_peat := calc_diet_co2_feed_luc_peat(
      feed_ration_fraction = feed_ration_fraction,
      co2_feed_luc_peat = co2_feed_luc_peat
    ),
    by = .I
  ]

  feed_emissions_detailed[
    ,
    diet_n2o_feed_fertilizer := calc_diet_n2o_feed_fertilizer(
      feed_ration_fraction = feed_ration_fraction,
      n2o_feed_fertilizer = n2o_feed_fertilizer
    ),
    by = .I
  ]

  feed_emissions_detailed[
    ,
    diet_n2o_feed_manure_applied := calc_diet_n2o_feed_manure_applied(
      feed_ration_fraction = feed_ration_fraction,
      n2o_feed_manure_applied = n2o_feed_manure_applied
    ),
    by = .I
  ]

  feed_emissions_detailed[
    ,
    diet_n2o_feed_crop_residues := calc_diet_n2o_feed_crop_residues(
      feed_ration_fraction = feed_ration_fraction,
      n2o_feed_crop_residues = n2o_feed_crop_residues
    ),
    by = .I
  ]

  feed_emissions_detailed[
    ,
    diet_ch4_feed_rice := calc_diet_ch4_feed_rice(
      feed_ration_fraction = feed_ration_fraction,
      ch4_feed_rice = ch4_feed_rice
    ),
    by = .I
  ]

  # --- Step 5: Summarize dietary emissions at cohort level --------------------
  feed_emissions_summary <- feed_emissions_detailed[
    ,
    .(
      diet_co2_feed_fertilizer = sum(diet_co2_feed_fertilizer, na.rm = TRUE),
      diet_co2_feed_pesticides = sum(diet_co2_feed_pesticides, na.rm = TRUE),
      diet_co2_feed_crop_operations = sum(diet_co2_feed_crop_operations, na.rm = TRUE),
      diet_co2_feed_luc_nopeat = sum(diet_co2_feed_luc_nopeat, na.rm = TRUE),
      diet_co2_feed_luc_peat = sum(diet_co2_feed_luc_peat, na.rm = TRUE),
      diet_n2o_feed_fertilizer = sum(diet_n2o_feed_fertilizer, na.rm = TRUE),
      diet_n2o_feed_manure_applied = sum(diet_n2o_feed_manure_applied, na.rm = TRUE),
      diet_n2o_feed_crop_residues = sum(diet_n2o_feed_crop_residues, na.rm = TRUE),
      diet_ch4_feed_rice = sum(diet_ch4_feed_rice, na.rm = TRUE)
    ),
    by = .(herd_id, animal, cohort_short)
  ]

  # Clear progress indicator if it was shown
  if (show_indicator) {
    cli::cli_status_clear()
    cli::cli_alert_success("Feed emissions aggregation complete.")
  }

  return(feed_emissions_summary)
}
