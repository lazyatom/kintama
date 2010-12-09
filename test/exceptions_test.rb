require 'test_helper'

class ExceptionsTest < Kintama_TestUnit_TestCase

  def test_should_capture_exceptions_in_tests_as_failing_tests
    x = context "Given a test" do
      should "that raises an exception" do
        raise "aaargh"
      end
    end
    x.run
    assert !x.passed?
  end

  def test_should_capture_exceptions_in_setups_as_failing_tests
    x = context "Given a test with setup that fails" do
      setup do
        raise "aargh"
      end
      should "that would otherwise pass" do
        assert true
      end
    end
    x.run
    assert !x.passed?
  end

  def test_should_capture_exceptions_in_teardowns_as_failing_tests
    x = context "Given a test with teardown that fails" do
      teardown do
        raise "aargh"
      end
      should "that would otherwise pass" do
        assert true
      end
    end
    x.run
    assert !x.passed?
  end
end