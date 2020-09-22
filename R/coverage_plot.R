#' Plot a coverage simulation for a single estimator
#'
#' @param metasims_output A data.frame produced by [metasims].
#'
#' @family vis_tools
#' @family reporting Functions and tools for reporting simulation results.
#'
#' @export

coverage_plot <- function(metasims_output) {
  assertthat::assert_that("metasim" %in% class(metasims_output))

  # get trials
  trials <-
    metasims_output %>%
    purrr::pluck("arguments") %>%
    dplyr::filter(argument == "trials") %>%
    purrr::pluck("value")

  distns <-
    metasims_output %>%
    purrr::pluck("distributions") %>%
    tibble::as_tibble() %>%
    dplyr::mutate(plot_label_dist = #"test"
                    purrr::map2_chr(dist, par, dist_label)) %>%
    dplyr::group_by(dist) %>%
    dplyr::mutate(grouping = 1:dplyr::n())

  shape_labels <-
    distns %>%
    dplyr::ungroup() %>%
    dplyr::select(plot_label_dist, grouping) %>%
    dplyr::group_split(grouping) %>%
    purrr::map(1) %>%
    purrr::map(paste, collapse = ", ") %>%
    tibble::tibble(shape_label = .) %>%
    dplyr::mutate(shape_label = as.character(shape_label),
                  grouping = dplyr::row_number()
    ) %>%
    dplyr::left_join(distns, by = "grouping") %>%
    dplyr::select(-grouping)

  metasims_output %>%
    purrr::pluck("results") %>%
    dplyr::mutate(Distribution = purrr::map_chr(rdist, dist_name),
                  effect_ratio = dplyr::if_else(
                    effect_ratio == 1,
                    sprintf("equal: %g", effect_ratio),
                    sprintf("unequal: %g", effect_ratio)
                  )) %>%
    dplyr::left_join(shape_labels,
                     by = c("rdist"= "dist",
                            "parameters" ="par")) %>%
    ggplot2::ggplot(ggplot2::aes(x = Distribution, y = coverage)) +
    ggplot2::geom_hline(yintercept = 0.95,
                        linetype = "dotted",
                        alpha = 0.4,
    ) +
    ggplot2::geom_jitter(
      alpha = 0.6,
      size = 4,
      height = 0,
      width = 0.25,
      ggplot2::aes(colour = effect_ratio,
                   shape = shape_label)
    ) +
    ggplot2::facet_grid(tau_sq_true ~ k) +
    hrbrthemes::scale_colour_ipsum("Effect ratio") +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(angle = 30, hjust = 1),
      legend.position = "bottom",
      legend.direction = "vertical") +
    ggplot2::labs(
      y = "Coverage",
      title = "Coverage probability simulation results",
      caption = stringr::str_wrap(
        "A small amount of random horizontal displacement has been applied. The dotted line indicates 0.95, the ideal result for this
          coverage probability simulation. *A meta-analytic random sample comprises K
      pairings of intervention and control groups, where there is random
      error associated with both the study's context and the variability.
      See the R package
      simeta:: for more details. ",
        90
      ),
      subtitle = stringr::str_wrap(
        paste0(
          "Each point represents the proportion of ",
          trials,
          " trials wherein the true
      effect ratio falls within the confidence interveral calculated from a
      meta-analytic random sample* from a given distribution,
      distributional parameter set, variance between studies (plot rows), and number of studies (plot columns)."
        )
        ,
        80
      )
    ) +
    ggplot2::scale_shape_discrete(name = "Distribution")
}

#' Study heterogeneity and confidence interval width
#'
#' Extension of [coverage_plot].
#'
#' @export

variance_plot <- function(metasims_output) {
  assertthat::assert_that("metasim" %in% class(metasims_output))

  # get trials
  trials <-
    metasims_output %>%
    purrr::pluck("arguments") %>%
    dplyr::filter(argument == "trials") %>%
    purrr::pluck("value")

  distns <-
    metasims_output %>%
    purrr::pluck("distributions") %>%
    tibble::as_tibble() %>%
    dplyr::mutate(plot_label_dist = #"test"
                    purrr::map2_chr(dist, par, dist_label)) %>%
    dplyr::group_by(dist) %>%
    dplyr::mutate(grouping = 1:dplyr::n())

  shape_labels <-
    distns %>%
    dplyr::ungroup() %>%
    dplyr::select(plot_label_dist, grouping) %>%
    dplyr::group_split(grouping) %>%
    purrr::map(1) %>%
    purrr::map(paste, collapse = ", ") %>%
    tibble::tibble(shape_label = .) %>%
    dplyr::mutate(shape_label = as.character(shape_label),
                  grouping = dplyr::row_number()
    ) %>%
    dplyr::left_join(distns, by = "grouping") %>%
    dplyr::select(-grouping)

  metasims_output %>%
    purrr::pluck("results") %>%
    dplyr::mutate(Distribution = purrr::map_chr(rdist, dist_name),
                  effect_ratio = dplyr::if_else(
                    effect_ratio == 1,
                    sprintf("equal: %g", effect_ratio),
                    sprintf("unequal: %g", effect_ratio)
                  )) %>%
    dplyr::left_join(shape_labels,
                     by = c("rdist"= "dist",
                            "parameters" ="par")) %>%
    ggplot2::ggplot(ggplot2::aes(x = log(ci_width), y = log(tau_sq))) +
    ggplot2::geom_point(
      alpha = 0.3,
      size = 6,
      ggplot2::aes(colour = Distribution,
                   shape = shape_label)
    ) +
    ggplot2::geom_point(
      ggplot2::aes(size = effect_ratio),
      alpha = 0.2
    ) +
    ggplot2::scale_size_discrete(range = c(0.2, 1.5)) +

    ggplot2::facet_grid(tau_sq_true ~ k, scales = "free") +
    hrbrthemes::scale_colour_ipsum("Effect ratio") +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(angle = 30, hjust = 1),
      legend.position = "bottom",
      legend.direction = "vertical") +
    ggplot2::labs(
      y = latex2exp::TeX("Log mean estimated study heterogeneity"),
      x = latex2exp::TeX("Log mean confidence interval width"),
      title = "Simulation mean estimates for study heterogeneity by confidence interval width",
      caption = stringr::str_wrap(
        "*A meta-analytic random sample comprises K
      pairings of intervention and control groups, where there is random
      error associated with both the study's context and the variability.
      See the R package
      simeta:: for more details. ",
        90
      ),
      subtitle = stringr::str_wrap(
        paste0(
          "This visualisation does not have fixed axes for the plot columns and plot rows, the plots are scaled do the data in the group. Each point represents the mean estimates of study heterogeneity and mean confidence interval width, over ",
          trials,
          " trials from a given distribution,
      distributional parameter set, variance between studies (plot rows), and number of studies (plot columns)."
        )
        ,
        80
      )
    ) +
    ggplot2::scale_shape_discrete(name = "Distribution")

}
