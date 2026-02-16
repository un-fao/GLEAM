
# GLEAM-X R Package

**Official R package of FAO's Global Livestock Environmental Assessment Model (GLEAM-X).**

This package provides a complete, modular implementation of GLEAM to quantify greenhouse gas emissions from livestock agrifood systems. 
It simulates herd structures, animal energy requirements, feed intake, as well as emissions from enteric fermentation, manure mangement, and the production of feed. 

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

The model currently consideres cattle, buffalo, camels, chicken, goats, pigs, and sheep.   

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
