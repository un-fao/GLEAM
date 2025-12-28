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
#' @param data data.table. Cohort-level production inputs (per country/animal/LPS) containing milk
#'   yields, fibre production, slaughter characteristics, and classifier columns such as
#'   `animal`, `LPS_short`, and `HerdType_short`.
#' @param lactose_lookup data.table. Lookup table mapping `Animal_short` to lactose percentage values
#'   in column `Value`.
#' @param assessment_duration Numeric. Number of assessment days used to annualise production outputs.
#'   Defaults to `365`.
#' @param standard_lactose Numeric. Reference lactose fraction used for FPCM energy calculations.
#'   Defaults to `0.048` (reflecting IDF 2022 guidance).
#'
#' @return data.table. The input data with appended milk, fibre, and meat production columns.
#'
#' @examples
#' \dontrun{
#' input_path <- system.file("extdata/GLEAM_input_production.csv", package = "gleam")
#' data <- data.table::fread(input_path)
#' lactose_lookup <- data.table::fread(
#'   system.file("extdata/GLEAM_MilkDefault_LactoseContent.csv", package = "gleam")
#' )
#' run_production_cohort(data, lactose_lookup)
#' }
#'
#' @keywords internal
#'
#' @importFrom data.table := .I
run_production_cohort <- function(
    data,
    lactose_lookup,
    assessment_duration = 365,
    standard_lactose = 0.048
) {
  # --- Step 1: Validate inputs -------------------------------------------------
  if (!inherits(data, "data.frame") || nrow(data) == 0) {
    cli::cli_abort("Input must be a non-empty data.frame or data.table.")
  }

  if (!data.table::is.data.table(lactose_lookup) || nrow(lactose_lookup) == 0) {
    cli::cli_abort("{.arg lactose_lookup} must be a non-empty data.table.")
  }

  required_data <- unique(c(
    "Animal_short", "cohort", "milk_yield", "size", "milking_fraction",
    "milk_protein", "milk_fat", "fibre_prod", "offtake_number",
    "slaughter_weight", "carcass_dressing_percentage",
    "bone_free_meat_fraction", "meat_protein"
  ))
  miss_data <- setdiff(required_data, names(data))
  if (length(miss_data)) {
    cli::cli_abort("Missing required columns in {.arg data}: {miss_data}.")
  }

  if (!"Animal_short" %in% names(lactose_lookup) || !"Value" %in% names(lactose_lookup)) {
    cli::cli_abort("{.arg lactose_lookup} must contain columns {.field Animal_short} and {.field Value}.")
  }

  validate_scalar_numeric(assessment_duration, "assessment_duration")
  validate_scalar_numeric(standard_lactose, "standard_lactose")

  # --- Step 1.5: Lookup lactose content for each animal ------------------------
  # Merge lactose lookup table (convert percentage to fraction)
  lactose_lookup_fraction <- lactose_lookup
  lactose_lookup_fraction[, Value := Value / 100]

  data <- merge(
    data,
    lactose_lookup_fraction[, .(Animal_short, lactose = Value)],
    by = "Animal_short",
    all.x = TRUE
  )

  # Fill missing values with standard lactose
  data[is.na(lactose), lactose := standard_lactose]

  # --- Step 2: Compute milk production outputs --------------------------------
  milk_output_cols <- c(
    "output_milk_mass_production",
    "output_milk_protein_production",
    "output_milk_fpcm_production"
  )

  # Standard composition constants reflect IDF 2022 guidance and must remain fixed to
  # reproduce the historical FPCM values distributed with GLEAM.
  data[ , (milk_output_cols) := compute_milk_outputs(
    milk_yield = milk_yield,
    assessment_duration = assessment_duration,
    size = size,
    milking_fraction = milking_fraction,
    milk_protein = milk_protein,
    milk_fat = milk_fat,
    lactose = lactose,
    standard_protein = 0.033,
    standard_fat = 0.04,
    standard_lactose = standard_lactose
  ),
  by = .I
  ]

  # Clean up temporary lactose column
  data[, lactose := NULL]

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
    offtake_number = offtake_number,
    slaughter_weight = slaughter_weight,
    carcass_dressing_percentage = carcass_dressing_percentage,
    bone_free_meat_fraction = bone_free_meat_fraction,
    meat_protein = meat_protein
  ),
  by = .I
  ]

  return(data)
}
