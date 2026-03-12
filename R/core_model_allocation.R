#' Milk Energy Requirement for Allocation
#'
#' Computes the energy required for milk production over the assessment period
#' (MJ/cohort/assessment period), based on total fat- and protein-corrected milk
#' (FPCM) produced by the cohort.
#'
#' @param milk_production_fpcm_cohort Numeric. Total fat-protein-corrected milk (FPCM) produced over the assessment
#' period (kg/cohort/assessment period).
#' Suggested standard fat, protein and lactose contents are 0.04, 0.033, and 0.048 respectively.
#' @param milk_protein_fraction_standard Numeric. Standard protein content of milk, used to calculate
#' Fat-protein-corrected milk (FPCM), (kg protein/kg milk).
#' Suggested value = 0.033.
#' @param milk_fat_fraction_standard Numeric. Standard fat content of milk, used to calculate Fat-protein-corrected milk
#' (FPCM), (kg fat/kg milk).
#' Suggested value = 0.04.
#' @param milk_lactose_fraction_standard Numeric. Standard lactose content of milk, used to calculate
#' Fat-protein-corrected milk (FPCM) , (kg lactose/kg milk).
#' Suggested value = 0.048.
#'
#' @return Numeric. Energy required to produce total milk output by cohort (MJ/cohort/assessment period).
#' Non-zero values are applicable only to milk-producing species and cohorts (species = CTL, BFL, CML, SHP, GTS;
#' cohorts=FA).
#' All other species–cohort combinations are assigned a value of 0.
#'
#' @details
#' This function provides the milk-related energy term used in a biophysical
#' allocation framework to apportion emissions between milk and other co-products
#' in multifunctional livestock production systems.
#'
#' The approach implements the IDF (2022) standard, adapted from Thoma and Nemecek (2020), and is consistent with
#' FAO LEAP livestock LCA guidelines (FAO, 2016a, 2016b, 2016c) and with ISO 14044:2006 (Section 4.3.4.2, Step 2).
#'
#' In accordance with ISO 14044:2006, known biophysical relationships may be used
#' to assign shared inputs and outputs of a production system to individual
#' products or sub-units. In livestock systems, this includes apportioning shared
#' feed and energy use according to physiological energy requirements such as
#' lactation, growth, and maintenance. If the resulting process remains
#' multifunctional, these energy terms may subsequently be used to derive
#' allocation factors among co-products.
#'
#' The \code{milk_allocation_energy} is calculated as follows:
#'
#' \eqn{energy\_allocation\_milk = energy\_standard \times milk\_production\_fpcm\_cohort}
#'
#' where:
#'
#' \itemize{
#'
#'   \item \code{energy_standard} is the energy content of standard milk,
#'   calculated internally based on standard fat, protein, and lactose contents
#'   following IDF (2022) (MJ/kg milk).
#'
#'   \item \code{milk_production_fpcm_cohort} is the total fat- and protein-corrected milk
#'   (FPCM) produced over the assessment period (kg/assessment period). It can be computed using \code{\link{calc_milk_production}}
#'   (see also \code{\link{run_production_module}}).
#'
#' }
#'
#' @references
#' ISO. (2006). \emph{Environmental management — Life cycle assessment —
#' Requirements and guidelines (ISO 14044:2006)}. International Organization for
#' Standardization, Geneva.
#'
#' IDF. (2022). \emph{The IDF Global Carbon Footprint Standard for the Dairy
#' Sector}. Bulletin of the IDF No. 520/2022. International Dairy Federation,
#' Brussels.
#'
#' Thoma, G., and Nemecek, T. (2020). Allocation between milk and meat in dairy
#' LCA: Critical discussion of the IDF’s standard methodology. In
#' \emph{Proceedings of the 12th International Conference on Life Cycle Assessment
#' of Food (LCAFood 2020)} (pp. 83--89), 13--16 October, Berlin, Germany.
#'
#' FAO. (2016a). \emph{Environmental performance of large ruminant supply chains:
#' Guidelines for assessment}. Livestock Environmental Assessment and Performance
#' (LEAP) Partnership. FAO, Rome, Italy.
#'
#' FAO. (2016b). \emph{Greenhouse gas emissions and fossil energy use from small
#' ruminant supply chains: Guidelines for assessment}. Livestock Environmental
#' Assessment and Performance (LEAP) Partnership. FAO, Rome, Italy.
#'
#' FAO. (2016c). \emph{Greenhouse gas emissions and fossil energy use from poultry
#' supply chains: Guidelines for assessment}. Livestock Environmental Assessment
#' and Performance (LEAP) Partnership. FAO, Rome, Italy.
#'
#' @seealso
#' \code{\link{calc_milk_production}},
#' \code{\link{run_production_module}}
#'
#' @export
calc_milk_allocation_energy <- function(
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
  # Apply IDF coefficients to fat, protein, and lactose components.
  energy_standard <- (
    0.0929 * milk_fat_fraction_standard +
      0.0547 * milk_protein_fraction_standard +
      0.0395 * milk_lactose_fraction_standard
  ) * 4.184 * 100

  # Total energy for milk production
  milk_allocation_energy <- energy_standard * milk_production_fpcm_cohort

  return(milk_allocation_energy)
}

