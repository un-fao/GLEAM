#' Run diet greenhouse gas (GHG) emissions factor calculation
#'
#' Computes cohort-level greenhouse gas (GHG) emissions from feed production by
#' weighting feed item emission factors by diet composition (`feed_ration_fraction`).
#' Returns the average feed-production GHG emission factors of the diet by gas and source for each cohort.
#'
#' @param rations_share A `data.table` with feed shares by cohort. Must include:
#'   \describe{
#'   \item{herd_id}{Character. Unique identifier for the herd, repeated for each cohort belonging to the same herd.}
#'   \item{animal}{Character. Code identifying the livestock species.
#'   Supported values include:
#'   \itemize{
#'     \item \code{PGS}: pigs
#'     \item \code{CML}: camels
#'     \item \code{CTL}: cattle
#'     \item \code{BFL}: buffalo
#'     \item \code{SHP}: sheep
#'     \item \code{GTS}: goats
#'   }}
#'   \item{cohort_short}{Character scalar. Sex- and age-specific cohort code describing the
#'   production stage of the animals. Supported values include:
#'   \itemize{
#'     \item \code{FA}: adult females (from age at first parturition)
#'     \item \code{FS}: sub-adult females (from weaning to age at first parturition)
#'     \item \code{FJ}: juvenile females (from birth to weaning)
#'     \item \code{MA}: adult males (from age at first breeding)
#'     \item \code{MS}: sub-adult males (from weaning to age at first breeding)
#'     \item \code{MJ}: juvenile males (from birth to weaning)
#'   }}
#'   \item{feed_id}{Character. Unique identifier for the feed item.}
#'   \item{feed_name}{Character. Name of the feed item.}
#'   \item{feed_ration_fraction}{Numeric. Proportion of a specific feed item in the total ration, expressed as its fraction of diet dry matter (fraction). Within each herd_id and cohort, proportions should sum to 1.}
#'   }
#'   The following column is optional:
#'   \describe{
#'     \item{category}{Character. Feed category (e.g., cereals, fodder crops, by-products, crop residues, animal products).}
#'   }
#'
#' @param feed_emissions A `data.table` with feed item emission factors. Must include:
#'   \describe{
#'   \item{feed_id}{Character. Unique identifier for the feed item.}
#'   \item{feed_name}{Character. Name of the feed item.}
#'   \item{co2_feed_fertilizer}{Numeric. Carbon dioxide (CO₂) emission factor from fertilizer use in feed production, calculated per kg of dry matter intake (g CO₂/kg DM).}
#'   \item{co2_feed_pesticides}{Numeric. Carbon dioxide (CO₂) emission factor from pesticide use in feed production, calculated per kg of dry matter intake (g CO₂/kg DM).}
#'   \item{co2_feed_crop_operations}{Numeric. Carbon dioxide (CO₂) emission factor from land-use change excluding peat in feed production, calculated per kg of dry matter intake (g CO₂/kg DM).}
#'   \item{co2_feed_luc_nopeat}{Numeric. Carbon dioxide (CO₂) emission factor from land-use change excluding peat in feed production, calculated per kg of dry matter intake (g CO₂/kg DM).}
#'   \item{co2_feed_luc_peat}{Numeric. Carbon dioxide (CO₂) emission factor from peatland land-use change in feed production, calculated per kg of dry matter intake (g CO₂/kg DM).}
#'   \item{n2o_feed_fertilizer}{Numeric. Nitrous oxide (N₂O) emission factor from fertilizer use in feed production, calculated per kg of dry matter intake (g N₂O/kg DM).}
#'   \item{n2o_feed_manure_applied}{Numeric. Nitrous oxide (N₂O) emission factor from manure applied to cropland in feed production, calculated per kg of dry matter intake (g N₂O/kg DM).}
#'   \item{n2o_feed_crop_residues}{Numeric. Nitrous oxide (N₂O) emission factor from crop residues in feed production, calculated per kg of dry matter intake (g N₂O/kg DM).}
#'   \item{ch4_feed_rice}{Numeric. Methane (CH₄) emission factor from rice cultivation in feed production, calculated per kg of dry matter intake (g CH₄/kg DM).}
#'   }
#'   The following column is optional:
#'   \describe{
#'     \item{category}{Character. Feed category (e.g., cereals, fodder crops, by-products, crop residues, animal products).}
#'   }
#'
#'#' @return A `data.table` summarized at the cohort level with the following columns:
#'   \describe{
#'     \item{diet_co2_feed_fertilizer}{
#'       Numeric. Average carbon dioxide (CO₂) emission factor from fertilizer use in feed production of the diet (g CO₂/kg DM).
#'     }
#'     \item{diet_co2_feed_pesticides}{
#'       Numeric. Average carbon dioxide (CO₂) emission factor from pesticide use in feed production of the diet (g CO₂/kg DM).
#'     }
#'     \item{diet_co2_feed_crop_operations}{
#'       Numeric. Average carbon dioxide (CO₂) emission factor from crop operations in feed production of the diet (g CO₂/kg DM).
#'     }
#'     \item{diet_co2_feed_luc_nopeat}{
#'       Numeric. Average carbon dioxide (CO₂) emission factor from land‑use change excluding peat in feed production of the diet (g CO₂/kg DM).
#'     }
#'     \item{diet_co2_feed_luc_peat}{
#'       Numeric. Average carbon dioxide (CO₂) emission factor from peatland land‑use change in feed production of the diet (g CO₂/kg DM).
#'     }
#'     \item{diet_n2o_feed_fertilizer}{
#'       Numeric. Average nitrous oxide (N₂O) emission factor from fertilizer use in feed production of the diet (g N₂O/kg DM).
#'     }
#'     \item{diet_n2o_feed_manure_applied}{
#'       Numeric. Average nitrous oxide (N₂O) emission factor from manure applied to cropland in feed production of the diet (g N₂O/kg DM).
#'     }
#'     \item{diet_n2o_feed_crop_residues}{
#'       Numeric. Average nitrous oxide (N₂O) emission factor from crop residues in feed production of the diet (g N₂O/kg DM).
#'     }
#'     \item{diet_ch4_feed_rice}{
#'       Numeric. Average methane (CH₄) emission factor from rice cultivation in feed production of the diet (g CH₄/kg DM).
#'     }
#'   }
#'   
#' @details
#' The function computes greenhouse gas (GHG) emissions from feed production by
#' weighting feed-specific emission factors by their share in the diet
#' (`feed_ration_fraction`). Each emission factor corresponds to a specific
#' source.
#'
#' For each feed item \(i\), the contribution of a given emission source is:
#'
#' \deqn{
#'   \text{diet\_ghg\_component}_{i} =
#'     \text{feed\_ration\_fraction}_{i}
#'     \times
#'     \text{emission\_factor}_{i,\text{source}}
#' }
#'
#' Cohort-level dietary emission factors are obtained by summing contributions
#' across all feed items in the cohort:
#'
#' \deqn{
#'   \text{diet\_ghg\_component} =
#'     \sum_{i=1}^{n}
#'       \left(
#'         \text{feed\_ration\_fraction}_{i}
#'         \times
#'         \text{emission\_factor}_{i,\text{source}}
#'       \right)
#' }
#'
#' @examples
#' \dontrun{
#' # Load cleaned example input from the package and compute the calculation of feed emission factors
#' 
#' # Load table with feed emission factors
#' feed_emissions <- data.table::fread(
#'   system.file("extdata/Parameters/feed/feed_emission_factors.csv", package = "gleam")
#' )
#'
#' # Load table with ration shares
#' rations_share <- data.table::fread(
#'   system.file("extdata/examples/feed_rations_share_example.csv", package = "gleam")
#' )
#'
#' # Run the code
#' result <- run_feed_emissions(rations_share, feed_emissions)
#' }
#' @export

run_feed_emissions <- function(
    rations_share,
    feed_emissions
) {
  # --- Step 1: Validate inputs ------------------------------------------------
  validate_feed_indirect_emissions_inputs(rations_share, feed_emissions)
  
  rations_share <- data.table::copy(rations_share)
  feed_emissions <- data.table::copy(feed_emissions)
  
  # --- Step 2: Merge ration shares with feed emission parameters ---------------
  feed_emissions_detailed <- merge(
    rations_share, feed_emissions,
    by = "feed_id", all.x = TRUE
  )
  
  # --- Step 3: Calculate cohort feed contributions ----------------------------
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
  
  # --- Step 4: Summarize dietary emissions at cohort level --------------------
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
  
  return(feed_emissions_summary)
}
