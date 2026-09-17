# All validation rules are maintained in this single CSV.
# Use ANY in species_short or cohort_short when a rule applies to all codes.
# Dependency requirements and numeric bounds share each parameter row.
# range_species_short/range_cohort_short specify where the bounds apply.
# comparison_operator = positive_if_positive requires variable > 0 whenever
# comparison_variable > 0. The rule is limited by species, cohort and function.
parameter_rules <- data.table::fread("data-raw/parameter_rules.csv")
if (any(!is.na(parameter_rules$requirement) & !parameter_rules$requirement %in% c("", "R", "O"))) {
  stop("Unknown dependency requirement in parameter_rules.csv; use R, O, or leave blank.")
}

# Snapshot as internal data.
usethis::use_data(
  parameter_rules,
  internal = TRUE,
  overwrite = TRUE
)

message("Built internal validation data from data-raw/parameter_rules.csv.")
