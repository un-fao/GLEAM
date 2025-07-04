#' Calculate Net Energy for Maintenance
#'
#' Computes net energy required for maintenance (MJ/head/day).
#'
#' @param animal Character. Species code (e.g., "CTL", "BFL", "SHP", "GTS", "PGS", "CHK", "CML").
#' @param cohort Character. Cohort code.
#' @param average_weight Numeric. Average live weight (kg).
#' @param idle Numeric. Fraction of time idle (for PGS).
#' @param gest Numeric. Fraction of time gestating (for PGS).
#' @param lact Numeric. Fraction of time lactating (for PGS).
#' @param litsize Numeric. Litter size (for PGS, SHP, GTS).
#' @param ckg Numeric. Birth weight (for PGS).
#' @param milking_fraction Numeric. Proportion of lactating adult females.
#' @param offtake_rate Numeric. Offtake rate by cohort.
#' @param afc Numeric. Age at first calving (for SHP).
#'
#' @return Numeric. Net energy for maintenance (MJ/head/day).
#' @export
calculate_net_energy_maintenance <- function(
    animal,
    cohort,
    average_weight,
    idle = NA,
    gest = NA,
    lact = NA,
    litsize = NA,
    ckg = NA,
    milking_fraction = NA,
    offtake_rate = NA,
    afc = NA
) {
  cmain <- NA

  if (animal %in% c("CTL", "BFL")) {
    if (cohort %in% c("FA")) {
      # Weighted by milking fraction
      cmain <- 0.386 * milking_fraction + 0.322 * (1 - milking_fraction)
    } else if (cohort %in% c("FS", "FJ", "MJ")) {
      cmain <- 0.322
    } else if (cohort %in% c("MA", "MS")) {
      # Weighted by offtake rate
      cmain <- 0.37 * offtake_rate + 0.322 * (1 - offtake_rate)
    }
  } else if (animal == "CML") {
    cmain <- 0.435 # Camelids fixed coefficient
  } else if (animal == "GTS") {
    cmain <- 0.315 # Goats fixed coefficient
  } else if (animal == "SHP") {
    # Sheep: different coefficients for cohorts
    if (cohort == "FA") {
      cmain <- 0.217
    } else if (cohort == "FS") {
      # Weighted by age at first calving (afc)
      cmain <- (0.236 * (1 / afc)) + (0.217 * ((afc - 1) / afc))
    } else if (cohort == "FJ") {
      cmain <- 0.236
    } else if (cohort == "MA") {
      # Weighted by offtake rate
      cmain <- 0.217 * offtake_rate + 0.217 * 1.15 * (1 - offtake_rate)
    } else if (cohort == "MS") {
      # Complex weighted average for subadult males
      cmain <- ((0.271 * offtake_rate + 0.217 * 1.15 * (1 - offtake_rate)) * ((afc - 1) / afc) +
                  (0.236 * offtake_rate + 0.236 * 1.15 * (1 - offtake_rate)) * (1 / afc))
    } else if (cohort == "MJ") {
      cmain <- 0.236 * offtake_rate + 0.236 * 1.15 * (1 - offtake_rate)
    }
  } else if (animal == "PGS") {
    cmain <- 0.4435 # Pigs fixed coefficient
    if (cohort == "FA") {
      # Weighted average for adult females based on physiological state
      lw_AF <- ((average_weight^0.75 * idle) +
                  ((average_weight + (litsize * ckg + 0.15 * average_weight) / 2)^0.75 * gest) +
                  ((average_weight + (0.15 * average_weight) / 2)^0.75 * lact)) /
        (idle + gest + lact)
      return(lw_AF * cmain)
    }
  }
  # Default: metabolic body weight scaling
  return((average_weight^0.75) * cmain)
}

