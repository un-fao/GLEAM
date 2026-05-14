# Calculate live weights by cohort and life stage

Determines the initial, potential final, and slaughter live weights for
a given sex–age cohort based on species‑specific biological parameters.
The function assigns weights according to the animal's life stage
(juvenile, subadult, adult) and the sex of the cohort.

## Usage

``` r
calc_cohort_weights(
  cohort_short,
  live_weight_female_adult = NA_real_,
  live_weight_male_adult = NA_real_,
  live_weight_at_birth = NA_real_,
  live_weight_female_at_slaughter = NA_real_,
  live_weight_male_at_slaughter = NA_real_,
  live_weight_at_weaning = NA_real_
)
```

## Arguments

- cohort_short:

  Character. Sex- and age-specific cohort code describing the production
  stage of the animals. Supported values include:

  - `FA`: adult females (from age at first parturition)

  - `FS`: sub-adult females (from weaning to age at first parturition)

  - `FJ`: juvenile females (from birth to weaning)

  - `MA`: adult males (from age at first breeding)

  - `MS`: sub-adult males (from weaning to age at first breeding)

  - `MJ`: juvenile males (from birth to weaning)

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

This function is part of the
[`run_weights_module()`](https://github.com/un-fao/GLEAM/reference/run_weights_module.md).

## See also

[`run_weights_module`](https://github.com/un-fao/GLEAM/reference/run_weights_module.md)
