library(readr)
library(data.table)

dt_pastmanfrac <- as.data.table(read_csv("0_PreProcessing/variables_calc/past_man_frac/FAOSTAT_data_en_3-24-2025.csv"))


Dfunc_past_man_frac <- function(dt) {
  # Step 1: Pivot the data using dcast
  dt <- dcast(
    dt,
    `Domain Code` + `Area Code (M49)` + Domain + Year + Area + Year ~ Item,
    value.var = "Value"
  )
  
  # Step 2: Calculate the pasture management fraction
  dt[, past_man_frac := {
    # Replace NA with 0 in the relevant variables
    nom <- ifelse(is.na(`Temporary fallow`), 0, `Temporary fallow`) + 
      ifelse(is.na(`Temporary meadows and pastures`), 0, `Temporary meadows and pastures`)
    
    denom <- ifelse(is.na(`Permanent meadows and pastures`), 0, `Permanent meadows and pastures`) + 
      ifelse(is.na(`Temporary fallow`), 0, `Temporary fallow`) + 
      ifelse(is.na(`Temporary meadows and pastures`), 0, `Temporary meadows and pastures`)
    
    # Avoid division by zero and return NA where necessary
    result <- nom / denom
    result[is.na(result) | denom == 0] <- 0  # Replace NA and handle division by zero
    result  # Return the result
  }]
  
  # Step 3: Rename the Area Code column
  setnames(dt, "Area Code (M49)", "M49_code")
  
  # Return the transformed data.table
  return(dt)
}


processed_data <- Dfunc_past_man_frac(dt_pastmanfrac)


# write.csv(processed_data, "0_PreProcessing/variables_calc/past_man_frac/faostat_pastmanfrac.csv")


