library(data.table)
GLEAM_input_energyrequirement<-fread("Inputs/GLEAM_input_energyrequirements.csv")

# upload functions
source("Functions/03_functions_energyrequirements.R")
source("Functions/04_functions_drymatterintake.R")


GLEAM_input_energyrequirement[, nemain := Dfunction_nemain(Animal_short, cohort, averageLW, idle,
                                               gest, lact, litsize, ckg, milking_fraction, offtake_rate, afc), by = seq_len(nrow(GLEAM_input_energyrequirement))]

## energy for activity
GLEAM_input_energyrequirement[, neact := Dfunction_neact(Animal_short, cohort, past_man_frac, mmspasture,
                                                          nemain, averageLW, offtake_rate),  by = seq_len(nrow(GLEAM_input_energyrequirement))]


## energy for growing
GLEAM_input_energyrequirement[, negrow := Dfunction_negrow(Animal_short, cohort,
                                               averageLW, finalLW, initial_weight, dwg, offtake_rate,
                                               duration), by = seq_len(nrow(GLEAM_input_energyrequirement))]


## energy for lactation
GLEAM_input_energyrequirement[, nelact := Dfunction_nelact(Animal_short, cohort, milk_yield, milking_fraction,
                                               milk_fat, idle, gest, litsize, lambing_interval, parturition_rate,
                                               dr1, ckg, wkg, lact), by = seq_len(nrow(GLEAM_input_energyrequirement))]


## energy for egg production
# dat_merged_output[, neegg := Dfunction_neegg(animal = Animal_short, cohort = cohort, eggs_year = EGGSYEAR,
#                                              egg_weight = EGGWGHT), by = seq_len(nrow(dat_merged_output))]


## energy for working
GLEAM_input_energyrequirement[, nework := Dfunction_nework(Animal_short, cohort, nemain,
                                                           work_hours, draught_fraction), by = seq_len(nrow (GLEAM_input_energyrequirement))]



## energy for fiber production
GLEAM_input_energyrequirement[, nefibre := Dfunction_nefibre(Animal_short, cohort, fibre_prod), by = seq_len(nrow(GLEAM_input_energyrequirement))]


## energy for pregnancy
GLEAM_input_energyrequirement[, nepreg := Dfunction_nepreg(Animal_short, cohort, nemain, parturition_rate,
                                               duration, idle, gest, lact, litsize, offtake_rate = offtake_rate), by = seq_len(nrow(GLEAM_input_energyrequirement))]


## energy for rem
GLEAM_input_energyrequirement[, rem := Dfunction_rem(Animal_short, diet_dig), by = seq_len(nrow(GLEAM_input_energyrequirement))]


## energy for reg
GLEAM_input_energyrequirement[, reg := Dfunction_reg(Animal_short, diet_dig), by = seq_len(nrow(GLEAM_input_energyrequirement))]

## total energy
GLEAM_input_energyrequirement[, getot := Dfunction_getot(Animal_short, cohort, nemain, neact,
                                             nelact, nework, nepreg, rem, negrow,
                                             nefibre, neegg, reg, diet_dig, afc), by = seq_len(nrow(GLEAM_input_energyrequirement))]


## energy for meat production
GLEAM_input_energyrequirement[, nemeat := Dfunction_nemeat(Animal_short, cohort = cohort,
                                               ckg, afc, slaughter_weight, initial_weight), by = seq_len(nrow(GLEAM_input_energyrequirement))]




GLEAM_input_energyrequirement[, dmi := Dfunction_dmi(Animal_short, getot, diet_ge, diet_me), by = seq_len(nrow(GLEAM_input_energyrequirement))]


fwrite(GLEAM_input_energyrequirement, "Inputs/GLEAM_input_directemissions.csv")


# View(GLEAM_input_energyrequirement[,.(Animal_short, COUNTRY, LPS, HerdType, cohort, MLK_YIELD, FR, WKG, initial_weight,nelact, averageLW, nemain,   nepreg, negrow, diet_dig, rem, reg, getot, dmi)])
