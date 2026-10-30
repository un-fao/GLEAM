# Run Combined Herd Module Pipeline

This function orchestrates the demographic herd module
[`run_demographic_herd_module()`](https://un-fao.github.io/GLEAM/reference/run_demographic_herd_module.md)
and the non-demographic herd module
[`run_nondemographic_herd_module()`](https://un-fao.github.io/GLEAM/reference/run_nondemographic_herd_module.md)
within a single wrapper. Depending on the selected logical switches, it
runs the demographic module, the non-demographic module, or both, and
returns a harmonized herd-module output structure for downstream use in
[`run_gleam()`](https://un-fao.github.io/GLEAM/reference/run_gleam.md).

## Usage

``` r
run_all_herd_module(
  cohort_level_data = NULL,
  herd_level_data = NULL,
  simulation_duration = 365,
  show_indicator = TRUE,
  run_demographic = TRUE,
  run_nondemographic = TRUE
)
```

## Arguments

- cohort_level_data:

  A `data.table` with one row per `herd_id` and cohort. Required rows
  and columns depend on the selected execution mode:

  - **Case 1 - when `run_demographic = TRUE` and
    `run_nondemographic = FALSE`:** `cohort_level_data` must contain
    rows for the demographic cohorts only (`FA`, `FJ`, `FS`, `MA`, `MJ`,
    `MS`). In this case the table must contain the columns required by
    [`run_demographic_herd_module()`](https://un-fao.github.io/GLEAM/reference/run_demographic_herd_module.md):

    `herd_id`

    :   Character. Unique identifier for the herd, repeated for each
        cohort belonging to the same herd.

    `cohort_short`

    :   Character. Demographic cohort code. Supported values are `FJ`,
        `FS`, `FA`, `MJ`, `MS`, and `MA`.

    `cohort_duration_days`

    :   Numeric. Amount of time that each animal spends in the
        demographic cohort (days).

    `offtake_rate`

    :   Numeric. Annual proportion of animals removed from the herd for
        each demographic cohort (fraction).

    `death_rate`

    :   Numeric. Fraction of deaths in a herd over a year for each
        demographic cohort (fraction).

  - **Case 2 - when `run_demographic = FALSE` and
    `run_nondemographic = TRUE`:** `cohort_level_data` must contain rows
    for the non-demographic cohorts only (`FN`, `MN`). In this case the
    table must contain the columns required by
    [`run_nondemographic_herd_module()`](https://un-fao.github.io/GLEAM/reference/run_nondemographic_herd_module.md):

    `herd_id`

    :   Character. Unique identifier for the herd, repeated for each
        non-demographic cohort phase belonging to the same herd.

    `cohort_short`

    :   Character. Non-demographic cohort code. Supported values are
        `FN` for non-demographic female animals and `MN` for
        non-demographic male animals.

    `nondemo_productive_phase_id`

    :   Numeric. Productive phase identifier within a non-demographic
        cycle. `1` is required and `2` is optional.

    `death_rate`

    :   Numeric. Fraction of deaths occurring during the non-demographic
        productive phase (fraction).

  - **Case 3 - when `run_demographic = TRUE` and
    `run_nondemographic = TRUE`:** `cohort_level_data` must contain both
    demographic and non-demographic rows. In this case the table must
    satisfy both sets of requirements described above. Internally,
    `run_all_herd_module()` splits the combined input into demographic
    and non-demographic subsets using `cohort_short`.

- herd_level_data:

  A `data.table` with one row per `herd_id`. This table is required in
  all execution modes. Required columns depend on the selected execution
  mode:

  - **Case 1 - when `run_demographic = TRUE` and
    `run_nondemographic = FALSE`:** `herd_level_data` must contain the
    herd-level inputs required by
    [`run_demographic_herd_module()`](https://un-fao.github.io/GLEAM/reference/run_demographic_herd_module.md):

    `herd_id`

    :   Character. Unique identifier for the herd.

    `parturition_rate`

    :   Numeric. Average annual number of parturitions per female animal
        (# parturitions/adult female/year). For `CHK`, this corresponds
        to eggs laid for reproduction.

    `litter_size`

    :   Numeric. Average number of offspring produced per parturition (#
        offspring/parturition). For `CHK`, this can be interpreted as
        offspring produced per reproductive event.

    `birth_fraction_female`

    :   Numeric. Female birth fraction, defined as the probability that
        a newborn offspring is female (fraction).

    `herd_size_total`

    :   Numeric. Total population size at the start of the year,
        including all cohorts (# heads).

    `prop_nondemo_mal_juv`

    :   Numeric. Fraction of male juveniles diverted into the
        non-demographic stream at the moment they transition to the next
        age class (fraction).

    `prop_nondemo_fem_juv`

    :   Numeric. Fraction of female juveniles diverted into the
        non-demographic stream at the moment they transition to the next
        age class (fraction).

  - **Case 2 - when `run_demographic = FALSE` and
    `run_nondemographic = TRUE`:** `herd_level_data` must contain the
    herd-level inputs required by
    [`run_nondemographic_herd_module()`](https://un-fao.github.io/GLEAM/reference/run_nondemographic_herd_module.md):

    `herd_id`

    :   Character. Unique identifier for the herd.

    `cohort_stock_fem_annual_nondemo`

    :   Numeric. Total annual entrants into the `FN` cohort block over
        the simulated period (# heads / simulated period).

    `cohort_stock_mal_annual_nondemo`

    :   Numeric. Total annual entrants into the `MN` cohort block over
        the simulated period (# heads / simulated period).

    `rest_between_nondemo_cycles_duration`

    :   Numeric. Duration of the resting or empty phase between
        non-demographic cycles (days).

    `phase1_nondemo_fem_duration_days`

    :   Numeric. Duration of productive phase 1 for the female
        non-demographic cohort (`FN`) (days).

    `phase2_nondemo_fem_duration_days`

    :   Numeric. Duration of productive phase 2 for the female
        non-demographic cohort (`FN`) (days).

    `phase1_nondemo_mal_duration_days`

    :   Numeric. Duration of productive phase 1 for the male
        non-demographic cohort (`MN`) (days).

    `phase2_nondemo_mal_duration_days`

    :   Numeric. Duration of productive phase 2 for the male
        non-demographic cohort (`MN`) (days).

  - **Case 3 - when `run_demographic = TRUE` and
    `run_nondemographic = TRUE`:** `herd_level_data` must contain the
    demographic herd inputs required by
    [`run_demographic_herd_module()`](https://un-fao.github.io/GLEAM/reference/run_demographic_herd_module.md),
    plus the non-demographic cycle-duration inputs required to run
    [`run_nondemographic_herd_module()`](https://un-fao.github.io/GLEAM/reference/run_nondemographic_herd_module.md)
    after annual non-demographic entrants are derived internally from
    the demographic output:

    `herd_id`

    :   Character. Unique identifier for the herd.

    `parturition_rate`

    :   Numeric. Average annual number of parturitions per female animal
        (# parturitions/adult female/year). For `CHK`, this corresponds
        to eggs laid for reproduction.

    `litter_size`

    :   Numeric. Average number of offspring produced per parturition (#
        offspring/parturition). For `CHK`, this can be interpreted as
        offspring produced per reproductive event.

    `birth_fraction_female`

    :   Numeric. Female birth fraction, defined as the probability that
        a newborn offspring is female (fraction).

    `herd_size_total`

    :   Numeric. Total population size at the start of the year,
        including all cohorts (# heads).

    `prop_nondemo_mal_juv`

    :   Numeric. Fraction of male juveniles diverted into the
        non-demographic stream at the moment they transition to the next
        age class (fraction).

    `prop_nondemo_fem_juv`

    :   Numeric. Fraction of female juveniles diverted into the
        non-demographic stream at the moment they transition to the next
        age class (fraction).

    `rest_between_nondemo_cycles_duration`

    :   Numeric. Duration of the resting or empty phase between
        non-demographic cycles (days).

    `phase1_nondemo_fem_duration_days`

    :   Numeric. Duration of productive phase 1 for the female
        non-demographic cohort (`FN`) (days).

    `phase2_nondemo_fem_duration_days`

    :   Numeric. Duration of productive phase 2 for the female
        non-demographic cohort (`FN`) (days).

    `phase1_nondemo_mal_duration_days`

    :   Numeric. Duration of productive phase 1 for the male
        non-demographic cohort (`MN`) (days).

    `phase2_nondemo_mal_duration_days`

    :   Numeric. Duration of productive phase 2 for the male
        non-demographic cohort (`MN`) (days).

    In this combined mode, `cohort_stock_fem_annual_nondemo` and
    `cohort_stock_mal_annual_nondemo` are omitted because derived
    internally from the demographic output and therefore do not need to
    be supplied as primary herd-level inputs.

- simulation_duration:

  Numeric. Length of the reporting period (days).

- show_indicator:

  Logical. Whether to display progress indicators during calculations.
  Defaults to `TRUE`.

- run_demographic:

  Logical. If `TRUE`, run
  [`run_demographic_herd_module()`](https://un-fao.github.io/GLEAM/reference/run_demographic_herd_module.md).

- run_nondemographic:

  Logical. If `TRUE`, run
  [`run_nondemographic_herd_module()`](https://un-fao.github.io/GLEAM/reference/run_nondemographic_herd_module.md).

## Value

A named list with two elements:

- `cohort_level_results`:

  A `data.table` with one row per retained cohort. Depending on the
  selected execution mode, this table contains demographic rows only,
  non-demographic rows only, or both in a harmonized schema.
  Intermediate scaling variables are removed before return. It includes
  the original cohort-level input columns plus the following result
  variables when available:

  `cohort_stock_size`

  :   Numeric. Average population size for the assessed cohort (#
      heads).

  `offtake_heads`

  :   Numeric. Total number of animals removed from the cohort over the
      full 365-day simulation horizon (# heads).

  `offtake_heads_assessment`

  :   Numeric. Total number of animals removed from the cohort over
      `simulation_duration` (# heads / simulated period).

  `cohort_stock_annual_nondemographic`

  :   Numeric. For demographic rows only, annual number of animals
      diverted from the demographic pathway into the non-demographic
      pathway (# heads).

  `nondemo_productive_phase_id`

  :   Numeric. For non-demographic rows only, productive phase
      identifier within the non-demographic cycle. Allowed values are
      `1` and optionally `2`.

  `partial_nondemo_phase_duration`

  :   Numeric. For non-demographic rows only, duration of the terminal
      partial productive phase falling within the fixed 365-day
      non-demographic simulation horizon (days).

  `number_full_nondemo_cycles`

  :   Integer. For non-demographic rows only, number of complete
      non-demographic cycles fully contained within the fixed 365-day
      simulation horizon (# cycles).

  `total_nondemo_cycle_starts_to_distribute`

  :   Integer. For non-demographic rows only, total number of cycle
      starts within the fixed 365-day simulation horizon used to
      distribute annual entrants (# cycle starts).

- `herd_level_results`:

  A `data.table` with one row per `herd_id`. Depending on the selected
  execution mode, this is the herd-level output of the demographic
  module, the non-demographic module, or the merged herd-level output of
  both modules. It includes the original herd-level input columns plus
  the following result variables when available:

  `growth_rate_herd`

  :   Numeric. Annualized growth rate at which the herd reaches steady
      state (fraction).

  `cohort_stock_fem_annual_nondemo`

  :   Numeric. Annual number of female animals entering the
      non-demographic pathway (`FN`) over the simulated period (#
      heads). When both modules are run, this is derived internally from
      the demographic output.

  `cohort_stock_mal_annual_nondemo`

  :   Numeric. Annual number of male animals entering the
      non-demographic pathway (`MN`) over the simulated period (#
      heads). When both modules are run, this is derived internally from
      the demographic output.

  `rest_between_nondemo_cycles_duration`

  :   Numeric. Duration of the resting or empty phase between
      non-demographic cycles (days).

  `total_nondemo_fem_duration_days`

  :   Numeric. Total duration of the productive non-demographic phases
      assigned to the female non-demographic cohort block (`FN`) (days).

  `total_nondemo_mal_duration_days`

  :   Numeric. Total duration of the productive non-demographic phases
      assigned to the male non-demographic cohort block (`MN`) (days).

## Details

The function supports three execution modes:

1.  Demographic only: see
    [`run_demographic_herd_module()`](https://un-fao.github.io/GLEAM/reference/run_demographic_herd_module.md)
    for additional details.

2.  Non-demographic only: see
    [`run_nondemographic_herd_module()`](https://un-fao.github.io/GLEAM/reference/run_nondemographic_herd_module.md)
    for additional details.

3.  Demographic and non-demographic together: When
    `run_demographic = TRUE` and `run_nondemographic = TRUE`, the
    function:

    1.  runs
        [`run_demographic_herd_module()`](https://un-fao.github.io/GLEAM/reference/run_demographic_herd_module.md)
        on the demographic subset

    2.  derives annual non-demographic entrants from the demographic
        output

    3.  runs
        [`run_nondemographic_herd_module()`](https://un-fao.github.io/GLEAM/reference/run_nondemographic_herd_module.md)
        on the non-demographic subset

    4.  row-binds the two cohort-level result tables

    5.  harmonizes shared output columns

    6.  rescales average stock and offtake to the herd total

When both modules are run, annual entrants into the non-demographic
blocks are derived from the demographic output:

- female entrants to `FN` are taken from demographic cohort `FJ` as
  `cohort_stock_fem_annual_nondemo = cohort_stock_annual_nondemographic`

- male entrants to `MN` are taken from demographic cohort `MJ` as
  `cohort_stock_mal_annual_nondemo = cohort_stock_annual_nondemographic`

These entrant counts are merged with herd-level non-demographic timing
inputs such as:

- `rest_between_nondemo_cycles_duration`

- `phase1_nondemo_fem_duration_days`

- `phase2_nondemo_fem_duration_days`

- `phase1_nondemo_mal_duration_days`

- `phase2_nondemo_mal_duration_days`

After the selected modules run, the function combines their cohort-level
outputs using
`data.table::rbindlist(..., use.names = TRUE, fill = TRUE)`. This allows
demographic and non-demographic rows to share a common schema.

The combined cohort output harmonizes, when needed:

- `offtake_heads`

- `offtake_heads_assessment`

- `cohort_duration_days`

- `death_rate`

- `cohort_stock_size`

When both modules are run, intermediate unscaled cohort stock and
offtake outputs are combined and rescaled so that the summed cohort
average stock matches `herd_size_total` from `herd_level_data`. The same
rescaling applies to non-demographic-only runs when `herd_size_total` is
supplied.

The rescaling is performed in two steps:

1.  `cohort_stock_size_unscaled` is rescaled internally to
    `cohort_stock_size` within each `herd_id`

2.  `offtake_heads_unscaled` and `offtake_heads_assessment_unscaled` are
    rescaled proportionally to the final `cohort_stock_size`

When only the demographic module is run, its scaled outputs are renamed
to the harmonized final output names. Non-demographic-only runs without
`herd_size_total` return unscaled stock and offtake under those names.

The function then rescales the combined cohort stock and offtake outputs
so that the summed cohort average stock matches `herd_size_total` from
`herd_level_data`.

The rescaling is performed in two steps:

1.  `cohort_stock_size_unscaled` is rescaled to `cohort_stock_size`
    within each `herd_id`

2.  `offtake_heads` and `offtake_heads_assessment` are rescaled
    proportionally from the unscaled cohort stock to the scaled cohort
    stock

Without a herd-size target in non-demographic-only mode,
`cohort_stock_size_unscaled` is simply renamed to `cohort_stock_size`.

## Use cases

### Use case 1: Run both demographic and non-demographic modules

    # Load herd simulation inputs (cohort and herd-level)
    herd_all_chrt_dt <- data.table::fread(system.file(
      "extdata/run_modules_examples/herd_all_input_chrt_data.csv",
      package = "gleam"
    ))
    herd_all_hrd_dt <- data.table::fread(system.file(
      "extdata/run_modules_examples/herd_all_input_hrd_data.csv",
      package = "gleam"
    ))

    # Run mixed demographic and non-demographic herd simulation
    results <- run_all_herd_module(
      cohort_level_data = herd_all_chrt_dt,
      herd_level_data = herd_all_hrd_dt,
      run_demographic = TRUE,
      run_nondemographic = TRUE,
      simulation_duration = 365,
      show_indicator = TRUE
    )

### Use case 2: Run the non-demographic module only

    # Load non-demographic-only herd inputs (CHK layers and broilers)
    herd_all_chrt_dt <- data.table::fread(system.file(
      "extdata/run_modules_examples/herd_all_nondemo_input_chrt_data.csv",
      package = "gleam"
    ))
    herd_all_hrd_dt <- data.table::fread(system.file(
      "extdata/run_modules_examples/herd_all_nondemo_input_hrd_data.csv",
      package = "gleam"
    ))

    # Run non-demographic-only herd simulation
    results <- run_all_herd_module(
      cohort_level_data = herd_all_chrt_dt,
      herd_level_data = herd_all_hrd_dt,
      run_demographic = FALSE,
      run_nondemographic = TRUE,
      simulation_duration = 365,
      show_indicator = TRUE
    )

### Use case 3: Run the demographic module only

    # Load demographic-only herd inputs (cohort and herd-level)
    herd_all_chrt_dt <- data.table::fread(system.file(
      "extdata/run_modules_examples/herd_all_demo_input_chrt_data.csv",
      package = "gleam"
    ))
    herd_all_hrd_dt <- data.table::fread(system.file(
      "extdata/run_modules_examples/herd_all_demo_input_hrd_data.csv",
      package = "gleam"
    ))

    # Run demographic-only herd simulation
    results <- run_all_herd_module(
      cohort_level_data = herd_all_chrt_dt,
      herd_level_data = herd_all_hrd_dt,
      run_demographic = TRUE,
      run_nondemographic = FALSE,
      simulation_duration = 365,
      show_indicator = TRUE
    )

## See also

[`run_gleam()`](https://un-fao.github.io/GLEAM/reference/run_gleam.md),
[`run_demographic_herd_module()`](https://un-fao.github.io/GLEAM/reference/run_demographic_herd_module.md),
[`run_nondemographic_herd_module()`](https://un-fao.github.io/GLEAM/reference/run_nondemographic_herd_module.md),
[`rescale_x_to_y()`](https://un-fao.github.io/GLEAM/reference/rescale_x_to_y.md)
