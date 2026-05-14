# Calculate methane conversion factor (ym)

Calculates the methane conversion factor (ym, % of dietary gross energy
in feed converted to methane) for a given species and cohort based on
diet digestibility. Implements species- and cohort-specific rules
consistent with IPCC Tier 2 approach.

## Usage

``` r
calc_conversion_factor_ym(
  species_short,
  cohort_short,
  ration_digestibility_fraction
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

- cohort_short:

  Character. Sex- and age-specific cohort code describing the production
  stage of the animals. Supported values include:

  - `FA`: adult females (from age at first parturition)

  - `FS`: sub-adult females (from weaning to age at first parturition)

  - `FJ`: juvenile females (from birth to weaning)

  - `MA`: adult males (from age at first breeding)

  - `MS`: sub-adult males (from weaning to age at first breeding)

  - `MJ`: juvenile males (from birth to weaning)

- ration_digestibility_fraction:

  Numeric. Average digestibility of the feed ration, expressed as ratio
  of digestible (or metabolizable, for poultry) to gross energy content
  (fraction).

## Value

Numeric. Methane (CH4) conversion factor (ym), representing the
percentage of gross energy of the feed ration that is converted to CH4
(percentage).

## Details

ym is computed using species- and cohort-specific default relationships
with diet digestibility (Opio et al., 2013).

`ration_digestibility_fraction` can be calculated with
[`calc_ration_digestibility`](https://github.com/un-fao/GLEAM/reference/calc_ration_digestibility.md) -
see also
[`run_ration_quality_module`](https://github.com/un-fao/GLEAM/reference/run_ration_quality_module.md).

- **For `CTL` and `BFL`:** \$\$ym = 9.75 - 0.05 \times
  (ration\\digestibility\\fraction \times 100)\$\$

- **For `SHP`, `GTS` and `CML`:**

  - `FA` and `MA` cohorts: \$\$ym = 9.75 - 0.05 \times
    (ration\\digestibility\\fraction \times 100)\$\$

  - `FS` and `MS` cohorts: \$\$ym = 7.75 - 0.05 \times
    (ration\\digestibility\\fraction \times 100)\$\$

- **For `PGS`:** ym is assigned fixed values by cohort:

  - `FA` and `MA` cohorts: \$\$ym = 1.01\$\$

  - `FS` and `MS` cohorts: \$\$ym = 0.39\$\$

ym is returned as 0 for juvenile cohorts (`FJ`, `MJ`), assuming
negligible enteric methane production before weaning/rumen development.

This function is part of the
[`run_emissions_enteric_module()`](https://github.com/un-fao/GLEAM/reference/run_emissions_enteric_module.md).

## References

Opio, C., Gerber, P., Mottet, A., Falcucci, A., Tempio, G., MacLeod, M.,
Vellinga, T., Henderson, B. & Steinfeld, H. (2013). *Greenhouse gas
emissions from ruminant supply chains – A global life cycle assessment*.
Food and Agriculture Organization of the United Nations (FAO), Rome.

Jørgensen, H., Theil, P. K. & Knudsen, K. E. B. (2011). *Enteric methane
emission from pigs*. In: Planet Earth 2011 – Global Warming Challenges
and Opportunities for Policy and Practice (p. 610; Table 2). InTech.

IPCC. (2019). *2019 Refinement to the 2006 IPCC Guidelines for National
Greenhouse Gas Inventories*. Chapter 10: Emissions from Livestock and
Manure Management, Equation 10.21.

IPCC. (2006). *2006 IPCC Guidelines for National Greenhouse Gas
Inventories*. Chapter 10: Emissions from Livestock and Manure
Management, Equation 10.21.

## See also

[`run_emissions_enteric_module`](https://github.com/un-fao/GLEAM/reference/run_emissions_enteric_module.md),
[`calc_ration_digestibility`](https://github.com/un-fao/GLEAM/reference/calc_ration_digestibility.md),
[`run_ration_quality_module`](https://github.com/un-fao/GLEAM/reference/run_ration_quality_module.md)
