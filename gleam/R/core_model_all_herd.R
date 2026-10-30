#' Rescale a variable from one reference total to another
#'
#' Rescales a vector of values expressed relative to an original reference
#' (\code{x_reference_from}) so that they sum, or scale proportionally, to a
#' new target reference (\code{y_scaling_variable}). Zero values are preserved
#' as zero.
#'
#' This function is part of the [run_all_herd_module()].
#'
#' @param x_scaled_variable Numeric vector. Values to be rescaled.
#' @param x_reference_from Numeric vector or scalar. Original reference total
#'   used to scale \code{x_scaled_variable}.
#' @param y_scaling_variable Numeric vector or scalar. Target reference total
#'   to which \code{x_scaled_variable} should be rescaled.
#'
#' @return Numeric vector of the same length as \code{x_scaled_variable},
#'   containing the rescaled values.
#'
#' @seealso [run_all_herd_module()]
#'
#' @export
rescale_x_to_y <- function(
    x_scaled_variable,
    x_reference_from,
    y_scaling_variable
) {
  ifelse(
    x_scaled_variable == 0,
    0,
    x_scaled_variable / x_reference_from * y_scaling_variable
  )
}
