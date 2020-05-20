context("neet: non-empty thing of expected type")

# devtools::install_github("softloud/neet")
library(neet)

# zeta beta ---------------------------------------------------------------
test_prop <- runif(1, 0.3, 0.8)
test_error <- runif(1, 0.1, 0.2)

test_that(
  "beta_par", {
    expect_neet(beta_par(proportion = 0.3, error = 0.2), "list")
  }
)

test_that("intervention_proportion", {
  expect_neet(intervention_proportion(3, 0.5, 0.1), "numeric")
})

test_that("intervention_proportion", {
  expect_neet(intervention_proportion(4, 0.2, 0.01), "numeric")
})


# sims data ---------------------------------------------------------------

sims <- metasims(progress = FALSE)

# simulation functions ----------------------------------------------------


test_that(
  "density function", {
    expect_neet(density_fn(0.1, "norm", list(mean = 3, sd = 0.4)), "numeric")
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
  expect_is(default_parameters, "data.frame")
})


test_that("lr_se", {
  expect_neet(lr_se("median", 4, 3, 0.2, 5, 4.1, 0.3), "numeric")
  expect_neet(lr_se("mean", 4, 3, 0.2, 5, 4.1, 0.3), "numeric")
})

test_that("metamodel", {
  expect_neet(metamodel(), "data.frame")
})

test_that("metasim", {
  expect_neet(metasim(), "data.frame")
})

test_that("metasims", {
  expect_neet(sims, "metasim")
})

test_that("metatrial", {
  expect_neet(metatrial(), "data.frame")
})

test_that("sim_df", {
  expect_neet(sim_df(), "data.frame")
})

test_that("sim_n", {
  expect_neet(sim_n(), "data.frame")

})

test_that("sim_sample", {
  expect_neet(sim_sample(), "numeric")
})

test_that("sim_stats", {
  expect_neet(sim_stats(), "data.frame")
})

# test reporting ----------------------------------------------------------

test_that("coverage plot", {
  covplot <- sims %>% coverage_plot()

  expect_neet(covplot, "ggplot")
})

