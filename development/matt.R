library(simeta)
library(tidyverse)
library(targets)

tar_load(trial_results)
tar_load(trials)
tar_load(sim_tau_sq)
tar_load(sim_effect_ratio)

paste_parameter_label <- function(a_vector) {
  paste0(a_vector, collapse = ", ")
}


trial_results %>%
  ggplot(
    aes(
      x = participants,
      y = p_value,
      colour = dist_label
    )
  ) +
  geom_hline(
    yintercept = 0.05,
    linetype = "dotted"
  ) +
  geom_point(
    alpha = 0.2
  ) +
  geom_point(
    alpha = 0.6,
    data = trial_results %>% filter(p_value < 0.05)
  ) +
  facet_grid(effect_ratio + tau_sq_true ~ study_n_label,
             scales = "free_x") +
  theme_minimal(base_size = 20, base_family = "serif") +
labs(
  title = "Simulated meta-analysis p-values and sample sizes",
  subtitle = sprintf("For simulated studies, (%s), with effect ratios
    (%s) and variation between studies (%s)",
                     paste_parameter_label(
                       unique(trial_results$k)
                     ),
                     paste_parameter_label(sim_effect_ratio),
                     paste_parameter_label(sim_tau_sq)) %>%
    str_wrap(),
  x = "Total number of participants in meta-analysis",
  y = "P-value",
  caption = sprintf("Dotted line represents 0.05 signficance. %d simulations
                      for each parameter set.", trials) %>% str_wrap(120)
) +
  scale_color_brewer("Sampling Distribution", palette = "Dark2") +
  theme(strip.text.y = element_text(
    angle = 0
  ),
    panel.grid = element_blank(),
        axis.text.y = element_blank(),
        legend.position = "top"
  )
