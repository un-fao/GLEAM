#' Milk Energy Requirement for Allocation
#'
#' Converts fat- and protein-corrected milk output into the megajoule demand used in the allocation workflow.
#' The formula calculates energy density based on standard milk composition and multiplies by production.
#'
#' @param milk_fpcm_output Numeric scalar. Fat- and protein-corrected milk production (kg).
#' @param standard_protein Numeric scalar. Reference protein content (g per 100 g milk).
#' @param standard_fat Numeric scalar. Reference fat content (g per 100 g milk).
#' @param standard_lactose Numeric scalar. Reference lactose content (g per 100 g milk).
#'
#' @return Numeric scalar. Energy requirements in megajoules.
#' @export
calc_energy_allocation_milk <- function(
    milk_fpcm_output,
    standard_protein,
    standard_fat,
    standard_lactose
) {
  validate_allocation_milk_inputs(
    milk_fpcm_output, standard_protein, standard_fat, standard_lactose
  )

  # Calculate energy content of standard milk (MJ/kg milk)
  # Coefficients from IDF (2022): kcal per 100 g milk per 1% unit of fat/protein/lactose
  # Formula: (0.0929 * fat + 0.0547 * protein + 0.0395 * lactose) * 4.184 * 100
  energy_standard <- (
    0.0929 * standard_fat +
      0.0547 * standard_protein +
      0.0395 * standard_lactose
  ) * 4.184 * 100

  # Total energy for milk production
  energy_allocation_milk <- energy_standard * milk_fpcm_output

  return(energy_allocation_milk)
}

#' Meat Energy Requirement for Allocation
#'
#' Applies species- and cohort-specific equations to compute the megajoules required to produce meat output.
#' The calculation follows species-specific formulas to determine energy per kg liveweight, then multiplies by output.
#'
#' @param animal Character scalar. Species code (e.g., "CTL", "BFL", "CML", "SHP", "GTS", "PGS").
#' @param cohort_code Character scalar. Cohort identifier (e.g., "FA", "FS", "FJ", "MA", "MS", "MJ").
#' @param age_first_parturition_years Numeric scalar. Age at first parturition (years). Not currently used but retained for compatibility.
#' @param slaughter_liveweight Numeric scalar. Slaughter liveweight (kg).
#' @param initial_liveweight Numeric scalar. Initial cohort liveweight (kg). Not currently used but retained for compatibility.
#' @param birth_liveweight Numeric scalar. Birthweight (kg).
#' @param meat_output_liveweight Numeric scalar. Liveweight meat output (kg).
#'
#' @return Numeric scalar. Energy requirements in megajoules.
#' @export
calc_energy_allocation_meat <- function(
    animal,
    cohort_code,
    age_first_parturition_years,
    slaughter_liveweight,
    initial_liveweight,
    birth_liveweight,
    meat_output_liveweight
) {
  validate_allocation_meat_inputs(
    animal, cohort_code, age_first_parturition_years,
    slaughter_liveweight, initial_liveweight, birth_liveweight, meat_output_liveweight
  )

  # Default fallback
  specific_energy_meat <- NA_real_

  # Check for valid weights
  if (is.na(animal) || is.na(slaughter_liveweight) || is.na(birth_liveweight)) {
    energy_allocation_meat <- NA_real_
  } else if (animal %in% c("CTL", "BFL")) {
    # Cattle and Buffalo: use growth efficiency factor based on cohort
    if (cohort_code %in% c("FA", "FS", "FJ")) {
      growth_efficiency_factor <- 0.8
    } else if (cohort_code %in% c("MA", "MS", "MJ")) {
      growth_efficiency_factor <- 1
    } else {
      growth_efficiency_factor <- NA_real_
    }
    if (!is.na(growth_efficiency_factor)) {
      specific_energy_meat <- (
        22.02 * (((slaughter_liveweight - birth_liveweight) / 2) /
                   (growth_efficiency_factor * slaughter_liveweight))^0.75 *
          (slaughter_liveweight - birth_liveweight)^1.097
      ) / slaughter_liveweight
    }

  } else if (animal == "CML") {
    # Camelids: simple linear formula
    specific_energy_meat <- (41.8 * (slaughter_liveweight - birth_liveweight)) / slaughter_liveweight

  } else if (animal == "SHP") {
    # Sheep: coefficients vary by cohort (female vs male)
    if (cohort_code %in% c("FA", "FS", "FJ")) {
      a <- 2.1
      b <- 0.45
    } else if (cohort_code %in% c("MA", "MS", "MJ")) {
      a <- 4.4
      b <- 0.32
    } else {
      a <- NA_real_
      b <- NA_real_
    }
    if (!is.na(a) && !is.na(b)) {
      specific_energy_meat <- (
        (slaughter_liveweight - birth_liveweight) *
          (a + 0.5 * b * (birth_liveweight + slaughter_liveweight))
      ) / slaughter_liveweight
    }

  } else if (animal == "GTS") {
    # Goats: fixed coefficients
    a <- 5
    b <- 0.33
    specific_energy_meat <- (
      (slaughter_liveweight - birth_liveweight) *
        (a + 0.5 * b * (birth_liveweight + slaughter_liveweight))
    ) / slaughter_liveweight

  } else if (animal == "PGS") {
    # Pigs: not calculated (returns NA)
    specific_energy_meat <- NA_real_
  }

  # Multiply specific energy by meat output to get total energy allocation
  energy_allocation_meat <- specific_energy_meat * meat_output_liveweight

  return(energy_allocation_meat)
}

