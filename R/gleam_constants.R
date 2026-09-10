# GLEAM Package Constants
#
# Centralised lookup objects for valid codes, biologically meaningful
# species/cohort sub-groups, and pipeline variable metadata.
# Any change to supported codes or groupings should be made here only;
# all other files reference these objects.

# --- Valid input codes -------------------------------------------------------
#
# Single source of truth for species: the named vector maps code -> full name.
# gleam_species (codes only) is derived from it for validation and subsetting.

#' Species code -> full name mapping
#'
#' Maps each species short code to its full common name. Used for display and
#' documentation. \code{gleam_species} is derived from this as the vector of codes.
#'
#' @format A named character vector of length 7.
#' @keywords internal
gleam_species_names <- c(
  CTL = "Cattle",
  BFL = "Buffalo",
  SHP = "Sheep",
  GTS = "Goats",
  PGS = "Pigs",
  CML = "Camels",
  CHK = "Chickens"
)

#' Valid species short codes
#'
#' All livestock species supported by GLEAM. Derived from \code{gleam_species_names}.
#'
#' @format A character vector of length 7.
#' @keywords internal
gleam_species <- names(gleam_species_names)

# --- Cohort codes ------------------------------------------------------------
#
# Single source of truth for cohorts: named vector maps code -> full name.
# gleam_cohorts (codes only) is derived from it.

#' Cohort code -> full name mapping
#'
#' Maps each cohort short code to its descriptive name (sex and age class).
#' \code{gleam_cohorts} is derived from this as the vector of codes.
#'
#' @format A named character vector of length 8.
#' @keywords internal
gleam_cohorts_names <- c(
  FJ = "Juvenile female",
  FS = "Sub-adult female",
  FA = "Adult female",
  MJ = "Juvenile male",
  MS = "Sub-adult male",
  MA = "Adult male",
  FN = "Non-demographic female",
  MN = "Non-demographic male"
)

#' Valid cohort short codes
#'
#' All sex- and age-class cohort codes recognised by GLEAM. Derived from
#' \code{gleam_cohorts_names}.
#'
#' @format A character vector of length 8.
#' @keywords internal
gleam_cohorts <- names(gleam_cohorts_names)

#' Demographic cohort short codes
#'
#' The 6 sex- and age-class cohort codes used by the demographic herd module.
#'
#' @format A character vector of length 6.
#' @keywords internal
gleam_cohorts_demographic <- c("FJ", "FS", "FA", "MJ", "MS", "MA")

# --- Species sub-groups ------------------------------------------------------
# Derived from gleam_species

#' Ruminant species (four-stomach, NE-based energy system)
#'
#' Cattle, Buffalo, Sheep, Goats. Energy requirements are expressed as net
#' energy (NE) and converted to gross energy (GE) via digestibility ratios.
#' Camels use metabolizable energy (ME) instead.
#'
#' @format A character vector of length 4.
#' @keywords internal
gleam_species_ruminants <- setdiff(gleam_species, c("PGS", "CML", "CHK"))

#' Milk-producing species
#'
#' Species for which milk production, lactation energy requirements, and
#' ruminant-style digestibility parameters apply. Includes ruminants plus
#' Camels.
#'
#' @format A character vector of length 5.
#' @keywords internal
gleam_species_milk_producers <- setdiff(gleam_species, c("PGS", "CHK"))

#' Poultry species
#'
#' Species using the poultry-specific demographic energy and nitrogen equations.
#'
#' @format A character vector of length 1.
#' @keywords internal
gleam_species_poultry <- "CHK"

#' Species excluding poultry
#'
#' All supported species except poultry. Useful when a poultry-specific branch
#' requires explicit exclusion.
#'
#' @format A character vector of length 6.
#' @keywords internal
gleam_species_non_poultry <- setdiff(gleam_species, gleam_species_poultry)

#' Default lower critical temperature for chickens
#'
#' Poultry maintenance equations use a fixed lower critical temperature in the
#' run-level pipeline.
#'
#' @format Numeric scalar.
#' @keywords internal
gleam_chk_lower_critical_temperature <- 18.89

# --- Cohort sub-groups -------------------------------------------------------
# Derived from gleam_cohorts via setdiff (F* = female, M* = male)

