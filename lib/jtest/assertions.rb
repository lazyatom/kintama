module JTest
  module Assertions
    def assert(expression, message="failed")
      raise JTest::TestFailure, message unless expression
    end

    def flunk
      assert false
    end

    def assert_equal(expected, actual)
      assert actual == expected, "Expected #{expected.inspect} but got #{actual.inspect}"
    end

    def assert_raises(message="should raise an exception", &block)
      yield
      raise JTest::TestFailure, message
    rescue
      # do nothing, we expected this, but now no TestFailure was raised.
    end
  end
end