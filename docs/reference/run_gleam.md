# Run the full Global Livestock Environmental Assessment Model (GLEAM) Pipeline

Runs the full GLEAM pipeline from master herd and cohort inputs through
all modules: herd (optional), weights, ration quality, energy
requirements, manure emissions, enteric fermentation, nitrogren balance,
feed emissions, allocation, and aggregation.  
  
**Common identifiers**: Several input tables share the following
identifier columns. Their supported values are listed once here and
referenced throughout.  
  
**`species_short`** — Character. Species code:

- `CTL`: Cattle

- `BFL`: Buffalo

- `SHP`: Sheep

- `GTS`: Goats

- `PGS`: Pigs

- `CML`: Camels

**`cohort_short`** — Character. Sex- and age-specific cohort code:

- `FA`: adult females (from age at first parturition)

- `FS`: sub-adult females (from weaning to age at first parturition)

- `FJ`: juvenile females (from birth to weaning)

- `MA`: adult males (from age at first breeding)

- `MS`: sub-adult males (from weaning to age at first breeding)

- `MJ`: juvenile males (from birth to weaning)

## Usage

``` r
run_gleam(
  has_herd_structure = FALSE,
  cohort_level_data,
  herd_level_data,
  feed_rations,
  feed_params,
  feed_emissions,
  manure_management_system_fraction,
  manure_management_system_factors,
  simulation_duration = 365,
  global_warming_potential_set = "AR6",
  show_indicator = TRUE
)
```

## Arguments

