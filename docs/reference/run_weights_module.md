# Run Weights Module Pipeline

Calculates cohort-level live weight metrics by combining cohort-level
inputs with herd-level biological parameters. The function appends
cohort weights (initial, potential final, slaughter), then derives
average and final live weights accounting for offtake, and finally
computes average daily live weight gain over each cohort stage.

## Usage

``` r
run_weights_module(cohort_level_data, herd_level_data, show_indicator = TRUE)
```

## Arguments

- cohort_level_data:

  A `data.table` in long format with one row per herd \\\times\\ cohort.
  Must include:

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

  cohort_duration_days

  :   Numeric. Amount of time that each animal spends in a specific
      cohort (days).

  offtake_rate

  :   Numeric. Annual proportion of animals removed from the herd for
      each sex-age cohort (fraction).

- herd_level_data:

  A `data.table` with one row per herd. Must include:

  - `live_weight_female_adult` Numeric. Live weight of adult females
    (kg)

  - `live_weight_male_adult` Numeric. Live weight of adult males (kg)

  - `live_weight_at_birth` Numeric. Live weight of the animal at birth
    (kg).

  - `live_weight_at_weaning` Numeric. Live weight of the animal at
    weaning (kg)

  - `live_weight_female_at_slaughter` Numeric. Slaughter weight of
    female sub-adult animals (kg)

  - `live_weight_male_at_slaughter` Numeric. Slaughter weight of male
    sub-adult animals (kg)

- show_indicator:

  Logical. Whether to display progress indicators during calculations.
  Defaults to `TRUE`.

## Value

A named list with two `data.table`s:

- cohort_level_results:

  The input `cohort_level_data` with these additional columns:

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

- herd_level_results:

  A copy of the input `herd_level_data`.

## Details

