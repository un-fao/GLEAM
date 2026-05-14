# Run Aggregation Module Pipeline

This function generates final herd-level results by aggregating key
cohort-level outputs, scaling variables over the assessment duration,
allocating emissions to commodities, and converting methane (CH4) and
nitrous oxide (N2O) emissions to CO2-equivalents (CO2eq) using selected
100-year Global Warming Potential (GWP-100) factors.

## Usage

``` r
run_aggregation_module(
  cohort_level_data,
  allocation_herd_long,
  simulation_duration = 365,
  global_warming_potential_set = "AR6",
  show_indicator = TRUE
)
```

## Arguments

- cohort_level_data:

  data.table. Cohort-level input table with the following data
  requirement:

  herd_id

  :   Character. Unique identifier for the herd, repeated for each
      cohort belonging to the same herd.

  species_short

  :   Character. Livestock species code. Supported values include:

      - `CTL`: cattle

      - `BFL`: buffalo

      - `SHP`: sheep

      - `GTS`: goats

      - `PGS`: pigs

      - `CML`: camels

  cohort_short

  :   Character. Sex- and age-specific cohort code. Supported values
      include:

      - `FA`: adult females

      - `FS`: sub-adult females

      - `FJ`: juvenile females

      - `MA`: adult males

      - `MS`: sub-adult males

      - `MJ`: juvenile males

  cohort_stock_size

  :   Numeric. Average population size in each of the 6 sex-age cohorts
      (# heads). (cohorts=FJ, FS, FA, MJ, MS, MA).

  **Feed variables**

  :   

      ration_intake

      :   Numeric. Average daily dry matter intake of feed (kg
          DM/head/day).

  **Nitrogen balance variables**

  :   

      nitrogen_intake

      :   Numeric. Daily nitrogen intake (kg N/head/day)

      nitrogen_retention

      :   Numeric. Daily nitrogen retention in animal body tissues and
          products (e.g., growth, pregnancy, milk...) (kg N/head/day)

      nitrogen_excretion

      :   Numeric. Daily nitrogen excretion (kg N/head/day)

  **Production variables**

  :   

      milk_production_mass_cohort

      :   Numeric. Total milk production produced over the assessment
          period (kg/cohort/assessment period).

      milk_production_protein_cohort

      :   Numeric. Total milk protein production produced over the
          assessment period (kg protein/cohort/assessment period).

      milk_production_fpcm_cohort

      :   Numeric. Total fat-protein-corrected milk (FPCM) produced over
          the assessment period (kg/cohort/assessment period).

      meat_production_live_weight_cohort

      :   Numeric . Total meat produced as live weight over the
          assessment period by cohort (kg/cohort/assessment period).

      meat_production_carcass_weight_cohort

      :   Numeric. Total meat as carcass weight (excluding organs, and
          other by-products after dressing) produced over the assessment
          period by cohort (kg/cohort/assessment period).

      meat_production_bone_free_meat_cohort

      :   Numeric. Total bone-free-meat (excluding bones, organs, and
          other by-products after dressing and bone removal) produced
          over the assessment period by cohort (kg/cohort/assessment
          period)

      meat_production_protein_cohort

      :   Numeric. Total meat protein (excluding bones, organs, and
          other by-products after dressing and bone removal) produced
          over the assessment period by cohort (kg
          protein/cohort/assessment period).

      fibre_production_cohort

      :   Numeric. Total fibre produced over the assessment period by
          cohort (kg/cohort/assessment period)

  **Emission variables**

  :   

      ch4_enteric

      :   Numeric. Average daily enteric methane (CH4) emissions (kg
          CH4/head/day).

      ch4_manure_pasture

      :   Numeric. Methane (CH4) emissions from manure deposited on
          pasture (kg CH4/head/day)

      ch4_manure_burned

      :   Numeric. Methane (CH4) emissions from manure burned for fuel
          (kg CH4/head/day)

      ch4_manure_other

      :   Numeric. Methane (CH4) emissions from manure management
          systems, excluding emissions from manure deposited on pasture
          and burned for fuel (kg CH4/head/day)

      n2o_manure_pasture_direct

      :   Numeric. Direct nitrous oxide (N2O) emissions from manure
          deposited on pasture (kg N2O/head/day)

      n2o_manure_burned_direct

      :   Numeric. Direct nitrous oxide (N2O) emissions from manure
          burned for fuel (kg N2O/head/day)

      n2o_manure_other_direct

      :   Numeric. Direct nitrous oxide (N2O) emissions from manure
          management systems, excluding emissions from manure deposited
          on pasture and burned for fuel (kg N2O/head/day)

      n2o_manure_burned_indirect

      :   Numeric. Total indirect nitrous oxide (N2O) emissions from
          manure deposited on pasture. Includes emissions from
          atmospheric deposition of volatilised nitrogen (NH3 and NOx)
          and from leaching and runoff of manure nitrogen (kg
          N2O/head/day).

      n2o_manure_pasture_indirect

      :   Numeric. Total indirect nitrous oxide (N2O) emissions
          originating from manure burned for fuel. Includes emissions
          from atmospheric deposition of volatilised nitrogen (NH3 and
          NOx) and from leaching and runoff of manure nitrogen (kg
          N2O/head/day).

      n2o_manure_other_indirect

      :   Numeric. Total indirect nitrous oxide (N2O) emissions
          originating from manure management systems, excluding manure
          deposited on pasture and burned for fuel. Includes emissions
          from atmospheric deposition of volatilised nitrogen (NH3 and
          NOx) and from leaching and runoff of manure nitrogen (kg
          N2O/head/day).

      co2_ration_fertilizer

      :   Numeric. Diet-level average carbon dioxide (CO2) emission
          factor from fertilizer manufacture in feed production (g
          CO2/kg DM).

      co2_ration_pesticides

      :   Numeric. Diet-level average carbon dioxide (CO2) emission
          factor from pesticide manufacture in feed production (g CO2/kg
          DM).

      co2_ration_crop_activities

      :   Numeric. Diet-level average carbon dioxide (CO2) emission
          factor from on-field agricultural activities in feed
          production (g CO2/kg DM).

      co2_ration_luc_nopeat

      :   Numeric. Diet-level average carbon dioxide (CO2) emission
          factor from land-use change (excluding peatland drainage) in
          feed production (g CO2/kg DM).

      co2_ration_luc_peat

      :   Numeric. Diet-level average carbon dioxide (CO2) emission
          factor from peatland drainage in feed production (g CO2/kg
          DM).

      n2o_ration_fertilizer

      :   Numeric. Diet-level average nitrous oxide (N2O) emission
          factor from fertilizer use in feed production (g N2O/kg DM).

      n2o_ration_manure_applied

      :   Numeric. Diet-level average nitrous oxide (N2O) emission
          factor from manure applied to or deposited on soil in feed
          production (g N2O/kg DM).

      n2o_ration_crop_residues

      :   Numeric. Diet-level average nitrous oxide (N2O) emission
          factor from crop residues decomposition in feed production (g
          N2O/kg DM).

      ch4_ration_rice

      :   Numeric. Diet-level average methane (CH4) emission factor from
          rice cultivation in feed production (g CH4/kg DM).

- allocation_herd_long:

  data.table. Herd-level allocation table in long format, typically
  generated by
  [`run_allocation_module()`](https://github.com/un-fao/GLEAM/reference/run_allocation_module.md),
  with the following data requirements:

  herd_id

  :   Character. Unique identifier for the herd, repeated for each
      cohort belonging to the same herd.

  species_short

  :   Character. Code identifying the livestock species. Supported
      values include PGS, CML, CTL, BFL, SHP, GTS

  variable_name

  :   Character. Names of emission variables to which allocation should
      be applied (e.g., "ch4_enteric", "ch4_manure_pasture",
      "ch4_manure_burned", "ch4_manure_other",
      "n2o_manure_pasture_direct", "n2o_manure_burned_direct",
      "n2o_manure_other_direct", "n2o_manure_burned_indirect",
      "n2o_manure_pasture_indirect", "n2o_manure_other_indirect",
      "co2_ration_fertilizer", "co2_ration_pesticides",
      "co2_ration_crop_activities", "co2_ration_luc_nopeat",
      "co2_ration_luc_peat", "n2o_ration_fertilizer",
      "n2o_ration_manure_applied", "n2o_ration_crop_residues",
      "ch4_ration_rice")

  commodity_name

  :   Character. List of commodity categories to which emissions may be
      allocated. List = c("None", "Milk", "Meat", "Fibre", "Work",
      "Eggs")

  commodity_type

  :   Character. Commodity (commodity_name) grouping, either `"Edible"`
      or `"Non-Edible"`.

  allocation_share

  :   Numeric. Allocation share assigned to the commodity for the
      corresponding emission source (fraction).

- simulation_duration:

  Numeric. Length of the assessment period (days).

- global_warming_potential_set:

  Character. Settings for the 100-year Global Warming Potential
  (GWP-100) conversion factors used to express CH4 and N2O emissions as
  CO2eq. Must be one of:

  - `"AR6"`: IPCC Sixth Assessment Report (IPCC, 2021) - CH4 = 27, N2O =
    273

  - `"AR5_excluding_carbon_feedback"`: IPCC Fifth Assessment Report
    (excluding climate-carbon feedbacks) (IPCC, 2013) - CH4 = 28, N2O =
    265

  - `"AR5_including_carbon_feedback"`: IPCC Fifth Assessment Report
    (including climate-carbon feedbacks) (IPCC, 2013) - CH4 = 34, N2O =
    298

  - `"AR4"`: IPCC Fourth Assessment Report (IPCC, 2007) - CH4 = 25, N2O
    = 298

- show_indicator:

  Logical. Whether to display progress indicators during the pipeline
  run. Defaults to `TRUE`.

## Value

A named list with the following elements:

- results_emissions:

  A `data.table` containing herd-level emissions scaled to the
  assessment duration and allocated to commodities. Includes gas type,
  allocation shares, commodity metadata, GWP factors, and emissions
  expressed both as allocated gas mass (kg gas) and as CO2-equivalents
  (kg CO2eq).

- results_feed:

  A `data.table` containing herd-level feed variables, aggregated at
  herd level and scaled to the assessment duration.

- results_production:

  A `data.table` containing herd-level production variables aggregated
  from cohort-level values over the assessment duration.

- results_nitrogen:

  A `data.table` containing herd-level nitrogen balance variables
  aggregated from cohort-level values and scaled to the assessment
  duration.

## Details

This function represents the final step of the Global Livestock
Environmental Assessment Model (GLEAM) computational pipeline
[`run_gleam()`](https://github.com/un-fao/GLEAM/reference/run_gleam.md)
and performs the following calculation sequence:

1.  Cohort-level variables are reshaped from wide to long format.

2.  Variables are classified into `"Feed"`, `"NitrogenBalance"`,
    `"Production"`, and `"Emissions"`.

3.  Cohort totals are calculated using
    [`calc_cohort_totals()`](https://github.com/un-fao/GLEAM/reference/calc_cohort_totals.md).
    Production variables are retained as provided, whereas emissions,
    feed, and nitrogen balance variables are scaled using cohort stock
    size and simulation duration.

4.  Cohort totals are aggregated to herd level within each
    `herd_id x species_short x variable_type x variable_name` group.

5.  Herd-level emissions are merged with commodity allocation shares
    from `allocation_herd_long`.

6.  Emissions are allocated to commodities using
    [`calc_allocated_emissions()`](https://github.com/un-fao/GLEAM/reference/calc_allocated_emissions.md).

7.  Gas type is identified from the emission variable name as `"CH4"`,
    `"N2O"`, or `"CO2"`.

8.  Allocated CH4, N2O, and CO2 emissions are converted to
    CO2-equivalents (CO2eq) using
    [`calc_co2eq()`](https://github.com/un-fao/GLEAM/reference/calc_co2eq.md)
    and the selected GWP-100 option.

9.  Final output tables are produced summarizing herd-level results for
    emissions, feed, production, and nitrogen balance variables.

## See also

[`run_gleam()`](https://github.com/un-fao/GLEAM/reference/run_gleam.md),
[`calc_cohort_totals()`](https://github.com/un-fao/GLEAM/reference/calc_cohort_totals.md),
[`calc_cohort_to_herd_aggregation()`](https://github.com/un-fao/GLEAM/reference/calc_cohort_to_herd_aggregation.md),
[`calc_allocated_emissions()`](https://github.com/un-fao/GLEAM/reference/calc_allocated_emissions.md),
[`calc_co2eq()`](https://github.com/un-fao/GLEAM/reference/calc_co2eq.md),
[`run_allocation_module()`](https://github.com/un-fao/GLEAM/reference/run_allocation_module.md)

## Examples

``` r
# \donttest{
# Load cohort-level aggregation input
aggregation_chrt_dt <- data.table::fread(system.file(
  "extdata/run_modules_examples/aggregation_input_chrt_data.csv",
  package = "gleam"
))

# Load allocation shares (herd-level, long format)
allocation_long <- data.table::fread(system.file(
  "extdata/run_modules_examples/aggregation_allocation_input_data.csv",
  package = "gleam"
))

# Run aggregation
results <- run_aggregation_module(
  cohort_level_data = aggregation_chrt_dt,
  allocation_herd_long = allocation_long,
  simulation_duration = 365,
  global_warming_potential_set = "AR6"
)
#> 🕒 Aggregating results, please wait…
#> ✔ Aggregation complete.
# }
```
