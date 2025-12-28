# Function to calculate soil organic carbon stock change from start to end (20 years)
# Input
calculate_soil_organic_carbon <- function(area, 
                                          climate_zone, 
                                          socRef = NA, 
                                          soil_type, 
                                          management_start, 
                                          management_end,
                                          management_params, 
                                          soil_type_params, 
                                          luc_factors
) {
  
  # Renamed to avoid confusion in the calculations
  cz <- climate_zone
  soilClass <- soil_type
  
  # Check area input
  if (is.na(area) || area <= 0) {
    stop("Area (ha) must be a positive number.")
  }
  
  # Use provided SOCref, or fallback to lookup from soil_type_params
  if (is.na(socRef)) {
    socRef <- soil_type_params[
      climate_zone == cz & soil_type == soilClass,
      V1
    ]
  }
  
  if (length(socRef) == 0 || is.na(socRef)) {
    stop("No SOCref found for given climate zone + soil class")
  }
  
  # Lookup management factors
  mgmtFactor1 <- management_params[
    climate_zone == cz & management_type == management_start,
    V1
  ]
  mgmtFactor2 <- management_params[
    climate_zone == cz & management_type == management_end,
    V1
  ]
  
  if (length(mgmtFactor1) == 0 || is.na(mgmtFactor1)) {
    stop("No management factor found for starting management")
  }
  if (length(mgmtFactor2) == 0 || is.na(mgmtFactor2)) {
    stop("No management factor found for ending management")
  }
  
  
  luFactor1 <- luc_factors[
    climate_zone == cz,
    V1
  ]
  luFactor2 <- luc_factors[
    climate_zone == cz,
    V1
  ]
  
  if (length(luFactor1) == 0 || all(is.na(luFactor1))) {
    stop("No land use change factor found for starting management")
  }
  if (length(luFactor1) > 1) {
    warning("Multiple land use change factors found; using the first one")
    luFactor1 <- luFactor1
  }
  
  # Core calculations
  SOC1 <- area * socRef * mgmtFactor1 * luFactor1
  SOC2 <- area * socRef * mgmtFactor2 * luFactor2
  dSOC <- (SOC2 - SOC1) / 20   # yearly change
  
  return(list(
    SOC1 = as.numeric(SOC1),
    SOC2 = as.numeric(SOC2),
    dSOC = as.numeric(dSOC)
  ))
  
}
