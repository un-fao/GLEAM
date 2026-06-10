# Calculate Volatile Solids (VS)

Calculates daily volatile solids (VS) excretion in manure (kg
VS/head/day). VS represent the organic fraction of manure dry matter,
including both biodegradable and non-biodegradable organic material. VS
is a key intermediate variable required for estimating methane (CH4)
emissions from manure management systems under IPCC methodologies.

## Usage

``` r
calc_volatile_solids(
  ration_intake,
  ration_digestibility_fraction,
  ration_urinary_energy_fraction,
  ration_ash
)
```

## Arguments

- ration_intake:

  Numeric. Average daily dry matter intake of feed (kg DM/head/day).

- ration_digestibility_fraction:

  Numeric. Average digestibility of the feed ration, expressed as ratio
  of digestible to gross energy content (fraction).

- ration_urinary_energy_fraction:

  Numeric. Fraction of feed's gross energy that is excreted in urine
  (fraction).

- ration_ash:

  Numeric. Average ash content of feed, calculated as a fraction of the
  dry matter intake (kg ash/kg DM).

## Value

Numeric. Total volatile solids (VS) excreted per animal per day,
representing the organic material in livestock manure and consisting of
both biodegradable and non-biodegradable fractions (kg VS/head/day).

## Details

The IPCC recommends estimating volatile solids (VS) excretion from feed
intake and digestibility when country-specific average daily VS
excretion rates are not available. The core relationship is provided in
**IPCC Equation 10.24 (Volatile solids excretion rates)**, which
estimates daily VS excretion as a function of:

- Gross energy intake (gross_energy_intake, MJ/day)

- Digestibility of the diet (ration_digestibility_fraction)

- Urinary energy expressed as a fraction of GE
  (ration_urinary_energy_fraction)

- Ash content of the diet (ration_ash, fraction of dry matter)

- A conversion factor representing the average gross energy content of
  dry matter (18.45 MJ/kg DM)

The general structure of Eq. 10.24 partitions gross energy intake into
digestible energy, urinary losses, and ash, and converts the remaining
organic matter into volatile solids using the energy density of dry
matter.

**Implementation note.** This function applies an algebraically
simplified formulation from Equation 10.24 of IPCC.

In this implementation, the function takes `ration_intake` directly as
an input. It can be calculated upstream with
[`calc_ration_intake`](https://github.com/un-fao/GLEAM/reference/calc_ration_intake.md)
as a function of energy requirements and the energy content of the diet.

\$\$ dry\\matter\\intake =
\frac{gross\\energy\\intake}{diet\\gross\\energy} \$\$

This reflects the use of ration-specific energy content upstream and
avoids assuming a fixed gross energy density of 18.45 MJ/kg DM, as in
the IPCC default approach.

The volatile solids excretion is then calculated as:

\$\$ volatile\\solids = dry\\matter\\intake \times (1 -
diet\\digestibility\\fraction + urinary\\energy\\fraction) \times (1 -
diet\\ash) \$\$

The resulting calculations are algebraically equivalent to the IPCC
approach and fully consistent with Equation 10.24.

This function is part of the
[`run_emissions_manure_module()`](https://github.com/un-fao/GLEAM/reference/run_emissions_manure_module.md).

## References

IPCC. (2019). *2019 Refinement to the 2006 IPCC Guidelines for National
Greenhouse Gas Inventories*, Chapter 10: Emissions from Livestock and
Manure Management. Equation 10.24.

IPCC. (2006). *2006 IPCC Guidelines for National Greenhouse Gas
Inventories*, Chapter 10: Emissions from Livestock and Manure
Management. Equation 10.24.

## See also

[`run_emissions_manure_module`](https://github.com/un-fao/GLEAM/reference/run_emissions_manure_module.md)

## Examples

``` r
calc_volatile_solids <- calc_volatile_solids(
  ration_intake = 5,
  ration_digestibility_fraction = 0.6,
  ration_urinary_energy_fraction = 0.04,
  ration_ash = 0.08
)
```
