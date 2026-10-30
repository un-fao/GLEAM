# Package index

## Main pipeline

- [`run_gleam()`](https://un-fao.github.io/GLEAM/reference/run_gleam.md)
  : Run the full Global Livestock Environmental Assessment Model (GLEAM)
  Pipeline

## Combined herd module

- [`run_all_herd_module()`](https://un-fao.github.io/GLEAM/reference/run_all_herd_module.md)
  : Run Combined Herd Module Pipeline
- [`rescale_x_to_y()`](https://un-fao.github.io/GLEAM/reference/rescale_x_to_y.md)
  : Rescale a variable from one reference total to another

## Demographic herd module

- [`run_demographic_herd_module()`](https://un-fao.github.io/GLEAM/reference/run_demographic_herd_module.md)
  : Run Demographic Herd Module Pipeline
- [`calc_fecundity_rates()`](https://un-fao.github.io/GLEAM/reference/calc_fecundity_rates.md)
  : Calculate daily fecundity rates
- [`calc_transition_probabilities()`](https://un-fao.github.io/GLEAM/reference/calc_transition_probabilities.md)
  : Calculate transition probabilities for sex-age classes
- [`calc_steady_state_structure()`](https://un-fao.github.io/GLEAM/reference/calc_steady_state_structure.md)
  : Calculate steady-state population structure
- [`calc_projected_population_size()`](https://un-fao.github.io/GLEAM/reference/calc_projected_population_size.md)
  : Calculate one year of steady-state population dynamics
- [`calc_summary_offtake()`](https://un-fao.github.io/GLEAM/reference/calc_summary_offtake.md)
  : Summarise offtake and stock Variation for a steady-state year

## Non-demographic herd module

- [`run_nondemographic_herd_module()`](https://un-fao.github.io/GLEAM/reference/run_nondemographic_herd_module.md)
  : Run Non-Demographic Herd Module Pipeline
- [`assign_nondemographic_phase_durations()`](https://un-fao.github.io/GLEAM/reference/assign_nondemographic_phase_durations.md)
  : Assign nondemographic phase durations to cohort rows
- [`calc_nondemographic_total_durations()`](https://un-fao.github.io/GLEAM/reference/calc_nondemographic_total_durations.md)
  : Calculate total nondemographic durations by herd
- [`calc_nondemo_cycle_geometry()`](https://un-fao.github.io/GLEAM/reference/calc_nondemo_cycle_geometry.md)
  : Calculate nondemographic cycle geometry
- [`calc_nondemo_start_sizes()`](https://un-fao.github.io/GLEAM/reference/calc_nondemo_start_sizes.md)
  : Calculate nondemographic entrants across production cycles
- [`calc_nondemo_phase()`](https://un-fao.github.io/GLEAM/reference/calc_nondemo_phase.md)
  : Calculate a nondemographic productive phase
- [`calc_nondemo_avg_stock_phase_horizon()`](https://un-fao.github.io/GLEAM/reference/calc_nondemo_avg_stock_phase_horizon.md)
  : Calculate average nondemographic stock over the fixed simulation
  horizon
- [`calc_nondemo_offtake_total_horizon()`](https://un-fao.github.io/GLEAM/reference/calc_nondemo_offtake_total_horizon.md)
  : Calculate total nondemographic offtake over the assessment horizon

## Weights module

- [`run_weights_module()`](https://un-fao.github.io/GLEAM/reference/run_weights_module.md)
  : Run Weights Module Pipeline
- [`calc_avg_weights()`](https://un-fao.github.io/GLEAM/reference/calc_avg_weights.md)
  : Calculate average and final live weights by cohort
- [`calc_cohort_weights()`](https://un-fao.github.io/GLEAM/reference/calc_cohort_weights.md)
  : Calculate live weights by cohort and life stage
- [`calc_daily_weight_gain()`](https://un-fao.github.io/GLEAM/reference/calc_daily_weight_gain.md)
  : Calculate daily weight gain by cohort

## Ration quality module

- [`run_ration_quality_module()`](https://un-fao.github.io/GLEAM/reference/run_ration_quality_module.md)
  : Run Ration Quality Module Pipeline
- [`calc_feed_digestibility_fraction()`](https://un-fao.github.io/GLEAM/reference/calc_feed_digestibility_fraction.md)
  : Calculate feed digestibility fraction
- [`calc_ration_digestibility()`](https://un-fao.github.io/GLEAM/reference/calc_ration_digestibility.md)
  : Calculate diet digestibility contribution for a ration component
- [`calc_ration_metabolizable_energy()`](https://un-fao.github.io/GLEAM/reference/calc_ration_metabolizable_energy.md)
  : Calculate diet metabolizable energy contribution for a ration
  component
- [`calc_ration_gross_energy()`](https://un-fao.github.io/GLEAM/reference/calc_ration_gross_energy.md)
  : Calculate diet gross energy contribution for a ration component
- [`calc_ration_nitrogen_content()`](https://un-fao.github.io/GLEAM/reference/calc_ration_nitrogen_content.md)
  : Calculate diet nitrogen contribution for a ration component
- [`calc_ration_urinary_energy_fraction()`](https://un-fao.github.io/GLEAM/reference/calc_ration_urinary_energy_fraction.md)
  : Calculate urinary energy fraction contribution for a ration
  component
- [`calc_ration_ash()`](https://un-fao.github.io/GLEAM/reference/calc_ration_ash.md)
  : Calculate diet ash contribution for a ration component

## Metabolic energy requirements module

- [`run_metabolic_energy_req_module()`](https://un-fao.github.io/GLEAM/reference/run_metabolic_energy_req_module.md)
  : Run Metabolic Energy Requirements and Dry Matter Intake Module
  Pipeline
- [`calc_metabolic_energy_req_maintenance()`](https://un-fao.github.io/GLEAM/reference/calc_metabolic_energy_req_maintenance.md)
  : Calculate metabolic energy requirements for maintenance
- [`calc_metabolic_energy_req_activity()`](https://un-fao.github.io/GLEAM/reference/calc_metabolic_energy_req_activity.md)
  : Calculate metabolic energy requirements for activity
- [`calc_metabolic_energy_req_growth()`](https://un-fao.github.io/GLEAM/reference/calc_metabolic_energy_req_growth.md)
  : Calculate metabolic energy requirements for growth
- [`calc_metabolic_energy_req_lactation()`](https://un-fao.github.io/GLEAM/reference/calc_metabolic_energy_req_lactation.md)
  : Calculate metabolic energy requirements for lactation
- [`calc_metabolic_energy_req_pregnancy()`](https://un-fao.github.io/GLEAM/reference/calc_metabolic_energy_req_pregnancy.md)
  : Calculate metabolic energy requirements for pregnancy
- [`calc_metabolic_energy_req_work()`](https://un-fao.github.io/GLEAM/reference/calc_metabolic_energy_req_work.md)
  : Calculate metabolic energy requirements for work
- [`calc_metabolic_energy_req_fibre()`](https://un-fao.github.io/GLEAM/reference/calc_metabolic_energy_req_fibre.md)
  : Calculate metabolic energy requirements for fibre production
- [`calc_metabolic_energy_req_eggs()`](https://un-fao.github.io/GLEAM/reference/calc_metabolic_energy_req_eggs.md)
  : Calculate metabolic energy requirements for egg production
- [`calc_rem_maintenance()`](https://un-fao.github.io/GLEAM/reference/calc_rem_maintenance.md)
  : Calculate ratio of net energy available for maintenance in the diet
  (REM - Net Energy for Maintenance / Digestible Energy)
- [`calc_reg_growth()`](https://un-fao.github.io/GLEAM/reference/calc_reg_growth.md)
  : Calculate the ratio of net energy available for growth in the diet
  (REG – Net Energy for Growth / Digestible Energy)
- [`calc_total_metabolic_energy_req()`](https://un-fao.github.io/GLEAM/reference/calc_total_metabolic_energy_req.md)
  : Calculate total metabolic energy requirements
- [`calc_ration_intake()`](https://un-fao.github.io/GLEAM/reference/calc_ration_intake.md)
  : Calculate daily ration intake in dry matter

## Nitrogen balance module

- [`run_nitrogen_balance_module()`](https://un-fao.github.io/GLEAM/reference/run_nitrogen_balance_module.md)
  : Run Nitrogen Balance Module Pipeline
- [`calc_nitrogen_intake()`](https://un-fao.github.io/GLEAM/reference/calc_nitrogen_intake.md)
  : Calculate daily nitrogen intake
- [`calc_nitrogen_retention()`](https://un-fao.github.io/GLEAM/reference/calc_nitrogen_retention.md)
  : Calculate daily nitrogen retention
- [`calc_nitrogen_excretion()`](https://un-fao.github.io/GLEAM/reference/calc_nitrogen_excretion.md)
  : Calculate daily nitrogen excretion

## Enteric emissions module

- [`run_emissions_enteric_module()`](https://un-fao.github.io/GLEAM/reference/run_emissions_enteric_module.md)
  : Run Enteric Methane (CH4) Emissions Module Pipeline
- [`calc_conversion_factor_ym()`](https://un-fao.github.io/GLEAM/reference/calc_conversion_factor_ym.md)
  : Calculate methane conversion factor (ym)
- [`calc_ch4_enteric()`](https://un-fao.github.io/GLEAM/reference/calc_ch4_enteric.md)
  : Calculate daily enteric methane emissions

## Manure emissions module

- [`run_emissions_manure_module()`](https://un-fao.github.io/GLEAM/reference/run_emissions_manure_module.md)
  : Run Emissions from Manure Module Pipeline
- [`calc_volatile_solids()`](https://un-fao.github.io/GLEAM/reference/calc_volatile_solids.md)
  : Calculate Volatile Solids (VS)
- [`calc_ch4_manure()`](https://un-fao.github.io/GLEAM/reference/calc_ch4_manure.md)
  : Calculate methane (CH4) emissions from manure management systems
- [`calc_n2o_manure_direct()`](https://un-fao.github.io/GLEAM/reference/calc_n2o_manure_direct.md)
  : Calculate direct Nitrous Oxide (N2O) emissions from manure
  management systems
- [`calc_n2o_manure_volatilization()`](https://un-fao.github.io/GLEAM/reference/calc_n2o_manure_volatilization.md)
  : Calculate indirect Nitrous Oxide (N2O) emissions from manure
  volatilization
- [`calc_n2o_manure_leaching()`](https://un-fao.github.io/GLEAM/reference/calc_n2o_manure_leaching.md)
  : Calculate indirect Nitrous Oxide (N2O) emissions from manure
  leaching and runoff
- [`calc_n2o_manure_total()`](https://un-fao.github.io/GLEAM/reference/calc_n2o_manure_total.md)
  : Calculate total Nitrous Oxide (N2O) emissions from manure

## Feed emissions module

- [`run_emissions_ration_module()`](https://un-fao.github.io/GLEAM/reference/run_emissions_ration_module.md)
  : Run Emissions from Feed Production Module Pipeline
- [`calc_ch4_ration_rice()`](https://un-fao.github.io/GLEAM/reference/calc_ch4_ration_rice.md)
  : Calculate a ration component's contribution to methane (CH4)
  emissions from rice cultivation
- [`calc_co2_ration_fertilizer()`](https://un-fao.github.io/GLEAM/reference/calc_co2_ration_fertilizer.md)
  : Calculate a ration component's contribution to carbon dioxide (CO2)
  emissions from fertilizer manufacture
- [`calc_co2_ration_pesticides()`](https://un-fao.github.io/GLEAM/reference/calc_co2_ration_pesticides.md)
  : Calculate a ration component's contribution to carbon dioxide (CO2)
  emissions from pesticide manufacture
- [`calc_co2_ration_crop_activities()`](https://un-fao.github.io/GLEAM/reference/calc_co2_ration_crop_activities.md)
  : Calculate a ration component's contribution to carbon dioxide (CO2)
  emissions from on-field agricultural activities
- [`calc_co2_ration_luc_nopeat()`](https://un-fao.github.io/GLEAM/reference/calc_co2_ration_luc_nopeat.md)
  : Calculate a ration component's contribution to carbon dioxide (CO2)
  emissions from land-use change (excluding peatland drainage)
- [`calc_co2_ration_luc_peat()`](https://un-fao.github.io/GLEAM/reference/calc_co2_ration_luc_peat.md)
  : Calculate a ration component's contribution to carbon dioxide (CO2)
  emissions from peatland drainage
- [`calc_n2o_ration_fertilizer()`](https://un-fao.github.io/GLEAM/reference/calc_n2o_ration_fertilizer.md)
  : Calculate a ration component's contribution to nitrous oxide (N2O)
  emissions from fertilizer use
- [`calc_n2o_ration_manure()`](https://un-fao.github.io/GLEAM/reference/calc_n2o_ration_manure.md)
  : Calculate a ration component's contribution to nitrous oxide (N2O)
  emissions from manure application and deposition
- [`calc_n2o_ration_crop_residues()`](https://un-fao.github.io/GLEAM/reference/calc_n2o_ration_crop_residues.md)
  : Calculate a ration component's contribution to nitrous oxide (N2O)
  emissions from crop residues decomposition

## Production module

- [`run_production_module()`](https://un-fao.github.io/GLEAM/reference/run_production_module.md)
  : Run Production Module Pipeline
- [`calc_milk_production()`](https://un-fao.github.io/GLEAM/reference/calc_milk_production.md)
  : Calculate milk production
- [`calc_meat_production()`](https://un-fao.github.io/GLEAM/reference/calc_meat_production.md)
  : Calculate meat production
- [`calc_fibre_production()`](https://un-fao.github.io/GLEAM/reference/calc_fibre_production.md)
  : Calculate fibre production
- [`calc_egg_production()`](https://un-fao.github.io/GLEAM/reference/calc_egg_production.md)
  : Calculate egg production

## Allocation module

- [`run_allocation_module()`](https://un-fao.github.io/GLEAM/reference/run_allocation_module.md)
  : Run Allocation Module Pipeline
- [`calc_milk_allocation_energy()`](https://un-fao.github.io/GLEAM/reference/calc_milk_allocation_energy.md)
  : Calculate milk energy requirements (for biophysical allocation)
- [`calc_meat_allocation_energy()`](https://un-fao.github.io/GLEAM/reference/calc_meat_allocation_energy.md)
  : Calculate meat energy requirements (for biophysical allocation)
- [`calc_fibre_allocation_energy()`](https://un-fao.github.io/GLEAM/reference/calc_fibre_allocation_energy.md)
  : Calculate fibre energy requirements (for biophysical allocation)
- [`calc_work_allocation_energy()`](https://un-fao.github.io/GLEAM/reference/calc_work_allocation_energy.md)
  : Calculate work energy requirements (for biophysical allocation)
- [`calc_egg_allocation_energy()`](https://un-fao.github.io/GLEAM/reference/calc_egg_allocation_energy.md)
  : Calculate egg energy requirements (for biophysical allocation)
- [`calc_allocation_shares()`](https://un-fao.github.io/GLEAM/reference/calc_allocation_shares.md)
  : Calculate allocation shares for livestock commodities
- [`assign_allocation_shares()`](https://un-fao.github.io/GLEAM/reference/assign_allocation_shares.md)
  : Assign allocation shares to emission variables by commodity

## Aggregation module

- [`run_aggregation_module()`](https://un-fao.github.io/GLEAM/reference/run_aggregation_module.md)
  : Run Aggregation Module Pipeline
- [`calc_cohort_totals()`](https://un-fao.github.io/GLEAM/reference/calc_cohort_totals.md)
  : Calculate totals by cohort
- [`calc_cohort_to_herd_aggregation()`](https://un-fao.github.io/GLEAM/reference/calc_cohort_to_herd_aggregation.md)
  : Aggregate cohort-level to herd-level data
- [`calc_allocated_emissions()`](https://un-fao.github.io/GLEAM/reference/calc_allocated_emissions.md)
  : Calculate allocated greenhouse gas emissions (GHG)
- [`calc_co2eq()`](https://un-fao.github.io/GLEAM/reference/calc_co2eq.md)
  : Convert methane (CH4) and nitrous oxide (N2O) emissions to
  CO2-equivalents (CO2eq) using Global Warming Potentials (GWP) factors
