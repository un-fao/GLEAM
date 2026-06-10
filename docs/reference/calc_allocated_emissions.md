# Calculate allocated greenhouse gas emissions (GHG)

Calculates the greenhouse gas emissions (GHG) attributable to specific
commodities by applying allocation shares to total herd-level emissions.

## Usage

``` r
calc_allocated_emissions(value, allocation_share)
```

## Arguments

- value:

  Numeric. Total herd-level emissions by source before allocation to
  commodities (kg gas).

- allocation_share:

  Numeric. Allocation share assigned to the commodity for the
  corresponding emission source (fraction).

## Value

Numeric. Allocated emissions for each commodity–emission combination (kg
gas).

## Details

Allocation shares represent the fraction of total emissions assigned to
each commodity (e.g., meat, milk, fibre). See
[`run_allocation_module()`](https://github.com/un-fao/GLEAM/reference/run_allocation_module.md)
for additional details.

Allocated emissions are calculated as:

\$\$value\\allocated = value \times allocation\\share\$\$

This function is part of the
[`run_aggregation_module()`](https://github.com/un-fao/GLEAM/reference/run_aggregation_module.md).

## See also

[`run_aggregation_module()`](https://github.com/un-fao/GLEAM/reference/run_aggregation_module.md),
[`run_allocation_module()`](https://github.com/un-fao/GLEAM/reference/run_allocation_module.md)
