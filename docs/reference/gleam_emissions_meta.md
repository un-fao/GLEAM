# Emissions variable metadata

All direct and indirect emission sources handled by the allocation and
aggregation modules. Each element contains `emissions_source` (the
column name in cohort-level data) and `label` (the string used in the
aggregated long-form output).

## Usage

``` r
gleam_emissions_meta
```

## Format

An object of class `list` of length 19.

## Details

The `emissions_source` values from this list are the canonical set
passed to
[`assign_allocation_shares()`](https://github.com/un-fao/GLEAM/reference/assign_allocation_shares.md)
in the allocation module and used to pivot the aggregation output.
Adding or renaming an emission source here automatically updates both
modules.
