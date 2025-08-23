# Read the CSV
csv_path <- "data-raw/herd_module_parameter_ranges.csv"
herd_module_parameter_ranges <- data.table::fread(csv_path)

# Snapshot as internal data
usethis::use_data(
  herd_module_parameter_ranges,
  internal = TRUE,
  overwrite = TRUE
)

message("✅ Built internal data `herd_module_parameter_ranges` from CSV.")

