# Calculate daily weight gain by cohort

Calculates average daily weight gain for a given sex–age cohort based on
the difference between potential final and initial live weights.

## Usage

``` r
calc_daily_weight_gain(
  live_weight_cohort_potential_final,
  live_weight_cohort_initial,
  cohort_duration_days
)
```

## Arguments

- live_weight_cohort_potential_final:

  Numeric. Potential final live weight attainable at the end of the
  cohort stage in the absence of offtake (kg). (For juveniles: equals
  weaning weight; For subadults: equals adult live weight; For adults:
  equals adult live weight)

- live_weight_cohort_initial:

  Numeric. Live weight at the beginning of the cohort stage (kg).

- cohort_duration_days:

  Numeric. Amount of time that each animal spends in a specific cohort
  (days).

## Value

Numeric. Average live weight gain of the cohort over the cohort stage
(kg/head/day).

## Details

Daily live weight gain is calculated as the difference between the
potential final live weight and the initial live weight, divided by the
duration of the cohort stage:

\$\$daily\\weight\\gain = (live\\weight\\cohort\\potential\\final -
live\\weight\\cohort\\initial) / cohort\\duration\\days\$\$

This function is part of the
[`run_weights_module()`](https://github.com/un-fao/GLEAM/reference/run_weights_module.md).

## See also

[`run_weights_module`](https://github.com/un-fao/GLEAM/reference/run_weights_module.md)
