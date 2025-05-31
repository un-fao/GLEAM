---
output: github_document
---

# GLEAM R Package

**Official R package of the FAO Global Livestock Environmental Assessment Model (GLEAM).**

This package provides a complete, modular implementation of GLEAM for quantifying greenhouse gas emissions from livestock systems. It models herd structures, feed allocation, energy requirements, and emissions across countries, species, and production systems.

## Purpose

The package supports the **official GLEAM workflow**, allowing users to:

- Simulate steady-state herd dynamics by species, cohort, and production system
- Estimate cohort-specific population sizes, offtake, and mortality
- Compute liveweight development, durations, and daily weight gain
- Allocate feed rations and calculate nutritional contributions per cohort
- Estimate energy requirements for maintenance, growth, lactation, pregnancy, work, and fiber
- Calculate dry matter intake and direct CH₄ emissions from enteric fermentation and manure
- Output detailed results at the sex-age cohort level, structured by species, system, and country

## Model Coverage

- **Species**: Cattle, Buffalo, Sheep, Goats, Pigs, Chickens, Camels  
- **Systems**: Based on GLEAM's production systems (e.g. grazing, mixed, industrial)  
- **Emissions**: CH₄ (enteric + manure), N₂O (manure pathways), energy-related components  

## Installation

To install the development version of the package:

```r
# If devtools is not installed
install.packages("devtools")

# Install from GitHub
devtools::install_git("https://github.com/APPLITICS/gleam.git")
```

## Help & Contact

For documentation, internal guidance, or technical questions, please contact the GLEAM development team:

- 📧 Info-GLEAM@fao.org
- 🌐 [GLEAM Website](https://www.fao.org/gleam/en/)

## License

This package is licensed under the MIT License.
