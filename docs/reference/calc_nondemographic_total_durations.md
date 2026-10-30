# Calculate total nondemographic durations by herd

Aggregates total modeled nondemographic productive-phase durations by
herd and sex from `FN` and `MN` cohort rows.

## Usage

``` r
calc_nondemographic_total_durations(cohort_short, cohort_duration_days)
```

## Arguments

- cohort_short:

  Character. Sex- and production-stage-specific cohort code describing
  the animal group. Supported values include:

  - `FA`: adult females (from age at first parturition)

  - `FS`: sub-adult females (from weaning to age at first parturition)

  - `FJ`: juvenile females (from birth to weaning)

  - `MA`: adult males (from age at first breeding)

  - `MS`: sub-adult males (from weaning to age at first breeding)

  - `MJ`: juvenile males (from birth to weaning)

  - `FN`: non-demographic females

  - `MN`: non-demographic males

- cohort_duration_days:

  Numeric. Amount of time that each animal spends in a specific cohort
  (days).

## Value

A named list with elements:

- total_nondemo_fem_duration_days:

  Numeric. Total duration of the productive nondemographic phases
  assigned to the female nondemographic cohort block (`FN`) (days).

- total_nondemo_mal_duration_days:

  Numeric. Total duration of the productive nondemographic phases
  assigned to the male nondemographic cohort block (`MN`) (days).

## See also

[`run_nondemographic_herd_module()`](https://un-fao.github.io/GLEAM/reference/run_nondemographic_herd_module.md)
