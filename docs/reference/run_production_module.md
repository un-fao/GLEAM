# Run Production Module Pipeline

Calculates cohort-level production outputs over the assessment period by
combining cohort-level herd structure inputs with herd-level production
parameters. The function returns milk, fibre, meat, and egg outputs for
each cohort.

## Usage

``` r
run_production_module(
  cohort_level_data,
  herd_level_data,
  simulation_duration = 365,
  show_indicator = TRUE
)
```

## Arguments

- cohort_level_data:

  data.table. Cohort-level input table (one row per herd-cohort) with
  the following data requirement:

  herd_id

  :   Character. Unique identifier for the herd, repeated for each
      cohort belonging to the same herd.

  cohort_short

  :   Character. Sex-specific cohort code describing the age and/or the
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

  nondemo_productive_phase_id

  :   Numeric. Optional productive phase identifier for non-demographic
      cohorts (`FN`, `MN`). Takes value `1` for phase 1 and optionally
      `2` for phase 2.

  is_egg_producing

  :   Logical. Cohort-level flag identifying egg-producing `CHK`
      cohorts. This can be `TRUE` only for `FA` and for `FN` with
      `nondemo_productive_phase_id = 2`.

  cohort_stock_size

  :   Numeric. Average population size of the assessed cohort (# heads).

  offtake_heads_assessment

  :   Numeric. Total number of animals removed from each cohort over the
      assessment period (# heads/assessment period).

  live_weight_cohort_at_slaughter

  :   Numeric. Live weight at slaughter for animals removed from the
      cohort (kg).

- herd_level_data:

  data.table. Herd-level input table (one row per `herd_id`) with the
  following data requirement. Milk-related columns and
  `fibre_yield_year` may be omitted when the cohort table contains only
  `FN` and `MN`:

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

      - `CHK`: chickens

  milk_yield_day

  :   Numeric. Average milk yield per milk-producing animal during the
      assessment duration (kg/head/day). This value is calculated as the
      total quantity of milk produced for human consumption by
      milk-producing animals during the assessment period, divided by
      the number of milk-producing animals, and the length of the
      assessment period (days). Required only for species = CML, CTL,
      BFL, SHP, and GTS.

  lactating_females_fraction

  :   Numeric. Proportion of adult females that are lactating during the
      assessment period (fraction). Required only for species: CML, CTL,
      BFL, SHP, and GTS.

  milk_protein_fraction

  :   Numeric. Milk protein fraction (kg protein/kg milk). Required only
      for species = CML, CTL, BFL, SHP, and GTS.

  milk_fat_fraction

  :   Numeric. Milk fat fraction (kg fat/kg milk). Required only for
      species = CML, CTL, BFL, SHP, and GTS.

  milk_lactose_fraction

  :   Numeric. Milk lactose fraction (kg lactose/kg milk). Required only
      for species = CML, CTL, BFL, SHP, and GTS.

  milk_protein_fraction_standard

  :   Numeric. Standard protein content of milk, used to calculate
      Fat-protein-corrected milk (FPCM), (kg protein/kg milk). Suggested
      value = 0.033.

  milk_fat_fraction_standard

  :   Numeric. Standard fat content of milk, used to calculate
      Fat-protein-corrected milk (FPCM), (kg fat/kg milk). Suggested
      value = 0.04.

  milk_lactose_fraction_standard

  :   Numeric. Standard lactose content of milk, used to calculate
      Fat-protein-corrected milk (FPCM), (kg lactose/kg milk). Suggested
      value = 0.048.

  egg_human_consumption_yield

  :   Numeric. Number of eggs produced for human consumption in one year
      by hen (eggs/year/animal). Used for `CHK`.

  egg_average_weight

  :   Numeric. Average egg weight (kg/egg).

  fibre_yield_year

  :   Numeric. Annual production yield of fibre, such as wool, cashmere,
      mohair (kg/head/year). Required only for species = CML, SHP, and
      GTS.

  carcass_dressing_fraction

  :   Numeric. Ratio of a slaughtered animal's carcass weight to its
      live weight (fraction).

  bone_free_meat_fraction

  :   Numeric. Ratio of bone-free-meat to carcass weight (fraction).

  meat_protein_fraction

  :   Numeric. Protein content of bone-free-meat (kg protein/kg
      bone-free-meat).

- simulation_duration:

  Numeric. Length of the assessment period (days).

- show_indicator:

  Logical. Whether to display progress indicators during simulation.
  Defaults to `TRUE`.

## Value

A `data.table` with the original cohort-level input columns plus the
following new variables. If `nondemo_productive_phase_id` is present in
the input, the returned table preserves phase-specific rows for `FN` and
`MN`:

- milk_production_mass_cohort:

  Numeric. Total milk production produced over the assessment period
  (kg/cohort/assessment period).

- milk_production_protein_cohort:

  Numeric. Total milk protein production produced over the assessment
  period (kg protein/cohort/assessment period).

- milk_production_fpcm_cohort:

  Numeric. Total fat-protein-corrected milk (FPCM) produced over the
  assessment period (kg/cohort/assessment period).

- fibre_production_cohort:

  Numeric. Total fibre produced over the assessment period by cohort (kg
  /cohort/assessment period).

- meat_production_live_weight_cohort:

  Numeric . Total meat produced as live weight over the assessment
  period by cohort (kg/cohort/assessment period).

- meat_production_carcass_weight_cohort:

  Numeric. Total meat as carcass weight (excluding organs, and other
  by-products after dressing) produced over the assessment period by
  cohort (kg/cohort/assessment period).

- meat_production_bone_free_meat_cohort:

  Numeric. Total bone-free-meat (excluding bones, organs, and other
  by-products after dressing and bone removal) produced over the
  assessment period by cohort (kg/cohort/assessment period).

- meat_production_protein_cohort:

  Numeric. Total meat protein (excluding bones, organs, and other
  by-products after dressing and bone removal) produced over the
  assessment period by cohort (kg protein/cohort/assessment period).

- egg_production_number_cohort:

  Numeric. Total egg output over the assessment period by cohort
  (eggs/cohort/assessment period).

- egg_production_mass_cohort:

  Numeric. Total egg mass produced over the assessment period by cohort
  (kg/cohort/assessment period).

- egg_production_protein_cohort:

  Numeric. Total egg protein output over the assessment period by cohort
  (kg protein/cohort/assessment period).

## Details

This function represents the intermediate module of the Global Livestock
Environmental Assessment Model (GLEAM) computational pipeline
[`run_gleam()`](https://un-fao.github.io/GLEAM/reference/run_gleam.md)
to estimate meat, milk, fibre, and eggs production outputs from
livestock and performs the following calculation sequence:

1.  Milk outputs are computed using
    [`calc_milk_production`](https://un-fao.github.io/GLEAM/reference/calc_milk_production.md)

2.  Fibre outputs are computed using
    [`calc_fibre_production`](https://un-fao.github.io/GLEAM/reference/calc_fibre_production.md)

3.  Meat outputs are computed using
    [`calc_meat_production`](https://un-fao.github.io/GLEAM/reference/calc_meat_production.md)

4.  Eggs outputs are computed using
    [`calc_egg_production`](https://un-fao.github.io/GLEAM/reference/calc_egg_production.md)

For species/cohorts where milk, fibre or egg production is not
applicable, outputs are returned as zero. Food-egg output is calculated
from `egg_human_consumption_yield` (eggs/year/animal), multiplied by the
stock of each flagged cohort and scaled to the assessment period.
Reproductive eggs from `FA` are excluded from food-egg production.

## See also

[`run_gleam`](https://un-fao.github.io/GLEAM/reference/run_gleam.md),
[`calc_milk_production`](https://un-fao.github.io/GLEAM/reference/calc_milk_production.md),
[`calc_fibre_production`](https://un-fao.github.io/GLEAM/reference/calc_fibre_production.md),
[`calc_meat_production`](https://un-fao.github.io/GLEAM/reference/calc_meat_production.md),
[`calc_egg_production`](https://un-fao.github.io/GLEAM/reference/calc_egg_production.md)

## Examples

``` r
# \donttest{
# Load production inputs (cohort and herd-level)
production_chrt_dt <- data.table::fread(system.file(
  "extdata/run_modules_examples/production_input_chrt_data.csv",
  package = "gleam"
))
production_hrd_dt <- data.table::fread(system.file(
  "extdata/run_modules_examples/production_input_hrd_data.csv",
  package = "gleam"
))

# Run production calculations
results <- run_production_module(
  cohort_level_data = production_chrt_dt,
  herd_level_data = production_hrd_dt,
  simulation_duration = 365
)
#> 🕒 Calculating production (milk, fibre, meat), please wait…
#> ✔ Production cohort calculations completed.
# }
```
