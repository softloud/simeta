# what plots are there

library(simeta)
library(cowplot)

# get a sim
sim <- metasims()


# plots -------------------------------------------------------------------

plot_grid(
  sim %>%
    coverage_plot()
)


sim %>%
  pluck("distributions") %>%
  sim_dist()

sim %>%
  pluck("distributions") %>%
  sim_dist(output = "table")

sim %>%
  simpar_table()

