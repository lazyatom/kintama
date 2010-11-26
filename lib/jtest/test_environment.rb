module JTest
  class TestEnvironment
    def initialize(context)
      @__context = context
    end

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

    def method_missing(*args, &block)
      @__context.send(*args, &block)
    end

    def respond_to?(name)
      @__context.respond_to?(name)
    end
  end
end