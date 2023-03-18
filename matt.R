library(simeta)
library(tidyverse)

sim_dat <-
  sim_df(
  # different effect sizes
  # what is small, medium large effect
  effect_ratio = c(1, 1.1, 1.5, 2),
  # what is small medium large variance
  tau2 = c(0, 0.1, 0.5, 1),
  min_n = 5,
  max_n = 150
)

# repeat each row for number of trials per parameter
trials = 20

trials_dat <- sim_dat %>%
  ungroup() %>%
  slice(rep(1:n(), trials))

sim_samples <-
trials_dat %>%
  mutate(
    sample = pmap(
      list(
        measure = "mean",
        measure_spread = "sd",
        n_df = n,
        wide = TRUE,
        rdist,
        parameters,
        tau_sq_true,
        effect_ratio
      ),
      sim_stats
    )
  )


sim_metafor <-
  sim_samples %>%
  mutate(
    rma = map(sample,
      function(x) {
        rma(data = x,
          measure = "SMD",
          m1i = effect_c,
          sd1i = effect_spread_c,
          n1i = n_c,
          m2i = effect_i,
          sd2i = effect_spread_i,
          n2i = n_i
            )}

      )
  ) %>%
  # extract pvalues
  mutate(
    p_val = map_dbl(rma, pluck, "pval")
  )


# calculate proportions
sim_metafor %>%
  group_by(k)

# add sample size
sim_metafor %>%
  mutate(
    dist = map_chr(rdist, dist_name)
  ) %>%
  ggplot(
    aes(x = p_val, fill = dist)
  ) +
  geom_vline(xintercept = 0.05, linetype = "dotted", show.legend = TRUE) +
  geom_histogram(alpha = 0.7, bins = 19) +
  facet_grid(effect_ratio + tau_sq_true ~ k) +
  theme_minimal(base_size = 20, base_family = "serif") +
  labs(
    title = "Simulated meta-analysis p-value distributions",
    subtitle = "For simulated studies (3, 7, 20) with effect ratios (1, 1.1, 1.5, 2) and variation between studies (0, 0.1, 0.5)" %>%
      str_wrap(),
    x = "P-value",
    y = "Count",
    caption = sprintf("Dotted line represents 0.05 signficance. %d simulations run for each parameter set.", trials)
  ) +
  theme(panel.grid = element_blank(),
    axis.text = element_blank(),
    legend.position = "top"
  ) +
  scale_fill_brewer("Sampling Distribution", palette = "Dark2")



