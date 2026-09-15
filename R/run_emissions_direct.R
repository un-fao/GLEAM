#' Run Direct Emissions Pipeline
#'
#' Calculates CH4 emissions from enteric fermentation and CH4 and N2O emissions
#' from manure management at cohort level.
#' Runs the GLEAM direct emissions pipeline from master herd and cohort inputs
#' through the following modules: herd (optional), weights, ration quality
#' (optional), energy requirements, enteric fermentation, nitrogen balance,
#' manure emissions, production, allocation, and aggregation.
#' <br>
#' <br>
#' \strong{Common identifiers}:
#' Several input tables share the following identifier columns. Their supported
#' values are listed once here and referenced throughout.
#' <br>
#' <br>
#' \strong{\code{species_short}} --- Character. Species code:
#' \itemize{
#'   \item \code{CTL}: Cattle
#'   \item \code{BFL}: Buffalo
#'   \item \code{SHP}: Sheep
#'   \item \code{GTS}: Goats
#'   \item \code{PGS}: Pigs
#'   \item \code{CML}: Camels
#' }
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
#' @inheritParams run_gleam
#'
#' @param emission_factors_only Logical. If \code{TRUE}, stop after calculating
#'   enteric and manure emission factors at cohort level, skipping production,
#'   allocation, and aggregation. Factors are returned in
#'   \code{cohort_level_results}; \code{allocation_long} and
#'   \code{aggregation_results} are \code{NULL}. Defaults to \code{FALSE}.
#'
#' @param feed_rations Optional data.table. Cohort-level feed ration shares
#'   passed to \code{\link{run_ration_quality_module}}. Defaults to \code{NULL}.
#'   Provide together with \code{feed_params}, or omit both and supply primary
#'   nutritional quality in \code{cohort_level_data} (see Details).
#'   Required columns when supplied:
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
#' @param feed_params Optional data.table. Feed nutritional parameters.
#'   Defaults to \code{NULL}. Provide together with \code{feed_rations}.
#'   Required columns when supplied:
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
#' @details
#' This function represents the intermediate module of the Global Livestock Environmental
#' Assessment Model (GLEAM) computational pipeline [run_gleam()] to compute direct emissions.
#' The function computes CH4 emissions from enteric fermentation and CH4 and
#' N2O emissions from manure management, together with the intermediate
#' biological and production variables required by the calculation.
#' 
#' 
#' The function can operate either from a complete feed ration description or
#' from pre-calculated ration-quality parameters.
#' In both cases, \code{cohort_level_data} must contain exactly one row for
#' each of the six cohorts per herd, including when
#' \code{has_herd_structure = TRUE} or \code{emission_factors_only = TRUE}.
#'
#' When \code{feed_rations} and \code{feed_params} are supplied, ration quality
#' is calculated internally using \code{\link{run_ration_quality_module}}.
#' Alternatively, both inputs can be omitted and the required ration-quality
#' variables supplied directly in \code{cohort_level_data}. In this second
#' mode, the ration-quality module is bypassed and the supplied values are used
#' directly by the subsequent calculations.
#'
#' When ration quality is supplied directly, \code{cohort_level_data} must
#' include the following variables:
#' \describe{
#'   \item{ration_gross_energy}{
#'     Numeric. Average gross energy content of the diet (MJ/kg DM).
#'   }
#'   \item{ration_metabolizable_energy}{
#'     Numeric. Average metabolizable energy content of the diet (MJ/kg DM).
#'   }
#'   \item{ration_nitrogen}{
#'     Numeric. Average nitrogen content of the diet (kg N/kg DM).
#'   }
#'   \item{ration_digestibility_fraction}{
#'     Numeric. Average digestibility of the ration, expressed as the ratio of
#'     digestible energy to gross energy, or metabolizable energy to gross
#'     energy for poultry (fraction).
#'   }
#'   \item{ration_urinary_energy_fraction}{
#'     Numeric. Fraction of gross energy excreted in urine (fraction).
#'   }
#'   \item{ration_ash}{
#'     Numeric. Average ash content of the ration on a dry-matter basis
#'     (kg ash/kg DM).
#'   }
#' }
#'
#' The computational sequence follows the corresponding modules used by
#' \code{\link{run_gleam}}:
#' \enumerate{
#'   \item herd structure is generated when
#'   \code{has_herd_structure = FALSE}; otherwise the supplied cohort
#'   structure is used directly;
#'   \item cohort live weights and weight gain are calculated;
#'   \item ration quality is calculated, unless supplied directly;
#'   \item energy requirements and dry matter intake are calculated;
#'   \item enteric CH4 emissions are calculated;
#'   \item nitrogen intake, retention, and excretion are calculated;
#'   \item CH4 and direct and indirect N2O emissions from manure management
#'   are calculated;
#'   \item production, allocation, and aggregation are calculated unless
#'   \code{emission_factors_only = TRUE}.
#' }
#'
#' Feed production emissions are outside the scope of this function.
#' Therefore, no \code{feed_emissions} input is required and feed-related
#' upstream emissions are not included in the returned emission totals.
#'
#' If \code{emission_factors_only = TRUE}, the function stops after enteric
#' and manure emissions have been calculated. Cohort-level emission factors
#' and the intermediate variables used to derive them are returned, while
#' production, allocation, aggregation, herd-level emission totals, and
#' CO2-eq conversion are not performed.
#' 
#' @seealso
#' \code{\link{run_gleam}},
#' \code{\link{run_demographic_herd_module}},
#' \code{\link{run_weights_module}},
#' \code{\link{run_ration_quality_module}},
#' \code{\link{run_metabolic_energy_req_module}},
#' \code{\link{run_emissions_enteric_module}},
#' \code{\link{run_nitrogen_balance_module}},
#' \code{\link{run_emissions_manure_module}},
#' \code{\link{run_production_module}},
#' \code{\link{run_allocation_module}},
#' \code{\link{run_aggregation_module}}
#'
#' @return A named list with four elements. When \code{emission_factors_only = TRUE},
#'   \code{cohort_level_results} contains the inputs and variables calculated
#'   through manure emissions, while \code{allocation_long} and
#'   \code{aggregation_results} are \code{NULL}. Otherwise all outputs below
#'   are calculated:
#' \describe{
#'   \item{cohort_level_results}{A cohort-level \code{data.table} containing the
#'     original input columns plus all variables generated across the pipeline.
#'     Calculated variables are grouped below by module.
#'     \subsection{Demographic herd simulation}{
#'     Computed when \code{has_herd_structure = FALSE}:
#'     \describe{
#'       \item{cohort_stock_size}{Numeric. Average population size in each of the 6 sex-age cohorts (# heads). (cohorts = \code{FJ}, \code{FS}, \code{FA}, \code{MJ}, \code{MS}, \code{MA}).}
#'       \item{offtake_heads}{Numeric. Total number of animals removed via offtake over the year, aggregated to 6 sex-age cohorts (heads/year) (cohorts = \code{FJ}, \code{FS}, \code{FA}, \code{MJ}, \code{MS}, \code{MA}).}
#'       \item{offtake_heads_assessment}{Numeric. Total number of animals removed via offtake over the assessment period, aggregated to 6 sex-age cohorts (heads/assessment period) (cohorts = \code{FJ}, \code{FS}, \code{FA}, \code{MJ}, \code{MS}, \code{MA}).}
#'     }}
#'     \subsection{Weight variables}{
#'     \describe{
#'       \item{live_weight_mature_stage}{Numeric. Mature (adult) live weight that the animal can attain under given biological and management conditions (kg).}
#'       \item{live_weight_cohort_initial}{Numeric. Live weight at the beginning of the cohort stage (kg).}
#'       \item{live_weight_cohort_potential_final}{Numeric. Potential final live weight attainable at the end of the cohort stage in the absence of offtake (kg). (For juveniles: equals weaning weight; For subadults: equals adult live weight; For adults: equals adult live weight)}
#'       \item{live_weight_cohort_at_slaughter}{Numeric. Live weight at slaughter for animals removed from the cohort (kg).}
#'       \item{live_weight_cohort_average}{Numeric. Average live weight over the cohort stage. Computed by accounting for the share of offtaken animals within the cohort, using their slaughter weight, and the potential final weight of animals that remain in the cohort (kg).}
#'       \item{live_weight_cohort_final}{Numeric. Live weight at the end of the cohort stage, accounting for both surviving and offtaken animals. Computed as a weighted average of the potential final weight of surviving animals and the slaughter weight of offtaken animals, based on the offtake rate (kg).}
#'       \item{daily_weight_gain}{Numeric. Average live weight gain of the cohort over the cohort stage (kg/head/day).}
#'     }}
#'     \subsection{Ration quality variables}{
#'     \describe{
#'       \item{ration_gross_energy}{Numeric. Average gross energy content of the diet (MJ/kg DM).}
#'       \item{ration_metabolizable_energy}{Numeric. Average metabolizable energy content of the diet (MJ/kg DM).}
#'       \item{ration_nitrogen}{Numeric. Average nitrogen content of diet (kg N/kg DM).}
#'       \item{ration_digestibility_fraction}{Numeric. Average digestibility of the feed ration, expressed as ratio of digestible (or metabolizable, for poultry) to gross energy content (fraction).}
#'       \item{ration_urinary_energy_fraction}{Numeric. Fraction of feed's gross energy that is excreted in urine (fraction).}
#'       \item{ration_ash}{Numeric. Average ash content of feed, calculated as a fraction of the dry matter intake (kg ash/kg DM).}
#'     }}
#'     \subsection{Energy requirement variables}{
#'     Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS unless stated otherwise.
#'     \describe{
#'       \item{metabolic_energy_req_maintenance}{Numeric. Energy required for maintenance, defined as the amount of energy needed to keep the animal at equilibrium such that body energy is neither gained nor lost (MJ/head/day). Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS.}
#'       \item{metabolic_energy_req_activity}{Numeric. Energy required for activity, defined as the amount of energy needed to support animal movement and physical activity (MJ/head/day). Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS.}
#'       \item{metabolic_energy_req_growth}{Numeric. Energy required for growth (i.e., weight gain) (MJ/head/day). Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS.}
#'       \item{metabolic_energy_req_lactation}{Numeric. Energy required for lactation (MJ/head/day). Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS.}
#'       \item{metabolic_energy_req_work}{Numeric. Energy required for work, used to estimate the energy required for draught power for CTL, BFL and CML (MJ/head/day). Assumed to be 0 for other species. Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS.}
#'       \item{metabolic_energy_req_fibre_production}{Numeric. Energy required for the synthesis of fibre for SHP, GTS and CML. Assumed to be 0 for other species. (MJ/head/day). Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS (MJ/head/day).}
#'       \item{metabolic_energy_req_pregnancy}{Numeric. Energy required for pregnancy for pregnant females (MJ/head/day). Expressed as net energy for CTL, BFL, SHP, GTS and as metabolizable energy for CML and PGS.}
#'       \item{net_energy_maintenance_digestible_energy_ratio}{Numeric. Ratio of net energy available for maintenance in the diet to digestible energy consumed (fraction).}
#'       \item{net_energy_growth_digestible_energy_ratio}{Numeric. Ratio of net energy available for growth in the diet to digestible energy consumed (fraction).}
#'       \item{metabolic_energy_req_total}{Numeric. Total daily energy requirement (MJ/head/day). For CTL, BFL, SHP and GTS this is expressed as gross energy intake requirement (GE). For CML and PGS the function returns the summed daily metabolizable energy requirement.}
#'       \item{ration_intake}{Numeric. Average daily dry matter intake of feed (kg DM/head/day).}
#'     }}
#'     \subsection{Enteric emission variables}{
#'     \describe{
#'       \item{ch4_mitigation_factor}{Numeric. Multiplicative mitigation factor applied to baseline enteric methane (CH4) emissions (dimensionless). If not provided, a default value of \code{1} (no mitigation) is used.}
#'       \item{ch4_conversion_factor_ym}{Numeric. Methane (CH4) conversion factor (ym), representing the percentage of gross energy of the feed ration that is converted to CH4 (percentage).}
#'       \item{ch4_enteric}{Numeric. Average daily enteric methane (CH4) emissions (kg CH4/head/day).}
#'     }}
#'     \subsection{Nitrogen balance variables}{
#'     \describe{
#'       \item{nitrogen_intake}{Numeric. Daily nitrogen intake (kg N/head/day).}
#'       \item{nitrogen_retention}{Numeric. Daily nitrogen retention in animal body tissues and products (e.g., growth, pregnancy, milk...) (kg N/head/day).}
#'       \item{nitrogen_excretion}{Numeric. Daily nitrogen excretion (kg N/head/day).}
#'     }}
#'     \subsection{Manure emission variables}{
#'     \describe{
#'       \item{volatile_solids}{Numeric. Total volatile solids (VS) excreted per animal per day, representing the organic material in livestock manure and consisting of both biodegradable and non-biodegradable fractions (kg VS/head/day).}
#'       \item{ch4_manure_pasture}{Numeric. Methane (CH4) emissions from manure deposited on pasture (kg CH4/head/day).}
#'       \item{ch4_manure_burned}{Numeric. Methane (CH4) emissions from manure burned for fuel (kg CH4/head/day).}
#'       \item{ch4_manure_other}{Numeric. Methane (CH4) emissions from manure management systems, excluding emissions from manure deposited on pasture and burned for fuel (kg CH4/head/day).}
#'       \item{ch4_manure_all_noburn}{Numeric. Methane (CH4) emissions from manure management systems, excluding manure burned for fuel (kg CH4/head/day).}
#'       \item{n2o_manure_pasture_direct}{Numeric. Direct nitrous oxide (N2O) emissions from manure deposited on pasture (kg N2O/head/day).}
#'       \item{n2o_manure_burned_direct}{Numeric. Direct nitrous oxide (N2O) emissions from manure burned for fuel (kg N2O/head/day).}
#'       \item{n2o_manure_other_direct}{Numeric. Direct nitrous oxide (N2O) emissions from manure management systems, excluding emissions from manure deposited on pasture and burned for fuel (kg N2O/head/day).}
#'       \item{n2o_manure_all_noburn_direct}{Numeric. Direct nitrous oxide (N2O) emissions from manure management systems, excluding emissions from manure burned for fuel (kg N2O/head/day).}
#'       \item{n2o_manure_pasture_vol}{Numeric. Indirect nitrous oxide (N2O) emissions resulting from atmospheric deposition of volatilised nitrogen (NH3 and NOx) from manure deposited on pasture (kg N2O/head/day).}
#'       \item{n2o_manure_burned_vol}{Numeric. Indirect nitrous oxide (N2O) emissions resulting from atmospheric deposition of volatilised nitrogen (NH3 and NOx) from manure burned for fuel (kg N2O/head/day).}
#'       \item{n2o_manure_other_vol}{Numeric. Indirect nitrous oxide (N2O) emissions resulting from atmospheric deposition of volatilised nitrogen (NH3 and NOx) from manure management systems, excluding manure deposited on pasture and manure burned for fuel (kg N2O/head/day).}
#'       \item{n2o_manure_all_noburn_vol}{Numeric. Indirect nitrous oxide (N2O) emissions resulting from atmospheric deposition of volatilised nitrogen (NH3 and NOx) from manure management systems, excluding losses from manure burned for fuel (kg N2O/head/day).}
#'       \item{n2o_manure_pasture_leach}{Numeric. Indirect nitrous oxide (N2O) emissions resulting from leaching and runoff of manure nitrogen from manure deposited on pasture (kg N2O/head/day).}
#'       \item{n2o_manure_burned_leach}{Numeric. Indirect nitrous oxide (N2O) emissions resulting from leaching and runoff of manure nitrogen from manure burned for fuel (kg N2O/head/day).}
#'       \item{n2o_manure_other_leach}{Numeric. Indirect nitrous oxide (N2O) emissions resulting from leaching and runoff of manure nitrogen from manure management systems, excluding losses from manure deposited on pasture and manure burned for fuel (kg N2O/head/day).}
#'       \item{n2o_manure_all_noburn_leach}{Numeric. Indirect nitrous oxide (N2O) emissions resulting from leaching and runoff of manure nitrogen from manure management systems, excluding losses from manure burned for fuel (kg N2O/head/day).}
#'       \item{n2o_manure_pasture_indirect}{Numeric. Total indirect nitrous oxide (N2O) emissions from manure deposited on pasture. Includes emissions from atmospheric deposition of volatilised nitrogen (NH3 and NOx) and from leaching and runoff of manure nitrogen (kg N2O/head/day).}
#'       \item{n2o_manure_burned_indirect}{Numeric. Total indirect nitrous oxide (N2O) emissions originating from manure burned for fuel. Includes emissions from atmospheric deposition of volatilised nitrogen (NH3 and NOx) and from leaching and runoff of manure nitrogen (kg N2O/head/day).}
#'       \item{n2o_manure_other_indirect}{Numeric. Total indirect nitrous oxide (N2O) emissions originating from manure management systems, excluding manure deposited on pasture and burned for fuel. Includes emissions from atmospheric deposition of volatilised nitrogen (NH3 and NOx) and from leaching and runoff of manure nitrogen (kg N2O/head/day).}
#'       \item{n2o_manure_pasture_total}{Numeric. Total nitrous oxide emissions from manure deposited on pasture. Includes direct emissions and indirect emissions from volatilisation, leaching, and runoff (kg N2O/head/day).}
#'       \item{n2o_manure_burned_total}{Numeric. Total nitrous oxide emissions (N2O) from manure burned for fuel. Includes direct emissions and indirect emissions from volatilisation, leaching, and runoff (kg N2O/head/day).}
#'       \item{n2o_manure_other_total}{Numeric. Total nitrous oxide (N2O) emissions from manure management systems, excluding manure deposited on pasture and manure burned for fuel. Includes direct emissions and indirect emissions from volatilisation, leaching, and runoff (kg N2O/head/day).}
#'     }}
#'     \subsection{Production variables}{
#'     Computed when \code{emission_factors_only = FALSE}:
#'     \describe{
#'       \item{milk_production_mass_cohort}{Numeric. Total milk production produced over the assessment period (kg/cohort/assessment period).}
#'       \item{milk_production_protein_cohort}{Numeric. Total milk protein production produced over the assessment period (kg protein/cohort/assessment period).}
#'       \item{milk_production_fpcm_cohort}{Numeric. Total fat-protein-corrected milk (FPCM) produced over the assessment period (kg/cohort/assessment period).}
#'       \item{fibre_production_cohort}{Numeric. Total fibre produced over the assessment period by cohort (kg/cohort/assessment period).}
#'       \item{meat_production_live_weight_cohort}{Numeric. Total meat produced as live weight over the assessment period by cohort (kg/cohort/assessment period).}
#'       \item{meat_production_carcass_weight_cohort}{Numeric. Total meat as carcass weight (excluding organs, and other by-products after dressing) produced over the assessment period by cohort (kg/cohort/assessment period).}
#'       \item{meat_production_bone_free_meat_cohort}{Numeric. Total bone-free-meat (excluding bones, organs, and other by-products after dressing and bone removal) produced over the assessment period by cohort (kg/cohort/assessment period).}
#'       \item{meat_production_protein_cohort}{Numeric. Total meat protein (excluding bones, organs, and other by-products after dressing and bone removal) produced over the assessment period by cohort (kg protein/cohort/assessment period).}
#'     }}
#'     \subsection{Allocation variables}{
#'     Computed when \code{emission_factors_only = FALSE}:
#'     \describe{
#'       \item{milk_allocation_energy}{Numeric. Energy required to produce total milk output by cohort (MJ/cohort/assessment period). Non-zero values are applicable only to milk-producing species and cohorts (species = CTL, BFL, CML, SHP, GTS; cohorts = FA). All other species-cohort combinations are assigned a value of 0.}
#'       \item{meat_allocation_energy}{Numeric. Energy required by a given sex-age cohort for total meat output by cohort during the assessment period, equal to the energy needed to produce all live-weight gain to reach the target slaughter weight (MJ/cohort/assessment period).}
#'       \item{fibre_allocation_energy}{Numeric. Energy required to produce all fibre output by cohort (MJ/cohort/assessment period).}
#'       \item{work_allocation_energy}{Numeric. Energy required to provide all draught power (traction/work) by cohort (MJ/cohort/assessment period).}
#'       \item{egg_allocation_energy}{Numeric. Energy required for egg production over the assessment period (MJ/cohort/assessment period). Currently set to 0.}
#'     }}
#'   }
#'   \item{herd_level_results}{A herd-level \code{data.table}. When
#'     \code{has_herd_structure = FALSE}, the output from
#'     \code{\link{run_demographic_herd_module}}, including:
#'     \describe{
#'       \item{growth_rate_herd}{Numeric. Annualized growth rate at which the herd reaches steady state (fraction).}
#'     }
#'     When \code{has_herd_structure = TRUE}, the supplied
#'     \code{herd_level_data} is returned unchanged.}
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
#'   \item{aggregation_results}{A named list from
#'     \code{\link{run_aggregation_module}} with elements
#'     \code{results_emissions}, \code{results_feed},
#'     \code{results_production}, and \code{results_nitrogen}. These tables
#'     summarise herd-level emissions, feed intake, production, and nitrogen
#'     balance, all scaled to the assessment duration.}
#' }
#'
#' @seealso \code{\link{run_gleam}}, \code{\link{run_ration_quality_module}}
#' @examples
#' # Use case 1: Ration composition and quality of feed items provided
#' # Example 1a: Without a supplied herd structure.
#' \donttest{
#'
#' path_run_modules_examples <- system.file("extdata/run_modules_examples", package = "gleam")
#' emissions_direct_input_chrt_no_structure_dt <- data.table::fread(file.path(
#'   path_run_modules_examples, "emissions_direct_input_chrt_no_structure_data.csv"
#' ))
#' emissions_direct_input_hrd_dt <- data.table::fread(file.path(
#'   path_run_modules_examples, "emissions_direct_input_hrd_data.csv"
#' ))
#' feed_rations_chrt_dt <- data.table::fread(file.path(
#'   path_run_modules_examples, "feed_rations_share_chrt.csv"
#' ))
#' feed_params_dt <- data.table::fread(file.path(
#'   path_run_modules_examples, "feed_quality.csv"
#' ))
#' manure_management_system_fraction_dt <- data.table::fread(file.path(
#'   path_run_modules_examples, "manure_management_system_fraction.csv"
#' ))
#' manure_management_system_factors_dt <- data.table::fread(file.path(
#'   path_run_modules_examples, "manure_management_system_factors.csv"
#' ))
#'
#' results <- run_emissions_direct(
#'   has_herd_structure = FALSE,
#'   cohort_level_data = emissions_direct_input_chrt_no_structure_dt,
#'   herd_level_data = emissions_direct_input_hrd_dt,
#'   feed_rations = feed_rations_chrt_dt,
#'   feed_params = feed_params_dt,
#'   manure_management_system_fraction = manure_management_system_fraction_dt,
#'   manure_management_system_factors = manure_management_system_factors_dt,
#'   simulation_duration = 365,
#'   global_warming_potential_set = "AR6"
#' )
#' print(results$cohort_level_results)
#' print(results$herd_level_results)
#' }
#'
#' # Example 1b: With a supplied herd structure.
#' \donttest{
#' path_run_modules_examples <- system.file("extdata/run_modules_examples", package = "gleam")
#' emissions_direct_input_chrt_structure_dt <- data.table::fread(file.path(
#'   path_run_modules_examples, "emissions_direct_input_chrt_structure_data.csv"
#' ))
#' emissions_direct_input_hrd_dt <- data.table::fread(file.path(
#'   path_run_modules_examples, "emissions_direct_input_hrd_data.csv"
#' ))
#' feed_rations_chrt_dt <- data.table::fread(file.path(
#'   path_run_modules_examples, "feed_rations_share_chrt.csv"
#' ))
#' feed_params_dt <- data.table::fread(file.path(
#'   path_run_modules_examples, "feed_quality.csv"
#' ))
#' manure_management_system_fraction_dt <- data.table::fread(file.path(
#'   path_run_modules_examples, "manure_management_system_fraction.csv"
#' ))
#' manure_management_system_factors_dt <- data.table::fread(file.path(
#'   path_run_modules_examples, "manure_management_system_factors.csv"
#' ))
#'
#' results <- run_emissions_direct(
#'   has_herd_structure = TRUE,
#'   cohort_level_data = emissions_direct_input_chrt_structure_dt,
#'   herd_level_data = emissions_direct_input_hrd_dt,
#'   feed_rations = feed_rations_chrt_dt,
#'   feed_params = feed_params_dt,
#'   manure_management_system_fraction = manure_management_system_fraction_dt,
#'   manure_management_system_factors = manure_management_system_factors_dt,
#'   simulation_duration = 365,
#'   global_warming_potential_set = "AR6"
#' )
#' print(results$cohort_level_results)
#' print(results$herd_level_results)
#' }
#'
#' # Use case 2:  Ration quality directly provided
#' # Example 2a: Without a supplied herd structure.
#' \donttest{
#' path_run_modules_examples <- system.file("extdata/run_modules_examples", package = "gleam")
#' emissions_direct_input_chrt_no_structure_ration_quality_dt <- data.table::fread(file.path(
#'   path_run_modules_examples, "emissions_direct_input_chrt_no_structure_ration_quality_data.csv"
#' ))
#' emissions_direct_input_hrd_dt <- data.table::fread(file.path(
#'   path_run_modules_examples, "emissions_direct_input_hrd_data.csv"
#' ))
#' manure_management_system_fraction_dt <- data.table::fread(file.path(
#'   path_run_modules_examples, "manure_management_system_fraction.csv"
#' ))
#' manure_management_system_factors_dt <- data.table::fread(file.path(
#'   path_run_modules_examples, "manure_management_system_factors.csv"
#' ))
#'
#' results <- run_emissions_direct(
#'   has_herd_structure = FALSE,
#'   cohort_level_data = emissions_direct_input_chrt_no_structure_ration_quality_dt,
#'   herd_level_data = emissions_direct_input_hrd_dt,
#'   manure_management_system_fraction = manure_management_system_fraction_dt,
#'   manure_management_system_factors = manure_management_system_factors_dt,
#'   simulation_duration = 365,
#'   global_warming_potential_set = "AR6"
#' )
#' print(results$cohort_level_results)
#' print(results$herd_level_results)
#' }
#'
#' # Example 2b: With a supplied herd structure.
#' \donttest{
#' path_run_modules_examples <- system.file("extdata/run_modules_examples", package = "gleam")
#' # This cohort file already contains all six ration quality columns.
#' emissions_direct_input_chrt_structure_ration_quality_dt <- data.table::fread(file.path(
#'   path_run_modules_examples, "emissions_direct_input_chrt_structure_ration_quality_data.csv"
#' ))
#' emissions_direct_input_hrd_dt <- data.table::fread(file.path(
#'   path_run_modules_examples, "emissions_direct_input_hrd_data.csv"
#' ))
#' manure_management_system_fraction_dt <- data.table::fread(file.path(
#'   path_run_modules_examples, "manure_management_system_fraction.csv"
#' ))
#' manure_management_system_factors_dt <- data.table::fread(file.path(
#'   path_run_modules_examples, "manure_management_system_factors.csv"
#' ))
#'
#' results <- run_emissions_direct(
#'   has_herd_structure = TRUE,
#'   cohort_level_data = emissions_direct_input_chrt_structure_ration_quality_dt,
#'   herd_level_data = emissions_direct_input_hrd_dt,
#'   manure_management_system_fraction = manure_management_system_fraction_dt,
#'   manure_management_system_factors = manure_management_system_factors_dt,
#'   simulation_duration = 365,
#'   global_warming_potential_set = "AR6"
#' )
#' print(results$cohort_level_results)
#' print(results$herd_level_results)
#' }
#'
#' @export
run_emissions_direct <- function(
    has_herd_structure = FALSE,
    cohort_level_data,
    herd_level_data,
    feed_rations = NULL,
    feed_params = NULL,
    manure_management_system_fraction,
    manure_management_system_factors,
    simulation_duration = 365,
    global_warming_potential_set = "AR6",
    show_indicator = TRUE,
    emission_factors_only = FALSE
) {

  # --- Step 1: Validate inputs ------------------------------------------------
  validate_run_emissions_direct_inputs(
    has_herd_structure = has_herd_structure,
    cohort_level_data = cohort_level_data,
    herd_level_data = herd_level_data,
    feed_rations = feed_rations,
    feed_params = feed_params,
    manure_management_system_fraction = manure_management_system_fraction,
    manure_management_system_factors = manure_management_system_factors,
    simulation_duration = simulation_duration,
    global_warming_potential_set = global_warming_potential_set,
    emission_factors_only = emission_factors_only
  )

  # Show progress indicator if requested
  if (show_indicator) {
    cli::cli_h1("\U1F552 Running GLEAM direct emissions pipeline\U2026")
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
    herd_level_data = gleam_hrd_data,
    show_indicator = show_indicator
  )

  gleam_chrt_data <- weights_results$cohort_level_results

  # --- Step 4: Calculate ration quality or retain primary inputs -------------
  if (!is.null(feed_rations)) {
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
  }

  # --- Step 5: Run energy requirements and DMI --------------------------------
  gleam_chrt_data <- run_metabolic_energy_req_module(
    cohort_level_data = gleam_chrt_data,
    herd_level_data = gleam_hrd_data,
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
    herd_level_data = gleam_hrd_data,
    show_indicator = show_indicator
  )

  # --- Step 8: Run direct emissions from manure management systems ------------
  gleam_chrt_data <- run_emissions_manure_module(
    cohort_level_data = gleam_chrt_data,
    manure_management_system_fraction = manure_management_system_fraction,
    manure_management_system_factors = manure_management_system_factors,
    show_indicator = show_indicator
  )

  allocation_long <- NULL
  aggregation_results <- NULL
  if (!emission_factors_only) {
    # --- Step 9: Run production (milk, fibre, meat) at cohort level -----------
    gleam_chrt_data <- run_production_module(
      cohort_level_data = gleam_chrt_data,
      herd_level_data = gleam_hrd_data,
      simulation_duration = simulation_duration,
      show_indicator = show_indicator
    )

    # --- Step 10: Run allocation -------------------------------------------
    allocation_results <- run_allocation_module(
      cohort_level_data = gleam_chrt_data,
      herd_level_data = gleam_hrd_data,
      simulation_duration = simulation_duration,
      show_indicator = show_indicator
    )
    gleam_chrt_data <- allocation_results$cohort_allocation_inputs
    allocation_long <- allocation_results$allocation_long

    # --- Step 11: Run aggregation (herd totals and emissions in CO2eq) -------
    aggregation_results <- run_aggregation_module(
      cohort_level_data = gleam_chrt_data,
      allocation_herd_long = allocation_long,
      simulation_duration = simulation_duration,
      global_warming_potential_set = global_warming_potential_set,
      show_indicator = show_indicator
    )
  }

  # Clear progress indicator if it was shown
  if (show_indicator) {
    cli::cli_status_clear()
    cli::cli_rule()
    cli::cli_alert_success("{.strong GLEAM direct emissions pipeline complete.}")
  }

  return(
    list(
      cohort_level_results = gleam_chrt_data,
      herd_level_results = gleam_hrd_data,
      allocation_long = allocation_long,
      aggregation_results = aggregation_results
    )
  )
}
