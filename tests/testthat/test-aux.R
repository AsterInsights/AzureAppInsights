require(testthat)

test_that('We can recognize instrumentation keys', {
  expect_true(is_instrumentation_key('00000000-0000-0000-0000-000000000000'))  ## well, technically....
  expect_true(is_instrumentation_key('12345678-abcd-ef91-2345-678910abcdef'))
  expect_false(is_instrumentation_key('12345678-abcd-ef91-2345-xyz910abcdef'))  ## CSI-type hex keys
  expect_false(is_instrumentation_key('sdfsdfsdsdfs-:@0-0000-0000-000000000000'))
})
