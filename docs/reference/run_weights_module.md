# Run Weights Module Pipeline

Calculates cohort-level live weight metrics by combining cohort-level
inputs with herd-level biological parameters. The function appends
cohort weights (initial, potential final, slaughter), then derives
average and final live weights accounting for offtake, and finally
computes average daily live weight gain over each cohort stage.

## Usage

``` r
run_weights_module(cohort_level_data, herd_level_data, show_indicator = TRUE)
```

## Arguments

- cohort_level_data:

  A `data.table` in long format with one row per herd \\\times\\ cohort.
  Must include:

  herd_id

  :   Character. Unique identifier for the herd, repeated for each
      cohort belonging to the same herd.

  cohort_short

  :   Character. Sex- and age-specific cohort code describing the
      production stage of the animals. Supported values include:

      - `FA`: adult females (from age at first parturition)

      - `FS`: sub-adult females (from weaning to age at first
        parturition)

      - `FJ`: juvenile females (from birth to weaning)

      - `MA`: adult males (from age at first breeding)

      - `MS`: sub-adult males (from weaning to age at first breeding)

      - `MJ`: juvenile males (from birth to weaning)

      - `FN`: non-demographic females

      - `MN`: non-demographic males

  cohort_duration_days

  :   Numeric. Amount of time that each animal spends in a specific
      cohort (days). For `CHK`, suggested value for `FJ` and `MJ`
      cohorts: 3 days.

  offtake_rate

  :   Numeric. Annual proportion of animals removed from the herd for
      each sex-age cohort (fraction).

  Optional column:

  nondemo_productive_phase_id

  :   Numeric. Productive phase identifier for non-demographic cohorts
      (`FN`, `MN`). Allowed values are `1` and optionally `2`.
      Demographic cohorts use `NA`.

- herd_level_data:

  A `data.table` with one row per herd. Must include:

  - `herd_id` Character. Unique identifier for the herd.

  - `species_short` Character. Code identifying the livestock species.
    Supported values include:

    - `PGS`: pigs

    - `CML`: camels

    - `CTL`: cattle

    - `BFL`: buffalo

    - `SHP`: sheep

    - `GTS`: goats

    - `CHK`: chickens

  - `live_weight_female_adult` Numeric. Live weight of adult females
    (kg), required when female demographic cohorts (`FJ`, `FS`, `FA`)
    are present.

  - `live_weight_male_adult` Numeric. Live weight of adult males (kg),
    required when male demographic cohorts (`MJ`, `MS`, `MA`) are
    present.

  - `live_weight_at_birth` Numeric. Live weight of the animal at birth
    (kg), required when juvenile demographic cohorts (`FJ`, `MJ`) are
    present.

  - `live_weight_at_weaning` Numeric. Live weight of the animal at
    weaning (kg), required when juvenile demographic cohorts (`FJ`,
    `MJ`) are present.

  - `live_weight_female_at_slaughter` Numeric. Slaughter weight of
    female sub-adult animals (kg), required when `FS` is present.

  - `live_weight_male_at_slaughter` Numeric. Slaughter weight of male
    sub-adult animals (kg), required when `MS` is present.

  - `live_weight_female_nondemographic_start` Numeric. Live weight at
    the beginning of the female non-demographic cycle (kg), when `FN` is
    present.

  - `live_weight_female_nondemographic_end` Numeric. Live weight at the
    end of the female non-demographic cycle (kg), when `FN` is present.

  - `live_weight_male_nondemographic_start` Numeric. Live weight at the
    beginning of the male non-demographic cycle (kg), when `MN` is
    present.

  - `live_weight_male_nondemographic_end` Numeric. Live weight at the
    end of the male non-demographic cycle (kg), when `MN` is present.

  - `phase1_nondemo_fem_duration_days` Numeric. Productive phase 1
    duration for `FN` (days), when `FN` is present.

  - `phase2_nondemo_fem_duration_days` Numeric. Productive phase 2
    duration for `FN` (days), optional.

  - `phase1_nondemo_mal_duration_days` Numeric. Productive phase 1
    duration for `MN` (days), when `MN` is present.

  - `phase2_nondemo_mal_duration_days` Numeric. Productive phase 2
    duration for `MN` (days), optional.

