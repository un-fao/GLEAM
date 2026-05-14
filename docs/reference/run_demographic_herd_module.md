# Run Demographic Herd Module Pipeline

This function takes herd- and cohort-level demographic inputs and
estimates a steady-state sex–age herd structure compatible with
downstream calculations in the Global Livestock Environmental Assessment
Model (GLEAM) computational pipeline
[`run_gleam()`](https://github.com/un-fao/GLEAM/reference/run_gleam.md).
In addition to cohort population sizes, it derives population growth
rates, and offtake numbers. The steady state is defined as a constant
sex–age cohort structure over time, with population size potentially
growing or declining at a constant rate.

## Usage

``` r
run_demographic_herd_module(
  cohort_level_data,
  herd_level_data,
  initial_herd_structure = c(FJ = 100, FS = 50, FA = 30, MJ = 100, MS = 50, MA = 30),
  max_simulation_years = 100,
  min_lambda_change = 1e-09,
  show_indicator = TRUE,
  simulation_duration = 365
)
```

## Arguments

- cohort_level_data:

  A `data.table` with the one row per herd and cohort, and the following
  mandatory columns:

  `herd_id`

  :   Character. Unique identifier for the herd, repeated for each
      cohort belonging to the same herd.

  `cohort_short`

  :   Character. Sex- and age-specific cohort code describing the
      production stage of the animals. Supported values include:

      - `FA`: adult females (from age at first parturition)

      - `FS`: sub-adult females (from weaning to age at first
        parturition)

      - `FJ`: juvenile females (from birth to weaning)

      - `MA`: adult males (from age at first breeding)

      - `MS`: sub-adult males (from weaning to age at first breeding)

      - `MJ`: juvenile males (from birth to weaning)

  `cohort_duration_days`

  :   Numeric vector of length 6. Amount of time that each animal spends
      in a specific cohort (days).

  `offtake_rate`

  :   Numeric vector of length 6. Annual proportion of animals removed
      from the herd for each sex-age cohort (fraction).

  `death_rate`

  :   Numeric vector of length 6. Fraction of deaths in a herd over a
      year for each sex-age cohort (fraction).

- herd_level_data:

  A `data.table` with one row per herd, and the following mandatory
  columns:

  `herd_id`

  :   Character. Unique identifier for the herd, repeated for each
      cohort belonging to the same herd.

  `parturition_rate`

  :   Numeric. Average annual number of parturitions per female animal
      (# parturitions/adult female/year). A herd-level reproductive
      performance indicator calculated as the total number of
      parturitions (deliveries) occurring during a year divided by the
      number of adult females potentially able to give birth during that
      year.

  `litter_size`

  :   Numeric. Average number of offspring born per parturition (#
      offspring/parturition). This value can be calculated as the total
      number of offspring born divided by the total number of
      parturitions during the year.

  `birth_fraction_female`

  :   Numeric. Female birth fraction, defined as the probability that a
      newborn offspring is female (fraction). Can be calculated as the
      number of female offspring born divided by the total number of
      offspring born.

  `herd_size_total`

  :   Numeric. Total population size at the start of the year, including
      all cohorts (# heads).

- initial_herd_structure:

  Named numeric vector of length 6. Initial number of individuals in
  each of the 6 sex-age cohorts used to bootstrap the steady-state
  simulation (# heads).These values are used as starting points for the
  iterative simulation and do not affect the final steady-state results
  (only convergence speed). Default is
  `c(FJ = 100, FS = 50, FA = 30, MJ = 100, MS = 50, MA = 30)`.

- max_simulation_years:

  Numeric. Maximum number of years to simulate (years). Defaults to
  `100`.

- min_lambda_change:

  Numeric. Convergence threshold for changes in cohort-specific growth
  rates of sex–age cohort proportions (lambda). Iterations of the herd
  simulation stop when the absolute change in lambda between successive
  iterations falls below this threshold. Defaults to `1e-9`.

- show_indicator:

  Logical. Whether to display progress indicators during simulation.
  Defaults to `TRUE`.

- simulation_duration:

  Numeric. Length of the assessment period (days).

## Value

A named list with two elements:

- `cohort_level_results`:

  A `data.table` with one row per herd and cohort containing all
  original `cohort_level_data` columns plus the following simulation
  results:

  - `cohort_stock_size` - Numeric vector of length 6. Average population
    size in each of the 6 sex–age cohorts (# heads) (cohorts = (`FJ`,
    `FS`, `FA`, `MJ`, `MS`, `MA`)). This corresponds to
    `cohort_stock_start` returned by
    [`calc_projected_population_size`](https://github.com/un-fao/GLEAM/reference/calc_projected_population_size.md),
    as it reflects the size of the population by cohort while preserving
    the total population size (`herd_size_total`) provided in the
    inputs.

  - `offtake_heads` - Numeric vector of length 6. Total number of
    animals removed via offtake over the year, aggregated to 6 sex–age
    cohorts (heads/year) (cohorts = `FJ`, `FS`, `FA`, `MJ`, `MS`, `MA`).

  - `offtake_heads_assessment` - Numeric vector of length 6. Total
    number of animals removed via offtake over the assessment period,
    aggregated to 6 sex–age cohorts (heads/assessment period) (cohorts =
    `FJ`, `FS`, `FA`, `MJ`, `MS`, `MA`).

- `herd_level_results`:

  A `data.table` with one row per herd containing all original
  `herd_level_data` columns plus the following herd-level simulation
  results:

  - `growth_rate_herd` - Numeric. Annualized growth rate at which the
    herd size reaches steady state (fraction).

## Details

The function operates under a **steady-state assumption**: demographic
parameters are constant over time, so the population converges to a
stable cohort composition and a constant annual growth rate. Once this
regime is reached, the model computes cohort population sizes
(start/end/average), cohort shares, and offtake totals.

A key feature of this implementation is that it applies demography at a
**daily** resolution. Annual mortality and offtake inputs are converted
into daily hazards and daily transition probabilities under competing
risks (death vs. offtake vs. survival).

Conceptually, this corresponds to the steady-state demographic approach
implemented in Dynmod *STEADY1* (Lesnoff, 2013), adapted here to a daily
time-step formulation within an R workflow and fully integrated into the
GLEAM computational pipeline.

### Model structure

The population is divided by sex (female/male) and age class
(juvenile/subadult/adult), represented by six cohorts:

- `FJ`, `FS`, `FA` (female juvenile, subadult, adult)

- `MJ`, `MS`, `MA` (male juvenile, subadult, adult)

Only adult females (`FA`) contribute to reproduction. Births are
distributed between females and males using `birth_fraction_female`.
Reproduction is assumed to be distributed over time (no birth pulse).
Daily fecundity rates are computed in
[`calc_fecundity_rates`](https://github.com/un-fao/GLEAM/reference/calc_fecundity_rates.md).

### Dynamics and parameters

Herd dynamics result from:

- births (driven by `parturition_rate` and `litter_size`)

- natural deaths (driven by `death_rate`)

- removals by offtake (driven by `offtake_rate`)

- cohort aging / growth transitions (driven by `cohort_duration_days`)

As in Dynmod, `offtake_rate` is interpreted as a *net removal rate* for
the cohort (e.g. slaughter), while `death_rate` represents natural
mortality excluding offtake.

### Competing risks and conversion to daily probabilities

Mortality and offtake are treated as **competing risks** within each
cohort: at any time an animal can survive, die, or be offtaken.Annual
inputs are converted to daily hazards and then daily transition
probabilities in
[`calc_transition_probabilities`](https://github.com/un-fao/GLEAM/reference/calc_transition_probabilities.md).

Internally, the model:

1.  Converts annual mortality (`death_rate`) into a daily mortality
    hazard.

2.  Solves for the daily offtake hazard such that the implied offtake
    probability matches `offtake_rate` under competing risks.

3.  Computes daily probabilities of death, offtake, and survival from
    the hazards.

### Steady state

Under constant parameters, the cohort structure converges to a stable
composition and a stable population growth rate. This function seeks
that steady state by iterating the demographic system (see
[`calc_steady_state_structure`](https://github.com/un-fao/GLEAM/reference/calc_steady_state_structure.md))
starting from `initial_herd_structure` until changes in cohort-specific
growth rates of sex–age cohort proportions (\\\lambda\\) fall below
`min_lambda_change`, or until `max_simulation_years` is reached.

### Projection of population size

The steady-state solution obtained here provides:

- cohort shares used to scale herd-level population sizes,

- a stable annual herd growth rate,

- internally consistent death, offtake, and survival probabilities.

These outputs are subsequently used to project one year of population
dynamics
([`calc_projected_population_size`](https://github.com/un-fao/GLEAM/reference/calc_projected_population_size.md))
and to summarise annual offtake and stock variation
([`calc_summary_offtake`](https://github.com/un-fao/GLEAM/reference/calc_summary_offtake.md)).

## References

Lesnoff, M. (2013). *DYNMOD: A spreadsheet interface for demographic
projections of tropical livestock populations, User's manual*. CIRAD,
Montpellier, France.

## See also

[`calc_fecundity_rates`](https://github.com/un-fao/GLEAM/reference/calc_fecundity_rates.md),
[`calc_transition_probabilities`](https://github.com/un-fao/GLEAM/reference/calc_transition_probabilities.md),
[`calc_steady_state_structure`](https://github.com/un-fao/GLEAM/reference/calc_steady_state_structure.md),
[`calc_projected_population_size`](https://github.com/un-fao/GLEAM/reference/calc_projected_population_size.md),
[`calc_summary_offtake`](https://github.com/un-fao/GLEAM/reference/calc_summary_offtake.md)

## Examples

``` r
# \donttest{
# Load herd simulation inputs (cohort- and herd-level)
herd_simulation_chrt_dt <- data.table::fread(system.file(
  "extdata/run_modules_examples/herd_simulation_input_chrt_data.csv",
  package = "gleam"
))
herd_simulation_hrd_dt <- data.table::fread(system.file(
  "extdata/run_modules_examples/herd_simulation_input_hrd_data.csv",
  package = "gleam"
))

# Run herd simulation
results <- run_demographic_herd_module(
  cohort_level_data = herd_simulation_chrt_dt,
  herd_level_data = herd_simulation_hrd_dt,
  simulation_duration = 200
)
#> 🕒 Simulating the herd structure, please wait…
#> ✔ Herd simulation complete.

# Access results
print(results$cohort_level_results)
#> Key: <herd_id, cohort_short>
#>     herd_id cohort_short cohort_duration_days offtake_rate death_rate
#>       <int>       <char>                <int>        <num>      <num>
#>  1:       1           FA                  989        0.000     0.0310
#>  2:       1           FJ                   60        0.247     0.0670
#>  3:       1           FS                  710        0.247     0.0310
#>  4:       1           MA                  823        0.000     0.0310
#>  5:       1           MJ                   60        0.949     0.0670
#>  6:       1           MS                  710        0.949     0.0310
#>  7:       2           FA                 5000        0.000     0.0500
#>  8:       2           FJ                   60        0.661     0.0700
#>  9:       2           FS                 1400        0.661     0.0500
#> 10:       2           MA                 1820        0.000     0.0500
#> 11:       2           MJ                   60        0.783     0.0700
#> 12:       2           MS                 1400        0.783     0.0500
#> 13:       3           FA                 1110        0.000     0.0650
#> 14:       3           FJ                   60        0.453     0.1710
#> 15:       3           FS                  448        0.453     0.0650
#> 16:       3           MA                 2090        0.000     0.0650
#> 17:       3           MJ                   60        0.913     0.1710
#> 18:       3           MS                  448        0.913     0.0650
#> 19:       4           FA                 2430        0.000     0.0309
#> 20:       4           FJ                   60        0.543     0.1010
#> 21:       4           FS                  669        0.543     0.0309
#> 22:       4           MA                 2680        0.000     0.0309
#> 23:       4           MJ                   60        0.836     0.1010
#> 24:       4           MS                  669        0.836     0.0309
#> 25:       5           FA                 2230        0.000     0.0200
#> 26:       5           FJ                   60        0.737     0.0500
#> 27:       5           FS                  415        0.737     0.0200
#> 28:       5           MA                 1540        0.000     0.0200
#> 29:       5           MJ                   60        0.974     0.0500
#> 30:       5           MS                  415        0.974     0.0200
#> 31:       6           FA                 2110        0.000     0.1270
#> 32:       6           FJ                   60        0.359     0.3300
#> 33:       6           FS                  564        0.359     0.1270
#> 34:       6           MA                 2600        0.000     0.1270
#> 35:       6           MJ                   60        0.644     0.3300
#> 36:       6           MS                  600        0.644     0.1270
#> 37:       7           FA                 3650        0.000     0.0400
#> 38:       7           FJ                   60        0.664     0.0800
#> 39:       7           FS                  974        0.664     0.0400
#> 40:       7           MA                 1170        0.000     0.0400
#> 41:       7           MJ                   60        0.906     0.0800
#> 42:       7           MS                  974        0.906     0.0400
#> 43:       8           FA                 1830        0.000     0.1000
#> 44:       8           FJ                   60        0.134     0.2400
#> 45:       8           FS                 1400        0.134     0.1000
#> 46:       8           MA                 2430        0.000     0.1000
#> 47:       8           MJ                   60        0.862     0.5300
#> 48:       8           MS                 1400        0.862     0.1000
#> 49:       9           FA                  890        0.000     0.0603
#> 50:       9           FJ                   27        0.948     0.1300
#> 51:       9           FS                  359        0.948     0.0509
#> 52:       9           MA                  890        0.000     0.0603
#> 53:       9           MJ                   27        0.973     0.1300
#> 54:       9           MS                  359        0.973     0.0516
#> 55:      10           FA                 3650        0.000     0.0200
#> 56:      10           FJ                   90        0.952     0.2200
#> 57:      10           FS                  340        0.952     0.0310
#> 58:      10           MA                 3650        0.000     0.0200
#> 59:      10           MJ                   90        0.974     0.2200
#> 60:      10           MS                  340        0.974     0.0305
#> 61:      11           FA                 5000        0.000     0.0630
#> 62:      11           FJ                  370        0.000     0.2800
#> 63:      11           FS                 2190        0.000     0.0300
#> 64:      11           MA                 5000        0.004     0.0630
#> 65:      11           MJ                  370        0.000     0.2800
#> 66:      11           MS                 2190        0.496     0.0300
#> 67:      12           FA                 5000        0.000     0.0600
#> 68:      12           FJ                  365        0.000     0.2000
#> 69:      12           FS                 1280        0.000     0.0300
#> 70:      12           MA                 5000        0.004     0.0600
#> 71:      12           MJ                  365        0.000     0.2000
#> 72:      12           MS                 1280        0.500     0.0300
#>     herd_id cohort_short cohort_duration_days offtake_rate death_rate
#>       <int>       <char>                <int>        <num>      <num>
#>     cohort_stock_size offtake_heads offtake_heads_assessment
#>                 <num>         <num>                    <num>
#>  1:      1.240094e+07  4.015397e+06             2.200218e+06
#>  2:      7.023271e+05  1.149662e+06             6.299519e+05
#>  3:      6.905753e+06  1.824891e+06             9.999405e+05
#>  4:      1.225347e+03  4.801632e+02             2.631031e+02
#>  5:      2.370447e+05  4.346241e+06             2.381502e+06
#>  6:      5.271326e+04  1.514360e+05             8.297863e+04
#>  7:      7.014573e+03  3.359382e+02             1.840757e+02
#>  8:      2.328332e+02  1.523096e+03             8.345734e+02
#>  9:      6.625667e+02  7.072882e+02             3.875552e+02
#> 10:      1.612192e+03  2.539230e+02             1.391359e+02
#> 11:      1.935859e+02  1.801334e+03             9.870321e+02
#> 12:      2.842486e+02  4.316695e+02             2.365312e+02
#> 13:      2.785519e+06  7.288965e+05             3.993953e+05
#> 14:      1.476204e+05  5.326455e+05             2.918605e+05
#> 15:      5.876920e+05  3.259743e+05             1.786160e+05
#> 16:      1.958993e+06  2.531053e+05             1.386878e+05
#> 17:      6.309694e+04  1.056444e+06             5.788732e+05
#> 18:      1.707810e+04  4.026396e+04             2.206245e+04
#> 19:      4.545825e+06  5.757908e+05             3.155018e+05
#> 20:      1.838593e+05  8.741053e+05             4.789618e+05
#> 21:      7.156782e+05  5.359769e+05             2.936860e+05
#> 22:      2.303766e+06  2.591738e+05             1.420130e+05
#> 23:      1.185504e+05  1.339239e+06             7.338294e+05
#> 24:      1.123206e+05  1.960767e+05             1.074393e+05
#> 25:      9.432571e+05  1.346210e+05             7.376491e+04
#> 26:      3.447891e+04  2.679635e+05             1.468293e+05
#> 27:      5.826126e+04  7.328718e+04             4.015736e+04
#> 28:      2.872073e+05  5.779800e+04             3.167014e+04
#> 29:      1.532746e+04  3.515418e+05             1.926257e+05
#> 30:      1.467928e+03  5.215234e+03             2.857663e+03
#> 31:      1.136264e+05  1.220205e+04             6.686053e+03
#> 32:      9.482460e+03  3.012785e+04             1.650841e+04
#> 33:      3.857459e+04  1.748756e+04             9.582226e+03
#> 34:      2.016955e+04  1.582635e+03             8.671974e+02
#> 35:      6.912891e+03  5.386447e+04             2.951478e+04
#> 36:      1.123412e+04  1.205651e+04             6.606306e+03
#> 37:      2.650601e+05  2.026641e+04             1.110488e+04
#> 38:      1.018474e+04  6.719274e+04             3.681794e+04
#> 39:      2.805708e+04  2.973843e+04             1.629503e+04
#> 40:      2.165653e+04  5.381888e+03             2.948980e+03
#> 41:      6.149071e+03  9.128747e+04             5.002053e+04
#> 42:      2.892509e+03  6.791890e+03             3.721584e+03
#> 43:      4.416865e+07  6.316267e+06             3.460968e+06
#> 44:      2.498356e+06  2.369657e+06             1.298442e+06
#> 45:      4.093659e+07  5.874583e+06             3.218950e+06
#> 46:      4.598860e+06  4.301470e+05             2.356970e+05
#> 47:      5.665933e+05  1.506559e+07             8.255119e+06
#> 48:      3.095179e+04  6.487573e+04             3.554835e+04
#> 49:      1.022903e+07  3.158829e+06             1.730865e+06
#> 50:      3.152269e+06  1.249115e+08             6.844464e+07
#> 51:      9.588819e+05  2.565339e+06             1.405665e+06
#> 52:      9.347594e+06  2.871834e+06             1.573608e+06
#> 53:      2.286055e+06  1.279131e+08             7.008937e+07
#> 54:      1.261730e+05  4.325333e+05             2.370046e+05
#> 55:      9.468841e+05  8.093874e+04             4.434999e+04
#> 56:      2.414018e+05  4.804328e+06             2.632509e+06
#> 57:      5.670844e+03  1.848447e+04             1.012848e+04
#> 58:      9.117222e+05  7.790147e+04             4.268574e+04
#> 59:      1.442343e+05  4.905532e+06             2.687963e+06
#> 60:      8.669005e+01  3.474927e+02             1.904070e+02
#> 61:      3.028327e+06  1.376734e+05             7.543747e+04
#> 62:      5.567416e+05  0.000000e+00             0.000000e+00
#> 63:      2.402478e+06  0.000000e+00             0.000000e+00
#> 64:      4.708059e+04  2.266325e+03             1.241822e+03
#> 65:      5.567416e+05  0.000000e+00             0.000000e+00
#> 66:      6.186313e+05  4.339350e+05             2.377726e+05
#> 67:      1.488909e+05  7.255222e+03             3.975464e+03
#> 68:      5.093173e+04  0.000000e+00             0.000000e+00
#> 69:      1.138641e+05  0.000000e+00             0.000000e+00
#> 70:      1.460977e+04  7.524338e+02             4.122925e+02
#> 71:      5.093173e+04  0.000000e+00             0.000000e+00
#> 72:      5.077177e+04  3.766352e+04             2.063755e+04
#>     cohort_stock_size offtake_heads offtake_heads_assessment
#>                 <num>         <num>                    <num>
print(results$herd_level_results)
#> Key: <herd_id>
#>     herd_id parturition_rate litter_size birth_fraction_female herd_size_total
#>       <int>            <num>       <num>                 <num>           <num>
#>  1:       1            0.800         1.0                   0.5        20300000
#>  2:       2            0.684         1.0                   0.5           10000
#>  3:       3            0.930         1.0                   0.5         5560000
#>  4:       4            0.745         1.0                   0.5         7980000
#>  5:       5            0.820         1.0                   0.5         1340000
#>  6:       6            0.910         1.7                   0.5          200000
#>  7:       7            0.800         1.0                   0.5          334000
#>  8:       8            0.835         1.0                   0.5        92800000
#>  9:       9            2.330        13.5                   0.5        26100000
#> 10:      10            1.600         7.0                   0.5         2250000
#> 11:      11            0.430         1.0                   0.5         7210000
#> 12:      12            0.830         1.0                   0.5          430000
#>     growth_rate_herd
#>                <num>
#>  1:      -0.16373626
#>  2:      -0.09552083
#>  3:      -0.22503189
#>  4:      -0.12192024
#>  5:      -0.14067431
#>  6:      -0.11165302
#>  7:      -0.10957255
#>  8:      -0.10870841
#>  9:      -0.34965339
#> 10:      -0.10382278
#> 11:       0.01025810
#> 12:       0.10336424
# }
```
