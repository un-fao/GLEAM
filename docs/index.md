# gleam: The GLEAM R Package

**The official R package of the FAO’s Global Livestock Environmental
Assessment Model (GLEAM).**

This package provides a modular implementation of GLEAM to quantify
environmental impacts from livestock agrifood systems. The model
simulates herd dynamics and quantifies key metrics, including
animal-sourced food production, energy requirements and feed intake,
nitrogen balance, and greenhouse gas emissions from enteric
fermentation, manure management, and upstream feed production. The
package also allocates estimated emissions to major animal products and
services.

## Purpose

This package supports the sustainable transformation of livestock
systems by enabling evidence-based decision-making through a transparent
and reproducible modeling framework.

The **official GLEAM workflow** allows users to:

- Simulate steady-state herd dynamics to disaggregate animal herds into
  age and sex-specific cohorts
- Compute annual production of animal products and herd growth rate
- Estimate animal energy requirements for maintenance, activity, growth,
  lactation, pregnancy, work, eggs, and fiber production
- Compute nutritional contributions of user-defined feed rations per
  cohort
- Estimate dry matter intake and nitrogen balance
- Estimate methane (CH₄) emissions from enteric fermentation
- Estimate CH₄ and nitrous oxide (N₂O) emissions from manure management
- Estimate carbon dioxide (CO₂), CH₄, and N₂O emission related to the
  production, processing and transport of feed
- Allocate estimated emissions to major animal products and services

## Model Coverage

The model currently considers cattle, buffalo, camels, goats, pigs, and
sheep.

## Installation

To install the development version of the package:

``` r
# If devtools is not installed
install.packages("devtools")

# Install from GitHub
devtools::install_git("https://github.com/un-fao/GLEAM.git")
```

## Help & Contact

We kindly ask users to inform us of your usage, as this helps us track
the tool’s impact and guide future improvements. Please also get in
touch with the GLEAM development team for documentation, internal
guidance, or technical questions.

- 📧 <Info-GLEAM@fao.org>
- 🌐 [GLEAM Website](https://www.fao.org/gleam/en/)

## License

This package is licensed under the AGPL-3 license which permits free
use, modification, and sharing of the software. Under AGPL-3.0, any
modifications to the code must be made publicly available by creating a
new branch on GitHub. The software cannot be relicensed under more
restrictive terms without adhering to the AGPL-3.0 guidelines.
Developers may anonymize or remove any sensitive or identifiable data
(customizations) before resubmitting code.

## Acknowledgement

The development of the GLEAM ecosystem was supported by the German
Federal Ministry of Food, Agriculture, and Regional Identity
[BMELH](https://www.bmleh.de/EN/Home/home_node.html).

------------------------------------------------------------------------
