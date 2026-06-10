# Calculate methane (CH4) emissions from manure management systems

Calculates daily methane emissions from manure management using
IPCC-based parameters and separates emissions from manure deposited on
pasture, manure burned for fuel, and all other manure management
systems.

## Usage

``` r
calc_ch4_manure(ratio_m3CH4_to_kgCH4 = 0.67, volatile_solids, ...)
```

## Arguments

- ratio_m3CH4_to_kgCH4:

  Numeric. Conversion factor used to convert methane (CH4) from
  volumetric unit (m3) to a mass unit (kg). This value represents the
  density of methane. It defaults to 0.67 kg/m3.

- volatile_solids:

  Numeric. Total volatile solids (VS) excreted per animal per day,
  representing the organic material in livestock manure and consisting
  of both biodegradable and non-biodegradable fractions (kg
  VS/head/day).

- ...:

  A variable number of manure management system (MMS) arguments. Each
  MMS must be provided as a named numeric vector with exactly the
  following fields:

  manure_management_system_fraction

  :   Numeric. Fraction of total manure excreted by animals in a given
      herd and cohort that is handled in a specific manure management
      system. Values ranges from 0 to 1. The sum of all fractions for
      each herd_id must equal 1.

  methane_conversion_factor_mcf

  :   Numeric. Methane conversion factor represents the portion or
      degree of the maximum methane producing capacity (\\B_0\\) that is
      effectively achieved within a specific manure management system.
      It represents the extent to which the theoretical methane yield is
      realized based on management practices and environmental
      conditions, specifically the temperature of the system, the
      retention time of the organic material, and the degree of
      anaerobic conditions present. The value theoretically ranges from
      0 to 100 percent. Default values can be selected from Table 10.17
      of the IPCC guidelines (IPCC 2006, 2019).

  ch4_max_producing_capacity_bo

  :   Numeric. Maximum methane producing capacity (\\B_0\\) for all
      manure management systems (m3 CH4 / kg VS). The value is region-
      and species-specific, and represents the theoretical maximum
      methane yield per unit of volatile solids.. Default values may be
      selected from Table 10.16 (IPCC, 2019) or from Tables 10A-4 to
      10A-9 (IPCC, 2006).

  Two MMS names are treated explicitly when present:

  `mms_pasture`

  :   Manure deposited on pasture.

  `mms_burned`

  :   Manure burned for fuel.

  All remaining MMS arguments are grouped and treated as other manure
  management systems.

## Value

A named list with the following elements:

- ch4_manure_pasture:

  Numeric. Methane (CH4) emissions from manure deposited on pasture (kg
  CH4/head/day).

- ch4_manure_burned:

  Numeric. Methane (CH4) emissions from manure burned for fuel (kg
  CH4/head/day).

- ch4_manure_other:

  Numeric. Methane (CH4) emissions from manure management systems,
  excluding emissions from manure deposited on pasture and burned for
  fuel (kg CH4/head/day).

- ch4_manure_all_noburn:

  Numeric. Methane (CH4) emissions from manure management systems,
  excluding manure burned for fuel (kg CH4/head/day).

## Details

This calculation follows the structure of IPCC Equation 10.23 for
methane (CH4) emission factors from manure management.

In the IPCC formulation, emissions are determined by combining:

- daily volatile solids excretion (`volatile_solids`) - see
  [`calc_volatile_solids`](https://github.com/un-fao/GLEAM/reference/calc_volatile_solids.md),

- the maximum methane-producing capacity (`b0`),

- the methane conversion factor (`mcf`) for each manure management
  system,

- and the fraction of manure handled in each system
  (`manure_management_system_fraction`).

Applying the IPCC conversion factor from m3 CH4 to kg CH4 (0.67), daily
methane emissions are calculated as:

\$\$ CH4 = volatile\\solids \times b0 \times 0.67 \times \sum \left(
\frac{mcf}{100} \times manure\\management\\system\\fraction \right) \$\$

The summation is taken over all manure management systems included in
the calculation. Results are expressed at daily resolution (kg
CH4/head/day), consistent with Equation 10.23 after adapting the
original annual formulation to a daily basis.

This function is part of the
[`run_emissions_manure_module()`](https://github.com/un-fao/GLEAM/reference/run_emissions_manure_module.md).

## References

IPCC. (2019). *2019 Refinement to the 2006 IPCC Guidelines for National
Greenhouse Gas Inventories*, Chapter 10: Emissions from Livestock and
Manure Management. Equation 10.23.

IPCC. (2006). *2006 IPCC Guidelines for National Greenhouse Gas
Inventories*, Chapter 10: Emissions from Livestock and Manure
Management. Equation 10.23.

## See also

[`run_emissions_manure_module`](https://github.com/un-fao/GLEAM/reference/run_emissions_manure_module.md),
[`calc_volatile_solids`](https://github.com/un-fao/GLEAM/reference/calc_volatile_solids.md)

[`run_emissions_manure_module`](https://github.com/un-fao/GLEAM/reference/run_emissions_manure_module.md),
[`calc_volatile_solids`](https://github.com/un-fao/GLEAM/reference/calc_volatile_solids.md)

## Examples

``` r
calc_ch4_manure(
  ratio_m3CH4_to_kgCH4 = 0.67,
  volatile_solids   = 2.024,
  mms_burned = c(
    manure_management_system_fraction = 0.020,
    methane_conversion_factor_mcf = 10,
    ch4_max_producing_capacity_bo = 0.13
  ),
  mms_drylot = c(
    manure_management_system_fraction = 0.264,
    methane_conversion_factor_mcf = 2,
    ch4_max_producing_capacity_bo = 0.13
  ),
  mms_pasture = c(
    manure_management_system_fraction = 0.310,
    methane_conversion_factor_mcf = 0.47,
    ch4_max_producing_capacity_bo = 0.19
  ),
  mms_solid = c(
    manure_management_system_fraction = 0.406,
    methane_conversion_factor_mcf = 5,
    ch4_max_producing_capacity_bo = 0.13
  )
)
#> $ch4_manure_pasture
#> [1] 0.0003754036
#> 
#> $ch4_manure_burned
#> [1] 0.0003525808
#> 
#> $ch4_manure_other
#> [1] 0.004509508
#> 
#> $ch4_manure_all_noburn
#> [1] 0.004884912
#> 
```
