require 'test_helper'

class ActionTest < KintamaIntegrationTest

  def test_should_run_action_between_setup_and_test
    context "Given a context with an `action`" do
      setup do
        @thing = 123
      end

      action do
        @thing += 1
      end

      it "should have called the action between the `setup` and the test" do
        assert @thing == 124
      end
    end.
    should_output(%{
      Given a context with an `action`
        it should have called the action between the `setup` and the test: .
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

      it "should have called the action after all setup blocks" do
        assert @thing == 247
      end
    end.
    should_output(%{
      Given an action
        it should have called the action after all setup blocks
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
        it "should have called the action after both outer and inner setups" do
          assert @thing == 247
        end
      end
    end.
    should_output(%{
      Given an action
        it should have called the action after the first setup for outer tests: .
        and a setup in a nested context
          it should have called the action after both outer and inner setups: .
    }).
    and_pass
  end

  def test_should_allow_subcontexts_to_change_parameters_used_in_action
    context "A doubling action" do
      action do
        @result = @parameter * 2
      end

      context "when the parameter is 2" do
        setup do
          @parameter = 2
        end

        should "result in 4" do
          assert_equal 4, @result
        end
      end

      context "when the parameter is 3" do
        setup do
          @parameter = 3
        end

        should "result in 6" do
          assert_equal 6, @result
        end
      end
    end.
    should_output(%{
      A doubling action
        when the parameter is 2
          should result in 4: .
        when the parameter is 3
          should result in 6: .
    }).
    and_pass
  end
end
