#' Coverage Simulation Plot
#'
#' This provides a coverage plot for a simulation of one estimator.
#'
#' @param sims A simulation object produced by [metasims].
#'
#' @export

coverage_plot <- function(sims) {
  # basic scatterplot
  sims %>%
    pluck("results") %>%
    mutate(Distribution = map_chr(rdist, dist_name)) %>%
    ggplot(aes(x = Distribution,
               y = coverage,
               colour = Distribution)) +
    geom_point(
      position = "jitter",
      alpha = 0.6) +
    facet_grid(tau_sq_true ~ k) +
    theme(axis.text.x =
            element_text(
              hjust = 1,
              angle = 30)) +
    labs(
      y = "Coverage",
      title = "Coverage simulation plot",
      subtitle = "More informative stuff should go here",
      caption = "Perhaps I can put simulation parameters here"
    ) +
    hrbrthemes::scale_color_ipsum()

}
