# Calculate nondemographic cycle geometry

Calculates the number of full (including productive and resting phase)
and partial nondemographic production cycles that fit within a fixed
365-day time horizon, allowing for up to two productive phases per cycle
and an optional resting period between cycles.

## Usage

``` r
calc_nondemo_cycle_geometry(
  phase1_nondemo_duration,
  phase2_nondemo_duration,
  rest_between_nondemo_cycles_duration
)
```

## Arguments

- phase1_nondemo_duration:

  Numeric. Duration of productive phase 1 for the assessed
  nondemographic cohort (`FN` or `MN`) (days). Must be at least `1` day.

- phase2_nondemo_duration:

  Numeric. Duration of productive phase 2 for the assessed
  nondemographic cohort (`FN` or `MN`) (days). Use `0` when phase 2 is
  absent.

- rest_between_nondemo_cycles_duration:

  Numeric. Duration of the resting or empty phase between
  non-demographic cycles (days). Use `0` when there is no rest between
  cycles.

## Value

A named list with elements:

- number_full_nondemo_cycles:

  Integer. Number of complete cycles fully contained within the fixed
  365-day time horizon for the assessed non-demographic cohort (`FN` or
  `MN`) (# cycles).

- partial_phase1_nondemo_duration:

  Numeric. Duration of the terminal partial productive phase 1 occurring
  at the end of the fixed 365-day simulation horizon for the assessed
  nondemographic cohort (`FN` or `MN`) (days).

- partial_phase2_nondemo_duration:

  Numeric. Duration of the terminal partial productive phase 2 occurring
  at the end of the fixed 365-day simulation horizon for the assessed
  nondemographic cohort (`FN` or `MN`) (days).

- total_nondemo_cycle_starts_to_distribute:

  Integer. Total number of cycle starts within the fixed 365-day time
  horizon for the assessed non-demographic cohort (`FN` or `MN`) (#
  cycle starts).

- cycle_length:

  Numeric. Total duration of one full nondemographic cycle, including
  productive phases and the rest period between cycles (days).

## Details

A nondemographic production cycle can contain one or two productive
phases, followed by an optional resting period before the next cycle
starts. The function uses a fixed 365-day time horizon so the horizon
matches the demographic herd simulation.

A cycle consists of:

- Phase 1 (productive) of length `phase1_nondemo_duration`

- Optional Phase 2 (productive) of length `phase2_nondemo_duration`

- Optional rest between cycles (after the productive phases and before
  the next cycle starts) of length
  `rest_between_nondemo_cycles_duration`

The total length of one cycle is calculated as: \$\$ cycle\\length =
phase1\\non\\demo\\duration + phase2\\non\\demo\\duration +
rest\\between\\non\\demo\\cycles\\duration \$\$

The number of complete cycles fully contained within the fixed time
horizon is: \$\$ number\\full\\non\\demo\\cycles = \left\lfloor
\frac{time\\horizon}{cycle\\length} \right\rfloor \$\$

The time remaining after all complete cycles have been allocated is:
\$\$ time\\remaining = time\\horizon - number\\full\\non\\demo\\cycles
\times cycle\\length \$\$

Any time remaining after the full cycles is allocated sequentially to
the next cycle.

First, the remaining time is used to fill phase 1: \$\$
partial\\phase1\\nondemo\\duration = \min(time\\remaining,\\
phase1\\non\\demo\\duration) \$\$

The time left after phase 1 is: \$\$ time\\remaining2 =
time\\remaining - partial\\phase1\\nondemo\\duration \$\$

If:

- phase 2 exists (`phase2_nondemo_duration > 0`), and

- phase 1 was fully completed

then the remaining time is allocated to phase 2: \$\$
partial\\phase2\\nondemo\\duration = \min(time\\remaining2,\\
phase2\\non\\demo\\duration) \$\$

Each full cycle contributes one cycle start. In addition, if a partial
phase 1 is present (i.e. `partial_phase1_nondemo_duration > 0`), this
indicates that a new cycle has started.

Therefore: \$\$ total\\nondemo\\cycle\\starts\\to\\distribute =
number\\full\\non\\demo\\cycles + I(partial\\phase1\\nondemo\\duration
\> 0) \$\$

This function is part of the
[`run_nondemographic_herd_module()`](https://un-fao.github.io/GLEAM/reference/run_nondemographic_herd_module.md).

## See also

[`run_nondemographic_herd_module()`](https://un-fao.github.io/GLEAM/reference/run_nondemographic_herd_module.md)
