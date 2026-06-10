# Calculate feed digestibility fraction

Calculates species-specific feed digestibility fractions by feed
component.

## Usage

``` r
calc_feed_digestibility_fraction(
  feed_digestible_energy_ruminant,
  feed_digestible_energy_pigs,
  feed_gross_energy
)
```

## Arguments

- feed_digestible_energy_ruminant:

  Numeric. Digestible energy content of a feed component for ruminants,
  representing the energy absorbed by the animal after fecal losses
  (MJ/kg DM).

- feed_digestible_energy_pigs:

  Numeric. Digestible energy content of a feed component for pigs,
  representing the energy absorbed by the animal after fecal losses
  (MJ/kg DM).

- feed_gross_energy:

  Numeric. Gross energy content of a feed component, representing the
  total chemical energy released upon complete combustion of the feed
  (MJ/kg DM).

## Value

List with elements:

- feed_digestibility_fraction_ruminant:

  Numeric. Digestibility of a feed component for ruminants, expressed as
  the ratio of digestible energy to gross energy content (fraction).

- feed_digestibility_fraction_pigs:

  Numeric. Digestibility of a feed component for pigs, expressed as the
  ratio of digestible energy to gross energy content (fraction).

## Details

Digestibility is computed as the ratio of usable energy to gross energy:
\$\$feed\\digestibility\\fraction = usable\\energy /
feed\\gross\\energy\$\$

For ruminants and pigs, usable energy is represented by
`digestible_energy` (DE), which accounts for fecal energy losses.

This function is part of the
[`run_ration_quality_module()`](https://github.com/un-fao/GLEAM/reference/run_ration_quality_module.md).

## See also

[`run_ration_quality_module`](https://github.com/un-fao/GLEAM/reference/run_ration_quality_module.md)
