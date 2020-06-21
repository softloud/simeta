#' Calculate proportion of intervention group
#'
#' @param n sample size
#' @inheritParams beta_par
#'
#' @family neet_test_one One neet test has been written
#' @family simulation Functions that contribute to simulation pipeline.
#' @family sample_size Generating meta-anlysis sample sizes.
#'
#' @export

intervention_proportion <- function(n, proportion, error) {

  assert_neet(n, "numint")
  assert_neet(proportion, "numeric")
  assert_neet(error, "numeric")

  par <- beta_par(proportion, error)

  rbeta(n, shape1 = par$alpha, shape2 = par$beta)
}
