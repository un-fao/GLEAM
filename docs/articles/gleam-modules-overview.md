# About gleam modules

## Introduction

This vignette provides a high-level overview of all GLEAM modules, the
sequence of their functions, and their input and output datasets. An
overview of the full pipeline is provided in the [GLEAM
Overview](https://github.com/un-fao/GLEAM/articles/gleam-overview.md).
Full documentation for each module is available via the module reference
pages linked in each section below.

## Herd Simulation Module

*See
[`run_demographic_herd_module()`](https://github.com/un-fao/GLEAM/reference/run_demographic_herd_module.md)
for full documentation.*

This module takes herd- and cohort-level demographic inputs and
estimates a steady-state sex–age herd structure compatible with
downstream calculations in GLEAM. In addition to cohort population
sizes, it derives population growth rates and offtake numbers. The
steady state is defined as a constant sex–age cohort structure over
time, with population size potentially growing or declining at a
constant rate.

The module operates under a **steady-state assumption**: demographic
parameters are constant over time, so the population converges to a
stable cohort composition and a constant annual growth rate. Once this
regime is reached, the model computes cohort population sizes
(start/end/average), cohort shares, and offtake totals.

A key feature of this implementation is that it applies demography at a
**daily** resolution. Annual mortality and offtake inputs are converted
into daily hazards and daily transition probabilities under competing
risks (death vs. offtake vs. survival). Conceptually, this corresponds
to the steady-state demographic approach implemented in Dynmod *STEADY1*
(Lesnoff, 2013), adapted here to a daily time-step formulation.

The population is divided by sex (female/male) and age class
(juvenile/subadult/adult), represented by six cohorts: `FJ`, `FS`, `FA`
(female juvenile, subadult, adult) and `MJ`, `MS`, `MA` (male juvenile,
subadult, adult).

**Overview of the GLEAM demographic herd module with functions, input
and output:**

![Overview of the GLEAM demographic herd
module](images/gleamx_package_module_herd.png)

## Weights Module

*See
[`run_weights_module()`](https://github.com/un-fao/GLEAM/reference/run_weights_module.md)
for full documentation.*

Computes cohort-level live weight metrics by combining cohort-level
inputs with herd-level biological parameters. The module appends cohort
weights (initial, potential final, slaughter), then derives average and
final live weights accounting for offtake, and finally computes average
daily live weight gain over each cohort stage.

**Overview of the GLEAM weights module with functions, input and
output:**

![Overview of the GLEAM weights
module](images/gleamx_package_module_weights.png)

The calculation pipeline consists of the following steps:

1.  **Cohort-stage weight assignment** — herd-level biological
    parameters are matched to each cohort row by `herd_id` and weights
    are assigned per life stage using
    [`calc_cohort_weights()`](https://github.com/un-fao/GLEAM/reference/calc_cohort_weights.md).
2.  **Average and final live weights (accounting for offtake)** —
    computed using
    [`calc_avg_weights()`](https://github.com/un-fao/GLEAM/reference/calc_avg_weights.md).
3.  **Average daily live weight gain** — computed using
    [`calc_daily_weight_gain()`](https://github.com/un-fao/GLEAM/reference/calc_daily_weight_gain.md).

## Ration Nutritional Content Module

*See
[`run_ration_quality_module()`](https://github.com/un-fao/GLEAM/reference/run_ration_quality_module.md)
for full documentation.*

Computes cohort-level diet nutritional metrics — gross and metabolizable
energy content, digestibility, nitrogen content, urinary energy losses,
and ash content — from cohort-level feed ration composition shares and
feed component nutrient parameters.

**Overview of the GLEAM herd module with functions, input and output:**

![Overview of the GLEAM feed rations
module](images/gleamx_package_module_feedrations.png)

The module joins ration shares with feed parameters by `feed_id`, uses
`species_short` for species-specific lookups, and computes
ration-weighted nutritional metrics by cohort through the following
steps:

1.  Species-specific digestibility fractions are computed from energy
    parameters using
    [`calc_feed_digestibility_fraction()`](https://github.com/un-fao/GLEAM/reference/calc_feed_digestibility_fraction.md).
2.  Contributions of each feed component are computed as ration-weighted
    values for:
    - gross energy —
      [`calc_ration_gross_energy()`](https://github.com/un-fao/GLEAM/reference/calc_ration_gross_energy.md)
    - nitrogen —
      [`calc_ration_nitrogen_content()`](https://github.com/un-fao/GLEAM/reference/calc_ration_nitrogen_content.md)
    - digestibility —
      [`calc_ration_digestibility()`](https://github.com/un-fao/GLEAM/reference/calc_ration_digestibility.md)
    - metabolizable energy —
      [`calc_ration_metabolizable_energy()`](https://github.com/un-fao/GLEAM/reference/calc_ration_metabolizable_energy.md)
    - urinary energy fraction —
      [`calc_ration_urinary_energy_fraction()`](https://github.com/un-fao/GLEAM/reference/calc_ration_urinary_energy_fraction.md)
    - ash —
      [`calc_ration_ash()`](https://github.com/un-fao/GLEAM/reference/calc_ration_ash.md)
3.  Component contributions are summed to produce cohort-level diet
    metrics, including
    [`calc_ration_intake()`](https://github.com/un-fao/GLEAM/reference/calc_ration_intake.md).

## Metabolic Energy Requirements and Ration Intake Module

*See
[`run_metabolic_energy_req_module()`](https://github.com/un-fao/GLEAM/reference/run_metabolic_energy_req_module.md)
for full documentation.*

Computes cohort-level daily energy requirements (MJ/head/day) and feed
dry matter intake (kg DM/head/day) by applying the IPCC Tier 2 energy
partitioning functions.

Energy requirements are expressed as **net energy (NE)** for CTL, BFL,
SHP, and GTS, and as **metabolizable energy (ME)** for CML, PGS, and
CHK. The module computes the following energy partitions:

- Maintenance —
  [`calc_metabolic_energy_req_maintenance()`](https://github.com/un-fao/GLEAM/reference/calc_metabolic_energy_req_maintenance.md)
- Activity —
  [`calc_metabolic_energy_req_activity()`](https://github.com/un-fao/GLEAM/reference/calc_metabolic_energy_req_activity.md)
- Growth —
  [`calc_metabolic_energy_req_growth()`](https://github.com/un-fao/GLEAM/reference/calc_metabolic_energy_req_growth.md)
- Lactation —
  [`calc_metabolic_energy_req_lactation()`](https://github.com/un-fao/GLEAM/reference/calc_metabolic_energy_req_lactation.md)
- Pregnancy —
  [`calc_metabolic_energy_req_pregnancy()`](https://github.com/un-fao/GLEAM/reference/calc_metabolic_energy_req_pregnancy.md)
- Work (draught power; CTL, BFL, CML only) —
  [`calc_metabolic_energy_req_work()`](https://github.com/un-fao/GLEAM/reference/calc_metabolic_energy_req_work.md)
- Fibre production (SHP, GTS, CML only) —
  [`calc_metabolic_energy_req_fibre()`](https://github.com/un-fao/GLEAM/reference/calc_metabolic_energy_req_fibre.md)

Total energy requirements are then aggregated using
[`calc_total_metabolic_energy_req()`](https://github.com/un-fao/GLEAM/reference/calc_total_metabolic_energy_req.md),
and dry matter intake is derived using
[`calc_ration_intake()`](https://github.com/un-fao/GLEAM/reference/calc_ration_intake.md)
by dividing the total energy requirement by the diet energy density.

**Overview of the GLEAM metabolic energy requirements module with
functions, input and output:**

![Overview of the GLEAM metabolic energy requirements
module](images/gleamx_package_module_energyrequirements.png)

## Enteric Emissions Module

*See
[`run_emissions_enteric_module()`](https://github.com/un-fao/GLEAM/reference/run_emissions_enteric_module.md)
for full documentation.*

Computes daily enteric methane emissions by cohort (kg CH₄/head/day)
using the IPCC Tier 2 approach, by applying species-, cohort-, and
diet-specific methane conversion factors (ym).

**Overview of the GLEAM enteric emissions module with functions, input
and output:**

![Overview of the GLEAM enteric emissions
module](images/gleamx_package_module_enteric.png)

The calculation pipeline consists of the following steps:

1.  If `ch4_mitigation_factor` is not provided in the input data, it is
    set to `1` (no mitigation).
2.  The methane conversion factor (ym) is computed using
    [`calc_conversion_factor_ym()`](https://github.com/un-fao/GLEAM/reference/calc_conversion_factor_ym.md).
3.  Daily enteric methane emissions are computed using
    [`calc_ch4_enteric()`](https://github.com/un-fao/GLEAM/reference/calc_ch4_enteric.md).

## Nitrogen Balance Module

*See
[`run_nitrogen_balance_module()`](https://github.com/un-fao/GLEAM/reference/run_nitrogen_balance_module.md)
for full documentation.*

Computes cohort-level daily nitrogen intake, retention, and excretion
(kg N/head/day) following the IPCC Tier 2 approach.

**Overview of the GLEAM nitrogen balance module with functions, input
and output:**

![Overview of the GLEAM nitrogen balance
module](images/gleamx_package_module_nitrogen.png)

The following calculation sequence is applied:

1.  Daily nitrogen intake is computed from `ration_intake` and
    `ration_nitrogen` using
    [`calc_nitrogen_intake()`](https://github.com/un-fao/GLEAM/reference/calc_nitrogen_intake.md).
2.  Daily nitrogen retention (in body tissues and products such as
    growth, pregnancy, and milk) is computed using
    [`calc_nitrogen_retention()`](https://github.com/un-fao/GLEAM/reference/calc_nitrogen_retention.md).
3.  Daily nitrogen excretion is computed as intake minus retention using
    [`calc_nitrogen_excretion()`](https://github.com/un-fao/GLEAM/reference/calc_nitrogen_excretion.md).

## Manure Emissions Module

*See
[`run_emissions_manure_module()`](https://github.com/un-fao/GLEAM/reference/run_emissions_manure_module.md)
for full documentation.*

Computes cohort-level greenhouse gas emissions from manure management
systems (MMS) following the IPCC Tier 2 methodology, using volatile
solids (VS), MMS allocation fractions, and MMS-specific emission
factors.

For each `herd_id`, the set of MMS identifiers must be consistent
between the `manure_management_system_fraction` and
`manure_management_system_factors` tables. The following calculation
sequence is applied:

1.  **Volatile solids (VS)** excretion is computed from feed ration
    nutritional parameters (digestibility, urinary energy, ash) using
    **Overview of the GLEAM manure emissions module with functions,
    input and output:**

![Overview of the GLEAM manure emissions
module](images/gleamx_package_module_manure.png)

    [`calc_volatile_solids()`](../reference/calc_volatile_solids.html)
    (IPCC 2006/2019, Eq. 10.24).

2.  **Methane (CH₄)** emissions from manure management are computed from
    VS and MMS-specific factors (MCF and B₀), reported by MMS group
    (pasture, burned, other) using
    [`calc_ch4_manure()`](https://github.com/un-fao/GLEAM/reference/calc_ch4_manure.md)
    (IPCC 2006/2019, Eq. 10.23).
3.  **Direct N₂O** emissions are computed from nitrogen excretion and
    MMS-specific EF3 values, reported by MMS group using
    [`calc_n2o_manure_direct()`](https://github.com/un-fao/GLEAM/reference/calc_n2o_manure_direct.md)
    (IPCC 2006/2019, Eq. 10.25).
4.  **Indirect N₂O** emissions are the sum of:

- Volatilisation-driven N₂O from MMS-specific nitrogen losses (FracGas)
  and EF4 using
  [`calc_n2o_manure_volatilization()`](https://github.com/un-fao/GLEAM/reference/calc_n2o_manure_volatilization.md)
  (IPCC 2006/2019, Eq. 10.26–10.28).
- Leaching/runoff-driven N₂O from MMS-specific nitrogen losses
  (FracLeach) and EF5 using
  [`calc_n2o_manure_leaching()`](https://github.com/un-fao/GLEAM/reference/calc_n2o_manure_leaching.md)
  (IPCC 2006/2019, Eq. 10.27–10.29).

5.  **Total N₂O** (direct + indirect) is summed by MMS group using
    [`calc_n2o_manure_total()`](https://github.com/un-fao/GLEAM/reference/calc_n2o_manure_total.md).

## Feed Production Emissions Module

*See
[`run_emissions_ration_module()`](https://github.com/un-fao/GLEAM/reference/run_emissions_ration_module.md)
for full documentation.*

Computes cohort-level average greenhouse gas emission factors from feed
production by weighting the emission factors of individual feed
components by diet composition. Returns diet-level average GHG emission
factors by gas and emission source for each cohort.

The module joins ration shares with feed emission factors by `feed_id`
and applies the following calculation sequence:

1.  **Merge** ration shares with emission factors at the feed-component
    level.
2.  **Compute feed-component contributions** (row-wise) for each
    emission source by multiplying the ration share of each feed
    component (`feed_ration_fraction`) by the corresponding emission
    factor:
    - CO₂ from fertilizer manufacture —
      [`calc_co2_ration_fertilizer()`](https://github.com/un-fao/GLEAM/reference/calc_co2_ration_fertilizer.md)
    - CO₂ from pesticide manufacture —
      [`calc_co2_ration_pesticides()`](https://github.com/un-fao/GLEAM/reference/calc_co2_ration_pesticides.md)
    - CO₂ from on-field crop activities —
      [`calc_co2_ration_crop_activities()`](https://github.com/un-fao/GLEAM/reference/calc_co2_ration_crop_activities.md)
    - CO₂ from land-use change (no peat) —
      [`calc_co2_ration_luc_nopeat()`](https://github.com/un-fao/GLEAM/reference/calc_co2_ration_luc_nopeat.md)
    - CO₂ from land-use change (peat) —
      [`calc_co2_ration_luc_peat()`](https://github.com/un-fao/GLEAM/reference/calc_co2_ration_luc_peat.md)
    - N₂O from fertilizer use —
      [`calc_n2o_ration_fertilizer()`](https://github.com/un-fao/GLEAM/reference/calc_n2o_ration_fertilizer.md)
    - N₂O from manure applied to soil —
      [`calc_n2o_ration_manure()`](https://github.com/un-fao/GLEAM/reference/calc_n2o_ration_manure.md)
    - N₂O from crop residues —
      [`calc_n2o_ration_crop_residues()`](https://github.com/un-fao/GLEAM/reference/calc_n2o_ration_crop_residues.md)
    - CH₄ from rice cultivation —
      [`calc_ch4_ration_rice()`](https://github.com/un-fao/GLEAM/reference/calc_ch4_ration_rice.md)
3.  **Sum** component contributions within each cohort to obtain
    diet-level average emission factors (g gas/kg DM).

**Overview of the GLEAM feed production emissions module with functions,
input and output:**

![Overview of the GLEAM feed production emissions
module](images/gleamx_package_module_feedemissions.png)

## Production Module

*See
[`run_production_module()`](https://github.com/un-fao/GLEAM/reference/run_production_module.md)
for full documentation.*

Computes cohort-level production outputs over the assessment period by
combining cohort-level herd structure inputs with herd-level production
parameters. The module returns milk, fibre, and meat outputs for each
cohort.

**Overview of the GLEAM production module with functions, input and
output:**

![Overview of the GLEAM production
module](images/gleamx_package_module_production.png)

The following calculation sequence is applied:

1.  Milk outputs (raw mass, protein, and fat-protein-corrected milk —
    FPCM) are computed using
    [`calc_milk_production()`](https://github.com/un-fao/GLEAM/reference/calc_milk_production.md).
2.  Fibre outputs (wool, cashmere, mohair) are computed using
    [`calc_fibre_production()`](https://github.com/un-fao/GLEAM/reference/calc_fibre_production.md).
3.  Meat outputs (live weight, carcass weight, bone-free meat, and
    protein) are computed using
    [`calc_meat_production()`](https://github.com/un-fao/GLEAM/reference/calc_meat_production.md).

## Emission Allocation Module

*See
[`run_allocation_module()`](https://github.com/un-fao/GLEAM/reference/run_allocation_module.md)
for full documentation.*

Computes biophysical allocation shares for livestock commodities by
calculating cohort-level energy requirements for meat, milk, fibre,
work, and eggs, aggregating these terms to herd level, and assigning
allocation shares to emission sources. The approach follows the IDF
Global Carbon Footprint Standard for the dairy sector, adapted for
livestock systems in which emissions are apportioned among multiple
products according to their physiological energy requirements. This is
consistent with ISO 14044:2006 (Section 4.3.4.2, Step 2).

**Overview of the GLEAM emissions allocation module with functions,
input and output:**

![Overview of the GLEAM emissions allocation
module](images/gleamx_package_module_allocation.png)

The pipeline consists of the following steps:

1.  **Cohort-level energy allocation terms** are computed for each
    commodity:
    - Meat —
      [`calc_meat_allocation_energy()`](https://github.com/un-fao/GLEAM/reference/calc_meat_allocation_energy.md)
    - Milk —
      [`calc_milk_allocation_energy()`](https://github.com/un-fao/GLEAM/reference/calc_milk_allocation_energy.md)
    - Fibre —
      [`calc_fibre_allocation_energy()`](https://github.com/un-fao/GLEAM/reference/calc_fibre_allocation_energy.md)
    - Work (draught power) —
      [`calc_work_allocation_energy()`](https://github.com/un-fao/GLEAM/reference/calc_work_allocation_energy.md)
    - Eggs — set to 0 (not yet implemented)
2.  **Cohort-level energy terms are aggregated to herd level** using
    [`calc_cohort_to_herd_aggregation()`](https://github.com/un-fao/GLEAM/reference/calc_cohort_to_herd_aggregation.md).
3.  **Herd-level allocation shares** are computed using
    [`calc_allocation_shares()`](https://github.com/un-fao/GLEAM/reference/calc_allocation_shares.md).
4.  **Allocation shares are reshaped to long format** and assigned to
    emission sources using
    [`assign_allocation_shares()`](https://github.com/un-fao/GLEAM/reference/assign_allocation_shares.md).

## Aggregation and Reporting Module

*See
[`run_aggregation_module()`](https://github.com/un-fao/GLEAM/reference/run_aggregation_module.md)
for full documentation.*

This is the final step of the GLEAM pipeline. It generates final
herd-level results by aggregating key cohort-level outputs, scaling
variables over the assessment duration, allocating emissions to
commodities, and converting CH₄ and N₂O emissions to CO₂-equivalents
(CO₂eq) using selected 100-year Global Warming Potential (GWP-100)
factors.

**Overview of the GLEAM aggregation module with functions, input and
output:**

![Overview of the GLEAM aggregation
module](images/gleamx_package_module_aggregation.png)

The following calculation sequence is applied:

1.  Cohort-level variables are reshaped from wide to long format.
2.  Variables are classified into `"Feed"`, `"NitrogenBalance"`,
    `"Production"`, and `"Emissions"`.
3.  Cohort totals are calculated using
    [`calc_cohort_totals()`](https://github.com/un-fao/GLEAM/reference/calc_cohort_totals.md).
    Production variables are retained as provided; emissions, feed, and
    nitrogen balance variables are scaled using cohort stock size and
    simulation duration.
4.  Cohort totals are aggregated to herd level using
    [`calc_cohort_to_herd_aggregation()`](https://github.com/un-fao/GLEAM/reference/calc_cohort_to_herd_aggregation.md).
5.  Herd-level emissions are merged with commodity allocation shares.
6.  Emissions are allocated to commodities using
    [`calc_allocated_emissions()`](https://github.com/un-fao/GLEAM/reference/calc_allocated_emissions.md).
7.  Gas type (CH₄, N₂O, CO₂) is identified from the emission variable
    name.
8.  Allocated emissions are converted to CO₂eq using
    [`calc_co2eq()`](https://github.com/un-fao/GLEAM/reference/calc_co2eq.md)
    and the selected GWP-100 option (AR4, AR5, or AR6).
9.  Final output tables are produced summarising herd-level results for
    emissions, feed, production, and nitrogen balance.
