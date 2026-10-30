# Calculate nondemographic entrants across production cycles

Distributes the total number of animals entering a nondemographic cohort
over the production cycles occurring within the simulated period, based
on the number of cycle starts occurring within the fixed 365-day
horizon.

## Usage

``` r
calc_nondemo_start_sizes(
  cohort_stock_nondemo_annual_entrants,
  total_nondemo_cycle_starts_to_distribute
)
```

## Arguments

- cohort_stock_nondemo_annual_entrants:

  Numeric. Total number of animals entering the nondemographic
  production pathway over the simulated period for the assessed cohort
  block (`FN` or `MN`) (heads / simulated period).

- total_nondemo_cycle_starts_to_distribute:

  Integer. Total number of cycle starts within the fixed 365-day time
  horizon for the assessed non-demographic cohort (`FN` or `MN`) (#
  cycle starts).

## Value

A named list with the following element:

- cohort_stock_nondemo_start_cycle:

  Numeric. Number of animals starting each nondemographic production
  cycle for the assessed cohort block (`FN` or `MN`), calculated by
  distributing total annual entrants over the total number of cycle
  starts (heads / cycle).

## Details

The annual entrant stock is evenly distributed across all defined
production cycle starts. The number of animals entering each cycle is
calculated as:

\$\$ cohort\\stock\\nondemo\\start\\cycle =
\frac{cohort\\stock\\nondemo\\annual\\entrants}
{total\\non\\demo\\cycle\\starts\\to\\distribute} \$\$

where:

- `cohort_stock_nondemo_start_cycle` is the number of animals entering
  each cycle

- `cohort_stock_nondemo_annual_entrants` is the total annual entrants

- `total_non_demo_cycle_starts_to_distribute` is the number of cycle
  starts

No rounding or integer enforcement is applied:

This means fractional values may occur when
`cohort_stock_nondemo_annual_entrants` is not perfectly divisible by
`total_non_demo_cycle_starts_to_distribute`. Handling of integer
constraints (if required) is delegated to downstream processes.

This function is part of the
[`run_nondemographic_herd_module()`](https://un-fao.github.io/GLEAM/reference/run_nondemographic_herd_module.md).

## See also

[`run_nondemographic_herd_module()`](https://un-fao.github.io/GLEAM/reference/run_nondemographic_herd_module.md)
