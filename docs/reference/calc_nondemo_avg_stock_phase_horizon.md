# Calculate average nondemographic stock over the fixed simulation horizon

Computes average stock for a nondemographic productive phase over the
fixed 365-day simulation horizon, including animals that may have
entered the phase before the beginning of the horizon.

## Usage

``` r
calc_nondemo_avg_stock_phase_horizon(
  full_nondemo_phase,
  total_nondemo_cycle_starts_to_distribute
)
```

## Arguments

- full_nondemo_phase:

  List. Simulated stock dynamics for one complete nondemographic
  productive phase. The list must contain:

  - `time_simulated_nondemographic`: Number of days simulated for the
    productive phase (days).

  - `cohort_stock_nondemo$start`: Number of animals at the beginning of
    the simulated productive phase (heads)..

  - `cohort_stock_nondemo$end`: Number of animals remaining at the end
    of the simulated productive phase after applying mortality over the
    simulated time interval (heads).

  This object cab be obtained by running
  [`calc_nondemo_phase()`](https://un-fao.github.io/GLEAM/reference/calc_nondemo_phase.md)
  for the complete duration of the productive phase.

- total_nondemo_cycle_starts_to_distribute:

  Integer. Total number of cycle starts within the fixed 365-day time
  horizon for the assessed non-demographic cohort (`FN` or `MN`) (#
  cycle starts).

## Value

A named list with:

- cohort_stock_size_unscaled:

  Numeric. Average population size of the assessed cohort, not scaled to
  the total livestock population (herd_size_total) (# heads).

## Details

The number of cycle starts is calculated upstream by
[`calc_nondemo_cycle_geometry()`](https://un-fao.github.io/GLEAM/reference/calc_nondemo_cycle_geometry.md)
from the productive-phase and between-cycle rest durations and is
supplied to this function through
`total_nondemo_cycle_starts_to_distribute`.

For one complete productive phase, animal-days are approximated using
the trapezoidal rule: \$\$ AD\_{phase} = T\_{phase} \times
\frac{N\_{start} + N\_{end}}{2} \$\$

where \\T\_{phase}\\ is the duration of the productive phase (days), and
\\N\_{start}\\ and \\N\_{end}\\ are the numbers of animals at the start
and end of the phase, respectively.

Average stock over the fixed 365-day simulation horizon is then
calculated as: \$\$ N\_{avg} = \frac{N\_{starts} \times
AD\_{phase}}{365} \$\$

where \\N\_{starts}\\ is the total number of production-cycle starts
within the fixed 365-day simulation horizon.

Each cycle start is assigned the animal-days of one complete productive
phase. The calculation therefore represents steady-state phase occupancy
rather than truncating the contribution of a cycle that starts near the
end of the 365-day horizon. Contributions extending beyond the end of
the horizon are balanced conceptually by contributions from cycles that
began before the horizon.

A complete phase is used even when no complete production cycle fits
within the 365-day horizon. A zero-duration phase contributes zero
stock.

The calculation assumes linear stock change within each phase and
applies no rounding. Fractional average stock values may occur.

This function is part of
[`run_nondemographic_herd_module()`](https://un-fao.github.io/GLEAM/reference/run_nondemographic_herd_module.md).

## See also

[`calc_nondemo_phase()`](https://un-fao.github.io/GLEAM/reference/calc_nondemo_phase.md),
[`calc_nondemo_cycle_geometry()`](https://un-fao.github.io/GLEAM/reference/calc_nondemo_cycle_geometry.md),
[`run_nondemographic_herd_module()`](https://un-fao.github.io/GLEAM/reference/run_nondemographic_herd_module.md)