#' Calculate Net Energy for Activity
#'
#' Computes net energy required for activity (MJ/head/day).
#'
#' @param animal Character. Species code.
#' @param cohort Character. Cohort code.
#' @param past_man_frac Numeric. Pasture management fraction.
#' @param mmspasture Numeric. Fraction of time on pasture.
#' @param nemain Numeric. Net energy for maintenance.
#' @param average_weight Numeric. Average live weight (kg).
#' @param offtake_rate Numeric. Offtake rate by cohort.
#'
#' @return Numeric. Net energy for activity (MJ/head/day).
#' @export
calculate_net_energy_activity <- function(
    animal,
    cohort,
    past_man_frac,
    mmspasture,
    nemain,
    average_weight,
    offtake_rate
) {
  if (animal %in% c("CTL", "BFL")) {
    # Weighted by pasture management
    cact <- (0.17 * mmspasture * past_man_frac) + (0.36 * mmspasture * (1 - past_man_frac))
    ret <- cact * nemain
  } else if (animal %in% c("CML")) {
    cact <- (0.1 * mmspasture)
    ret <- cact * nemain
  } else if (animal == "SHP") {
    # Sheep: more complex, includes offtake effect
    cact <- (0.0107 * mmspasture * past_man_frac) + (0.024 * mmspasture * (1 - past_man_frac)) * (1 - offtake_rate) + (0.0067 * offtake_rate)
    if (cohort == "FA") {
      cact <- 0.0096 # Adult females fixed
    }
    ret <- cact * average_weight
  } else if (animal %in% c("GTS")) {
    cact <- (0.019 * mmspasture * past_man_frac) + (0.024 * mmspasture * (1 - past_man_frac))
    ret <- cact * average_weight
  } else if (animal == "PGS") {
    cact <- 0.125 * mmspasture # Pigs: fixed activity coefficient
    ret <- cact * nemain
  }
  return(ret)
}

#' Calculate Net Energy for Growth
#'
#' Computes net energy required for growth (MJ/head/day).
#'
#' @param animal Character. Species code.
#' @param cohort Character. Cohort code.
#' @param average_weight Numeric. Average live weight (kg).
#' @param final_weight Numeric. Final live weight (kg).
#' @param initial_weight Numeric. Initial live weight (kg).
#' @param dwg Numeric. Daily weight gain (kg/day).
#' @param offtake_rate Numeric. Offtake rate by cohort.
#' @param duration Numeric. Duration in days.
#'
#' @return Numeric. Net energy for growth (MJ/head/day).
#' @export
calculate_net_energy_growth <- function(
    animal,
    cohort,
    average_weight,
    final_weight,
    initial_weight,
    dwg,
    offtake_rate,
    duration
) {
  if (animal %in% c("CTL", "BFL")) {
    if (cohort %in% c("FS", "FJ")) {
      cgro <- 0.8
    } else if (cohort %in% c("MS", "MJ")) {
      cgro <- 1.2 * (1 - offtake_rate) + 1 * offtake_rate
    }
    if (cohort %in% c("FS", "FJ", "MS", "MJ")) {
      ret <- 22.02 * ((average_weight / (cgro * final_weight))^0.75) * (dwg^1.097)
    } else {
      return(0) # No growth for other cohorts
    }
  } else if (animal %in% c("CML")) {
    if (cohort %in% c("FS", "FJ", "MS", "MJ")) {
      ret <- 41.8 * dwg
    } else {
      ret <- 0
    }
  } else if (animal %in% c("SHP")) {
    # Sheep: a, b coefficients depend on cohort and offtake
    if (cohort %in% c("FS", "FJ")) {
      a <- 2.1
      b <- 0.45
    } else if (cohort %in% c("MS", "MJ")) {
      a <- 4.4 * offtake_rate + 2.5 * (1 - offtake_rate)
      b <- 0.32 * offtake_rate + 0.35 * (1 - offtake_rate)
    } else if (cohort %in% c("FA", "MA")) {
      a <- 0
      b <- 0
    }
    # Linear growth formula
    ret <- ((final_weight - initial_weight) * (a + 0.5 * b * (initial_weight + final_weight))) / duration
  } else if (animal %in% c("GTS")) {
    if (cohort %in% c("FS", "FJ", "MS", "MJ")) {
      a <- 5
      b <- 0.33
    } else if (cohort %in% c("FA", "MA")) {
      a <- 0
      b <- 0
    }
    ret <- ((final_weight - initial_weight) * (a + 0.5 * b * (initial_weight + final_weight))) / duration
  } else if (animal == "PGS") {
    prot_tissue_frac <- 0.65 # Protein tissue fraction
    if (cohort %in% c("FS", "FJ", "MS", "MJ")) {
      cgro <- (prot_tissue_frac * 0.23 * 54) + ((1 - prot_tissue_frac) * 0.9 * 52.3)
      ret <- dwg * cgro
    } else {
      ret <- 0
    }
  } else {
    ret <- 0 # Default: no growth
  }
  return(ret)
}

