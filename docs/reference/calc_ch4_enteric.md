# Calculate daily enteric methane emissions

Calculates daily enteric methane emissions (kg CH4/head/day) based on
gross energy intake, methane conversion factor (ym), and dry matter
intake.

## Usage

``` r
calc_ch4_enteric(
  species_short,
  ch4_conversion_factor_ym,
  ch4_mitigation_factor,
  ration_gross_energy,
  ration_intake
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

- ch4_conversion_factor_ym:

  Numeric. Methane (CH4) conversion factor (ym), representing the
  percentage of gross energy of the feed ration that is converted to CH4
  (percentage).

- ch4_mitigation_factor:

  Numeric. Optional. Multiplicative mitigation factor applied to
  baseline enteric methane (CH4) emissions (dimensionless). If not
  provided, a default value of `1` (no mitigation) is used. Values lower
  than 1 represent proportional reductions (e.g., `0.90` = 10%
  reduction). This factor can represent mitigation measures with a
  direct effect on enteric methane emissions, such as the use of feed
  additives or methane inhibitors.

- ration_gross_energy:

  Numeric. Average gross energy content of the diet (MJ/kg DM).

- ration_intake:

  Numeric. Average daily dry matter intake of feed (kg DM/head/day).

## Value

Numeric. Average daily enteric methane (CH4) emissions (kg
CH4/head/day).

## Details

The formula used to estimate daily enteric methane emissions is:

\$\$CH_4 = \frac{ration\\gross\\energy \times ration\\intake \times
ch4\\conversion\\factor\\ym}{55.65 \times 100}\$\$

where 55.65 MJ/kg is the energy content of methane.

`ration_gross_energy` and `ration_intake` can be calculated with
[`calc_ration_gross_energy`](https://github.com/un-fao/GLEAM/reference/calc_ration_gross_energy.md)
and
[`calc_ration_intake`](https://github.com/un-fao/GLEAM/reference/calc_ration_intake.md)
( see also
[`run_ration_quality_module`](https://github.com/un-fao/GLEAM/reference/run_ration_quality_module.md)
and
[`run_metabolic_energy_req_module`](https://github.com/un-fao/GLEAM/reference/run_metabolic_energy_req_module.md)).

This function is part of the
[`run_emissions_enteric_module()`](https://github.com/un-fao/GLEAM/reference/run_emissions_enteric_module.md).

## References

IPCC. (2019). *2019 Refinement to the 2006 IPCC Guidelines for National
Greenhouse Gas Inventories*. Chapter 10: Emissions from Livestock and
Manure Management, Equation 10.21.

IPCC. (2006). *2006 IPCC Guidelines for National Greenhouse Gas
Inventories*. Chapter 10: Emissions from Livestock and Manure
Management, Equation 10.21.

## See also

[`run_emissions_enteric_module`](https://github.com/un-fao/GLEAM/reference/run_emissions_enteric_module.md),
[`calc_ration_gross_energy`](https://github.com/un-fao/GLEAM/reference/calc_ration_gross_energy.md),
[`calc_ration_intake`](https://github.com/un-fao/GLEAM/reference/calc_ration_intake.md),
[`run_ration_quality_module`](https://github.com/un-fao/GLEAM/reference/run_ration_quality_module.md)
[`run_metabolic_energy_req_module`](https://github.com/un-fao/GLEAM/reference/run_metabolic_energy_req_module.md)
