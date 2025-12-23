#' Allocation Pipeline (Internal)
#'
#' Computes allocation fractions by calculating cohort energy for meat, milk, fibre, work and summarising to herd level.
#' Returns cohort results, herd totals, and long-form shares for associating emissions with commodities.
#'
#' The function implements biophysical allocation based on energy requirements to produce different products,
#' following the IDF (2022) global carbon footprint standard for the dairy sector.
#'
#' @param allocation_inputs Cohort-level input table provided as data.frame or data.table.
#' @param group_by_keys Character vector that lists the columns used for herd aggregation.
#' @param standard_protein Numeric scalar for reference milk protein content (g per 100 g milk).
#' @param standard_fat Numeric scalar for reference milk fat content (g per 100 g milk).
#' @param standard_lactose Numeric scalar for reference milk lactose content (g per 100 g milk).
#' @param ratio_ne_me_camelids Numeric scalar for the net-to-metabolizable energy conversion for camelids.
#' @param assessment_duration_days Numeric scalar giving the assessment period in days.
#'
#' @return A named list of three `data.table` objects:
#'   * `cohort_energy`: Cohort-level inputs augmented with calculated energy allocations.
#'   * `herd_summary`: Aggregated totals and allocation shares per grouping key.
#'   * `allocation_long`: Long-format representation of allocation shares with commodity labels.
#'
#' @examples
#' \dontrun{
#' # Load example input from the package and run allocation calculation
#' input_path <- system.file("extdata/GLEAM_input_allocation.csv", package = "gleam")
#' allocation_data <- data.table::fread(input_path)
#' result <- run_allocation(allocation_data)
#' # View herd-level allocation shares
#' head(result$herd_summary[, .(Animal_short, allocation_share_meat, allocation_share_milk)])
#' # View long-format allocation
#' head(result$allocation_long)
#' }
#'
#' @keywords internal
#'
#' @importFrom data.table := .I melt patterns fifelse setcolorder
run_allocation <- function(
    allocation_inputs,
    group_by_keys = c(
      "ADM0_CODE",
      "HerdType_short",
      "Animal_short",
      "LPS_short"
    ),
    standard_protein = 0.033,
    standard_fat = 0.04,
    standard_lactose = 0.048,
    ratio_ne_me_camelids = 0.43,
    assessment_duration_days = 365
) {
  # --- Input validation
  # Validate that input is a data.frame with at least one row
  if (!inherits(allocation_inputs, "data.frame") || nrow(allocation_inputs) == 0) {
    cli::cli_abort("Input must be a non-empty data.frame or data.table.")
  }

  # Validate required columns for cohort-level calculations
  required_cohort_columns <- c(
    "Animal_short",
    "cohort",
    "afc",
    "slaughterLW",
    "initialLW",
    "ckg",
    "output_meat_production_liveweight",
    "output_milk_fpcm_production",
    "nefibre",
    "nework"
  )

  required_columns <- unique(c(required_cohort_columns, group_by_keys))
  miss <- setdiff(required_columns, names(allocation_inputs))
  if (length(miss)) {
    cli::cli_abort(c(
      "Missing required columns in input data:" = paste(miss, collapse = ", ")
    ))
  }

  # --- Calculate cohort-level energy allocations
  # Milk energy allocation: based on FPCM (fat- and protein-corrected milk) output
  allocation_inputs[, energy_allocation_milk := calc_energy_allocation_milk(
    milk_fpcm_output = output_milk_fpcm_production,
    standard_protein = standard_protein,
    standard_fat = standard_fat,
    standard_lactose = standard_lactose
  ), by = .I]

  # Meat energy allocation: species- and cohort-specific formulas
  allocation_inputs[, energy_allocation_meat := calc_energy_allocation_meat(
    animal = Animal_short,
    cohort_code = cohort,
    age_first_parturition_years = afc,
    slaughter_liveweight = slaughterLW,
    initial_liveweight = initialLW,
    birth_liveweight = ckg,
    meat_output_liveweight = output_meat_production_liveweight
  ), by = .I]

  # Fibre energy allocation: applies camelid conversion factor when needed
  allocation_inputs[, energy_allocation_fibre := calc_energy_allocation_fibre(
    animal = Animal_short,
    fibre_energy_requirement = nefibre,
    ratio_ne_to_me = ratio_ne_me_camelids,
    assessment_duration = assessment_duration_days
  ), by = .I]

  # Work energy allocation: applies camelid conversion factor when needed
  allocation_inputs[, energy_allocation_work := calc_energy_allocation_work(
    animal = Animal_short,
    work_energy_requirement = nework,
    ratio_ne_to_me = ratio_ne_me_camelids,
    assessment_duration = assessment_duration_days
  ), by = .I]

  # Eggs energy allocation: placeholder (not currently implemented)
  allocation_inputs[, energy_allocation_eggs := 0]

  # --- Aggregate from cohort to herd level
  # Sum energy allocations by grouping keys to get herd-level totals
  allocation_herd <- aggregate_cohort_to_herd(
    data_cohort = allocation_inputs,
    id_cols = c( "ADM0_CODE",
                 "HerdType_short",
                 "Animal_short",
                 "LPS_short"),
    vars_to_sum = c("energy_allocation_meat", 
                    "energy_allocation_milk", 
                    "energy_allocation_fibre",
                    "energy_allocation_work", 
                    "energy_allocation_eggs"),
    cohort = "cohort")
  
  

  # Calculate allocation shares to each commodity
  allocation_herd[
      ,
      c("allocation_share_meat",
        "allocation_share_milk",
        "allocation_share_fibre",
        "allocation_share_work",
        "allocation_share_eggs") :=
        calc_allocation_shares(
          animal = Animal_short,
          energy_allocation_meat  = energy_allocation_meat,
          energy_allocation_milk  = energy_allocation_milk,
          energy_allocation_fibre = energy_allocation_fibre,
          energy_allocation_work  = energy_allocation_work,
          energy_allocation_eggs  = energy_allocation_eggs
        ),
      by = .I
    ]
    
  
  # --- Reshape to long format
  # Convert allocation shares from wide to long format for downstream processing
  # Note: id_vars order matches legacy: ADM0_CODE, Animal_short, LPS_short, HerdType_short
  id_vars_for_melt <- c("ADM0_CODE", "Animal_short", "LPS_short", "HerdType_short")
  # Ensure all id_vars are present in the data
  id_vars_for_melt <- intersect(id_vars_for_melt, names(herd_summary_dt))
  
  allocation_long_dt <- melt(
    herd_summary_dt,
    id.vars = id_vars_for_melt,
    measure.vars = patterns("^allocation_share_"),
      variable.name = "commodity_name",
    value.name = "V1"
    )
    
  # Clean up commodity names: remove prefix and capitalize first letter
  allocation_long_dt[, commodity_name := gsub(
    "^allocation_share_",
    "",
    commodity_name
  )]
  allocation_long_dt[, commodity_name := paste0(
    toupper(substr(commodity_name, 1, 1)),
    substr(commodity_name, 2, nchar(commodity_name))
  )]

  # Classify commodities as edible or non-edible
  edible <- c("Meat", "Milk", "Eggs")
  non_edible <- c("Fibre", "Work")
  allocation_long_dt[, commodity_type := fifelse(
    commodity_name %in% edible,
    "Edible",
    fifelse(
      commodity_name %in% non_edible,
      "NonEdible",
      NA_character_
    )
  )]
    
  # Set column order to match legacy exactly:
  # ADM0_CODE, Animal_short, LPS_short, HerdType_short, commodity_name, commodity_type, V1
  setcolorder(
    allocation_long_dt,
    c(id_vars_for_melt, "commodity_name", "commodity_type", "V1")
  )
    
  # Remove temporary total_allocation_energy column from herd summary
  herd_summary_dt[, total_allocation_energy := NULL]

  # Return list with all three outputs
  list(
    cohort_energy = allocation_inputs,
    herd_summary = herd_summary_dt,
    allocation_long = allocation_long_dt
  )
}