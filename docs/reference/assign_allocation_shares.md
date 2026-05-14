# Assign allocation shares to emission variables by commodity

Expands commodity-level allocation shares across emission sources and
applies predefined allocation rules for excluded emission sources.

## Usage

``` r
assign_allocation_shares(
  allocation_herd_long,
  emissions_vars,
  commodities,
  non_allocated_emission_sources,
  commodity_col,
  allocation_col
)
```

## Arguments

- allocation_herd_long:

  Long-format `data.table` containing herd-level emissions and
  allocation information. Each row represents an emission
  source–commodity combination or an unallocated emission source prior
  to allocation.

- emissions_vars:

  Character. Names of emission variables to which allocation should be
  applied (e.g.,
  "ch4_enteric","ch4_manure_pasture","ch4_manure_burned","ch4_manure_other",
  "n2o_manure_pasture_direct","n2o_manure_burned_direct","n2o_manure_other_direct",
  "n2o_manure_burned_indirect","n2o_manure_pasture_indirect","n2o_manure_other_indirect",
  "co2_ration_fertilizer", "co2_ration_pesticides",
  "co2_ration_crop_activities", "co2_ration_luc_nopeat",
  "co2_ration_luc_peat", "n2o_ration_fertilizer",
  "n2o_ration_manure_applied", "n2o_ration_crop_residues",
  "ch4_ration_rice").

- commodities:

  Character. List of commodity categories to which emissions may be
  allocated. For example: c("None","Milk","Meat","Fibre","Work","Eggs").

- non_allocated_emission_sources:

  Character. Emission variables that should not be allocated across
  commodities, even if they appear in emissions_vars (e.g.,
  "ch4_manure_pasture", "ch4_manure_burned").

- commodity_col:

  Character. Name of the column in `allocation_herd_long` identifying
  the commodity category.

- allocation_col:

  Character. Name of the column in `allocation_herd_long` containing the
  allocation share to be applied.

## Value

A `data.table` equal to `allocation_herd_long` expanded over all
`emissions_vars`, with enforced allocation rules:

- Non-allocated emission sources:

  `allocation_col = 1` when `commodity_col == "None"`, else `0`.

- Allocated emission sources:

  `allocation_col = 0` when `commodity_col == "None"` (others
  unchanged).

## Details

The function assigns commodity allocation shares to emission sources
while also allowing for the implementation of specific allocation rules.
Emission sources listed in `non_allocated_emission_sources` (e.g.,
emissions from manure burned as fuel or manure deposited on pasture) are
treated as not attributable to livestock commodities under the chosen
goal and scope. Consequently, these emissions are allocated entirely to
the residual commodity category `"None"` and are not distributed across
milk, meat, fibre, work, or egg outputs.

The following methodological rules apply to emission sources listed in
`non_allocated_emission_sources`:

- **Manure burned for fuel** — Emissions are considered outside the life
  cycle assessment system boundaries under the defined goal and scope
  and are therefore not attributed to livestock commodities. A cut-off
  approach is applied, consistent with the IDF (2022) standard and LEAP
  guidelines (LEAP 2016a, 2016b, 2016c).

- **Manure deposited on pastures** — Emissions are not allocated to
  livestock commodities in order to avoid double counting. When upstream
  feed production is included in the inventory, emission factors of feed
  items already account for this source.

This function is part of the
[`run_allocation_module()`](https://github.com/un-fao/GLEAM/reference/run_allocation_module.md).

## References

IDF. (2022). *The IDF Global Carbon Footprint Standard for the Dairy
Sector*. Bulletin of the IDF No. 520/2022. International Dairy
Federation, Brussels.

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

[`run_allocation_module()`](https://github.com/un-fao/GLEAM/reference/run_allocation_module.md)
