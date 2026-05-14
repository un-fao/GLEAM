# Calculate one year of steady-state population dynamics

Calculates one year of population dynamics under steady-state
assumptions using demographic parameters and returns population size
statistics and offtake results. The steady state is defined as a
constant sex–age cohort structure over time, with population size
potentially growing or declining at a constant rate.

## Usage

``` r
calc_projected_population_size(
  herd_size_total,
  fecundity_female,
  fecundity_male,
  probability_death,
  probability_offtake,
  probability_growth,
  growth_rate_herd,
  herd_structure,
  cohort_share
)
```

## Arguments

- herd_size_total:

  Numeric. Total population size at the start of the year, including all
  cohorts (# heads)

- fecundity_female:

  Numeric. Daily number of female offspring per adult female (#
  offspring/day)

- fecundity_male:

  Numeric. Daily number of male offspring per adult female (#
  offspring/day)

- probability_death:

  Named numeric vector of length 10. Probability of animal dying within
  the model time interval for 10 cohorts (fraction) (cohorts= `FB`:
  Female Birth, `FJ`: Female Juvenile, `FS`: Female Sub-adult, `FA`:
  Female Adult, `FC`: Female Culling, `MB`: Male Birth, `MJ`: Male
  Juvenile, `MS`: Male Sub-adult, `MA`: Male Adult, `MC`: Male Culling).

- probability_offtake:

  Named numeric vector of length 10. Probability that an animal will be
  removed from the herd within the model time interval for 10 cohorts
  (fraction). (cohorts= `FB`: Female Birth, `FJ`: Female Juvenile, `FS`:
  Female Sub-adult, `FA`: Female Adult, `FC`: Female Culling, `MB`: Male
  Birth, `MJ`: Male Juvenile, `MS`: Male Sub-adult, `MA`: Male Adult,
  `MC`: Male Culling).

- probability_growth:

  Named numeric vector of length 10. Probability of growing into the
  next age class for 10 cohorts (fraction) (cohorts= `FB`: Female Birth,
  `FJ`: Female Juvenile, `FS`: Female Sub-adult, `FA`: Female Adult,
  `FC`: Female Culling, `MB`: Male Birth, `MJ`: Male Juvenile, `MS`:
  Male Sub-adult, `MA`: Male Adult, `MC`: Male Culling).

- growth_rate_herd:

  Numeric. Annualized growth rate at which the herd reaches steady state
  (fraction)

- herd_structure:

  Named numeric vector of length 8. Final steady-state share of each of
  8 sex-age cohorts (`FB`, `FJ`, `FS`, `FA`, `MB`, `MJ`, `MS`, `MA`)
  (fraction). Shares should sum to 1.

- cohort_share:

  Named numeric vector of length 6. Final steady-state share of 6
  grouped sex-age cohorts (`FJ`, `FS`, `FA`, `MJ`, `MS`, `MA`, where
  `FJ = FB + FJ` and `MJ = MB + MJ`) (fraction). Shares should sum to 1.

## Value

A named list with:

- cohort_stock_start:

  Numeric vector of length 6. Population size in each of the 6 sex–age
  cohorts at the start of the year (# heads). (cohorts= `FJ`, `FS`,
  `FA`, `MJ`, `MS`, `MA`)

- cohort_stock_end_projected:

  Numeric vector of length 6. Population size in each of the 6 sex–age
  cohorts at the end of the year, projected using the steady-state
  growth rate (# heads). (cohorts= `FJ`, `FS`, `FA`, `MJ`, `MS`, `MA`)

- cohort_stock_end_exact_simulated:

  Numeric vector of length 10. Population size in each of 10 sex–age
  cohort at the end of the year, based on a demographic daily simulation
  over 365 days (# heads) (cohorts= `FB`: Female Birth, `FJ`: Female
  Juvenile, `FS`: Female Sub-adult, `FA`: Female Adult, `FC`: Female
  Culling, `MB`: Male Birth, `MJ`: Male Juvenile, `MS`: Male Sub-adult,
  `MA`: Male Adult, `MC`: Male Culling)

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

This function is part of the
[`run_demographic_herd_module()`](https://github.com/un-fao/GLEAM/reference/run_demographic_herd_module.md).

## See also

[`run_demographic_herd_module()`](https://github.com/un-fao/GLEAM/reference/run_demographic_herd_module.md)
