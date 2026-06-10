# Calculate metabolic energy requirements for growth

Calculates the energy requirement for growth by cohort (MJ/head/day),
defined as the energy required for body tissue accretion, corresponding
to the retained energy component of live weight gain.

## Usage

``` r
calc_metabolic_energy_req_growth(
  species_short,
  cohort_short,
  live_weight_cohort_average = NA_real_,
  live_weight_cohort_final = NA_real_,
  live_weight_cohort_initial = NA_real_,
  live_weight_mature_stage = NA_real_,
  daily_weight_gain = NA_real_,
  offtake_rate = NA_real_,
  cohort_duration_days = NA_real_
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

- live_weight_cohort_final:

  Numeric. Live weight at the end of the cohort stage, accounting for
  both surviving and offtaken animals. Computed as a weighted average of
  the potential final weight of surviving animals and the slaughter
  weight of offtaken animals, based on the offtake rate (kg).

- live_weight_cohort_initial:

  Numeric. Live weight at the beginning of the cohort stage (kg).

- live_weight_mature_stage:

  Numeric. Mature (adult) live weight that the animal can attain under
  given biological and management conditions (kg).

- daily_weight_gain:

  Numeric. Average live weight gain of the cohort over the cohort stage
  (kg/head/day).

- offtake_rate:

  Numeric. Annual proportion of animals removed from the herd for each
  sex-age cohort (fraction).

- cohort_duration_days:

  Numeric. Amount of time that each animal spends in a specific cohort
  (days).

## Value

Numeric. Energy required for growth (i.e., weight gain) (MJ/head/day).
Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable
energy for CML and PGS.

## Details

This function follows the IPCC Tier 2 energy partitioning approach and
applies species-specific equations for growth energy requirements.

In general, growth energy is computed only for growing cohorts (`FJ`,
`FS`, `MJ`, `MS`); in this implementation, growth is set to 0 for adult
cohorts (`FA`, `MA`).

**Species-specific approach:**

- **CTL and BFL** (NRC, 1996; IPCC, 2006; IPCC, 2019)

  Growth energy is computed using a growth coefficient \\cgro\\ that
  differs between castrated and intact males. For male cohorts, \\cgro\\
  is calculated as a weighted average using `offtake_rate`, assuming
  that animals removed from the herd are castrated and animals remaining
  in the cohort are intact.

- **SHP and GTS** (Gibbs et al., 2002; AFRC, 1993; IPCC, 2006; IPCC,
  2019)

  For sheep and goats, growth energy is calculated using a linear
  formulation with coefficients \\a\\ and \\b\\ (MJ/kg live weight). For
  male cohorts, the coefficients differ between castrated and intact
  males; the model computes a weighted average using `offtake_rate`,
  assuming that offtaken animals are castrated.

- **CML** (Al-Jassim, 2019)

  Growth energy is represented using a simplified linear relationship
  with daily weight gain.

- **PGS** (NRC, 1998)

  For pigs, growth is assumed to consist exclusively of protein tissue
  and fat tissue, and growth energy requirements are expressed as
  metabolizable energy (ME).

  The growth energy coefficient \\cgro\\ (MJ/kg live weight) is
  calculated as:

  \\ cgro = prot\\tissue\\frac \times meat\\protein \times
  meat\\protein\\energy + (1 - prot\\tissue\\frac) \times
  fat\\adipose\\tissue_frac \times meat\\fat\\energy \\

  Total metabolizable energy required for growth is then:

  \\metabolic\\energy\\req\\growth = daily\\weight\\gain \times cgro\\

  where:

  - \\cgro\\ is the growth energy coefficient (MJ/kg live weight),

  - `prot_tissue_frac = 0.65` is the fraction of protein tissue in daily
    weight gain,

  - `meat_protein = 0.23` is the fraction of protein in protein tissue,

  - `meat_protein_energy = 54.0` is the ME cost of protein deposition
    (MJ/kg protein),

  - `fat_adipose_tissue_frac = 0.90` is the fraction of fat in adipose
    tissue,

  - `meat_fat_energy = 52.3` is the ME cost of fat deposition (MJ/kg
    fat).

This function is part of the
[`run_metabolic_energy_req_module()`](https://github.com/un-fao/GLEAM/reference/run_metabolic_energy_req_module.md).

## References

Al-Jassim, R. (2019). *Metabolisable energy and protein requirements of
the Arabian camel (Camelus dromedarius)*. Journal of Camelid Science
(12) 33-45

NRC (1998). *Nutrient Requirements of Swine*, 10th Revised Edition.
National Academies Press, Washington, DC.

NRC (1996). *Nutrient Requirements of Beef Cattle*, 7th Revised Edition.
National Academies Press, Washington, DC.

AFRC (1993). *Energy and Protein Requirements of Ruminants. An Advisory
Manual Prepared by the AFRC Technical Committee on Responses to
Nutrients.* CAB International, Wallingford, UK.

Gibbs, M.J., Conneely, D., Johnson, D., Lassey, K.R. and Ulyatt, M.J.
(2002). *CH4 emissions from enteric fermentation*. In: Background
Papers: IPCC Expert Meetings on Good Practice Guidance and Uncertainty
Management in National Greenhouse Gas Inventories, p 297–320.
IPCC-NGGIP, Institute for Global Environmental Strategies (IGES),
Hayama, Kanagawa, Japan.

IPCC. (2019). *2019 Refinement to the 2006 IPCC Guidelines for National
Greenhouse Gas Inventories*, Chapter 10: Emissions from Livestock and
Manure Management, Equation 10.6 and 10.7; Table 10.6.

IPCC. (2006). *2006 IPCC Guidelines for National Greenhouse Gas
Inventories*, Chapter 10: Emissions from Livestock and Manure
Management, Equation 10.6 and 10.7; Table 10.6.

## See also

[`run_metabolic_energy_req_module`](https://github.com/un-fao/GLEAM/reference/run_metabolic_energy_req_module.md),
[`calc_cohort_weights`](https://github.com/un-fao/GLEAM/reference/calc_cohort_weights.md),
[`calc_avg_weights`](https://github.com/un-fao/GLEAM/reference/calc_avg_weights.md),
[`calc_daily_weight_gain`](https://github.com/un-fao/GLEAM/reference/calc_daily_weight_gain.md)
