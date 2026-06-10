# Calculate meat energy requirements (for biophysical allocation)

Calculates the energy required for meat production over the assessment
period (MJ/cohort/assessment period), based on total live weight gained
by the cohort from birth to slaughter.

## Usage

``` r
calc_meat_allocation_energy(
  species_short,
  cohort_short,
  meat_production_live_weight_cohort,
  live_weight_cohort_at_slaughter = NA_real_,
  live_weight_at_birth = NA_real_,
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

- cohort_short:

  Character. Sex- and age-specific cohort code describing the production
  stage of the animals. Supported values include:

  - `FA`: adult females (from age at first parturition)

  - `FS`: sub-adult females (from weaning to age at first parturition)

  - `FJ`: juvenile females (from birth to weaning)

  - `MA`: adult males (from age at first breeding)

  - `MS`: sub-adult males (from weaning to age at first breeding)

  - `MJ`: juvenile males (from birth to weaning)

- meat_production_live_weight_cohort:

  Numeric. Total meat produced as live weight over the assessment period
  by cohort (kg/cohort/assessment period).

- live_weight_cohort_at_slaughter:

  Numeric. Live weight at slaughter for animals removed from the cohort
  (kg).

- live_weight_at_birth:

  Numeric. Live weight of the animal at birth (kg).

- ratio_me_to_ne:

  Numeric. Ratio of metabolizable energy converted to net energy
  (fraction). Used for species_short = CML.

## Value

Numeric. Energy required by a given sex–age cohort for total meat output
by cohort during the assessment period, equal to the energy needed to
produce all live-weight gain to reach the target slaughter weight
(MJ/cohort/assessment period). For pigs (`PGS`), the function returns
`0` by design.

## Details

This function provides the meat-related energy term used in a
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
energy requirements such as growth, lactation, and maintenance. If the
resulting process remains multifunctional, these energy terms may
subsequently be used to derive allocation factors among co-products.

The `meat_allocation_energy` is calculated as follows:

\\energy\\allocation\\meat = specific\\energy\\meat \times
meat\\production\\live\\weight\\cohort\\

where

- `specific_energy_meat` is the average energy required to produce one
  kilogram of live weight, accounting for species- and cohort-specific
  growth characteristics (MJ/kg live weight).

- `meat_production_live_weight_cohort` is the total live weight of
  animals sold for meat over the assessment period. It can be computed
  using
  [`calc_meat_production`](https://github.com/un-fao/GLEAM/reference/calc_meat_production.md)
  (see also
  [`run_production_module`](https://github.com/un-fao/GLEAM/reference/run_production_module.md)).

**Specific approaches by species:**

- **For `CTL`, `BFL`, `CML`, `SHP`, `GTS`**:

  Growth energy is calculated using species- and cohort-specific
  biophysical relationships adapted from established growth energy
  formulations (further details in
  [`calc_metabolic_energy_req_growth`](https://github.com/un-fao/GLEAM/reference/calc_metabolic_energy_req_growth.md)).

- **For `PGS`**:

  Growth energy is not calculated in this function and `0` is returned.
  In downstream processing,
  [`calc_allocation_shares`](https://github.com/un-fao/GLEAM/reference/calc_allocation_shares.md)
  assigns 100% of the allocation to the edible meat commodity for pig
  systems.

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
[`calc_meat_production`](https://github.com/un-fao/GLEAM/reference/calc_meat_production.md),
[`run_production_module`](https://github.com/un-fao/GLEAM/reference/run_production_module.md),
[`calc_allocation_shares`](https://github.com/un-fao/GLEAM/reference/calc_allocation_shares.md)
