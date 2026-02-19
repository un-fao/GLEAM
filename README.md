# GLEAM-X R Package

**Official R package of FAO's Global Livestock Environmental Assessment Model (GLEAM-X).**

This package provides a complete, modular implementation of GLEAM to quantify environmental impacts from livestock agrifood systems. 
It currently simulates herd structures, animal energy requirements, feed intake, as well as greenhouse gas emissions from enteric fermentation, manure management, and the production of feed. 

## Purpose

The package supports the **official GLEAM workflow**, allowing users to:

- Simulate steady-state herd dynamics to disaggreate animal herds into age and sex-specific cohorts
- Compute liveweight development over time and transitions to  cohort
- Estimate animal energy requirements for maintenance, growth, lactation, pregnancy, work, and fiber
- Allocate feed rations and calculate nutritional contributions per cohort
- Calculate dry matter intake to meet energy and nutritional requirements 
- Calculate CH~4~ emissions from enteric fermentation
- Calculate N~2~O emissions from manure management
- Calculate CO~2~, CH~4~, and N~2~O emission related to the production, processing and transport of feed 

## Model Coverage

The model currently considers cattle, buffalo, camels, chicken, goats, pigs, and sheep.   

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
We kindly ask users to inform us of your usage, as this helps us track the tool’s impact and guide future improvements. Please also get in touch with the GLEAM development team for  documentation, internal guidance, or technical questions. 


- 📧 Info-GLEAM@fao.org
- 🌐 [GLEAM Website](https://www.fao.org/gleam/en/)


## License

This package is licensed under the AGPL-3 license which permits free use, modification, and sharing of the software. Under AGPL-3.0, any modifications to the code must be made publicly available by creating a new branch on GitHub. The software cannot be relicensed under more restrictive terms without adhering to the AGPL-3.0 guidelines. Developers may anonymize or remove any sensitive or identifiable data (customizations) before resubmitting code. 

