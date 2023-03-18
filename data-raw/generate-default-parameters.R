library(tidyverse)

set.seed(40)

# todo, extra distributions
fixed_par <-
  tribble(
    ~dist,     ~par,
    "pareto", list(shape = 2, scale = 1),
    "norm",    list(mean = 50, sd = 17),
    "lnorm",   list(meanlog = 4, sdlog = 0.3),
    # "beta",    list(shape1 =9, shape2 = 4),
    "exp",     list(rate = 10),
    # "weibull", list(shape = 2, scale = 35)
  )

random_par <-
  tribble(
    ~dist,      ~par,
    "pareto",   list(shape = runif(1, min = 0.5, max = 5),
                     scale = runif(1, min = 1, max = 3)),
    "norm",     list(mean = runif(1, min = 20, max = 100),
                     sd = runif(1, min = 5, max = 20)),
    "lnorm",    list(mean = runif(1, min = 2, max = 4),
                     sd = runif(1, min = 0.2, max = 0.5)),
    "exp",      list(rate = runif(1, min = 1, max = 20))# ,
    # "beta", list(shape1 = runif(1,1,10), shape2 = runif(1,1,10)),
    # "weibull", list(shape = runif(1, 3, 5), scale = runif(1, 5, 50))

  )


default_parameters <-
  bind_rows(fixed_par, random_par)

usethis::use_data(default_parameters, overwrite = TRUE)
