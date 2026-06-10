# Calculate fibre production

Calculates fibre production for producing cohorts (`FA`, `FS`, `MA`,
`MS`) of fibre-producing species (`CML`, `SHP`, `GTS`) over the
assessment period (kg/cohort/assessment period).

## Usage

``` r
calc_fibre_production(
  species_short,
  cohort_short,
  fibre_yield_year,
  simulation_duration,
  cohort_stock_size
)
```

## Arguments

- species_short:

  Character. Code identifying the livestock species. Supported values
  include:

  - `PGS`: pigs

  - `CML`: camels

  - `CTL`: cattle

  - `BFL`: buffalo

  - `SHP`: sheep

  - `GTS`: goats

- cohort_short:

  Character. Sex- and age-specific cohort code describing the production
  stage of the animals. Supported values include:

  - `FA`: adult females (from age at first parturition)

  - `FS`: sub-adult females (from weaning to age at first parturition)

  - `FJ`: juvenile females (from birth to weaning)

  - `MA`: adult males (from age at first breeding)

  - `MS`: sub-adult males (from weaning to age at first breeding)

  - `MJ`: juvenile males (from birth to weaning)

- fibre_yield_year:

  Numeric. Annual production yield of fibre, such as wool, cashmere,
  mohair (kg/head/year). Required only for species = CML, SHP, and GTS.

- simulation_duration:

  Numeric. Length of the assessment period (days).

- cohort_stock_size:

  Numeric. Average population size in each of the 6 sex–age cohorts (#
  heads). (cohorts=FJ, FS, FA, MJ, MS, MA).

## Value

Numeric. Total fibre produced over the assessment period by cohort (kg
/cohort/assessment period).

## Details

Fibre production outputs are computed as follows:

\\fibre\\production = \frac{fibre\\yield\\year}{365} \times
simulation\\duration \times cohort\\stock\\size\\

Non-zero fibre outputs are only expected for producing cohorts (`FA`,
`FS`, `MA`, `MS`) of fibre-producing species (`CML`, `SHP`, `GTS`).

This function is part of the
[`run_production_module()`](https://github.com/un-fao/GLEAM/reference/run_production_module.md).

## See also

[`run_production_module`](https://github.com/un-fao/GLEAM/reference/run_production_module.md)
