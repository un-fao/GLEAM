# Calculate total nondemographic durations by herd

Aggregates total modeled nondemographic productive-phase durations by
herd and sex from `FN` and `MN` cohort rows.

## Usage

``` r
calc_nondemographic_total_durations(cohort_short, cohort_duration_days)
```

## Arguments

- cohort_short:

  Character. Sex-specific cohort code describing the age and/or the
  production stage of the animals. Supported values include:

  - `FN`: non-demographic females

  - `MN`: non-demographic males

- cohort_duration_days:

  Numeric. Amount of time that each animal spends in a specific cohort
  (days). For `CHK`, suggested value for `FJ` and `MJ` cohorts: 3 days.

## Value

A named list with elements:

- total_nondemo_fem_duration_days:

  Numeric. Total duration of the productive non-demographic phases
  assigned to the female non-demographic cohort block (`FN`) (days).

- total_nondemo_mal_duration_days:

  Numeric. Total duration of the productive non-demographic phases
  assigned to the male non-demographic cohort block (`MN`) (days).

## See also

[`run_nondemographic_herd_module()`](https://un-fao.github.io/GLEAM/reference/run_nondemographic_herd_module.md)
