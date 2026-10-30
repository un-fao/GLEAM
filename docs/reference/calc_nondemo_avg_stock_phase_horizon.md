# Calculate average nondemographic stock over the assessment horizon

Computes annual average stock for a full productive phase, including
animals that entered before the assessment year.

## Usage

``` r
calc_nondemo_avg_stock_phase_horizon(
  full_nondemo_phase,
  total_nondemo_cycle_starts_to_distribute
)
```

## Arguments

- full_nondemo_phase:

  List. Output of
  [`calc_nondemo_phase()`](https://un-fao.github.io/GLEAM/reference/calc_nondemo_phase.md)
  for a full productive phase. Must contain
  `time_simulated_nondemographic` (days) and
  `cohort_stock_nondemo$start` and `cohort_stock_nondemo$end` (heads).

- total_nondemo_cycle_starts_to_distribute:

  Numeric. Annual cycle starts, calculated by
  [`calc_nondemo_cycle_geometry()`](https://un-fao.github.io/GLEAM/reference/calc_nondemo_cycle_geometry.md)
  and passed internally by
  [`run_nondemographic_herd_module()`](https://un-fao.github.io/GLEAM/reference/run_nondemographic_herd_module.md).

## Value

A named list with:

- cohort_stock_size_unscaled:

  Numeric. Annual average population in the phase (heads), before
  rescaling to `herd_size_total`.

## Details

The model calculates cycle starts from the phase and rest durations. No
additional input-table field is required for this value.

For one full phase, animal-days are approximated using the trapezoidal
rule: \$\$ full\\phase\\days =
full_nondemo_phase\$time_simulated_nondemographic \times \frac{
full_nondemo_phase\$cohort_stock_nondemo\$start +
full_nondemo_phase\$cohort_stock_nondemo\$end }{2} \$\$

Annual average stock is then: \$\$ average\\stock\\phase\\horizon =
\frac{total\\nondemo\\cycle\\starts\\to\\distribute \times
full\\phase\\days}{365} \$\$

Full-phase stock is used even when no complete cycle fits within 365
days. This represents an established herd with animals from previous
arrival years. A zero-duration phase contributes zero stock.

The calculation assumes linear stock change within each phase and
applies no rounding. Fractional average stock values may occur.

This function is part of
[`run_nondemographic_herd_module()`](https://un-fao.github.io/GLEAM/reference/run_nondemographic_herd_module.md).

## See also

[`run_nondemographic_herd_module()`](https://un-fao.github.io/GLEAM/reference/run_nondemographic_herd_module.md)
