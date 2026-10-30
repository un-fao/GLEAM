# Calculate a ration component's contribution to carbon dioxide (CO2) emissions from pesticide manufacture

Calculates the contribution of an individual feed component to carbon
dioxide (CO2) emissions from pesticide manufacture in feed production,
using feed-specific emission factors weighted by the component's share
in the ration.

## Usage

``` r
calc_co2_ration_pesticides(feed_ration_fraction, co2_feed_pesticides)
```

## Arguments

- feed_ration_fraction:

  Numeric. Proportion of a specific feed component in the total ration,
  expressed as its fraction of diet dry matter intake (fraction). Within
  each herd_id and cohort, proportions should sum to 1.

- co2_feed_pesticides:

  Numeric. Carbon dioxide (CO2) emission factor of a feed component,
  representing CO2 emissions from pesticide manufacture in feed
  production, expressed per kilogram of dry matter intake (g CO2/kg DM).

## Value

Numeric. Contribution of an individual feed component to the diet-level
average carbon dioxide (CO2) emission factor from pesticide manufacture
in feed production (g CO2/kg DM).

## Details

The contribution is computed as:

\$\$diet\\co2\\feed\\pesticides = feed\\ration\\fraction \times
co2\\feed\\pesticides\$\$
