# Calculate total Nitrous Oxide (N2O) emissions from manure

Aggregates direct and indirect nitrous oxide (N2O) emissions from
manure, by manure management system group (deposited on pasture, burned
for fuel, and all other systems). Indirect emissions include
contributions from volatilization and from leaching and runoff.

## Usage

``` r
calc_n2o_manure_total(
  n2o_manure_pasture_vol,
  n2o_manure_pasture_leach,
  n2o_manure_burned_vol,
  n2o_manure_burned_leach,
  n2o_manure_other_vol,
  n2o_manure_other_leach,
  n2o_manure_pasture_direct,
  n2o_manure_burned_direct,
  n2o_manure_other_direct
)
```

## Arguments

- n2o_manure_pasture_vol:

  Numeric. Indirect nitrous oxide (N2O) emissions resulting from
  atmospheric deposition of volatilised nitrogen (NH3 and NOx) from
  manure deposited on pasture (kg N2O/head/day).

- n2o_manure_pasture_leach:

  Numeric. Indirect nitrous oxide (N2O) emissions resulting from
  leaching and runoff of manure nitrogen from manure deposited on
  pasture (kg N2O/head/day).

- n2o_manure_burned_vol:

  Numeric. Indirect nitrous oxide (N2O) emissions resulting from
  atmospheric deposition of volatilised nitrogen (NH3 and NOx) from
  manure burned for fuel (kg N2O/head/day).

- n2o_manure_burned_leach:

  Numeric. Indirect nitrous oxide (N2O) emissions resulting from
  leaching and runoff of manure nitrogen from manure burned for fuel (kg
  N2O/head/day).

- n2o_manure_other_vol:

  Numeric. Indirect nitrous oxide (N2O) emissions resulting from
  atmospheric deposition of volatilised nitrogen (NH3 and NOx) from
  manure management systems, excluding manure deposited on pasture and
  manure burned for fuel (kg N2O/head/day).

- n2o_manure_other_leach:

  Numeric. Indirect nitrous oxide (N2O) emissions resulting from
  leaching and runoff of manure nitrogen from manure management systems,
  excluding losses from manure deposited on pasture and manure burned
  for fuel (kg N2O/head/day).

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

## Value

A named list with:

- n2o_manure_pasture_indirect:

  Numeric. Total indirect nitrous oxide (N2O) emissions from manure
  deposited on pasture. Includes emissions from atmospheric deposition
  of volatilised nitrogen (NH3 and NOx) and from leaching and runoff of
  manure nitrogen (kg N2O/head/day).

- n2o_manure_burned_indirect:

  Numeric. Total indirect nitrous oxide (N2O) emissions originating from
  manure burned for fuel. Includes emissions from atmospheric deposition
  of volatilised nitrogen (NH3 and NOx) and from leaching and runoff of
  manure nitrogen (kg N2O/head/day).

- n2o_manure_other_indirect:

  Numeric. Total indirect nitrous oxide (N2O) emissions originating from
  manure management systems, excluding manure deposited on pasture and
  manure burned for fuel. Includes emissions from atmospheric deposition
  of volatilised nitrogen (NH3 and NOx) and from leaching and runoff of
  manure nitrogen (kg N2O/head/day).

- n2o_manure_pasture_total:

  Numeric. Total nitrous oxide (N2O) emissions from manure deposited on
  pasture. Includes direct emissions and indirect emissions from
  volatilisation, leaching, and runoff (kg N2O/head/day).

- n2o_manure_burned_total:

  Numeric. Total nitrous oxide (N2O) emissions from manure burned for
  fuel. Includes direct emissions and indirect emissions from
  volatilisation, leaching, and runoff (kg N2O/head/day).

- n2o_manure_other_total:

  Numeric. Total nitrous oxide (N2O) emissions from manure management
  systems, excluding manure deposited on pasture and manure burned for
  fuel. Includes direct emissions and indirect emissions from
  volatilisation, leaching, and runoff (kg N2O/head/day).

This function is part of the
[`run_emissions_manure_module()`](https://github.com/un-fao/GLEAM/reference/run_emissions_manure_module.md).

## Details

The following aggregations are applied: \$\$
n2o\\manure\\pasture\\indirect = n2o\\vol\\manure\\pasture +
n2o\\leach\\manure\\pasture \$\$ \$\$ n2o\\manure\\burned\\indirect =
n2o\\vol\\manure\\burned + n2o\\leach\\manure\\burned \$\$ \$\$
n2o\\manure\\other\\indirect = n2o\\vol\\manure\\other +
n2o\\leach\\manure\\other \$\$ \$\$ n2o\\manure\\pasture\\total =
n2o\\manure\\pasture\\indirect + n2o\\manure\\pasture\\direct \$\$ \$\$
n2o\\manure\\burned\\total = n2o\\manure\\burned\\indirect +
n2o\\manure\\burned\\direct \$\$ \$\$ n2o\\manure\\other\\total =
n2o\\manure\\other\\indirect + n2o\\manure\\other\\direct \$\$

## See also

[`run_emissions_manure_module`](https://github.com/un-fao/GLEAM/reference/run_emissions_manure_module.md)

## Examples

``` r
calc_n2o_manure_total(
  n2o_manure_pasture_vol = 0.0129,
  n2o_manure_pasture_leach = 0.0012,
  n2o_manure_burned_vol = 0,
  n2o_manure_burned_leach = 0,
  n2o_manure_other_vol = 0.052,
  n2o_manure_other_leach = 0.00027,
  n2o_manure_pasture_direct = 0.009,
  n2o_manure_burned_direct = 0,
  n2o_manure_other_direct = 0.01033
)
#> $n2o_manure_pasture_indirect
#> [1] 0.0141
#> 
#> $n2o_manure_burned_indirect
#> [1] 0
#> 
#> $n2o_manure_other_indirect
#> [1] 0.05227
#> 
#> $n2o_manure_pasture_total
#> [1] 0.0231
#> 
#> $n2o_manure_burned_total
#> [1] 0
#> 
#> $n2o_manure_other_total
#> [1] 0.0626
#> 
```
