# Run Nitrogen Balance Module Pipeline

Calculates cohort-level daily nitrogen intake, retention, and excretion
(kg N/head/day) by applying IPCC Tier 2 approach.

## Usage

``` r
run_nitrogen_balance_module(
  cohort_level_data,
  herd_level_data,
  show_indicator = TRUE
)
```

## Arguments

- cohort_level_data:

  data.table. Cohort-level input table with the following data
  requirement:

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

  ration_intake

  :   Numeric. Average daily dry matter intake of feed (kg DM/head/day).

  ration_nitrogen

  :   Numeric. Average nitrogen content of diet (kg N/kg DM).

  daily_weight_gain

  :   Numeric. Average live weight gain of the cohort over the cohort
      stage (kg/head/day).

  cohort_duration_days

  :   Numeric. Amount of time that each animal spends in a specific
      cohort (days).

- herd_level_data:

  data.table. Herd-level input table (one row per `herd_id`) with the
  following data requirement:

  herd_id

  :   Character. Unique identifier for the herd, repeated for each
      cohort belonging to the same herd.

  species_short

  :   Character. Code identifying the livestock species. Supported
      values include:

      - `PGS`: pigs

      - `CML`: camels

      - `CTL`: cattle

      - `BFL`: buffalo

      - `SHP`: sheep

      - `GTS`: goats

  milk_protein_fraction

  :   Numeric. Milk protein fraction (kg protein / kg milk). Required
      only for species = CML, CTL, BFL, SHP, and GTS.

  milk_yield_day

  :   Numeric. Average milk yield per milk-producing animal during the
      assessment duration (kg/head/day). This value is calculated as the
      total quantity of milk produced for human consumption by
      milk-producing animals during the assessment period, divided by
      the number of milk-producing animals, and the length of the
      assessment period (days). Required only for species = CML, CTL,
      BFL, SHP, and GTS.

  fibre_yield_year

  :   Numeric. Annual production yield of fibre, such as wool, cashmere,
      mohair (kg/head/year). Required only for species = CML, SHP, and
      GTS.

  litter_size

  :   Numeric. Average number of offspring born per parturition (#
      offsprings/parturition). This value can be calculated as the total
      number of offspring born divided by the total number of
      parturitions during the year.

  parturition_rate

  :   Numeric. Average annual number of parturitions per female animal
      (# parturitions/adult female/year). A herd-level reproductive
      performance indicator calculated as the total number of
      parturitions (deliveries) occurring during a year divided by the
      number of adult females potentially able to give birth during that
      year.

  live_weight_at_weaning

  :   Numeric. Live weight of the animal at weaning (kg).

  live_weight_at_birth

  :   Numeric. Live weight of the animal at birth (kg).

  pregnancy_duration

  :   Numeric. Duration of pregnancy period (days).

- show_indicator:

  Logical. Whether to display progress indicators during simulation.
  Defaults to `TRUE`.

## Value

A `data.table` with the original cohort-level input columns plus the
following new variables:

- nitrogen_intake:

  Numeric. Daily nitrogen intake (kg N/head/day).

- nitrogen_retention:

  Numeric. Daily nitrogen retention in animal body tissues and products
  (e.g., growth, pregnancy, milk...) (kg N/head/day)

- nitrogen_excretion:

  Numeric. Daily nitrogen excretion (kg N/head/day).

## Details

This function represents the intermediate module of the Global Livestock
Environmental Assessment Model (GLEAM) computational pipeline
[`run_gleam()`](https://github.com/un-fao/GLEAM/reference/run_gleam.md)
to compute the nitrogen balance. The function joins `cohort_level_data`
with `herd_level_data` by `herd_id`, uses `species_short` directly for
all species-specific nitrogen balance calculations, and computes
cohort-level nitrogen balance components following the IPCC Tier 2
structure.

The following calculation sequence is applied:

1.  Daily nitrogen intake is computed using
    [`calc_nitrogen_intake`](https://github.com/un-fao/GLEAM/reference/calc_nitrogen_intake.md)
    from `ration_intake` and `ration_nitrogen`.

2.  Daily nitrogen retention is computed using
    [`calc_nitrogen_retention`](https://github.com/un-fao/GLEAM/reference/calc_nitrogen_retention.md)
    from cohort-level and herd-level species parameters.

3.  Daily nitrogen excretion is computed using
    [`calc_nitrogen_excretion`](https://github.com/un-fao/GLEAM/reference/calc_nitrogen_excretion.md)
    as intake minus retention (species-specific validation applied).

## See also

[`run_gleam`](https://github.com/un-fao/GLEAM/reference/run_gleam.md),
[`calc_nitrogen_intake`](https://github.com/un-fao/GLEAM/reference/calc_nitrogen_intake.md),
[`calc_nitrogen_retention`](https://github.com/un-fao/GLEAM/reference/calc_nitrogen_retention.md),
[`calc_nitrogen_excretion`](https://github.com/un-fao/GLEAM/reference/calc_nitrogen_excretion.md)

## Examples

``` r
# \donttest{
# Load nitrogen balance inputs (cohort and herd-level)
nitrogen_balance_chrt_dt <- data.table::fread(system.file(
  "extdata/run_modules_examples/nitrogen_balance_input_chrt_data.csv",
  package = "gleam"
))
nitrogen_balance_hrd_dt <- data.table::fread(system.file(
  "extdata/run_modules_examples/nitrogen_balance_input_hrd_data.csv",
  package = "gleam"
))

# Run nitrogen balance calculations
results <- run_nitrogen_balance_module(
  cohort_level_data = nitrogen_balance_chrt_dt,
  herd_level_data = nitrogen_balance_hrd_dt
)
#> 🕒 Calculating nitrogen balance, please wait…
#> ✔ Nitrogen balance calculation complete.
# }
```