#' Meat Energy Requirement for Allocation
#'
#' Computes the energy required for meat production over the assessment period
#' (MJ/cohort/assessment period), based on total live weight produced by the
#' cohort.
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
#' @param cohort_short Character. Sex- and age-specific cohort code describing the
#'   production stage of the animals. Supported values include:
#'   \itemize{
#'     \item \code{FA}: adult females (from age at first parturition)
#'     \item \code{FS}: sub-adult females (from weaning to age at first parturition)
#'     \item \code{FJ}: juvenile females (from birth to weaning)
#'     \item \code{MA}: adult males (from age at first breeding)
#'     \item \code{MS}: sub-adult males (from weaning to age at first breeding)
#'     \item \code{MJ}: juvenile males (from birth to weaning)
#'   }
#' @param live_weight_cohort_at_slaughter Numeric. Live weight at slaughter for animals removed from the cohort (kg).
#' @param live_weight_at_birth Numeric. Live weight of the animal at birth (kg).
#' @param meat_production_live_weight_cohort Numeric. Total meat produced as live weight over the assessment period by
#' cohort (kg/cohort/assessment period).
#' @param ratio_me_to_ne Numeric. Ratio of metabolizable energy converted to net energy (fraction). Used for
#' species_short = CML.
#'
#' @return Numeric. Energy required by a given sex–age cohort for total meat output by cohort during the assessment
#' period,
#' equal to the energy needed to produce all live-weight gain to reach the target slaughter weight (MJ/cohort/assessment
#' period).
#' For pigs (\code{PGS}), the function returns \code{0} by design.
#'
#' @details
#' This function provides the meat-related energy term used in a biophysical
#' allocation framework to apportion emissions between milk and other co-products
#' in multifunctional livestock production systems.
#'
#' The approach implements the IDF (2022) standard, adapted from Thoma and Nemecek (2020), and is consistent with
#' FAO LEAP livestock LCA guidelines (FAO, 2016a, 2016b, 2016c) and with ISO 14044:2006 (Section 4.3.4.2, Step 2).
#'
#' In accordance with ISO 14044:2006, known biophysical relationships may be used
#' to assign shared inputs and outputs of a production system to individual
#' products or sub-units. In livestock systems, this includes apportioning shared
#' feed and energy use according to physiological energy requirements such as
#' growth, lactation, and maintenance. If the resulting process remains
#' multifunctional, these energy terms may subsequently be used to derive
#' allocation factors among co-products.
#'
#' The \code{meat_allocation_energy} is calculated as follows:
#'
#' \eqn{energy\_allocation\_meat = specific\_energy\_meat \times meat\_production\_live\_weight\_cohort}
#'
#' where
#' \itemize{
#'
#'   \item \code{specific_energy_meat} is the average energy required to produce
#'   one kilogram of live weight, accounting for species- and cohort-specific
#'   growth characteristics (MJ/kg live weight).
#'
#'   \item \code{meat_production_live_weight_cohort} is the total live weight of
#'   animals sold for meat over the assessment period. It can be computed using
#'   \code{\link{calc_meat_production}} (see also
#'   \code{\link{run_production_module}}).
#'   }
#'
#' \strong{Specific approaches by species:}
#'
#' \itemize{
#'   \item \strong{For \code{CTL}, \code{BFL}, \code{CML},
#'   \code{SHP}, \code{GTS}}:
#'
#'   Growth energy is calculated using species- and
#'   cohort-specific biophysical relationships adapted from established growth
#'   energy formulations (further details in \code{\link{calc_metabolic_energy_req_growth}}).
#'
#'   \item \strong{For \code{PGS}}:
#'
#'   Growth energy is not calculated in this
#'   function and \code{NA} is returned. In downstream processing,
#'   \code{\link{calc_allocation_shares}} assigns 100% of the allocation to the
#'   edible meat commodity for pig systems.
#' }
#'
#' @references
#' ISO. (2006). \emph{Environmental management — Life cycle assessment —
#' Requirements and guidelines (ISO 14044:2006)}. International Organization for
#' Standardization, Geneva.
#'
#' IDF. (2022). \emph{The IDF Global Carbon Footprint Standard for the Dairy
#' Sector}. Bulletin of the IDF No. 520/2022. International Dairy Federation,
#' Brussels.
#'
#' Thoma, G., and Nemecek, T. (2020). Allocation between milk and meat in dairy
#' LCA: Critical discussion of the IDF’s standard methodology. In
#' \emph{Proceedings of the 12th International Conference on Life Cycle Assessment
#' of Food (LCAFood 2020)} (pp. 83--89), 13--16 October, Berlin, Germany.
#'
#' FAO. (2016a). \emph{Environmental performance of large ruminant supply chains:
#' Guidelines for assessment}. Livestock Environmental Assessment and Performance
#' (LEAP) Partnership. FAO, Rome, Italy.
#'
#' FAO. (2016b). \emph{Greenhouse gas emissions and fossil energy use from small
#' ruminant supply chains: Guidelines for assessment}. Livestock Environmental
#' Assessment and Performance (LEAP) Partnership. FAO, Rome, Italy.
#'
#' FAO. (2016c). \emph{Greenhouse gas emissions and fossil energy use from poultry
#' supply chains: Guidelines for assessment}. Livestock Environmental Assessment
#' and Performance (LEAP) Partnership. FAO, Rome, Italy.
#'
#' @seealso
#' \code{\link{calc_meat_production}},
#' \code{\link{run_production_module}},
#' \code{\link{calc_allocation_shares}}
#'
#' @export
calc_meat_allocation_energy <- function(
    species_short,
    cohort_short,
    meat_production_live_weight_cohort,
    live_weight_cohort_at_slaughter = NA_real_,
    live_weight_at_birth = NA_real_,
    ratio_me_to_ne = NA_real_
) {
  validate_allocation_meat_inputs(
    species_short, cohort_short, meat_production_live_weight_cohort,
    live_weight_cohort_at_slaughter, live_weight_at_birth, ratio_me_to_ne
  )

  if (species_short %in% c("CTL", "BFL")) {
    # Cattle and Buffalo: use growth efficiency factor based on cohort
    growth_efficiency_factor <- if (cohort_short %in% gleam_cohorts_female) 0.8 else 1
    specific_energy_meat <- (
      22.02 * (((live_weight_cohort_at_slaughter - live_weight_at_birth) / 2) /
                 (growth_efficiency_factor * live_weight_cohort_at_slaughter))^0.75 *
        (live_weight_cohort_at_slaughter - live_weight_at_birth)^1.097
    ) / live_weight_cohort_at_slaughter

  } else if (species_short == "CML") {
    # Camelids: convert ME to NE using ratio_me_to_ne (ME/NE)
    specific_energy_meat <- (
      41.8 * (live_weight_cohort_at_slaughter - live_weight_at_birth) / live_weight_cohort_at_slaughter
    ) / ratio_me_to_ne

  } else if (species_short == "SHP") {
    # Sheep: coefficients vary by cohort (female vs male)
    if (cohort_short %in% gleam_cohorts_female) {
      a <- 2.1
      b <- 0.45
    } else {
      a <- 4.4
      b <- 0.32
    }

    specific_energy_meat <- (
      (live_weight_cohort_at_slaughter - live_weight_at_birth) *
        (a + 0.5 * b * (live_weight_at_birth + live_weight_cohort_at_slaughter))
    ) / live_weight_cohort_at_slaughter

  } else if (species_short == "GTS") {
    # Goats: fixed coefficients
    a <- 5
    b <- 0.33
    specific_energy_meat <- (
      (live_weight_cohort_at_slaughter - live_weight_at_birth) *
        (a + 0.5 * b * (live_weight_at_birth + live_weight_cohort_at_slaughter))
    ) / live_weight_cohort_at_slaughter
  } else if (species_short == "PGS") {
    # Pigs: not calculated (returns 0)
    return(0)
  }

  # Multiply specific energy by meat output to get total energy allocation
  meat_allocation_energy <- specific_energy_meat * meat_production_live_weight_cohort

  return(meat_allocation_energy)
}

