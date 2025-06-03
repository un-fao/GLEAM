GLEAM_input_directemissions <- fread(
  system.file("extdata/GLEAM_input_directemissions.csv", package = "gleam")
)
source("legacy/Functions/05_functions_directemissions.R")

# CH4-----

## CH4 from enteric fermentation-----

### converted energy
GLEAM_input_directemissions[, ym := Dfunction_ym(Animal_short, cohort, diet_dig), by = seq_len(nrow(GLEAM_input_directemissions))]

### methane amount
GLEAM_input_directemissions[, ch4_enteric := Dfunction_ch4_enteric(Animal_short, cohort, ym ,
                                           diet_ge, dmi, afc), by = seq_len(nrow(GLEAM_input_directemissions))]


## CH4 from manure-----

### Volatile Solids (VS)------

##### VS IPCC 2019------
GLEAM_input_directemissions[, vs_2019 := Dfunction_vs2019(Animal_short, cohort, dmi, diet_dig,
                                  diet_me, diet_ge, afc), by = seq_len(nrow(GLEAM_input_directemissions))]


##### VS IPCC 2006------
GLEAM_input_directemissions[, vs_2006 := Dfunction_vs2006 (Animal_short, dmi, diet_dig, diet_me, diet_ge), by = seq_len(nrow(GLEAM_input_directemissions))]

