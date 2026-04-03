# CRAN Submission Comments — gleam 0.8.0

## Test environments

- macOS (local), R 4.4.x
- Windows (GitHub Actions, `windows-latest`), R release
- Ubuntu (GitHub Actions, `ubuntu-latest`), R release
- Windows (win-builder), R-devel — `devtools::check_win_devel()`

## R CMD check results

0 errors | 0 warnings | 0 notes

## Notes for reviewers

- **License**: The package uses AGPL-3, which is a CRAN-approved license. AGPL-3 is
  required by the Food and Agriculture Organization of the United Nations (FAO), the
  copyright holder, in accordance with FAO's open-source policy for official software.

- **Examples**: All `\donttest{}` examples are genuine and runnable. They are wrapped in
  `\donttest{}` rather than executed during `R CMD check` because some modules
  (e.g., `run_demographic_herd_module()` with `simulation_duration = 200`) may exceed
  the typical per-example time budget. All examples load data exclusively via
  `system.file()` from the package's own `inst/extdata/` directory — no internet
  access or external files are required.

- **Package size**: Vignettes include flow-chart images stored in `inst/` which may
  increase the installed package size. These are necessary for the scientific
  documentation of the GLEAM model methodology.

- **Dependencies**: The package intentionally keeps its dependency footprint minimal —
  only `cli` and `data.table` are hard imports. Both are widely used, well-maintained
  CRAN packages.

- **Authors**: Multiple authors and contributors are listed, reflecting that this is an
  official FAO tool developed by a team across FAO and Applitics. The `cre` (maintainer)
  role is held by Ahmed Jou <ahmed@applitics.fr>.
