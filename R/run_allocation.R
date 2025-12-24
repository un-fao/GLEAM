#' Allocation Pipeline (Internal)
#'
#' Computes allocation fractions by calculating cohort energy for meat, milk, fibre, work and summarising to herd level.
#' Returns cohort results, herd totals, and long-form shares for associating emissions with commodities.
#'
#' The function implements biophysical allocation based on energy requirements to produce different products,
#' following the IDF (2022) global carbon footprint standard for the dairy sector.
#'
#' @param allocation_inputs Cohort-level input table provided as data.frame or data.table.
#' @param allocation_type Character vector that defines the allocation methodology in use. Default= "biophysical-energy"
#' @param group_by_keys Character vector that lists the columns used for herd aggregation.
#' @param standard_protein Numeric scalar for reference milk protein content (g per 100 g milk).
#' @param standard_fat Numeric scalar for reference milk fat content (g per 100 g milk).
#' @param standard_lactose Numeric scalar for reference milk lactose content (g per 100 g milk).
#' @param ratio_ne_me_camelids Numeric scalar for the net-to-metabolizable energy conversion for camelids.
#' @param assessment_duration_days Numeric scalar giving the assessment period in days.
#'
#' @return A named list of three `data.table` objects:
#'   * `cohort_allocation_inputs`: Cohort-level inputs to estimate allocation shares at herd-level.
#'   * `allocation_long`: Herd-level, long-format representation of allocation shares with commodity labels.
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
    allocation_type="biophysical-energy", #Temporary here set as default allocation_type. It defines the methodology. At the moment only 1 is implemented, but in future developments other approaches will be implemented.
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
    
  allocation_herd[,allocation_share_other:=NA_real_]
  
  
  # --- Reshape to long format
  # Convert allocation shares from wide to long format for downstream processing
  # Note: id_vars order matches legacy: ADM0_CODE, Animal_short, LPS_short, HerdType_short / 
  # @Yassine: this should be replaced with record ID
  
 
    # Define ID columns
    id_vars <- c("ADM0_CODE", "Animal_short", "LPS_short", "HerdType_short")
    
    # Reshape allocation shares from wide to long
    allocation_herd_long <- melt(
      allocation_herd,
      id.vars = id_vars,
      measure.vars = c("allocation_share_meat",
                       "allocation_share_milk",
                       "allocation_share_fibre",
                       "allocation_share_work",
                       "allocation_share_eggs",
                       "allocation_share_other"),
      variable.name = "commodity_name",
      value.name = "allocation_share"
    )
    
    # Rename the commodity columns 
    rename_map <- c(
      allocation_share_meat  = "Meat",
      allocation_share_milk  = "Milk",
      allocation_share_fibre = "Fibre",
      allocation_share_work  = "Work",
      allocation_share_eggs  = "Eggs",
      allocation_share_other  = "Other"
    )
    
    allocation_herd_long[, commodity_name := rename_map[commodity_name]]
    
    
    # Adding a commodity_type column to group commodity into edible and non-edible
    
    allocation_herd_long[commodity_name %in% c("Meat", "Milk", "Eggs"), commodity_type:="Edible"]
    allocation_herd_long[commodity_name %in% c("Work", "Fibre", "Other"), commodity_type:="Non-Edible"]
    
    
    
    
    # Assigning allocation to emission sources------
    allocation_herd_long_all <- assign_allocation_to_emissions(
      allocation_herd_long = allocation_herd_long,
      emissions_vars = c(
        "ch4_enteric","ch4_manure_pasture","ch4_manure_burned","ch4_manure_other",
        "direct_n2o_manure_pasture","direct_n2o_manure_burned","direct_n2o_manure_other",
        "indirect_n2o_manure_burned","indirect_n2o_manure_pasture","indirect_n2o_manure_other"
      ),
      commodities = c("Other","Milk","Meat","Fibre","Work","Eggs"),
      excluded_vars = c(
        "ch4_manure_pasture","ch4_manure_burned",
        "direct_n2o_manure_pasture","direct_n2o_manure_burned",
        "indirect_n2o_manure_burned","indirect_n2o_manure_pasture"
      ),
      commodity_col   = "commodity_name",
      allocation_col = "allocation_share"
    )
    
    
    allocation_herd_long_all[,allocation_type:=allocation_type]
    
    
  # Return list with all two outputs
  list(
    cohort_allocation_inputs = allocation_inputs,
    allocation_herd_long = allocation_herd_long_all
  )
}
