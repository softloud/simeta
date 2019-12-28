context("Smoosh together a density fn")

# types of density functions
types <- c("d", "r", "p", "q")

# fuzz testing parmaters
whole_num <- sample(seq(1:100), size = 1)
part_num <- runif(1, 0, 1)

expect_neet <- function(dist, par) {
  expect_is(density_fn(
    x = 0.5,
    distribution = dist,
    parameters = par,
    type = "d"
  ),
  "numeric")
  expect_is(density_fn(
    x = 3,
    distribution = dist,
    parameters = par,
    type = "r"
  ),
  "numeric")
  expect_is(density_fn(
    x = 0.5,
    distribution = dist,
    parameters = par,
    type = "p"
  ),
  "numeric")
  expect_is(density_fn(
    x = 0.5,
    distribution = dist,
    parameters = par,
    type = "q"
  ),
  "numeric")
}


test_that("Density works for normal distributions", {
  expect_neet(dist = "norm", par = list(mean = 30, sd = 0.3))
  expect_neet(dist = "norm",
              par = list(mean = whole_num, sd = part_num))
})

test_that("Density works for exponential distributions", {
  expect_neet(dist = "exp", par = list(rate = 2))
  expect_neet(dist = "exp", par = list(rate = whole_num))
  expect_neet(dist = "exp", par = list(rate = part_num))
})

test_that("Density works for pareto distributions", {
  expect_neet(dist = "pareto", par = list(shape = 30, scale = 0.3))
  expect_neet(dist = "pareto",
              par = list(shape = whole_num, scale = part_num))
})

test_that("Density works for lnorm distributions", {
  expect_neet(dist = "lnorm", par = list(meanlog = 30, sdlog = 0.3))
  expect_neet(dist = "lnorm",
              par = list(meanlog = whole_num, sdlog = part_num))
})
