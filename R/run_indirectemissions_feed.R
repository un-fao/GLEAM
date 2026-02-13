#' Calculate Feed Production GHG Emissions
#'
#' Computes cohort-level CO2, N2O, and CH4 emissions from feed production
#' (fertilizer, pesticides, crop operations, land-use change, manure, residues, rice)
#' based on feed rations and feed emission factors. 
#'
#' @param rations_share A data.table containing feed shares per cohort. Must include:
#'   - `herd_id`, `animal`, `feed_id`, `cohort`, `feed_ration_fraction`.
#' @param feed_emissions A data.table of feed production emission factors expressed as g gas/kg dry matter.
#' Must include:
#'   - `feed_id`,
#'   - `co2_feed_fertilizer`, `co2_feed_pesticides`,
#'   - `co2_feed_crop_operations`, `co2_feed_luc_nopeat`, `co2_feed_luc_peat`,
#'   - `n2o_feed_fertilizer`, `n2o_feed_manure_applied`, `n2o_feed_crop_residues`,
#'   - `ch4_feed_rice`.
#'
#' @return A data.table summarized by `herd_id`, `animal`, and `cohort` with:
#'   - `diet_co2_feed_fertilizer`, `diet_co2_feed_pesticides`,
#'   - `diet_co2_feed_crop_operations`, `diet_co2_feed_luc_nopeat`,
#'   - `diet_co2_feed_luc_peat`,
#'   - `diet_n2o_feed_fertilizer`, `diet_n2o_feed_manure_applied`,
#'   - `diet_n2o_feed_crop_residues`,
#'   - `diet_ch4_feed_rice`
#'
#'
#' @examples
#' \dontrun{
#' # Load cleaned example input from the package and compute feed intake metrics#' 
#' feed_emissions <- data.table::fread(
#'   system.file("extdata/Parameters/feed/feed_emission_factors.csv", package = "gleam")
#' )
#'
#'
#' rations_share <- data.table::fread(
#'   system.file("extdata/examples/feed_rations_share_example.csv", package = "gleam")
#' )
#'
#' result <- run_feed_production_emissions(rations_share, feed_emissions)
#' }
#' @export

run_feed_production_emissions <- function(
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