#' Fibre Energy Requirement for Allocation
#'
#' Computes fibre energy demand over the assessment window, applying the camelid conversion factor when required.
#'
#' @param animal Character scalar. Species code (e.g., "GTS", "SHP", "CML").
#' @param fibre_energy_requirement Numeric scalar. Fibre energy demand (MJ per head per day).
#' @param ratio_ne_to_me Numeric scalar. Net-to-metabolizable energy conversion ratio (used for camelids).
#' @param assessment_duration Numeric scalar. Assessment duration (days).
#'
#' @return Numeric scalar. Energy requirements in megajoules.
#' @export
calc_energy_allocation_fibre <- function(
    animal,
    fibre_energy_requirement,
    ratio_ne_to_me,
    assessment_duration = 365
) {
  validate_allocation_fibre_inputs(
    animal, fibre_energy_requirement, ratio_ne_to_me, assessment_duration
  )

  if (animal %in% c("GTS", "SHP")) {
    # Sheep and goats: direct NE calculation
    energy_allocation_fibre <- fibre_energy_requirement * assessment_duration
  } else if (animal == "CML") {
    # Camelids: convert ME to NE using ratio
    energy_allocation_fibre <- fibre_energy_requirement * ratio_ne_to_me * assessment_duration
  } else {
    # Other species: no fibre production
    energy_allocation_fibre <- 0
  }

  return(energy_allocation_fibre)
}

#' Work Energy Requirement for Allocation
#'
#' Estimates energy expenditure on animal work for the assessment duration, adjusting camelid values when required.
#'
#' @param animal Character scalar. Species code (e.g., "CML" for camelids).
#' @param work_energy_requirement Numeric scalar. Work energy demand (MJ per head per day).
#' @param ratio_ne_to_me Numeric scalar. Net-to-metabolizable energy conversion ratio (used for camelids).
#' @param assessment_duration Numeric scalar. Assessment duration (days).
#'
#' @return Numeric scalar. Energy requirements in megajoules.
#' @export
calc_energy_allocation_work <- function(
    animal,
    work_energy_requirement,
    ratio_ne_to_me,
    assessment_duration = 365
) {
  validate_allocation_work_inputs(
    animal, work_energy_requirement, ratio_ne_to_me, assessment_duration
  )

  if (animal == "CML") {
    # Camelids: convert ME to NE using ratio
    energy_allocation_work <- work_energy_requirement * ratio_ne_to_me * assessment_duration
  } else {
    # Other species: direct calculation
    energy_allocation_work <- work_energy_requirement * assessment_duration
  }

  return(energy_allocation_work)
}

