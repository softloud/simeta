#' Aggregate plots of simulation results
#'
#' @param sim Simulation results of the type produced by [metasims].
#'
#' @importFrom cowplot plot_grid
#'
#' @export

metaplot <- function(type = "coverage") {

  # plots -------------------------------------------------------------------

covplot <- sim %>%
  coverage_plot()

distplot <- sim %>%
  pluck("distributions") %>%
  sim_dist()

disttable <- sim %>%
  pluck("distributions") %>%
  sim_dist(output = "table")

distplot <- sim %>%
  pluck("distributions") %>%
  sim_dist()


simpar <- sim %>%
  simpar_table()

if (type = "coverage") {
  cowplot::plot_grid(covplot, simpar, #disttable, distplot,
                     labels = letters[1:2],
                     rel_widths = c(1, 0.3),
                     label_size = 12)

} else {
  cowplot::plot_grid(distplot, disttable,
                     labels = letters[1:2],
                     rel_widths = c(1, 0.6),
                     label_size = 12)
}

}
