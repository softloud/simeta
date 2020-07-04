#' generate simulation parameter dataframe
#'
#'
#' @param dist_tribble A \code{\link{tibble::tribble}}
#' with one column for distribution, and one column for the parameters
#' @inheritParams sim_n
#' @inheritParams metasims
#'
#' @import purrr
#' @import tibble
#' @import dplyr
#'
#' @family simulation Functions that contribute to simulation pipeline.
#' @family neet_test_one One neet test has been written
#'
#' @export


sim_df <- function(
  # simulation-level parameters
  dist_tribble = default_parameters,
  k = c(3, 7, 20),
  tau2 = seq(0, 0.4, by = 0.2),
  effect_ratio = c(1, 1.2),
  # arguments for sample sizes
  min_n = 20,
  max_n = 200,
  prop = 0.5,
  prop_error = 0.1) {


# check inputs ------------------------------------------------------------

  neet::assert_neet(dist_tribble, "data.frame")
  neet::assert_neet(k, "numint")
  neet::assert_neet(tau2, "numeric")
  neet::assert_neet(effect_ratio, "numeric")
  neet::assert_neet(min_n, "numint")
  neet::assert_neet(max_n, "numint")
  neet::assert_neet(prop, "numeric")
  neet::assert_neet(prop_error, "numeric")

# body --------------------------------------------------------------------


# this_works <-
  dist_tribble %>%
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
          tau_sq_true = tau2,
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
                sim_id = paste("sim", seq(1, nrow(.)))) %>%
    dplyr::mutate(true_effect =
                    purrr::map2_dbl(
                      rdist,
                      parameters,
                      .f = function(rdist, parameters) {
                        if (rdist == "pareto") {
                          actuar::qpareto(0.5,
                                           shape = parameters[[1]],
                                           scale = parameters[[2]])
                        } else {
                          density_fn(
                            x = 0.5,
                            distribution = rdist,
                            parameters = parameters,
                            type = "q"
                          )
                        }
                      }
                    ))
}
