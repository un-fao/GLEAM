# Calculate metabolic energy requirements for maintenance

Calculates the energy requirement for maintenance by cohort
(MJ/head/day), defined as the energy required to maintain basal
physiological functions at equilibrium, with no net gain or loss of body
energy.

## Usage

``` r
calc_metabolic_energy_req_maintenance(
  species_short,
  cohort_short,
  live_weight_cohort_average,
  lactating_females_fraction = NA_real_,
  offtake_rate = NA_real_,
  age_first_parturition = NA_real_
)
```

## Arguments

- species_short:

  Character. Code identifying the livestock species. Supported values
  include:

  - `PGS`: pigs

  - `CML`: camels

  - `CTL`: cattle

  - `BFL`: buffalo

  - `SHP`: sheep

  - `GTS`: goats

- cohort_short:

  Character. Sex- and age-specific cohort code describing the production
  stage of the animals. Supported values include:

  - `FA`: adult females (from age at first parturition)

  - `FS`: sub-adult females (from weaning to age at first parturition)

  - `FJ`: juvenile females (from birth to weaning)

  - `MA`: adult males (from age at first breeding)

  - `MS`: sub-adult males (from weaning to age at first breeding)

  - `MJ`: juvenile males (from birth to weaning)

- live_weight_cohort_average:

  Numeric. Average live weight over the cohort stage. Computed by
  accounting for the share of offtaken animals within the cohort, using
  their slaughter weight, and the potential final weight of animals that
  remain in the cohort (kg).

- lactating_females_fraction:

  Numeric. Proportion of adult females that are lactating during the
  assessment period (fraction). Required only for species = CML, CTL,
  BFL, SHP, and GTS.

- offtake_rate:

  Numeric. Annual proportion of animals removed from the herd for each
  sex-age cohort (fraction).

- age_first_parturition:

  Numeric. Age at first parturition for female breeding animals (days)

## Value

Numeric. Energy required for maintenance, defined as the amount of
energy needed to keep the animal at equilibrium such that body energy is
neither gained nor lost. Expressed as net energy for CTL, BFL, SHP, GTS
and as metabolizable energy for CML and PGS (MJ/head/day).

## Details

This approach follows the IPCC Tier 2 partitioning method and applies:

\\metabolic\\energy\\req\\maintenance = cmain \times
average\\weight^{0.75}\\

where \\cmain\\ is a category-specific coefficient
(MJ/day/kg\\^{0.75}\\) that reflects basal metabolic requirements and
varies by species, physiological status, and sex.

For selected cohorts, \\cmain\\ is computed as a weighted average to
account for:

- `CTL, BFL`: lactating vs. non-lactating females

- `CTL, BFL, SHP`: intact vs. castrated males - Offtaken animals assumed
  castrated

- `SHP`: animals below vs. above one year of age

**Specific coefficients by species and cohort:**

**CTL and BFL** (NRC, 1996; AFRC, 1993):

- `FA`: \\cmain = 0.386 \times lactating\\females\\fraction + 0.322
  \times (1 - lactating\\females\\fraction)\\

- `FS`, `FJ`, `MJ`: \\cmain = 0.322\\

- `MA`, `MS`: \\cmain = 0.322 \times offtake\\rate + 0.370 \times (1 -
  offtake\\rate)\\

**CML** (Wardeh, 2004):

- All cohorts: \\cmain = 0.435\\

**GTS** (AFRC, 1993):

- All cohorts: \\cmain = 0.315\\

**SHP** (AFRC, 1993):

- `FA`: \\cmain = 0.217\\

- `FJ`: \\cmain = 0.236\\

- `FS`: \\cmain = 0.236 \times (365/age\\first\\parturition) + 0.217
  \times ((age\\first\\parturition - 365)/age\\first\\parturition)\\

- `MA`: \\cmain = 0.217 \times offtake\\rate + (0.217 \times 1.15)
  \times (1 - offtake\\rate)\\

- `MJ`: \\cmain = 0.236 \times offtake\\rate + (0.236 \times 1.15)
  \times (1 - offtake\\rate)\\

- `MS`: \\cmain = (0.217 \times offtake\\rate + (0.217 \times 1.15)
  \times (1 - offtake\\rate)) \times ((age\\first\\parturition -
  365)/age\\first\\parturition) + (0.236 \times offtake\\rate + (0.236
  \times 1.15) \times (1 - offtake\\rate)) \times
  (365/age\\first\\parturition)\\

**PGS** (NRC, 1998):

- All cohorts: \\cmain = 0.4435\\

This function is part of the
[`run_metabolic_energy_req_module()`](https://github.com/un-fao/GLEAM/reference/run_metabolic_energy_req_module.md).

## References

NRC (1998). *Nutrient Requirements of Swine*, 10th Revised Edition.
National Academies Press, Washington, DC.

NRC (1996). *Nutrient Requirements of Beef Cattle*, 7th Revised Edition.
National Academies Press, Washington, DC.

AFRC (1993). *Energy and Protein Requirements of Ruminants. An Advisory
Manual Prepared by the AFRC Technical Committee on Responses to
Nutrients.* CAB International, Wallingford, UK.

IPCC. (2019). *2019 Refinement to the 2006 IPCC Guidelines for National
Greenhouse Gas Inventories*. Chapter 10: Emissions from Livestock and
Manure Management, Equation 10.3; Table 10.4.

IPCC. (2006). *2006 IPCC Guidelines for National Greenhouse Gas
Inventories*. Chapter 10: Emissions from Livestock and Manure
Management, Equation 10.3; Table 10.4.

Wardeh, M. F. (2004). *The nutrient requirements of the dromedary
camel*. Journal of Camel Science, 1(1):37-45. The Camel Applied Research
and Development Network (CARDN), Arab Center for the Studies of Arid
Zones and Dry Lands (ACSAD).

## See also

[`run_metabolic_energy_req_module`](https://github.com/un-fao/GLEAM/reference/run_metabolic_energy_req_module.md),
[`calc_avg_weights`](https://github.com/un-fao/GLEAM/reference/calc_avg_weights.md)
