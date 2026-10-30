# Calculate metabolic energy requirements for egg production

Calculates metabolizable energy required for egg deposition for chickens
(MJ/head/day).

## Usage

``` r
calc_metabolic_energy_req_eggs(
  species_short,
  cohort_short,
  egg_human_consumption_yield = NA_real_,
  egg_average_weight = NA_real_,
  reproductive_rate = NA_real_,
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

- egg_human_consumption_yield:

  Numeric. Number of eggs produced for human consumption in one year by
  hen (eggs/year/animal). Used for `CHK`.

- egg_average_weight:

  Numeric. Average egg weight (kg/egg).

- reproductive_rate:

  Numeric. Average annual number of parturitions per reproductive female
  (# parturitions/reproductive female/year). For chickens, annual number
  of eggs laid for reproduction per breeding hen (# eggs/hen/year).

- nondemo_productive_phase_id:

  Numeric. Optional productive phase identifier for non-demographic
  cohorts (`FN`, `MN`). Takes value `1` for phase 1 and optionally `2`
  for phase 2.

- is_egg_producing:

  Logical. Cohort-level flag identifying egg-producing `CHK` cohorts.
  This can be `TRUE` only for `FA` and for `FN` with
  `nondemo_productive_phase_id = 2`.

## Value

Numeric. Metabolizable energy required for egg deposition (MJ/head/day).

## Details

For chickens, energy required to produce reproductive eggs is included
for the `FA` cohort. Energy required to produce eggs for human
consumption is included only when `is_egg_producing = TRUE`. This flag
is allowed only for `FA` and for non-demographic `FN` cohorts in
productive phase 2.

Daily egg mass per head is calculated as:

\$\$ egg\\mass\\production = (human\\consumption\\eggs\\head\\day +
reproductive\\eggs\\head\\day) \times egg\\average\\weight \$\$
Human-consumption eggs per head per day equal
`egg_human_consumption_yield / 365` when the food-egg flag is true, and
zero otherwise. Reproductive eggs per head per day equal
`reproductive_rate / 365` for `FA`, and zero for other cohorts.

Daily egg energy is then:

\$\$metabolic\\energy\\req\\egg\\deposition = egg\\mass\\production
\times 10.04\$\$

where 10.04 MJ/kg egg is the Sakomura (2004) coefficient obtained by
expressing 0.01004 MJ/g egg on a kilogram basis for consistency with the
other coefficients used in GLEAM-X.

## References

Sakomura, N. K. (2004). *Modeling energy utilization in broiler
breeders, laying hens and broilers*. Brazilian Journal of Poultry
Science, 6, 1-11.
