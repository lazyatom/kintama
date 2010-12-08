$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require 'test/unit'

ENV["JTEST_EXPLICITLY_DONT_RUN"] = "true"
require 'jtest'

class JTest_TestUnit_TestCase < Test::Unit::TestCase
  def setup
    JTest.reset
  end

  def test_an_empty_test_so_that_test_unit_doesnt_complain
    # stupid no-op test
  end
end