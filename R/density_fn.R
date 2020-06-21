#' Get an arbitrary density function
#'
#' @param x Input for density function.
#' @param distribution Currently programmed for "norm", "pareto", "exp", and
#' "lnorm" inputs.
#' @param parameters List of parameters for distribution; e.g. list(mean = 30,
#' sd = 0.2) for \eqn{normal(30, 0.2)}.
#' @param type Random "r" sample, density "d", quantile "q", or probability "p".
#'
#' @importFrom actuar dpareto qpareto rpareto qpareto
#'
#' @family simulation Functions that contribute to simulation pipeline.
#' @family neet_test_one One neet test has been written
#'
#' @export

density_fn <- function(x,
                       distribution,
                       parameters,
                       type = "q") {
  assert_neet(x, "numeric")
  assert_neet(distribution, "character")
  assert_neet(parameters, "list")
  assert_neet(type, "character")

  fn <- get(paste0(type, distribution))

  # dplyr::case_when()
  if (length(parameters) == 1) {
    fn(x, parameters[[1]])
  } else {
    fn(x, parameters[[1]], parameters[[2]])
  }

}