#' Fibre Energy Requirement for Allocation
#'
#' Computes the energy required for fibre production over the assessment period
#' (MJ/cohort/assessment period), based on the daily energy requirement for fibre
#' production, cohort size, and assessment duration.
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
#' @param cohort_stock_size Numeric. Average population size in each of the 6 sex–age cohorts (# heads). (cohorts=FJ,
#' FS, FA, MJ, MS, MA).
#' @param metabolic_energy_req_fibre_production Numeric. Energy required for the synthesis of fibre for SHP, GTS and CML.
#' Assumed to be 0 for other species. (MJ/head/day). Expressed as net energy for SHP and GTS and as metabolizable energy
#' for CML.
#' @param ratio_me_to_ne Numeric. Ratio of metabolizable energy converted to net energy (fraction). Used for
#' species_short = CML.
#' @param simulation_duration Numeric. Length of the assessment period (days).
#'
#' @return Numeric. Energy required to produce all fibre output by cohort (MJ/cohort/assessment period).
#' Non-zero values are expected only for fibre-producing species (CML, SHP, GTS) and applicable cohorts ("FA", "FS",
#' "MA", "MS")
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
#' Total fibre-related energy over the assessment period is computed for
#' fibre-producing species (\code{CML}, \code{SHP},
#' \code{GTS}) and applicable cohorts (\code{"FA"}, \code{"FS"}, \code{"MA"},
#' \code{"MS"}).
#'
#' The \code{fibre_allocation_energy} is calculated as follows:
#'
#' \eqn{energy\_allocation\_fibre =
#' \frac{energy\_requirement\_fibre\_production}{ratio\_me\_to\_ne}
#' \times simulation\_duration \times cohort\_stock\_size}
#'
#' for camels (\code{CML}), and:
#'
#' \eqn{energy\_allocation\_fibre =
#' energy\_requirement\_fibre\_production \times simulation\_duration \times cohort\_stock\_size}
#'
#' for sheep (\code{SHP}) and goats (\code{GTS}).
#'
#' where \code{metabolic_energy_req_fibre_production} can be computed using
#'   \code{\link{calc_metabolic_energy_req_fibre}} (see also
#'   \code{\link{run_metabolic_energy_req_module}}).
#'
#' @seealso
#' \code{\link{calc_metabolic_energy_req_fibre}},
#' \code{\link{run_metabolic_energy_req_module}}
#'
#' @references
#' ISO. (2006). \emph{Environmental management — Life cycle assessment —
#' Requirements and guidelines (ISO 14044:2006)}. International Organization for
#' Standardization, Geneva.
#'
#' IDF. (2022). \emph{The IDF Global Carbon Footprint Standard for the Dairy
#' Sector}. Bulletin of the IDF No. 520/2022. International Dairy Federation,
#' Brussels.
#'
#' Thoma, G., and Nemecek, T. (2020). Allocation between milk and meat in dairy
#' LCA: Critical discussion of the IDF’s standard methodology. In
#' \emph{Proceedings of the 12th International Conference on Life Cycle Assessment
#' of Food (LCAFood 2020)} (pp. 83--89), 13--16 October, Berlin, Germany.
#'
#' FAO. (2016a). \emph{Environmental performance of large ruminant supply chains:
#' Guidelines for assessment}. Livestock Environmental Assessment and Performance
#' (LEAP) Partnership. FAO, Rome, Italy.
#'
#' FAO. (2016b). \emph{Greenhouse gas emissions and fossil energy use from small
#' ruminant supply chains: Guidelines for assessment}. Livestock Environmental
#' Assessment and Performance (LEAP) Partnership. FAO, Rome, Italy.
#'
#' FAO. (2016c). \emph{Greenhouse gas emissions and fossil energy use from poultry
#' supply chains: Guidelines for assessment}. Livestock Environmental Assessment
#' and Performance (LEAP) Partnership. FAO, Rome, Italy.
#'
#' @export
calc_fibre_allocation_energy <- function(
    species_short,
    cohort_stock_size = NA_real_,
    metabolic_energy_req_fibre_production = NA_real_,
    ratio_me_to_ne = NA_real_,
    simulation_duration = NA_real_
) {
  validate_allocation_fibre_inputs(
    species_short, cohort_stock_size,
    metabolic_energy_req_fibre_production, ratio_me_to_ne, simulation_duration
  )

  if (species_short %in% c("GTS", "SHP")) {
    # Sheep and goats: direct NE calculation
    fibre_allocation_energy <- metabolic_energy_req_fibre_production *
      simulation_duration * cohort_stock_size
  } else if (species_short == "CML") {
    # Camelids: convert ME to NE using ratio_me_to_ne (ME/NE)
    fibre_allocation_energy <- (metabolic_energy_req_fibre_production / ratio_me_to_ne) *
      simulation_duration * cohort_stock_size
  } else {
    # Other species: no fibre production
    fibre_allocation_energy <- 0
  }

  return(fibre_allocation_energy)
}

