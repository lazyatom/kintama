require 'test_helper'

class ContextTest < Test::Unit::TestCase
  def test_should_clear_previous_failure_when_running_test_again
    $thing = 456
    x = context "Given something" do
      should "work" do
        assert_equal 123, $thing
      end
    end
    assert_equal false, x.run
    $thing = 123
    assert_equal true, x.run
  end
end
