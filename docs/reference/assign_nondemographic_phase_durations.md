# Assign nondemographic phase durations to cohort rows

Maps herd-level nondemographic phase-duration inputs onto the
corresponding cohort-phase rows and fills `cohort_duration_days` for
`FN` and `MN`.

## Usage

``` r
assign_nondemographic_phase_durations(
  cohort_short,
  nondemo_productive_phase_id,
  cohort_duration_days = NA_real_,
  phase1_nondemo_fem_duration_days = NA_real_,
  phase2_nondemo_fem_duration_days = NA_real_,
  phase1_nondemo_mal_duration_days = NA_real_,
  phase2_nondemo_mal_duration_days = NA_real_
)
```

## Arguments

- cohort_short:

  Character. Sex-specific cohort code describing the age and/or the
  production stage of the animals. Supported values include:

  - `FN`: non-demographic females

  - `MN`: non-demographic males

- nondemo_productive_phase_id:

  Numeric. Identifier of the productive phase for non-demographic
  cohorts (`FN`, `MN`). Takes value `1` for phase 1 and optionally `2`
  for phase 2.

- cohort_duration_days:

  Numeric. Amount of time that each animal spends in a specific cohort
  and production phase (days). For `CHK`, suggested value for `FJ` and
  `MJ` cohorts: 3 days. Not required for `FN` and `MN` when phase
  durations are supplied in the herd table; the code fills it from the
  herd values, which override any cohort values.

- phase1_nondemo_fem_duration_days:

  Numeric. Duration of productive phase 1 for the female non-demographic
  cohort (`FN`) (days).

- phase2_nondemo_fem_duration_days:

  Numeric. Duration of productive phase 2 for the female non-demographic
  cohort (`FN`) (days).

- phase1_nondemo_mal_duration_days:

  Numeric. Duration of productive phase 1 for the male nondemographic
  cohort (`MN`) (days).

- phase2_nondemo_mal_duration_days:

  Numeric. Duration of productive phase 2 for the male non-demographic
  cohort (`MN`) (days).

## Value

Numeric vector. Updated `cohort_duration_days`. For non-demographic
cohorts (`FN` and `MN`), `cohort_duration_days` is not required when
phase durations are supplied in the herd table. The code fills it from
the herd values, which override any cohort values. If a herd value is
missing, the cohort value is used instead. All other cohorts keep their
original values.

## See also

[`run_nondemographic_herd_module()`](https://un-fao.github.io/GLEAM/reference/run_nondemographic_herd_module.md)
