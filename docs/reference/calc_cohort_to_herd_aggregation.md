# Aggregate cohort-level to herd-level data

This function aggregates a dataset from cohort level to herd level by
summing specified variables over the defined 'id' columns.

## Usage

``` r
calc_cohort_to_herd_aggregation(
  data_cohort,
  id_cols,
  vars_to_sum,
  cohort_short
)
```

## Arguments

- data_cohort:

  Cohort-level dataset containing energy allocation variables and herd
  identifiers. Each row corresponds to a single sex–age cohort within a
  herd.

- id_cols:

  Character. Unique identifier for the herd, repeated for each cohort
  belonging to the same herd.

- vars_to_sum:

  Character vector. Names of numeric cohort-level variables to be summed
  across cohorts to produce herd-level totals (e.g.,
  meat_allocation_energy, milk_allocation_energy,
  fibre_allocation_energy, work_allocation_energy,
  egg_allocation_energy)

- cohort_short:

  Character. Sex- and age-specific cohort code describing the production
  stage of the animals. Supported values include:

  - `FA`: adult females (from age at first parturition)

  - `FS`: sub-adult females (from weaning to age at first parturition)

  - `FJ`: juvenile females (from birth to weaning)

  - `MA`: adult males (from age at first breeding)

  - `MS`: sub-adult males (from weaning to age at first breeding)

  - `MJ`: juvenile males (from birth to weaning)

## Value

A `data.table` at herd scale, in which selected cohort-level variables
have been summed across all cohorts belonging to the same herd, as
defined by id_herd.

This function is part of the
[`run_allocation_module()`](https://github.com/un-fao/GLEAM/reference/run_allocation_module.md)
and
[`run_aggregation_module()`](https://github.com/un-fao/GLEAM/reference/run_aggregation_module.md).

## See also

[`run_allocation_module()`](https://github.com/un-fao/GLEAM/reference/run_allocation_module.md),
[`run_aggregation_module()`](https://github.com/un-fao/GLEAM/reference/run_aggregation_module.md)
