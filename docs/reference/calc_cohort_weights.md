# Calculate live weights by cohort and life stage

Determines the initial, potential final, and slaughter live weights for
a given cohort based on species-specific biological parameters. The
function handles demographic cohorts (`FJ`, `FS`, `FA`, `MJ`, `MS`,
`MA`) and nondemographic cohorts (`FN`, `MN`).

## Usage

``` r
calc_cohort_weights(
  species_short = NA_character_,
  cohort_short,
  live_weight_female_adult = NA_real_,
  live_weight_male_adult = NA_real_,
  live_weight_at_birth = NA_real_,
  live_weight_female_at_slaughter = NA_real_,
  live_weight_male_at_slaughter = NA_real_,
  live_weight_at_weaning = NA_real_,
  nondemo_productive_phase_id = NA_real_,
  live_weight_female_nondemographic_start = NA_real_,
  live_weight_female_nondemographic_end = NA_real_,
  live_weight_male_nondemographic_start = NA_real_,
  live_weight_male_nondemographic_end = NA_real_,
  phase1_nondemo_fem_duration_days = NA_real_,
  phase2_nondemo_fem_duration_days = NA_real_,
  phase1_nondemo_mal_duration_days = NA_real_,
  phase2_nondemo_mal_duration_days = NA_real_
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

  - `CHK`: chickens

- cohort_short:

  Character. Sex-specific cohort code describing the age and/or the
  production stage of the animals. Supported values include:

  - `FA`: adult females (from age at first parturition)

  - `FS`: sub-adult females (from weaning to age at first parturition)

  - `FJ`: juvenile females (from birth to weaning)

  - `MA`: adult males (from age at first breeding)

  - `MS`: sub-adult males (from weaning to age at first breeding)

  - `MJ`: juvenile males (from birth to weaning)

  - `FN`: non-demographic females

  - `MN`: non-demographic males

- live_weight_female_adult:

  Numeric. Live weight of adult females (kg)

- live_weight_male_adult:

  Numeric. Live weight of adult males (kg)

- live_weight_at_birth:

  Numeric. Live weight of the animal at birth (kg).

- live_weight_female_at_slaughter:

  Numeric. Slaughter weight of female sub-adult animals (kg).

- live_weight_male_at_slaughter:

  Numeric. Slaughter weight of male sub-adult animals (kg).

- live_weight_at_weaning:

  Numeric. Live weight of the animal at weaning (kg)

- nondemo_productive_phase_id:

  Numeric. Productive phase identifier for non-demographic cohorts
  (`FN`, `MN`). Takes value `1` for phase 1 and optionally `2` for
  phase 2. Demographic cohorts use `NA`.

- live_weight_female_nondemographic_start:

  Numeric. Live weight of female animals at the beginning of the
  nondemographic cycle (kg).

- live_weight_female_nondemographic_end:

  Numeric. Live weight of female animals at the end of the
  nondemographic cycle (kg).

- live_weight_male_nondemographic_start:

  Numeric. Live weight of male animals at the beginning of the
  nondemographic cycle (kg).

- live_weight_male_nondemographic_end:

  Numeric. Live weight of male animals at the end of the nondemographic
  cycle (kg).

- phase1_nondemo_fem_duration_days:

  Numeric. Duration of productive phase 1 for the female non-demographic
  cohort (`FN`) (days).

- phase2_nondemo_fem_duration_days:

  Numeric. Duration of productive phase 2 for the female non-demographic
  cohort (`FN`) (days).

- phase1_nondemo_mal_duration_days:

  Numeric. Duration of productive phase 1 for the male nondemographic
  cohort (`MN`) (days).

- phase2_nondemo_mal_duration_days:

  Numeric. Duration of productive phase 2 for the male non-demographic
  cohort (`MN`) (days).

## Value

A named list with:

- live_weight_cohort_initial:

  Numeric. Live weight at the beginning of the cohort stage (kg).

- live_weight_cohort_potential_final:

  Numeric. Potential final live weight attainable at the end of the
  cohort stage in the absence of offtake (kg). (For juveniles: equals
  weaning weight; For subadults: equals adult live weight; For adults:
  equals adult live weight)

- live_weight_cohort_at_slaughter:

  Numeric. Live weight at slaughter for animals removed from the cohort
  (kg).

- live_weight_mature_stage:

  Numeric. Mature (adult) live weight that the animal can attain under
  given biological and management conditions (kg).

## Details

The function attributes weights according to cohort and animal type:

- **Juveniles** (`"FJ"`, `"MJ"`):

  - `live_weight_cohort_initial = live_weight_at_birth`

  - `live_weight_cohort_potential_final = live_weight_at_weaning`

  - `live_weight_cohort_at_slaughter = live_weight_at_weaning`

- **Subadults** (`"FS"`, `"MS"`):

  - `live_weight_cohort_initial = live_weight_at_weaning`

  - `live_weight_cohort_potential_final` = adult weight for the cohort
    sex (`live_weight_female_adult` for `"FS"`, `live_weight_male_adult`
    for `"MS"`)

  - `live_weight_cohort_at_slaughter` = subadult slaughter weight for
    the cohort sex (`live_weight_female_at_slaughter` for `"FS"`,
    `live_weight_male_at_slaughter` for `"MS"`)

- **Adults** (`"FA"`, `"MA"`):

  - `live_weight_cohort_initial = live_weight_female_adult` for `"FA"`,
    and `live_weight_cohort_initial = live_weight_male_adult` for `"MA"`

  - `live_weight_cohort_potential_final` = adult weight for the cohort
    sex

  - `live_weight_cohort_at_slaughter` = adult weight for the cohort sex

- **Nondemographic cohorts** (`"FN"`, `"MN"`):

  - a linear live-weight gain is computed from the nondemographic start
    and end weights over the total nondemographic duration

  - for `nondemo_productive_phase_id = 1`, the initial weight is the
    nondemographic start weight and the potential final weight is the
    end of phase 1

  - for `nondemo_productive_phase_id = 2`, the initial weight is the end
    of phase 1 and the potential final weight is the end of phase 2

  - `live_weight_cohort_at_slaughter` is set equal to the phase-specific
    potential final weight

For chickens, the juvenile stage is represented as a very short
hatch-to-day-3 period. Accordingly, this implementation sets
`live_weight_at_weaning = live_weight_at_birth` whenever
`species_short = "CHK"`, so that demographic juvenile cohorts do not
introduce artificial early growth before the subsequent subadult phase.

This function is part of the
[`run_weights_module()`](https://un-fao.github.io/GLEAM/reference/run_weights_module.md).

## See also

[`run_weights_module`](https://un-fao.github.io/GLEAM/reference/run_weights_module.md)
