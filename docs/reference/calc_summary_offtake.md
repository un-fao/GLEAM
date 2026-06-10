# Summarise offtake and stock Variation for a steady-state year

Calculates annual offtake quantities and rates, as well as stock
variation and their combined values across 6 sex-age classes based on
steady-state population projections. The steady state is defined as a
constant sex–age cohort structure over time, with population size
potentially growing or declining at a constant rate.

## Usage

``` r
calc_summary_offtake(
  cohort_stock_start,
  cohort_stock_end_projected,
  cohort_stock_average,
  cohort_offtake_heads,
  simulation_duration
)
```

## Arguments

- cohort_stock_start:

  Numeric vector of length 6. Population size in each of the 6 sex–age
  cohorts at the start of the year (# heads). (cohorts= `FJ`, `FS`,
  `FA`, `MJ`, `MS`, `MA`)

- cohort_stock_end_projected:

  Numeric vector of length 6. Population size in each of the 6 sex–age
  cohorts at the end of the year, projected using the steady-state
  growth rate (# heads). (cohorts= `FJ`, `FS`, `FA`, `MJ`, `MS`, `MA`)

- cohort_stock_average:

  Numeric vector of length 6. Average population size in each of the 6
  sex–age cohorts over the year (# heads). Estimated from
  cohort_stock_start and cohort_stock_end_projected (cohorts= `FJ`,
  `FS`, `FA`, `MJ`, `MS`, `MA`)

- cohort_offtake_heads:

  Numeric vector of length 10. Total number of animals removed from the
  herd over the year, by 10 sex–age cohorts (heads/year) (cohorts= `FB`:
  Female Birth, `FJ`: Female Juvenile, `FS`: Female Sub-adult, `FA`:
  Female Adult, `FC`: Female Culling, `MB`: Male Birth, `MJ`: Male
  Juvenile, `MS`: Male Sub-adult, `MA`: Male Adult, `MC`: Male Culling)

- simulation_duration:

  Numeric. Length of the assessment period (days)

## Value

A named list with:

- stock_variation_heads:

  Numeric vector of length 6. Change in population size between the
  start and end of the year for each sex–age cohort (# heads) (cohorts=
  `FJ`, `FS`, `FA`, `MJ`, `MS`, `MA`).

- offtake_heads:

  Numeric vector of length 6. Total number of animals removed via
  offtake over the year, aggregated to 6 sex–age cohorts (heads/year)
  (cohorts= `FJ`, `FS`, `FA`, `MJ`, `MS`, `MA`)

- offtake_heads_assessment:

  Numeric vector of length 6. Total number of animals removed via
  offtake over the assessment period, aggregated to 6 sex–age cohorts
  (heads/assessment period) (cohorts= `FJ`, `FS`, `FA`, `MJ`, `MS`,
  `MA`)

- offtake_rate_to_stock_start:

  Numeric vector of length 6. Offtake rate relative to the starting
  population size in each sex–age cohort (fraction) (cohorts= `FJ`,
  `FS`, `FA`, `MJ`, `MS`, `MA`)

- offtake_rate_to_stock_average:

  Numeric vector of length 6. Offtake rate relative to the average
  population size in each sex–age cohort (fraction) (cohorts= `FJ`,
  `FS`, `FA`, `MJ`, `MS`, `MA`)

- offtake_stock_variation_heads:

  Numeric vector of length 6. Sum of offtake and stock variation for
  each sex–age cohort over the year (# heads) (cohorts= `FJ`, `FS`,
  `FA`, `MJ`, `MS`, `MA`)

- offtake_stock_plus_variation_rate_to_stock_start:

  Numeric vector of length 6. Offtake plus stock-variation rate relative
  to starting population size (fraction) (cohorts= `FJ`, `FS`, `FA`,
  `MJ`, `MS`, `MA`)

- offtake_stock_plus_variation_rate_to_stock_average:

  Numeric vector of length 6. Offtake plus stock-variation rate relative
  to average population size (fraction) (cohorts= `FJ`, `FS`, `FA`,
  `MJ`, `MS`, `MA`)

This function is part of the
[`run_demographic_herd_module()`](https://github.com/un-fao/GLEAM/reference/run_demographic_herd_module.md).

## See also

[`run_demographic_herd_module()`](https://github.com/un-fao/GLEAM/reference/run_demographic_herd_module.md)
