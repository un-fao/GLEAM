source("Functions/05.2.2_functions_directemissions-Manure.R")
load_manure_parameters(input_path = "Inputs/Manure_parameters/", ipcc_methods = c("2006", "2019"))
GLEAM_input_directemissions <- fread("Inputs/GLEAM_input_directemissions_manure2.csv")[, ADM0_CODE := as.factor(ADM0_CODE)][, Animal_short := as.factor(Animal_short)][, HerdType_short := as.factor(HerdType_short)]



# CH4-----


## CH4 from manure-----

### Volatile Solids (VS)------

##### VS - IPCC 2019------
GLEAM_input_directemissions[, c("vs2019") :=
                              Dfunction_vs(
                                gleam_data=GLEAM_input_directemissions, 
                                ipcc_method=="2019")[
                                  , .(vs)
                                ]
]


##### VS - IPCC 2006------
GLEAM_input_directemissions[, c("vs2006") :=
                              Dfunction_vs(
                                gleam_data=GLEAM_input_directemissions, 
                                ipcc_method=="2006")[
                                  , .(vs)
                                ]
]

##### MCF - IPCC 2019 -----
GLEAM_input_directemissions[, c("mcf_pasture2019", "mcf_burned2019", "mcf_other2019") :=
                              Dfunction_mcf_emissions(
                                gleam_data=GLEAM_input_directemissions, 
                                mcf_dataset=mcf_2019,
                                ipcc_method=="2019")[
                                , .(mcf_pasture, mcf_burned, mcf_other)
                              ]
]

##### MCF - IPCC 2006 -----
GLEAM_input_directemissions[, c("mcf_pasture2006", "mcf_burned2006", "mcf_other2006") :=
                              Dfunction_mcf_emissions(
                                gleam_data=GLEAM_input_directemissions,
                                mcf_dataset=mcf_2006,
                                ipcc_method=="2006")[
                                , .(mcf_pasture, mcf_burned, mcf_other)
                              ]
]

#### CH4 manure - IPCC 2019 -----
GLEAM_input_directemissions[, c(
  "ch4_manure_pasture2019", 
  "ch4_manure_burned2019", 
  "ch4_manure_other2019", 
  "ch4_manure_all_noburn2019"
) := Dfunction_ch4_manure(
  gleam_data = GLEAM_input_directemissions,
  b0_dataset = b0_2019,
  ipcc_method = "2019"
)
]


#### CH4 manure - IPCC 2006 -----
GLEAM_input_directemissions[, c(
  "ch4_manure_pasture2006", 
  "ch4_manure_burned2006", 
  "ch4_manure_other2006", 
  "ch4_manure_all_noburn2006"
) := Dfunction_ch4_manure(
  gleam_data = GLEAM_input_directemissions,
  b0_dataset = b0_2006,
  ipcc_method = "2006"
)
]



# N2O------
## N2O from manure - direct ------
### EF3 - IPCC 2019------
GLEAM_input_directemissions[, c("ef3_pasture2019", "ef3_burned2019", "ef3_other2019") :=
                              Dfunction_ef3_manure(
                                gleam_data = GLEAM_input_directemissions,
                                ef3_dataset = ef3_2019,
                                ipcc_method="2019"
                              )[, .(ef3_pasture, ef3_burned, ef3_other)]
]


### EF3 - IPCC 2006------
GLEAM_input_directemissions[, c("ef3_pasture2006", "ef3_burned2006", "ef3_other2006") :=
                              Dfunction_ef3_manure(
                                gleam_data = GLEAM_input_directemissions,
                                ef3_dataset = ef3_2006,
                                ipcc_method="2006"
                              )[, .(ef3_pasture, ef3_burned, ef3_other)]
]


### N2O manure direct - IPCC 2019------
GLEAM_input_directemissions[, c("direct_n2o_manure_pasture2019", 
                                "direct_n2o_manure_burned2019", 
                                "direct_n2o_manure_other2019", 
                                "direct_n2o_manure_all_noburn2019") :=
                              Dfunction_direct_n2o_manure(
                                gleam_data = GLEAM_input_directemissions,
                                ipcc_method = "2019"  # or "2006"
                              )[, .(direct_n2o_manure_pasture, direct_n2o_manure_burned,
                                    direct_n2o_manure_other, direct_n2o_manure_all_noburn)]
]

