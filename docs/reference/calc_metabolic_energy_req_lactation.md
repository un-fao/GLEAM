# Calculate metabolic energy requirements for lactation

Calculates the energy requirement for lactation by cohort (MJ/head/day),
defined as the energy needed to support milk production by lactating
females.

## Usage

``` r
calc_metabolic_energy_req_lactation(
  species_short,
  cohort_short,
  lactating_females_fraction = NA_real_,
  milk_yield_day = NA_real_,
  milk_fat_fraction = NA_real_,
  non_productive_duration = NA_real_,
  pregnancy_duration = NA_real_,
  litter_size = NA_real_,
  death_rate_juvenile = NA_real_,
  live_weight_at_birth = NA_real_,
  live_weight_at_weaning = NA_real_,
  lactation_duration = NA_real_,
  parturition_rate = NA_real_
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

- lactating_females_fraction:

  Numeric. Proportion of adult females that are lactating during the
  assessment period (fraction). Required only for species = CML, CTL,
  BFL, SHP, and GTS.

- milk_yield_day:

  Numeric. Average milk yield per milk-producing animal during the
  assessment duration (kg/head/day). This value is calculated as the
  total quantity of milk produced for human consumption by
  milk-producing animals during the assessment period, divided by the
  number of milk-producing animals, and the length of the assessment
  period (days). Required only for species = CML, CTL, BFL, SHP, and
  GTS.

- milk_fat_fraction:

  Numeric. Milk fat fraction (kg fat/kg milk). Required only for species
  = CML, CTL, BFL, SHP, and GTS.

- non_productive_duration:

  Numeric. Period during which the animal is not performing any
  productive physiological function such as pregnancy or lactation
  (days). Required only for PGS.

- pregnancy_duration:

  Numeric. Duration of pregnancy period (days).

- litter_size:

  Numeric. Average number of offspring born per parturition (#
  offspring/parturition). This value can be calculated as the total
  number of offspring born divided by the total number of parturitions
  during the year.

- death_rate_juvenile:

  Numeric. Fraction of deaths in a herd over a year for juvenile cohorts
  (i.e. FJ and MJ), (fraction).

- live_weight_at_birth:

  Numeric. Live weight of the animal at birth (kg).

- live_weight_at_weaning:

  Numeric. Live weight of the animal at weaning (kg).

- lactation_duration:

  Numeric. Duration of the lactation period, defined as the number of
  days during which the animal is lactating (days). Required only for
  PGS.

- parturition_rate:

  Numeric. Average annual number of parturitions per female animal (#
  parturitions/adult female/year). A herd-level reproductive performance
  indicator calculated as the total number of parturitions (deliveries)
  occurring during a year divided by the number of adult females
  potentially able to give birth during that year.

## Value

Numeric. Energy required for lactation (MJ/head/day). Expressed as net
energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and
PGS.

## Details

This approach follows the IPCC Tier 2 partitioning method and applies
species-specific equations for lactation energy requirements as a
function of the quantity of milk produced and a species-specific energy
cost per unit of milk.

Requirements are calculated only for cohort = `FA` (adult females) and
are scaled by the proportion of lactating animals
(`lactating_females_fraction`) or reproducing females
(`parturition_rate`) within the cohort.

**Species-specific approach:**

**CTL, BFL, CML, SHP and GTS**:

Total milk production includes:

- milk extracted for human consumption (`milk_yield`)

- milk consumed directly by offspring (`milk_for_offspring`)

In general form, lactation energy is computed as:

\$\$ metabolic\\energy\\req\\lactation = (milk\\yield \times
lactating\\females\\fraction + milk\\for\\offspring) \times energy\\milk
\$\$

where:

`energy_milk` is a species-specific coefficient representing the net
energy cost of producing one kilogram of milk (MJ/kg milk).

Species-specific values of `energy_milk` are:

- `CTL`, `BFL`: estimated as a function of milk fat content, \\1.47 +
  0.40 \times (milk\\fat\\fraction \times 100)\\ (NRC, 1989),

- `CML`: \\4.063\\ (Wardeh, 2004),

- `SHP`: \\4.6\\ (AFRC, 1993),

- `GTS`: \\3.0\\ (AFRC, 1998).

`milk_for_offspring` is the daily amount of milk required to rear
offspring across the year (kg/day). It is calculated assuming that **5
kg of milk are required for each kilogram of live-weight gain up to
weaning**:

\$\$ milk\\for\\offspring = \frac{parturition\\rate \times 5 \times
(weaning\\weight - birth\\weight)}{365} \$\$

For **SHP** and **GTS**, `milk_for_offspring` is multiplied by
`litter_size` to account for multiple offspring per birth.

**PGS** (NRC, 1998):

Lactation energy accounts only for the milk consumed directly by
offspring (`milk_for_offspring`), adjusted by the fraction of the
reproductive cycle spent in lactation (`cadj`):

\$\$ \begin{aligned} metabolic\\energy\\req\\lactation &= litter\\size
\times (1 - 0.5 \times death\\rate\\juvenile) \times \\ & \left(
\frac{0.02059 \times (weaning\\weight - birth\\weight) \times 1000}
{lactation\\duration} - \frac{0.3766}{0.67} \right) \times cadj
\end{aligned} \$\$

where:

- \\0.02059\\ is the coefficient for lactation energy requirement (MJ/g
  live weight),

- \\0.3766\\ is the coefficient for sow weight loss during lactation
  (MJ/head/day),

- \\0.67\\ is the efficiency of conversion of dietary intake to milk
  energy (fraction),

- \\cadj\\ is the fraction of the reproductive cycle spent in lactation:

  \$\$ cadj = \frac{lactation\\duration}{non\\productive\\duration +
  pregnancy\\duration + lactation\\duration} \$\$

This function is part of the
[`run_metabolic_energy_req_module()`](https://github.com/un-fao/GLEAM/reference/run_metabolic_energy_req_module.md).

## References

AFRC (1998) *The Nutrition of Goats.* CAB International, Wallingford,
UK.

AFRC (1993). *Energy and Protein Requirements of Ruminants. An Advisory
Manual Prepared by the AFRC Technical Committee on Responses to
Nutrients.* CAB International, Wallingford, UK.

IPCC. (2019). *2019 Refinement to the 2006 IPCC Guidelines for National
Greenhouse Gas Inventories*, Chapter 10: Emissions from Livestock and
Manure Management, Equation 10.8-10.10.

IPCC. (2006). *2006 IPCC Guidelines for National Greenhouse Gas
Inventories*, Chapter 10: Emissions from Livestock and Manure
Management, Equation 10.8-10.10.

NRC (1998). *Nutrient Requirements of Swine*, 10th Revised Edition.
National Academies Press, Washington, DC.

NRC (1989) *Nutrient Requirements of Dairy Cattle*, 6th Ed. .
Washington, D.C. U.S.A: National Academy Press.

Wardeh, M. F. (2004). *The nutrient requirements of the dromedary
camel*. Journal of Camel Science, 1(1):37-45. The Camel Applied Research
and Development Network (CARDN), Arab Center for the Studies of Arid
Zones and Dry Lands (ACSAD).

## See also

[`run_metabolic_energy_req_module`](https://github.com/un-fao/GLEAM/reference/run_metabolic_energy_req_module.md)