- has_herd_structure:

  Logical. If `TRUE`, `cohort_level_data` is treated as an existing herd
  structure and the demographic herd simulation step is skipped. If
  `FALSE`, herd structure is first generated from `cohort_level_data`
  and `herd_level_data` using
  [`run_demographic_herd_module`](https://github.com/un-fao/GLEAM/reference/run_demographic_herd_module.md).

- cohort_level_data:

  data.table. Cohort-level master input table. Required columns:

  herd_id

  :   Character. Unique herd identifier, repeated for each cohort within
      the same herd.

  species_short

  :   Character. Species code (see Common identifiers).

  cohort_short

  :   Character. Cohort code (see Common identifiers).

  cohort_duration_days

  :   Numeric. Time each animal spends in the cohort (days).

  offtake_rate

  :   Numeric. Annual proportion of animals removed from the herd per
      cohort (fraction).

  low_activity_fraction

  :   Numeric. Proportion of the assessment period with low-intensity
      movement, e.g. stall-feeding or near-field grazing (fraction).

  high_activity_fraction

  :   Numeric. Proportion of the assessment period with sustained
      locomotion, e.g. herding or long-distance grazing over uneven
      terrain (fraction).

  Additional columns when `has_herd_structure = FALSE`:

  death_rate

  :   Numeric. Annual fraction of deaths per cohort (fraction).

  Additional columns when `has_herd_structure = TRUE`:

  cohort_stock_size

  :   Numeric. Average population size in each cohort (heads).

  offtake_heads_assessment

  :   Numeric. Total animals removed via offtake over the assessment
      period per cohort (heads/assessment period).

  Optional column (both cases):

  ch4_mitigation_factor

  :   Numeric. Multiplicative factor applied to baseline enteric CH4
      emissions (dimensionless). Defaults to `1` (no mitigation). Values
      \< 1 represent proportional reductions (e.g. `0.90` = 10 percent
      reduction). Can represent feed additives or methane inhibitors.

- herd_level_data:

  data.table. Herd-level master input table (one row per `herd_id`).
  Required columns:

  herd_id

  :   Character. Unique herd identifier.

  species_short

  :   Character. Species code (see Common identifiers).

  live_weight_female_adult

  :   Numeric. Adult female live weight (kg).

  live_weight_male_adult

  :   Numeric. Adult male live weight (kg).

  live_weight_at_birth

  :   Numeric. Live weight at birth (kg).

  live_weight_at_weaning

  :   Numeric. Live weight at weaning (kg).

  live_weight_female_at_slaughter

  :   Numeric. Female sub-adult slaughter weight (kg).

  live_weight_male_at_slaughter

  :   Numeric. Male sub-adult slaughter weight (kg).

  age_first_parturition

  :   Numeric. Age at first parturition (days).

  lactating_females_fraction

  :   Numeric. Proportion of adult females lactating during the
      assessment period (fraction). Required for CTL, BFL, CML, SHP,
      GTS.

  milk_yield_day

  :   Numeric. Average daily milk yield per milk-producing animal
      (kg/head/day), calculated as total milk produced for human
      consumption divided by the number of milk-producing animals and
      the assessment period length. Required for CTL, BFL, CML, SHP,
      GTS.

  milk_fat_fraction

  :   Numeric. Milk fat content (kg fat/kg milk). Required for CTL, BFL,
      CML, SHP, GTS.

  milk_protein_fraction

  :   Numeric. Milk protein content (kg protein/kg milk). Required for
      CTL, BFL, CML, SHP, GTS.

  milk_lactose_fraction

  :   Numeric. Milk lactose content (kg lactose/kg milk). Required for
      CTL, BFL, CML, SHP, GTS.

  milk_protein_fraction_standard

  :   Numeric. Standard milk protein content for FPCM calculation (kg
      protein/kg milk). Suggested: 0.033.

  milk_fat_fraction_standard

  :   Numeric. Standard milk fat content for FPCM calculation (kg fat/kg
      milk). Suggested: 0.04.

  milk_lactose_fraction_standard

  :   Numeric. Standard milk lactose content for FPCM calculation (kg
      lactose/kg milk). Suggested: 0.048.

  non_productive_duration

  :   Numeric. Period without productive function (pregnancy/lactation)
      (days). Required for PGS.

  pregnancy_duration

  :   Numeric. Pregnancy duration (days).

  death_rate_juvenile

  :   Numeric. Annual death fraction for juvenile cohorts (FJ, MJ)
      (fraction).

  lactation_duration

  :   Numeric. Lactation period length (days). Required for PGS.

  parturition_rate

  :   Numeric. Average annual parturitions per adult female
      (parturitions/adult female/year).

  litter_size

  :   Numeric. Average offspring born per parturition
      (offspring/parturition).

  draught_work_hours_female

  :   Numeric. Average daily working time per adult female
      (hours/head/day). Required for CTL, BFL, CML.

  draught_work_hours_male

  :   Numeric. Average daily working time per adult male
      (hours/head/day). Required for CTL, BFL, CML.

  draught_fraction_female

  :   Numeric. Fraction of adult females doing draught work (fraction).
      Required for CTL, BFL, CML.

  draught_fraction_male

  :   Numeric. Fraction of adult males doing draught work (fraction).
      Required for CTL, BFL, CML.

  fibre_yield_year

  :   Numeric. Annual fibre production (wool, cashmere, mohair)
      (kg/head/year). Required for CML, SHP, GTS.

  carcass_dressing_fraction

  :   Numeric. Carcass weight to live weight ratio (fraction).

  bone_free_meat_fraction

  :   Numeric. Bone-free meat to carcass weight ratio (fraction).

  meat_protein_fraction

  :   Numeric. Protein content of bone-free meat (kg protein/kg
      bone-free meat).

  ratio_me_to_ne

  :   Numeric. Metabolizable-to-net energy ratio (fraction). Used
      for CML. Suggested: 0.43.

  Additional columns when `has_herd_structure = FALSE`:

  birth_fraction_female

  :   Numeric. Probability that a newborn is female (fraction).

  herd_size_total

  :   Numeric. Total population at start of year, all cohorts (heads).

- feed_rations:

  data.table. Cohort-level feed ration shares, also used by
  [`run_ration_quality_module`](https://github.com/un-fao/GLEAM/reference/run_ration_quality_module.md)
  and
  [`run_emissions_ration_module`](https://github.com/un-fao/GLEAM/reference/run_emissions_ration_module.md).
  Required columns:

  herd_id

  :   Character. Unique herd identifier.

  species_short

  :   Character. Species code (see Common identifiers).

  cohort_short

  :   Character. Cohort code (see Common identifiers).

  feed_id

  :   Character. Unique feed component identifier, used as join key with
      feed parameter tables.

  feed_name

  :   Character. Optional. Human-readable feed name; should match
      `feed_id` uniquely if provided.

  feed_ration_fraction

  :   Numeric. Proportion of this feed component in the total ration as
      a fraction of diet dry matter intake (fraction). Must sum to 1
      within each herd_id \\\times\\ cohort combination.

- feed_params:

  data.table. Feed nutritional parameters. Required columns:

  feed_id

  :   Character. Unique feed component identifier.

  feed_gross_energy

  :   Numeric. Gross energy: total chemical energy upon complete
      combustion (MJ/kg DM).

  feed_digestible_energy_ruminant

  :   Numeric. Digestible energy for ruminants: energy absorbed after
      faecal losses (MJ/kg DM).

  feed_digestible_energy_pigs

  :   Numeric. Digestible energy for pigs (MJ/kg DM).

  feed_metabolizable_energy_ruminant

  :   Numeric. Metabolizable energy for ruminants: digestible energy
      minus urinary and gaseous losses (MJ/kg DM).

  feed_metabolizable_energy_pigs

  :   Numeric. Metabolizable energy for pigs (MJ/kg DM).

  feed_metabolizable_energy_chicken

  :   Numeric. Metabolizable energy for chickens: digestible energy
      minus uric acid and gaseous losses (MJ/kg DM).

  feed_nitrogen_content

  :   Numeric. Nitrogen content (kg N/kg DM).

  feed_urinary_energy_ruminant

  :   Numeric. Fraction of gross energy excreted in urine for ruminants
      (fraction).

  feed_urinary_energy_pigs

  :   Numeric. Fraction of gross energy excreted in urine for pigs
      (fraction).

  feed_ash

  :   Numeric. Ash content as a fraction of dry matter (g ash/100 g DM).

  category

  :   Character. Optional. Feed category; should be used consistently
      with `feed_id`.

  feed_name

  :   Character. Optional. Human-readable feed name; should match
      `feed_id` uniquely if provided.

- feed_emissions:

  data.table. Emission factors per feed component. All emission factors
  are expressed per kg of feed dry matter intake. Required columns:

  feed_id

  :   Character. Unique feed component identifier.

  feed_name

  :   Character. Optional. Human-readable feed name.

  co2_feed_fertilizer

  :   Numeric. CO2 from fertilizer manufacture (g CO2/kg DM).

  co2_feed_pesticides

  :   Numeric. CO2 from pesticide manufacture (g CO2/kg DM).

  co2_feed_crop_activities

  :   Numeric. CO2 from on-field agricultural activities (g CO2/kg DM).

  co2_feed_luc_nopeat

  :   Numeric. CO2 from land-use change, excluding peatland drainage (g
      CO2/kg DM).

  co2_feed_luc_peat

  :   Numeric. CO2 from peatland drainage (g CO2/kg DM).

  n2o_feed_fertilizer

  :   Numeric. N2O from fertilizer use (g N2O/kg DM).

  n2o_feed_manure_applied

  :   Numeric. N2O from manure applied to or deposited on soil (g N2O/kg
      DM).

  n2o_feed_crop_residues

  :   Numeric. N2O from crop residue decomposition (g N2O/kg DM).

  ch4_feed_rice

  :   Numeric. CH4 from rice cultivation (g CH4/kg DM).

- manure_management_system_fraction:

  data.table. Cohort-level manure management system fractions passed to
  [`run_emissions_manure_module`](https://github.com/un-fao/GLEAM/reference/run_emissions_manure_module.md).
  Required columns:

  herd_id

  :   Character. Unique herd identifier.

  cohort_short

  :   Character. Cohort code (see Common identifiers).

  manure_management_system

  :   Character. Manure management system name. `mms_pasture` and
      `mms_burned` are reserved for manure deposited on pasture and
      burned for fuel, respectively. All other systems are grouped as
      "other".

  manure_management_system_fraction

  :   Numeric. Fraction of total manure handled by this system for each
      herd \\\times\\ cohort combination (0–1). Must sum to 1 per
      herd_id.

- manure_management_system_factors:

  data.table. Emission factors and parameters per manure management
  system, passed to
  [`run_emissions_manure_module`](https://github.com/un-fao/GLEAM/reference/run_emissions_manure_module.md).
  Required columns:

  manure_management_system

  :   Character. System name (see `manure_management_system_fraction`).

  ratio_m3CH4_to_kgCH4

  :   Numeric. CH4 density conversion factor (kg/m3). Default: 0.67.

  methane_conversion_factor_mcf

  :   Numeric. Fraction of maximum CH4-producing capacity (Bo) realised
      under given management and environmental conditions (0–1). See
      IPCC Table 10.17 (2006, 2019).

  ch4_max_producing_capacity_bo

  :   Numeric. Maximum CH4-producing capacity per unit volatile solids
      (m3 CH4/kg VS). Region- and species-specific. See IPCC Table
      10.16 (2019) or Tables 10A-4 to 10A-9 (2006).

  n2o_ef3

  :   Numeric. Direct N2O emission factor per manure management system
      (kg N2O-N/kg N). See IPCC Table 10.21 and Table 11.1 (2006, 2019).

  n2o_ef4

  :   Numeric. Indirect N2O emission factor from atmospheric deposition
      of volatilised N (kg N2O-N/(kg NH3-N + NOx-N)). See IPCC Table
      11.3 (2006, 2019).

  nitrogen_fracgas

  :   Numeric. Fraction of excreted N volatilised as NH3 and NOx during
      collection, storage, and treatment (0–1). See IPCC Table 10.22
      (2006, 2019).

  n2o_ef5

  :   Numeric. Indirect N2O emission factor from leaching and runoff (kg
      N2O-N/kg N). See IPCC Table 11.3 (2006, 2019).

  nitrogen_fracleach

  :   Numeric. Fraction of excreted N lost through leaching and runoff
      (0–1). See IPCC Table 10.22 (2006, 2019).

- simulation_duration:

  Numeric. Assessment period length (days). Used by the demographic herd
  simulation (when `has_herd_structure = FALSE`) and by the production
  and aggregation steps. Default: `365`.

- global_warming_potential_set:

  Character. GWP-100 conversion factors for expressing CH4 and N2O as
  CO2-eq. One of:

  - `"AR6"`: IPCC 6th Assessment (2021) — CH4 = 27, N2O = 273.

  - `"AR5_excluding_carbon_feedback"`: IPCC 5th Assessment, excl.
    climate-carbon feedbacks (2013) — CH4 = 28, N2O = 265.

  - `"AR5_including_carbon_feedback"`: IPCC 5th Assessment, incl.
    climate-carbon feedbacks (2013) — CH4 = 34, N2O = 298.

  - `"AR4"`: IPCC 4th Assessment (2007) — CH4 = 25, N2O = 298.

- show_indicator:

  Logical. Whether to display progress indicators during calculations.
  Defaults to `TRUE`.

## Value

A named list with four elements:

- cohort_level_results:

  A cohort-level `data.table` containing the original input columns plus
  all variables generated across the pipeline. Calculated variables are
  grouped below by module.

  ### Demographic herd simulation

  Computed when `has_herd_structure = FALSE`:

  cohort_stock_size

  :   Numeric. Average population size in each of the 6 sex-age cohorts
      (# heads). (cohorts = `FJ`, `FS`, `FA`, `MJ`, `MS`, `MA`).

  offtake_heads

  :   Numeric. Total number of animals removed via offtake over the
      year, aggregated to 6 sex-age cohorts (heads/year) (cohorts =
      `FJ`, `FS`, `FA`, `MJ`, `MS`, `MA`).

  offtake_heads_assessment

  :   Numeric. Total number of animals removed via offtake over the
      assessment period, aggregated to 6 sex-age cohorts
      (heads/assessment period) (cohorts = `FJ`, `FS`, `FA`, `MJ`, `MS`,
      `MA`).

  ### Weight variables

  live_weight_mature_stage

  :   Numeric. Mature (adult) live weight that the animal can attain
      under given biological and management conditions (kg).

  live_weight_cohort_initial

  :   Numeric. Live weight at the beginning of the cohort stage (kg).

  live_weight_cohort_potential_final

  :   Numeric. Potential final live weight attainable at the end of the
      cohort stage in the absence of offtake (kg). (For juveniles:
      equals weaning weight; For subadults: equals adult live weight;
      For adults: equals adult live weight)

  live_weight_cohort_at_slaughter

  :   Numeric. Live weight at slaughter for animals removed from the
      cohort (kg).

  live_weight_cohort_average

  :   Numeric. Average live weight over the cohort stage. Computed by
      accounting for the share of offtaken animals within the cohort,
      using their slaughter weight, and the potential final weight of
      animals that remain in the cohort (kg).

  live_weight_cohort_final

  :   Numeric. Live weight at the end of the cohort stage, accounting
      for both surviving and offtaken animals. Computed as a weighted
      average of the potential final weight of surviving animals and the
      slaughter weight of offtaken animals, based on the offtake rate
      (kg).

  daily_weight_gain

  :   Numeric. Average live weight gain of the cohort over the cohort
      stage (kg/head/day).

  ### Ration quality variables

  ration_gross_energy

  :   Numeric. Average gross energy content of the diet (MJ/kg DM).

  ration_metabolizable_energy

  :   Numeric. Average metabolizable energy content of the diet (MJ/kg
      DM).

  ration_nitrogen

  :   Numeric. Average nitrogen content of diet (kg N/kg DM).

  ration_digestibility_fraction

  :   Numeric. Average digestibility of the feed ration, expressed as
      ratio of digestible (or metabolizable, for poultry) to gross
      energy content (fraction).

  ration_urinary_energy_fraction

  :   Numeric. Fraction of feed's gross energy that is excreted in urine
      (fraction).

  ration_ash

  :   Numeric. Average ash content of feed, calculated as a fraction of
      the dry matter intake (kg ash/kg DM).

  ### Energy requirement variables

  Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable
  energy for CML and PGS unless stated otherwise.

  metabolic_energy_req_maintenance

  :   Numeric. Energy required for maintenance, defined as the amount of
      energy needed to keep the animal at equilibrium such that body
      energy is neither gained nor lost (MJ/head/day). Expressed as net
      energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML
      and PGS.

  metabolic_energy_req_activity

  :   Numeric. Energy required for activity, defined as the amount of
      energy needed to support animal movement and physical activity
      (MJ/head/day). Expressed as net energy for CTL, BFL, SHP, GTS and
      as metabolizable energy for CML and PGS.

  metabolic_energy_req_growth

  :   Numeric. Energy required for growth (i.e., weight gain)
      (MJ/head/day). Expressed as net energy for CTL, BFL, SHP, GTS and
      as metabolizable energy for CML and PGS.

  metabolic_energy_req_lactation

  :   Numeric. Energy required for lactation (MJ/head/day). Expressed as
      net energy for CTL, BFL, SHP, GTS and as metabolizable energy for
      CML and PGS.

  metabolic_energy_req_work

  :   Numeric. Energy required for work, used to estimate the energy
      required for draught power for CTL, BFL and CML (MJ/head/day).
      Assumed to be 0 for other species. Expressed as net energy for
      CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS.

  metabolic_energy_req_fibre_production

  :   Numeric. Energy required for the synthesis of fibre for SHP, GTS
      and CML. Assumed to be 0 for other species. (MJ/head/day).
      Expressed as net energy for CTL, BFL, SHP, GTS and as
      metabolizable energy for CML and PGS (MJ/head/day).

  metabolic_energy_req_pregnancy

  :   Numeric. Energy required for pregnancy for pregnant females
      (MJ/head/day). Expressed as net energy for CTL, BFL, SHP, GTS and
      as metabolizable energy for CML and PGS.

  net_energy_maintenance_digestible_energy_ratio

  :   Numeric. Ratio of net energy available for maintenance in the diet
      to digestible energy consumed (fraction).

  net_energy_growth_digestible_energy_ratio

  :   Numeric. Ratio of net energy available for growth in the diet to
      digestible energy consumed (fraction).

  metabolic_energy_req_total

  :   Numeric. Total daily energy requirement (MJ/head/day). For CTL,
      BFL, SHP and GTS this is expressed as gross energy intake
      requirement (GE). For CML and PGS the function returns the summed
      daily metabolizable energy requirement.

  ration_intake

  :   Numeric. Average daily dry matter intake of feed (kg DM/head/day).

  ### Enteric emission variables

  ch4_mitigation_factor

  :   Numeric. Multiplicative mitigation factor applied to baseline
      enteric methane (CH4) emissions (dimensionless). If not provided,
      a default value of `1` (no mitigation) is used.

  ch4_conversion_factor_ym

  :   Numeric. Methane (CH4) conversion factor (ym), representing the
      percentage of gross energy of the feed ration that is converted to
      CH4 (percentage).

  ch4_enteric

  :   Numeric. Average daily enteric methane (CH4) emissions (kg
      CH4/head/day).

  ### Nitrogen balance variables

  nitrogen_intake

  :   Numeric. Daily nitrogen intake (kg N/head/day).

  nitrogen_retention

  :   Numeric. Daily nitrogen retention in animal body tissues and
      products (e.g., growth, pregnancy, milk...) (kg N/head/day).

  nitrogen_excretion

  :   Numeric. Daily nitrogen excretion (kg N/head/day).

  ### Manure emission variables

  volatile_solids

  :   Numeric. Total volatile solids (VS) excreted per animal per day,
      representing the organic material in livestock manure and
      consisting of both biodegradable and non-biodegradable fractions
      (kg VS/head/day).

  ch4_manure_pasture

  :   Numeric. Methane (CH4) emissions from manure deposited on pasture
      (kg CH4/head/day).

  ch4_manure_burned

  :   Numeric. Methane (CH4) emissions from manure burned for fuel (kg
      CH4/head/day).

  ch4_manure_other

  :   Numeric. Methane (CH4) emissions from manure management systems,
      excluding emissions from manure deposited on pasture and burned
      for fuel (kg CH4/head/day).

  ch4_manure_all_noburn

  :   Numeric. Methane (CH4) emissions from manure management systems,
      excluding manure burned for fuel (kg CH4/head/day).

  n2o_manure_pasture_direct

  :   Numeric. Direct nitrous oxide (N2O) emissions from manure
      deposited on pasture (kg N2O/head/day).

  n2o_manure_burned_direct

  :   Numeric. Direct nitrous oxide (N2O) emissions from manure burned
      for fuel (kg N2O/head/day).

  n2o_manure_other_direct

  :   Numeric. Direct nitrous oxide (N2O) emissions from manure
      management systems, excluding emissions from manure deposited on
      pasture and burned for fuel (kg N2O/head/day).

  n2o_manure_all_noburn_direct

  :   Numeric. Direct nitrous oxide (N2O) emissions from manure
      management systems, excluding emissions from manure burned for
      fuel (kg N2O/head/day).

  n2o_manure_pasture_vol

  :   Numeric. Indirect nitrous oxide (N2O) emissions resulting from
      atmospheric deposition of volatilised nitrogen (NH3 and NOx) from
      manure deposited on pasture (kg N2O/head/day).

  n2o_manure_burned_vol

  :   Numeric. Indirect nitrous oxide (N2O) emissions resulting from
      atmospheric deposition of volatilised nitrogen (NH3 and NOx) from
      manure burned for fuel (kg N2O/head/day).

  n2o_manure_other_vol

  :   Numeric. Indirect nitrous oxide (N2O) emissions resulting from
      atmospheric deposition of volatilised nitrogen (NH3 and NOx) from
      manure management systems, excluding manure deposited on pasture
      and manure burned for fuel (kg N2O/head/day).

  n2o_manure_all_noburn_vol

  :   Numeric. Indirect nitrous oxide (N2O) emissions resulting from
      atmospheric deposition of volatilised nitrogen (NH3 and NOx) from
      manure management systems, excluding losses from manure burned for
      fuel (kg N2O/head/day).

  n2o_manure_pasture_leach

  :   Numeric. Indirect nitrous oxide (N2O) emissions resulting from
      leaching and runoff of manure nitrogen from manure deposited on
      pasture (kg N2O/head/day).

  n2o_manure_burned_leach

  :   Numeric. Indirect nitrous oxide (N2O) emissions resulting from
      leaching and runoff of manure nitrogen from manure burned for fuel
      (kg N2O/head/day).

  n2o_manure_other_leach

  :   Numeric. Indirect nitrous oxide (N2O) emissions resulting from
      leaching and runoff of manure nitrogen from manure management
      systems, excluding losses from manure deposited on pasture and
      manure burned for fuel (kg N2O/head/day).

  n2o_manure_all_noburn_leach

  :   Numeric. Indirect nitrous oxide (N2O) emissions resulting from
      leaching and runoff of manure nitrogen from manure management
      systems, excluding losses from manure burned for fuel (kg
      N2O/head/day).

  n2o_manure_pasture_indirect

  :   Numeric. Total indirect nitrous oxide (N2O) emissions from manure
      deposited on pasture. Includes emissions from atmospheric
      deposition of volatilised nitrogen (NH3 and NOx) and from leaching
      and runoff of manure nitrogen (kg N2O/head/day).

  n2o_manure_burned_indirect

  :   Numeric. Total indirect nitrous oxide (N2O) emissions originating
      from manure burned for fuel. Includes emissions from atmospheric
      deposition of volatilised nitrogen (NH3 and NOx) and from leaching
      and runoff of manure nitrogen (kg N2O/head/day).

  n2o_manure_other_indirect

  :   Numeric. Total indirect nitrous oxide (N2O) emissions originating
      from manure management systems, excluding manure deposited on
      pasture and burned for fuel. Includes emissions from atmospheric
      deposition of volatilised nitrogen (NH3 and NOx) and from leaching
      and runoff of manure nitrogen (kg N2O/head/day).

  n2o_manure_pasture_total

  :   Numeric. Total nitrous oxide emissions from manure deposited on
      pasture. Includes direct emissions and indirect emissions from
      volatilisation, leaching, and runoff (kg N2O/head/day).

  n2o_manure_burned_total

  :   Numeric. Total nitrous oxide emissions (N2O) from manure burned
      for fuel. Includes direct emissions and indirect emissions from
      volatilisation, leaching, and runoff (kg N2O/head/day).

  n2o_manure_other_total

  :   Numeric. Total nitrous oxide (N2O) emissions from manure
      management systems, excluding manure deposited on pasture and
      manure burned for fuel. Includes direct emissions and indirect
      emissions from volatilisation, leaching, and runoff (kg
      N2O/head/day).

  ### Feed production emission variables

  co2_ration_fertilizer

  :   Numeric. Diet-level average carbon dioxide (CO2) emission factor
      from fertilizer manufacture in feed production (g CO2/kg DM).

  co2_ration_pesticides

  :   Numeric. Diet-level average carbon dioxide (CO2) emission factor
      from pesticide manufacture in feed production (g CO2/kg DM).

  co2_ration_crop_activities

  :   Numeric. Diet-level average carbon dioxide (CO2) emission factor
      from on-field agricultural activities in feed production (g CO2/kg
      DM).

  co2_ration_luc_nopeat

  :   Numeric. Diet-level average carbon dioxide (CO2) emission factor
      from land-use change (excluding peatland drainage) in feed
      production (g CO2/kg DM).

  co2_ration_luc_peat

  :   Numeric. Diet-level average carbon dioxide (CO2) emission factor
      from peatland drainage in feed production (g CO2/kg DM).

  n2o_ration_fertilizer

  :   Numeric. Diet-level average nitrous oxide (N2O) emission factor
      from fertilizer use in feed production (g N2O/kg DM).

  n2o_ration_manure_applied

  :   Numeric. Diet-level average nitrous oxide (N2O) emission factor
      from manure applied to or deposited on soil in feed production (g
      N2O/kg DM).

  n2o_ration_crop_residues

  :   Numeric. Diet-level average nitrous oxide (N2O) emission factor
      from crop residues decomposition in feed production (g N2O/kg DM).

  ch4_ration_rice

  :   Numeric. Diet-level average methane (CH4) emission factor from
      rice cultivation in feed production (g CH4/kg DM).

  ### Production variables

  milk_production_mass_cohort

  :   Numeric. Total milk production produced over the assessment period
      (kg/cohort/assessment period).

  milk_production_protein_cohort

  :   Numeric. Total milk protein production produced over the
      assessment period (kg protein/cohort/assessment period).

  milk_production_fpcm_cohort

  :   Numeric. Total fat-protein-corrected milk (FPCM) produced over the
      assessment period (kg/cohort/assessment period).

  fibre_production_cohort

  :   Numeric. Total fibre produced over the assessment period by cohort
      (kg/cohort/assessment period).

  meat_production_live_weight_cohort

  :   Numeric. Total meat produced as live weight over the assessment
      period by cohort (kg/cohort/assessment period).

  meat_production_carcass_weight_cohort

  :   Numeric. Total meat as carcass weight (excluding organs, and other
      by-products after dressing) produced over the assessment period by
      cohort (kg/cohort/assessment period).

  meat_production_bone_free_meat_cohort

  :   Numeric. Total bone-free-meat (excluding bones, organs, and other
      by-products after dressing and bone removal) produced over the
      assessment period by cohort (kg/cohort/assessment period).

  meat_production_protein_cohort

  :   Numeric. Total meat protein (excluding bones, organs, and other
      by-products after dressing and bone removal) produced over the
      assessment period by cohort (kg protein/cohort/assessment period).

  ### Allocation variables

  milk_allocation_energy

  :   Numeric. Energy required to produce total milk output by cohort
      (MJ/cohort/assessment period). Non-zero values are applicable only
      to milk-producing species and cohorts (species = CTL, BFL, CML,
      SHP, GTS; cohorts = FA). All other species-cohort combinations are
      assigned a value of 0.

  meat_allocation_energy

  :   Numeric. Energy required by a given sex-age cohort for total meat
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

- herd_level_results:

  A herd-level `data.table`. When `has_herd_structure = FALSE`, the
  output from
  [`run_demographic_herd_module`](https://github.com/un-fao/GLEAM/reference/run_demographic_herd_module.md),
  including:

  growth_rate_herd

  :   Numeric. Annualized growth rate at which the herd reaches steady
      state (fraction).

  When `has_herd_structure = TRUE`, the supplied `herd_level_data` is
  returned unchanged.

- allocation_long:

  A herd-level `data.table` in long format with one row per herd
  \\\times\\ commodity \\\times\\ emission source:

  herd_id

  :   Character. Herd identifier.

  species_short

  :   Character. Species code.

  variable_name

  :   Character. Emission variable name (e.g. `"ch4_enteric"`,
      `"n2o_manure_pasture_direct"`).

  commodity_name

  :   Character. Commodity category: one of `"None"`, `"Milk"`,
      `"Meat"`, `"Fibre"`, `"Work"`, `"Eggs"`.

  commodity_type

  :   Character. `"Edible"` or `"Non-Edible"`.

  allocation_share

  :   Numeric. Allocation share for this commodity-emission combination
      (fraction).

- aggregation_results:

  A named list from
  [`run_aggregation_module`](https://github.com/un-fao/GLEAM/reference/run_aggregation_module.md)
  with elements `results_emissions`, `results_feed`,
  `results_production`, and `results_nitrogen`. These tables summarise
  herd-level emissions, feed intake, production, and nitrogen balance,
  all scaled to the assessment duration.

## Details

The GLEAM package implements the core computational engine of the Global
Livestock Environmental Assessment Model (GLEAM), developed by the Food
and Agriculture Organization of the United Nations (FAO). It provides a
modular workflow for quantifying greenhouse gas emissions from livestock
systems using a Life Cycle Assessment (LCA) approach based on the IPCC
Tier 2 methodology.

The pipeline covers seven species (CTL, BFL, CML, SHP, GTS, PGS). Within
each herd, animals are organised into six sex-age cohorts (FJ, FS, FA,
MJ, MS, MA). These identifiers are used consistently across all modules.

The assessment period is specified in days via `simulation_duration`
(typically 365). Intermediate per-head-per-day variables are carried
through the cohort workflow and scaled to cohort and herd totals in the
final aggregation step.

### Pipeline sequence

1.  If `has_herd_structure = FALSE`, generate herd structure with
    [`run_demographic_herd_module`](https://github.com/un-fao/GLEAM/reference/run_demographic_herd_module.md);
    otherwise use supplied tables directly.

2.  Compute cohort weights
    ([`run_weights_module`](https://github.com/un-fao/GLEAM/reference/run_weights_module.md)).

3.  Summarise ration quality
    ([`run_ration_quality_module`](https://github.com/un-fao/GLEAM/reference/run_ration_quality_module.md))
    and merge into the cohort table.

4.  Compute energy requirements and dry matter intake
    ([`run_metabolic_energy_req_module`](https://github.com/un-fao/GLEAM/reference/run_metabolic_energy_req_module.md)).

5.  Compute enteric CH4
    ([`run_emissions_enteric_module`](https://github.com/un-fao/GLEAM/reference/run_emissions_enteric_module.md)).

6.  Compute nitrogen balance
    ([`run_nitrogen_balance_module`](https://github.com/un-fao/GLEAM/reference/run_nitrogen_balance_module.md)).

7.  Compute manure emissions
    ([`run_emissions_manure_module`](https://github.com/un-fao/GLEAM/reference/run_emissions_manure_module.md)).

8.  Summarise feed production emissions
    ([`run_emissions_ration_module`](https://github.com/un-fao/GLEAM/reference/run_emissions_ration_module.md))
    and merge into the cohort table.

9.  Compute production outputs
    ([`run_production_module`](https://github.com/un-fao/GLEAM/reference/run_production_module.md)).

10. Compute allocation
    ([`run_allocation_module`](https://github.com/un-fao/GLEAM/reference/run_allocation_module.md)).

11. Aggregate to herd-level results and CO2-eq
    ([`run_aggregation_module`](https://github.com/un-fao/GLEAM/reference/run_aggregation_module.md)).

All inputs containing `herd_id` must refer to the same herd set.
Validation blocks variables that are expected to be produced internally.

## See also

[`run_demographic_herd_module`](https://github.com/un-fao/GLEAM/reference/run_demographic_herd_module.md),
[`run_weights_module`](https://github.com/un-fao/GLEAM/reference/run_weights_module.md),
[`run_ration_quality_module`](https://github.com/un-fao/GLEAM/reference/run_ration_quality_module.md),
[`run_metabolic_energy_req_module`](https://github.com/un-fao/GLEAM/reference/run_metabolic_energy_req_module.md),
[`run_emissions_enteric_module`](https://github.com/un-fao/GLEAM/reference/run_emissions_enteric_module.md),
[`run_nitrogen_balance_module`](https://github.com/un-fao/GLEAM/reference/run_nitrogen_balance_module.md),
[`run_emissions_manure_module`](https://github.com/un-fao/GLEAM/reference/run_emissions_manure_module.md),
[`run_emissions_ration_module`](https://github.com/un-fao/GLEAM/reference/run_emissions_ration_module.md),
[`run_production_module`](https://github.com/un-fao/GLEAM/reference/run_production_module.md),
[`run_allocation_module`](https://github.com/un-fao/GLEAM/reference/run_allocation_module.md),
[`run_aggregation_module`](https://github.com/un-fao/GLEAM/reference/run_aggregation_module.md)

## Examples

``` r
# Example 1: You do NOT have herd structure — use cohort input for herd simulation.
# Pipeline runs herd simulation first, then the rest of the pipeline.
# \donttest{
path_run_gleam_examples <- system.file("extdata/run_gleam_examples", package = "gleam")

master_chrt_lvl_no_structure_dt <- data.table::fread(file.path(
  path_run_gleam_examples, "master_chrt_lvl_no_structure_data.csv"
))
master_hrd_lvl_dt <- data.table::fread(
file.path(path_run_gleam_examples, "master_hrd_lvl_data.csv")
)
feed_rations_chrt_dt <- data.table::fread(
file.path(path_run_gleam_examples, "feed_rations_share_chrt.csv")
)
feed_params_dt <- data.table::fread(system.file(
  "extdata/run_gleam_examples/feed_quality.csv",
  package = "gleam"
))
feed_emissions_dt <- data.table::fread(system.file(
  "extdata/run_gleam_examples/feed_emission_factors.csv",
  package = "gleam"
))

manure_management_system_fraction_dt <- data.table::fread(
  file.path(path_run_gleam_examples, "manure_management_system_fraction.csv")
)
manure_management_system_factors_dt <- data.table::fread(
  file.path(path_run_gleam_examples, "manure_management_system_factors.csv")
)

results <- run_gleam(
  has_herd_structure = FALSE,
  cohort_level_data = master_chrt_lvl_no_structure_dt,
  herd_level_data = master_hrd_lvl_dt,
  feed_rations = feed_rations_chrt_dt,
  feed_params = feed_params_dt,
  feed_emissions = feed_emissions_dt,
  manure_management_system_fraction = manure_management_system_fraction_dt,
  manure_management_system_factors = manure_management_system_factors_dt,
  simulation_duration = 365
)
#> 
#> ── 🕒 Running GLEAM pipeline… ──────────────────────────────────────────────────
#> 🕒 Simulating the herd structure, please wait…
#> ✔ Herd simulation complete.
#> 🕒 Calculating cohort weights, please wait…
#> ✔ Cohort weights calculation complete.
#> 🕒 Aggregating ration quality, please wait…
#> ✔ Ration quality aggregation complete.
#> 🕒 Calculating metabolic energy requirements and ration, please wait…
#> ✔ Metabolic energy requirements calculation complete.
#> 🕒 Calculating enteric methane emissions, please wait…
#> ✔ Enteric methane emissions calculation complete.
#> 🕒 Calculating nitrogen balance, please wait…
#> ✔ Nitrogen balance calculation complete.
#> 🕒 Calculating emissions from manure management systems…
#> ✔ Emissions from manure management calculation complete.
#> 🕒 Aggregating feed emissions, please wait…
#> ✔ Feed emissions aggregation complete.
#> 🕒 Calculating production (milk, fibre, meat), please wait…
#> ✔ Production cohort calculations completed.
#> 🕒 Computing allocation shares, please wait…
#> ✔ Allocation calculation complete.
#> 🕒 Aggregating results, please wait…
#> ✔ Aggregation complete.
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ GLEAM pipeline complete.
print(results$cohort_level_results)
#> Key: <herd_id, species_short, cohort_short>
#>     herd_id species_short cohort_short cohort_duration_days offtake_rate
#>       <int>        <char>       <char>                <int>        <num>
#>  1:       1           CTL           FA                  989        0.000
#>  2:       1           CTL           FJ                   60        0.247
#>  3:       1           CTL           FS                  710        0.247
#>  4:       1           CTL           MA                  823        0.000
#>  5:       1           CTL           MJ                   60        0.949
#>  6:       1           CTL           MS                  710        0.949
#>  7:       2           CTL           FA                 5000        0.000
#>  8:       2           CTL           FJ                   60        0.661
#>  9:       2           CTL           FS                 1400        0.661
#> 10:       2           CTL           MA                 1820        0.000
#> 11:       2           CTL           MJ                   60        0.783
#> 12:       2           CTL           MS                 1400        0.783
#> 13:       3           SHP           FA                 1110        0.000
#> 14:       3           SHP           FJ                   60        0.453
#> 15:       3           SHP           FS                  448        0.453
#> 16:       3           SHP           MA                 2090        0.000
#> 17:       3           SHP           MJ                   60        0.913
#> 18:       3           SHP           MS                  448        0.913
#> 19:       4           SHP           FA                 2430        0.000
#> 20:       4           SHP           FJ                   60        0.543
#> 21:       4           SHP           FS                  669        0.543
#> 22:       4           SHP           MA                 2680        0.000
#> 23:       4           SHP           MJ                   60        0.836
#> 24:       4           SHP           MS                  669        0.836
#> 25:       5           GTS           FA                 2230        0.000
#> 26:       5           GTS           FJ                   60        0.737
#> 27:       5           GTS           FS                  415        0.737
#> 28:       5           GTS           MA                 1540        0.000
#> 29:       5           GTS           MJ                   60        0.974
#> 30:       5           GTS           MS                  415        0.974
#> 31:       6           GTS           FA                 2110        0.000
#> 32:       6           GTS           FJ                   60        0.359
#> 33:       6           GTS           FS                  564        0.359
#> 34:       6           GTS           MA                 2600        0.000
#> 35:       6           GTS           MJ                   60        0.644
#> 36:       6           GTS           MS                  600        0.644
#> 37:       7           BFL           FA                 3650        0.000
#> 38:       7           BFL           FJ                   60        0.664
#> 39:       7           BFL           FS                  974        0.664
#> 40:       7           BFL           MA                 1170        0.000
#> 41:       7           BFL           MJ                   60        0.906
#> 42:       7           BFL           MS                  974        0.906
#> 43:       8           BFL           FA                 1830        0.000
#> 44:       8           BFL           FJ                   60        0.134
#> 45:       8           BFL           FS                 1400        0.134
#> 46:       8           BFL           MA                 2430        0.000
#> 47:       8           BFL           MJ                   60        0.862
#> 48:       8           BFL           MS                 1400        0.862
#> 49:       9           PGS           FA                  890        0.000
#> 50:       9           PGS           FJ                   27        0.948
#> 51:       9           PGS           FS                  359        0.948
#> 52:       9           PGS           MA                  890        0.000
#> 53:       9           PGS           MJ                   27        0.973
#> 54:       9           PGS           MS                  359        0.973
#> 55:      10           PGS           FA                 3650        0.000
#> 56:      10           PGS           FJ                   90        0.952
#> 57:      10           PGS           FS                  340        0.952
#> 58:      10           PGS           MA                 3650        0.000
#> 59:      10           PGS           MJ                   90        0.974
#> 60:      10           PGS           MS                  340        0.974
#> 61:      11           CML           FA                 5000        0.000
#> 62:      11           CML           FJ                  370        0.000
#> 63:      11           CML           FS                 2190        0.000
#> 64:      11           CML           MA                 5000        0.004
#> 65:      11           CML           MJ                  370        0.000
#> 66:      11           CML           MS                 2190        0.496
#> 67:      12           CML           FA                 5000        0.000
#> 68:      12           CML           FJ                  365        0.000
#> 69:      12           CML           FS                 1280        0.000
#> 70:      12           CML           MA                 5000        0.004
#> 71:      12           CML           MJ                  365        0.000
#> 72:      12           CML           MS                 1280        0.500
#>     herd_id species_short cohort_short cohort_duration_days offtake_rate
#>       <int>        <char>       <char>                <int>        <num>
#>     death_rate high_activity_fraction low_activity_fraction cohort_stock_size
#>          <num>                  <num>                 <num>             <num>
#>  1:     0.0310               0.000036              1.66e-06      1.240094e+07
#>  2:     0.0670               0.000036              1.66e-06      7.023271e+05
#>  3:     0.0310               0.000036              1.66e-06      6.905753e+06
#>  4:     0.0310               0.000036              1.66e-06      1.225347e+03
#>  5:     0.0670               0.000036              1.66e-06      2.370447e+05
#>  6:     0.0310               0.000036              1.66e-06      5.271326e+04
#>  7:     0.0500               0.600000              4.65e-02      7.014573e+03
#>  8:     0.0700               0.600000              4.65e-02      2.328332e+02
#>  9:     0.0500               0.600000              4.65e-02      6.625667e+02
#> 10:     0.0500               0.600000              4.65e-02      1.612192e+03
#> 11:     0.0700               0.600000              4.65e-02      1.935859e+02
#> 12:     0.0500               0.600000              4.65e-02      2.842486e+02
#> 13:     0.0650               0.226000              1.33e-01      2.785519e+06
#> 14:     0.1710               0.226000              1.33e-01      1.476204e+05
#> 15:     0.0650               0.226000              1.33e-01      5.876920e+05
#> 16:     0.0650               0.226000              1.33e-01      1.958993e+06
#> 17:     0.1710               0.226000              1.33e-01      6.309694e+04
#> 18:     0.0650               0.226000              1.33e-01      1.707810e+04
#> 19:     0.0309               0.478000              2.18e-02      4.545825e+06
#> 20:     0.1010               0.478000              2.18e-02      1.838593e+05
#> 21:     0.0309               0.478000              2.18e-02      7.156782e+05
#> 22:     0.0309               0.478000              2.18e-02      2.303766e+06
#> 23:     0.1010               0.478000              2.18e-02      1.185504e+05
#> 24:     0.0309               0.478000              2.18e-02      1.123206e+05
#> 25:     0.0200               0.245000              1.09e-01      9.432571e+05
#> 26:     0.0500               0.245000              1.09e-01      3.447891e+04
#> 27:     0.0200               0.245000              1.09e-01      5.826126e+04
#> 28:     0.0200               0.245000              1.09e-01      2.872073e+05
#> 29:     0.0500               0.245000              1.09e-01      1.532746e+04
#> 30:     0.0200               0.245000              1.09e-01      1.467928e+03
#> 31:     0.1270               0.000000              7.50e-01      1.136264e+05
#> 32:     0.3300               0.000000              7.50e-01      9.482460e+03
#> 33:     0.1270               0.000000              7.50e-01      3.857459e+04
#> 34:     0.1270               0.000000              7.50e-01      2.016955e+04
#> 35:     0.3300               0.000000              7.50e-01      6.912891e+03
#> 36:     0.1270               0.000000              7.50e-01      1.123412e+04
#> 37:     0.0400               0.018900              1.11e-02      2.650601e+05
#> 38:     0.0800               0.018900              1.11e-02      1.018474e+04
#> 39:     0.0400               0.018900              1.11e-02      2.805708e+04
#> 40:     0.0400               0.018900              1.11e-02      2.165653e+04
#> 41:     0.0800               0.018900              1.11e-02      6.149071e+03
#> 42:     0.0400               0.018900              1.11e-02      2.892509e+03
#> 43:     0.1000               0.043100              1.57e-01      4.416865e+07
#> 44:     0.2400               0.043100              1.57e-01      2.498356e+06
#> 45:     0.1000               0.043100              1.57e-01      4.093659e+07
#> 46:     0.1000               0.043100              1.57e-01      4.598860e+06
#> 47:     0.5300               0.043100              1.57e-01      5.665933e+05
#> 48:     0.1000               0.043100              1.57e-01      3.095179e+04
#> 49:     0.0603               0.000000              0.00e+00      1.022903e+07
#> 50:     0.1300               0.000000              0.00e+00      3.152269e+06
#> 51:     0.0509               0.000000              0.00e+00      9.588819e+05
#> 52:     0.0603               0.000000              0.00e+00      9.347594e+06
#> 53:     0.1300               0.000000              0.00e+00      2.286055e+06
#> 54:     0.0516               0.000000              0.00e+00      1.261730e+05
#> 55:     0.0200               0.000000              2.00e-01      9.468841e+05
#> 56:     0.2200               0.000000              2.00e-01      2.414018e+05
#> 57:     0.0310               0.000000              2.00e-01      5.670844e+03
#> 58:     0.0200               0.000000              2.00e-01      9.117222e+05
#> 59:     0.2200               0.000000              2.00e-01      1.442343e+05
#> 60:     0.0305               0.000000              2.00e-01      8.669005e+01
#> 61:     0.0630               0.000000              1.00e+00      3.028327e+06
#> 62:     0.2800               0.000000              1.00e+00      5.567416e+05
#> 63:     0.0300               0.000000              1.00e+00      2.402478e+06
#> 64:     0.0630               0.000000              1.00e+00      4.708059e+04
#> 65:     0.2800               0.000000              1.00e+00      5.567416e+05
#> 66:     0.0300               0.000000              1.00e+00      6.186313e+05
#> 67:     0.0600               0.000000              0.00e+00      1.488909e+05
#> 68:     0.2000               0.000000              0.00e+00      5.093173e+04
#> 69:     0.0300               0.000000              0.00e+00      1.138641e+05
#> 70:     0.0600               0.000000              0.00e+00      1.460977e+04
#> 71:     0.2000               0.000000              0.00e+00      5.093173e+04
#> 72:     0.0300               0.000000              0.00e+00      5.077177e+04
#>     death_rate high_activity_fraction low_activity_fraction cohort_stock_size
#>          <num>                  <num>                 <num>             <num>
#>     offtake_heads offtake_heads_assessment live_weight_mature_stage
#>             <num>                    <num>                    <num>
#>  1:  4.015397e+06             4.015397e+06                    680.0
#>  2:  1.149662e+06             1.149662e+06                    680.0
#>  3:  1.824891e+06             1.824891e+06                    680.0
#>  4:  4.801632e+02             4.801632e+02                    916.0
#>  5:  4.346241e+06             4.346241e+06                    916.0
#>  6:  1.514360e+05             1.514360e+05                    916.0
#>  7:  3.359382e+02             3.359382e+02                    350.0
#>  8:  1.523096e+03             1.523096e+03                    350.0
#>  9:  7.072882e+02             7.072882e+02                    350.0
#> 10:  2.539230e+02             2.539230e+02                    450.0
#> 11:  1.801334e+03             1.801334e+03                    450.0
#> 12:  4.316695e+02             4.316695e+02                    450.0
#> 13:  7.288965e+05             7.288965e+05                     51.0
#> 14:  5.326455e+05             5.326455e+05                     51.0
#> 15:  3.259743e+05             3.259743e+05                     51.0
#> 16:  2.531053e+05             2.531053e+05                     59.0
#> 17:  1.056444e+06             1.056444e+06                     59.0
#> 18:  4.026396e+04             4.026396e+04                     59.0
#> 19:  5.757908e+05             5.757908e+05                     60.1
#> 20:  8.741053e+05             8.741053e+05                     60.1
#> 21:  5.359769e+05             5.359769e+05                     60.1
#> 22:  2.591738e+05             2.591738e+05                     70.3
#> 23:  1.339239e+06             1.339239e+06                     70.3
#> 24:  1.960767e+05             1.960767e+05                     70.3
#> 25:  1.346210e+05             1.346210e+05                     70.0
#> 26:  2.679635e+05             2.679635e+05                     70.0
#> 27:  7.328718e+04             7.328718e+04                     70.0
#> 28:  5.779800e+04             5.779800e+04                    110.0
#> 29:  3.515418e+05             3.515418e+05                    110.0
#> 30:  5.215234e+03             5.215234e+03                    110.0
#> 31:  1.220205e+04             1.220205e+04                     51.0
#> 32:  3.012785e+04             3.012785e+04                     51.0
#> 33:  1.748756e+04             1.748756e+04                     51.0
#> 34:  1.582635e+03             1.582635e+03                     75.2
#> 35:  5.386447e+04             5.386447e+04                     75.2
#> 36:  1.205651e+04             1.205651e+04                     75.2
#> 37:  2.026641e+04             2.026641e+04                    600.0
#> 38:  6.719274e+04             6.719274e+04                    600.0
#> 39:  2.973843e+04             2.973843e+04                    600.0
#> 40:  5.381888e+03             5.381888e+03                    800.0
#> 41:  9.128747e+04             9.128747e+04                    800.0
#> 42:  6.791890e+03             6.791890e+03                    800.0
#> 43:  6.316267e+06             6.316267e+06                    478.0
#> 44:  2.369657e+06             2.369657e+06                    478.0
#> 45:  5.874583e+06             5.874583e+06                    478.0
#> 46:  4.301470e+05             4.301470e+05                    500.0
#> 47:  1.506559e+07             1.506559e+07                    500.0
#> 48:  6.487573e+04             6.487573e+04                    500.0
#> 49:  3.158829e+06             3.158829e+06                    225.0
#> 50:  1.249115e+08             1.249115e+08                    225.0
#> 51:  2.565339e+06             2.565339e+06                    225.0
#> 52:  2.871834e+06             2.871834e+06                    265.0
#> 53:  1.279131e+08             1.279131e+08                    265.0
#> 54:  4.325333e+05             4.325333e+05                    265.0
#> 55:  8.093874e+04             8.093874e+04                     64.0
#> 56:  4.804328e+06             4.804328e+06                     64.0
#> 57:  1.848447e+04             1.848447e+04                     64.0
#> 58:  7.790147e+04             7.790147e+04                     71.0
#> 59:  4.905532e+06             4.905532e+06                     71.0
#> 60:  3.474927e+02             3.474927e+02                     71.0
#> 61:  1.376734e+05             1.376734e+05                    352.0
#> 62:  0.000000e+00             0.000000e+00                    352.0
#> 63:  0.000000e+00             0.000000e+00                    352.0
#> 64:  2.266325e+03             2.266325e+03                    382.0
#> 65:  0.000000e+00             0.000000e+00                    382.0
#> 66:  4.339350e+05             4.339350e+05                    382.0
#> 67:  7.255222e+03             7.255222e+03                    537.0
#> 68:  0.000000e+00             0.000000e+00                    537.0
#> 69:  0.000000e+00             0.000000e+00                    537.0
#> 70:  7.524338e+02             7.524338e+02                    572.0
#> 71:  0.000000e+00             0.000000e+00                    572.0
#> 72:  3.766352e+04             3.766352e+04                    572.0
#>     offtake_heads offtake_heads_assessment live_weight_mature_stage
#>             <num>                    <num>                    <num>
#>     live_weight_cohort_initial live_weight_cohort_potential_final
#>                          <num>                              <num>
#>  1:                     680.00                              680.0
#>  2:                      41.00                              250.0
#>  3:                     250.00                              680.0
#>  4:                     916.00                              916.0
#>  5:                      41.00                              250.0
#>  6:                     250.00                              916.0
#>  7:                     350.00                              350.0
#>  8:                      14.00                              220.0
#>  9:                     220.00                              350.0
#> 10:                     450.00                              450.0
#> 11:                      14.00                              220.0
#> 12:                     220.00                              450.0
#> 13:                      51.00                               51.0
#> 14:                       4.19                               30.0
#> 15:                      30.00                               51.0
#> 16:                      59.00                               59.0
#> 17:                       4.19                               30.0
#> 18:                      30.00                               59.0
#> 19:                      60.10                               60.1
#> 20:                       5.21                               35.0
#> 21:                      35.00                               60.1
#> 22:                      70.30                               70.3
#> 23:                       5.21                               35.0
#> 24:                      35.00                               70.3
#> 25:                      70.00                               70.0
#> 26:                       3.50                               15.0
#> 27:                      15.00                               70.0
#> 28:                     110.00                              110.0
#> 29:                       3.50                               15.0
#> 30:                      15.00                              110.0
#> 31:                      51.00                               51.0
#> 32:                       3.30                               14.0
#> 33:                      14.00                               51.0
#> 34:                      75.20                               75.2
#> 35:                       3.30                               14.0
#> 36:                      14.00                               75.2
#> 37:                     600.00                              600.0
#> 38:                      38.00                              130.0
#> 39:                     130.00                              600.0
#> 40:                     800.00                              800.0
#> 41:                      38.00                              130.0
#> 42:                     130.00                              800.0
#> 43:                     478.00                              478.0
#> 44:                      32.60                              110.0
#> 45:                     110.00                              478.0
#> 46:                     500.00                              500.0
#> 47:                      32.60                              110.0
#> 48:                     110.00                              500.0
#> 49:                     225.00                              225.0
#> 50:                       1.20                                7.0
#> 51:                       7.00                              225.0
#> 52:                     265.00                              265.0
#> 53:                       1.20                                7.0
#> 54:                       7.00                              265.0
#> 55:                      64.00                               64.0
#> 56:                       1.00                                6.0
#> 57:                       6.00                               64.0
#> 58:                      71.00                               71.0
#> 59:                       1.00                                6.0
#> 60:                       6.00                               71.0
#> 61:                     352.00                              352.0
#> 62:                      28.70                              120.0
#> 63:                     120.00                              352.0
#> 64:                     382.00                              382.0
#> 65:                      28.70                              120.0
#> 66:                     120.00                              382.0
#> 67:                     537.00                              537.0
#> 68:                      32.70                              150.0
#> 69:                     150.00                              537.0
#> 70:                     572.00                              572.0
#> 71:                      32.70                              150.0
#> 72:                     150.00                              572.0
#>     live_weight_cohort_initial live_weight_cohort_potential_final
#>                          <num>                              <num>
#>     live_weight_cohort_at_slaughter live_weight_cohort_average
#>                               <num>                      <num>
#>  1:                           680.0                  680.00000
#>  2:                           250.0                  145.50000
#>  3:                           557.0                  449.80950
#>  4:                           916.0                  916.00000
#>  5:                           250.0                  145.50000
#>  6:                           605.0                  435.43050
#>  7:                           350.0                  350.00000
#>  8:                           220.0                  117.00000
#>  9:                           250.0                  251.95000
#> 10:                           450.0                  450.00000
#> 11:                           220.0                  117.00000
#> 12:                           250.0                  256.70000
#> 13:                            51.0                   51.00000
#> 14:                            30.0                   17.09500
#> 15:                            35.0                   36.87600
#> 16:                            59.0                   59.00000
#> 17:                            30.0                   17.09500
#> 18:                            35.0                   33.54400
#> 19:                            60.1                   60.10000
#> 20:                            35.0                   20.10500
#> 21:                            51.8                   45.29655
#> 22:                            70.3                   70.30000
#> 23:                            35.0                   20.10500
#> 24:                            55.9                   46.63080
#> 25:                            70.0                   70.00000
#> 26:                            15.0                    9.25000
#> 27:                            25.0                   25.91750
#> 28:                           110.0                  110.00000
#> 29:                            15.0                    9.25000
#> 30:                            25.0                   21.10500
#> 31:                            51.0                   51.00000
#> 32:                            14.0                    8.65000
#> 33:                            29.0                   28.55100
#> 34:                            75.2                   75.20000
#> 35:                            14.0                    8.65000
#> 36:                            29.0                   29.72360
#> 37:                           600.0                  600.00000
#> 38:                           130.0                   84.00000
#> 39:                           420.0                  305.24000
#> 40:                           800.0                  800.00000
#> 41:                           130.0                   84.00000
#> 42:                           420.0                  292.86000
#> 43:                           478.0                  478.00000
#> 44:                           110.0                   71.30000
#> 45:                           110.0                  269.34400
#> 46:                           500.0                  500.00000
#> 47:                           110.0                   71.30000
#> 48:                           110.0                  136.91000
#> 49:                           225.0                  225.00000
#> 50:                             7.0                    4.10000
#> 51:                           122.0                   67.17800
#> 52:                           265.0                  265.00000
#> 53:                             7.0                    4.10000
#> 54:                           122.0                   66.43050
#> 55:                            64.0                   64.00000
#> 56:                             6.0                    3.50000
#> 57:                            60.0                   33.09600
#> 58:                            71.0                   71.00000
#> 59:                             6.0                    3.50000
#> 60:                            60.0                   33.14300
#> 61:                           352.0                  352.00000
#> 62:                           120.0                   74.35000
#> 63:                           352.0                  236.00000
#> 64:                           382.0                  382.00000
#> 65:                           120.0                   74.35000
#> 66:                           382.0                  251.00000
#> 67:                           537.0                  537.00000
#> 68:                           150.0                   91.35000
#> 69:                           537.0                  343.50000
#> 70:                           572.0                  572.00000
#> 71:                           150.0                   91.35000
#> 72:                           572.0                  361.00000
#>     live_weight_cohort_at_slaughter live_weight_cohort_average
#>                               <num>                      <num>
#>     live_weight_cohort_final daily_weight_gain ration_gross_energy
#>                        <num>             <num>               <num>
#>  1:                 680.0000        0.00000000              18.788
#>  2:                 250.0000        3.48333333              21.900
#>  3:                 649.6190        0.60563380              18.788
#>  4:                 916.0000        0.00000000              18.788
#>  5:                 250.0000        3.48333333              21.900
#>  6:                 620.8610        0.93802817              18.788
#>  7:                 350.0000        0.00000000              17.850
#>  8:                 220.0000        3.43333333              21.900
#>  9:                 283.9000        0.09285714              17.850
#> 10:                 450.0000        0.00000000              17.850
#> 11:                 220.0000        3.43333333              21.900
#> 12:                 293.4000        0.16428571              17.850
#> 13:                  51.0000        0.00000000              18.214
#> 14:                  30.0000        0.43016667              20.400
#> 15:                  43.7520        0.04687500              18.214
#> 16:                  59.0000        0.00000000              18.214
#> 17:                  30.0000        0.43016667              20.400
#> 18:                  37.0880        0.06473214              18.214
#> 19:                  60.1000        0.00000000              17.929
#> 20:                  35.0000        0.49650000              20.400
#> 21:                  55.5931        0.03751868              17.929
#> 22:                  70.3000        0.00000000              17.929
#> 23:                  35.0000        0.49650000              20.400
#> 24:                  58.2616        0.05276532              17.929
#> 25:                  70.0000        0.00000000              18.358
#> 26:                  15.0000        0.19166667              21.900
#> 27:                  36.8350        0.13253012              18.358
#> 28:                 110.0000        0.00000000              18.358
#> 29:                  15.0000        0.19166667              21.900
#> 30:                  27.2100        0.22891566              18.358
#> 31:                  51.0000        0.00000000              17.850
#> 32:                  14.0000        0.17833333              21.900
#> 33:                  43.1020        0.06560284              17.850
#> 34:                  75.2000        0.00000000              17.850
#> 35:                  14.0000        0.17833333              21.900
#> 36:                  45.4472        0.10200000              17.850
#> 37:                 600.0000        0.00000000              18.888
#> 38:                 130.0000        1.53333333              24.300
#> 39:                 480.4800        0.48254620              18.888
#> 40:                 800.0000        0.00000000              18.888
#> 41:                 130.0000        1.53333333              24.300
#> 42:                 455.7200        0.68788501              18.888
#> 43:                 478.0000        0.00000000              18.245
#> 44:                 110.0000        1.29000000              24.300
#> 45:                 428.6880        0.26285714              18.245
#> 46:                 500.0000        0.00000000              18.245
#> 47:                 110.0000        1.29000000              24.300
#> 48:                 163.8200        0.27857143              18.245
#> 49:                 225.0000        0.00000000              18.857
#> 50:                   7.0000        0.21481481              25.800
#> 51:                 127.3560        0.60724234              18.857
#> 52:                 265.0000        0.00000000              18.857
#> 53:                   7.0000        0.21481481              25.800
#> 54:                 125.8610        0.71866295              18.857
#> 55:                  64.0000        0.00000000              18.236
#> 56:                   6.0000        0.05555556              25.800
#> 57:                  60.1920        0.17058824              18.236
#> 58:                  71.0000        0.00000000              18.236
#> 59:                   6.0000        0.05555556              25.800
#> 60:                  60.2860        0.19117647              18.236
#> 61:                 352.0000        0.00000000              18.140
#> 62:                 120.0000        0.24675676              22.200
#> 63:                 352.0000        0.10593607              18.140
#> 64:                 382.0000        0.00000000              18.140
#> 65:                 120.0000        0.24675676              22.200
#> 66:                 382.0000        0.11963470              18.140
#> 67:                 537.0000        0.00000000              18.116
#> 68:                 150.0000        0.32136986              22.200
#> 69:                 537.0000        0.30234375              18.116
#> 70:                 572.0000        0.00000000              18.116
#> 71:                 150.0000        0.32136986              22.200
#> 72:                 572.0000        0.32968750              18.116
#>     live_weight_cohort_final daily_weight_gain ration_gross_energy
#>                        <num>             <num>               <num>
#>     ration_metabolizable_energy ration_nitrogen ration_digestibility_fraction
#>                           <num>           <num>                         <num>
#>  1:                     10.9430       0.0210060                     0.7095322
#>  2:                     20.4000       0.0411000                     0.9726027
#>  3:                     10.9430       0.0210060                     0.7095322
#>  4:                     10.9430       0.0210060                     0.7095322
#>  5:                     20.4000       0.0411000                     0.9726027
#>  6:                     10.9430       0.0210060                     0.7095322
#>  7:                      8.1062       0.0164160                     0.5721907
#>  8:                     20.4000       0.0411000                     0.9726027
#>  9:                      8.1062       0.0164160                     0.5721907
#> 10:                      8.1062       0.0164160                     0.5721907
#> 11:                     20.4000       0.0411000                     0.9726027
#> 12:                      8.1062       0.0164160                     0.5721907
#> 13:                      9.4792       0.0200758                     0.6428824
#> 14:                     19.0000       0.0486000                     0.9705882
#> 15:                      9.4792       0.0200758                     0.6428824
#> 16:                      9.4792       0.0200758                     0.6428824
#> 17:                     19.0000       0.0486000                     0.9705882
#> 18:                      9.4792       0.0200758                     0.6428824
#> 19:                      8.0304       0.0168610                     0.5634958
#> 20:                     19.0000       0.0486000                     0.9705882
#> 21:                      8.0304       0.0168610                     0.5634958
#> 22:                      8.0304       0.0168610                     0.5634958
#> 23:                     19.0000       0.0486000                     0.9705882
#> 24:                      8.0304       0.0168610                     0.5634958
#> 25:                     10.1050       0.0269400                     0.6849606
#> 26:                     20.4000       0.0411000                     0.9726027
#> 27:                     10.1050       0.0269400                     0.6849606
#> 28:                     10.1050       0.0269400                     0.6849606
#> 29:                     20.4000       0.0411000                     0.9726027
#> 30:                     10.1050       0.0269400                     0.6849606
#> 31:                      7.9100       0.0156500                     0.5580566
#> 32:                     20.4000       0.0411000                     0.9726027
#> 33:                      7.9100       0.0156500                     0.5580566
#> 34:                      7.9100       0.0156500                     0.5580566
#> 35:                     20.4000       0.0411000                     0.9726027
#> 36:                      7.9100       0.0156500                     0.5580566
#> 37:                     10.5940       0.0205852                     0.6843249
#> 38:                     22.6000       0.0445000                     0.9711934
#> 39:                     10.5940       0.0205852                     0.6843249
#> 40:                     10.5940       0.0205852                     0.6843249
#> 41:                     22.6000       0.0445000                     0.9711934
#> 42:                     10.5940       0.0205852                     0.6843249
#> 43:                      7.9301       0.0144556                     0.5362405
#> 44:                     22.6000       0.0445000                     0.9711934
#> 45:                      7.9301       0.0144556                     0.5362405
#> 46:                      7.9301       0.0144556                     0.5362405
#> 47:                     22.6000       0.0445000                     0.9711934
#> 48:                      7.9301       0.0144556                     0.5362405
#> 49:                     14.1850       0.0349430                     0.7902968
#> 50:                     24.1000       0.0468000                     0.9728682
#> 51:                     14.1850       0.0349430                     0.7902968
#> 52:                     14.1850       0.0349430                     0.7902968
#> 53:                     24.1000       0.0468000                     0.9728682
#> 54:                     14.1850       0.0349430                     0.7902968
#> 55:                      9.2350       0.0234152                     0.5495364
#> 56:                     24.1000       0.0468000                     0.9728682
#> 57:                      9.2350       0.0234152                     0.5495364
#> 58:                      9.2350       0.0234152                     0.5495364
#> 59:                     24.1000       0.0468000                     0.9728682
#> 60:                      9.2350       0.0234152                     0.5495364
#> 61:                      8.8456       0.0217400                     0.6131448
#> 62:                     20.7000       0.0400000                     0.9729730
#> 63:                      8.8456       0.0217400                     0.6131448
#> 64:                      8.8456       0.0217400                     0.6131448
#> 65:                     20.7000       0.0400000                     0.9729730
#> 66:                      8.8456       0.0217400                     0.6131448
#> 67:                      8.6922       0.0176120                     0.5968941
#> 68:                     20.7000       0.0400000                     0.9729730
#> 69:                      8.6922       0.0176120                     0.5968941
#> 70:                      8.6922       0.0176120                     0.5968941
#> 71:                     20.7000       0.0400000                     0.9729730
#> 72:                      8.6922       0.0176120                     0.5968941
#>     ration_metabolizable_energy ration_nitrogen ration_digestibility_fraction
#>                           <num>           <num>                         <num>
#>     ration_urinary_energy_fraction ration_ash metabolic_energy_req_maintenance
#>                              <num>      <num>                            <num>
#>  1:                       0.128390       0.04                        46.287258
#>  2:                       0.041100       0.04                        13.489726
#>  3:                       0.128390       0.04                        31.450484
#>  4:                       0.128390       0.04                        61.606045
#>  5:                       0.041100       0.04                        13.489726
#>  6:                       0.128390       0.04                        30.926747
#>  7:                       0.118280       0.04                        26.055950
#>  8:                       0.041100       0.04                        11.455005
#>  9:                       0.118280       0.04                        20.362994
#> 10:                       0.118280       0.04                        36.150234
#> 11:                       0.041100       0.04                        11.455005
#> 12:                       0.118280       0.04                        21.318239
#> 13:                       0.122634       0.04                         4.141306
#> 14:                       0.039200       0.04                         1.984101
#> 15:                       0.122634       0.04                         3.451551
#> 16:                       0.122634       0.04                         5.312471
#> 17:                       0.039200       0.04                         2.009994
#> 18:                       0.122634       0.04                         3.256855
#> 19:                       0.116220       0.04                         4.683986
#> 20:                       0.039200       0.04                         2.240733
#> 21:                       0.116220       0.04                         3.954959
#> 22:                       0.116220       0.04                         6.058625
#> 23:                       0.039200       0.04                         2.295855
#> 24:                       0.116220       0.04                         4.141448
#> 25:                       0.136150       0.04                         7.623143
#> 26:                       0.041100       0.04                         1.670771
#> 27:                       0.136150       0.04                         3.618307
#> 28:                       0.136150       0.04                        10.699293
#> 29:                       0.041100       0.04                         1.670771
#> 30:                       0.136150       0.04                         3.101698
#> 31:                       0.115000       0.04                         6.011574
#> 32:                       0.041100       0.04                         1.588812
#> 33:                       0.115000       0.04                         3.890689
#> 34:                       0.115000       0.04                         8.044035
#> 35:                       0.041100       0.04                         1.588812
#> 36:                       0.115000       0.04                         4.009928
#> 37:                       0.124646       0.04                        41.751932
#> 38:                       0.041200       0.04                         8.934399
#> 39:                       0.124646       0.04                        23.514565
#> 40:                       0.124646       0.04                        55.656926
#> 41:                       0.041200       0.04                         8.934399
#> 42:                       0.124646       0.04                        23.115016
#> 43:                       0.103938       0.04                        35.207409
#> 44:                       0.041200       0.04                         7.900835
#> 45:                       0.103938       0.04                        21.408505
#> 46:                       0.103938       0.04                        39.122737
#> 47:                       0.041200       0.04                         7.900835
#> 48:                       0.103938       0.04                        13.153025
#> 49:                       0.034718       0.04                        25.765022
#> 50:                       0.038800       0.04                         1.277855
#> 51:                       0.034718       0.04                        10.406721
#> 52:                       0.034718       0.04                        29.129165
#> 53:                       0.038800       0.04                         1.277855
#> 54:                       0.034718       0.04                        10.319752
#> 55:                       0.046149       0.04                        10.035259
#> 56:                       0.038800       0.04                         1.134866
#> 57:                       0.046149       0.04                         6.119631
#> 58:                       0.046149       0.04                        10.847693
#> 59:                       0.038800       0.04                         1.134866
#> 60:                       0.046149       0.04                         6.126148
#> 61:                       0.127710       0.04                        35.350556
#> 62:                       0.040500       0.04                        11.014125
#> 63:                       0.127710       0.04                        26.192277
#> 64:                       0.127710       0.04                        37.586923
#> 65:                       0.040500       0.04                        11.014125
#> 66:                       0.127710       0.04                        27.431184
#> 67:                       0.117380       0.04                        48.525495
#> 68:                       0.040500       0.04                        12.853478
#> 69:                       0.117380       0.04                        34.708378
#> 70:                       0.117380       0.04                        50.878732
#> 71:                       0.040500       0.04                        12.853478
#> 72:                       0.117380       0.04                        36.026300
#>     ration_urinary_energy_fraction ration_ash metabolic_energy_req_maintenance
#>                              <num>      <num>                            <num>
#>     metabolic_energy_req_activity metabolic_energy_req_growth
#>                             <num>                       <num>
#>  1:                  0.0006129451                   0.0000000
#>  2:                  0.0001786336                  32.1983739
#>  3:                  0.0004164736                  11.0147361
#>  4:                  0.0008157996                   0.0000000
#>  5:                  0.0001786336                  21.6175258
#>  6:                  0.0004095382                  11.6627279
#>  7:                  5.8340573879                   0.0000000
#>  8:                  2.5648328054                  44.2862193
#>  9:                  4.5593762810                   1.5001268
#> 10:                  8.0942180800                   0.0000000
#> 11:                  2.5648328054                  30.0531238
#> 12:                  4.7732602371                   1.9304217
#> 13:                  0.3492021000                   0.0000000
#> 14:                  0.1170511745                   4.2125146
#> 15:                  0.2524936596                   0.5738452
#> 16:                  0.4039789000                   0.0000000
#> 17:                  0.1170511745                   4.1940037
#> 18:                  0.2296791224                   0.2382126
#> 19:                  0.7034861260                   0.0000000
#> 20:                  0.2353342523                   5.5346096
#> 21:                  0.5302078949                   0.6920835
#> 22:                  0.8228797780                   0.0000000
#> 23:                  0.2353342523                   5.2732851
#> 24:                  0.5458256380                   0.6689772
#> 25:                  0.5565700000                   0.0000000
#> 26:                  0.0735467500                   1.5433958
#> 27:                  0.2060700425                   0.7130719
#> 28:                  0.8746100000                   0.0000000
#> 29:                  0.0735467500                   1.5433958
#> 30:                  0.1678058550                   0.3520202
#> 31:                  0.7267500000                   0.0000000
#> 32:                  0.1232625000                   1.4007192
#> 33:                  0.4068517500                   0.7441562
#> 34:                  1.0716000000                   0.0000000
#> 35:                  0.1232625000                   1.4007192
#> 36:                  0.4235613000                   0.7761582
#> 37:                  0.3628660444                   0.0000000
#> 38:                  0.0776488604                   9.5222412
#> 39:                  0.2043650874                   7.0503332
#> 40:                  0.4837143419                   0.0000000
#> 41:                  0.0776488604                   6.4015613
#> 42:                  0.2008926005                   6.7792718
#> 43:                  1.4859639036                   0.0000000
#> 44:                  0.3334626627                   8.2615771
#> 45:                  0.9035673831                   3.9092368
#> 46:                  1.6512142272                   0.0000000
#> 47:                  0.3334626627                   6.6199666
#> 48:                  0.5551365857                   2.0097569
#> 49:                  0.0000000000                   0.0000000
#> 50:                  0.0000000000                   5.2731667
#> 51:                  0.0000000000                  14.9062813
#> 52:                  0.0000000000                   0.0000000
#> 53:                  0.0000000000                   5.2731667
#> 54:                  0.0000000000                  17.6413788
#> 55:                  0.2508814860                   0.0000000
#> 56:                  0.0283716547                   1.3637500
#> 57:                  0.1529907817                   4.1875147
#> 58:                  0.2711923250                   0.0000000
#> 59:                  0.0283716547                   1.3637500
#> 60:                  0.1531537008                   4.6929044
#> 61:                  3.5350556465                   0.0000000
#> 62:                  1.1014124635                  10.1663784
#> 63:                  2.6192277250                   4.3645662
#> 64:                  3.7586923421                   0.0000000
#> 65:                  1.1014124635                  10.1663784
#> 66:                  2.7431183671                   4.9289498
#> 67:                  0.0000000000                   0.0000000
#> 68:                  0.0000000000                  13.2404384
#> 69:                  0.0000000000                  12.4565625
#> 70:                  0.0000000000                   0.0000000
#> 71:                  0.0000000000                  13.2404384
#> 72:                  0.0000000000                  13.5831250
#>     metabolic_energy_req_activity metabolic_energy_req_growth
#>                             <num>                       <num>
#>     metabolic_energy_req_lactation metabolic_energy_req_work
#>                              <num>                     <num>
#>  1:                     39.6787123                 0.0000000
#>  2:                      0.0000000                 0.0000000
#>  3:                      0.0000000                 0.0000000
#>  4:                      0.0000000                 0.0000000
#>  5:                      0.0000000                 0.0000000
#>  6:                      0.0000000                 0.0000000
#>  7:                      2.8373819                 0.0000000
#>  8:                      0.0000000                 0.0000000
#>  9:                      0.0000000                 0.0000000
#> 10:                      0.0000000                 0.7953051
#> 11:                      0.0000000                 0.0000000
#> 12:                      0.0000000                 0.0000000
#> 13:                      1.8050967                 0.0000000
#> 14:                      0.0000000                 0.0000000
#> 15:                      0.0000000                 0.0000000
#> 16:                      0.0000000                 0.0000000
#> 17:                      0.0000000                 0.0000000
#> 18:                      0.0000000                 0.0000000
#> 19:                      1.3984977                 0.0000000
#> 20:                      0.0000000                 0.0000000
#> 21:                      0.0000000                 0.0000000
#> 22:                      0.0000000                 0.0000000
#> 23:                      0.0000000                 0.0000000
#> 24:                      0.0000000                 0.0000000
#> 25:                      1.5935342                 0.0000000
#> 26:                      0.0000000                 0.0000000
#> 27:                      0.0000000                 0.0000000
#> 28:                      0.0000000                 0.0000000
#> 29:                      0.0000000                 0.0000000
#> 30:                      0.0000000                 0.0000000
#> 31:                      0.6802562                 0.0000000
#> 32:                      0.0000000                 0.0000000
#> 33:                      0.0000000                 0.0000000
#> 34:                      0.0000000                 0.0000000
#> 35:                      0.0000000                 0.0000000
#> 36:                      0.0000000                 0.0000000
#> 37:                      8.6751646                 0.0000000
#> 38:                      0.0000000                 0.0000000
#> 39:                      0.0000000                 0.0000000
#> 40:                      0.0000000                 0.0000000
#> 41:                      0.0000000                 0.0000000
#> 42:                      0.0000000                 0.0000000
#> 43:                     11.4940320                 0.0000000
#> 44:                      0.0000000                 0.0000000
#> 45:                      0.0000000                 0.0000000
#> 46:                      0.0000000                 1.7214004
#> 47:                      0.0000000                 0.0000000
#> 48:                      0.0000000                 0.0000000
#> 49:                      8.4025534                 0.0000000
#> 50:                      0.0000000                 0.0000000
#> 51:                      0.0000000                 0.0000000
#> 52:                      0.0000000                 0.0000000
#> 53:                      0.0000000                 0.0000000
#> 54:                      0.0000000                 0.0000000
#> 55:                      1.4307671                 0.0000000
#> 56:                      0.0000000                 0.0000000
#> 57:                      0.0000000                 0.0000000
#> 58:                      0.0000000                 0.0000000
#> 59:                      0.0000000                 0.0000000
#> 60:                      0.0000000                 0.0000000
#> 61:                      7.2678721                 0.0000000
#> 62:                      0.0000000                 0.0000000
#> 63:                      0.0000000                 0.0000000
#> 64:                      0.0000000                 0.8000000
#> 65:                      0.0000000                 0.0000000
#> 66:                      0.0000000                 0.0000000
#> 67:                     17.2664699                 0.0000000
#> 68:                      0.0000000                 0.0000000
#> 69:                      0.0000000                 0.0000000
#> 70:                      0.0000000                 0.8000000
#> 71:                      0.0000000                 0.0000000
#> 72:                      0.0000000                 0.0000000
#>     metabolic_energy_req_lactation metabolic_energy_req_work
#>                              <num>                     <num>
#>     metabolic_energy_req_fibre_production metabolic_energy_req_pregnancy
#>                                     <num>                          <num>
#>  1:                            0.00000000                     2.87107813
#>  2:                            0.00000000                     0.00000000
#>  3:                            0.00000000                     0.94395307
#>  4:                            0.00000000                     0.00000000
#>  5:                            0.00000000                     0.00000000
#>  6:                            0.00000000                     0.00000000
#>  7:                            0.00000000                     1.38183624
#>  8:                            0.00000000                     0.00000000
#>  9:                            0.00000000                     0.13954033
#> 10:                            0.00000000                     0.00000000
#> 11:                            0.00000000                     0.00000000
#> 12:                            0.00000000                     0.00000000
#> 13:                            0.09863014                     0.12349852
#> 14:                            0.00000000                     0.00000000
#> 15:                            0.09863014                     0.04932396
#> 16:                            0.09863014                     0.00000000
#> 17:                            0.00000000                     0.00000000
#> 18:                            0.09863014                     0.00000000
#> 19:                            0.16438356                     0.11189568
#> 20:                            0.00000000                     0.00000000
#> 21:                            0.16438356                     0.03162033
#> 22:                            0.16438356                     0.00000000
#> 23:                            0.00000000                     0.00000000
#> 24:                            0.16438356                     0.00000000
#> 25:                            0.11835616                     0.19780490
#> 26:                            0.00000000                     0.00000000
#> 27:                            0.11835616                     0.02648470
#> 28:                            0.11835616                     0.00000000
#> 29:                            0.00000000                     0.00000000
#> 30:                            0.11835616                     0.00000000
#> 31:                            0.04931507                     0.25022064
#> 32:                            0.00000000                     0.00000000
#> 33:                            0.04931507                     0.05107254
#> 34:                            0.04931507                     0.00000000
#> 35:                            0.00000000                     0.00000000
#> 36:                            0.04931507                     0.00000000
#> 37:                            0.00000000                     2.83684363
#> 38:                            0.00000000                     0.00000000
#> 39:                            0.00000000                     0.25146582
#> 40:                            0.00000000                     0.00000000
#> 41:                            0.00000000                     0.00000000
#> 42:                            0.00000000                     0.00000000
#> 43:                            0.00000000                     2.49683228
#> 44:                            0.00000000                     0.00000000
#> 45:                            0.00000000                     0.41052338
#> 46:                            0.00000000                     0.00000000
#> 47:                            0.00000000                     0.00000000
#> 48:                            0.00000000                     0.00000000
#> 49:                            0.00000000                     1.48558190
#> 50:                            0.00000000                     0.00000000
#> 51:                            0.00000000                     0.03369747
#> 52:                            0.00000000                     0.00000000
#> 53:                            0.00000000                     0.00000000
#> 54:                            0.00000000                     0.00000000
#> 55:                            0.00000000                     0.52907566
#> 56:                            0.00000000                     0.00000000
#> 57:                            0.00000000                     0.01703001
#> 58:                            0.00000000                     0.00000000
#> 59:                            0.00000000                     0.00000000
#> 60:                            0.00000000                     0.00000000
#> 61:                            0.15291494                     1.82408871
#> 62:                            0.00000000                     0.00000000
#> 63:                            0.15291494                     0.55972538
#> 64:                            0.15291494                     0.00000000
#> 65:                            0.00000000                     0.00000000
#> 66:                            0.15291494                     0.00000000
#> 67:                            0.15291494                     4.83313927
#> 68:                            0.00000000                     0.00000000
#> 69:                            0.15291494                     1.26902505
#> 70:                            0.15291494                     0.00000000
#> 71:                            0.00000000                     0.00000000
#> 72:                            0.15291494                     0.00000000
#>     metabolic_energy_req_fibre_production metabolic_energy_req_pregnancy
#>                                     <num>                          <num>
#>     net_energy_maintenance_digestible_energy_ratio
#>                                              <num>
#>  1:                                      0.5313640
#>  2:                                      0.5703707
#>  3:                                      0.5313640
#>  4:                                      0.5313640
#>  5:                                      0.5703707
#>  6:                                      0.5313640
#>  7:                                      0.4818171
#>  8:                                      0.5703707
#>  9:                                      0.4818171
#> 10:                                      0.4818171
#> 11:                                      0.5703707
#> 12:                                      0.4818171
#> 13:                                      0.5113743
#> 14:                                      0.5702122
#> 15:                                      0.5113743
#> 16:                                      0.5113743
#> 17:                                      0.5702122
#> 18:                                      0.5113743
#> 19:                                      0.4774136
#> 20:                                      0.5702122
#> 21:                                      0.4774136
#> 22:                                      0.4774136
#> 23:                                      0.5702122
#> 24:                                      0.4774136
#> 25:                                      0.5247185
#> 26:                                      0.5703707
#> 27:                                      0.5247185
#> 28:                                      0.5247185
#> 29:                                      0.5703707
#> 30:                                      0.5247185
#> 31:                                      0.4745590
#> 32:                                      0.5703707
#> 33:                                      0.4745590
#> 34:                                      0.4745590
#> 35:                                      0.5703707
#> 36:                                      0.4745590
#> 37:                                      0.5245362
#> 38:                                      0.5702600
#> 39:                                      0.5245362
#> 40:                                      0.5245362
#> 41:                                      0.5702600
#> 42:                                      0.5245362
#> 43:                                      0.4622809
#> 44:                                      0.5702600
#> 45:                                      0.4622809
#> 46:                                      0.4622809
#> 47:                                      0.5702600
#> 48:                                      0.4622809
#> 49:                                             NA
#> 50:                                             NA
#> 51:                                             NA
#> 52:                                             NA
#> 53:                                             NA
#> 54:                                             NA
#> 55:                                             NA
#> 56:                                             NA
#> 57:                                             NA
#> 58:                                             NA
#> 59:                                             NA
#> 60:                                             NA
#> 61:                                             NA
#> 62:                                             NA
#> 63:                                             NA
#> 64:                                             NA
#> 65:                                             NA
#> 66:                                             NA
#> 67:                                             NA
#> 68:                                             NA
#> 69:                                             NA
#> 70:                                             NA
#> 71:                                             NA
#> 72:                                             NA
#>     net_energy_maintenance_digestible_energy_ratio
#>                                              <num>
#>     net_energy_growth_digestible_energy_ratio metabolic_energy_req_total
#>                                         <num>                      <num>
#>  1:                                 0.3366230                 235.631255
#>  2:                                 0.4013328                 106.805914
#>  3:                                 0.3366230                 132.040173
#>  4:                                 0.3366230                 163.404819
#>  5:                                 0.4013328                  79.698986
#>  6:                                 0.3366230                 130.860305
#>  7:                                 0.2579456                 130.977044
#>  8:                                 0.4013328                 138.728872
#>  9:                                 0.2579456                 101.069589
#> 10:                                 0.2579456                 163.370281
#> 11:                                 0.4013328                 102.265302
#> 12:                                 0.2579456                 107.719552
#> 13:                                 0.3045771                  20.029290
#> 14:                                 0.4010622                  14.618203
#> 15:                                 0.3045771                  14.851340
#> 16:                                 0.3045771                  17.891964
#> 17:                                 0.4010622                  14.617434
#> 18:                                 0.3045771                  12.325590
#> 19:                                 0.2510549                  26.802645
#> 20:                                 0.4010622                  18.692005
#> 21:                                 0.2510549                  22.843874
#> 22:                                 0.2510549                  26.741829
#> 23:                                 0.4010622                  18.120278
#> 24:                                 0.2510549                  23.314269
#> 25:                                 0.3259111                  28.272900
#> 26:                                 0.4013328                   7.098369
#> 27:                                 0.3259111                  14.438782
#> 28:                                 0.3259111                  32.732552
#> 29:                                 0.4013328                   7.098369
#> 30:                                 0.3259111                  11.203905
#> 31:                                 0.2465946                  29.315720
#> 32:                                 0.4013328                   6.674726
#> 33:                                 0.2465946                  22.186279
#> 34:                                 0.2465946                  34.778960
#> 35:                                 0.4013328                   6.674726
#> 36:                                 0.2465946                  22.739320
#> 37:                                 0.3256180                 149.397791
#> 38:                                 0.4011437                  40.713963
#> 39:                                 0.3256180                  98.418797
#> 40:                                 0.3256180                 156.401027
#> 41:                                 0.4011437                  32.703761
#> 42:                                 0.3256180                  95.379015
#> 43:                                 0.2274637                 204.459533
#> 44:                                 0.4011437                  36.073770
#> 45:                                 0.2274637                 123.712077
#> 46:                                 0.2274637                 171.425678
#> 47:                                 0.4011437                  31.860062
#> 48:                                 0.2274637                  71.775302
#> 49:                                        NA                  35.653157
#> 50:                                        NA                   6.551021
#> 51:                                        NA                  25.346700
#> 52:                                        NA                  29.129165
#> 53:                                        NA                   6.551021
#> 54:                                        NA                  27.961131
#> 55:                                        NA                  12.245984
#> 56:                                        NA                   2.526988
#> 57:                                        NA                  10.477167
#> 58:                                        NA                  11.118885
#> 59:                                        NA                   2.526988
#> 60:                                        NA                  10.972206
#> 61:                                        NA                  48.130488
#> 62:                                        NA                  22.281915
#> 63:                                        NA                  33.888712
#> 64:                                        NA                  42.298531
#> 65:                                        NA                  22.281915
#> 66:                                        NA                  35.256167
#> 67:                                        NA                  70.778019
#> 68:                                        NA                  26.093917
#> 69:                                        NA                  48.586880
#> 70:                                        NA                  51.831647
#> 71:                                        NA                  26.093917
#> 72:                                        NA                  49.762340
#>     net_energy_growth_digestible_energy_ratio metabolic_energy_req_total
#>                                         <num>                      <num>
#>     ration_intake ch4_mitigation_factor ch4_conversion_factor_ym ch4_enteric
#>             <num>                 <num>                    <num>       <num>
#>  1:    12.5415826                     1                 6.202339 0.262617234
#>  2:     4.8769824                     1                 0.000000 0.000000000
#>  3:     7.0278994                     1                 6.202339 0.147162248
#>  4:     8.6972972                     1                 6.202339 0.182118970
#>  5:     3.6392231                     1                 0.000000 0.000000000
#>  6:     6.9651003                     1                 6.202339 0.145847253
#>  7:     7.3376495                     1                 6.889047 0.162139616
#>  8:     6.3346517                     1                 0.000000 0.000000000
#>  9:     5.6621619                     1                 6.889047 0.125116462
#> 10:     9.1523967                     1                 6.889047 0.202239978
#> 11:     4.6696485                     1                 0.000000 0.000000000
#> 12:     6.0347088                     1                 6.889047 0.133348610
#> 13:     1.0996646                     1                 6.535588 0.023522585
#> 14:     0.7165786                     1                 0.000000 0.000000000
#> 15:     0.8153805                     1                 4.535588 0.012104143
#> 16:     0.9823193                     1                 6.535588 0.021012489
#> 17:     0.7165409                     1                 0.000000 0.000000000
#> 18:     0.6767097                     1                 4.535588 0.010045606
#> 19:     1.4949325                     1                 6.932521 0.033389020
#> 20:     0.9162748                     1                 0.000000 0.000000000
#> 21:     1.2741298                     1                 4.932521 0.020247598
#> 22:     1.4915405                     1                 6.932521 0.033313259
#> 23:     0.8882489                     1                 0.000000 0.000000000
#> 24:     1.3003664                     1                 4.932521 0.020664532
#> 25:     1.5400861                     1                 6.325197 0.032135069
#> 26:     0.3241264                     1                 0.000000 0.000000000
#> 27:     0.7865117                     1                 4.325197 0.011222026
#> 28:     1.7830130                     1                 6.325197 0.037203924
#> 29:     0.3241264                     1                 0.000000 0.000000000
#> 30:     0.6103009                     1                 4.325197 0.008707834
#> 31:     1.6423373                     1                 6.959717 0.036662913
#> 32:     0.3047820                     1                 0.000000 0.000000000
#> 33:     1.2429288                     1                 4.959717 0.019773165
#> 34:     1.9484011                     1                 6.959717 0.043495366
#> 35:     0.3047820                     1                 0.000000 0.000000000
#> 36:     1.2739115                     1                 4.959717 0.020266054
#> 37:     7.9096670                     1                 6.328376 0.169891346
#> 38:     1.6754717                     1                 0.000000 0.000000000
#> 39:     5.2106521                     1                 6.328376 0.111919339
#> 40:     8.2804440                     1                 6.328376 0.177855247
#> 41:     1.3458338                     1                 0.000000 0.000000000
#> 42:     5.0497149                     1                 6.328376 0.108462576
#> 43:    11.2063323                     1                 7.068798 0.259709441
#> 44:     1.4845173                     1                 0.000000 0.000000000
#> 45:     6.7806016                     1                 7.068798 0.157142070
#> 46:     9.3957620                     1                 7.068798 0.217749039
#> 47:     1.3111137                     1                 0.000000 0.000000000
#> 48:     3.9339711                     1                 7.068798 0.091170723
#> 49:     2.5134407                     1                 1.010000 0.008601961
#> 50:     0.2718266                     1                 0.000000 0.000000000
#> 51:     1.7868664                     1                 0.390000 0.002361370
#> 52:     2.0535188                     1                 1.010000 0.007027931
#> 53:     0.2718266                     1                 0.000000 0.000000000
#> 54:     1.9711760                     1                 0.390000 0.002604938
#> 55:     1.3260405                     1                 1.010000 0.004388767
#> 56:     0.1048543                     1                 0.000000 0.000000000
#> 57:     1.1345064                     1                 0.390000 0.001449893
#> 58:     1.2039941                     1                 1.010000 0.003984833
#> 59:     0.1048543                     1                 0.000000 0.000000000
#> 60:     1.1881111                     1                 0.390000 0.001518400
#> 61:     5.4411784                     1                 6.684276 0.118554889
#> 62:     1.0764210                     1                 0.000000 0.000000000
#> 63:     3.8311377                     1                 4.684276 0.058498182
#> 64:     4.7818724                     1                 6.684276 0.104189628
#> 65:     1.0764210                     1                 0.000000 0.000000000
#> 66:     3.9857293                     1                 4.684276 0.060858662
#> 67:     8.1427048                     1                 6.765529 0.179336060
#> 68:     1.2605757                     1                 0.000000 0.000000000
#> 69:     5.5897103                     1                 4.765529 0.086715674
#> 70:     5.9630067                     1                 6.765529 0.131330086
#> 71:     1.2605757                     1                 0.000000 0.000000000
#> 72:     5.7249419                     1                 4.765529 0.088813581
#>     ration_intake ch4_mitigation_factor ch4_conversion_factor_ym ch4_enteric
#>             <num>                 <num>                    <num>       <num>
#>     nitrogen_intake nitrogen_retention nitrogen_excretion volatile_solids
#>               <num>              <num>              <num>           <num>
#>  1:      0.26344849       0.1383840000        0.125064485      5.04301398
#>  2:      0.20044398       0.1135566667        0.086887309      0.32069753
#>  3:      0.14762805       0.0197436620        0.127884392      2.82594276
#>  4:      0.18269542       0.0000000000        0.182695424      3.49721342
#>  5:      0.14957207       0.1135566667        0.036015403      0.23930574
#>  6:      0.14630890       0.0305797183        0.115729179      2.80069105
#>  7:      0.12045485       0.0000000000        0.120454855      3.84673157
#>  8:      0.26035419       0.1119266667        0.148427519      0.41655004
#>  9:      0.09295005       0.0030271429        0.089922906      2.96836428
#> 10:      0.15024574       0.0000000000        0.150245744      4.79810504
#> 11:      0.19192255       0.1119266667        0.079995887      0.30706380
#> 12:      0.09906578       0.0053557143        0.093710066      3.16367044
#> 13:      0.02207665       0.0025180449        0.019558601      0.50646315
#> 14:      0.03482572       0.0111843333        0.023641386      0.04719909
#> 15:      0.01636942       0.0017694349        0.014599981      0.37553286
#> 16:      0.01972085       0.0005506849        0.019170161      0.45241844
#> 17:      0.03482389       0.0111843333        0.023639555      0.04719661
#> 18:      0.01358549       0.0022337206        0.011351767      0.31166642
#> 19:      0.02520606       0.0009178082        0.024288249      0.79323391
#> 20:      0.04453095       0.0129090000        0.031621953      0.06035254
#> 21:      0.02148310       0.0018932940        0.019589809      0.67607266
#> 22:      0.02514886       0.0009178082        0.024231055      0.79143404
#> 23:      0.04316890       0.0129090000        0.030259897      0.05850655
#> 24:      0.02192548       0.0022897066        0.019635771      0.68999418
#> 25:      0.04148992       0.0079504219        0.033539497      0.66707566
#> 26:      0.01332160       0.0049833333        0.008338262      0.02131370
#> 27:      0.02118863       0.0041066051        0.017082021      0.34067111
#> 28:      0.04803437       0.0006608219        0.047373547      0.77229744
#> 29:      0.01332160       0.0049833333        0.008338262      0.02131370
#> 30:      0.01644151       0.0066126291        0.009828878      0.26434685
#> 31:      0.02570258       0.0002753425        0.025427236      0.87810131
#> 32:      0.01252654       0.0046366667        0.007889874      0.02004166
#> 33:      0.01945184       0.0019810162        0.017470819      0.66455132
#> 34:      0.03049248       0.0002753425        0.030217135      1.04174313
#> 35:      0.01252654       0.0046366667        0.007889874      0.02004166
#> 36:      0.01993671       0.0029273425        0.017009372      0.68111670
#> 37:      0.16282208       0.0172979200        0.145524158      3.34348177
#> 38:      0.07455849       0.0499866667        0.024571825      0.11260229
#> 39:      0.10726232       0.0157310062        0.091531310      2.20258581
#> 40:      0.17045460       0.0000000000        0.170454596      3.50021228
#> 41:      0.05988960       0.0499866667        0.009902936      0.09044854
#> 42:      0.10394939       0.0224250513        0.081524340      2.13455632
#> 43:      0.16199426       0.0285040000        0.133490257      6.10733458
#> 44:      0.06606102       0.0420540000        0.024007018      0.09976894
#> 45:      0.09801766       0.0085691429        0.089448522      3.69535738
#> 46:      0.13582138       0.0000000000        0.135821377      5.12059259
#> 47:      0.05834456       0.0420540000        0.016290558      0.08811513
#> 48:      0.05686791       0.0090814286        0.047786484      2.14397332
#> 49:      0.08782716       0.0153361812        0.072490979      0.58976477
#> 50:      0.01272149       0.0053703704        0.007351115      0.01720513
#> 51:      0.06243847       0.0156220503        0.046816423      0.41927818
#> 52:      0.07175611       0.0000000000        0.071756108      0.48184667
#> 53:      0.01272149       0.0053703704        0.007351115      0.01720513
#> 54:      0.06887880       0.0179665738        0.050912228      0.46252538
#> 55:      0.03104950       0.0046810176        0.026368485      0.63218727
#> 56:      0.00490718       0.0013888889        0.003518291      0.00663670
#> 57:      0.02656469       0.0044659064        0.022098788      0.54087378
#> 58:      0.02819176       0.0000000000        0.028191762      0.57400189
#> 59:      0.00490718       0.0013888889        0.003518291      0.00663670
#> 60:      0.02781986       0.0047794118        0.023040448      0.56642972
#> 61:      0.11829122       0.0237191233        0.094572096      2.68784762
#> 62:      0.04305684       0.0064156757        0.036641166      0.06978001
#> 63:      0.08328893       0.0031214612        0.080167472      1.89251546
#> 64:      0.10395791       0.0003671233        0.103590783      2.36216191
#> 65:      0.04305684       0.0064156757        0.036641166      0.06978001
#> 66:      0.08664975       0.0034776256        0.083172129      1.96888102
#> 67:      0.14340932       0.0547991233        0.088610194      4.06863644
#> 68:      0.05042303       0.0083556164        0.042067411      0.08171801
#> 69:      0.09844598       0.0082280608        0.090217917      2.79299073
#> 70:      0.10502047       0.0003671233        0.104653351      2.97951441
#> 71:      0.05042303       0.0083556164        0.042067411      0.08171801
#> 72:      0.10082768       0.0089389983        0.091888678      2.86056140
#>     nitrogen_intake nitrogen_retention nitrogen_excretion volatile_solids
#>               <num>              <num>              <num>           <num>
#>     ch4_manure_pasture ch4_manure_burned ch4_manure_other ch4_manure_all_noburn
#>                  <num>             <num>            <num>                 <num>
#>  1:       0.000000e+00      0.0000000000     1.575611e-01          1.575611e-01
#>  2:       0.000000e+00      0.0000000000     1.001969e-02          1.001969e-02
#>  3:       0.000000e+00      0.0000000000     8.829217e-02          8.829217e-02
#>  4:       0.000000e+00      0.0000000000     1.092650e-01          1.092650e-01
#>  5:       0.000000e+00      0.0000000000     7.476735e-03          7.476735e-03
#>  6:       0.000000e+00      0.0000000000     8.750322e-02          8.750322e-02
#>  7:       1.380923e-03      0.0033505032     3.015453e-03          4.396376e-03
#>  8:       1.495356e-04      0.0003628151     3.265336e-04          4.760692e-04
#>  9:       1.065601e-03      0.0025854453     2.326901e-03          3.392502e-03
#> 10:       1.722453e-03      0.0041791495     3.761235e-03          5.483687e-03
#> 11:       1.102316e-04      0.0002674526     2.407073e-04          3.509389e-04
#> 12:       1.135713e-03      0.0027555570     2.480001e-03          3.615715e-03
#> 13:       1.212088e-04      0.0000000000     7.092004e-04          8.304091e-04
#> 14:       1.129588e-05      0.0000000000     6.609289e-05          7.738877e-05
#> 15:       8.987403e-05      0.0000000000     5.258587e-04          6.157327e-04
#> 16:       1.082746e-04      0.0000000000     6.335215e-04          7.417961e-04
#> 17:       1.129528e-05      0.0000000000     6.608941e-05          7.738470e-05
#> 18:       7.458925e-05      0.0000000000     4.364265e-04          5.110157e-04
#> 19:       2.372999e-04      0.0000000000     5.181801e-04          7.554799e-04
#> 20:       1.805476e-05      0.0000000000     3.942530e-05          5.748006e-05
#> 21:       2.022505e-04      0.0000000000     4.416445e-04          6.438950e-04
#> 22:       2.367615e-04      0.0000000000     5.170043e-04          7.537657e-04
#> 23:       1.750253e-05      0.0000000000     3.821941e-05          5.572193e-05
#> 24:       2.064152e-04      0.0000000000     4.507387e-04          6.571539e-04
#> 25:       1.596472e-04      0.0000000000     8.849426e-04          1.044590e-03
#> 26:       5.100880e-06      0.0000000000     2.827476e-05          3.337564e-05
#> 27:       8.153077e-05      0.0000000000     4.519343e-04          5.334651e-04
#> 28:       1.848293e-04      0.0000000000     1.024530e-03          1.209359e-03
#> 29:       5.100880e-06      0.0000000000     2.827476e-05          3.337564e-05
#> 30:       6.326455e-05      0.0000000000     3.506825e-04          4.139471e-04
#> 31:       2.626884e-04      0.0000000000     1.529652e-03          1.792341e-03
#> 32:       5.995564e-06      0.0000000000     3.491258e-05          4.090814e-05
#> 33:       1.988039e-04      0.0000000000     1.157648e-03          1.356452e-03
#> 34:       3.116427e-04      0.0000000000     1.814717e-03          2.126359e-03
#> 35:       5.995564e-06      0.0000000000     3.491258e-05          4.090814e-05
#> 36:       2.037595e-04      0.0000000000     1.186505e-03          1.390265e-03
#> 37:       2.000439e-04      0.0000000000     3.292995e-02          3.313000e-02
#> 38:       6.737108e-06      0.0000000000     1.109020e-03          1.115757e-03
#> 39:       1.317829e-04      0.0000000000     2.169327e-02          2.182505e-02
#> 40:       2.094212e-04      0.0000000000     3.447359e-02          3.468301e-02
#> 41:       5.411626e-06      0.0000000000     8.908276e-04          8.962393e-04
#> 42:       1.277126e-04      0.0000000000     2.102325e-02          2.115096e-02
#> 43:       7.308159e-04      0.0081838283     4.910297e-03          5.641113e-03
#> 44:       1.193855e-05      0.0001336904     8.021423e-05          9.215278e-05
#> 45:       4.421939e-04      0.0049517789     2.971067e-03          3.413261e-03
#> 46:       6.127404e-04      0.0068615941     4.116956e-03          4.729697e-03
#> 47:       1.054403e-05      0.0001180743     7.084456e-05          8.138859e-05
#> 48:       2.565521e-04      0.0028729242     1.723755e-03          1.980307e-03
#> 49:       7.057243e-06      0.0000000000     2.096659e-02          2.097365e-02
#> 50:       2.058801e-07      0.0000000000     6.116557e-04          6.118616e-04
#> 51:       5.017167e-06      0.0000000000     1.490566e-02          1.491068e-02
#> 52:       5.765874e-06      0.0000000000     1.713002e-02          1.713579e-02
#> 53:       2.058801e-07      0.0000000000     6.116557e-04          6.118616e-04
#> 54:       5.534671e-06      0.0000000000     1.644313e-02          1.644867e-02
#> 55:       1.891220e-05      0.0000000000     4.337207e-02          4.339098e-02
#> 56:       1.985402e-07      0.0000000000     4.553198e-04          4.555183e-04
#> 57:       1.618051e-05      0.0000000000     3.710738e-02          3.712356e-02
#> 58:       1.717155e-05      0.0000000000     3.938018e-02          3.939735e-02
#> 59:       1.985402e-07      0.0000000000     4.553198e-04          4.555183e-04
#> 60:       1.694503e-05      0.0000000000     3.886068e-02          3.887763e-02
#> 61:       1.238288e-03      0.0000000000     4.008710e-03          5.246998e-03
#> 62:       3.214756e-05      0.0000000000     1.040713e-04          1.362189e-04
#> 63:       8.718794e-04      0.0000000000     2.822535e-03          3.694415e-03
#> 64:       1.088245e-03      0.0000000000     3.522976e-03          4.611220e-03
#> 65:       3.214756e-05      0.0000000000     1.040713e-04          1.362189e-04
#> 66:       9.070609e-04      0.0000000000     2.936429e-03          3.843489e-03
#> 67:       1.217153e-03      0.0000000000     5.724571e-03          6.941724e-03
#> 68:       2.444635e-05      0.0000000000     1.149772e-04          1.394236e-04
#> 69:       8.355371e-04      0.0000000000     3.929738e-03          4.765275e-03
#> 70:       8.913366e-04      0.0000000000     4.192177e-03          5.083513e-03
#> 71:       2.444635e-05      0.0000000000     1.149772e-04          1.394236e-04
#> 72:       8.557512e-04      0.0000000000     4.024810e-03          4.880561e-03
#>     ch4_manure_pasture ch4_manure_burned ch4_manure_other ch4_manure_all_noburn
#>                  <num>             <num>            <num>                 <num>
#>     n2o_manure_pasture_direct n2o_manure_burned_direct n2o_manure_other_direct
#>                         <num>                    <num>                   <num>
#>  1:              0.000000e+00                        0            2.362289e-03
#>  2:              0.000000e+00                        0            1.641177e-03
#>  3:              0.000000e+00                        0            2.415553e-03
#>  4:              0.000000e+00                        0            3.450856e-03
#>  5:              0.000000e+00                        0            6.802795e-04
#>  6:              0.000000e+00                        0            2.185959e-03
#>  7:              2.271434e-04                        0            9.464310e-04
#>  8:              2.798919e-04                        0            1.166216e-03
#>  9:              1.695689e-04                        0            7.065371e-04
#> 10:              2.833205e-04                        0            1.180502e-03
#> 11:              1.508494e-04                        0            6.285391e-04
#> 12:              1.767104e-04                        0            7.362934e-04
#> 13:              3.688193e-05                        0            2.919820e-04
#> 14:              4.458090e-05                        0            3.529321e-04
#> 15:              2.753139e-05                        0            2.179569e-04
#> 16:              3.614945e-05                        0            2.861831e-04
#> 17:              4.457745e-05                        0            3.529048e-04
#> 18:              2.140619e-05                        0            1.694657e-04
#> 19:              5.725087e-05                        0            3.816725e-04
#> 20:              7.453746e-05                        0            4.969164e-04
#> 21:              4.617598e-05                        0            3.078399e-04
#> 22:              5.711606e-05                        0            3.807737e-04
#> 23:              7.132690e-05                        0            4.755127e-04
#> 24:              4.628432e-05                        0            3.085621e-04
#> 25:              6.324591e-05                        0            5.006968e-04
#> 26:              1.572358e-05                        0            1.244783e-04
#> 27:              3.221181e-05                        0            2.550102e-04
#> 28:              8.933297e-05                        0            7.072194e-04
#> 29:              1.572358e-05                        0            1.244783e-04
#> 30:              1.853446e-05                        0            1.467311e-04
#> 31:              5.993563e-05                        0            1.997854e-04
#> 32:              1.859756e-05                        0            6.199186e-05
#> 33:              4.118122e-05                        0            1.372707e-04
#> 34:              7.122610e-05                        0            2.374203e-04
#> 35:              1.859756e-05                        0            6.199186e-05
#> 36:              4.009352e-05                        0            1.336451e-04
#> 37:              4.573616e-05                        0            1.372085e-03
#> 38:              7.722574e-06                        0            2.316772e-04
#> 39:              2.876698e-05                        0            8.630095e-04
#> 40:              5.357144e-05                        0            1.607143e-03
#> 41:              3.112351e-06                        0            9.337054e-05
#> 42:              2.562194e-05                        0            7.686581e-04
#> 43:              8.390816e-05                        0            2.517245e-03
#> 44:              1.509013e-05                        0            4.527038e-04
#> 45:              5.622479e-05                        0            1.686744e-03
#> 46:              8.537344e-05                        0            2.561203e-03
#> 47:              1.023978e-05                        0            3.071934e-04
#> 48:              3.003722e-05                        0            9.011165e-04
#> 49:              1.366973e-05                        0            5.515735e-04
#> 50:              1.386210e-06                        0            5.593359e-05
#> 51:              8.828240e-06                        0            3.562195e-04
#> 52:              1.353115e-05                        0            5.459820e-04
#> 53:              1.386210e-06                        0            5.593359e-05
#> 54:              9.600591e-06                        0            3.873839e-04
#> 55:              1.243086e-05                        0            1.877059e-04
#> 56:              1.658623e-06                        0            2.504520e-05
#> 57:              1.041800e-05                        0            1.573118e-04
#> 58:              1.329040e-05                        0            2.006851e-04
#> 59:              1.658623e-06                        0            2.504520e-05
#> 60:              1.086193e-05                        0            1.640151e-04
#> 61:              3.432967e-04                        0            3.863946e-04
#> 62:              1.330074e-04                        0            1.497053e-04
#> 63:              2.910079e-04                        0            3.275414e-04
#> 64:              3.760345e-04                        0            4.232423e-04
#> 65:              1.330074e-04                        0            1.497053e-04
#> 66:              3.019148e-04                        0            3.398176e-04
#> 67:              2.088669e-04                        0            1.392446e-03
#> 68:              9.915890e-05                        0            6.610593e-04
#> 69:              2.126565e-04                        0            1.417710e-03
#> 70:              2.466829e-04                        0            1.644553e-03
#> 71:              9.915890e-05                        0            6.610593e-04
#> 72:              2.165947e-04                        0            1.443965e-03
#>     n2o_manure_pasture_direct n2o_manure_burned_direct n2o_manure_other_direct
#>                         <num>                    <num>                   <num>
#>     n2o_manure_all_noburn_direct n2o_manure_pasture_vol n2o_manure_burned_vol
#>                            <num>                  <num>                 <num>
#>  1:                 2.362289e-03           0.000000e+00                     0
#>  2:                 1.641177e-03           0.000000e+00                     0
#>  3:                 2.415553e-03           0.000000e+00                     0
#>  4:                 3.450856e-03           0.000000e+00                     0
#>  5:                 6.802795e-04           0.000000e+00                     0
#>  6:                 2.185959e-03           0.000000e+00                     0
#>  7:                 1.173574e-03           1.192503e-04                     0
#>  8:                 1.446108e-03           1.469432e-04                     0
#>  9:                 8.761060e-04           8.902368e-05                     0
#> 10:                 1.463823e-03           1.487433e-04                     0
#> 11:                 7.793885e-04           7.919593e-05                     0
#> 12:                 9.130038e-04           9.277297e-05                     0
#> 13:                 3.288639e-04           1.290868e-05                     0
#> 14:                 3.975130e-04           1.560331e-05                     0
#> 15:                 2.454883e-04           9.635987e-06                     0
#> 16:                 3.223326e-04           1.265231e-05                     0
#> 17:                 3.974822e-04           1.560211e-05                     0
#> 18:                 1.908719e-04           7.492166e-06                     0
#> 19:                 4.389234e-04           2.003781e-05                     0
#> 20:                 5.714539e-04           2.608811e-05                     0
#> 21:                 3.540158e-04           1.616159e-05                     0
#> 22:                 4.378898e-04           1.999062e-05                     0
#> 23:                 5.468396e-04           2.496442e-05                     0
#> 24:                 3.548464e-04           1.619951e-05                     0
#> 25:                 5.639427e-04           2.213607e-05                     0
#> 26:                 1.402019e-04           5.503253e-06                     0
#> 27:                 2.872220e-04           1.127413e-05                     0
#> 28:                 7.965524e-04           3.126654e-05                     0
#> 29:                 1.402019e-04           5.503253e-06                     0
#> 30:                 1.652656e-04           6.487060e-06                     0
#> 31:                 2.597210e-04           2.097747e-05                     0
#> 32:                 8.058942e-05           6.509146e-06                     0
#> 33:                 1.784519e-04           1.441343e-05                     0
#> 34:                 3.086464e-04           2.492914e-05                     0
#> 35:                 8.058942e-05           6.509146e-06                     0
#> 36:                 1.737386e-04           1.403273e-05                     0
#> 37:                 1.417821e-03           2.401149e-05                     0
#> 38:                 2.393998e-04           4.054351e-06                     0
#> 39:                 8.917765e-04           1.510267e-05                     0
#> 40:                 1.660715e-03           2.812501e-05                     0
#> 41:                 9.648289e-05           1.633984e-06                     0
#> 42:                 7.942800e-04           1.345152e-05                     0
#> 43:                 2.601153e-03           4.405178e-05                     0
#> 44:                 4.677939e-04           7.922316e-06                     0
#> 45:                 1.742968e-03           2.951801e-05                     0
#> 46:                 2.646577e-03           4.482105e-05                     0
#> 47:                 3.174332e-04           5.375884e-06                     0
#> 48:                 9.311538e-04           1.576954e-05                     0
#> 49:                 5.652432e-04           6.698166e-06                     0
#> 50:                 5.731980e-05           6.792431e-07                     0
#> 51:                 3.650477e-04           4.325837e-06                     0
#> 52:                 5.595131e-04           6.630264e-06                     0
#> 53:                 5.731980e-05           6.792431e-07                     0
#> 54:                 3.969845e-04           4.704290e-06                     0
#> 55:                 2.001368e-04           6.091120e-06                     0
#> 56:                 2.670383e-05           8.127252e-07                     0
#> 57:                 1.677298e-04           5.104820e-06                     0
#> 58:                 2.139755e-04           6.512297e-06                     0
#> 59:                 2.670383e-05           8.127252e-07                     0
#> 60:                 1.748770e-04           5.322343e-06                     0
#> 61:                 7.296913e-04           1.201538e-04                     0
#> 62:                 2.827128e-04           4.655260e-05                     0
#> 63:                 6.185493e-04           1.018528e-04                     0
#> 64:                 7.992769e-04           1.316121e-04                     0
#> 65:                 2.827128e-04           4.655260e-05                     0
#> 66:                 6.417324e-04           1.056702e-04                     0
#> 67:                 1.601313e-03           7.310341e-05                     0
#> 68:                 7.602182e-04           3.470561e-05                     0
#> 69:                 1.630367e-03           7.442978e-05                     0
#> 70:                 1.891236e-03           8.633901e-05                     0
#> 71:                 7.602182e-04           3.470561e-05                     0
#> 72:                 1.660560e-03           7.580816e-05                     0
#>     n2o_manure_all_noburn_direct n2o_manure_pasture_vol n2o_manure_burned_vol
#>                            <num>                  <num>                 <num>
#>     n2o_manure_other_vol n2o_manure_all_noburn_vol n2o_manure_pasture_leach
#>                    <num>                     <num>                    <num>
#>  1:         3.120895e-04              3.120895e-04             0.000000e+00
#>  2:         2.168211e-04              2.168211e-04             0.000000e+00
#>  3:         3.191264e-04              3.191264e-04             0.000000e+00
#>  4:         4.559034e-04              4.559034e-04             0.000000e+00
#>  5:         8.987387e-05              8.987387e-05             0.000000e+00
#>  6:         2.887939e-04              2.887939e-04             0.000000e+00
#>  7:         9.937526e-05              2.186256e-04             0.000000e+00
#>  8:         1.224527e-04              2.693959e-04             0.000000e+00
#>  9:         7.418640e-05              1.632101e-04             0.000000e+00
#> 10:         1.239527e-04              2.726960e-04             0.000000e+00
#> 11:         6.599661e-05              1.451925e-04             0.000000e+00
#> 12:         7.731080e-05              1.700838e-04             0.000000e+00
#> 13:         2.335856e-05              3.626723e-05             0.000000e+00
#> 14:         2.823457e-05              4.383788e-05             0.000000e+00
#> 15:         1.743655e-05              2.707254e-05             0.000000e+00
#> 16:         2.289465e-05              3.554696e-05             0.000000e+00
#> 17:         2.823238e-05              4.383449e-05             0.000000e+00
#> 18:         1.355725e-05              2.104942e-05             0.000000e+00
#> 19:         2.862544e-05              4.866324e-05             0.000000e+00
#> 20:         3.726873e-05              6.335684e-05             0.000000e+00
#> 21:         2.308799e-05              3.924958e-05             0.000000e+00
#> 22:         2.855803e-05              4.854865e-05             0.000000e+00
#> 23:         3.566345e-05              6.062787e-05             0.000000e+00
#> 24:         2.314216e-05              3.934167e-05             0.000000e+00
#> 25:         4.005574e-05              6.219181e-05             0.000000e+00
#> 26:         9.958268e-06              1.546152e-05             0.000000e+00
#> 27:         2.040081e-05              3.167495e-05             0.000000e+00
#> 28:         5.657755e-05              8.784409e-05             0.000000e+00
#> 29:         9.958268e-06              1.546152e-05             0.000000e+00
#> 30:         1.173849e-05              1.822555e-05             0.000000e+00
#> 31:         1.198713e-05              3.296459e-05             0.000000e+00
#> 32:         3.719512e-06              1.022866e-05             0.000000e+00
#> 33:         8.236243e-06              2.264967e-05             0.000000e+00
#> 34:         1.424522e-05              3.917436e-05             0.000000e+00
#> 35:         3.719512e-06              1.022866e-05             0.000000e+00
#> 36:         8.018704e-06              2.205144e-05             0.000000e+00
#> 37:         4.733693e-04              4.973808e-04             0.000000e+00
#> 38:         7.992864e-05              8.398299e-05             0.000000e+00
#> 39:         2.977383e-04              3.128409e-04             0.000000e+00
#> 40:         5.544645e-04              5.825895e-04             0.000000e+00
#> 41:         3.221284e-05              3.384682e-05             0.000000e+00
#> 42:         2.651870e-04              2.786385e-04             0.000000e+00
#> 43:         1.887934e-04              2.328451e-04             0.000000e+00
#> 44:         3.395278e-05              4.187510e-05             0.000000e+00
#> 45:         1.265058e-04              1.560238e-04             0.000000e+00
#> 46:         1.920902e-04              2.369113e-04             0.000000e+00
#> 47:         2.303950e-05              2.841539e-05             0.000000e+00
#> 48:         6.758374e-05              8.335328e-05             0.000000e+00
#> 49:         6.870883e-04              6.937865e-04             6.014680e-06
#> 50:         6.967578e-05              7.035503e-05             6.099325e-07
#> 51:         4.437382e-04              4.480641e-04             3.884425e-06
#> 52:         6.801231e-04              6.867533e-04             5.953707e-06
#> 53:         6.967578e-05              7.035503e-05             6.099325e-07
#> 54:         4.825593e-04              4.872636e-04             4.224260e-06
#> 55:         1.931465e-04              1.992376e-04             5.469577e-06
#> 56:         2.577113e-05              2.658385e-05             7.297940e-07
#> 57:         1.618714e-04              1.669762e-04             4.583920e-06
#> 58:         2.065018e-04              2.130141e-04             5.847777e-06
#> 59:         2.577113e-05              2.658385e-05             7.297940e-07
#> 60:         1.687690e-04              1.740913e-04             4.779247e-06
#> 61:         2.452119e-05              1.446750e-04             3.021011e-04
#> 62:         9.500531e-06              5.605313e-05             1.170465e-04
#> 63:         2.078628e-05              1.226391e-04             2.560870e-04
#> 64:         2.685961e-05              1.584717e-04             3.309104e-04
#> 65:         9.500531e-06              5.605313e-05             1.170465e-04
#> 66:         2.156534e-05              1.272355e-04             2.656850e-04
#> 67:         1.044334e-04              1.775369e-04             1.838029e-04
#> 68:         4.957945e-05              8.428506e-05             8.725983e-05
#> 69:         1.063283e-04              1.807580e-04             1.871377e-04
#> 70:         1.233414e-04              2.096805e-04             2.170810e-04
#> 71:         4.957945e-05              8.428506e-05             8.725983e-05
#> 72:         1.082974e-04              1.841055e-04             1.906034e-04
#>     n2o_manure_other_vol n2o_manure_all_noburn_vol n2o_manure_pasture_leach
#>                    <num>                     <num>                    <num>
#>     n2o_manure_burned_leach n2o_manure_other_leach n2o_manure_all_noburn_leach
#>                       <num>                  <num>                       <num>
#>  1:                       0           4.972207e-05                4.972207e-05
#>  2:                       0           3.454391e-05                3.454391e-05
#>  3:                       0           5.084318e-05                5.084318e-05
#>  4:                       0           7.263448e-05                7.263448e-05
#>  5:                       0           1.431870e-05                1.431870e-05
#>  6:                       0           4.601061e-05                4.601061e-05
#>  7:                       0           1.873933e-05                1.873933e-05
#>  8:                       0           2.309108e-05                2.309108e-05
#>  9:                       0           1.398943e-05                1.398943e-05
#> 10:                       0           2.337395e-05                2.337395e-05
#> 11:                       0           1.244507e-05                1.244507e-05
#> 12:                       0           1.457861e-05                1.457861e-05
#> 13:                       0           7.437857e-06                7.437857e-06
#> 14:                       0           8.990481e-06                8.990481e-06
#> 15:                       0           5.552164e-06                5.552164e-06
#> 16:                       0           7.290138e-06                7.290138e-06
#> 17:                       0           8.989785e-06                8.989785e-06
#> 18:                       0           4.316915e-06                4.316915e-06
#> 19:                       0           7.347195e-06                7.347195e-06
#> 20:                       0           9.565641e-06                9.565641e-06
#> 21:                       0           5.925917e-06                5.925917e-06
#> 22:                       0           7.329894e-06                7.329894e-06
#> 23:                       0           9.153619e-06                9.153619e-06
#> 24:                       0           5.939821e-06                5.939821e-06
#> 25:                       0           1.275459e-05                1.275459e-05
#> 26:                       0           3.170922e-06                3.170922e-06
#> 27:                       0           6.496049e-06                6.496049e-06
#> 28:                       0           1.801548e-05                1.801548e-05
#> 29:                       0           3.170922e-06                3.170922e-06
#> 30:                       0           3.737782e-06                3.737782e-06
#> 31:                       0           4.395279e-06                4.395279e-06
#> 32:                       0           1.363821e-06                1.363821e-06
#> 33:                       0           3.019956e-06                3.019956e-06
#> 34:                       0           5.223248e-06                5.223248e-06
#> 35:                       0           1.363821e-06                1.363821e-06
#> 36:                       0           2.940191e-06                2.940191e-06
#> 37:                       0           3.018587e-05                3.018587e-05
#> 38:                       0           5.096899e-06                5.096899e-06
#> 39:                       0           1.898621e-05                1.898621e-05
#> 40:                       0           3.535715e-05                3.535715e-05
#> 41:                       0           2.054152e-06                2.054152e-06
#> 42:                       0           1.691048e-05                1.691048e-05
#> 43:                       0           4.845696e-05                4.845696e-05
#> 44:                       0           8.714548e-06                8.714548e-06
#> 45:                       0           3.246981e-05                3.246981e-05
#> 46:                       0           4.930316e-05                4.930316e-05
#> 47:                       0           5.913473e-06                5.913473e-06
#> 48:                       0           1.734649e-05                1.734649e-05
#> 49:                       0           1.365834e-05                1.967302e-05
#> 50:                       0           1.385055e-06                1.994988e-06
#> 51:                       0           8.820883e-06                1.270531e-05
#> 52:                       0           1.351988e-05                1.947358e-05
#> 53:                       0           1.385055e-06                1.994988e-06
#> 54:                       0           9.592591e-06                1.381685e-05
#> 55:                       0           2.962688e-06                8.432265e-06
#> 56:                       0           3.953051e-07                1.125099e-06
#> 57:                       0           2.482957e-06                7.066877e-06
#> 58:                       0           3.167546e-06                9.015323e-06
#> 59:                       0           3.953051e-07                1.125099e-06
#> 60:                       0           2.588759e-06                7.368006e-06
#> 61:                       0           8.255468e-06                3.103566e-04
#> 62:                       0           3.198512e-06                1.202451e-04
#> 63:                       0           6.998048e-06                2.630850e-04
#> 64:                       0           9.042735e-06                3.399531e-04
#> 65:                       0           3.198512e-06                1.202451e-04
#> 66:                       0           7.260333e-06                2.729454e-04
#> 67:                       0           2.680458e-05                2.106074e-04
#> 68:                       0           1.272539e-05                9.998522e-05
#> 69:                       0           2.729092e-05                2.144287e-04
#> 70:                       0           3.165764e-05                2.487386e-04
#> 71:                       0           1.272539e-05                9.998522e-05
#> 72:                       0           2.779633e-05                2.183997e-04
#>     n2o_manure_burned_leach n2o_manure_other_leach n2o_manure_all_noburn_leach
#>                       <num>                  <num>                       <num>
#>     n2o_manure_pasture_indirect n2o_manure_burned_indirect
#>                           <num>                      <num>
#>  1:                0.000000e+00                          0
#>  2:                0.000000e+00                          0
#>  3:                0.000000e+00                          0
#>  4:                0.000000e+00                          0
#>  5:                0.000000e+00                          0
#>  6:                0.000000e+00                          0
#>  7:                1.192503e-04                          0
#>  8:                1.469432e-04                          0
#>  9:                8.902368e-05                          0
#> 10:                1.487433e-04                          0
#> 11:                7.919593e-05                          0
#> 12:                9.277297e-05                          0
#> 13:                1.290868e-05                          0
#> 14:                1.560331e-05                          0
#> 15:                9.635987e-06                          0
#> 16:                1.265231e-05                          0
#> 17:                1.560211e-05                          0
#> 18:                7.492166e-06                          0
#> 19:                2.003781e-05                          0
#> 20:                2.608811e-05                          0
#> 21:                1.616159e-05                          0
#> 22:                1.999062e-05                          0
#> 23:                2.496442e-05                          0
#> 24:                1.619951e-05                          0
#> 25:                2.213607e-05                          0
#> 26:                5.503253e-06                          0
#> 27:                1.127413e-05                          0
#> 28:                3.126654e-05                          0
#> 29:                5.503253e-06                          0
#> 30:                6.487060e-06                          0
#> 31:                2.097747e-05                          0
#> 32:                6.509146e-06                          0
#> 33:                1.441343e-05                          0
#> 34:                2.492914e-05                          0
#> 35:                6.509146e-06                          0
#> 36:                1.403273e-05                          0
#> 37:                2.401149e-05                          0
#> 38:                4.054351e-06                          0
#> 39:                1.510267e-05                          0
#> 40:                2.812501e-05                          0
#> 41:                1.633984e-06                          0
#> 42:                1.345152e-05                          0
#> 43:                4.405178e-05                          0
#> 44:                7.922316e-06                          0
#> 45:                2.951801e-05                          0
#> 46:                4.482105e-05                          0
#> 47:                5.375884e-06                          0
#> 48:                1.576954e-05                          0
#> 49:                1.271285e-05                          0
#> 50:                1.289176e-06                          0
#> 51:                8.210263e-06                          0
#> 52:                1.258397e-05                          0
#> 53:                1.289176e-06                          0
#> 54:                8.928550e-06                          0
#> 55:                1.156070e-05                          0
#> 56:                1.542519e-06                          0
#> 57:                9.688740e-06                          0
#> 58:                1.236007e-05                          0
#> 59:                1.542519e-06                          0
#> 60:                1.010159e-05                          0
#> 61:                4.222550e-04                          0
#> 62:                1.635991e-04                          0
#> 63:                3.579397e-04                          0
#> 64:                4.625225e-04                          0
#> 65:                1.635991e-04                          0
#> 66:                3.713552e-04                          0
#> 67:                2.569063e-04                          0
#> 68:                1.219654e-04                          0
#> 69:                2.615675e-04                          0
#> 70:                3.034200e-04                          0
#> 71:                1.219654e-04                          0
#> 72:                2.664115e-04                          0
#>     n2o_manure_pasture_indirect n2o_manure_burned_indirect
#>                           <num>                      <num>
#>     n2o_manure_other_indirect n2o_manure_pasture_total n2o_manure_burned_total
#>                         <num>                    <num>                   <num>
#>  1:              3.618116e-04             0.000000e+00                       0
#>  2:              2.513650e-04             0.000000e+00                       0
#>  3:              3.699695e-04             0.000000e+00                       0
#>  4:              5.285379e-04             0.000000e+00                       0
#>  5:              1.041926e-04             0.000000e+00                       0
#>  6:              3.348045e-04             0.000000e+00                       0
#>  7:              1.181146e-04             3.463937e-04                       0
#>  8:              1.455438e-04             4.268351e-04                       0
#>  9:              8.817583e-05             2.585926e-04                       0
#> 10:              1.473267e-04             4.320638e-04                       0
#> 11:              7.844168e-05             2.300453e-04                       0
#> 12:              9.188941e-05             2.694834e-04                       0
#> 13:              3.079641e-05             4.979061e-05                       0
#> 14:              3.722505e-05             6.018421e-05                       0
#> 15:              2.298871e-05             3.716738e-05                       0
#> 16:              3.018479e-05             4.880175e-05                       0
#> 17:              3.722217e-05             6.017955e-05                       0
#> 18:              1.787417e-05             2.889836e-05                       0
#> 19:              3.597263e-05             7.728868e-05                       0
#> 20:              4.683437e-05             1.006256e-04                       0
#> 21:              2.901391e-05             6.233757e-05                       0
#> 22:              3.588792e-05             7.710668e-05                       0
#> 23:              4.481707e-05             9.629132e-05                       0
#> 24:              2.908198e-05             6.248383e-05                       0
#> 25:              5.281033e-05             8.538198e-05                       0
#> 26:              1.312919e-05             2.122683e-05                       0
#> 27:              2.689686e-05             4.348594e-05                       0
#> 28:              7.459303e-05             1.205995e-04                       0
#> 29:              1.312919e-05             2.122683e-05                       0
#> 30:              1.547627e-05             2.502152e-05                       0
#> 31:              1.638240e-05             8.091310e-05                       0
#> 32:              5.083333e-06             2.510670e-05                       0
#> 33:              1.125620e-05             5.559464e-05                       0
#> 34:              1.946847e-05             9.615524e-05                       0
#> 35:              5.083333e-06             2.510670e-05                       0
#> 36:              1.095890e-05             5.412625e-05                       0
#> 37:              5.035552e-04             6.974765e-05                       0
#> 38:              8.502554e-05             1.177692e-05                       0
#> 39:              3.167245e-04             4.386965e-05                       0
#> 40:              5.898216e-04             8.169645e-05                       0
#> 41:              3.426699e-05             4.746336e-06                       0
#> 42:              2.820975e-04             3.907345e-05                       0
#> 43:              2.372503e-04             1.279599e-04                       0
#> 44:              4.266733e-05             2.301244e-05                       0
#> 45:              1.589756e-04             8.574280e-05                       0
#> 46:              2.413934e-04             1.301945e-04                       0
#> 47:              2.895298e-05             1.561566e-05                       0
#> 48:              8.493023e-05             4.580676e-05                       0
#> 49:              7.007467e-04             2.638257e-05                       0
#> 50:              7.106084e-05             2.675386e-06                       0
#> 51:              4.525591e-04             1.703850e-05                       0
#> 52:              6.936429e-04             2.611512e-05                       0
#> 53:              7.106084e-05             2.675386e-06                       0
#> 54:              4.921519e-04             1.852914e-05                       0
#> 55:              1.961092e-04             2.399155e-05                       0
#> 56:              2.616643e-05             3.201142e-06                       0
#> 57:              1.643544e-04             2.010674e-05                       0
#> 58:              2.096694e-04             2.565048e-05                       0
#> 59:              2.616643e-05             3.201142e-06                       0
#> 60:              1.713577e-04             2.096352e-05                       0
#> 61:              3.277666e-05             7.655517e-04                       0
#> 62:              1.269904e-05             2.966066e-04                       0
#> 63:              2.778433e-05             6.489477e-04                       0
#> 64:              3.590235e-05             8.385570e-04                       0
#> 65:              1.269904e-05             2.966066e-04                       0
#> 66:              2.882568e-05             6.732701e-04                       0
#> 67:              1.312380e-04             4.657732e-04                       0
#> 68:              6.230484e-05             2.211243e-04                       0
#> 69:              1.336192e-04             4.742240e-04                       0
#> 70:              1.549991e-04             5.501029e-04                       0
#> 71:              6.230484e-05             2.211243e-04                       0
#> 72:              1.360937e-04             4.830063e-04                       0
#>     n2o_manure_other_indirect n2o_manure_pasture_total n2o_manure_burned_total
#>                         <num>                    <num>                   <num>
#>     n2o_manure_other_total co2_ration_fertilizer co2_ration_pesticides
#>                      <num>                 <num>                 <num>
#>  1:           2.724101e-03               33.4710               11.4574
#>  2:           1.892542e-03                0.0000                0.0000
#>  3:           2.785523e-03               33.4710               11.4574
#>  4:           3.979393e-03               33.4710               11.4574
#>  5:           7.844721e-04                0.0000                0.0000
#>  6:           2.520763e-03               33.4710               11.4574
#>  7:           1.064546e-03                0.5440                0.0922
#>  8:           1.311760e-03                0.0000                0.0000
#>  9:           7.947130e-04                0.5440                0.0922
#> 10:           1.327829e-03                0.5440                0.0922
#> 11:           7.069808e-04                0.0000                0.0000
#> 12:           8.281828e-04                0.5440                0.0922
#> 13:           3.227784e-04               16.6353                8.3062
#> 14:           3.901572e-04                0.0000                0.0000
#> 15:           2.409456e-04               16.6353                8.3062
#> 16:           3.163679e-04               16.6353                8.3062
#> 17:           3.901269e-04                0.0000                0.0000
#> 18:           1.873398e-04               16.6353                8.3062
#> 19:           4.176451e-04                7.4240                0.4442
#> 20:           5.437508e-04                0.0000                0.0000
#> 21:           3.368538e-04                7.4240                0.4442
#> 22:           4.166617e-04                7.4240                0.4442
#> 23:           5.203297e-04                0.0000                0.0000
#> 24:           3.376441e-04                7.4240                0.4442
#> 25:           5.535071e-04               22.6363               10.7182
#> 26:           1.376075e-04                0.0000                0.0000
#> 27:           2.819070e-04               22.6363               10.7182
#> 28:           7.818124e-04               22.6363               10.7182
#> 29:           1.376075e-04                0.0000                0.0000
#> 30:           1.622074e-04               22.6363               10.7182
#> 31:           2.161678e-04                0.0000                0.0000
#> 32:           6.707520e-05                0.0000                0.0000
#> 33:           1.485269e-04                0.0000                0.0000
#> 34:           2.568888e-04                0.0000                0.0000
#> 35:           6.707520e-05                0.0000                0.0000
#> 36:           1.446040e-04                0.0000                0.0000
#> 37:           1.875640e-03               24.1376               10.7537
#> 38:           3.167027e-04                0.0000                0.0000
#> 39:           1.179734e-03               24.1376               10.7537
#> 40:           2.196965e-03               24.1376               10.7537
#> 41:           1.276375e-04                0.0000                0.0000
#> 42:           1.050756e-03               24.1376               10.7537
#> 43:           2.754495e-03               22.5590                2.2507
#> 44:           4.953711e-04                0.0000                0.0000
#> 45:           1.845719e-03               22.5590                2.2507
#> 46:           2.802597e-03               22.5590                2.2507
#> 47:           3.361464e-04                0.0000                0.0000
#> 48:           9.860468e-04               22.5590                2.2507
#> 49:           1.252320e-03               38.3230                9.1713
#> 50:           1.269944e-04                0.0000                0.0000
#> 51:           8.087786e-04               38.3230                9.1713
#> 52:           1.239625e-03               38.3230                9.1713
#> 53:           1.269944e-04                0.0000                0.0000
#> 54:           8.795358e-04               38.3230                9.1713
#> 55:           3.838151e-04               24.8210                6.5384
#> 56:           5.121164e-05                0.0000                0.0000
#> 57:           3.216662e-04               24.8210                6.5384
#> 58:           4.103545e-04               24.8210                6.5384
#> 59:           5.121164e-05                0.0000                0.0000
#> 60:           3.353728e-04               24.8210                6.5384
#> 61:           4.191712e-04               32.1360                2.2574
#> 62:           1.624044e-04                0.0000                0.0000
#> 63:           3.553257e-04               32.1360                2.2574
#> 64:           4.591447e-04               32.1360                2.2574
#> 65:           1.624044e-04                0.0000                0.0000
#> 66:           3.686432e-04               32.1360                2.2574
#> 67:           1.523684e-03               27.7760               12.9242
#> 68:           7.233642e-04                0.0000                0.0000
#> 69:           1.551329e-03               27.7760               12.9242
#> 70:           1.799552e-03               27.7760               12.9242
#> 71:           7.233642e-04                0.0000                0.0000
#> 72:           1.580059e-03               27.7760               12.9242
#>     n2o_manure_other_total co2_ration_fertilizer co2_ration_pesticides
#>                      <num>                 <num>                 <num>
#>     co2_ration_crop_activities co2_ration_luc_nopeat co2_ration_luc_peat
#>                          <num>                 <num>               <num>
#>  1:                    81.7010               49.0764            0.852196
#>  2:                     0.0000                0.0000            0.000000
#>  3:                    81.7010               49.0764            0.852196
#>  4:                    81.7010               49.0764            0.852196
#>  5:                     0.0000                0.0000            0.000000
#>  6:                    81.7010               49.0764            0.852196
#>  7:                    47.3820                0.0262            0.001018
#>  8:                     0.0000                0.0000            0.000000
#>  9:                    47.3820                0.0262            0.001018
#> 10:                    47.3820                0.0262            0.001018
#> 11:                     0.0000                0.0000            0.000000
#> 12:                    47.3820                0.0262            0.001018
#> 13:                    57.6480                5.9369            0.057910
#> 14:                     0.0000                0.0000            0.000000
#> 15:                    57.6480                5.9369            0.057910
#> 16:                    57.6480                5.9369            0.057910
#> 17:                     0.0000                0.0000            0.000000
#> 18:                    57.6480                5.9369            0.057910
#> 19:                    87.5980                2.3662            0.313018
#> 20:                     0.0000                0.0000            0.000000
#> 21:                    87.5980                2.3662            0.313018
#> 22:                    87.5980                2.3662            0.313018
#> 23:                     0.0000                0.0000            0.000000
#> 24:                    87.5980                2.3662            0.313018
#> 25:                    73.6790               11.9319            0.106540
#> 26:                     0.0000                0.0000            0.000000
#> 27:                    73.6790               11.9319            0.106540
#> 28:                    73.6790               11.9319            0.106540
#> 29:                     0.0000                0.0000            0.000000
#> 30:                    73.6790               11.9319            0.106540
#> 31:                    83.5000                0.0000            0.000000
#> 32:                     0.0000                0.0000            0.000000
#> 33:                    83.5000                0.0000            0.000000
#> 34:                    83.5000                0.0000            0.000000
#> 35:                     0.0000                0.0000            0.000000
#> 36:                    83.5000                0.0000            0.000000
#> 37:                    81.8810               49.5318            0.652960
#> 38:                     0.0000                0.0000            0.000000
#> 39:                    81.8810               49.5318            0.652960
#> 40:                    81.8810               49.5318            0.652960
#> 41:                     0.0000                0.0000            0.000000
#> 42:                    81.8810               49.5318            0.652960
#> 43:                    79.8860                6.9051            0.822760
#> 44:                     0.0000                0.0000            0.000000
#> 45:                    79.8860                6.9051            0.822760
#> 46:                    79.8860                6.9051            0.822760
#> 47:                     0.0000                0.0000            0.000000
#> 48:                    79.8860                6.9051            0.822760
#> 49:                    55.8580               53.5010            0.336112
#> 50:                     0.0000                0.0000            0.000000
#> 51:                    55.8580               53.5010            0.336112
#> 52:                    55.8580               53.5010            0.336112
#> 53:                     0.0000                0.0000            0.000000
#> 54:                    55.8580               53.5010            0.336112
#> 55:                    31.1946              129.8650          -23.648440
#> 56:                     0.0000                0.0000            0.000000
#> 57:                    31.1946              129.8650          -23.648440
#> 58:                    31.1946              129.8650          -23.648440
#> 59:                     0.0000                0.0000            0.000000
#> 60:                    31.1946              129.8650          -23.648440
#> 61:                    31.2570               22.7100            1.639200
#> 62:                     0.0000                0.0000            0.000000
#> 63:                    31.2570               22.7100            1.639200
#> 64:                    31.2570               22.7100            1.639200
#> 65:                     0.0000                0.0000            0.000000
#> 66:                    31.2570               22.7100            1.639200
#> 67:                    92.8600                2.3662            0.313018
#> 68:                     0.0000                0.0000            0.000000
#> 69:                    92.8600                2.3662            0.313018
#> 70:                    92.8600                2.3662            0.313018
#> 71:                     0.0000                0.0000            0.000000
#> 72:                    92.8600                2.3662            0.313018
#>     co2_ration_crop_activities co2_ration_luc_nopeat co2_ration_luc_peat
#>                          <num>                 <num>               <num>
#>     n2o_ration_fertilizer n2o_ration_manure_applied n2o_ration_crop_residues
#>                     <num>                     <num>                    <num>
#>  1:              0.223890                  0.197650                 0.103184
#>  2:              0.000000                  0.000000                 0.000000
#>  3:              0.223890                  0.197650                 0.103184
#>  4:              0.223890                  0.197650                 0.103184
#>  5:              0.000000                  0.000000                 0.000000
#>  6:              0.223890                  0.197650                 0.103184
#>  7:              0.002860                  0.109080                 0.001202
#>  8:              0.000000                  0.000000                 0.000000
#>  9:              0.002860                  0.109080                 0.001202
#> 10:              0.002860                  0.109080                 0.001202
#> 11:              0.000000                  0.000000                 0.000000
#> 12:              0.002860                  0.109080                 0.001202
#> 13:              0.072447                  0.067596                 0.018048
#> 14:              0.000000                  0.000000                 0.000000
#> 15:              0.072447                  0.067596                 0.018048
#> 16:              0.072447                  0.067596                 0.018048
#> 17:              0.000000                  0.000000                 0.000000
#> 18:              0.072447                  0.067596                 0.018048
#> 19:              0.044660                  0.113400                 0.014342
#> 20:              0.000000                  0.000000                 0.000000
#> 21:              0.044660                  0.113400                 0.014342
#> 22:              0.044660                  0.113400                 0.014342
#> 23:              0.000000                  0.000000                 0.000000
#> 24:              0.044660                  0.113400                 0.014342
#> 25:              0.104779                  0.091046                 0.031238
#> 26:              0.000000                  0.000000                 0.000000
#> 27:              0.104779                  0.091046                 0.031238
#> 28:              0.104779                  0.091046                 0.031238
#> 29:              0.000000                  0.000000                 0.000000
#> 30:              0.104779                  0.091046                 0.031238
#> 31:              0.000000                  0.108000                 0.000000
#> 32:              0.000000                  0.000000                 0.000000
#> 33:              0.000000                  0.108000                 0.000000
#> 34:              0.000000                  0.108000                 0.000000
#> 35:              0.000000                  0.000000                 0.000000
#> 36:              0.000000                  0.108000                 0.000000
#> 37:              0.185636                  0.213822                 0.097351
#> 38:              0.000000                  0.000000                 0.000000
#> 39:              0.185636                  0.213822                 0.097351
#> 40:              0.185636                  0.213822                 0.097351
#> 41:              0.000000                  0.000000                 0.000000
#> 42:              0.185636                  0.213822                 0.097351
#> 43:              0.132050                  0.097550                 0.051655
#> 44:              0.000000                  0.000000                 0.000000
#> 45:              0.132050                  0.097550                 0.051655
#> 46:              0.132050                  0.097550                 0.051655
#> 47:              0.000000                  0.000000                 0.000000
#> 48:              0.132050                  0.097550                 0.051655
#> 49:              0.258840                  0.240100                 0.161783
#> 50:              0.000000                  0.000000                 0.000000
#> 51:              0.258840                  0.240100                 0.161783
#> 52:              0.258840                  0.240100                 0.161783
#> 53:              0.000000                  0.000000                 0.000000
#> 54:              0.258840                  0.240100                 0.161783
#> 55:              0.119804                  0.095069                 0.148221
#> 56:              0.000000                  0.000000                 0.000000
#> 57:              0.119804                  0.095069                 0.148221
#> 58:              0.119804                  0.095069                 0.148221
#> 59:              0.000000                  0.000000                 0.000000
#> 60:              0.119804                  0.095069                 0.148221
#> 61:              0.195100                  0.133180                 0.075510
#> 62:              0.000000                  0.000000                 0.000000
#> 63:              0.195100                  0.133180                 0.075510
#> 64:              0.195100                  0.133180                 0.075510
#> 65:              0.000000                  0.000000                 0.000000
#> 66:              0.195100                  0.133180                 0.075510
#> 67:              0.117716                  0.052298                 0.014342
#> 68:              0.000000                  0.000000                 0.000000
#> 69:              0.117716                  0.052298                 0.014342
#> 70:              0.117716                  0.052298                 0.014342
#> 71:              0.000000                  0.000000                 0.000000
#> 72:              0.117716                  0.052298                 0.014342
#>     n2o_ration_fertilizer n2o_ration_manure_applied n2o_ration_crop_residues
#>                     <num>                     <num>                    <num>
#>     ch4_ration_rice milk_production_mass_cohort milk_production_protein_cohort
#>               <num>                       <num>                          <num>
#>  1:           0.000                 50513974803                     1565933219
#>  2:           0.000                           0                              0
#>  3:           0.000                           0                              0
#>  4:           0.000                           0                              0
#>  5:           0.000                           0                              0
#>  6:           0.000                           0                              0
#>  7:           0.000                           0                              0
#>  8:           0.000                           0                              0
#>  9:           0.000                           0                              0
#> 10:           0.000                           0                              0
#> 11:           0.000                           0                              0
#> 12:           0.000                           0                              0
#> 13:           0.000                    64663043                        3750456
#> 14:           0.000                           0                              0
#> 15:           0.000                           0                              0
#> 16:           0.000                           0                              0
#> 17:           0.000                           0                              0
#> 18:           0.000                           0                              0
#> 19:           0.000                           0                              0
#> 20:           0.000                           0                              0
#> 21:           0.000                           0                              0
#> 22:           0.000                           0                              0
#> 23:           0.000                           0                              0
#> 24:           0.000                           0                              0
#> 25:           0.000                   138404115                        4705740
#> 26:           0.000                           0                              0
#> 27:           0.000                           0                              0
#> 28:           0.000                           0                              0
#> 29:           0.000                           0                              0
#> 30:           0.000                           0                              0
#> 31:           0.000                           0                              0
#> 32:           0.000                           0                              0
#> 33:           0.000                           0                              0
#> 34:           0.000                           0                              0
#> 35:           0.000                           0                              0
#> 36:           0.000                           0                              0
#> 37:           0.000                    78558504                        3660826
#> 38:           0.000                           0                              0
#> 39:           0.000                           0                              0
#> 40:           0.000                           0                              0
#> 41:           0.000                           0                              0
#> 42:           0.000                           0                              0
#> 43:           7.200                 28720555287                     1005219435
#> 44:           0.000                           0                              0
#> 45:           7.200                           0                              0
#> 46:           7.200                           0                              0
#> 47:           0.000                           0                              0
#> 48:           7.200                           0                              0
#> 49:           0.000                           0                              0
#> 50:           0.000                           0                              0
#> 51:           0.000                           0                              0
#> 52:           0.000                           0                              0
#> 53:           0.000                           0                              0
#> 54:           0.000                           0                              0
#> 55:           0.736                           0                              0
#> 56:           0.000                           0                              0
#> 57:           0.736                           0                              0
#> 58:           0.736                           0                              0
#> 59:           0.000                           0                              0
#> 60:           0.736                           0                              0
#> 61:           0.000                  1382779737                       48397291
#> 62:           0.000                           0                              0
#> 63:           0.000                           0                              0
#> 64:           0.000                           0                              0
#> 65:           0.000                           0                              0
#> 66:           0.000                           0                              0
#> 67:           0.000                   158470524                        5546468
#> 68:           0.000                           0                              0
#> 69:           0.000                           0                              0
#> 70:           0.000                           0                              0
#> 71:           0.000                           0                              0
#> 72:           0.000                           0                              0
#>     ch4_ration_rice milk_production_mass_cohort milk_production_protein_cohort
#>               <num>                       <num>                          <num>
#>     milk_production_fpcm_cohort fibre_production_cohort
#>                           <num>                   <num>
#>  1:                 47870829419                   0.000
#>  2:                           0                   0.000
#>  3:                           0                   0.000
#>  4:                           0                   0.000
#>  5:                           0                   0.000
#>  6:                           0                   0.000
#>  7:                           0                   0.000
#>  8:                           0                   0.000
#>  9:                           0                   0.000
#> 10:                           0                   0.000
#> 11:                           0                   0.000
#> 12:                           0                   0.000
#> 13:                    96609660             4178278.794
#> 14:                           0                   0.000
#> 15:                           0              881538.017
#> 16:                           0             2938490.049
#> 17:                           0                   0.000
#> 18:                           0               25617.157
#> 19:                           0            11364562.472
#> 20:                           0                   0.000
#> 21:                           0             1789195.608
#> 22:                           0             5759416.231
#> 23:                           0                   0.000
#> 24:                           0              280801.455
#> 25:                   170714332             1697862.793
#> 26:                           0                   0.000
#> 27:                           0              104870.260
#> 28:                           0              516973.219
#> 29:                           0                   0.000
#> 30:                           0                2642.270
#> 31:                           0               85219.795
#> 32:                           0                   0.000
#> 33:                           0               28930.945
#> 34:                           0               15127.161
#> 35:                           0                   0.000
#> 36:                           0                8425.587
#> 37:                   128157410                   0.000
#> 38:                           0                   0.000
#> 39:                           0                   0.000
#> 40:                           0                   0.000
#> 41:                           0                   0.000
#> 42:                           0                   0.000
#> 43:                 40295747197                   0.000
#> 44:                           0                   0.000
#> 45:                           0                   0.000
#> 46:                           0                   0.000
#> 47:                           0                   0.000
#> 48:                           0                   0.000
#> 49:                           0                   0.000
#> 50:                           0                   0.000
#> 51:                           0                   0.000
#> 52:                           0                   0.000
#> 53:                           0                   0.000
#> 54:                           0                   0.000
#> 55:                           0                   0.000
#> 56:                           0                   0.000
#> 57:                           0                   0.000
#> 58:                           0                   0.000
#> 59:                           0                   0.000
#> 60:                           0                   0.000
#> 61:                  1316577976             3028327.447
#> 62:                           0                   0.000
#> 63:                           0             2402477.568
#> 64:                           0               47080.593
#> 65:                           0                   0.000
#> 66:                           0              618631.277
#> 67:                   150883612              148890.884
#> 68:                           0                   0.000
#> 69:                           0              113864.120
#> 70:                           0               14609.767
#> 71:                           0                   0.000
#> 72:                           0               50771.772
#>     milk_production_fpcm_cohort fibre_production_cohort
#>                           <num>                   <num>
#>     meat_production_live_weight_cohort meat_production_carcass_weight_cohort
#>                                  <num>                                 <num>
#>  1:                       2.730470e+09                          1.774806e+09
#>  2:                       2.874156e+08                          1.868201e+08
#>  3:                       1.016465e+09                          6.607019e+08
#>  4:                       4.398295e+05                          2.858892e+05
#>  5:                       1.086560e+09                          7.062642e+08
#>  6:                       9.161878e+07                          5.955220e+07
#>  7:                       1.175784e+05                          7.642593e+04
#>  8:                       3.350812e+05                          2.178028e+05
#>  9:                       1.768221e+05                          1.149343e+05
#> 10:                       1.142653e+05                          7.427247e+04
#> 11:                       3.962934e+05                          2.575907e+05
#> 12:                       1.079174e+05                          7.014629e+04
#> 13:                       3.717372e+07                          2.416292e+07
#> 14:                       1.597936e+07                          1.038659e+07
#> 15:                       1.140910e+07                          7.415915e+06
#> 16:                       1.493321e+07                          9.706589e+06
#> 17:                       3.169331e+07                          2.060065e+07
#> 18:                       1.409239e+06                          9.160051e+05
#> 19:                       3.460503e+07                          2.249327e+07
#> 20:                       3.059369e+07                          1.988590e+07
#> 21:                       2.776360e+07                          1.804634e+07
#> 22:                       1.821992e+07                          1.184295e+07
#> 23:                       4.687335e+07                          3.046768e+07
#> 24:                       1.096069e+07                          7.124446e+06
#> 25:                       9.423467e+06                          6.125254e+06
#> 26:                       4.019452e+06                          2.612644e+06
#> 27:                       1.832179e+06                          1.190917e+06
#> 28:                       6.357780e+06                          4.132557e+06
#> 29:                       5.273128e+06                          3.427533e+06
#> 30:                       1.303809e+05                          8.474756e+04
#> 31:                       6.223043e+05                          4.044978e+05
#> 32:                       4.217899e+05                          2.741635e+05
#> 33:                       5.071393e+05                          3.296406e+05
#> 34:                       1.190142e+05                          7.735921e+04
#> 35:                       7.541025e+05                          4.901666e+05
#> 36:                       3.496387e+05                          2.272652e+05
#> 37:                       1.215985e+07                          7.903900e+06
#> 38:                       8.735056e+06                          5.677787e+06
#> 39:                       1.249014e+07                          8.118592e+06
#> 40:                       4.305511e+06                          2.798582e+06
#> 41:                       1.186737e+07                          7.713791e+06
#> 42:                       2.852594e+06                          1.854186e+06
#> 43:                       3.019176e+09                          1.962464e+09
#> 44:                       2.606623e+08                          1.694305e+08
#> 45:                       6.462042e+08                          4.200327e+08
#> 46:                       2.150735e+08                          1.397978e+08
#> 47:                       1.657215e+09                          1.077190e+09
#> 48:                       7.136331e+06                          4.638615e+06
#> 49:                       7.107366e+08                          4.619788e+08
#> 50:                       8.743803e+08                          5.683472e+08
#> 51:                       3.129714e+08                          2.034314e+08
#> 52:                       7.610360e+08                          4.946734e+08
#> 53:                       8.953917e+08                          5.820046e+08
#> 54:                       5.276906e+07                          3.429989e+07
#> 55:                       5.180079e+06                          3.367052e+06
#> 56:                       2.882597e+07                          1.873688e+07
#> 57:                       1.109068e+06                          7.208943e+05
#> 58:                       5.531005e+06                          3.595153e+06
#> 59:                       2.943319e+07                          1.913158e+07
#> 60:                       2.084956e+04                          1.355222e+04
#> 61:                       4.846103e+07                          3.149967e+07
#> 62:                       0.000000e+00                          0.000000e+00
#> 63:                       0.000000e+00                          0.000000e+00
#> 64:                       8.657360e+05                          5.627284e+05
#> 65:                       0.000000e+00                          0.000000e+00
#> 66:                       1.657632e+08                          1.077461e+08
#> 67:                       3.896054e+06                          2.532435e+06
#> 68:                       0.000000e+00                          0.000000e+00
#> 69:                       0.000000e+00                          0.000000e+00
#> 70:                       4.303921e+05                          2.797549e+05
#> 71:                       0.000000e+00                          0.000000e+00
#> 72:                       2.154353e+07                          1.400330e+07
#>     meat_production_live_weight_cohort meat_production_carcass_weight_cohort
#>                                  <num>                                 <num>
#>     meat_production_bone_free_meat_cohort meat_production_protein_cohort
#>                                     <num>                          <num>
#>  1:                          1.153624e+09                   2.422610e+08
#>  2:                          1.214331e+08                   2.550095e+07
#>  3:                          4.294563e+08                   9.018581e+07
#>  4:                          1.858280e+05                   3.902387e+04
#>  5:                          4.590717e+08                   9.640506e+07
#>  6:                          3.870893e+07                   8.128876e+06
#>  7:                          4.967686e+04                   1.043214e+04
#>  8:                          1.415718e+05                   2.973008e+04
#>  9:                          7.470732e+04                   1.568854e+04
#> 10:                          4.827710e+04                   1.013819e+04
#> 11:                          1.674340e+05                   3.516113e+04
#> 12:                          4.559509e+04                   9.574969e+03
#> 13:                          1.691404e+07                   3.551949e+06
#> 14:                          7.270611e+06                   1.526828e+06
#> 15:                          5.191141e+06                   1.090140e+06
#> 16:                          6.794612e+06                   1.426869e+06
#> 17:                          1.442046e+07                   3.028296e+06
#> 18:                          6.412036e+05                   1.346528e+05
#> 19:                          1.574529e+07                   3.306511e+06
#> 20:                          1.392013e+07                   2.923227e+06
#> 21:                          1.263244e+07                   2.652812e+06
#> 22:                          8.290063e+06                   1.740913e+06
#> 23:                          2.132738e+07                   4.478749e+06
#> 24:                          4.987112e+06                   1.047294e+06
#> 25:                          4.287678e+06                   9.004123e+05
#> 26:                          1.828851e+06                   3.840586e+05
#> 27:                          8.336417e+05                   1.750647e+05
#> 28:                          2.892790e+06                   6.074859e+05
#> 29:                          2.399273e+06                   5.038473e+05
#> 30:                          5.932329e+04                   1.245789e+04
#> 31:                          2.831485e+05                   5.946118e+04
#> 32:                          1.919144e+05                   4.030203e+04
#> 33:                          2.307484e+05                   4.845716e+04
#> 34:                          5.415145e+04                   1.137180e+04
#> 35:                          3.431167e+05                   7.205450e+04
#> 36:                          1.590856e+05                   3.340798e+04
#> 37:                          5.927925e+06                   1.244864e+06
#> 38:                          4.258340e+06                   8.942514e+05
#> 39:                          6.088944e+06                   1.278678e+06
#> 40:                          2.098936e+06                   4.407767e+05
#> 41:                          5.785343e+06                   1.214922e+06
#> 42:                          1.390640e+06                   2.920343e+05
#> 43:                          1.471848e+09                   3.090881e+08
#> 44:                          1.270729e+08                   2.668530e+07
#> 45:                          3.150245e+08                   6.615515e+07
#> 46:                          1.048483e+08                   2.201815e+07
#> 47:                          8.078924e+08                   1.696574e+08
#> 48:                          3.478961e+06                   7.305819e+05
#> 49:                          3.002862e+08                   6.306010e+07
#> 50:                          3.694257e+08                   7.757939e+07
#> 51:                          1.322304e+08                   2.776839e+07
#> 52:                          3.215377e+08                   6.752292e+07
#> 53:                          3.783030e+08                   7.944363e+07
#> 54:                          2.229493e+07                   4.681935e+06
#> 55:                          2.188584e+06                   4.596025e+05
#> 56:                          1.217897e+07                   2.557584e+06
#> 57:                          4.685813e+05                   9.840207e+04
#> 58:                          2.336849e+06                   4.907384e+05
#> 59:                          1.243552e+07                   2.611460e+06
#> 60:                          8.808940e+03                   1.849877e+03
#> 61:                          2.047479e+07                   4.299705e+06
#> 62:                          0.000000e+00                   0.000000e+00
#> 63:                          0.000000e+00                   0.000000e+00
#> 64:                          3.657735e+05                   7.681243e+04
#> 65:                          0.000000e+00                   0.000000e+00
#> 66:                          7.003494e+07                   1.470734e+07
#> 67:                          1.646083e+06                   3.456774e+05
#> 68:                          0.000000e+00                   0.000000e+00
#> 69:                          0.000000e+00                   0.000000e+00
#> 70:                          1.818407e+05                   3.818654e+04
#> 71:                          0.000000e+00                   0.000000e+00
#> 72:                          9.102143e+06                   1.911450e+06
#>     meat_production_bone_free_meat_cohort meat_production_protein_cohort
#>                                     <num>                          <num>
#>     milk_allocation_energy meat_allocation_energy fibre_allocation_energy
#>                      <num>                  <num>                   <num>
#>  1:           148558245766            70930704266                    0.00
#>  2:                      0             5459498936                    0.00
#>  3:                      0            25225336085                    0.00
#>  4:                      0               10254181                    0.00
#>  5:                      0            17458777507                    0.00
#>  6:                      0             1961416853                    0.00
#>  7:                      0                2979095                    0.00
#>  8:                      0                7750870                    0.00
#>  9:                      0                4203753                    0.00
#> 10:                      0                2552519                    0.00
#> 11:                      0                7754159                    0.00
#> 12:                      0                2170249                    0.00
#> 13:              299810171              495340455            100278691.06
#> 14:                      0              134626608                    0.00
#> 15:                      0              109649887             21156912.40
#> 16:                      0              201298468             70523761.19
#> 17:                      0              269134326                    0.00
#> 18:                      0               13236980               614811.76
#> 19:                      0              530800747            272749499.33
#> 20:                      0              290269906                    0.00
#> 21:                      0              372750803             42940694.60
#> 22:                      0              278038379            138225989.54
#> 23:                      0              432216444                    0.00
#> 24:                      0              140912970              6739234.91
#> 25:              529780287              153330412             40748707.04
#> 26:                      0               24814422                    0.00
#> 27:                      0               15287980              2516886.25
#> 28:                      0              146054314             12407357.25
#> 29:                      0               32554093                    0.00
#> 30:                      0                1087917                63414.49
#> 31:                      0                8124954              2045275.09
#> 32:                      0                2532040                    0.00
#> 33:                      0                4642391               694342.68
#> 34:                      0                2042842               363051.86
#> 35:                      0                4526939                    0.00
#> 36:                      0                3200619               202214.08
#> 37:              397712768              310208481                    0.00
#> 38:                      0              114474375                    0.00
#> 39:                      0              291527440                    0.00
#> 40:                      0               98544602                    0.00
#> 41:                      0              131557189                    0.00
#> 42:                      0               56320893                    0.00
#> 43:           125050382208            74620563140                    0.00
#> 44:                      0             3325621824                    0.00
#> 45:                      0             8244502318                    0.00
#> 46:                      0             4543068108                    0.00
#> 47:                      0            17885087671                    0.00
#> 48:                      0               77017097                    0.00
#> 49:                      0                      0                    0.00
#> 50:                      0                      0                    0.00
#> 51:                      0                      0                    0.00
#> 52:                      0                      0                    0.00
#> 53:                      0                      0                    0.00
#> 54:                      0                      0                    0.00
#> 55:                      0                      0                    0.00
#> 56:                      0                      0                    0.00
#> 57:                      0                      0                    0.00
#> 58:                      0                      0                    0.00
#> 59:                      0                      0                    0.00
#> 60:                      0                      0                    0.00
#> 61:             4085755707             4326766984            393076575.06
#> 62:                      0                      0                    0.00
#> 63:                      0                      0            311841328.51
#> 64:                      0               77834760              6111055.94
#> 65:                      0                      0                    0.00
#> 66:                      0            14903084038             80298272.84
#> 67:              468239322              355670229             19326020.65
#> 68:                      0                      0                    0.00
#> 69:                      0                      0             14779550.41
#> 70:                      0               39446326              1896346.16
#> 71:                      0                      0                    0.00
#> 72:                      0             1974509183              6590170.55
#>     milk_allocation_energy meat_allocation_energy fibre_allocation_energy
#>                      <num>                  <num>                   <num>
#>     work_allocation_energy egg_allocation_energy
#>                      <num>                 <num>
#>  1:                    0.0                     0
#>  2:                    0.0                     0
#>  3:                    0.0                     0
#>  4:                    0.0                     0
#>  5:                    0.0                     0
#>  6:                    0.0                     0
#>  7:                    0.0                     0
#>  8:                    0.0                     0
#>  9:                    0.0                     0
#> 10:               467997.5                     0
#> 11:                    0.0                     0
#> 12:                    0.0                     0
#> 13:                    0.0                     0
#> 14:                    0.0                     0
#> 15:                    0.0                     0
#> 16:                    0.0                     0
#> 17:                    0.0                     0
#> 18:                    0.0                     0
#> 19:                    0.0                     0
#> 20:                    0.0                     0
#> 21:                    0.0                     0
#> 22:                    0.0                     0
#> 23:                    0.0                     0
#> 24:                    0.0                     0
#> 25:                    0.0                     0
#> 26:                    0.0                     0
#> 27:                    0.0                     0
#> 28:                    0.0                     0
#> 29:                    0.0                     0
#> 30:                    0.0                     0
#> 31:                    0.0                     0
#> 32:                    0.0                     0
#> 33:                    0.0                     0
#> 34:                    0.0                     0
#> 35:                    0.0                     0
#> 36:                    0.0                     0
#> 37:                    0.0                     0
#> 38:                    0.0                     0
#> 39:                    0.0                     0
#> 40:                    0.0                     0
#> 41:                    0.0                     0
#> 42:                    0.0                     0
#> 43:                    0.0                     0
#> 44:                    0.0                     0
#> 45:                    0.0                     0
#> 46:           2889514739.0                     0
#> 47:                    0.0                     0
#> 48:                    0.0                     0
#> 49:                    0.0                     0
#> 50:                    0.0                     0
#> 51:                    0.0                     0
#> 52:                    0.0                     0
#> 53:                    0.0                     0
#> 54:                    0.0                     0
#> 55:                    0.0                     0
#> 56:                    0.0                     0
#> 57:                    0.0                     0
#> 58:                    0.0                     0
#> 59:                    0.0                     0
#> 60:                    0.0                     0
#> 61:                    0.0                     0
#> 62:                    0.0                     0
#> 63:                    0.0                     0
#> 64:             31971007.7                     0
#> 65:                    0.0                     0
#> 66:                    0.0                     0
#> 67:                    0.0                     0
#> 68:                    0.0                     0
#> 69:                    0.0                     0
#> 70:              9921051.0                     0
#> 71:                    0.0                     0
#> 72:                    0.0                     0
#>     work_allocation_energy egg_allocation_energy
#>                      <num>                 <num>
print(results$allocation_long)
#> Key: <commodity_name>
#>      herd_id species_short              variable_name commodity_name
#>        <int>        <char>                     <char>         <char>
#>   1:       3           SHP                ch4_enteric          Fibre
#>   2:       3           SHP           ch4_manure_other          Fibre
#>   3:       3           SHP            ch4_ration_rice          Fibre
#>   4:       3           SHP co2_ration_crop_activities          Fibre
#>   5:       3           SHP      co2_ration_fertilizer          Fibre
#>  ---                                                                
#> 445:      12           CML    n2o_manure_other_direct           Work
#> 446:      12           CML  n2o_manure_other_indirect           Work
#> 447:      12           CML   n2o_ration_crop_residues           Work
#> 448:      12           CML      n2o_ration_fertilizer           Work
#> 449:      12           CML  n2o_ration_manure_applied           Work
#>      commodity_type allocation_share
#>              <char>            <num>
#>   1:     Non-Edible       0.11224423
#>   2:     Non-Edible       0.11224423
#>   3:     Non-Edible       0.11224423
#>   4:     Non-Edible       0.11224423
#>   5:     Non-Edible       0.11224423
#>  ---                                
#> 445:     Non-Edible       0.00343244
#> 446:     Non-Edible       0.00343244
#> 447:     Non-Edible       0.00343244
#> 448:     Non-Edible       0.00343244
#> 449:     Non-Edible       0.00343244
# }

# Example 2: You already HAVE herd structure — use cohort table and skip herd simulation.
# Pipeline skips herd simulation and uses this as the starting cohort table.
# \donttest{
path_run_gleam_examples <- system.file("extdata/run_gleam_examples", package = "gleam")

master_chrt_lvl_structure_dt <- data.table::fread(file.path(
  path_run_gleam_examples, "master_chrt_lvl_structure_data.csv"
))
master_hrd_lvl_dt <- data.table::fread(
file.path(path_run_gleam_examples, "master_hrd_lvl_data.csv")
)
feed_rations_chrt_dt <- data.table::fread(
file.path(path_run_gleam_examples, "feed_rations_share_chrt.csv")
)
feed_params_dt <- data.table::fread(system.file(
  "extdata/run_gleam_examples/feed_quality.csv",
  package = "gleam"
))
feed_emissions_dt <- data.table::fread(system.file(
  "extdata/run_gleam_examples/feed_emission_factors.csv",
  package = "gleam"
))

manure_management_system_fraction_dt <- data.table::fread(
  file.path(path_run_gleam_examples, "manure_management_system_fraction.csv")
)
manure_management_system_factors_dt <- data.table::fread(
  file.path(path_run_gleam_examples, "manure_management_system_factors.csv")
)

results <- run_gleam(
  has_herd_structure = TRUE,
  cohort_level_data = master_chrt_lvl_structure_dt,
  herd_level_data = master_hrd_lvl_dt,
  feed_rations = feed_rations_chrt_dt,
  feed_params = feed_params_dt,
  feed_emissions = feed_emissions_dt,
  manure_management_system_fraction = manure_management_system_fraction_dt,
  manure_management_system_factors = manure_management_system_factors_dt,
  simulation_duration = 365,
  global_warming_potential_set = "AR6"
)
#> 
#> ── 🕒 Running GLEAM pipeline… ──────────────────────────────────────────────────
#> 🕒 Calculating cohort weights, please wait…
#> ✔ Cohort weights calculation complete.
#> 🕒 Aggregating ration quality, please wait…
#> ✔ Ration quality aggregation complete.
#> 🕒 Calculating metabolic energy requirements and ration, please wait…
#> ✔ Metabolic energy requirements calculation complete.
#> 🕒 Calculating enteric methane emissions, please wait…
#> ✔ Enteric methane emissions calculation complete.
#> 🕒 Calculating nitrogen balance, please wait…
#> ✔ Nitrogen balance calculation complete.
#> 🕒 Calculating emissions from manure management systems…
#> ✔ Emissions from manure management calculation complete.
#> 🕒 Aggregating feed emissions, please wait…
#> ✔ Feed emissions aggregation complete.
#> 🕒 Calculating production (milk, fibre, meat), please wait…
#> ✔ Production cohort calculations completed.
#> 🕒 Computing allocation shares, please wait…
#> ✔ Allocation calculation complete.
#> 🕒 Aggregating results, please wait…
#> ✔ Aggregation complete.
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ GLEAM pipeline complete.
print(results$cohort_level_results)
#> Key: <herd_id, species_short, cohort_short>
#>     herd_id species_short cohort_short cohort_stock_size cohort_duration_days
#>       <int>        <char>       <char>             <num>                <int>
#>  1:       1           CTL           FA      1.240094e+07                  989
#>  2:       1           CTL           FJ      7.023271e+05                   60
#>  3:       1           CTL           FS      6.905753e+06                  710
#>  4:       1           CTL           MA      1.225347e+03                  823
#>  5:       1           CTL           MJ      2.370447e+05                   60
#>  6:       1           CTL           MS      5.271326e+04                  710
#>  7:       2           CTL           FA      7.014573e+03                 5000
#>  8:       2           CTL           FJ      2.328332e+02                   60
#>  9:       2           CTL           FS      6.625667e+02                 1400
#> 10:       2           CTL           MA      1.612192e+03                 1820
#> 11:       2           CTL           MJ      1.935859e+02                   60
#> 12:       2           CTL           MS      2.842486e+02                 1400
#> 13:       3           SHP           FA      2.785519e+06                 1110
#> 14:       3           SHP           FJ      1.476204e+05                   60
#> 15:       3           SHP           FS      5.876920e+05                  448
#> 16:       3           SHP           MA      1.958993e+06                 2090
#> 17:       3           SHP           MJ      6.309694e+04                   60
#> 18:       3           SHP           MS      1.707810e+04                  448
#> 19:       4           SHP           FA      4.545825e+06                 2430
#> 20:       4           SHP           FJ      1.838593e+05                   60
#> 21:       4           SHP           FS      7.156782e+05                  669
#> 22:       4           SHP           MA      2.303766e+06                 2680
#> 23:       4           SHP           MJ      1.185504e+05                   60
#> 24:       4           SHP           MS      1.123206e+05                  669
#> 25:       5           GTS           FA      9.432571e+05                 2230
#> 26:       5           GTS           FJ      3.447891e+04                   60
#> 27:       5           GTS           FS      5.826126e+04                  415
#> 28:       5           GTS           MA      2.872073e+05                 1540
#> 29:       5           GTS           MJ      1.532746e+04                   60
#> 30:       5           GTS           MS      1.467928e+03                  415
#> 31:       6           GTS           FA      1.136264e+05                 2110
#> 32:       6           GTS           FJ      9.482460e+03                   60
#> 33:       6           GTS           FS      3.857459e+04                  564
#> 34:       6           GTS           MA      2.016955e+04                 2600
#> 35:       6           GTS           MJ      6.912891e+03                   60
#> 36:       6           GTS           MS      1.123412e+04                  600
#> 37:       7           BFL           FA      2.650601e+05                 3650
#> 38:       7           BFL           FJ      1.018474e+04                   60
#> 39:       7           BFL           FS      2.805708e+04                  974
#> 40:       7           BFL           MA      2.165653e+04                 1170
#> 41:       7           BFL           MJ      6.149071e+03                   60
#> 42:       7           BFL           MS      2.892509e+03                  974
#> 43:       8           BFL           FA      4.416865e+07                 1830
#> 44:       8           BFL           FJ      2.498356e+06                   60
#> 45:       8           BFL           FS      4.093659e+07                 1400
#> 46:       8           BFL           MA      4.598860e+06                 2430
#> 47:       8           BFL           MJ      5.665933e+05                   60
#> 48:       8           BFL           MS      3.095179e+04                 1400
#> 49:       9           PGS           FA      1.022903e+07                  890
#> 50:       9           PGS           FJ      3.152269e+06                   27
#> 51:       9           PGS           FS      9.588819e+05                  359
#> 52:       9           PGS           MA      9.347594e+06                  890
#> 53:       9           PGS           MJ      2.286055e+06                   27
#> 54:       9           PGS           MS      1.261730e+05                  359
#> 55:      10           PGS           FA      9.468841e+05                 3650
#> 56:      10           PGS           FJ      2.414018e+05                   90
#> 57:      10           PGS           FS      5.670844e+03                  340
#> 58:      10           PGS           MA      9.117222e+05                 3650
#> 59:      10           PGS           MJ      1.442343e+05                   90
#> 60:      10           PGS           MS      8.669005e+01                  340
#> 61:      11           CML           FA      3.028327e+06                 5000
#> 62:      11           CML           FJ      5.567416e+05                  370
#> 63:      11           CML           FS      2.402478e+06                 2190
#> 64:      11           CML           MA      4.708059e+04                 5000
#> 65:      11           CML           MJ      5.567416e+05                  370
#> 66:      11           CML           MS      6.186313e+05                 2190
#> 67:      12           CML           FA      1.488909e+05                 5000
#> 68:      12           CML           FJ      5.093173e+04                  365
#> 69:      12           CML           FS      1.138641e+05                 1280
#> 70:      12           CML           MA      1.460977e+04                 5000
#> 71:      12           CML           MJ      5.093173e+04                  365
#> 72:      12           CML           MS      5.077177e+04                 1280
#>     herd_id species_short cohort_short cohort_stock_size cohort_duration_days
#>       <int>        <char>       <char>             <num>                <int>
#>     offtake_rate offtake_heads_assessment high_activity_fraction
#>            <num>                    <num>                  <num>
#>  1:        0.000             4.015397e+06               0.000036
#>  2:        0.247             1.149662e+06               0.000036
#>  3:        0.247             1.824891e+06               0.000036
#>  4:        0.000             4.801632e+02               0.000036
#>  5:        0.949             4.346241e+06               0.000036
#>  6:        0.949             1.514360e+05               0.000036
#>  7:        0.000             3.359382e+02               0.600000
#>  8:        0.661             1.523096e+03               0.600000
#>  9:        0.661             7.072882e+02               0.600000
#> 10:        0.000             2.539230e+02               0.600000
#> 11:        0.783             1.801334e+03               0.600000
#> 12:        0.783             4.316695e+02               0.600000
#> 13:        0.000             7.288965e+05               0.226000
#> 14:        0.453             5.326455e+05               0.226000
#> 15:        0.453             3.259743e+05               0.226000
#> 16:        0.000             2.531053e+05               0.226000
#> 17:        0.913             1.056444e+06               0.226000
#> 18:        0.913             4.026396e+04               0.226000
#> 19:        0.000             5.757908e+05               0.478000
#> 20:        0.543             8.741053e+05               0.478000
#> 21:        0.543             5.359769e+05               0.478000
#> 22:        0.000             2.591738e+05               0.478000
#> 23:        0.836             1.339239e+06               0.478000
#> 24:        0.836             1.960767e+05               0.478000
#> 25:        0.000             1.346210e+05               0.245000
#> 26:        0.737             2.679635e+05               0.245000
#> 27:        0.737             7.328718e+04               0.245000
#> 28:        0.000             5.779800e+04               0.245000
#> 29:        0.974             3.515418e+05               0.245000
#> 30:        0.974             5.215234e+03               0.245000
#> 31:        0.000             1.220205e+04               0.000000
#> 32:        0.359             3.012785e+04               0.000000
#> 33:        0.359             1.748756e+04               0.000000
#> 34:        0.000             1.582635e+03               0.000000
#> 35:        0.644             5.386447e+04               0.000000
#> 36:        0.644             1.205651e+04               0.000000
#> 37:        0.000             2.026641e+04               0.018900
#> 38:        0.664             6.719274e+04               0.018900
#> 39:        0.664             2.973843e+04               0.018900
#> 40:        0.000             5.381888e+03               0.018900
#> 41:        0.906             9.128747e+04               0.018900
#> 42:        0.906             6.791890e+03               0.018900
#> 43:        0.000             6.316267e+06               0.043100
#> 44:        0.134             2.369657e+06               0.043100
#> 45:        0.134             5.874583e+06               0.043100
#> 46:        0.000             4.301470e+05               0.043100
#> 47:        0.862             1.506559e+07               0.043100
#> 48:        0.862             6.487573e+04               0.043100
#> 49:        0.000             3.158829e+06               0.000000
#> 50:        0.948             1.249115e+08               0.000000
#> 51:        0.948             2.565339e+06               0.000000
#> 52:        0.000             2.871834e+06               0.000000
#> 53:        0.973             1.279131e+08               0.000000
#> 54:        0.973             4.325333e+05               0.000000
#> 55:        0.000             8.093874e+04               0.000000
#> 56:        0.952             4.804328e+06               0.000000
#> 57:        0.952             1.848447e+04               0.000000
#> 58:        0.000             7.790147e+04               0.000000
#> 59:        0.974             4.905532e+06               0.000000
#> 60:        0.974             3.474927e+02               0.000000
#> 61:        0.000             1.376734e+05               0.000000
#> 62:        0.000             0.000000e+00               0.000000
#> 63:        0.000             0.000000e+00               0.000000
#> 64:        0.004             2.266325e+03               0.000000
#> 65:        0.000             0.000000e+00               0.000000
#> 66:        0.496             4.339350e+05               0.000000
#> 67:        0.000             7.255222e+03               0.000000
#> 68:        0.000             0.000000e+00               0.000000
#> 69:        0.000             0.000000e+00               0.000000
#> 70:        0.004             7.524338e+02               0.000000
#> 71:        0.000             0.000000e+00               0.000000
#> 72:        0.500             3.766352e+04               0.000000
#>     offtake_rate offtake_heads_assessment high_activity_fraction
#>            <num>                    <num>                  <num>
#>     low_activity_fraction live_weight_mature_stage live_weight_cohort_initial
#>                     <num>                    <num>                      <num>
#>  1:              1.66e-06                    680.0                     680.00
#>  2:              1.66e-06                    680.0                      41.00
#>  3:              1.66e-06                    680.0                     250.00
#>  4:              1.66e-06                    916.0                     916.00
#>  5:              1.66e-06                    916.0                      41.00
#>  6:              1.66e-06                    916.0                     250.00
#>  7:              4.65e-02                    350.0                     350.00
#>  8:              4.65e-02                    350.0                      14.00
#>  9:              4.65e-02                    350.0                     220.00
#> 10:              4.65e-02                    450.0                     450.00
#> 11:              4.65e-02                    450.0                      14.00
#> 12:              4.65e-02                    450.0                     220.00
#> 13:              1.33e-01                     51.0                      51.00
#> 14:              1.33e-01                     51.0                       4.19
#> 15:              1.33e-01                     51.0                      30.00
#> 16:              1.33e-01                     59.0                      59.00
#> 17:              1.33e-01                     59.0                       4.19
#> 18:              1.33e-01                     59.0                      30.00
#> 19:              2.18e-02                     60.1                      60.10
#> 20:              2.18e-02                     60.1                       5.21
#> 21:              2.18e-02                     60.1                      35.00
#> 22:              2.18e-02                     70.3                      70.30
#> 23:              2.18e-02                     70.3                       5.21
#> 24:              2.18e-02                     70.3                      35.00
#> 25:              1.09e-01                     70.0                      70.00
#> 26:              1.09e-01                     70.0                       3.50
#> 27:              1.09e-01                     70.0                      15.00
#> 28:              1.09e-01                    110.0                     110.00
#> 29:              1.09e-01                    110.0                       3.50
#> 30:              1.09e-01                    110.0                      15.00
#> 31:              7.50e-01                     51.0                      51.00
#> 32:              7.50e-01                     51.0                       3.30
#> 33:              7.50e-01                     51.0                      14.00
#> 34:              7.50e-01                     75.2                      75.20
#> 35:              7.50e-01                     75.2                       3.30
#> 36:              7.50e-01                     75.2                      14.00
#> 37:              1.11e-02                    600.0                     600.00
#> 38:              1.11e-02                    600.0                      38.00
#> 39:              1.11e-02                    600.0                     130.00
#> 40:              1.11e-02                    800.0                     800.00
#> 41:              1.11e-02                    800.0                      38.00
#> 42:              1.11e-02                    800.0                     130.00
#> 43:              1.57e-01                    478.0                     478.00
#> 44:              1.57e-01                    478.0                      32.60
#> 45:              1.57e-01                    478.0                     110.00
#> 46:              1.57e-01                    500.0                     500.00
#> 47:              1.57e-01                    500.0                      32.60
#> 48:              1.57e-01                    500.0                     110.00
#> 49:              0.00e+00                    225.0                     225.00
#> 50:              0.00e+00                    225.0                       1.20
#> 51:              0.00e+00                    225.0                       7.00
#> 52:              0.00e+00                    265.0                     265.00
#> 53:              0.00e+00                    265.0                       1.20
#> 54:              0.00e+00                    265.0                       7.00
#> 55:              2.00e-01                     64.0                      64.00
#> 56:              2.00e-01                     64.0                       1.00
#> 57:              2.00e-01                     64.0                       6.00
#> 58:              2.00e-01                     71.0                      71.00
#> 59:              2.00e-01                     71.0                       1.00
#> 60:              2.00e-01                     71.0                       6.00
#> 61:              1.00e+00                    352.0                     352.00
#> 62:              1.00e+00                    352.0                      28.70
#> 63:              1.00e+00                    352.0                     120.00
#> 64:              1.00e+00                    382.0                     382.00
#> 65:              1.00e+00                    382.0                      28.70
#> 66:              1.00e+00                    382.0                     120.00
#> 67:              0.00e+00                    537.0                     537.00
#> 68:              0.00e+00                    537.0                      32.70
#> 69:              0.00e+00                    537.0                     150.00
#> 70:              0.00e+00                    572.0                     572.00
#> 71:              0.00e+00                    572.0                      32.70
#> 72:              0.00e+00                    572.0                     150.00
#>     low_activity_fraction live_weight_mature_stage live_weight_cohort_initial
#>                     <num>                    <num>                      <num>
#>     live_weight_cohort_potential_final live_weight_cohort_at_slaughter
#>                                  <num>                           <num>
#>  1:                              680.0                           680.0
#>  2:                              250.0                           250.0
#>  3:                              680.0                           557.0
#>  4:                              916.0                           916.0
#>  5:                              250.0                           250.0
#>  6:                              916.0                           605.0
#>  7:                              350.0                           350.0
#>  8:                              220.0                           220.0
#>  9:                              350.0                           250.0
#> 10:                              450.0                           450.0
#> 11:                              220.0                           220.0
#> 12:                              450.0                           250.0
#> 13:                               51.0                            51.0
#> 14:                               30.0                            30.0
#> 15:                               51.0                            35.0
#> 16:                               59.0                            59.0
#> 17:                               30.0                            30.0
#> 18:                               59.0                            35.0
#> 19:                               60.1                            60.1
#> 20:                               35.0                            35.0
#> 21:                               60.1                            51.8
#> 22:                               70.3                            70.3
#> 23:                               35.0                            35.0
#> 24:                               70.3                            55.9
#> 25:                               70.0                            70.0
#> 26:                               15.0                            15.0
#> 27:                               70.0                            25.0
#> 28:                              110.0                           110.0
#> 29:                               15.0                            15.0
#> 30:                              110.0                            25.0
#> 31:                               51.0                            51.0
#> 32:                               14.0                            14.0
#> 33:                               51.0                            29.0
#> 34:                               75.2                            75.2
#> 35:                               14.0                            14.0
#> 36:                               75.2                            29.0
#> 37:                              600.0                           600.0
#> 38:                              130.0                           130.0
#> 39:                              600.0                           420.0
#> 40:                              800.0                           800.0
#> 41:                              130.0                           130.0
#> 42:                              800.0                           420.0
#> 43:                              478.0                           478.0
#> 44:                              110.0                           110.0
#> 45:                              478.0                           110.0
#> 46:                              500.0                           500.0
#> 47:                              110.0                           110.0
#> 48:                              500.0                           110.0
#> 49:                              225.0                           225.0
#> 50:                                7.0                             7.0
#> 51:                              225.0                           122.0
#> 52:                              265.0                           265.0
#> 53:                                7.0                             7.0
#> 54:                              265.0                           122.0
#> 55:                               64.0                            64.0
#> 56:                                6.0                             6.0
#> 57:                               64.0                            60.0
#> 58:                               71.0                            71.0
#> 59:                                6.0                             6.0
#> 60:                               71.0                            60.0
#> 61:                              352.0                           352.0
#> 62:                              120.0                           120.0
#> 63:                              352.0                           352.0
#> 64:                              382.0                           382.0
#> 65:                              120.0                           120.0
#> 66:                              382.0                           382.0
#> 67:                              537.0                           537.0
#> 68:                              150.0                           150.0
#> 69:                              537.0                           537.0
#> 70:                              572.0                           572.0
#> 71:                              150.0                           150.0
#> 72:                              572.0                           572.0
#>     live_weight_cohort_potential_final live_weight_cohort_at_slaughter
#>                                  <num>                           <num>
#>     live_weight_cohort_average live_weight_cohort_final daily_weight_gain
#>                          <num>                    <num>             <num>
#>  1:                  680.00000                 680.0000        0.00000000
#>  2:                  145.50000                 250.0000        3.48333333
#>  3:                  449.80950                 649.6190        0.60563380
#>  4:                  916.00000                 916.0000        0.00000000
#>  5:                  145.50000                 250.0000        3.48333333
#>  6:                  435.43050                 620.8610        0.93802817
#>  7:                  350.00000                 350.0000        0.00000000
#>  8:                  117.00000                 220.0000        3.43333333
#>  9:                  251.95000                 283.9000        0.09285714
#> 10:                  450.00000                 450.0000        0.00000000
#> 11:                  117.00000                 220.0000        3.43333333
#> 12:                  256.70000                 293.4000        0.16428571
#> 13:                   51.00000                  51.0000        0.00000000
#> 14:                   17.09500                  30.0000        0.43016667
#> 15:                   36.87600                  43.7520        0.04687500
#> 16:                   59.00000                  59.0000        0.00000000
#> 17:                   17.09500                  30.0000        0.43016667
#> 18:                   33.54400                  37.0880        0.06473214
#> 19:                   60.10000                  60.1000        0.00000000
#> 20:                   20.10500                  35.0000        0.49650000
#> 21:                   45.29655                  55.5931        0.03751868
#> 22:                   70.30000                  70.3000        0.00000000
#> 23:                   20.10500                  35.0000        0.49650000
#> 24:                   46.63080                  58.2616        0.05276532
#> 25:                   70.00000                  70.0000        0.00000000
#> 26:                    9.25000                  15.0000        0.19166667
#> 27:                   25.91750                  36.8350        0.13253012
#> 28:                  110.00000                 110.0000        0.00000000
#> 29:                    9.25000                  15.0000        0.19166667
#> 30:                   21.10500                  27.2100        0.22891566
#> 31:                   51.00000                  51.0000        0.00000000
#> 32:                    8.65000                  14.0000        0.17833333
#> 33:                   28.55100                  43.1020        0.06560284
#> 34:                   75.20000                  75.2000        0.00000000
#> 35:                    8.65000                  14.0000        0.17833333
#> 36:                   29.72360                  45.4472        0.10200000
#> 37:                  600.00000                 600.0000        0.00000000
#> 38:                   84.00000                 130.0000        1.53333333
#> 39:                  305.24000                 480.4800        0.48254620
#> 40:                  800.00000                 800.0000        0.00000000
#> 41:                   84.00000                 130.0000        1.53333333
#> 42:                  292.86000                 455.7200        0.68788501
#> 43:                  478.00000                 478.0000        0.00000000
#> 44:                   71.30000                 110.0000        1.29000000
#> 45:                  269.34400                 428.6880        0.26285714
#> 46:                  500.00000                 500.0000        0.00000000
#> 47:                   71.30000                 110.0000        1.29000000
#> 48:                  136.91000                 163.8200        0.27857143
#> 49:                  225.00000                 225.0000        0.00000000
#> 50:                    4.10000                   7.0000        0.21481481
#> 51:                   67.17800                 127.3560        0.60724234
#> 52:                  265.00000                 265.0000        0.00000000
#> 53:                    4.10000                   7.0000        0.21481481
#> 54:                   66.43050                 125.8610        0.71866295
#> 55:                   64.00000                  64.0000        0.00000000
#> 56:                    3.50000                   6.0000        0.05555556
#> 57:                   33.09600                  60.1920        0.17058824
#> 58:                   71.00000                  71.0000        0.00000000
#> 59:                    3.50000                   6.0000        0.05555556
#> 60:                   33.14300                  60.2860        0.19117647
#> 61:                  352.00000                 352.0000        0.00000000
#> 62:                   74.35000                 120.0000        0.24675676
#> 63:                  236.00000                 352.0000        0.10593607
#> 64:                  382.00000                 382.0000        0.00000000
#> 65:                   74.35000                 120.0000        0.24675676
#> 66:                  251.00000                 382.0000        0.11963470
#> 67:                  537.00000                 537.0000        0.00000000
#> 68:                   91.35000                 150.0000        0.32136986
#> 69:                  343.50000                 537.0000        0.30234375
#> 70:                  572.00000                 572.0000        0.00000000
#> 71:                   91.35000                 150.0000        0.32136986
#> 72:                  361.00000                 572.0000        0.32968750
#>     live_weight_cohort_average live_weight_cohort_final daily_weight_gain
#>                          <num>                    <num>             <num>
#>     ration_gross_energy ration_metabolizable_energy ration_nitrogen
#>                   <num>                       <num>           <num>
#>  1:              18.788                     10.9430       0.0210060
#>  2:              21.900                     20.4000       0.0411000
#>  3:              18.788                     10.9430       0.0210060
#>  4:              18.788                     10.9430       0.0210060
#>  5:              21.900                     20.4000       0.0411000
#>  6:              18.788                     10.9430       0.0210060
#>  7:              17.850                      8.1062       0.0164160
#>  8:              21.900                     20.4000       0.0411000
#>  9:              17.850                      8.1062       0.0164160
#> 10:              17.850                      8.1062       0.0164160
#> 11:              21.900                     20.4000       0.0411000
#> 12:              17.850                      8.1062       0.0164160
#> 13:              18.214                      9.4792       0.0200758
#> 14:              20.400                     19.0000       0.0486000
#> 15:              18.214                      9.4792       0.0200758
#> 16:              18.214                      9.4792       0.0200758
#> 17:              20.400                     19.0000       0.0486000
#> 18:              18.214                      9.4792       0.0200758
#> 19:              17.929                      8.0304       0.0168610
#> 20:              20.400                     19.0000       0.0486000
#> 21:              17.929                      8.0304       0.0168610
#> 22:              17.929                      8.0304       0.0168610
#> 23:              20.400                     19.0000       0.0486000
#> 24:              17.929                      8.0304       0.0168610
#> 25:              18.358                     10.1050       0.0269400
#> 26:              21.900                     20.4000       0.0411000
#> 27:              18.358                     10.1050       0.0269400
#> 28:              18.358                     10.1050       0.0269400
#> 29:              21.900                     20.4000       0.0411000
#> 30:              18.358                     10.1050       0.0269400
#> 31:              17.850                      7.9100       0.0156500
#> 32:              21.900                     20.4000       0.0411000
#> 33:              17.850                      7.9100       0.0156500
#> 34:              17.850                      7.9100       0.0156500
#> 35:              21.900                     20.4000       0.0411000
#> 36:              17.850                      7.9100       0.0156500
#> 37:              18.888                     10.5940       0.0205852
#> 38:              24.300                     22.6000       0.0445000
#> 39:              18.888                     10.5940       0.0205852
#> 40:              18.888                     10.5940       0.0205852
#> 41:              24.300                     22.6000       0.0445000
#> 42:              18.888                     10.5940       0.0205852
#> 43:              18.245                      7.9301       0.0144556
#> 44:              24.300                     22.6000       0.0445000
#> 45:              18.245                      7.9301       0.0144556
#> 46:              18.245                      7.9301       0.0144556
#> 47:              24.300                     22.6000       0.0445000
#> 48:              18.245                      7.9301       0.0144556
#> 49:              18.857                     14.1850       0.0349430
#> 50:              25.800                     24.1000       0.0468000
#> 51:              18.857                     14.1850       0.0349430
#> 52:              18.857                     14.1850       0.0349430
#> 53:              25.800                     24.1000       0.0468000
#> 54:              18.857                     14.1850       0.0349430
#> 55:              18.236                      9.2350       0.0234152
#> 56:              25.800                     24.1000       0.0468000
#> 57:              18.236                      9.2350       0.0234152
#> 58:              18.236                      9.2350       0.0234152
#> 59:              25.800                     24.1000       0.0468000
#> 60:              18.236                      9.2350       0.0234152
#> 61:              18.140                      8.8456       0.0217400
#> 62:              22.200                     20.7000       0.0400000
#> 63:              18.140                      8.8456       0.0217400
#> 64:              18.140                      8.8456       0.0217400
#> 65:              22.200                     20.7000       0.0400000
#> 66:              18.140                      8.8456       0.0217400
#> 67:              18.116                      8.6922       0.0176120
#> 68:              22.200                     20.7000       0.0400000
#> 69:              18.116                      8.6922       0.0176120
#> 70:              18.116                      8.6922       0.0176120
#> 71:              22.200                     20.7000       0.0400000
#> 72:              18.116                      8.6922       0.0176120
#>     ration_gross_energy ration_metabolizable_energy ration_nitrogen
#>                   <num>                       <num>           <num>
#>     ration_digestibility_fraction ration_urinary_energy_fraction ration_ash
#>                             <num>                          <num>      <num>
#>  1:                     0.7095322                       0.128390       0.04
#>  2:                     0.9726027                       0.041100       0.04
#>  3:                     0.7095322                       0.128390       0.04
#>  4:                     0.7095322                       0.128390       0.04
#>  5:                     0.9726027                       0.041100       0.04
#>  6:                     0.7095322                       0.128390       0.04
#>  7:                     0.5721907                       0.118280       0.04
#>  8:                     0.9726027                       0.041100       0.04
#>  9:                     0.5721907                       0.118280       0.04
#> 10:                     0.5721907                       0.118280       0.04
#> 11:                     0.9726027                       0.041100       0.04
#> 12:                     0.5721907                       0.118280       0.04
#> 13:                     0.6428824                       0.122634       0.04
#> 14:                     0.9705882                       0.039200       0.04
#> 15:                     0.6428824                       0.122634       0.04
#> 16:                     0.6428824                       0.122634       0.04
#> 17:                     0.9705882                       0.039200       0.04
#> 18:                     0.6428824                       0.122634       0.04
#> 19:                     0.5634958                       0.116220       0.04
#> 20:                     0.9705882                       0.039200       0.04
#> 21:                     0.5634958                       0.116220       0.04
#> 22:                     0.5634958                       0.116220       0.04
#> 23:                     0.9705882                       0.039200       0.04
#> 24:                     0.5634958                       0.116220       0.04
#> 25:                     0.6849606                       0.136150       0.04
#> 26:                     0.9726027                       0.041100       0.04
#> 27:                     0.6849606                       0.136150       0.04
#> 28:                     0.6849606                       0.136150       0.04
#> 29:                     0.9726027                       0.041100       0.04
#> 30:                     0.6849606                       0.136150       0.04
#> 31:                     0.5580566                       0.115000       0.04
#> 32:                     0.9726027                       0.041100       0.04
#> 33:                     0.5580566                       0.115000       0.04
#> 34:                     0.5580566                       0.115000       0.04
#> 35:                     0.9726027                       0.041100       0.04
#> 36:                     0.5580566                       0.115000       0.04
#> 37:                     0.6843249                       0.124646       0.04
#> 38:                     0.9711934                       0.041200       0.04
#> 39:                     0.6843249                       0.124646       0.04
#> 40:                     0.6843249                       0.124646       0.04
#> 41:                     0.9711934                       0.041200       0.04
#> 42:                     0.6843249                       0.124646       0.04
#> 43:                     0.5362405                       0.103938       0.04
#> 44:                     0.9711934                       0.041200       0.04
#> 45:                     0.5362405                       0.103938       0.04
#> 46:                     0.5362405                       0.103938       0.04
#> 47:                     0.9711934                       0.041200       0.04
#> 48:                     0.5362405                       0.103938       0.04
#> 49:                     0.7902968                       0.034718       0.04
#> 50:                     0.9728682                       0.038800       0.04
#> 51:                     0.7902968                       0.034718       0.04
#> 52:                     0.7902968                       0.034718       0.04
#> 53:                     0.9728682                       0.038800       0.04
#> 54:                     0.7902968                       0.034718       0.04
#> 55:                     0.5495364                       0.046149       0.04
#> 56:                     0.9728682                       0.038800       0.04
#> 57:                     0.5495364                       0.046149       0.04
#> 58:                     0.5495364                       0.046149       0.04
#> 59:                     0.9728682                       0.038800       0.04
#> 60:                     0.5495364                       0.046149       0.04
#> 61:                     0.6131448                       0.127710       0.04
#> 62:                     0.9729730                       0.040500       0.04
#> 63:                     0.6131448                       0.127710       0.04
#> 64:                     0.6131448                       0.127710       0.04
#> 65:                     0.9729730                       0.040500       0.04
#> 66:                     0.6131448                       0.127710       0.04
#> 67:                     0.5968941                       0.117380       0.04
#> 68:                     0.9729730                       0.040500       0.04
#> 69:                     0.5968941                       0.117380       0.04
#> 70:                     0.5968941                       0.117380       0.04
#> 71:                     0.9729730                       0.040500       0.04
#> 72:                     0.5968941                       0.117380       0.04
#>     ration_digestibility_fraction ration_urinary_energy_fraction ration_ash
#>                             <num>                          <num>      <num>
#>     metabolic_energy_req_maintenance metabolic_energy_req_activity
#>                                <num>                         <num>
#>  1:                        46.287258                  0.0006129451
#>  2:                        13.489726                  0.0001786336
#>  3:                        31.450484                  0.0004164736
#>  4:                        61.606045                  0.0008157996
#>  5:                        13.489726                  0.0001786336
#>  6:                        30.926747                  0.0004095382
#>  7:                        26.055950                  5.8340573879
#>  8:                        11.455005                  2.5648328054
#>  9:                        20.362994                  4.5593762810
#> 10:                        36.150234                  8.0942180800
#> 11:                        11.455005                  2.5648328054
#> 12:                        21.318239                  4.7732602371
#> 13:                         4.141306                  0.3492021000
#> 14:                         1.984101                  0.1170511745
#> 15:                         3.451551                  0.2524936596
#> 16:                         5.312471                  0.4039789000
#> 17:                         2.009994                  0.1170511745
#> 18:                         3.256855                  0.2296791224
#> 19:                         4.683986                  0.7034861260
#> 20:                         2.240733                  0.2353342523
#> 21:                         3.954959                  0.5302078949
#> 22:                         6.058625                  0.8228797780
#> 23:                         2.295855                  0.2353342523
#> 24:                         4.141448                  0.5458256380
#> 25:                         7.623143                  0.5565700000
#> 26:                         1.670771                  0.0735467500
#> 27:                         3.618307                  0.2060700425
#> 28:                        10.699293                  0.8746100000
#> 29:                         1.670771                  0.0735467500
#> 30:                         3.101698                  0.1678058550
#> 31:                         6.011574                  0.7267500000
#> 32:                         1.588812                  0.1232625000
#> 33:                         3.890689                  0.4068517500
#> 34:                         8.044035                  1.0716000000
#> 35:                         1.588812                  0.1232625000
#> 36:                         4.009928                  0.4235613000
#> 37:                        41.751932                  0.3628660444
#> 38:                         8.934399                  0.0776488604
#> 39:                        23.514565                  0.2043650874
#> 40:                        55.656926                  0.4837143419
#> 41:                         8.934399                  0.0776488604
#> 42:                        23.115016                  0.2008926005
#> 43:                        35.207409                  1.4859639036
#> 44:                         7.900835                  0.3334626627
#> 45:                        21.408505                  0.9035673831
#> 46:                        39.122737                  1.6512142272
#> 47:                         7.900835                  0.3334626627
#> 48:                        13.153025                  0.5551365857
#> 49:                        25.765022                  0.0000000000
#> 50:                         1.277855                  0.0000000000
#> 51:                        10.406721                  0.0000000000
#> 52:                        29.129165                  0.0000000000
#> 53:                         1.277855                  0.0000000000
#> 54:                        10.319752                  0.0000000000
#> 55:                        10.035259                  0.2508814860
#> 56:                         1.134866                  0.0283716547
#> 57:                         6.119631                  0.1529907817
#> 58:                        10.847693                  0.2711923250
#> 59:                         1.134866                  0.0283716547
#> 60:                         6.126148                  0.1531537008
#> 61:                        35.350556                  3.5350556465
#> 62:                        11.014125                  1.1014124635
#> 63:                        26.192277                  2.6192277250
#> 64:                        37.586923                  3.7586923421
#> 65:                        11.014125                  1.1014124635
#> 66:                        27.431184                  2.7431183671
#> 67:                        48.525495                  0.0000000000
#> 68:                        12.853478                  0.0000000000
#> 69:                        34.708378                  0.0000000000
#> 70:                        50.878732                  0.0000000000
#> 71:                        12.853478                  0.0000000000
#> 72:                        36.026300                  0.0000000000
#>     metabolic_energy_req_maintenance metabolic_energy_req_activity
#>                                <num>                         <num>
#>     metabolic_energy_req_growth metabolic_energy_req_lactation
#>                           <num>                          <num>
#>  1:                   0.0000000                     39.6787123
#>  2:                  32.1983739                      0.0000000
#>  3:                  11.0147361                      0.0000000
#>  4:                   0.0000000                      0.0000000
#>  5:                  21.6175258                      0.0000000
#>  6:                  11.6627279                      0.0000000
#>  7:                   0.0000000                      2.8373819
#>  8:                  44.2862193                      0.0000000
#>  9:                   1.5001268                      0.0000000
#> 10:                   0.0000000                      0.0000000
#> 11:                  30.0531238                      0.0000000
#> 12:                   1.9304217                      0.0000000
#> 13:                   0.0000000                      1.8050967
#> 14:                   4.2125146                      0.0000000
#> 15:                   0.5738452                      0.0000000
#> 16:                   0.0000000                      0.0000000
#> 17:                   4.1940037                      0.0000000
#> 18:                   0.2382126                      0.0000000
#> 19:                   0.0000000                      1.3984977
#> 20:                   5.5346096                      0.0000000
#> 21:                   0.6920835                      0.0000000
#> 22:                   0.0000000                      0.0000000
#> 23:                   5.2732851                      0.0000000
#> 24:                   0.6689772                      0.0000000
#> 25:                   0.0000000                      1.5935342
#> 26:                   1.5433958                      0.0000000
#> 27:                   0.7130719                      0.0000000
#> 28:                   0.0000000                      0.0000000
#> 29:                   1.5433958                      0.0000000
#> 30:                   0.3520202                      0.0000000
#> 31:                   0.0000000                      0.6802562
#> 32:                   1.4007192                      0.0000000
#> 33:                   0.7441562                      0.0000000
#> 34:                   0.0000000                      0.0000000
#> 35:                   1.4007192                      0.0000000
#> 36:                   0.7761582                      0.0000000
#> 37:                   0.0000000                      8.6751646
#> 38:                   9.5222412                      0.0000000
#> 39:                   7.0503332                      0.0000000
#> 40:                   0.0000000                      0.0000000
#> 41:                   6.4015613                      0.0000000
#> 42:                   6.7792718                      0.0000000
#> 43:                   0.0000000                     11.4940320
#> 44:                   8.2615771                      0.0000000
#> 45:                   3.9092368                      0.0000000
#> 46:                   0.0000000                      0.0000000
#> 47:                   6.6199666                      0.0000000
#> 48:                   2.0097569                      0.0000000
#> 49:                   0.0000000                      8.4025534
#> 50:                   5.2731667                      0.0000000
#> 51:                  14.9062813                      0.0000000
#> 52:                   0.0000000                      0.0000000
#> 53:                   5.2731667                      0.0000000
#> 54:                  17.6413788                      0.0000000
#> 55:                   0.0000000                      1.4307671
#> 56:                   1.3637500                      0.0000000
#> 57:                   4.1875147                      0.0000000
#> 58:                   0.0000000                      0.0000000
#> 59:                   1.3637500                      0.0000000
#> 60:                   4.6929044                      0.0000000
#> 61:                   0.0000000                      7.2678721
#> 62:                  10.1663784                      0.0000000
#> 63:                   4.3645662                      0.0000000
#> 64:                   0.0000000                      0.0000000
#> 65:                  10.1663784                      0.0000000
#> 66:                   4.9289498                      0.0000000
#> 67:                   0.0000000                     17.2664699
#> 68:                  13.2404384                      0.0000000
#> 69:                  12.4565625                      0.0000000
#> 70:                   0.0000000                      0.0000000
#> 71:                  13.2404384                      0.0000000
#> 72:                  13.5831250                      0.0000000
#>     metabolic_energy_req_growth metabolic_energy_req_lactation
#>                           <num>                          <num>
#>     metabolic_energy_req_work metabolic_energy_req_fibre_production
#>                         <num>                                 <num>
#>  1:                 0.0000000                            0.00000000
#>  2:                 0.0000000                            0.00000000
#>  3:                 0.0000000                            0.00000000
#>  4:                 0.0000000                            0.00000000
#>  5:                 0.0000000                            0.00000000
#>  6:                 0.0000000                            0.00000000
#>  7:                 0.0000000                            0.00000000
#>  8:                 0.0000000                            0.00000000
#>  9:                 0.0000000                            0.00000000
#> 10:                 0.7953051                            0.00000000
#> 11:                 0.0000000                            0.00000000
#> 12:                 0.0000000                            0.00000000
#> 13:                 0.0000000                            0.09863014
#> 14:                 0.0000000                            0.00000000
#> 15:                 0.0000000                            0.09863014
#> 16:                 0.0000000                            0.09863014
#> 17:                 0.0000000                            0.00000000
#> 18:                 0.0000000                            0.09863014
#> 19:                 0.0000000                            0.16438356
#> 20:                 0.0000000                            0.00000000
#> 21:                 0.0000000                            0.16438356
#> 22:                 0.0000000                            0.16438356
#> 23:                 0.0000000                            0.00000000
#> 24:                 0.0000000                            0.16438356
#> 25:                 0.0000000                            0.11835616
#> 26:                 0.0000000                            0.00000000
#> 27:                 0.0000000                            0.11835616
#> 28:                 0.0000000                            0.11835616
#> 29:                 0.0000000                            0.00000000
#> 30:                 0.0000000                            0.11835616
#> 31:                 0.0000000                            0.04931507
#> 32:                 0.0000000                            0.00000000
#> 33:                 0.0000000                            0.04931507
#> 34:                 0.0000000                            0.04931507
#> 35:                 0.0000000                            0.00000000
#> 36:                 0.0000000                            0.04931507
#> 37:                 0.0000000                            0.00000000
#> 38:                 0.0000000                            0.00000000
#> 39:                 0.0000000                            0.00000000
#> 40:                 0.0000000                            0.00000000
#> 41:                 0.0000000                            0.00000000
#> 42:                 0.0000000                            0.00000000
#> 43:                 0.0000000                            0.00000000
#> 44:                 0.0000000                            0.00000000
#> 45:                 0.0000000                            0.00000000
#> 46:                 1.7214004                            0.00000000
#> 47:                 0.0000000                            0.00000000
#> 48:                 0.0000000                            0.00000000
#> 49:                 0.0000000                            0.00000000
#> 50:                 0.0000000                            0.00000000
#> 51:                 0.0000000                            0.00000000
#> 52:                 0.0000000                            0.00000000
#> 53:                 0.0000000                            0.00000000
#> 54:                 0.0000000                            0.00000000
#> 55:                 0.0000000                            0.00000000
#> 56:                 0.0000000                            0.00000000
#> 57:                 0.0000000                            0.00000000
#> 58:                 0.0000000                            0.00000000
#> 59:                 0.0000000                            0.00000000
#> 60:                 0.0000000                            0.00000000
#> 61:                 0.0000000                            0.15291494
#> 62:                 0.0000000                            0.00000000
#> 63:                 0.0000000                            0.15291494
#> 64:                 0.8000000                            0.15291494
#> 65:                 0.0000000                            0.00000000
#> 66:                 0.0000000                            0.15291494
#> 67:                 0.0000000                            0.15291494
#> 68:                 0.0000000                            0.00000000
#> 69:                 0.0000000                            0.15291494
#> 70:                 0.8000000                            0.15291494
#> 71:                 0.0000000                            0.00000000
#> 72:                 0.0000000                            0.15291494
#>     metabolic_energy_req_work metabolic_energy_req_fibre_production
#>                         <num>                                 <num>
#>     metabolic_energy_req_pregnancy
#>                              <num>
#>  1:                     2.87107813
#>  2:                     0.00000000
#>  3:                     0.94395307
#>  4:                     0.00000000
#>  5:                     0.00000000
#>  6:                     0.00000000
#>  7:                     1.38183624
#>  8:                     0.00000000
#>  9:                     0.13954033
#> 10:                     0.00000000
#> 11:                     0.00000000
#> 12:                     0.00000000
#> 13:                     0.12349852
#> 14:                     0.00000000
#> 15:                     0.04932396
#> 16:                     0.00000000
#> 17:                     0.00000000
#> 18:                     0.00000000
#> 19:                     0.11189568
#> 20:                     0.00000000
#> 21:                     0.03162033
#> 22:                     0.00000000
#> 23:                     0.00000000
#> 24:                     0.00000000
#> 25:                     0.19780490
#> 26:                     0.00000000
#> 27:                     0.02648470
#> 28:                     0.00000000
#> 29:                     0.00000000
#> 30:                     0.00000000
#> 31:                     0.25022064
#> 32:                     0.00000000
#> 33:                     0.05107254
#> 34:                     0.00000000
#> 35:                     0.00000000
#> 36:                     0.00000000
#> 37:                     2.83684363
#> 38:                     0.00000000
#> 39:                     0.25146582
#> 40:                     0.00000000
#> 41:                     0.00000000
#> 42:                     0.00000000
#> 43:                     2.49683228
#> 44:                     0.00000000
#> 45:                     0.41052338
#> 46:                     0.00000000
#> 47:                     0.00000000
#> 48:                     0.00000000
#> 49:                     1.48558190
#> 50:                     0.00000000
#> 51:                     0.03369747
#> 52:                     0.00000000
#> 53:                     0.00000000
#> 54:                     0.00000000
#> 55:                     0.52907566
#> 56:                     0.00000000
#> 57:                     0.01703001
#> 58:                     0.00000000
#> 59:                     0.00000000
#> 60:                     0.00000000
#> 61:                     1.82408871
#> 62:                     0.00000000
#> 63:                     0.55972538
#> 64:                     0.00000000
#> 65:                     0.00000000
#> 66:                     0.00000000
#> 67:                     4.83313927
#> 68:                     0.00000000
#> 69:                     1.26902505
#> 70:                     0.00000000
#> 71:                     0.00000000
#> 72:                     0.00000000
#>     metabolic_energy_req_pregnancy
#>                              <num>
#>     net_energy_maintenance_digestible_energy_ratio
#>                                              <num>
#>  1:                                      0.5313640
#>  2:                                      0.5703707
#>  3:                                      0.5313640
#>  4:                                      0.5313640
#>  5:                                      0.5703707
#>  6:                                      0.5313640
#>  7:                                      0.4818171
#>  8:                                      0.5703707
#>  9:                                      0.4818171
#> 10:                                      0.4818171
#> 11:                                      0.5703707
#> 12:                                      0.4818171
#> 13:                                      0.5113743
#> 14:                                      0.5702122
#> 15:                                      0.5113743
#> 16:                                      0.5113743
#> 17:                                      0.5702122
#> 18:                                      0.5113743
#> 19:                                      0.4774136
#> 20:                                      0.5702122
#> 21:                                      0.4774136
#> 22:                                      0.4774136
#> 23:                                      0.5702122
#> 24:                                      0.4774136
#> 25:                                      0.5247185
#> 26:                                      0.5703707
#> 27:                                      0.5247185
#> 28:                                      0.5247185
#> 29:                                      0.5703707
#> 30:                                      0.5247185
#> 31:                                      0.4745590
#> 32:                                      0.5703707
#> 33:                                      0.4745590
#> 34:                                      0.4745590
#> 35:                                      0.5703707
#> 36:                                      0.4745590
#> 37:                                      0.5245362
#> 38:                                      0.5702600
#> 39:                                      0.5245362
#> 40:                                      0.5245362
#> 41:                                      0.5702600
#> 42:                                      0.5245362
#> 43:                                      0.4622809
#> 44:                                      0.5702600
#> 45:                                      0.4622809
#> 46:                                      0.4622809
#> 47:                                      0.5702600
#> 48:                                      0.4622809
#> 49:                                             NA
#> 50:                                             NA
#> 51:                                             NA
#> 52:                                             NA
#> 53:                                             NA
#> 54:                                             NA
#> 55:                                             NA
#> 56:                                             NA
#> 57:                                             NA
#> 58:                                             NA
#> 59:                                             NA
#> 60:                                             NA
#> 61:                                             NA
#> 62:                                             NA
#> 63:                                             NA
#> 64:                                             NA
#> 65:                                             NA
#> 66:                                             NA
#> 67:                                             NA
#> 68:                                             NA
#> 69:                                             NA
#> 70:                                             NA
#> 71:                                             NA
#> 72:                                             NA
#>     net_energy_maintenance_digestible_energy_ratio
#>                                              <num>
#>     net_energy_growth_digestible_energy_ratio metabolic_energy_req_total
#>                                         <num>                      <num>
#>  1:                                 0.3366230                 235.631255
#>  2:                                 0.4013328                 106.805914
#>  3:                                 0.3366230                 132.040173
#>  4:                                 0.3366230                 163.404819
#>  5:                                 0.4013328                  79.698986
#>  6:                                 0.3366230                 130.860305
#>  7:                                 0.2579456                 130.977044
#>  8:                                 0.4013328                 138.728872
#>  9:                                 0.2579456                 101.069589
#> 10:                                 0.2579456                 163.370281
#> 11:                                 0.4013328                 102.265302
#> 12:                                 0.2579456                 107.719552
#> 13:                                 0.3045771                  20.029290
#> 14:                                 0.4010622                  14.618203
#> 15:                                 0.3045771                  14.851340
#> 16:                                 0.3045771                  17.891964
#> 17:                                 0.4010622                  14.617434
#> 18:                                 0.3045771                  12.325590
#> 19:                                 0.2510549                  26.802645
#> 20:                                 0.4010622                  18.692005
#> 21:                                 0.2510549                  22.843874
#> 22:                                 0.2510549                  26.741829
#> 23:                                 0.4010622                  18.120278
#> 24:                                 0.2510549                  23.314269
#> 25:                                 0.3259111                  28.272900
#> 26:                                 0.4013328                   7.098369
#> 27:                                 0.3259111                  14.438782
#> 28:                                 0.3259111                  32.732552
#> 29:                                 0.4013328                   7.098369
#> 30:                                 0.3259111                  11.203905
#> 31:                                 0.2465946                  29.315720
#> 32:                                 0.4013328                   6.674726
#> 33:                                 0.2465946                  22.186279
#> 34:                                 0.2465946                  34.778960
#> 35:                                 0.4013328                   6.674726
#> 36:                                 0.2465946                  22.739320
#> 37:                                 0.3256180                 149.397791
#> 38:                                 0.4011437                  40.713963
#> 39:                                 0.3256180                  98.418797
#> 40:                                 0.3256180                 156.401027
#> 41:                                 0.4011437                  32.703761
#> 42:                                 0.3256180                  95.379015
#> 43:                                 0.2274637                 204.459533
#> 44:                                 0.4011437                  36.073770
#> 45:                                 0.2274637                 123.712077
#> 46:                                 0.2274637                 171.425678
#> 47:                                 0.4011437                  31.860062
#> 48:                                 0.2274637                  71.775302
#> 49:                                        NA                  35.653157
#> 50:                                        NA                   6.551021
#> 51:                                        NA                  25.346700
#> 52:                                        NA                  29.129165
#> 53:                                        NA                   6.551021
#> 54:                                        NA                  27.961131
#> 55:                                        NA                  12.245984
#> 56:                                        NA                   2.526988
#> 57:                                        NA                  10.477167
#> 58:                                        NA                  11.118885
#> 59:                                        NA                   2.526988
#> 60:                                        NA                  10.972206
#> 61:                                        NA                  48.130488
#> 62:                                        NA                  22.281915
#> 63:                                        NA                  33.888712
#> 64:                                        NA                  42.298531
#> 65:                                        NA                  22.281915
#> 66:                                        NA                  35.256167
#> 67:                                        NA                  70.778019
#> 68:                                        NA                  26.093917
#> 69:                                        NA                  48.586880
#> 70:                                        NA                  51.831647
#> 71:                                        NA                  26.093917
#> 72:                                        NA                  49.762340
#>     net_energy_growth_digestible_energy_ratio metabolic_energy_req_total
#>                                         <num>                      <num>
#>     ration_intake ch4_mitigation_factor ch4_conversion_factor_ym ch4_enteric
#>             <num>                 <num>                    <num>       <num>
#>  1:    12.5415826                     1                 6.202339 0.262617234
#>  2:     4.8769824                     1                 0.000000 0.000000000
#>  3:     7.0278994                     1                 6.202339 0.147162248
#>  4:     8.6972972                     1                 6.202339 0.182118970
#>  5:     3.6392231                     1                 0.000000 0.000000000
#>  6:     6.9651003                     1                 6.202339 0.145847253
#>  7:     7.3376495                     1                 6.889047 0.162139616
#>  8:     6.3346517                     1                 0.000000 0.000000000
#>  9:     5.6621619                     1                 6.889047 0.125116462
#> 10:     9.1523967                     1                 6.889047 0.202239978
#> 11:     4.6696485                     1                 0.000000 0.000000000
#> 12:     6.0347088                     1                 6.889047 0.133348610
#> 13:     1.0996646                     1                 6.535588 0.023522585
#> 14:     0.7165786                     1                 0.000000 0.000000000
#> 15:     0.8153805                     1                 4.535588 0.012104143
#> 16:     0.9823193                     1                 6.535588 0.021012489
#> 17:     0.7165409                     1                 0.000000 0.000000000
#> 18:     0.6767097                     1                 4.535588 0.010045606
#> 19:     1.4949325                     1                 6.932521 0.033389020
#> 20:     0.9162748                     1                 0.000000 0.000000000
#> 21:     1.2741298                     1                 4.932521 0.020247598
#> 22:     1.4915405                     1                 6.932521 0.033313259
#> 23:     0.8882489                     1                 0.000000 0.000000000
#> 24:     1.3003664                     1                 4.932521 0.020664532
#> 25:     1.5400861                     1                 6.325197 0.032135069
#> 26:     0.3241264                     1                 0.000000 0.000000000
#> 27:     0.7865117                     1                 4.325197 0.011222026
#> 28:     1.7830130                     1                 6.325197 0.037203924
#> 29:     0.3241264                     1                 0.000000 0.000000000
#> 30:     0.6103009                     1                 4.325197 0.008707834
#> 31:     1.6423373                     1                 6.959717 0.036662913
#> 32:     0.3047820                     1                 0.000000 0.000000000
#> 33:     1.2429288                     1                 4.959717 0.019773165
#> 34:     1.9484011                     1                 6.959717 0.043495366
#> 35:     0.3047820                     1                 0.000000 0.000000000
#> 36:     1.2739115                     1                 4.959717 0.020266054
#> 37:     7.9096670                     1                 6.328376 0.169891346
#> 38:     1.6754717                     1                 0.000000 0.000000000
#> 39:     5.2106521                     1                 6.328376 0.111919339
#> 40:     8.2804440                     1                 6.328376 0.177855247
#> 41:     1.3458338                     1                 0.000000 0.000000000
#> 42:     5.0497149                     1                 6.328376 0.108462576
#> 43:    11.2063323                     1                 7.068798 0.259709441
#> 44:     1.4845173                     1                 0.000000 0.000000000
#> 45:     6.7806016                     1                 7.068798 0.157142070
#> 46:     9.3957620                     1                 7.068798 0.217749039
#> 47:     1.3111137                     1                 0.000000 0.000000000
#> 48:     3.9339711                     1                 7.068798 0.091170723
#> 49:     2.5134407                     1                 1.010000 0.008601961
#> 50:     0.2718266                     1                 0.000000 0.000000000
#> 51:     1.7868664                     1                 0.390000 0.002361370
#> 52:     2.0535188                     1                 1.010000 0.007027931
#> 53:     0.2718266                     1                 0.000000 0.000000000
#> 54:     1.9711760                     1                 0.390000 0.002604938
#> 55:     1.3260405                     1                 1.010000 0.004388767
#> 56:     0.1048543                     1                 0.000000 0.000000000
#> 57:     1.1345064                     1                 0.390000 0.001449893
#> 58:     1.2039941                     1                 1.010000 0.003984833
#> 59:     0.1048543                     1                 0.000000 0.000000000
#> 60:     1.1881111                     1                 0.390000 0.001518400
#> 61:     5.4411784                     1                 6.684276 0.118554889
#> 62:     1.0764210                     1                 0.000000 0.000000000
#> 63:     3.8311377                     1                 4.684276 0.058498182
#> 64:     4.7818724                     1                 6.684276 0.104189628
#> 65:     1.0764210                     1                 0.000000 0.000000000
#> 66:     3.9857293                     1                 4.684276 0.060858662
#> 67:     8.1427048                     1                 6.765529 0.179336060
#> 68:     1.2605757                     1                 0.000000 0.000000000
#> 69:     5.5897103                     1                 4.765529 0.086715674
#> 70:     5.9630067                     1                 6.765529 0.131330086
#> 71:     1.2605757                     1                 0.000000 0.000000000
#> 72:     5.7249419                     1                 4.765529 0.088813581
#>     ration_intake ch4_mitigation_factor ch4_conversion_factor_ym ch4_enteric
#>             <num>                 <num>                    <num>       <num>
#>     nitrogen_intake nitrogen_retention nitrogen_excretion volatile_solids
#>               <num>              <num>              <num>           <num>
#>  1:      0.26344849       0.1383840000        0.125064485      5.04301398
#>  2:      0.20044398       0.1135566667        0.086887309      0.32069753
#>  3:      0.14762805       0.0197436620        0.127884392      2.82594276
#>  4:      0.18269542       0.0000000000        0.182695424      3.49721342
#>  5:      0.14957207       0.1135566667        0.036015403      0.23930574
#>  6:      0.14630890       0.0305797183        0.115729179      2.80069105
#>  7:      0.12045485       0.0000000000        0.120454855      3.84673157
#>  8:      0.26035419       0.1119266667        0.148427519      0.41655004
#>  9:      0.09295005       0.0030271429        0.089922906      2.96836428
#> 10:      0.15024574       0.0000000000        0.150245744      4.79810504
#> 11:      0.19192255       0.1119266667        0.079995887      0.30706380
#> 12:      0.09906578       0.0053557143        0.093710066      3.16367044
#> 13:      0.02207665       0.0025180449        0.019558601      0.50646315
#> 14:      0.03482572       0.0111843333        0.023641386      0.04719909
#> 15:      0.01636942       0.0017694349        0.014599981      0.37553286
#> 16:      0.01972085       0.0005506849        0.019170161      0.45241844
#> 17:      0.03482389       0.0111843333        0.023639555      0.04719661
#> 18:      0.01358549       0.0022337206        0.011351767      0.31166642
#> 19:      0.02520606       0.0009178082        0.024288249      0.79323391
#> 20:      0.04453095       0.0129090000        0.031621953      0.06035254
#> 21:      0.02148310       0.0018932940        0.019589809      0.67607266
#> 22:      0.02514886       0.0009178082        0.024231055      0.79143404
#> 23:      0.04316890       0.0129090000        0.030259897      0.05850655
#> 24:      0.02192548       0.0022897066        0.019635771      0.68999418
#> 25:      0.04148992       0.0079504219        0.033539497      0.66707566
#> 26:      0.01332160       0.0049833333        0.008338262      0.02131370
#> 27:      0.02118863       0.0041066051        0.017082021      0.34067111
#> 28:      0.04803437       0.0006608219        0.047373547      0.77229744
#> 29:      0.01332160       0.0049833333        0.008338262      0.02131370
#> 30:      0.01644151       0.0066126291        0.009828878      0.26434685
#> 31:      0.02570258       0.0002753425        0.025427236      0.87810131
#> 32:      0.01252654       0.0046366667        0.007889874      0.02004166
#> 33:      0.01945184       0.0019810162        0.017470819      0.66455132
#> 34:      0.03049248       0.0002753425        0.030217135      1.04174313
#> 35:      0.01252654       0.0046366667        0.007889874      0.02004166
#> 36:      0.01993671       0.0029273425        0.017009372      0.68111670
#> 37:      0.16282208       0.0172979200        0.145524158      3.34348177
#> 38:      0.07455849       0.0499866667        0.024571825      0.11260229
#> 39:      0.10726232       0.0157310062        0.091531310      2.20258581
#> 40:      0.17045460       0.0000000000        0.170454596      3.50021228
#> 41:      0.05988960       0.0499866667        0.009902936      0.09044854
#> 42:      0.10394939       0.0224250513        0.081524340      2.13455632
#> 43:      0.16199426       0.0285040000        0.133490257      6.10733458
#> 44:      0.06606102       0.0420540000        0.024007018      0.09976894
#> 45:      0.09801766       0.0085691429        0.089448522      3.69535738
#> 46:      0.13582138       0.0000000000        0.135821377      5.12059259
#> 47:      0.05834456       0.0420540000        0.016290558      0.08811513
#> 48:      0.05686791       0.0090814286        0.047786484      2.14397332
#> 49:      0.08782716       0.0153361812        0.072490979      0.58976477
#> 50:      0.01272149       0.0053703704        0.007351115      0.01720513
#> 51:      0.06243847       0.0156220503        0.046816423      0.41927818
#> 52:      0.07175611       0.0000000000        0.071756108      0.48184667
#> 53:      0.01272149       0.0053703704        0.007351115      0.01720513
#> 54:      0.06887880       0.0179665738        0.050912228      0.46252538
#> 55:      0.03104950       0.0046810176        0.026368485      0.63218727
#> 56:      0.00490718       0.0013888889        0.003518291      0.00663670
#> 57:      0.02656469       0.0044659064        0.022098788      0.54087378
#> 58:      0.02819176       0.0000000000        0.028191762      0.57400189
#> 59:      0.00490718       0.0013888889        0.003518291      0.00663670
#> 60:      0.02781986       0.0047794118        0.023040448      0.56642972
#> 61:      0.11829122       0.0237191233        0.094572096      2.68784762
#> 62:      0.04305684       0.0064156757        0.036641166      0.06978001
#> 63:      0.08328893       0.0031214612        0.080167472      1.89251546
#> 64:      0.10395791       0.0003671233        0.103590783      2.36216191
#> 65:      0.04305684       0.0064156757        0.036641166      0.06978001
#> 66:      0.08664975       0.0034776256        0.083172129      1.96888102
#> 67:      0.14340932       0.0547991233        0.088610194      4.06863644
#> 68:      0.05042303       0.0083556164        0.042067411      0.08171801
#> 69:      0.09844598       0.0082280608        0.090217917      2.79299073
#> 70:      0.10502047       0.0003671233        0.104653351      2.97951441
#> 71:      0.05042303       0.0083556164        0.042067411      0.08171801
#> 72:      0.10082768       0.0089389983        0.091888678      2.86056140
#>     nitrogen_intake nitrogen_retention nitrogen_excretion volatile_solids
#>               <num>              <num>              <num>           <num>
#>     ch4_manure_pasture ch4_manure_burned ch4_manure_other ch4_manure_all_noburn
#>                  <num>             <num>            <num>                 <num>
#>  1:       0.000000e+00      0.0000000000     1.575611e-01          1.575611e-01
#>  2:       0.000000e+00      0.0000000000     1.001969e-02          1.001969e-02
#>  3:       0.000000e+00      0.0000000000     8.829217e-02          8.829217e-02
#>  4:       0.000000e+00      0.0000000000     1.092650e-01          1.092650e-01
#>  5:       0.000000e+00      0.0000000000     7.476735e-03          7.476735e-03
#>  6:       0.000000e+00      0.0000000000     8.750322e-02          8.750322e-02
#>  7:       1.380923e-03      0.0033505032     3.015453e-03          4.396376e-03
#>  8:       1.495356e-04      0.0003628151     3.265336e-04          4.760692e-04
#>  9:       1.065601e-03      0.0025854453     2.326901e-03          3.392502e-03
#> 10:       1.722453e-03      0.0041791495     3.761235e-03          5.483687e-03
#> 11:       1.102316e-04      0.0002674526     2.407073e-04          3.509389e-04
#> 12:       1.135713e-03      0.0027555570     2.480001e-03          3.615715e-03
#> 13:       1.212088e-04      0.0000000000     7.092004e-04          8.304091e-04
#> 14:       1.129588e-05      0.0000000000     6.609289e-05          7.738877e-05
#> 15:       8.987403e-05      0.0000000000     5.258587e-04          6.157327e-04
#> 16:       1.082746e-04      0.0000000000     6.335215e-04          7.417961e-04
#> 17:       1.129528e-05      0.0000000000     6.608941e-05          7.738470e-05
#> 18:       7.458925e-05      0.0000000000     4.364265e-04          5.110157e-04
#> 19:       2.372999e-04      0.0000000000     5.181801e-04          7.554799e-04
#> 20:       1.805476e-05      0.0000000000     3.942530e-05          5.748006e-05
#> 21:       2.022505e-04      0.0000000000     4.416445e-04          6.438950e-04
#> 22:       2.367615e-04      0.0000000000     5.170043e-04          7.537657e-04
#> 23:       1.750253e-05      0.0000000000     3.821941e-05          5.572193e-05
#> 24:       2.064152e-04      0.0000000000     4.507387e-04          6.571539e-04
#> 25:       1.596472e-04      0.0000000000     8.849426e-04          1.044590e-03
#> 26:       5.100880e-06      0.0000000000     2.827476e-05          3.337564e-05
#> 27:       8.153077e-05      0.0000000000     4.519343e-04          5.334651e-04
#> 28:       1.848293e-04      0.0000000000     1.024530e-03          1.209359e-03
#> 29:       5.100880e-06      0.0000000000     2.827476e-05          3.337564e-05
#> 30:       6.326455e-05      0.0000000000     3.506825e-04          4.139471e-04
#> 31:       2.626884e-04      0.0000000000     1.529652e-03          1.792341e-03
#> 32:       5.995564e-06      0.0000000000     3.491258e-05          4.090814e-05
#> 33:       1.988039e-04      0.0000000000     1.157648e-03          1.356452e-03
#> 34:       3.116427e-04      0.0000000000     1.814717e-03          2.126359e-03
#> 35:       5.995564e-06      0.0000000000     3.491258e-05          4.090814e-05
#> 36:       2.037595e-04      0.0000000000     1.186505e-03          1.390265e-03
#> 37:       2.000439e-04      0.0000000000     3.292995e-02          3.313000e-02
#> 38:       6.737108e-06      0.0000000000     1.109020e-03          1.115757e-03
#> 39:       1.317829e-04      0.0000000000     2.169327e-02          2.182505e-02
#> 40:       2.094212e-04      0.0000000000     3.447359e-02          3.468301e-02
#> 41:       5.411626e-06      0.0000000000     8.908276e-04          8.962393e-04
#> 42:       1.277126e-04      0.0000000000     2.102325e-02          2.115096e-02
#> 43:       7.308159e-04      0.0081838283     4.910297e-03          5.641113e-03
#> 44:       1.193855e-05      0.0001336904     8.021423e-05          9.215278e-05
#> 45:       4.421939e-04      0.0049517789     2.971067e-03          3.413261e-03
#> 46:       6.127404e-04      0.0068615941     4.116956e-03          4.729697e-03
#> 47:       1.054403e-05      0.0001180743     7.084456e-05          8.138859e-05
#> 48:       2.565521e-04      0.0028729242     1.723755e-03          1.980307e-03
#> 49:       7.057243e-06      0.0000000000     2.096659e-02          2.097365e-02
#> 50:       2.058801e-07      0.0000000000     6.116557e-04          6.118616e-04
#> 51:       5.017167e-06      0.0000000000     1.490566e-02          1.491068e-02
#> 52:       5.765874e-06      0.0000000000     1.713002e-02          1.713579e-02
#> 53:       2.058801e-07      0.0000000000     6.116557e-04          6.118616e-04
#> 54:       5.534671e-06      0.0000000000     1.644313e-02          1.644867e-02
#> 55:       1.891220e-05      0.0000000000     4.337207e-02          4.339098e-02
#> 56:       1.985402e-07      0.0000000000     4.553198e-04          4.555183e-04
#> 57:       1.618051e-05      0.0000000000     3.710738e-02          3.712356e-02
#> 58:       1.717155e-05      0.0000000000     3.938018e-02          3.939735e-02
#> 59:       1.985402e-07      0.0000000000     4.553198e-04          4.555183e-04
#> 60:       1.694503e-05      0.0000000000     3.886068e-02          3.887763e-02
#> 61:       1.238288e-03      0.0000000000     4.008710e-03          5.246998e-03
#> 62:       3.214756e-05      0.0000000000     1.040713e-04          1.362189e-04
#> 63:       8.718794e-04      0.0000000000     2.822535e-03          3.694415e-03
#> 64:       1.088245e-03      0.0000000000     3.522976e-03          4.611220e-03
#> 65:       3.214756e-05      0.0000000000     1.040713e-04          1.362189e-04
#> 66:       9.070609e-04      0.0000000000     2.936429e-03          3.843489e-03
#> 67:       1.217153e-03      0.0000000000     5.724571e-03          6.941724e-03
#> 68:       2.444635e-05      0.0000000000     1.149772e-04          1.394236e-04
#> 69:       8.355371e-04      0.0000000000     3.929738e-03          4.765275e-03
#> 70:       8.913366e-04      0.0000000000     4.192177e-03          5.083513e-03
#> 71:       2.444635e-05      0.0000000000     1.149772e-04          1.394236e-04
#> 72:       8.557512e-04      0.0000000000     4.024810e-03          4.880561e-03
#>     ch4_manure_pasture ch4_manure_burned ch4_manure_other ch4_manure_all_noburn
#>                  <num>             <num>            <num>                 <num>
#>     n2o_manure_pasture_direct n2o_manure_burned_direct n2o_manure_other_direct
#>                         <num>                    <num>                   <num>
#>  1:              0.000000e+00                        0            2.362289e-03
#>  2:              0.000000e+00                        0            1.641177e-03
#>  3:              0.000000e+00                        0            2.415553e-03
#>  4:              0.000000e+00                        0            3.450856e-03
#>  5:              0.000000e+00                        0            6.802795e-04
#>  6:              0.000000e+00                        0            2.185959e-03
#>  7:              2.271434e-04                        0            9.464310e-04
#>  8:              2.798919e-04                        0            1.166216e-03
#>  9:              1.695689e-04                        0            7.065371e-04
#> 10:              2.833205e-04                        0            1.180502e-03
#> 11:              1.508494e-04                        0            6.285391e-04
#> 12:              1.767104e-04                        0            7.362934e-04
#> 13:              3.688193e-05                        0            2.919820e-04
#> 14:              4.458090e-05                        0            3.529321e-04
#> 15:              2.753139e-05                        0            2.179569e-04
#> 16:              3.614945e-05                        0            2.861831e-04
#> 17:              4.457745e-05                        0            3.529048e-04
#> 18:              2.140619e-05                        0            1.694657e-04
#> 19:              5.725087e-05                        0            3.816725e-04
#> 20:              7.453746e-05                        0            4.969164e-04
#> 21:              4.617598e-05                        0            3.078399e-04
#> 22:              5.711606e-05                        0            3.807737e-04
#> 23:              7.132690e-05                        0            4.755127e-04
#> 24:              4.628432e-05                        0            3.085621e-04
#> 25:              6.324591e-05                        0            5.006968e-04
#> 26:              1.572358e-05                        0            1.244783e-04
#> 27:              3.221181e-05                        0            2.550102e-04
#> 28:              8.933297e-05                        0            7.072194e-04
#> 29:              1.572358e-05                        0            1.244783e-04
#> 30:              1.853446e-05                        0            1.467311e-04
#> 31:              5.993563e-05                        0            1.997854e-04
#> 32:              1.859756e-05                        0            6.199186e-05
#> 33:              4.118122e-05                        0            1.372707e-04
#> 34:              7.122610e-05                        0            2.374203e-04
#> 35:              1.859756e-05                        0            6.199186e-05
#> 36:              4.009352e-05                        0            1.336451e-04
#> 37:              4.573616e-05                        0            1.372085e-03
#> 38:              7.722574e-06                        0            2.316772e-04
#> 39:              2.876698e-05                        0            8.630095e-04
#> 40:              5.357144e-05                        0            1.607143e-03
#> 41:              3.112351e-06                        0            9.337054e-05
#> 42:              2.562194e-05                        0            7.686581e-04
#> 43:              8.390816e-05                        0            2.517245e-03
#> 44:              1.509013e-05                        0            4.527038e-04
#> 45:              5.622479e-05                        0            1.686744e-03
#> 46:              8.537344e-05                        0            2.561203e-03
#> 47:              1.023978e-05                        0            3.071934e-04
#> 48:              3.003722e-05                        0            9.011165e-04
#> 49:              1.366973e-05                        0            5.515735e-04
#> 50:              1.386210e-06                        0            5.593359e-05
#> 51:              8.828240e-06                        0            3.562195e-04
#> 52:              1.353115e-05                        0            5.459820e-04
#> 53:              1.386210e-06                        0            5.593359e-05
#> 54:              9.600591e-06                        0            3.873839e-04
#> 55:              1.243086e-05                        0            1.877059e-04
#> 56:              1.658623e-06                        0            2.504520e-05
#> 57:              1.041800e-05                        0            1.573118e-04
#> 58:              1.329040e-05                        0            2.006851e-04
#> 59:              1.658623e-06                        0            2.504520e-05
#> 60:              1.086193e-05                        0            1.640151e-04
#> 61:              3.432967e-04                        0            3.863946e-04
#> 62:              1.330074e-04                        0            1.497053e-04
#> 63:              2.910079e-04                        0            3.275414e-04
#> 64:              3.760345e-04                        0            4.232423e-04
#> 65:              1.330074e-04                        0            1.497053e-04
#> 66:              3.019148e-04                        0            3.398176e-04
#> 67:              2.088669e-04                        0            1.392446e-03
#> 68:              9.915890e-05                        0            6.610593e-04
#> 69:              2.126565e-04                        0            1.417710e-03
#> 70:              2.466829e-04                        0            1.644553e-03
#> 71:              9.915890e-05                        0            6.610593e-04
#> 72:              2.165947e-04                        0            1.443965e-03
#>     n2o_manure_pasture_direct n2o_manure_burned_direct n2o_manure_other_direct
#>                         <num>                    <num>                   <num>
#>     n2o_manure_all_noburn_direct n2o_manure_pasture_vol n2o_manure_burned_vol
#>                            <num>                  <num>                 <num>
#>  1:                 2.362289e-03           0.000000e+00                     0
#>  2:                 1.641177e-03           0.000000e+00                     0
#>  3:                 2.415553e-03           0.000000e+00                     0
#>  4:                 3.450856e-03           0.000000e+00                     0
#>  5:                 6.802795e-04           0.000000e+00                     0
#>  6:                 2.185959e-03           0.000000e+00                     0
#>  7:                 1.173574e-03           1.192503e-04                     0
#>  8:                 1.446108e-03           1.469432e-04                     0
#>  9:                 8.761060e-04           8.902368e-05                     0
#> 10:                 1.463823e-03           1.487433e-04                     0
#> 11:                 7.793885e-04           7.919593e-05                     0
#> 12:                 9.130038e-04           9.277297e-05                     0
#> 13:                 3.288639e-04           1.290868e-05                     0
#> 14:                 3.975130e-04           1.560331e-05                     0
#> 15:                 2.454883e-04           9.635987e-06                     0
#> 16:                 3.223326e-04           1.265231e-05                     0
#> 17:                 3.974822e-04           1.560211e-05                     0
#> 18:                 1.908719e-04           7.492166e-06                     0
#> 19:                 4.389234e-04           2.003781e-05                     0
#> 20:                 5.714539e-04           2.608811e-05                     0
#> 21:                 3.540158e-04           1.616159e-05                     0
#> 22:                 4.378898e-04           1.999062e-05                     0
#> 23:                 5.468396e-04           2.496442e-05                     0
#> 24:                 3.548464e-04           1.619951e-05                     0
#> 25:                 5.639427e-04           2.213607e-05                     0
#> 26:                 1.402019e-04           5.503253e-06                     0
#> 27:                 2.872220e-04           1.127413e-05                     0
#> 28:                 7.965524e-04           3.126654e-05                     0
#> 29:                 1.402019e-04           5.503253e-06                     0
#> 30:                 1.652656e-04           6.487060e-06                     0
#> 31:                 2.597210e-04           2.097747e-05                     0
#> 32:                 8.058942e-05           6.509146e-06                     0
#> 33:                 1.784519e-04           1.441343e-05                     0
#> 34:                 3.086464e-04           2.492914e-05                     0
#> 35:                 8.058942e-05           6.509146e-06                     0
#> 36:                 1.737386e-04           1.403273e-05                     0
#> 37:                 1.417821e-03           2.401149e-05                     0
#> 38:                 2.393998e-04           4.054351e-06                     0
#> 39:                 8.917765e-04           1.510267e-05                     0
#> 40:                 1.660715e-03           2.812501e-05                     0
#> 41:                 9.648289e-05           1.633984e-06                     0
#> 42:                 7.942800e-04           1.345152e-05                     0
#> 43:                 2.601153e-03           4.405178e-05                     0
#> 44:                 4.677939e-04           7.922316e-06                     0
#> 45:                 1.742968e-03           2.951801e-05                     0
#> 46:                 2.646577e-03           4.482105e-05                     0
#> 47:                 3.174332e-04           5.375884e-06                     0
#> 48:                 9.311538e-04           1.576954e-05                     0
#> 49:                 5.652432e-04           6.698166e-06                     0
#> 50:                 5.731980e-05           6.792431e-07                     0
#> 51:                 3.650477e-04           4.325837e-06                     0
#> 52:                 5.595131e-04           6.630264e-06                     0
#> 53:                 5.731980e-05           6.792431e-07                     0
#> 54:                 3.969845e-04           4.704290e-06                     0
#> 55:                 2.001368e-04           6.091120e-06                     0
#> 56:                 2.670383e-05           8.127252e-07                     0
#> 57:                 1.677298e-04           5.104820e-06                     0
#> 58:                 2.139755e-04           6.512297e-06                     0
#> 59:                 2.670383e-05           8.127252e-07                     0
#> 60:                 1.748770e-04           5.322343e-06                     0
#> 61:                 7.296913e-04           1.201538e-04                     0
#> 62:                 2.827128e-04           4.655260e-05                     0
#> 63:                 6.185493e-04           1.018528e-04                     0
#> 64:                 7.992769e-04           1.316121e-04                     0
#> 65:                 2.827128e-04           4.655260e-05                     0
#> 66:                 6.417324e-04           1.056702e-04                     0
#> 67:                 1.601313e-03           7.310341e-05                     0
#> 68:                 7.602182e-04           3.470561e-05                     0
#> 69:                 1.630367e-03           7.442978e-05                     0
#> 70:                 1.891236e-03           8.633901e-05                     0
#> 71:                 7.602182e-04           3.470561e-05                     0
#> 72:                 1.660560e-03           7.580816e-05                     0
#>     n2o_manure_all_noburn_direct n2o_manure_pasture_vol n2o_manure_burned_vol
#>                            <num>                  <num>                 <num>
#>     n2o_manure_other_vol n2o_manure_all_noburn_vol n2o_manure_pasture_leach
#>                    <num>                     <num>                    <num>
#>  1:         3.120895e-04              3.120895e-04             0.000000e+00
#>  2:         2.168211e-04              2.168211e-04             0.000000e+00
#>  3:         3.191264e-04              3.191264e-04             0.000000e+00
#>  4:         4.559034e-04              4.559034e-04             0.000000e+00
#>  5:         8.987387e-05              8.987387e-05             0.000000e+00
#>  6:         2.887939e-04              2.887939e-04             0.000000e+00
#>  7:         9.937526e-05              2.186256e-04             0.000000e+00
#>  8:         1.224527e-04              2.693959e-04             0.000000e+00
#>  9:         7.418640e-05              1.632101e-04             0.000000e+00
#> 10:         1.239527e-04              2.726960e-04             0.000000e+00
#> 11:         6.599661e-05              1.451925e-04             0.000000e+00
#> 12:         7.731080e-05              1.700838e-04             0.000000e+00
#> 13:         2.335856e-05              3.626723e-05             0.000000e+00
#> 14:         2.823457e-05              4.383788e-05             0.000000e+00
#> 15:         1.743655e-05              2.707254e-05             0.000000e+00
#> 16:         2.289465e-05              3.554696e-05             0.000000e+00
#> 17:         2.823238e-05              4.383449e-05             0.000000e+00
#> 18:         1.355725e-05              2.104942e-05             0.000000e+00
#> 19:         2.862544e-05              4.866324e-05             0.000000e+00
#> 20:         3.726873e-05              6.335684e-05             0.000000e+00
#> 21:         2.308799e-05              3.924958e-05             0.000000e+00
#> 22:         2.855803e-05              4.854865e-05             0.000000e+00
#> 23:         3.566345e-05              6.062787e-05             0.000000e+00
#> 24:         2.314216e-05              3.934167e-05             0.000000e+00
#> 25:         4.005574e-05              6.219181e-05             0.000000e+00
#> 26:         9.958268e-06              1.546152e-05             0.000000e+00
#> 27:         2.040081e-05              3.167495e-05             0.000000e+00
#> 28:         5.657755e-05              8.784409e-05             0.000000e+00
#> 29:         9.958268e-06              1.546152e-05             0.000000e+00
#> 30:         1.173849e-05              1.822555e-05             0.000000e+00
#> 31:         1.198713e-05              3.296459e-05             0.000000e+00
#> 32:         3.719512e-06              1.022866e-05             0.000000e+00
#> 33:         8.236243e-06              2.264967e-05             0.000000e+00
#> 34:         1.424522e-05              3.917436e-05             0.000000e+00
#> 35:         3.719512e-06              1.022866e-05             0.000000e+00
#> 36:         8.018704e-06              2.205144e-05             0.000000e+00
#> 37:         4.733693e-04              4.973808e-04             0.000000e+00
#> 38:         7.992864e-05              8.398299e-05             0.000000e+00
#> 39:         2.977383e-04              3.128409e-04             0.000000e+00
#> 40:         5.544645e-04              5.825895e-04             0.000000e+00
#> 41:         3.221284e-05              3.384682e-05             0.000000e+00
#> 42:         2.651870e-04              2.786385e-04             0.000000e+00
#> 43:         1.887934e-04              2.328451e-04             0.000000e+00
#> 44:         3.395278e-05              4.187510e-05             0.000000e+00
#> 45:         1.265058e-04              1.560238e-04             0.000000e+00
#> 46:         1.920902e-04              2.369113e-04             0.000000e+00
#> 47:         2.303950e-05              2.841539e-05             0.000000e+00
#> 48:         6.758374e-05              8.335328e-05             0.000000e+00
#> 49:         6.870883e-04              6.937865e-04             6.014680e-06
#> 50:         6.967578e-05              7.035503e-05             6.099325e-07
#> 51:         4.437382e-04              4.480641e-04             3.884425e-06
#> 52:         6.801231e-04              6.867533e-04             5.953707e-06
#> 53:         6.967578e-05              7.035503e-05             6.099325e-07
#> 54:         4.825593e-04              4.872636e-04             4.224260e-06
#> 55:         1.931465e-04              1.992376e-04             5.469577e-06
#> 56:         2.577113e-05              2.658385e-05             7.297940e-07
#> 57:         1.618714e-04              1.669762e-04             4.583920e-06
#> 58:         2.065018e-04              2.130141e-04             5.847777e-06
#> 59:         2.577113e-05              2.658385e-05             7.297940e-07
#> 60:         1.687690e-04              1.740913e-04             4.779247e-06
#> 61:         2.452119e-05              1.446750e-04             3.021011e-04
#> 62:         9.500531e-06              5.605313e-05             1.170465e-04
#> 63:         2.078628e-05              1.226391e-04             2.560870e-04
#> 64:         2.685961e-05              1.584717e-04             3.309104e-04
#> 65:         9.500531e-06              5.605313e-05             1.170465e-04
#> 66:         2.156534e-05              1.272355e-04             2.656850e-04
#> 67:         1.044334e-04              1.775369e-04             1.838029e-04
#> 68:         4.957945e-05              8.428506e-05             8.725983e-05
#> 69:         1.063283e-04              1.807580e-04             1.871377e-04
#> 70:         1.233414e-04              2.096805e-04             2.170810e-04
#> 71:         4.957945e-05              8.428506e-05             8.725983e-05
#> 72:         1.082974e-04              1.841055e-04             1.906034e-04
#>     n2o_manure_other_vol n2o_manure_all_noburn_vol n2o_manure_pasture_leach
#>                    <num>                     <num>                    <num>
#>     n2o_manure_burned_leach n2o_manure_other_leach n2o_manure_all_noburn_leach
#>                       <num>                  <num>                       <num>
#>  1:                       0           4.972207e-05                4.972207e-05
#>  2:                       0           3.454391e-05                3.454391e-05
#>  3:                       0           5.084318e-05                5.084318e-05
#>  4:                       0           7.263448e-05                7.263448e-05
#>  5:                       0           1.431870e-05                1.431870e-05
#>  6:                       0           4.601061e-05                4.601061e-05
#>  7:                       0           1.873933e-05                1.873933e-05
#>  8:                       0           2.309108e-05                2.309108e-05
#>  9:                       0           1.398943e-05                1.398943e-05
#> 10:                       0           2.337395e-05                2.337395e-05
#> 11:                       0           1.244507e-05                1.244507e-05
#> 12:                       0           1.457861e-05                1.457861e-05
#> 13:                       0           7.437857e-06                7.437857e-06
#> 14:                       0           8.990481e-06                8.990481e-06
#> 15:                       0           5.552164e-06                5.552164e-06
#> 16:                       0           7.290138e-06                7.290138e-06
#> 17:                       0           8.989785e-06                8.989785e-06
#> 18:                       0           4.316915e-06                4.316915e-06
#> 19:                       0           7.347195e-06                7.347195e-06
#> 20:                       0           9.565641e-06                9.565641e-06
#> 21:                       0           5.925917e-06                5.925917e-06
#> 22:                       0           7.329894e-06                7.329894e-06
#> 23:                       0           9.153619e-06                9.153619e-06
#> 24:                       0           5.939821e-06                5.939821e-06
#> 25:                       0           1.275459e-05                1.275459e-05
#> 26:                       0           3.170922e-06                3.170922e-06
#> 27:                       0           6.496049e-06                6.496049e-06
#> 28:                       0           1.801548e-05                1.801548e-05
#> 29:                       0           3.170922e-06                3.170922e-06
#> 30:                       0           3.737782e-06                3.737782e-06
#> 31:                       0           4.395279e-06                4.395279e-06
#> 32:                       0           1.363821e-06                1.363821e-06
#> 33:                       0           3.019956e-06                3.019956e-06
#> 34:                       0           5.223248e-06                5.223248e-06
#> 35:                       0           1.363821e-06                1.363821e-06
#> 36:                       0           2.940191e-06                2.940191e-06
#> 37:                       0           3.018587e-05                3.018587e-05
#> 38:                       0           5.096899e-06                5.096899e-06
#> 39:                       0           1.898621e-05                1.898621e-05
#> 40:                       0           3.535715e-05                3.535715e-05
#> 41:                       0           2.054152e-06                2.054152e-06
#> 42:                       0           1.691048e-05                1.691048e-05
#> 43:                       0           4.845696e-05                4.845696e-05
#> 44:                       0           8.714548e-06                8.714548e-06
#> 45:                       0           3.246981e-05                3.246981e-05
#> 46:                       0           4.930316e-05                4.930316e-05
#> 47:                       0           5.913473e-06                5.913473e-06
#> 48:                       0           1.734649e-05                1.734649e-05
#> 49:                       0           1.365834e-05                1.967302e-05
#> 50:                       0           1.385055e-06                1.994988e-06
#> 51:                       0           8.820883e-06                1.270531e-05
#> 52:                       0           1.351988e-05                1.947358e-05
#> 53:                       0           1.385055e-06                1.994988e-06
#> 54:                       0           9.592591e-06                1.381685e-05
#> 55:                       0           2.962688e-06                8.432265e-06
#> 56:                       0           3.953051e-07                1.125099e-06
#> 57:                       0           2.482957e-06                7.066877e-06
#> 58:                       0           3.167546e-06                9.015323e-06
#> 59:                       0           3.953051e-07                1.125099e-06
#> 60:                       0           2.588759e-06                7.368006e-06
#> 61:                       0           8.255468e-06                3.103566e-04
#> 62:                       0           3.198512e-06                1.202451e-04
#> 63:                       0           6.998048e-06                2.630850e-04
#> 64:                       0           9.042735e-06                3.399531e-04
#> 65:                       0           3.198512e-06                1.202451e-04
#> 66:                       0           7.260333e-06                2.729454e-04
#> 67:                       0           2.680458e-05                2.106074e-04
#> 68:                       0           1.272539e-05                9.998522e-05
#> 69:                       0           2.729092e-05                2.144287e-04
#> 70:                       0           3.165764e-05                2.487386e-04
#> 71:                       0           1.272539e-05                9.998522e-05
#> 72:                       0           2.779633e-05                2.183997e-04
#>     n2o_manure_burned_leach n2o_manure_other_leach n2o_manure_all_noburn_leach
#>                       <num>                  <num>                       <num>
#>     n2o_manure_pasture_indirect n2o_manure_burned_indirect
#>                           <num>                      <num>
#>  1:                0.000000e+00                          0
#>  2:                0.000000e+00                          0
#>  3:                0.000000e+00                          0
#>  4:                0.000000e+00                          0
#>  5:                0.000000e+00                          0
#>  6:                0.000000e+00                          0
#>  7:                1.192503e-04                          0
#>  8:                1.469432e-04                          0
#>  9:                8.902368e-05                          0
#> 10:                1.487433e-04                          0
#> 11:                7.919593e-05                          0
#> 12:                9.277297e-05                          0
#> 13:                1.290868e-05                          0
#> 14:                1.560331e-05                          0
#> 15:                9.635987e-06                          0
#> 16:                1.265231e-05                          0
#> 17:                1.560211e-05                          0
#> 18:                7.492166e-06                          0
#> 19:                2.003781e-05                          0
#> 20:                2.608811e-05                          0
#> 21:                1.616159e-05                          0
#> 22:                1.999062e-05                          0
#> 23:                2.496442e-05                          0
#> 24:                1.619951e-05                          0
#> 25:                2.213607e-05                          0
#> 26:                5.503253e-06                          0
#> 27:                1.127413e-05                          0
#> 28:                3.126654e-05                          0
#> 29:                5.503253e-06                          0
#> 30:                6.487060e-06                          0
#> 31:                2.097747e-05                          0
#> 32:                6.509146e-06                          0
#> 33:                1.441343e-05                          0
#> 34:                2.492914e-05                          0
#> 35:                6.509146e-06                          0
#> 36:                1.403273e-05                          0
#> 37:                2.401149e-05                          0
#> 38:                4.054351e-06                          0
#> 39:                1.510267e-05                          0
#> 40:                2.812501e-05                          0
#> 41:                1.633984e-06                          0
#> 42:                1.345152e-05                          0
#> 43:                4.405178e-05                          0
#> 44:                7.922316e-06                          0
#> 45:                2.951801e-05                          0
#> 46:                4.482105e-05                          0
#> 47:                5.375884e-06                          0
#> 48:                1.576954e-05                          0
#> 49:                1.271285e-05                          0
#> 50:                1.289176e-06                          0
#> 51:                8.210263e-06                          0
#> 52:                1.258397e-05                          0
#> 53:                1.289176e-06                          0
#> 54:                8.928550e-06                          0
#> 55:                1.156070e-05                          0
#> 56:                1.542519e-06                          0
#> 57:                9.688740e-06                          0
#> 58:                1.236007e-05                          0
#> 59:                1.542519e-06                          0
#> 60:                1.010159e-05                          0
#> 61:                4.222550e-04                          0
#> 62:                1.635991e-04                          0
#> 63:                3.579397e-04                          0
#> 64:                4.625225e-04                          0
#> 65:                1.635991e-04                          0
#> 66:                3.713552e-04                          0
#> 67:                2.569063e-04                          0
#> 68:                1.219654e-04                          0
#> 69:                2.615675e-04                          0
#> 70:                3.034200e-04                          0
#> 71:                1.219654e-04                          0
#> 72:                2.664115e-04                          0
#>     n2o_manure_pasture_indirect n2o_manure_burned_indirect
#>                           <num>                      <num>
#>     n2o_manure_other_indirect n2o_manure_pasture_total n2o_manure_burned_total
#>                         <num>                    <num>                   <num>
#>  1:              3.618116e-04             0.000000e+00                       0
#>  2:              2.513650e-04             0.000000e+00                       0
#>  3:              3.699695e-04             0.000000e+00                       0
#>  4:              5.285379e-04             0.000000e+00                       0
#>  5:              1.041926e-04             0.000000e+00                       0
#>  6:              3.348045e-04             0.000000e+00                       0
#>  7:              1.181146e-04             3.463937e-04                       0
#>  8:              1.455438e-04             4.268351e-04                       0
#>  9:              8.817583e-05             2.585926e-04                       0
#> 10:              1.473267e-04             4.320638e-04                       0
#> 11:              7.844168e-05             2.300453e-04                       0
#> 12:              9.188941e-05             2.694834e-04                       0
#> 13:              3.079641e-05             4.979061e-05                       0
#> 14:              3.722505e-05             6.018421e-05                       0
#> 15:              2.298871e-05             3.716738e-05                       0
#> 16:              3.018479e-05             4.880175e-05                       0
#> 17:              3.722217e-05             6.017955e-05                       0
#> 18:              1.787417e-05             2.889836e-05                       0
#> 19:              3.597263e-05             7.728868e-05                       0
#> 20:              4.683437e-05             1.006256e-04                       0
#> 21:              2.901391e-05             6.233757e-05                       0
#> 22:              3.588792e-05             7.710668e-05                       0
#> 23:              4.481707e-05             9.629132e-05                       0
#> 24:              2.908198e-05             6.248383e-05                       0
#> 25:              5.281033e-05             8.538198e-05                       0
#> 26:              1.312919e-05             2.122683e-05                       0
#> 27:              2.689686e-05             4.348594e-05                       0
#> 28:              7.459303e-05             1.205995e-04                       0
#> 29:              1.312919e-05             2.122683e-05                       0
#> 30:              1.547627e-05             2.502152e-05                       0
#> 31:              1.638240e-05             8.091310e-05                       0
#> 32:              5.083333e-06             2.510670e-05                       0
#> 33:              1.125620e-05             5.559464e-05                       0
#> 34:              1.946847e-05             9.615524e-05                       0
#> 35:              5.083333e-06             2.510670e-05                       0
#> 36:              1.095890e-05             5.412625e-05                       0
#> 37:              5.035552e-04             6.974765e-05                       0
#> 38:              8.502554e-05             1.177692e-05                       0
#> 39:              3.167245e-04             4.386965e-05                       0
#> 40:              5.898216e-04             8.169645e-05                       0
#> 41:              3.426699e-05             4.746336e-06                       0
#> 42:              2.820975e-04             3.907345e-05                       0
#> 43:              2.372503e-04             1.279599e-04                       0
#> 44:              4.266733e-05             2.301244e-05                       0
#> 45:              1.589756e-04             8.574280e-05                       0
#> 46:              2.413934e-04             1.301945e-04                       0
#> 47:              2.895298e-05             1.561566e-05                       0
#> 48:              8.493023e-05             4.580676e-05                       0
#> 49:              7.007467e-04             2.638257e-05                       0
#> 50:              7.106084e-05             2.675386e-06                       0
#> 51:              4.525591e-04             1.703850e-05                       0
#> 52:              6.936429e-04             2.611512e-05                       0
#> 53:              7.106084e-05             2.675386e-06                       0
#> 54:              4.921519e-04             1.852914e-05                       0
#> 55:              1.961092e-04             2.399155e-05                       0
#> 56:              2.616643e-05             3.201142e-06                       0
#> 57:              1.643544e-04             2.010674e-05                       0
#> 58:              2.096694e-04             2.565048e-05                       0
#> 59:              2.616643e-05             3.201142e-06                       0
#> 60:              1.713577e-04             2.096352e-05                       0
#> 61:              3.277666e-05             7.655517e-04                       0
#> 62:              1.269904e-05             2.966066e-04                       0
#> 63:              2.778433e-05             6.489477e-04                       0
#> 64:              3.590235e-05             8.385570e-04                       0
#> 65:              1.269904e-05             2.966066e-04                       0
#> 66:              2.882568e-05             6.732701e-04                       0
#> 67:              1.312380e-04             4.657732e-04                       0
#> 68:              6.230484e-05             2.211243e-04                       0
#> 69:              1.336192e-04             4.742240e-04                       0
#> 70:              1.549991e-04             5.501029e-04                       0
#> 71:              6.230484e-05             2.211243e-04                       0
#> 72:              1.360937e-04             4.830063e-04                       0
#>     n2o_manure_other_indirect n2o_manure_pasture_total n2o_manure_burned_total
#>                         <num>                    <num>                   <num>
#>     n2o_manure_other_total co2_ration_fertilizer co2_ration_pesticides
#>                      <num>                 <num>                 <num>
#>  1:           2.724101e-03               33.4710               11.4574
#>  2:           1.892542e-03                0.0000                0.0000
#>  3:           2.785523e-03               33.4710               11.4574
#>  4:           3.979393e-03               33.4710               11.4574
#>  5:           7.844721e-04                0.0000                0.0000
#>  6:           2.520763e-03               33.4710               11.4574
#>  7:           1.064546e-03                0.5440                0.0922
#>  8:           1.311760e-03                0.0000                0.0000
#>  9:           7.947130e-04                0.5440                0.0922
#> 10:           1.327829e-03                0.5440                0.0922
#> 11:           7.069808e-04                0.0000                0.0000
#> 12:           8.281828e-04                0.5440                0.0922
#> 13:           3.227784e-04               16.6353                8.3062
#> 14:           3.901572e-04                0.0000                0.0000
#> 15:           2.409456e-04               16.6353                8.3062
#> 16:           3.163679e-04               16.6353                8.3062
#> 17:           3.901269e-04                0.0000                0.0000
#> 18:           1.873398e-04               16.6353                8.3062
#> 19:           4.176451e-04                7.4240                0.4442
#> 20:           5.437508e-04                0.0000                0.0000
#> 21:           3.368538e-04                7.4240                0.4442
#> 22:           4.166617e-04                7.4240                0.4442
#> 23:           5.203297e-04                0.0000                0.0000
#> 24:           3.376441e-04                7.4240                0.4442
#> 25:           5.535071e-04               22.6363               10.7182
#> 26:           1.376075e-04                0.0000                0.0000
#> 27:           2.819070e-04               22.6363               10.7182
#> 28:           7.818124e-04               22.6363               10.7182
#> 29:           1.376075e-04                0.0000                0.0000
#> 30:           1.622074e-04               22.6363               10.7182
#> 31:           2.161678e-04                0.0000                0.0000
#> 32:           6.707520e-05                0.0000                0.0000
#> 33:           1.485269e-04                0.0000                0.0000
#> 34:           2.568888e-04                0.0000                0.0000
#> 35:           6.707520e-05                0.0000                0.0000
#> 36:           1.446040e-04                0.0000                0.0000
#> 37:           1.875640e-03               24.1376               10.7537
#> 38:           3.167027e-04                0.0000                0.0000
#> 39:           1.179734e-03               24.1376               10.7537
#> 40:           2.196965e-03               24.1376               10.7537
#> 41:           1.276375e-04                0.0000                0.0000
#> 42:           1.050756e-03               24.1376               10.7537
#> 43:           2.754495e-03               22.5590                2.2507
#> 44:           4.953711e-04                0.0000                0.0000
#> 45:           1.845719e-03               22.5590                2.2507
#> 46:           2.802597e-03               22.5590                2.2507
#> 47:           3.361464e-04                0.0000                0.0000
#> 48:           9.860468e-04               22.5590                2.2507
#> 49:           1.252320e-03               38.3230                9.1713
#> 50:           1.269944e-04                0.0000                0.0000
#> 51:           8.087786e-04               38.3230                9.1713
#> 52:           1.239625e-03               38.3230                9.1713
#> 53:           1.269944e-04                0.0000                0.0000
#> 54:           8.795358e-04               38.3230                9.1713
#> 55:           3.838151e-04               24.8210                6.5384
#> 56:           5.121164e-05                0.0000                0.0000
#> 57:           3.216662e-04               24.8210                6.5384
#> 58:           4.103545e-04               24.8210                6.5384
#> 59:           5.121164e-05                0.0000                0.0000
#> 60:           3.353728e-04               24.8210                6.5384
#> 61:           4.191712e-04               32.1360                2.2574
#> 62:           1.624044e-04                0.0000                0.0000
#> 63:           3.553257e-04               32.1360                2.2574
#> 64:           4.591447e-04               32.1360                2.2574
#> 65:           1.624044e-04                0.0000                0.0000
#> 66:           3.686432e-04               32.1360                2.2574
#> 67:           1.523684e-03               27.7760               12.9242
#> 68:           7.233642e-04                0.0000                0.0000
#> 69:           1.551329e-03               27.7760               12.9242
#> 70:           1.799552e-03               27.7760               12.9242
#> 71:           7.233642e-04                0.0000                0.0000
#> 72:           1.580059e-03               27.7760               12.9242
#>     n2o_manure_other_total co2_ration_fertilizer co2_ration_pesticides
#>                      <num>                 <num>                 <num>
#>     co2_ration_crop_activities co2_ration_luc_nopeat co2_ration_luc_peat
#>                          <num>                 <num>               <num>
#>  1:                    81.7010               49.0764            0.852196
#>  2:                     0.0000                0.0000            0.000000
#>  3:                    81.7010               49.0764            0.852196
#>  4:                    81.7010               49.0764            0.852196
#>  5:                     0.0000                0.0000            0.000000
#>  6:                    81.7010               49.0764            0.852196
#>  7:                    47.3820                0.0262            0.001018
#>  8:                     0.0000                0.0000            0.000000
#>  9:                    47.3820                0.0262            0.001018
#> 10:                    47.3820                0.0262            0.001018
#> 11:                     0.0000                0.0000            0.000000
#> 12:                    47.3820                0.0262            0.001018
#> 13:                    57.6480                5.9369            0.057910
#> 14:                     0.0000                0.0000            0.000000
#> 15:                    57.6480                5.9369            0.057910
#> 16:                    57.6480                5.9369            0.057910
#> 17:                     0.0000                0.0000            0.000000
#> 18:                    57.6480                5.9369            0.057910
#> 19:                    87.5980                2.3662            0.313018
#> 20:                     0.0000                0.0000            0.000000
#> 21:                    87.5980                2.3662            0.313018
#> 22:                    87.5980                2.3662            0.313018
#> 23:                     0.0000                0.0000            0.000000
#> 24:                    87.5980                2.3662            0.313018
#> 25:                    73.6790               11.9319            0.106540
#> 26:                     0.0000                0.0000            0.000000
#> 27:                    73.6790               11.9319            0.106540
#> 28:                    73.6790               11.9319            0.106540
#> 29:                     0.0000                0.0000            0.000000
#> 30:                    73.6790               11.9319            0.106540
#> 31:                    83.5000                0.0000            0.000000
#> 32:                     0.0000                0.0000            0.000000
#> 33:                    83.5000                0.0000            0.000000
#> 34:                    83.5000                0.0000            0.000000
#> 35:                     0.0000                0.0000            0.000000
#> 36:                    83.5000                0.0000            0.000000
#> 37:                    81.8810               49.5318            0.652960
#> 38:                     0.0000                0.0000            0.000000
#> 39:                    81.8810               49.5318            0.652960
#> 40:                    81.8810               49.5318            0.652960
#> 41:                     0.0000                0.0000            0.000000
#> 42:                    81.8810               49.5318            0.652960
#> 43:                    79.8860                6.9051            0.822760
#> 44:                     0.0000                0.0000            0.000000
#> 45:                    79.8860                6.9051            0.822760
#> 46:                    79.8860                6.9051            0.822760
#> 47:                     0.0000                0.0000            0.000000
#> 48:                    79.8860                6.9051            0.822760
#> 49:                    55.8580               53.5010            0.336112
#> 50:                     0.0000                0.0000            0.000000
#> 51:                    55.8580               53.5010            0.336112
#> 52:                    55.8580               53.5010            0.336112
#> 53:                     0.0000                0.0000            0.000000
#> 54:                    55.8580               53.5010            0.336112
#> 55:                    31.1946              129.8650          -23.648440
#> 56:                     0.0000                0.0000            0.000000
#> 57:                    31.1946              129.8650          -23.648440
#> 58:                    31.1946              129.8650          -23.648440
#> 59:                     0.0000                0.0000            0.000000
#> 60:                    31.1946              129.8650          -23.648440
#> 61:                    31.2570               22.7100            1.639200
#> 62:                     0.0000                0.0000            0.000000
#> 63:                    31.2570               22.7100            1.639200
#> 64:                    31.2570               22.7100            1.639200
#> 65:                     0.0000                0.0000            0.000000
#> 66:                    31.2570               22.7100            1.639200
#> 67:                    92.8600                2.3662            0.313018
#> 68:                     0.0000                0.0000            0.000000
#> 69:                    92.8600                2.3662            0.313018
#> 70:                    92.8600                2.3662            0.313018
#> 71:                     0.0000                0.0000            0.000000
#> 72:                    92.8600                2.3662            0.313018
#>     co2_ration_crop_activities co2_ration_luc_nopeat co2_ration_luc_peat
#>                          <num>                 <num>               <num>
#>     n2o_ration_fertilizer n2o_ration_manure_applied n2o_ration_crop_residues
#>                     <num>                     <num>                    <num>
#>  1:              0.223890                  0.197650                 0.103184
#>  2:              0.000000                  0.000000                 0.000000
#>  3:              0.223890                  0.197650                 0.103184
#>  4:              0.223890                  0.197650                 0.103184
#>  5:              0.000000                  0.000000                 0.000000
#>  6:              0.223890                  0.197650                 0.103184
#>  7:              0.002860                  0.109080                 0.001202
#>  8:              0.000000                  0.000000                 0.000000
#>  9:              0.002860                  0.109080                 0.001202
#> 10:              0.002860                  0.109080                 0.001202
#> 11:              0.000000                  0.000000                 0.000000
#> 12:              0.002860                  0.109080                 0.001202
#> 13:              0.072447                  0.067596                 0.018048
#> 14:              0.000000                  0.000000                 0.000000
#> 15:              0.072447                  0.067596                 0.018048
#> 16:              0.072447                  0.067596                 0.018048
#> 17:              0.000000                  0.000000                 0.000000
#> 18:              0.072447                  0.067596                 0.018048
#> 19:              0.044660                  0.113400                 0.014342
#> 20:              0.000000                  0.000000                 0.000000
#> 21:              0.044660                  0.113400                 0.014342
#> 22:              0.044660                  0.113400                 0.014342
#> 23:              0.000000                  0.000000                 0.000000
#> 24:              0.044660                  0.113400                 0.014342
#> 25:              0.104779                  0.091046                 0.031238
#> 26:              0.000000                  0.000000                 0.000000
#> 27:              0.104779                  0.091046                 0.031238
#> 28:              0.104779                  0.091046                 0.031238
#> 29:              0.000000                  0.000000                 0.000000
#> 30:              0.104779                  0.091046                 0.031238
#> 31:              0.000000                  0.108000                 0.000000
#> 32:              0.000000                  0.000000                 0.000000
#> 33:              0.000000                  0.108000                 0.000000
#> 34:              0.000000                  0.108000                 0.000000
#> 35:              0.000000                  0.000000                 0.000000
#> 36:              0.000000                  0.108000                 0.000000
#> 37:              0.185636                  0.213822                 0.097351
#> 38:              0.000000                  0.000000                 0.000000
#> 39:              0.185636                  0.213822                 0.097351
#> 40:              0.185636                  0.213822                 0.097351
#> 41:              0.000000                  0.000000                 0.000000
#> 42:              0.185636                  0.213822                 0.097351
#> 43:              0.132050                  0.097550                 0.051655
#> 44:              0.000000                  0.000000                 0.000000
#> 45:              0.132050                  0.097550                 0.051655
#> 46:              0.132050                  0.097550                 0.051655
#> 47:              0.000000                  0.000000                 0.000000
#> 48:              0.132050                  0.097550                 0.051655
#> 49:              0.258840                  0.240100                 0.161783
#> 50:              0.000000                  0.000000                 0.000000
#> 51:              0.258840                  0.240100                 0.161783
#> 52:              0.258840                  0.240100                 0.161783
#> 53:              0.000000                  0.000000                 0.000000
#> 54:              0.258840                  0.240100                 0.161783
#> 55:              0.119804                  0.095069                 0.148221
#> 56:              0.000000                  0.000000                 0.000000
#> 57:              0.119804                  0.095069                 0.148221
#> 58:              0.119804                  0.095069                 0.148221
#> 59:              0.000000                  0.000000                 0.000000
#> 60:              0.119804                  0.095069                 0.148221
#> 61:              0.195100                  0.133180                 0.075510
#> 62:              0.000000                  0.000000                 0.000000
#> 63:              0.195100                  0.133180                 0.075510
#> 64:              0.195100                  0.133180                 0.075510
#> 65:              0.000000                  0.000000                 0.000000
#> 66:              0.195100                  0.133180                 0.075510
#> 67:              0.117716                  0.052298                 0.014342
#> 68:              0.000000                  0.000000                 0.000000
#> 69:              0.117716                  0.052298                 0.014342
#> 70:              0.117716                  0.052298                 0.014342
#> 71:              0.000000                  0.000000                 0.000000
#> 72:              0.117716                  0.052298                 0.014342
#>     n2o_ration_fertilizer n2o_ration_manure_applied n2o_ration_crop_residues
#>                     <num>                     <num>                    <num>
#>     ch4_ration_rice milk_production_mass_cohort milk_production_protein_cohort
#>               <num>                       <num>                          <num>
#>  1:           0.000                 50513974803                     1565933219
#>  2:           0.000                           0                              0
#>  3:           0.000                           0                              0
#>  4:           0.000                           0                              0
#>  5:           0.000                           0                              0
#>  6:           0.000                           0                              0
#>  7:           0.000                           0                              0
#>  8:           0.000                           0                              0
#>  9:           0.000                           0                              0
#> 10:           0.000                           0                              0
#> 11:           0.000                           0                              0
#> 12:           0.000                           0                              0
#> 13:           0.000                    64663043                        3750456
#> 14:           0.000                           0                              0
#> 15:           0.000                           0                              0
#> 16:           0.000                           0                              0
#> 17:           0.000                           0                              0
#> 18:           0.000                           0                              0
#> 19:           0.000                           0                              0
#> 20:           0.000                           0                              0
#> 21:           0.000                           0                              0
#> 22:           0.000                           0                              0
#> 23:           0.000                           0                              0
#> 24:           0.000                           0                              0
#> 25:           0.000                   138404115                        4705740
#> 26:           0.000                           0                              0
#> 27:           0.000                           0                              0
#> 28:           0.000                           0                              0
#> 29:           0.000                           0                              0
#> 30:           0.000                           0                              0
#> 31:           0.000                           0                              0
#> 32:           0.000                           0                              0
#> 33:           0.000                           0                              0
#> 34:           0.000                           0                              0
#> 35:           0.000                           0                              0
#> 36:           0.000                           0                              0
#> 37:           0.000                    78558504                        3660826
#> 38:           0.000                           0                              0
#> 39:           0.000                           0                              0
#> 40:           0.000                           0                              0
#> 41:           0.000                           0                              0
#> 42:           0.000                           0                              0
#> 43:           7.200                 28720555287                     1005219435
#> 44:           0.000                           0                              0
#> 45:           7.200                           0                              0
#> 46:           7.200                           0                              0
#> 47:           0.000                           0                              0
#> 48:           7.200                           0                              0
#> 49:           0.000                           0                              0
#> 50:           0.000                           0                              0
#> 51:           0.000                           0                              0
#> 52:           0.000                           0                              0
#> 53:           0.000                           0                              0
#> 54:           0.000                           0                              0
#> 55:           0.736                           0                              0
#> 56:           0.000                           0                              0
#> 57:           0.736                           0                              0
#> 58:           0.736                           0                              0
#> 59:           0.000                           0                              0
#> 60:           0.736                           0                              0
#> 61:           0.000                  1382779737                       48397291
#> 62:           0.000                           0                              0
#> 63:           0.000                           0                              0
#> 64:           0.000                           0                              0
#> 65:           0.000                           0                              0
#> 66:           0.000                           0                              0
#> 67:           0.000                   158470524                        5546468
#> 68:           0.000                           0                              0
#> 69:           0.000                           0                              0
#> 70:           0.000                           0                              0
#> 71:           0.000                           0                              0
#> 72:           0.000                           0                              0
#>     ch4_ration_rice milk_production_mass_cohort milk_production_protein_cohort
#>               <num>                       <num>                          <num>
#>     milk_production_fpcm_cohort fibre_production_cohort
#>                           <num>                   <num>
#>  1:                 47870829419                   0.000
#>  2:                           0                   0.000
#>  3:                           0                   0.000
#>  4:                           0                   0.000
#>  5:                           0                   0.000
#>  6:                           0                   0.000
#>  7:                           0                   0.000
#>  8:                           0                   0.000
#>  9:                           0                   0.000
#> 10:                           0                   0.000
#> 11:                           0                   0.000
#> 12:                           0                   0.000
#> 13:                    96609660             4178278.794
#> 14:                           0                   0.000
#> 15:                           0              881538.017
#> 16:                           0             2938490.049
#> 17:                           0                   0.000
#> 18:                           0               25617.157
#> 19:                           0            11364562.472
#> 20:                           0                   0.000
#> 21:                           0             1789195.608
#> 22:                           0             5759416.231
#> 23:                           0                   0.000
#> 24:                           0              280801.455
#> 25:                   170714332             1697862.793
#> 26:                           0                   0.000
#> 27:                           0              104870.260
#> 28:                           0              516973.219
#> 29:                           0                   0.000
#> 30:                           0                2642.270
#> 31:                           0               85219.795
#> 32:                           0                   0.000
#> 33:                           0               28930.945
#> 34:                           0               15127.161
#> 35:                           0                   0.000
#> 36:                           0                8425.587
#> 37:                   128157410                   0.000
#> 38:                           0                   0.000
#> 39:                           0                   0.000
#> 40:                           0                   0.000
#> 41:                           0                   0.000
#> 42:                           0                   0.000
#> 43:                 40295747197                   0.000
#> 44:                           0                   0.000
#> 45:                           0                   0.000
#> 46:                           0                   0.000
#> 47:                           0                   0.000
#> 48:                           0                   0.000
#> 49:                           0                   0.000
#> 50:                           0                   0.000
#> 51:                           0                   0.000
#> 52:                           0                   0.000
#> 53:                           0                   0.000
#> 54:                           0                   0.000
#> 55:                           0                   0.000
#> 56:                           0                   0.000
#> 57:                           0                   0.000
#> 58:                           0                   0.000
#> 59:                           0                   0.000
#> 60:                           0                   0.000
#> 61:                  1316577976             3028327.447
#> 62:                           0                   0.000
#> 63:                           0             2402477.568
#> 64:                           0               47080.593
#> 65:                           0                   0.000
#> 66:                           0              618631.277
#> 67:                   150883612              148890.884
#> 68:                           0                   0.000
#> 69:                           0              113864.120
#> 70:                           0               14609.767
#> 71:                           0                   0.000
#> 72:                           0               50771.772
#>     milk_production_fpcm_cohort fibre_production_cohort
#>                           <num>                   <num>
#>     meat_production_live_weight_cohort meat_production_carcass_weight_cohort
#>                                  <num>                                 <num>
#>  1:                       2.730470e+09                          1.774806e+09
#>  2:                       2.874156e+08                          1.868201e+08
#>  3:                       1.016465e+09                          6.607019e+08
#>  4:                       4.398295e+05                          2.858892e+05
#>  5:                       1.086560e+09                          7.062642e+08
#>  6:                       9.161878e+07                          5.955220e+07
#>  7:                       1.175784e+05                          7.642593e+04
#>  8:                       3.350812e+05                          2.178028e+05
#>  9:                       1.768221e+05                          1.149343e+05
#> 10:                       1.142653e+05                          7.427247e+04
#> 11:                       3.962934e+05                          2.575907e+05
#> 12:                       1.079174e+05                          7.014629e+04
#> 13:                       3.717372e+07                          2.416292e+07
#> 14:                       1.597936e+07                          1.038659e+07
#> 15:                       1.140910e+07                          7.415915e+06
#> 16:                       1.493321e+07                          9.706589e+06
#> 17:                       3.169331e+07                          2.060065e+07
#> 18:                       1.409239e+06                          9.160051e+05
#> 19:                       3.460503e+07                          2.249327e+07
#> 20:                       3.059369e+07                          1.988590e+07
#> 21:                       2.776360e+07                          1.804634e+07
#> 22:                       1.821992e+07                          1.184295e+07
#> 23:                       4.687335e+07                          3.046768e+07
#> 24:                       1.096069e+07                          7.124446e+06
#> 25:                       9.423467e+06                          6.125254e+06
#> 26:                       4.019452e+06                          2.612644e+06
#> 27:                       1.832179e+06                          1.190917e+06
#> 28:                       6.357780e+06                          4.132557e+06
#> 29:                       5.273128e+06                          3.427533e+06
#> 30:                       1.303809e+05                          8.474756e+04
#> 31:                       6.223043e+05                          4.044978e+05
#> 32:                       4.217899e+05                          2.741635e+05
#> 33:                       5.071393e+05                          3.296406e+05
#> 34:                       1.190142e+05                          7.735921e+04
#> 35:                       7.541025e+05                          4.901666e+05
#> 36:                       3.496387e+05                          2.272652e+05
#> 37:                       1.215985e+07                          7.903900e+06
#> 38:                       8.735056e+06                          5.677787e+06
#> 39:                       1.249014e+07                          8.118592e+06
#> 40:                       4.305511e+06                          2.798582e+06
#> 41:                       1.186737e+07                          7.713791e+06
#> 42:                       2.852594e+06                          1.854186e+06
#> 43:                       3.019176e+09                          1.962464e+09
#> 44:                       2.606623e+08                          1.694305e+08
#> 45:                       6.462042e+08                          4.200327e+08
#> 46:                       2.150735e+08                          1.397978e+08
#> 47:                       1.657215e+09                          1.077190e+09
#> 48:                       7.136331e+06                          4.638615e+06
#> 49:                       7.107366e+08                          4.619788e+08
#> 50:                       8.743803e+08                          5.683472e+08
#> 51:                       3.129714e+08                          2.034314e+08
#> 52:                       7.610360e+08                          4.946734e+08
#> 53:                       8.953917e+08                          5.820046e+08
#> 54:                       5.276906e+07                          3.429989e+07
#> 55:                       5.180079e+06                          3.367052e+06
#> 56:                       2.882597e+07                          1.873688e+07
#> 57:                       1.109068e+06                          7.208943e+05
#> 58:                       5.531005e+06                          3.595153e+06
#> 59:                       2.943319e+07                          1.913158e+07
#> 60:                       2.084956e+04                          1.355222e+04
#> 61:                       4.846103e+07                          3.149967e+07
#> 62:                       0.000000e+00                          0.000000e+00
#> 63:                       0.000000e+00                          0.000000e+00
#> 64:                       8.657360e+05                          5.627284e+05
#> 65:                       0.000000e+00                          0.000000e+00
#> 66:                       1.657632e+08                          1.077461e+08
#> 67:                       3.896054e+06                          2.532435e+06
#> 68:                       0.000000e+00                          0.000000e+00
#> 69:                       0.000000e+00                          0.000000e+00
#> 70:                       4.303921e+05                          2.797549e+05
#> 71:                       0.000000e+00                          0.000000e+00
#> 72:                       2.154353e+07                          1.400330e+07
#>     meat_production_live_weight_cohort meat_production_carcass_weight_cohort
#>                                  <num>                                 <num>
#>     meat_production_bone_free_meat_cohort meat_production_protein_cohort
#>                                     <num>                          <num>
#>  1:                          1.153624e+09                   2.422610e+08
#>  2:                          1.214331e+08                   2.550095e+07
#>  3:                          4.294563e+08                   9.018581e+07
#>  4:                          1.858280e+05                   3.902387e+04
#>  5:                          4.590717e+08                   9.640506e+07
#>  6:                          3.870893e+07                   8.128876e+06
#>  7:                          4.967686e+04                   1.043214e+04
#>  8:                          1.415718e+05                   2.973008e+04
#>  9:                          7.470732e+04                   1.568854e+04
#> 10:                          4.827710e+04                   1.013819e+04
#> 11:                          1.674340e+05                   3.516113e+04
#> 12:                          4.559509e+04                   9.574969e+03
#> 13:                          1.691404e+07                   3.551949e+06
#> 14:                          7.270611e+06                   1.526828e+06
#> 15:                          5.191141e+06                   1.090140e+06
#> 16:                          6.794612e+06                   1.426869e+06
#> 17:                          1.442046e+07                   3.028296e+06
#> 18:                          6.412036e+05                   1.346528e+05
#> 19:                          1.574529e+07                   3.306511e+06
#> 20:                          1.392013e+07                   2.923227e+06
#> 21:                          1.263244e+07                   2.652812e+06
#> 22:                          8.290063e+06                   1.740913e+06
#> 23:                          2.132738e+07                   4.478749e+06
#> 24:                          4.987112e+06                   1.047294e+06
#> 25:                          4.287678e+06                   9.004123e+05
#> 26:                          1.828851e+06                   3.840586e+05
#> 27:                          8.336417e+05                   1.750647e+05
#> 28:                          2.892790e+06                   6.074859e+05
#> 29:                          2.399273e+06                   5.038473e+05
#> 30:                          5.932329e+04                   1.245789e+04
#> 31:                          2.831485e+05                   5.946118e+04
#> 32:                          1.919144e+05                   4.030203e+04
#> 33:                          2.307484e+05                   4.845716e+04
#> 34:                          5.415145e+04                   1.137180e+04
#> 35:                          3.431167e+05                   7.205450e+04
#> 36:                          1.590856e+05                   3.340798e+04
#> 37:                          5.927925e+06                   1.244864e+06
#> 38:                          4.258340e+06                   8.942514e+05
#> 39:                          6.088944e+06                   1.278678e+06
#> 40:                          2.098936e+06                   4.407767e+05
#> 41:                          5.785343e+06                   1.214922e+06
#> 42:                          1.390640e+06                   2.920343e+05
#> 43:                          1.471848e+09                   3.090881e+08
#> 44:                          1.270729e+08                   2.668530e+07
#> 45:                          3.150245e+08                   6.615515e+07
#> 46:                          1.048483e+08                   2.201815e+07
#> 47:                          8.078924e+08                   1.696574e+08
#> 48:                          3.478961e+06                   7.305819e+05
#> 49:                          3.002862e+08                   6.306010e+07
#> 50:                          3.694257e+08                   7.757939e+07
#> 51:                          1.322304e+08                   2.776839e+07
#> 52:                          3.215377e+08                   6.752292e+07
#> 53:                          3.783030e+08                   7.944363e+07
#> 54:                          2.229493e+07                   4.681935e+06
#> 55:                          2.188584e+06                   4.596025e+05
#> 56:                          1.217897e+07                   2.557584e+06
#> 57:                          4.685813e+05                   9.840207e+04
#> 58:                          2.336849e+06                   4.907384e+05
#> 59:                          1.243552e+07                   2.611460e+06
#> 60:                          8.808940e+03                   1.849877e+03
#> 61:                          2.047479e+07                   4.299705e+06
#> 62:                          0.000000e+00                   0.000000e+00
#> 63:                          0.000000e+00                   0.000000e+00
#> 64:                          3.657735e+05                   7.681243e+04
#> 65:                          0.000000e+00                   0.000000e+00
#> 66:                          7.003494e+07                   1.470734e+07
#> 67:                          1.646083e+06                   3.456774e+05
#> 68:                          0.000000e+00                   0.000000e+00
#> 69:                          0.000000e+00                   0.000000e+00
#> 70:                          1.818407e+05                   3.818654e+04
#> 71:                          0.000000e+00                   0.000000e+00
#> 72:                          9.102143e+06                   1.911450e+06
#>     meat_production_bone_free_meat_cohort meat_production_protein_cohort
#>                                     <num>                          <num>
#>     milk_allocation_energy meat_allocation_energy fibre_allocation_energy
#>                      <num>                  <num>                   <num>
#>  1:           148558245766            70930704266                    0.00
#>  2:                      0             5459498936                    0.00
#>  3:                      0            25225336085                    0.00
#>  4:                      0               10254181                    0.00
#>  5:                      0            17458777507                    0.00
#>  6:                      0             1961416853                    0.00
#>  7:                      0                2979095                    0.00
#>  8:                      0                7750870                    0.00
#>  9:                      0                4203753                    0.00
#> 10:                      0                2552519                    0.00
#> 11:                      0                7754159                    0.00
#> 12:                      0                2170249                    0.00
#> 13:              299810171              495340455            100278691.06
#> 14:                      0              134626608                    0.00
#> 15:                      0              109649887             21156912.40
#> 16:                      0              201298468             70523761.19
#> 17:                      0              269134326                    0.00
#> 18:                      0               13236980               614811.76
#> 19:                      0              530800747            272749499.33
#> 20:                      0              290269906                    0.00
#> 21:                      0              372750803             42940694.60
#> 22:                      0              278038379            138225989.54
#> 23:                      0              432216444                    0.00
#> 24:                      0              140912970              6739234.91
#> 25:              529780287              153330412             40748707.04
#> 26:                      0               24814422                    0.00
#> 27:                      0               15287980              2516886.25
#> 28:                      0              146054314             12407357.25
#> 29:                      0               32554093                    0.00
#> 30:                      0                1087917                63414.49
#> 31:                      0                8124954              2045275.09
#> 32:                      0                2532040                    0.00
#> 33:                      0                4642391               694342.68
#> 34:                      0                2042842               363051.86
#> 35:                      0                4526939                    0.00
#> 36:                      0                3200619               202214.08
#> 37:              397712768              310208481                    0.00
#> 38:                      0              114474375                    0.00
#> 39:                      0              291527440                    0.00
#> 40:                      0               98544602                    0.00
#> 41:                      0              131557189                    0.00
#> 42:                      0               56320893                    0.00
#> 43:           125050382208            74620563140                    0.00
#> 44:                      0             3325621824                    0.00
#> 45:                      0             8244502318                    0.00
#> 46:                      0             4543068108                    0.00
#> 47:                      0            17885087671                    0.00
#> 48:                      0               77017097                    0.00
#> 49:                      0                      0                    0.00
#> 50:                      0                      0                    0.00
#> 51:                      0                      0                    0.00
#> 52:                      0                      0                    0.00
#> 53:                      0                      0                    0.00
#> 54:                      0                      0                    0.00
#> 55:                      0                      0                    0.00
#> 56:                      0                      0                    0.00
#> 57:                      0                      0                    0.00
#> 58:                      0                      0                    0.00
#> 59:                      0                      0                    0.00
#> 60:                      0                      0                    0.00
#> 61:             4085755707             4326766984            393076575.07
#> 62:                      0                      0                    0.00
#> 63:                      0                      0            311841328.51
#> 64:                      0               77834760              6111055.94
#> 65:                      0                      0                    0.00
#> 66:                      0            14903084038             80298272.84
#> 67:              468239322              355670229             19326020.65
#> 68:                      0                      0                    0.00
#> 69:                      0                      0             14779550.41
#> 70:                      0               39446326              1896346.16
#> 71:                      0                      0                    0.00
#> 72:                      0             1974509183              6590170.55
#>     milk_allocation_energy meat_allocation_energy fibre_allocation_energy
#>                      <num>                  <num>                   <num>
#>     work_allocation_energy egg_allocation_energy
#>                      <num>                 <num>
#>  1:                    0.0                     0
#>  2:                    0.0                     0
#>  3:                    0.0                     0
#>  4:                    0.0                     0
#>  5:                    0.0                     0
#>  6:                    0.0                     0
#>  7:                    0.0                     0
#>  8:                    0.0                     0
#>  9:                    0.0                     0
#> 10:               467997.5                     0
#> 11:                    0.0                     0
#> 12:                    0.0                     0
#> 13:                    0.0                     0
#> 14:                    0.0                     0
#> 15:                    0.0                     0
#> 16:                    0.0                     0
#> 17:                    0.0                     0
#> 18:                    0.0                     0
#> 19:                    0.0                     0
#> 20:                    0.0                     0
#> 21:                    0.0                     0
#> 22:                    0.0                     0
#> 23:                    0.0                     0
#> 24:                    0.0                     0
#> 25:                    0.0                     0
#> 26:                    0.0                     0
#> 27:                    0.0                     0
#> 28:                    0.0                     0
#> 29:                    0.0                     0
#> 30:                    0.0                     0
#> 31:                    0.0                     0
#> 32:                    0.0                     0
#> 33:                    0.0                     0
#> 34:                    0.0                     0
#> 35:                    0.0                     0
#> 36:                    0.0                     0
#> 37:                    0.0                     0
#> 38:                    0.0                     0
#> 39:                    0.0                     0
#> 40:                    0.0                     0
#> 41:                    0.0                     0
#> 42:                    0.0                     0
#> 43:                    0.0                     0
#> 44:                    0.0                     0
#> 45:                    0.0                     0
#> 46:           2889514739.0                     0
#> 47:                    0.0                     0
#> 48:                    0.0                     0
#> 49:                    0.0                     0
#> 50:                    0.0                     0
#> 51:                    0.0                     0
#> 52:                    0.0                     0
#> 53:                    0.0                     0
#> 54:                    0.0                     0
#> 55:                    0.0                     0
#> 56:                    0.0                     0
#> 57:                    0.0                     0
#> 58:                    0.0                     0
#> 59:                    0.0                     0
#> 60:                    0.0                     0
#> 61:                    0.0                     0
#> 62:                    0.0                     0
#> 63:                    0.0                     0
#> 64:             31971007.7                     0
#> 65:                    0.0                     0
#> 66:                    0.0                     0
#> 67:                    0.0                     0
#> 68:                    0.0                     0
#> 69:                    0.0                     0
#> 70:              9921051.0                     0
#> 71:                    0.0                     0
#> 72:                    0.0                     0
#>     work_allocation_energy egg_allocation_energy
#>                      <num>                 <num>
print(results$allocation_long)
#> Key: <commodity_name>
#>      herd_id species_short              variable_name commodity_name
#>        <int>        <char>                     <char>         <char>
#>   1:       3           SHP                ch4_enteric          Fibre
#>   2:       3           SHP           ch4_manure_other          Fibre
#>   3:       3           SHP            ch4_ration_rice          Fibre
#>   4:       3           SHP co2_ration_crop_activities          Fibre
#>   5:       3           SHP      co2_ration_fertilizer          Fibre
#>  ---                                                                
#> 445:      12           CML    n2o_manure_other_direct           Work
#> 446:      12           CML  n2o_manure_other_indirect           Work
#> 447:      12           CML   n2o_ration_crop_residues           Work
#> 448:      12           CML      n2o_ration_fertilizer           Work
#> 449:      12           CML  n2o_ration_manure_applied           Work
#>      commodity_type allocation_share
#>              <char>            <num>
#>   1:     Non-Edible       0.11224423
#>   2:     Non-Edible       0.11224423
#>   3:     Non-Edible       0.11224423
#>   4:     Non-Edible       0.11224423
#>   5:     Non-Edible       0.11224423
#>  ---                                
#> 445:     Non-Edible       0.00343244
#> 446:     Non-Edible       0.00343244
#> 447:     Non-Edible       0.00343244
#> 448:     Non-Edible       0.00343244
#> 449:     Non-Edible       0.00343244
# }
```
