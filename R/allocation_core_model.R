#' Milk Energy Requirement for Allocation
#'
#' Calculates the net energy demand required to produce total fat-protein-corrected milk (FPCM) over a defined assessment period.
#'
#' @param milk_production_fpcm_cohort Numeric scalar. Total fat-protein-corrected milk (FPCM) produced over the assessment period  (kg/assessment period).
#' Default fat and protein content=0.04 and 0.033.
#'
#' @param milk_protein_fraction_standard Numeric. Standard protein content of milk, used to calculate fat-protein-corrected milk (FPCM), (kg protein/kg milk).
#' Default used=0.033.
#'
#' @param milk_fat_fraction_standard Numeric. Standard fat content of milk, used to calculate fat-protein-corrected milk (FPCM), (kg fat/kg milk).
#' Default used=0.04.
#'
#' @param milk_lactose_fraction_standard Numeric. Standard lactose content of milk, used to calculate fat-protein-corrected milk (FPCM) , (kg lactose/kg milk).
#' Default used=0.048.
#'
#' @return Numeric scalar. Energy required to produce total milk output over the assessment period (MJ/cohort/assessment period).
#'
#' Non-zero values are applicable only to milk-producing species (CTL, BFL, CML, SHP, GTS) and adult female cohorts (FA).
#' In the allocation workflow, non-milk-producing species or cohorts are assigned a value of 0 for this term.
#'
#' @details
#' This function provides the milk-related energy term used in a biophysical
#' allocation framework to apportion emissions between milk and other co-products
#' in multifunctional livestock production systems.
#'
#' The approach implements the IDF (2022) standard, adapted from Thoma and Nemecek (2020), and is consistent with
#' FAO LEAP livestock LCA guidelines (FAO, 2016a, 2016b, 2016c) and with ISO 14044:2006 (Section 4.3.4.2, Step 2).
#'
#' In accordance with ISO 14044:2006 (Section 4.3.4.2, Step 2), known processing or
#' biophysical relationships may be used to assign shared inputs and outputs of a
#' single production unit to individual products or sub-units. In livestock systems,
#' this includes apportioning shared feed and energy use according to physiological
#' energy requirements (e.g., net energy for lactation, growth, etc.). If the
#' resulting process remains multifunctional, these energy terms may subsequently
#' be used to derive allocation factors among co-products.
#'
#' The total energy required for milk production over the assessment period is calculated as:
#' \code{energy_allocation_milk = energy_standard * milk_production_fpcm_cohort}
#'
#' where:
#'
#' \itemize{
#'
#'   \item \code{energy_standard} is the energy content of standard milk,
#'   calculated internally based on standard fat, protein, and lactose contents
#'   following IDF (2022) (MJ/kg milk).
#'
#'   \item \code{milk_fpcm_output} is the total fat- and protein-corrected milk
#'   (FPCM) produced over the assessment period (kg/assessment period).
#' }
#'
#' @references
#' ISO. 2006. Environmental management — Life cycle assessment — Requirements and
#' guidelines (ISO 14044:2006). International Organization for Standardization, Geneva.
#'
#' IDF. 2022. The IDF Global Carbon Footprint Standard for the Dairy Sector.
#' Bulletin of the IDF No. 520/2022. International Dairy Federation, Brussels.
#'
#' Thoma, G., and T. Nemecek. 2020. Allocation between milk and meat in dairy LCA:
#' Critical discussion of the IDF’s standard methodology. Proceedings of the
#' 12th International Conference on Life Cycle Assessment of Food (LCAFood 2020),
#' pp. 83–89, 13–16 October, Berlin, Germany.
#'
#' FAO. 2016a. Environmental performance of large ruminant supply chains:
#' Guidelines for assessment. Livestock Environmental Assessment and Performance
#' (LEAP) Partnership. FAO, Rome, Italy.
#'
#' FAO. 2016b. Greenhouse gas emissions and fossil energy use from small ruminant
#' supply chains: Guidelines for assessment. Livestock Environmental Assessment
#' and Performance (LEAP) Partnership. FAO, Rome, Italy.
#'
#' FAO. 2016c. Greenhouse gas emissions and fossil energy use from poultry supply
#' chains: Guidelines for assessment. Livestock Environmental Assessment and
#' Performance (LEAP) Partnership. FAO, Rome, Italy.
#'
#' @export
calc_energy_allocation_milk <- function(
    milk_production_fpcm_cohort,
    milk_protein_fraction_standard,
    milk_fat_fraction_standard,
    milk_lactose_fraction_standard
) {
  validate_allocation_milk_inputs(
    milk_production_fpcm_cohort,
    milk_protein_fraction_standard,
    milk_fat_fraction_standard,
    milk_lactose_fraction_standard
  )

  # Calculate energy content of standard milk (MJ/kg milk)
  # Coefficients from IDF (2022): kcal per 100 g milk per 1% unit of fat/protein/lactose
  # Formula: (0.0929 * fat + 0.0547 * protein + 0.0395 * lactose) * 4.184 * 100
  energy_standard <- (
    0.0929 * milk_fat_fraction_standard +
      0.0547 * milk_protein_fraction_standard +
      0.0395 * milk_lactose_fraction_standard
  ) * 4.184 * 100

  # Total energy for milk production
  energy_allocation_milk <- energy_standard * milk_production_fpcm_cohort

  return(energy_allocation_milk)
}

