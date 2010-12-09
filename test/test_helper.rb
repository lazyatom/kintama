$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require 'test/unit'

ENV["KINTAMA_EXPLICITLY_DONT_RUN"] = "true"
require 'kintama'

require 'stringio'

class Kintama_TestUnit_TestCase < Test::Unit::TestCase
  def setup
    Kintama.reset
  end

  def test_an_empty_test_so_that_test_unit_doesnt_complain
    # stupid no-op test
  end

  private

  module ::Kernel
    def capture_stdout
      out = StringIO.new
      $stdout = out
      yield
      out.rewind
      return out
    ensure
      $stdout = STDOUT
    end
  end

  def assert_output(expected, &block)
    output = capture_stdout(&block).read
    if expected.is_a?(Regexp)
      assert_match expected, output
    else
      assert_equal expected, output
    end
  end
end