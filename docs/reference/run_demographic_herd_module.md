# Run Demographic Herd Module Pipeline

This function takes herd- and cohort-level demographic inputs and
estimates a steady-state sex–age herd structure compatible with
downstream calculations in the Global Livestock Environmental Assessment
Model (GLEAM) computational pipeline
[`run_gleam()`](https://un-fao.github.io/GLEAM/reference/run_gleam.md).
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

  :   Character. Unique identifier for the herd.

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

  `prop_nondemo_mal_juv`

  :   Numeric. Fraction of male juveniles diverted into the
      non-demographic stream at the moment they transition to the next
      age class (fraction).

  `prop_nondemo_fem_juv`

  :   Numeric. Fraction of female juveniles diverted into the
      non-demographic stream at the moment they transition to the next
      age class (fraction).

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

  `cohort_stock_size_unscaled`

  :   Numeric. Average population size for the assessed cohort, not
      scaled to the total livestock population (herd_size_total), (#
      heads). This corresponds to `cohort_stock_average` returned by
      [`calc_projected_population_size`](https://un-fao.github.io/GLEAM/reference/calc_projected_population_size.md)

  `cohort_stock_size_scaled`

  :   Numeric. Average population size for the assessed cohort, scaled
      to the total livestock population (herd_size_total), (# heads).
      This corresponds to `cohort_stock_start` returned by
      [`calc_projected_population_size`](https://un-fao.github.io/GLEAM/reference/calc_projected_population_size.md)

  `offtake_heads_unscaled`

  :   Numeric. Total number of animals removed from the cohort over the
      full 365-day simulation horizon, not scaled to the cohort
      population at the start of the assessment period (# heads).

  `offtake_heads_assessment_unscaled`

  :   Numeric. Total number of animals removed from the cohort over
      'simulation_duration', not scaled to the cohort population at the
      start of the assessment period (# heads/assessment period).

  `offtake_heads_scaled`

  :   Numeric. Total number of animals removed from the cohort over the
      full 365-day simulation horizon, scaled to the cohort population
      at the start of the assessment period (# heads).

  `offtake_heads_assessment_scaled`

  :   Numeric. Total number of animals removed from the cohort over
      'simulation_duration', scaled to the cohort population at the
      start of the assessment period (# heads/assessment period).

  `cohort_stock_annual_nondemographic`

  :   Numeric. Annual number of animals diverted from the demographic
      pathway into the non-demographic pathway (# heads).

- `herd_level_results`:

  A `data.table` with one row per herd containing all original
  `herd_level_data` columns plus the following herd-level simulation
  results:

  `growth_rate_herd`

  :   Numeric. Annualized growth rate at which the herd size reaches
      steady state (fraction).

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
[`calc_fecundity_rates`](https://un-fao.github.io/GLEAM/reference/calc_fecundity_rates.md).

### Dynamics and parameters

Herd dynamics result from:

- births (driven by `parturition_rate` and `litter_size`)

- natural deaths (driven by `death_rate`)

- removals by offtake (driven by `offtake_rate`)

- cohort aging / growth transitions (driven by `cohort_duration_days`)

- optional diversion of animals from the demographic pathway into the
  non-demographic pathway at cohort transitions

As in Dynmod, `offtake_rate` is interpreted as a *net removal rate* for
the cohort (e.g. slaughter), while `death_rate` represents natural
mortality excluding offtake.

### Diversion into the non-demographic block

This implementation can divert part of the demographic flow into the
non-demographic block. Diversion is controlled at herd level through:

- `prop_nondemo_fem_juv`: fraction of female juveniles diverted when
  transitioning from `FJ -> FS`

- `prop_nondemo_mal_juv`: fraction of male juveniles diverted when
  transitioning from `MJ -> MS`

Internally, these herd-level inputs are expanded into the named vector
`proportion_nondemographic`, which is aligned with the six demographic
cohorts (`FJ`, `FS`, `FA`, `MJ`, `MS`, `MA`). In the current demographic
herd module, only the juvenile entries are populated from user inputs
and the remaining cohort entries are set to zero.

Diversion is applied after the model computes the number of animals
leaving a cohort through aging or progression, and before those animals
are added to the next demographic cohort. For example:

- a share of `FJ -> FS` transitions is removed from the demographic
  female flow and counted as entrants to the female non-demographic
  block

- a share of `MJ -> MS` transitions is removed from the demographic male
  flow and counted as entrants to the male non-demographic block

The diverted animals are reported in
`cohort_stock_annual_nondemographic`, which represents the annual number
of animals leaving the demographic model and entering the
non-demographic component. When diversion fractions are set to zero,
demographic transitions reduce to the original no-diversion case.

### Competing risks and conversion to daily probabilities

Mortality and offtake are treated as **competing risks** within each
cohort: at any time an animal can survive, die, or be offtaken.Annual
inputs are converted to daily hazards and then daily transition
probabilities in
[`calc_transition_probabilities`](https://un-fao.github.io/GLEAM/reference/calc_transition_probabilities.md).

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
[`calc_steady_state_structure`](https://un-fao.github.io/GLEAM/reference/calc_steady_state_structure.md))
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
([`calc_projected_population_size`](https://un-fao.github.io/GLEAM/reference/calc_projected_population_size.md))
and to summarise annual offtake and stock variation
([`calc_summary_offtake`](https://un-fao.github.io/GLEAM/reference/calc_summary_offtake.md)).
In both the steady-state and projected-population calculations,
diversion to the non-demographic block is treated as a competing outflow
on the relevant cohort transition, separate from death and offtake.

## References

Lesnoff, M. (2013). *DYNMOD: A spreadsheet interface for demographic
projections of tropical livestock populations, User's manual*. CIRAD,
Montpellier, France.

## See also

[`calc_fecundity_rates`](https://un-fao.github.io/GLEAM/reference/calc_fecundity_rates.md),
[`calc_transition_probabilities`](https://un-fao.github.io/GLEAM/reference/calc_transition_probabilities.md),
[`calc_steady_state_structure`](https://un-fao.github.io/GLEAM/reference/calc_steady_state_structure.md),
[`calc_projected_population_size`](https://un-fao.github.io/GLEAM/reference/calc_projected_population_size.md),
[`calc_summary_offtake`](https://un-fao.github.io/GLEAM/reference/calc_summary_offtake.md)

## Examples

``` r
# \donttest{
# Load demographic herd simulation inputs (cohort and herd-level)
herd_simulation_chrt_dt <- data.table::fread(system.file(
  "extdata/run_modules_examples/herd_simulation_input_chrt_data.csv",
  package = "gleam"
))
herd_simulation_hrd_dt <- data.table::fread(system.file(
  "extdata/run_modules_examples/herd_simulation_input_hrd_data.csv",
  package = "gleam"
))

# Run demographic herd simulation
results <- run_demographic_herd_module(
  cohort_level_data = herd_simulation_chrt_dt,
  herd_level_data = herd_simulation_hrd_dt,
  simulation_duration = 365,
  show_indicator = TRUE
)
# }
```