### N2O manure direct - IPCC 2006------
GLEAM_input_directemissions[, c("direct_n2o_manure_pasture2006", 
                                "direct_n2o_manure_burned2006", 
                                "direct_n2o_manure_other2006", 
                                "direct_n2o_manure_all_noburn2006") :=
                              Dfunction_direct_n2o_manure(
                                gleam_data = GLEAM_input_directemissions,
                                ipcc_method = "2006"  # or "2019"
                              )[, .(direct_n2o_manure_pasture, direct_n2o_manure_burned,
                                    direct_n2o_manure_other, direct_n2o_manure_all_noburn)]
]


## N2O from manure - indirect ------


### Fracgas - IPCC 2019------
GLEAM_input_directemissions[, c("fracgas_pasture2019", 
                                "fracgas_burned2019", 
                                "fracgas_other2019") :=
                              Dfunction_fracgas_manure(
                                gleam_data = GLEAM_input_directemissions,
                                fracgas_dt = fracgas_2019,
                                ipcc_method = "2019"
                              )[, .(fracgas_pasture, fracgas_burned, fracgas_other)]
]


### Fracgas - IPCC 2006------
GLEAM_input_directemissions[, c("fracgas_pasture2006", 
                                "fracgas_burned2006", 
                                "fracgas_other2006") :=
                              Dfunction_fracgas_manure(
                                gleam_data = GLEAM_input_directemissions,
                                fracgas_dt = fracgas_2006,
                                ipcc_method = "2006"
                              )[, .(fracgas_pasture, fracgas_burned, fracgas_other)]
]


### Nvol - IPCC 2019------
GLEAM_input_directemissions[, c("n_vol_manure_pasture2019", 
                                "n_vol_manure_burned2019", 
                                "n_vol_manure_other2019", 
                                "n_vol_manure_all_noburn2019") :=
                              Dfunction_n_volatilization_manure(
                                gleam_data = GLEAM_input_directemissions,
                                ipcc_method = "2019"
                              )[, .(n_vol_manure_pasture, n_vol_manure_burned, 
                                    n_vol_manure_other, n_vol_manure_all_noburn)]
]

### Nvol - IPCC 2006------
GLEAM_input_directemissions[, c("n_vol_manure_pasture2006", 
                                "n_vol_manure_burned2006", 
                                "n_vol_manure_other2006", 
                                "n_vol_manure_all_noburn2006") :=
                              Dfunction_n_volatilization_manure(
                                gleam_data = GLEAM_input_directemissions,
                                ipcc_method = "2006"
                              )[, .(n_vol_manure_pasture, n_vol_manure_burned, 
                                    n_vol_manure_other, n_vol_manure_all_noburn)]
]





### N2O manure indirect volatilization - IPCC 2019------
GLEAM_input_directemissions[, c("n2o_vol_manure_pasture2019", 
                                "n2o_vol_manure_burned2019", 
                                "n2o_vol_manure_other2019", 
                                "n2o_vol_manure_all_noburn2019") :=
                              Dfunction_n2o_volatilization_manure(
                                gleam_data = GLEAM_input_directemissions,
                                ef4_dt = ef4_2019,
                                ipcc_method = "2019"
                              )[, .(n2o_pasture,
                                    n2o_burned,
                                    n2o_other,
                                    n2o_noburn)]
]



### N2O manure indirect volatilization - IPCC 2006------
GLEAM_input_directemissions[, c("n2o_vol_manure_pasture2006", 
                                "n2o_vol_manure_burned2006", 
                                "n2o_vol_manure_other2006", 
                                "n2o_vol_manure_all_noburn2006") :=
                              Dfunction_n2o_volatilization_manure(
                                gleam_data = GLEAM_input_directemissions,
                                ef4_dt = ef4_2006,
                                ipcc_method = "2006"
                              )[, .(n2o_pasture,
                                    n2o_burned,
                                    n2o_other,
                                    n2o_noburn)]
]


