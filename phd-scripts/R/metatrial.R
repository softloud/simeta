#' Generate meta-analysis data and calculate estimator
#'
#' Simulate data based on simulation parameters and meta-analyse.
#'
#' NB: bias is effect - true effect.
#'
#' @param log(effect_ratio) The value of the control population median.
#' @inheritParams sim_stats
#' @param test "knha" or "z" for [metafor::rma].
#'
#' @family neet_test_one One neet test has been written
#' @family simulation Functions that contribute to simulation pipeline.
#'
#' @export

metatrial <- function(measure = "median",
                      measure_spread = "iqr",
                      tau_sq = 0.6,
                      effect_ratio = 1.2,
                      rdist = "norm",
                      parameters = list(mean = 50, sd = 0.2),
                      n_df = sim_n(k = 3)) {

  # set up simulation -------------------------------------------------------
  measure_label <- paste0("lr_", measure)

  # simulate data
  metadata <-
    sim_stats(
      measure = measure,
      measure_spread = measure_spread,
      n_df = n_df,
      rdist = rdist,
      par = parameters,
      tau_sq = tau_sq,
      effect_ratio = effect_ratio,
      wide = TRUE
    ) %>%
    # append estimators
    mutate(
      effect_se_c = pmap_dbl(
        list(
          centre = effect_c,
          spread = effect_spread_c,
          n = n_c
        ),
        varameta::effect_se,
        centre_type = measure,
        spread_type = measure_spread
      ),
      effect_se_i = pmap_dbl(
        list(
          centre = effect_i,
          spread = effect_spread_i,
          n = n_i
        ),
        varameta::effect_se,
        centre_type = measure,
        spread_type = measure_spread
      ) ,
      lr = log(effect_i / effect_c),
      # to do: have a look at variance for log-ratio of means, might just
      # need to specify this component for means if else
      lr_se = pmap_dbl(
        list(
          measure = measure,
          n_c = n_c,
          effect_c = effect_c,
          effect_se_c = effect_se_c,
          n_i = n_i,
          effect_i = effect_i,
          effect_se_i = effect_se_i
        ),
        .f = lr_se
      ),
      lr_var = lr_se ^ 2
    )

  metamodel <-
    tryCatch(
      metafor::rma(
        yi = lr,
        vi = lr_var,
        data = metadata,
        test = "knha"
      ),
      warning = function(x) {
        NULL
      },
      error = function(x) {
        NULL
      }
    )

  if (is.null(metamodel)) {
    return(NULL)
  } else {
    model_summary <-
      metamodel %>%
      broom::tidy() %>%
      dplyr::mutate(
        ci_lb = estimate - std.error * qnorm(0.975),
        ci_ub = estimate + std.error * qnorm(0.975),
        tau_sq = metamodel %>% broom::glance() %>% purrr::pluck("tau.squared"),
        covered = log(effect_ratio) > ci_lb &
          log(effect_ratio) < ci_ub,
        bias = abs(estimate - log(effect_ratio))
      ) %>%
      dplyr::select(effect = estimate, ci_lb, ci_ub, tau_sq, covered, bias)

    return(model_summary)
  }
}
