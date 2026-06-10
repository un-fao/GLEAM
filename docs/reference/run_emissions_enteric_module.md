# Run Enteric Methane (CH4) Emissions Module Pipeline

Calculates daily enteric methane emissions by cohort (kg CH4/head/day)
using a Tier 2 IPCC approach, by applying species-, cohort- and
diet-specific methane conversion factors (ym).

## Usage

``` r
run_emissions_enteric_module(cohort_level_data, show_indicator = TRUE)
```

## Arguments

- cohort_level_data:

  data.table. Cohort-level input table with the following data
  requirement:

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

  ration_digestibility_fraction

  :   Numeric. Average digestibility of the feed ration, expressed as
      ratio of digestible (or metabolizable, for poultry) to gross
      energy content (fraction).

  ration_gross_energy

  :   Numeric. Average gross energy content of the diet (MJ/kg DM).

  ration_intake

  :   Numeric. Average daily dry matter intake of feed (kg DM/head/day).

  ch4_mitigation_factor

  :   Numeric. Optional. Multiplicative mitigation factor applied to
      baseline enteric methane (CH4) emissions (dimensionless). If not
      provided, a default value of `1` (no mitigation) is used. Values
      lower than 1 represent proportional reductions (e.g., `0.90` = 10%
      reduction). This factor can represent mitigation measures with a
      direct effect on enteric methane emissions, such as the use of
      feed additives or methane inhibitors.

- show_indicator:

  Logical. Whether to display progress indicators during calculations.
  Defaults to `TRUE`.

## Value

A `data.table` with the original input columns plus the following new
variables:

- ch4_mitigation_factor:

  Added by the function if not provided as input.

- ch4_conversion_factor_ym:

  Numeric. Methane (CH4) conversion factor (ym), representing the
  percentage of gross energy of the feed ration that is converted to CH4
  (percentage).

- ch4_enteric:

  Numeric. Average daily enteric methane (CH4) emissions (kg
  CH4/head/day).

## Details

This function represents the intermediate module of the Global Livestock
Environmental Assessment Model (GLEAM) computational pipeline
[`run_gleam()`](https://github.com/un-fao/GLEAM/reference/run_gleam.md)
to estimate enteric methane emissions and performs the following
calculation sequence:

1.  If `ch4_mitigation_factor` is not provided in the input data, it is
    set to `1` (no mitigation).

2.  The methane conversion factor (ym) is computed using
    [`calc_conversion_factor_ym`](https://github.com/un-fao/GLEAM/reference/calc_conversion_factor_ym.md).

3.  Daily enteric methane emissions are computed using
    [`calc_ch4_enteric`](https://github.com/un-fao/GLEAM/reference/calc_ch4_enteric.md).

## References

IPCC. (2019). *2019 Refinement to the 2006 IPCC Guidelines for National
Greenhouse Gas Inventories*. Chapter 10: Emissions from Livestock and
Manure Management, Equation 10.21.

IPCC. (2006). *2006 IPCC Guidelines for National Greenhouse Gas
Inventories*. Chapter 10: Emissions from Livestock and Manure
Management, Equation 10.21.

## See also

[`run_gleam`](https://github.com/un-fao/GLEAM/reference/run_gleam.md),
[`calc_conversion_factor_ym`](https://github.com/un-fao/GLEAM/reference/calc_conversion_factor_ym.md),
[`calc_ch4_enteric`](https://github.com/un-fao/GLEAM/reference/calc_ch4_enteric.md)

## Examples

``` r
# \donttest{
# Load example input (6 herd_ids, cohort-level; only required columns)
input_path <- system.file(
  "extdata/run_modules_examples/emissions_enteric_input_chrt_data.csv",
  package = "gleam"
)
emissions_enteric_input_chrt_data <- data.table::fread(input_path)
results <- run_emissions_enteric_module(
cohort_level_data = emissions_enteric_input_chrt_data
)
#> 🕒 Calculating enteric methane emissions, please wait…
#> ✔ Enteric methane emissions calculation complete.
# }
```
