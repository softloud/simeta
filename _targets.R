library(targets)
library(simeta)
library(tidyverse)
library(assertthat)
library(latex2exp)

# This is an example _targets.R file. Every
# {targets} pipeline needs one.
# Use tar_script() to create _targets.R and tar_edit()
# to open it again for editing.
# Then, run tar_make() to run the pipeline
# and tar_read(summary) to view the results.

# Define custom functions and other global objects.
# This is where you write source(\"R/functions.R\")
# if you keep your functions in external scripts.

paste_parameter_label <- function(a_vector) {
  paste0(a_vector, collapse = ", ")
}


# Set target-specific options such as packages:
# tar_option_set(packages = "utils") # nolint

# End this file with a list of target objects.
list(
  # set simulation parameters
  tar_target(trials,
             100),
  tar_target(sim_effect_ratio,
             c(1, 1.1, 1.5)),

  tar_target(sim_tau_sq,
             c(0, 0.05, 0.5)),

  tar_target(study_n_range,
             list(min = 5,
                  max = 150)),

  # generate simulation parameter dataframe
  tar_target(
    par,
    sim_df(
      dist_df = default_parameters,
      tau_sq = sim_tau_sq,
      effect_ratio = sim_effect_ratio,
      min_n = study_n_range$min,
      max_n = study_n_range$max,
      prop_error = 0.3
    )
  ),

  tar_target(trials_df,
             # Repeats the number of rows by trials
             sim_trials(par, trials)),

  tar_target(
    # check trials dataframe has correct number of rows
    trials_check,
    assert_that(
      nrow(par) * trials == nrow(trials_df),
      msg = "Number of rows in parameter df does not equal trials x
                number of
      rows in parameter df."
    )
  ),

  tar_target(
    samples,
    sim_stats(
      measure = "mean",
      measure_spread = "sd",
      # how to iterate over dataframe?
      n_df = trials_df %>% pluck("n", 1),
      wide = TRUE,
      rdist = trials_df %>% pluck("rdist", 1),
      par = trials_df %>% pluck("parameters", 1),
      tau_sq = trials_df %>% pluck("tau_sq_true", 1),
      effect_ratio = trials_df %>% pluck("effect_ratio", 1)
    ),
    pattern = map(trials_df),
    iteration = "list"
  ),

  tar_target(samples_check,
             assert_that(length(samples) == nrow(trials_df))),

  tar_target(
    models,
    tryCatch(
      metafor::rma(
        data = samples,
        measure = "SMD",
        m1i = effect_c,
        sd1i = effect_spread_c,
        n1i = n_c,
        m2i = effect_i,
        sd2i = effect_spread_i,
        n2i = n_i
      ),
      #if an error occurs, tell me the error
      error = function(e) {
        message('An Error Occurred')
        print(e)
        return(e)
      },
      #if a warning occurs, tell me the warning
      warning = function(w) {
        message('A Warning Occurred')
        print(w)
        return(w)
      }
    )
    ,
    pattern = map(samples),
    iteration = "list"

  ),

  tar_target(p_values,
             if ("pval" %in% objects(models))
             {
               p_value <- models %>% pluck("pval")

             } else {p_value <- 100},
             pattern = map(models),
             iteration = "vector"),

  tar_target(
    trial_results_raw,
    trials_df %>%
      # calculate total participant size
      mutate(participants = map_int(n,
                                    ~ sum(.x$n))) %>%
      select(-n) %>%
      mutate(
        # append model results of interest
        p_value = p_values,
        # create some plot labels
        dist_label = map_chr(rdist, dist_name),
        study_n_label = sprintf("%d studies", k) %>%
          fct_relevel("3 studies", "7 studies")
      ) %>%
      # filter sims that didn't converge
      filter(p_value != 100)

  ),

  tar_target(trial_results,
             # overwrite common variables with labellers
             trial_results_raw),

  tar_target(
    sim_props,
    trial_results %>%
      group_by(study_n_label) %>%
      mutate(x = quantile(participants, 0.5)) %>%
      group_by(x,
               study_n_label,
               tau_sq_true,
               effect_ratio) %>%
      summarise(sig = sum(p_value < 0.05) / n(), ) %>%
      mutate(label = str_c(round(sig * 100), "% significant"),
             y = 0.5)
  ),

  tar_target(
    sim_vis_foundation,
    trial_results %>%
      ggplot(aes(
        x = participants,
        y = p_value,
        colour = dist_label
      )) +
      geom_hline(yintercept = 0.05,
                 linetype = "dotted") +
      geom_text(
        data = sim_props,
        aes(x = x, y = y, label = label),
        size = 5,
        alpha = 0.3,
        colour = "black"
      ) +
      geom_point(alpha = 0.2) +
      geom_point(alpha = 0.6,
                 data = trial_results %>% filter(p_value < 0.05)) +
      facet_grid(effect_ratio + tau_sq_true ~ study_n_label,
                 scales = "free_x")
  ),

  tar_target(sim_vis,
             {
               this_plot <-
                 sim_vis_foundation +
                 theme_minimal(base_size = 10, base_family = "serif") +
                 labs(
                   title = "Simulated meta-analysis p-values and sample sizes",
                   subtitle = sprintf(
                     "For simulated studies, (%s), with effect ratios
    (%s) and variation between studies (%s)",
                     paste_parameter_label(unique(trial_results$k)),
                     paste_parameter_label(sim_effect_ratio),
                     paste_parameter_label(sim_tau_sq)
                   ) %>%
                     str_wrap(),
                   x = "Total number of participants in meta-analysis",
                   y = "P-value",
                   caption = sprintf(
                     "Dotted line represents 0.05 signficance. %d simulations
                      for each parameter set. The percentage of trials with
                      p-values less than 0.05 is displayed in text in each grid
                      of the plot, representing a parameter set.
                      Each point represents one
                     simulation of total sample size,
                     represented in the x-axis, and
                     p-value, in the y-axis, for a given number of studies,
                     effect ratio, and variation between studies. See the
                     sampling distributions table for distribution parameters.",
                     trials
                   ) %>% str_wrap()
                 ) +
                 scale_color_brewer("Sampling distribution", palette = "Dark2") +
                 theme(
                   strip.text.y = element_text(angle = 0),
                   panel.grid = element_blank(),
                   axis.text.y = element_blank(),
                   legend.position = "top"
                 ) + ylim(-0.05, 1)

               ggsave("man/figures/example_sim.png", this_plot)
               write_rds(this_plot, "example_plot.rds")
             }),


  NULL
)
