# Calculate fibre energy requirements (for biophysical allocation)

Calculates the energy required for fibre production over the assessment
period (MJ/cohort/assessment period), based on the daily energy
requirement for fibre production, cohort size, and assessment duration.

## Usage

``` r
calc_fibre_allocation_energy(
  species_short,
  cohort_stock_size = NA_real_,
  metabolic_energy_req_fibre_production = NA_real_,
  ratio_me_to_ne = NA_real_,
  simulation_duration = NA_real_
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

- cohort_stock_size:

  Numeric. Average population size in each of the 6 sex–age cohorts (#
  heads). (cohorts=FJ, FS, FA, MJ, MS, MA).

- metabolic_energy_req_fibre_production:

  Numeric. Energy required for the synthesis of fibre for SHP, GTS
  and CML. Assumed to be 0 for other species. (MJ/head/day). Expressed
  as net energy for SHP and GTS and as metabolizable energy for CML.

- ratio_me_to_ne:

  Numeric. Ratio of metabolizable energy converted to net energy
  (fraction). Used for species_short = CML.

- simulation_duration:

  Numeric. Length of the assessment period (days).

## Value

Numeric. Energy required to produce all fibre output by cohort
(MJ/cohort/assessment period). Non-zero values are expected only for
fibre-producing species (CML, SHP, GTS) and applicable cohorts ("FA",
"FS", "MA", "MS").

## Details

This function provides the fibre-related energy term used in a
biophysical allocation framework to apportion emissions between milk and
other co-products in multifunctional livestock production systems.

The approach implements the IDF (2022) standard, adapted from Thoma and
Nemecek (2020), and is consistent with FAO LEAP livestock LCA guidelines
(FAO, 2016a, 2016b, 2016c) and with ISO 14044:2006 (Section 4.3.4.2,
Step 2).

In accordance with ISO 14044:2006 (Section 4.3.4.2, Step 2), known
processing or biophysical relationships may be used to assign shared
inputs and outputs of a single production unit to individual products or
sub-units. In livestock systems, this includes apportioning shared feed
and energy use according to physiological energy requirements (e.g., net
energy for lactation, growth, etc.). If the resulting process remains
multifunctional, these energy terms may subsequently be used to derive
allocation factors among co-products.

Total fibre-related energy over the assessment period is computed for
fibre-producing species (`CML`, `SHP`, `GTS`) and applicable cohorts
(`"FA"`, `"FS"`, `"MA"`, `"MS"`).

The `fibre_allocation_energy` is calculated as follows:

\\energy\\allocation\\fibre =
\frac{energy\\requirement\\fibre\\production}{ratio\\me\\to\\ne} \times
simulation\\duration \times cohort\\stock\\size\\

for camels (`CML`), and:

\\energy\\allocation\\fibre = energy\\requirement\\fibre\\production
\times simulation\\duration \times cohort\\stock\\size\\

for sheep (`SHP`) and goats (`GTS`).

where `metabolic_energy_req_fibre_production` can be computed using
[`calc_metabolic_energy_req_fibre`](https://github.com/un-fao/GLEAM/reference/calc_metabolic_energy_req_fibre.md)
(see also
[`run_metabolic_energy_req_module`](https://github.com/un-fao/GLEAM/reference/run_metabolic_energy_req_module.md)).

This function is part of the
[`run_allocation_module()`](https://github.com/un-fao/GLEAM/reference/run_allocation_module.md).

## References

ISO. (2006). *Environmental management — Life cycle assessment —
Requirements and guidelines (ISO 14044:2006)*. International
Organization for Standardization, Geneva.

IDF. (2022). *The IDF Global Carbon Footprint Standard for the Dairy
Sector*. Bulletin of the IDF No. 520/2022. International Dairy
Federation, Brussels.

Thoma, G., and Nemecek, T. (2020). Allocation between milk and meat in
dairy LCA: Critical discussion of the IDF’s standard methodology. In
*Proceedings of the 12th International Conference on Life Cycle
Assessment of Food (LCAFood 2020)* (pp. 83–89), 13–16 October, Berlin,
Germany.

FAO. (2016a). *Environmental performance of large ruminant supply
chains: Guidelines for assessment*. Livestock Environmental Assessment
and Performance (LEAP) Partnership. FAO, Rome, Italy.

FAO. (2016b). *Greenhouse gas emissions and fossil energy use from small
ruminant supply chains: Guidelines for assessment*. Livestock
Environmental Assessment and Performance (LEAP) Partnership. FAO, Rome,
Italy.

FAO. (2016c). *Greenhouse gas emissions and fossil energy use from
poultry supply chains: Guidelines for assessment*. Livestock
Environmental Assessment and Performance (LEAP) Partnership. FAO, Rome,
Italy.

## See also

[`run_allocation_module`](https://github.com/un-fao/GLEAM/reference/run_allocation_module.md),
[`calc_metabolic_energy_req_fibre`](https://github.com/un-fao/GLEAM/reference/calc_metabolic_energy_req_fibre.md),
[`run_metabolic_energy_req_module`](https://github.com/un-fao/GLEAM/reference/run_metabolic_energy_req_module.md)
