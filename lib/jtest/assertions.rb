module JTest
  module Assertions
    def assert(expression, message="failed")
      raise JTest::TestFailure, message unless expression
    end

    def flunk
      assert false, "flunked."
    end

    def assert_equal(expected, actual, message="Expected #{expected.inspect} but got #{actual.inspect}")
      assert actual == expected, message
    end

    def assert_not_equal(expected, actual, message)
      assert actual != expected, message
    end

    def assert_nil(object, message="#{object.inspect} was not nil")
      assert_equal nil, object, message
    end

    def assert_not_nil(object, message="should not be nil")
      assert_not_equal nil, object, message
    end

    def assert_kind_of(klass, thing, message="should be a kind of #{klass}")
      assert thing.is_a?(klass)
    end

    def assert_raises(message="should raise an exception", &block)
      yield
      raise JTest::TestFailure, message
    rescue
      # do nothing, we expected this, but now no TestFailure was raised.
    end
  end
end