#' Meat Energy Requirement for Allocation
#'
#' Calculates the net energy demand associated with meat production (expressed as
#' liveweight output) over the assessment period for a given species and cohort.
#'
#'
#' @param species_short Character. Code identifying the livestock species.
#'   Supported values include:
#'   \itemize{
#'     \item \code{PGS}: pigs
#'     \item \code{CML}: camels
#'     \item \code{CTL}: cattle
#'     \item \code{BFL}: buffalo
#'     \item \code{SHP}: sheep
#'     \item \code{GTS}: goats
#'   }
#' @param cohort_short Character scalar. Sex- and age-specific cohort code describing the
#'   production stage of the animals. Supported values include:
#'   \itemize{
#'     \item \code{FA}: adult females (from age at first parturition)
#'     \item \code{FS}: sub-adult females (from weaning to age at first parturition)
#'     \item \code{FJ}: juvenile females (from birth to weaning)
#'     \item \code{MA}: adult males (from age at first breeding)
#'     \item \code{MS}: sub-adult males (from weaning to age at first breeding)
#'     \item \code{MJ}: juvenile males (from birth to weaning)
#'   }
#' @param slaughter_weight_cohort Numeric scalar. Live weight at slaughter for animals removed from the cohort (kg).
#' @param birth_weight Numeric scalar. Live weight of the animal at birth (kg).
#' @param meat_production_live_weight_cohort Numeric. Total meat produced as live weight over the assessment period by cohort (kg/cohort/assessment period).
#' @param ratio_me_to_ne Numeric. Ratio of metabolizable energy to net energy (ME/NE). Used for CML.
#'
#' @return Numeric scalar. Energy required by a given sex–age cohort for total meat output by cohort over
#' the assessment period, equal to the energy needed to produce all live-weight gain to reach the target slaughter weight (MJ/cohort/assessment period).
#'
#' Non-zero values are applicable to all species/cohorts where growth is modelled. For
#' pigs (\code{PGS}), the function returns \code{NA} by design.
#'
#'
#' @details
#' This function provides the meat-related energy term used in a biophysical
#' allocation framework to apportion emissions between milk and other co-products
#' in multifunctional livestock production systems.
#'
#' The approach implements the IDF (2022) standard, adapted from Thoma and Nemecek (2020), and is consistent with
#' FAO LEAP livestock LCA guidelines (FAO, 2016a, 2016b, 2016c) and with ISO 14044:2006 (Section 4.3.4.2, Step 2).
#'
#' In accordance with ISO 14044:2006
#' (Section 4.3.4.2, Step 2), known processing or biophysical relationships may be
#' used to assign shared inputs and outputs of a single production unit to
#' individual products or sub-units. In livestock systems, this includes
#' apportioning shared feed and energy use according to physiological energy
#' requirements (e.g., net energy for lactation or growth). If the process
#' remains multifunctional after such assignment, the resulting energy terms
#' may be used to derive allocation factors among co-products.
#'
#' The objective of this function is to estimate the net
#' energy required to produce meat, as live-weight growth of animal slaughtered during the assessment period.
#' This is achieved by quantifying the physiological energy required for animals
#' to grow from birth weight to slaughter weight for each species and cohort.
#'
#' Total energy required for meat production over the assessment period is then
#' calculated as:
#'
#'\code{energy_allocation_meat = specific_energy_meat * meat_production_live_weight_cohort}
#'
#'
#' where
#'
#' \code{specific_energy_meat} is the average
#' net energy required to produce one kilogram of liveweight gain, accounting
#' for differences in growth efficiency, reflecting species and cohort specific growth characteristics (MJ/kg live weight).
#'
#' \code{meat_production_live_weight_cohort} is the total liveweight of
#' animals sold for meat during the assessment period, which is calculated with a species-specific approach:
#'
#' \itemize{
#'   \item \strong{For (\code{CTL}, \code{BFL}, \code{CML},
#'   \code{SHP}, \code{GTS})}:
#'
#'   Growth energy is calculated using species- and
#'   cohort-specific biophysical relationships adapted from established growth
#'   energy formulations (further details in \code{\link[gleam]{calc_net_energy_growth}}).
#'
#'   \item \strong{For (\code{PGS})}:
#'
#'   Growth energy is not calculated in this
#'   function and \code{NA} is returned. In downstream processing,
#'   \code{\link{calc_allocation_shares}} assigns 100% of the allocation to the
#'   edible meat commodity for pig systems.
#' }
#'
#' @references
#' ISO. 2006. Environmental management — Life cycle assessment — Requirements and
#' guidelines (ISO 14044:2006). International Organization for Standardization, Geneva.
#'
#' IDF. 2022. The IDF Global Carbon Footprint Standard for the Dairy Sector.
#' Bulletin of the IDF No. 520/2022. International Dairy Federation, Brussels.
#'
#' Thoma, G., and T. Nemecek. 2020. Allocation between milk and meat in dairy LCA:
#' Critical discussion of the IDF’s standard methodology. Proceedings of the
#' 12th International Conference on Life Cycle Assessment of Food (LCAFood 2020),
#' pp. 83–89, 13–16 October, Berlin, Germany.
#'
#' FAO. 2016a. Environmental performance of large ruminant supply chains:
#' Guidelines for assessment. Livestock Environmental Assessment and Performance
#' (LEAP) Partnership. FAO, Rome, Italy.
#'
#' FAO. 2016b. Greenhouse gas emissions and fossil energy use from small ruminant
#' supply chains: Guidelines for assessment. Livestock Environmental Assessment
#' and Performance (LEAP) Partnership. FAO, Rome, Italy.
#'
#' FAO. 2016c. Greenhouse gas emissions and fossil energy use from poultry supply
#' chains: Guidelines for assessment. Livestock Environmental Assessment and
#' Performance (LEAP) Partnership. FAO, Rome, Italy.
#'
#' @export
calc_energy_allocation_meat <- function(
    species_short,
    cohort_short,
    slaughter_weight_cohort,
    birth_weight,
    meat_production_live_weight_cohort,
    ratio_me_to_ne
) {
  validate_allocation_meat_inputs(
    species_short, cohort_short,
    slaughter_weight_cohort, birth_weight, meat_production_live_weight_cohort, ratio_me_to_ne
  )

  # Default fallback
  specific_energy_meat <- NA_real_

  # Check for valid weights
  if (is.na(species_short) || is.na(slaughter_weight_cohort) || is.na(birth_weight)) {
    energy_allocation_meat <- NA_real_
  } else if (species_short %in% c("CTL", "BFL")) {
    # Cattle and Buffalo: use growth efficiency factor based on cohort
    if (cohort_short %in% c("FA", "FS", "FJ")) {
      growth_efficiency_factor <- 0.8
    } else if (cohort_short %in% c("MA", "MS", "MJ")) {
      growth_efficiency_factor <- 1
    } else {
      growth_efficiency_factor <- NA_real_
    }
    if (!is.na(growth_efficiency_factor)) {
      specific_energy_meat <- (
        22.02 * (((slaughter_weight_cohort - birth_weight) / 2) /
                   (growth_efficiency_factor * slaughter_weight_cohort))^0.75 *
          (slaughter_weight_cohort - birth_weight)^1.097
      ) / slaughter_weight_cohort
    }

  } else if (species_short == "CML") {
    # Camelids: convert ME to NE using ratio_me_to_ne (ME/NE)
    specific_energy_meat <- (41.8 * (slaughter_weight_cohort - birth_weight) / slaughter_weight_cohort) / ratio_me_to_ne

  } else if (species_short == "SHP") {
    # Sheep: coefficients vary by cohort (female vs male)
    if (cohort_short %in% c("FA", "FS", "FJ")) {
      a <- 2.1
      b <- 0.45
    } else if (cohort_short %in% c("MA", "MS", "MJ")) {
      a <- 4.4
      b <- 0.32
    } else {
      a <- NA_real_
      b <- NA_real_
    }
    if (!is.na(a) && !is.na(b)) {
      specific_energy_meat <- (
        (slaughter_weight_cohort - birth_weight) *
          (a + 0.5 * b * (birth_weight + slaughter_weight_cohort))
      ) / slaughter_weight_cohort
    }

  } else if (species_short == "GTS") {
    # Goats: fixed coefficients
    a <- 5
    b <- 0.33
    specific_energy_meat <- (
      (slaughter_weight_cohort - birth_weight) *
        (a + 0.5 * b * (birth_weight + slaughter_weight_cohort))
    ) / slaughter_weight_cohort

  } else if (species_short == "PGS") {
    # Pigs: not calculated (returns 0)
    specific_energy_meat <- 0
  }

  # Multiply specific energy by meat output to get total energy allocation
  energy_allocation_meat <- specific_energy_meat * meat_production_live_weight_cohort

  return(energy_allocation_meat)
}

