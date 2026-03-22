# Read the CSV
csv_path <- "data-raw/parameter_ranges.csv"
parameter_ranges <- data.table::fread(csv_path)

# Snapshot as internal data
usethis::use_data(
  parameter_ranges,
  internal = TRUE,
  overwrite = TRUE
)

message("✅ Built internal data `parameter_ranges` from CSV.")