- show_indicator:

  Logical. Whether to display progress indicators during calculations.
  Defaults to `TRUE`.

## Value

A named list with two `data.table`s:

- cohort_level_results:

  The input `cohort_level_data` with these additional columns:

  live_weight_mature_stage

  :   Numeric. Mature (adult) live weight that the animal can attain
      under given biological and management conditions (kg).

  live_weight_cohort_initial

  :   Numeric. Live weight at the beginning of the cohort stage (kg).

  live_weight_cohort_potential_final

  :   Numeric. Potential final live weight attainable at the end of the
      cohort stage in the absence of offtake (kg). (For juveniles:
      equals weaning weight; For subadults: equals adult live weight;
      For adults: equals adult live weight)

  live_weight_cohort_at_slaughter

  :   Numeric. Live weight at slaughter for animals removed from the
      cohort (kg).

  live_weight_cohort_average

  :   Numeric. Average live weight over the cohort stage. Computed by
      accounting for the share of offtaken animals within the cohort,
      using their slaughter weight, and the potential final weight of
      animals that remain in the cohort (kg).

  live_weight_cohort_final

  :   Numeric. Live weight at the end of the cohort stage, accounting
      for both surviving and offtaken animals. Computed as a weighted
      average of the potential final weight of surviving animals and the
      slaughter weight of offtaken animals, based on the offtake rate
      (kg).

  daily_weight_gain

  :   Numeric. Average live weight gain of the cohort over the cohort
      stage (kg/head/day).

- herd_level_results:

  A copy of the input `herd_level_data`.

## Details

Species is read from `herd_level_data$species_short`, matched to cohort
rows by `herd_id`. Demographic weight columns may be omitted when the
cohort table contains only `FN` and `MN`; their weights come from the
non-demographic start/end weights and phase durations.

This function represents the intermediate module of the Global Livestock
Environmental Assessment Model (GLEAM) computational pipeline
[`run_gleam()`](https://un-fao.github.io/GLEAM/reference/run_gleam.md)
to estimate animals' live weight and is composed of the following steps:

1.  **Cohort-stage weight assignment** using
    [`calc_cohort_weights`](https://un-fao.github.io/GLEAM/reference/calc_cohort_weights.md).
    Herd-level biological parameters are matched to each cohort row by
    `herd_id` via `data.table` joins. For non-demographic cohorts (`FN`,
    `MN`), the function uses `nondemo_productive_phase_id` together with
    herd-level start/end live weights and phase durations to assign
    phase-specific initial and final weights.

2.  **Calculation of average and final live weights (accounting for
    offtake)** using
    [`calc_avg_weights`](https://un-fao.github.io/GLEAM/reference/calc_avg_weights.md).
    For non-demographic cohorts, `offtake_rate` is ignored and the final
    weight equals the phase-specific potential final weight.

3.  **Calculation of average daily live weight gain** using
    [`calc_daily_weight_gain`](https://un-fao.github.io/GLEAM/reference/calc_daily_weight_gain.md).

## See also

[`run_gleam`](https://un-fao.github.io/GLEAM/reference/run_gleam.md),
[`calc_cohort_weights`](https://un-fao.github.io/GLEAM/reference/calc_cohort_weights.md),
[`calc_avg_weights`](https://un-fao.github.io/GLEAM/reference/calc_avg_weights.md),
[`calc_daily_weight_gain`](https://un-fao.github.io/GLEAM/reference/calc_daily_weight_gain.md),

## Examples

``` r
# \donttest{
# Load weights inputs (cohort and herd-level)
weights_chrt_dt <- data.table::fread(system.file(
  "extdata/run_modules_examples/weights_input_chrt_data.csv",
  package = "gleam"
))
weights_hrd_dt <- data.table::fread(system.file(
  "extdata/run_modules_examples/weights_input_hrd_data.csv",
  package = "gleam"
))

# Run weight calculations
results <- run_weights_module(
  cohort_level_data = weights_chrt_dt,
  herd_level_data = weights_hrd_dt
)
#> 🕒 Calculating cohort weights, please wait…
#> ✔ Cohort weights calculation complete.
# }
```
