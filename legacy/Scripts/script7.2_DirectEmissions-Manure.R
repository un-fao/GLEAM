GLEAM_input_directemissions <- fread(
  system.file("extdata/GLEAM_input_directemissions_manure.csv", package = "gleam")
)[, ADM0_CODE := as.character(ADM0_CODE)][]

# CH4
mcf_country2019 <- fread("inst/extdata/Manure_parameters/manure_ch4_mcf_ipcc2019_bycountry.csv")[, ADM0_CODE := as.character(ADM0_CODE)][]
mcf_country2006 <- fread("inst/extdata/Manure_parameters/manure_ch4_mcf_ipcc2006_bycountry.csv")[, ADM0_CODE := as.character(ADM0_CODE)][]

b0_country <- fread("inst/extdata/Manure_parameters/manure_ch4_b0_bycountry_ipcc2006-2019.csv")[, ADM0_CODE := as.character(ADM0_CODE)][]


# N2O
ef3_country2019 <- fread("inst/extdata/Manure_parameters/manure_n2o_ef3_ipcc2019.csv")[, ADM0_CODE := as.character(ADM0_CODE)][]
ef3_country2006 <- fread("inst/extdata/Manure_parameters/manure_n2o_ef3_ipcc2006.csv")[, ADM0_CODE := as.character(ADM0_CODE)][]


ef4_country2019 <- fread("inst/extdata/Manure_parameters/manure_n2o_ef4_ipcc2019.csv")[, ADM0_CODE := as.character(ADM0_CODE)][]
ef4_country2006 <- fread("inst/extdata/Manure_parameters/manure_n2o_ef4_ipcc2006.csv")[, ADM0_CODE := as.character(ADM0_CODE)][]


ef5_country2019 <- fread("inst/extdata/Manure_parameters/manure_n2o_ef5_ipcc2019.csv")[, ADM0_CODE := as.character(ADM0_CODE)][]
ef5_country2006 <- fread("inst/extdata/Manure_parameters/manure_n2o_ef5_ipcc2006.csv")[, ADM0_CODE := as.character(ADM0_CODE)][]


fracgas_country2019 <- fread("inst/extdata/Manure_parameters/manure_n2o_fracgas_ipcc2019.csv")[, `:=`(
  ADM0_CODE = as.character(ADM0_CODE),
  HerdType_short = fifelse(as.character(HerdType_short) == "", NA_character_, as.character(HerdType_short))
)][]
fracgas_country2006 <- fread("inst/extdata/Manure_parameters/manure_n2o_fracgas_ipcc2006.csv")[, `:=`(
  ADM0_CODE = as.character(ADM0_CODE),
  HerdType_short = fifelse(as.character(HerdType_short) == "", NA_character_, as.character(HerdType_short))
)][]

fracleach_country2019 <- fread("inst/extdata/Manure_parameters/manure_n2o_fracleach_ipcc2019.csv")[, `:=`(
  ADM0_CODE = as.character(ADM0_CODE),
  HerdType_short = fifelse(as.character(HerdType_short) == "", NA_character_, as.character(HerdType_short))
)][]
fracleach_country2006 <- fread("inst/extdata/Manure_parameters/manure_n2o_fracleach_ipcc2006.csv")[, `:=`(
  ADM0_CODE = as.character(ADM0_CODE),
  HerdType_short = fifelse(as.character(HerdType_short) == "", NA_character_, as.character(HerdType_short))
)][]


source("legacy/Functions/05.2_functions_directemissions-Manure.R")

# CH4-----


## CH4 from manure-----

### Volatile Solids (VS)------

##### VS - IPCC 2019------
GLEAM_input_directemissions[, vs_2019 := Dfunction_vs2019(Animal_short, cohort, dmi, diet_dig,
                                  diet_me, diet_ge, afc), by = seq_len(nrow(GLEAM_input_directemissions))]


##### VS - IPCC 2006------
GLEAM_input_directemissions[, vs_2006 := Dfunction_vs2006 (Animal_short, dmi, diet_dig, diet_me, diet_ge), by = seq_len(nrow(GLEAM_input_directemissions))]


##### MCF - IPCC 2019 -----
mms_cols <- grep("^mms", names(GLEAM_input_directemissions), value = TRUE)

GLEAM_input_directemissions[, c("mcf_pasture2019", "mcf_burned2019", "mcf_other2019") :=
                              Dfunction_mcf_emissions(
                                ADM0_CODE_input = ADM0_CODE,
                                mms_values = .SD,
                                mcf_dataset = mcf_country2019
                              ),
                            by = seq_len(nrow(GLEAM_input_directemissions)),
                            .SDcols = mms_cols
]

