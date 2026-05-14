# Calculate a ration component's contribution to carbon dioxide (CO2) emissions from land-use change (excluding peatland drainage)

Calculates the contribution of an individual feed component to carbon
dioxide (CO2) emissions from land-use change in feed production
(excluding peatland drainage), using feed-specific emission factors
weighted by the component's share in the ration.

## Usage

``` r
calc_co2_ration_luc_nopeat(feed_ration_fraction, co2_feed_luc_nopeat)
```

## Arguments

- feed_ration_fraction:

  Numeric. Proportion of a specific feed component in the total ration,
  expressed as its fraction of diet dry matter intake (fraction). Within
  each herd_id and cohort, proportions should sum to 1.

- co2_feed_luc_nopeat:

  Numeric. Carbon dioxide (CO2) emission factor of a feed component,
  representing CO2 emissions from land-use change in feed production
  (excluding peatland drainage), expressed per kilogram of dry matter
  intake (g CO2/kg DM).

## Value

Numeric. Contribution of an individual feed component to the diet-level
average carbon dioxide (CO2) emission factor from land-use change
(excluding peatland drainage) in feed production (g CO2/kg DM).

## Details

The contribution is computed as:

\$\$diet\\co2\\feed\\luc\\nopeat = feed\\ration\\fraction \times
co2\\feed\\luc\\nopeat\$\$

This function is part of the
[`run_emissions_ration_module()`](https://github.com/un-fao/GLEAM/reference/run_emissions_ration_module.md).

## See also

[`run_emissions_ration_module`](https://github.com/un-fao/GLEAM/reference/run_emissions_ration_module.md)
