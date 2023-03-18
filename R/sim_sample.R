#' Simulate a sample
#'
#' Given a distribution, parameters, sample size, generate a sample.
#'
#' @param n sample size
#' @param this_study_error this study error, gamma_k / 2, under the assumption
#' random effect variance is split between two.
#' @param rdist string indicating distribution, "norm", "lnorm", "exp", or "pareto"
#' @param par list of parameter arguments
#' @param control value of first parameter of distribution is determined by median ratio
#' @param effect_ratio ratio of population effects intervention / control
#'
#' @family simulation Functions that contribute to simulation pipeline.
#'
#' @export

sim_sample <- function(n = 18,
                       this_study_error = 0.2,
                       rdist = "norm",
                       par = list(mean = 20, sd = 0.2),
                       control = TRUE,
                       effect_ratio = 1.2) {
  # check inputs are valid
  assert_that(length(par) <= 2,
              msg = "haven't coded this
                          for more than two parameters")
  assert_that(rdist %in% c("exp", "norm", "lnorm", "pareto"),
              msg = "choose exp, norm, lnorm, and pareto")
  assert_that(is.numeric(n),
              length(n) == 1,
              round(n) == n,
              msg = "n argument requires an integer")
  assert_that(is.numeric(this_study_error),
              length(this_study_error) == 1,
              msg = "this_study_error should requires a number")
  assert_that(is.logical(control),
              msg = "control argument needs to be a logical
                          indicating if in control group")
  assert_that(is.numeric(effect_ratio),
              msg = "effect_ratio needs to be a numeric")

  # set up sign for different arms
  beta <- if (control == TRUE) {
    -1
  } else {
    1
  }

  if (rdist == "norm") {
    # set value of first parameter to ensure median ratio
    par_j <-
      if (control == FALSE)
        par[[1]] * effect_ratio
    else
      par[[1]]

    # generate sample
    return(rnorm(
      n,
      mean = par_j * exp(beta * this_study_error),
      sd = par[[2]]
    ))

  } else if (rdist == "lnorm") {
    # set value of first parameter to ensure median ratio
    par_j <-
      if (control == FALSE)
        par[[1]] + log(effect_ratio)
    else
      par[[1]]

    # generate sample
    return(rlnorm(n, par_j * exp(beta * this_study_error), par[[2]]))

  } else if (rdist == "pareto") {
    # set value of first parameter to ensure median ratio
    par_j <- if (control == FALSE) {
      par[[2]] * effect_ratio
    } else {
      par[[2]]
    }

    # generate sample
    # nb: varying the scale parameter instead might be violating, apples and
    # oranges, comparison.
    return(actuar::rpareto2(
      n,
      min = 0,
      shape = par[[1]],
      scale = par_j * exp(beta * this_study_error)
    ))

  } else if (rdist == "exp") {
    # set value of first parameter to ensure median ratio
    par_j <- if (control == FALSE) {
      par[[1]] / effect_ratio
    } else {
      par[[1]]
    }

    # generate sample
    return(rexp(n, par_j * exp(-beta * this_study_error)))
  }

}
