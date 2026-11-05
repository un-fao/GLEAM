# Run the full Global Livestock Environmental Assessment Model (GLEAM) Pipeline

Runs the full GLEAM pipeline from master herd and cohort inputs through
all modules: herd (optional), weights, ration quality, energy
requirements, manure emissions, enteric fermentation, nitrogren balance,
feed emissions, allocation, and aggregation.  
  
**Common identifiers**: Several input tables share the following
identifier columns. Their supported values are listed below.  
  
**`species_short`** — Character. Species code:

- `CTL`: Cattle

- `BFL`: Buffalo

- `SHP`: Sheep

- `GTS`: Goats

- `PGS`: Pigs

- `CML`: Camels

- `CHK`: Chickens

**`cohort_short`** — Character. Sex-specific cohort code describing the
age and/or the production stage of the animals. Supported values
include:

- `FA`: adult females (from age at first parturition)

- `FS`: sub-adult females (from weaning to age at first parturition)

- `FJ`: juvenile females (from birth to weaning)

- `MA`: adult males (from age at first breeding)

- `MS`: sub-adult males (from weaning to age at first breeding)

- `MJ`: juvenile males (from birth to weaning)

- `FN`: non-demographic females

- `MN`: non-demographic males

## Usage

``` r
run_gleam(
  has_herd_structure = FALSE,
  run_demographic = TRUE,
  run_nondemographic = TRUE,
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
  [`run_all_herd_module`](https://un-fao.github.io/GLEAM/reference/run_all_herd_module.md),
  which can run the demographic herd module, the non-demographic herd
  module, or both depending on `run_demographic` and
  `run_nondemographic`.

- run_demographic:

  Logical. If `TRUE` and `has_herd_structure = FALSE`, include the
  demographic herd module in the herd-structure generation step via
  [`run_all_herd_module`](https://un-fao.github.io/GLEAM/reference/run_all_herd_module.md).

- run_nondemographic:

  Logical. If `TRUE` and `has_herd_structure = FALSE`, include the
  non-demographic herd module in the herd-structure generation step via
  [`run_all_herd_module`](https://un-fao.github.io/GLEAM/reference/run_all_herd_module.md).

- cohort_level_data:

  data.table. Cohort-level master input table. Required columns:

  herd_id

  :   Character. Unique identifier for the herd, repeated for each
      cohort belonging to the same herd.

  species_short

  :   Character. Species code (see Common identifiers).

  cohort_short

  :   Character. Sex-specific cohort code describing the age and/or the
      production stage of the animals. Supported values include:

      - `FA`: adult females (from age at first parturition)

      - `FS`: sub-adult females (from weaning to age at first
        parturition)

      - `FJ`: juvenile females (from birth to weaning)

      - `MA`: adult males (from age at first breeding)

      - `MS`: sub-adult males (from weaning to age at first breeding)

      - `MJ`: juvenile males (from birth to weaning)

      - `FN`: non-demographic females

      - `MN`: non-demographic males

  cohort_duration_days

  :   Numeric. Amount of time that each animal spends in a specific
      cohort and production phase (days). For `CHK`, suggested value for
      `FJ` and `MJ` cohorts: 3 days. Not required for `FN` and `MN` when
      phase durations are supplied in the herd table; the code fills it
      from the herd values, which override any cohort values.

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

  :   Numeric. Fraction of animals dying in the assessed cohort, over
      one year for demographic cohorts or over the productive phase for
      non-demographic cohorts (fraction).

  nondemo_productive_phase_id

  :   Numeric. Productive phase identifier for non-demographic cohorts
      (`FN`, `MN`). Takes value `1` for phase 1 and optionally `2` for
      phase 2. Demographic cohorts use `NA`.

  Additional columns when `has_herd_structure = TRUE`:

  cohort_stock_size

  :   Numeric. Average population size of the assessed cohort (# heads).

  offtake_heads_assessment

  :   Numeric. Total number of animals removed from each cohort over the
      assessment period (# heads/assessment period).

  Optional column (both cases):

  is_egg_producing

  :   Logical. Cohort-level flag identifying egg-producing `CHK`
      cohorts. This can be `TRUE` only for `FA` and for `FN` with
      `nondemo_productive_phase_id = 2`.

  ch4_mitigation_factor

  :   Numeric. Multiplicative factor applied to baseline enteric CH4
      emissions (dimensionless). Defaults to `1` (no mitigation). Values
      \< 1 represent proportional reductions (e.g. `0.90` = 10 percent
      reduction). Can represent feed additives or methane inhibitors.

- herd_level_data:

  data.table. Herd-level master input table (one row per `herd_id`).
  Required columns:

  herd_id

  :   Character. Unique identifier for the herd.

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

  :   Numeric. Age at first parturition for female breeding animals
      (days).

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

  :   Numeric. Fraction of deaths in a herd over a year for juvenile
      cohorts (i.e. FJ and MJ), (fraction).

  lactation_duration

  :   Numeric. Lactation period length (days). Required for PGS.

  reproductive_rate

  :   Numeric. Average annual number of parturitions per reproductive
      female (# parturitions/reproductive female/year). For chickens,
      annual number of eggs laid for reproduction per breeding hen (#
      eggs/hen/year).

  offspring_per_reproductive_event

  :   Numeric. Average number of offspring born per parturition (#
      offspring/parturition). For chickens, hatchability of eggs laid
      for reproduction, calculated as the number of chicks hatched
      divided by the number of eggs laid for reproduction (fraction).

  average_annual_temperature

  :   Numeric. Average annual temperature (degrees C). Used for `CHK`.

  egg_average_weight

  :   Numeric. Average egg weight (kg/egg).

  egg_human_consumption_yield

  :   Numeric. Number of eggs produced for human consumption in one year
      by hen (eggs/year/animal). Used for `CHK`.

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

  :   Numeric. Ratio of a slaughtered animal's carcass weight to its
      live weight (fraction).

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

  :   Numeric. Total demographic population size at the start of the
      year, including all cohorts (# heads)

  prop_nondemo_fem_juv

  :   Numeric. Fraction of female juveniles diverted into the
      non-demographic stream at the moment they transition to the next
      age class (fraction). Required when the demographic herd module is
      run.

  prop_nondemo_mal_juv

  :   Numeric. Fraction of male juveniles diverted into the
      non-demographic stream at the moment they transition to the next
      age class (fraction). Required when the demographic herd module is
      run.

  rest_between_nondemo_cycles_duration

  :   Numeric. Duration of the resting or empty phase between
      non-demographic cycles (days). Use `0` when there is no rest
      between cycles.

  phase1_nondemo_fem_duration_days

  :   Numeric. Duration of productive phase 1 for the female
      non-demographic cohort (`FN`) (days).

  phase2_nondemo_fem_duration_days

  :   Numeric. Duration of productive phase 2 for the female
      non-demographic cohort (`FN`) (days).

  phase1_nondemo_mal_duration_days

  :   Numeric. Duration of productive phase 1 for the male
      nondemographic cohort (`MN`) (days).

  phase2_nondemo_mal_duration_days

  :   Numeric. Duration of productive phase 2 for the male
      non-demographic cohort (`MN`) (days).

- feed_rations:

  data.table. Cohort-level feed ration shares, also used by
  [`run_ration_quality_module`](https://un-fao.github.io/GLEAM/reference/run_ration_quality_module.md)
  and
  [`run_emissions_ration_module`](https://un-fao.github.io/GLEAM/reference/run_emissions_ration_module.md).
  Required columns:

  herd_id

  :   Character. Unique identifier for the herd, repeated for each
      cohort belonging to the same herd.

  species_short

  :   Character. Species code (see Common identifiers).

  cohort_short

  :   Character. Sex-specific cohort code describing the age and/or the
      production stage of the animals. Supported values include:

      - `FA`: adult females (from age at first parturition)

      - `FS`: sub-adult females (from weaning to age at first
        parturition)

      - `FJ`: juvenile females (from birth to weaning)

      - `MA`: adult males (from age at first breeding)

      - `MS`: sub-adult males (from weaning to age at first breeding)

      - `MJ`: juvenile males (from birth to weaning)

      - `FN`: non-demographic females

      - `MN`: non-demographic males

  feed_id

  :   Character. Unique identifier for the feed component, used to join
      feed ration data with feed parameter tables.

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

  :   Character. Unique identifier for the feed component, used to join
      feed ration data with feed parameter tables.

  feed_gross_energy

  :   Numeric. Gross energy content of a feed component, representing
      the total chemical energy released upon complete combustion of the
      feed (MJ/kg DM).

  feed_digestible_energy_ruminant

  :   Numeric. Digestible energy content of a feed component for
      ruminants, representing the energy absorbed by the animal after
      fecal losses (MJ/kg DM).

  feed_digestible_energy_pigs

  :   Numeric. Digestible energy content of a feed component for pigs,
      representing the energy absorbed by the animal after fecal losses
      (MJ/kg DM).

  feed_metabolizable_energy_ruminant

  :   Numeric. Metabolizable energy content of a feed component for
      ruminants, representing digestible energy minus energy losses in
      urine and gaseous products of digestion (MJ/kg DM).

  feed_metabolizable_energy_pigs

  :   Numeric. Metabolizable energy content of a feed component for
      pigs, representing digestible energy minus energy losses in urine
      and gaseous products of digestion (MJ/kg DM).

  feed_metabolizable_energy_chicken

  :   Numeric. Metabolizable energy content of a feed component for
      chickens (MJ/kg DM).

  feed_nitrogen_content

  :   Numeric. Nitrogen content (kg N/kg DM).

  feed_urinary_energy_ruminant

  :   Numeric. Fraction of gross energy excreted in urine for ruminants
      (fraction).

  feed_urinary_energy_pigs

  :   Numeric. Fraction of gross energy excreted in urine for pigs
      (fraction).

  feed_ash

  :   Numeric. Average ash content by feed component, expressed as a
      fraction of the dry matter intake (g ash/100g DM).

  category

  :   Character. Optional. Feed category; should be used consistently
      with `feed_id`.

  feed_name

  :   Character. Optional. Human-readable feed name; should match
      `feed_id` uniquely if provided.

- feed_emissions:

  data.table. Emission factors of individual feed components with the
  following data requirement:

  feed_id

  :   Character. Unique identifier for the feed component, used to join
      feed ration data with feed parameter tables.

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
  [`run_emissions_manure_module`](https://un-fao.github.io/GLEAM/reference/run_emissions_manure_module.md).
  Required columns:

  herd_id

  :   Character. Unique identifier for the herd, repeated for each
      cohort belonging to the same herd.

  cohort_short

  :   Character. Sex-specific cohort code describing the age and/or the
      production stage of the animals. Supported values include:

      - `FA`: adult females (from age at first parturition)

      - `FS`: sub-adult females (from weaning to age at first
        parturition)

      - `FJ`: juvenile females (from birth to weaning)

      - `MA`: adult males (from age at first breeding)

      - `MS`: sub-adult males (from weaning to age at first breeding)

      - `MJ`: juvenile males (from birth to weaning)

      - `FN`: non-demographic females

      - `MN`: non-demographic males

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
  [`run_emissions_manure_module`](https://un-fao.github.io/GLEAM/reference/run_emissions_manure_module.md).
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

  Numeric. Length of the assessment period (days). Used by the
  herd-simulation step (when `has_herd_structure = FALSE`) through
  [`run_all_herd_module`](https://un-fao.github.io/GLEAM/reference/run_all_herd_module.md),
  and by the production and aggregation steps. Default: `365`.

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

  :   Numeric. Average population size of the assessed cohort (# heads).

  offtake_heads

  :   Numeric. Total number of animals removed from each cohort over the
      full 365-day simulation horizon (# heads/year).

  offtake_heads_assessment

  :   Numeric. Total number of animals removed from each cohort over the
      assessment period (# heads/assessment period).

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
      energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML,
      PGS, and CHK.

  metabolic_energy_req_activity

  :   Numeric. Energy required for activity, defined as the amount of
      energy needed to support animal movement and physical activity
      (MJ/head/day). Expressed as net energy for CTL, BFL, SHP, GTS and
      as metabolizable energy for CML, PGS, and CHK.

  metabolic_energy_req_growth

  :   Numeric. Energy required for growth (i.e., weight gain)
      (MJ/head/day). Expressed as net energy for CTL, BFL, SHP, GTS and
      as metabolizable energy for CML, PGS, and CHK.

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
      Expressed as net energy for SHP and GTS and as metabolizable
      energy for CML.

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
      requirement (GE). For CML, PGS and CHK the function returns the
      summed daily metabolizable energy requirement.

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

  egg_production_number_cohort

  :   Numeric. Total egg output over the assessment period by cohort
      (eggs/cohort/assessment period).

  egg_production_mass_cohort

  :   Numeric. Total egg mass produced over the assessment period by
      cohort (kg/cohort/assessment period).

  egg_production_protein_cohort

  :   Numeric. Total egg protein output over the assessment period by
      cohort (kg protein/cohort/assessment period).

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

  :   Numeric. Energy required to produce all eggs during the assessment
      period by cohort (MJ/cohort/assessment period).

- herd_level_results:

  A herd-level `data.table`. When `has_herd_structure = FALSE`, this is
  the output from
  [`run_all_herd_module`](https://un-fao.github.io/GLEAM/reference/run_all_herd_module.md)
  and may therefore contain:

  growth_rate_herd

  :   Numeric. Annualized growth rate at which the herd reaches steady
      state (fraction). Returned when the demographic herd module is
      run.

  cohort_stock_fem_annual_nondemo

  :   Numeric. Annual number of female animals entering the
      non-demographic pathway (`FN`) over the 365-time horizon (#
      heads). When both demographic and non-demographic modules are run,
      this is derived internally from the demographic calculations.

  cohort_stock_mal_annual_nondemo

  :   Numeric. Annual number of male animals entering the
      non-demographic pathway (`MN`) over the 365-time horizon (#
      heads). When both demographic and non-demographic modules are run,
      this is derived internally from the demographic calculations.

  rest_between_nondemo_cycles_duration

  :   Numeric. Duration of the resting or empty phase between
      non-demographic cycles (days). Use `0` when there is no rest
      between cycles.

  total_nondemo_fem_duration_days

  :   Numeric. Total duration of the productive non-demographic phases
      assigned to the female non-demographic cohort block (`FN`) (days).

  total_nondemo_mal_duration_days

  :   Numeric. Total duration of the productive non-demographic phases
      assigned to the male non-demographic cohort block (`MN`) (days).

  When `has_herd_structure = TRUE`, the supplied `herd_level_data` is
  returned unchanged.

- allocation_long:

  A herd-level `data.table` in long format with one row per herd
  \\\times\\ commodity \\\times\\ emission source:

  herd_id

  :   Character. Unique identifier for the herd.

  species_short

  :   Character. Species code.

  variable_name

  :   Character. Emission variable name (e.g. `"ch4_enteric"`,
      `"n2o_manure_pasture_direct"`).

  commodity_name

  :   Character. List of commodity categories to which emissions may be
      allocated. List = c("Other", "Milk", "Meat", "Fibre", "Work",
      "Eggs")

  commodity_type

  :   Character. Commodity (commodity_name) grouping, either `"Edible"`
      or `"Non-Edible"`.

  allocation_share

  :   Numeric. Allocation share for this commodity-emission combination
      (fraction).

- aggregation_results:

  A named list from
  [`run_aggregation_module`](https://un-fao.github.io/GLEAM/reference/run_aggregation_module.md)
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

The pipeline covers seven species (CTL, BFL, CML, SHP, GTS, PGS, CHK).
Within each herd, animals are organised into the six demographic sex-age
cohorts (`FJ`, `FS`, `FA`, `MJ`, `MS`, `MA`), with optional
non-demographic cohorts (`FN`, `MN`) when the non-demographic herd
module is used. These identifiers are used consistently across all
modules.

The assessment period is specified in days via `simulation_duration`
(typically 365). Intermediate per-head-per-day variables are carried
through the cohort workflow and scaled to cohort and herd totals in the
final aggregation step.

Every cohort and productive phase must have a matching feed ration. The
pipeline stops and lists any missing combinations before merging
rations.

### Pipeline sequence

1.  If `has_herd_structure = FALSE`, generate herd structure with
    [`run_all_herd_module`](https://un-fao.github.io/GLEAM/reference/run_all_herd_module.md)
    using the selected `run_demographic` and `run_nondemographic`
    switches; otherwise use supplied tables directly.

2.  Compute cohort weights
    ([`run_weights_module`](https://un-fao.github.io/GLEAM/reference/run_weights_module.md)).

3.  Summarise ration quality
    ([`run_ration_quality_module`](https://un-fao.github.io/GLEAM/reference/run_ration_quality_module.md))
    and merge into the cohort table.

4.  Compute energy requirements and dry matter intake
    ([`run_metabolic_energy_req_module`](https://un-fao.github.io/GLEAM/reference/run_metabolic_energy_req_module.md)).

5.  Compute enteric CH4
    ([`run_emissions_enteric_module`](https://un-fao.github.io/GLEAM/reference/run_emissions_enteric_module.md)).

6.  Compute nitrogen balance
    ([`run_nitrogen_balance_module`](https://un-fao.github.io/GLEAM/reference/run_nitrogen_balance_module.md)).

7.  Compute manure emissions
    ([`run_emissions_manure_module`](https://un-fao.github.io/GLEAM/reference/run_emissions_manure_module.md)).

8.  Summarise feed production emissions
    ([`run_emissions_ration_module`](https://un-fao.github.io/GLEAM/reference/run_emissions_ration_module.md))
    and merge into the cohort table.

9.  Compute production outputs
    ([`run_production_module`](https://un-fao.github.io/GLEAM/reference/run_production_module.md)).

10. Compute allocation
    ([`run_allocation_module`](https://un-fao.github.io/GLEAM/reference/run_allocation_module.md)).

11. Aggregate to herd-level results and CO2-eq
    ([`run_aggregation_module`](https://un-fao.github.io/GLEAM/reference/run_aggregation_module.md)).

All inputs containing `herd_id` must refer to the same herd set.
Validation blocks variables that are expected to be produced internally.

## See also

[`run_all_herd_module`](https://un-fao.github.io/GLEAM/reference/run_all_herd_module.md),
[`run_demographic_herd_module`](https://un-fao.github.io/GLEAM/reference/run_demographic_herd_module.md),
[`run_weights_module`](https://un-fao.github.io/GLEAM/reference/run_weights_module.md),
[`run_ration_quality_module`](https://un-fao.github.io/GLEAM/reference/run_ration_quality_module.md),
[`run_metabolic_energy_req_module`](https://un-fao.github.io/GLEAM/reference/run_metabolic_energy_req_module.md),
[`run_emissions_enteric_module`](https://un-fao.github.io/GLEAM/reference/run_emissions_enteric_module.md),
[`run_nitrogen_balance_module`](https://un-fao.github.io/GLEAM/reference/run_nitrogen_balance_module.md),
[`run_emissions_manure_module`](https://un-fao.github.io/GLEAM/reference/run_emissions_manure_module.md),
[`run_emissions_ration_module`](https://un-fao.github.io/GLEAM/reference/run_emissions_ration_module.md),
[`run_production_module`](https://un-fao.github.io/GLEAM/reference/run_production_module.md),
[`run_allocation_module`](https://un-fao.github.io/GLEAM/reference/run_allocation_module.md),
[`run_aggregation_module`](https://un-fao.github.io/GLEAM/reference/run_aggregation_module.md)

## Examples

``` r
# Example 1: You do NOT have herd structure — use combined demographic and
# non-demographic cohort input for herd simulation. Pipeline runs herd
# simulation first, then the rest of the pipeline.
# The demographic module estimates diverted FN/MN to the non-demographic block.
if (FALSE) { # \dontrun{
path_run_gleam_examples <- system.file("extdata/run_gleam_examples", package = "gleam")

master_chrt_lvl_no_structure_dt <- data.table::fread(file.path(
  path_run_gleam_examples, "master_chrt_lvl_no_structure_mixed_data.csv"
))
master_hrd_lvl_dt <- data.table::fread(
  file.path(path_run_gleam_examples, "master_hrd_lvl_mixed_data.csv")
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
  run_demographic = TRUE,
  run_nondemographic = TRUE,
  cohort_level_data = master_chrt_lvl_no_structure_dt,
  herd_level_data = master_hrd_lvl_dt,
  feed_rations = feed_rations_chrt_dt,
  feed_params = feed_params_dt,
  feed_emissions = feed_emissions_dt,
  manure_management_system_fraction = manure_management_system_fraction_dt,
  manure_management_system_factors = manure_management_system_factors_dt,
  simulation_duration = 365
)
names(results)
} # }

