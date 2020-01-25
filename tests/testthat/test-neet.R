context("non-empty thing of expected type")

# perhaps make this a method?
expect_neet <- function(fn_output, output_class = "numeric") {
  # test to see if na
  expect_false(any(is.na(fn_output)))
  expect_false(is.null(fn_output))

  # infs
  expect_false(
    any(abs(as.numeric(fn_output)) == Inf))

  # non-empty
  expect_true(length(fn_output) > 0)

  # expected type
  expect_is(fn_output, output_class)
}

# zeta beta ---------------------------------------------------------------
test_prop <- runif(1, 0.3, 0.8)
test_error <- runif(1, 0.1, 0.2)

test_that(
  "beta_par", {
    expect_neet(beta_par(proportion = 0.3, error = 0.2), "list")
    expect_neet(beta_par(proportion = test_prop, error = test_error), "list")
  }
)

test_that("intervention_proportion", {

})

test_that("zeta_plot", {

})


# sims data ---------------------------------------------------------------

sims <- metasims()


# plot functions ----------------------------------------------------------


test_that(
  "coverage_plot", {
    expect_true("ggplot" %in% (sims %>% coverage_plot() %>% class()))
  }
)


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

test_that("default_sim_pars", {

})

test_that("estimator_comparison", {

})

test_that("intervention_proportion", {

})

test_that("lr_se", {

})

test_that("metafor_converge", {

})

test_that("metamodel", {

})

test_that("metasim", {

})

test_that("metasims", {

})

test_that("metatrial", {

})

test_that("sim_df", {

})

test_that("sim_dist", {

})

test_that("sim_n", {

})

test_that("simpar_table", {

})

test_that("sim_sample", {

})

test_that("sim_stats", {

})

test_that("simulation_methods", {

})

test_that("simulation_parameters", {

})

test_that("singletrial", {

})

test_that("tidy_sim", {

})

test_that("toss", {

})

