# Calculate egg production

Calculates food-egg outputs for chickens over the assessment period.

## Usage

``` r
calc_egg_production(
  species_short,
  cohort_short,
  egg_human_consumption_yield,
  egg_average_weight,
  simulation_duration,
  cohort_stock_size,
  egg_protein_fraction = 0.125,
  nondemo_productive_phase_id = NA_real_,
  is_egg_producing = FALSE
)
```

## Arguments

- species_short:

  Character. Code identifying the livestock species. Supported values
  include:

  - `CHK`: chickens

- cohort_short:

  Character. Sex- and age-specific cohort code describing the production
  stage of the animals. Supported values include:

  - `FA`: adult females (from age at first parturition)

  - `FS`: sub-adult females (from weaning to age at first parturition)

  - `FJ`: juvenile females (from birth to weaning)

  - `FN`: non-demographic females

  - `MA`: adult males (from age at first breeding)

  - `MS`: sub-adult males (from weaning to age at first breeding)

  - `MJ`: juvenile males (from birth to weaning)

  - `MN`: non-demographic males

- egg_human_consumption_yield:

  Numeric. Number of eggs produced for human consumption in one year by
  hen (eggs/year/animal). Used for `CHK`.

- egg_average_weight:

  Numeric. Average egg weight (kg/egg).

- simulation_duration:

  Numeric. Length of the assessment period (days).

- cohort_stock_size:

  Numeric. Average population size of the assessed cohort (heads).

- egg_protein_fraction:

  Numeric. Protein content of whole egg (kg protein/kg egg).

- nondemo_productive_phase_id:

  Numeric. Optional productive phase identifier for non-demographic
  cohorts.

- is_egg_producing:

  Logical. Cohort-level flag identifying food-egg-producing `CHK`
  cohorts. This can be `TRUE` only for `FA` and for `FN` with
  `nondemo_productive_phase_id = 2`.

## Value

A named list with total egg number, mass, and protein over the
assessment period.

## Details

Food-egg production is computed only for cohorts flagged with
`is_egg_producing = TRUE`. Validation restricts this flag to demographic
laying hens (`FA`) and to non-demographic `FN` phase 2 when intensive
layers are represented in the non-demographic pathway. Reproductive eggs
from `FA` are excluded from these food outputs.

The following equations are applied:

\$\$ egg\\production\\number\\cohort =
\frac{egg\\human\\consumption\\yield}{365} \times cohort\\stock\\size
\times simulation\\duration \$\$

\$\$ egg\\production\\mass\\cohort = egg\\production\\number\\cohort
\times egg\\average\\weight \$\$

\$\$ egg\\production\\protein\\cohort = egg\\production\\mass\\cohort
\times egg\\protein\\fraction \$\$

where the default `egg_protein_fraction` is 0.125 kg protein/kg egg
mass, following the poultry integration assumptions used in GLEAM-X.

## References

Caffa, I., Proietti, E., Turrini, F., Borgarelli, C., Ferrando, M. R.,
Formisano, E., ... & Pisciotta, L. (2025). Nutritional Aspects of Eggs
for a Healthy and Sustainable Consumption: A Narrative Review. *Food
Science & Nutrition*, 13(9), e70285.
