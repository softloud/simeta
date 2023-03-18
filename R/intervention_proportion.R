#' Calculate proportion of intervention group
#'
#' @param n sample size
#' @inheritParams beta_par
#'
#' @family simulation Functions that contribute to simulation pipeline.
#' @family sample_size Generating meta-anlysis sample sizes.
#'
#' @export

intervention_proportion <- function(n, proportion, error) {

  par <- beta_par(proportion, error)

  stats::rbeta(n, shape1 = par$alpha, shape2 = par$beta)
}
