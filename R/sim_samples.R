#' Repeat rows
#'
#' @inheritParams sim_samples
#'
#' @export

sim_trials <- function(sim_dat, trials){
  sim_dat %>%
    dplyr::ungroup() %>%
    dplyr::slice(rep(1:dplyr::n(), trials)) %>%
    dplyr::ungroup()
}

#' Simulate samples
#'
#' Function to repeat rows in sim_df and produces a sample for each
#'
#' @inheritParams sim_stats
#' @param sim_dat Dataframe created by [sim_df].
#' @param trials Number of trials, that is repeated rows to return.
#' Defaults to 3 (small number of trials is good for testing).
#'
#' @export

sim_samples <- function(
  measure = "mean",
  measure_spread = "sd",
  sim_dat,
  trials = 3
  ){

  trials_dat <- sim_trials(sim_dat, trials)

  sim_samples <-
    trials_dat %>%
    dplyr::mutate(
      sample = purrr::pmap(
        list(
          n,
          rdist,
          parameters,
          tau_sq_true,
          effect_ratio
        ),
        function(n, rdist, parameters, tau_sq_true, effect_ratio){ sim_stats(
          measure = measure,
          measure_spread = measure_spread,
          n_df = n,
          wide = TRUE,
          rdist = rdist,
          par = parameters,
          tau_sq = tau_sq_true,
          effect_ratio = effect_ratio
        )}
      )
    )

}



