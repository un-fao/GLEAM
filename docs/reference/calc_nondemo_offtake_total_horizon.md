# Calculate total nondemographic offtake over the assessment horizon

Calculates total offtake (animals exiting the system) for a
nondemographic cohort (FN or MN) over the assessment period using a
steady-state throughput formulation.

## Usage

``` r
calc_nondemo_offtake_total_horizon(
  cohort_stock_nondemo_end_phase1,
  cohort_stock_nondemo_end_phase2,
  cohort_stock_nondemo_annual_entrants,
  cohort_stock_nondemo_start_cycle,
  number_full_nondemo_cycles,
  partial_phase1_nondemo_duration,
  partial_phase2_nondemo_duration,
  phase1_nondemo_duration,
  phase2_nondemo_duration,
  simulation_duration
)
```

## Arguments

- cohort_stock_nondemo_end_phase1:

  Numeric. Number of animals remaining at the end of one complete
  nondemographic productive phase 1 after applying phase-specific
  mortality (# heads / cycle). Typically obtained as
  `cohort_stock_nondemo$end` from
  [`calc_nondemo_phase`](https://un-fao.github.io/GLEAM/reference/calc_nondemo_phase.md)
  when simulating a full phase 1.

- cohort_stock_nondemo_end_phase2:

  Numeric. Number of animals remaining at the end of one complete
  nondemographic productive phase 2 after applying phase-specific
  mortality (# heads / cycle). Typically obtained as
  `cohort_stock_nondemo$end` from
  [`calc_nondemo_phase`](https://un-fao.github.io/GLEAM/reference/calc_nondemo_phase.md)
  when simulating a full phase 2. Used only when phase 2 exists.

- cohort_stock_nondemo_annual_entrants:

  Numeric. Total annual number of animals entering the nondemographic
  block over the fixed 365-day horizon (# heads / simulated period).

- cohort_stock_nondemo_start_cycle:

  Numeric. Number of animals starting one nondemographic production
  cycle (# heads / cycle).

- number_full_nondemo_cycles:

  Integer. Number of complete nondemographic production cycles fully
  contained within the simulated period (cycles / simulated period).
  This is calculated by
  [`calc_nondemo_cycle_geometry`](https://un-fao.github.io/GLEAM/reference/calc_nondemo_cycle_geometry.md).

- partial_phase1_nondemo_duration:

  Numeric. Duration of the terminal partial productive phase 1 occurring
  at the end of the simulated period (days). Used only to determine
  whether the final partial phase 1 reaches completion; terminal partial
  phases do not contribute to offtake. This is calculated by
  [`calc_nondemo_cycle_geometry`](https://un-fao.github.io/GLEAM/reference/calc_nondemo_cycle_geometry.md).

- partial_phase2_nondemo_duration:

  Numeric. Duration of the terminal partial productive phase 2 occurring
  at the end of the simulated period (days). Used only to determine
  whether the final partial phase 2 reaches completion; terminal partial
  phases do not contribute to offtake. This is calculated by
  [`calc_nondemo_cycle_geometry`](https://un-fao.github.io/GLEAM/reference/calc_nondemo_cycle_geometry.md).

- phase1_nondemo_duration:

  Numeric. Full duration of productive phase 1 for the assessed
  nondemographic cohort block (`FN` or `MN`) (days). This duration is
  used as input to both
  [`calc_nondemo_cycle_geometry`](https://un-fao.github.io/GLEAM/reference/calc_nondemo_cycle_geometry.md)
  and
  [`calc_nondemo_phase`](https://un-fao.github.io/GLEAM/reference/calc_nondemo_phase.md).

- phase2_nondemo_duration:

  Numeric. Full duration of productive phase 2 for the assessed
  nondemographic cohort block (`FN` or `MN`) (days). Use `0` when no
  second productive phase exists. This duration is used as input to both
  [`calc_nondemo_cycle_geometry`](https://un-fao.github.io/GLEAM/reference/calc_nondemo_cycle_geometry.md)
  and
  [`calc_nondemo_phase`](https://un-fao.github.io/GLEAM/reference/calc_nondemo_phase.md).

- simulation_duration:

  Numeric. Length of the assessment period (days).

## Value

A named list with:

- offtake_heads_nondemo_phase1:

  Numeric. Total number of animals removed at the end of productive
  phase 1 of the nondemographic block over the fixed 365-day horizon
  (heads).

- offtake_heads_nondemo_phase2:

  Numeric. Total number of animals removed at the end of productive
  phase 2 of the nondemographic block over the fixed 365-day horizon
  (heads).

- offtake_heads_assessment_nondemo_phase1:

  Numeric. Total number of animals removed at the end of productive
  phase 1 of the nondemographic block over `simulation_duration` (heads
  / simulated period).

- offtake_heads_assessment_nondemo_phase2:

  Numeric. Total number of animals removed at the end of productive
  phase 2 of the nondemographic block over `simulation_duration` (heads
  / simulated period).

## Details

This function is applied within
[`run_nondemographic_herd_module`](https://un-fao.github.io/GLEAM/reference/run_nondemographic_herd_module.md)
after productive phases have been simulated with
[`calc_nondemo_phase()`](https://un-fao.github.io/GLEAM/reference/calc_nondemo_phase.md)
and end-of- phase stock sizes have been obtained.

Offtake is assumed to occur only at the end of the last existing
productive phase in the cycle (phase 2 if present, otherwise phase 1).
The function uses a fixed 365-day simulated horizon so the
nondemographic pathway stays aligned with the demographic herd
simulation.

Annual offtake is estimated as annual entrants into the nondemographic
block multiplied by survival to the terminal productive phase. If
productive phase 2 exists (`phase2_nondemo_duration > 0`), terminal
survival is: \$\$survival\\{terminal} =
\frac{cohort\\stock\\nondemo\\end\\phase2}{cohort\\stock\\nondemo\\start\\cycle}\$\$
Otherwise, terminal survival is taken from phase 1:
\$\$survival\\{terminal} =
\frac{cohort\\stock\\nondemo\\end\\phase1}{cohort\\stock\\nondemo\\start\\cycle}\$\$

Simulated annual offtake is then: \$\$offtake\\{sim} =
cohort\\stock\\nondemo\\annual\\entrants \times survival\\{terminal}\$\$

Offtake totals are scaled to the reporting period by converting to an
average daily offtake rate over the fixed 365-day simulated horizon and
multiplying by `simulation_duration`: \$\$offtake\\{assessment} =
offtake\\{sim} \times \frac{simulation\\duration}{365}\$\$

This function is part of the
[`run_nondemographic_herd_module()`](https://un-fao.github.io/GLEAM/reference/run_nondemographic_herd_module.md).

## See also

[`calc_nondemo_phase`](https://un-fao.github.io/GLEAM/reference/calc_nondemo_phase.md),
[`run_nondemographic_herd_module`](https://un-fao.github.io/GLEAM/reference/run_nondemographic_herd_module.md)
