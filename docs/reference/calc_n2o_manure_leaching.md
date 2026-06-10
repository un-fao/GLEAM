# Calculate indirect Nitrous Oxide (N2O) emissions from manure leaching and runoff

Calculates daily indirect nitrous oxide (N2O) emissions resulting from
nitrogen leaching and runoff from manure management systems and
separates emissions from manure deposited on pasture, manure burned for
fuel, and all other manure management systems.

## Usage

``` r
calc_n2o_manure_leaching(ratio_N2ON_to_N2O = 44/28, nitrogen_excretion, ...)
```

## Arguments

- ratio_N2ON_to_N2O:

  Numeric. Conversion factor from kg N2O–N to kg N2O, based on molecular
  weights. Defaults to 44/28.

- nitrogen_excretion:

  Numeric. Daily nitrogen excretion (kg N/head/day).

- ...:

  A variable number of manure management system (MMS) arguments. Each
  MMS must be provided as a named numeric vector with exactly the
  following fields:

  manure_management_system_fraction

  :   Numeric. Fraction of total manure excreted by animals in a given
      herd and cohort that is handled in a specific manure management
      system. Values ranges from 0 to 1. The sum of all fractions for
      each herd_id must equal 1.

  n2o_ef5

  :   Numeric. Emission factor for indirect nitrous oxide (N2O)
      emissions resulting from nitrogen leaching and runoff, expressed
      as kilograms of N2O–N per kilogram of nitrogen leached or lost
      through runoff (kg N2O–N / kg N). Default values can be selected
      from Table 11.3 in IPCC Guidelines (IPCC 2006, 2019).

  nitrogen_fracleach

  :   Numeric. Fraction of manure nitrogen excreted by a given livestock
      category that is lost through leaching and runoff from a specific
      manure management system. This parameter is highly uncertain and
      is used to estimate indirect N2O emissions from nitrogen that
      enters the surrounding environment of the storage facility. It is
      expressed as a dimensionless fraction (0–1). Default values are
      provided in Table 10.22 of IPCC Guidelines (IPCC 2006, 2019).

  Two MMS names are treated explicitly when present:

  `mms_pasture`

  :   Manure deposited on pasture.

  `mms_burned`

  :   Manure burned for fuel.

  All remaining MMS arguments are grouped and treated as other manure
  management systems.

## Value

A named list with the following elements

- n2o_manure_pasture_leach:

  Numeric. Indirect nitrous oxide (N2O) emissions resulting from
  leaching and runoff of manure nitrogen from manure deposited on
  pasture (kg N2O/head/day).

- n2o_manure_burned_leach:

  Numeric. Indirect nitrous oxide (N2O) emissions resulting from
  leaching and runoff of manure nitrogen from manure burned for fuel (kg
  N2O/head/day).

- n2o_manure_other_leach:

  Numeric. Indirect nitrous oxide (N2O) emissions resulting from
  leaching and runoff of manure nitrogen from manure management systems,
  excluding losses from manure deposited on pasture and manure burned
  for fuel (kg N2O/head/day).

- n2o_manure_all_noburn_leach:

  Numeric. Indirect nitrous oxide (N2O) emissions resulting from
  leaching and runoff of manure nitrogen from manure management systems,
  excluding losses from manure burned for fuel (kg N2O/head/day).

## Details

This calculation follows the Tier 2 methodology for indirect N2O
emissions from manure management as defined in Equations 10.28 (IPCC,
2006), 10.27 (IPCC, 2019), and 10.29 (IPCC, 2006, 2019).

In the IPCC formulation, indirect emissions associated with nitrogen
leaching and runoff are calculated as:

\$\$ N2O\_{L(mm)} = \frac{44}{28} \sum\_{S} \left( N \times AWMS_S
\times FracLeach\_{S} \times EF5 \right) \$\$

where:

- \\N2O_L(mm)\\:

  Indirect N2O emissions due to leaching and runoff from Manure
  Management.

- \\44/28\\:

  Conversion factor from N2O–N to N2O.

- \\N\\:

  Nitrogen excreted (kg N).

- \\AWMS_S\\:

  Fraction of excreted nitrogen managed in manure management system
  \\S\\.

- \\FracLeach\_{S}\\:

  Fraction of nitrogen lost through leaching and runoff in manure
  management system \\S\\.

- \\EF5\\:

  Emission factor for indirect N2O emissions from leaching and runoff
  (kg N2O–N per kg N leached or lost through runoff).

In this implementation, calculations are performed at daily, per-head
resolution using `nitrogen_excretion` (kg N/head/day):

\$\$ \begin{aligned} N_2O &= nitrogen\\excretion \times
ratio\\N2ON\\to\\N2O \times \\ & \sum\_{S} \left(
manure\\management\\system\\fraction \times nitrogen\\fracleach \times
n2o\\ef5 \right) \end{aligned} \$\$

This function is part of the
[`run_emissions_manure_module()`](https://github.com/un-fao/GLEAM/reference/run_emissions_manure_module.md).

## References

IPCC. (2019). *2019 Refinement to the 2006 IPCC Guidelines for National
Greenhouse Gas Inventories*, Chapter 10: Emissions from Livestock and
Manure Management. Equations 10.27; 10.29.

IPCC. (2006). *2006 IPCC Guidelines for National Greenhouse Gas
Inventories*, Volume 4, Chapter 10: Emissions from Livestock and Manure
Management. Equations 10.28; 10.29.

## See also

[`run_emissions_manure_module`](https://github.com/un-fao/GLEAM/reference/run_emissions_manure_module.md)

## Examples

``` r
calc_n2o_manure_leaching(
  ratio_N2ON_to_N2O = 44 / 28,
  nitrogen_excretion = 0.9,
  mms_burned = c(
    manure_management_system_fraction = 0.020,
    n2o_ef5 = 0.011,
    nitrogen_fracleach = 0
  ),
  mms_drylot = c(
    manure_management_system_fraction = 0.264,
    n2o_ef5 = 0.011,
    nitrogen_fracleach = 0.035
  ),
  mms_pasture = c(
    manure_management_system_fraction = 0.310,
    n2o_ef5 = 0.011,
    nitrogen_fracleach = 0.24
  ),
  mms_solid = c(
    manure_management_system_fraction = 0.406,
    n2o_ef5 = 0.011,
    nitrogen_fracleach = 0.02
  )
)
#> $n2o_manure_pasture_leach
#> [1] 0.001157451
#> 
#> $n2o_manure_burned_leach
#> [1] 0
#> 
#> $n2o_manure_other_leach
#> [1] 0.000270072
#> 
#> $n2o_manure_all_noburn_leach
#> [1] 0.001427523
#> 
```
