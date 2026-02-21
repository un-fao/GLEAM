#' Run Enteric Methane Direct Emissions
#'
#' Computes daily enteric methane emissions (kg CH₄/head/day) for each
#' cohort record by applying species-, cohort- and diet- specific methane conversion factors (ym),
#' using a Tier 2 approach (IPCC 2006, 2019)
#'
#' This function is intended for internal workflows and does not perform any file I/O.
#'
#' It adds two columns:
#' - `ym`: Numeric. Methane conversion factor (ym), representing the percentage of gross energy of the feed ration that is converted to CH₄ (percentage).
#' - `ch4_enteric`: Numeric. Average daily enteric methane emissions (kg CH₄/head/day).
#'
#' Input data must at minimum include the following columns:
#' param animal Character. Code identifying the livestock species.
#'   Supported values include:
#'   \itemize{
#'     \item \code{PGS}: pigs
#'     \item \code{CML}: camels
#'     \item \code{CTL}: cattle
#'     \item \code{BFL}: buffalo
#'     \item \code{SHP}: sheep
#'     \item \code{GTS}: goats
#'   }
#'
#' param cohort Character Sex- and age-specific cohort code describing the
#'   production stage of the animals. Supported values include:
#'   \itemize{
#'     \item \code{FA}: adult females (from age at first parturition)
#'     \item \code{FS}: sub-adult females (from weaning to age at first parturition)
#'     \item \code{FJ}: juvenile females (from birth to weaning)
#'     \item \code{MA}: adult males (from age at first breeding)
#'     \item \code{MS}: sub-adult males (from weaning to age at first breeding)
#'     \item \code{MJ}: juvenile males (from birth to weaning)
#'   }
#' - `diet_dig`: Numeric. Average digestibility of the the feed ration, expressed as ratio of digestible to gross energy content (fraction)
#' - `diet_ge`: Numeric. Average gross energy content of the diet (MJ/kg DM).
#' - `dmi`: Numeric. Daily dry matter intake of feed (kg DM/head/day).
#'
#' Optional input data include:
#' - `ch4_mitigation_factor`: Numeric. Dimensionless fraction of baseline enteric methane emissions remaining after mitigation. Applied as a
#' multiplicative factor to calculated emissions (1 = no mitigation, 0.9 = 10% reduction). Set to 1 by default.
#'
#' @param data A `data.table` with cohort-level nutritional and demographic inputs.
#' @param show_indicator Logical. Whether to display progress indicators during calculations.
#'
#' @return The same `data.table` with new columns `ym` and `ch4_enteric`.
#'
#' IPCC. (2019). *2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories*, Chapter 10: Emissions from
#' Livestock and Manure Management, Equation 10.21.
#'
#' IPCC. (2006). *2006 IPCC Guidelines for National Greenhouse Gas Inventories*, Chapter 10: Emissions from
#' Livestock and Manure Management, Equation 10.21.
#'
#' @examples
#' \dontrun{
#' # Load example input (6 herd_ids, cohort-level; only required columns)
#' input_path <- system.file(
#'   "extdata/examples/directemissions_enteric_input_chrt_data.csv",
#'   package = "gleam"
#' )
#' directemissions_enteric_input_chrt_data <- data.table::fread(input_path)
#' result <- run_directemissions_enteric(directemissions_enteric_input_chrt_data)
#' head(result[, .(Animal_short, cohort, ym, ch4_enteric)])
#' }
#'
#' @importFrom data.table :=
run_directemissions_enteric <- function(data, show_indicator = TRUE) {

  # --- Step 1: Validate inputs ------------------------------------------------
  validate_run_directemissions_enteric_inputs(data)

  # Show progress indicator if requested
  if (show_indicator) {
    cli::cli_status("\U1F552 Calculating enteric methane emissions, please wait\U2026")
  }

  # --- Step 2: Create working copy --------------------------------------------
  enteric_results <- data.table::copy(data)

  # Use mitigation factor from data if present; otherwise default to 1.
  if (!"ch4_mitigation_factor" %in% names(enteric_results)) {
    enteric_results[, ch4_mitigation_factor := 1]
  }

  # --- Step 3: Compute methane conversion factor (ym) -------------------------
  enteric_results[
    ,
    ym := compute_methane_conversion_factor(
      animal = Animal_short,
      cohort = cohort,
      diet_dig = diet_dig
    )
    , by = .I
  ]

  # --- Step 4: Compute enteric methane emissions (kg CH4/head/day) ------------
  enteric_results[
    ,
    ch4_enteric := compute_daily_enteric_emissions(
      animal = Animal_short,
      ym = ym,
      ch4_mitigation_factor = ch4_mitigation_factor,
      diet_ge = diet_ge,
      dmi = dmi
    )
    , by = .I
  ]

  # Clear progress indicator if it was shown
  if (show_indicator) {
    cli::cli_status_clear()
    cli::cli_alert_success("Enteric methane emissions calculation complete.")
  }

  return(enteric_results)
}
