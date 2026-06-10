# Calculate daily nitrogen excretion

Calculates daily nitrogen excretion per animal (kg N/head/day) as the
difference between nitrogen intake and nitrogen retention.

## Usage

``` r
calc_nitrogen_excretion(species_short, nitrogen_intake, nitrogen_retention)
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

- nitrogen_intake:

  Numeric. Daily nitrogen intake (kg N/head/day).

- nitrogen_retention:

  Numeric. Daily nitrogen retention in animal body tissues and products
  (e.g., growth, pregnancy, milk...) (kg N/head/day).

## Value

Numeric. Daily nitrogen excretion (kg N/head/day).

## Details

Nitrogen excretion represents the fraction of consumed nitrogen that is
not retained in animal tissues or products and is therefore excreted in
urine and dung.

Nitrogen excretion is calculated as:

\\nitrogen\\excretion = nitrogen\\intake - nitrogen\\retention\\

where all quantities are expressed in kg N/head/day.

This quantity forms the basis for subsequent calculations of nitrous
oxide (N2O) emissions from manure management under the IPCC Tier 2
methodology.

## References

IPCC. (2019). *2019 Refinement to the 2006 IPCC Guidelines for National
Greenhouse Gas Inventories*, Chapter 10: Emissions from Livestock and
Manure Management. Equation 10.31A.

This function is part of the
[`run_nitrogen_balance_module()`](https://github.com/un-fao/GLEAM/reference/run_nitrogen_balance_module.md).

## See also

[`run_nitrogen_balance_module`](https://github.com/un-fao/GLEAM/reference/run_nitrogen_balance_module.md),
[`calc_nitrogen_retention`](https://github.com/un-fao/GLEAM/reference/calc_nitrogen_retention.md)
