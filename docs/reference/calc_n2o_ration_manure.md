# Calculate a ration component's contribution to nitrous oxide (N2O) emissions from manure application and deposition

Calculates the contribution of an individual feed component to nitrous
oxide (N2O) emissions from manure application to or deposition on soil
in feed production, using feed-specific emission factors weighted by the
component's share in the ration.

## Usage

``` r
calc_n2o_ration_manure(feed_ration_fraction, n2o_feed_manure_applied)
```

## Arguments

- feed_ration_fraction:

  Numeric. Proportion of a specific feed component in the total ration,
  expressed as its fraction of diet dry matter intake (fraction). Within
  each herd_id and cohort, proportions should sum to 1.

- n2o_feed_manure_applied:

  Numeric. Nitrous oxide (N2O) emission factor of a feed component,
  representing N2O emissions from manure applied to or deposited on soil
  in feed production, expressed per kg of dry matter intake (g N2O/kg
  DM).

## Value

Numeric. Contribution of an individual feed component to the diet-level
average nitrous oxide (N2O) emission factor from manure applied to or
deposited on soil in feed production (g N2O/kg DM).

## Details

The contribution is computed as:

\$\$diet\\n2o\\feed\\manure\\applied = feed\\ration\\fraction \times
n2o\\feed\\manure\\applied\$\$

This function is part of the
[`run_emissions_ration_module()`](https://github.com/un-fao/GLEAM/reference/run_emissions_ration_module.md).

## See also

[`run_emissions_ration_module`](https://github.com/un-fao/GLEAM/reference/run_emissions_ration_module.md)
