#' calculate the standard error of the log-ratio of two random samples
#'
#' Provides sample estimator for the squared-root of the variance of the
#' log-ratio of two random samples
#'
#' @param measure mean or median
#' @param n_c sample size of control group
#' @param effect_c effect measure for control group
#' @param effect_se_c standard error of control group
#' @param n_i sample size of intervention group
#' @param effect_i effect measure of intervention group
#' @param effect_se_i standard error of intervention group
#'
#' @family neet_test_one One neet test has been written
#' @family simulation Functions that contribute to simulation pipeline.
#'
#' @export

lr_se <-
  function(measure,
           n_c,
           effect_c,
           effect_se_c,
           n_i,
           effect_i,
           effect_se_i) {
    neet::assert_neet(measure, "character")
    neet::assert_neet(n_c, "numint")
    neet::assert_neet(n_i, "numint")
    neet::assert_neet(effect_c, "numint")
    neet::assert_neet(effect_se_c, "numint")
    neet::assert_neet(effect_i, "numint")
    neet::assert_neet(effect_se_i, "numint")

    case_when(
      measure == "median" ~ sqrt(effect_se_c ^ 2 / effect_c ^ 2 +
                                   effect_se_i ^ 2 / effect_i ^ 2),
      measure == "mean" ~ sqrt(
        1 / sum(n_c, n_i) *
          (1 - ((sum(
            n_c, n_i
          ) - 1) / (sum(
            n_c, n_i
          ) - 1))) *
          1 / effect_c ^ 2 *
          ((effect_i / effect_c) ^ 2 * effect_se_c ^
             2 +
             effect_se_i ^ 2)
      )
    )
  }
