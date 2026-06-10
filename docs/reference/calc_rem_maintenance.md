# Calculate ratio of net energy available for maintenance in the diet (REM - Net Energy for Maintenance / Digestible Energy)

Calculates the ratio of net energy available in the diet for maintenance
to digestible energy.

## Usage

``` r
calc_rem_maintenance(species_short, ration_digestibility_fraction = NA_real_)
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

Numeric. Ratio of net energy available for maintenance in the diet to
digestible energy consumed (fraction).

## Details

This component follows the IPCC Tier 2 partitioning approach and it
returns the value for ruminants (`CTL`, `BFL`, `SHP`, `GTS`) calculated
as follows:

\$\$ net\\energy\\maintenance\\digestible\\energy\\ratio = 1.123 -
0.004092 \times (diet\\digestibility\\fraction \times 100) + 0.00001126
\times (diet\\digestibility\\fraction \times 100)^2 -
\frac{25.4}{diet\\digestibility\\fraction \times 100} \$\$

For the Other species REM is not applicable and the function returns
`NA_real_`.

This function is part of the
[`run_metabolic_energy_req_module()`](https://github.com/un-fao/GLEAM/reference/run_metabolic_energy_req_module.md).

## References

Gibbs M.J., Johnson D.E. (1993) *Livestock Emissions*. In: International
Methane Emissions. Washington, D.C., U.S.A: US Environmental Protection
Agency, Climate Change Division.

IPCC. (2019). *2019 Refinement to the 2006 IPCC Guidelines for National
Greenhouse Gas Inventories*, Chapter 10: Emissions from Livestock and
Manure Management, Equation 10.14.

IPCC. (2006). *2006 IPCC Guidelines for National Greenhouse Gas
Inventories*, Chapter 10: Emissions from Livestock and Manure
Management, Equation 10.14.

## See also

[`run_metabolic_energy_req_module`](https://github.com/un-fao/GLEAM/reference/run_metabolic_energy_req_module.md),
[`calc_ration_digestibility`](https://github.com/un-fao/GLEAM/reference/calc_ration_digestibility.md)
[`calc_total_metabolic_energy_req`](https://github.com/un-fao/GLEAM/reference/calc_total_metabolic_energy_req.md)
[`calc_ration_intake`](https://github.com/un-fao/GLEAM/reference/calc_ration_intake.md)