# Example 2: Non-demographic-only simulation of CHK layers and broilers.
# The cohort file contains only FN/MN cohorts.
if (FALSE) { # \dontrun{
path_run_gleam_examples <- system.file("extdata/run_gleam_examples", package = "gleam")

master_chrt_lvl_no_structure_dt <- data.table::fread(file.path(
  path_run_gleam_examples, "master_chrt_lvl_no_structure_nondemo_data.csv"
))
master_hrd_lvl_dt <- data.table::fread(file.path(
  path_run_gleam_examples, "master_hrd_lvl_nondemo_data.csv"
  ))
feed_rations_chrt_dt <- data.table::fread(
  file.path(path_run_gleam_examples, "feed_rations_share_chrt_nondemo.csv")
)
feed_params_dt <- data.table::fread(
  file.path(path_run_gleam_examples, "feed_quality.csv")
)
feed_emissions_dt <- data.table::fread(
  file.path(path_run_gleam_examples, "feed_emission_factors.csv")
)
manure_management_system_fraction_dt <- data.table::fread(file.path(
  path_run_gleam_examples, "manure_management_system_fraction_nondemo.csv"
))
manure_management_system_factors_dt <- data.table::fread(file.path(
  path_run_gleam_examples, "manure_management_system_factors_nondemo.csv"
))

results <- run_gleam(
  has_herd_structure = FALSE,
  run_demographic = FALSE,
  run_nondemographic = TRUE,
  cohort_level_data = master_chrt_lvl_no_structure_dt,
  herd_level_data = master_hrd_lvl_dt,
  feed_rations = feed_rations_chrt_dt,
  feed_params = feed_params_dt,
  feed_emissions = feed_emissions_dt,
  manure_management_system_fraction = manure_management_system_fraction_dt,
  manure_management_system_factors = manure_management_system_factors_dt,
  simulation_duration = 365,
  show_indicator = TRUE
)
names(results)
} # }

