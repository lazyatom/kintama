require 'test_helper'

class ActionTest < Test::Unit::TestCase

  def test_should_run_action_between_setup_and_test
    c = context "Given an action" do
      setup do
        @thing = 123
      end
      action do
        @thing += 1
      end
      it "should have called action" do
        assert @thing == 124
      end
    end
    c.run
    assert c.passed?
  end

  def test_should_run_action_after_all_setups
    c = context "Given an action" do
      setup do
        @thing = 123
      end
      setup do
        @thing *= 2
      end
      action do
        @thing += 1
      end
      it "should have called action after all setups" do
        assert @thing == 247
      end
    end
    c.run
    assert c.passed?
  end

  def test_should_run_action_after_setups_in_nested_contexts
    c = context "Given an action" do
      setup do
        @thing = 123
      end
      action do
        @thing += 1
      end
      context "and a setup in a nested context" do
        setup do
          @thing *= 2
        end
        it "should have called action after all setups" do
          assert @thing == 247
        end
      end
      it "should have called action after the first setup for outer tests" do
        assert @thing == 124
      end
    end
    c.run
    assert c.passed?
  end
end
