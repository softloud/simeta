#' Calculate proportion of intervention group
#'
#' @param n sample size
#' @inheritParams beta_par
#'
#' @family neet_test_one One neet test has been written
#' @family beta_parameters Beta distribution parameters for intervention proportion.
#'
#' @export

intervention_proportion <- function(n, proportion, error) {

  par <- beta_par(proportion, error)

  rbeta(n, shape1 = par$alpha, shape2 = par$beta)
}
