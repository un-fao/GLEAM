# Calculate average and final live weights by cohort

Calculates the average and final live weight for a given sex–age cohort
based on initial weight, potential final weight, slaughter weight, and
the offtake rate.

## Usage

``` r
calc_avg_weights(
  live_weight_cohort_initial,
  live_weight_cohort_potential_final,
  live_weight_cohort_at_slaughter,
  offtake_rate
)
```

## Arguments

- live_weight_cohort_initial:

  Numeric. Live weight at the beginning of the cohort stage (kg).

- live_weight_cohort_potential_final:

  Numeric. Potential final live weight attainable at the end of the
  cohort stage in the absence of offtake (kg). (For juveniles: equals
  weaning weight; For subadults: equals adult live weight; For adults:
  equals adult live weight)

- live_weight_cohort_at_slaughter:

  Numeric. Live weight at slaughter for animals removed from the cohort
  (kg).

- offtake_rate:

  Numeric. Annual proportion of animals removed from the herd for each
  sex-age cohort (fraction).

## Value

A named list with:

- live_weight_cohort_average:

  Numeric. Average live weight over the cohort stage. Computed by
  accounting for the share of offtaken animals within the cohort, using
  their slaughter weight, and the potential final weight of animals that
  remain in the cohort (kg).

- live_weight_cohort_final:

  Numeric. Live weight at the end of the cohort stage, accounting for
  both surviving and offtaken animals. Computed as a weighted average of
  the potential final weight of surviving animals and the slaughter
  weight of offtaken animals, based on the offtake rate (kg).

## Details

The calculation of `live_weight_cohort_average` and
`live_weight_cohort_final` is performed considering that a fraction of
animals is removed (offtake) during the cohort stage, while the
remaining animals reach the potential final live weight.

The final live weight is computed as: \$\$ live\\weight\\cohort_final =
(1 - offtake\\rate) \times live\\weight\\cohort\\potential\\final +
offtake\\rate \times live\\weight\\cohort\\at\\slaughter \$\$

The average live weight over the stage is approximated as:
\$\$live\\weight\\cohort\\average = (live\\weight\\cohort\\initial +
live\\weight\\cohort\\final)/2\$\$

This function is part of the
[`run_weights_module()`](https://github.com/un-fao/GLEAM/reference/run_weights_module.md).

## See also

[`run_weights_module`](https://github.com/un-fao/GLEAM/reference/run_weights_module.md)
