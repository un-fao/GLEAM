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

  Character. Sex- and production-stage-specific cohort code describing
  the animal group. Supported values include:

  - `FA`: adult females (from age at first parturition)

  - `FS`: sub-adult females (from weaning to age at first parturition)

  - `FJ`: juvenile females (from birth to weaning)

  - `MA`: adult males (from age at first breeding)

  - `MS`: sub-adult males (from weaning to age at first breeding)

  - `MJ`: juvenile males (from birth to weaning)

  - `FN`: non-demographic females

  - `MN`: non-demographic males

- nondemo_productive_phase_id:

  Numeric. Identifier of the productive phase for nondemographic cohorts
  `FN` and `MN`. Takes value `1` for phase 1 and optionally `2` for
  phase 2. Demographic cohorts use `NA`.

- cohort_duration_days:

  Numeric. Amount of time that each animal spends in a specific cohort
  (days). Not required for `FN` and `MN` when phase durations are
  supplied in the herd table.

- phase1_nondemo_fem_duration_days:

  Numeric. Duration of productive phase 1 for the female nondemographic
  cohort (`FN`) (days).

- phase2_nondemo_fem_duration_days:

  Numeric. Duration of productive phase 2 for the female nondemographic
  cohort (`FN`) (days).

- phase1_nondemo_mal_duration_days:

  Numeric. Duration of productive phase 1 for the male nondemographic
  cohort (`MN`) (days).

- phase2_nondemo_mal_duration_days:

  Numeric. Duration of productive phase 2 for the male nondemographic
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
