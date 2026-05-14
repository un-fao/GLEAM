# Calculate daily fecundity rates

Calculates the daily number of male and female offspring produced per
adult female.

## Usage

``` r
calc_fecundity_rates(parturition_rate, litter_size, birth_fraction_female)
```

## Arguments

- parturition_rate:

  Numeric. Average annual number of parturitions per female animal (#
  parturitions/adult female/year). A herd-level reproductive performance
  indicator calculated as the total number of parturitions (deliveries)
  occurring during a year divided by the number of adult females
  potentially able to give birth during that year.

- litter_size:

  Numeric. Average number of offspring born per parturition (#
  offspring/parturition). This value can be calculated as the total
  number of offspring born divided by the total number of parturitions
  during the year.

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
[`run_demographic_herd_module()`](https://github.com/un-fao/GLEAM/reference/run_demographic_herd_module.md).

## See also

[`run_demographic_herd_module()`](https://github.com/un-fao/GLEAM/reference/run_demographic_herd_module.md)

## Examples

``` r
calc_fecundity_rates(parturition_rate = 0.8, litter_size = 2, birth_fraction_female = 0.5)
#> $fecundity_female
#> [1] 0.002191781
#> 
#> $fecundity_male
#> [1] 0.002191781
#> 
```
