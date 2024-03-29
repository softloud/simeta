#' Calculate distributional parametrs for proportion of sample size given
#' to intervention
#'
#' This function returns parameters for a beta distribution calculated from an
#' expected proportion assigned to intervention group and error.
#'
#' Called by [intervention_proportion], this function calculates
#' the parameters for the beta distribution to randomly generate
#' the proportion \eqn{p_k} of the total sample size
#' \eqn{N_k} for the
#' \eqn{k}th study.
#'
#' @param proportion Expected proportion for the intervention group
#' @param error Within what value will 90 per cent of the proportion
#' of intervention groups fall within?
#'
#' @family sample_size Generating meta-anlysis sample sizes.
#' @family simulation Functions that contribute to simulation pipeline.
#'
#' @export

beta_par <- function(proportion, error) {

  # check inputs
  assertthat::assert_that(proportion > 0 &
                             proportion < 1,
                           msg = "proportion must be from (0,1)")
  assertthat::assert_that(error > 0 &
                             error < 1,
                           msg = "error must be from (0,1)")

  # calculate beta distribution parameters

  alpha <- proportion * (((10 * proportion ^ 2) / error ^ 2) *
                           (1 / proportion - 1) - 1)

  beta <- alpha / proportion - alpha

  return(list(alpha = alpha,
              beta = beta))
}
