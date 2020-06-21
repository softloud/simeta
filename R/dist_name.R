#' R to name
#'
#' A function that switches out the R name for a distribution with the real
#' name, and back again.
#'
#' @param dist A string with a distribution name, e.g. "lnorm" or "log-normal".
#' @param toR Boolean as to whether it's to the R name or not. Defaults to
#' false.
#'
#' @family neet_test_one One neet test has been written
#' @family reporting Functions and tools for reporting simulation results.
#'
#' @export

dist_name <- function(dist, toR = FALSE) {

  assert_neet(dist, "character")
  assesrt_neet(toR, "logical")

  if (toR) {
    switch(dist,
           normal = "norm",
           "log-normal" = "lnorm",
           beta = "beta",
           Weibull = "weibull",
           exponential = "exp",
           gamma = "gamma",
           Pareto = "pareto",
           "chi-squared" = "chisq",
           "error")
  } else {
    switch(dist,
           norm = "normal",
           lnorm = "log-normal",
           beta = "beta",
           weibull = "Weibull",
           exp = "exponential",
           gamma = "gamma",
           pareto = "Pareto",
           chisq = "chi-squared",
           "error")
  }
}
