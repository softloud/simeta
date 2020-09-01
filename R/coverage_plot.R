#' Plot a coverage simulation for a single estimator
#'
#' @param metasims_results A data.frame produced by [metasims].
#'
#' @family vis_tools
#' @family reporting Functions and tools for reporting simulation results.
#'
#' @export

coverage_plot <- function(metasims_results) {
  assertthat::assert_that("metasim" %in% class(metasims_results))

  # get trials
  trials <-
    metasims_results %>%
    purrr::pluck("arguments") %>%
    dplyr::filter(argument == "trials") %>%
    purrr::pluck("value")

  metasims_results %>%
    purrr::pluck("results") %>%
    # this is a hack
    # dplyr::filter(measure == "lr_median") %>%
    dplyr::mutate(
      plot_par = purrr::map(parameters, .f = function(par) {
        par %>% purrr::map_dbl(pluck) %>% round(digits = 2)
      }) ,
      Distribution = purrr::map_chr(rdist, dist_name),
      plot_label = stringr::str_replace(plot_par, "c\\(", "") %>%
        stringr::str_replace("\\)", "") %>%
        stringr::str_c(Distribution, ., sep = " ")
    ) %>%
    ggplot2::ggplot(ggplot2::aes(x = Distribution, y = coverage)) +
    ggplot2::geom_hline(yintercept = 0.95,
                        linetype = "dotted",
                        alpha = 0.4,) +
    # ggrepel::geom_text_repel(
    #   min.segment.length = 1,
    #   colour = "darkgrey",
    #   force = 3,
    #   size = 2.2,
    #   segment.alpha = 0.5,
    #   ggplot2::aes(label = plot_label)
    # ) +
    ggplot2::geom_point(
      position = "jitter",
      alpha = 0.4,
      size = 4,
      ggplot2::aes(colour = effect_ratio,
                   shape = plot_label)
    ) +
    ggplot2::facet_grid(k ~ tau_sq_true) +
    hrbrthemes::scale_color_ipsum() +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 30, hjust = 1)) +
    # ggplot2::scale_y_log10(
    #   n.breaks = 5,
    #   breaks = scales::trans_breaks("log10", function(x)
    #     10 ^ x),
    #   labels = scales::trans_format("log10", scales::math_format(10 ^ .x))
    # )  +
    ggplot2::labs(
      y = "Coverage",
      title = "Coverage probability simulation results",
      caption = stringr::str_wrap(
        "*A meta-analytic random sample comprises K
      pairings of intervention and control groups, where there is random
      error associated with both the study's context and the variability.
      See the R package
      simeta:: for more details.",
        90
      ),
      subtitle = stringr::str_wrap(
        paste0(
          "Each point represents the proportion of ",
          trials,
          " trials wherein the true
      effect ratio falls within the confidence interveral calculated from a
      meta-analytic random sample* from a given distribution,
      distributional parameter set, variance between studies (facet columns), and number of
      studies (facet rows). The dotted line indicates 0.95, the ideal result for this
          coverage probability simulation."
        )
        ,
        80
      )
    ) +
    ggplot2::scale_shape_discrete(name = "Effect ratio")
}
