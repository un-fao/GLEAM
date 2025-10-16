#' Run Indirect Emissions by Feed
#'
#' Computes feed-specific emissions (\eqn{kg\ gas/head/day}) based on dry matter intake (DMI),
#' feed ration composition, and feed emission factors (EFs). The function applies
#' user-specified or default trade preferences to select the appropriate EF for
#' each feed item, merges all inputs coherently, and calculates emissions per feed item.
#'
#' @section Workflow:
#' 1. Validate inputs and select only required columns from each data.table.
#' 2. Merge cohort-level DMI (`gleam_dmi`) with feedbasket composition (`gleam_feedbasket`)
#'    to distribute total DMI across feed items.
#' 3. Construct a full set of trade preferences, applying user overrides if provided.
#' 4. Filter emission factors (`gleam_feedEF`) by trade scenario and feed IDs in use.
#' 5. Merge all inputs and calculate emissions per feed item.
#'
#' @section Column Handling:
#' The function preserves all columns from the input data.tables in the final output,
#' while validating that required columns are present. This ensures the output contains
#' all the same columns as the legacy script while providing flexibility for input data.
#'
#' @param gleam_dmi A `data.table` containing cohort-level dry matter intake data.
#'   Must include columns:
#'   \describe{
#'     \item{ADM0_CODE}{Country code (factor or character).}
#'     \item{Animal_short}{Species abbreviation (e.g. `CTL`, `SHP`).}
#'     \item{HerdType_short}{Herd type abbreviation (e.g. `TL`, `DR`).}
#'     \item{LPS_short}{Livestock production system abbreviation.}
#'     \item{cohort}{Cohort code (e.g. `FA`, `MJ`).}
#'     \item{dmi_total}{Total dry matter intake (kg DM/head/day).}
#'   }
#'   All columns from this data.table will be preserved in the output.
#'
#' @param gleam_feedbasket A `data.table` specifying feed ration shares per cohort.
#'   Must include columns matching those in `gleam_dmi` (for merging), plus:
#'   \describe{
#'     \item{Item_Name}{Feed identifier (string).}
#'     \item{feed_share}{Feed share as fraction of total diet (0–1).}
#'   }
#'   All columns from this data.table will be preserved in the output.
#'
#' @param gleam_feedEF A `data.table` with emission factors for each feed item.
#'   Must include:
#'   \describe{
#'     \item{ADM0_CODE}{Country code.}
#'     \item{Item_Name}{Feed identifier.}
#'     \item{Trade}{Trade category (`"With trade"`, `"Local"`, `"Non traded"`).}
#'     \item{EF}{Emission factor (kg gas/kg DM).}
#'   }
#'   All columns from this data.table will be preserved in the output.
#'
#' @param trade_preferences Optional named list specifying per-feed trade preferences.
#'   Each name corresponds to a feed ID (e.g. `"BPULP"`), and the value must be
#'   `"With Trade"` or `"Without Trade"`.
#'   If omitted, all feeds use the `default_trade_option`.
#'
#' @param default_trade_option Character string specifying the default trade selection
#'   when no user preference is provided. Accepts `"With Trade"` (default) or `"Without Trade"`.
#'
#' @param feed_id_col Character. Name of the column identifying feed items.
#'   Default is `"Item_Name"`.
#'
#' @param country_code Character. Name of the column identifying country codes.
#'   Default is `"ADM0_CODE"`.
#'
#' @return A `data.table` containing:
#'   \describe{
#'     \item{dmi_byfeed}{Feed-specific dry matter intake (kg DM/head/day).}
#'     \item{feed_emissions_kgGas}{Feed-specific emissions (kg gas/head/day).}
#'     \item{TradeOption_selected}{Applied trade option per feed.}
#'     \item{emission_factor}{Emission factor used (kg gas/kg DM).}
#'   }
#'
#' @examples
#' \dontrun{
#' library(data.table)
#'
#' # Load inputs
#' gleam_dmi <- fread("inst/extdata/GLEAM_input_directemissions_enteric.csv")[
#'   , .(ADM0_CODE = as.factor(ADM0_CODE),
#'       Animal_short, HerdType_short, LPS_short, cohort, ISO3,
#'       dmi_total = dmi)
#' ]
#'
#' gleam_feedbasket <- fread("inst/extdata/GLEAM_input_FeedRations.csv")[
#'   , .(ADM0_CODE = as.factor(ADM0_CODE),
#'       Animal_short, HerdType_short, LPS_short, cohort,
#'       Item_Name, feed_share = value)
#' ]
#'
#' gleam_feedEF <- fread("inst/extdata/Feed_parameters/GLEAM_Feed_EF.csv")[
#'   , ADM0_CODE := as.factor(ADM0_CODE)
#' ]
#'
#' # Run model with one user-defined trade preference
#' gleam_feed_result <- run_indirectemissions_feed(
#'   gleam_dmi = gleam_dmi,
#'   gleam_feedbasket = gleam_feedbasket,
#'   gleam_feedEF = gleam_feedEF,
#'   trade_preferences = list("BPULP" = "Without Trade"),
#'   feed_id_col = "Item_Name"
#' )
#'
#' head(gleam_feed_result[, .(Item_Name, dmi_byfeed, EF, feed_emissions_kgGas)])
#' }
#'
#' @keywords internal
#'
#' @importFrom data.table := .I data.table
#' @importFrom stats setNames
run_indirectemissions_feed <- function(
    gleam_dmi,
    gleam_feedbasket,
    gleam_feedEF,
    trade_preferences = NULL,
    default_trade_option = "With Trade",
    feed_id_col = "Item_Name",
    country_code = "ADM0_CODE"
) {

  # --- 0. Validate inputs -----------------------------------------------------
  stopifnot(
    inherits(gleam_dmi, "data.table"),
    inherits(gleam_feedbasket, "data.table"),
    inherits(gleam_feedEF, "data.table")
  )

  # Check that required columns exist
  required_dmi_cols <- c(country_code, "Animal_short", "HerdType_short", "LPS_short", "cohort", "dmi_total")
  required_feedbasket_cols <- c(country_code, "Animal_short", "HerdType_short", "LPS_short", "cohort", feed_id_col, "feed_share")
  required_ef_cols <- c(country_code, feed_id_col, "Trade", "EF")

  missing_dmi_cols <- setdiff(required_dmi_cols, names(gleam_dmi))
  missing_feedbasket_cols <- setdiff(required_feedbasket_cols, names(gleam_feedbasket))
  missing_ef_cols <- setdiff(required_ef_cols, names(gleam_feedEF))

  if (length(missing_dmi_cols) > 0) {
    stop("Missing required columns in gleam_dmi: ", paste(missing_dmi_cols, collapse = ", "))
  }
  if (length(missing_feedbasket_cols) > 0) {
    stop("Missing required columns in gleam_feedbasket: ", paste(missing_feedbasket_cols, collapse = ", "))
  }
  if (length(missing_ef_cols) > 0) {
    stop("Missing required columns in gleam_feedEF: ", paste(missing_ef_cols, collapse = ", "))
  }

  # --- 1. Merge DMI with feedbasket ------------------------------------------
  # Each cohort-feed combination gets its feed-specific DMI (kg DM/head/day)
  dmi_feed <- merge(
    gleam_dmi,
    gleam_feedbasket,
    by = c(country_code, "Animal_short", "HerdType_short", "LPS_short", "cohort"),
    allow.cartesian = TRUE
  )

  # Calculate feed-specific DMI row-wise
  dmi_feed[
    , dmi_byfeed := compute_dmi_by_feed(
      dmi_total = dmi_total,
      feed_share = feed_share
    ), by = .I
  ]

  # --- 2. Construct trade preference table -----------------------------------
  feeds_in_dmi <- unique(dmi_feed[[feed_id_col]])

  if (is.null(trade_preferences)) {
    # Default: all feeds use the default trade option
    trade_prefs_all <- data.table(
      feed_id = feeds_in_dmi,
      TradeOption_selected = default_trade_option
    )
  } else {
    # Combine user preferences and defaults for missing feeds
    trade_prefs_user <- data.table(
      feed_id = names(trade_preferences),
      TradeOption_selected = unlist(trade_preferences, use.names = FALSE)
    )
    missing_feeds <- setdiff(feeds_in_dmi, trade_prefs_user$feed_id)
    trade_prefs_default <- data.table(
      feed_id = missing_feeds,
      TradeOption_selected = default_trade_option
    )
    trade_prefs_all <- rbind(trade_prefs_user, trade_prefs_default)
  }

  data.table::setnames(trade_prefs_all, "feed_id", feed_id_col)

  # --- 3. Filter EF table by trade options -----------------------------------
  # Merge EF data with trade preferences
  gleam_feedEF_filtered <- merge(
    gleam_feedEF[get(feed_id_col) %in% feeds_in_dmi],
    trade_prefs_all,
    by = feed_id_col,
    allow.cartesian = TRUE
  )[
    # Apply trade logic: include only relevant trade scenarios
    (TradeOption_selected == "With Trade" &
       (Trade %in% c("With trade", "Non traded") | is.na(Trade))) |
      (TradeOption_selected == "Without Trade" &
         (Trade %in% c("Local", "Non traded") | is.na(Trade)))
  ]

  # --- 4. Merge DMI with EF and compute emissions ----------------------------
  result <- merge(
    dmi_feed,
    gleam_feedEF_filtered,
    by = c(country_code, feed_id_col),
    all.x = TRUE,
    all.y = TRUE,
    allow.cartesian = TRUE
  )

  result[
    , feed_emissions_kgGas := compute_feed_emissions(
      dmi_byfeed = dmi_byfeed,
      emission_factor = EF
    ), by = .I
  ]

  # --- 5. Return result -------------------------------------------------------
  return(result)
}
