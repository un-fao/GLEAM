#' Run Global Livestock Environmental Assessment Model (GLEAM) Pipeline
#'
#' Runs the full GLEAM pipeline from master herd and cohort inputs through all
#' modules: herd (optional), weights, ration quality, energy requirements,
#' manure emissions, feed emissions, allocation, and aggregation.
#'
#' @section Common identifiers:
#' Several input tables share the following identifier columns. Their supported
#' values are listed once here and referenced throughout.
#'
#' \strong{\code{species_short}} --- Character. Species code:
#' \itemize{
#'   \item \code{CTL}: Cattle
#'   \item \code{BFL}: Buffalo
#'   \item \code{SHP}: Sheep
#'   \item \code{GTS}: Goats
#'   \item \code{CHK}: Chicken
#'   \item \code{PGS}: Pigs
#'   \item \code{CML}: Camels
#' }
#'
#' \strong{\code{cohort_short}} --- Character. Sex- and age-specific cohort code:
#' \itemize{
#'   \item \code{FA}: adult females (from age at first parturition)
#'   \item \code{FS}: sub-adult females (from weaning to age at first parturition)
#'   \item \code{FJ}: juvenile females (from birth to weaning)
#'   \item \code{MA}: adult males (from age at first breeding)
#'   \item \code{MS}: sub-adult males (from weaning to age at first breeding)
#'   \item \code{MJ}: juvenile males (from birth to weaning)
#' }
#'
#' @param has_herd_structure Logical. If \code{TRUE}, \code{cohort_level_data}
#'   is treated as an existing herd structure and the demographic herd
#'   simulation step is skipped. If \code{FALSE}, herd structure is first
#'   generated from \code{cohort_level_data} and \code{herd_level_data} using
#'   \code{\link{run_demographic_herd_module}}.
#'
#' @param cohort_level_data data.table. Cohort-level master input table.
#'   Required columns:
#'   \describe{
#'     \item{herd_id}{Character. Unique herd identifier, repeated for each
#'       cohort within the same herd.}
#'     \item{species_short}{Character. Species code (see Common identifiers).}
#'     \item{cohort_short}{Character. Cohort code (see Common identifiers).}
#'     \item{cohort_duration_days}{Numeric. Time each animal spends in the
#'       cohort (days).}
#'     \item{offtake_rate}{Numeric. Annual proportion of animals removed from
#'       the herd per cohort (fraction).}
#'     \item{low_activity_fraction}{Numeric. Proportion of the assessment period
#'       with low-intensity movement, e.g. stall-feeding or near-field grazing
#'       (fraction).}
#'     \item{high_activity_fraction}{Numeric. Proportion of the assessment
#'       period with sustained locomotion, e.g. herding or long-distance grazing
#'       over uneven terrain (fraction).}
#'   }
#'   Additional columns when \code{has_herd_structure = FALSE}:
#'   \describe{
#'     \item{death_rate}{Numeric. Annual fraction of deaths per cohort
#'       (fraction).}
#'   }
#'   Additional columns when \code{has_herd_structure = TRUE}:
#'   \describe{
#'     \item{cohort_stock_size}{Numeric. Average population size in each cohort
#'       (heads).}
#'     \item{offtake_heads_assessment}{Numeric. Total animals removed via
#'       offtake over the assessment period per cohort (heads/assessment
#'       period).}
#'   }
#'   Optional column (both cases):
#'   \describe{
#'     \item{ch4_mitigation_factor}{Numeric. Multiplicative factor applied to
#'       baseline enteric CH4 emissions (dimensionless). Defaults to \code{1}
#'       (no mitigation). Values < 1 represent proportional reductions (e.g.
#'       \code{0.90} = 10 percent reduction). Can represent feed additives or
#'       methane inhibitors.}
#'   }
#'
#' @param herd_level_data data.table. Herd-level master input table (one row per
#'   \code{herd_id}). Required columns:
#'   \describe{
#'     \item{herd_id}{Character. Unique herd identifier.}
#'     \item{species_short}{Character. Species code (see Common identifiers).}
#'     \item{live_weight_female_adult}{Numeric. Adult female live weight (kg).}
#'     \item{live_weight_male_adult}{Numeric. Adult male live weight (kg).}
#'     \item{live_weight_at_birth}{Numeric. Live weight at birth (kg).}
#'     \item{live_weight_at_weaning}{Numeric. Live weight at weaning (kg).}
#'     \item{live_weight_female_at_slaughter}{Numeric. Female sub-adult
#'       slaughter weight (kg).}
#'     \item{live_weight_male_at_slaughter}{Numeric. Male sub-adult slaughter
#'       weight (kg).}
#'     \item{age_first_parturition}{Numeric. Age at first parturition (days).}
#'     \item{lactating_females_fraction}{Numeric. Proportion of adult females
#'       lactating during the assessment period (fraction). Required for CTL,
#'       BFL, CML, SHP, GTS.}
#'     \item{milk_yield_day}{Numeric. Average daily milk yield per
#'       milk-producing animal (kg/head/day), calculated as total milk produced
#'       for human consumption divided by the number of milk-producing animals
#'       and the assessment period length. Required for CTL, BFL, CML, SHP,
#'       GTS.}
#'     \item{milk_fat_fraction}{Numeric. Milk fat content (kg fat/kg milk).
#'       Required for CTL, BFL, CML, SHP, GTS.}
#'     \item{milk_protein_fraction}{Numeric. Milk protein content (kg protein/kg
#'       milk). Required for CTL, BFL, CML, SHP, GTS.}
#'     \item{milk_lactose_fraction}{Numeric. Milk lactose content (kg
#'       lactose/kg milk). Required for CTL, BFL, CML, SHP, GTS.}
#'     \item{milk_protein_fraction_standard}{Numeric. Standard milk protein
#'       content for FPCM calculation (kg protein/kg milk). Suggested: 0.033.}
#'     \item{milk_fat_fraction_standard}{Numeric. Standard milk fat content for
#'       FPCM calculation (kg fat/kg milk). Suggested: 0.04.}
#'     \item{milk_lactose_fraction_standard}{Numeric. Standard milk lactose
#'       content for FPCM calculation (kg lactose/kg milk). Suggested: 0.048.}
#'     \item{non_productive_duration}{Numeric. Period without productive
#'       function (pregnancy/lactation) (days). Required for PGS.}
#'     \item{pregnancy_duration}{Numeric. Pregnancy duration (days).}
#'     \item{death_rate_juvenile}{Numeric. Annual death fraction for juvenile
#'       cohorts (FJ, MJ) (fraction).}
#'     \item{lactation_duration}{Numeric. Lactation period length (days).
#'       Required for PGS.}
#'     \item{parturition_rate}{Numeric. Average annual parturitions per adult
#'       female (parturitions/adult female/year).}
#'     \item{litter_size}{Numeric. Average offspring born per parturition
#'       (offspring/parturition).}
#'     \item{draught_work_hours_female}{Numeric. Average daily working time per
#'       adult female (hours/head/day). Required for CTL, BFL, CML.}
#'     \item{draught_work_hours_male}{Numeric. Average daily working time per
#'       adult male (hours/head/day). Required for CTL, BFL, CML.}
#'     \item{draught_fraction_female}{Numeric. Fraction of adult females doing
#'       draught work (fraction). Required for CTL, BFL, CML.}
#'     \item{draught_fraction_male}{Numeric. Fraction of adult males doing
#'       draught work (fraction). Required for CTL, BFL, CML.}
#'     \item{fibre_yield_year}{Numeric. Annual fibre production (wool,
#'       cashmere, mohair) (kg/head/year). Required for CML, SHP, GTS.}
#'     \item{carcass_dressing_fraction}{Numeric. Carcass weight to live weight
#'       ratio (fraction).}
#'     \item{bone_free_meat_fraction}{Numeric. Bone-free meat to carcass weight
#'       ratio (fraction).}
#'     \item{meat_protein_fraction}{Numeric. Protein content of bone-free meat
#'       (kg protein/kg bone-free meat).}
#'     \item{ratio_me_to_ne}{Numeric. Metabolizable-to-net energy ratio
#'       (fraction). Used for CML. Suggested: 0.43.}
#'   }
#'   Additional columns when \code{has_herd_structure = FALSE}:
#'   \describe{
#'     \item{birth_fraction_female}{Numeric. Probability that a newborn is
#'       female (fraction).}
#'     \item{herd_size_total}{Numeric. Total population at start of year, all
#'       cohorts (heads).}
#'   }
#'
#' @param feed_rations data.table. Cohort-level feed ration shares, also used by
#'   \code{\link{run_ration_quality_module}} and
#'   \code{\link{run_emissions_ration_module}}. Required columns:
#'   \describe{
#'     \item{herd_id}{Character. Unique herd identifier.}
#'     \item{species_short}{Character. Species code (see Common identifiers).}
#'     \item{cohort_short}{Character. Cohort code (see Common identifiers).}
#'     \item{feed_id}{Character. Unique feed component identifier, used as join
#'       key with feed parameter tables.}
#'     \item{feed_name}{Character. Optional. Human-readable feed name; should
#'       match \code{feed_id} uniquely if provided.}
#'     \item{feed_ration_fraction}{Numeric. Proportion of this feed component in
#'       the total ration as a fraction of diet dry matter intake (fraction).
#'       Must sum to 1 within each herd_id \eqn{\times}{x} cohort combination.}
#'   }
#'
#' @param feed_params data.table. Feed nutritional parameters. Required columns:
#'   \describe{
#'     \item{feed_id}{Character. Unique feed component identifier.}
#'     \item{feed_gross_energy}{Numeric. Gross energy: total chemical energy
#'       upon complete combustion (MJ/kg DM).}
#'     \item{feed_digestible_energy_ruminant}{Numeric. Digestible energy for
#'       ruminants: energy absorbed after faecal losses (MJ/kg DM).}
#'     \item{feed_digestible_energy_pigs}{Numeric. Digestible energy for pigs
#'       (MJ/kg DM).}
#'     \item{feed_metabolizable_energy_ruminant}{Numeric. Metabolizable energy
#'       for ruminants: digestible energy minus urinary and gaseous losses
#'       (MJ/kg DM).}
#'     \item{feed_metabolizable_energy_pigs}{Numeric. Metabolizable energy for
#'       pigs (MJ/kg DM).}
#'     \item{feed_metabolizable_energy_chicken}{Numeric. Metabolizable energy
#'       for chickens: digestible energy minus uric acid and gaseous losses
#'       (MJ/kg DM).}
#'     \item{feed_nitrogen_content}{Numeric. Nitrogen content (kg N/kg DM).}
#'     \item{feed_urinary_energy_ruminant}{Numeric. Fraction of gross energy
#'       excreted in urine for ruminants (fraction).}
#'     \item{feed_urinary_energy_pigs}{Numeric. Fraction of gross energy
#'       excreted in urine for pigs (fraction).}
#'     \item{feed_ash}{Numeric. Ash content as a fraction of dry matter
#'       (g ash/100 g DM).}
#'     \item{category}{Character. Optional. Feed category; should be used
#'       consistently with \code{feed_id}.}
#'     \item{feed_name}{Character. Optional. Human-readable feed name; should
#'       match \code{feed_id} uniquely if provided.}
#'   }
#'
#' @param feed_emissions data.table. Emission factors per feed component.
#'   All emission factors are expressed per kg of feed dry matter intake.
#'   Required columns:
#'   \describe{
#'     \item{feed_id}{Character. Unique feed component identifier.}
#'     \item{feed_name}{Character. Optional. Human-readable feed name.}
#'     \item{co2_feed_fertilizer}{Numeric. CO2 from fertilizer manufacture
#'       (g CO2/kg DM).}
#'     \item{co2_feed_pesticides}{Numeric. CO2 from pesticide manufacture
#'       (g CO2/kg DM).}
#'     \item{co2_feed_crop_operations}{Numeric. CO2 from on-field
#'       agricultural activities (g CO2/kg DM).}
#'     \item{co2_feed_luc_nopeat}{Numeric. CO2 from land-use change,
#'       excluding peatland drainage (g CO2/kg DM).}
#'     \item{co2_feed_luc_peat}{Numeric. CO2 from peatland drainage
#'       (g CO2/kg DM).}
#'     \item{n2o_feed_fertilizer}{Numeric. N2O from fertilizer use
#'       (g N2O/kg DM).}
#'     \item{n2o_feed_manure_applied}{Numeric. N2O from manure applied to
#'       or deposited on soil (g N2O/kg DM).}
#'     \item{n2o_feed_crop_residues}{Numeric. N2O from crop residue
#'       decomposition (g N2O/kg DM).}
#'     \item{ch4_feed_rice}{Numeric. CH4 from rice cultivation
#'       (g CH4/kg DM).}
#'   }
#'
#' @param manure_management_system_fraction data.table. Cohort-level manure
#'   management system fractions passed to
#'   \code{\link{run_emissions_manure_module}}. Required columns:
#'   \describe{
#'     \item{herd_id}{Character. Unique herd identifier.}
#'     \item{cohort_short}{Character. Cohort code (see Common identifiers).}
#'     \item{manure_management_system}{Character. Manure management system name.
#'       \code{mms_pasture} and \code{mms_burned} are reserved for manure
#'       deposited on pasture and burned for fuel, respectively. All other
#'       systems are grouped as "other".}
#'     \item{manure_management_system_fraction}{Numeric. Fraction of total
#'       manure handled by this system for each herd \eqn{\times}{x} cohort
#'       combination (0--1). Must sum to 1 per herd_id.}
#'   }
#'
#' @param manure_management_system_factors data.table. Emission factors and
#'   parameters per manure management system, passed to
#'   \code{\link{run_emissions_manure_module}}. Required columns:
#'   \describe{
#'     \item{manure_management_system}{Character. System name (see
#'       \code{manure_management_system_fraction}).}
#'     \item{ratio_m3CH4_to_kgCH4}{Numeric. CH4 density conversion factor
#'       (kg/m3). Default: 0.67.}
#'     \item{methane_conversion_factor_mcf}{Numeric. Fraction of maximum
#'       CH4-producing capacity (Bo) realised under given management
#'       and environmental conditions (0--1). See IPCC Table 10.17
#'       (2006, 2019).}
#'     \item{ch4_max_producing_capacity_bo}{Numeric. Maximum CH4-producing
#'       capacity per unit volatile solids (m3 CH4/kg VS).
#'       Region- and species-specific. See IPCC Table 10.16 (2019) or
#'       Tables 10A-4 to 10A-9 (2006).}
#'     \item{n2o_ef3}{Numeric. Direct N2O emission factor per manure
#'       management system (kg N2O-N/kg N). See IPCC Table 10.21 and
#'       Table 11.1 (2006, 2019).}
#'     \item{n2o_ef4}{Numeric. Indirect N2O emission factor from
#'       atmospheric deposition of volatilised N (kg N2O-N/(kg NH3-N
#'       + NOx-N)). See IPCC Table 11.3 (2006, 2019).}
#'     \item{nitrogen_fracgas}{Numeric. Fraction of excreted N volatilised as
#'       NH3 and NOx during collection, storage, and treatment (0--1).
#'       See IPCC Table 10.22 (2006, 2019).}
#'     \item{n2o_ef5}{Numeric. Indirect N2O emission factor from leaching
#'       and runoff (kg N2O-N/kg N). See IPCC Table 11.3 (2006, 2019).}
#'     \item{nitrogen_fracleach}{Numeric. Fraction of excreted N lost through
#'       leaching and runoff (0--1). See IPCC Table 10.22 (2006, 2019).}
#'   }
#'
#' @param simulation_duration Numeric. Assessment period length (days). Used by
#'   the demographic herd simulation (when \code{has_herd_structure = FALSE})
#'   and by the production and aggregation steps. Default: \code{365}.
#'
#' @param global_warming_potential_set Character. GWP-100 conversion factors for
#'   expressing CH4 and N2O as CO2-eq. One of:
#'   \itemize{
#'     \item \code{"AR6"}: IPCC 6th Assessment (2021) --- CH4 = 27,
#'       N2O = 273.
#'     \item \code{"AR5_excluding_carbon_feedback"}: IPCC 5th Assessment,
#'       excl. climate-carbon feedbacks (2013) --- CH4 = 28, N2O = 265.
#'     \item \code{"AR5_including_carbon_feedback"}: IPCC 5th Assessment,
#'       incl. climate-carbon feedbacks (2013) --- CH4 = 34, N2O = 298.
#'     \item \code{"AR4"}: IPCC 4th Assessment (2007) --- CH4 = 25,
#'       N2O = 298.
#'   }
#'
#' @param show_indicator Logical. Display progress indicators during the
#'   pipeline run. Default: \code{TRUE}.
#'
#' @return A named list with four elements:
#' \describe{
#'   \item{cohort_level_results}{A cohort-level \code{data.table} containing the
#'     original input columns plus all variables generated across the pipeline.
#'     Calculated variables are grouped below by module.
#'
#'     \subsection{Demographic herd simulation}{
#'     Computed when \code{has_herd_structure = FALSE}:
#'     \describe{
#'       \item{cohort_stock_size}{Average population per cohort (heads).}
#'       \item{offtake_heads}{Animals removed via offtake per year per cohort
#'         (heads/year).}
#'       \item{offtake_heads_assessment}{Animals removed via offtake over the
#'         assessment period per cohort (heads/assessment period).}
#'     }}
#'
#'     \subsection{Weight variables}{
#'     \describe{
#'       \item{live_weight_mature_stage}{Mature (adult) live weight attainable
#'         under given conditions (kg).}
#'       \item{live_weight_cohort_initial}{Live weight at cohort stage start
#'         (kg).}
#'       \item{live_weight_cohort_potential_final}{Potential final live weight
#'         in the absence of offtake (kg). Equals weaning weight for juveniles,
#'         adult weight for sub-adults and adults.}
#'       \item{live_weight_cohort_at_slaughter}{Slaughter weight for offtaken
#'         animals (kg).}
#'       \item{live_weight_cohort_average}{Average live weight over the cohort
#'         stage, weighted by offtaken vs. remaining animals (kg).}
#'       \item{live_weight_cohort_final}{End-of-stage live weight as a weighted
#'         average of surviving and offtaken animals (kg).}
#'       \item{daily_weight_gain}{Average daily weight gain (kg/head/day).}
#'     }}
#'
#'     \subsection{Ration quality variables}{
#'     \describe{
#'       \item{ration_gross_energy}{Diet gross energy (MJ/kg DM).}
#'       \item{ration_metabolizable_energy}{Diet metabolizable energy
#'         (MJ/kg DM).}
#'       \item{ration_nitrogen}{Diet nitrogen content (kg N/kg DM).}
#'       \item{ration_digestibility_fraction}{Diet digestibility: ratio of
#'         digestible (or metabolizable for poultry) to gross energy
#'         (fraction).}
#'       \item{ration_urinary_energy_fraction}{Fraction of diet gross energy
#'         excreted in urine (fraction).}
#'       \item{ration_ash}{Diet ash content (g ash/100 g DM).}
#'     }}
#'
#'     \subsection{Energy requirement variables}{
#'     Expressed as net energy for CTL, BFL, SHP, GTS; as metabolizable energy
#'     for CML and PGS unless stated otherwise.
#'     \describe{
#'       \item{metabolic_energy_req_maintenance}{Energy for maintenance: keeping
#'         body energy at equilibrium (MJ/head/day).}
#'       \item{metabolic_energy_req_activity}{Energy for movement and physical
#'         activity (MJ/head/day).}
#'       \item{metabolic_energy_req_growth}{Energy for weight gain
#'         (MJ/head/day).}
#'       \item{metabolic_energy_req_lactation}{Energy for lactation
#'         (MJ/head/day).}
#'       \item{metabolic_energy_req_work}{Energy for draught power; CTL, BFL,
#'         CML only, 0 for others (MJ/head/day).}
#'       \item{metabolic_energy_req_fibre_production}{Energy for fibre
#'         synthesis; SHP, GTS, CML only, 0 for others (MJ/head/day).}
#'       \item{metabolic_energy_req_pregnancy}{Energy for pregnancy
#'         (MJ/head/day).}
#'       \item{net_energy_maintenance_digestible_energy_ratio}{Net energy for
#'         maintenance to digestible energy ratio (fraction).}
#'       \item{net_energy_growth_digestible_energy_ratio}{Net energy for growth
#'         to digestible energy ratio (fraction).}
#'       \item{metabolic_energy_req_total}{Total daily energy requirement
#'         (MJ/head/day). Gross energy intake for CTL, BFL, SHP, GTS; summed
#'         metabolizable energy for CML, PGS.}
#'       \item{ration_intake}{Average daily dry matter intake
#'         (kg DM/head/day).}
#'     }}
#'
#'     \subsection{Enteric emission variables}{
#'     \describe{
#'       \item{ch4_mitigation_factor}{Mitigation factor (added if not provided
#'         as input).}
#'       \item{ch4_conversion_factor_ym}{CH4 conversion factor (Ym):
#'         percentage of gross energy converted to CH4 (percent).}
#'       \item{ch4_enteric}{Daily enteric CH4 emissions
#'         (kg CH4/head/day).}
#'     }}
#'
#'     \subsection{Nitrogen balance variables}{
#'     \describe{
#'       \item{nitrogen_intake}{Daily N intake (kg N/head/day).}
#'       \item{nitrogen_retention}{Daily N retained in tissues and products
#'         (kg N/head/day).}
#'       \item{nitrogen_excretion}{Daily N excretion (kg N/head/day).}
#'     }}
#'
#'     \subsection{Manure emission variables}{
#'     All in kg/head/day. For each manure pathway (\code{pasture},
#'     \code{burned}, \code{other}, \code{all_noburn}), the following
#'     variables are produced, where \code{{pathway}} is one of the four
#'     pathway names:
#'     \describe{
#'       \item{volatile_solids}{Total volatile solids excreted
#'         (kg VS/head/day).}
#'       \item{ch4_manure_{pathway}}{CH4 emissions from manure.}
#'       \item{n2o_manure_{pathway}_direct}{Direct N2O emissions.}
#'       \item{n2o_manure_{pathway}_vol}{Indirect N2O from
#'         volatilisation of NH3 and NOx.}
#'       \item{n2o_manure_{pathway}_leach}{Indirect N2O from
#'         leaching and runoff.}
#'       \item{n2o_manure_{pathway}_indirect}{Total indirect N2O
#'         (volatilisation + leaching).}
#'       \item{n2o_manure_{pathway}_total}{Total N2O (direct +
#'         indirect).}
#'     }}
#'
#'     \subsection{Feed production emission variables}{
#'     Diet-level averages per kg DM.
#'     \describe{
#'       \item{co2_ration_fertilizer}{CO2 from fertilizer manufacture
#'         (g CO2/kg DM).}
#'       \item{co2_ration_pesticides}{CO2 from pesticide manufacture
#'         (g CO2/kg DM).}
#'       \item{co2_ration_crop_activities}{CO2 from on-field activities
#'         (g CO2/kg DM).}
#'       \item{co2_ration_luc_nopeat}{CO2 from land-use change, excl.
#'         peatland (g CO2/kg DM).}
#'       \item{co2_ration_luc_peat}{CO2 from peatland drainage
#'         (g CO2/kg DM).}
#'       \item{n2o_ration_fertilizer}{N2O from fertilizer use
#'         (g N2O/kg DM).}
#'       \item{n2o_ration_manure_applied}{N2O from manure applied to soil
#'         (g N2O/kg DM).}
#'       \item{n2o_ration_crop_residues}{N2O from crop residues
#'         (g N2O/kg DM).}
#'       \item{ch4_ration_rice}{CH4 from rice cultivation
#'         (g CH4/kg DM).}
#'     }}
#'
#'     \subsection{Production variables}{
#'     Per cohort per assessment period.
#'     \describe{
#'       \item{milk_production_mass_cohort}{Total milk produced (kg).}
#'       \item{milk_production_protein_cohort}{Total milk protein (kg protein).}
#'       \item{milk_production_fpcm_cohort}{Fat-protein-corrected milk (kg).}
#'       \item{fibre_production_cohort}{Total fibre produced (kg).}
#'       \item{meat_production_live_weight_cohort}{Total meat as live weight
#'         (kg).}
#'       \item{meat_production_carcass_weight_cohort}{Total meat as carcass
#'         weight (kg).}
#'       \item{meat_production_bone_free_meat_cohort}{Total bone-free meat
#'         (kg).}
#'       \item{meat_production_protein_cohort}{Total meat protein (kg protein).}
#'     }}
#'
#'     \subsection{Allocation variables}{
#'     Energy allocated per commodity, per cohort per assessment period (MJ).
#'     \describe{
#'       \item{milk_allocation_energy}{Energy for milk production.}
#'       \item{meat_allocation_energy}{Energy for meat production (live-weight
#'         gain to slaughter weight).}
#'       \item{fibre_allocation_energy}{Energy for fibre production.}
#'       \item{work_allocation_energy}{Energy for draught power.}
#'       \item{egg_allocation_energy}{Energy for egg production (currently 0).}
#'     }}
#'   }
#'
#'   \item{herd_level_results}{A herd-level \code{data.table}. When
#'     \code{has_herd_structure = FALSE}, the output from
#'     \code{\link{run_demographic_herd_module}}, including:
#'     \describe{
#'       \item{growth_rate_herd}{Annualised herd growth rate at steady state
#'         (fraction).}
#'     }
#'     When \code{has_herd_structure = TRUE}, the supplied
#'     \code{herd_level_data} is returned unchanged.}
#'
#'   \item{allocation_long}{A herd-level \code{data.table} in long format with
#'     one row per herd \eqn{\times}{x} commodity \eqn{\times}{x} emission
#'     source:
#'     \describe{
#'       \item{herd_id}{Character. Herd identifier.}
#'       \item{species_short}{Character. Species code.}
#'       \item{variable_name}{Character. Emission variable name (e.g.
#'         \code{"ch4_enteric"}, \code{"n2o_manure_pasture_direct"}).}
#'       \item{commodity_name}{Character. Commodity category: one of
#'         \code{"None"}, \code{"Milk"}, \code{"Meat"}, \code{"Fibre"},
#'         \code{"Work"}, \code{"Eggs"}.}
#'       \item{commodity_type}{Character. \code{"Edible"} or
#'         \code{"Non-Edible"}.}
#'       \item{allocation_share}{Numeric. Allocation share for this
#'         commodity-emission combination (fraction).}
#'     }}
#'
#'   \item{aggregation_results}{A named list from
#'     \code{\link{run_aggregation_module}} with elements
#'     \code{results_emissions}, \code{results_feed},
#'     \code{results_production}, and \code{results_nitrogen}. These tables
#'     summarise herd-level emissions, feed intake, production, and nitrogen
#'     balance, all scaled to the assessment duration.}
#' }
#'
#' @details
#' The GLEAM package implements the core computational engine of the Global
#' Livestock Environmental Assessment Model (GLEAM), developed by the Food and
#' Agriculture Organization of the United Nations (FAO). It provides a modular
#' workflow for quantifying greenhouse gas emissions from livestock systems using
#' a Life Cycle Assessment (LCA) approach based on the IPCC Tier 2 methodology.
#'
#' The pipeline covers seven species (CTL, BFL, CML, SHP, GTS, PGS, CHK).
#' Within each herd, animals are organised into six sex-age cohorts (FJ, FS, FA,
#' MJ, MS, MA). These identifiers are used consistently across all modules.
#'
#' The assessment period is specified in days via \code{simulation_duration}
#' (typically 365). Intermediate per-head-per-day variables are carried through
#' the cohort workflow and scaled to cohort and herd totals in the final
#' aggregation step.
#'
#' \subsection{Pipeline sequence}{
#' \enumerate{
#'   \item If \code{has_herd_structure = FALSE}, generate herd structure with
#'     \code{\link{run_demographic_herd_module}}; otherwise use supplied tables
#'     directly.
#'   \item Compute cohort weights (\code{\link{run_weights_module}}).
#'   \item Summarise ration quality (\code{\link{run_ration_quality_module}})
#'     and merge into the cohort table.
#'   \item Compute energy requirements and dry matter intake
#'     (\code{\link{run_metabolic_energy_req_module}}).
#'   \item Compute enteric CH4
#'     (\code{\link{run_emissions_enteric_module}}).
#'   \item Compute nitrogen balance
#'     (\code{\link{run_nitrogen_balance_module}}).
#'   \item Compute manure emissions
#'     (\code{\link{run_emissions_manure_module}}).
#'   \item Summarise feed production emissions
#'     (\code{\link{run_emissions_ration_module}}) and merge into the cohort
#'     table.
#'   \item Compute production outputs
#'     (\code{\link{run_production_module}}).
#'   \item Compute allocation (\code{\link{run_allocation_module}}).
#'   \item Aggregate to herd-level results and CO2-eq
#'     (\code{\link{run_aggregation_module}}).
#' }}
#'
#' All inputs containing \code{herd_id} must refer to the same herd set.
#' Validation blocks variables that are expected to be produced internally.
#'
#' @seealso
#' \code{\link{run_demographic_herd_module}},
#' \code{\link{run_weights_module}},
#' \code{\link{run_ration_quality_module}},
#' \code{\link{run_metabolic_energy_req_module}},
#' \code{\link{run_emissions_enteric_module}},
#' \code{\link{run_nitrogen_balance_module}},
#' \code{\link{run_emissions_manure_module}},
#' \code{\link{run_emissions_ration_module}},
#' \code{\link{run_production_module}},
#' \code{\link{run_allocation_module}},
#' \code{\link{run_aggregation_module}}
#'
#'
#' @examples
#' \dontrun{
#' # --- Shared data loading ---
#' path_ex <- system.file("extdata/run_gleam_examples", package = "gleam")
#'
#' master_hrd_lvl_dt <- data.table::fread(
#'   file.path(path_ex, "master_hrd_lvl_data.csv")
#' )
#' feed_rations_chrt_dt <- data.table::fread(
#'   file.path(path_ex, "feed_rations_share_chrt.csv")
#' )
#' feed_params_dt <- data.table::fread(
#'   file.path(path_ex, "feed_quality.csv")
#' )
#' feed_emissions_dt <- data.table::fread(
#'   file.path(path_ex, "feed_emission_factors.csv")
#' )
#' mms_fraction_dt <- data.table::fread(
#'   file.path(path_ex, "manure_management_system_fraction.csv")
#' )
#' mms_factors_dt <- data.table::fread(
#'   file.path(path_ex, "manure_management_system_factors.csv")
#' )
#'}