#' Fibre Energy Requirement for Allocation
#'
#' Calculates the net energy demand associated with fibre production over the
#' assessment period for fibre-producing species and cohorts.
#'
#' @param species_short Character. Code identifying the livestock species.
#'   Supported values include:
#'   \itemize{
#'     \item \code{PGS}: pigs
#'     \item \code{CML}: camels
#'     \item \code{CTL}: cattle
#'     \item \code{BFL}: buffalo
#'     \item \code{SHP}: sheep
#'     \item \code{GTS}: goats
#'   }
#' @param cohort_stock_size Numeric. Population size in the cohort at the start of the assessment period (heads).
#' @param energy_requirement_fibre_production Numeric. Energy required for the synthesis of fibre for SHP, GTS and CML. Assumed to be 0 for other species. (MJ/head/day). Expressed as net energy for SHP and GTS and as metabolizable energy for CML (MJ/head/day).
#' @param ratio_me_to_ne Numeric. Ratio of metabolizable energy to net energy (ME/NE). Used for CML.
#' @param simulation_duration Numeric. Length of the assessment period (days).
#'
#' @return Numeric scalar. Energy required to produce all fibre output by cohort (MJ/cohort/assessment period).
#'
#' Non-zero values are expected only for fibre-producing species (CML, SHP, GTS) and applicable cohorts ("FA", "FS", "MA", "MS")
#'
#' @details
#' This function provides the fibre-related energy term used in a biophysical
#' allocation framework to apportion emissions between milk and other co-products
#' in multifunctional livestock production systems.
#'
#' The approach implements the IDF (2022) standard, adapted from Thoma and Nemecek (2020), and is consistent with
#' FAO LEAP livestock LCA guidelines (FAO, 2016a, 2016b, 2016c) and with ISO 14044:2006 (Section 4.3.4.2, Step 2).
#'
#' In accordance with ISO 14044:2006 (Section 4.3.4.2, Step 2), known processing or
#' biophysical relationships may be used to assign shared inputs and outputs of a
#' single production unit to individual products or sub-units. In livestock systems,
#' this includes apportioning shared feed and energy use according to physiological
#' energy requirements (e.g., net energy for lactation, growth, etc.). If the
#' resulting process remains multifunctional, these energy terms may subsequently
#' be used to derive allocation factors among co-products.
#'
#'
#' Total fibre-related energy over the assessment period is computed for
#' fibre-producing species (\code{CML}, \code{SHP},
#' \code{GTS}) and applicable cohorts (\code{"FA"}, \code{"FS"}, \code{"MA"},
#' \code{"MS"}).
#'
#' The fibre-related energy over the assessment period is calculated as:
#'
#' \itemize{
#'   \item For sheep (\code{SHP}) and goats (\code{GTS}):
#'
#'   \code{energy_allocation_fibre =
#'   fibre_energy_requirement * assessment_duration * size}
#'
#'   \item For camels (\code{CML}):
#'
#'   \code{energy_allocation_fibre =
#'   fibre_energy_requirement * ratio_me_to_ne * assessment_duration * size}
#'
#'
#' }
#'
#' where \code{fibre_energy_requirement} represents the daily energy requirement
#' for fibre production (MJ/head/day) and is obtained from
#' \code{\link[gleam]{calc_net_energy_fibre}}.
#'
#' @references
#' ISO. 2006. Environmental management — Life cycle assessment — Requirements and
#' guidelines (ISO 14044:2006). International Organization for Standardization, Geneva.
#'
#' IDF. 2022. The IDF Global Carbon Footprint Standard for the Dairy Sector.
#' Bulletin of the IDF No. 520/2022. International Dairy Federation, Brussels.
#'
#' Thoma, G., and T. Nemecek. 2020. Allocation between milk and meat in dairy LCA:
#' Critical discussion of the IDF’s standard methodology. Proceedings of the
#' 12th International Conference on Life Cycle Assessment of Food (LCAFood 2020),
#' pp. 83–89, 13–16 October, Berlin, Germany.
#'
#' FAO. 2016a. Environmental performance of large ruminant supply chains:
#' Guidelines for assessment. Livestock Environmental Assessment and Performance
#' (LEAP) Partnership. FAO, Rome, Italy.
#'
#' FAO. 2016b. Greenhouse gas emissions and fossil energy use from small ruminant
#' supply chains: Guidelines for assessment. Livestock Environmental Assessment
#' and Performance (LEAP) Partnership. FAO, Rome, Italy.
#'
#' FAO. 2016c. Greenhouse gas emissions and fossil energy use from poultry supply
#' chains: Guidelines for assessment. Livestock Environmental Assessment and
#' Performance (LEAP) Partnership. FAO, Rome, Italy.
#'
#' @export
calc_energy_allocation_fibre <- function(
    species_short,
    cohort_stock_size,
    energy_requirement_fibre_production,
    ratio_me_to_ne,
    simulation_duration
) {
  validate_allocation_fibre_inputs(
    species_short, cohort_stock_size,
    energy_requirement_fibre_production, ratio_me_to_ne, simulation_duration
  )

  if (species_short %in% c("GTS", "SHP")) {
    # Sheep and goats: direct NE calculation
    energy_allocation_fibre <- energy_requirement_fibre_production * simulation_duration * cohort_stock_size
  } else if (species_short == "CML") {
    # Camelids: convert ME to NE using ratio_me_to_ne (ME/NE)
    energy_allocation_fibre <- (energy_requirement_fibre_production / ratio_me_to_ne) * simulation_duration * cohort_stock_size
  } else {
    # Other species: no fibre production
    energy_allocation_fibre <- 0
  }

  return(energy_allocation_fibre)
}

