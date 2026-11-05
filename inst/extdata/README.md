# GLEAM example datasets

Use `run_gleam_examples/` for the full pipeline and `run_modules_examples/`
for individual modules. Files with the same name in these folders belong to
different example sets. Load the inputs from the folder used in the function's
help example.

## Full pipeline examples

Choose one matching cohort and herd file pair. Each pair represents a separate
workflow, even when it uses the same herd IDs as another pair.

| Workflow | Cohort file | Herd file |
|---|---|---|
| Mixed simulation | `master_chrt_lvl_no_structure_mixed_data.csv` | `master_hrd_lvl_mixed_data.csv` |
| Non-demographic-only simulation | `master_chrt_lvl_no_structure_nondemo_data.csv` | `master_hrd_lvl_nondemo_data.csv` |
| Supplied herd structure | `master_chrt_lvl_structure_data.csv` | `master_hrd_lvl_structure_data.csv` |

| Workflow | `has_herd_structure` | `run_demographic` | `run_nondemographic` |
|---|---|---|---|
| Mixed simulation | `FALSE` | `TRUE` | `TRUE` |
| Non-demographic-only simulation | `FALSE` | `FALSE` | `TRUE` |
| Supplied herd structure | `TRUE` | `FALSE` | `FALSE` |

### Mixed simulation

This example covers 15 herds and includes demographic cohorts (`FJ`, `FS`, `FA`,
`MJ`, `MS`, `MA`) and non-demographic phases (`FN`, `MN`). The demographic
simulation calculates the annual animals diverted into the non-demographic
pathway. The combined average stock and offtake are rescaled to `herd_size_total`.

Herd 14 represents laying chickens: 95% of female juveniles enter FN, with
60 days in phase 1 and 365 days in phase 2. Food eggs are produced by FN phase 2.
Herd 15 represents meat chickens: 95% of female juveniles and all male juveniles
enter FN/MN, with 21 days in each phase. Both herds also contain a demographic
component in this workflow.

### Non-demographic-only simulation

This example covers herds 14 and 15 using only FN/MN production phases. It
does not include or simulate a breeding population. Annual entrants are supplied
directly as `cohort_stock_fem_annual_nondemo` and
`cohort_stock_mal_annual_nondemo` in the herd file.

These are alternative inputs for herds 14 and 15, not additional animals to append
to the mixed example. The cohort file contains six rows: two FN phases for herd
14, and two FN plus two MN phases for herd 15.

The cohort file omits `cohort_duration_days`: the model fills it from the
phase-duration columns in the herd file.

The non-demographic herd file contains only the 21 columns needed for these
chicken examples: identifiers, annual entrants, phase and rest durations,
non-demographic start/end weights, birth weight for meat allocation, temperature,
egg yield and weight, slaughter fractions, and `ratio_me_to_ne`. Demographic
adult/slaughter weights, reproductive parameters, milk, fibre and draught-work
columns can be omitted for this workflow.

The supplied herd file has no `herd_size_total`, so average stock and offtake
remain unscaled. Annual entrants are a flow in heads/year, not average animals
present. Supply `herd_size_total` to rescale both stock and offtake to a target.

### Supplied herd structure

The cohort file supplies `cohort_stock_size` and `offtake_heads_assessment`.
Both herd simulations are skipped, and the pipeline starts with weights.
The two herd-module switches have no effect when `has_herd_structure = TRUE`.

### Ration shares and manure inputs

Choose the fraction files matching the workflow:

| Workflow | Ration-share file | Manure-fraction file | Manure-factors file |
|---|---|---|---|
| Mixed simulation or supplied structure | `feed_rations_share_chrt.csv` | `manure_management_system_fraction.csv` | `manure_management_system_factors.csv` |
| Non-demographic-only simulation | `feed_rations_share_chrt_nondemo.csv` | `manure_management_system_fraction_nondemo.csv` | `manure_management_system_factors_nondemo.csv` |

The non-demographic ration and manure-fraction files contain only the six FN/MN
phases in the corresponding cohort master file for herds 14 and 15. The
non-demographic manure-factors file contains the unchanged factor rows for
these two herds from `manure_management_system_factors.csv`. Load these files
directly without filtering. Fractions sum to 1 within each herd, cohort and
productive phase.

All three workflows share `feed_quality.csv` and `feed_emission_factors.csv`.
These feed-level tables do not need a herd filter.

See `?run_gleam` for a complete runnable example of each workflow.

## Individual module examples

The files in `run_modules_examples/` are standalone inputs derived from the
full-pipeline master files and their shared feed and manure tables in
`run_gleam_examples/`. They retain only the variables used by each module,
plus cohort and productive-phase identifiers. The downstream examples cover
all 15 mixed-example herds, including chickens and non-demographic productive
phases.

| Herd workflow | Cohort file | Herd file |
|---|---|---|
| Standalone demographic module | `herd_simulation_input_chrt_data.csv` | `herd_simulation_input_hrd_data.csv` |
| Standalone non-demographic module | `nondemographic_herd_input_chrt_data.csv` | `nondemographic_herd_input_hrd_data.csv` |
| Combined module: mixed | `herd_all_input_chrt_data.csv` | `herd_all_input_hrd_data.csv` |
| Combined module: non-demographic only | `herd_all_nondemo_input_chrt_data.csv` | `herd_all_nondemo_input_hrd_data.csv` |
| Combined module: demographic only | `herd_all_demo_input_chrt_data.csv` | `herd_all_demo_input_hrd_data.csv` |

The demographic herd example contains only the six demographic cohorts. The
non-demographic herd example contains only FN/MN rows for the five herds that
have them in the mixed master. Its annual entrants are calculated from juvenile
diversion in the mixed simulation; they are not herd-size targets. This
standalone example has no `herd_size_total`, so its outputs remain unscaled.

The combined module's non-demographic-only example uses the dedicated CHK
master pair for herds 14 and 15, keeping only FN/MN identifiers, mortality,
annual entrants and phase/rest durations. Its demographic-only example supplies
a dedicated cohort/herd file pair with both juvenile-diversion fractions set
to zero in the herd file. All module examples load their
prepared CSV files directly, without selecting or modifying inputs inline.

Weights, energy, nitrogen, manure, production, allocation and aggregation inputs
contain the intermediate values calculated by the preceding pipeline stages
for a 365-day assessment. In the weights herd file, non-demographic starting
weights reflect the weaning-weight assignment used by `run_gleam()` for diverted
animals. Feed and manure inputs are subsets of the shared full-pipeline tables.

Regenerate the module files from the project root with:

```sh
Rscript data-raw/generate_module_examples.R
```

Use the `run_gleam_examples/` master files when running the complete pipeline.

## Loading the examples

`library(gleam)` loads the installed package and its example files. To work with
the current source checkout during development, run `pkgload::load_all(".")`
from the project directory instead. Then `system.file(..., package = "gleam")`
resolves the examples from that checkout.
