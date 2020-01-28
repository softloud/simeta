# what plots are there

library(simeta)

# get a sim
# sim <- metasims()


# plots -------------------------------------------------------------------

sim %>%
  coverage_plot()

sim %>%
  pluck("distributions") %>%
  sim_dist()

sim %>%
  pluck("distributions") %>%
  sim_dist(output = "table")

sim %>%
  simpar_table()

