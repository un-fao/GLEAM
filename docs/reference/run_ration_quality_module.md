# Run Ration Quality Module Pipeline

Calculates cohort-level diet nutritional metrics (gross and
metabolizable energy content, digestibility, nitrogen content, urinary
energy losses, and ash content) from cohort-level feed ration
composition shares and feed component nutrient parameters.

## Usage

``` r
run_ration_quality_module(rations_share, feed_params, show_indicator = TRUE)
```

## Arguments

- rations_share:

  data.table. Cohort-level feed ration composition shares with the
  following minimum data requirement:

  herd_id

  :   Character. Unique identifier for the herd, repeated for each
      cohort belonging to the same herd.

  species_short

  :   Character. Code identifying the livestock species. Supported
      values include:

      - `PGS`: pigs

      - `CML`: camels

      - `CTL`: cattle

      - `BFL`: buffalo

      - `SHP`: sheep

      - `GTS`: goats

  cohort_short

  :   Character. Sex- and age-specific cohort code describing the
      production stage of the animals. Supported values include:

      - `FA`: adult females (from age at first parturition)

      - `FS`: sub-adult females (from weaning to age at first
        parturition)

      - `FJ`: juvenile females (from birth to weaning)

      - `MA`: adult males (from age at first breeding)

      - `MS`: sub-adult males (from weaning to age at first breeding)

      - `MJ`: juvenile males (from birth to weaning)

  feed_id

  :   Character. Unique identifier for the feed component, used to join
      feed ration data with feed parameter tables.

  feed_name

  :   Character. Feed component name (optional, for readability and
      reporting). If provided, it should uniquely identify the same feed
      component as `feed_id`.

  feed_ration_fraction

  :   Numeric. Proportion of a specific feed component in the total
      ration, expressed as its fraction of diet dry matter intake
      (fraction). Within each herd_id and cohort, proportions should sum
      to 1.

- feed_params:

  data.table. Feed nutritional parameters with the following minimum
  data requirement:

  feed_id

  :   Character. Unique identifier for the feed component, used to join
      feed ration data with feed parameter tables.

  feed_gross_energy

  :   Numeric. Gross energy content of a feed component, representing
      the total chemical energy released upon complete combustion of the
      feed (MJ/kg DM).

  feed_digestible_energy_ruminant

  :   Numeric. Digestible energy content of a feed component for
      ruminants, representing the energy absorbed by the animal after
      fecal losses (MJ/kg DM).

  feed_digestible_energy_pigs

  :   Numeric. Digestible energy content of a feed component for pigs,
      representing the energy absorbed by the animal after fecal losses
      (MJ/kg DM).

  feed_metabolizable_energy_ruminant

  :   Numeric. Metabolizable energy content of a feed component for
      ruminants, representing digestible energy minus energy losses in
      urine and gaseous products of digestion (MJ/kg DM).

  feed_metabolizable_energy_pigs

  :   Numeric. Metabolizable energy content of a feed component for
      pigs, representing digestible energy minus energy losses in urine
      and gaseous products of digestion (MJ/kg DM).

  feed_nitrogen_content

  :   Numeric. Nitrogen content of a feed component (kg N/kg DM).

  feed_urinary_energy_ruminant

  :   Numeric. Fraction of feed's gross energy that is excreted in urine
      for ruminants (fraction).

  feed_urinary_energy_pigs

  :   Numeric. Fraction of feed's gross energy that is excreted in urine
      for pigs (fraction).

  feed_ash

  :   Numeric. Average ash content by feed component, calculated as a
      fraction of the dry matter intake (g ash/100g DM).

  category

  :   Character. Feed category (optional). If provided, it should be
      used consistently with `feed_id`, for a coherent result.

  feed_name

  :   Character. Feed component name (optional, for readability and
      reporting). If provided, it should uniquely identify the same feed
      component as `feed_id`.

- show_indicator:

  Logical. Whether to display progress indicators during calculations.
  Defaults to `TRUE`.

## Value

data.table. Cohort-level nutritional metrics summarized by `herd_id`,
`species_short`, and `cohort_short` with the following columns:

- ration_gross_energy:

  Numeric. Average gross energy content of the diet (MJ/kg DM).

