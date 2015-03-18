require "set"
require "stringio"

module Kintama
  module Assertions
    def assert(expression, message="failed")
      raise Kintama::TestFailure, message unless expression
    end

    def flunk(message="flunked.")
      assert false, message
    end

    def assert_equal(expected, actual, message="Expected #{expected.inspect} but got #{actual.inspect}")
      assert actual == expected, message
    end

    def assert_not_equal(expected, actual, message="Expected #{expected.inspect} to not be equal to #{actual.inspect}")
      assert actual != expected, message
    end

    def assert_nil(object, message="#{object.inspect} was not nil")
      assert_equal nil, object, message
    end

    def assert_not_nil(object, message="should not be nil")
      assert_not_equal nil, object, message
    end

    def assert_match(regexp, string, message="expected #{string.inspect} to match #{regexp.inspect}")
      assert (string =~ regexp), message
    end

    def assert_no_match(regexp, string, message="expected #{string.inspect} not to match #{regexp.inspect}")
      assert !(string =~ regexp), message
    end

    def assert_kind_of(klass, thing, message="should be a kind of #{klass}")
      assert thing.is_a?(klass), message
    end

    def assert_same(expected, actual, message="Expected #{expected.inspect} (oid=#{expected.object_id}) to be the same as #{actual.inspect} (oid=#{actual.object_id})")
      assert actual.equal?(expected), message
    end

    def assert_same_elements(expected, object, message = "#{object.inspect} does not contain the same elements as #{expected.inspect}")
      assert Set.new(expected) == Set.new(object), message
    end

    def assert_nothing_raised(message="should not raise anything", &block)
      yield
    rescue Exception => e
      raise Kintama::TestFailure, message + " (#{e} was raised)"
    end

    def assert_raises(klass_or_message=Exception, message="should raise an exception", &block)
      if klass_or_message.respond_to?(:ancestors)
        klass = klass_or_message
      else
        message = klass_or_message
        klass = Exception
      end
      yield
      raised = false
    rescue => e
      if e.class.ancestors.include?(klass)
        raised = true
      else
        raised = false
      end
    ensure
      raise Kintama::TestFailure, message unless raised
    end

    def assert_output(expected, message="Expected output to match #{expected.inspect}", &block)
      output = capture_output(&block).read.strip
      if expected.is_a?(Regexp)
        assert_match expected, output, message
      else
        assert_equal expected, output, message
      end
    end

    def assert_not_output(not_expected, message="Expected output not to match #{not_expected.inspect}", &block)
      output = capture_output(&block).read.strip
      if not_expected.is_a?(Regexp)
        assert_no_match not_expected, output, message
      else
        assert_not_equal not_expected, output, message
      end
    end

    private

    def capture_output(&block)
      out = StringIO.new
      $stdout = out
      yield
      out.rewind
      return out
    ensure
      $stdout = STDOUT
    end
  end
end
