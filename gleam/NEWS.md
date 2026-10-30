# gleam 0.8.0

## New Features

- Full pipeline function `run_gleam()` integrating all modules end-to-end, supporting both
  cohort-input and pre-computed herd-structure workflows.
- Complete modular API: `run_demographic_herd_module()`, `run_weights_module()`,
  `run_ration_quality_module()`, `run_metabolic_energy_req_module()`,
  `run_nitrogen_balance_module()`, `run_emissions_enteric_module()`,
  `run_emissions_manure_module()`, `run_emissions_ration_module()`,
  `run_production_module()`, `run_allocation_module()`, `run_aggregation_module()`.
- Support for AR5 and AR6 global warming potential sets in `run_aggregation_module()`.
- Bundled example datasets in `inst/extdata/` for all modules and the full pipeline.
- Four vignettes covering package overview, module descriptions, ecosystem context, and
  GLEAM history.

## Improvements

- Switched vignette math rendering to KaTeX for improved portability.
- Improved code readability and variable naming consistency across all modules.
- Corrected cohort-level result assignment in the aggregation module
  (`gleam_chrt_data` was incorrectly written to `gleam_hrd_data`).
- Updated `data.table` minimum version requirement to `>= 1.16.0`.
- Migrated repository to `un-fao` GitHub organisation; updated all URLs in
  `DESCRIPTION` and documentation.

## Bug Fixes

- Fixed chicken cohort documentation duplication.
- Fixed `co2_feed_crop_operations` variable name alignment across modules.
- Fixed `offtake_number` returning `NA` in edge cases.

## Infrastructure

- Added GitHub Actions workflow for R CMD check on Windows and Ubuntu.
- Added lintr configuration and CI linting step.
- Added testthat (edition 3) test suite covering all modules and the full pipeline.
- Added `_pkgdown.yml` for `pkgdown` website generation.

---

# gleam 0.7.x (development)

Initial development iterations establishing the core herd module, basic unit tests, and
package infrastructure. See the git history for detailed commit-level changes.
