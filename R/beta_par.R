#' Calculate distributional parametrs for proportion of sample size given
#' to intervention
#'
#' This function returns parameters for a beta distribution calculated from an
#' expected proportion assigned to intervention group and error.
#'
#' Called by [intervention_proportion], this function is calculates creating
#' the parameters for the beta distribution to sample
#' the proportion \eqn{p_k} of the total sample size
#' \eqn{N_k} for the
#' \eqn{k}th study.
#'
#' @param proportion Expected proportion for the intervention group
#' @param error Within what value will 90 per cent of the proportion
#' of intervention groups fall within?
#'
#' @export

beta_par <- function(proportion, error) {
  alpha <- proportion * (
    ((10 * proportion^2) / error^2) *
      (1 / proportion - 1) - 1
  )

  beta <- alpha / proportion - alpha

  return(list(
    alpha = alpha,
    beta = beta
  ))
}
