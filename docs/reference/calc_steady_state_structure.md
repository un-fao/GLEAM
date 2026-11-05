# Calculate steady-state population structure

Calculates population dynamics over time until a steady state is
reached. The steady state is defined as a constant sex–age cohort
structure over time, with population size potentially growing or
declining at a constant rate. Tracks sex–age cohort structure and
population growth based on survival, offtake, fecundity parameters and
diversion to non-demographic blocks such as fattening operations.

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
  probability_growth,
  proportion_nondemographic
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

- proportion_nondemographic:

  Named numeric vector of length 6. Fraction of animals diverted from
  the demographic pathway into the non-demographic pathway for 6
  demographic cohorts (fraction). (cohorts= `FJ`, `FS`, `FA`, `MJ`,
  `MS`, `MA`).

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

- size_unscaled:

  Named numeric vector of length 6. Final steady-state population size
  by grouped demographic sex-age cohort before rescaling to the observed
  herd total (heads).

This function is part of the
[`run_demographic_herd_module()`](https://un-fao.github.io/GLEAM/reference/run_demographic_herd_module.md).

## Details

Diversion into the non-demographic block is applied on cohort
transitions. For each transition eligible for diversion, the model first
computes the total number of animals progressing out of the current
demographic cohort. It then splits that transition flow into:

- a retained demographic component, which continues into the next
  demographic cohort

- a diverted non-demographic component, recorded separately through
  `proportion_nondemographic`

In formula terms, if \\T\\ is the total transition flow and \\p\\ is the
relevant entry of `proportion_nondemographic`, then: \$\$ T\_{non-demo}
= p \times T \$\$ \$\$ T\_{demo} = (1 - p) \times T \$\$

This allows the demographic steady-state structure to remain internally
consistent while tracking how many animals are redirected to the
non-demographic component.

## See also

[`run_demographic_herd_module()`](https://un-fao.github.io/GLEAM/reference/run_demographic_herd_module.md)
