# Calculate diet nitrogen contribution for a ration component

Calculates the contribution of a single feed component to diet nitrogen
content by weighting feed nitrogen content by its ration composition
share.

## Usage

``` r
calc_ration_nitrogen_content(feed_ration_fraction, feed_nitrogen_content)
```

## Arguments

- feed_ration_fraction:

  Numeric. Proportion of a specific feed component in the total ration,
  expressed as its fraction of diet dry matter intake (fraction). Within
  each herd_id and cohort, proportions should sum to 1.

- feed_nitrogen_content:

  Numeric. Nitrogen content of a feed component (kg N/kg DM).

## Value

Numeric. Contribution of the feed component to total diet nitrogen
content (kg N/kg DM).

## Details

The nitrogen contribution is defined as: \$\$diet\\nitrogen =
feed\\ration\\fraction \times feed\\nitrogen\\content\$\$
