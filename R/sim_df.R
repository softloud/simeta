#' generate simulation parameter dataframe
#'
#'
#' @param dist_df A `tibble::tribble`.
#' with one column for distribution, and one column for the parameters.
#' Defaults to [default_parameters]. Note that the `par` arguments can be
#' changed, but only the distributions presented in [default_parameters] have
#' been implemented.
#' @inheritParams sim_n
#' @param k Vector of desired numbers studies to simulate for.
#' @param k Simulate for different numbers of studies.
#' @param tau_sq Variance \eqn{\gamma_k \sim N(0, \tau^2)} associated with the random effect
#' @param effect_ratio Ratio of population effects intervention / control
#'
#' @import purrr
#' @import tibble
#' @import dplyr
#'
#' @family simulation Functions that contribute to simulation pipeline.
#'
#' @export


sim_df <- function(
  # simulation-level parameters
  dist_df = default_parameters,
  k = c(3, 7, 20),
  tau_sq = seq(0, 0.4, by = 0.2),
  effect_ratio = c(1, 1.2, 1.5),
  # arguments for sample sizes
  min_n = 20,
  max_n = 200,
  prop = 0.5,
  prop_error = 0.1) {



# body --------------------------------------------------------------------

  dist_df %>%
    dplyr::mutate(distribution =
                    purrr::map2(dist, par,
                                function(x, y) {
                                  list(dist = x, par = y)
                                })) %>%
    purrr::pluck("distribution") %>% {
      purrr::cross_df(
        list(
          distribution = .,
          k = k,
          tau_sq_true = tau_sq,
          effect_ratio = effect_ratio
        )
      )
    } %>%
    dplyr::mutate(
      rdist = purrr::map_chr(distribution, "dist"),
      parameters = purrr::map(distribution, "par")
    )  %>%
    dplyr::select(-distribution) %>%
    dplyr::mutate(n = purrr::map(k,
                                 sim_n,
                                 min_n = min_n,
                                 max_n = max_n,
                                 prop = prop,
                                 prop_error = prop_error),
                sim_id = paste("sim", seq(1, nrow(.))))

}
