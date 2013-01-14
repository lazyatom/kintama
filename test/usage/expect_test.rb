require 'test_helper'

class ExpectTest < KintamaIntegrationTest

  def setup
    # reload mocha because the reset removes the extensions
    require 'kintama/mocha'
  end

  def test_should_allow_setting_of_expectations_in_tests
    context "Given an expectation" do
      setup do
        @thing = stub('thing')
      end

      expect "blah to be called" do
        @thing.expects(:blah)
        @thing.blah
      end
    end.
    should_output(%{
      Given an expectation
        expect blah to be called
    }).
    and_pass
  end

  def test_should_report_failed_expectations_as_failures
    context "Given an expectation" do
      setup do
        @thing = stub('thing')
      end

      expect "blah to be called" do
        @thing.expects(:blah)
      end
    end.
    should_output(%{
      unsatisfied expectations:
      - expected exactly once, not yet invoked: #<Mock:thing>.blah
    }).
    and_fail
  end

  def test_should_set_expectations_before_action_is_called
    context "Given an action" do
      setup do
        @thing = stub('thing')
      end
      action do
        @thing.go
      end
      expect "go to be called on thing" do
        @thing.expects(:go)
      end
    end.
    should_output(%{
      Given an action
        expect go to be called on thing
    }).
    and_pass
  end

  def test_should_not_set_expectations_for_normal_tests_defined_near_the_expect
    context "Given an expectation" do
      setup do
        @thing = [1,2,3]
      end

      expect "blah to be called" do
        @thing.expects(:join)
        @thing.join
      end

      it "should retain original behaviour in other tests" do
        assert_equal "123", @thing.join
      end
    end.should_output(%{
      Given an expectation
        it should retain original behaviour in other tests: .
        expect blah to be called: .
    }).
    and_pass
  end
end
