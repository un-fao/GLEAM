# GLEAM Package Constants
#
# Centralised lookup vectors for valid species and cohort codes, and for
# biologically meaningful sub-groups that are referenced throughout model
# and validation functions. Any change to supported codes or groupings
# should be made here; all other files reference these objects.

# --- Valid input codes -------------------------------------------------------

#' Valid species short codes
#'
#' All livestock species supported by GLEAM.
#'
#' @format A character vector of length 7.
#' @keywords internal
gleam_species <- c("CTL", "BFL", "SHP", "GTS", "CHK", "PGS", "CML")

#' Valid cohort short codes
#'
#' All sex- and age-class cohort codes recognised by GLEAM.
#'
#' @format A character vector of length 6.
#' @keywords internal
gleam_cohorts <- c("FJ", "FS", "FA", "MJ", "MS", "MA")

# --- Species sub-groups ------------------------------------------------------

#' Ruminant species (four-stomach, NE-based energy system)
#'
#' Cattle, Buffalo, Sheep, Goats. Energy requirements for these species are
#' expressed as net energy (NE) and converted to gross energy (GE) via
#' digestibility ratios. Camels use metabolizable energy (ME) instead.
#'
#' @format A character vector of length 4.
#' @keywords internal
gleam_species_ruminants <- c("CTL", "BFL", "SHP", "GTS")

#' Milk-producing species
#'
#' Species for which milk production, lactation energy requirements, and
#' ruminant-style digestibility parameters apply. Includes ruminants plus
#' Camels.
#'
#' @format A character vector of length 5.
#' @keywords internal
gleam_species_milk_producers <- c("CTL", "BFL", "CML", "SHP", "GTS")

#' Non-poultry species (species with non-zero enteric CH4 and N excretion)
#'
#' All species except Chicken (\code{CHK}). Used for enteric methane emission
#' calculations and nitrogen excretion models, where poultry produce negligible
#' enteric CH4 and the N-excretion pathway is not yet implemented.
#'
#' @format A character vector of length 6.
#' @keywords internal
gleam_species_non_poultry <- c("CTL", "BFL", "CML", "SHP", "GTS", "PGS")
