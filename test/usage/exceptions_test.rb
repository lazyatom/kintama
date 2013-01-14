require 'test_helper'

class ExceptionsTest < KintamaIntegrationTest

  def test_should_capture_exceptions_in_tests_as_failing_tests
    context "Given a test" do
      should "fail when there is an exception" do
        raise "aaargh"
      end
    end.
    should_output(%{
      Given a test
        should fail when there is an exception: F
    }).
    and_fail
  end

  def test_should_capture_exceptions_in_setups_as_failing_tests
    context "Given a test with setup that fails" do
      setup do
        raise "aargh"
      end
      should "fail even though it would otherwise pass" do
        assert true
      end
    end.
    should_output(%{
      Given a test with setup that fails
        should fail even though it would otherwise pass: F
    }).
    and_fail
  end

  def test_should_capture_exceptions_in_teardowns_as_failing_tests
    context "Given a test with teardown that fails" do
      teardown do
        raise "aargh"
      end
      should "fail even though it would otherwise pass" do
        assert true
      end
    end.
    should_output(%{
      Given a test with teardown that fails
        should fail even though it would otherwise pass: F
    }).
    and_fail
  end
end
