# Calculate diet ash contribution for a ration component

Calculates the contribution of a single feed component to diet ash
content by weighting feed ash content by its ration composition share.

## Usage

``` r
calc_ration_ash(feed_ration_fraction, feed_ash)
```

## Arguments

- feed_ration_fraction:

  Numeric. Proportion of a specific feed component in the total ration,
  expressed as its fraction of diet dry matter intake (fraction). Within
  each herd_id and cohort, proportions should sum to 1.

- feed_ash:

  Numeric. Average ash content by feed component, expressed as a
  fraction of the dry matter intake (g ash/100g DM).

## Value

Numeric. Contribution of the feed component to total diet ash content
(kg ash/kg DM).

## Details

The ash contribution is defined as: \$\$ration\\ash =
feed\\ration\\fraction \times feed\\ash / 100\$\$

Ash content is expressed as a percentage (g/100g DM); the result is a
fraction.

This function is part of the
[`run_ration_quality_module()`](https://github.com/un-fao/GLEAM/reference/run_ration_quality_module.md).

## See also

[`run_ration_quality_module`](https://github.com/un-fao/GLEAM/reference/run_ration_quality_module.md)
