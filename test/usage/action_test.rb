require 'test_helper'

class ActionTest < KintamaIntegrationTest

  def test_should_run_action_between_setup_and_test
    context "Given an action" do
      setup do
        @thing = 123
      end
      action do
        @thing += 1
      end
      it "should have called the action" do
        assert @thing == 124
      end
    end.
    should_output(%{
      Given an action
        it should have called the action
    }).
    and_pass
  end

  def test_should_run_action_after_all_setups
    context "Given an action" do
      setup do
        @thing = 123
      end
      setup do
        @thing *= 2
      end
      action do
        @thing += 1
      end
      it "should have called the action after all setups" do
        assert @thing == 247
      end
    end.
    should_output(%{
      Given an action
        it should have called the action after all setups
    }).
    and_pass
  end

  def test_should_run_action_after_setups_in_nested_contexts
    context "Given an action" do
      setup do
        @thing = 123
      end
      action do
        @thing += 1
      end
      it "should have called the action after the first setup for outer tests" do
        assert @thing == 124
      end
      context "and a setup in a nested context" do
        setup do
          @thing *= 2
        end
        it "should have called the action after all setups" do
          assert @thing == 247
        end
      end
    end.
    should_output(%{
      Given an action
        it should have called the action after the first setup for outer tests: .
        and a setup in a nested context
          it should have called the action after all setups
    }).
    and_pass
  end
end