##### MCF - IPCC 2006 -----
GLEAM_input_directemissions[, c("mcf_pasture2006", "mcf_burned2006", "mcf_other2006") :=
                              Dfunction_mcf_emissions(
                                ADM0_CODE_input = ADM0_CODE,
                                mms_values = .SD,
                                mcf_dataset = mcf_country2006
                              ),
                            by = seq_len(nrow(GLEAM_input_directemissions)),
                            .SDcols = mms_cols
]


#### CH4 manure - IPCC 2019 -----
GLEAM_input_directemissions[, c("b0",
                                "b0_pasture",
                                "ch4_manure_burned2019",
                                "ch4_manure_pasture2019",
                                "ch4_manure_other2019",
                                "ch4_manure_all_noburn2019") :=
                              Dfunction_ch4_manure(
                                ADM0_CODE_input = ADM0_CODE,
                                Animal_short_input = Animal_short,
                                HerdType_short_input = HerdType_short,
                                vs = vs_2019,
                                mcf_pasture = mcf_pasture2019,
                                mcf_burned  = mcf_burned2019,
                                mcf_other   = mcf_other2019,
                                b0_dataset  = b0_country,
                                ipcc_method = "2019"
                              ), by = seq_len(nrow(GLEAM_input_directemissions))]

#### CH4 manure - IPCC 2006 -----
GLEAM_input_directemissions[, c("b0",
                                "b0_pasture",
                                "ch4_manure_burned2006",
                                "ch4_manure_pasture2006",
                                "ch4_manure_other2006",
                                "ch4_manure_all_noburn2006") :=
                              Dfunction_ch4_manure(
                                ADM0_CODE_input = ADM0_CODE,
                                Animal_short_input = Animal_short,
                                HerdType_short_input = HerdType_short,
                                vs = vs_2006,
                                mcf_pasture = mcf_pasture2006,
                                mcf_burned  = mcf_burned2006,
                                mcf_other   = mcf_other2006,
                                b0_dataset  = b0_country,
                                ipcc_method = "2006"
                              ), by = seq_len(nrow(GLEAM_input_directemissions))]



# N2O------
## N balance------

### N intake------
GLEAM_input_directemissions[, n_intake := Dfunction_n_intake(
  dmi = dmi,
  diet_nitrogen = diet_nitrogen,
  n_retention = n_retention
), by = seq_len(nrow(GLEAM_input_directemissions))]



### N retention------
GLEAM_input_directemissions[, c("n_retention") :=
                              Dfunction_n_retention(
                                Animal_short = Animal_short,
                                cohort = cohort,
                                duration,
                                n_intake=n_intake,
                                dwg = dwg,
                                negrow = negrow,
                                milk_yield = milk_yield,
                                milk_protein = milk_protein,
                                ckg = ckg,
                                litsize = litsize,
                                fr = fr,
                                wkg = wkg,
                                afc = afc,
                                fibre_prod=fibre_prod), by = seq_len(nrow(GLEAM_input_directemissions))]


### N excrection------
GLEAM_input_directemissions[, n_excretion := Dfunction_n_excretion(
  Animal_short = Animal_short,
  n_intake=n_intake,
  n_retention = n_retention), by = seq_len(nrow(GLEAM_input_directemissions))]



## N2O from manure - direct ------
### EF3 - IPCC 2019------
ef3_result <- Dfunction_ef3_manure(emissions_dt=GLEAM_input_directemissions,
                                   ef3_dt=ef3_country2019)

GLEAM_input_directemissions[, c("ef3_n2o_manure_pasture2019",
                                "ef3_n2o_manure_burned2019",
                                "ef3_n2o_manure_other2019") := ef3_result]

### EF3 - IPCC 2006------
ef3_result <- Dfunction_ef3_manure(emissions_dt=GLEAM_input_directemissions,
                                   ef3_dt=ef3_country2006)

GLEAM_input_directemissions[, c("ef3_n2o_manure_pasture2006",
                                "ef3_n2o_manure_burned2006",
                                "ef3_n2o_manure_other2006") := ef3_result]

### N2O manure direct - IPCC 2019------
GLEAM_input_directemissions[, c("direct_n2o_manure_burned2019",
                                "direct_n2o_manure_pasture2019",
                                "direct_n2o_manure_other2019",
                                "direct_n2o_manure_all_noburn2019") :=
                              Dfunction_direct_n2o_manure(
                                ef3_pasture = ef3_n2o_manure_pasture2019,
                                ef3_burned = ef3_n2o_manure_burned2019,
                                ef3_other = ef3_n2o_manure_other2019,
                                n_excretion = n_excretion
                              ), by = seq_len(nrow(GLEAM_input_directemissions))]