#' Calculate Net Energy for Lactation
#'
#' Computes net energy required for lactation (MJ/head/day).
#'
#' @param animal Character. Species code.
#' @param cohort Character. Cohort code.
#' @param milking_fraction Numeric. Proportion of lactating adult females.
#' @param milk_yield Numeric. Milk yield (kg/day).
#' @param milk_fat Numeric. Milk fat content (fraction).
#' @param idle Numeric. Fraction of time idle (for PGS).
#' @param gest Numeric. Fraction of time gestating (for PGS).
#' @param litsize Numeric. Litter size (for PGS, SHP, GTS).
#' @param dr1 Numeric. Death rate in first year (for PGS).
#' @param ckg Numeric. Birth weight (for PGS).
#' @param wkg Numeric. Weaning weight (for PGS).
#' @param lact Numeric. Fraction of time lactating (for PGS).
#' @param parturition_rate Numeric. Parturition rate.
#' @param lambing_interval Numeric. Lambing interval (for SHP, GTS).
#'
#' @return Numeric. Net energy for lactation (MJ/head/day).
#' @export
calculate_net_energy_lactation <- function(
    animal,
    cohort,
    milking_fraction,
    milk_yield,
    milk_fat,
    idle,
    gest,
    litsize,
    dr1,
    ckg,
    wkg,
    lact,
    parturition_rate,
    lambing_interval
) {
  if (animal %in% c("CTL", "BFL")) {
    if (cohort == "FA") {
      ret <- (milk_yield + (parturition_rate * 5 * (wkg - ckg)) / 365) * (milk_fat * 100 * 0.40 + 1.47) * milking_fraction
    } else {
      ret <- 0
    }
  } else if (animal %in% c("CML")) {
    if (cohort == "FA") {
      ret <- (milk_yield + (parturition_rate * 5 * (wkg - ckg)) / 365) * 4.063 * milking_fraction
    } else {
      ret <- 0
    }
  } else if (animal %in% c("SHP")) {
    if (cohort == "FA") {
      # Includes effect of litter size and lambing interval
      ret <- (milk_yield + (litsize * (365 * parturition_rate / lambing_interval) * 5 * (wkg - ckg)) / 365) * 4.6 * milking_fraction
    } else {
      ret <- 0
    }
  } else if (animal %in% c("GTS")) {
    if (cohort == "FA") {
      ret <- (milk_yield + (litsize * (365 * parturition_rate / lambing_interval) * 5 * (wkg - ckg)) / 365) * 3 * milking_fraction
    } else {
      ret <- 0
    }
  } else if (animal == "PGS") {
    if (cohort != "FA") {
      ret <- 0
    } else {
      # Pigs: adjustment for lactation period
      cadj <- lact / (idle + gest + lact)
      ret <- litsize * (1 - 0.5 * dr1) * ((0.02059 * (wkg - ckg) * 1000 / lact) - (0.3766 / 0.67)) * cadj
    }
    return(ret)
  }
}