# Example 3: You already HAVE herd structure — use cohort table and skip herd simulation.
# Pipeline skips herd simulation and uses this as the starting cohort table.
# The cohort file already supplies cohort_stock_size and offtake_heads_assessment.
if (FALSE) { # \dontrun{
path_run_gleam_examples <- system.file("extdata/run_gleam_examples", package = "gleam")

master_chrt_lvl_structure_dt <- data.table::fread(file.path(
  path_run_gleam_examples, "master_chrt_lvl_structure_data.csv"
))
master_hrd_lvl_dt <- data.table::fread(
file.path(path_run_gleam_examples, "master_hrd_lvl_structure_data.csv")
)
feed_rations_chrt_dt <- data.table::fread(file.path(
  path_run_gleam_examples, "feed_rations_share_chrt.csv"
))
feed_params_dt <- data.table::fread(file.path(
  path_run_gleam_examples, "feed_quality.csv"
))
feed_emissions_dt <- data.table::fread(file.path(
  path_run_gleam_examples, "feed_emission_factors.csv"
))
manure_management_system_fraction_dt <- data.table::fread(
  file.path(path_run_gleam_examples, "manure_management_system_fraction.csv")
)
manure_management_system_factors_dt <- data.table::fread(
  file.path(path_run_gleam_examples, "manure_management_system_factors.csv")
)

results <- run_gleam(
  has_herd_structure = TRUE,
  run_demographic = FALSE,
  run_nondemographic = FALSE,
  cohort_level_data = master_chrt_lvl_structure_dt,
  herd_level_data = master_hrd_lvl_dt,
  feed_rations = feed_rations_chrt_dt,
  feed_params = feed_params_dt,
  feed_emissions = feed_emissions_dt,
  manure_management_system_fraction = manure_management_system_fraction_dt,
  manure_management_system_factors = manure_management_system_factors_dt,
  simulation_duration = 365,
  show_indicator = FALSE
)
names(results)
} # }
```
