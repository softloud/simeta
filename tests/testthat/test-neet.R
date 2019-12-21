context("non-empty thing of expected type")

# perhaps make this a method?
expect_neet <- function(fn_output, output_class = "numeric") {
  # test to see if na
  expect_false(is.na(fn_output))
  expect_false(is.null(fn_output))

  # non-empty
  expect_true(length(fn_output) > 0)

  # expected type
  expect_is(fn_output, output_class)
}

test_prop <- runif(1, 0.3, 0.8)
test_error <- runif(1, 0.1, 0.2)

test_that({
  "beta_par"
},
expect_neet(beta_par(proportion = 0.3, error = 0.2), "list")
# expect_neet(beta_par(proportion = test_prop, error = test_error), "list"))
)