#' Calculate Net Energy for Work
#'
#' Computes net energy required for work (MJ/head/day).
#'
#' @param animal Character. Species code.
#' @param cohort Character. Cohort code.
#' @param nemain Numeric. Net energy for maintenance.
#' @param work_hours Numeric. Number of work hours.
#' @param draught_fraction Numeric. Draught fraction.
#'
#' @return Numeric. Net energy for work (MJ/head/day).
#' @export
calculate_net_energy_work <- function(
    animal,
    cohort,
    nemain,
    work_hours,
    draught_fraction
) {
  # Only adult males (MA) work
  if (animal %in% c("CTL", "BFL")) {
    if (cohort != "MA") {
      ret <- 0
    } else {
      # 0.1 coefficient: GLEAM standard for work
      ret <- 0.1 * nemain * work_hours * draught_fraction
    }
  } else if (animal %in% c("CML")) {
    if (cohort != "MA") {
      ret <- 0
    } else {
      ret <- 4 * work_hours * draught_fraction
    }
  } else if (animal %in% c("SHP", "GTS", "PGS", "CHK")) {
    ret <- 0 # No work for these species
  }
  return(ret)
}

#' Calculate Net Energy for Fibre Production
#'
#' Computes net energy required for fibre production (MJ/head/day).
#'
#' @param animal Character. Species code.
#' @param cohort Character. Cohort code.
#' @param fibre_prod Numeric. Fibre production (kg/year).
#'
#' @return Numeric. Net energy for fibre production (MJ/head/day).
#' @export
calculate_net_energy_fibre <- function(
    animal,
    cohort,
    fibre_prod
) {
  # Only sheep, goats, camelids produce fibre
  if (animal %in% c("GTS", "SHP")) {
    if (cohort %in% c("FA", "FS", "MA", "MS")) {
      ret <- 24 * fibre_prod / 365 # 24 MJ/kg fibre, annualized
    } else {
      ret <- 0
    }
  } else if (animal %in% c("CML")) {
    if (cohort %in% c("FA", "FS", "MA", "MS")) {
      ret <- (24 / 0.43) * (fibre_prod / 365) # 0.43: efficiency factor for camels
    } else {
      ret <- 0
    }
  } else if (animal %in% c("CTL", "BFL", "PGS", "CHK")) {
    ret <- 0 # Not applicable
  }
  return(ret)
}

#' Calculate Net Energy for Pregnancy
#'
#' Computes net energy required for pregnancy (MJ/head/day).
#'
#' @param animal Character. Species code.
#' @param cohort Character. Cohort code.
#' @param nemain Numeric. Net energy for maintenance.
#' @param parturition_rate Numeric. Parturition rate.
#' @param idle Numeric. Fraction of time idle (for PGS).
#' @param lact Numeric. Fraction of time lactating (for PGS).
#' @param litsize Numeric. Litter size (for SHP, GTS, PGS).
#' @param gest Numeric. Fraction of time gestating (for PGS).
#' @param duration Numeric. Duration in days.
#' @param offtake_rate Numeric. Offtake rate by cohort.
#'
#' @return Numeric. Net energy for pregnancy (MJ/head/day).
#' @export
calculate_net_energy_pregnancy <- function(
    animal,
    cohort,
    nemain,
    parturition_rate,
    idle,
    lact,
    litsize,
    gest,
    duration,
    offtake_rate
) {
  if (animal %in% c("CTL", "BFL")) {
    if (cohort == "FA") {
      ret <- (nemain * 0.1 * parturition_rate)
    } else if (cohort == "FS") {
      ret <- (nemain * 0.1) * (1 / (duration / 365)) * (1 - offtake_rate)
    } else {
      ret <- 0
    }
  } else if (animal %in% c("CML")) {
    if (cohort == "FA") {
      ret <- nemain * 0.12 * parturition_rate
    } else if (cohort == "FS") {
      ret <- nemain * 0.12 * (1 / (duration / 365)) * (1 - offtake_rate)
    } else {
      ret <- 0
    }
  } else if (animal %in% c("SHP", "GTS")) {
    if (cohort == "FA") {
      cpreg <- 0
      # Litter size effect
      if (litsize >= 1 & litsize <= 2) {
        cpreg <- (0.077 * (2 - litsize) + 0.126 * (litsize - 1))
      } else if (litsize > 2) {
        cpreg <- 0.150
      }
      ret <- nemain * cpreg * parturition_rate
    } else if (cohort == "FS") {
      # 5 months pregnancy assumed
      ret <- nemain * 0.077 * (1 / (duration / 365)) * (1 - offtake_rate)
    } else {
      ret <- 0
    }
  } else if (animal == "PGS") {
    cgest <- 0.14985 # GLEAM coefficient for pigs
    if (cohort == "FA") {
      cadj <- gest / (idle + gest + lact)
    } else if (cohort == "FS") {
      cadj <- (gest / (duration)) * (1 / (duration / 365)) * (1 - offtake_rate)
    }
    if (cohort %in% c("FA", "FS")) {
      ret <- cgest * litsize * cadj
    } else {
      ret <- 0
    }
  } else if (animal == "CHK") {
    ret <- 0 # Not applicable
  }
  return(ret)
}

