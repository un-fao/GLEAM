# Calculate indirect Nitrous Oxide (N2O) emissions from manure volatilization

Calculates daily indirect nitrous oxide (N2O) emissions resulting from
atmospheric deposition of volatilised nitrogen (NH3–N and NOx–N) from
manure management systems and separates emissions from manure deposited
on pasture, manure burned for fuel, and all other manure management
systems.

## Usage

``` r
calc_n2o_manure_volatilization(
  ratio_N2ON_to_N2O = 44/28,
  nitrogen_excretion,
  ...
)
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

  n2o_ef4

  :   Numeric. Emission factor for indirect nitrous oxide (N2O)
      emissions resulting from atmospheric deposition of volatilised
      nitrogen (NH3–N and NOx–N) onto soils and water surfaces (kg N2O–N
      per kg NH3–N + NOx–N). Default values can be selected from Table
      11.3 in IPCC Guidelines (IPCC 2006, 2019).

  nitrogen_fracgas

  :   Numeric. Fraction of manure nitrogen excreted by a given livestock
      category that is lost through volatilisation as ammonia (NH3) and
      nitrogen oxides (NOx) within a specific manure management system.
      This parameter represents the share of excreted nitrogen that is
      mineralised and released to the atmosphere during manure
      collection, storage, and treatment. It is expressed as a
      dimensionless fraction (0–1). Default values are provided in Table
      10.22 of IPCC Guidelines (IPCC 2006, 2019).

  Two MMS names are treated explicitly when present:

  `mms_pasture`

  :   Manure deposited on pasture.

  `mms_burned`

  :   Manure burned for fuel.

  All remaining MMS arguments are grouped and treated as other manure
  management systems.

## Value

A named list with the following elements:

- n2o_manure_pasture_vol:

  Numeric. Indirect nitrous oxide (N2O) emissions resulting from
  atmospheric deposition of volatilised nitrogen (NH3 and NOx) from
  manure deposited on pasture (kg N2O/head/day).

- n2o_manure_burned_vol:

  Numeric. Indirect nitrous oxide (N2O) emissions resulting from
  atmospheric deposition of volatilised nitrogen (NH3 and NOx) from
  manure burned for fuel (kg N2O/head/day).

- n2o_manure_other_vol:

  Numeric. Indirect nitrous oxide (N2O) emissions resulting from
  atmospheric deposition of volatilised nitrogen (NH3 and NOx) from
  manure management systems, excluding manure deposited on pasture and
  manure burned for fuel (kg N2O/head/day).

- n2o_manure_all_noburn_vol:

  Numeric. Indirect nitrous oxide (N2O) emissions resulting from
  atmospheric deposition of volatilised nitrogen (NH3 and NOx) from
  manure management systems, excluding losses from manure burned for
  fuel (kg N2O/head/day).

## Details

This calculation follows the Tier 2 methodology for indirect N2O
emissions from manure management as defined in the IPCC Guidelines in
Equations 10.26 (IPCC, 2006, 2019), 10.27 (IPCC, 2006) and 10.28 (IPCC,
2019).

In the IPCC formulation, indirect emissions from atmospheric deposition
of volatilised nitrogen are calculated as:

\$\$ N2O\_{G(mm)} = \frac{44}{28} \sum\_{S} \left( N \times AWMS_S
\times FracGas\_{S} \times EF4 \right) \$\$

where:

- \\N2O_G(mm)\\:

  Indirect N2O emissions due to volatilization of N from Manure
  Management.

- \\44/28\\:

  Conversion factor from N2O-N to N2O.

- \\N\\:

  Nitrogen excreted (kg N).

- \\AWMS_S\\:

  Fraction of excreted nitrogen managed in manure management system
  \\S\\.

- \\FracGas\_{S}\\:

  Fraction of nitrogen volatilised as NH3–N and NOx–N in manure
  management system \\S\\.

- \\EF4\\:

  Emission factor for indirect N2O emissions from atmospheric deposition
  (kg N2O-N per kg NH3–N + NOx–N).

In this implementation, calculations are performed at daily, per-head
resolution using `nitrogen_excretion` (kg N/head/day):

\$\$ \begin{aligned} N_2O &= nitrogen\\excretion \times
ratio\\N2ON\\to\\N2O \times \\ & \sum\_{S} \left(
manure\\management\\system\\fraction \times nitrogen\\fracgas \times
n2o\\ef4 \right) \end{aligned} \$\$

This function is part of the
[`run_emissions_manure_module()`](https://github.com/un-fao/GLEAM/reference/run_emissions_manure_module.md).

## References

IPCC. (2019). *2019 Refinement to the 2006 IPCC Guidelines for National
Greenhouse Gas Inventories*, Chapter 10: Emissions from Livestock and
Manure Management. Equation 10.26; 10.28.

IPCC. (2006). *2006 IPCC Guidelines for National Greenhouse Gas
Inventories*, Chapter 10: Emissions from Livestock and Manure
Management. Equation 10.26; 10.27.

## See also

[`run_emissions_manure_module`](https://github.com/un-fao/GLEAM/reference/run_emissions_manure_module.md)

## Examples

``` r
calc_n2o_manure_volatilization(
  ratio_N2ON_to_N2O = 44 / 28,
  nitrogen_excretion = 0.9,
  mms_burned = c(
    manure_management_system_fraction = 0.020,
    n2o_ef4 = 0.14,
    nitrogen_fracgas = 0
  ),
  mms_drylot = c(
    manure_management_system_fraction = 0.264,
    n2o_ef4 = 0.14,
    nitrogen_fracgas = 0.3
  ),
  mms_pasture = c(
    manure_management_system_fraction = 0.310,
    n2o_ef4 = 0.14,
    nitrogen_fracgas = 0.21
  ),
  mms_solid = c(
    manure_management_system_fraction = 0.406,
    n2o_ef4 = 0.14,
    nitrogen_fracgas = 0.45
  )
)
#> $n2o_manure_pasture_vol
#> [1] 0.0128898
#> 
#> $n2o_manure_burned_vol
#> [1] 0
#> 
#> $n2o_manure_other_vol
#> [1] 0.0518562
#> 
#> $n2o_manure_all_noburn_vol
#> [1] 0.064746
#> 
```
