# Convert methane (CH4) and nitrous oxide (N2O) emissions to CO2-equivalents (CO2eq) using Global Warming Potentials (GWP) factors

Calculates CO2-equivalent (CO2eq) emissions for CH4 and N2O based on
100-year Global Warming Potentials (GWP) reported in IPCC assessment
reports.

## Usage

``` r
calc_co2eq(gas, value_allocated, global_warming_potential_set)
```

## Arguments

- gas:

  Character. Gas type for each observation. Supported values:

  - `"CH4"`: methane (CH4)

  - `"N2O"`: nitrous oxide (N2O)

  - `"CO2"`: carbon dioxide (CO2)

- value_allocated:

  Numeric. Allocated emissions for each commodity–emission combination
  (kg gas).

- global_warming_potential_set:

  Character. Settings for the 100-year Global Warming Potential
  (GWP-100) conversion factors used to express CH4 and N2O emissions as
  CO2eq. Must be one of:

  - `"AR6"`: IPCC Sixth Assessment Report (IPCC, 2021) — CH4 = 27, N2O =
    273

  - `"AR5_excluding_carbon_feedback"`: IPCC Fifth Assessment Report
    (excluding climate–carbon feedbacks) (IPCC, 2013) — CH4 = 28, N2O =
    265

  - `"AR5_including_carbon_feedback"`: IPCC Fifth Assessment Report
    (including climate–carbon feedbacks) (IPCC, 2013) — CH4 = 34, N2O =
    298

  - `"AR4"`: IPCC Fourth Assessment Report (IPCC, 2007) — CH4 = 25, N2O
    = 298

## Value

List with elements:

- value_co2eq:

  Numeric vector. Emissions expressed as CO2-equivalents (kg CO2eq).

- gwp:

  Numeric vector. Global Warming Potential factor applied to each
  observation (kg CO2eq/kg gas).

## Details

CO2-equivalent emissions are calculated as:

\$\$value\\co2eq = value\\allocated \times gwp\$\$

where `gwp` is the gas-specific 100-year Global Warming Potential factor
from the selected IPCC assessment report.

This function is part of the
[`run_aggregation_module()`](https://github.com/un-fao/GLEAM/reference/run_aggregation_module.md).

## References

IPCC (2007). Climate Change 2007: The Physical Science Basis.
Contribution of Working Group I to the Fourth Assessment Report of the
Intergovernmental Panel on Climate Change.

IPCC (2013). Climate Change 2013: The Physical Science Basis.
Contribution of Working Group I to the Fifth Assessment Report of the
Intergovernmental Panel on Climate Change.

IPCC (2021). Climate Change 2021: The Physical Science Basis.
Contribution of Working Group I to the Sixth Assessment Report of the
Intergovernmental Panel on Climate Change.

## See also

[`run_aggregation_module()`](https://github.com/un-fao/GLEAM/reference/run_aggregation_module.md),
