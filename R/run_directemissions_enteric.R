#' Run Enteric Methane (CH₄) Direct Emissions
#'
#' Computes daily enteric methane emissions by cohort (kg CH₄/head/day) using a Tier 2
#'  IPCC approach, by applying species-, cohort- and diet-specific methane
#'  conversion factors (ym).
#'
#' @param cohort_level_data data.table. Cohort-level input table with the following data requirement:
#'   \describe{
#'     \item{herd_id}{Character. Unique identifier for the herd, repeated for each cohort belonging to the same herd.}
#'     \item{animal}{Character. Livestock category name used to map to a species short code via an
#'       internal lookup table. Supported values include:
#'       \itemize{
#'         \item \code{Cattle}
#'         \item \code{Buffalo}
#'         \item \code{Sheep}
#'         \item \code{Goats}
#'         \item \code{Chicken}
#'         \item \code{Pigs}
#'         \item \code{Camels}
#'       }}
#'     \item{cohort_short}{Character. Sex- and age-specific cohort code describing the production stage
#'       of the animals. Supported values include:
#'       \itemize{
#'         \item \code{FA}: adult females (from age at first parturition)
#'         \item \code{FS}: sub-adult females (from weaning to age at first parturition)
#'         \item \code{FJ}: juvenile females (from birth to weaning)
#'         \item \code{MA}: adult males (from age at first breeding)
#'         \item \code{MS}: sub-adult males (from weaning to age at first breeding)
#'         \item \code{MJ}: juvenile males (from birth to weaning)
#'       }}
#'     \item{diet_digestibility_fraction}{Numeric. Average digestibility of the the feed ration, expressed as
#'     ratio of digestible (or metabolizable, for poultry) to gross energy content (fraction).}
#'     \item{diet_gross_energy}{Numeric. Average gross energy content of the diet (MJ/kg DM).}
#'     \item{dry_matter_intake}{Numeric. Average daily dry matter intake of feed (kg DM/head/day).}
#'     \item{ch4_mitigation_factor}{Numeric. Optional. Multiplicative mitigation factor applied to
#'     baseline enteric methane (CH₄) emissions (dimensionless). If not provided, a default
#'     value of \code{1} (no mitigation) is used. Values lower than 1 represent proportional
#'     reductions (e.g., \code{0.90} = 10% reduction). This factor can represent mitigation
#'     measures with a direct effect on enteric methane emissions, such as the use of feed
#'     additives or methane inhibitors.}
#'   }
#'
#' @param show_indicator Logical. Whether to display progress indicators during calculations.
#'   Defaults to \code{TRUE}.
#'
#' @return A \code{data.table} with the original input columns plus the following new variables:
#'   \describe{
#'   \item{ch4_mitigation_factor}{Added by the function if not provided as input.}
#'     \item{ch4_conversion_factor_ym}{Numeric. Methane (CH₄) conversion factor (ym),
#'     representing the percentage of  gross energy of the feed ration that is converted to CH₄ (percentage).}
#'     \item{ch4_enteric}{Numeric. Average daily enteric methane (CH₄) emissions (kg CH₄/head/day).}
#'   }
#'
#' @details
#' This function performs the following calculation sequence:
#' \enumerate{
#'   \item If \code{ch4_mitigation_factor} is not provided in the input data, it is set to \code{1} (no mitigation).
#'   \item The methane conversion factor (ym) is computed using \code{\link{compute_methane_conversion_factor}}.
#'   \item Daily enteric methane emissions are computed using \code{\link{compute_daily_enteric_emissions}}.
#' }
#'
#' @seealso
#' \code{\link{compute_methane_conversion_factor}},
#' \code{\link{compute_daily_enteric_emissions}}
#'
#'
#' IPCC. (2019).
#' \emph{2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories}.
#' Chapter 10: Emissions from Livestock and Manure Management, Equation 10.21.
#'
#' IPCC. (2006).
#' \emph{2006 IPCC Guidelines for National Greenhouse Gas Inventories}.
#' Chapter 10: Emissions from Livestock and Manure Management, Equation 10.21.
#'
#' @examples
#' \dontrun{
#' # Load example input (6 herd_ids, cohort-level; only required columns)
#' input_path <- system.file(
#'   "extdata/run_modules_examples/directemissions_enteric_input_chrt_data.csv",
#'   package = "gleam"
#' )
#' directemissions_enteric_input_chrt_data <- data.table::fread(input_path)
#' results <- run_directemissions_enteric(
#' cohort_level_data = directemissions_enteric_input_chrt_data
#' )
#' }
#'
#' @importFrom data.table :=
run_directemissions_enteric <- function(
    cohort_level_data,
    show_indicator = TRUE
) {

  # --- Step 1: Validate inputs ------------------------------------------------
  validate_run_directemissions_enteric_inputs(cohort_level_data)

  # Show progress indicator if requested
  if (show_indicator) {
    cli::cli_status("\U1F552 Calculating enteric methane emissions, please wait\U2026")
  }

  # --- Step 2: Create working copy --------------------------------------------
  enteric_results <- data.table::copy(cohort_level_data)

  # --- Step 3: Map full animal names to species_short -------------------------
  enteric_results <- merge(
    enteric_results,
    abbr_animals,
    by = "animal",
    all.x = TRUE
  )

  # Use mitigation factor from data if present; otherwise default to 1.
  if (!"ch4_mitigation_factor" %in% names(enteric_results)) {
    enteric_results[, ch4_mitigation_factor := 1]
  }

  # --- Step 4: Compute methane conversion factor (ym) -------------------------
  enteric_results[
    ,
    ch4_conversion_factor_ym := compute_methane_conversion_factor(
      species_short = species_short,
      cohort_short = cohort_short,
      diet_digestibility_fraction = diet_digestibility_fraction
    ),
    by = .I
  ]

  # --- Step 5: Compute enteric methane emissions (kg CH4/head/day) ------------
  enteric_results[
    ,
    ch4_enteric := compute_daily_enteric_emissions(
      species_short = species_short,
      ch4_conversion_factor_ym = ch4_conversion_factor_ym,
      ch4_mitigation_factor = ch4_mitigation_factor,
      diet_gross_energy = diet_gross_energy,
      dry_matter_intake = dry_matter_intake
    ),
    by = .I
  ]

  # Clear progress indicator if it was shown
  if (show_indicator) {
    cli::cli_status_clear()
    cli::cli_alert_success("Enteric methane emissions calculation complete.")
  }

  # Drop species_short (internal scientific layer only, never user-facing)
  enteric_results[, species_short := NULL]

  return(enteric_results)
}
