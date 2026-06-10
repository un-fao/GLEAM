# Calculate urinary energy fraction contribution for a ration component

Applies species-specific urinary energy fractions to a ration
composition share to compute the contribution of a feed component to
urinary energy losses.

## Usage

``` r
calc_ration_urinary_energy_fraction(
  species_short,
  feed_ration_fraction,
  feed_urinary_energy_ruminant = NA_real_,
  feed_urinary_energy_pigs = NA_real_
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

- feed_urinary_energy_ruminant:

  Numeric. Fraction of feed's gross energy that is excreted in urine for
  ruminants (fraction).

- feed_urinary_energy_pigs:

  Numeric. Fraction of feed's gross energy that is excreted in urine for
  pigs (fraction).

## Value

Numeric. Contribution of the feed component to the fraction of total
diet gross energy that is excreted in urine (fraction).

## Details

The urinary energy fraction contribution uses the animal-specific
parameter:

- Ruminants (`CTL`, `BFL`, `CML`, `SHP`, `GTS`):
  `feed_ration_fraction * feed_urinary_energy_ruminant`

- Pigs (`PGS`): `feed_ration_fraction * feed_urinary_energy_pigs`

This function is part of the
[`run_ration_quality_module()`](https://github.com/un-fao/GLEAM/reference/run_ration_quality_module.md).

## See also

[`run_ration_quality_module`](https://github.com/un-fao/GLEAM/reference/run_ration_quality_module.md)