#' Work Energy Requirement for Allocation
#'
#' Calculates the net energy demand associated with animal work over the
#' assessment period for animals involved in draught power generation.
#'
#' @param species_short Character. Code identifying the livestock species.
#'   Supported values include:
#'   \itemize{
#'     \item \code{PGS}: pigs
#'     \item \code{CML}: camels
#'     \item \code{CTL}: cattle
#'     \item \code{BFL}: buffalo
#'     \item \code{SHP}: sheep
#'     \item \code{GTS}: goats
#'   }
#' @param cohort_stock_size Numeric. Population size in the cohort at the start of the assessment period (heads).
#' @param energy_requirement_work Numeric. Energy required for work/draught power for CTL, BFL and CML. Assumed to be 0 for other species. (MJ/head/day). Expressed as net energy for CTL and BFL and as metabolizable energy for CML (MJ/head/day).
#' @param ratio_me_to_ne Numeric. Ratio of metabolizable energy to net energy (ME/NE). Used for CML.
#' @param simulation_duration Numeric. Length of the assessment period (days).
#'
#' @return Numeric scalar. Energy required to provide all draught power (traction/work) over the assessment period (MJ/cohort/assessment period).
#'
#' Non-zero values are expected only for draught or work-producing species (CTL, BFL CML) and applicable cohorts (MA).
#'
#' @details
#' This function provides the work-related energy term used in a biophysical
#' allocation framework to apportion emissions between milk and other co-products
#' in multifunctional livestock production systems.
#'
#' The approach implements the IDF (2022) standard, adapted from Thoma and Nemecek (2020), and is consistent with
#' FAO LEAP livestock LCA guidelines (FAO, 2016a, 2016b, 2016c) and with ISO 14044:2006 (Section 4.3.4.2, Step 2).
#'
#' In accordance with ISO 14044:2006 (Section 4.3.4.2, Step 2), known processing or
#' biophysical relationships may be used to assign shared inputs and outputs of a
#' single production unit to individual products or sub-units. In livestock systems,
#' this includes apportioning shared feed and energy use according to physiological
#' energy requirements (e.g., net energy for lactation, growth..etc.). If the
#' resulting process remains multifunctional, these energy terms may subsequently
#' be used to derive allocation factors among co-products.
#'
#' Total work-related energy is computed for species (\code{CTL}, \code{BFL}, \code{CML})
#' and cohorts (\code{MA}) assumed to be potentially involved in draught power generation, and
#' is calculated as follows:
#'
#' \itemize{
#'   \item \code{energy_allocation_work = work_energy_requirement * assessment_duration * size}
#' }
#'
#' where \code{work_energy_requirement} represents the daily energy requirement for
#' animal work (MJ/head/day) and is obtained from
#' \code{\link[gleam]{calc_net_energy_work}}.
#'
#' @references
#' ISO. 2006. Environmental management — Life cycle assessment — Requirements and
#' guidelines (ISO 14044:2006). International Organization for Standardization, Geneva.
#'
#' IDF. 2022. The IDF Global Carbon Footprint Standard for the Dairy Sector.
#' Bulletin of the IDF No. 520/2022. International Dairy Federation, Brussels.
#'
#' Thoma, G., and T. Nemecek. 2020. Allocation between milk and meat in dairy LCA:
#' Critical discussion of the IDF’s standard methodology. Proceedings of the
#' 12th International Conference on Life Cycle Assessment of Food (LCAFood 2020),
#' pp. 83–89, 13–16 October, Berlin, Germany.
#'
#' FAO. 2016a. Environmental performance of large ruminant supply chains:
#' Guidelines for assessment. Livestock Environmental Assessment and Performance
#' (LEAP) Partnership. FAO, Rome, Italy.
#'
#' FAO. 2016b. Greenhouse gas emissions and fossil energy use from small ruminant
#' supply chains: Guidelines for assessment. Livestock Environmental Assessment
#' and Performance (LEAP) Partnership. FAO, Rome, Italy.
#'
#' FAO. 2016c. Greenhouse gas emissions and fossil energy use from poultry supply
#' chains: Guidelines for assessment. Livestock Environmental Assessment and
#' Performance (LEAP) Partnership. FAO, Rome, Italy.
#'
#' @export
calc_energy_allocation_work <- function(
    species_short,
    cohort_stock_size,
    energy_requirement_work,
    ratio_me_to_ne,
    simulation_duration
) {
  validate_allocation_work_inputs(
    species_short, cohort_stock_size, energy_requirement_work, ratio_me_to_ne, simulation_duration
  )

  if (species_short == "CML") {
    # Camelids: convert ME to NE using ratio_me_to_ne (ME/NE)
    energy_allocation_work <- (energy_requirement_work * simulation_duration * cohort_stock_size) / ratio_me_to_ne
  } else {
    # Other species: direct calculation
    energy_allocation_work <- energy_requirement_work * simulation_duration * cohort_stock_size
  }

  return(energy_allocation_work)
}

