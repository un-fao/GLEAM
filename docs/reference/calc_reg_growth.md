# Calculate the ratio of net energy available for growth in the diet (REG – Net Energy for Growth / Digestible Energy)

Calculates the ratio of net energy available for growth to digestible
energy consumed (fraction), which represents the efficiency with which
digestible energy in the diet is converted into net energy retained as
body tissue.

## Usage

``` r
calc_reg_growth(species_short, ration_digestibility_fraction = NA_real_)
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

- ration_digestibility_fraction:

  Numeric. Average digestibility of the feed ration, expressed as ratio
  of digestible to gross energy content (fraction).

## Value

Numeric. Ratio of net energy available for growth in the diet to
digestible energy consumed (fraction).

## Details

This component follows the IPCC Tier 2 partitioning approach and returns
REG for ruminants (`CTL`, `BFL`, `SHP`, `GTS`) as: \$\$
net\\energy\\growth\\digestible\\energy\\ratio = 1.164 - 0.005160 \times
diet\\digestibility\\fraction \times 100 + 0.00001308 \times
(diet\\digestibility\\fraction \times 100)^2 -
\frac{37.4}{diet\\digestibility\\fraction \times 100} \$\$

For Other species REG is not applicable and the function returns
`NA_real_`.

This function is part of the
[`run_metabolic_energy_req_module()`](https://github.com/un-fao/GLEAM/reference/run_metabolic_energy_req_module.md).

## References

Gibbs M.J., Johnson D.E. (1993) *Livestock Emissions*. In: International
Methane Emissions. Washington, D.C., U.S.A: US Environmental Protection
Agency, Climate Change Division.

IPCC. (2019). *2019 Refinement to the 2006 IPCC Guidelines for National
Greenhouse Gas Inventories*, Chapter 10: Emissions from Livestock and
Manure Management, Equation 10.15.

IPCC. (2006). *2006 IPCC Guidelines for National Greenhouse Gas
Inventories*, Chapter 10: Emissions from Livestock and Manure
Management, Equation 10.15.

## See also

[`run_metabolic_energy_req_module`](https://github.com/un-fao/GLEAM/reference/run_metabolic_energy_req_module.md),
[`calc_ration_digestibility`](https://github.com/un-fao/GLEAM/reference/calc_ration_digestibility.md)
[`calc_total_metabolic_energy_req`](https://github.com/un-fao/GLEAM/reference/calc_total_metabolic_energy_req.md)
[`calc_ration_intake`](https://github.com/un-fao/GLEAM/reference/calc_ration_intake.md)
