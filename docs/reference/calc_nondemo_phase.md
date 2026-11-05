# Calculate a nondemographic productive phase

Simulates stock dynamics for a nondemographic productive phase within a
production cycle. This function is applied within
[`run_nondemographic_herd_module`](https://un-fao.github.io/GLEAM/reference/run_nondemographic_herd_module.md)
to model productive phase 1 and productive phase 2 under full and
terminal (partial) phase durations.

## Usage

``` r
calc_nondemo_phase(
  cohort_stock_nondemo_start_by_phase,
  productive_phase_nondemo_duration,
  death_rate_nondemo_phase,
  max_simulation_days_nondemo_phase
)
```

## Arguments

- cohort_stock_nondemo_start_by_phase:

  Numeric. Number of animals entering a nondemographic productive phase
  for the assessed cohort (`FN` or `MN`) (heads / phase). When used for
  productive phase 1, this represents the number of animals starting
  each nondemographic production cycle
  (`cohort_stock_nondemo_start_cycle`), computed using
  [`calc_nondemo_start_sizes()`](https://un-fao.github.io/GLEAM/reference/calc_nondemo_start_sizes.md).
  When used for productive phase 2, this represents the number of
  animals surviving productive phase 1 and entering productive phase 2,
  obtained as the end stock of the productive phase 1 simulation.

- productive_phase_nondemo_duration:

  Numeric. Duration of the productive phase within a nondemographic
  production cycle for the assessed cohort (`FN` or `MN`) (days). When
  applied to productive phase 1, this parameter corresponds to
  `phase1_nondemo_duration`. When applied to productive phase 2, it
  corresponds to `phase2_nondemo_duration`.

- death_rate_nondemo_phase:

  Numeric. Fraction of animals dying during the productive phase for the
  assessed nondemographic cohort (`FN` or `MN`) (fraction).

- max_simulation_days_nondemo_phase:

  Numeric. Maximum number of days to simulate for the productive phase
  (days). Use the full phase duration to simulate a complete productive
  phase, or a shorter value to simulate a terminal partial phase within
  the simulated period. When applied to productive phase 1, this
  parameter is set either to the full phase duration
  (`phase1_nondemo_duration`) or to `partial_phase1_nondemo_duration`.
  When applied to productive phase 2, it is analogously set to the full
  phase duration (`phase2_nondemo_duration`) or to
  `partial_phase2_nondemo_duration`.

## Value

A named list with:

- time_simulated_nondemographic:

  Numeric. Number of days simulated for the productive phase (days).

- cohort_stock_nondemo:

  List with:

  `start`

  :   Numeric. Number of animals at the beginning of the simulated
      productive phase (heads).

  `end`

  :   Numeric. Number of animals remaining at the end of the simulated
      productive phase after applying mortality over the simulated time
      interval (heads).

## Details

The function converts the phase-level mortality probability
(`death_rate_nondemo_phase`) into an implied daily mortality probability
under the assumption of constant daily mortality throughout the phase.
The implied daily mortality is derived so that cumulative survival over
the full phase duration (`productive_phase_nondemo_duration`) is equal
to \\1 - death_rate_nondemo_phase\\.

Daily mortality is calculated as: \$\$ death\\rate\\daily\\nondemo = 1 -
(1 - death\\rate\\nondemo\\phase)^{1 /
productive\\phase\\nondemo\\duration} \$\$

and the corresponding daily survival probability is: \$\$
survival\\rate\\daily\\nondemo = 1 - death\\rate\\daily\\nondemo \$\$

The number of simulated days is limited by both the total phase duration
and the maximum number of days allowed for the current simulation step:
\$\$ time\\simulated\\nondemographic =
\min(max\\simulation\\days\\nondemo\\phase,\\
productive\\phase\\nondemo\\duration) \$\$

End-of-phase stock is then calculated by applying constant daily
survival to the starting stock over the simulated period: \$\$
cohort\\stock\\nondemo\_{end} = cohort\\stock\\nondemo\\start\\by\\phase
\times survival\\rate\\daily\\nondemo^{time\\simulated\\nondemographic}
\$\$

Equivalently: \$\$ cohort\\stock\\nondemo\_{end} =
cohort\\stock\\nondemo\\start\\by\\phase \times (1 -
death\\rate\\daily\\nondemo)^{time\\simulated\\nondemographic} \$\$

If `productive_phase_nondemo_duration` is `NULL` or less than or equal
to zero, the function assumes that no productive phase is simulated. In
this case, mortality is set to zero, simulated time is set to zero, and
both starting and ending stock are returned as zero.

No rounding is applied to stock values. Therefore, fractional values may
occur in `cohort_stock_nondemo_{end}`.

This function is part of the
[`run_nondemographic_herd_module()`](https://un-fao.github.io/GLEAM/reference/run_nondemographic_herd_module.md).

## See also

[`run_nondemographic_herd_module()`](https://un-fao.github.io/GLEAM/reference/run_nondemographic_herd_module.md)