#' Male cohort codes (M-prefix)
#' @format A character vector of length 3.
#' @keywords internal
gleam_cohorts_male <- grep("^M", gleam_cohorts, value = TRUE)

#' Female cohort codes (complement of male in gleam_cohorts)
#' @format A character vector of length 3.
#' @keywords internal
gleam_cohorts_female <- setdiff(gleam_cohorts, gleam_cohorts_male)

# --- Pipeline variable metadata ----------------------------------------------
#
# Each list below describes the cohort-level variables that the aggregation
# module pivots into long form, and that the allocation module assigns
# emission shares to. Keeping them here ensures both modules stay in sync.

#' Feed intake variable metadata
#'
#' One entry: dry-matter intake from the ration quality module.
#'
#' Each element contains:
#' \describe{
#'   \item{feed_source}{Column name in cohort-level data.}
#'   \item{label}{Human-readable label used in aggregated output.}
#'   \item{unit}{Physical unit of the variable.}
#' }
#' @keywords internal
gleam_feed_meta <- list(
  list(feed_source = "ration_intake", label = "DryMatterIntake", unit = "kg dry matter")
)

#' Nitrogen balance variable metadata
#'
#' Intake, retention, and excretion from the nitrogen balance module.
#'
#' Each element contains \code{nitrogen_balance_source}, \code{label}, \code{unit}.
#' @keywords internal
gleam_nitrogen_balance_meta <- list(
  list(nitrogen_balance_source = "nitrogen_intake", label = "NitrogenIntake", unit = "kg N"),
  list(nitrogen_balance_source = "nitrogen_retention", label = "NitrogenRetention", unit = "kg N"),
  list(nitrogen_balance_source = "nitrogen_excretion", label = "NitrogenExcretion", unit = "kg N")
)

#' Production variable metadata
#'
#' Milk, meat, and fibre production outputs from the production module.
#'
#' Each element contains \code{production_source}, \code{label}, \code{unit},
#' \code{commodity_name}, and \code{commodity_type}.
#' @keywords internal
gleam_production_meta <- list(
  list(
    production_source = "milk_production_mass_cohort",
    label = "MilkRaw",
    unit = "kg",
    commodity_name = "Milk",
    commodity_type = "Edible"
  ),
  list(
    production_source = "milk_production_protein_cohort",
    label = "MilkProtein",
    unit = "kg protein",
    commodity_name = "Milk",
    commodity_type = "Edible"
  ),
  list(
    production_source = "milk_production_fpcm_cohort",
    label = "MilkFatProteinCorrected",
    unit = "kg fat-protein corrected",
    commodity_name = "Milk",
    commodity_type = "Edible"
  ),
  list(
    production_source = "meat_production_live_weight_cohort",
    label = "MeatLiveWeight",
    unit = "kg live weight",
    commodity_name = "Meat",
    commodity_type = "Edible"
  ),
  list(
    production_source = "meat_production_carcass_weight_cohort",
    label = "MeatCarcassWeight",
    unit = "kg carcass weight",
    commodity_name = "Meat",
    commodity_type = "Edible"
  ),
  list(
    production_source = "meat_production_bone_free_meat_cohort",
    label = "MeatBoneFree",
    unit = "kg bone-free meat",
    commodity_name = "Meat",
    commodity_type = "Edible"
  ),
  list(
    production_source = "meat_production_protein_cohort",
    label = "MeatProtein",
    unit = "kg protein",
    commodity_name = "Meat",
    commodity_type = "Edible"
  ),
  list(
    production_source = "fibre_production_cohort",
    label = "Fibre",
    unit = "kg",
    commodity_name = "Fibre",
    commodity_type = "Edible"
  ),
  list(
    production_source = "egg_production_number_cohort",
    label = "EggNumber",
    unit = "eggs",
    commodity_name = "Eggs",
    commodity_type = "Edible"
  ),
  list(
    production_source = "egg_production_mass_cohort",
    label = "EggMass",
    unit = "kg",
    commodity_name = "Eggs",
    commodity_type = "Edible"
  ),
  list(
    production_source = "egg_production_protein_cohort",
    label = "EggProtein",
    unit = "kg protein",
    commodity_name = "Eggs",
    commodity_type = "Edible"
  )
)

