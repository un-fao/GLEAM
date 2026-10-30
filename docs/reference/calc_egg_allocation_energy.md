# Calculate egg energy requirements (for biophysical allocation)

Calculates the energy required for egg production over the assessment
period (MJ/cohort/assessment period) for chicken adult females.

## Usage

``` r
calc_egg_allocation_energy(
  species_short,
  cohort_short,
  egg_production_mass_cohort,
  nondemo_productive_phase_id = NA_real_,
  is_egg_producing = FALSE
)
```

## Arguments

- species_short:

  Character. Code identifying the livestock species.

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

- egg_production_mass_cohort:

  Numeric. Total egg mass produced over the assessment period by cohort
  (kg/cohort/assessment period).

- nondemo_productive_phase_id:

  Numeric. Optional productive phase identifier for non-demographic
  cohorts (`FN`, `MN`). Takes value `1` for phase 1 and optionally `2`
  for phase 2.

- is_egg_producing:

  Logical. Cohort-level flag identifying egg-producing `CHK` cohorts.
  This can be `TRUE` only for `FA` and for `FN` with
  `nondemo_productive_phase_id = 2`.

## Value

Numeric. Energy required to produce all eggs during the assessment
period (MJ/cohort/assessment period).

## Details

For chickens, egg allocation energy is computed only for cohorts flagged
with `is_egg_producing = TRUE`. Validation restricts this flag to
demographic laying hens (`FA`) and to non-demographic `FN` phase 2 when
intensive layers are represented in the non-demographic pathway.

\$\$ egg\\allocation\\energy = egg\\production\\mass\\cohort \times
10.04 \$\$

where 10.04 MJ/kg egg is the poultry egg-production coefficient adapted
from Sakomura (2004) and expressed on a kilogram basis for consistency
with the allocation framework.

## References

Sakomura, N. K. (2004). Modeling energy utilization in broiler breeders,
laying hens and broilers. *Brazilian Journal of Poultry Science*, 6,
1-11.
