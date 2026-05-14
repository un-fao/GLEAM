# Calculate transition probabilities for sex-age classes

Calculates hazard rates and daily transition probabilities (death,
offtake, survival, and growth) across different sex-age cohorts.
Converts annual inputs to daily hazards, then derives daily
probabilities from those hazards.

## Usage

``` r
calc_transition_probabilities(cohort_duration_days, offtake_rate, death_rate)
```

## Arguments

- cohort_duration_days:

  Numeric vector of length 6. Amount of time that each animal spends in
  a specific cohort (days).

- offtake_rate:

  Numeric vector of length 6. Annual proportion of animals removed from
  the herd for each sex-age cohort (fraction).

- death_rate:

  Numeric vector of length 6. Fraction of deaths in a herd over a year
  for each sex-age cohort (fraction)

## Value

A named list with:

- hazard_death:

  Numeric vector of length 6. Instantaneous mortality hazard rate for
  the 6 sex–age cohorts. Represents the risk of death per unit time
  (day) (cohorts= `FJ`, `FS`, `FA`, `MJ`, `MS`, `MA`)

- hazard_offtake:

  Numeric vector of length 6. Instantaneous offtake hazard rate for the
  6 sex-age cohorts. Represents the risk to leave the herd through
  planned removals per unit of time (day-1) (cohorts= `FJ`, `FS`, `FA`,
  `MJ`, `MS`, `MA`)

- probability_death:

  Named numeric vector of length 10. Probability of animal dying within
  the model time interval for 10 cohorts (fraction). (cohorts= `FB`:
  Female Birth, `FJ`: Female Juvenile, `FS`: Female Sub-adult, `FA`:
  Female Adult, `FC`: Female Culling, `MB`: Male Birth, `MJ`: Male
  Juvenile, `MS`: Male Sub-adult, `MA`: Male Adult, `MC`: Male Culling)

- probability_offtake:

  Named numeric vector of length 10. Probability that an animal will be
  removed from the herd within the model time interval for 10 cohorts
  (fraction). (cohorts= `FB`: Female Birth, `FJ`: Female Juvenile, `FS`:
  Female Sub-adult, `FA`: Female Adult, `FC`: Female Culling, `MB`: Male
  Birth, `MJ`: Male Juvenile, `MS`: Male Sub-adult, `MA`: Male Adult,
  `MC`: Male Culling)

- probability_survival:

  Named numeric vector of length 10. Probability that an animal remains
  alive in the herd within the model time interval for 10 cohorts
  (fraction). (cohorts= `FB`: Female Birth, `FJ`: Female Juvenile, `FS`:
  Female Sub-adult, `FA`: Female Adult, `FC`: Female Culling, `MB`: Male
  Birth, `MJ`: Male Juvenile, `MS`: Male Sub-adult, `MA`: Male Adult,
  `MC`: Male Culling)

- probability_growth:

  Named numeric vector of length 10. Probability of growing into the
  next age class for 10 cohorts (fraction) (cohorts= `FB`: Female Birth,
  `FJ`: Female Juvenile, `FS`: Female Sub-adult, `FA`: Female Adult,
  `FC`: Female Culling, `MB`: Male Birth, `MJ`: Male Juvenile, `MS`:
  Male Sub-adult, `MA`: Male Adult, `MC`: Male Culling)

This function is part of the
[`run_demographic_herd_module()`](https://github.com/un-fao/GLEAM/reference/run_demographic_herd_module.md).

## See also

[`run_demographic_herd_module()`](https://github.com/un-fao/GLEAM/reference/run_demographic_herd_module.md)