### Fracleach - IPCC 2019------
GLEAM_input_directemissions[, c("fracleach_pasture2019", 
                                "fracleach_burned2019", 
                                "fracleach_other2019") :=
                              Dfunction_fracleach_manure(
                                gleam_data = GLEAM_input_directemissions,
                                fracleach_dt = fracleach_2019,
                                ipcc_method = "2019"
                              )[, .(fracleach_pasture, fracleach_burned, fracleach_other)]
]

### Fracleach - IPCC 2006------
GLEAM_input_directemissions[, c("fracleach_pasture2006", 
                                "fracleach_burned2006", 
                                "fracleach_other2006") :=
                              Dfunction_fracleach_manure(
                                gleam_data = GLEAM_input_directemissions,
                                fracleach_dt = fracleach_2006,
                                ipcc_method = "2006"
                              )[, .(fracleach_pasture, fracleach_burned, fracleach_other)]
]






### Nleach - IPCC 2019------
GLEAM_input_directemissions[, c("n_leach_manure_pasture2019", 
                                "n_leach_manure_burned2019", 
                                "n_leach_manure_other2019", 
                                "n_leach_manure_all_noburn2019") :=
                              Dfunction_n_leaching_manure(
                                gleam_data = GLEAM_input_directemissions,
                                ipcc_method = "2019"
                              )[, .(n_leach_manure_pasture, n_leach_manure_burned, 
                                    n_leach_manure_other, n_leach_manure_all_noburn)]
]




### Nleach - IPCC 2006------
GLEAM_input_directemissions[, c("n_leach_manure_pasture2006", 
                                "n_leach_manure_burned2006", 
                                "n_leach_manure_other2006", 
                                "n_leach_manure_all_noburn2006") :=
                              Dfunction_n_leaching_manure(
                                gleam_data = GLEAM_input_directemissions,
                                ipcc_method = "2006"
                              )[, .(n_leach_manure_pasture, n_leach_manure_burned, 
                                    n_leach_manure_other, n_leach_manure_all_noburn)]
]



### N2O manure indirect leaching - IPCC 2019------
GLEAM_input_directemissions[, c("n2o_leach_manure_pasture2019", 
                                "n2o_leach_manure_burned2019", 
                                "n2o_leach_manure_other2019", 
                                "n2o_leach_manure_all_noburn2019") :=
                              Dfunction_n2o_leaching_manure(
                                gleam_data = GLEAM_input_directemissions,
                                ef5_dt = ef5_2019,
                                ipcc_method = "2019"
                              )[, .(n2o_pasture,
                                    n2o_burned,
                                    n2o_other,
                                    n2o_noburn)]
]




### N2O manure indirect leaching - IPCC 2006------
GLEAM_input_directemissions[, c("n2o_leach_manure_pasture2006", 
                                "n2o_leach_manure_burned2006", 
                                "n2o_leach_manure_other2006", 
                                "n2o_leach_manure_all_noburn2006") :=
                              Dfunction_n2o_leaching_manure(
                                gleam_data = GLEAM_input_directemissions,
                                ef5_dt = ef5_2006,
                                ipcc_method = "2006"
                              )[, .(n2o_pasture,
                                    n2o_burned,
                                    n2o_other,
                                    n2o_noburn)]
]



## TOTAL N2O 2019 -----
GLEAM_input_directemissions[, c("indirect_n2o_manure_burned2019",
                                "indirect_n2o_manure_pasture2019",
                                "indirect_n2o_manure_other2019",
                                "total_n2o_manure_burned2019",
                                "total_n2o_manure_pasture2019",
                                "total_n2o_manure_other2019") :=
                              Dfunction_n2o_manure_total(
                                gleam_data = GLEAM_input_directemissions,
                                ipcc_method = "2019"
                              )
]

## TOTAL N2O 2006 -----
GLEAM_input_directemissions[, c("indirect_n2o_manure_burned2006",
                                "indirect_n2o_manure_pasture2006",
                                "indirect_n2o_manure_other2006",
                                "total_n2o_manure_burned2006",
                                "total_n2o_manure_pasture2006",
                                "total_n2o_manure_other2006") :=
                              Dfunction_n2o_manure_total(
                                gleam_data = GLEAM_input_directemissions,
                                ipcc_method = "2006"
                              )
]


# fwrite(GLEAM_input_directemissions, "Inputs/NAME_TO_BE_DEFINED")

