# Calculate total metabolic energy requirements

Calculates the total daily energy requirement (MJ/head/day) by summing
relevant energy partitions (maintenance, activity, lactation, work,
pregnancy, growth, fibre, egg deposition).

## Usage

``` r
calc_total_metabolic_energy_req(
  species_short,
  metabolic_energy_req_maintenance,
  metabolic_energy_req_activity,
  metabolic_energy_req_lactation,
  metabolic_energy_req_work,
  metabolic_energy_req_pregnancy,
  net_energy_maintenance_digestible_energy_ratio,
  metabolic_energy_req_growth,
  metabolic_energy_req_fibre_production,
  metabolic_energy_req_egg_deposition,
  net_energy_growth_digestible_energy_ratio,
  ration_digestibility_fraction
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

- metabolic_energy_req_maintenance:

  Numeric. Energy required for maintenance, defined as the amount of
  energy needed to keep the animal at equilibrium such that body energy
  is neither gained nor lost (MJ/head/day). Expressed as net energy for
  CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS.

- metabolic_energy_req_activity:

  Numeric. Energy required for activity, defined as the amount of energy
  needed to support animal movement and physical activity (MJ/head/day).
  Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable
  energy for CML and PGS.

- metabolic_energy_req_lactation:

  Numeric. Energy required for lactation (MJ/head/day). Expressed as net
  energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and
  PGS.

- metabolic_energy_req_work:

  Numeric. Energy required for work, used to estimate the energy
  required for draught power for CTL, BFL and CML (MJ/head/day). Assumed
  to be 0 for other species. Expressed as net energy for CTL, BFL, SHP,
  GTS and as metabolizable energy for CML and PGS.

- metabolic_energy_req_pregnancy:

  Numeric. Energy required for pregnancy for pregnant females
  (MJ/head/day). Expressed as net energy for CTL, BFL, SHP, GTS and as
  metabolizable energy for CML and PGS.

- net_energy_maintenance_digestible_energy_ratio:

  Ratio of net energy available for maintenance in the diet to
  digestible energy consumed (fraction).

- metabolic_energy_req_growth:

  Numeric. Energy required for growth (i.e., weight gain) (MJ/head/day).
  Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable
  energy for CML and PGS.

- metabolic_energy_req_fibre_production:

  Numeric. Energy required for the synthesis of fibre for SHP, GTS
  and CML. Assumed to be 0 for other species (MJ/head/day). Expressed as
  net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML
  and PGS (MJ/head/day).

- metabolic_energy_req_egg_deposition:

  Numeric. Net energy for egg production (MJ/head/day).

- net_energy_growth_digestible_energy_ratio:

  Numeric. Ratio of net energy available for growth in the diet to
  digestible energy consumed (fraction)

- ration_digestibility_fraction:

  Numeric. Average digestibility of the feed ration, expressed as ratio
  of digestible to gross energy content (fraction).

## Value

Numeric. Total daily energy requirement (MJ/head/day). For CTL, BFL, SHP
and GTS this is expressed as gross energy intake requirement (GE). For
CML and PGS the function returns the summed daily metabolizable energy
requirement.

## Details

This component follows the IPCC Tier 2 partitioning approach and the
calculation is computed differently depending on whether species energy
requirements are expressed as net or metabolizable energy.

**Species-specific approach:**

- **Energy requirements expressed as net energy (`CTL`, `BFL`, `SHP`,
  `GTS`)**

  - **`CTL` and `BFL`**: \$\$ metabolic\\energy\\req\\total = \frac{
    \left( \frac{ metabolic\\energy\\req\\maintenance +
    metabolic\\energy\\req\\activity +
    metabolic\\energy\\req\\lactation + metabolic\\energy\\req\\work +
    metabolic\\energy\\req\\pregnancy }{REM} \right) + \left(
    \frac{metabolic\\energy\\req\\growth}{REG} \right)
    }{diet\\digestibility\\fraction} \$\$

  - **`SHP` and `GTS`**: \$\$ metabolic\\energy\\req\\total = \frac{
    \left( \frac{ metabolic\\energy\\req\\maintenance +
    metabolic\\energy\\req\\activity +
    metabolic\\energy\\req\\lactation +
    metabolic\\energy\\req\\pregnancy }{REM} \right) + \left( \frac{
    metabolic\\energy\\req\\growth + metabolic\\energy\\req\\fibre
    }{REG} \right) }{diet_digestibility_fraction} \$\$

- **Energy requirements expressed as metabolizable energy (`CML`,
  `PGS`)**

  For these species, the total daily requirement is computed as the
  **direct sum** of relevant energy components (MJ/head/day).

  - **`CML`**: \$\$ metabolic\\energy\\req\\total =
    metabolic\\energy\\req\\maintenance +
    metabolic\\energy\\req\\activity +
    metabolic\\energy\\req\\lactation + metabolic\\energy\\req\\work +
    metabolic\\energy\\req\\fibre\\production +
    metabolic\\energy\\req\\pregnancy + metabolic\\energy\\req\\growth
    \$\$

  - **`PGS`**: \$\$ metabolic\\energy\\req\\total =
    metabolic\\energy\\req\\maintenance +
    metabolic\\energy\\req\\activity +
    metabolic\\energy\\req\\lactation +
    metabolic\\energy\\req\\pregnancy + metabolic\\energy\\req\\growth
    \$\$

This function is part of the
[`run_metabolic_energy_req_module()`](https://github.com/un-fao/GLEAM/reference/run_metabolic_energy_req_module.md).

## References

IPCC. (2019). *2019 Refinement to the 2006 IPCC Guidelines for National
Greenhouse Gas Inventories*, Chapter 10: Emissions from Livestock and
Manure Management, Equation 10.16.

IPCC. (2006). *2006 IPCC Guidelines for National Greenhouse Gas
Inventories*, Chapter 10: Emissions from Livestock and Manure
Management, Equation 10.16.

## See also

[`run_metabolic_energy_req_module`](https://github.com/un-fao/GLEAM/reference/run_metabolic_energy_req_module.md),
[`calc_metabolic_energy_req_maintenance`](https://github.com/un-fao/GLEAM/reference/calc_metabolic_energy_req_maintenance.md)
[`calc_metabolic_energy_req_activity`](https://github.com/un-fao/GLEAM/reference/calc_metabolic_energy_req_activity.md)
[`calc_metabolic_energy_req_growth`](https://github.com/un-fao/GLEAM/reference/calc_metabolic_energy_req_growth.md)
[`calc_metabolic_energy_req_lactation`](https://github.com/un-fao/GLEAM/reference/calc_metabolic_energy_req_lactation.md)
[`calc_metabolic_energy_req_work`](https://github.com/un-fao/GLEAM/reference/calc_metabolic_energy_req_work.md)
[`calc_metabolic_energy_req_fibre`](https://github.com/un-fao/GLEAM/reference/calc_metabolic_energy_req_fibre.md)
[`calc_metabolic_energy_req_pregnancy`](https://github.com/un-fao/GLEAM/reference/calc_metabolic_energy_req_pregnancy.md)
[`calc_rem_maintenance`](https://github.com/un-fao/GLEAM/reference/calc_rem_maintenance.md)
[`calc_reg_growth`](https://github.com/un-fao/GLEAM/reference/calc_reg_growth.md)
[`calc_ration_intake`](https://github.com/un-fao/GLEAM/reference/calc_ration_intake.md)
