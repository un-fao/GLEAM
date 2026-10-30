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
  offspring_per_reproductive_event = NA_real_,
  reproductive_rate = NA_real_,
  live_weight_at_weaning = NA_real_,
  live_weight_at_birth = NA_real_,
  pregnancy_duration = NA_real_,
  cohort_duration_days = NA_real_,
  egg_human_consumption_yield = NA_real_,
  egg_average_weight = NA_real_,
  nondemo_productive_phase_id = NA_real_,
  is_egg_producing = FALSE
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

  - `CHK`: chickens

- cohort_short:

  Character. Sex-specific cohort code describing the age and/or the
  production stage of the animals. Supported values include:

  - `FA`: adult females (from age at first parturition)

  - `FS`: sub-adult females (from weaning to age at first parturition)

  - `FJ`: juvenile females (from birth to weaning)

  - `MA`: adult males (from age at first breeding)

  - `MS`: sub-adult males (from weaning to age at first breeding)

  - `MJ`: juvenile males (from birth to weaning)

  - `FN`: non-demographic females

  - `MN`: non-demographic males

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

- offspring_per_reproductive_event:

  Numeric. Average number of offspring born per parturition (#
  offspring/parturition). For chickens, hatchability of eggs laid for
  reproduction, calculated as the number of chicks hatched divided by
  the number of eggs laid for reproduction (fraction).

- reproductive_rate:

  Numeric. Average annual number of parturitions per reproductive female
  (# parturitions/reproductive female/year). For chickens, annual number
  of eggs laid for reproduction per breeding hen (# eggs/hen/year).

- live_weight_at_weaning:

  Numeric. Live weight of the animal at weaning (kg).

- live_weight_at_birth:

  Numeric. Live weight of the animal at birth (kg).

- pregnancy_duration:

  Numeric. Duration of pregnancy period (days).

- cohort_duration_days:

  Numeric. Amount of time that each animal spends in a specific cohort
  (days). For `CHK`, suggested value for `FJ` and `MJ` cohorts: 3 days.

- egg_human_consumption_yield:

  Numeric. Number of eggs produced for human consumption in one year by
  hen (eggs/year/animal). Used for `CHK`.

- egg_average_weight:

  Numeric. Average egg weight (kg/egg).

- nondemo_productive_phase_id:

  Numeric. Optional productive phase identifier for non-demographic
  cohorts (`FN`, `MN`). Takes value `1` for phase 1 and optionally `2`
  for phase 2.

- is_egg_producing:

  Logical. Cohort-level flag identifying egg-producing `CHK` cohorts.
  This can be `TRUE` only for `FA` and for `FN` with
  `nondemo_productive_phase_id = 2`.

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

**For CHK**:

Nitrogen retention includes growth and egg deposition. Reproductive eggs
are included for `FA` regardless of the food-egg flag. Eggs for human
consumption are included only when `is_egg_producing = TRUE`:

\$\$nitrogen\\retention = growth\\component + egg\\component\$\$

with:

\$\$growth\\component = daily\\weight\\gain \times 0.032\$\$

and:

\$\$ egg\\component = (human\\consumption\\eggs\\head\\day +
reproductive\\eggs\\head\\day) \times egg\\average\\weight \times 0.02
\$\$ Human-consumption eggs per head per day equal
`egg_human_consumption_yield / 365` when the food-egg flag is true, and
zero otherwise. Reproductive eggs per head per day equal
`reproductive_rate / 365` for `FA`, and zero for other cohorts.

The coefficient 0.032 represents nitrogen retained in live-weight gain
(kg N/kg live weight), following Lessire (2004). The coefficient 0.02
represents nitrogen content of egg mass (kg N/kg egg mass), based on the
egg protein composition summarized by Caffa et al. (2025). As
implemented in the poultry pathway, the food-egg component is activated
by the cohort-level `is_egg_producing` flag. Validation restricts this
flag to demographic laying hens (`FA`) and to non-demographic `FN` phase
2 when intensive layers are modeled outside the demographic structure.

This function is part of the
[`run_nitrogen_balance_module()`](https://un-fao.github.io/GLEAM/reference/run_nitrogen_balance_module.md).

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

Caffa, I., Proietti, E., Turrini, F., Borgarelli, C., Ferrando, M. R.,
Formisano, E., ... & Pisciotta, L. (2025). Nutritional Aspects of Eggs
for a Healthy and Sustainable Consumption: A Narrative Review. *Food
Science & Nutrition*, 13(9), e70285.

Lessire, M. (2004). Nutritional values for poultry. In *Tables of
composition and nutritional value of feed materials* (pp. 37-42).
Wageningen Academic.

## See also

[`run_nitrogen_balance_module`](https://un-fao.github.io/GLEAM/reference/run_nitrogen_balance_module.md)
