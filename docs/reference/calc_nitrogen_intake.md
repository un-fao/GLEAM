# Calculate daily nitrogen intake

Calculates the daily nitrogen intake per head (kg N/head/day) as the
product of feed dry matter intake (DMI) and diet nitrogen content.

## Usage

``` r
calc_nitrogen_intake(ration_intake, ration_nitrogen)
```

## Arguments

- ration_intake:

  Numeric. Average daily dry matter intake of feed (kg DM/head/day).

- ration_nitrogen:

  Numeric. Average nitrogen content of diet (kg N/kg DM).

## Value

Numeric. Daily nitrogen intake (kg N/head/day).

## Details

This approach follows the IPCC Tier 2 approach and estimates
`ration_intake` as follows:

\\nitrogen\\intake = dry\\matter\\intake \times diet\\nitrogen\\

This function is part of the
[`run_nitrogen_balance_module()`](https://github.com/un-fao/GLEAM/reference/run_nitrogen_balance_module.md).

## References

IPCC. (2019). *2019 Refinement to the 2006 IPCC Guidelines for National
Greenhouse Gas Inventories*, Chapter 10: Emissions from Livestock and
Manure Management. Equation 10.32.

IPCC. (2006). *2006 IPCC Guidelines for National Greenhouse Gas
Inventories*, Chapter 10: Emissions from Livestock and Manure
Management. Equation 10.32.

## See also

[`run_nitrogen_balance_module`](https://github.com/un-fao/GLEAM/reference/run_nitrogen_balance_module.md),
[`calc_ration_intake`](https://github.com/un-fao/GLEAM/reference/calc_ration_intake.md),
[`run_metabolic_energy_req_module`](https://github.com/un-fao/GLEAM/reference/run_metabolic_energy_req_module.md),
[`calc_ration_nitrogen_content`](https://github.com/un-fao/GLEAM/reference/calc_ration_nitrogen_content.md),
[`run_ration_quality_module`](https://github.com/un-fao/GLEAM/reference/run_ration_quality_module.md)
