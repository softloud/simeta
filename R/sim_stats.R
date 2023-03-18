#' Simulate a meta-analysis dataset
#'
#' @param measure Calculate sample median or mean. Defaults to mean.
#' @param measure_spread Defaults to standard deviation, `sd`. Specify "iqr", "range", "sd", "var". Will have to check how many of these are done right now.
#' @param n_df \code{data.frame} of sample sizes.
#' @param wide Logical indicating if wide format, as is expected by `metafor`. Defaults to TRUE.
#' @inheritParams sim_sample
#' @inheritParams sim_df
#'
#' @importFrom assertthat assert_that
#' @import tibble
#' @import purrr
#' @import dplyr
#' @export

sim_stats <- function(measure = "mean",
                      measure_spread = "sd",
                      n_df = sim_n(),
                      wide = TRUE,
                      rdist = "norm",
                      par = list(mean = 50, sd = 0.2),
                      tau_sq = 0.4,
                      effect_ratio = 1.2) {
  # check inputs to function are as required
  assertthat::assert_that("data.frame" %in% class(n_df),
                          msg = "n_f = argument requires a dataframe")
  assertthat::assert_that("character" %in% class(rdist),
                          msg = "rdist = argument requires a character
                          string: norm, exp, lnorm, or pareto")
  assertthat::assert_that(
    "list" %in% class(par),
    length(par) > 0,
    length(par) <= 2,
    msg = "par = argument expects a list
                          vector of length one or two, dependening
                          on choice of distribution"
  )
  assertthat::assert_that("numeric" %in% class(tau_sq),
                          length(tau_sq) == 1,
                          msg = "tau_sq = argument should be numeric
                          of length 1")
  assertthat::assert_that("numeric" %in% class(effect_ratio),
                          length(effect_ratio) == 1,
                          msg = "effect_ratio = argument requires a number")


  # generate study-level random effect
  samples <-

    ## this code could be rewritten

    # set a tibble with random vector x_k ~ N(0, tau_sq) for K studies
    # study_error
    #
    # add column of studies
    #
    # add column of control
    # add column of intervention
    # pivot_longer cols = c(control, intervention)
    # names_to = ""
    # values_to = "group"
    #
    # add column of control_indicator = group == "control"

    # take set of sample sizes for studies & arms
    n_df %>%
    # just the control group
    dplyr::filter(group == "control") %>%
    # just select study
    dplyr::select(study) %>%

    # this sampling is then correct
    dplyr::mutate(this_study_error =
                   rnorm(nrow(n_df) / 2, 0, tau_sq) / 2,
    ) %>%
    # join to df
    dplyr::full_join(n_df, by = "study") %>%
    dplyr::mutate(
      control_indicator = group == "control" ,
      sample =
        purrr::pmap(
          list(
            n = n,
            this_study_error = this_study_error,
            control = control_indicator
          ),
          sim_sample,
          rdist = rdist,
          par = par,
          effect_ratio = effect_ratio
        )
    ) %>% dplyr::select(-control_indicator)

  summary_stats <- samples %>%
    dplyr::mutate(
      min = purrr::map_dbl(sample, min),
      max = purrr::map_dbl(sample, max),
      mean = purrr::map_dbl(sample, mean),
      sd = purrr::map_dbl(sample, sd),
      first_q = purrr::map_dbl(sample, quantile, 0.25),
      median = purrr::map_dbl(sample, quantile, 0.5),
      third_q = purrr::map_dbl(sample, quantile, 0.75),
      iqr = third_q - first_q
    ) %>%
    # remove the sample and return the effect stats
    dplyr::select(-sample) %>%
    mutate(effect = !!sym(measure),
           effect_spread = !!sym(measure_spread)) %>%
    select(study, group, effect, effect_spread, n)

  if (!is.data.frame(samples) | nrow(samples) <= 1) {
    summary_stats <- NULL
  } else if (wide == TRUE) {
    summary_stats <- full_join(
      summary_stats %>% filter(group == "control") %>%
        select(-group) %>%
        rename(
          effect_c = effect,
          effect_spread_c = effect_spread,
          n_c = n
        ),
      summary_stats %>%
        filter(group == "intervention") %>%
        select(-group) %>%
        rename(
          effect_i = effect,
          effect_spread_i = effect_spread,
          n_i = n
        ),
    by = "study")}

  return(summary_stats %>% dplyr::arrange(study))
}