- ration_metabolizable_energy:

  Numeric. Average metabolizable energy content of the diet (MJ/kg DM).

- ration_nitrogen:

  Numeric. Average nitrogen content of diet (kg N/kg DM).

- ration_digestibility_fraction:

  Numeric. Average digestibility of the feed ration, expressed as ratio
  of digestible to gross energy content (fraction).

- ration_urinary_energy_fraction:

  Numeric. Fraction of feed's gross energy that is excreted in urine
  (fraction).

- ration_ash:

  Numeric. Average ash content of feed, calculated as a fraction of the
  dry matter intake (kg ash/kg DM).

## Details

This function represents the intermediate module of the Global Livestock
Environmental Assessment Model (GLEAM) computational pipeline
[`run_gleam()`](https://github.com/un-fao/GLEAM/reference/run_gleam.md)
to estimate the nutritional quality of the feed ration. This function
joins `rations_share` with `feed_params` by `feed_id`, uses
`species_short` directly, and computes ration-weighted nutritional
metrics by cohort.

The following calculation sequence is applied:

1.  Species-specific digestibility ratios are computed from energy
    parameters and `feed_gross_energy` using
    [`calc_feed_digestibility_fraction`](https://github.com/un-fao/GLEAM/reference/calc_feed_digestibility_fraction.md).

2.  Contributions of each feed component are computed as ration-weighted
    values:

    - gross energy using
      [`calc_ration_gross_energy`](https://github.com/un-fao/GLEAM/reference/calc_ration_gross_energy.md)

    - nitrogen using
      [`calc_ration_nitrogen_content`](https://github.com/un-fao/GLEAM/reference/calc_ration_nitrogen_content.md)

    - digestibility using
      [`calc_ration_digestibility`](https://github.com/un-fao/GLEAM/reference/calc_ration_digestibility.md)

    - metabolizable energy using
      [`calc_ration_metabolizable_energy`](https://github.com/un-fao/GLEAM/reference/calc_ration_metabolizable_energy.md)

    - urinary energy fraction using
      [`calc_ration_urinary_energy_fraction`](https://github.com/un-fao/GLEAM/reference/calc_ration_urinary_energy_fraction.md)

    - ash using
      [`calc_ration_ash`](https://github.com/un-fao/GLEAM/reference/calc_ration_ash.md)

3.  Cohort-level nutritional metrics are obtained for the whole feed
    ration by summing contributions across feed components within each
    `herd_id`, `species_short`, and `cohort_short`.

## See also

[`run_gleam`](https://github.com/un-fao/GLEAM/reference/run_gleam.md),
[`calc_feed_digestibility_fraction`](https://github.com/un-fao/GLEAM/reference/calc_feed_digestibility_fraction.md),
[`calc_ration_gross_energy`](https://github.com/un-fao/GLEAM/reference/calc_ration_gross_energy.md),
[`calc_ration_nitrogen_content`](https://github.com/un-fao/GLEAM/reference/calc_ration_nitrogen_content.md),
[`calc_ration_digestibility`](https://github.com/un-fao/GLEAM/reference/calc_ration_digestibility.md),
[`calc_ration_metabolizable_energy`](https://github.com/un-fao/GLEAM/reference/calc_ration_metabolizable_energy.md),
[`calc_ration_urinary_energy_fraction`](https://github.com/un-fao/GLEAM/reference/calc_ration_urinary_energy_fraction.md),
[`calc_ration_ash`](https://github.com/un-fao/GLEAM/reference/calc_ration_ash.md)

## Examples

``` r
# \donttest{
# Load feed rations inputs (cohort-level shares and feed parameters)
feed_rations_chrt_dt <- data.table::fread(system.file(
  "extdata/run_modules_examples/feed_rations_share_chrt.csv",
  package = "gleam"
))
feed_params_dt <- data.table::fread(system.file(
  "extdata/run_modules_examples/feed_quality.csv",
  package = "gleam"
))

result <- run_ration_quality_module(
  rations_share = feed_rations_chrt_dt,
  feed_params = feed_params_dt
)
#> 🕒 Aggregating ration quality, please wait…
#> ✔ Ration quality aggregation complete.
# }
```
