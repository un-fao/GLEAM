# Calculate a ration component's contribution to methane (CH4) emissions from rice cultivation

Calculates the contribution of an individual feed component to methane
(CH4) emissions from rice cultivation in feed production, using
feed-specific emission factors weighted by the component's share in the
ration.

## Usage

``` r
calc_ch4_ration_rice(feed_ration_fraction, ch4_feed_rice)
```

## Arguments

- feed_ration_fraction:

  Numeric. Proportion of a specific feed component in the total ration,
  expressed as its fraction of diet dry matter intake (fraction). Within
  each herd_id and cohort, proportions should sum to 1.

- ch4_feed_rice:

  Numeric. Methane (CH4) emission factor of a feed component,
  representing CH4 emissions from rice cultivation in feed production,
  expressed per kg of dry matter intake (g CH4/kg DM).

## Value

Numeric. Contribution of an individual feed component to the diet-level
average methane (CH4) emission factor from rice cultivation in feed
production (g CH4/kg DM).

## Details

The contribution is computed as:

\$\$diet\\ch4\\feed\\rice = feed\\ration\\fraction \times
ch4\\feed\\rice\$\$

This function is part of the
[`run_emissions_ration_module()`](https://github.com/un-fao/GLEAM/reference/run_emissions_ration_module.md).

## See also

[`run_emissions_ration_module`](https://github.com/un-fao/GLEAM/reference/run_emissions_ration_module.md)
