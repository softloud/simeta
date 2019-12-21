#' Plot a coverage simulation for a single estimator
#'
#' @param results_df A data.frame produced by [metasims].
#'
#' @family vis_tools
#'
#' @export

coverage_plot <- function(results_df) {
  results_df %>%
    ggplot(aes(x = rdist, y = coverage)) +
    geom_point(position = "jitter",
               aes(
                 colour = rdist,
                 shape = effect_ratio
               )) +
    facet_grid(k ~ tau_sq_true) +
    hrbrthemes::scale_color_ipsum()
}



