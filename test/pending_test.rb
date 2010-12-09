require 'test_helper'

class PendingTest < Kintama_TestUnit_TestCase
  
  def test_should_pass_any_pending_tests
    c = context "Given a context" do
      test "that is not implemented"
    end
    c.run
    assert c.passed?
  end

end