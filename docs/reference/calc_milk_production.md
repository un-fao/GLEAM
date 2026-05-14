# Calculate milk production

Calculates total milk production for the producing cohort (`FA`) of
milk-producing species (`CML`, `CTL`, `BFL`, `SHP`, `GTS`) over the
assessment period and returns multiple production metrics: total milk
mass, milk protein, and fat-protein-corrected milk (FPCM)
(kg/cohort/assessment period).

## Usage

``` r
calc_milk_production(
  species_short,
  cohort_short,
  milk_yield_day,
  simulation_duration,
  cohort_stock_size,
  lactating_females_fraction,
  milk_protein_fraction,
  milk_fat_fraction,
  milk_lactose_fraction,
  milk_protein_fraction_standard,
  milk_fat_fraction_standard,
  milk_lactose_fraction_standard
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

- milk_yield_day:

  Numeric. Average milk yield per milk-producing animal during the
  assessment duration (kg/head/day). This value is calculated as the
  total quantity of milk produced for human consumption by
  milk-producing animals during the assessment period, divided by the
  number of milk-producing animals, and the length of the assessment
  period (days). Required only for species = CML, CTL, BFL, SHP, and
  GTS.

- simulation_duration:

  Numeric. Length of the assessment period (days).

- cohort_stock_size:

  Numeric. Average population size in each of the 6 sex–age cohorts (#
  heads). (cohorts=FJ, FS, FA, MJ, MS, MA).

- lactating_females_fraction:

  Numeric. Proportion of adult females that are lactating during the
  assessment period (fraction). Required only for species: CML, CTL,
  BFL, SHP, and GTS.

- milk_protein_fraction:

  Numeric. Milk protein fraction (kg protein/kg milk). Required only for
  species = CML, CTL, BFL, SHP, and GTS.

- milk_fat_fraction:

  Numeric. Milk fat fraction (kg fat/kg milk). Required only for species
  = CML, CTL, BFL, SHP, and GTS.

- milk_lactose_fraction:

  Numeric. Milk lactose fraction (kg lactose/kg milk). Required only for
  species = CML, CTL, BFL, SHP, and GTS.

- milk_protein_fraction_standard:

  Numeric. Standard protein content of milk, used to calculate
  Fat-protein-corrected milk (FPCM), (kg protein/kg milk). Suggested
  value = 0.033.

- milk_fat_fraction_standard:

  Numeric. Standard fat content of milk, used to calculate
  Fat-protein-corrected milk (FPCM), (kg fat/kg milk). Suggested value =
  0.04.

- milk_lactose_fraction_standard:

  Numeric. Standard lactose content of milk, used to calculate
  Fat-protein-corrected milk (FPCM), (kg lactose/kg milk). Suggested
  value = 0.048.

## Value

A named list with:

- milk_production_mass_cohort:

  Numeric. Total milk production produced over the assessment period
  (kg/cohort/assessment period).

- milk_production_protein_cohort:

  Numeric. Total milk protein production produced over the assessment
  period (kg protein/cohort/assessment period).

- milk_production_fpcm_cohort:

  Numeric. Total fat-protein-corrected milk (FPCM) produced over the
  assessment period (kg/cohort/assessment period).

## Details

Milk production outputs are computed as follows:

- **`milk_production_mass_cohort`** is computed as:

  \\milk\\production = milk\\yield\\day \times simulation\\duration
  \times cohort\\stock\\size \times lactating\\females\\fraction\\

- **`milk_production_protein_cohort`** is computed as:

  \\milk\\protein\\production = milk\\production \times
  milk\\protein\\fraction\\

- **`milk_production_fpcm_cohort`** is computed using the ratio of
  energy content of actual versus standard milk:

  \\FPCM = milk\\production \times \frac{E\_{milk}}{E\_{standard}}\\

  where milk energy content (Mcal/kg) is computed as (IDF, 2022):

  \\E\_{milk} = 0.0929 \times milk\\fat\\fraction + 0.0547 \times
  milk\\protein\\fraction + 0.0395 \times milk\\lactose\\fraction\\

  \\E\_{standard} = 0.0929 \times milk\\fat\\fraction\\standard + 0.0547
  \times milk\\protein\\fraction\\standard + 0.0395 \times
  milk\\lactose\\fraction\\standard\\

Non-zero milk outputs are only expected for adult female cohorts of
milk-producing species.

This function is part of the
[`run_production_module()`](https://github.com/un-fao/GLEAM/reference/run_production_module.md).

## References

International Dairy Federation (IDF). 2022. *The IDF Global Carbon
Footprint Standard for the Dairy Sector*. Bulletin of the IDF No.
520/2022. International Dairy Federation (ed.), Brussels, Belgium.
Equation 10.

## See also

[`run_production_module`](https://github.com/un-fao/GLEAM/reference/run_production_module.md)
