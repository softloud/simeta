context("neet: non-empty thing of expected type")

# datasets ----------------------------------------------------------------

test_that("default parameters", {
  expect_is(default_parameters, "data.frame")
})

# beta --------------------------------------------------------------------

test_prop <- runif(1, 0.3, 0.8)
test_error <- runif(1, 0.1, 0.2)

test_that("beta_par", {
  expect_type(beta_par(proportion = 0.3, error = 0.2), "list")
})

test_that("intervention_proportion", {
  expect_type(intervention_proportion(3, 0.5, 0.1), "double")
})

test_that("intervention_proportion", {
  expect_type(intervention_proportion(4, 0.2, 0.01), "double")
})

test_that("ggplot", {
  expect_s3_class(zeta_plot(0.2, 0.1), "ggplot")
})


# sims data ---------------------------------------------------------------

sims <- metasims(progress = FALSE)

# simulation functions ----------------------------------------------------

test_that("density function", {
  expect_type(density_fn(0.1, "norm", list(mean = 3, sd = 0.4)), "double")
})

test_that("dist_name", {
  expect_type(dist_name("norm"), "character")
})

test_that("default_parameters", {
  expect_is(default_parameters, "data.frame")
})


test_that("lr_se", {
  expect_type(lr_se("median", 4, 3, 0.2, 5, 4.1, 0.3), "double")
  expect_type(lr_se("mean", 4, 3, 0.2, 5, 4.1, 0.3), "double")
})

test_that("metamodel", {
  expect_is(metamodel(), "data.frame")
})

test_that("metasim", {
  expect_is(metasim(), "data.frame")
})

test_that("metasims", {
  expect_is(sims, "metasim")
})

test_that("metatrial", {
  expect_is(metatrial(), "data.frame")
})

test_that("sim_df", {
  expect_is(sim_df(), "data.frame")
})

test_that("sim_n", {
  expect_is(sim_n(), "data.frame")

})

test_that("sim_sample", {
  expect_type(sim_sample(), "double")
})

test_that("sim_stats", {
  expect_is(sim_stats(), "data.frame")
  expect_is(
    sim_stats() %>%
      metafor::rma(yi = effect, vi = effect_spread, data = .) %>%
      tidy_sim()
    ,
    "data.frame"
  )
})


# # reporting ----------------------------------------------------------

test_that("coverage plot", {
  covplot <- sims %>% coverage_plot()

  expect_s3_class(covplot, "ggplot")
})
