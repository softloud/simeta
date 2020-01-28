# what plots are there

library(simeta)

# get a sim
# sim <- metasims()


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

library(cowplot)
plot_grid(covplot, simpar, #disttable, distplot,
          labels = letters[1:2],
          rel_widths = c(1, 0.3),
           label_size = 12)

plot_grid(distplot, disttable,
          labels = letters[1:2],
          rel_widths = c(1, 0.6),
          label_size = 12)