#' Aggregate Cohort-Level Data to Herd-Level
#'
#' This function aggregates a dataset from cohort level to herd level by summing
#' specified variables over the defined 'id' columns.
#'
#' @param data_cohort A `data.table` at cohort-level containing energy allocation variables and herd identifiers. Each row corresponds to a single sex–age cohort within a herd.
#' @param id_cols Character. Unique identifier for the herd, repeated for each cohort belonging to the same herd.
#' @param vars_to_sum Character vector. Names of numeric cohort-level variables to be summed across cohorts to produce herd-level totals (e.g., energy_allocation_meat, energy_allocation_milk, energy_allocation_fibre, energy_allocation_work, energy_allocation_eggs).
#' @param cohort_short Character. Name of the column identifying the sex–age cohort (e.g. FJ, FA, MJ, etc.).
#'
#' @return A `data.table` at herd scale, in which selected cohort-level variables have been summed across all cohorts belonging to the same herd, as defined by id_herd.
#' @export
aggregate_cohort_to_herd <- function(
    data_cohort,
    id_cols,
    vars_to_sum,
    cohort_short
) {

  # Aggregate over cohorts
  data_herd <- data_cohort[
    ,
    lapply(.SD, sum),
    by = id_cols,
    .SDcols = vars_to_sum
  ]

  # Add cohort_short = "ALL"
  data_herd[
    ,
    (cohort_short) := "ALL"
  ]

  return(data_herd)
}

