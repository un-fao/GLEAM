#' Run Production Cohort (Internal)
#'
#' Drives the production cohort workflow to translate cohort-level herd inputs into
#' annualised milk, fibre, and meat outputs for each table row. The routine validates
#' the source tables, computes the three production streams with the core helpers, and
#' writes the derived columns back into the supplied data.table as an output.
#'
#' Input data must be loaded beforehand. Package examples live under `inst/extdata` and can
#' be accessed via [system.file()] together with [data.table::fread()].
#'
#' @param data data.table. Cohort-level production inputs (per country/animal/LPS) containing:
#'
#' - `size`: Numeric. Population size in each of the 6 sex–age cohorts at the start of the year (# heads). (cohorts=FJ, FS, FA, MJ, MS, MA)
#'
#' #' **Milk production**
#' - `milk_yield`: Numeric. Average milk yield per milk-producing animal during the assessment duration (kg/head/day).
#' - `milking_fraction`: Numeric. Share of adult females lactating within the assessment duration. Applies to species = CML, CTL, BFL, SHP, GTS. (fraction).
#' - `milk_protein`: Numeric. Milk protein fraction (kg protein/kg milk).
#' - `milk_fat`: Numeric. Milk fat fraction (kg fat/kg milk).
#' - `lactose`: Numeric. Milk lactose fraction (kg lactose/kg milk).
#'
#' **Fibre production**
#' - `fibre_prod`: Numeric. Annual production yield of fibre, such as wool, cashmere, mohair (kg/head/year).
#'
#' **Meat production**
#' - `offtake_number_assessment`: Numeric. Total number of animals removed via offtake over the assessment period, aggregated to 6 sex–age cohorts (cohorts = FJ, FS, FA, MJ, MS, MA) (heads/year)
#' - `slaughter_weight`: Numeric. Live weight at slaughter for animals removed from the cohort (kg).
#' - `carcass_dressing_percentage`: Numeric. Ratio of a slaughtered animal's carcass weight to its live weight (fraction).
#' - `bone_free_meat_fraction`: Numeric. Ratio of bone-free-meat to carcass weight (fraction).
#' - `meat_protein`: Numeric. Protein content of bone-free-meat (fraction).
#'
#' @param assessment_duration Numeric. Length of the assessment period (days).
#'
#' @return data.table.  The input data with the following columns appended:
#'
#' **Milk production outputs**
#' - `output_milk_mass_production`
#'   Total milk produced over the assessment period (kg milk / cohort / assessment period).
#'
#' - `output_milk_protein_production`
#'   Total milk protein produced over the assessment period  (kg protein / cohort / assessment period).
#'
#' - `output_milk_fpcm_production`
#'   Total fat-protein-corrected milk (FPCM) produced over the assessment period, calculated using IDF (2022) energy-based correction with standard composition
#'   (kg FPCM / cohort / assessment period).
#'
#' **Fibre production outputs**
#' - `output_fibre_production`
#'   Total fibre produced over the assessment period
#'   (kg fibre / cohort / assessment period).
#'
#' **Meat production outputs**
#' - `output_meat_production_liveweight`
#'   Total meat produced expressed as live weight removed via offtake
#'   (kg live weight / cohort / assessment period).
#'
#' - `output_meat_production_carcassweight`
#'   Total carcass weight produced after dressing
#'   (kg carcass weight / cohort / assessment period).
#'
#' - `output_meat_production_meat`
#'   Total bone-free meat produced
#'   (kg meat / cohort / assessment period).
#'
#' - `output_meat_production_protein`
#'   Total meat protein produced
#'   (kg protein / cohort / assessment period).
#'
#' @examples
#' \dontrun{
#' input_path <- system.file("extdata/GLEAM_input_production.csv", package = "gleam")
#' data <- data.table::fread(input_path)
#'
#' run_production_cohort(data)
#' }
#'
#' @keywords internal
#'
#' @importFrom data.table := .I
run_production_cohort <- function(
    data,
    assessment_duration = 365
) {
  # --- Step 1: Validate inputs -------------------------------------------------
  if (!inherits(data, "data.frame") || nrow(data) == 0) {
    cli::cli_abort("Input must be a non-empty data.frame or data.table.")
  }

  required_data <- unique(c(
    "Animal_short", "cohort", "milk_yield", "size", "milking_fraction",
    "milk_protein", "milk_fat", "fibre_prod", "offtake_number_assessment",
    "slaughter_weight", "carcass_dressing_percentage",
    "bone_free_meat_fraction", "meat_protein"
  ))
  miss_data <- setdiff(required_data, names(data))
  if (length(miss_data)) {
    cli::cli_abort("Missing required columns in {.arg data}: {miss_data}.")
  }


  validate_scalar_numeric(assessment_duration, "assessment_duration")

  # --- Step 2: Compute milk production outputs --------------------------------
  milk_output_cols <- c(
    "output_milk_mass_production",
    "output_milk_protein_production",
    "output_milk_fpcm_production"
  )

  # Standard composition constants reflect IDF 2022 guidance and must remain fixed to
  # reproduce the historical FPCM values distributed with GLEAM.
  data[ , (milk_output_cols) := compute_milk_outputs(
    cohort = cohort,
    milk_yield = milk_yield,
    assessment_duration = assessment_duration,
    size = size,
    milking_fraction = milking_fraction,
    milk_protein = milk_protein,
    milk_fat = milk_fat,
    lactose = lactose,
    standard_protein = 0.033,
    standard_fat = 0.04,
    standard_lactose = 0.048
  ),
  by = .I
  ]


  # --- Step 3: Aggregate fibre production ------------------------------------
  # The downstream energy requirements module expects annual fibre tonnage at the cohort level.
  data[ , output_fibre_production := compute_fibre_output(
    fibre_prod = fibre_prod,
    assessment_duration = assessment_duration,
    size = size
  ),
  by = .I
  ]

  # --- Step 4: Compute meat production outputs --------------------------------
  meat_output_cols <- c(
    "output_meat_production_liveweight",
    "output_meat_production_carcassweight",
    "output_meat_production_meat",
    "output_meat_production_protein"
  )

  data[ , (meat_output_cols) := compute_meat_outputs(
    offtake_number_assessment = offtake_number_assessment,
    slaughter_weight = slaughter_weight,
    carcass_dressing_percentage = carcass_dressing_percentage,
    bone_free_meat_fraction = bone_free_meat_fraction,
    meat_protein = meat_protein
  ),
  by = .I
  ]

  return(data)
}
