GLEAM_input_directemissions <- fread(
  system.file("extdata/GLEAM_input_directemissions_enteric.csv", package = "gleam")
)[, ADM0_CODE := as.character(ADM0_CODE)][]

source("legacy/Functions/05.1_functions_directemissions-Enteric.R")

# CH4-----

## CH4 from enteric fermentation-----

### converted energy
GLEAM_input_directemissions[, ym := Dfunction_ym(Animal_short, cohort, diet_dig), by = seq_len(nrow(GLEAM_input_directemissions))]

### methane amount
GLEAM_input_directemissions[, ch4_enteric := Dfunction_ch4_enteric(Animal_short, cohort, ym ,
                                                                   diet_ge, dmi, afc), by = seq_len(nrow(GLEAM_input_directemissions))]



fwrite(GLEAM_input_directemissions, "inst/extdata/GLEAM_input_directemissions_manure.csv")