#' Work Energy Requirement for Allocation
#'
#' Computes the energy required for animal work over the assessment period
#' (MJ/cohort/assessment period), based on the daily energy requirement for work,
#' cohort size, and assessment duration.
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
#' @param metabolic_energy_req_work Numeric. Energy required for work, used to estimate the energy required for draught
#' power for CTL, BFL and CML. (MJ/head/day) Assumed to be 0 for other species. Expressed as net energy for CTL, BFL,
#' SHP, GTS and as metabolizable energy for CML and PGS.
#' @param ratio_me_to_ne Numeric. Ratio of metabolizable energy converted to net energy (fraction).
#' @param simulation_duration Numeric. Length of the assessment period (days).
#'
#' @return Numeric. Energy required to provide all draught power (traction/work) by cohort (MJ/cohort/assessment
#' period).
#' Non-zero values are expected only for draught or work-producing species (CTL, BFL CML).
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
#' and cohorts (, \code{FA}, \code{MA}) assumed to be potentially involved in draught power generation.
#'
#' The \code{work_allocation_energy} is calculated as follows:
#'
#' \eqn{energy\_allocation\_work =
#' energy\_requirement\_work \times simulation\_duration \times cohort\_stock\_size}
#'
#' for cattle (\code{CTL}) and buffalo (\code{BFL}), and:
#'
#' \eqn{energy\_allocation\_work =
#' \frac{energy\_requirement\_work \times simulation\_duration \times cohort\_stock\_size}
#' {ratio\_me\_to\_ne}}
#'
#' for camels (\code{CML}).
#'
#' where \code{metabolic_energy_req_work} can be computed using
#'   \code{\link{calc_metabolic_energy_req_work}} (see also
#'   \code{\link{run_metabolic_energy_req_module}}).
#'
#' @seealso
#' \code{\link{calc_metabolic_energy_req_work}},
#' \code{\link{run_metabolic_energy_req_module}}
#'
#' @references
#' ISO. (2006). \emph{Environmental management — Life cycle assessment —
#' Requirements and guidelines (ISO 14044:2006)}. International Organization for
#' Standardization, Geneva.
#'
#' IDF. (2022). \emph{The IDF Global Carbon Footprint Standard for the Dairy
#' Sector}. Bulletin of the IDF No. 520/2022. International Dairy Federation,
#' Brussels.
#'
#' Thoma, G., and Nemecek, T. (2020). Allocation between milk and meat in dairy
#' LCA: Critical discussion of the IDF’s standard methodology. In
#' \emph{Proceedings of the 12th International Conference on Life Cycle Assessment
#' of Food (LCAFood 2020)} (pp. 83--89), 13--16 October, Berlin, Germany.
#'
#' FAO. (2016a). \emph{Environmental performance of large ruminant supply chains:
#' Guidelines for assessment}. Livestock Environmental Assessment and Performance
#' (LEAP) Partnership. FAO, Rome, Italy.
#'
#' FAO. (2016b). \emph{Greenhouse gas emissions and fossil energy use from small
#' ruminant supply chains: Guidelines for assessment}. Livestock Environmental
#' Assessment and Performance (LEAP) Partnership. FAO, Rome, Italy.
#'
#' FAO. (2016c). \emph{Greenhouse gas emissions and fossil energy use from poultry
#' supply chains: Guidelines for assessment}. Livestock Environmental Assessment
#' and Performance (LEAP) Partnership. FAO, Rome, Italy.
#'
#' @export
calc_work_allocation_energy <- function(
    species_short,
    cohort_stock_size,
    metabolic_energy_req_work,
    simulation_duration,
    ratio_me_to_ne = NA_real_
) {
  validate_allocation_work_inputs(
    species_short,
    cohort_stock_size,
    metabolic_energy_req_work,
    simulation_duration,
    ratio_me_to_ne
  )

  if (species_short == "CML") {
    # Camelids: convert ME to NE using ratio_me_to_ne (ME/NE)
    work_allocation_energy <- (
      metabolic_energy_req_work * simulation_duration * cohort_stock_size
    ) / ratio_me_to_ne
  } else {
    # Other species: direct calculation
    work_allocation_energy <- metabolic_energy_req_work * simulation_duration * cohort_stock_size
  }

  return(work_allocation_energy)
}