### N2O manure direct - IPCC 2006------
GLEAM_input_directemissions[, c("direct_n2o_manure_burned2006",
                                "direct_n2o_manure_pasture2006",
                                "direct_n2o_manure_other2006",
                                "direct_n2o_manure_all_noburn2006") :=
                              Dfunction_direct_n2o_manure(
                                ef3_pasture = ef3_n2o_manure_pasture2006,
                                ef3_burned = ef3_n2o_manure_burned2006,
                                ef3_other = ef3_n2o_manure_other2006,
                                n_excretion = n_excretion
                              ), by = seq_len(nrow(GLEAM_input_directemissions))]


## N2O from manure - indirect ------


### Fracgas - IPCC 2019------
fracgas <- Dfunction_fracgas_manure(emissions_dt=GLEAM_input_directemissions, fracgas_dt=fracgas_country2019)
GLEAM_input_directemissions[, c("fracgas_n2o_manure_pasture2019",
                                "fracgas_n2o_manure_burned2019",
                                "fracgas_n2o_manure_other2019") := fracgas]
### Fracgas - IPCC 2006------
fracgas <- Dfunction_fracgas_manure(emissions_dt=GLEAM_input_directemissions, fracgas_dt=fracgas_country2006)
GLEAM_input_directemissions[, c("fracgas_n2o_manure_pasture2006",
                                "fracgas_n2o_manure_burned2006",
                                "fracgas_n2o_manure_other2006") := fracgas]



### Nvol - IPCC 2019------
GLEAM_input_directemissions[, c("n_vol_manure_burned2019",
                                "n_vol_manure_pasture2019",
                                "n_vol_manure_other2019",
                                "n_vol_manure_all_noburn2019") :=
                              Dfunction_n_volatilization_manure(
                                fracgas_pasture = fracgas_n2o_manure_pasture2019,
                                fracgas_burned = fracgas_n2o_manure_burned2019,
                                fracgas_other = fracgas_n2o_manure_other2019,
                                n_excretion = n_excretion
                              ), by = seq_len(nrow(GLEAM_input_directemissions))]


### Nvol - IPCC 2006------
GLEAM_input_directemissions[, c("n_vol_manure_burned2006",
                                "n_vol_manure_pasture2006",
                                "n_vol_manure_other2006",
                                "n_vol_manure_all_noburn2006") :=
                              Dfunction_n_volatilization_manure(
                                fracgas_pasture = fracgas_n2o_manure_pasture2006,
                                fracgas_burned = fracgas_n2o_manure_burned2006,
                                fracgas_other = fracgas_n2o_manure_other2006,
                                n_excretion = n_excretion
                              ), by = seq_len(nrow(GLEAM_input_directemissions))]


### N2O manure indirect volatilization - IPCC 2019------
n2o_vol_manure_results <- Dfunction_n2o_volatilization_manure(emissions_dt=GLEAM_input_directemissions,ef4_dt=ef4_country2019, ipcc_method = "2019")

GLEAM_input_directemissions[, c("n2o_vol_manure_burned2019",
                                "n2o_vol_manure_pasture2019",
                                "n2o_vol_manure_other2019",
                                "n2o_vol_manure_all_noburn2019") := n2o_vol_manure_results]


### N2O manure indirect volatilization - IPCC 2006------
n2o_vol_manure_results <- Dfunction_n2o_volatilization_manure(emissions_dt=GLEAM_input_directemissions, ef4_dt=ef4_country2006, ipcc_method = "2006")

GLEAM_input_directemissions[, c("n2o_vol_manure_burned2006",
                                "n2o_vol_manure_pasture2006",
                                "n2o_vol_manure_other2006",
                                "n2o_vol_manure_all_noburn2006") := n2o_vol_manure_results]


### Fracleach - IPCC 2019------
fracleach <- Dfunction_fracleach_manure(emissions_dt = GLEAM_input_directemissions, fracleach_dt = fracleach_country2019)
GLEAM_input_directemissions[, c("fracleach_n2o_manure_pasture2019",
                                "fracleach_n2o_manure_burned2019",
                                "fracleach_n2o_manure_other2019") := fracleach]

### Fracleach - IPCC 2006------
fracleach <- Dfunction_fracleach_manure(emissions_dt=GLEAM_input_directemissions, fracleach_dt=fracleach_country2006)
GLEAM_input_directemissions[, c("fracleach_n2o_manure_pasture2006",
                                "fracleach_n2o_manure_burned2006",
                                "fracleach_n2o_manure_other2006") := fracleach]




### Nleach - IPCC 2019------
GLEAM_input_directemissions[, c("n_leach_manure_burned2019",
                                "n_leach_manure_pasture2019",
                                "n_leach_manure_other2019",
                                "n_leach_manure_all_noburn2019") :=
                              Dfunction_n_leaching_manure(
                                fracleach_pasture = fracleach_n2o_manure_pasture2019,
                                fracleach_burned = fracleach_n2o_manure_burned2019,
                                fracleach_other = fracleach_n2o_manure_other2019,
                                n_excretion = n_excretion
                              ), by = seq_len(nrow(GLEAM_input_directemissions))]

