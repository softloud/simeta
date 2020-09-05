#' one row, one simulations
#'
#' runs on one row, returns coverage probability
#'
#' @param trial_fn the function to repeat
#' @param trials the number of trials per simulation
#' @param ... \code{trial_fn} arguments, i.e., simulation nparameters
#' @inheritParams metatrial
#'
#' @family neet_test_one One neet test has been written
#' @family simulation Functions that contribute to simulation pipeline.
#'
#' @export

metasim <- function(...,
                    id = "simulation1",
                    trial_fn = metatrial,
                    trials = 4) {

  neet::assert_neet(id, "character")
  neet::assert_neet(trial_fn, "function")
  neet::assert_neet(trials, "numint")

  all_trials <-
    # map_peacefully(1:trials, .f = function(x) {trial_fn(...)})
    map_df(1:trials, .f = function(x) {trial_fn(...)})

  results <-
    all_trials %>%
    dplyr::summarise(
      tau_sq = mean(tau_sq),
      ci_width = mean(ci_ub - ci_lb),
      bias = mean(bias),
      coverage = sum(covered) / length(covered)
    ) %>%
    mutate(sim_id = id)

  return(results)

}
