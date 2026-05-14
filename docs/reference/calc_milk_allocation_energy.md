# Calculate milk energy requirements (for biophysical allocation)

Calculates the energy required for milk production over the assessment
period (MJ/cohort/assessment period), based on total fat- and
protein-corrected milk (FPCM) produced by the cohort.

## Usage

``` r
calc_milk_allocation_energy(
  milk_production_fpcm_cohort,
  milk_protein_fraction_standard,
  milk_fat_fraction_standard,
  milk_lactose_fraction_standard
)
```

## Arguments

- milk_production_fpcm_cohort:

  Numeric. Total fat-protein-corrected milk (FPCM) produced over the
  assessment period (kg/cohort/assessment period). Suggested standard
  fat, protein and lactose contents are 0.04, 0.033, and 0.048
  respectively.

- milk_protein_fraction_standard:

  Numeric. Standard protein content of milk, used to calculate
  Fat-protein-corrected milk (FPCM), (kg protein/kg milk). Suggested
  value = 0.033.

- milk_fat_fraction_standard:

  Numeric. Standard fat content of milk, used to calculate
  Fat-protein-corrected milk (FPCM), (kg fat/kg milk). Suggested value =
  0.04.

- milk_lactose_fraction_standard:

  Numeric. Standard lactose content of milk, used to calculate
  Fat-protein-corrected milk (FPCM) , (kg lactose/kg milk). Suggested
  value = 0.048.

## Value

Numeric. Energy required to produce total milk output by cohort
(MJ/cohort/assessment period). Non-zero values are applicable only to
milk-producing species and cohorts (species = CTL, BFL, CML, SHP, GTS;
cohorts=FA). All other species–cohort combinations are assigned a value
of 0.

## Details

This function provides the milk-related energy term used in a
biophysical allocation framework to apportion emissions between milk and
other co-products in multifunctional livestock production systems.

The approach implements the IDF (2022) standard, adapted from Thoma and
Nemecek (2020), and is consistent with FAO LEAP livestock LCA guidelines
(FAO, 2016a, 2016b, 2016c) and with ISO 14044:2006 (Section 4.3.4.2,
Step 2).

In accordance with ISO 14044:2006, known biophysical relationships may
be used to assign shared inputs and outputs of a production system to
individual products or sub-units. In livestock systems, this includes
apportioning shared feed and energy use according to physiological
energy requirements such as lactation, growth, and maintenance. If the
resulting process remains multifunctional, these energy terms may
subsequently be used to derive allocation factors among co-products.

The `milk_allocation_energy` is calculated as follows:

\\energy\\allocation\\milk = energy\\standard \times
milk\\production\\fpcm\\cohort\\

where:

- `energy_standard` is the energy content of standard milk, calculated
  internally based on standard fat, protein, and lactose contents
  following IDF (2022) (MJ/kg milk).

- `milk_production_fpcm_cohort` is the total fat- and protein-corrected
  milk (FPCM) produced over the assessment period (kg/assessment
  period). It can be computed using
  [`calc_milk_production`](https://github.com/un-fao/GLEAM/reference/calc_milk_production.md)
  (see also
  [`run_production_module`](https://github.com/un-fao/GLEAM/reference/run_production_module.md)).

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
[`calc_milk_production`](https://github.com/un-fao/GLEAM/reference/calc_milk_production.md),
[`run_production_module`](https://github.com/un-fao/GLEAM/reference/run_production_module.md)
