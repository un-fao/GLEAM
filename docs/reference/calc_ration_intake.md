# Calculate daily ration intake in dry matter

Calculates daily feed intake as dry matter intake (DMI) per animal (kg
DM/head/day) from the animal's daily energy requirement and the diet
energy density.

## Usage

``` r
calc_ration_intake(
  species_short,
  metabolic_energy_req_total,
  ration_gross_energy,
  ration_metabolizable_energy
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

- metabolic_energy_req_total:

  Numeric. Total daily energy requirement (MJ/head/day). For CTL, BFL,
  SHP and GTS this is expressed as gross energy intake requirement (GE).
  For CML and PGS the function returns the summed daily metabolizable
  energy requirement.

- ration_gross_energy:

  Numeric. Average gross energy content of the diet (MJ/kg DM).

- ration_metabolizable_energy:

  Numeric. Average metabolizable energy content of the diet (MJ/kg DM).

## Value

Numeric. Average daily dry matter intake of feed (kg DM/head/day).

## Details

This function follows the IPCC Tier 2 framework. DMI is computed by
dividing the appropriate daily energy requirement by the corresponding
diet energy content (MJ/kg DM).

- **Energy expressed as gross energy intake requirement - `CTL`, `BFL`,
  `SHP`, `GTS`**:

  \$\$ ration\\intake =
  \frac{metabolic\\energy\\req\\total}{ration\\gross\\energy} \$\$

- **Energy expressed as metabolizable energy requirement - `CML`,
  `PGS`**:

  \$\$ ration\\intake =
  \frac{metabolic\\energy\\req\\total}{ration\\metabolizable\\energy}
  \$\$

This function is part of the
[`run_metabolic_energy_req_module()`](https://github.com/un-fao/GLEAM/reference/run_metabolic_energy_req_module.md).

## References

IPCC. (2006). *2006 IPCC Guidelines for National Greenhouse Gas
Inventories*, Volume 4 (AFOLU), Chapter 10: *Emissions from Livestock
and Manure Management*.

IPCC. (2019). *2019 Refinement to the 2006 IPCC Guidelines for National
Greenhouse Gas Inventories*, Volume 4 (AFOLU), Chapter 10: *Emissions
from Livestock and Manure Management*.

## See also

[`run_metabolic_energy_req_module`](https://github.com/un-fao/GLEAM/reference/run_metabolic_energy_req_module.md),
[`calc_total_metabolic_energy_req`](https://github.com/un-fao/GLEAM/reference/calc_total_metabolic_energy_req.md)
[`calc_ration_gross_energy`](https://github.com/un-fao/GLEAM/reference/calc_ration_gross_energy.md)
[`calc_ration_metabolizable_energy`](https://github.com/un-fao/GLEAM/reference/calc_ration_metabolizable_energy.md)