#' Aggregate Cohort-Level Data to Herd-Level
#'
#' This function aggregates a dataset from cohort level to herd level by summing
#' specified variables over the defined 'id' columns.
#'
#' @param data_cohort Cohort-level dataset containing energy allocation variables and herd identifiers. Each row
#' corresponds to a single sex–age cohort within a herd.
#' @param id_cols Character. Unique identifier for the herd, repeated for each cohort belonging to the same herd.
#' @param vars_to_sum Character vector. Names of numeric cohort-level variables to be summed across cohorts to produce
#' herd-level totals (e.g., meat_allocation_energy, milk_allocation_energy, fibre_allocation_energy,
#' work_allocation_energy, egg_allocation_energy)
#' @param cohort_short Character. Sex- and age-specific cohort code describing the
#'   production stage of the animals. Supported values include:
#'   \itemize{
#'     \item \code{FA}: adult females (from age at first parturition)
#'     \item \code{FS}: sub-adult females (from weaning to age at first parturition)
#'     \item \code{FJ}: juvenile females (from birth to weaning)
#'     \item \code{MA}: adult males (from age at first breeding)
#'     \item \code{MS}: sub-adult males (from weaning to age at first breeding)
#'     \item \code{MJ}: juvenile males (from birth to weaning)
#'   }
#'
#' @return A `data.table` at herd scale, in which selected cohort-level variables have been summed across all cohorts
#' belonging to the same herd, as defined by id_herd.
#' @export
calc_cohort_to_herd_aggregation <- function(
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

  return(data_herd)
}