This function represents the intermediate module of the Global Livestock
Environmental Assessment Model (GLEAM) computational pipeline
[`run_gleam()`](https://github.com/un-fao/GLEAM/reference/run_gleam.md)
to estimate animals' live weight and is composed of the following steps:

1.  **Cohort-stage weight assignment** using
    [`calc_cohort_weights`](https://github.com/un-fao/GLEAM/reference/calc_cohort_weights.md).
    Herd-level biological parameters are matched to each cohort row by
    `herd_id` via `data.table` joins.

2.  **Calculation of average and final live weights (accounting for
    offtake)** using
    [`calc_avg_weights`](https://github.com/un-fao/GLEAM/reference/calc_avg_weights.md).

3.  **Calculation of average daily live weight gain** using
    [`calc_daily_weight_gain`](https://github.com/un-fao/GLEAM/reference/calc_daily_weight_gain.md).

## See also

[`run_gleam`](https://github.com/un-fao/GLEAM/reference/run_gleam.md),
[`calc_cohort_weights`](https://github.com/un-fao/GLEAM/reference/calc_cohort_weights.md),
[`calc_avg_weights`](https://github.com/un-fao/GLEAM/reference/calc_avg_weights.md),
[`calc_daily_weight_gain`](https://github.com/un-fao/GLEAM/reference/calc_daily_weight_gain.md),

## Examples

``` r
# \donttest{
# Load weights inputs (cohort- and herd-level)
weights_chrt_dt <- data.table::fread(system.file(
  "extdata/run_modules_examples/weights_input_chrt_data.csv",
  package = "gleam"
))
weights_hrd_dt <- data.table::fread(system.file(
  "extdata/run_modules_examples/weights_input_hrd_data.csv",
  package = "gleam"
))

# Run weight calculations
results <- run_weights_module(
  cohort_level_data = weights_chrt_dt,
  herd_level_data = weights_hrd_dt
)
#> 🕒 Calculating cohort weights, please wait…
#> ✔ Cohort weights calculation complete.

# Access results
print(results$cohort_level_results)
#>     herd_id cohort_short cohort_duration_days offtake_rate
#>       <int>       <char>                <int>        <num>
#>  1:       1           FA                  989        0.000
#>  2:       1           FJ                   60        0.247
#>  3:       1           FS                  710        0.247
#>  4:       1           MA                  823        0.000
#>  5:       1           MJ                   60        0.949
#>  6:       1           MS                  710        0.949
#>  7:       2           FA                 5000        0.000
#>  8:       2           FJ                   60        0.661
#>  9:       2           FS                 1400        0.661
#> 10:       2           MA                 1820        0.000
#> 11:       2           MJ                   60        0.783
#> 12:       2           MS                 1400        0.783
#> 13:       3           FA                 1110        0.000
#> 14:       3           FJ                   60        0.453
#> 15:       3           FS                  448        0.453
#> 16:       3           MA                 2090        0.000
#> 17:       3           MJ                   60        0.913
#> 18:       3           MS                  448        0.913
#> 19:       4           FA                 2430        0.000
#> 20:       4           FJ                   60        0.543
#> 21:       4           FS                  669        0.543
#> 22:       4           MA                 2680        0.000
#> 23:       4           MJ                   60        0.836
#> 24:       4           MS                  669        0.836
#> 25:       5           FA                 2230        0.000
#> 26:       5           FJ                   60        0.737
#> 27:       5           FS                  415        0.737
#> 28:       5           MA                 1540        0.000
#> 29:       5           MJ                   60        0.974
#> 30:       5           MS                  415        0.974
#> 31:       6           FA                 2110        0.000
#> 32:       6           FJ                   60        0.359
#> 33:       6           FS                  564        0.359
#> 34:       6           MA                 2600        0.000
#> 35:       6           MJ                   60        0.644
#> 36:       6           MS                  600        0.644
#> 37:       7           FA                 3650        0.000
#> 38:       7           FJ                   60        0.664
#> 39:       7           FS                  974        0.664
#> 40:       7           MA                 1170        0.000
#> 41:       7           MJ                   60        0.906
#> 42:       7           MS                  974        0.906
#> 43:       8           FA                 1830        0.000
#> 44:       8           FJ                   60        0.134
#> 45:       8           FS                 1400        0.134
#> 46:       8           MA                 2430        0.000
#> 47:       8           MJ                   60        0.862
#> 48:       8           MS                 1400        0.862
#> 49:       9           FA                  890        0.000
#> 50:       9           FJ                   27        0.948
#> 51:       9           FS                  359        0.948
#> 52:       9           MA                  890        0.000
#> 53:       9           MJ                   27        0.973
#> 54:       9           MS                  359        0.973
#> 55:      10           FA                 3650        0.000
#> 56:      10           FJ                   90        0.952
#> 57:      10           FS                  340        0.952
#> 58:      10           MA                 3650        0.000
#> 59:      10           MJ                   90        0.974
#> 60:      10           MS                  340        0.974
#> 61:      11           FA                 5000        0.000
#> 62:      11           FJ                  370        0.000
#> 63:      11           FS                 2190        0.000
#> 64:      11           MA                 5000        0.004
#> 65:      11           MJ                  370        0.000
#> 66:      11           MS                 2190        0.496
#> 67:      12           FA                 5000        0.000
#> 68:      12           FJ                  365        0.000
#> 69:      12           FS                 1280        0.000
#> 70:      12           MA                 5000        0.004
#> 71:      12           MJ                  365        0.000
#> 72:      12           MS                 1280        0.500
#>     herd_id cohort_short cohort_duration_days offtake_rate
#>       <int>       <char>                <int>        <num>
#>     live_weight_mature_stage live_weight_cohort_initial
#>                        <num>                      <num>
#>  1:                    680.0                     680.00
#>  2:                    680.0                      41.00
#>  3:                    680.0                     250.00
#>  4:                    916.0                     916.00
#>  5:                    916.0                      41.00
#>  6:                    916.0                     250.00
#>  7:                    350.0                     350.00
#>  8:                    350.0                      14.00
#>  9:                    350.0                     220.00
#> 10:                    450.0                     450.00
#> 11:                    450.0                      14.00
#> 12:                    450.0                     220.00
#> 13:                     51.0                      51.00
#> 14:                     51.0                       4.19
#> 15:                     51.0                      30.00
#> 16:                     59.0                      59.00
#> 17:                     59.0                       4.19
#> 18:                     59.0                      30.00
#> 19:                     60.1                      60.10
#> 20:                     60.1                       5.21
#> 21:                     60.1                      35.00
#> 22:                     70.3                      70.30
#> 23:                     70.3                       5.21
#> 24:                     70.3                      35.00
#> 25:                     70.0                      70.00
#> 26:                     70.0                       3.50
#> 27:                     70.0                      15.00
#> 28:                    110.0                     110.00
#> 29:                    110.0                       3.50
#> 30:                    110.0                      15.00
#> 31:                     51.0                      51.00
#> 32:                     51.0                       3.30
#> 33:                     51.0                      14.00
#> 34:                     75.2                      75.20
#> 35:                     75.2                       3.30
#> 36:                     75.2                      14.00
#> 37:                    600.0                     600.00
#> 38:                    600.0                      38.00
#> 39:                    600.0                     130.00
#> 40:                    800.0                     800.00
#> 41:                    800.0                      38.00
#> 42:                    800.0                     130.00
#> 43:                    478.0                     478.00
#> 44:                    478.0                      32.60
#> 45:                    478.0                     110.00
#> 46:                    500.0                     500.00
#> 47:                    500.0                      32.60
#> 48:                    500.0                     110.00
#> 49:                    225.0                     225.00
#> 50:                    225.0                       1.20
#> 51:                    225.0                       7.00
#> 52:                    265.0                     265.00
#> 53:                    265.0                       1.20
#> 54:                    265.0                       7.00
#> 55:                     64.0                      64.00
#> 56:                     64.0                       1.00
#> 57:                     64.0                       6.00
#> 58:                     71.0                      71.00
#> 59:                     71.0                       1.00
#> 60:                     71.0                       6.00
#> 61:                    352.0                     352.00
#> 62:                    352.0                      28.70
#> 63:                    352.0                     120.00
#> 64:                    382.0                     382.00
#> 65:                    382.0                      28.70
#> 66:                    382.0                     120.00
#> 67:                    537.0                     537.00
#> 68:                    537.0                      32.70
#> 69:                    537.0                     150.00
#> 70:                    572.0                     572.00
#> 71:                    572.0                      32.70
#> 72:                    572.0                     150.00
#>     live_weight_mature_stage live_weight_cohort_initial
#>                        <num>                      <num>
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
print(results$herd_level_results)
#>     herd_id live_weight_female_adult live_weight_male_adult
#>       <int>                    <num>                  <num>
#>  1:       1                    680.0                  916.0
#>  2:       2                    350.0                  450.0
#>  3:       3                     51.0                   59.0
#>  4:       4                     60.1                   70.3
#>  5:       5                     70.0                  110.0
#>  6:       6                     51.0                   75.2
#>  7:       7                    600.0                  800.0
#>  8:       8                    478.0                  500.0
#>  9:       9                    225.0                  265.0
#> 10:      10                     64.0                   71.0
#> 11:      11                    352.0                  382.0
#> 12:      12                    537.0                  572.0
#>     live_weight_at_birth live_weight_female_at_slaughter
#>                    <num>                           <num>
#>  1:                41.00                           557.0
#>  2:                14.00                           250.0
#>  3:                 4.19                            35.0
#>  4:                 5.21                            51.8
#>  5:                 3.50                            25.0
#>  6:                 3.30                            29.0
#>  7:                38.00                           420.0
#>  8:                32.60                           110.0
#>  9:                 1.20                           122.0
#> 10:                 1.00                            60.0
#> 11:                28.70                           352.0
#> 12:                32.70                           537.0
#>     live_weight_male_at_slaughter live_weight_at_weaning
#>                             <num>                  <int>
#>  1:                         605.0                    250
#>  2:                         250.0                    220
#>  3:                          35.0                     30
#>  4:                          55.9                     35
#>  5:                          25.0                     15
#>  6:                          29.0                     14
#>  7:                         420.0                    130
#>  8:                         110.0                    110
#>  9:                         122.0                      7
#> 10:                          60.0                      6
#> 11:                         382.0                    120
#> 12:                         572.0                    150
# }
```