#' Aggregate Cohort-Level Data to Herd-Level
#'
#' This function aggregates a dataset from cohort level to herd level by summing
#' specified variables over the defined ID columns.
#' 
#' @param data A `data.table` containing cohort-level data.
#' @param id_cols Character vector of ID variables (e.g., Animal_short, LPS_short, HerdType_short).@Yassine: this should be revised. Record_id should be used.
#' @param vars_to_sum Character vector of column names to be summed during aggregation.
#' @param cohort Character. Cohort code (e.g., "FJ", "MJ", "FS", "MS", "FA", "MA").

#'
#' @return A `data.table` with summed values at the herd level.
#' @export
#'

aggregate_cohort_to_herd <- function(data_cohort, id_cols, vars_to_sum, cohort) {
  
  # Aggregate over cohorts
  data_herd <- data_cohort[
    ,
    lapply(.SD, sum, na.rm = TRUE),
    by = id_cols,
    .SDcols = vars_to_sum
  ]
  
  # Add cohort = "ALL"
  data_herd[, (cohort) := "ALL"]
  
  return(data_herd[])
}


#' Calculate Energy Allocation Shares for Livestock Commodities
#'
#' Computes allocation shares of energy required for meat, milk, fibre, work, and eggs
#' based on total energy demand per output. 
#'
#' @param animal Character vector of animal species codes (e.g., "CTL", "SHP", "PGS").
#' @param energy_meat Numeric vector: Herd-level energy requirement for meat production (MJ).
#' @param energy_milk Numeric vector: Herd-level energy requirement for milk production (MJ).
#' @param energy_fibre Numeric vector: Herd-level energy requirement for fibre production (MJ).
#' @param energy_work Numeric vector: Herd-level energy requirement for work (MJ).
#' @param energy_eggs Numeric vector: Herd-level energy requirement for eggs (MJ). 
#'
#' @return A named list of numeric vectors with same length as input, containing:
#' \describe{
#'   \item{allocation_share_meat}{Proportion of total energy allocated to meat}
#'   \item{allocation_share_milk}{... to milk}
#'   \item{allocation_share_fibre}{... to fibre}
#'   \item{allocation_share_work}{... to work}
#'   \item{allocation_share_eggs}{... to eggs}
#' }
#' @export
#' 
calc_allocation_shares <- function(animal,
                                   energy_allocation_meat,
                                   energy_allocation_milk,
                                   energy_allocation_fibre,
                                   energy_allocation_work,
                                   energy_allocation_eggs) {
  
  total_energy <- sum(
    c(energy_allocation_meat,
      energy_allocation_milk,
      energy_allocation_fibre,
      energy_allocation_work,
      energy_allocation_eggs),
    na.rm = TRUE
  )
  
  if (animal == "PGS") {
    allocation_share_meat  <- 1
    allocation_share_milk  <- 0
    allocation_share_fibre <- 0
    allocation_share_work  <- 0
    allocation_share_eggs  <- 0
  } else {
    allocation_share_meat  <- ifelse(is.na(energy_allocation_meat), 0, energy_allocation_meat / total_energy)
    allocation_share_milk  <- ifelse(is.na(energy_allocation_milk), 0, energy_allocation_milk / total_energy)
    allocation_share_fibre  <- ifelse(is.na(energy_allocation_fibre), 0, energy_allocation_fibre / total_energy)
    allocation_share_work  <- ifelse(is.na(energy_allocation_work), 0, energy_allocation_work / total_energy)
    allocation_share_eggs  <- ifelse(is.na(energy_allocation_eggs), 0, energy_allocation_eggs / total_energy)
    
  }
  list(
    allocation_share_meat  = allocation_share_meat,
    allocation_share_milk  = allocation_share_milk,
    allocation_share_fibre = allocation_share_fibre,
    allocation_share_work  = allocation_share_work,
    allocation_share_eggs  = allocation_share_eggs
  )
}