#' Calculate Energy Allocation shares for livestock commodities
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
#' @param meat_allocation_energy Numeric. Energy required by a given sex–age cohort for total meat output by cohort
#' during the assessment period, equal to the energy needed to produce all live-weight gain to reach the target
#' slaughter weight (MJ/cohort/assessment period).
#' @param milk_allocation_energy Numeric. Energy required to produce total milk output by cohort (MJ/cohort/assessment
#' period). Non-zero values are applicable only to milk-producing species and cohorts (species=CTL, BFL, CML, SHP, GTS;
#' cohorts=FA). All other species–cohort combinations are assigned a value of 0.
#' @param fibre_allocation_energy Numeric. Energy required to produce all fibre output by cohort (MJ/cohort/assessment
#' period).
#' @param work_allocation_energy Numeric vector. Energy required to provide all draught power (traction/work) by cohort
#' (MJ/cohort/assessment period).
#' @param egg_allocation_energy Numeric vector. Energy required to produce all eggs during the assessment period
#' (MJ/cohort/assessment period).
#'
#' @return A named list of numeric vectors with same length as input, containing:
#' \describe{
#'   \item{meat_share_allocation}{Numeric. Allocation share assigned to meat (fraction).}
#'   \item{milk_share_allocation}{Numeric. Allocation share assigned to milk (fraction).}
#'   \item{fibre_share_allocation}{Numeric. Allocation share assigned to fibre (fraction).}
#'   \item{work_share_allocation}{Numeric. Allocation share assigned to work (fraction).}
#'   \item{eggs_share_allocation}{Numeric. Allocation share assigned to eggs (fraction).}
#' }
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
#' This function calculates biophysical allocation fractions for commodities
#' (meat, milk, fibre, work, eggs) for all species. The allocation is based on
#' commodity-specific energy requirements calculated using
#' \code{\link{calc_meat_allocation_energy}},
#' \code{\link{calc_milk_allocation_energy}},
#' \code{\link{calc_fibre_allocation_energy}},
#' \code{\link{calc_work_allocation_energy}}, and
#' \code{calc_eggs_allocation_energy}.
#'
#' \strong{Pig systems (\code{PGS}).} For pigs, allocation is not based on energy
#' partitioning because pig production is treated as functionally single-output
#' (edible meat). Consequently, 100% of the allocation is assigned to the meat
#' commodity (meat share = 1; all other commodity shares = 0), independent of the
#' energy inputs.
#'
#' @seealso
#' \code{\link{calc_meat_allocation_energy}},
#' \code{\link{calc_milk_allocation_energy}},
#' \code{\link{calc_fibre_allocation_energy}},
#' \code{\link{calc_work_allocation_energy}},
#' \code{calc_eggs_allocation_energy}
#'
#' @references
#' ISO. (2006). \emph{Environmental management — Life cycle assessment —
#' Requirements and guidelines (ISO 14044:2006)}. International Organization for
#' Standardization, Geneva.
#'
#' IDF. (2022). \emph{The IDF Global Carbon Footprint Standard for the Dairy
#' Sector}. Bulletin of the IDF No. 520/2022. International Dairy Federation,
#' Brussels.
#'
#' Thoma, G., and Nemecek, T. (2020). Allocation between milk and meat in dairy
#' LCA: Critical discussion of the IDF’s standard methodology. In
#' \emph{Proceedings of the 12th International Conference on Life Cycle Assessment
#' of Food (LCAFood 2020)} (pp. 83--89), 13--16 October, Berlin, Germany.
#'
#' FAO. (2016a). \emph{Environmental performance of large ruminant supply chains:
#' Guidelines for assessment}. Livestock Environmental Assessment and Performance
#' (LEAP) Partnership. FAO, Rome, Italy.
#'
#' FAO. (2016b). \emph{Greenhouse gas emissions and fossil energy use from small
#' ruminant supply chains: Guidelines for assessment}. Livestock Environmental
#' Assessment and Performance (LEAP) Partnership. FAO, Rome, Italy.
#'
#' FAO. (2016c). \emph{Greenhouse gas emissions and fossil energy use from poultry
#' supply chains: Guidelines for assessment}. Livestock Environmental Assessment
#' and Performance (LEAP) Partnership. FAO, Rome, Italy.
#'
#' @export
#'
calc_allocation_shares <- function(
    species_short,
    meat_allocation_energy,
    milk_allocation_energy,
    fibre_allocation_energy,
    work_allocation_energy,
    egg_allocation_energy
) {

  total_energy <- sum(
    c(meat_allocation_energy,
      milk_allocation_energy,
      fibre_allocation_energy,
      work_allocation_energy,
      egg_allocation_energy),
    na.rm = TRUE
  )

  if (species_short == "PGS") {
    meat_share_allocation <- 1
    milk_share_allocation <- 0
    fibre_share_allocation <- 0
    work_share_allocation <- 0
    eggs_share_allocation <- 0
  } else {
    meat_share_allocation <- meat_allocation_energy / total_energy
    milk_share_allocation <- milk_allocation_energy / total_energy
    fibre_share_allocation <- fibre_allocation_energy / total_energy
    work_share_allocation <- work_allocation_energy / total_energy
    eggs_share_allocation <- egg_allocation_energy / total_energy
  }

  return(
    list(
      meat_share_allocation = meat_share_allocation,
      milk_share_allocation = milk_share_allocation,
      fibre_share_allocation = fibre_share_allocation,
      work_share_allocation = work_share_allocation,
      eggs_share_allocation = eggs_share_allocation
    )
  )
}

