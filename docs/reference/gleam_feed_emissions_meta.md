# Feed-related emission sources

Emission variables expressed per kg dry matter intake (g/kg DM). Passed
to
[`calc_cohort_totals()`](https://github.com/un-fao/GLEAM/reference/calc_cohort_totals.md)
to apply ration_intake scaling. All other emissions use
cohort_stock_size \* simulation_duration only.

## Usage

``` r
gleam_feed_emissions_meta
```

## Format

A list of lists with `emissions_source` and `label`.
