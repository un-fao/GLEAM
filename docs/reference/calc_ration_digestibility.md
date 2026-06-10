# Calculate diet digestibility contribution for a ration component

Applies species-specific digestibility parameters to a ration
composition share to compute the contribution of a single feed component
to total diet digestibility.

## Usage

``` r
calc_ration_digestibility(
  species_short,
  feed_ration_fraction,
  feed_digestibility_fraction_ruminant = NA_real_,
  feed_digestibility_fraction_pigs = NA_real_
)
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

- feed_ration_fraction:

  Numeric. Proportion of a specific feed component in the total ration,
  expressed as its fraction of diet dry matter intake (fraction). Within
  each herd_id and cohort, proportions should sum to 1.

- feed_digestibility_fraction_ruminant:

  Numeric. Digestibility of a feed component for ruminants, expressed as
  the ratio of digestible energy to gross energy content (fraction).

- feed_digestibility_fraction_pigs:

  Numeric. Digestibility of a feed component for pigs, expressed as the
  ratio of digestible energy to gross energy content (fraction).

## Value

Numeric. Contribution of the feed component to total diet digestibility
(fraction).

## Details

The digestibility contribution uses the animal-specific digestibility
ratio:

- Ruminants (`CTL`, `BFL`, `CML`, `SHP`, `GTS`):
  `feed_ration_fraction * feed_digestibility_fraction_ruminant`

- Pigs (`PGS`):
  `feed_ration_fraction * feed_digestibility_fraction_pigs`

This function is part of the
[`run_ration_quality_module()`](https://github.com/un-fao/GLEAM/reference/run_ration_quality_module.md).

## See also

[`run_ration_quality_module`](https://github.com/un-fao/GLEAM/reference/run_ration_quality_module.md)
