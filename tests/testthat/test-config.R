require(testthat)

test_that('Configuration fails', {
  expect_error(config('hello'))
  expect_error(config(connectionString='hello', appId="hello"))
  expect_error(config(connectionString='InstrumentationKey=hello', appId="hello"))
  config(connectionString="InstrumentationKey=abc;IngestionEndpoint=abc", appId="hello")
  expect_error(
    config(connectionString="InstrumentationKey=abc;IngestionEndpoint=abc", appId=123),
    regexp = "rlang::is_string(x = appId) is not TRUE", fixed=TRUE
  )

})
