# Load the parameters
load_gleam_feedEF <- function(file_path, version) {
  dt <- fread(file_path)                            
  dt <- dt[GLEASTAT_version == version]             
  dt[, ADM0_CODE := as.factor(ADM0_CODE)]           
  return(dt)
}

# Dry Matter intake by feed-----
# Output: kg DM/head/day per feed item
calculate_intake_byfeed <- function(gleam_dmi, gleam_feedbasket, by_merge) {
  gleam_dmi <- merge(
    gleam_dmi,
    gleam_feedbasket,
    by = by_merge,
    allow.cartesian = TRUE
  )
  
  gleam_dmi[, dmi_byfeed := feed_share * dmi_total]
  
  return(gleam_dmi)
}

# Emissions by feed item-----
# Output: kg gas/head/day per feed item
calculate_feed_emissions <- function(
    gleam_dmi,
    gleam_feedEF,
    trade_preferences = NULL,
    default_trade_option = "With Trade",
    feed_id_col = "GLEAM3_name",
    country_code = "ADM0_CODE",
    by_merge
) {
  
  
  
  # Step 1: Set merge keys
  if (is.null(by_merge)) {
    by_merge <- c(country_code, feed_id_col)
  }
  
  # Step 2: Identify feeds used in DMI
  feeds_in_dmi <- unique(gleam_dmi[[feed_id_col]])
  
  # Step 3: Construct full trade preferences
  if (is.null(trade_preferences)) {
    trade_prefs_all <- data.table(
      feed_id = feeds_in_dmi,
      TradeOption_selected = default_trade_option
    )
  } else {
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
  
  # Rename column to match selected feed_id_col
  setnames(trade_prefs_all, "feed_id", feed_id_col)
  
  # Step 4: Filter EF to relevant feed IDs
  gleam_feedEF <- gleam_feedEF[get(feed_id_col) %in% feeds_in_dmi]
  
  # Step 5: Merge EF with trade preferences
  gleam_feedEF_merged <- merge(
    gleam_feedEF,
    trade_prefs_all,
    by = feed_id_col,
    allow.cartesian = TRUE
  )
  
  # Step 6: Apply trade logic
  gleam_feedEF_filtered <- gleam_feedEF_merged[
    (TradeOption_selected == "With Trade"    & (Trade %in% c("With trade", "Non traded") | is.na(Trade))) |
      (TradeOption_selected == "Without Trade" & (Trade %in% c("Local", "Non traded")     | is.na(Trade)))
  ]
  
  # Step 7: Merge DMI with EF
  gleam_feed_emissions <- merge(
    gleam_dmi,
    gleam_feedEF_filtered,
    by = by_merge,
    all.x = TRUE,
    all.y = TRUE,
    allow.cartesian = TRUE
  )
  
  # Step 8: Calculate emissions
  gleam_feed_emissions[, feed_emissions_kgGas := fifelse(
    is.na(dmi_byfeed) | is.na(EF),
    0,
    dmi_byfeed * EF
  )]
  
  return(gleam_feed_emissions)
}




