# Calculate daily fecundity rates

Calculates the daily number of male and female offspring produced per
adult female.

## Usage

``` r
calc_fecundity_rates(
  reproductive_rate,
  offspring_per_reproductive_event,
  birth_fraction_female
)
```

## Arguments

- reproductive_rate:

  Numeric. Average annual number of parturitions per reproductive female
  (# parturitions/reproductive female/year). For chickens, annual number
  of eggs laid for reproduction per breeding hen (# eggs/hen/year).

- offspring_per_reproductive_event:

  Numeric. Average number of offspring born per parturition (#
  offspring/parturition). For chickens, hatchability of eggs laid for
  reproduction, calculated as the number of chicks hatched divided by
  the number of eggs laid for reproduction (fraction).

- birth_fraction_female:

  Numeric. Female birth fraction, defined as the probability that a
  newborn offspring is female (fraction). Can be calculated as the
  number of female offspring born divided by the total number of
  offspring born.

## Value

A named list with two elements:

- fecundity_female:

  Numeric. Daily number of female offspring per adult female (#
  offspring/day)

- fecundity_male:

  Numeric. Daily number of male offspring per adult female (#
  offspring/day)

This function is part of the
[`run_demographic_herd_module()`](https://un-fao.github.io/GLEAM/reference/run_demographic_herd_module.md).

## See also

[`run_demographic_herd_module()`](https://un-fao.github.io/GLEAM/reference/run_demographic_herd_module.md)

## Examples

``` r
calc_fecundity_rates(reproductive_rate = 0.8, offspring_per_reproductive_event = 2, birth_fraction_female = 0.5)
#> $fecundity_female
#> [1] 0.002191781
#> 
#> $fecundity_male
#> [1] 0.002191781
#> 
```