#' Assign Allocation shares to emission variables by commodity
#'
#' Expands commodity-level allocation shares across emission sources and applies
#' predefined allocation rules for excluded emission sources.
#'
#' @param allocation_herd_long Long-format `data.table` containing herd-level emissions and allocation information. Each
#' row represents an emission source–commodity combination or an unallocated emission source prior to allocation.
#' @param emissions_vars Character. Names of emission variables to which allocation should be applied (e.g.,
#' "ch4_enteric","ch4_manure_pasture","ch4_manure_burned","ch4_manure_other",
#' "n2o_manure_pasture_direct","n2o_manure_burned_direct","n2o_manure_other_direct",
#' "n2o_manure_burned_indirect","n2o_manure_pasture_indirect","n2o_manure_other_indirect", "co2_ration_fertilizer",
#' "co2_ration_pesticides", "co2_ration_crop_activities", "co2_ration_luc_nopeat", "co2_ration_luc_peat",
#' "n2o_ration_fertilizer", "n2o_ration_manure_applied", "n2o_ration_crop_residues", "ch4_ration_rice").
#' @param commodities Character. List of commodity categories to which emissions may be allocated.
#' List=c("None","Milk","Meat","Fibre","Work","Eggs").
#' @param non_allocated_emission_sources Character. Emission variables that should not be allocated
#' across commodities, even if they appear in emissions_vars (e.g., "ch4_manure_pasture", "ch4_manure_burned").
#' @param commodity_col Character. Name of the column in `allocation_herd_long` identifying the commodity category.
#' @param allocation_col Character. Name of the column in `allocation_herd_long` containing the allocation share to be
#' applied.
#'
#' @return A `data.table` equal to `allocation_herd_long` expanded over all `emissions_vars`,
#' with enforced allocation rules:
#' \describe{
#'   \item{Non-allocated emission sources}{`allocation_col = 1` when `commodity_col == "None"`, else `0`.}
#'   \item{Allocated emission sources}{`allocation_col = 0` when `commodity_col == "None"` (others unchanged).}
#' }
#'
#'@details
#' Emission sources listed in \code{non_allocated_emission_sources} (e.g., emissions from manure
#' burned as fuel or manure deposited on pasture) are treated as not attributable
#' to livestock commodities under the chosen goal and scope. Consequently,
#' these emissions are allocated entirely to the residual commodity category
#' \code{"None"} and are not distributed across milk, meat, fibre, work, or egg
#' outputs.
#'
#' The following methodological rules apply to emission sources listed in
#' \code{non_allocated_emission_sources}:
#'
#' \itemize{
#'   \item \strong{Manure burned for fuel} — Emissions are considered outside the
#'   life cycle assessment system boundaries under the defined goal and scope and
#'   are therefore not attributed to livestock commodities. A cut-off
#'   approach is applied, consistent with the IDF (2022) standard and LEAP guidelines (LEAP 2016a, 2016b, 2016c).
#'
#'   \item \strong{Manure deposited on pastures} — Emissions are not
#'   allocated to livestock commodities in order to avoid double counting.
#'   When upstream feed production is included in the inventory, emission factors of feed items
#'   already account for this source.
#' }
#'
#' @references
#' IDF. (2022). \emph{The IDF Global Carbon Footprint Standard for the Dairy
#' Sector}. Bulletin of the IDF No. 520/2022. International Dairy Federation,
#' Brussels.
#'
#' FAO. (2016a). \emph{Environmental performance of large ruminant supply chains:
#' Guidelines for assessment}. Livestock Environmental Assessment and Performance
#' (LEAP) Partnership. FAO, Rome, Italy.
#'
#' FAO. (2016b). \emph{Greenhouse gas emissions and fossil energy use from small
#' ruminant supply chains: Guidelines for assessment}. Livestock Environmental
#' Assessment and Performance (LEAP) Partnership. FAO, Rome, Italy.
#'
#' FAO. (2016c). \emph{Greenhouse gas emissions and fossil energy use from poultry
#' supply chains: Guidelines for assessment}. Livestock Environmental Assessment
#' and Performance (LEAP) Partnership. FAO, Rome, Italy.
#'
#' @export
assign_allocation_shares <- function(
    allocation_herd_long,
    emissions_vars,
    commodities,
    non_allocated_emission_sources,
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

  # 3) Non-allocated emission sources → 100% to Other, 0% to others
  allocation_herd_long[
    variable_name %in% non_allocated_emission_sources & get(commodity_col) == "Other",
    (allocation_col) := 1
  ]
  allocation_herd_long[
    variable_name %in% non_allocated_emission_sources & get(commodity_col) != "Other",
    (allocation_col) := 0
  ]

  # 4) Allocated emission sources → Other = 0
  allocation_herd_long[
    !(variable_name %in% non_allocated_emission_sources) & get(commodity_col) == "Other",
    (allocation_col) := 0
  ]

  return(allocation_herd_long)
}
