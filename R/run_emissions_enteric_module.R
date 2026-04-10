#' Run Enteric Methane (CH4) Emissions Module Pipeline
#'
#' Calculates daily enteric methane emissions by cohort (kg CH4/head/day) using a Tier 2
#'  IPCC approach, by applying species-, cohort- and diet-specific methane
#'  conversion factors (ym).
#'
#' @param cohort_level_data data.table. Cohort-level input table with the following data requirement:
#'   \describe{
#'     \item{herd_id}{Character. Unique identifier for the herd, repeated for each cohort belonging to the same herd.}
#'     \item{species_short}{Character. Code identifying the livestock species.
#'         Supported values include:
#'         \itemize{
#'         \item \code{PGS}: pigs
#'         \item \code{CML}: camels
#'         \item \code{CTL}: cattle
#'         \item \code{BFL}: buffalo
#'         \item \code{SHP}: sheep
#'         \item \code{GTS}: goats
#'         }}
#'     \item{cohort_short}{Character. Sex- and age-specific cohort code describing the production stage
#'       of the animals. Supported values include:
#'       \itemize{
#'         \item \code{FA}: adult females (from age at first parturition)
#'         \item \code{FS}: sub-adult females (from weaning to age at first parturition)
#'         \item \code{FJ}: juvenile females (from birth to weaning)
#'         \item \code{FN}: non-demographic females
#'         \item \code{MA}: adult males (from age at first breeding)
#'         \item \code{MS}: sub-adult males (from weaning to age at first breeding)
#'         \item \code{MJ}: juvenile males (from birth to weaning)
#'         \item \code{MN}: non-demographic males
#'       }}
#'     \item{nondemo_productive_phase_id}{Numeric. Optional productive phase identifier
#'     for non-demographic cohorts (\code{FN}, \code{MN}). When present, enteric
#'     methane emissions are computed and retained separately by phase.}
#'     \item{ration_digestibility_fraction}{Numeric. Average digestibility of the feed ration, expressed as
#'     ratio of digestible (or metabolizable, for poultry) to gross energy content (fraction).}
#'     \item{ration_gross_energy}{Numeric. Average gross energy content of the diet (MJ/kg DM).}
#'     \item{ration_intake}{Numeric. Average daily dry matter intake of feed (kg DM/head/day).}
#'     \item{ch4_mitigation_factor}{Numeric. Optional. Multiplicative mitigation factor applied to
#'     baseline enteric methane (CH4) emissions (dimensionless). If not provided, a default
#'     value of \code{1} (no mitigation) is used. Values lower than 1 represent proportional
#'     reductions (e.g., \code{0.90} = 10% reduction). This factor can represent mitigation
#'     measures with a direct effect on enteric methane emissions, such as the use of feed
#'     additives or methane inhibitors.}
#'   }
#'
#' @param show_indicator Logical. Whether to display progress indicators during calculations.
#'   Defaults to \code{TRUE}.
#'
#' @return A \code{data.table} with the original input columns plus the following
#'   new variables. If \code{nondemo_productive_phase_id} is present in the input,
#'   the returned table preserves phase-specific rows for \code{FN} and \code{MN}:
#'   \describe{
#'   \item{ch4_mitigation_factor}{Added by the function if not provided as input.}
#'     \item{ch4_conversion_factor_ym}{Numeric. Methane (CH4) conversion factor (ym),
#'     representing the percentage of  gross energy of the feed ration that is converted to CH4 (percentage).}
#'     \item{ch4_enteric}{Numeric. Average daily enteric methane (CH4) emissions (kg CH4/head/day).}
#'   }
#'
#' @details
#' This function represents the intermediate module of the Global Livestock Environmental
#' Assessment Model (GLEAM) computational pipeline [run_gleam()] to estimate enteric methane
#' emissions and performs the following calculation sequence:
#' \enumerate{
#'   \item If \code{ch4_mitigation_factor} is not provided in the input data, it is set to \code{1} (no mitigation).
#'   \item The methane conversion factor (ym) is computed using \code{\link{calc_conversion_factor_ym}}.
#'   \item Daily enteric methane emissions are computed using \code{\link{calc_ch4_enteric}}.
#' }
#'
#' @seealso
#' \code{\link{run_gleam}},
#' \code{\link{calc_conversion_factor_ym}},
#' \code{\link{calc_ch4_enteric}}
#'
#'@references
#' IPCC. (2019).
#' \emph{2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories}.
#' Chapter 10: Emissions from Livestock and Manure Management, Equation 10.21.
#'
#' IPCC. (2006).
#' \emph{2006 IPCC Guidelines for National Greenhouse Gas Inventories}.
#' Chapter 10: Emissions from Livestock and Manure Management, Equation 10.21.
#'
#' @examples
#' \donttest{
#' # Load example input (6 herd_ids, cohort-level; only required columns)
#' input_path <- system.file(
#'   "extdata/run_modules_examples/emissions_enteric_input_chrt_data.csv",
#'   package = "gleam"
#' )
#' emissions_enteric_input_chrt_data <- data.table::fread(input_path)
#' results <- run_emissions_enteric_module(
#' cohort_level_data = emissions_enteric_input_chrt_data
#' )
#' }
#'
#' @export
#'
#' @importFrom data.table :=
run_emissions_enteric_module <- function(
    cohort_level_data,
    show_indicator = TRUE
) {

  # --- Step 1: Validate inputs ------------------------------------------------
  validate_run_emissions_enteric_module_inputs(cohort_level_data)

  # Show progress indicator if requested
  if (show_indicator) {
    cli::cli_status("\U1F552 Calculating enteric methane emissions, please wait\U2026")
  }

  # --- Step 2: Create working copy --------------------------------------------
  enteric_results <- data.table::copy(cohort_level_data)

  # Use mitigation factor from data if present; otherwise default to 1.
  if (!"ch4_mitigation_factor" %in% names(enteric_results)) {
    enteric_results[, ch4_mitigation_factor := 1]
  }

  # --- Step 3: Compute methane conversion factor (ym) -------------------------
  enteric_results[
    ,
    ch4_conversion_factor_ym := calc_conversion_factor_ym(
      species_short = species_short,
      cohort_short = cohort_short,
      ration_digestibility_fraction = ration_digestibility_fraction
    ),
    by = .I
  ]

  # --- Step 4: Compute enteric methane emissions (kg CH4/head/day) ------------
  enteric_results[
    ,
    ch4_enteric := calc_ch4_enteric(
      species_short = species_short,
      ch4_conversion_factor_ym = ch4_conversion_factor_ym,
      ch4_mitigation_factor = ch4_mitigation_factor,
      ration_gross_energy = ration_gross_energy,
      ration_intake = ration_intake
    ),
    by = .I
  ]

  # Clear progress indicator if it was shown
  if (show_indicator) {
    cli::cli_status_clear()
    cli::cli_alert_success("Enteric methane emissions calculation complete.")
  }

  return(enteric_results)
}
