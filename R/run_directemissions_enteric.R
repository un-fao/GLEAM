#' Run Enteric Methane Direct Emissions (Internal)
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
#' # Load example input from the package and run the simulation
#' input_path <- system.file("extdata/GLEAM_input_directemissions_enteric.csv", package = "gleam")
#' dt <- data.table::fread(input_path)
#' result <- run_directemissions_enteric(dt)
#' head(result[, .(Animal_short, cohort, ym, ch4_enteric)])
#' }
#'
#' @keywords internal
#'
#' @importFrom data.table :=
run_directemissions_enteric <- function(data) {
  # Internal checks
  if (!inherits(data, "data.frame") || nrow(data) == 0) {
    cli::cli_abort("Input must be a non-empty data.frame or data.table.")
  }

  required <- c("Animal_short", "cohort", "diet_dig", "diet_ge", "dmi")
  miss <- setdiff(required, names(data))
  if (length(miss)) {
    cli::cli_abort(c(
      "Missing required columns:" = paste(miss, collapse = ", ")
    ))
  }

  # Compute methane conversion factor (YM)
  data[, ym := compute_methane_conversion_factor(
    animal = Animal_short,
    cohort = cohort,
    diet_dig = diet_dig
  ), by = seq_len(nrow(data))]

  # Compute enteric methane emissions (kg CH4/day)
  data[, ch4_enteric := compute_daily_enteric_emissions(
    animal = Animal_short,
    cohort = cohort,
    ym = ym,
    ch4_mitigation_factor = 1,
    diet_ge = diet_ge,
    dmi = dmi
  ), by = seq_len(nrow(data))]

  return(data)
}