#' Calculate Energy Allocation Shares for Livestock Commodities
#'
#' Calculates biophysical allocation fractions for commodities (meat, milk, fibre, work,
#' eggs) based on their total energy requirements.
#'
#' @param species_short Character. Code identifying the livestock species.
#'   Supported values include:
#'   \itemize{
#'     \item \code{PGS}: pigs
#'     \item \code{CML}: camels
#'     \item \code{CTL}: cattle
#'     \item \code{BFL}: buffalo
#'     \item \code{SHP}: sheep
#'     \item \code{GTS}: goats
#'   }
#' @param energy_allocation_meat Numeric. Energy required by a given sex–age cohort for total meat output by cohort during the assessment period, equal to the energy needed to produce all live-weight gain to reach the target slaughter weight (MJ/cohort/assessment period).
#' @param energy_allocation_milk Numeric. Energy required to produce total milk output by cohort (MJ/cohort/assessment period). Non-zero values are applicable only to milk-producing species and cohorts (species=CTL, BFL, CML, SHP, GTS; cohorts=AF). All other species–cohort combinations are assigned a value of 0.
#' @param energy_allocation_fibre Numeric. Energy required to produce all fibre output by cohort (MJ/cohort/assessment period).
#' @param energy_allocation_work Numeric vector. Energy required to provide all draught power (traction/work) by cohort (MJ/cohort/assessment period).
#' @param energy_allocation_eggs Numeric vector. Energy required to produce all eggs during the assessment period (MJ/cohort/assessment period).
#'
#' @return A named list of numeric vectors with same length as input, containing:
#' \describe{
#'   \item{allocation_share_meat}{Numeric. Allocation share assigned to meat (fraction).}
#'   \item{allocation_share_milk}{Numeric. Allocation share assigned to milk (fraction).}
#'   \item{allocation_share_fibre}{Numeric. Allocation share assigned to fibre (fraction).}
#'   \item{allocation_share_work}{Numeric. Allocation share assigned to work (fraction).}
#'   \item{allocation_share_eggs}{Numeric. Allocation share assigned to eggs (fraction).}
#' }
#'
#'
#' @details
#' These fractions represent the proportions of total environmental burdens (e.g., GHG
#' emissions) that will be allocated to each commodity in subsequent steps of the
#' assessment.
#'
#' The biophysical approach follows the IDF Global Carbon Footprint Standard for the
#' Dairy Sector (IDF, 2022), adapted from Thoma and Nemecek (2020), and is consistent
#' with FAO LEAP livestock LCA guidelines (FAO, 2016a, 2016b, 2016c). It aligns with
#' ISO 14044:2006 (Section 4.3.4.2, Step 2) by using underlying physical (energy-based)
#' relationships to assign shared inputs and outputs in multifunctional livestock
#' production systems.
#'
#' In accordance with ISO 14044:2006 (Section 4.3.4.2, Step 2), known processing or
#' biophysical relationships may be used to assign shared inputs and outputs of a
#' single production unit to individual products or sub-units. In livestock systems,
#' this includes apportioning shared feed and energy use according to physiological
#' energy requirements (e.g., net energy for lactation, growth..etc.). If the
#' resulting process remains multifunctional, these energy terms may subsequently
#' be used to derive allocation factors among co-products.
#'
#' This function calculates biophysical allocation
#' fractions for commodities (meat, milk, fibre, work, eggs) for all species.
#'
#' \strong{Pig systems (\code{PGS}).} For pigs, allocation is not based on energy
#' partitioning because pig production is treated as functionally single-output
#' (edible meat). Consequently, 100% of the allocation is assigned to the meat
#' commodity (meat share = 1; all other commodity shares = 0), independent of the
#' energy inputs.
#'
#'
#' @references
#' ISO. 2006. Environmental management — Life cycle assessment — Requirements and
#' guidelines (ISO 14044:2006). International Organization for Standardization, Geneva.
#'
#' IDF. 2022. The IDF Global Carbon Footprint Standard for the Dairy Sector.
#' Bulletin of the IDF No. 520/2022. International Dairy Federation, Brussels.
#'
#' Thoma, G., and T. Nemecek. 2020. Allocation between milk and meat in dairy LCA:
#' Critical discussion of the IDF’s standard methodology. Proceedings of the
#' 12th International Conference on Life Cycle Assessment of Food (LCAFood 2020),
#' pp. 83–89, 13–16 October, Berlin, Germany.
#'
#' FAO. 2016a. Environmental performance of large ruminant supply chains:
#' Guidelines for assessment. Livestock Environmental Assessment and Performance
#' (LEAP) Partnership. FAO, Rome, Italy.
#'
#' FAO. 2016b. Greenhouse gas emissions and fossil energy use from small ruminant
#' supply chains: Guidelines for assessment. Livestock Environmental Assessment
#' and Performance (LEAP) Partnership. FAO, Rome, Italy.
#'
#' FAO. 2016c. Greenhouse gas emissions and fossil energy use from poultry supply
#' chains: Guidelines for assessment. Livestock Environmental Assessment and
#' Performance (LEAP) Partnership. FAO, Rome, Italy.
#'
#' @export
#'
calc_allocation_shares <- function(
    species_short,
    energy_allocation_meat,
    energy_allocation_milk,
    energy_allocation_fibre,
    energy_allocation_work,
    energy_allocation_eggs
) {

  total_energy <- sum(
    c(energy_allocation_meat,
      energy_allocation_milk,
      energy_allocation_fibre,
      energy_allocation_work,
      energy_allocation_eggs),
    na.rm = TRUE
  )

  if (species_short == "PGS") {
    allocation_share_meat <- 1
    allocation_share_milk <- 0
    allocation_share_fibre <- 0
    allocation_share_work <- 0
    allocation_share_eggs <- 0
  } else {
    allocation_share_meat <- ifelse(
      is.na(energy_allocation_meat), 0, energy_allocation_meat / total_energy
    )
    allocation_share_milk <- ifelse(
      is.na(energy_allocation_milk), 0, energy_allocation_milk / total_energy
    )
    allocation_share_fibre <- ifelse(
      is.na(energy_allocation_fibre), 0, energy_allocation_fibre / total_energy
    )
    allocation_share_work <- ifelse(
      is.na(energy_allocation_work), 0, energy_allocation_work / total_energy
    )
    allocation_share_eggs <- ifelse(
      is.na(energy_allocation_eggs), 0, energy_allocation_eggs / total_energy
    )

  }

  return(
    list(
      allocation_share_meat = allocation_share_meat,
      allocation_share_milk = allocation_share_milk,
      allocation_share_fibre = allocation_share_fibre,
      allocation_share_work = allocation_share_work,
      allocation_share_eggs = allocation_share_eggs
    )
  )
}


