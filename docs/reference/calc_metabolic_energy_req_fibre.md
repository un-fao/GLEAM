# Calculate metabolic energy requirements for fibre production

Calculates the energy requirement for fibre production (MJ/head/day),
defined as the additional energy required for the synthesis of animal
fibre (e.g. wool or hair).

## Usage

``` r
calc_metabolic_energy_req_fibre(
  species_short,
  cohort_short,
  fibre_yield_year = NA_real_
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

- fibre_yield_year:

  Numeric. Annual production yield of fibre, such as wool, cashmere,
  mohair (kg/head/year). Required only for species = CML, SHP, and GTS.

## Value

Numeric. Energy required for the synthesis of fibre for SHP, GTS and
CML. Assumed to be 0 for other species. (MJ/head/day). Expressed as net
energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and
PGS (MJ/head/day).

## Details

This component follows the IPCC Tier 2 partitioning approach and is
applied only to fibre-producing species and relevant cohorts, which are
assumed to be `FA`, `FS`, `MA`, and `MS`.

**Species-specific approach:**

- **SHP and GTS** (IPCC, 2006; IPCC, 2019):

  For sheep and goats, fibre production energy is calculated assuming a
  fixed net energy cost of \\24\\ MJ per kilogram of fibre produced.
  Annual fibre production is converted to a daily requirement as:

  \$\$ metabolic\\energy\\req\\fibre = \frac{24 \times
  fibre\\yield\\year}{365} \$\$

  where:

  - \\fibre\\yield\\year\\ is annual fibre production (kg/head/year),

  - \\24\\ is the net energy requirement per kilogram of fibre (MJ/kg
    fibre),

  - division by \\365\\ converts annual production to a daily basis.

- **CML** (AFRC, 1998; Cannas et al., 2007):

  For camels, fibre energy requirements are first calculated on a **net
  energy** basis and then converted to **metabolizable energy** using a
  net-to-metabolizable energy efficiency coefficient:

  \$\$ metabolic\\energy\\req\\fibre = \frac{24}{0.43} \times
  \frac{fibre\\yield\\year}{365} \$\$

  where:

  - \\24\\ is the net energy requirement per kilogram of fibre (MJ/kg
    fibre),

  - \\0.43\\ is the efficiency of conversion from metabolizable energy
    to net energy for fibre production (fraction),

  - \\fibre\\prod\\ is annual fibre production per animal
    (kg/head/year),

  - \\365\\ to convert annual production to a daily basis.

  The efficiency coefficient of \\0.43\\ is adopted by analogy with
  goats, assuming a dietary metabolizability of approximately 0.55,
  following AFRC guidance and the synthesis by Cannas et al. (2007).

- **Other species**: Fibre production energy is assumed to be zero.

This function is part of the
[`run_metabolic_energy_req_module()`](https://github.com/un-fao/GLEAM/reference/run_metabolic_energy_req_module.md).

## References

AFRC (1998) *The Nutrition of Goats.* CAB International, Wallingford,
UK.

AFRC (1993). *Energy and Protein Requirements of Ruminants. An Advisory
Manual Prepared by the AFRC Technical Committee on Responses to
Nutrients.* CAB International, Wallingford, UK.

Cannas, A., Atzori, A. S., Boe, F., & Teixeira, I. (2007). *Energy and
protein requirements of goats*. In: Dairy sheep nutrition (pp. 31-49).
CAB International, Wallingford, UK.

IPCC. (2019). *2019 Refinement to the 2006 IPCC Guidelines for National
Greenhouse Gas Inventories*. Chapter 10: Emissions from Livestock and
Manure Management, Equation 10.12.

IPCC. (2006). *2006 IPCC Guidelines for National Greenhouse Gas
Inventories*. Chapter 10: Emissions from Livestock and Manure
Management, Equation 10.12.

## See also

[`run_metabolic_energy_req_module`](https://github.com/un-fao/GLEAM/reference/run_metabolic_energy_req_module.md),
