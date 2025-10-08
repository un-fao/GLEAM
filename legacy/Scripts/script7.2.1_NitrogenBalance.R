GLEAM_input_directemissions <- fread("inst/extdata/GLEAM_input_directemissions_manure.csv")[, ADM0_CODE := as.character(ADM0_CODE)]
source("legacy/Functions/05.2.1_functions_NitrogenBalance.R")


## N balance------

### N intake------
GLEAM_input_directemissions[, c("n_intake") :=
                              Dfunction_n_intake(
                                gleam_data=GLEAM_input_directemissions, 
                                ipcc_method=c("2019", "2006"))[
                                  , .(n_intake)
                                ]
]



### N retention------
GLEAM_input_directemissions[, n_retention :=
                              Dfunction_n_retention(
                                gleam_data = GLEAM_input_directemissions, 
                                ipcc_method=c("2019", "2006"))[
                                , .(n_retention)
                              ]
]


### N excretion------
GLEAM_input_directemissions[, n_excretion :=
                              Dfunction_n_excretion(
                                gleam_data = GLEAM_input_directemissions, 
                                ipcc_method=c("2019", "2006"))[
                                , .(n_excretion)
                              ]
]

fwrite(GLEAM_input_directemissions, "inst/extdata/GLEAM_input_directemissions_manure2.csv")
