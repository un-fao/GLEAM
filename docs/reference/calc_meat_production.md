# Calculate meat production

Calculates cohort-level meat production outputs over the assessment
period based on the number of animals removed from the herd (offtake).
The function returns multiple production metrics expressed in live
weight, carcass weight, bone-free meat, and meat protein
(kg/cohort/assessment period).

## Usage

``` r
calc_meat_production(
  offtake_heads_assessment,
  live_weight_cohort_at_slaughter,
  carcass_dressing_fraction,
  bone_free_meat_fraction,
  meat_protein_fraction
)
```

## Arguments

- offtake_heads_assessment:

  Numeric. Total number of animals removed via offtake over the
  assessment period, aggregated to 6 sex–age cohorts (heads/assessment
  period) (cohorts = FJ, FS, FA, MJ, MS, MA).

- live_weight_cohort_at_slaughter:

  Numeric. Live weight at slaughter for animals removed from the cohort
  (kg).

- carcass_dressing_fraction:

  Numeric. Ratio of a slaughtered animal's carcass weight to its live
  weight (fraction).

- bone_free_meat_fraction:

  Numeric. Ratio of bone-free-meat to carcass weight (fraction).

- meat_protein_fraction:

  Numeric. Protein content of bone-free-meat (kg protein/kg
  bone-free-meat).

## Value

A named list with:

- meat_production_live_weight_cohort:

  Numeric . Total meat produced as live weight over the assessment
  period by cohort (kg/cohort/assessment period).

- meat_production_carcass_weight_cohort:

  Numeric. Total meat as carcass weight (excluding organs, and other
  by-products after dressing) produced over the assessment period by
  cohort (kg/cohort/assessment period).

- meat_production_bone_free_meat_cohort:

  Numeric. Total bone-free-meat (excluding bones, organs, and other
  by-products after dressing and bone removal) produced over the
  assessment period by cohort (kg/cohort/assessment period).

- meat_production_protein_cohort:

  Numeric. Total meat protein (excluding bones, organs, and other
  by-products after dressing and bone removal) produced over the
  assessment period by cohort (kg protein/cohort/assessment period).

## Details

Meat production outputs are computed as follows:

- **`meat_production_live_weight_cohort`** is computed as:

  \\meat\\production\\live\\weight\\cohort = offtake\\heads\\assessment
  \times live\\weight\\cohort\\at\\slaughter\\

- **`meat_production_carcass_weight_cohort`** is computed as:

  \\meat\\production\\carcass\\weight\\cohort =
  meat\\production\\live\\weight\\cohort \times
  carcass\\dressing\\fraction\\

- **`meat_production_bone_free_meat_cohort`** is computed as:

  \\meat\\production\\bone\\free\\meat\\cohort =
  meat\\production\\carcass\\weight\\cohort \times
  bone\\free\\meat\\fraction\\

- **`meat_production_protein_cohort`** is computed as:

  \\meat\\production\\protein\\cohort =
  meat\\production\\bone\\free\\meat\\cohort \times
  meat\\protein\\fraction\\

This function is part of the
[`run_production_module()`](https://github.com/un-fao/GLEAM/reference/run_production_module.md).

## See also

[`run_production_module`](https://github.com/un-fao/GLEAM/reference/run_production_module.md),
[`run_demographic_herd_module`](https://github.com/un-fao/GLEAM/reference/run_demographic_herd_module.md),
[`run_weights_module`](https://github.com/un-fao/GLEAM/reference/run_weights_module.md)
