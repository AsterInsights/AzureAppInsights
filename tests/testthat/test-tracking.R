require(testthat)

mockSession <- list(sendCustomMessage=function(name, message) {})
test_that('names are checked', {
  expect_error(check_name(1))
  expect_error(check_name())

  expect_error(check_names(c('foo','bar')))
})

test_that('properties are checked', {
  expect_equal(check_properties(), list())
  expect_equal(check_properties(NULL), list())
  expect_equal(check_properties(list('foo'='bar')), list('foo'='bar'))
  expect_equal(check_properties(list(`2`='bar')), list(`2`='bar'))
  expect_equal(check_properties(list('letters'=letters)), list('letters'=letters))

  expect_error(check_properties(list('foo')))
  expect_error(check_properties(1))
  prop <- list('bar')
  names(prop) <- ''
  expect_error(check_properties(prop))
})

test_that("trackEvent handles arguments", {
  expect_s3_class(trackEvent(mockSession, "hello"), "json")
  expect_equal(as.character(trackEvent(mockSession, "hello")),
    "{\"name\":\"hello\",\"properties\":[]}"
  )

  expect_equal(as.character(trackEvent(mockSession, "hello", list('foo'='bar'))),
    '{"name":"hello","properties":{"foo":"bar"}}'
  )

  # checks
  expect_error(trackEvent(mockSession, 1L))
  expect_error(trackEvent(mockSession, "hello", 1L))
})


test_that("trackMetric handles arguments", {

  expect_null(trackMetric(mockSession, "hello", numeric(0)))
  json <- expect_s3_class(trackMetric(mockSession, "hello", 1L), "json")
  baselist <- jsonlite::fromJSON(json)

  expect_equal(baselist,
    list(name='hello', metrics=list(average=1, range1=1, range2=1, count=1, stdDev=0), properties=list())
  )

  expect_null(trackMetric(mockSession, "hello", NA_integer_))
  expect_null(trackMetric(mockSession, "hello", c(NA_real_, Inf, -Inf)))
  expect_equal(trackMetric(mockSession, 'hello', c(NA_real_, -Inf, Inf, 1)), json)

  # checks
  expect_error(trackMetric(mockSession, 1L))
  expect_error(trackMetric(mockSession, "hello", 1L, properties=1L))
})
