#' Aggregate plots of simulation results
#'
#' @param sim Simulation results of the type produced by [metasims].
#'
#' @importFrom cowplot plot_grid
#'
#' @family vis_tools
#'
#' @export

metaplot <- function(sim, coverage = TRUE) {

  # plots -------------------------------------------------------------------

covplot <- sim %>%
  coverage_plot()

distplot <- sim %>%
  pluck("distributions") %>%
  sim_dist()

disttable <- sim %>%
  pluck("distributions") %>%
  sim_dist(output = "table")

simpar <- sim %>%
  simpar_table()

if (isTRUE(coverage)) {
  cowplot::plot_grid(simpar, covplot, #disttable, distplot,
                     labels = letters[1:2],
                     rel_widths = c(0.4, 1),
                     label_size = 12)

} else {
  cowplot::plot_grid(distplot, disttable,
                     labels = letters[1:2],
                     ncol = 1,
                     rel_widths = c(0.5, 1),
                     label_size = 12)
}

}
