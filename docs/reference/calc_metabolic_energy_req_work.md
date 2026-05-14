# Calculate metabolic energy requirements for work

Calculates the energy requirement for work (MJ/head/day), defined as the
additional energy required to support draught power and work-related
physical activity.

## Usage

``` r
calc_metabolic_energy_req_work(
  species_short,
  cohort_short,
  metabolic_energy_req_maintenance = NA_real_,
  draught_work_hours_female = NA_real_,
  draught_work_hours_male = NA_real_,
  draught_fraction_female = NA_real_,
  draught_fraction_male = NA_real_
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

- metabolic_energy_req_maintenance:

  Numeric. Energy required for maintenance, defined as the amount of
  energy needed to keep the animal at equilibrium such that body energy
  is neither gained nor lost. Expressed as net energy for CTL, BFL, SHP,
  GTS and as metabolizable energy for CML and PGS (MJ/head/day).

- draught_work_hours_female:

  Numeric. Average daily working time per adult female (hours/head/day).
  Required only for species = CML, CTL and BFL.

- draught_work_hours_male:

  Numeric. Average daily working time per adult male (hours/head/day).
  Required only for species = CML, CTL and BFL.

- draught_fraction_female:

  Numeric. Fraction of adult females involved in draught work
  (fraction). Required only for species = CML, CTL and BFL.

- draught_fraction_male:

  Numeric. Fraction of adult males involved in draught work (fraction).
  Required only for species = CML, CTL and BFL.

## Value

Numeric. Energy required for work, used to estimate the energy required
for draught power for CTL, BFL and CML (MJ/head/day). Assumed to be 0
for other species. Expressed as net energy for CTL, BFL, SHP, GTS and as
metabolizable energy for CML and PGS.

## Details

This approach follows the IPCC Tier 2 partitioning method and applies
species-specific coefficients for draught work.

This energy component is calculated only for adult cohorts ( `FA` and
`MA`) of draught-capable species (`CTL`, `BFL`, and `CML`). It is scaled
by the fraction of adult animals involved in draught work
(`draught_fraction_female`, `draught_fraction_male`) and their average
daily working time (`draught_work_hours_female`,
`draught_work_hours_male`).

**Species-specific approach:**

**CTL and BFL** - (Bamualim & Kartiarso, 1985; IPCC, 2006; IPCC 2019).
Draught work energy is expressed as a proportion of net energy for
maintenance:

\\ metabolic\\energy\\req\\work = 0.1 \times
metabolic\\energy\\req\\maintenance \times work\\hours \times
draught\\fraction \\

where:

- \\metabolic\\energy\\req\\maintenance\\ is net energy required for
  maintenance (MJ/head/day) and can be calculated using
  [`calc_metabolic_energy_req_maintenance()`](https://github.com/un-fao/GLEAM/reference/calc_metabolic_energy_req_maintenance.md),

- \\0.1\\ represents a 10% increase in maintenance energy per hour of
  work,

- \\work\\hours\\ is the mean number of hours worked per animal per
  day - `draught_work_hours_female` (for `FA`) and
  `draught_work_hours_male` (for `MA`) and,

- \\draught\\fraction\\ is the fraction of adult animals performing
  draught work - `draught_fraction_female` (for `FA`) and
  `draught_fraction_male` (for `MA`)

**CML** - (Wilson, 1989) Draught work energy is calculated using a fixed
metabolizable energy cost per hour of work:

\$\$ metabolic\\energy\\req\\work = 4 \times work\\hours \times
draught\\fraction \$\$

where:

- \\4\\ is the metabolizable energy requirement for draught work
  (MJ/hour),

- \\work\\hours\\ is the mean number of hours worked per animal per
  day - `draught_work_hours_female` (for `FA`) and
  `draught_work_hours_male` (for `MA`) and,

- \\draught\\fraction\\ is the fraction of adult animals performing
  draught work - `draught_fraction_female` (for `FA`) and
  `draught_fraction_male` (for `MA`)

This function is part of the
[`run_metabolic_energy_req_module()`](https://github.com/un-fao/GLEAM/reference/run_metabolic_energy_req_module.md).

## References

Bamualim A., Kartiarso (1985). *Nutrition of draught animals with
special reference to Indonesia*. In: Draught Animal Power for
Production. Australian Centre for International agricultural Research
(ACIAR), Proceedings Series No. 10, ed. JW Copland. Canberra, A.C.T.,
Australia: ACIAR.

IPCC. (2019). *2019 Refinement to the 2006 IPCC Guidelines for National
Greenhouse Gas Inventories*, Chapter 10: Emissions from Livestock and
Manure Management, Equation 10.11.

IPCC. (2006). *2006 IPCC Guidelines for National Greenhouse Gas
Inventories*, Chapter 10: Emissions from Livestock and Manure
Management, Equation 10.11.

Wilson (1989). *The nutritional requirements of camel*. In: Tisserand
J.-L. (ed.). Séminaire sur la digestion, la nutrition et l'alimentation
du dromadaire. Zaragoza : CIHEAM. (1989). p. 171-179 (Options
Méditerranéennes : Série A. Séminaires Méditerranéens; n. 2)

## See also

[`run_metabolic_energy_req_module`](https://github.com/un-fao/GLEAM/reference/run_metabolic_energy_req_module.md),
[`calc_metabolic_energy_req_maintenance`](https://github.com/un-fao/GLEAM/reference/calc_metabolic_energy_req_maintenance.md)
