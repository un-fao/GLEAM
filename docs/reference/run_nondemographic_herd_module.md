# Run Non-Demographic Herd Module Pipeline

This function takes herd- and cohort-level non-demographic inputs and
simulates production-cycle dynamics for the non-demographic cohorts used
in the Global Livestock Environmental Assessment Model (GLEAM)
computational pipeline
[`run_gleam()`](https://un-fao.github.io/GLEAM/reference/run_gleam.md).
It computes phase-specific average stock sizes and offtake numbers.
Annual average stock and offtake include animals that entered before the
assessment year, so productive phases can span year boundaries. Stock is
returned unscaled;
[`run_all_herd_module()`](https://un-fao.github.io/GLEAM/reference/run_all_herd_module.md)
applies any supplied herd-size target.

## Usage

``` r
run_nondemographic_herd_module(
  cohort_level_data,
  herd_level_data,
  simulation_duration = 365,
  show_indicator = TRUE
)
```

## Arguments

- cohort_level_data:

  A `data.table` with one row per herd, cohort, and productive phase,
  and the following mandatory columns:

  `herd_id`

  :   Character. Unique identifier for the herd, repeated for each
      cohort belonging to the same herd.

  `cohort_short`

  :   Character. Sex-specific cohort code describing the age and/or the
      production stage of the animals. Supported values include:

      - `FN`: non-demographic females

      - `MN`: non-demographic males

  `nondemo_productive_phase_id`

  :   Numeric. Identifier of the productive phase for non-demographic
      cohorts (`FN`, `MN`). Takes value `1` for phase 1 and optionally
      `2` for phase 2.

  `death_rate`

  :   Numeric. Fraction of animals dying in the assessed cohort over the
      productive phase for non-demographic cohorts (fraction).

  `cohort_duration_days` is not required for `FN` and `MN` when phase
  durations are supplied in the herd table.

- herd_level_data:

  A `data.table` with one row per herd, and the following mandatory
  columns:

  `herd_id`

  :   Character. Unique identifier for the herd.

  `cohort_stock_fem_annual_nondemo`

  :   Numeric. Annual number of female animals entering the
      non-demographic pathway (`FN`) over the 365-time horizon (#
      heads).

  `cohort_stock_mal_annual_nondemo`

  :   Numeric. Annual number of male animals entering the
      non-demographic pathway (`MN`) over the 365-time horizon (#
      heads).

  `rest_between_nondemo_cycles_duration`

  :   Numeric. Duration of the resting or empty phase between
      non-demographic cycles (days). Use `0` when there is no rest
      between cycles.

  `phase1_nondemo_fem_duration_days`

  :   Numeric. Duration of productive phase 1 for the female
      non-demographic cohort (`FN`) (days).

  `phase2_nondemo_fem_duration_days`

  :   Numeric. Duration of productive phase 2 for the female
      non-demographic cohort (`FN`) (days).

  `phase1_nondemo_mal_duration_days`

  :   Numeric. Duration of productive phase 1 for the male
      nondemographic cohort (`MN`) (days).

  `phase2_nondemo_mal_duration_days`

  :   Numeric. Duration of productive phase 2 for the male
      non-demographic cohort (`MN`) (days).

- simulation_duration:

  Numeric. Length of the assessment period (days).

- show_indicator:

  Logical. Whether to display progress indicators during simulation.
  Defaults to `TRUE`.

## Value

A named list with two elements:

- `cohort_level_results`:

  A `data.table` with one row per retained herd, non-demographic cohort
  block, and productive phase, containing the original
  `cohort_level_data` columns plus:

  `cohort_duration_days`

  :   Numeric. Amount of time that each animal spends in a specific
      cohort and production phase (days). For `CHK`, suggested value for
      `FJ` and `MJ` cohorts: 3 days. Not required for `FN` and `MN` when
      phase durations are supplied in the herd table; the code fills it
      from the herd values, which override any cohort values.

  `cohort_stock_size_unscaled`

  :   Numeric. Average population size of the assessed cohort, not
      scaled to the total livestock population (herd_size_total) (#
      heads).

  `partial_nondemo_phase_duration`

  :   Numeric. Duration of the terminal partial productive phase falling
      within the fixed 365-day non-demographic simulation horizon
      (days).

  `offtake_heads_unscaled`

  :   Numeric. Total number of animals removed from each cohort over the
      full 365-day simulation horizon, not scaled to the cohort
      population at the start of the assessment (# heads).

  `offtake_heads_assessment_unscaled`

  :   Numeric. Total number of animals removed from each cohort over the
      assessment period, not scaled to the cohort population at the
      start of the assessment (# heads/assessment period).

  `number_full_nondemo_cycles`

  :   Integer. Number of complete cycles fully contained within the
      fixed 365-day time horizon for the assessed non-demographic cohort
      (`FN` or `MN`) (# cycles).

  `total_nondemo_cycle_starts_to_distribute`

  :   Integer. Total number of cycle starts within the fixed 365-day
      time horizon for the assessed non-demographic cohort (`FN` or
      `MN`) (# cycle starts).

- `herd_level_results`:

  A `data.table` with one row per `herd_id` containing the original
  `herd_level_data` columns plus:

  `total_nondemo_fem_duration_days`

  :   Numeric. Total duration of the productive non-demographic phases
      assigned to the female non-demographic cohort block (`FN`) (days).

  `total_nondemo_mal_duration_days`

  :   Numeric. Total duration of the productive non-demographic phases
      assigned to the male non-demographic cohort block (`MN`) (days).

## Details

The function operates over a **365-day simulation horizon** to maintain
consistency with the demographic herd module. For each herd and
non-demographic cohort block, it computes how many complete production
cycles fit within the horizon, whether an additional partial cycle is
present, and how annual entrants should be distributed across cycle
starts.

A key feature of this implementation is that it applies mortality at the
**phase level**. Phase-level mortality fractions are converted to
implied daily mortality probabilities, and the resulting daily survival
is used to compute end-of-phase stock, average stock over the horizon,
and total offtake.

### Model structure

The non-demographic population is divided into two cohort blocks:

- `FN`: non-demographic female animals

- `MN`: non-demographic male animals

Each cohort block may contain up to two sequential productive phases,
identified by `nondemo_productive_phase_id = 1` and optionally
`nondemo_productive_phase_id = 2`. A resting period between cycles is
supplied at herd level through `rest_between_nondemo_cycles_duration`.

### Dynamics and parameters

Non-demographic herd dynamics result from:

- annual entrants into each non-demographic cohort block

- mortality during each productive phase (`death_rate`)

- phase duration (`cohort_duration_days`), either supplied directly in
  the cohort table or derived later from herd-level phase-duration
  inputs

- the duration of the resting period between cycles

For each herd and cohort block, the function:

1.  identifies phase 1 and optional phase 2 from `cohort_level_data`

2.  computes cycle geometry using
    [`calc_nondemo_cycle_geometry`](https://un-fao.github.io/GLEAM/reference/calc_nondemo_cycle_geometry.md)

3.  distributes annual entrants across cycle starts using
    [`calc_nondemo_start_sizes`](https://un-fao.github.io/GLEAM/reference/calc_nondemo_start_sizes.md)

4.  simulates stock dynamics within each phase using
    [`calc_nondemo_phase`](https://un-fao.github.io/GLEAM/reference/calc_nondemo_phase.md)

5.  computes average stock over the assessment horizon using
    [`calc_nondemo_avg_stock_phase_horizon`](https://un-fao.github.io/GLEAM/reference/calc_nondemo_avg_stock_phase_horizon.md)

6.  computes total and assessment-window offtake using
    [`calc_nondemo_offtake_total_horizon`](https://un-fao.github.io/GLEAM/reference/calc_nondemo_offtake_total_horizon.md)

## See also

[`calc_nondemo_cycle_geometry`](https://un-fao.github.io/GLEAM/reference/calc_nondemo_cycle_geometry.md),
[`calc_nondemo_start_sizes`](https://un-fao.github.io/GLEAM/reference/calc_nondemo_start_sizes.md),
[`calc_nondemo_phase`](https://un-fao.github.io/GLEAM/reference/calc_nondemo_phase.md),
[`calc_nondemo_avg_stock_phase_horizon`](https://un-fao.github.io/GLEAM/reference/calc_nondemo_avg_stock_phase_horizon.md),
[`calc_nondemo_offtake_total_horizon`](https://un-fao.github.io/GLEAM/reference/calc_nondemo_offtake_total_horizon.md)

## Examples

``` r
# \donttest{
# Load non-demographic herd simulation inputs (FN/MN cohorts and annual entrants)
nondemo_chrt_dt <- data.table::fread(system.file(
  "extdata/run_modules_examples/nondemographic_herd_input_chrt_data.csv",
  package = "gleam"
))
nondemo_hrd_dt <- data.table::fread(system.file(
  "extdata/run_modules_examples/nondemographic_herd_input_hrd_data.csv",
  package = "gleam"
))

# Run non-demographic herd simulation
results <- run_nondemographic_herd_module(
  cohort_level_data = nondemo_chrt_dt,
  herd_level_data = nondemo_hrd_dt,
  simulation_duration = 365,
  show_indicator = TRUE
)
#> 🕒 Simulating the non-demographic herd, please wait…
#> ✔ Non-demographic herd simulation complete.
# }
```
