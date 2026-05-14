# Calculate diet gross energy contribution for a ration component

Computes the contribution of a single feed component to diet gross
energy content by weighting feed gross energy by its ration composition
share.

## Usage

``` r
calc_ration_gross_energy(feed_ration_fraction, feed_gross_energy)
```

## Arguments

- feed_ration_fraction:

  Numeric. Proportion of a specific feed component in the total ration,
  expressed as its fraction of diet dry matter intake (fraction). Within
  each herd_id and cohort, proportions should sum to 1.

- feed_gross_energy:

  Numeric. Gross energy content of a feed component, representing the
  total chemical energy released upon complete combustion of the feed
  (MJ/kg DM).

## Value

Numeric. Contribution of the feed component to total diet gross energy
content (MJ/kg DM).

## Details

The gross energy contribution is defined as: \$\$diet\\gross\\energy =
feed\\ration\\fraction \times feed\\gross\\energy\$\$

This function is part of the
[`run_ration_quality_module()`](https://github.com/un-fao/GLEAM/reference/run_ration_quality_module.md).

## See also

[`run_ration_quality_module`](https://github.com/un-fao/GLEAM/reference/run_ration_quality_module.md)