### Nleach - IPCC 2006------
GLEAM_input_directemissions[, c("n_leach_manure_burned2006",
                                "n_leach_manure_pasture2006",
                                "n_leach_manure_other2006",
                                "n_leach_manure_all_noburn2006") :=
                              Dfunction_n_leaching_manure(
                                fracleach_pasture = fracleach_n2o_manure_pasture2006,
                                fracleach_burned = fracleach_n2o_manure_burned2006,
                                fracleach_other = fracleach_n2o_manure_other2006,
                                n_excretion = n_excretion
                              ), by = seq_len(nrow(GLEAM_input_directemissions))]





### N2O manure indirect leaching - IPCC 2019------
n2o_leach_manure_results <- Dfunction_n2o_leaching_manure(emissions_dt=GLEAM_input_directemissions,ef5_dt=ef5_country2019, ipcc_method = "2019")

GLEAM_input_directemissions[, c("n2o_leach_manure_burned2019",
                                "n2o_leach_manure_pasture2019",
                                "n2o_leach_manure_other2019",
                                "n2o_leach_manure_all_noburn2019") := n2o_leach_manure_results]


### N2O manure indirect leaching - IPCC 2006------
n2o_leach_manure_results <- Dfunction_n2o_leaching_manure(emissions_dt=GLEAM_input_directemissions, ef5_dt=ef5_country2006, ipcc_method = "2006")

GLEAM_input_directemissions[, c("n2o_leach_manure_burned2006",
                                "n2o_leach_manure_pasture2006",
                                "n2o_leach_manure_other2006",
                                "n2o_leach_manure_all_noburn2006") := n2o_leach_manure_results]



## TOTALS N2O from manure -----

### N2O manure indirect - IPCC 2019-----
GLEAM_input_directemissions$indirect_n2o_manure_burned2019 <- GLEAM_input_directemissions$n2o_vol_manure_burned2019 + GLEAM_input_directemissions$n2o_leach_manure_burned2019
GLEAM_input_directemissions$indirect_n2o_manure_pasture2019 <- GLEAM_input_directemissions$n2o_vol_manure_pasture2019 + GLEAM_input_directemissions$n2o_leach_manure_pasture2019
GLEAM_input_directemissions$indirect_n2o_manure_other2019 <- GLEAM_input_directemissions$n2o_vol_manure_other2019 + GLEAM_input_directemissions$n2o_leach_manure_other2019

### N2O manure indirect - IPCC 2006-----
GLEAM_input_directemissions$indirect_n2o_manure_burned2006 <- GLEAM_input_directemissions$n2o_vol_manure_burned2006 + GLEAM_input_directemissions$n2o_leach_manure_burned2006
GLEAM_input_directemissions$indirect_n2o_manure_pasture2006 <- GLEAM_input_directemissions$n2o_vol_manure_pasture2006 + GLEAM_input_directemissions$n2o_leach_manure_pasture2006
GLEAM_input_directemissions$indirect_n2o_manure_other2006 <- GLEAM_input_directemissions$n2o_vol_manure_other2006 + GLEAM_input_directemissions$n2o_leach_manure_other2006


### N2O manure direct+indirect - IPCC 2019-----
GLEAM_input_directemissions$total_n2o_manure_burned2019 <- GLEAM_input_directemissions$direct_n2o_manure_burned2019 + GLEAM_input_directemissions$indirect_n2o_manure_burned2019
GLEAM_input_directemissions$total_n2o_manure_pasture2019 <- GLEAM_input_directemissions$direct_n2o_manure_pasture2019 + GLEAM_input_directemissions$indirect_n2o_manure_pasture2019
GLEAM_input_directemissions$total_n2o_manure_other2019 <- GLEAM_input_directemissions$direct_n2o_manure_other2019 + GLEAM_input_directemissions$indirect_n2o_manure_other2019

### N2O manure direct+indirect - IPCC 2006-----
GLEAM_input_directemissions$total_n2o_manure_burned2006 <- GLEAM_input_directemissions$direct_n2o_manure_burned2006 + GLEAM_input_directemissions$indirect_n2o_manure_burned2006
GLEAM_input_directemissions$total_n2o_manure_pasture2006 <- GLEAM_input_directemissions$direct_n2o_manure_pasture2006 + GLEAM_input_directemissions$indirect_n2o_manure_pasture2006
GLEAM_input_directemissions$total_n2o_manure_other2006 <- GLEAM_input_directemissions$direct_n2o_manure_other2006 + GLEAM_input_directemissions$indirect_n2o_manure_other2006


# fwrite(GLEAM_input_directemissions, "inst/extdata/GLEAM_input_feedemissions.csv")
# fwrite(GLEAM_input_directemissions, "inst/extdata/GLEAM_input_allocation.csv")