#' Calculate REM (Net Energy for Maintenance / Digestible Energy)
#'
#' Computes the ratio of net energy available in the diet for maintenance to digestible energy.
#'
#' @param animal Character. Species code.
#' @param diet_dig Numeric. Diet digestibility (fraction).
#'
#' @return Numeric. REM value (fraction).
#' @export
calculate_rem_maintenance <- function(
    animal,
    diet_dig
) {
  # Only ruminants: cattle, buffalo, sheep, goats
  if (animal %in% c("CTL", "BFL", "SHP", "GTS")) {
    # Polynomial fit from GLEAM
    ret <- 1.123 - (0.004092 * (diet_dig * 100)) + (0.00001126 * (diet_dig * 100)^2) - (25.4 / (diet_dig * 100))
  } else if (animal %in% c("PGS", "CHK", "CML")) {
    ret <- NA # Not applicable
  }
  return(ret)
}

#' Calculate REG (Net Energy for Growth / Digestible Energy)
#'
#' Computes the ratio of net energy available in the diet for growth to digestible energy.
#'
#' @param animal Character. Species code.
#' @param diet_dig Numeric. Diet digestibility (fraction).
#'
#' @return Numeric. REG value (fraction).
#' @export
calculate_reg_growth <- function(
    animal,
    diet_dig
) {
  # Only ruminants: cattle, buffalo, sheep, goats
  if (animal %in% c("CTL", "BFL", "SHP", "GTS")) {
    # Polynomial fit
    ret <- 1.164 - (0.005160 * (diet_dig * 100)) + (0.00001308 * (diet_dig * 100)^2) - (37.4 / (diet_dig * 100))
  } else if (animal %in% c("PGS", "CHK", "CML")) {
    ret <- NA # Not applicable
  }
  return(ret)
}

