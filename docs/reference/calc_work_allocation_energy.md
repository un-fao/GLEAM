# Calculate work energy requirements (for biophysical allocation)

Calculates the energy required for animal work over the assessment
period (MJ/cohort/assessment period), based on the daily energy
requirement for work, cohort size, and assessment duration.

## Usage

``` r
calc_work_allocation_energy(
  species_short,
  cohort_stock_size,
  metabolic_energy_req_work,
  simulation_duration,
  ratio_me_to_ne = NA_real_
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

  Numeric. Population size in the cohort at the start of the assessment
  period (heads).

- metabolic_energy_req_work:

  Numeric. Energy required for work, used to estimate the energy
  required for draught power for CTL, BFL and CML. (MJ/head/day) Assumed
  to be 0 for other species. Expressed as net energy for CTL, BFL, SHP,
  GTS and as metabolizable energy for CML and PGS.

- simulation_duration:

  Numeric. Length of the assessment period (days).

- ratio_me_to_ne:

  Numeric. Ratio of metabolizable energy converted to net energy
  (fraction).

## Value

Numeric. Energy required to provide all draught power (traction/work) by
cohort (MJ/cohort/assessment period). Non-zero values are expected only
for draught or work-producing species (CTL, BFL CML).

## Details

This function provides the work-related energy term used in a
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

Total work-related energy is computed for species (`CTL`, `BFL`, `CML`)
and cohorts (, `FA`, `MA`) assumed to be potentially involved in draught
power generation.

The `work_allocation_energy` is calculated as follows:

\\energy\\allocation\\work = energy\\requirement\\work \times
simulation\\duration \times cohort\\stock\\size\\

for cattle (`CTL`) and buffalo (`BFL`), and:

\\energy\\allocation\\work = \frac{energy\\requirement\\work \times
simulation\\duration \times cohort\\stock\\size} {ratio\\me\\to\\ne}\\

for camels (`CML`).

where `metabolic_energy_req_work` can be computed using
[`calc_metabolic_energy_req_work`](https://github.com/un-fao/GLEAM/reference/calc_metabolic_energy_req_work.md)
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
[`calc_metabolic_energy_req_work`](https://github.com/un-fao/GLEAM/reference/calc_metabolic_energy_req_work.md),
[`run_metabolic_energy_req_module`](https://github.com/un-fao/GLEAM/reference/run_metabolic_energy_req_module.md)
