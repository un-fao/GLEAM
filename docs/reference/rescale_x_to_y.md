# Rescale a variable from one reference total to another

Rescales a vector of values expressed relative to an original reference
(`x_reference_from`) so that they sum, or scale proportionally, to a new
target reference (`y_scaling_variable`). Zero values are preserved as
zero.

## Usage

``` r
rescale_x_to_y(x_scaled_variable, x_reference_from, y_scaling_variable)
```

## Arguments

- x_scaled_variable:

  Numeric vector. Values to be rescaled.

- x_reference_from:

  Numeric vector or scalar. Original reference total used to scale
  `x_scaled_variable`.

- y_scaling_variable:

  Numeric vector or scalar. Target reference total to which
  `x_scaled_variable` should be rescaled.

## Value

Numeric vector of the same length as `x_scaled_variable`, containing the
rescaled values.

## Details

This function is part of the
[`run_all_herd_module()`](https://un-fao.github.io/GLEAM/reference/run_all_herd_module.md).

## See also

[`run_all_herd_module()`](https://un-fao.github.io/GLEAM/reference/run_all_herd_module.md)
