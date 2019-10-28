context("find out which function is throwing an error in the pipeline")


test_that("error", {
  expect_error(metasims())
})
