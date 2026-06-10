# Run Metabolic Energy Requirements and Dry Matter Intake Module Pipeline

Calculates cohort-level daily energy requirements (MJ/head/day) and
ration dry matter intake (kg DM/head/day) by applying the IPCC Tier 2
energy partitioning functions.

## Usage

``` r
run_metabolic_energy_req_module(
  cohort_level_data,
  herd_level_data,
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

  live_weight_cohort_average

  :   Numeric. Average live weight over the cohort stage. Computed by
      accounting for the share of offtaken animals within the cohort,
      using their slaughter weight, and the potential final weight of
      animals that remain in the cohort (kg).

  offtake_rate

  :   Numeric. Annual proportion of animals removed from the herd for
      each sex-age cohort (fraction).

  low_activity_fraction

  :   Numeric. Proportion of the assessment period during which the
      animal performs low-intensity movement typical of stall-feeding or
      near-field grazing, characterized by minimal walking distances and
      flat terrain (fraction).

  high_activity_fraction

  :   Numeric. Proportion of the assessment period during which the
      animal engages in sustained locomotion associated with herding or
      long-distance grazing, typically involving extended walking
      distances and/or uneven or hilly terrain (fraction).

  live_weight_cohort_initial

  :   Numeric. Live weight at the beginning of the cohort stage (kg).

  live_weight_cohort_final

  :   Numeric. Live weight at the end of the cohort stage, accounting
      for both surviving and offtaken animals. Computed as a weighted
      average of the potential final weight of surviving animals and the
      slaughter weight of offtaken animals, based on the offtake rate
      (kg).

  live_weight_mature_stage

  :   Numeric. Mature (adult) live weight that the animal can attain
      under given biological and management conditions (kg).

  daily_weight_gain

  :   Numeric. Average live weight gain of the cohort over the cohort
      stage (kg/head/day).

  cohort_duration_days

  :   Numeric. Amount of time that each animal spends in a specific
      cohort (days).

  ration_digestibility_fraction

  :   Numeric. Average digestibility of the feed ration, expressed as
      ratio of digestible to gross energy content (fraction).

  ration_gross_energy

  :   Numeric. Average gross energy content of the diet (MJ/kg DM).

  ration_metabolizable_energy

  :   Numeric. Average metabolizable energy content of the diet (MJ/kg
      DM).

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

  age_first_parturition

  :   Numeric. Age at first parturition for female breeding animals
      (days).

  lactating_females_fraction

  :   Numeric. Proportion of adult females that are lactating during the
      assessment period (fraction). Required only for species = CML,
      CTL, BFL, SHP, and GTS.

  milk_yield_day

  :   Numeric. Average milk yield per milk-producing animal during the
      assessment duration (kg/head/day). This value is calculated as the
      total quantity of milk produced for human consumption by
      milk-producing animals during the assessment period, divided by
      the number of milk-producing animals, and the length of the
      assessment period (days). Required only for species = CML, CTL,
      BFL, SHP, and GTS.

  milk_fat_fraction

  :   Numeric. Milk fat fraction (kg fat / kg milk). Required only for
      species = CML, CTL, BFL, SHP, and GTS.

  non_productive_duration

  :   Numeric. Period during which the animal is not performing any
      productive physiological function such as pregnancy or lactation
      (days). Required only for PGS.

  pregnancy_duration

  :   Numeric. Duration of pregnancy period (days).

  litter_size

  :   Numeric. Average number of offspring born per parturition (#
      offsprings/parturition). This value can be calculated as the total
      number of offspring born divided by the total number of
      parturitions during the year.

  death_rate_juvenile

  :   Numeric. Fraction of deaths in a herd over a year for juvenile
      cohorts (i.e. FJ and MJ), (fraction).

  live_weight_at_birth

  :   Numeric. Live weight of the animal at birth (kg).

  live_weight_at_weaning

  :   Numeric. Live weight of the animal at weaning (kg).

  lactation_duration

  :   Numeric. Duration of the lactation period, defined as the number
      of days during which the animal is lactating (days). Required only
      for PGS.

  parturition_rate

  :   Numeric. Average annual number of parturitions per female animal
      (# parturitions/adult female/year). A herd-level reproductive
      performance indicator calculated as the total number of
      parturitions (deliveries) occurring during a year divided by the
      number of adult females potentially able to give birth during that
      year.

  draught_work_hours_female

  :   Numeric. Average daily working time per adult female
      (hours/head/day). Required only for species = CML, CTL, and BFL.

  draught_work_hours_male

  :   Numeric. Average daily working time per adult male
      (hours/head/day). Required only for species = CML, CTL, and BFL.

  draught_fraction_female

  :   Numeric. Fraction of adult females involved in draught work
      (fraction). Required only for species = CML, CTL, and BFL.

  draught_fraction_male

  :   Numeric. Fraction of adult males involved in draught work
      (fraction). Required only for species = CML, CTL, and BFL.

  fibre_yield_year

  :   Numeric. Annual production yield of fibre, such as wool, cashmere,
      mohair (kg/head/year). Required only for species = CML, SHP, and
      GTS.

- show_indicator:

  Logical. Whether to display progress indicators during simulation.
  Defaults to `TRUE`.

## Value

A `data.table` with the original cohort-level input columns plus the
following new variables:

- metabolic_energy_req_maintenance:

  Numeric. Energy required for maintenance, defined as the amount of
  energy needed to keep the animal at equilibrium such that body energy
  is neither gained nor lost. Expressed as net energy for CTL, BFL, SHP,
  GTS and as metabolizable energy for CML and PGS (MJ/head/day).

- metabolic_energy_req_activity:

  Numeric. Energy required for activity, defined as the amount of energy
  needed to support animal movement and physical activity (MJ/head/day).
  Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable
  energy for CML and PGS.

- metabolic_energy_req_growth:

  Numeric. Energy required for growth (i.e., weight gain) (MJ/head/day).
  Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable
  energy for CML and PGS.

- metabolic_energy_req_lactation:

  Numeric. Energy required for lactation (MJ/head/day). Expressed as net
  energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and
  PGS.

- metabolic_energy_req_work:

  Numeric. Energy required for work, used to estimate the energy
  required for draught power for CTL, BFL and CML (MJ/head/day). Assumed
  to be 0 for other species. Expressed as net energy for CTL, BFL, SHP,
  GTS and as metabolizable energy for CML and PGS.

- metabolic_energy_req_fibre_production:

  Numeric. Energy required for the synthesis of fibre for SHP, GTS
  and CML. Assumed to be 0 for other species. (MJ/head/day). Expressed
  as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for
  CML and PGS (MJ/head/day).

- metabolic_energy_req_pregnancy:

  Numeric. Energy required for pregnancy for pregnant females
  (MJ/head/day). Expressed as net energy for CTL, BFL, SHP, GTS and as
  metabolizable energy for CML and PGS.

- net_energy_maintenance_digestible_energy_ratio:

  Numeric. Ratio of net energy available for maintenance in the diet to
  digestible energy consumed (fraction).

- net_energy_growth_digestible_energy_ratio:

  Numeric. Ratio of net energy available for growth in the diet to
  digestible energy consumed (fraction).

- metabolic_energy_req_total:

  Numeric. Total daily energy requirement (MJ/head/day). For CTL, BFL,
  SHP and GTS this is expressed as gross energy intake requirement (GE).
  For CML and PGS the function returns the summed daily metabolizable
  energy requirement.

- ration_intake:

  Numeric. Average daily dry matter intake of feed (kg DM/head/day).

## Details

This function joins `cohort_level_data` with `herd_level_data` by
`herd_id`, uses `species_short` directly for all species-specific energy
calculations, and computes IPCC Tier 2 energy partition components and
derived feed intake metrics by cohort.

Energy requirements are expressed as:

- **Net energy** for CTL, BFL, SHP, GTS.

- **Metabolizable energy** for CML and PGS.

This function represents the intermediate module of the Global Livestock
Environmental Assessment Model (GLEAM) computational pipeline
[`run_gleam()`](https://github.com/un-fao/GLEAM/reference/run_gleam.md)
to estimate animals' metabolic energy requirements and dry matter intake
and performs the following calculation sequence:

1.  Maintenance energy is computed using
    [`calc_metabolic_energy_req_maintenance`](https://github.com/un-fao/GLEAM/reference/calc_metabolic_energy_req_maintenance.md).

2.  Activity energy is computed using
    [`calc_metabolic_energy_req_activity`](https://github.com/un-fao/GLEAM/reference/calc_metabolic_energy_req_activity.md).

3.  Growth energy is computed using
    [`calc_metabolic_energy_req_growth`](https://github.com/un-fao/GLEAM/reference/calc_metabolic_energy_req_growth.md).

4.  Lactation energy is computed using
    [`calc_metabolic_energy_req_lactation`](https://github.com/un-fao/GLEAM/reference/calc_metabolic_energy_req_lactation.md).

5.  Work energy is computed using
    [`calc_metabolic_energy_req_work`](https://github.com/un-fao/GLEAM/reference/calc_metabolic_energy_req_work.md).

6.  Fibre production energy is computed using
    [`calc_metabolic_energy_req_fibre`](https://github.com/un-fao/GLEAM/reference/calc_metabolic_energy_req_fibre.md).

7.  Pregnancy energy is computed using
    [`calc_metabolic_energy_req_pregnancy`](https://github.com/un-fao/GLEAM/reference/calc_metabolic_energy_req_pregnancy.md).

8.  Diet net energy ratios are computed using
    [`calc_rem_maintenance`](https://github.com/un-fao/GLEAM/reference/calc_rem_maintenance.md)
    and
    [`calc_reg_growth`](https://github.com/un-fao/GLEAM/reference/calc_reg_growth.md)
    (ruminants only).

9.  Total daily energy requirement is computed using
    [`calc_total_metabolic_energy_req`](https://github.com/un-fao/GLEAM/reference/calc_total_metabolic_energy_req.md).

10. Daily dry matter intake is computed using
    [`calc_ration_intake`](https://github.com/un-fao/GLEAM/reference/calc_ration_intake.md).

## See also

[`run_gleam`](https://github.com/un-fao/GLEAM/reference/run_gleam.md),
[`calc_metabolic_energy_req_maintenance`](https://github.com/un-fao/GLEAM/reference/calc_metabolic_energy_req_maintenance.md),
[`calc_metabolic_energy_req_activity`](https://github.com/un-fao/GLEAM/reference/calc_metabolic_energy_req_activity.md),
[`calc_metabolic_energy_req_growth`](https://github.com/un-fao/GLEAM/reference/calc_metabolic_energy_req_growth.md),
[`calc_metabolic_energy_req_lactation`](https://github.com/un-fao/GLEAM/reference/calc_metabolic_energy_req_lactation.md),
[`calc_metabolic_energy_req_work`](https://github.com/un-fao/GLEAM/reference/calc_metabolic_energy_req_work.md),
[`calc_metabolic_energy_req_fibre`](https://github.com/un-fao/GLEAM/reference/calc_metabolic_energy_req_fibre.md),
[`calc_metabolic_energy_req_pregnancy`](https://github.com/un-fao/GLEAM/reference/calc_metabolic_energy_req_pregnancy.md),
[`calc_rem_maintenance`](https://github.com/un-fao/GLEAM/reference/calc_rem_maintenance.md),
[`calc_reg_growth`](https://github.com/un-fao/GLEAM/reference/calc_reg_growth.md),
[`calc_total_metabolic_energy_req`](https://github.com/un-fao/GLEAM/reference/calc_total_metabolic_energy_req.md),
[`calc_ration_intake`](https://github.com/un-fao/GLEAM/reference/calc_ration_intake.md)

## Examples

``` r
# \donttest{
# Load metabolic energy requirements inputs (cohort and herd-level)
metabolic_energy_req_chrt_dt <- data.table::fread(system.file(
  "extdata/run_modules_examples/metabolic_energy_req_input_chrt_data.csv",
  package = "gleam"
))
metabolic_energy_req_hrd_dt <- data.table::fread(system.file(
  "extdata/run_modules_examples/metabolic_energy_req_input_hrd_data.csv",
  package = "gleam"
))

# Run metabolic energy requirement and rations calculations
results <- run_metabolic_energy_req_module(
  cohort_level_data = metabolic_energy_req_chrt_dt,
  herd_level_data = metabolic_energy_req_hrd_dt
)
#> 🕒 Calculating metabolic energy requirements and ration, please wait…
#> ✔ Metabolic energy requirements calculation complete.
# }
```
