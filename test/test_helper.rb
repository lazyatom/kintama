$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require 'test/unit'

ENV["KINTAMA_EXPLICITLY_DONT_RUN"] = "true"
require 'kintama'

class Kintama_TestUnit_TestCase < Test::Unit::TestCase
  def setup
    Kintama.reset
  end

  def test_an_empty_test_so_that_test_unit_doesnt_complain
    # stupid no-op test
  end
end