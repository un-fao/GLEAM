# Calculate metabolic energy requirements for activity

Calculates the energy requirement for activity by cohort (MJ/head/day),
defined as the amount of energy needed to support animal movement and
physical activity.

## Usage

``` r
calc_metabolic_energy_req_activity(
  species_short,
  cohort_short,
  metabolic_energy_req_maintenance,
  live_weight_cohort_average,
  low_activity_fraction,
  high_activity_fraction
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

- metabolic_energy_req_maintenance:

  Numeric. Energy required for maintenance, defined as the amount of
  energy needed to keep the animal at equilibrium such that body energy
  is neither gained nor lost. Expressed as net energy for CTL, BFL, SHP,
  GTS and as metabolizable energy for CML and PGS (MJ/head/day).

- live_weight_cohort_average:

  Numeric. Average live weight over the cohort stage. Computed by
  accounting for the share of offtaken animals within the cohort, using
  their slaughter weight, and the potential final weight of animals that
  remain in the cohort (kg).

- low_activity_fraction:

  Numeric. Proportion of the assessment period during which the animal
  performs low-intensity movement typical of stall-feeding or near-field
  grazing, characterized by minimal walking distances and flat terrain
  (fraction).

- high_activity_fraction:

  Numeric. Proportion of the assessment period during which the animal
  engages in sustained locomotion associated with herding or
  long-distance grazing, typically involving extended walking distances
  and/or uneven or hilly terrain (fraction).

## Value

Numeric. Energy required for activity, defined as the amount of energy
needed to support animal movement and physical activity (MJ/head/day).
Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable
energy for CML and PGS.

## Details

This approach follows the IPCC Tier 2 energy partitioning method and
applies:

\\metabolic\\energy\\req\\activity = cact \times
metabolic\\energy\\req\\maintenance\\

For `SHP` and `GTS`, activity energy is calculated as:

\\metabolic\\energy\\req\\activity = cact \times
live\\weight\\cohort\\average\\

where

\\cact\\ is an activity coefficient (dimensionless for `CTL`, `BFL`,
`PGS`; MJ/day/kg for `SHP`, `GTS`) that reflects the animal’s feeding
and management conditions. `metabolic_energy_req_maintenance` can be
calculated using
[`calc_metabolic_energy_req_maintenance()`](https://github.com/un-fao/GLEAM/reference/calc_metabolic_energy_req_maintenance.md).

For `CTL, BFL, SHP` and `GTS`, \\cact\\ is computed as a *weighted
average* of activity levels over the assessment period to account for
variation in management and grazing intensity.

**Specific coefficients by species and cohort:**

**CTL, BFL** (NRC, 1996; AFRC, 1993):

- `low_activity_fraction`: \\cact = 0.17\\

- `high_activity_fraction`: \\cact = 0.36\\

**CML** (Wardeh, 2004):

- `all activity levels`: \\cact = 0.1\\

**GTS** (AFRC, 1993):

- `low_activity_fraction`: \\cact = 0.019\\

- `high_activity_fraction`: \\cact = 0.024\\

**SHP** (AFRC, 1993):

- `low_activity_fraction`: \\cact = 0.0107\\

- `high_activity_fraction`: \\cact = 0.024\\

**PGS** (NRC, 1998):

- `all activity levels`: \\cact = 0.125\\

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
Greenhouse Gas Inventories*, Chapter 10: Emissions from Livestock and
Manure Management, Equation 10.4; Table 10.5.

IPCC. (2006). *2006 IPCC Guidelines for National Greenhouse Gas
Inventories*, Chapter 10: Emissions from Livestock and Manure
Management, Equation 10.4; Table 10.5.

Wardeh, M. F. (2004). *The nutrient requirements of the dromedary
camel*. Journal of Camel Science, 1(1):37-45. The Camel Applied Research
and Development Network (CARDN), Arab Center for the Studies of Arid
Zones and Dry Lands (ACSAD).

## See also

[`run_metabolic_energy_req_module`](https://github.com/un-fao/GLEAM/reference/run_metabolic_energy_req_module.md),
[`calc_metabolic_energy_req_maintenance`](https://github.com/un-fao/GLEAM/reference/calc_metabolic_energy_req_maintenance.md),
[`calc_avg_weights`](https://github.com/un-fao/GLEAM/reference/calc_avg_weights.md)
