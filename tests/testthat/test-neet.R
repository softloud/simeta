context("non-empty thing of expected type")

# devtools::install_github("softloud/neet")
library(neet)

# zeta beta ---------------------------------------------------------------
test_prop <- runif(1, 0.3, 0.8)
test_error <- runif(1, 0.1, 0.2)

test_that(
  "beta_par", {
    expect_neet(beta_par(proportion = 0.3, error = 0.2))
  }
)

test_that("intervention_proportion", {
  expect_neet(intervention_proportion(3, 0.5, 0.1))
})

test_that("intervention_proportion", {
  expect_neet(intervention_proportion(4, 0.2, 0.01))
})

test_that("zeta_plot", {

})


# sims data ---------------------------------------------------------------

sims <- metasims(progress = FALSE)

# summary functions -------------------------------------------------------

test_that(
  "coverage_plot", {
    expect_neet(sims %>% coverage_plot())
  }
)

test_that("simpar_table", {

})

test_that("sim_dist", {
  expect_neet(sim_dist(default_parameters))
})

# simulation functions ----------------------------------------------------


test_that(
  "density function", {
    expect_neet(density_fn(0.1, "norm", list(mean = 3, sd = 0.4)))
  }
)

test_that(
  "dist_name", {
    expect_neet_dist_name <- function(dist = dist, toR = FALSE) {
      expect_type(dist_name(dist, toR), "character")
    }
    expect_neet_dist_name("norm")
  }
)

test_that("default_parameters", {
  expect_is(default_parameters, "tbl")
})


test_that("lr_se", {
  expect_neet(lr_se("median", 4, 3, 0.2, 5, 4.1, 0.3))
})

test_that("metamodel", {
  expect_neet(metamodel())
})

test_that("metasim", {
  expect_neet(metasim())
})

test_that("metasims", {
  expect_neet(sims)
})

test_that("metatrial", {
  expect_neet(metatrial())
})

test_that("sim_df", {
  expect_neet(sim_df())
})

test_that("sim_n", {
  expect_neet(sim_n())

})


test_that("sim_sample", {
  expect_neet(sim_sample())
})

test_that("sim_stats", {
  expect_neet(sim_stats())
})

test_that("simulation_methods", {
  # these are methods for summary
})

test_that("simulation_parameters", {
 # not sure about these
})

test_that("singletrial", {
  expect_neet(singletrial())
})

test_that("tidy_sim", {
  expect_neet(pinheiro_data %>% metafor::rma(yi = m_c, vi = s_c_d, data = .))
})

test_that("toss", {
  # don't think I need this function
})