#' @examples
#' # Example 1: You do NOT have herd structure — use cohort input for herd simulation.
#' # Pipeline runs herd simulation first, then the rest of the pipeline.
#' \dontrun{
#' path_run_gleam_examples <- system.file("extdata/run_gleam_examples", package = "gleam")
#'
#' master_chrt_lvl_no_structure_dt <- data.table::fread(file.path(
#'   path_run_gleam_examples, "master_chrt_lvl_no_structure_data.csv"
#' ))
#' master_hrd_lvl_dt <- data.table::fread(
#' file.path(path_run_gleam_examples, "master_hrd_lvl_data.csv")
#' )
#' feed_rations_chrt_dt <- data.table::fread(
#' file.path(path_run_gleam_examples, "feed_rations_share_chrt.csv")
#' )
#' feed_params_dt <- data.table::fread(system.file(
#'   "extdata/run_gleam_examples/feed_quality.csv",
#'   package = "gleam"
#' ))
#' feed_emissions_dt <- data.table::fread(system.file(
#'   "extdata/run_gleam_examples/feed_emission_factors.csv",
#'   package = "gleam"
#' ))
#'
#' manure_management_system_fraction_dt <- data.table::fread(
#'   file.path(path_run_gleam_examples, "manure_management_system_fraction.csv")
#' )
#' manure_management_system_factors_dt <- data.table::fread(
#'   file.path(path_run_gleam_examples, "manure_management_system_factors.csv")
#' )
#'
#' results <- run_gleam(
#'   has_herd_structure = FALSE,
#'   cohort_level_data = master_chrt_lvl_no_structure_dt,
#'   herd_level_data = master_hrd_lvl_dt,
#'   feed_rations = feed_rations_chrt_dt,
#'   feed_params = feed_params_dt,
#'   feed_emissions = feed_emissions_dt,
#'   manure_management_system_fraction = manure_management_system_fraction_dt,
#'   manure_management_system_factors = manure_management_system_factors_dt,
#'   simulation_duration = 365
#' )
#' print(results$cohort_level_results)
#' print(results$allocation_long)
#' }
#'
#' # Example 2: You already HAVE herd structure — use cohort table and skip herd simulation.
#' # Pipeline skips herd simulation and uses this as the starting cohort table.
#' \dontrun{
#' path_run_gleam_examples <- system.file("extdata/run_gleam_examples", package = "gleam")
#'
#' master_chrt_lvl_structure_dt <- data.table::fread(file.path(
#'   path_run_gleam_examples, "master_chrt_lvl_structure_data.csv"
#' ))
#' master_hrd_lvl_dt <- data.table::fread(
#' file.path(path_run_gleam_examples, "master_hrd_lvl_data.csv")
#' )
#' feed_rations_chrt_dt <- data.table::fread(
#' file.path(path_run_gleam_examples, "feed_rations_share_chrt.csv")
#' )
#' feed_params_dt <- data.table::fread(system.file(
#'   "extdata/run_gleam_examples/feed_quality.csv",
#'   package = "gleam"
#' ))
#' feed_emissions_dt <- data.table::fread(system.file(
#'   "extdata/run_gleam_examples/feed_emission_factors.csv",
#'   package = "gleam"
#' ))
#'
#' manure_management_system_fraction_dt <- data.table::fread(
#'   file.path(path_run_gleam_examples, "manure_management_system_fraction.csv")
#' )
#' manure_management_system_factors_dt <- data.table::fread(
#'   file.path(path_run_gleam_examples, "manure_management_system_factors.csv")
#' )
#'
#' results <- run_gleam(
#'   has_herd_structure = TRUE,
#'   cohort_level_data = master_chrt_lvl_structure_dt,
#'   herd_level_data = master_hrd_lvl_dt,
#'   feed_rations = feed_rations_chrt_dt,
#'   feed_params = feed_params_dt,
#'   feed_emissions = feed_emissions_dt,
#'   manure_management_system_fraction = manure_management_system_fraction_dt,
#'   manure_management_system_factors = manure_management_system_factors_dt,
#'   simulation_duration = 365,
#'   global_warming_potential_set = "AR6"
#' )
#' print(results$cohort_level_results)
#' print(results$allocation_long)
#' }
#' @export
run_gleam <- function(
    has_herd_structure = FALSE,
    cohort_level_data,
    herd_level_data,
    feed_rations,
    feed_params,
    feed_emissions,
    manure_management_system_fraction,
    manure_management_system_factors,
    simulation_duration = 365,
    global_warming_potential_set = "AR6",
    show_indicator = TRUE
) {

  # --- Step 1: Validate inputs ------------------------------------------------
  validate_run_gleam_inputs(
    has_herd_structure = has_herd_structure,
    cohort_level_data = cohort_level_data,
    herd_level_data = herd_level_data,
    feed_rations = feed_rations,
    feed_params = feed_params,
    feed_emissions = feed_emissions,
    manure_management_system_fraction = manure_management_system_fraction,
    manure_management_system_factors = manure_management_system_factors,
    simulation_duration = simulation_duration,
    global_warming_potential_set = global_warming_potential_set
  )

  # Show progress indicator if requested
  if (show_indicator) {
    cli::cli_h1("\U1F552 Running GLEAM pipeline\U2026")
  }

  # --- Step 2: Run herd simulation (or use provided structure) ----------------
  if (has_herd_structure) {
    gleam_chrt_data <- data.table::as.data.table(cohort_level_data)
    gleam_hrd_data <- data.table::as.data.table(herd_level_data)
  } else {
    herd_results <- run_demographic_herd_module(
      cohort_level_data = cohort_level_data,
      herd_level_data = herd_level_data,
      simulation_duration = simulation_duration,
      show_indicator = show_indicator
    )
    gleam_chrt_data <- herd_results$cohort_level_results
    gleam_hrd_data <- herd_results$herd_level_results
  }

  # --- Step 3: Run weights at cohort level ------------------------------------
  weights_results <- run_weights_module(
    cohort_level_data = gleam_chrt_data,
    herd_level_data = herd_level_data,
    show_indicator = show_indicator
  )

  gleam_chrt_data <- weights_results$cohort_level_results

  # --- Step 4: Summarize feed rations and merge -------------------------------
  feed_rations_summary <- run_ration_quality_module(
    rations_share = feed_rations,
    feed_params = feed_params,
    show_indicator = show_indicator
  )

  gleam_chrt_data <- merge(
    gleam_chrt_data,
    feed_rations_summary,
    by = c("herd_id", "species_short", "cohort_short")
  )

  # --- Step 5: Run energy requirements and DMI --------------------------------
  gleam_chrt_data <- run_metabolic_energy_req_module(
    cohort_level_data = gleam_chrt_data,
    herd_level_data = herd_level_data,
    show_indicator = show_indicator
  )

  # --- Step 6: Run enteric methane direct emissions ---------------------------
  # ch4_mitigation_factor is optional cohort-level input
  gleam_chrt_data <- run_emissions_enteric_module(
    cohort_level_data = gleam_chrt_data,
    show_indicator = show_indicator
  )

  # --- Step 7: Run nitrogen balance -------------------------------------------
  gleam_chrt_data <- run_nitrogen_balance_module(
    cohort_level_data = gleam_chrt_data,
    herd_level_data = herd_level_data,
    show_indicator = show_indicator
  )

  # --- Step 8: Run direct emissions from manure management systems ------------
  gleam_chrt_data <- run_emissions_manure_module(
    cohort_level_data = gleam_chrt_data,
    manure_management_system_fraction = manure_management_system_fraction,
    manure_management_system_factors = manure_management_system_factors,
    show_indicator = show_indicator
  )

  # --- Step 9: Run feed emissions (diet-level emission factors) ---------------
  feed_emissions_summary <- run_emissions_ration_module(
    rations_share = feed_rations,
    feed_emissions = feed_emissions,
    show_indicator = show_indicator
  )
  gleam_chrt_data <- merge(
    gleam_chrt_data,
    feed_emissions_summary,
    by = c("herd_id", "species_short", "cohort_short")
  )

  # --- Step 10: Run production (milk, fibre, meat) at cohort level ------------
  gleam_chrt_data <- run_production_module(
    cohort_level_data = gleam_chrt_data,
    herd_level_data = herd_level_data,
    simulation_duration = simulation_duration,
    show_indicator = show_indicator
  )

  # --- Step 11: Run allocation (energy allocation terms and commodity shares) -
  allocation_results <- run_allocation_module(
    cohort_level_data = gleam_chrt_data,
    herd_level_data = gleam_hrd_data,
    simulation_duration = simulation_duration,
    show_indicator = show_indicator
  )
  gleam_chrt_data <- allocation_results$cohort_allocation_inputs

  # --- Step 12: Run aggregation (herd-level totals, allocated emissions in CO₂eq) ----
  aggregation_results <- run_aggregation_module(
    cohort_level_data = gleam_chrt_data,
    allocation_herd_long = allocation_results$allocation_long,
    simulation_duration = simulation_duration,
    global_warming_potential_set = global_warming_potential_set,
    show_indicator = show_indicator
  )

  # Clear progress indicator if it was shown
  if (show_indicator) {
    cli::cli_status_clear()
    cli::cli_rule()
    cli::cli_alert_success("{.strong GLEAM pipeline complete.}")
  }

  return(
    list(
      cohort_level_results = gleam_chrt_data,
      herd_level_results = gleam_hrd_data,
      allocation_long = allocation_results$allocation_long,
      aggregation_results = list(
        results_emissions = aggregation_results$results_emissions,
        results_feed = aggregation_results$results_feed,
        results_production = aggregation_results$results_production,
        results_nitrogen = aggregation_results$results_nitrogen
      )
    )
  )
}