#' Calculate Total Energy Requirement
#'
#' Computes the total energy requirement (MJ/head/day).
#'
#' @param animal Character. Species code.
#' @param cohort Character. Cohort code.
#' @param nemain Numeric. Net energy for maintenance.
#' @param neact Numeric. Net energy for activity.
#' @param nelact Numeric. Net energy for lactation.
#' @param nework Numeric. Net energy for work.
#' @param nepreg Numeric. Net energy for pregnancy.
#' @param rem Numeric. REM value.
#' @param negrow Numeric. Net energy for growth.
#' @param nefibre Numeric. Net energy for fibre production.
#' @param neegg Numeric. Net energy for egg production.
#' @param reg Numeric. REG value.
#' @param diet_dig Numeric. Diet digestibility (fraction).
#' @param afc Numeric. Age at first calving (for SHP, GTS).
#'
#' @return Numeric. Total energy requirement (MJ/head/day).
#' @export
calculate_total_energy_requirement <- function(
    animal,
    cohort,
    nemain,
    neact,
    nelact,
    nework,
    nepreg,
    rem,
    negrow,
    nefibre,
    neegg,
    reg,
    diet_dig,
    afc
) {
  # Cattle, buffalo: sum maintenance, activity, lactation, work, pregnancy, growth
  if (animal %in% c("CTL", "BFL")) {
    ret <- (((nemain + neact + nelact + nework + nepreg) / rem) + ((negrow) / reg)) / diet_dig
  } else if (animal %in% c("SHP", "GTS")) {
    # Sheep, goats: add fibre
    ret <- (((nemain + neact + nelact + nepreg) / rem) + ((negrow + nefibre) / reg)) / diet_dig
  } else if (animal == "CML") {
    ret <- nemain + neact + nelact + nework + nefibre + nepreg
  } else if (animal == "PGS") {
    ret <- nemain + neact + nelact + nepreg + negrow
  } else if (animal == "CHK") {
    ret <- nemain + neact + negrow + neegg
  }
  return(ret)
}

#' Calculate Net Energy for Meat Production
#'
#' Computes the energy requirement for meat production (MJ/head).
#'
#' @param animal Character. Species code.
#' @param cohort Character. Cohort code.
#' @param ckg Numeric. Birth weight (kg).
#' @param afc Numeric. Age at first calving (for SHP, GTS).
#' @param slaughter_weight Numeric. Slaughter weight (kg).
#' @param initial_weight Numeric. Initial live weight (kg).
#'
#' @return Numeric. Net energy for meat production (MJ/head).
#' @export
calculate_net_energy_meat <- function(
    animal,
    cohort,
    ckg,
    afc,
    slaughter_weight,
    initial_weight
) {
  ret <- NA_real_
  # Cattle, buffalo: cohort-specific cgro
  if (animal %in% c("CTL", "BFL")) {
    if (cohort %in% c("FA", "FS", "FJ")) {
      cgro <- 0.8
    } else if (cohort %in% c("MA", "MS", "MJ")) {
      cgro <- 1
    }
    ret <- ((22.02 * (((slaughter_weight - ckg) / 2) / (cgro * slaughter_weight))^0.75 * (slaughter_weight - ckg)^1.097)) / slaughter_weight
  } else if (animal %in% c("SHP", "GTS")) {
    # Sheep, goats: a, b coefficients
    if (animal == "SHP") {
      if (cohort %in% c("FA", "FS", "FJ")) {
        a <- 2.1
        b <- 0.45
      } else if (cohort %in% c("MA", "MS", "MJ")) {
        a <- 4.4
        b <- 0.32
      }
    } else if (animal == "GTS") {
      a <- 5
      b <- 0.33
    }
    ret <- ((slaughter_weight - ckg) * (a + 0.5 * b * (ckg + slaughter_weight))) / slaughter_weight
  } else if (animal %in% c("PGS")) {
    ret <- NA # Not applicable
  }
  return(ret)
}

#' Calculate Daily Dry Matter Intake
#'
#' Computes daily feed intake per animal (kg DM/head/day).
#'
#' @param animal Character. Species code.
#' @param total_energy Numeric. Total energy requirement (MJ/head/day).
#' @param diet_ge Numeric. Gross energy of diet (MJ/kg DM).
#' @param diet_me Numeric. Metabolizable energy of diet (MJ/kg DM).
#'
#' @return Numeric. Dry matter intake (kg DM/head/day).
#' @export
calculate_dry_matter_intake <- function(
    animal,
    total_energy,
    diet_ge,
    diet_me
) {
  # Ruminants: use gross energy
  if (animal %in% c("CTL", "BFL", "SHP", "GTS")) {
    ret <- total_energy / diet_ge
  } else if (animal %in% c("PGS", "CHK", "CML")) {
    # Monogastrics/camelids: use metabolizable energy
    ret <- total_energy / diet_me
  }
  return(ret)
}
