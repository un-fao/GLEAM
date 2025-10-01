#' Run Nitrogen Balance (Internal)
#'
#' Computes cohort-level nitrogen intake, retention, and excretion (kg N/head/day)
#' for each row of input data. This wrapper applies the core nitrogen balance
#' functions to the provided dataset and appends results.
#'
#' Input data must include the columns required by the underlying functions:
#' dmi, diet_nitrogen, Animal_short, cohort, milk_protein, milk_yield,
#' dwg, fibre_prod, litsize, parturition_rate, wkg, ckg, and afc.
#'
#' @param data A `data.table` containing cohort-level inputs for nitrogen balance.
#'
#' @return A `data.table` with three additional columns:
#'   - n_intake: daily nitrogen intake (kg N/head/day)
#'   - n_retention: daily nitrogen retention (kg N/head/day)
#'   - n_excretion: daily nitrogen excretion (kg N/head/day)
#'
#' @examples
#' \dontrun{
#' input_path <- system.file("extdata/GLEAM_input_directemissions_manure.csv", package = "gleam")
#' data <- data.table::fread(input_path)
#' results <- run_nitrogen_balance(data)
#' }
#'
#' @keywords internal
#' @importFrom data.table :=
run_nitrogen_balance <- function(data) {
  # --- Internal checks
  if (!inherits(data, "data.frame") || nrow(data) == 0) {
    cli::cli_abort("Input must be a non-empty data.frame or data.table.")
  }

  required <- c(
    "dmi", "diet_nitrogen", "Animal_short", "cohort", "milk_protein",
    "milk_yield", "dwg", "fibre_prod", "litsize", "parturition_rate",
    "wkg", "ckg", "afc"
  )
  miss <- setdiff(required, names(data))
  if (length(miss)) {
    cli::cli_abort(c(
      "!" = "Missing required columns in input data.",
      "x" = paste(miss, collapse = ", ")
    ))
  }

  # --- Intake: N consumed per head/day
  data[, n_intake := compute_nitrogen_intake(
    dmi = dmi,
    diet_nitrogen = diet_nitrogen
  ), by = .I]

  # --- Retention: N allocated to growth, milk, reproduction, fibre
  data[, n_retention := compute_nitrogen_retention(
    animal = Animal_short,
    cohort = cohort,
    milk_protein = milk_protein,
    milk_yield = milk_yield,
    dwg = dwg,
    fibre_prod = fibre_prod,
    litsize = litsize,
    parturition_rate = parturition_rate,
    wkg = wkg,
    ckg = ckg,
    afc = afc
  ), by = .I]

  # --- Excretion: N lost (intake - retention)
  data[, n_excretion := compute_nitrogen_excretion(
    animal = Animal_short,
    n_intake = n_intake,
    n_retention = n_retention
  ), by = .I]

  return(data)
}