#' Emissions variable metadata
#'
#' All direct and indirect emission sources handled by the allocation and
#' aggregation modules. Each element contains \code{emissions_source} (the
#' column name in cohort-level data) and \code{label} (the string used in
#' the aggregated long-form output).
#'
#' The \code{emissions_source} values from this list are the canonical set
#' passed to \code{assign_allocation_shares()} in the allocation module and
#' used to pivot the aggregation output. Adding or renaming an emission
#' source here automatically updates both modules.
#'
#' @keywords internal
gleam_emissions_meta <- list(
  list(emissions_source = "ch4_enteric", label = "Enteric_CH4"),
  list(emissions_source = "ch4_manure_pasture", label = "Manure-Pasture_CH4"),
  list(emissions_source = "ch4_manure_burned", label = "Manure-Burned_CH4"),
  list(emissions_source = "ch4_manure_other", label = "Manure-Other_CH4"),

  list(emissions_source = "n2o_manure_pasture_direct", label = "ManureDirect-Pasture_N2O"),
  list(emissions_source = "n2o_manure_burned_direct", label = "ManureDirect-Burned_N2O"),
  list(emissions_source = "n2o_manure_other_direct", label = "ManureDirect-Other_N2O"),

  list(emissions_source = "n2o_manure_burned_indirect", label = "ManureIndirect-Burned_N2O"),
  list(emissions_source = "n2o_manure_pasture_indirect", label = "ManureIndirect-Pasture_N2O"),
  list(emissions_source = "n2o_manure_other_indirect", label = "ManureIndirect-Other_N2O"),

  list(emissions_source = "co2_ration_fertilizer", label = "Feed-Fertilizer_CO2"),
  list(emissions_source = "co2_ration_pesticides", label = "Feed-Pesticides_CO2"),
  list(emissions_source = "co2_ration_crop_activities", label = "Feed-CropActivities_CO2"),
  list(emissions_source = "co2_ration_luc_nopeat", label = "Feed-LandUseChange_CO2"),
  list(emissions_source = "co2_ration_luc_peat", label = "Feed-PeatDrainage_CO2"),

  list(emissions_source = "n2o_ration_fertilizer", label = "Feed-Fertilizer_N2O"),
  list(emissions_source = "n2o_ration_manure_applied", label = "Feed-ManureApplication_N2O"),
  list(emissions_source = "n2o_ration_crop_residues", label = "Feed-CropResidues_N2O"),

  list(emissions_source = "ch4_ration_rice", label = "Feed-Rice_CH4")
)

#' Feed-related emission sources
#'
#' Emission variables expressed per kg dry matter intake (g/kg DM). Passed to
#' \code{calc_cohort_totals()} to apply ration_intake scaling. All other
#' emissions use cohort_stock_size * simulation_duration only.
#'
#' @format A list of lists with \code{emissions_source} and \code{label}.
#' @keywords internal
gleam_feed_emissions_meta <- list(
  list(emissions_source = "co2_ration_fertilizer", label = "Feed-Fertilizer_CO2"),
  list(emissions_source = "co2_ration_pesticides", label = "Feed-Pesticides_CO2"),
  list(emissions_source = "co2_ration_crop_activities", label = "Feed-CropActivities_CO2"),
  list(emissions_source = "co2_ration_luc_nopeat", label = "Feed-LandUseChange_CO2"),
  list(emissions_source = "co2_ration_luc_peat", label = "Feed-PeatDrainage_CO2"),
  list(emissions_source = "n2o_ration_fertilizer", label = "Feed-Fertilizer_N2O"),
  list(emissions_source = "n2o_ration_manure_applied", label = "Feed-ManureApplication_N2O"),
  list(emissions_source = "n2o_ration_crop_residues", label = "Feed-CropResidues_N2O"),
  list(emissions_source = "ch4_ration_rice", label = "Feed-Rice_CH4")
)

#' Emission sources excluded from commodity allocation
#'
#' These pasture and burn emission sources are not allocated to individual
#' commodities (they remain as herd-level totals). Referenced by both
#' \code{run_allocation_module} and any downstream reporting logic.
#'
#' @keywords internal
gleam_non_allocated_emissions <- c(
  "ch4_manure_pasture",
  "ch4_manure_burned",
  "n2o_manure_pasture_direct",
  "n2o_manure_burned_direct",
  "n2o_manure_burned_indirect",
  "n2o_manure_pasture_indirect"
)
