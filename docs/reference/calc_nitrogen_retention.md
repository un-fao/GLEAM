# Calculate daily nitrogen retention

Calculates daily nitrogen retention per animal by species and cohort (kg
N/head/day). Nitrogen retention represents the portion of consumed
nitrogen that is incorporated into animal products or body tissues.

## Usage

``` r
calc_nitrogen_retention(
  species_short,
  cohort_short,
  milk_protein_fraction = NA_real_,
  milk_yield_day = NA_real_,
  daily_weight_gain = NA_real_,
  fibre_yield_year = NA_real_,
  litter_size = NA_real_,
  parturition_rate = NA_real_,
  live_weight_at_weaning = NA_real_,
  live_weight_at_birth = NA_real_,
  pregnancy_duration = NA_real_,
  cohort_duration_days = NA_real_
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

- milk_protein_fraction:

  Numeric. Milk protein fraction (kg protein / kg milk). Required only
  for species = CML, CTL, BFL, SHP, and GTS.

- milk_yield_day:

  Numeric. Average milk yield per milk-producing animal during the
  assessment duration (kg/head/day). This value is calculated as the
  total quantity of milk produced for human consumption by
  milk-producing animals during the assessment period, divided by the
  number of milk-producing animals, and the length of the assessment
  period (days). Required only for species = CML, CTL, BFL, SHP, and
  GTS.

- daily_weight_gain:

  Numeric. Average live weight gain of the cohort over the cohort stage
  (kg/head/day).

- fibre_yield_year:

  Numeric. Annual production yield of fibre, such as wool, cashmere,
  mohair (kg/head/year). Required only for species = CML, SHP, and GTS.

- litter_size:

  Numeric. Average number of offspring born per parturition (#
  offsprings/parturition). This value can be calculated as the total
  number of offspring born divided by the total number of parturitions
  during the year.

- parturition_rate:

  Numeric. Average annual number of parturitions per female animal (#
  parturitions/adult female/year). A herd-level reproductive performance
  indicator calculated as the total number of parturitions (deliveries)
  occurring during a year divided by the number of adult females
  potentially able to give birth during that year.

- live_weight_at_weaning:

  Numeric. Live weight of the animal at weaning (kg).

- live_weight_at_birth:

  Numeric. Live weight of the animal at birth (kg).

- pregnancy_duration:

  Numeric. Duration of pregnancy period (days).

- cohort_duration_days:

  Numeric. Amount of time that each animal spends in a specific cohort
  (days).

## Value

Numeric. Daily nitrogen retention in animal body tissues and products
(e.g., growth, pregnancy, milk...) (kg N/head/day)

## Details

Species-specific nitrogen retention calculations are applied.

**For CTL, BFL, SHP, GTS, and CML**:

Nitrogen retained in products and tissues is computed consistent with
the process described in the Technical paper from MPI (Ministry for
Primary Industries (MPI), 2025), where nitrogen retention is calculated
as the sum of:

- nitrogen secreted in milk,

- nitrogen retained in live weight gain (tissue),

- nitrogen retained in fibre (for fibre-producing species).

Coefficients for nitrogen content of deposited tissue, fibre, and milk
are derived from Chapter 5 (Nitrogen Excretion) of the MPI Technical
paper.

The following constants are used:

- **Tissue nitrogen content (`tissue_n`)**

  - `CTL` and `BFL`: **0.0326 kg N/kg live weight**

  - `SHP`, `GTS` and `CML`: **0.026 kg N/kg live weight**

- **Fibre nitrogen content (`fibre_n`)**

  - `SHP`, `GTS` and `CML`: **0.134 kg N/kg fibre**

- **Milk nitrogen content (`milk_n`)**:

  - `CTL`, `BFL`, `SHP`, `GTS` and `CML`: derived from
    `milk_protein_fraction` using a protein-to-nitrogen conversion
    factor of **6.25 kg protein/kg nitrogen**

**For PGS**

Nitrogen retention is calculated following the IPCC (2019) Tier 2
equations for swine (Equations 10.33A and 10.33B).

Nitrogen retention includes nitrogen retained in:

- live weight gain (tissue),

- reproductive outputs (conceptus and weaned offspring).

In this implementation:

- Nitrogen content of live weight gain is assumed to be **`0.025` kg
  N/kg live weight**.

- Protein digestibility fraction is assumed to be **`0.98`
  (dimensionless)**.

- For breeding cohorts, the reproductive component is represented by
  annual nitrogen retention in conceptus and weaned offspring, expressed
  as a daily average by distributing the annual value uniformly over the
  year (365 days).

- A constant factor of **`0.806` (dimensionless)** is applied to
  piglets' live weight gain to correct for their higher nitrogen content
  per unit of live weight gain, following IPCC (2019).

This function is part of the
[`run_nitrogen_balance_module()`](https://github.com/un-fao/GLEAM/reference/run_nitrogen_balance_module.md).

## References

Ministry for Primary Industries (MPI). (2025). *Detailed methodologies
for agricultural greenhouse gas emission calculation: Methodology for
calculation of New Zealand’s agricultural greenhouse gas emissions*
(Version 11). MPI Technical Paper, Wellington, New Zealand. Chapter 5.

IPCC. (2019). *2019 Refinement to the 2006 IPCC Guidelines for National
Greenhouse Gas Inventories*, Chapter 10: Emissions from Livestock and
Manure Management. Equation 10.33A, 10.33B.

IPCC. (2006). *2006 IPCC Guidelines for National Greenhouse Gas
Inventories*, Chapter 10: Emissions from Livestock and Manure
Management. Equation 10.33.

## See also

[`run_nitrogen_balance_module`](https://github.com/un-fao/GLEAM/reference/run_nitrogen_balance_module.md)
