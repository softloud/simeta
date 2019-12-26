#' Plot a coverage simulation for a single estimator
#'
#' @param results_df A data.frame produced by [metasims].
#'
#' @family vis_tools
#'
#' @export

coverage_plot <- function(results_df) {
  results_df %>%
    purrr::pluck("results") %>%
    dplyr::mutate(Distribution = map_chr(rdist, dist_name),
                  Effect_ratio = map_chr(effect_ratio,
                                         .f = function(x) {
                                           dplyr::if_else(is.na(x),
                                                          x,
                                                          as.character(as.numeric(x)))
                                         })) %>%
    ggplot2::ggplot(ggplot2::aes(x = Distribution, y = coverage)) +
    ggplot2::geom_point(position = "jitter",
                        alpha = 0.5,
                        size = 4,
                        ggplot2::aes(colour = Distribution,
                                     shape = Effect_ratio)) +
    ggplot2::facet_grid(k ~ tau_sq_true) +
    hrbrthemes::scale_color_ipsum() +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(angle = 30, hjust = 1)
    ) +
    ggplot2::labs(
      y = "Coverage",
      title = "Coverage probability simulation results",
      caption = stringr::str_wrap("*A meta-analytic random sample comprises K
      pairings of intervention and control groups, where there is random
      error associated with both the study's context and the variability.
      See the R package
      simeta:: for more details.", 130),
      subtitle = stringr::str_wrap(
      "Each point represents the proportion of trials wherein the true
      effect ratio falls within the confidence interveral calculated from a
      meta-analytic random sample* from a given distribution,
      distributional parameter set, variance between studies (facet columns), and number of
      studies (facet rows).", 120)
    ) +
    ggplot2::scale_shape_discrete(name = "Effect ratio")
}
