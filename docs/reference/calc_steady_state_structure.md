# Calculate steady-state population structure

Calculates population dynamics over time until a steady state is
reached. The steady state is defined as a constant sex–age cohort
structure over time, with population size potentially growing or
declining at a constant rate. Tracks sex–age cohort structure and
population growth based on survival, offtake, and fecundity parameters.

## Usage

``` r
calc_steady_state_structure(
  initial_herd_structure,
  max_simulation_years,
  min_lambda_change,
  fecundity_female,
  fecundity_male,
  probability_death,
  probability_offtake,
  probability_growth
)
```

## Arguments

- initial_herd_structure:

  Named numeric vector of length 6. Initial number of individuals in
  each of the 6 sex-age classes used to bootstrap the steady-state
  simulation (# heads). These values are used as starting points for the
  iterative simulation and do not affect the final steady-state results
  (only convergence speed). Must be named with: `FJ`, `FS`, `FA`, `MJ`,
  `MS`, `MA`.

- max_simulation_years:

  Numeric. Maximum number of years to simulate (years).

- min_lambda_change:

  Numeric. Convergence threshold for changes in cohort-specific growth
  rates of sex–age cohort proportions (lambda). Iterations of the herd
  simulation stop when the absolute change in lambda between successive
  iterations falls below this threshold.

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

## Value

A named list with:

- days_to_steady_state:

  Numeric. Number of days required for the herd population structure to
  converge to a steady state, defined as the point at which successive
  iterations produce negligible changes in cohort proportions (days)

- herd_structure:

  Named numeric vector of length 8. Final steady-state share of each of
  8 sex-age cohorts (`FB`, `FJ`, `FS`, `FA`, `MB`, `MJ`, `MS`, `MA`)
  (fraction). Shares should sum to 1.

- cohort_share:

  Named numeric vector of length 6. Final steady-state share of 6
  grouped sex-age cohorts (`FJ`, `FS`, `FA`, `MJ`, `MS`, `MA`, where
  `FJ = FB + FJ` and `MJ = MB + MJ`) (fraction). Shares should sum to 1.

- growth_rate_herd:

  Numeric. Annualized growth rate at which the herd reaches steady state
  (fraction)

This function is part of the
[`run_demographic_herd_module()`](https://github.com/un-fao/GLEAM/reference/run_demographic_herd_module.md).

## See also

[`run_demographic_herd_module()`](https://github.com/un-fao/GLEAM/reference/run_demographic_herd_module.md)
