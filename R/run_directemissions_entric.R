#' Run Enteric Methane Direct Emissions (Internal)
#'
#' Computes daily enteric methane emissions (kg CH4 head^-1 day^-1) for each
#' cohort record by applying species- and cohort-specific methane yield (YM) rules
#' and the CH4 conversion formula. This function is intended for internal workflows
#' and does not perform any file I/O.
#'
#' It adds two columns:
#' - `ym`: Methane conversion factor (% of gross energy intake converted to CH4).
#' - `ch4_enteric`: Daily enteric methane emissions (kg CH4/head/day).
#'
#' Input data must at minimum include the following columns:
#' - `Animal_short`: Species abbreviation (e.g. CTL, BFL, SHP, GTS, PGS, CML, CHK).
#' - `cohort`: Cohort identifier (e.g. FJ, FS, FA, MJ, MS, MA).
#' - `diet_dig`: Diet digestibility (fraction of GE).
#' - `diet_ge`: Gross energy content of the diet (MJ/kg DM).
#' - `dmi`: Dry matter intake (kg DM/head/day).
#' - `afc`: Age at first calving (years, required for some species).
#'
#' @param data A `data.table` with cohort-level nutritional and demographic inputs.
#'
#' @return The same `data.table` with new columns `ym` and `ch4_enteric`.
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

  required <- c("Animal_short", "cohort", "diet_dig", "diet_ge", "dmi", "afc")
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
    diet_ge = diet_ge,
    dmi = dmi,
    afc = afc
  ), by = seq_len(nrow(data))]

  return(data)
}
