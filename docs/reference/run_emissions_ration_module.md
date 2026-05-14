# Run Emissions from Feed Production Module Pipeline

Computes cohort-level average greenhouse gas (GHG) emission factors from
feed production by weighting emission factors of individual feed
components by diet composition. Returns diet-level average GHG emission
factors by gas and emission source for each cohort.

## Usage

``` r
run_emissions_ration_module(
  rations_share,
  feed_emissions,
  show_indicator = TRUE
)
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

- feed_emissions:

  data.table. Emission factors of individual feed components with the
  following data requirement:

  feed_id

  :   Character. Unique identifier for the feed component, used to join
      feed ration data with feed parameter tables.

  feed_name

  :   Character. Feed component name (optional, for readability and
      reporting). If provided, it should uniquely identify the same feed
      component as `feed_id`.

  co2_feed_fertilizer

  :   Numeric. Carbon dioxide (CO2) emission factor of a feed component,
      representing CO2 emissions from fertilizer manufacture in feed
      production, expressed per kilogram of dry matter intake (g CO2/kg
      DM).

  co2_feed_pesticides

  :   Numeric. Carbon dioxide (CO2) emission factor of a feed component,
      representing CO2 emissions from pesticide manufacture in feed
      production, expressed per kilogram of dry matter intake (g CO2/kg
      DM).

  co2_feed_crop_activities

  :   Numeric. Carbon dioxide (CO2) emission factor of a feed component,
      representing CO2 emissions from on-field agricultural activities
      in feed production, expressed per kilogram of dry matter intake
      (kg CO2/kg DM).

  co2_feed_luc_nopeat

  :   Numeric. Carbon dioxide (CO2) emission factor of a feed component,
      representing CO2 emissions from land-use change in feed production
      (excluding peatland drainage), expressed per kilogram of dry
      matter intake (g CO2/kg DM).

  co2_feed_luc_peat

  :   Numeric. Carbon dioxide (CO2) emission factor of a feed component,
      representing CO2 emissions from peatland drainage in feed
      production, expressed per kilogram of dry matter intake (g CO2/kg
      DM).

  n2o_feed_fertilizer

  :   Numeric. Nitrous oxide (N2O) emission factor of a feed component,
      representing N2O emissions from fertilizer use in feed production,
      expressed per kg of dry matter intake (g N2O/kg DM).

  n2o_feed_manure_applied

  :   Numeric. Nitrous oxide (N2O) emission factor of a feed component,
      representing N2O emissions from manure applied to or deposited on
      soil in feed production, expressed per kg of dry matter intake (g
      N2O/kg DM).

  n2o_feed_crop_residues

  :   Numeric. Nitrous oxide (N2O) emission factor of a feed component,
      representing N2O emissions from crop residues decomposition in
      feed production, expressed per kg of dry matter intake (g N2O/kg
      DM).

  ch4_feed_rice

  :   Numeric. Methane (CH4) emission factor of a feed component,
      representing CH4 emissions from rice cultivation in feed
      production, expressed per kg of dry matter intake (g CH4/kg DM).

- show_indicator:

  Logical. Whether to display progress indicators during calculations.
  Defaults to `TRUE`.

## Value

data.table. Cohort-level emission factors summarized by `herd_id`,
`species_short`, and `cohort_short` with the following columns:

- co2_ration_fertilizer:

  Numeric. Diet-level average carbon dioxide (CO2) emission factor from
  fertilizer manufacture in feed production (g CO2/kg DM).

- co2_ration_pesticides:

  Numeric. Diet-level average carbon dioxide (CO2) emission factor from
  pesticide manufacture in feed production (g CO2/kg DM).

- co2_ration_crop_activities:

  Numeric. Diet-level average carbon dioxide (CO2) emission factor from
  on-field agricultural activities in feed production (g CO2/kg DM).

- co2_ration_luc_nopeat:

  Numeric. Diet-level average carbon dioxide (CO2) emission factor from
  land-use change (excluding peatland drainage) in feed production (g
  CO2/kg DM).

- co2_ration_luc_peat:

  Numeric. Diet-level average carbon dioxide (CO2) emission factor from
  peatland drainage in feed production (g CO2/kg DM).

- n2o_ration_fertilizer:

  Numeric. Diet-level average nitrous oxide (N2O) emission factor from
  fertilizer use in feed production (g N2O/kg DM).

- n2o_ration_manure_applied:

  Numeric. Diet-level average nitrous oxide (N2O) emission factor from
  manure applied to or deposited on soil in feed production (g N2O/kg
  DM).

- n2o_ration_crop_residues:

  Numeric. Diet-level average nitrous oxide (N2O) emission factor from
  crop residues decomposition in feed production (g N2O/kg DM).

- ch4_ration_rice:

  Numeric. Diet-level average methane (CH4) emission factor from rice
  cultivation in feed production (g CH4/kg DM).

## Details

This function represents the intermediate module of the Global Livestock
Environmental Assessment Model (GLEAM) computational pipeline
[`run_gleam()`](https://github.com/un-fao/GLEAM/reference/run_gleam.md)
to estimate emissions from feed production used in the animal's ration.
The function joins `rations_share` with `feed_emissions` by `feed_id`,
uses `species_short` directly, and computes ration-weighted emission
factors by cohort.

The following calculation sequence is applied:

1.  **Merge ration shares with emission factors** at the feed-component
    level using [`merge`](https://rdrr.io/r/base/merge.html) on
    `feed_id` (left join: `all.x = TRUE`).

2.  **Compute feed-component contributions** (row-wise) for each
    emission source by multiplying the ration share of each feed
    component (`feed_ration_fraction`) by the corresponding feed
    emission factor. Each contribution is computed using the specific
    helper below (called with `by = .I`):

    - CO2 fertilizer:
      [`calc_co2_ration_fertilizer`](https://github.com/un-fao/GLEAM/reference/calc_co2_ration_fertilizer.md)

    - CO2 pesticides:
      [`calc_co2_ration_pesticides`](https://github.com/un-fao/GLEAM/reference/calc_co2_ration_pesticides.md)

    - CO2 crop operations:
      [`calc_co2_ration_crop_activities`](https://github.com/un-fao/GLEAM/reference/calc_co2_ration_crop_activities.md)

    - CO2 land-use change (no peat):
      [`calc_co2_ration_luc_nopeat`](https://github.com/un-fao/GLEAM/reference/calc_co2_ration_luc_nopeat.md)

    - CO2 land-use change (peat):
      [`calc_co2_ration_luc_peat`](https://github.com/un-fao/GLEAM/reference/calc_co2_ration_luc_peat.md)

    - N2O fertilizer:
      [`calc_n2o_ration_fertilizer`](https://github.com/un-fao/GLEAM/reference/calc_n2o_ration_fertilizer.md)

    - N2O manure applied:
      [`calc_n2o_ration_manure`](https://github.com/un-fao/GLEAM/reference/calc_n2o_ration_manure.md)

    - N2O crop residues:
      [`calc_n2o_ration_crop_residues`](https://github.com/un-fao/GLEAM/reference/calc_n2o_ration_crop_residues.md)

    - CH4 rice cultivation:
      [`calc_ch4_ration_rice`](https://github.com/un-fao/GLEAM/reference/calc_ch4_ration_rice.md)

3.  **Aggregate to cohort-level diet emission factors** by summing
    feed-component contributions across all feeds within each group
    `(herd_id, species_short, cohort_short)`.

For each emission source, cohort-level dietary emission factors are
computed as:

\$\$ \mathrm{diet\\ef} = \sum\_{i=1}^{n} \left(
\mathrm{feed\\ration\\fraction}\_{i} \times \mathrm{feed\\ef}\_{i}
\right) \$\$

## See also

[`run_gleam`](https://github.com/un-fao/GLEAM/reference/run_gleam.md),
[`calc_co2_ration_fertilizer`](https://github.com/un-fao/GLEAM/reference/calc_co2_ration_fertilizer.md),
[`calc_co2_ration_pesticides`](https://github.com/un-fao/GLEAM/reference/calc_co2_ration_pesticides.md),
[`calc_co2_ration_crop_activities`](https://github.com/un-fao/GLEAM/reference/calc_co2_ration_crop_activities.md),
[`calc_co2_ration_luc_nopeat`](https://github.com/un-fao/GLEAM/reference/calc_co2_ration_luc_nopeat.md),
[`calc_co2_ration_luc_peat`](https://github.com/un-fao/GLEAM/reference/calc_co2_ration_luc_peat.md),
[`calc_n2o_ration_fertilizer`](https://github.com/un-fao/GLEAM/reference/calc_n2o_ration_fertilizer.md),
[`calc_n2o_ration_manure`](https://github.com/un-fao/GLEAM/reference/calc_n2o_ration_manure.md),
[`calc_n2o_ration_crop_residues`](https://github.com/un-fao/GLEAM/reference/calc_n2o_ration_crop_residues.md),
[`calc_ch4_ration_rice`](https://github.com/un-fao/GLEAM/reference/calc_ch4_ration_rice.md)

## Examples

``` r
# \donttest{
# Load cleaned example input from the package and compute the calculation of feed emission factors

# Load table with ration shares
rations_share <- data.table::fread(system.file(
  "extdata/run_modules_examples/feed_rations_share_chrt.csv",
  package = "gleam"
))

# Load table with feed emission factors
feed_emissions <- data.table::fread(system.file(
  "extdata/run_modules_examples/feed_emission_factors.csv",
  package = "gleam"
))

# Run the code
result <- run_emissions_ration_module(
  rations_share = rations_share,
  feed_emissions = feed_emissions
)
#> 🕒 Aggregating feed emissions, please wait…
#> ✔ Feed emissions aggregation complete.
# }
```