#' Assign Allocation Shares to Emission Variables by Commodity
#'
#' This function operationalizes commodity-level allocation of emissions by combining each commodity with each emission source
#' and applying predefined allocation rules.
#'
#' The function enforces the allocation of emissions from manure burned as fuel and deposited on pasture
#' to be **100% to the commodity "Other"**.
#'
#' @param allocation_herd_long A `data.table` containing a commodity column (levels=Eggs, Milk, Meat, Work, Fibre..) and an allocation share column.
#' @param emissions_vars Character vector. Names of emission variables to which allocation should be applied (e.g., "ch4_enteric","ch4_manure_pasture","ch4_manure_burned","ch4_manure_other",         "direct_n2o_manure_pasture","direct_n2o_manure_burned","direct_n2o_manure_other", "indirect_n2o_manure_burned","indirect_n2o_manure_pasture","indirect_n2o_manure_other")
#' @param commodities Character vector. List of commodity categories to which emissions may be allocated. List=c("Other","Milk","Meat","Fibre","Work","Eggs")
#' @param excluded_vars Character vector. Emission variables that should not be allocated across commodities, even if they appear in emissions_vars ( e.g., "ch4_manure_pasture","ch4_manure_burned").
#' @param commodity_col Character. Name of the column in `allocation_herd_long` identifying the commodity category.
#' @param allocation_col Character. Name of the column in `allocation_herd_long` containing the allocation share to be applied.
#'
#' @return A `data.table` equal to `allocation_herd_long` expanded over all `emissions_vars`,
#' with enforced allocation rules:
#' \describe{
#'   \item{Excluded emission variables}{`allocation_col = 1` when `commodity_col == "Other"`, else `0`.}
#'   \item{Non-excluded emission variables}{`allocation_col = 0` when `commodity_col == "Other"` (others unchanged).}
#' }
#'
#'@details
#'
#' Emission variables listed in \code{excluded_vars} (e.g., emissions from manure
#' burned as fuel or manure deposited on pasture) are treated as not attributable
#' to edible livestock commodities under the chosen goal and scope. Consequently,
#' these emissions are allocated entirely to the residual commodity category
#' \code{"Other"} and are not distributed across milk, meat, fibre, work, or egg
#' outputs.
#'
#' The following methodological rules apply to emission variables listed in
#' \code{excluded_vars}:
#'
#' \itemize{
#'   \item \strong{Manure burned for fuel} — Emissions are considered outside the
#'   life cycle assessment system boundaries under the defined goal and scope and
#'   are therefore not attributed to edible livestock commodities. A cut-off
#'   approach is applied, consistent with the IDF (2022) standard and LEAP guidelines (LEAP 2016a, 2016b, 2016c).
#'
#'   \item \strong{Manure deposited on pasture or grassland} — Emissions are not
#'   allocated to edible livestock commodities in order to avoid double counting.
#'   When upstream feed production is included in the inventory, emission factors of feed items
#'   already account for this source.
#' }
#'
#' @references
#'
#' IDF. 2022. The IDF Global Carbon Footprint Standard for the Dairy Sector.
#' Bulletin of the IDF No. 520/2022. International Dairy Federation, Brussels.
#'
#' FAO. 2016a. Environmental performance of large ruminant supply chains:
#' Guidelines for assessment. Livestock Environmental Assessment and Performance
#' (LEAP) Partnership. FAO, Rome, Italy.
#'
#' FAO. 2016b. Greenhouse gas emissions and fossil energy use from small ruminant
#' supply chains: Guidelines for assessment. Livestock Environmental Assessment
#' and Performance (LEAP) Partnership. FAO, Rome, Italy.
#'
#' FAO. 2016c. Greenhouse gas emissions and fossil energy use from poultry supply
#' chains: Guidelines for assessment. Livestock Environmental Assessment and
#' Performance (LEAP) Partnership. FAO, Rome, Italy.
#'
#' @export
assign_allocation_to_emissions <- function(
    allocation_herd_long,
    emissions_vars,
    commodities,
    excluded_vars,
    commodity_col,
    allocation_col
) {
  # 1) All combinations: commodity x emission variable
  grid <- data.table::CJ(
    variable_name  = emissions_vars,
    commodity_name = commodities,
    unique = TRUE
  )

  # 2) Expand allocation table by emission variables (many-to-many: herds × emission vars)
  allocation_herd_long <- merge(
    allocation_herd_long,
    grid,
    by = commodity_col,
    allow.cartesian = TRUE
  )

  # 3) Excluded vars → 100% to Other, 0% to others
  allocation_herd_long[
    variable_name %in% excluded_vars & get(commodity_col) == "Other",
    (allocation_col) := 1
  ]
  allocation_herd_long[
    variable_name %in% excluded_vars & get(commodity_col) != "Other",
    (allocation_col) := 0
  ]

  # 4) Non-excluded vars → Other = 0
  allocation_herd_long[
    !(variable_name %in% excluded_vars) & get(commodity_col) == "Other",
    (allocation_col) := 0
  ]

  return(allocation_herd_long)
}
