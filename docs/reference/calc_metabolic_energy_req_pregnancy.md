# Calculate metabolic energy requirements for pregnancy

Calculates the energy requirement for pregnancy by cohort (MJ/head/day)
for pregnant females, defined as the additional energy needed to support
gestation.

## Usage

``` r
calc_metabolic_energy_req_pregnancy(
  species_short,
  cohort_short,
  metabolic_energy_req_maintenance = NA_real_,
  parturition_rate = NA_real_,
  litter_size = NA_real_,
  pregnancy_duration = NA_real_,
  non_productive_duration = NA_real_,
  lactation_duration = NA_real_,
  cohort_duration_days = NA_real_,
  offtake_rate = NA_real_
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

- pregnancy_duration:

  Numeric. Duration of pregnancy period (days).

- non_productive_duration:

  Numeric. Period during which the animal is not performing any
  productive physiological function such as pregnancy or lactation
  (days). Required only for PGS.

- lactation_duration:

  Numeric. Duration of the lactation period, defined as the number of
  days during which the animal is lactating (days). Required only for
  PGS.

- cohort_duration_days:

  Numeric. Amount of time that each animal spends in a specific cohort
  (days).

- offtake_rate:

  Numeric. Annual proportion of animals removed from the herd for each
  sex-age cohort (fraction).

## Value

Numeric. Energy required for pregnancy for pregnant females
(MJ/head/day). Expressed as net energy for CTL, BFL, SHP, GTS and as
metabolizable energy for CML and PGS.

## Details

This component follows the IPCC Tier 2 partitioning framework and is
applied only to **female cohorts** (`FA` and `FS`).

Pregnancy energy (`metabolic_energy_req_pregnancy`) represents the
additional energy required to support gestation. Requirements are
computed as a fraction of maintenance energy and are adjusted to reflect
reproductive activity within the cohort:

- For `FA`, requirements are scaled by the annual parturition rate
  (`parturition_rate`) and (when applicable) by the fraction of the
  reproductive cycle spent in gestation
  (`pregnancy_duration/(pregnancy_duration+lactation_duration+non_productive_duration)`).

- For `FS`, only a fraction of animals is assumed to reach reproductive
  age within the cohort; requirements are therefore scaled by the
  proportion remaining in the cohort (\\1 - offtake\\rate\\) and by the
  share of the cohort duration spent pregnant
  (`pregnancy_duration/cohort_duration_days`).

**General form** \$\$ metabolic\\energy\\req\\pregnancy =
metabolic\\energy\\req\\maintenance \times c\_{preg} \times S \$\$

where

- \\c\_{preg}\\ is a species-specific pregnancy coefficient,

- \\S\\ is a scaling term that depends on cohort (`FA` vs `FS`).

- \\metabolic\\energy\\req\\maintenance\\ can be calculated using
  [`calc_metabolic_energy_req_maintenance()`](https://github.com/un-fao/GLEAM/reference/calc_metabolic_energy_req_maintenance.md)

**Specific coefficients by species and cohort:**

- **CTL and BFL** (IPCC, 2006, 2019): Pregnancy energy is approximated
  as \\10\\\\ of maintenance energy.

  - `FA`: \$\$ \begin{aligned} metabolic\\energy\\req\\pregnancy &= 0.10
    \times metabolic\\energy\\req\\maintenance \times parturition\\rate
    \times \\ & \frac{pregnancy\\duration}{365} \end{aligned} \$\$

  - `FS`: \$\$ \begin{aligned} metabolic\\energy\\req\\pregnancy &= 0.10
    \times metabolic\\energy\\req\\maintenance \times \\ &
    \frac{pregnancy\\duration}{cohort\\duration\\days} \times (1 -
    offtake\\rate) \end{aligned} \$\$

- **CML** (Wardeh, 2004): Pregnancy energy is estimated as \\12\\\\ of
  maintenance energy.

  - `FA`: \$\$ metabolic\\energy\\req\\pregnancy = 0.12 \times
    metabolic\\energy\\req\\maintenance \times parturition\\rate \$\$

  - `FS`: \$\$ metabolic\\energy\\req\\pregnancy = 0.12 \times
    metabolic\\energy\\req\\maintenance \times
    \frac{pregnancy\\duration}{cohort\\duration\\days} \times (1 -
    offtake\\rate) \$\$

- **SHP and GTS** (IPCC 2006; 2019): Pregnancy energy is calculated as a
  litter-size-dependent fraction of maintenance energy (\\c\_{preg}\\).

  - `FA`: \$\$ \begin{aligned} metabolic\\energy\\req\\pregnancy &=
    metabolic\\energy\\req\\maintenance \times c\_{preg} \times
    parturition\\rate \times \\ & \frac{pregnancy\\duration}{365}
    \end{aligned} \$\$ where \\c\_{preg}\\ is: \$\$ c\_{preg} = \left\\
    \begin{array}{ll} 0.077 \times (2 - litter\\size) + 0.126 \times
    (litter\\size - 1), & 1 \le litter\\size \le 2 \\ 0.150, &
    litter\\size \> 2 \end{array} \right. \$\$

  - `FS`: A single-birth coefficient is used (\\c\_{preg}=0.077\\) and
    scaled by the proportion of reproductive individuals in the cohort:
    \$\$ \begin{aligned} metabolic\\energy\\req\\pregnancy &= 0.12
    \times metabolic\\energy\\req\\maintenance \times \\ &
    \frac{pregnancy\\duration}{cohort\\duration\\days} \times \\ & (1 -
    offtake\\rate) \end{aligned} \$\$

- **PGS** (NRC, 1998): Pregnancy energy is expressed using a gestation
  coefficient \\c\_{gest}\\ (MJ/piglet), with default
  \\c\_{gest}=0.14985\\.

  - `FA`: \$\$ \begin{aligned} metabolic\\energy\\req\\pregnancy &=
    c\_{gest} \times litter\\size \times \\ &
    \frac{pregnancy\\duration}{ non\\productive\\duration +
    pregnancy\\duration + lactation\\duration } \end{aligned} \$\$

  - `FS`: \$\$ \begin{aligned} metabolic\\energy\\req\\pregnancy &=
    c\_{gest} \times litter\\size \times \\ &
    \frac{pregnancy\\duration}{cohort\\duration\\days} \times \\ & (1 -
    offtake\\rate) \end{aligned} \$\$

This function is part of the
[`run_metabolic_energy_req_module()`](https://github.com/un-fao/GLEAM/reference/run_metabolic_energy_req_module.md).

## References

NRC (1998). *Nutrient Requirements of Swine*, 10th Revised Edition.
National Academies Press, Washington, DC.

IPCC. (2019). *2019 Refinement to the 2006 IPCC Guidelines for National
Greenhouse Gas Inventories*. Chapter 10: Emissions from Livestock and
Manure Management, Equation 10.13; Table 10.7.

IPCC. (2006). *2006 IPCC Guidelines for National Greenhouse Gas
Inventories*. Chapter 10: Emissions from Livestock and Manure
Management, Equation 10.13; Table 10.7.

Wardeh, M. F. (2004). *The nutrient requirements of the dromedary
camel*. Journal of Camel Science, 1(1):37-45. The Camel Applied Research
and Development Network (CARDN), Arab Center for the Studies of Arid
Zones and Dry Lands (ACSAD).

## See also

[`run_metabolic_energy_req_module`](https://github.com/un-fao/GLEAM/reference/run_metabolic_energy_req_module.md),
[`calc_metabolic_energy_req_maintenance`](https://github.com/un-fao/GLEAM/reference/calc_metabolic_energy_req_maintenance.md)
