#' Summarise sampling distributions
#'
#' Provides plot or table summary of distributions dampled from in [metasims].
#'
#' @param parameter_tibble A tibble in the format of [default_parameters], with
#' a column for distributions, R-friendly format ("norm", "lnorm"), and
#' parameters as a list-column.
#' @param output Specify "plot" or "table".
#'
#' @examples
#' sim_dist(default_parameters)
#' sim_dist(default_parameters, output = "table")
#'
#' @family metapar Simulation metaparameter functions.
#' @family vis_tools
#'
#' @export

sim_dist <- function(parameter_tibble,
                     x_values = seq(0, 2, by = 0.001),
                     output = "plot") {
  density_data <-
    parameter_tibble %>%
    dplyr::mutate(
      sim_id = letters[seq(1:nrow(parameter_tibble))],
      Distribution = map_chr(dist, .f = dist_name),
      par_string = stringr::str_sub(as.character(par), start = 5, end = -1)
    ) %>%
    dplyr::mutate(Parameters = map2_chr(
      Distribution,
      par_string,
      .f = function(d, p) {
        paste0(d, p)
      }
    )) %>%
    dplyr::full_join(purrr::cross_df(list(sim_id = letters[seq(1:nrow(parameter_tibble))],
                                          x = x_values)),
                     by = "sim_id") %>%
    dplyr::mutate(y = pmap_dbl(
      list(x, dist, par),
      .f = function(x, d, p) {
        density_fn(x, d, p, type = "d")
      }
    ))

  label_data <- (density_data %>%
                   dplyr::filter(x == 0.5))


  density_plot <-
    density_data %>%
    ggplot2::ggplot(ggplot2::aes(x = x, y = y, group = sim_id)) +
    ggplot2::geom_line(aes(colour = Distribution)) +
    ggplot2::facet_grid(Distribution ~ ., scales = "free") +
    hrbrthemes::scale_colour_ipsum("Distribution") +
    ggplot2::theme(axis.title = ggplot2::element_blank(),
                   legend.position = "none") +
    ggrepel::geom_text_repel(ggplot2::aes(label = Parameters),
                             alpha = 0.6,
                             data = label_data) +
    ggplot2::labs(
      title = "Distributions Sampled"
    )

  density_table <- density_data %>%
    dplyr::filter(x == 0) %>%
    select(Distribution, Parameters) %>%
    ggpubr::ggtexttable(rows = NULL)

  if (output == "plot") {
    density_plot
  } else if (output == "table") {
    density_table
  } else {
    "output can be plot or table"
  }

}
