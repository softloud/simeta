context("metasims")

set.seed(38)

trials <- 10

default_metasims <-
  metasims(progress = FALSE, trials = trials) %>%
  pluck("results")

test_that("default trial_fn metatrial", {
  expect_is(default_metasims, "data.frame")
  expect_true(nrow(default_metasims) > 0)
  expect_true("k" %in% colnames(default_metasims))
  expect_true("id" %in% colnames(default_metasims))
  expect_true("effect_ratio" %in% colnames(default_metasims))
})

test_that("coverage is as expected", {
  expect_lt(default_metasims %>% pluck("coverage") %>% mean(), 1.0001)
  expect_gt(default_metasims %>% pluck("coverage") %>% mean(), 0.80)
})
