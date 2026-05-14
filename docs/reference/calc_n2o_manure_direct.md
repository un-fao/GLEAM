# Calculate direct Nitrous Oxide (N2O) emissions from manure management systems

Calculates daily direct nitrous oxide (N2O) emissions from manure
management using IPCC-based parameters and separates emissions from
manure deposited on pasture, manure burned for fuel, and all other
manure management systems.

## Usage

``` r
calc_n2o_manure_direct(ratio_N2ON_to_N2O = 44/28, nitrogen_excretion, ...)
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
      system. Value ranges from 0 to 1. The sum of all fractions for
      each herd_id must equal 1.

  n2o_ef3

  :   Numeric. Emission factor for direct nitrous oxide (N2O) emissions
      for each manure management system, representing nitrous oxide
      emitted per unit of nitrogen from nitrification and
      denitrification processes occurring during manure storage and
      treatment (kg N2O–N per kg N). Default values may be selected from
      Table 10.21 and Table 11.1 (for manure deposited on pasture) in
      IPCC Guidelines (IPCC 2006, 2019).

  Two MMS names are treated explicitly when present:

  `mms_pasture`

  :   Manure deposited on pasture.

  `mms_burned`

  :   Manure burned for fuel.

  All remaining MMS arguments are grouped and treated as other manure
  management systems.

## Value

A named list with the following elements:

- n2o_manure_pasture_direct:

  Numeric. Direct nitrous oxide (N2O) emissions from manure deposited on
  pasture (kg N2O/head/day).

- n2o_manure_burned_direct:

  Numeric. Direct nitrous oxide (N2O) emissions from manure burned for
  fuel (kg N2O/head/day).

- n2o_manure_other_direct:

  Numeric. Direct nitrous oxide (N2O) emissions from manure management
  systems, excluding emissions from manure deposited on pasture and
  burned for fuel (kg N2O/head/day).

- n2o_manure_all_noburn_direct:

  Numeric. Direct nitrous oxide (N2O) emissions from manure management
  systems, excluding manure burned for fuel (kg N2O/head/day).

## Details

This calculation follows the Tier 2 methodology for direct nitrous oxide
(N2O) emissions from manure management as defined in the IPCC Guidelines
(Equation 10.25).

In the IPCC formulation, annual direct emissions are:

\$\$ N2O\_{D(mm)} = \frac{44}{28} \sum\_{S} \left( N \times AWMS_S
\times EF3_S \right) \$\$

where:

- \\N2O_D(mm)\\:

  Direct N2O emissions from Manure Management.

- \\44/28\\:

  Conversion factor from N2O–N to N2O.

- \\N\\:

  Nitrogen excreted (kg N).

- \\AWMS_S\\:

  Fraction of excreted nitrogen managed in manure management system
  \\S\\.

- \\EF3_S\\:

  Direct emission factor for system \\S\\ (kg N2O–N per kg N managed).

In this implementation, calculations are performed at daily, per-head
resolution using `nitrogen_excretion` (kg N/head/day) - see also
[`calc_nitrogen_excretion`](https://github.com/un-fao/GLEAM/reference/calc_nitrogen_excretion.md).

Daily emissions are computed as:

\$\$ \begin{aligned} N2O &= nitrogen\\excretion \times
ratio\\N2ON\\to\\N2O \times \\ & \sum \left(
manure\\management\\system\\fraction \times n2o\\ef3 \right)
\end{aligned} \$\$

This function is part of the
[`run_emissions_manure_module()`](https://github.com/un-fao/GLEAM/reference/run_emissions_manure_module.md).

## References

IPCC. (2019). *2019 Refinement to the 2006 IPCC Guidelines for National
Greenhouse Gas Inventories*, Chapter 10: Emissions from Livestock and
Manure Management. Equation 10.25.

IPCC. (2006). *2006 IPCC Guidelines for National Greenhouse Gas
Inventories*, Chapter 10: Emissions from Livestock and Manure
Management. Equation 10.25.

## See also

[`run_emissions_manure_module`](https://github.com/un-fao/GLEAM/reference/run_emissions_manure_module.md)

## Examples

``` r
calc_n2o_manure_direct(
  ratio_N2ON_to_N2O = 44 / 28,
  nitrogen_excretion = 0.9,
  mms_burned = c(
    manure_management_system_fraction = 0.020,
    n2o_ef3  = 0
  ),
  mms_drylot = c(
    manure_management_system_fraction = 0.264,
    n2o_ef3  = 0.02
  ),
  mms_pasture = c(
    manure_management_system_fraction = 0.310,
    n2o_ef3  = 0.02
  ),
  mms_solid = c(
    manure_management_system_fraction = 0.406,
    n2o_ef3  = 0.005
  )
)
#> $n2o_manure_pasture_direct
#> [1] 0.008768571
#> 
#> $n2o_manure_burned_direct
#> [1] 0
#> 
#> $n2o_manure_other_direct
#> [1] 0.01033843
#> 
#> $n2o_manure_all_noburn_direct
#> [1] 0.019107
#> 
```
