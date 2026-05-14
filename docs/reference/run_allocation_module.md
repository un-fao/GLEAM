# Run Allocation Module Pipeline

Calculates biophysical allocation shares for livestock commodities by
computing cohort-level energy requirements for meat, milk, fibre, work,
and eggs, aggregating these terms to herd level, and assigning
allocation shares to emission sources.

## Usage

``` r
run_allocation_module(
  cohort_level_data,
  herd_level_data,
  simulation_duration = 365,
  show_indicator = TRUE
)
```

## Arguments

- cohort_level_data:

  Cohort-level input table with the following data requirement:

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

  milk_production_fpcm_cohort

  :   Numeric. Total fat-protein-corrected milk (FPCM) produced over the
      assessment period (kg/cohort/assessment period). Suggested
      standard fat, protein and lactose contents are 0.04, 0.033, and
      0.048 respectively.

  live_weight_cohort_at_slaughter

  :   Numeric. Live weight at slaughter for animals removed from the
      cohort (kg).

  meat_production_live_weight_cohort

  :   Numeric. Total meat produced as live weight over the assessment
      period by cohort (kg/cohort/assessment period).

  metabolic_energy_req_fibre_production

  :   Numeric. Energy required for the synthesis of fibre for SHP, GTS
      and CML. Assumed to be 0 for other species. (MJ/head/day).
      Expressed as net energy for SHP and GTS and as metabolizable
      energy for CML.

  cohort_stock_size

  :   Numeric. Average population size in each of the 6 sex–age cohorts
      (# heads). (cohorts=FJ, FS, FA, MJ, MS, MA).

  metabolic_energy_req_work

  :   Numeric. Energy required for work, used to estimate the energy
      required for draught power for CTL, BFL and CML. (MJ/head/day)
      Assumed to be 0 for other species. Expressed as net energy for
      CTL, BFL, SHP, GTS and as metabolizable energy for CML.

- herd_level_data:

  data.table. Herd-level input table (one row per `herd_id`) with the
  following data requirement:

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

  live_weight_at_birth

  :   Numeric. Live weight of the animal at birth (kg).

  milk_protein_fraction_standard

  :   Numeric. Standard protein content of milk, used to calculate
      Fat-protein-corrected milk (FPCM), (kg protein/kg milk). Suggested
      value = 0.033.

  milk_fat_fraction_standard

  :   Numeric. Standard fat content of milk, used to calculate
      Fat-protein-corrected milk (FPCM), (kg fat/kg milk). Suggested
      value = 0.04.

  milk_lactose_fraction_standard

  :   Numeric. Standard lactose content of milk, used to calculate
      Fat-protein-corrected milk (FPCM) , (kg lactose/kg milk).
      Suggested value = 0.048.

  ratio_me_to_ne

  :   Numeric. Ratio of metabolizable energy converted to net energy
      (fraction). Used for species_short = CML.

- simulation_duration:

  Numeric. Length of the assessment period (days).

- show_indicator:

  Logical. Whether to display progress indicators during simulation.
  Defaults to `TRUE`.

## Value

A named list of two `data.table` objects:

- cohort_allocation_inputs:

  A `data.table` with the original cohort-level input columns plus the
  following new variables:

  milk_allocation_energy

  :   Numeric. Energy required to produce total milk output by cohort
      (MJ/cohort/assessment period).

  meat_allocation_energy

  :   Numeric. Energy required by a given sex–age cohort for total meat
      output by cohort during the assessment period, equal to the energy
      needed to produce all live-weight gain to reach the target
      slaughter weight (MJ/cohort/assessment period).

  fibre_allocation_energy

  :   Numeric. Energy required to produce all fibre output by cohort
      (MJ/cohort/assessment period).

  work_allocation_energy

  :   Numeric. Energy required to provide all draught power
      (traction/work) by cohort (MJ/cohort/assessment period).

  egg_allocation_energy

  :   Numeric. Energy required for egg production over the assessment
      period (MJ/cohort/assessment period). Currently set to 0.

- allocation_long:

  A herd-level `data.table` in long format with one row per herd,
  commodity, and emission source combination, containing the following
  columns:

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

  variable_name

  :   Character. Names of emission variables to which allocation should
      be applied (e.g.,"ch4_enteric", "ch4_manure_pasture",
      "ch4_manure_burned","ch4_manure_other",
      "n2o_manure_pasture_direct",
      "n2o_manure_burned_direct","n2o_manure_other_direct",
      "n2o_manure_burned_indirect","n2o_manure_pasture_indirect",
      "n2o_manure_other_indirect", "co2_ration_fertilizer",
      "co2_ration_pesticides", "co2_ration_crop_activities",
      "co2_ration_luc_nopeat", "co2_ration_luc_peat",
      "n2o_ration_fertilizer", "n2o_ration_manure_applied",
      "n2o_ration_crop_residues", "ch4_ration_rice")

  commodity_name

  :   Character. List of commodity categories to which emissions may be
      allocated. List=c("None","Milk","Meat","Fibre","Work","Eggs")

  commodity_type

  :   Character. Commodity (commodity_name) grouping, either `"Edible"`
      or `"Non-Edible"`.

  allocation_share

  :   Numeric. Allocation share assigned to the commodity for the
      corresponding emission source (fraction).

## Details

This function implements the allocation pipeline used to derive
biophysical allocation shares for livestock commodities in
multifunctional production systems.

The approach follows the IDF standard for the dairy sector, adapted for
livestock systems in which emissions are apportioned among multiple
products according to their physiological energy requirements. In
accordance with ISO 14044:2006, known biophysical relationships may be
used to assign shared inputs and outputs of a production system to
individual products or sub-units.

This function represents the intermediate allocation module of the
Global Livestock Environmental Assessment Model (GLEAM) computational
pipeline
[`run_gleam()`](https://github.com/un-fao/GLEAM/reference/run_gleam.md)
and performs the following calculation sequence:

1.  Calculation of cohort-level energy allocation terms for meat, milk,
    fibre, work, and eggs using
    [`calc_meat_allocation_energy`](https://github.com/un-fao/GLEAM/reference/calc_meat_allocation_energy.md),
    [`calc_milk_allocation_energy`](https://github.com/un-fao/GLEAM/reference/calc_milk_allocation_energy.md),
    [`calc_fibre_allocation_energy`](https://github.com/un-fao/GLEAM/reference/calc_fibre_allocation_energy.md),
    [`calc_work_allocation_energy`](https://github.com/un-fao/GLEAM/reference/calc_work_allocation_energy.md),
    and `calc_eggs_allocation_energy`.

2.  Aggregation of cohort-level energy terms to herd level using
    [`calc_cohort_to_herd_aggregation`](https://github.com/un-fao/GLEAM/reference/calc_cohort_to_herd_aggregation.md).

3.  Calculation of herd-level allocation shares for commodities using
    [`calc_allocation_shares`](https://github.com/un-fao/GLEAM/reference/calc_allocation_shares.md).

4.  Reshaping of allocation shares to long format and assignment of
    shares to emission sources using
    [`assign_allocation_shares`](https://github.com/un-fao/GLEAM/reference/assign_allocation_shares.md).

Commodity-specific allocation shares represent the fraction of total
herd-level energy requirements attributable to each commodity. These
shares are then used to assign emissions to meat, milk, fibre, work,
eggs, or the residual category `"None"`.

Emissions from manure burned for fuel and manure deposited on pasture
are not allocated to livestock commodities. These flows are assigned
fully to `"None"` in accordance with the rules implemented in
[`assign_allocation_shares`](https://github.com/un-fao/GLEAM/reference/assign_allocation_shares.md).

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

[`run_gleam`](https://github.com/un-fao/GLEAM/reference/run_gleam.md),
[`calc_milk_production`](https://github.com/un-fao/GLEAM/reference/calc_milk_production.md),
[`calc_meat_production`](https://github.com/un-fao/GLEAM/reference/calc_meat_production.md),
[`run_production_module`](https://github.com/un-fao/GLEAM/reference/run_production_module.md),
[`calc_meat_allocation_energy`](https://github.com/un-fao/GLEAM/reference/calc_meat_allocation_energy.md),
[`calc_milk_allocation_energy`](https://github.com/un-fao/GLEAM/reference/calc_milk_allocation_energy.md),
[`calc_fibre_allocation_energy`](https://github.com/un-fao/GLEAM/reference/calc_fibre_allocation_energy.md),
[`calc_work_allocation_energy`](https://github.com/un-fao/GLEAM/reference/calc_work_allocation_energy.md),
`calc_eggs_allocation_energy`,
[`calc_cohort_to_herd_aggregation`](https://github.com/un-fao/GLEAM/reference/calc_cohort_to_herd_aggregation.md),
[`calc_allocation_shares`](https://github.com/un-fao/GLEAM/reference/calc_allocation_shares.md),
[`assign_allocation_shares`](https://github.com/un-fao/GLEAM/reference/assign_allocation_shares.md)

## Examples

``` r
# \donttest{
# Load allocation inputs (cohort and herd-level)
allocation_chrt_dt <- data.table::fread(system.file(
  "extdata/run_modules_examples/allocation_input_chrt_data.csv",
  package = "gleam"
))
allocation_hrd_dt <- data.table::fread(system.file(
  "extdata/run_modules_examples/allocation_input_hrd_data.csv",
  package = "gleam"
))
results <- run_allocation_module(
cohort_level_data = allocation_chrt_dt,
herd_level_data = allocation_hrd_dt
)
#> 🕒 Computing allocation shares, please wait…
#> ✔ Allocation calculation complete.
head(results$allocation_long)
#> Key: <commodity_name>
#>    herd_id species_short              variable_name commodity_name
#>      <int>        <char>                     <char>         <char>
#> 1:       3           SHP                ch4_enteric          Fibre
#> 2:       3           SHP           ch4_manure_other          Fibre
#> 3:       3           SHP            ch4_ration_rice          Fibre
#> 4:       3           SHP co2_ration_crop_activities          Fibre
#> 5:       3           SHP      co2_ration_fertilizer          Fibre
#> 6:       3           SHP      co2_ration_luc_nopeat          Fibre
#>    commodity_type allocation_share
#>            <char>            <num>
#> 1:     Non-Edible        0.1122442
#> 2:     Non-Edible        0.1122442
#> 3:     Non-Edible        0.1122442
#> 4:     Non-Edible        0.1122442
#> 5:     Non-Edible        0.1122442
#> 6:     Non-Edible        0.1122442
# }
```
